public with sharing class Describer {
  public class SObjectInfo {
    public Schema.DescribeSObjectResult describeSObjectResult;
    public SObjectInfo(Schema.DescribeSObjectResult describeSObjectResult) {
      this.describeSObjectResult = describeSObjectResult;
    }
  }

  public class FieldInfo {
    public Schema.DescribeSObjectResult describeSObjectResult;
    public Schema.DescribeFieldResult describeFieldResult;
    public String queriableFieldApiName;
    public String fieldPath;
    public String errorMessage;
    public Boolean hasError = false;
    public Boolean isRelative = false;
    public FieldInfo(
      Schema.DescribeSObjectResult describeSObjectResult,
      Schema.DescribeFieldResult describeFieldResult,
      String queriableFieldApiName
    ) {
      this.describeSObjectResult = describeSObjectResult;
      this.describeFieldResult = describeFieldResult;
      this.queriableFieldApiName = queriableFieldApiName;
    }
    public FieldInfo(String errorMessage) {
      this.hasError = true;
      this.errorMessage = errorMessage;
    }
  }

  public static Schema.DescribeFieldResult describeField(
    String objectApiName,
    String fieldApiName
  ) {
    if (String.isBlank(objectApiName)) {
      throwException('"objectApiName" must not be blank.');
    }
    if (String.isBlank(fieldApiName)) {
      throwException('"fieldApiName" must not be blank.');
    }

    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe()
      .get(objectApiName.trim())
      ?.getDescribe(SObjectDescribeOptions.DEFERRED);
    if (dsor == null) {
      throwException(
        '"' + objectApiName + '" is not a valid Salesforce Object API Name.'
      );
    }

    Schema.DescribeFieldResult dfr = dsor.fields.getMap()
      .get(fieldApiName)
      ?.getDescribe();
    if (dfr == null) {
      throwException('"' + fieldApiName + '" is not a valid field API Name.');
    }
    return dfr;
  }

  public static Schema.DescribeSObjectResult describeSObject(
    String objectApiName
  ) {
    if (String.isBlank(objectApiName)) {
      throwException('"objectApiName" must not be blank.');
    }
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe()
      .get(objectApiName.trim())
      ?.getDescribe(SObjectDescribeOptions.DEFERRED);
    if (dsor == null) {
      throwException(
        '"' + objectApiName + '" is not a valid Salesforce Object API Name.'
      );
    }
    return dsor;
  }

  public static List<FieldInfo> describeFields(
    String objectApiName,
    String fieldApiNames
  ) {
    List<FieldInfo> results = new List<FieldInfo>();
    try {
      List<String> fieldPaths = String.isNotBlank(fieldApiNames)
        ? fieldApiNames.split('\\,')
        : new List<String>();

      for (String fieldPath : fieldPaths) {
        FieldInfo fieldInfo = describeField(
          objectApiName?.trim(),
          fieldPath.trim(),
          new List<String>()
        );
        fieldInfo.fieldPath = fieldPath.trim();
        results.add(fieldInfo);
      }
    } catch (Exception e) {
      throwException(e.getMessage());
    }
    return results;
  }

  @TestVisible
  private static FieldInfo describeField(
    String objectApiName,
    String fieldPath,
    List<String> relationshipNames
  ) {
    if (relationshipNames == null) {
      relationshipNames = new List<String>();
    }
    if (String.isBlank(objectApiName)) {
      return new FieldInfo('objectApiName must not be empty.');
    } else if (String.isBlank(fieldPath)) {
      return new FieldInfo('fieldPath must not be empty.');
    }

    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe()
      .get(objectApiName)
      ?.getDescribe(SObjectDescribeOptions.DEFERRED);
    if (dsor == null) {
      throwException(
        '"' + objectApiName + '" is not a valid Salesforce Object API Name.'
      );
    }

    List<String> fieldPathComponents = fieldPath.split('\\.');
    String fieldPathComponent = fieldPathComponents.remove(0);
    String fieldApiName = fieldPathComponent.substringBefore(':');
    String preferedObjectApiName = fieldPathComponent.substringAfter(':');

    Schema.DescribeFieldResult dfr = dsor.fields.getMap()
      .get(fieldApiName)
      ?.getDescribe();
    if (dfr == null) {
      return new FieldInfo(
        '"' + fieldApiName + '" is not a valid field API name.'
      );
    }

    if (
      dfr.getType() == Schema.DisplayType.REFERENCE &&
      fieldPathComponents.size() > 0
    ) {
      if (dfr.getRelationshipName() == null) {
        return new FieldInfo(
          '"' + fieldApiName + '"  is not a valid reference field API name.'
        );
      }
      String reducedObjectApiName = getReferenceToObjectApiName(
        dfr,
        preferedObjectApiName
      );
      String reducedFieldPath = String.join(fieldPathComponents, '.');
      relationshipNames.add(dfr.getRelationshipName());
      return describeField(
        reducedObjectApiName,
        reducedFieldPath,
        relationshipNames
      );
    } else if (
      dfr.getType() == Schema.DisplayType.DATE ||
      dfr.getType() == Schema.DisplayType.DATETIME
    ) {
      FieldInfo field = new FieldInfo(dsor, dfr, fieldApiName);
      if (preferedObjectApiName == 'relative') {
        field.fieldPath = field.fieldPath?.split(':')[0];
        field.isRelative = true;
      }
      return field;
    } else {
      relationshipNames.add(dfr.getName());
      return new FieldInfo(dsor, dfr, String.join(relationshipNames, '.'));
    }
  }

  @TestVisible
  private static String getReferenceToObjectApiName(
    Schema.DescribeFieldResult dfr,
    String preferedObjectApiName
  ) {
    for (Schema.SObjectType sot : dfr.getReferenceTo()) {
      if (
        sot.getDescribe().getName().toLowerCase() ==
        preferedObjectApiName.toLowerCase()
      ) {
        return sot.getDescribe().getName();
      }
    }
    return dfr.getReferenceTo()[0].getDescribe().getName();
  }

  private static AuraHandledException throwException(String message) {
    AuraHandledException e = new AuraHandledException(message);
    e.setMessage(message);
    throw e;
  }
}
