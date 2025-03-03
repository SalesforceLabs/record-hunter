/**
 * @description This class provides methods to describe Salesforce objects and their fields.
 */
public with sharing class MetadataService {
  /**
   * @description This class represents the metadata of a Salesforce object.
   */
  public class ObjectMetadata {
    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String label { get; set; }
  }
  /**
   * @description This class represents the metadata of a Salesforce object field.
   */
  public class FieldMetadata {
    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String label { get; set; }

    @AuraEnabled
    public String type { get; set; }

    @AuraEnabled
    public Boolean isFilterable { get; set; }

    @AuraEnabled
    public Boolean isUnique { get; set; }

    @AuraEnabled
    public Boolean isCalculated { get; set; }

    @AuraEnabled
    public Integer precision { get; set; }

    @AuraEnabled
    public Integer scale { get; set; }

    @AuraEnabled
    public String compoundFieldName { get; set; }

    @AuraEnabled
    public Boolean isCompoundField { get; set; }

    @AuraEnabled
    public List<ReferenceToMetadata> referenceTo { get; set; }
  }

  /**
   * @description This class represents the metadata of a reference to another Salesforce object.
   */
  public class ReferenceToMetadata {
    @AuraEnabled
    public String objectName { get; set; }

    @AuraEnabled
    public String childRelationshipName { get; set; }
  }

  /**
   * @description Describes the specified Salesforce object and returns its metadata.
   * @param objectApiName The API name of the Salesforce object to describe.
   * @return An ObjectMetadata containing the object's metadata and its fields.
   * @throws AuraHandledException if the objectApiName is null, empty, or invalid.
   */
  @AuraEnabled(cacheable=false)
  public static ObjectMetadata getObjectMetadataByName(String objectApiName) {
    validateObjectApiName(objectApiName);
    Schema.DescribeSObjectResult dsor = getDescribeSObjectResult(objectApiName);
    ObjectMetadata objectMetadata = createObjectMetadata(dsor);
    return objectMetadata;
  }

  @AuraEnabled(cacheable=false)
  public static ObjectMetadata getObjectMetadataById(String recordId) {
    Id parsedRecordId;
    try {
      parsedRecordId = (Id) recordId;
    } catch (Exception e) {
      throwAuraHandledException(
        'The recordId parameter is not a valid Salesforce record ID.'
      );
    }
    String objectApiName = parsedRecordId.getSObjectType()
      .getDescribe(SObjectDescribeOptions.DEFERRED)
      .getName();

    Schema.DescribeSObjectResult dsor = getDescribeSObjectResult(objectApiName);
    ObjectMetadata objectMetadata = createObjectMetadata(dsor);
    return objectMetadata;
  }

  @AuraEnabled(cacheable=false)
  public static FieldMetadata getFieldMetadata(
    String objectApiName,
    String fieldApiName
  ) {
    Schema.DescribeSObjectResult dsor = getDescribeSObjectResult(objectApiName);
    Schema.DescribeFieldResult dfr = dsor.fields.getMap()
      .get(fieldApiName)
      ?.getDescribe();

    if (dfr == null) {
      throwAuraHandledException(
        'The specified field does not exist: ' + fieldApiName
      );
    }

    FieldMetadata fieldMetadata = createFieldMetadata(dfr, dsor.getName());
    return fieldMetadata;
  }

  @AuraEnabled(cacheable=false)
  public static List<FieldMetadata> getComponentFieldMetadataList(
    String objectApiName,
    String fieldApiName
  ) {
    Schema.DescribeSObjectResult dsor = getDescribeSObjectResult(objectApiName);

    List<FieldMetadata> fieldMetadataList = new List<FieldMetadata>();
    for (Schema.SObjectField sObjectField : dsor.fields.getMap().values()) {
      Schema.DescribeFieldResult dfr = sObjectField.getDescribe();
      if (!dfr.isAccessible()) {
        continue;
      }
      if (dfr.getCompoundFieldName() == fieldApiName) {
        FieldMetadata fieldMetadata = createFieldMetadata(dfr, objectApiName);
        fieldMetadataList.add(fieldMetadata);
      }
    }
    return fieldMetadataList;
  }

  private static void validateObjectApiName(String objectApiName) {
    if (String.isBlank(objectApiName)) {
      throwAuraHandledException(
        'The objectApiName parameter cannot be null or empty.'
      );
    }
    if (!Schema.getGlobalDescribe().containsKey(objectApiName)) {
      throwAuraHandledException(
        'The specified object does not exist: ' + objectApiName
      );
    }
  }

  private static Schema.DescribeSObjectResult getDescribeSObjectResult(
    String objectApiName
  ) {
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe()
      .get(objectApiName)
      .getDescribe(SObjectDescribeOptions.DEFERRED);
    if (!dsor.isAccessible()) {
      throwAuraHandledException(
        'The specified object is not accessible: ' + objectApiName
      );
    }
    return dsor;
  }

  private static ObjectMetadata createObjectMetadata(
    Schema.DescribeSObjectResult dsor
  ) {
    ObjectMetadata objectMetadata = new ObjectMetadata();
    objectMetadata.name = dsor.getName();
    objectMetadata.label = dsor.getLabel();
    return objectMetadata;
  }
  private static FieldMetadata createFieldMetadata(
    Schema.DescribeFieldResult dfr,
    String objectApiName
  ) {
    FieldMetadata fieldMetadata = new FieldMetadata();
    fieldMetadata.name = dfr.getName();
    fieldMetadata.label = dfr.getLabel();
    fieldMetadata.type = dfr.getType().name();
    fieldMetadata.isFilterable = dfr.isFilterable();
    fieldMetadata.isUnique = dfr.isUnique();
    fieldMetadata.isCalculated = dfr.isCalculated();
    fieldMetadata.compoundFieldName = dfr.getCompoundFieldName();

    // if number or similar field type, add precision and scale value to dedicated variables
    if (dfr.getType() == Schema.DisplayType.Integer) {
      fieldMetadata.precision = dfr.getPrecision();
    } else if (dfr.getType() == Schema.DisplayType.Double) {
      fieldMetadata.precision = dfr.getPrecision();
      fieldMetadata.scale = dfr.getScale();
    } else if (dfr.getType() == Schema.DisplayType.Percent) {
      fieldMetadata.precision = dfr.getPrecision();
      fieldMetadata.scale = dfr.getScale();
    } else if (dfr.getType() == Schema.DisplayType.Currency) {
      fieldMetadata.precision = dfr.getPrecision();
      fieldMetadata.scale = dfr.getScale();
    }

    if (dfr.getType() == Schema.DisplayType.Reference) {
      fieldMetadata.referenceTo = getReferenceToMetadataList(
        dfr,
        objectApiName
      );
    }
    return fieldMetadata;
  }

  private static List<ReferenceToMetadata> getReferenceToMetadataList(
    Schema.DescribeFieldResult dfr,
    String objectApiName
  ) {
    List<ReferenceToMetadata> referenceToMetadataList = new List<ReferenceToMetadata>();
    for (Schema.SObjectType referenceToObject : dfr.getReferenceTo()) {
      ReferenceToMetadata referenceToMetadata = new ReferenceToMetadata();
      referenceToMetadata.objectName = referenceToObject.getDescribe()
        .getName();
      Schema.DescribeSObjectResult refDsor = Schema.getGlobalDescribe()
        .get(referenceToMetadata.objectName)
        .getDescribe(SObjectDescribeOptions.DEFERRED);
      for (
        Schema.ChildRelationship childRel : refDsor.getChildRelationships()
      ) {
        if (
          childRel.getChildSObject().getDescribe().getName() == objectApiName &&
          childRel.getField().getDescribe().getName() == dfr.getName()
        ) {
          referenceToMetadata.childRelationshipName = childRel.getRelationshipName();
          break;
        }
      }
      referenceToMetadataList.add(referenceToMetadata);
    }
    return referenceToMetadataList;
  }

  private static void throwAuraHandledException(String message) {
    AuraHandledException e = new AuraHandledException(message);
    e.setMessage(message);
    throw e;
  }
}
