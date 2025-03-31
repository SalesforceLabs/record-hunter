import { LightningElement, api, wire } from "lwc";
import getInputInfos from "@salesforce/apex/FilterDataService.getInputInfos";
import filterRecordIds from "@salesforce/apex/FilterDataService.filterRecordIds";
import queryRecordIds from "@salesforce/apex/FilterDataService.queryRecordIds";
import getRecord from "@salesforce/apex/FilterDataService.getRecord";

import MessageService from "c/messageService";
import { throwConfigurationError, throwRuntimeError } from "c/errorService";

const DEFAULT_COLUMN_SIZE = 6;

export default class Filter extends LightningElement {
  @api objectName;
  @api componentId;
  @api sourceComponentIds;
  @api targetComponentIds;
  @api recordId;
  @api get fields() {
    return this._fields;
  }
  set fields(value) {
    this._fields = value || [];
    this.setAttribute("fields", this._fields);
  }
  @api
  get customLogic() {
    const inputIndexList = [];
    for (let field of this.fields) {
      inputIndexList.push(field.index + 1);
    }

    return this._customLogic ? this._customLogic : inputIndexList.join(" AND ");
  }
  set customLogic(value) {
    this._customLogic = value;
    this.setAttribute("customLogic", this._customLogic);
  }

  @api
  search() {
    const params = {
      objectApiName: this._targetObjectName,
      fieldApiNames: this._targetFieldNames,
      formDataJson: JSON.stringify(this._formData),
      customLogic: this.customLogic
    };

    this._showSpinner = true;
    queryRecordIds(params)
      .then((result) => {
        if (result && !result.hasError) {
          this.messageService.publishStatusChangedToCompleted(result.body);
          this._showSpinner = false;
        } else if (result && result.hasError) {
          this._showSpinner = false;
          throwRuntimeError(result.errorMessage, result.errorCode);
        }
      })
      .catch((error) => {
        this._showSpinner = false;
        throwRuntimeError(error);
      });
  }

  _targetObjectName;
  _targetFieldNames;
  _inputs = [];
  _showSpinner = false;
  get _formData() {
    const formData = {};
    for (let input of this._inputs) {
      const inputElement = this.template.querySelector(
        '[data-key="' + input.key + '"]'
      );
      const value = inputElement.value;
      if (value) {
        formData[input.name] = value;
      }
    }

    return formData;
  }

  @wire(getInputInfos, {
    objectApiName: "$_targetObjectName",
    fieldApiNames: "$_targetFieldNames"
  })
  wiredGetInputInfos({ error, data }) {
    if (data && !data.hasError) {
      this._inputInfos = data.body;
      this._inputs = this._buildInputs(
        this.fields,
        this._inputInfos,
        this._defaultValues
      );
      this._isInputUpdated = true;
    } else if (data && data.hasError) {
      throwConfigurationError(data.errorMessage, data.errorCode);
    } else if (error) {
      throwConfigurationError(error);
    }
  }

  connectedCallback() {
    this.messageService = new MessageService(this, this.targetComponentIds);
    this.messageService.subscribeStatusChangedToCompleted(
      this.onStatusChangedToCompleted.bind(this)
    );

    this._targetObjectName = this.objectName;

    this._targetFieldNames = this._buildTargetFieldNames(this.fields);

    this._buildDefaultValues(this.recordId, this.fields).then(
      (defaultValues) => {
        this._defaultValues = defaultValues;
        this._inputs = this._buildInputs(
          this.fields,
          this._inputInfos,
          this._defaultValues
        );
        this._isInputUpdated = true;
      }
    );
    this._customLogic = this.customLogic;
  }
  renderedCallback() {
    if (this._isInputUpdated) {
      this._isInputUpdated = false;
      this.messageService.publishStatusChangedToReady();
    }
  }
  disconnectedCallback() {
    this.messageService.unsubscribeAll();
  }

