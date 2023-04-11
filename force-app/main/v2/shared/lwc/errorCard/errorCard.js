import {LightningElement, api} from "lwc";

export default class ErrorCard extends LightningElement {
  @api title;
  @api message;
}
