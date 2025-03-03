@isTest
public class RecordServiceTest {
  @testSetup
  static void setupTestData() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
  }

  @isTest
  static void testGetRecordById_NormalCase() {
    // 正常系: 有効なRecord Idと存在するフィールドで呼び出す
    Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];
    Test.startTest();
    SObject result = RecordService.getRecordById(
      testAcc.Id,
      new List<String>{ 'Name' }
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Record should be returned.');
    System.assertEquals(
      testAcc.Name,
      (String) result.get('Name'),
      'Fetched Name should match.'
    );
  }

  @isTest
  static void testGetRecordById_InvalidRecordId() {
    // 異常系: 不正なRecord Id文字列
    Boolean exceptionThrown = false;
    Test.startTest();
    try {
      RecordService.getRecordById('InvalidId', new List<String>{ 'Name' });
    } catch (AuraHandledException e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('not a valid Salesforce record ID')
      );
    }
    Test.stopTest();
    System.assertEquals(
      true,
      exceptionThrown,
      'Exception should be thrown for invalid record ID.'
    );
  }

  @isTest
  static void testGetRecordById_RecordNotFound() {
    // 異常系: 存在しない有効なID(ダミーID使用)
    // Object Typeは存在するが、そのIDのレコードが無いケース
    Boolean exceptionThrown = false;
    Id nonExistentId = '001000000000000AAA'; // 不正でないが存在しないAccount ID形式
    Test.startTest();
    try {
      RecordService.getRecordById(nonExistentId, new List<String>{ 'Name' });
    } catch (AuraHandledException e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('The specified record does not exist')
      );
    }
    Test.stopTest();
    System.assertEquals(
      true,
      exceptionThrown,
      'Exception should be thrown for non-existent record.'
    );
  }

  @isTest
  static void testGetRecordById_FieldNotExist() {
    // 異常系: 存在しないフィールド指定
    Account testAcc = [SELECT Id FROM Account LIMIT 1];
    Boolean exceptionThrown = false;
    Test.startTest();
    try {
      RecordService.getRecordById(
        testAcc.Id,
        new List<String>{ 'NotExistField__c' }
      );
    } catch (AuraHandledException e) {
      exceptionThrown = true;
      System.assert(
        e.getMessage().contains('The specified field does not exist')
      );
    }
    Test.stopTest();
    System.assertEquals(
      true,
      exceptionThrown,
      'Exception should be thrown for non-existent field.'
    );
  }

  @isTest
  static void testFindRecordsByLocation_NormalCase() {
    // 正常系: findRecordsByLocationを呼び出す（Unit=km, distance>0を指定）
    // BillingAddressはAccountに存在し、Addressフィールド、Nameは通常取得可能
    // BillingLatitude/BillingLongitudeは標準で用意された地理情報フィールド(GeoLocation有効な組織を前提)
    // テスト環境ではたとえクエリで0件でもクエリ文生成によりカバレッジを稼げる
    Test.startTest();
    List<SObject> records = RecordService.findRecordsByLocation(
      'Account',
      'BillingAddress',
      'BillingLatitude',
      'BillingLongitude',
      'Name',
      'Name',
      10, // latitude
      10, // longitude
      100, // distance
      'km', // unit
      '' // recordIds (empty)
    );
    Test.stopTest();

    // 結果が0件でもエラーにならなければOK(カバレッジ確保)
    System.assertNotEquals(
      null,
      records,
      'Should return a list even if empty.'
    );
  }

  @isTest
  static void testGetQueryStringForFindRecordsByLocation_AllConditions() {
    // 全条件(距離条件 + recordIds条件)あり
    Test.startTest();
    String query = RecordService.getQueryStringForFindRecordsByLocation(
      'Account',
      'BillingAddress',
      'BillingLatitude',
      'BillingLongitude',
      'Name',
      'Name',
      10, // latitude
      10, // longitude
      50, // distance
      'km', // unit
      '001000000000000AAA'
    );
    Test.stopTest();
    System.assert(
      query.contains('DISTANCE'),
      'Query should contain DISTANCE condition'
    );
    System.assert(
      query.contains('Id IN (\''),
      'Query should contain Id IN condition'
    );
  }

  @isTest
  static void testGetQueryStringForFindRecordsByLocation_NoDistanceNoRecordIds() {
    // distanceとunit、latitude、longitudeがnull → 条件なし
    Test.startTest();
    String query = RecordService.getQueryStringForFindRecordsByLocation(
      'Account',
      'BillingAddress',
      'BillingLatitude',
      'BillingLongitude',
      'Name',
      'Name',
      null,
      null,
      null,
      null,
      null
    );
    Test.stopTest();
    System.assert(
      !query.contains('WHERE'),
      'Query should have no WHERE clause when no conditions provided'
    );
  }

  @isTest
  static void testGetQueryStringForFindRecordsByLocation_DistanceOnly() {
    // distance条件のみ(緯度経度単位OK、recordIdsなし)
    Test.startTest();
    String query = RecordService.getQueryStringForFindRecordsByLocation(
      'Account',
      'BillingAddress',
      'BillingLatitude',
      'BillingLongitude',
      'Name',
      'Name',
      20,
      30,
      10,
      'mi',
      ''
    );
    Test.stopTest();
    System.assert(
      query.contains('DISTANCE'),
      'Query should contain DISTANCE condition'
    );
    System.assert(
      !query.contains('Id IN ('),
      'Should not contain recordIds condition'
    );
  }

  @isTest
  static void testGetQueryStringForFindRecordsByLocation_RecordIdsOnly() {
    // recordIds条件のみ
    Test.startTest();
    String query = RecordService.getQueryStringForFindRecordsByLocation(
      'Account',
      'BillingAddress',
      'BillingLatitude',
      'BillingLongitude',
      'Name',
      'Name',
      null,
      null,
      null,
      null,
      '001000000000000AAA,001000000000000AAB'
    );
    Test.stopTest();
    System.assert(
      !query.contains('DISTANCE'),
      'Should not contain DISTANCE condition'
    );
    System.assert(
      query.contains('Id IN (\''),
      'Should contain recordIds condition'
    );
  }

  @isTest
  static void testGetQueryStringForFindRecordsByLocation_RelationshipField() {
    // Relationshipフィールドを混ぜてtoRelationshipNameをテストする
    // Contact->Account->OwnerIdなど
    Test.startTest();
    String query = RecordService.getQueryStringForFindRecordsByLocation(
      'Contact',
      'MailingAddress', // Contact用Addressフィールド
      'MailingLatitude',
      'MailingLongitude',
      'Account.OwnerId', // Relationship path
      'Name',
      10,
      20,
      5,
      'km',
      ''
    );
    Test.stopTest();

    // OwnerIdがクエリ上でOwnerに変換されていることを確認
    System.assert(
      query.contains('Account.Owner'),
      'OwnerId should be converted to Owner relationship.'
    );
  }
}
