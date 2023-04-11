@isTest
public class TestSchemaDataService {
  // TEST: Result getObjectInfoByName(String objectApiName)
  @isTest
  static void getObjectInfoByName() {
    DataService.Result result = SchemaDataService.getObjectInfoByName('Account');
    Map<String, Object> fieldInfo = (Map<String, Object>) result.body;
    System.assertEquals('Account', fieldInfo.get('name'));
  }

  // TEST: Result getFieldInfo(String objectApiName, String fieldApiName)
  @isTest
  static void getFieldInfo() {
    DataService.Result result = SchemaDataService.getFieldInfo('Account', 'Name');
    Map<String, Object> fieldInfo = (Map<String, Object>) result.body;
    System.assertEquals('Name', fieldInfo.get('name'));
  }

  // TEST: Result getFieldInfos(String objectApiName, String fieldApiNames, Boolean skipError)
  @isTest
  static void getFieldInfos() {
    DataService.Result result = SchemaDataService.getFieldInfos('Account', 'Name', false);
    List<Map<String, Object>> fieldInfos = (List<Map<String, Object>>) result.body;
    Map<String, Object> fieldInfo = (Map<String, Object>) fieldInfos[0];
    System.assertEquals('Name', fieldInfo.get('name'));
  }

  @isTest
  static void getFieldInfosWhenSkipErrorIsTrue() {
    DataService.Result result = SchemaDataService.getFieldInfos('Account', '123, Name', true);
    List<Map<String, Object>> fieldInfos = (List<Map<String, Object>>) result.body;
    Map<String, Object> fieldInfo = (Map<String, Object>) fieldInfos[0];
    System.assertEquals('Name', fieldInfo.get('name'));
  }
}
