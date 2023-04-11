@isTest
public class TestSeachDataService {
  //
  // TEST : List<Id> searchRecordIds(String objectApiName, String keyword)
  //

  @isTest
  static void searchRecordIds() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.searchRecordIds('User', u.LastName);
    Test.stopTest();

    List<Id> recordIds = (List<Id>) result.body;
    System.assertEquals(1, recordIds.size());
    System.assertEquals(u.Id, recordIds[0]);
  }
  @isTest
  static void searchRecordIdsWhenNoRecordFound() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>());
    Test.startTest();
    DataService.Result result = SearchDataService.searchRecordIds('User', u.LastName);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<Id>);
    List<Id> recordIds = (List<Id>) result.body;
    System.assert(recordIds.isEmpty());
  }
  @isTest
  static void searchRecordIdsWhenObjectApiNameIsNull() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.searchRecordIds(null, u.LastName);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }
  @isTest
  static void searchRecordIdsWhenObjectApiNameIsEmpty() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.searchRecordIds('', u.LastName);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }
  @isTest
  static void searchRecordIdsWhenKeywordIsNull() {
    Test.setFixedSearchResults(new List<Id>{ [SELECT Id FROM User LIMIT 1][0].Id });
    Test.startTest();
    DataService.Result result = SearchDataService.searchRecordIds('User', null);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }

  @isTest
  static void searchRecordIdsWhenKeywordIsEmpty() {
    Test.setFixedSearchResults(new List<Id>{ [SELECT Id FROM User LIMIT 1][0].Id });
    Test.startTest();
    DataService.Result result = SearchDataService.searchRecordIds('User', '');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }

  //
  // TEST : Result filterRecordIds(String objectApiName, String keyword, String recordIds)
  //

  @isTest
  static void filterRecordIds() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds('User', u.LastName, u.Id);
    Test.stopTest();

    List<Id> recordIds = (List<Id>) result.body;
    System.assertEquals(1, recordIds.size());
    System.assertEquals(u.Id, recordIds[0]);
  }
  @isTest
  static void filterRecordIdsWhenNoRecordFound() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>());
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds('User', u.LastName, u.Id);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<Id>);
    List<Id> recordIds = (List<Id>) result.body;
    System.assert(recordIds.isEmpty());
  }
  @isTest
  static void filterRecordIdsWhenObjectApiNameIsNull() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds(null, u.LastName, u.Id);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }
  @isTest
  static void filterRecordIdsWhenObjectApiNameIsEmpty() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds('', u.LastName, u.Id);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }
  @isTest
  static void filterRecordIdsWhenKeywordIsNull() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds('User', null, u.Id);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }
  @isTest
  static void filterRecordIdsWhenKeywordIsEmpty() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds('User', '', u.Id);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }
  @isTest
  static void filterRecordIdsWhenRecordIdsIsEmpty() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds('User', u.LastName, '');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<Id>);
    List<Id> recordIds = (List<Id>) result.body;
    System.assert(recordIds.isEmpty());
  }
  @isTest
  static void filterRecordIdsWhenRecordIdsIsNull() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.filterRecordIds('User', u.LastName, null);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
  }

  //
  // TEST : Result getFieldValueForRecord(String recordId, String objectApiName, String fieldApiName)
  //

  @isTest
  static void getFieldValueForRecord() {
    User u = [SELECT Id, LastName FROM User LIMIT 1][0];
    Test.setFixedSearchResults(new List<Id>{ u.Id });
    Test.startTest();
    DataService.Result result = SearchDataService.getFieldValueForRecord(u.Id, 'User', 'LastName');
    Test.stopTest();

    System.assertEquals(u.LastName, result.body);
  }
}
