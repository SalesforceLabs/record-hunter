import { createElement } from "lwc";
import MapFilterCard from "c/mapFilterCard";

// import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
// import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

describe("c-map-filter-card", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("has component name on the header", () => {
    const element = createElement("c-map-filter-card", {
      is: MapFilterCard
    });
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const componentHeader = element.shadowRoot.querySelector("h1");
      expect(componentHeader.textContent).toBe("mapFilterCard");
    });
  });
});
