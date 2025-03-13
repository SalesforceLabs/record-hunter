import { LightningElement, api } from "lwc";
import { ConfigErrorEvent, RuntimeErrorEvent } from "c/errorEvent";

import {
  fetchObjectMetadataByName,
  fetchObjectMetadataById,
  fetchFieldMetadata
} from "c/metadataService";
import { fetchRecordById, queryRecordsByLocation } from "c/recordService";

import MessageService from "c/messageService";

const DEFAULT_ZOOM_LEVEL = "12";
const UNIT_OPTIONS = [
  { label: "km", value: "km", isSelected: true },
  { label: "mi", value: "mi" }
];

export default class MapFilter extends LightningElement {
  @api recordId;
  @api objectName;
  @api locationFieldApiName;
  @api googleCloudApiKey;
  @api zoomLevel = DEFAULT_ZOOM_LEVEL;
  @api markerTitleFieldApiName;
  @api markerContentFieldApiName;
  @api defaultCenter;
  @api defaultDistance;
  @api defaultUnitOfDistance;
  @api componentId;
  @api sourceComponentIds;
  @api targetComponentIds;
  @api isDebugMode;

  showSpinner;
  mapFilterInputAttributes;
  lightningMapAttributes;

  async connectedCallback() {
    this.messageService = new MessageService(this, this.targetComponentIds);
    this.messageService.subscribeStatusChangedToCompleted(async () => {
      if (this.isComponentReady) {
        const records = await this.queryRecords();
        this.messageService.publishStatusChangedToCompletedWithResult({
          recordIds: records.map((record) => record.Id).join(",")
        });
      }
    });
    this.messageService.subscribeStatusChangedToCompletedWithResult(
      async ({ recordIds }) => {
        if (this.isComponentReady) {
          const records = await this.filterRecords(recordIds);
          this.messageService.publishStatusChangedToCompletedWithResult({
            recordIds: records.map((record) => record.Id).join(",")
          });
        }
      }
    );

    this.showSpinner = true;
    this.initLightningMapAttributes(this.zoomLevel);

    try {
      this.validateAttributes();
      await this.initFilterConditions(
        this.objectName,
        this.locationFieldApiName,
        this.markerTitleFieldApiName,
        this.markerContentFieldApiName
      );
      await this.initMapFilterInputAttributes(
        this.recordId,
        this.defaultCenter,
        this.defaultDistance,
        this.defaultUnitOfDistance,
        this.googleCloudApiKey
      );
    } catch (error) {
      this.dispatchEvent(new ConfigErrorEvent(error));
    } finally {
      this.showSpinner = false;
    }
  }

  async onMapFilterValueChanged(e) {
    e.stopPropagation();
    const { location, distance, unit } = e.detail.value;

    try {
      const updatedLocation = await this.handleGeocoding(
        location,
        this.googleCloudApiKey
      );

      const updatedFilterConditions = this.updateFilterConditions(
        this.filterConditions,
        updatedLocation,
        distance,
        unit
      );
      const { circle, markers } = this.prepareMapMarkers(
        this.lightningMapAttributes.mapMarkers,
        updatedLocation,
        distance,
        unit
      );
      const mapMarkers = this.composeMapMarkers(circle, markers);
      const updatedMapAttributes = this.updateMapAttributes(
        this.lightningMapAttributes,
        updatedLocation,
        mapMarkers
      );
      this.filterConditions = updatedFilterConditions;
      this.lightningMapAttributes = updatedMapAttributes;

      if (!this.isComponentReady) {
        this.isComponentReady = true;
        this.messageService.publishStatusChangedToReady();
      }
    } catch (error) {
      this.dispatchEvent(new RuntimeErrorEvent(error));
    }
  }

  initLightningMapAttributes(zoomLevel) {
    this.lightningMapAttributes = {
      listView: "hidden",
      options: {
        draggable: true,
        zoomControl: true,
        scrollwheel: true,
        disableDefaultUI: true,
        disableDoubleClickZoom: false
      },
      zoomLevel
    };
  }

