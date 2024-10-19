import getRecordById from "@salesforce/apex/RecordService.getRecordById";
import getQueryStringForFindRecordsByLocation from "@salesforce/apex/RecordService.getQueryStringForFindRecordsByLocation";
import findRecordsByLocation from "@salesforce/apex/RecordService.findRecordsByLocation";

export async function fetchRecordById({ recordId, fields }) {
  if (fields && !Array.isArray(fields)) {
    console.error("fields must be an array");
    throw new Error("fields must be an array");
  }
  try {
    const record = await getRecordById({
      recordId,
      fields: fields.filter((field) => field?.trim())
    });

    if (!record) {
      throw new Error(`Record "${recordId}" not found`);
    }

    return record;
  } catch (error) {
    console.error("ERROR: fetchRecordById: ", error);
    throw error;
  }
}

export async function queryRecordsByLocation(
  {
    objectApiName,
    locationFieldApiName,
    latitudeFieldApiName,
    longitudeFieldApiName,
    markerTitleFieldApiName,
    markerContentFieldApiName,
    latitude,
    longitude,
    distance,
    unit,
    recordIds
  },
  { isDebugMode }
) {
  if (isDebugMode) {
    try {
      const queryString = await getQueryStringForFindRecordsByLocation({
        objectApiName,
        locationFieldApiName,
        latitudeFieldApiName,
        longitudeFieldApiName,
        markerTitleFieldApiName,
        markerContentFieldApiName,
        latitude,
        longitude,
        distance,
        unit,
        recordIds
      });
      console.log("queryString: ", queryString);
    } catch (error) {
      console.error("ERROR: getQueryStringForFindRecordsByLocation: ", error);
      throw error;
    }
  }

  try {
    const records = await findRecordsByLocation({
      objectApiName,
      locationFieldApiName,
      latitudeFieldApiName,
      longitudeFieldApiName,
      markerTitleFieldApiName,
      markerContentFieldApiName,
      latitude,
      longitude,
      distance,
      unit,
      recordIds
    });
    return records;
  } catch (error) {
    console.error("ERROR: queryRecordsByLocation: ", error);
    throw error;
  }
}
