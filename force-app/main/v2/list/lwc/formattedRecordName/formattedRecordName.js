import {api, LightningElement} from "lwc";
import {NavigationMixin} from "lightning/navigation";
export default class FormattedRecordName extends NavigationMixin(LightningElement) {
  @api label;
  @api recordId;
  onLinkClicked() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        actionName: "view"
      }
    });
  }
}
