public with sharing class SchemaDataService extends DataService {
  @AuraEnabled(cacheable=true)
  public static Result getObjectInfoByName(String objectApiName) {
    try {
      Schema.DescribeSObjectResult dsor = Describer.describeSObject(objectApiName);
      Map<String, Object> objectInfo = new Map<String, Object>();
      objectInfo.put('name', dsor.getName());
      objectInfo.put('label', dsor.getLabel());
      return new Result(objectInfo);
    } catch (Exception e) {
      return new Result('', e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Result getFieldInfo(String objectApiName, String fieldApiName) {
    try {
      Schema.DescribeSObjectResult dsor = Describer.describeSObject(objectApiName);
      Schema.DescribeFieldResult dfr = Describer.describeField(objectApiName, fieldApiName);
      Map<String, Object> fieldInfo = new Map<String, Object>();
      fieldInfo.put('name', dfr.getName());
      return new Result(fieldInfo);
    } catch (Exception e) {
      return new Result('', e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Result getFieldInfos(String objectApiName, String fieldApiNames, Boolean skipError) {
    try {
      List<Map<String, Object>> fieldInfos = new List<Map<String, Object>>();
      Integer i = 0;
      List<Describer.FieldInfo> results = Describer.describeFields(objectApiName, fieldApiNames);
      for (Describer.FieldInfo result : results) {
        if (!skipError && result.hasError) {
          return new Result('', result.errorMessage);
        } else if (!result.hasError) {
          Schema.DescribeFieldResult dfr = result.describeFieldResult;
          Map<String, Object> fieldInfo = new Map<String, Object>();
          fieldInfo.put('name', dfr.getName());
          fieldInfo.put('type', dfr.getType().name());
          fieldInfo.put('path', result.fieldPath);
          fieldInfo.put('index', i);
          fieldInfos.add(fieldInfo);
        }
        i++;
      }
      return new Result(fieldInfos);
    } catch (Exception e) {
      return new Result('', e.getMessage());
    }
  }
}
