import { LightningElement, api } from "lwc";

export default class MultiSelectCombobox extends LightningElement {
  @api label;
  @api options;
  @api sourceLabel;
  @api selectedLabel;
  @api values = [];
  value = "";
  showDialog = false;

  get comboboxClass() {
    const classList = [
      "slds-combobox",
      "slds-dropdown-trigger",
      "slds-dropdown-trigger_click"
    ];
    if (this.showDialog) {
      classList.push("slds-is-open");
    }
    return classList.join(" ");
  }
  get dialogClass() {
    const classList = ["slds-popover", "slds-popover_full-width"];
    if (!this.showDialog) {
      classList.push("slds-popover_hide");
    }
    return classList.join(" ");
  }
  get buttonClass() {
    const classList = [
      "slds-combobox__input slds-input_faux fix-slds-input_faux"
    ];
    if (this.showDialog) {
      classList.push("slds-has-focus");
    }
    return classList.join(" ");
  }

  onWindowClicked = () => {
    this.value = this.values.join(";");
    this.showDialog = false;
  };
  connectedCallback() {
    window.addEventListener("click", this.onWindowClicked);
    this.value = this.values.join(";");
  }
  disconnectedCallback() {
    window.removeEventListener("click", this.onWindowClicked);
  }

  onSelectedOptionsChanged(e) {
    this.draftValues = e.detail.value;
    this.value = this.draftValues.join(";");
  }

  onComboboxClicked(e) {
    e.stopPropagation();
    if (!this.showDialog) {
      this.showDialog = true;
    }
  }
  onDialogClicked(e) {
    e.stopPropagation();
  }
  onCancelClicked(e) {
    e.stopPropagation();
    this.value = this.values.join(";");
    this.showDialog = false;
  }
  onDoneClicked(e) {
    e.stopPropagation();
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.values = this.draftValues;
    this.showDialog = false;
  }
}