  onStatusChangedToCompleted({ data, errors }) {
    if (errors) {
      console.error(errors);
      throwRuntimeError(errors);
      return;
    }

    const params = {
      objectApiName: this._targetObjectName,
      fieldApiNames: this._targetFieldNames,
      formDataJson: JSON.stringify(this._formData),
      recordIds: data?.join(","),
      customLogic: this._customLogic
    };

    this._showSpinner = true;
    (data ? filterRecordIds(params) : queryRecordIds(params))
      .then((response) => {
        if (response && !response.hasError) {
          this.messageService.publishStatusChangedToCompleted(response.body);
          this._showSpinner = false;
        } else if (response && response.hasError) {
          this._showSpinner = false;
          throwRuntimeError(response.errorMessage, response.errorCode);
        }
      })
      .catch((e) => {
        this._showSpinner = false;
        throwRuntimeError(e);
      });
  }

  _buildInputs(fields, inputInfos, defaultValues) {
    const inputs = [];
    if (inputInfos && defaultValues) {
      for (let i = 0; i < fields.length; i++) {
        const field = fields[i];
        const inputInfo = inputInfos[i];
        if (!inputInfo.isFilterable) {
          throwConfigurationError(
            `"${inputInfo.fieldApiName}" is not a filterable field.`
          );
        }
        inputs.push({
          name: inputInfo.fieldApiName,
          label: inputInfo.label,
          type: inputInfo.type,
          step: inputInfo.step,
          options: inputInfo.options,
          key: inputInfo.fieldApiName.replace(".", "-").toLowerCase(),
          objectName: inputInfo.objectInfo.label,
          showIndex: field.showIndex,
          default: defaultValues[i],
          index: i + 1,
          showObjectName: field.showObjectName,
          columnSize: field.columnSize || DEFAULT_COLUMN_SIZE,
          isRelative: inputInfo.isRelative
        });
      }
    }

    return inputs;
  }

  _buildTargetFieldNames(fields) {
    return fields
      .map((field) => {
        return field.name.trim();
      })
      .join(",");
  }

  async _buildDefaultValues(recordId, fields) {
    // Build recordId to field name list map object
    const idFieldMap = {};
    for (let field of fields) {
      if (field.default) {
        const {
          value,
          minValue,
          maxValue,
          timeQualifier,
          timeAmount,
          timeUnit
        } = field.default;
        const fieldNames = [
          value,
          minValue,
          maxValue,
          timeQualifier,
          timeAmount,
          timeUnit
        ]
          .filter((valueItem) => {
            return (
              typeof valueItem === "object" && valueItem.source === "context"
            );
          })
          .map((valueItem) => {
            return valueItem.fieldName;
          });

        if (idFieldMap[recordId] && fieldNames.length > 0) {
          idFieldMap[recordId] = [...idFieldMap[recordId], ...fieldNames];
        } else if (!idFieldMap[recordId] && fieldNames.length > 0) {
          idFieldMap[recordId] = fieldNames;
        }
      }
    }

    // Get records for default values
    const resultPromises = [];
    for (let recId in idFieldMap) {
      if ({}.hasOwnProperty.call(idFieldMap, recId)) {
        const fieldNames = idFieldMap[recId].join(",");
        resultPromises.push(getRecord({ recordId: recId, fieldNames }));
      }
    }

    let results = [];
    try {
      results = await Promise.all(resultPromises);
    } catch (error) {
      throwConfigurationError(error);
    }

    const records = [];
    for (let result of results) {
      if (!result.hasError) {
        records.push(result.body);
      } else if (result.hasError) {
        throwConfigurationError(result.errorMessage, result.errorCode);
      }
    }

    // Build defaultValues;
    const defaultValues = [];
    for (let field of fields) {
      if (field.default) {
        const {
          value,
          minValue,
          maxValue,
          timeQualifier,
          timeAmount,
          timeUnit
        } = field.default;
        const defaultValue = {};
        const contextRecord =
          records
            .filter((record) => {
              return record.Id === recordId;
            })
            .shift() || {};
        if (value && typeof value === "object" && value.source === "context") {
          defaultValue.value = contextRecord[value.fieldName];
        } else if (value) {
          defaultValue.value = value.trim();
        }
        if (
          minValue &&
          typeof minValue === "object" &&
          minValue.source === "context"
        ) {
          defaultValue.minValue = contextRecord[minValue.fieldName];
        } else if (minValue) {
          defaultValue.minValue = minValue.trim();
        }
        if (
          maxValue &&
          typeof maxValue === "object" &&
          maxValue.source === "context"
        ) {
          defaultValue.maxValue = contextRecord[maxValue.fieldName];
        } else if (maxValue) {
          defaultValue.maxValue = maxValue.trim();
        }
        if (
          timeQualifier &&
          typeof timeQualifier === "object" &&
          timeQualifier.source === "context"
        ) {
          defaultValue.timeQualifier = contextRecord[timeQualifier.fieldName];
        } else if (timeQualifier) {
          defaultValue.timeQualifier = timeQualifier.trim();
        }
        if (
          timeAmount &&
          typeof timeAmount === "object" &&
          timeAmount.source === "context"
        ) {
          defaultValue.timeAmount = contextRecord[timeAmount.fieldName];
        } else if (timeAmount) {
          defaultValue.timeAmount = timeAmount.trim();
        }
        if (
          timeUnit &&
          typeof timeUnit === "object" &&
          timeUnit.source === "context"
        ) {
          defaultValue.timeUnit = contextRecord[timeUnit.fieldName];
        } else if (timeUnit) {
          defaultValue.timeUnit = timeUnit.trim();
        }

        defaultValues.push(defaultValue);
      } else {
        defaultValues.push(null);
      }
    }

    return defaultValues;
  }

