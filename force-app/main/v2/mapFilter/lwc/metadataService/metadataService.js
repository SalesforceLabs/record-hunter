import getObjectMetadataByName from "@salesforce/apex/MetadataService.getObjectMetadataByName";
import getObjectMetadataById from "@salesforce/apex/MetadataService.getObjectMetadataById";
import getFieldMetadata from "@salesforce/apex/MetadataService.getFieldMetadata";
import getComponentFieldMetadataList from "@salesforce/apex/MetadataService.getComponentFieldMetadataList";

export async function fetchObjectMetadataByName({ objectApiName }) {
  try {
    const object = await getObjectMetadataByName({
      objectApiName
    });

    return object;
  } catch (error) {
    console.error(
      `Failed to fetch object metadata by name: ${objectApiName}`,
      error
    );
    throw new Error(
      `Failed to fetch object metadata by name: ${objectApiName}`
    );
  }
}

export async function fetchObjectMetadataById({ recordId }) {
  try {
    const object = await getObjectMetadataById({
      recordId
    });

    return object;
  } catch (error) {
    console.error(
      `Failed to fetch object metadata by record ID: ${recordId}`,
      error
    );
    throw new Error(
      `Failed to fetch object metadata by record ID: ${recordId}`
    );
  }
}

export async function fetchFieldMetadata(
  objectName,
  qualifiedFieldName,
  throwIfNotFound = true
) {
  const [currentFieldName, ...remainingQualifiedFieldNames] =
    qualifiedFieldName?.split(".") || [];

  try {
    const currentField = await getFieldMetadata({
      objectApiName: objectName,
      fieldApiName: currentFieldName
    });

    if (currentField.type !== "REFERENCE") {
      currentField.qualifiedName = currentField.name;

      if (currentField.type === "ADDRESS" || currentField.type === "LOCATION") {
        currentField.componentFields = await getComponentFieldMetadataList({
          objectApiName: objectName,
          fieldApiName: currentField.name
        });

        currentField.componentFields?.forEach((compoundField) => {
          compoundField.qualifiedName = compoundField.name;
        });
      }
      return currentField;
    }
    const resolvedField = await fetchFieldMetadata(
      currentField.referenceTo[0].objectName,
      remainingQualifiedFieldNames.join(".")
    );
    resolvedField.qualifiedName = `${currentField.name}.${resolvedField.qualifiedName}`;
    resolvedField.componentFields?.forEach((compoundField) => {
      compoundField.qualifiedName = `${currentField.name}.${compoundField.qualifiedName}`;
    });

    return resolvedField;
  } catch (error) {
    if (!throwIfNotFound) {
      return null;
    }
    console.error(
      `Failed to fetch field metadata for ${objectName}.${qualifiedFieldName}`,
      error
    );
    throw new Error(
      `Failed to fetch field metadata for ${objectName}.${qualifiedFieldName}`
    );
  }
}

export function toRelationshipFieldName(qualifiedFieldName) {
  // フィールドパスをドットで分割
  const fields = qualifiedFieldName.split(".");

  // 各フィールドを変換
  const transformedFields = fields.map((field, index) => {
    // 最後のフィールドは変換しない
    if (index < fields.length - 1) {
      // 標準関係フィールドの変換
      if (field.endsWith("Id")) {
        return field.slice(0, -2); // 'Id'を削除
      }
      // カスタム関係フィールドの変換
      else if (field.endsWith("__c")) {
        return field.slice(0, -3) + "__r"; // '__c'を'__r'に置換
      }
    }
    // 最後のフィールドはそのまま
    return field;
  });

  // 変換後のフィールドパスをドットで結合
  return transformedFields.join(".");
}
