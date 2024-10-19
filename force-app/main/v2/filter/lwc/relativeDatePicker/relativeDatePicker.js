/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from "lwc";

const QUALIFIER_OPTIONS = [
  { label: "", value: "" },
  { label: "LAST", value: "LAST" },
  { label: "NEXT", value: "NEXT" },
  { label: "TODAY", value: "TODAY" },
  { label: "YESTERDAY", value: "YESTERDAY" },
  { label: "TOMORROW", value: "TOMORROW" },
  { label: "LAST WEEK", value: "LAST_WEEK" },
  { label: "THIS WEEK", value: "THIS_WEEK" },
  { label: "NEXT WEEK", value: "NEXT_WEEK" },
  { label: "LAST MONTH", value: "LAST_MONTH" },
  { label: "THIS MONTH", value: "THIS_MONTH" },
  { label: "NEXT MONTH", value: "NEXT_MONTH" },
  { label: "LAST QUARTER", value: "LAST_QUARTER" },
  { label: "THIS QUARTER", value: "THIS_QUARTER" },
  { label: "NEXT QUARTER", value: "NEXT_QUARTER" },
  { label: "LAST YEAR", value: "LAST_YEAR" },
  { label: "THIS YEAR", value: "THIS_YEAR" },
  { label: "NEXT YEAR", value: "NEXT_YEAR" },
  { label: "LAST FISCAL QUARTER", value: "LAST_FISCAL_QUARTER" },
  { label: "THIS FISCAL QUARTER", value: "THIS_FISCAL_QUARTER" },
  { label: "NEXT FISCAL QUARTER", value: "NEXT_FISCAL_QUARTER" },
  { label: "LAST FISCAL YEAR", value: "LAST_FISCAL_YEAR" },
  { label: "THIS FISCAL YEAR", value: "THIS_FISCAL_YEAR" },
  { label: "NEXT FISCAL YEAR", value: "NEXT_FISCAL_YEAR" }
];
const UNIT_OPTIONS = [
  { label: "DAYS", value: "DAYS" },
  { label: "WEEKS", value: "WEEKS" },
  { label: "MONTHS", value: "MONTHS" },
  { label: "QUARTERS", value: "QUARTERS" },
  { label: "YEARS", value: "YEARS" },
  { label: "FISCAL QUARTERS", value: "FISCAL_QUARTERS" },
  { label: "FISCAL YEARS", value: "FISCAL_YEARS" }
];

export default class RelativeDatePicker extends LightningElement {
  @api label;
  @api qualifier;
  @api amount;
  @api unit;

  qualifierOptions = [];
  unitOptions = [];

  get isAmountDisabled() {
    return !this.requiresAmountAndUnit;
  }
  get isUnitDisabled() {
    return !this.requiresAmountAndUnit;
  }
  get requiresAmountAndUnit() {
    return (
      this.qualifier === "" ||
      this.qualifier === "LAST" ||
      this.qualifier === "NEXT"
    );
  }

  connectedCallback() {
    this.qualifierOptions = QUALIFIER_OPTIONS.map((option) => {
      const isSelected = option.label === this.qualifier;
      if (isSelected) {
        this.qualifier = option.value;
      }
      return {
        ...option,
        isSelected
      };
    });

    if (!this.qualifierOptions.some((option) => option.isSelected)) {
      this.qualifierOptions[0].isSelected = true;
      this.qualifier = this.qualifierOptions[0].value;
    }

    this.unitOptions = UNIT_OPTIONS.map((option) => {
      return {
        ...option,
        isSelected: option.label === this.unit
      };
    });
    if (!this.unitOptions.some((option) => option.isSelected)) {
      this.unitOptions[0].isSelected = true;
      this.unit = this.unitOptions[0].value;
    }

    this.amount = this.amount > 0 ? this.amount : null;
  }

  onQualifierChanged(e) {
    e.stopPropagation();
    this.qualifier = e.target.value;
  }
  onAmountChanged(e) {
    e.stopPropagation();
    this.amount = e.target.value > 0 ? e.target.value : null;
  }
  onUnitChanged(e) {
    e.stopPropagation();
    this.unit = e.target.value;
  }
}
