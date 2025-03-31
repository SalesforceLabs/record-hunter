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
        this.messageService.publishStatusChangedToCompleted(data.body);
        this.showSpinner = false;
      } else if (data && data.hasError) {
        this.showSpinner = false;
        throwRuntimeError(data.errorMessage, data.errorCode);
      }
    } else {
      this.messageService.publishStatusChangedToCompleted();
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
    this.messageService.subscribeStatusChangedToCompleted(
      this.onStatusChangedToCompleted.bind(this)
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

  onStatusChangedToCompleted({ data, errors }) {
    if (errors) {
      throwRuntimeError(errors);
      return;
    }
    const keyword = this.template.querySelector("lightning-input").value;
    if (keyword) {
      const params = {
        objectApiName: this.targetObjectApiName,
        keyword,
        recordIds: data
      };
      this.showSpinner = true;
      (data ? filterRecordIds(params) : searchRecordIds(params))
        .then((response) => {
          if (response && !response.hasError) {
            this.messageService.publishStatusChangedToCompleted(response.body);
            this.showSpinner = false;
          } else if (response && response.hasError) {
            this.showSpinner = false;
            throwRuntimeError(response.errorMessage, response.errorCode);
          }
        })
        .catch((e) => {
          this.showSpinner = false;
          throwRuntimeError(e);
        });
    } else {
      this.messageService.publishStatusChangedToCompleted();
    }
  }
}
