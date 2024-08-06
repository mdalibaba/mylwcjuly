public class TimeOffCalendarLTController {
    
    public TimeOffCalendarLTController(){
    }
    @RemoteAction @AuraEnabled
    public static List<HRMSUS__Absence_Requests__c> loadEvents(string wsDate, string weDate){
        Date startDate = Date.valueOf(wsDate);
        Date endDate   = Date.valueOf(weDate); 
        List<HRMSUS__Absence_Requests__c> timeOffRequestList = [select id,name,HRMSUS__Worker__c,HRMSUS__Worker__r.Name,HRMSUS__Worker__r.HRMSUS__User__c,HRMSUS__Absence_Type__c,HRMSUS__Absence_Type__r.Name,HRMSUS__Start_Date__c,HRMSUS__End_Date__c,HRMSUS__Approved__c,HRMSUS__Notes__c,HRMSUS__Rejection_Comments__c,HRMSUS__Total_Hours__c,HRMSUS__Total_Absence_Requested__c
                                                                from HRMSUS__Absence_Requests__c WITH SECURITY_ENFORCED];
        return timeOffRequestList;
        
    } 
    @RemoteAction @AuraEnabled
    public static List<HRMSUS__Time_Off_Dates__c> loadTimeOffDates(string wsDate, string weDate){
        Date startDate = Date.valueOf(wsDate);
        Date endDate   = Date.valueOf(weDate); 
        
        List<HRMSUS__Time_Off_Dates__c> timeOffRequestDatesList = [select Id,Name,HRMSUS__Date__c,HRMSUS__Time_Off_Hours__c,HRMSUS__Time_Off_Request__c,HRMSUS__Time_Off_Request__r.Name,HRMSUS__Time_Off_Entitlement__c,HRMSUS__Time_Off_Request__r.HRMSUS__Worker__c,HRMSUS__Time_Off_Request__r.HRMSUS__Start_Date__c,HRMSUS__Time_Off_Request__r.HRMSUS__End_Date__c,
                                                                   HRMSUS__Time_Off_Request__r.HRMSUS__Approved__c,HRMSUS__Time_Off_Request__r.HRMSUS__Notes__c,HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.Name, HRMSUS__Time_Off_Request__r.HRMSUS__Worker__r.HRMSUS__User__c,HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__c,HRMSUS__Time_Off_Request__r.HRMSUS__Absence_Type__r.Name,
                                                                   HRMSUS__Time_Off_Request__r.HRMSUS__Rejection_Comments__c,HRMSUS__Time_Off_Request__r.HRMSUS__Total_Hours__c,HRMSUS__Time_Off_Request__r.HRMSUS__Total_Absence_Requested__c
                                                                   from HRMSUS__Time_Off_Dates__c where HRMSUS__Time_Off_Request__c !=null Order by Createddate DESC Limit 1000];
        
        List<HRMSUS__Absence_Requests__c> timeOffRequestList = [select id,name,HRMSUS__Worker__c,HRMSUS__Worker__r.Name,HRMSUS__Worker__r.HRMSUS__User__c,HRMSUS__Absence_Type__c,HRMSUS__Absence_Type__r.Name,HRMSUS__Start_Date__c,HRMSUS__End_Date__c,HRMSUS__Approved__c,HRMSUS__Notes__c,HRMSUS__Rejection_Comments__c,HRMSUS__Total_Hours__c,HRMSUS__Total_Absence_Requested__c
                                                                from HRMSUS__Absence_Requests__c WITH SECURITY_ENFORCED];
        return timeOffRequestDatesList;
        
    } 
    @RemoteAction @AuraEnabled
    public static string updateEvent(string eventId, String message)
    {
        system.debug('updateEvent method=='+eventId+'\n message=='+message);
        HRMSUS__Absence_Requests__c timeOffRequest = [select id,name,HRMSUS__Start_Date__c,HRMSUS__End_Date__c,HRMSUS__Worker__c,HRMSUS__Absence_Type__c,HRMSUS__Approved__c,HRMSUS__Leave_Hours__c,HRMSUS__Total_Absence_Requested__c from HRMSUS__Absence_Requests__c where id=:eventId];
        if(timeOffRequest.HRMSUS__Approved__c =='Approved')
        {
            return 'Already Approved';
        }
        else
        {
            timeOffRequest.HRMSUS__Approved__c = message;
            system.debug('--TOR--'+timeOffRequest);
            update timeOffRequest;
            
            list<HRMSUS__Absence_Entitlement__c> absentitle=new list<HRMSUS__Absence_Entitlement__c>();
            absentitle=[SELECT Id, Name, HRMSUS__Absence_Taken__c ,HRMSUS__Time_off_Balance_Hours__c,
                        HRMSUS__Time_off_Allowed_Hours__c,New_Total_Taken_Hours__c,New_Time_off_Balance_Hours__c,
                        HRMSUS__Time_off_Taken_Hours__c FROM HRMSUS__Absence_Entitlement__c WHERE
                        (HRMSUS__Absence_Type__c=:timeOffRequest.HRMSUS__Absence_Type__c) AND HRMSUS__Worker__c = :timeOffRequest.HRMSUS__worker__c 
                        AND (HRMSUS__Absences_Start_Date__c <=: timeOffRequest.HRMSUS__Start_Date__c AND HRMSUS__End_Date__c >=: timeOffRequest.HRMSUS__End_Date__c)
                        LIMIT 1];
            for( HRMSUS__Absence_Entitlement__c TimeEnt : absentitle)
            {   
                System.debug('timeOffRequest.HRMSUS__Leave_Hours__c : '+ timeOffRequest.HRMSUS__Leave_Hours__c);
                decimal totHrs =  timeOffRequest.HRMSUS__Leave_Hours__c != null ? timeOffRequest.HRMSUS__Leave_Hours__c : 0 ;   
                System.debug('.total Hours :'+ totHrs);
                TimeEnt.HRMSUS__Time_off_Taken_Hours__c = ( 
                    TimeEnt.HRMSUS__Time_off_Taken_Hours__c != NULL ) ? 
                    TimeEnt.HRMSUS__Time_off_Taken_Hours__c+totHrs : totHrs ;                                    
                System.debug('TimeEnt.HRMSUS__Time_off_Taken_Hours__c : '+ TimeEnt.HRMSUS__Time_off_Taken_Hours__c); 
            }
            try{
                update absentitle;
            }catch(exception e){
                system.debug('exception occured '+e.getMessage()+' :Line Number : '+e.getLineNumber());
                return 'Exception occured : '+e.getMessage()+': at Line Number : '+e.getLineNumber();
            }
            return 'Approved';
        }
    }
    @RemoteAction @AuraEnabled
    public static String reject(string eventId, String message , String rejectComments)
    {
        system.debug('updateEvent method=='+eventId+'\n message=='+message+'\n rejectComments== '+rejectComments);
        HRMSUS__Absence_Requests__c timeOffRequest = [select id,name,HRMSUS__Start_Date__c,HRMSUS__End_Date__c,HRMSUS__Worker__c,HRMSUS__Absence_Type__c,HRMSUS__Approved__c,HRMSUS__Rejection_Comments__c from HRMSUS__Absence_Requests__c where id=:eventId];
        if(timeOffRequest.HRMSUS__Approved__c=='Approved')
        {
            return 'Approved';
        }
        else
        {
            timeOffRequest.HRMSUS__Approved__c = message;
            timeOffRequest.HRMSUS__Rejection_Comments__c = rejectComments;
            update timeOffRequest;
            return 'Rejected';
        }
    }
     
}