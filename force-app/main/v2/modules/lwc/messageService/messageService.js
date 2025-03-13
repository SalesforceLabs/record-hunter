import {
  subscribe,
  unsubscribe,
  publish,
  createMessageContext
} from "lightning/messageService";
import EVENT_MESSAGE_CHANNEL from "@salesforce/messageChannel/EventMessage__c";

export default class MessageService {
  static TYPES = {
    STATUS_CHANGED_TO_READY: "STATUS_CHANGED_TO_READY",
    STATUS_CHANGED_TO_COMPLETED: "STATUS_CHANGED_TO_COMPLETED",
    STATUS_CHANGED_TO_COMPLETED_WITH_RESULT:
      "STATUS_CHANGED_TO_COMPLETED_WITH_RESULT"
  };

  // Constructor

  constructor(component, destinations) {
    this.component = component;
    this.channel = EVENT_MESSAGE_CHANNEL;
    this.messageContext = createMessageContext();
    this.subscriptions = new Map();
    this.origin = component.componentId;
    if (typeof destinations === "string") {
      this.destinations = destinations.split(",").map((dest) => dest.trim());
    } else if (Array.isArray(destinations)) {
      this.destinations = destinations;
    } else {
      this.destinations = [];
    }
  }

  // Subscribe

  subscribeStatusChangedToReady(handler) {
    this._createSubscription(
      MessageService.TYPES.STATUS_CHANGED_TO_READY,
      handler
    );
  }

  subscribeStatusChangedToCompleted(handler) {
    this._createSubscription(
      MessageService.TYPES.STATUS_CHANGED_TO_COMPLETED,
      handler
    );
  }

  subscribeStatusChangedToCompletedWithResult(handler) {
    this._createSubscription(
      MessageService.TYPES.STATUS_CHANGED_TO_COMPLETED_WITH_RESULT,
      handler
    );
  }

  _createSubscription(subscriptionKey, handler) {
    if (!this.subscriptions.has(subscriptionKey)) {
      const subscription = subscribe(
        this.messageContext,
        this.channel,
        ({ type, origin, destinations, payload }) => {
          const self = this.component.componentId;
          if (origin === self) return;
          if (!destinations.includes(self) && !destinations.includes("*"))
            return;
          if (type !== subscriptionKey) return;
          handler.call(this.component, payload);
        }
      );
      this.subscriptions.set(subscriptionKey, subscription);
    }
  }

  // Unsubscribe

  unsubscribeStatusChangedToReady() {
    this._unsubscribe(MessageService.TYPES.STATUS_CHANGED_TO_READY);
  }

  unsubscribeStatusChangedToCompleted() {
    this._unsubscribe(MessageService.TYPES.STATUS_CHANGED_TO_COMPLETED);
  }

  unsubscribeStatusChangedToCompletedWithResult() {
    this._unsubscribe(
      MessageService.TYPES.STATUS_CHANGED_TO_COMPLETED_WITH_RESULT
    );
  }

  unsubscribeAll() {
    this.subscriptions.forEach((subscription) => {
      unsubscribe(subscription);
    });
    this.subscriptions.clear();
  }

  _unsubscribe(subscriptionKey) {
    const subscription = this.subscriptions.get(subscriptionKey);
    if (subscription) {
      unsubscribe(subscription);
      this.subscriptions.delete(subscriptionKey);
    }
  }

  // Publish

  publishStatusChangedToReady() {
    this._publishMessage(MessageService.TYPES.STATUS_CHANGED_TO_READY, {
      to: ["*"]
    });
  }

  publishStatusChangedToCompleted() {
    this._publishMessage(MessageService.TYPES.STATUS_CHANGED_TO_COMPLETED);
  }

  publishStatusChangedToCompletedWithResult(result) {
    this._publishMessage(
      MessageService.TYPES.STATUS_CHANGED_TO_COMPLETED_WITH_RESULT,
      {},
      { result }
    );
  }

  _publishMessage(type, options = {}, payload = {}) {
    publish(this.messageContext, this.channel, {
      type: type,
      origin: this.origin,
      destinations: options.to || this.destinations,
      timestamp: Date.now(),
      payload: payload
    });
  }
}
