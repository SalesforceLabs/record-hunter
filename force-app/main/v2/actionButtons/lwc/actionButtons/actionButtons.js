import { api } from "lwc";
import InteractiveLightningElement from "c/interactiveLightningElement";

export default class ActionButtons extends InteractiveLightningElement {
  @api componentId = "ACTION_BUTTONS";
  @api sourceComponentIds = "";
  @api targetComponentId = "0";
  @api alignment = "CENTER";
  @api searchButtonLabel = "Search";
  @api isSearchOnLoadEnabled = false;

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
    this.enableInteraction(this.componentId);
    if (this.isSearchOnLoadEnabled) {
      this.subscribeInitMessage(() => {
        this.publishTriggerMessage(this.targetComponentId);
      });
    }
  }

  disconnectedCallback() {
    this.unsubscribeInitMessage();
  }
  renderedCallback() {
    if (!this.isRendered) {
      this.isRendered = true;
      this.publishInitMessage();
    }
  }
  onSearchClicked() {
    this.publishTriggerMessage(this.targetComponentId);
  }
}
