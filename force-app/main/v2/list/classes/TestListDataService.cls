@isTest
public class TestListDataService {
  // TEST: Result getColumnInfos(String objectApiName, String fieldApiNames)
  @isTest
  static void getColumnInfos() {
    Test.startTest();
    DataService.Result result = ListDataService.getColumnInfos('Account', 'Name');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<ListDataService.Column>);
    List<ListDataService.Column> columnInfos = (List<ListDataService.Column>) result.body;
    System.assertEquals(1, columnInfos.size());
    System.assertEquals('Name', columnInfos[0].name);
  }

  // TEST: Result queryRecordsByIds(String objectApiName, String fieldApiNames, String recordIds, String sortedBy, String sortedDirection, Integer pageSize, Integer pageIndex)
  @isTest
  static void queryRecordsByIds() {
    User u = [SELECT Id, LastName, Profile.Name, IsActive FROM User LIMIT 1];
    Test.startTest();
    DataService.Result result = ListDataService.queryRecordsByIds('User', 'LastName', u.Id, 'Id', 'asc', 10, 0);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<Sobject>);
    List<Sobject> records = (List<Sobject>) result.body;
    System.assertEquals(1, records.size());
    System.assertEquals(u.LastName, records[0].get('LastName'));
  }
}
