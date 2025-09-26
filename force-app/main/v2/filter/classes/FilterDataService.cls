public with sharing class FilterDataService extends DataService {
  public class InputInfo {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public Decimal step;
    @AuraEnabled
    public String fieldApiName;
    @AuraEnabled
    public List<SelectOption> options;
    @AuraEnabled
    public ObjectInfo objectInfo;
    @AuraEnabled
    public Integer index;
    @AuraEnabled
    public Boolean isFilterable;
    @AuraEnabled
    public Boolean isRelative;
  }
  public class SelectOption {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    public SelectOption(String value, String label) {
      this.label = label;
      this.value = value;
    }
  }
  public class ObjectInfo {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String name;
    public ObjectInfo(String name, String label) {
      this.label = label;
      this.name = name;
    }
  }

  public class FormDataValue {
    public String value;
    public String minValue;
    public String maxValue;
    public FormDataValue(String value) {
      this.value = value;
    }
    public FormDataValue(String minValue, String maxValue) {
      this.minValue = minValue;
      this.maxValue = maxValue;
    }
  }

  @AuraEnabled(cacheable=true)
  public static Result getInputInfos(
    String objectApiName,
    String fieldApiNames
  ) {
    if (String.isBlank(objectApiName)) {
      return new Result('', '');
    }
    if (String.isBlank(fieldApiNames)) {
      return new Result(new List<InputInfo>());
    }

    List<Describer.FieldInfo> fieldInfos = new List<Describer.FieldInfo>();
    try {
      fieldInfos = Describer.describeFields(objectApiName, fieldApiNames);
    } catch (Exception e) {
      return new Result('', '');
    }
    return new Result(createInputInfos(fieldInfos));
  }

  @AuraEnabled(cacheable=false)
  public static Result filterRecordIds(
    String objectApiName,
    String fieldApiNames,
    String formDataJson,
    String recordIds,
    String customLogic
  ) {
    if (String.isBlank(objectApiName)) {
      return new Result('', '');
    }
    if (String.isBlank(fieldApiNames)) {
      return new Result('', '');
    }

    String conditions = getConditions(
      objectApiName,
      fieldApiNames,
      formDataJson,
      customLogic
    );

    String query = 'SELECT Id FROM ' + objectApiName;
    query +=
      ' WHERE Id IN (\'' +
      String.join(recordIds.split(','), '\',\'') +
      '\')';
    if (String.isNotBlank(conditions)) {
      query += ' AND ' + conditions;
    }
    List<Id> filteredRecordIds = performQuery(query);

    return new Result(filteredRecordIds);
  }

  @AuraEnabled(cacheable=false)
  public static Result queryRecordIds(
    String objectApiName,
    String fieldApiNames,
    String formDataJson,
    String customLogic
  ) {
    String conditions = getConditions(
      objectApiName,
      fieldApiNames,
      formDataJson,
      customLogic
    );
    String query = 'SELECT Id FROM ' + objectApiName;
    if (String.isNotBlank(conditions)) {
      query += ' WHERE ' + conditions;
    }
    List<Id> recordIds = performQuery(query);

    return new Result(recordIds);
  }

  @AuraEnabled(cacheable=true)
  public static Result getRecord(String recordId, String fieldNames) {
    try {
      Id recordIdFromString = recordId;
      String objectName = recordIdFromString.getSObjectType()
        .getDescribe()
        .getName();
      Schema.DescribeSObjectResult dsor = recordIdFromString.getSObjectType()
        .getDescribe(SObjectDescribeOptions.DEFERRED);

      List<String> fieldNameList = new List<String>();
      for (String fieldName : fieldNames.split(',')) {
        fieldNameList.add(fieldName.trim());
      }

      Set<String> fieldNameSet = new Set<String>{ 'Id' };
      for (String fieldName : fieldNameList) {
        if (
          String.isNotBlank(fieldName) &&
          dsor.fields.getMap().containsKey(fieldName) &&
          dsor.fields.getMap().get(fieldName).getDescribe().isAccessible()
        ) {
          fieldNameSet.add(fieldName);
        }
      }

      SObject record = null;
      if (!fieldNameSet.isEmpty()) {
        record = Database.query(
          'SELECT ' +
            String.join(new List<String>(fieldNameSet), ',') +
            ' FROM ' +
            objectName +
            ' WHERE Id = \'' +
            recordId +
            '\''
        );
      }

      return new Result(record);
    } catch (Exception e) {
      return new Result('', '');
    }
  }

  private static List<InputInfo> createInputInfos(
    List<Describer.FieldInfo> fieldInfos
  ) {
    List<InputInfo> inputInfos = new List<InputInfo>();
    for (Integer i = 0; i < fieldInfos.size(); i++) {
      inputInfos.add(createInputInfo(fieldInfos[i], i));
    }
    return inputInfos;
  }
  private static InputInfo createInputInfo(
    Describer.FieldInfo fieldInfo,
    Integer index
  ) {
    InputInfo inputInfo = new InputInfo();
    inputInfo.name = fieldInfo.queriableFieldApiName;
    inputInfo.fieldApiName = fieldInfo.fieldPath;
    inputInfo.index = index;
    inputInfo.isRelative = fieldInfo.isRelative;

    Schema.DescribeSObjectResult dsor = fieldInfo.describeSObjectResult;
    inputInfo.objectInfo = (new ObjectInfo(dsor.getName(), dsor.getLabel()));

    Schema.DescribeFieldResult dfr = fieldInfo.describeFieldResult;
    inputInfo.type = dfr.getType().name();
    inputInfo.label = dfr.getLabel();
    inputInfo.step = dfr.getScale() > 0
      ? 1.0 / Math.pow(10, dfr.getScale())
      : null;
    inputInfo.isFilterable = dfr.isFilterable();

    if (
      dfr.getType().name() == 'PICKLIST' ||
      dfr.getType().name() == 'MULTIPICKLIST' ||
      dfr.getType().name() == 'COMBOBOX'
    ) {
      List<Schema.PicklistEntry> picklistEntries = dfr.getPicklistValues();
      inputInfo.options = new List<SelectOption>();
      for (Schema.PicklistEntry e : picklistEntries) {
        inputInfo.options.add(new SelectOption(e.getValue(), e.getLabel()));
      }
    }
    return inputInfo;
  }

  private static List<String> performQuery(String query) {
    try {
      List<Sobject> records = Database.query(query);
      List<Id> recordIds = new List<Id>();
      for (SObject record : records) {
        recordIds.add(record.Id);
      }
      return recordIds;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String getConditions(
    String objectApiName,
    String fieldApiNames,
    String formDataJson,
    String customLogic
  ) {
    List<Describer.FieldInfo> fieldInfos = new List<Describer.FieldInfo>();
    try {
      fieldInfos = Describer.describeFields(objectApiName, fieldApiNames);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }

    Map<String, FormDataValue> formData = new Map<String, FormDataValue>();
    try {
      formData = (Map<String, FormDataValue>) JSON.deserialize(
        formDataJson,
        Map<String, FormDataValue>.class
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }

    // Get Valid Indexes
    List<String> validIndexes = new List<String>();
    for (Integer i = 0; i < fieldInfos.size(); i++) {
      if (formData.get(fieldInfos[i].fieldPath) != null) {
        validIndexes.add('' + (i + 1));
      }
    }

    List<LexerV2.Token> tokens = LexerV2.tokenize(customLogic);
    List<LexerV2.Token> reducedToken = reduceTokens(tokens, validIndexes);

    String conditions = ' ';
    for (LexerV2.Token token : reducedToken) {
      if (token.kind == LexerV2.Kind.NUM) {
        Describer.FieldInfo fieldInfo = fieldInfos[
          Integer.valueOf(token.lexeme) - 1
        ];
        Schema.DescribeFieldResult dfr = fieldInfo.describeFieldResult;
        String fieldName = fieldInfo.fieldPath;
        FormDataValue fdv = formData.get(fieldName);
        conditions +=
          ' ' +
          getWhereCondition(
            fieldInfo.queriableFieldApiName,
            dfr.getType().name(),
            fdv
          );
      } else {
        conditions += ' ' + token.lexeme;
      }
    }
    return conditions;
  }

  @TestVisible
  private static String getWhereCondition(
    String fieldName,
    String type,
    FormDataValue fdv
  ) {
    String whereCondition = '';
    String value = fdv.value;
    String minValue = fdv.minValue;
    String maxValue = fdv.maxValue;

    switch on type {
      when 'STRING', 'EMAIL', 'URL', 'PHONE', 'TEXTAREA' {
        if (value.contains('*')) {
          whereCondition =
            fieldName +
            ' LIKE \'' +
            (value.startsWith('*') ? '%' : '') +
            value.removeStart('*').removeEnd('*') +
            (value.endsWith('*') ? '%' : '') +
            '\'';
        } else {
          whereCondition = fieldName + ' = \'' + value + '\'';
        }
      }
      when 'PERCENT', 'CURRENCY', 'DOUBLE' {
        if (String.isNotBlank(minValue)) {
          whereCondition =
            fieldName +
            ' >= ' +
            (minValue.contains('.') ? minValue : minValue + '.0');
        }
        whereCondition += String.isNotBlank(minValue) &&
          String.isNotBlank(maxValue)
          ? ' AND '
          : '';
        if (String.isNotBlank(maxValue)) {
          whereCondition +=
            fieldName +
            ' <= ' +
            (maxValue.contains('.') ? maxValue : maxValue + '.0');
        }
      }
      when 'INTEGER' {
        whereCondition = String.isNotBlank(minValue)
          ? fieldName + ' >= ' + minValue
          : '';
        whereCondition += String.isNotBlank(minValue) &&
          String.isNotBlank(maxValue)
          ? ' AND '
          : '';
        whereCondition += String.isNotBlank(maxValue)
          ? fieldName + ' <= ' + maxValue
          : '';
      }
      when 'DATE' {
        if (String.isNotBlank(value)) {
          whereCondition = fieldName + ' = ' + value;
        } else {
          whereCondition = String.isNotBlank(minValue)
            ? fieldName + ' >= ' + minValue
            : '';
          whereCondition += String.isNotBlank(minValue) &&
            String.isNotBlank(maxValue)
            ? ' AND '
            : '';
          whereCondition += String.isNotBlank(maxValue)
            ? fieldName + ' <= ' + maxValue
            : '';
        }
      }
      when 'TIME' {
        whereCondition = String.isNotBlank(minValue)
          ? fieldName + ' >= ' + minValue
          : '';
        whereCondition += String.isNotBlank(minValue) &&
          String.isNotBlank(maxValue)
          ? ' AND '
          : '';
        if (String.isNotBlank(maxValue)) {
          Time toTime = (Time) JSON.deserialize(
            '"' + maxValue + '"',
            Time.class
          );
          String hh = ('' + toTime.hour()).leftPad(2, '0');
          String mm = ('' + toTime.minute()).leftPad(2, '0');
          String ss = ('' + toTime.second()).leftPad(2, '0');
          String SSS = ('' + toTime.millisecond()).leftPad(3, '0');
          if (toTime.millisecond() == 0 && toTime.second() == 0) {
            whereCondition += fieldName + ' <= ' + hh + ':' + mm + ':59.999Z';
          } else if (toTime.millisecond() == 0) {
            whereCondition +=
              fieldName +
              ' <= ' +
              hh +
              ':' +
              mm +
              ':' +
              ss +
              '.999Z';
          } else {
            whereCondition +=
              fieldName +
              ' <= ' +
              hh +
              ':' +
              mm +
              ':' +
              ss +
              '.' +
              SSS +
              'Z';
          }
        }
      }
      when 'DATETIME' {
        if (String.isNotBlank(value)) {
          whereCondition = fieldName + ' = ' + value;
        } else {
          whereCondition = String.isNotBlank(minValue)
            ? fieldName + ' >= ' + minValue
            : '';
          whereCondition += String.isNotBlank(minValue) &&
            String.isNotBlank(maxValue)
            ? ' AND '
            : '';
          if (String.isNotBlank(maxValue)) {
            Datetime dt = (Datetime) JSON.deserialize(
              '"' + maxValue + '"',
              Datetime.class
            );
            if (dt.millisecond() == 0 && dt.second() == 0) {
              whereCondition +=
                fieldName +
                ' <= ' +
                dt.formatGMT('yyyy-MM-dd\'T\'HH:mm') +
                ':59.999Z';
            } else if (dt.millisecond() == 0) {
              whereCondition +=
                fieldName +
                ' <= ' +
                dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') +
                '.999Z';
            } else {
              whereCondition +=
                fieldName +
                ' <= ' +
                dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS') +
                'Z';
            }
          }
        }
      }
      when 'ID' {
        whereCondition = String.isNotBlank(value)
          ? fieldName + ' = \'' + value + '\''
          : '';
      }
      when 'PICKLIST' {
        whereCondition = String.isNotBlank(value)
          ? fieldName +
            ' IN (\'' +
            String.join(value.split(','), '\',\'') +
            '\')'
          : '';
      }
      when 'MULTIPICKLIST' {
        whereCondition = String.isNotBlank(value)
          ? fieldName +
            ' INCLUDES (\'' +
            String.join(value.split(','), '\',\'') +
            '\')'
          : '';
      }
      when 'BOOLEAN' {
        whereCondition = String.isNotBlank(value)
          ? fieldName + ' = ' + (value.trim().toLowerCase() == 'true')
          : '';
      }
    }
    return whereCondition;
  }

  @TestVisible
  private static List<LexerV2.Token> reduceTokens(
    List<LexerV2.Token> tokens,
    List<String> validLexemes
  ) {
    List<LexerV2.Token> reducedTokens = new List<LexerV2.Token>();
    if (
      tokens != null &&
      !tokens.isEmpty() &&
      validLexemes != null &&
      !validLexemes.isEmpty()
    ) {
      LexerV2.Token prev = null;
      LexerV2.Token token;
      for (Integer i = 0; i < tokens.size(); i++) {
        token = tokens[i];
        prev = reducedTokens.size() > 0
          ? reducedTokens[reducedTokens.size() - 1]
          : null;
        if (
          token.kind == LexerV2.Kind.NUM && !validLexemes.contains(token.lexeme)
        ) {
          continue;
        } else if (token.kind == LexerV2.Kind.LOGICALAND) {
          if (prev == null) {
            continue;
          } else if (prev.kind == LexerV2.Kind.RPAREN) {
            reducedTokens.add(token);
          } else if (prev.kind == LexerV2.Kind.NUM) {
            reducedTokens.add(token);
          }
        } else if (token.kind == LexerV2.Kind.LOGICALOR) {
          if (prev == null) {
            continue;
          } else if (prev.kind == LexerV2.Kind.LOGICALAND) {
            reducedTokens.set(reducedTokens.size() - 1, token);
          } else if (prev.kind == LexerV2.Kind.RPAREN) {
            reducedTokens.add(token);
          } else if (prev.kind == LexerV2.Kind.NUM) {
            reducedTokens.add(token);
          }
        } else if (token.kind == LexerV2.Kind.RPAREN) {
          if (prev == null) {
            continue;
          } else if (prev.kind == LexerV2.Kind.LOGICALAND) {
            reducedTokens.set(reducedTokens.size() - 1, token);
          } else if (prev.kind == LexerV2.Kind.LOGICALOR) {
            reducedTokens.set(reducedTokens.size() - 1, token);
          } else if (prev.kind == LexerV2.Kind.RPAREN) {
            reducedTokens.add(token);
          } else if (prev.kind == LexerV2.Kind.LPAREN) {
            reducedTokens.remove(reducedTokens.size() - 1);
          } else if (prev.kind == LexerV2.Kind.NUM) {
            reducedTokens.add(token);
          }
        } else if (token.kind == LexerV2.Kind.LPAREN) {
          if (prev == null) {
            reducedTokens.add(token);
          } else if (prev.kind == LexerV2.Kind.LOGICALAND) {
            reducedTokens.add(token);
          } else if (prev.kind == LexerV2.Kind.LOGICALOR) {
            reducedTokens.add(token);
          } else if (prev.kind == LexerV2.Kind.LPAREN) {
            reducedTokens.add(token);
          }
        } else {
          reducedTokens.add(token);
        }
      }
      prev = reducedTokens.size() > 0
        ? reducedTokens[reducedTokens.size() - 1]
        : null;
      if (prev == null) {
      } else if (prev.kind == LexerV2.Kind.LOGICALAND) {
        reducedTokens.remove(reducedTokens.size() - 1);
      } else if (prev.kind == LexerV2.Kind.LOGICALOR) {
        reducedTokens.remove(reducedTokens.size() - 1);
      }
    }
    return reducedTokens;
  }
}
