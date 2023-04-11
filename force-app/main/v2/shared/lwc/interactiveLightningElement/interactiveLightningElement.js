import {LightningElement, wire} from "lwc";
import {publish, subscribe, unsubscribe, MessageContext} from "lightning/messageService";
import recordHunterRecordMessageChannel from "@salesforce/messageChannel/recordHunterRecordMessageChannel__c";
import recordHunterTriggerMessageChannel from "@salesforce/messageChannel/recordHunterTriggerMessageChannel__c";

export default class InteractiveLightningElement extends LightningElement {
  /****************************************/
  /**     INTERATIVE COMPONENTS BASE     **/
  /****************************************/
  @wire(MessageContext)
  messageContext;

  componentId;

  enableInteraction(componentId) {
    this.componentId = componentId;
  }

  // Record Message Channel
  subscribeRecordMessage(acceptedComponentIds, callback) {
    if (!this.recordHunterRecordMessageSubscription) {
      this.recordHunterRecordMessageSubscription = subscribe(this.messageContext, recordHunterRecordMessageChannel, (payload) => {
        const sourceComponentId = payload.sourceComponentId;
        const acceptedSourceComponentIdList = acceptedComponentIds?.split(",") || [];
        if (this.componentId !== sourceComponentId) {
          const matchedCmpIds = acceptedSourceComponentIdList.filter((acceptedSrcCmpId) => {
            return sourceComponentId === acceptedSrcCmpId;
          });
          if (matchedCmpIds.length > 0) {
            this.rootComponentId = payload.rootComponentId;
            callback(payload);
          }
        }
      });
    }
  }
  unsubscribeRecordMessage() {
    unsubscribe(this.recordHunterRecordMessageSubscription);
    this.recordHunterRecordMessageSubscription = null;
  }
  publishRecordMessage(recordIds) {
    publish(this.messageContext, recordHunterRecordMessageChannel, {recordIds, sourceComponentId: this.componentId, rootComponentId: this.rootComponentId});
  }

  subscribeTriggerMessage(callback) {
    if (!this.recordHunterTriggerMessageSubscription) {
      this.recordHunterTriggerMessageSubscription = subscribe(this.messageContext, recordHunterTriggerMessageChannel, (payload) => {
        const sourceComponentId = payload.sourceComponentId;
        const targetComponentId = payload.targetComponentId;
        if (this.componentId !== sourceComponentId && this.componentId === targetComponentId) {
          this.rootComponentId = this.componentId;
          callback(payload);
        }
      });
    }
  }
  unsubscribeTriggerMessage() {
    unsubscribe(this.recordHunterTriggerMessageSubscription);
    this.recordHunterTriggerMessageSubscription = null;
  }
  publishTriggerMessage(targetComponentId) {
    publish(this.messageContext, recordHunterTriggerMessageChannel, {sourceComponentId: this.componentId, targetComponentId});
  }
}
