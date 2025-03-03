
/*MetadataService.ObjectMetadata metadata = MetadataService.getObjectMetadata(
  'Opportunity'
);*/
/*
String objectApiName;
Schema.DescribeSObjectResult dsor = Schema.getGlobalDescribe().get(objectApiName)?.getDescribe();

System.debug(dsor == null);

*/



// Accountレコードを全件取得
List<Account> accounts = [SELECT Id, Name, BillingLatitude, BillingLongitude FROM Account];

// Accountレコードの Billing Latitude, Longitude をサンフランシスコ内のランダムな緯度経度に更新
for (Account account : accounts) {
  account.BillingLatitude = 37.7749 + Math.random() * 0.1;
  account.BillingLongitude = -122.4194 + Math.random() * 0.1;
}
update accounts;
