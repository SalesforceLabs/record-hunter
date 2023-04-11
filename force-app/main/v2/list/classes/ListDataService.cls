public with sharing class ListDataService extends DataService {
  public class Column {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public Boolean editable;
    @AuraEnabled
    public Boolean isSortable;
    @AuraEnabled
    public Boolean isNameField;
    @AuraEnabled
    public Boolean isCalculated;
    @AuraEnabled
    public Integer scale;
  }

  public static final Map<String, String> DATA_TYPE = new Map<String, String>{ 'String' => 'text' };

  @AuraEnabled(cacheable=true)
  public static Result getColumnInfos(String objectApiName, String fieldApiNames) {
    List<Describer.FieldInfo> fieldInfos = new List<Describer.FieldInfo>();
    try {
      fieldInfos = Describer.describeFields(objectApiName, fieldApiNames);
    } catch (Exception e) {
      return new Result('', e.getMessage());
    }
    List<Column> columns = new List<Column>();
    for (Describer.FieldInfo fieldInfo : fieldInfos) {
      if (fieldInfo.hasError) {
        return new Result('', fieldInfo.errorMessage);
      }
      Schema.DescribeFieldResult dfr = fieldInfo.describeFieldResult;
      Column column = new Column();
      column.label = dfr.getLabel();
      column.name = fieldInfo.queriableFieldApiName;
      column.type = dfr.getType().name();
      column.isSortable = dfr.isSortable();
      column.isNameField = dfr.isNameField();
      column.isCalculated = dfr.isCalculated();
      column.scale = dfr.getScale();
      columns.add(column);
    }
    return new Result(columns);
  }

  @AuraEnabled(cacheable=false)
  public static Result queryRecordsByIds(String objectApiName, String fieldApiNames, String recordIds, String sortedBy, String sortedDirection, Integer pageSize, Integer pageIndex) {
    //  項目情報の取得
    List<Describer.FieldInfo> fieldInfos = new List<Describer.FieldInfo>();
    try {
      fieldInfos = Describer.describeFields(objectApiName, fieldApiNames);
    } catch (Exception e) {
      return new Result('', '');
    }

    String query = 'SELECT Id';
    for (Describer.FieldInfo fieldInfo : fieldInfos) {
      Schema.DescribeSObjectResult dsor = fieldInfo.describeSObjectResult;
      Schema.DescribeFieldResult dfr = fieldInfo.describeFieldResult;
      String fieldName = fieldInfo.queriableFieldApiName;
      if (fieldName != 'Id' && dsor.isAccessible() && dfr.isAccessible()) {
        if (dfr.getType().name() == 'PICKLIST' || dfr.getType().name() == 'MULTIPICKLIST') {
          query += ',TOLABEL(' + fieldName + ')';
        } else {
          query += ',' + fieldName;
        }
      }
    }
    query += ' FROM ' + objectApiName;
    query += ' WHERE Id IN (\'' + String.join(recordIds.split(','), '\',\'') + '\')';
    query += ' ORDER BY ' + sortedBy + ' ' + sortedDirection + ' NULLS LAST';
    query += ' LIMIT ' + pageSize + ' OFFSET ' + pageSize * pageIndex;

    try {
      List<Sobject> records = Database.query(query);
      return new Result(records);
    } catch (Exception e) {
      return new Result('', '');
    }
  }
}
