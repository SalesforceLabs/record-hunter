@IsTest
private class MetadataServiceTest {
  @testSetup
  static void setupData() {
    // Insert a test Account record for testing getObjectMetadataById
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Contact contact = new Contact(
      LastName = 'Test Contact',
      AccountId = acc.Id
    );
    insert contact;
  }

  @isTest
  static void testGetObjectMetadataByName_Success() {
    // Test with a standard object name that exists (e.g. Account)
    MetadataService.ObjectMetadata result = MetadataService.getObjectMetadataByName(
      'Account'
    );
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(
      'Account',
      result.name,
      'Object name should be Account'
    );
    System.assertNotEquals(null, result.label, 'Label should not be null');
  }

  @isTest
  static void testGetObjectMetadataByName_EmptyName() {
    // Test passing an empty object name
    try {
      MetadataService.getObjectMetadataByName('');
      System.assert(false, 'Method should have thrown an AuraHandledException');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('cannot be null or empty'),
        'Exception should mention that objectApiName cannot be null or empty'
      );
    }
  }

  @isTest
  static void testGetObjectMetadataByName_NonExistentObject() {
    // Test passing a non-existent object name
    try {
      MetadataService.getObjectMetadataByName('NonExistentObject__c');
      System.assert(
        false,
        'Method should have thrown an AuraHandledException for non-existent object'
      );
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('does not exist'),
        'Exception should mention that the object does not exist'
      );
    }
  }

  @isTest
  static void testGetObjectMetadataById_Success() {
    // Retrieve the record inserted in testSetup
    Account acc = [SELECT Id FROM Account LIMIT 1];
    MetadataService.ObjectMetadata result = MetadataService.getObjectMetadataById(
      acc.Id
    );
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(
      'Account',
      result.name,
      'Object name should be Account'
    );
  }

  @isTest
  static void testGetObjectMetadataById_InvalidId() {
    // Test with an invalid Id
    try {
      MetadataService.getObjectMetadataById('InvalidId');
      System.assert(
        false,
        'Method should have thrown an AuraHandledException for invalid Id'
      );
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('not a valid Salesforce record ID'),
        'Exception should mention invalid Salesforce record ID'
      );
    }
  }

  @isTest
  static void testGetFieldMetadata_BasicField() {
    // Test with a standard field on a standard object
    MetadataService.FieldMetadata fieldMetadata = MetadataService.getFieldMetadata(
      'Account',
      'Name'
    );
    System.assertNotEquals(
      null,
      fieldMetadata,
      'FieldMetadata should not be null'
    );
    System.assertEquals(
      'Name',
      fieldMetadata.name,
      'Field name should be Name'
    );
    System.assertEquals(
      'STRING',
      fieldMetadata.type,
      'Field type should be String'
    );
  }

  @isTest
  static void testGetFieldMetadata_ReferenceField() {
    // Test with a standard field on a standard object
    MetadataService.FieldMetadata fieldMetadata = MetadataService.getFieldMetadata(
      'Contact',
      'AccountId'
    );
    System.assertNotEquals(
      null,
      fieldMetadata,
      'FieldMetadata should not be null'
    );
    System.assertEquals(
      'AccountId',
      fieldMetadata.name,
      'Field name should be AccountId'
    );
    System.assertEquals(
      'REFERENCE',
      fieldMetadata.type,
      'Field type should be Address'
    );
  }

  @isTest
  static void testGetFieldMetadata_AddressField() {
    // Test with a standard field on a standard object
    MetadataService.FieldMetadata fieldMetadata = MetadataService.getFieldMetadata(
      'Account',
      'BillingAddress'
    );
    System.assertNotEquals(
      null,
      fieldMetadata,
      'FieldMetadata should not be null'
    );
    System.assertEquals(
      'BillingAddress',
      fieldMetadata.name,
      'Field name should be BillingAddress'
    );
    System.assertEquals(
      'ADDRESS',
      fieldMetadata.type,
      'Field type should be Address'
    );
  }

  @isTest
  static void testGetComponentFieldMetadataList_Success() {
    // Test with a compound field on Account, e.g. BillingAddress
    // BillingAddress is a compound field comprising of BillingStreet, BillingCity, etc.
    // This should return metadata for the underlying component fields if accessible.
    List<MetadataService.FieldMetadata> fieldList = MetadataService.getComponentFieldMetadataList(
      'Account',
      'BillingAddress'
    );
    System.assertNotEquals(
      null,
      fieldList,
      'FieldMetadata list should not be null'
    );
    // The list may be empty if the running user doesn't have access to address fields,
    // but the method call should still be successful.
  }
}
