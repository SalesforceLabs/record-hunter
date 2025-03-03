import { LightningElement, api } from "lwc";
export default class MapFilterInput extends LightningElement {
  @api type;
  @api center;
  @api location;
  @api distance;
  @api unitOptions = [];

  get isAddressInputMode() {
    return this.type === "address";
  }
  get isLatlngInputMode() {
    return this.type === "latlng";
  }

  value = {
    location: { latitude: null, longitude: null, address: null },
    distance: null,
    unit: null
  };

  connectedCallback() {
    const latitude = this.location?.latitude
      ? this.location.latitude / 1
      : null;

    if (latitude && (latitude > 90 || latitude < -90)) {
      console.error("Invalid latitude value", latitude);
      throw new Error(`Invalid latitude value: ${latitude}`);
    }

    const longitude = this.location?.longitude
      ? this.location.longitude / 1
      : null;

    if (longitude && (longitude > 180 || longitude < -180)) {
      console.error("Invalid longitude", longitude);
      throw new Error(`Invalid longitude: ${longitude}`);
    }

    const address = this.location?.address?.trim()
      ? this.location.address.trim()
      : null;

    const distance = this.distance ? this.distance / 1 : null;

    if (distance && distance < 0) {
      console.error("Invalid distance", distance);
      throw new Error(`Invalid distance: ${distance}`);
    }

    if (this.unitOptions && !Array.isArray(this.unitOptions)) {
      console.error("unitOptions must be an array");
      throw new Error(`unitOptions must be an array`);
    }
    const unit =
      this.unitOptions?.length > 0
        ? this.unitOptions.find((option) => option.isSelected)?.value ||
          this.unitOptions[0].value
        : null;

    this.value = {
      location: {
        latitude,
        longitude,
        address
      },
      distance,
      unit
    };

    const value = { ...this.value };
    this.dispatchEvent(
      new CustomEvent("change", {
        detail: { value }
      })
    );
  }

  onInputBlurred(e) {
    e.stopPropagation();
    const value = { ...this.value };
    this.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value
        }
      })
    );
  }

  onValueChanged(e) {
    e.stopPropagation();
    const name = e.target.name;
    if (name === "latitude") {
      const latitude = e.target.value;
      if (
        latitude == null ||
        latitude.trim() === "" ||
        latitude > 90 ||
        latitude < -90
      ) {
        this.value.location.latitude = null;
      } else {
        this.value.location.latitude = latitude / 1;
      }
    } else if (name === "longitude") {
      const longitude = e.target.value;
      if (
        longitude == null ||
        longitude.trim() === "" ||
        longitude > 180 ||
        longitude < -180
      ) {
        this.value.location.longitude = null;
      } else {
        this.value.location.longitude = longitude / 1;
      }
    } else if (name === "address") {
      const address = e.target.value;
      if (address == null || address.trim() === "") {
        this.value.location.address = null;
      } else {
        this.value.location.address = address;
      }
    } else if (name === "distance") {
      const distance = e.target.value;
      if (distance == null || distance.trim() === "" || distance < 0) {
        this.value.distance = null;
      } else {
        this.value.distance = distance / 1;
      }
    } else if (name === "unit") {
      this.value.unit = e.target.value;
    }
  }
}
