public with sharing class RecordService {
  @AuraEnabled(cacheable=false)
  public static SObject getRecordById(String recordId, String[] fields) {
    Id parsedRecordId;
    try {
      parsedRecordId = (Id) recordId;
    } catch (Exception e) {
      throwAuraHandledException(
        'The recordId parameter is not a valid Salesforce record ID.'
      );
    }

    Schema.DescribeSObjectResult dsor = parsedRecordId.getSObjectType()
      .getDescribe(SObjectDescribeOptions.DEFERRED);
    String objectApiName = dsor.getName();

    if (!dsor.isAccessible()) {
      throwAuraHandledException(
        'The specified object is not accessible: ' + objectApiName
      );
    }

    // check if the fields are valid and isaccessible
    for (String field : fields) {
      if (!dsor.fields.getMap().containsKey(field)) {
        throwAuraHandledException(
          'The specified field does not exist: ' + field
        );
      }
      if (!dsor.fields.getMap().get(field).getDescribe().isAccessible()) {
        throwAuraHandledException(
          'The specified field is not accessible: ' + field
        );
      }
    }

    // escape single quotes using EscapeSingleQuote method in the fields array
    for (Integer i = 0; i < fields.size(); i++) {
      fields[i] = String.escapeSingleQuotes(fields[i]);
    }

    // Create a set from the fields array and add the Id field
    Set<String> fieldsSet = new Set<String>(fields);
    fieldsSet.add('Id');

    // create query string
    String queryString =
      'SELECT ' +
      String.join(new List<String>(fieldsSet), ', ') +
      ' FROM ' +
      objectApiName +
      ' WHERE Id = :parsedRecordId';

    // run the query and return the record. error if query string is invalid or record not found
    SObject[] records;
    try {
      records = Database.query(queryString);
    } catch (QueryException e) {
      throwAuraHandledException('The query string is invalid: ' + queryString);
    }
    if (records.size() == 0) {
      throwAuraHandledException(
        'The specified record does not exist: ' + recordId
      );
    }

    return records[0];
  }

  @AuraEnabled(cacheable=false)
  public static List<SObject> findRecordsByLocation(
    String objectApiName,
    String locationFieldApiName,
    String latitudeFieldApiName,
    String longitudeFieldApiName,
    String markerTitleFieldApiName,
    String markerContentFieldApiName,
    Decimal latitude,
    Decimal longitude,
    Decimal distance,
    String unit,
    String recordIds
  ) {
    String queryString = RecordService.getQueryStringForFindRecordsByLocation(
      objectApiName,
      locationFieldApiName,
      latitudeFieldApiName,
      longitudeFieldApiName,
      markerTitleFieldApiName,
      markerContentFieldApiName,
      latitude,
      longitude,
      distance,
      unit,
      recordIds
    );

    // run the query and return the records. error if query string is invalid
    List<SObject> records;
    try {
      records = Database.query(queryString);
    } catch (QueryException e) {
      throwAuraHandledException('The query string is invalid: ' + queryString);
    }

    return records;
  }

  @AuraEnabled(cacheable=false)
  public static String getQueryStringForFindRecordsByLocation(
    String objectApiName,
    String locationFieldApiName,
    String latitudeFieldApiName,
    String longitudeFieldApiName,
    String markerTitleFieldApiName,
    String markerContentFieldApiName,
    Decimal latitude,
    Decimal longitude,
    Decimal distance,
    String unit,
    String recordIds
  ) {
    // check if objectApiName is not a blank, is valid and accessible
    Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe()
      .get(objectApiName)
      ?.getDescribe(SObjectDescribeOptions.DEFERRED);
    if (dsor == null || !dsor.isAccessible()) {
      throwAuraHandledException(
        'The specified object is not accessible: ' + objectApiName
      );
    }

    // check if locationFieldApiName is valid and accessible and is an address or geolocation field
    Schema.DescribeFieldResult dfr = getDescribeField(
      objectApiName,
      locationFieldApiName
    );
    //Schema.DescribeFieldResult dfr = dsor.fields.getMap().get(locationFieldApiName)?.getDescribe();
    if (
      dfr == null ||
      !dfr.isAccessible() ||
      !(dfr.getType() == Schema.DisplayType.ADDRESS ||
      dfr.getType() == Schema.DisplayType.LOCATION)
    ) {
      throwAuraHandledException(
        'The location field does not exist or is not an address or geolocation field: ' +
        locationFieldApiName
      );
    }

    // check if latitudeFieldApiName is valid and accessible and is an Double field
    //dfr = dsor.fields.getMap().get(latitudeFieldApiName)?.getDescribe();
    dfr = getDescribeField(objectApiName, latitudeFieldApiName);
    if (
      dfr == null ||
      !dfr.isAccessible() ||
      dfr.getType() != Schema.DisplayType.DOUBLE
    ) {
      throwAuraHandledException(
        'The latitude field does not exist or is not a Decimal field: ' +
        latitudeFieldApiName
      );
    }

    // check if LongitudeFieldApiName is valid and accessible and is an Double field
    dfr = getDescribeField(objectApiName, longitudeFieldApiName);
    if (
      dfr == null ||
      !dfr.isAccessible() ||
      dfr.getType() != Schema.DisplayType.DOUBLE
    ) {
      throwAuraHandledException(
        'The longitude field does not exist or is not a Decimal field: ' +
        longitudeFieldApiName
      );
    }

    Boolean hasDistanceCondition = true;

    // check if latitude and longitude are not null and valid coordinates
    if (latitude == null || longitude == null) {
      hasDistanceCondition = false;
    }
    if (latitude < -90 || latitude > 90) {
      throwAuraHandledException('Latitude must be between -90 and 90 degrees.');
    }
    if (longitude < -180 || longitude > 180) {
      throwAuraHandledException(
        'Longitude must be between -180 and 180 degrees.'
      );
    }

    // check if distance is valid
    if (distance == null) {
      hasDistanceCondition = false;
    }
    if (distance < 0) {
      throwAuraHandledException('Distance must be greater than 0.');
    }

    // check if unit is valid
    if (unit == null) {
      hasDistanceCondition = false;
    }
    if (String.isNotBlank(unit) && !unit.equals('km') && !unit.equals('mi')) {
      throwAuraHandledException('Unit must be either "km" or "mi".');
    }

    Boolean hasRecordIdsCondition = true;
    if (String.isBlank(recordIds)) {
      hasRecordIdsCondition = false;
    }

    Set<String> selectQueryFieldSet = new Set<String>{
      'Id',
      toQueryForm(locationFieldApiName),
      toQueryForm(markerTitleFieldApiName),
      toQueryForm(markerContentFieldApiName),
      toQueryForm(latitudeFieldApiName),
      toQueryForm(longitudeFieldApiName)
    };

    // create query string
    String selectQueryString =
      'SELECT ' +
      String.join(new List<String>(selectQueryFieldSet), ', ') +
      ' FROM ' +
      objectApiName;

    String distanceConditionQueryString =
      'DISTANCE(' +
      toQueryForm(locationFieldApiName) +
      ', GEOLOCATION(' +
      latitude +
      ',' +
      longitude +
      '), \'' +
      unit +
      '\') < ' +
      distance;

    String recordIdsConditionQueryString = '';
    if (String.isNotBlank(recordIds)) {
      recordIds = String.escapeSingleQuotes(recordIds);
      recordIdsConditionQueryString =
        'Id IN (\'' +
        String.join(recordIds.split(','), '\',\'') +
        '\')';
    }

    if (hasDistanceCondition && hasRecordIdsCondition) {
      return selectQueryString +
        ' WHERE ' +
        distanceConditionQueryString +
        ' AND ' +
        recordIdsConditionQueryString;
    } else if (hasRecordIdsCondition) {
      return selectQueryString + ' WHERE ' + recordIdsConditionQueryString;
    } else if (hasDistanceCondition) {
      return selectQueryString + ' WHERE ' + distanceConditionQueryString;
    } else {
      return selectQueryString;
    }
  }

  /**
   * 指定されたオブジェクトとフィールドパスからDescribeFieldResultを取得します。
   * フィールドパスは最大5階層までの参照関係を含むことができます。
   *
   * @param objectApiName   開始オブジェクトのAPI名（例：'Contact'）
   * @param fieldPath       ドット記法で表現されたフィールドパス（例：'Account.Owner.Profile.Name'）
   * @return 最終フィールドのDescribeFieldResult、または無効な場合はnull
   */
  public static Schema.DescribeFieldResult getDescribeField(
    String objectApiName,
    String fieldPath
  ) {
    if (String.isBlank(objectApiName) || String.isBlank(fieldPath)) {
      return null;
    }

    // フィールドパスをドットで分割
    List<String> fields = fieldPath.split('\\.');
    if (fields.isEmpty()) {
      return null;
    }

    // グローバルなスキーマ記述を取得
    Schema.DescribeSObjectResult currentDescribe = Schema.getGlobalDescribe()
      .get(objectApiName)
      ?.getDescribe(SObjectDescribeOptions.DEFERRED);
    if (currentDescribe == null) {
      return null;
    }

    Schema.DescribeFieldResult fieldDescribe = null;

    // フィールドパスを順に辿る
    for (Integer i = 0; i < fields.size(); i++) {
      String fieldName = fields[i];
      fieldDescribe = currentDescribe.fields.getMap()
        .get(fieldName)
        ?.getDescribe();
      if (fieldDescribe == null) {
        // フィールドが存在しない場合はnullを返す
        return null;
      }

      if (i < fields.size() - 1) {
        // 次のフィールドに進むために参照関係を確認
        if (fieldDescribe.getType() != Schema.DisplayType.Reference) {
          // 参照フィールドでない場合はnullを返す
          return null;
        }
        // 参照先のオブジェクトを取得（ポリモーフィック参照の場合は最初の参照先を使用）
        List<Schema.SObjectType> referenceTo = fieldDescribe.getReferenceTo();
        if (referenceTo.isEmpty()) {
          return null;
        }
        currentDescribe = referenceTo[0].getDescribe();
      }
    }

    return fieldDescribe;
  }

  public static String toQueryForm(String qualifiedFieldName) {
    // 入力が空またはnullの場合はそのまま返す
    if (String.isBlank(qualifiedFieldName)) {
      return qualifiedFieldName;
    }

    // フィールドパスをドットで分割
    List<String> fields = qualifiedFieldName.split('\\.');

    // 各フィールドを変換
    for (Integer i = 0; i < fields.size(); i++) {
      fields[i] = toRelationshipName(fields[i], i < fields.size() - 1);
    }

    // 変換後のフィールドパスを再構築
    return String.join(fields, '.');
  }

  private static String toRelationshipName(
    String fieldName,
    Boolean isRelationshipField
  ) {
    if (isRelationshipField) {
      // 標準リレーションシップフィールドの場合 ("Id" で終わる)
      if (fieldName.endsWith('Id')) {
        return fieldName.removeEnd('Id');
      }
      // カスタムリレーションシップフィールドの場合 ("__c" で終わる)
      else if (fieldName.endsWith('__c')) {
        return fieldName.removeEnd('__c') + '__r';
      }
    }
    // リレーションシップフィールド以外はそのまま返す
    return fieldName;
  }

  private static void throwAuraHandledException(String message) {
    AuraHandledException e = new AuraHandledException(message);
    e.setMessage(message);
    throw e;
  }
}
