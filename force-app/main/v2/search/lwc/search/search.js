import { LightningElement, api, wire } from "lwc";
import searchRecordIds from "@salesforce/apex/SearchDataService.searchRecordIds";
import filterRecordIds from "@salesforce/apex/SearchDataService.filterRecordIds";
import getFieldValueForRecord from "@salesforce/apex/SearchDataService.getFieldValueForRecord";
import { throwConfigurationError, throwRuntimeError } from "c/errorService";

import MessageService from "c/messageService";

export default class Search extends LightningElement {
  // Reserved Public Properties
  @api recordId;
  @api objectApiName;

  // Public Properties
  @api targetObjectApiName;
  @api componentId;
  @api sourceComponentIds;
  @api targetComponentIds;
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
        this.messageService.publishStatusChangedToCompletedWithResult({
          recordIds: data.body.join(",")
        });
        this.showSpinner = false;
      } else if (data && data.hasError) {
        this.showSpinner = false;
        throwRuntimeError(data.errorMessage, data.errorCode);
      }
    } else {
      this.messageService.publishStatusChangedToCompletedWithResult({
        recordIds: null
      });
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
    this.messageService = new MessageService(this, this.targetComponentIds);
    this.messageService.subscribeStatusChangedToCompleted(() => {
      this.search();
    });
    this.messageService.subscribeStatusChangedToCompletedWithResult(
      ({ result }) => {
        const keyword = this.template.querySelector("lightning-input").value;
        if (keyword) {
          const params = {
            objectApiName: this.targetObjectApiName,
            keyword,
            recordIds: result.recordIds
          };
          this.showSpinner = true;
          (result.recordIds === null
            ? searchRecordIds(params)
            : filterRecordIds(params)
          )
            .then((response) => {
              if (response && !response.hasError) {
                this.messageService.publishStatusChangedToCompletedWithResult({
                  recordIds: response.body.join(",")
                });
                this.showSpinner = false;
              } else if (response && response.hasError) {
                this.showSpinner = false;
                throwRuntimeError(response.errorMessage, response.errorCode);
              }
            })
            .catch((error) => {
              this.showSpinner = false;
              throwRuntimeError(error);
            });
        } else {
          this.messageService.publishStatusChangedToCompletedWithResult({
            recordIds: null
          });
        }
      }
    );
  }
  disconnectedCallback() {
    this.messageService.unsubscribeAll();
  }
  renderedCallback() {
    if (this._isInputUpdated || (!this.recordId && !this.isRendered)) {
      this.isRendered = true;
      this._isInputUpdated = false;
      this.messageService.publishStatusChangedToReady();
    }
  }
}
