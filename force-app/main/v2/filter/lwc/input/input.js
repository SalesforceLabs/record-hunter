import { LightningElement, api } from "lwc";

export default class Input extends LightningElement {
  @api type;
  @api step;
  @api isHidden;
  @api options;
  @api showIndex;
  @api showObjectName;
  @api fieldIndex;
  @api objectName;
  @api isRelative;
  @api get defaultValue() {
    return this._defaultValue;
  }
  set defaultValue(defaultValue) {
    if (this.isSelection) {
      const { value } = defaultValue;
      this._defaultValue = { value: value ? value.split(";") : [] };
    } else {
      this._defaultValue = defaultValue;
    }
    this.setAttribute("defaultValue", this._defaultValue);
  }
  @api
  get label() {
    return (
      (this.showIndex ? this.fieldIndex + ". " : "") +
      this._label +
      (this.showObjectName ? " - " + this.objectName : "")
    );
  }
  set label(value) {
    this._label = value;
    this.setAttribute("label", this._label);
  }
  @api
  get value() {
    if (this.isText) {
      const value = this.template.querySelector(
        '[data-name="text-input"]'
      ).value;
      return value ? { value } : null;
    } else if (this.isCheckbox) {
      const value = this.template.querySelector(
        '[data-name="checkbox-input"]'
      ).checked;
      return value ? { value } : null;
    } else if (this.isNumberRange) {
      return this.getRangeValue(
        '[data-name="minimum-number-input"]',
        '[data-name="maximum-number-input"]'
      );
    } else if (this.isDatetimeRange) {
      return this.getRangeValue(
        '[data-name="minimum-datetime-input"]',
        '[data-name="maximum-datetime-input"]'
      );
    } else if (this.isDateRange) {
      return this.getRangeValue(
        '[data-name="minimum-date-input"]',
        '[data-name="maximum-date-input"]'
      );
    } else if (this.isTimeRange) {
      return this.getRangeValue(
        '[data-name="minimum-time-input"]',
        '[data-name="maximum-time-input"]'
      );
    } else if (this.isSelection) {
      const values = this.template.querySelector(
        '[data-name="multi-select-combobox"]'
      ).values;
      return values && values.length > 0 ? { value: values.join(",") } : null;
    } else if (this.isRelativeDate) {
      const input = this.template.querySelector('[data-name="relative-date"]');
      const { qualifier, amount, unit } = input;
      const value = this.getRelativeValue(qualifier, amount, unit);
      return value ? { value } : null;
    } else if (this.isRelativeDatetime) {
      const input = this.template.querySelector(
        '[data-name="relative-datetime"]'
      );
      const { qualifier, amount, unit } = input;
      const value = this.getRelativeValue(qualifier, amount, unit);
      return value ? { value } : null;
    }
    return {};
  }
  set value(value) {
    this._value = value;
    this.setAttribute("value", this._value);
  }

  get isText() {
    return ["STRING", "EMAIL", "PHONE", "ID", "TEXTAREA"].includes(this.type);
  }
  get isNumberRange() {
    return ["INTEGER", "PERCENT", "CURRENCY", "DOUBLE"].includes(this.type);
  }
  get isCheckbox() {
    return "BOOLEAN" === this.type;
  }
  get isSelection() {
    return ["PICKLIST", "MULTIPICKLIST", "COMBOBOX"].includes(this.type);
  }
  get isDateRange() {
    return "DATE" === this.type && !this.isRelative;
  }
  get isDatetimeRange() {
    return "DATETIME" === this.type && !this.isRelative;
  }
  get isTimeRange() {
    return "TIME" === this.type;
  }
  get inputClass() {
    const classList = [];
    if (this.isHidden) {
      classList.push("slds-hide");
    }
    return classList.join(" ");
  }
  get isRelativeDate() {
    return "DATE" === this.type && this.isRelative;
  }
  get isRelativeDatetime() {
    return "DATETIME" === this.type && this.isRelative;
  }

  getRangeValue(minSelector, maxSelector) {
    const minValue = this.template.querySelector(minSelector).value;
    const maxValue = this.template.querySelector(maxSelector).value;
    const value = {};

    if (minValue) {
      value.minValue = this.formatValue(minValue);
    }
    if (maxValue) {
      value.maxValue = this.formatValue(maxValue);
    }
    return minValue || maxValue ? value : null;
  }
  formatValue(value) {
    if (this.isTimeRange) {
      return value + "Z";
    }
    if (this.isDateRange && value && value.indexOf("T") > -1) {
      return value.substring(0, value.indexOf("T"));
    }
    return value;
  }

  getRelativeValue(qualifier, amount, unit) {
    if (!qualifier) {
      return null;
    }
    if (qualifier === "LAST" || qualifier === "NEXT") {
      if (amount == null || !unit) {
        return null;
      }
      return `${qualifier}_N_${unit}:${amount}`;
    }
    return qualifier;
  }
}