  async initFilterConditions(
    objectApiName,
    locationFieldApiName,
    markerTitleFieldApiName,
    markerContentFieldApiName
  ) {
    const object = await fetchObjectMetadataByName({
      objectApiName
    });

    const locationField = await fetchFieldMetadata(
      object.name,
      locationFieldApiName
    );

    const findField = (fields, suffixes) =>
      fields?.find((field) =>
        suffixes.some((suffix) => field.name.endsWith(suffix))
      ) || null;

    const latitudeField = findField(locationField?.componentFields, [
      "Latitude",
      "Latitude__s"
    ]);
    const longitudeField = findField(locationField?.componentFields, [
      "Longitude",
      "Longitude__s"
    ]);
    const markerTitleField = await fetchFieldMetadata(
      object.name,
      markerTitleFieldApiName
    );

    const markerContentField = markerContentFieldApiName
      ? await fetchFieldMetadata(object.name, markerContentFieldApiName)
      : null;

    this.filterConditions = {
      objectApiName: object.name,
      locationFieldApiName: locationField.qualifiedName,
      latitudeFieldApiName: latitudeField?.qualifiedName,
      longitudeFieldApiName: longitudeField?.qualifiedName,
      markerTitleFieldApiName: markerTitleField?.qualifiedName,
      markerContentFieldApiName: markerContentField?.qualifiedName
    };
  }

  async initMapFilterInputAttributes(
    recordId,
    defaultCenter,
    defaultDistance,
    defaultUnitOfDistance,
    googleCloudApiKey
  ) {
    const {
      contextObject,
      defaultCenterField,
      defaultCenterLatitudeField,
      defaultCenterLongitudeField,
      defaultCenterStreetField,
      defaultCenterCityField,
      defaultCenterStateField,
      defaultCenterPostalCodeField,
      defaultCenterCountryField,
      defaultDistanceField,
      defaultUnitOfDistanceField
    } = await this.getContextMetadata(
      recordId,
      defaultCenter,
      defaultDistance,
      defaultUnitOfDistance
    );

    const contextRecord = await this.getContextRecord(recordId, contextObject, [
      defaultCenterField,
      defaultCenterLatitudeField,
      defaultCenterLongitudeField,
      defaultCenterStreetField,
      defaultCenterCityField,
      defaultCenterStateField,
      defaultCenterPostalCodeField,
      defaultCenterCountryField,
      defaultDistanceField,
      defaultUnitOfDistanceField
    ]);

    const defaultCenterLocation = this.getDefaultCenterLocation(
      defaultCenter,
      contextRecord,
      defaultCenterField,
      defaultCenterLatitudeField,
      defaultCenterLongitudeField,
      defaultCenterStreetField,
      defaultCenterCityField,
      defaultCenterStateField,
      defaultCenterPostalCodeField,
      defaultCenterCountryField
    );

    const distance = this.getDefaultDistance(
      defaultDistance,
      contextRecord,
      defaultDistanceField
    );

    const unit = this.getDefaultUnit(
      defaultUnitOfDistance,
      contextRecord,
      defaultUnitOfDistanceField,
      UNIT_OPTIONS
    );

    this.mapFilterInputAttributes = {
      type: googleCloudApiKey ? "address" : "latlng",
      location: {
        latitude: defaultCenterLocation.latitude,
        longitude: defaultCenterLocation.longitude,
        address: defaultCenterLocation.address
      },
      distance,
      unitOptions: UNIT_OPTIONS.map((option) => {
        return {
          ...option,
          isSelected: option.value === unit
        };
      })
    };
  }

  async filterRecords(recordIds) {
    this.filterConditions = {
      ...this.filterConditions,
      recordIds
    };

    this.showSpinner = true;

    try {
      const records = await queryRecordsByLocation(
        { ...this.filterConditions },
        { isDebugMode: this.isDebugMode }
      );
      const circle = this.lightningMapAttributes.mapMarkers?.find(
        (marker) => marker.type === "Circle"
      );

      const markers = records?.length
        ? this.createMarkers(
            records,
            this.filterConditions.latitudeFieldApiName,
            this.filterConditions.longitudeFieldApiName,
            this.filterConditions.markerTitleFieldApiName,
            this.filterConditions.markerContentFieldApiName
          )
        : null;

      const mapMarkers = [
        ...(circle ? [circle] : []),
        ...(markers?.length ? markers : [])
      ];

      this.lightningMapAttributes = {
        ...this.lightningMapAttributes,
        mapMarkers: mapMarkers.length ? mapMarkers : null
      };

      return records;
    } catch (error) {
      this.dispatchEvent(new RuntimeErrorEvent(error));
    } finally {
      this.showSpinner = false;
    }

    return [];
  }

