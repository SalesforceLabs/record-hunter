@isTest
public class TestDescriber {
  @isTest
  static void InitFieldInfo() {
    String objectApiName = 'Account';
    String fieldApiName = 'Name';
    String queriableFieldApiName = 'Account.Name';
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe().get(objectApiName).getDescribe(SObjectDescribeOptions.DEFERRED);
    Schema.DescribeFieldResult dfr = dsor.fields.getMap().get(fieldApiName).getDescribe();
    Describer.FieldInfo fieldInfo = new Describer.FieldInfo(dsor, dfr, queriableFieldApiName);
    System.assertEquals(objectApiName, fieldInfo.describeSObjectResult.getName());
    System.assertEquals(fieldApiName, fieldInfo.describeFieldResult.getName());
    System.assertEquals(queriableFieldApiName, fieldInfo.queriableFieldApiName);
  }
  @isTest
  static void getReferenceToObjectApiNameForSimpleFieldWithoutPreference() {
    String objectApiName = 'Contact';
    String fieldApiName = 'AccountId';
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe().get(objectApiName).getDescribe(SObjectDescribeOptions.DEFERRED);
    Schema.DescribeFieldResult dfr = dsor.fields.getMap().get(fieldApiName).getDescribe();
    String referenceToObjectApiName = Describer.getReferenceToObjectApiName(dfr, '');
    System.assertEquals('Account', referenceToObjectApiName);
  }
  @isTest
  static void getReferenceToObjectApiNameForSimpleFieldWithPreference() {
    String objectApiName = 'Contact';
    String fieldApiName = 'AccountId';
    String preferedObjectApiName = 'Account';
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe().get(objectApiName).getDescribe(SObjectDescribeOptions.DEFERRED);
    Schema.DescribeFieldResult dfr = dsor.fields.getMap().get(fieldApiName).getDescribe();
    String referenceToObjectApiName = Describer.getReferenceToObjectApiName(dfr, preferedObjectApiName);
    System.assertEquals(preferedObjectApiName, referenceToObjectApiName);
  }
  @isTest
  static void getReferenceToObjectApiNameForPolymorphicFieldWithoutPreference() {
    String objectApiName = 'Event';
    String fieldApiName = 'WhatId';
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe().get(objectApiName).getDescribe(SObjectDescribeOptions.DEFERRED);
    Schema.DescribeFieldResult dfr = dsor.fields.getMap().get(fieldApiName).getDescribe();
    String referenceToObjectApiName = Describer.getReferenceToObjectApiName(dfr, '');
    System.assertEquals(true, String.isNotBlank(referenceToObjectApiName));
  }
  @isTest
  static void getReferenceToObjectApiNameForPolymorphicFieldWithPreference() {
    String objectApiName = 'Event';
    String fieldApiName = 'WhatId';
    String preferedObjectApiName = 'Opportunity';
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe().get(objectApiName).getDescribe(SObjectDescribeOptions.DEFERRED);
    Schema.DescribeFieldResult dfr = dsor.fields.getMap().get(fieldApiName).getDescribe();
    String referenceToObjectApiName = Describer.getReferenceToObjectApiName(dfr, preferedObjectApiName);
    System.assertEquals(preferedObjectApiName, referenceToObjectApiName);
  }

  @isTest
  static void describeFieldWithBlankObjectApiNameAndBlankFieldPath() {
    Describer.FieldInfo fieldInfo = Describer.describeField('', '', null);
    System.assertEquals(true, fieldInfo.hasError);
    System.assertEquals(true, String.isNotBlank(fieldInfo.errorMessage));
  }
  @isTest
  static void describeFieldWithBlankObjectApiName() {
    Describer.FieldInfo fieldInfo = Describer.describeField('', 'Id', null);
    System.assertEquals(true, fieldInfo.hasError);
    System.assertEquals(true, String.isNotBlank(fieldInfo.errorMessage));
  }
  @isTest
  static void describeFieldWithInvalidObjectApiName() {
    try {
      Describer.FieldInfo fieldInfo = Describer.describeField('INVALID', 'Id', null);
    } catch (AuraHandledException e) {
      System.assertEquals('System.AuraHandledException', e.getTypeName());
    }
  }
  @isTest
  static void describeFieldWithBlankFieldPath() {
    String objectApiName = '';
    Describer.FieldInfo fieldInfo = Describer.describeField('Account', '', null);
    System.assertEquals(true, fieldInfo.hasError);
    System.assertEquals(true, String.isNotBlank(fieldInfo.errorMessage));
  }
  @isTest
  static void describeFieldWithInvalidFieldPath() {
    String objectApiName = '';
    Describer.FieldInfo fieldInfo = Describer.describeField('Account', 'INVALID', null);
    System.assertEquals(true, fieldInfo.hasError);
    System.assertEquals(true, String.isNotBlank(fieldInfo.errorMessage));
  }
  @isTest
  static void describeFieldForInvalidReferenceFieldPath() {
    Describer.FieldInfo fieldInfo = Describer.describeField('Opportunity', 'ContactId.Name', null);
    System.assertEquals(true, fieldInfo.hasError);
    System.assertEquals(true, String.isNotBlank(fieldInfo.errorMessage));
  }

