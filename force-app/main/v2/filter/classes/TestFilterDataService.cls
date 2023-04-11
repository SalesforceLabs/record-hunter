@isTest
public class TestFilterDataService {
  // TEST: Result getInputInfos(String objectApiName, String fieldApiNames)
  @isTest
  static void getInputInfos() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos('Account', 'Name');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<FilterDataService.InputInfo>);
    List<FilterDataService.InputInfo> inputInfos = (List<FilterDataService.InputInfo>) result.body;
    System.assertEquals(1, inputInfos.size());
    System.assertEquals('Name', inputInfos[0].name);
  }
  @isTest
  static void getInputInfosForMultipleFieldApiNames() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos('Account', 'Name,AccountNumber,Site');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<FilterDataService.InputInfo>);
    List<FilterDataService.InputInfo> inputInfos = (List<FilterDataService.InputInfo>) result.body;
    System.assertEquals(3, inputInfos.size());
    System.assertEquals('Name', inputInfos[0].name);
    System.assertEquals('AccountNumber', inputInfos[1].name);
    System.assertEquals('Site', inputInfos[2].name);
  }
  @isTest
  static void getInputInfosForPicklist() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos('Account', 'Type');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<FilterDataService.InputInfo>);
    List<FilterDataService.InputInfo> inputInfos = (List<FilterDataService.InputInfo>) result.body;
    System.assertEquals(1, inputInfos.size());
    System.assertEquals('Type', inputInfos[0].name);
    System.assertNotEquals(null, inputInfos[0].options);
  }
  @isTest
  static void getInputInfosForCombobox() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos('Task', 'Subject');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<FilterDataService.InputInfo>);
    List<FilterDataService.InputInfo> inputInfos = (List<FilterDataService.InputInfo>) result.body;
    System.assertEquals(1, inputInfos.size());
    System.assertEquals('Subject', inputInfos[0].name);
    System.assertEquals('COMBOBOX', inputInfos[0].type);
    System.assertNotEquals(null, inputInfos[0].options);
  }
  @isTest
  static void getInputInfosWhenObjectApiNameIsNull() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos(null, 'Id');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
    System.assertEquals('', result.errorCode);
    System.assertEquals('', result.errorMessage);
  }
  @isTest
  static void getInputInfosWhenObjectApiNameIsEmpty() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos('', 'Id');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
    System.assertEquals('', result.errorCode);
    System.assertEquals('', result.errorMessage);
  }
  @isTest
  static void getInputInfosWhenFieldApiNamesIsNull() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos('Account', null);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<FilterDataService.InputInfo>);
    List<FilterDataService.InputInfo> inputInfos = (List<FilterDataService.InputInfo>) result.body;
    System.assertEquals(0, inputInfos.size());
  }
  @isTest
  static void getInputInfosWhenFieldApiNamesIsEmpty() {
    Test.startTest();
    DataService.Result result = FilterDataService.getInputInfos('Account', '');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<FilterDataService.InputInfo>);
    List<FilterDataService.InputInfo> inputInfos = (List<FilterDataService.InputInfo>) result.body;
    System.assertEquals(0, inputInfos.size());
  }

  // TEST: Result filterRecordIds(String objectApiName, String fieldApiNames, String formDataJson, String recordIds, String customLogic)
  @isTest
  static void filterRecordIds() {
    User u = [SELECT Id, LastName, Profile.Name, IsActive FROM User LIMIT 1];
    Test.startTest();
    DataService.Result result = FilterDataService.filterRecordIds(
      'User',
      'Name,LastName,ProfileId.Name,IsActive',
      '{"LastName": {"value": "' +
      u.LastName +
      '"},"IsActive": {"value": "' +
      u.IsActive +
      '"}}',
      u.Id,
      '0 AND 1 AND 2 AND 3'
    );
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<Id>);
    List<Id> recordIds = (List<Id>) result.body;
    System.assert(!recordIds.isEmpty());
    System.assert(recordIds.contains(u.Id));
  }
  @isTest
  static void filterRecordIdsWhenObjectApiNameIsEmpty() {
    User u = [SELECT Id, LastName, Profile.Name, IsActive FROM User LIMIT 1];
    Test.startTest();
    DataService.Result result = FilterDataService.filterRecordIds(
      '',
      'Name,LastName,ProfileId.Name,IsActive',
      '{"LastName": {"value": "' +
      u.LastName +
      '"},"IsActive": {"value": "' +
      u.IsActive +
      '"}}',
      u.Id,
      '0 AND 1 AND 2 AND 3'
    );
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
    System.assertEquals('', result.errorCode);
    System.assertEquals('', result.errorMessage);
  }
  @isTest
  static void filterRecordIdsWhenFieldApiNamesIsEmpty() {
    User u = [SELECT Id, LastName, Profile.Name, IsActive FROM User LIMIT 1];
    Test.startTest();
    DataService.Result result = FilterDataService.filterRecordIds(
      'User',
      '',
      '{"LastName": {"value": "' +
      u.LastName +
      '"},"ProfileId.Name": {"value": "' +
      u.Profile.Name +
      '"},"IsActive": {"value": "' +
      u.IsActive +
      '"}}',
      u.Id,
      '0 AND 1 AND 2 AND 3'
    );
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(true, result.hasError);
    System.assertEquals(null, result.body);
    System.assertEquals('', result.errorCode);
    System.assertEquals('', result.errorMessage);
  }

  // TEST : Result queryRecordIds(String objectApiName, String fieldApiNames, String formDataJson, String customLogic)
  @isTest
  static void queryRecordIds() {
    User u = [SELECT Id, LastName, Profile.Name, IsActive FROM User LIMIT 1];
    Test.startTest();
    DataService.Result result = FilterDataService.queryRecordIds(
      'User',
      'Name,LastName,ProfileId.Name,IsActive',
      '{"LastName": {"value": "' +
      u.LastName +
      '"},"IsActive": {"value": "' +
      u.IsActive +
      '"}}',
      '0 AND 1 AND 2 AND 3'
    );
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof List<Id>);
    List<Id> recordIds = (List<Id>) result.body;
    System.assert(!recordIds.isEmpty());
    System.assert(recordIds.contains(u.Id));
  }

  // TEST : Result getRecord(String recordId, String fieldNamesOrDefaultValues)
  @isTest
  static void getRecord() {
    User u = [SELECT Id, LastName, Profile.Name, IsActive FROM User LIMIT 1];
    Test.startTest();
    DataService.Result result = FilterDataService.getRecord(u.Id, 'Id, LastName, 123');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(false, result.hasError);
    System.assertNotEquals(null, result.body);
    System.assert(result.body instanceof User);
    User record = (User) result.body;
    System.assertEquals(u.Id, record.Id);
    System.assertEquals(u.LastName, record.LastName);
  }

  @isTest
  static void reduceTokens() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0' });
    System.assertEquals(1, results.size());
    System.assertEquals('0', results[0].lexeme);
  }
  @isTest
  static void reduceTokensForLogicalAnd() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND 1');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0', '1' });
    System.assertEquals(3, results.size());
    System.assertEquals('0', results[0].lexeme);
    System.assertEquals('AND', results[1].lexeme);
    System.assertEquals('1', results[2].lexeme);
  }
  @isTest
  static void reduceTokensForLogicalOr() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 OR 1');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0', '1' });
    System.assertEquals(3, results.size());
    System.assertEquals('0', results[0].lexeme);
    System.assertEquals('OR', results[1].lexeme);
    System.assertEquals('1', results[2].lexeme);
  }
  @isTest
  static void reduceTokensForComplexLogic() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND (1 OR 2)');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0', '1', '2' });
    System.assertEquals(7, results.size());
    System.assertEquals('0', results[0].lexeme);
    System.assertEquals('AND', results[1].lexeme);
    System.assertEquals('(', results[2].lexeme);
    System.assertEquals('1', results[3].lexeme);
    System.assertEquals('OR', results[4].lexeme);
    System.assertEquals('2', results[5].lexeme);
    System.assertEquals(')', results[6].lexeme);
  }
  @isTest
  static void reduceTokensForParensReduction() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('(0)');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0' });
    System.assertEquals(3, results.size());
    System.assertEquals('(', results[0].lexeme);
    System.assertEquals('0', results[1].lexeme);
    System.assertEquals(')', results[2].lexeme);
  }
  @isTest
  static void reduceTokensForHeadReduction() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND 1');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '1' });
    System.assertEquals(1, results.size());
    System.assertEquals('1', results[0].lexeme);
  }
  @isTest
  static void reduceTokensForTailReduction() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND 1');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0' });
    System.assertEquals(1, results.size());
    System.assertEquals('0', results[0].lexeme);
  }
  @isTest
  static void reduceTokensForMiddleReduction() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND 1 AND 2');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0', '2' });
    System.assertEquals(3, results.size());
    System.assertEquals('0', results[0].lexeme);
    System.assertEquals('AND', results[1].lexeme);
    System.assertEquals('2', results[2].lexeme);
  }
  @isTest
  static void reduceTokensForMiddleReductionWithParens() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND (1 OR 2)');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0', '2' });
    System.assertEquals(5, results.size());
    System.assertEquals('0', results[0].lexeme);
    System.assertEquals('AND', results[1].lexeme);
    System.assertEquals('(', results[2].lexeme);
    System.assertEquals('2', results[3].lexeme);
    System.assertEquals(')', results[4].lexeme);
  }
  @isTest
  static void reduceTokensForComplexParensReduction() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND (1 OR 2)');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>{ '0' });
    System.assertEquals(1, results.size());
    System.assertEquals('0', results[0].lexeme);
  }
  @isTest
  static void reduceTokensWhenTokensIsNull() {
    List<LexerV2.Token> results = FilterDataService.reduceTokens(null, new List<String>{ '0' });
    System.assertNotEquals(null, results);
    System.assert(results.isEmpty());
  }
  @isTest
  static void reduceTokensWhenvalidLexemesIsNull() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND (1 OR 2)');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, null);
    System.assertNotEquals(null, results);
    System.assert(results.isEmpty());
  }
  @isTest
  static void reduceTokensWhenTokensIsEmpty() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND (1 OR 2)');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(new List<LexerV2.Token>(), new List<String>{ '0' });
    System.assertNotEquals(null, results);
    System.assert(results.isEmpty());
  }
  @isTest
  static void reduceTokensWhenvalidLexemesIsEmpty() {
    List<LexerV2.Token> tokens = LexerV2.tokenize('0 AND (1 OR 2)');
    List<LexerV2.Token> results = FilterDataService.reduceTokens(tokens, new List<String>());
    System.assertNotEquals(null, results);
    System.assert(results.isEmpty());
  }

  // TEST: String getWhereCondition(String fieldName, String type, FormDataValue fdv)

  @isTest
  static void getWhereConditionForStringExactMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'STRING', fdv);
    System.assertEquals('Name = \'Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForStringPartialHeadMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'STRING', fdv);
    System.assertEquals('Name LIKE \'Sample%\'', cond);
  }
  @isTest
  static void getWhereConditionForStringPartialTailMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'STRING', fdv);
    System.assertEquals('Name LIKE \'%Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForStringPartialMiddleMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'STRING', fdv);
    System.assertEquals('Name LIKE \'%Sample%\'', cond);
  }

  @isTest
  static void getWhereConditionForEmailExactMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'EMAIL', fdv);
    System.assertEquals('Name = \'Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForEmailPartialHeadMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'EMAIL', fdv);
    System.assertEquals('Name LIKE \'Sample%\'', cond);
  }
  @isTest
  static void getWhereConditionForEmailPartialTailMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'EMAIL', fdv);
    System.assertEquals('Name LIKE \'%Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForEmailPartialMiddleMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'EMAIL', fdv);
    System.assertEquals('Name LIKE \'%Sample%\'', cond);
  }

  @isTest
  static void getWhereConditionForURLExactMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'URL', fdv);
    System.assertEquals('Name = \'Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForURLPartialHeadMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'URL', fdv);
    System.assertEquals('Name LIKE \'Sample%\'', cond);
  }
  @isTest
  static void getWhereConditionForURLPartialTailMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'URL', fdv);
    System.assertEquals('Name LIKE \'%Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForURLPartialMiddleMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'URL', fdv);
    System.assertEquals('Name LIKE \'%Sample%\'', cond);
  }

  @isTest
  static void getWhereConditionForPhoneExactMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'PHONE', fdv);
    System.assertEquals('Name = \'Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForPhonePartialHeadMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'PHONE', fdv);
    System.assertEquals('Name LIKE \'Sample%\'', cond);
  }
  @isTest
  static void getWhereConditionForPhonePartialTailMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'PHONE', fdv);
    System.assertEquals('Name LIKE \'%Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForPhonePartialMiddleMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'PHONE', fdv);
    System.assertEquals('Name LIKE \'%Sample%\'', cond);
  }

  @isTest
  static void getWhereConditionForTextareaExactMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'TEXTAREA', fdv);
    System.assertEquals('Name = \'Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForTextareaPartialHeadMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'TEXTAREA', fdv);
    System.assertEquals('Name LIKE \'Sample%\'', cond);
  }
  @isTest
  static void getWhereConditionForTextareaPartialTailMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample');
    String cond = FilterDataService.getWhereCondition('Name', 'TEXTAREA', fdv);
    System.assertEquals('Name LIKE \'%Sample\'', cond);
  }
  @isTest
  static void getWhereConditionForTextareaPartialMiddleMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('*Sample*');
    String cond = FilterDataService.getWhereCondition('Name', 'TEXTAREA', fdv);
    System.assertEquals('Name LIKE \'%Sample%\'', cond);
  }

  @isTest
  static void getWhereConditionForIdExactMiddleMatch() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('001ZZZZZZZZZZZZZZZ');
    String cond = FilterDataService.getWhereCondition('Id', 'ID', fdv);
    System.assertEquals('Id = \'001ZZZZZZZZZZZZZZZ\'', cond);
  }

  @isTest
  static void getWhereConditionForPicklistSingleSelection() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('choice');
    String cond = FilterDataService.getWhereCondition('PickList', 'PICKLIST', fdv);
    System.assertEquals('PickList IN (\'choice\')', cond);
  }
  @isTest
  static void getWhereConditionForPicklistMultipleSelection() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('choice1,choice2,choice3');
    String cond = FilterDataService.getWhereCondition('PickList', 'PICKLIST', fdv);
    System.assertEquals('PickList IN (\'choice1\',\'choice2\',\'choice3\')', cond);
  }

  @isTest
  static void getWhereConditionForMultipicklistSingleSelection() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('choice');
    String cond = FilterDataService.getWhereCondition('PickList', 'MULTIPICKLIST', fdv);
    System.assertEquals('PickList INCLUDES (\'choice\')', cond);
  }
  @isTest
  static void getWhereConditionForMultipicklistMultipleSelection() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('choice1,choice2,choice3');
    String cond = FilterDataService.getWhereCondition('PickList', 'MULTIPICKLIST', fdv);
    System.assertEquals('PickList INCLUDES (\'choice1\',\'choice2\',\'choice3\')', cond);
  }

  @isTest
  static void getWhereConditionForBooleanTrue() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('true');
    String cond = FilterDataService.getWhereCondition('Boolean', 'BOOLEAN', fdv);
    System.assertEquals('Boolean = true', cond);
  }
  @isTest
  static void getWhereConditionForBooleanFalse() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('false');
    String cond = FilterDataService.getWhereCondition('Boolean', 'BOOLEAN', fdv);
    System.assertEquals('Boolean = false', cond);
  }

  @isTest
  static void getWhereConditionForIntegerRange() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '100');
    String cond = FilterDataService.getWhereCondition('Integer', 'INTEGER', fdv);
    System.assertEquals('Integer >= 0 AND Integer <= 100', cond);
  }
  @isTest
  static void getWhereConditionForIntegerMin() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '');
    String cond = FilterDataService.getWhereCondition('Integer', 'INTEGER', fdv);
    System.assertEquals('Integer >= 0', cond);
  }
  @isTest
  static void getWhereConditionForIntegerMax() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '100');
    String cond = FilterDataService.getWhereCondition('Integer', 'INTEGER', fdv);
    System.assertEquals('Integer <= 100', cond);
  }

  @isTest
  static void getWhereConditionForPercentRange() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '100');
    String cond = FilterDataService.getWhereCondition('Percent', 'PERCENT', fdv);
    System.assertEquals('Percent >= 0.0 AND Percent <= 100.0', cond);
  }
  @isTest
  static void getWhereConditionForPercentMin() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '');
    String cond = FilterDataService.getWhereCondition('Percent', 'PERCENT', fdv);
    System.assertEquals('Percent >= 0.0', cond);
  }
  @isTest
  static void getWhereConditionForPercentMax() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '100');
    String cond = FilterDataService.getWhereCondition('Percent', 'PERCENT', fdv);
    System.assertEquals('Percent <= 100.0', cond);
  }

  @isTest
  static void getWhereConditionForCurrencyRange() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '100');
    String cond = FilterDataService.getWhereCondition('CURRENCY', 'CURRENCY', fdv);
    System.assertEquals('CURRENCY >= 0.0 AND CURRENCY <= 100.0', cond);
  }
  @isTest
  static void getWhereConditionForCurrencyMin() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '');
    String cond = FilterDataService.getWhereCondition('CURRENCY', 'CURRENCY', fdv);
    System.assertEquals('CURRENCY >= 0.0', cond);
  }
  @isTest
  static void getWhereConditionForCurrencyMax() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '100');
    String cond = FilterDataService.getWhereCondition('CURRENCY', 'CURRENCY', fdv);
    System.assertEquals('CURRENCY <= 100.0', cond);
  }

  @isTest
  static void getWhereConditionForDoubleRange() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '100');
    String cond = FilterDataService.getWhereCondition('DOUBLE', 'DOUBLE', fdv);
    System.assertEquals('DOUBLE >= 0.0 AND DOUBLE <= 100.0', cond);
  }
  @isTest
  static void getWhereConditionForDoubleMin() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('0', '');
    String cond = FilterDataService.getWhereCondition('DOUBLE', 'DOUBLE', fdv);
    System.assertEquals('DOUBLE >= 0.0', cond);
  }
  @isTest
  static void getWhereConditionForDoubleMax() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '100');
    String cond = FilterDataService.getWhereCondition('DOUBLE', 'DOUBLE', fdv);
    System.assertEquals('DOUBLE <= 100.0', cond);
  }

  @isTest
  static void getWhereConditionForDatetimeRange() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('2000-01-01T00:00:00.000Z', '2001-01-01T00:00:00.000Z');
    String cond = FilterDataService.getWhereCondition('DATETIME', 'DATETIME', fdv);
    System.assertEquals('DATETIME >= 2000-01-01T00:00:00.000Z AND DATETIME <= 2001-01-01T00:00:59.999Z', cond);
  }
  @isTest
  static void getWhereConditionForDatetimeMin() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('2000-01-01T00:00:00.000Z', '');
    String cond = FilterDataService.getWhereCondition('DATETIME', 'DATETIME', fdv);
    System.assertEquals('DATETIME >= 2000-01-01T00:00:00.000Z', cond);
  }
  @isTest
  static void getWhereConditionForDatetimeMax() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '2001-01-01T00:00:00.000Z');
    String cond = FilterDataService.getWhereCondition('DATETIME', 'DATETIME', fdv);
    System.assertEquals('DATETIME <= 2001-01-01T00:00:59.999Z', cond);
  }
  @isTest
  static void getWhereConditionForDatetimeMaxWithSeconds() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '2001-01-01T00:00:01.000Z');
    String cond = FilterDataService.getWhereCondition('DATETIME', 'DATETIME', fdv);
    System.assertEquals('DATETIME <= 2001-01-01T00:00:01.999Z', cond);
  }
  @isTest
  static void getWhereConditionForDatetimeMaxWithMilliseconds() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '2001-01-01T00:00:00.001Z');
    String cond = FilterDataService.getWhereCondition('DATETIME', 'DATETIME', fdv);
    System.assertEquals('DATETIME <= 2001-01-01T00:00:00.001Z', cond);
  }

  @isTest
  static void getWhereConditionForDateRange() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('2000-01-01', '2001-01-01');
    String cond = FilterDataService.getWhereCondition('DATE', 'DATE', fdv);
    System.assertEquals('DATE >= 2000-01-01 AND DATE <= 2001-01-01', cond);
  }
  @isTest
  static void getWhereConditionForDateMin() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('2000-01-01', '');
    String cond = FilterDataService.getWhereCondition('DATE', 'DATE', fdv);
    System.assertEquals('DATE >= 2000-01-01', cond);
  }
  @isTest
  static void getWhereConditionForDateMax() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '2001-01-01');
    String cond = FilterDataService.getWhereCondition('DATE', 'DATE', fdv);
    System.assertEquals('DATE <= 2001-01-01', cond);
  }

  @isTest
  static void getWhereConditionForTimeRange() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('00:00:00.000Z', '23:00:00.000Z');
    String cond = FilterDataService.getWhereCondition('TIME', 'TIME', fdv);
    System.assertEquals('TIME >= 00:00:00.000Z AND TIME <= 23:00:59.999Z', cond);
  }
  @isTest
  static void getWhereConditionForTimeMin() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('00:00:00.000Z', '');
    String cond = FilterDataService.getWhereCondition('TIME', 'TIME', fdv);
    System.assertEquals('TIME >= 00:00:00.000Z', cond);
  }
  @isTest
  static void getWhereConditionForTimeMax() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '23:00:00.000Z');
    String cond = FilterDataService.getWhereCondition('TIME', 'TIME', fdv);
    System.assertEquals('TIME <= 23:00:59.999Z', cond);
  }
  @isTest
  static void getWhereConditionForTimeMaxWithSeconds() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '23:00:01.000Z');
    String cond = FilterDataService.getWhereCondition('TIME', 'TIME', fdv);
    System.assertEquals('TIME <= 23:00:01.999Z', cond);
  }
  @isTest
  static void getWhereConditionForTimeMaxWithMilliseconds() {
    FilterDataService.FormDataValue fdv = new FilterDataService.FormDataValue('', '23:00:00.001Z');
    String cond = FilterDataService.getWhereCondition('TIME', 'TIME', fdv);
    System.assertEquals('TIME <= 23:00:00.001Z', cond);
  }
}
