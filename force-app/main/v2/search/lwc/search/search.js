import { api, wire } from "lwc";
import InteractiveLightningElement from "c/interactiveLightningElement";
import searchRecordIds from "@salesforce/apex/SearchDataService.searchRecordIds";
import filterRecordIds from "@salesforce/apex/SearchDataService.filterRecordIds";
import getFieldValueForRecord from "@salesforce/apex/SearchDataService.getFieldValueForRecord";
import { throwConfigurationError, throwRuntimeError } from "c/errorService";

export default class Search extends InteractiveLightningElement {
  // Reserved Public Properties
  @api recordId;
  @api objectApiName;

  // Public Properties
  @api targetObjectApiName;
  @api componentId;
  @api sourceComponentIds;
  @api get defaultValue() {
    return this._defaultValue;
  }
  set defaultValue(value) {
    if (typeof value === "object" && value.source === "context") {
      this.fieldApiName = value.fieldApiName;
    } else if (value) {
      this.defaultKeyword = value;
    }

    this._defaultValue = value;
    this.setAttribute("defaultValue", this._defaultValue);
  }

  // Private Properties
  defaultKeyword;
  showSpinner = false;
  fieldApiName;

  // Public Methods
  @api async search() {
    const keyword = this.template.querySelector("lightning-input").value;
    if (keyword) {
      this.showSpinner = true;
      const params = { objectApiName: this.targetObjectApiName, keyword };
      const data = await searchRecordIds(params).catch((error) => {
        this.showSpinner = false;
        throwRuntimeError(error);
      });

      if (data && !data.hasError) {
        this.publishRecordMessage(data.body.join(","));
        this.showSpinner = false;
      } else if (data && data.hasError) {
        this.showSpinner = false;
        throwRuntimeError(data.errorMessage, data.errorCode);
      }
    } else {
      this.publishRecordMessage(null);
    }
  }

  // Wire Service Event Handlers
  @wire(getFieldValueForRecord, {
    recordId: "$recordId",
    objectApiName: "$objectApiName",
    fieldApiName: "$fieldApiName"
  })
  getFieldValueForRecordCallback({ data, error }) {
    if (data && !data.hasError) {
      this.defaultKeyword = data.body;
      this._isInputUpdated = true;
    } else if (data && data.hasError) {
      throwConfigurationError(data.errorMessage, data.errorCode);
    } else if (error) {
      throwConfigurationError(error);
    }
  }

  // Lifecycle Event Handlers
  connectedCallback() {
    this.enableInteraction(this.componentId);
    this.subscribeRecordMessage(this.sourceComponentIds, ({ recordIds }) => {
      const keyword = this.template.querySelector("lightning-input").value;
      if (keyword) {
        const params = {
          objectApiName: this.targetObjectApiName,
          keyword,
          recordIds
        };
        this.showSpinner = true;
        (recordIds === null ? searchRecordIds(params) : filterRecordIds(params))
          .then((result) => {
            if (result && !result.hasError) {
              this.publishRecordMessage(result.body.join(","));
              this.showSpinner = false;
            } else if (result && result.hasError) {
              this.showSpinner = false;
              throwRuntimeError(result.errorMessage, result.errorCode);
            }
          })
          .catch((error) => {
            this.showSpinner = false;
            throwRuntimeError(error);
          });
      } else {
        this.publishRecordMessage(recordIds);
      }
    });
    this.subscribeTriggerMessage(() => {
      this.search();
    });
  }
  disconnectedCallback() {
    this.unsubscribeRecordMessage();
    this.unsubscribeTriggerMessage();
  }
  renderedCallback() {
    if (this._isInputUpdated) {
      this._isInputUpdated = false;
      this.publishInitMessage();
    }
  }
}