  _reduceTokens(tokens, lexemes) {
    const reducedTokens = [];
    if (tokens && tokens.length > 0 && lexemes && lexemes.length > 0) {
      let prev = null;
      let token;
      for (let i = 0; i < tokens.length; i++) {
        token = tokens[i];
        prev =
          reducedTokens.length > 0
            ? reducedTokens[reducedTokens.length - 1]
            : null;
        if (token.kind === "NUM" && !lexemes.includes(token.lexeme)) {
          continue;
        } else if (token.kind === "LOGICALAND") {
          if (prev === null) {
            continue;
          } else if (prev.kind === "RPAREN") {
            reducedTokens.push(token);
          } else if (prev.kind === "NUM") {
            reducedTokens.push(token);
          }
        } else if (token.kind === "LOGICALOR") {
          if (prev === null) {
            continue;
          } else if (prev.kind === "LOGICALAND") {
            reducedTokens[reducedTokens.length - 1] = token;
          } else if (prev.kind === "RPAREN") {
            reducedTokens.push(token);
          } else if (prev.kind === "NUM") {
            reducedTokens.push(token);
          }
        } else if (token.kind === "RPAREN") {
          if (prev === null) {
            continue;
          } else if (prev.kind === "LOGICALAND") {
            reducedTokens[reducedTokens.length - 1] = token;
          } else if (prev.kind === "LOGICALOR") {
            reducedTokens[reducedTokens.length - 1] = token;
          } else if (prev.kind === "RPAREN") {
            reducedTokens.push(token);
          } else if (prev.kind === "LPAREN") {
            reducedTokens.pop();
          } else if (prev.kind === "NUM") {
            reducedTokens.push(token);
          }
        } else if (token.kind === "LPAREN") {
          if (prev === null) {
            reducedTokens.push(token);
          } else if (prev.kind === "LOGICALAND") {
            reducedTokens.push(token);
          } else if (prev.kind === "LOGICALOR") {
            reducedTokens.push(token);
          } else if (prev.kind === "LPAREN") {
            reducedTokens.push(token);
          }
        } else {
          reducedTokens.push(token);
        }
      }
      prev =
        reducedTokens.length > 0
          ? reducedTokens[reducedTokens.length - 1]
          : null;
      if (prev === null) {
        /* empty */
      } else if (prev.kind === "LOGICALAND") {
        reducedTokens.pop();
      } else if (prev.kind === "LOGICALOR") {
        reducedTokens.pop();
      }
    }
    return reducedTokens;
  }
}
