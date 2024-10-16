public with sharing class demo2  {
    
 
    public demo2 (){
    }
    
    /***********************************************************************************************
    * @Description: Invocable method, that can be called via flow. (Main Method)
    * @Param1:      List<FlowLogEntry> - the flow paramters as a wrapper.
    * @Return:      List<FlowLogResult> - wrapper list of log results with record id.
    ***********************************************************************************************/
    @InvocableMethod(category='Logging' 
                     label='Add Log Entry' 
                     description='Creates a log entry for a flow or process builder')
    public static List<FlowLogResult> addFlowEntries(List<FlowLogEntry> flowLogEntries) {
    
        List<String> logRecordIds = createLogRecords(flowLogEntries);
     
        return createResults(logRecordIds);
    }
    
    public static List<String> createLogRecords(List<FlowLogEntry> flowLogEntries) {
        List<String> logRefIdList = new List<String>();
        List<ExceptionLogger__c> logList = new List<ExceptionLogger__c>();
        for (FlowLogEntry flowLogEntry : flowLogEntries) {
            logList.add(HandleCustomException.logException(flowLogEntry));
        }
        if(Schema.sObjectType.ExceptionLogger__c.isCreateable()){
            Database.SaveResult[] srList = Database.insert(logList, false);
           
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                 
                    logRefIdList.add(sr.getId());
                }
            }
        }
        return logRefIdList;
    }
    
    public static List<FlowLogResult> createResults(List<String> logRefIdList){
        List<FlowLogResult> logResults = new List<FlowLogResult>();
        FlowLogResult logResult;
        for(String logRefId : logRefIdList){
            logResult = new FlowLogResult();
            logResult.logRecordRef = logRefId;
        }
        logResults.add(logResult);
        return logResults;
    }
    
  
    public class FlowLogEntry{
     
        @InvocableVariable(required=true label='Flow API Name')
        public String flowName;
       
        @InvocableVariable(required=true label='Flow Fault Error Message')
        public String faultMessage;
        
        @InvocableVariable(required=true label='Scenario')
        public String scenario;
    
        @InvocableVariable(required=false label='(Optional) Record ID')
        public Id recordId;
    
       
        public DateTime timestamp = System.now();
    }
    
    
    public class FlowLogResult{
      
        @InvocableVariable(required=false label='Log Record Reference')
        public String logRecordRef;
    }
}