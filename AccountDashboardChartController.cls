public class AccountDashboardChartController {
    
    @AuraEnabled
    public static String getTouchpointbyMonth(String crop, String season){
        crop = 'Soybean';
        season = 'SUMMER';
        System.debug('Inside by month radl');
        Integer accountcount = 0;
        List<Account> touchpointmonthList = new List<Account>();
        String Status = 'Completed';
        
        Schema.DescribeFieldResult fieldResult;
        List<Schema.PicklistEntry> radlClass;        
        
        //Map<String,Integer> radlcountMap = new Map<String,Integer>();
        //Map<String,radlcountMap> radlTouchMap = new Map<String,radlcountMap>();
        Set<String> radlClassSet = new Set<String>();
        
        fieldResult = Account_Business_Role__c.Service_Level_Class_Descr__c.getDescribe();
        radlClass = fieldResult.getPicklistValues();
        //List<Account> accountRecordsList = new List<Account>();
        List<TouchPoint__c> touchpointList= new List<TouchPoint__c>();
        List<Account_Business_Role__c> accbusinessList = new List<Account_Business_Role__c>();
        Map<Id,String> touchmonthAccMap = new Map<Id,String>();
        RADLtouchWrapper radltouchwrp = new RADLtouchWrapper();
        //RADLWrapper radlwrp = new RADLWrapper();
        RADLWrapper radlwrp ;
        if(!radlClass.isEmpty()){
            for(integer i=0;i<radlClass.Size();i++){
                radlClassSet.add(radlClass[i].getvalue());                        
            }
        }
        Map<Id,Integer> accountMap = new Map<Id,Integer>();
        for(Account acc : [Select Id,(SELECT Id, Account_SFID__c, Account_SFID__r.Id, Completion_Date__c,Check__c FROM TouchPoints__r WHERE TouchPoint_Status__c = 'Completed') FROM Account WHERE Id IN (SELECT Account_SFID__c FROM Account_Farming_Area__c WHERE Selling_Season_Descr__c = :season AND Area_Usage_Descr__c = :crop)]){
            if(acc.TouchPoints__r.size() > 0){
                accountMap.put(acc.Id,acc.TouchPoints__r.size());
                System.debug('accountMap' + accountMap);
            }
        }
        
        touchpointList = [SELECT Id, Account_SFID__c, Account_SFID__r.Id, Completion_Date__c,Check__c FROM TouchPoint__c WHERE TouchPoint_Status__c = 'Completed'];
        //touchpointList = Database.query(query);
        system.debug('touchpointList' +touchpointList.size() + ' '+touchpointList);
        if(!touchpointList.isEmpty()){
            for(TouchPoint__c tPoint : touchpointList){
                //touchmonthAccMap.put(tPoint.Account__r.Id,((tPoint.Completion_Date__c).format('MMMMM'))); 
                if(tPoint.Completion_Date__c != null){
                    touchmonthAccMap.put(tPoint.Account_SFID__c,((tPoint.Completion_Date__c).format('MMMMM')));
                    System.debug('touchmonthAccMap' + touchmonthAccMap);
                }
            } 
        }
        system.debug('touchmonthAccMap' +touchmonthAccMap );
        Set<Id> accountIdSet = new Set<Id>();
        accbusinessList = [SELECT Id, Account_SFID__c, Service_Level_Class_Descr__c FROM Account_Business_Role__c WHERE Account_SFID__c = :touchmonthAccMap.keySet()];
        //accbusinessList = Database.query(radlQuery);
        for(Account_Business_Role__c accbusiness : accbusinessList){
            //radltouchwrp = new  RADLtouchWrapper();
            radlwrp = new  RADLWrapper();
            if(radlClassSet.contains(accbusiness.Service_Level_Class_Descr__c)){
                System.debug('accbusiness.Account_SFID__c' + accbusiness.Account_SFID__c);
                if(!accountMap.isEmpty() && accountMap.containskey(accbusiness.Account_SFID__c)){
                    System.debug('Not empty');
                    radlwrp.radlcount.put(accbusiness.Service_Level_Class_Descr__c ,accountMap.get(accbusiness.Account_SFID__c));
                    System.debug('radlwrp.radlcount' + radlwrp.radlcount);
                    radltouchwrp.radltouchcount.put(touchmonthAccMap.get(accbusiness.Account_SFID__c),radlwrp);
            System.debug('radltouchwrp.radltouchcount' + radltouchwrp.radltouchcount);
                }
            } 
            
            
        }  
        System.debug('radltouchwrp.radltouchcount' + radltouchwrp.radltouchcount);
        
        if(radltouchwrp!=null){
            return JSON.serialize(radltouchwrp);  
        }
        else{
            return null; 
        }
        
    }
    
    @AuraEnabled
    public static String getTouchpointTypebyRADL(String crop, String season){
        //Query Accounts and Touchpoints filter by Season and Crop
        Map<Id,Integer> acctouchCountMap = new Map<Id,Integer>();
        Map<Id,Integer> visitCountMap = new Map<Id,Integer>();
        Map<Id,Integer> webCountMap = new Map<Id,Integer>();
        Map<Id,Integer> emailCountMap = new Map<Id,Integer>();
        Map<String,Integer> totalTouchMap = new Map<String,Integer>();
        Map<String,Integer> visitTouchMap = new Map<String,Integer>();
        Map<String,Integer> webTouchMap = new Map<String,Integer>();
        Map<String,Integer> emailTouchMap = new Map<String,Integer>();
        Map<String,Integer> chatTouchMap = new Map<String,Integer>();
        Map<String,Integer> chatCountMap = new Map<String,Integer>();
        Map<String,Integer> callCountMap = new Map<String,Integer>();
        Map<String,Integer> callTouchMap = new Map<String,Integer>();
        List<Account_Farming_Area__c> accFarmingList= new List<Account_Farming_Area__c>();
        Set<Id> accCropSeasonId = new Set<Id>();
        Set<String> radlClassSet = new Set<String>();
        List<AggregateResult> groupedResults =  new List<AggregateResult>();
        RADLtouchWrapper radltouchtypeWrp = new RADLtouchWrapper();
        //Get all RADL picklist value
        Schema.DescribeFieldResult fieldResult = Account_Business_Role__c.Service_Level_Class_Descr__c.getDescribe();
        List<Schema.PicklistEntry> radlClass = fieldResult.getPicklistValues();  
        //Get all Touchpoint Types picklist value
        Schema.DescribeFieldResult fieldTypeResult = TouchPoint__c.TouchPointTypes__c.getDescribe();
        List<Schema.PicklistEntry> typeList = fieldTypeResult.getPicklistValues();
        Set<String> touchTypeSet = new Set<String>();
        
        String Status ='Completed';
        String Type1 = '1:1 Visit';
        String Type2 = 'Web';
        String Type3 = 'E-mail';
        String Type4 = 'Call';
        String Type5 = 'Event';
        
        if(!radlClass.isEmpty()){
            for(integer i=0;i<radlClass.Size();i++){
                radlClassSet.add(radlClass[i].getvalue());                        
            }
        }
        
        if(!typeList.isEmpty()){
            radltouchtypeWrp.typeSet.add('Total');
            for(Integer i=0;i<typeList.Size();i++){
                // touchTypeSet.add(typeList[i].getValue());
                radltouchtypeWrp.typeSet.add(typeList[i].getValue());
            } 
        }
        //Get accounts having selected season and crop
        accFarmingList = [SELECT Account_SFID__c,Area_Usage_Descr__c,Selling_Season_Descr__c FROM Account_Farming_Area__c WHERE Area_Usage_Descr__c = :crop AND Selling_Season_Descr__c = :season ];
        if(!accFarmingList.isEmpty()){
            for(Account_Farming_Area__c accFarming : accFarmingList){
                accCropSeasonId.add(accFarming.Account_SFID__c);
            }
        }
        
        
        /*  System.debug('Inside by type radl');
Map<Id,Integer> acctouchCountMap = new Map<Id,Integer>();
Map<Id,Integer> visitCountMap = new Map<Id,Integer>();
Map<Id,Integer> webCountMap = new Map<Id,Integer>();
Map<Id,Integer> emailCountMap = new Map<Id,Integer>();
Map<String,Integer> totalTouchMap = new Map<String,Integer>();
Map<String,Integer> visitTouchMap = new Map<String,Integer>();
Map<String,Integer> webTouchMap = new Map<String,Integer>();
Map<String,Integer> emailTouchMap = new Map<String,Integer>();
Map<String,Integer> chatTouchMap = new Map<String,Integer>();
Map<String,Integer> chatCountMap = new Map<String,Integer>();
Map<String,Integer> callCountMap = new Map<String,Integer>();
Map<String,Integer> callTouchMap = new Map<String,Integer>();


RADLtouchWrapper radltouchtypeWrp = new RADLtouchWrapper();
Schema.DescribeFieldResult fieldResult;
List<Schema.PicklistEntry> radlClass;
Set<String> radlClassSet = new Set<String>();

fieldResult = Account_Business_Role__c.Service_Level_Class_Descr__c.getDescribe();
radlClass = fieldResult.getPicklistValues();
Schema.DescribeFieldResult fieldTypeResult = TouchPoint__c.TouchPointTypes__c.getDescribe();
List<Schema.PicklistEntry> typeList = fieldTypeResult.getPicklistValues();
Set<String> touchTypeSet = new Set<String>();

List<AggregateResult> groupedResults =  new List<AggregateResult>();
String Status ='Completed';
String Type1 = '1:1 Visit';
String Type2 = 'Web';
String Type3 = 'E-mail';
String Type4 = 'Call';
String Type5 = 'Event';

if(!radlClass.isEmpty()){
for(integer i=0;i<radlClass.Size();i++){
radlClassSet.add(radlClass[i].getvalue());                        
}
}

if(!typeList.isEmpty()){
radltouchtypeWrp.typeSet.add('Total');
for(Integer i=0;i<typeList.Size();i++){
// touchTypeSet.add(typeList[i].getValue());
radltouchtypeWrp.typeSet.add(typeList[i].getValue());
}

}*/
        String queryString = 'SELECT Account_SFID__c accId, Count(Id) counttouch FROM TouchPoint__c WHERE TouchPoint_Status__c = \''+Status+'\' AND Account_SFID__c = :accCropSeasonId';
        
        String queryTotalTouch= queryString + ' GROUP BY Account_SFID__c';
        
        groupedResults = Database.query(queryTotalTouch);
        System.debug('groupedResults' + groupedResults);
        for(AggregateResult ar : groupedResults){
            //Id acc = (Id)(ar.get('accId'));
            acctouchCountMap.put( (Id)(ar.get('accId')), Integer.valueOf(ar.get('counttouch')));
        } 
        
        String queryVisitTotal = queryString + ' AND TouchPointTypes__c = \''+Type1+'\' GROUP BY Account_SFID__c';
        groupedResults = Database.query(queryVisitTotal);
        for(AggregateResult ar : groupedResults){
            visitCountMap.put((Id)(ar.get('accId')),Integer.valueof(ar.get('counttouch')));
            
        }
        String queryWebTotal = queryString + ' AND TouchPointTypes__c = \''+Type2+'\'  GROUP BY Account_SFID__c';
        groupedResults = Database.query(queryWebTotal);
        for(AggregateResult ar : groupedResults){
            webCountMap.put((Id)(ar.get('accId')),Integer.valueof(ar.get('counttouch')));
            
        }
        String queryEmailTotal = queryString + ' AND TouchPointTypes__c = \''+Type3+'\' GROUP BY Account_SFID__c';
        groupedResults = Database.query(queryEmailTotal);
        for(AggregateResult ar : groupedResults){
            emailCountMap.put((Id)(ar.get('accId')),Integer.valueof(ar.get('counttouch')));
        }
        String queryChatTotal = queryString + ' AND TouchPointTypes__c = \''+Type4+'\' GROUP BY Account_SFID__c';
        groupedResults = Database.query(queryChatTotal);
        for(AggregateResult ar : groupedResults){
            chatCountMap.put((Id)(ar.get('accId')),Integer.valueof(ar.get('counttouch')));
        }
        String queryCallTotal = queryString + ' AND TouchPointTypes__c = \''+Type5+'\' GROUP BY Account_SFID__c';
        groupedResults = Database.query(queryCallTotal);
        for(AggregateResult ar : groupedResults){
            callCountMap.put((Id)(ar.get('accId')),Integer.valueof(ar.get('counttouch')));
            
        }
        
        if(!acctouchCountMap.isEmpty() || !visitCountMap.isEmpty() || !webCountMap.isEmpty() || !emailCountMap.isEmpty() || !chatCountMap.isEmpty() || !callCountMap.isEmpty()){
            for(Account_Business_Role__c accBusiness : [SELECT Id, Service_Level_Class_Descr__c,Account_SFID__c FROM Account_Business_Role__c WHERE Service_Level_Class_Descr__c !=null]){
                if(radlClassSet.contains(accBusiness.Service_Level_Class_Descr__c)){
                    if(!acctouchCountMap.isEmpty() && acctouchCountMap.containskey(accBusiness.Account_SFID__c)){
                        if(radltouchtypeWrp.totalTouchMap.containsKey(accBusiness.Service_Level_Class_Descr__c)){
                            Integer touchcount = (radltouchtypeWrp.totalTouchMap.get(accBusiness.Service_Level_Class_Descr__c))+(acctouchCountMap.get(accBusiness.Account_SFID__c));
                            radltouchtypeWrp.totalTouchMap.put(accBusiness.Service_Level_Class_Descr__c,touchcount);
                        }
                        else{
                            radltouchtypeWrp.totalTouchMap.put(accBusiness.Service_Level_Class_Descr__c,acctouchCountMap.get(accBusiness.Account_SFID__c));
                        }  
                    }
                    if(!visitCountMap.isEmpty() && visitCountMap.containskey(accBusiness.Account_SFID__c)){
                        if(radltouchtypeWrp.visitTouchMap.containsKey(accBusiness.Service_Level_Class_Descr__c)){
                            Integer touchcount = (radltouchtypeWrp.visitTouchMap.get(accBusiness.Service_Level_Class_Descr__c))+(visitCountMap.get(accBusiness.Account_SFID__c));
                            radltouchtypeWrp.visitTouchMap.put(accBusiness.Service_Level_Class_Descr__c,touchcount);
                        }
                        else{
                            radltouchtypeWrp.visitTouchMap.put(accBusiness.Service_Level_Class_Descr__c,visitCountMap.get(accBusiness.Account_SFID__c));
                        } 
                    }
                    if(!webCountMap.isEmpty() && webCountMap.containskey(accBusiness.Account_SFID__c)){
                        if(radltouchtypeWrp.webTouchMap.containsKey(accBusiness.Service_Level_Class_Descr__c)){
                            Integer touchcount = (radltouchtypeWrp.webTouchMap.get(accBusiness.Service_Level_Class_Descr__c))+(webCountMap.get(accBusiness.Account_SFID__c));
                            radltouchtypeWrp.webTouchMap.put(accBusiness.Service_Level_Class_Descr__c,touchcount);
                        }
                        else{
                            radltouchtypeWrp.webTouchMap.put(accBusiness.Service_Level_Class_Descr__c,webCountMap.get(accBusiness.Account_SFID__c));
                        }
                        
                    }
                    if(!emailCountMap.isEmpty() && emailCountMap.containskey(accBusiness.Account_SFID__c)){
                        if(radltouchtypeWrp.emailTouchMap.containsKey(accBusiness.Service_Level_Class_Descr__c)){
                            Integer touchcount = (radltouchtypeWrp.emailTouchMap.get(accBusiness.Service_Level_Class_Descr__c))+(emailCountMap.get(accBusiness.Account_SFID__c));
                            radltouchtypeWrp.emailTouchMap.put(accBusiness.Service_Level_Class_Descr__c,touchcount);
                        }
                        else{
                            radltouchtypeWrp.emailTouchMap.put(accBusiness.Service_Level_Class_Descr__c,emailCountMap.get(accBusiness.Account_SFID__c));
                        }
                        
                    } 
                    if(!chatCountMap.isEmpty() && chatCountMap.containskey(accBusiness.Account_SFID__c)){
                        if(radltouchtypeWrp.chatTouchMap.containsKey(accBusiness.Service_Level_Class_Descr__c)){
                            Integer touchcount = (radltouchtypeWrp.chatTouchMap.get(accBusiness.Service_Level_Class_Descr__c))+(chatCountMap.get(accBusiness.Account_SFID__c));
                            radltouchtypeWrp.chatTouchMap.put(accBusiness.Service_Level_Class_Descr__c,touchcount);
                        }
                        else{
                            radltouchtypeWrp.chatTouchMap.put(accBusiness.Service_Level_Class_Descr__c,chatCountMap.get(accBusiness.Account_SFID__c));
                        }
                        
                    }
                    if(!callCountMap.isEmpty() && callCountMap.containskey(accBusiness.Account_SFID__c)){
                        if(radltouchtypeWrp.callTouchMap.containsKey(accBusiness.Service_Level_Class_Descr__c)){
                            Integer touchcount = (radltouchtypeWrp.callTouchMap.get(accBusiness.Service_Level_Class_Descr__c))+(callCountMap.get(accBusiness.Account_SFID__c));
                            radltouchtypeWrp.callTouchMap.put(accBusiness.Service_Level_Class_Descr__c,touchcount);
                        }
                        else{
                            radltouchtypeWrp.callTouchMap.put(accBusiness.Service_Level_Class_Descr__c,callCountMap.get(accBusiness.Account_SFID__c));
                        }
                        
                    }
                }
                
            } 
            
        } 
        if(radltouchtypeWrp != null){
            return JSON.serialize(radltouchtypeWrp);
        }
        else{
            return null;
        } 
    }
    
    @AuraEnabled
    public static String getAccountRadl(String crop, String season){
        System.debug('Inside account radl' + crop +'crop' + season + 'season');
        crop = 'Soybean';
        season = 'SUMMER';
        Integer accountcount;
        Integer touchpointcount;
        Integer totalaccPgmcount;
        Integer totalTpcount;
        Set<Id> accTouchId = new Set<Id>();
        Set<Id> accCropSeasonId = new Set<Id>();
        List<Account> accRadlList = new List<Account>();
        Map<String,Integer> accRadlMap = new Map<String,Integer>();
        //Map<String,Integer> accPgmRadlMap = new Map<String,Integer>();
        List<Account_Program__c> accPgmList = new List<Account_Program__c>();
        List<Account_Business_Role__c> accpgmRadl =  new List<Account_Business_Role__c>();
        List<Account_Business_Role__c> accTouchRadlList =  new List<Account_Business_Role__c>();
        List<TouchPoint__c> accTouchList = new List<TouchPoint__c>();
        Map<Id,List<Touchpoint__c>> accountTouchpointMap = new Map<Id,List<Touchpoint__c>>();
        RADLtouchWrapper radltouchtypeWrp = new RADLtouchWrapper();
        //List<Account> accPgmList = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();
        Set<String> radlClassSet = new Set<String>();
        String radl1 = 'Develop';
        String radl2 = 'Acquire';
        String radl3 = 'Retain';
        String radl4 = 'Light Touch';
        
        Schema.DescribeFieldResult fieldResult = Account_Business_Role__c.Service_Level_Class_Descr__c.getDescribe();
        List<Schema.PicklistEntry>  radlClass = fieldResult.getPicklistValues();
        //Get all Service Level Class Descr picklist value
        if(!radlClass.isEmpty()){
            for(integer i=0;i<radlClass.Size();i++){
                radlClassSet.add(radlClass[i].getvalue());                        
            }
        }
        
        //Get Dealer Accounts having selected Season and Crop
        List<Account_Farming_Area__c> accFarmingList= new List<Account_Farming_Area__c>();
        accFarmingList = [SELECT Account_SFID__c,Area_Usage_Descr__c,Account_Business_Role_SFID__c,Selling_Season_Descr__c FROM Account_Farming_Area__c WHERE Account_Business_Role_SFID__r.Role_Descr__c='Partner' AND  Area_Usage_Descr__c = :crop AND Selling_Season_Descr__c = :season ];
        if(!accFarmingList.isEmpty()){
            for(Account_Farming_Area__c accFarming : accFarmingList){
                accCropSeasonId.add(accFarming.Account_SFID__c);
            }
            System.debug('accCropSeasonId' + accCropSeasonId);
        }
        
        //Construct query to count dealer account as per Service Level Class Descr
        String accRadlquery ='SELECT count(Account_SFID__c) countacc FROM Account_Business_Role__c WHERE Account_SFID__c = :accCropSeasonId';
        
        //Append WHERE condition to count dealer account against Develop
        String accDevelopquery = accRadlquery + ' AND Service_Level_Class_Descr__c = \''+radl1+'\'';
        System.debug('accDevelopquery' + accDevelopquery);
        AggregateResult arResult = Database.query(accDevelopquery);
        radltouchtypeWrp.accountRadlMap.put('Develop',Integer.valueOf((arResult.get('countacc'))));
        
        //Append WHERE condition to count dealer account against Acquire
        String accAcquirequery = accRadlquery + ' AND Service_Level_Class_Descr__c = \''+radl2+'\'';
        AggregateResult arResult1 = Database.query(accAcquirequery);
        radltouchtypeWrp.accountRadlMap.put('Acquire',Integer.valueOf((arResult1.get('countacc'))));
        
        //Append WHERE condition to count dealer account against Retain
        String accRetainquery = accRadlquery + ' AND Service_Level_Class_Descr__c = \''+radl3+'\'';
        AggregateResult arResult2 = Database.query(accRetainquery);
        radltouchtypeWrp.accountRadlMap.put('Retain',Integer.valueOf((arResult2.get('countacc'))));
        
        //Append WHERE condition to count dealer account against Light Touch
        String accLightquery = accRadlquery + ' AND Service_Level_Class_Descr__c = \''+radl4+'\'';
        AggregateResult arResult3 = Database.query(accLightquery);
        radltouchtypeWrp.accountRadlMap.put('Light Touch',Integer.valueOf((arResult3.get('countacc'))));   
        System.debug('accountRadlMap' + radltouchtypeWrp.accountRadlMap);
        
        accPgmList = [SELECT Account_SFID__c FROM Account_Program__c WHERE Account_SFID__c IN : accCropSeasonId AND  Program_SFID__c != null];
        for(Account_Program__c accPgm : accPgmList){
            accIdSet.add(accPgm.Account_SFID__c);
        }
        System.debug('accPgm - accIdSet' + accIdSet);
        accpgmRadl  = [SELECT Id, Service_Level_Class_Descr__c, Account_SFID__c FROM Account_Business_Role__c WHERE Account_SFID__c = :accIdSet AND Service_Level_Class_Descr__c!=null];
        if(!accpgmRadl.isEmpty()){
            System.debug('Inside Account Program' + accpgmRadl);
            totalaccPgmcount = accpgmRadl.size();
            for(Account_Business_Role__c accradl : accpgmRadl){
                if(radlClassSet.contains(accradl.Service_Level_Class_Descr__c)){
                    System.debug('Inside business');
                    if(radltouchtypeWrp.accPgmRadlMap.containsKey(accradl.Service_Level_Class_Descr__c)){
                        accountcount = (radltouchtypeWrp.accPgmRadlMap.get(accradl.Service_Level_Class_Descr__c)) + 1;
                        radltouchtypeWrp.accPgmRadlMap.put(accradl.Service_Level_Class_Descr__c,accountcount);
                        System.debug('Inside if' + radltouchtypeWrp.accPgmRadlMap);
                    }
                    else{
                        accountcount = 1;
                        radltouchtypeWrp.accPgmRadlMap.put(accradl.Service_Level_Class_Descr__c,accountcount);
                        System.debug('Inside else' + radltouchtypeWrp.accPgmRadlMap);
                    }
                }
                //Integer totalacccount = radltouchtypeWrp.get()
            }
            if(!radlClass.isEmpty() && !radltouchtypeWrp.accPgmRadlMap.isEmpty()){
                for(Schema.PicklistEntry radl : radlClass){
                    if((radltouchtypeWrp.accPgmRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Develop'){       
                        radltouchtypeWrp.accPgmRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accPgmRadlMap.get(radl.getValue()))/totalaccPgmcount) * 100));
                        System.debug('Inside percentage accpgm' + radltouchtypeWrp.accPgmRadlpercMap);
                    }
                    if((radltouchtypeWrp.accPgmRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Acquire'){       
                        radltouchtypeWrp.accPgmRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accPgmRadlMap.get(radl.getValue()))/totalaccPgmcount) * 100));
                        System.debug('Inside percentage accpgm' + radltouchtypeWrp.accPgmRadlpercMap);
                    }
                    if((radltouchtypeWrp.accPgmRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Light Touch'){       
                        radltouchtypeWrp.accPgmRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accPgmRadlMap.get(radl.getValue()))/totalaccPgmcount) * 100));
                        System.debug('Inside percentage accpgm' + radltouchtypeWrp.accPgmRadlpercMap);
                    }
                    if((radltouchtypeWrp.accPgmRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Retain'){       
                        radltouchtypeWrp.accPgmRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accPgmRadlMap.get(radl.getValue()))/totalaccPgmcount) * 100));
                        System.debug('Inside percentage accpgm' + radltouchtypeWrp.accPgmRadlpercMap);
                    }
                }    
            }   
        }
        
        accTouchList = [SELECT Id, Account_SFID__c FROM TouchPoint__c WHERE TouchPointTypes__c ='1:1 Visit' AND TouchPoint_Status__c ='Completed' AND Account_SFID__c IN :accCropSeasonId];
        System.debug('Inside Account touch' + accTouchList);
        if(!accTouchList.isEmpty()){
            for(TouchPoint__c accTouch : accTouchList){
                accTouchId.add(accTouch.Account_SFID__c);
                if(accountTouchpointMap.containsKey(accTouch.Account_SFID__c)) {
                    accountTouchpointMap.get(accTouch.Account_SFID__c).add(accTouch);
                }
                else{
                    accountTouchpointMap.put(accTouch.Account_SFID__c,new List<Touchpoint__c>{accTouch});
                }
                
            }
            System.debug('accountTouchpointMap' + accountTouchpointMap);  
        } 
        
        accTouchRadlList  = [SELECT Id, Service_Level_Class_Descr__c,Account_SFID__c FROM Account_Business_Role__c WHERE Account_SFID__C = :accTouchId AND Service_Level_Class_Descr__c != null];
        System.debug('accTouchRadlList' + accTouchRadlList);
        if(!accTouchRadlList.isEmpty()){
            for(Account_Business_Role__c accradl : accTouchRadlList){
                if(radlClassSet.contains(accradl.Service_Level_Class_Descr__c)){
                    System.debug('Inside business');
                    if(radltouchtypeWrp.accTouchRadlMap.containsKey(accradl.Service_Level_Class_Descr__c)){
                        accountcount = (radltouchtypeWrp.accTouchRadlMap.get(accradl.Service_Level_Class_Descr__c)) + 1;
                        radltouchtypeWrp.accTouchRadlMap.put(accradl.Service_Level_Class_Descr__c,accountcount);
                        System.debug('Inside if accTouchRadlMap' + radltouchtypeWrp.accTouchRadlMap);
                    }
                    else{
                        accountcount = 1;
                        radltouchtypeWrp.accTouchRadlMap.put(accradl.Service_Level_Class_Descr__c,accountcount);
                        System.debug('Inside else accTouchRadlMap' + radltouchtypeWrp.accTouchRadlMap);
                    }
                    if(radltouchtypeWrp.TouchpointcountRadlMap.containsKey(accradl.Service_Level_Class_Descr__c)){
                        touchpointcount = (radltouchtypeWrp.TouchpointcountRadlMap.get(accradl.Service_Level_Class_Descr__c)) + (accountTouchpointMap.get(accradl.Account_SFID__c).size());
                        radltouchtypeWrp.TouchpointcountRadlMap.put(accradl.Service_Level_Class_Descr__c,touchpointcount);
                        System.debug('Inside if TouchpointcountRadlMap' + radltouchtypeWrp.TouchpointcountRadlMap);
                    }
                    else{
                        touchpointcount = accountTouchpointMap.get(accradl.Account_SFID__c).size();
                        
                        radltouchtypeWrp.TouchpointcountRadlMap.put(accradl.Service_Level_Class_Descr__c,touchpointcount);
                        System.debug('Inside else TouchpointcountRadlMap' + radltouchtypeWrp.TouchpointcountRadlMap);
                    }
                }
            }
            if(!radlClass.isEmpty() && !radltouchtypeWrp.accTouchRadlMap.isEmpty()){
                for(Schema.PicklistEntry radl : radlClass){
                    if((radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Develop'){       
                        radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size()))*100).setScale(0));
                        // radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size())) * 100));
                    }
                    if((radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Acquire'){       
                        radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size()))*100).setScale(0));
                        //radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size())) * 100));
                    }
                    if((radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Light Touch'){       
                        radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size()))*100).setScale(0));
                        //radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size())) * 100));
                    }
                    if((radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Retain'){       
                        radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size()))*100).setScale(0));
                        //radltouchtypeWrp.accTouchRadlpercMap.put(radl.getValue(),Integer.valueOf(((radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()))/(accTouchRadlList.size())) * 100));
                    }
                }    
            }
            if(!radlClass.isEmpty() && !radltouchtypeWrp.TouchpointcountRadlMap.isEmpty()){
                totalTpcount =0;
                System.debug('Inside touch count');
                if(radltouchtypeWrp.TouchpointcountRadlMap.containsKey('Develop')){
                    totalTpcount =   radltouchtypeWrp.TouchpointcountRadlMap.get('Develop');
                }
                if(radltouchtypeWrp.TouchpointcountRadlMap.containsKey('Acquire')){
                    totalTpcount = totalTpcount +  radltouchtypeWrp.TouchpointcountRadlMap.get('Acquire');
                }
                if(radltouchtypeWrp.TouchpointcountRadlMap.containsKey('Light Touch')){
                    totalTpcount =  totalTpcount + radltouchtypeWrp.TouchpointcountRadlMap.get('Light Touch');
                }
                if(radltouchtypeWrp.TouchpointcountRadlMap.containsKey('Retain')){
                    totalTpcount =  totalTpcount + radltouchtypeWrp.TouchpointcountRadlMap.get('Retain');
                }
                //totalTpcount = radltouchtypeWrp.TouchpointcountRadlMap.get('Develop') + radltouchtypeWrp.TouchpointcountRadlMap.get('Acquire') + radltouchtypeWrp.TouchpointcountRadlMap.get('Light Touch') + radltouchtypeWrp.TouchpointcountRadlMap.get('Retain');
                // totalTpcount = radltouchtypeWrp.TouchpointcountRadlMap.get('Develop'); 
                System.debug('Inside touchpointcountper' + totalTpcount);
                for(Schema.PicklistEntry radl : radlClass){
                    
                    System.debug('Inside  touch radlset');
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Develop'){       
                        Decimal divDevelop = (((Decimal)(radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)*100).setScale(0);
                        System.debug('divDevelop' + divDevelop);
                        radltouchtypeWrp.TpcountpercRadlMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)*100).setScale(0));
                    }
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Acquire'){       
                        radltouchtypeWrp.TpcountpercRadlMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)*100).setScale(0));
                        //radltouchtypeWrp.TpcountpercRadlMap.put(radl.getValue(),((Decimal)(((Decimal)((radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)) * 100)).setScale(2));
                    }
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Light Touch'){       
                        radltouchtypeWrp.TpcountpercRadlMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)*100).setScale(0));
                        // radltouchtypeWrp.TpcountpercRadlMap.put(radl.getValue(),((Decimal)(((Decimal)((radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)) * 100)).setScale(2));
                    }
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Retain'){       
                        radltouchtypeWrp.TpcountpercRadlMap.put(radl.getValue(),(((Decimal)(radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)*100).setScale(0));
                        //radltouchtypeWrp.TpcountpercRadlMap.put(radl.getValue(),((Decimal)(((Decimal)((radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/totalTpcount)) * 100)).setScale(2));
                    }
                }    
            } 
            if(!radlClass.isEmpty() && !radltouchtypeWrp.TouchpointcountRadlMap.isEmpty() && !radltouchtypeWrp.accTouchRadlMap.isEmpty()){
                //totalTpcount = radltouchtypeWrp.TpcountpercRadlMap.get('Develop') + radltouchtypeWrp.TpcountpercRadlMap.get('Acquire') + radltouchtypeWrp.TpcountpercRadlMap.get('Light Touch') + radltouchtypeWrp.TpcountpercRadlMap.get('Retain');
                for(Schema.PicklistEntry radl : radlClass){
                    
                    System.debug('Inside  avg radlset');
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && (radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Develop'){       
                        Decimal avgDevelopcount = (radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()));
                        radltouchtypeWrp.avgVisitRadlMap.put(radl.getValue(),avgDevelopcount);
                    }
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && (radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Acquire'){             
                        Decimal avgAcquirecount = (radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()));
                        radltouchtypeWrp.avgVisitRadlMap.put(radl.getValue(),avgAcquirecount);
                    }
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && (radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Light Touch'){                   
                        Decimal avgLightcount = (radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()));
                        radltouchtypeWrp.avgVisitRadlMap.put(radl.getValue(),avgLightcount);
                    }
                    if((radltouchtypeWrp.TouchpointcountRadlMap.containsKey(radl.getValue())) && (radltouchtypeWrp.accTouchRadlMap.containsKey(radl.getValue())) && radl.getValue() =='Retain'){                         
                        Decimal avgRetaincount = (radltouchtypeWrp.TouchpointcountRadlMap.get(radl.getValue()))/(radltouchtypeWrp.accTouchRadlMap.get(radl.getValue()));
                        radltouchtypeWrp.avgVisitRadlMap.put(radl.getValue(),avgRetaincount);
                    }
                }    
            }
        }
        if(radltouchtypeWrp!=null){
            System.debug('Inside return' + radltouchtypeWrp);
            return JSON.serialize(radltouchtypeWrp);  
        }
        else{
            return null; 
        }
    }
    public class RADLtouchWrapper{
        Map<String,RADLWrapper> radltouchcount {get;set;}
        Map<String,Integer>  totalTouchMap {get;set;}
        Map<String,Integer>  visitTouchMap {get;set;}
        Map<String,Integer>  webTouchMap {get;set;}
        Map<String,Integer>  emailTouchMap {get;set;}
        Map<String,Integer> chatTouchMap {get;set;}
        Map<String,Integer> callTouchMap {get;set;}   
        Map<String,Integer> accountRadlMap {get;set;}
        Map<String,Integer> accPgmRadlMap {get;set;}
        Map<String,Integer> accPgmRadlpercMap {get;set;}
        Map<String,Decimal> accTouchRadlpercMap {get;set;}
        Map<String,Integer> accTouchRadlMap {get;set;}
        Map<String,Integer> TouchpointcountRadlMap {get;set;}
        Map<String,Decimal> TpcountpercRadlMap {get;set;}
        Map<String,Decimal> avgVisitRadlMap {get;set;}
        Set<String> typeSet {get;set;}
        Set<String> accRADLLblSet {get;set;}
        
        public RADLtouchWrapper(){
            radltouchcount = new Map<String,RADLWrapper>(); 
            totalTouchMap = new Map<String,Integer>();
            visitTouchMap = new Map<String,Integer>();
            webTouchMap = new Map<String,Integer>();
            emailTouchMap = new Map<String,Integer>();
            chatTouchMap = new Map<String,Integer>();
            callTouchMap = new Map<String,Integer>();
            accountRadlMap = new Map<String,Integer>();
            accPgmRadlMap = new Map<String,Integer>();
            accPgmRadlpercMap = new Map<String,Integer>();
            accTouchRadlpercMap = new Map<String,Decimal>();
            accTouchRadlMap = new Map<String,Integer>();
            TouchpointcountRadlMap = new Map<String,Integer>();
            TpcountpercRadlMap = new Map<String,Decimal>();
            avgVisitRadlMap = new Map<String,Decimal>();
            typeSet = new Set<String>();
            accRADLLblSet = new Set<String>{'Accounts','Accounts with Program','Accounts Visited','Total Visits','Avg Visits'};
                }
        
    }
    
    public class RADLWrapper{ 
        public Map<String,Integer> radlcount {get;set;}
        
        public RADLWrapper(){
            radlcount = new Map<String,Integer>();
        }
    }
}