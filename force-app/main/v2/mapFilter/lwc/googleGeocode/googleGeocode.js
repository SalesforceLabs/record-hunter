import { LightningElement, api } from "lwc";
export default class GoogleGeocode extends LightningElement {
  messagePort = null;
  pendingRequests = {};
  isChannelInitialized = false;

  connectedCallback() {
    // No global message listeners needed when using MessageChannel
  }

  disconnectedCallback() {
    if (this.messagePort) {
      this.messagePort.close();
    }
  }

  // Handle the iframe load event to establish the MessageChannel
  handleIframeLoad() {
    const iframe = this.template.querySelector("iframe");
    if (iframe) {
      const iframeWindow = iframe.contentWindow;

      // Create a MessageChannel
      const channel = new MessageChannel();
      this.messagePort = channel.port1;

      // Send one end of the MessageChannel to the Visualforce page
      iframeWindow.postMessage({ type: "INIT_MESSAGE_CHANNEL" }, "*", [
        channel.port2
      ]);

      // Set up a listener for messages from the VF page
      this.messagePort.onmessage = this.handlePortMessage.bind(this);
      this.messagePort.start();
    }
  }

  // Handle incoming messages from the VF page via MessageChannel
  handlePortMessage(event) {
    const data = event.data;
    if (
      data &&
      (data.type === "GEOCODE_RESPONSE" || data.type === "GEOCODE_ERROR")
    ) {
      const requestId = data.requestId;
      if (this.pendingRequests[requestId]) {
        if (data.type === "GEOCODE_RESPONSE") {
          this.pendingRequests[requestId].resolve({
            latitude: data.latitude,
            longitude: data.longitude
          });
        } else if (data.type === "GEOCODE_ERROR") {
          this.pendingRequests[requestId].reject(new Error(data.message));
        }
        // Remove the completed request
        delete this.pendingRequests[requestId];
      }
    }
  }

  /**
   * Converts an address to latitude and longitude using the Google Maps Geocoder API.
   * @param {string} address - The address to geocode.
   * @param {string} apiKey - The Google Maps API key.
   * @returns {Promise<{latitude: number, longitude: number}>} - The geocoded coordinates.
   */
  @api
  geocode(address, apiKey) {
    return new Promise((resolve, reject) => {
      if (!this.messagePort) {
        reject(new Error("Geocoder message port is not initialized."));
        return;
      }

      if (!address) {
        reject(new Error("Please provide an address."));
        return;
      }

      if (!apiKey) {
        reject(new Error("API key is not provided."));
        return;
      }

      // Generate a unique request ID
      const requestId =
        "req_" + Date.now() + "_" + Math.random().toString(36).substring(2, 9);

      // Store the resolve and reject functions for later use
      this.pendingRequests[requestId] = { resolve, reject };

      // Send a geocoding request to the VF page
      const message = {
        type: "GEOCODE_REQUEST",
        apiKey: apiKey,
        address: address,
        requestId: requestId
      };
      this.messagePort.postMessage(message);
    });
  }
}