  @isTest
  static void describeFieldForSimpleField() {
    Describer.FieldInfo fieldInfo = Describer.describeField('Account', 'Name', null);
    System.assertEquals(false, fieldInfo.hasError);
    System.assertEquals('Account', fieldInfo.describeSObjectResult.getName());
    System.assertEquals('Name', fieldInfo.describeFieldResult.getName());
    System.assertEquals('Name', fieldInfo.queriableFieldApiName);
  }
  @isTest
  static void describeFieldForReferenceField() {
    Describer.FieldInfo fieldInfo = Describer.describeField('Contact', 'AccountId', null);
    System.assertEquals(false, fieldInfo.hasError);
    System.assertEquals('Contact', fieldInfo.describeSObjectResult.getName());
    System.assertEquals('AccountId', fieldInfo.describeFieldResult.getName());
    System.assertEquals('AccountId', fieldInfo.queriableFieldApiName);
  }

  @isTest
  static void describeFieldForChainedReferenceFieldSimple() {
    Describer.FieldInfo fieldInfo = Describer.describeField('Contact', 'AccountId.Name', null);
    System.assertEquals(false, fieldInfo.hasError);
    System.assertEquals('Account', fieldInfo.describeSObjectResult.getName());
    System.assertEquals('Name', fieldInfo.describeFieldResult.getName());
    System.assertEquals('Account.Name', fieldInfo.queriableFieldApiName);
  }
  @isTest
  static void describeFieldWithInvalidPreferedObjectApiName() {
    String objectApiName = '';
    Describer.FieldInfo fieldInfo = Describer.describeField('Contact', 'AccountId:INVALID', null);
    System.assertEquals(false, fieldInfo.hasError);
    System.assertEquals('Contact', fieldInfo.describeSObjectResult.getName());
    System.assertEquals('AccountId', fieldInfo.describeFieldResult.getName());
  }
  @isTest
  static void describeFieldForChainedReferenceFieldComplex() {
    Describer.FieldInfo fieldInfo = Describer.describeField('Event', 'WhatId:Account.OwnerId.Name', null);
    System.assertEquals(false, fieldInfo.hasError);
    System.assertEquals('User', fieldInfo.describeSObjectResult.getName());
    System.assertEquals('Name', fieldInfo.describeFieldResult.getName());
    System.assertEquals('What.Owner.Name', fieldInfo.queriableFieldApiName);
  }

  @isTest
  static void describeFieldForChainedReferenceFieldSubset() {
    Describer.FieldInfo fieldInfo = Describer.describeField('Account', 'Name', new List<String>{ 'Contact', 'Account' });
    System.assertEquals(false, fieldInfo.hasError);
    System.assertEquals('Account', fieldInfo.describeSObjectResult.getName());
    System.assertEquals('Name', fieldInfo.describeFieldResult.getName());
    System.assertEquals('Contact.Account.Name', fieldInfo.queriableFieldApiName);
  }

  @isTest
  static void describeFieldsWithSingleFieldApiName() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields('Account', 'Name');
    System.assertEquals(1, fieldInfos.size());
    System.assertEquals('Name', fieldInfos[0].describeFieldResult.getName());
  }
  @isTest
  static void describeFieldsWithMultipleFieldApiNames() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields('Account', 'Name,Phone,ParentId,Type,NumberOfEmployees,BillingAddress,Description,Website,Fax,CreatedById.Name');
    System.assertEquals(10, fieldInfos.size());
  }
  @isTest
  static void describeFieldsWithRedundantSpaces() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields('Account    ', '  Name ,   Phone,ParentId    ');
    System.assertEquals(3, fieldInfos.size());
    System.assertEquals('Name', fieldInfos[0].describeFieldResult.getName());
    System.assertEquals('Phone', fieldInfos[1].describeFieldResult.getName());
    System.assertEquals('ParentId', fieldInfos[2].describeFieldResult.getName());
  }
  @isTest
  static void describeFieldsWithInvalidFieldApiNames() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields('Account', 'INVALID ,INVALID,INVALID');
    System.assertEquals(3, fieldInfos.size());
    System.assertEquals(true, fieldInfos[0].hasError);
    System.assertEquals(true, fieldInfos[1].hasError);
    System.assertEquals(true, fieldInfos[2].hasError);
  }
  @isTest
  static void describeFieldsWithBlankObjectApiName() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields('', 'Id');
    System.assertEquals(1, fieldInfos.size());
    System.assertEquals(true, fieldInfos[0].hasError);
  }
  @isTest
  static void describeFieldsWithBlankFieldApiNames() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields('Account', '');
    System.assertEquals(0, fieldInfos.size());
  }
  @isTest
  static void describeFieldsWithNullObjectApiName() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields(null, 'Id');
    System.assertEquals(1, fieldInfos.size());
    System.assertEquals(true, fieldInfos[0].hasError);
  }
  @isTest
  static void describeFieldsWithNullFieldApiNames() {
    List<Describer.FieldInfo> fieldInfos = Describer.describeFields('Account', null);
    System.assertEquals(0, fieldInfos.size());
  }

  // TEST: Schema.DescribeFieldResult describeField(String objectApiName, String fieldApiName)

  @isTest
  static void describeField() {
    Schema.DescribeFieldResult dfr = Describer.describeField('Account', 'Name');
    System.assertEquals('Name', dfr.getName());
  }

  // TEST: Schema.DescribeSObjectResult describeSObject(String objectApiName)

  @isTest
  static void describeSObject() {
    Schema.DescribeSObjectResult dsor = Describer.describeSObject('Account');
    System.assertEquals('Account', dsor.getName());
  }
}
