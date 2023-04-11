public with sharing class SearchDataService extends DataService {
  @AuraEnabled(cacheable=true)
  public static Result searchRecordIds(String objectApiName, String keyword) {
    try {
      Schema.DescribeSObjectResult dsor = Describer.describeSObject(objectApiName);
      if (!dsor.isAccessible()) {
        return new Result('', 'You have no permission to access the sobject');
      }
      if (String.isBlank(keyword)) {
        return new Result('', 'keyword must not be blank');
      }

      // Find records by keyword
      String sosl = 'FIND \'' + String.escapeSingleQuotes(keyword) + '\' IN ALL FIELDS RETURNING ' + dsor.getName() + ' (Id ORDER BY Id)';
      List<Id> recordIds = new List<Id>(new Map<Id, SObject>(search.query(sosl)[0]).keySet());

      return new Result(recordIds);
    } catch (Exception e) {
      return new Result('', e.getMessage());
    }
  }
  @AuraEnabled(cacheable=true)
  public static Result filterRecordIds(String objectApiName, String keyword, String recordIds) {
    try {
      Schema.DescribeSObjectResult dsor = Describer.describeSObject(objectApiName);
      if (!dsor.isAccessible()) {
        return new Result('', 'You have no permission to access the sobject');
      }
      if (String.isBlank(keyword)) {
        return new Result('', 'keyword must not be blank');
      }

      // Find records by keyword
      String sosl =
        'FIND \'' +
        String.escapeSingleQuotes(keyword) +
        '\' IN ALL FIELDS RETURNING ' +
        dsor.getName() +
        ' (Id WHERE Id IN (\'' +
        String.join(recordIds.split(','), '\',\'') +
        '\') ORDER BY Id)';

      return new Result(new List<Id>(new Map<Id, SObject>(search.query(sosl)[0]).keySet()));
    } catch (Exception e) {
      return new Result('', e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Result getFieldValueForRecord(String recordId, String objectApiName, String fieldApiName) {
    try {
      if (String.isBlank(recordId)) {
        return new Result('', 'Invalid record ID');
      }
      Schema.DescribeSObjectResult dsor = Describer.describeSObject(objectApiName);
      Schema.DescribeFieldResult dfr = Describer.describeField(objectApiName, fieldApiName);

      if (!dfr.isAccessible()) {
        return new Result(null);
      }
      String query = 'SELECT ' + dfr.getName() + ' FROM ' + dsor.getName() + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
      SObject record = Database.query(query);
      return new Result(record.get(dfr.getName()));
    } catch (Exception e) {
      return new Result('', e.getMessage());
    }
  }
}
