public virtual with sharing class DataService {
  public class Result {
    @AuraEnabled
    public Object body;
    @AuraEnabled
    public String debugInfo;
    @AuraEnabled
    public Boolean hasError = false;
    @AuraEnabled
    public String errorCode;
    @AuraEnabled
    public String errorMessage;
    public Result(Object body) {
      this.body = body;
    }
    public Result(String errorCode, String errorMessage) {
      this.hasError = true;
      this.ErrorCode = ErrorCode;
      this.errorMessage = errorMessage;
    }
  }
}
