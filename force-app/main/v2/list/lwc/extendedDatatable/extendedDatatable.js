import LightningDatatable from "lightning/datatable";
import formulaTemplate from "./formulaTemplate.html";
import nameTemplate from "./nameTemplate.html";
import timeTemplate from "./timeTemplate.html";

export default class ExtendedDatatable extends LightningDatatable {
  static customTypes = {
    formula: {
      template: formulaTemplate,
      standardCellLayout: true
    },
    name: {
      template: nameTemplate,
      standardCellLayout: true,
      typeAttributes: ["recordId"]
    },
    time: {
      template: timeTemplate,
      standardCellLayout: true
    }
  };
}
