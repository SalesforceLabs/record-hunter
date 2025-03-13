import { LightningElement, wire } from "lwc";
import {
  publish,
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import recordHunterRecordMessageChannel from "@salesforce/messageChannel/recordHunterRecordMessageChannel__c";
import recordHunterTriggerMessageChannel from "@salesforce/messageChannel/recordHunterTriggerMessageChannel__c";
import recordHunterInitMessageChannel from "@salesforce/messageChannel/recordHunterInitMessageChannel__c";

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
      this.recordHunterRecordMessageSubscription = subscribe(
        this.messageContext,
        recordHunterRecordMessageChannel,
        (payload) => {
          const sourceComponentId = payload.sourceComponentId;
          const acceptedSourceComponentIdList =
            acceptedComponentIds?.split(",") || [];
          if (this.componentId !== sourceComponentId) {
            const matchedCmpIds = acceptedSourceComponentIdList.filter(
              (acceptedSrcCmpId) => {
                return sourceComponentId === acceptedSrcCmpId;
              }
            );
            if (matchedCmpIds.length > 0) {
              this.rootComponentId = payload.rootComponentId;
              callback(payload);
            }
          }
        }
      );
    }
  }
  unsubscribeRecordMessage() {
    unsubscribe(this.recordHunterRecordMessageSubscription);
    this.recordHunterRecordMessageSubscription = null;
  }
  publishRecordMessage(recordIds) {
    console.log("publishRecordMessage:start");
    publish(this.messageContext, recordHunterRecordMessageChannel, {
      recordIds,
      sourceComponentId: this.componentId,
      rootComponentId: this.rootComponentId
    });
    console.log("publishRecordMessage:done");
  }

  subscribeTriggerMessage(callback) {
    console.log(this.componentId, "subscribeTriggerMessage:start");
    if (!this.recordHunterTriggerMessageSubscription) {
      console.log(this.componentId, "subscribeTriggerMessage:subscribe");
      this.recordHunterTriggerMessageSubscription = subscribe(
        this.messageContext,
        recordHunterTriggerMessageChannel,
        (payload) => {
          console.log("subscribeTriggerMessage:callback");
          const sourceComponentId = payload.sourceComponentId;
          const targetComponentId = payload.targetComponentId;
          if (
            this.componentId !== sourceComponentId &&
            this.componentId === targetComponentId
          ) {
            this.rootComponentId = this.componentId;
            callback(payload);
          }
        }
      );
    }
  }
  unsubscribeTriggerMessage() {
    unsubscribe(this.recordHunterTriggerMessageSubscription);
    this.recordHunterTriggerMessageSubscription = null;
  }
  publishTriggerMessage(targetComponentId) {
    publish(this.messageContext, recordHunterTriggerMessageChannel, {
      sourceComponentId: this.componentId,
      targetComponentId
    });
  }

  subscribeInitMessage(callback) {
    if (!this.recordHunterInitMessageSubscription) {
      this.recordHunterInitMessageSubscription = subscribe(
        this.messageContext,
        recordHunterInitMessageChannel,
        () => {
          callback();
        }
      );
    }
  }
  unsubscribeInitMessage() {
    unsubscribe(this.recordHunterInitMessageSubscription);
    this.recordHunterInitMessageSubscription = null;
  }
  publishInitMessage() {
    publish(this.messageContext, recordHunterInitMessageChannel);
  }
}
