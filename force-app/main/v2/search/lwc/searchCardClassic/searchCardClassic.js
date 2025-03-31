import { LightningElement, api, wire } from "lwc";
import getObjectInfoByName from "@salesforce/apex/SchemaDataService.getObjectInfoByName";
import getObjectApiNameById from "@salesforce/apex/SchemaDataService.getObjectApiNameById";
import getFieldInfo from "@salesforce/apex/SchemaDataService.getFieldInfo";

export default class SearchCardClassic extends LightningElement {
  // Reserved Public Properties
  @api recordId;
  @api objectApiName;

  // Public Properties
  @api cardTitle = "Search";
  @api cardIconName = "custom:custom57";
  @api targetObjectApiName;
  @api defaultValuesOrFieldNames;
  @api order;

  // Private Properties
  componentId;
  sourceComponentIds;
  targetComponentIds;
  hasConfigurationError;
  hasRuntimeError;
  defaultValue;

  // Wire Service Event Handlers
  @wire(getObjectInfoByName, { objectApiName: "$targetObjectApiName" })
  getObjectInfoByNameCallback({ data, error }) {
    if (data && data.hasError) {
      this.showConfigurationError(data.errorMessage);
    } else if (error) {
      this.showConfigurationError(error);
    }
  }

  @wire(getObjectApiNameById, { recordId: "$recordId" })
  getObjectApiNameByIdCallback({ data, error }) {
    if (data && !data.hasError) {
      // eslint-disable-next-line @lwc/lwc/no-api-reassignments
      this.objectApiName = data.body;
    } else if (data && data.hasError) {
      this.showConfigurationError(data.errorMessage);
    } else if (error) {
      this.showConfigurationError(error);
    }
  }

  @wire(getFieldInfo, {
    objectApiName: "$objectApiName",
    fieldApiName: "$defaultValuesOrFieldNames"
  })
  getFieldInfoCallback({ data, error }) {
    if (data && !data.hasError) {
      this.defaultValue = {
        source: "context",
        fieldApiName: data.body.name
      };
    } else if (data && data.hasError) {
      this.defaultValue = this.defaultValuesOrFieldNames;
    } else if (error) {
      this.showConfigurationError(error);
    }
  }

  // Lifecycle Event Handlers
  connectedCallback() {
    this.componentId = this.order;
    this.targetComponentIds = parseInt(this.order, 10) + 1 + "";
    if (!this.objectApiName) {
      this.defaultValue = this.defaultValuesOrFieldNames;
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

  // User Event Handlers
  onSearchButtonClicked() {
    this.template.querySelector("c-search").search();
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
}
