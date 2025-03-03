import { LightningElement, api } from "lwc";
import { ErrorType } from "c/errorEvent";

const DEFAULT_ZOOM_LEVEL = 8;

export default class MapFilterCard extends LightningElement {
  @api cardHeaderTitle = "Map Filter";
  @api cardHeaderIconName = "custom:custom57";
  @api mapHeight = 500;

  @api recordId;
  @api objectName;
  @api locationFieldApiName;
  @api markerTitleFieldApiName;
  @api markerContentFieldApiName;
  @api defaultCenter;
  @api defaultDistance;
  @api defaultUnitOfDistance;
  @api order;

  @api googleCloudApiKey;

  hasConfigurationError = false;
  hasRuntimeError = false;
  errorTitle;
  errorMessage;

  get mapFilterAttributes() {
    return {
      recordId: this.recordId,
      objectName: this.objectName,
      locationFieldApiName: this.locationFieldApiName,
      markerTitleFieldApiName: this.markerTitleFieldApiName,
      markerContentFieldApiName: this.markerContentFieldApiName,
      defaultZoomLevel: DEFAULT_ZOOM_LEVEL,
      defaultCenter: this.defaultCenter,
      defaultDistance: this.defaultDistance,
      defaultUnitOfDistance: this.defaultUnitOfDistance,
      componentId: this.order,
      googleCloudApiKey: this.googleCloudApiKey,
      sourceComponentIds:
        parseInt(this.order, 10) - 1 > 0
          ? parseInt(this.order, 10) - 1 + ""
          : ""
    };
  }

  get mapStyle() {
    return `height: ${this.mapHeight}px;`;
  }

  onError(e) {
    e.stopPropagation();
    const { type, message } = e.detail;
    if (type === ErrorType.CONFIG) {
      this.errorTitle = "Component Configuration Error";
      this.errorMessage = message;
      this.hasConfigurationError = true;
    } else if (type === ErrorType.RUNTIME) {
      this.errorMessage = message;
      this.hasRuntimeError = true;
    }
    return false;
  }

  onAlertClosed() {
    this.hasRuntimeError = false;
    this.errorMessage = null;
  }
}
