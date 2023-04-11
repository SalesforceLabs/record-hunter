import {LightningElement, api} from "lwc";

export default class Alert extends LightningElement {
  @api message;
  onCloseClicked() {
    this.dispatchEvent(new CustomEvent("close"));
  }
}
