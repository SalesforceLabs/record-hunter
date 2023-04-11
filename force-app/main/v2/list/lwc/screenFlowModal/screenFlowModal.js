import {api} from "lwc";
import LightningModal from "lightning/modal";

export default class ScreenFlowModal extends LightningModal {
  @api selectedRecordIds;
  @api contextRecordId;
  @api flowApiName;

  get inputVariables() {
    return [
      {
        name: "selectedIds",
        type: "String",
        value: this.selectedRecordIds
      },
      {
        name: "contextId",
        type: "String",
        value: this.contextRecordId || ""
      }
    ];
  }
  onFlowStatusChange(e) {
    if (e.detail.status === "FINISHED") {
      this.close("success");
    }
  }
}
