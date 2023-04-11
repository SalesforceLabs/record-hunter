import {LightningElement, api} from "lwc";

export default class ListActionButtons extends LightningElement {
  @api actions = [];
  @api size = 3;
  @api disabled;

  get hasMenuItems() {
    return this.menuItems && this.menuItems.length > 0;
  }

  connectedCallback() {
    this.buttons = this.actions.slice(0, this.size);
    this.menuItems = this.actions.slice(this.size);
  }

  onActionClicked(e) {
    e.stopPropagation();
    const {name, label, type} = e.currentTarget.dataset;
    this.dispatchEvent(
      new CustomEvent("click", {
        detail: {name, label, type}
      })
    );
  }
}