  async queryRecords() {
    this.showSpinner = true;
    try {
      const records = await queryRecordsByLocation(
        { ...this.filterConditions },
        { isDebugMode: this.isDebugMode }
      );
      const circle = this.lightningMapAttributes.mapMarkers?.find(
        (marker) => marker.type === "Circle"
      );

      const markers = records?.length
        ? this.createMarkers(
            records,
            this.filterConditions.latitudeFieldApiName,
            this.filterConditions.longitudeFieldApiName,
            this.filterConditions.markerTitleFieldApiName,
            this.filterConditions.markerContentFieldApiName
          )
        : null;

      const mapMarkers = [
        ...(circle ? [circle] : []),
        ...(markers?.length ? markers : [])
      ];

      this.lightningMapAttributes = {
        ...this.lightningMapAttributes,
        mapMarkers: mapMarkers.length ? mapMarkers : null
      };

      return records;
    } catch (error) {
      this.dispatchEvent(new RuntimeErrorEvent(error));
    } finally {
      this.showSpinner = false;
    }

    return [];
  }

  validateAttributes() {
    if (!this.objectName) {
      throw new Error("Object API Name is required.");
    }
    if (!this.locationFieldApiName) {
      throw new Error("Location Field API Name is required.");
    }
  }

  async getContextMetadata(
    recordId,
    defaultCenter,
    defaultDistance,
    defaultUnitOfDistance
  ) {
    const context = {};

    if (recordId) {
      context.contextObject = await fetchObjectMetadataById({ recordId });
    }

    if (!context.contextObject) return context;

    context.defaultCenterField = await fetchFieldMetadata(
      context.contextObject.name,
      defaultCenter,
      false
    );

    const findField = (fields, suffixes) =>
      fields?.find((field) =>
        suffixes.some((suffix) => field.name.endsWith(suffix))
      ) || null;

    if (context.defaultCenterField) {
      const { type, componentFields } = context.defaultCenterField;
      context.defaultCenterLatitudeField = findField(componentFields, [
        "Latitude",
        "Latitude__s"
      ]);
      context.defaultCenterLongitudeField = findField(componentFields, [
        "Longitude",
        "Longitude__s"
      ]);

      if (type === "ADDRESS") {
        context.defaultCenterStreetField = findField(componentFields, [
          "Street",
          "Street__s"
        ]);
        context.defaultCenterCityField = findField(componentFields, [
          "City",
          "City__s"
        ]);
        context.defaultCenterStateField = findField(componentFields, [
          "State",
          "State__s"
        ]);
        context.defaultCenterPostalCodeField = findField(componentFields, [
          "PostalCode",
          "PostalCode__s"
        ]);
        context.defaultCenterCountryField = findField(componentFields, [
          "Country",
          "Country__s"
        ]);
      }
    }

    context.defaultDistanceField = await fetchFieldMetadata(
      context.contextObject.name,
      defaultDistance,
      false
    );
    context.defaultUnitOfDistanceField = await fetchFieldMetadata(
      context.contextObject.name,
      defaultUnitOfDistance,
      false
    );

    return context;
  }

  getContextRecord(recordId, object, fields) {
    if (!object) return null;
    const fieldNames = fields.filter(Boolean).map(({ name }) => name);
    return fetchRecordById({ recordId, fields: fieldNames });
  }

