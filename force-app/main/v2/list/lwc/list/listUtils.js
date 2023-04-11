const flattenRecord = (record) => {
  const result = {};
  const recurse = (cur, prop) => {
    if (Object(cur) !== cur) {
      result[prop] = cur;
    } else {
      let isEmpty = true;
      for (let p in cur) {
        if (Object.prototype.hasOwnProperty.call(cur, p)) {
          isEmpty = false;
          recurse(cur[p], prop ? prop + "." + p : p);
        }
      }
      if (isEmpty && prop) result[prop] = {};
    }
  };
  recurse(record);
  return result;
};

const getColumnType = (columnInfo) => {
  const type = columnInfo.type;
  if (columnInfo.isNameField) {
    return "name";
  } else if (columnInfo.isCalculated) {
    return "formula";
  } else if (["STRING", "ID", "TEXTAREA", "PICKLIST", "MULTIPICKLIST"].includes(type)) {
    return "text";
  } else if (type === "EMAIL") {
    return "email";
  } else if (type === "PHONE") {
    return "phone";
  } else if (["INTEGER", "DOUBLE"].includes(type)) {
    return "number";
  } else if (type === "PERCENT") {
    return "percent";
  } else if (type === "CURRENCY") {
    return "currency";
  } else if (type === "BOOLEAN") {
    return "boolean";
  } else if (type === "DATE") {
    return "date-local";
  } else if (type === "DATETIME") {
    return "date";
  } else if (type === "TIME") {
    return "time";
  }
  return type;
};
const getColumnTypeAttributes = (columnInfo) => {
  const type = columnInfo.type;
  if (columnInfo.isNameField) {
    const fieldPathComponents = columnInfo.name.split(".");
    fieldPathComponents.splice(fieldPathComponents.length - 1, 1, "Id");
    return {
      recordId: {fieldName: fieldPathComponents.join(".")}
    };
  } else if (type === "DATE") {
    return {
      year: "numeric",
      month: "2-digit",
      day: "2-digit"
    };
  } else if (type === "TIME") {
    return {
      hour: "2-digit",
      minute: "2-digit"
    };
  } else if (type === "DATETIME") {
    return {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit"
    };
  } else if (type === "PERCENT") {
    return {maximumFractionDigits: columnInfo.scale};
  }
  return type;
};
const getRows = (data, columns) => {
  const rows = [];
  for (let record of data) {
    const row = flattenRecord(record);
    for (let column of columns) {
      if (column.type === "percent" && row[column.fieldName]) {
        row[column.fieldName] /= 100.0;
      }
      if (column.type === "time" && Number.isInteger(row[column.fieldName])) {
        row[column.fieldName] = new Date(row[column.fieldName]).toISOString().substring(11, 19);
      }
    }
    rows.push(row);
  }
  return rows;
};
export {getColumnTypeAttributes, getColumnType, getRows};
