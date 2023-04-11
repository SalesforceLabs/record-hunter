import {LightningElement, api, wire} from "lwc";

import getFieldInfos from "@salesforce/apex/SchemaDataService.getFieldInfos";

export default class FilterCardClassic extends LightningElement {
  // Reserved Public Properties
  @api recordId;
  @api objectApiName;

  // Public Properties
  @api cardTitle = "Filter";
  @api cardIconName = "custom:custom57";
  @api targetObjectApiName = "Opportunity";
  @api targetFieldApiNames = "Id";
  @api numberOfColumns = "2";
  @api showObjectNames = false;
  @api showFieldIndex = false;
  @api defaultValuesOrFields = "";
  @api customLogic = "";
  @api showSearchButton = false;
  @api searchButtonLabel;
  @api order = "2";
  @api cardVariant;

  // Private Properties
  componentId;
  sourceComponentIds;
  config;
  targetObjectName;
  hasConfigurationError;
  hasRuntimeError;
  errorTitle;
  errorMessage;
  isCardFoldable;
  isCardOpen;
  iconName;
  fields;
  get cardBodyClass() {
    const classList = ["slds-card__body"];
    if (this.isCardOpen) {
      classList.push("slds-is-expanded");
    } else {
      classList.push("slds-is-collapsed");
    }
    return classList.join(" ");
  }

  @wire(getFieldInfos, {objectApiName: "$objectApiName", fieldApiNames: "$defaultValuesOrFields", skipError: true})
  getContextRecordFieldInfosCallback({data, error}) {
    if (data && !data.hasError) {
      this.contextRecordFieldInfos = data.body;
      if (this.filterFieldInfos) {
        this.defaultValues = this.buildDefaultValues();
        this.fields = this.buildFields();
      }
    } else if (data && data.hasError) {
      this.defaultValue = this.defaultValuesOrFields;
    } else if (error) {
      this.showConfigurationError(error);
    }
  }

  @wire(getFieldInfos, {
    objectApiName: "$targetObjectApiName",
    fieldApiNames: "$targetFieldApiNames",
    skipError: false
  })
  getFilterFieldInfosCallback({error, data}) {
    if (data && !data.hasError) {
      this.filterFieldInfos = data.body;
      if ((this.recordId && this.contextRecordFieldInfos) || !this.recordId) {
        this.defaultValues = this.buildDefaultValues();
        this.fields = this.buildFields();
      }
    } else if (data && data.hasError) {
      this.showConfigurationError(data.errorMessage);
    } else if (error) {
      this.showConfigurationError(error);
    }
  }

  connectedCallback() {
    this.componentId = this.order;
    this.sourceComponentIds = parseInt(this.order) - 1 > 0 ? parseInt(this.order) - 1 + "" : "";

    const numOfCols = parseInt(this.numberOfColumns, 10);
    this.columnSize = 0 < numOfCols && numOfCols <= 12 ? 12 / numOfCols : 6;

    if (this.cardVariant === "Open") {
      this.isCardFoldable = true;
      this.isCardOpen = true;
      this.iconName = "utility:chevrondown";
    } else if (this.cardVariant === "Close") {
      this.isCardFoldable = true;
      this.isCardOpen = false;
      this.iconName = "utility:chevronright";
    } else {
      this.isCardFoldable = false;
      this.iconName = this.cardIconName;
      this.isCardOpen = true;
    }
  }

  errorCallback(error, stack) {
    if (error.name === "RecordHunterRuntimeError") {
      this.showRuntimeError(error.message);
    } else if (error.name === "RecordHunterConfigurationError") {
      this.showConfigurationError(error.message);
    } else {
      console.error(error);
      console.error(stack);
    }
  }

  onFoldButtonClicked() {
    if (this.isCardOpen) {
      this.isCardOpen = false;
      this.iconName = "utility:chevronright";
    } else {
      this.isCardOpen = true;
      this.iconName = "utility:chevrondown";
    }
  }

  onAlertClosed() {
    this.hasRuntimeError = false;
    this.errorMessage = null;
  }

  //  Helpers
  showConfigurationError(error) {
    this.hasConfigurationError = true;
    this.errorTitle = "Component Configuration Error";
    let errorMessage = "";
    if (typeof error === "string") {
      errorMessage = error;
    } else if (Array.isArray(error.body)) {
      errorMessage = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      errorMessage = error.body.message;
    }
    this.errorMessage = errorMessage;
  }

  showRuntimeError(error) {
    this.hasRuntimeError = true;
    let errorMessage = "";
    if (typeof error === "string") {
      errorMessage = error;
    } else if (Array.isArray(error.body)) {
      errorMessage = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      errorMessage = error.body.message;
    }
    this.errorMessage = errorMessage;
  }

  buildDefaultValues() {
    const contextRecordFieldInfos = this.contextRecordFieldInfos;
    const defaultValuesOrFields = this.defaultValuesOrFields || "";
    const defaultValueOrFieldList = defaultValuesOrFields.split(",");
    if (contextRecordFieldInfos) {
      for (let contextRecordFieldInfo of contextRecordFieldInfos) {
        defaultValueOrFieldList[contextRecordFieldInfo.index] = {source: "context", fieldName: contextRecordFieldInfo.name};
      }
    }

    const filterFieldInfos = this.filterFieldInfos;
    const defaultValues = [];
    if (filterFieldInfos) {
      for (let i = 0, j = 0; i < filterFieldInfos.length; i++, j++) {
        const defaultValue = {};
        if (["INTEGER", "PERCENT", "CURRENCY", "DOUBLE", "DATETIME", "DATE", "TIME"].includes(filterFieldInfos[i].type)) {
          if (j < defaultValueOrFieldList.length) {
            defaultValue.minValue = defaultValueOrFieldList[j];
            j++;
          }
          if (j < defaultValueOrFieldList.length) {
            defaultValue.maxValue = defaultValueOrFieldList[j];
          }
        } else {
          if (j < defaultValueOrFieldList.length) {
            defaultValue.value = defaultValueOrFieldList[j];
          }
        }
        defaultValues.push(defaultValue);
      }
    }
    return defaultValues;
  }

  buildFields() {
    const filterFieldInfos = this.filterFieldInfos;
    const showObjectName = this.showObjectNames;
    const showIndex = this.showFieldIndex;
    const columnSize = this.columnSize;
    const defaultValues = this.defaultValues;
    const fields = [];

    for (let fieldInfo of filterFieldInfos) {
      const index = fieldInfo.index;
      const field = {
        index,
        name: fieldInfo.path,
        showObjectName,
        showIndex,
        columnSize,
        default: defaultValues[index]
      };
      fields.push(field);
    }
    return fields;
  }
}