  createMarkers(
    records,
    latitudeField,
    longitudeField,
    titleField,
    contentField
  ) {
    const getNestedValue = (obj, path) =>
      path
        .split(".")
        .reduce(
          (acc, key) => (acc && acc[key] !== undefined ? acc[key] : null),
          obj
        );

    const transformRelationshipField = (fieldName) =>
      fieldName
        .split(".")
        .map((field, index, fields) => {
          if (index < fields.length - 1) {
            if (field.endsWith("Id")) {
              return field.slice(0, -2);
            } else if (field.endsWith("__c")) {
              return `${field.slice(0, -3)}__r`;
            }
          }
          return field;
        })
        .join(".");

    // 変換済みのフィールド名を事前に計算してパフォーマンスを向上
    const transformedFields = {
      latitude: transformRelationshipField(latitudeField),
      longitude: transformRelationshipField(longitudeField),
      title: transformRelationshipField(titleField),
      description: transformRelationshipField(contentField)
    };

    return records
      .map((record) => {
        const latitude = getNestedValue(record, transformedFields.latitude);
        const longitude = getNestedValue(record, transformedFields.longitude);
        const title = getNestedValue(record, transformedFields.title);
        const description = getNestedValue(
          record,
          transformedFields.description
        );

        // 緯度と経度が存在する場合のみマーカーを作成
        if (latitude && longitude) {
          return {
            location: { Latitude: latitude, Longitude: longitude },
            value: record.Id,
            title: title || "",
            description: description || ""
          };
        }
        return null;
      })
      .filter(Boolean); // null を除外
  }

  getDefaultCenterLocation(
    centerLocation,
    record,
    locationField,
    latitudeField,
    longitudeField,
    streetField,
    cityField,
    stateField,
    postalCodeField,
    countryField
  ) {
    if (record && locationField) {
      const { type } = locationField;
      const latitude = record[latitudeField.name];
      const longitude = record[longitudeField.name];
      if (type === "LOCATION") {
        return { latitude, longitude };
      }
      if (type === "ADDRESS") {
        const address = `${record[streetField.name]}, ${record[cityField.name]}, ${record[stateField.name]}, ${record[postalCodeField.name]}, ${record[countryField.name]}`;
        return { latitude, longitude, address };
      }
      return { address: record[locationField.name] };
    }

    const [lat, lng] = (centerLocation || "").split(",").map((s) => s.trim());
    return {
      latitude: lat ? Number(lat) : null,
      longitude: lng ? Number(lng) : null,
      address: centerLocation || undefined
    };
  }

  getDefaultDistance(distance, record, distanceField) {
    if (distanceField) {
      const fieldDistance = Number(record[distanceField.name]);
      if (!isNaN(fieldDistance)) return fieldDistance;
    }
    const parsedDistance = Number(distance);
    return isNaN(parsedDistance) ? null : parsedDistance;
  }

  getDefaultUnit(unit, record, unitField, unitOptions) {
    const value = unitField ? record[unitField.name] : unit;
    return unitOptions.find((option) => option.value === value)?.value;
  }

  updateFilterConditions(filterConditions, location, distance, unit) {
    return {
      ...filterConditions,
      latitude: location.latitude,
      longitude: location.longitude,
      distance,
      unit
    };
  }

  prepareMapMarkers(existingMarkers, location, distance, unit) {
    const circle = this.createCircle(
      location.latitude,
      location.longitude,
      distance,
      unit
    );
    const markers = (existingMarkers || []).filter(
      (marker) => marker.type !== "Circle"
    );
    return { circle, markers };
  }

  composeMapMarkers(circle, markers) {
    if (circle) {
      return [circle, ...markers];
    }
    return markers.length ? markers : null;
  }

  updateMapAttributes(lightningMapAttributes, location, mapMarkers) {
    return {
      ...lightningMapAttributes,
      center: {
        location: {
          Latitude: location.latitude,
          Longitude: location.longitude
        }
      },
      mapMarkers
    };
  }

  async handleGeocoding(location, googleCloudApiKey) {
    if (!googleCloudApiKey) return location;
    try {
      if (location.address) {
        const { latitude, longitude } = await this.template
          .querySelector("c-google-geocode")
          .geocode(location.address, googleCloudApiKey);
        return { ...location, latitude, longitude };
      }
      return { ...location, latitude: null, longitude: null };
    } catch (error) {
      console.error("Error during geocoding:", error);
      return location;
    }
  }

  createCircle(latitude, longitude, distance, unit) {
    if (latitude == null || longitude == null || !distance || !unit)
      return null;

    const unitToMeters = { km: 1000, mi: 1609.344 };
    const radius = unitToMeters[unit] ? distance * unitToMeters[unit] : 0;

    return {
      location: { Latitude: latitude, Longitude: longitude },
      type: "Circle",
      radius,
      strokeColor: "#4bc076",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: "#4bc076",
      fillOpacity: 0.35
    };
  }
}
