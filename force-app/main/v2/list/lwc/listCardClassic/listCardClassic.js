import { LightningElement, api } from "lwc";
import ScreenFlowModal from "c/screenFlowModal";

export default class ListCardClassic extends LightningElement {
  // Reserved Public Properties
  @api recordId;
  @api objectApiName;

  // Public Properties
  @api cardTitle;
  @api cardIconName = "custom:custom57";
  @api targetObjectApiName;
  @api fieldNames;
  @api tableHeight;
  @api pageSize;
  @api flowNames;
  @api flowLabels;
  @api flowInput;
  @api order;

  // Private Properties
  componentId;
  sourceComponentIds;
  targetComponentIds;
  selectedRows = [];
  actions = [];
  totalNumberOfRecords = 0;
  numberOfRecordsLoaded = 0;
  hasConfigurationError;
  hasRuntimeError;
  errorTitle;
  errorMessage;
  get hasActions() {
    return this.actions && this.actions.length > 0;
  }
  get hideCheckboxColumn() {
    return !this.hasActions;
  }
  get isActionDisabled() {
    return !this.selectedRows || this.selectedRows.length === 0;
  }

  connectedCallback() {
    this.componentId = this.order;
    this.sourceComponentIds = parseInt(this.order, 10) - 1;
    this.targetComponentIds = parseInt(this.order, 10) + 1;
    const actions = [];
    const flowNameList = this.flowNames ? this.flowNames.split(",") : [];
    const flowLabelList = this.flowLabels ? this.flowLabels.split(",") : [];
    for (let i = 0; i < flowNameList.length; i++) {
      const name = flowNameList[i].trim();
      const label =
        i < flowLabelList.length
          ? flowLabelList[i].trim()
          : flowNameList[i].trim();
      const action = {
        type: "flow",
        name,
        label
      };
      actions.push(action);
    }
    this.actions = actions;
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
  onRecordLoaded(e) {
    this.numberOfRecordsLoaded = e.detail.numberOfRecords;
    this.totalNumberOfRecords = e.detail.totalNumberOfRecords;
  }

  onRowSelected(e) {
    this.selectedRows = e.detail.selectedRows;
  }

  onAlertClosed() {
    this.hasRuntimeError = false;
    this.errorMessage = null;
  }

  onActionButtonClicked(e) {
    const { type, name, label } = e.detail;
    if (type === "flow") {
      const selectedRecordIds = this.selectedRows.map((record) => {
        return record.Id;
      });
      ScreenFlowModal.open({
        label: label,
        size: "large",
        flowApiName: name,
        selectedRecordIds: selectedRecordIds,
        contextRecordId: this.recordId
      })
        .then(() => {
          this.template.querySelector("c-list").reload();
        })
        .catch((error) => {
          console.error(error);
        });
    }
  }

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
