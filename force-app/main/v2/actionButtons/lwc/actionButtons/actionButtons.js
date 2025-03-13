import { LightningElement, api } from "lwc";
import MessageService from "c/messageService";

export default class ActionButtons extends LightningElement {
  @api componentId = "ACTION_BUTTONS";
  @api sourceComponentIds = "";
  @api targetComponentId = "0";
  @api alignment = "CENTER";
  @api searchButtonLabel = "Search";
  @api isSearchOnLoadEnabled = false;

  targetComponentIds;

  get sldsBoxClass() {
    const classList = ["slds-box  slds-box_small slds-theme_default"];
    if (this.alignment === "RIGHT") {
      classList.push("slds-text-align_right");
    } else if (this.alignment === "LEFT") {
      classList.push("slds-text-align_left");
    } else {
      classList.push("slds-text-align_center");
    }
    return classList.join(" ");
  }
  get sldsCardBodyClass() {
    const classList = ["slds-card__body slds-card__body_inner"];
    if (this.alignment === "RIGHT") {
      classList.push("slds-text-align_right");
    } else if (this.alignment === "LEFT") {
      classList.push("slds-text-align_left");
    } else {
      classList.push("slds-text-align_center");
    }
    return classList.join(" ");
  }

  connectedCallback() {
    this.targetComponentIds = this.targetComponentId;
    this.messageService = new MessageService(this, this.targetComponentIds);
    this.messageService.subscribeStatusChangedToReady(() => {
      if (this.isSearchOnLoadEnabled) {
        this.messageService.publishStatusChangedToCompleted();
      }
    });
  }

  disconnectedCallback() {
    this.messageService.unsubscribeStatusChangedToReady();
  }
  onSearchClicked() {
    this.messageService.publishStatusChangedToCompleted();
  }
}
