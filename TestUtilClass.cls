/* ************************************************************************************************************
* Category             :   Apex Factory Class
* Name                 :   TestUtilClass
* Description          :   This is utility class for creating test data for the test class wherever required.
* Author               :   Cognizant Technology Solutions
* ************************************************************************************************************/
@isTest
public class TestUtilClass {
   Public static list<account> accts;
    Public static list<account> growerAccts;
    public static List<Account_Farming_Area__c> accCropFarmingArea;
    Public static list<Contact> contactList;
    Public static List<User> listUsers;
    Public static List<Territory2> territoryList;
    Public static List<Group> groupList;
    Public static List<LoginHistory> logHistory;
    public static List<Account_Farming_Area__c> accTotalFarmingArea;
    Public static List<User> listadminusers {get;set;}
    public static String adminProfile;
    //Create Test Records for Account
    public static List<Account> createTestAccount(Integer numAccts) {
        accts = new list<Account>();
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i, Archive_Ind__c = 'N',BillingLatitude=13.082680,BillingLongitude=80.270718);
            accts.add(a);
        }
        try{
            if(!accts.isEmpty()){
                insert accts; 
            }  
        }
        catch(DMLException e){
            System.debug('Exception Occured when createTestAccount'+e.getMessage());
        }     
        return accts;
    }  
    public static List<Account> createTestGrowerAccount(Integer numAccts) {
        growerAccts = new list<Account>();
        RecordType strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                      AND DeveloperName = 'Individual' LIMIT 1];
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i, Archive_Ind__c = 'N',BillingLatitude=13.082680,BillingLongitude=80.270718,
                                   Recordtypeid=strRecordTypeId.id,Dealer_SFID__c=accts[0].id);
            growerAccts.add(a);
        }
        try{
            if(!growerAccts.isEmpty()){
                insert growerAccts; 
            }  
        }
        catch(DMLException e){
            System.debug('Exception Occured when createTestAccount'+e.getMessage());
        }     
        return growerAccts;
    }    
   
    // Create business role for the respective account
   
    
    public static List<LoginHistory> createLoginHistory(List<User> users)
    {        
        return logHistory;
    }   
    
    
    //Create Test Records for Events
    public static List<Event> createTestEvent(Integer noOfEvents){ 
        List<Event> eventList = new List<Event>(); 
        // Add Events 
        for (Integer i=0;i<noOfEvents;i++){ 
            eventList.add(new Event(Description ='Test notes',Subject='Training',StartDateTime = DateTime.Now().addDays(-1), 
                                    WhatId = ((accts.size() == 4 && i <= 3 ? accts[i].Id:accts[0].Id)), 
                                    Type ='Phone Call',whoId = contactList[0].Id,ActivityDate = Date.Today().addDays(2),
                                    EndDateTime = DateTime.Now().addDays(5))); 
        } 
        try{
            if(!eventList.isEmpty()){        
                insert eventList;
            }
        }
        catch(Exception e){
            System.debug('Exception Occured when createTestEvent'+e.getMessage());
        }
        return eventList; 
    }
    
    //Create Test Records for Tasks
    public static List<Task> createTask(Integer noOfTask,String taskStatus){ 
        List<Task> taskList = new List<Task>();         
        // Add Events 
        for (Integer i=0;i<noOfTask;i++){ 
            taskList.add(new Task(Description ='Test notes',Type ='Call',ActivityDate = Date.Today(),
                                  WhatId = ((accts.size() == 4 && i <= 3 ? accts[i].Id:accts[0].Id)),Status=taskStatus));
        } 
        try{
            if(!taskList.isEmpty()){        
                insert taskList;
            }
        }
        catch(Exception e){
            System.debug('Exception Occured when createTask'+e.getMessage());
        }
        return taskList; 
    }
    public static void createContact(Integer numOfContacts){
        contactList = new list<Contact>();
        if(!accts.isEmpty()){
            for(Integer i=0;i<numOfContacts;i++) {
                Contact con = new Contact(FirstName='Test' + i,LastName='Contact'+i,AccountId = accts[0].Id); 
                contactList.add(con);
            }
            try{
                if(!contactList.isEmpty()){
                    insert contactList; 
                }  
                System.debug('Contacts list ---' + contactList);
            }
            catch(DMLException e){
                System.debug('Exception Occured when creating Contact'+e.getMessage());
            } 
        }
    }
    // Create Test Territory Records
    @future
    public static void CreateTestTerritory(Integer noofTerritory){        
        Territory2Model territoryModel = new Territory2Model();
        territoryModel .DeveloperName='ModelName'; // required field
        territoryModel.Name = 'Name'; // required field
        
        insert territoryModel ;   
        for (Integer i=0;i<noofTerritory;i++){ 
            territoryList.add(new Territory2(DeveloperName = 'TestTerritory',Territory2ModelId=territoryModel.Id, 
                                             Name='TestTerritory'));
        }     
        try{
            if(!territoryList.isEmpty()){        
                insert territoryList;                
            }
        }
        catch(Exception e){
            System.debug('Exception Occured when createTask'+e.getMessage());
        }      
        // return territoryList; 
    }
    // Create test records for the user territory
    @future
    public static void CreateUserTerritory2Association(Integer noofUserTerritory){       
        List<UserTerritory2Association> userTerritoryAssociationList = new List<UserTerritory2Association>();
        for (Integer i=0;i<noofUserTerritory;i++){ 
            userTerritoryAssociationList.add(new UserTerritory2Association(Territory2Id= territoryList[0].Id,
                                                                           UserId= listUsers[0].Id,RoleInTerritory2='Sales / Marketing Manager'));
        }    
        try{
            if(!userTerritoryAssociationList.isEmpty()){        
                insert userTerritoryAssociationList;
            }
        } 
        catch(Exception e){
            System.debug('Exception Occured when createTask'+e.getMessage());
        }    
        //return userTerritoryAssociationList; 
    }
    
    
    // Create account sharing records to provide sharing access to the account
    public static List<AccountShare> createAccountShare(){ 
        List<AccountShare> accountShares = new List<AccountShare>();
        //List<Group> grouplist=[Select Id, RelatedId from Group where Type='Territory'];
        if(accts.size()>0){
            for(Account acc : accts){
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = accts[0].Id;
                accountShare.UserOrGroupId = groupList[0].Id;
                accountShare.AccountAccessLevel = 'Edit';
                accountShare.ContactAccessLevel = 'Edit';
                accountShare.CaseAccessLevel = 'Edit';
                accountShare.OpportunityAccessLevel = 'Edit';
                accountShares.add(accountShare);
            }
        }
        try{
            if(!accountShares.isEmpty()){
                insert accountShares;
            }
        } 
        catch(Exception e){
            System.debug('Exception Occured when createTask'+e.getMessage());
        }
        return accountShares;
    }
    // create test users
    public static List<User> createTestUsers(String profileName,Integer noOfUser){
        adminProfile = profileName;
        String Country = 'en_US';
        String OrgID =Userinfo.getOrganizationId();    
        listUsers = new List<User>();       
        Profile admProfile = [select id,name from Profile where Name =: profileName];
        listadminusers = new List<User>();
        listadminusers = [Select Id, Name, ProfileId From User Where ProfileId =: admProfile.Id Limit 1];
        //User u1=[Select Id,Name from User where Id=:userInfo.getUserId()];
        
            //Create Test Records for List of users             
            for(integer i=0;i<noOfUser;i++){
                listUsers.add( new User(ProfileId = admProfile.id,isActive = True,FederationIdentifier = '199'+i+'7876'+i,
                                        LastName = 'Test1+i',FirstName='Test',Alias = 'test2',Email = 'admUser'+i+'@asdf.com',
                                        Username = 'admUser'+ OrgID + i +'@asdf.com',TimeZoneSidKey = 'GMT',LanguageLocaleKey = Country,EmailEncodingKey = 'UTF-8',LocaleSidKey = Country));
            }     
            try{
                if(!listUsers.isEmpty()){
                    insert listUsers;
                }
            }      
            catch(Exception e){
                System.debug('Error Message' + e.getMessage());
            }   
        
        return listUsers;
    }
    
    
    // Create test account communication records
    public static List<Account_Communication__c> createTestAccountCommunication(Integer numBusinessRolesperAccount){
        Profile admProfile = [select id,name from Profile where Name = 'System Administrator'];
        
                List<Account_Communication__c> accCommunication = new List<Account_Communication__c>();

        if(!listUsers.isEmpty() && adminProfile == 'System Administrator'){
            System.runAs(listUsers[0]){
        //Create Test Records for Account Communication
        // Add Account Communication
        RecordType strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account_Communication__c'
                                      AND DeveloperName = 'Account_Communication_Address_Role_Business_Role' LIMIT 1];
        
        for (Integer i=0;i<numBusinessRolesperAccount;i++) {
            accCommunication.add(new Account_Communication__c(Street_Addr__c='701 RAILROAD HWY',City_Name__c='UNDERWOOD',
                                                              State_Name__c='IA',Country_Name__c='US',Archive_Ind__c = 'N',
                                                              Account_SFID__c=(i<=2?(accts.size() == 4 && i <= 3 ? accts[i].Id:accts[0].Id):(growerAccts.size() == 4 && i <= 3 ? growerAccts[i].Id:growerAccts[0].Id)),
                                                              Recordtypeid=strRecordTypeId.id));
        }
        // Insert Business Role for all test accounts
        try{
            if(!accCommunication.isEmpty()){        
                insert accCommunication;
            }
        }
        catch(Exception e){
            System.debug('Exception Occured when createTestAccountCommunication'+e.getMessage());
        }
        }
        }
        return accCommunication;
    }
    
    
    
     public static List<Account_Business_Role__c> createTestAccountRole(Integer numBusinessRolesperAccount){
         
        List<String> Radlclass = new List<String>{'Develop','Acquire','Retain','Light Touch'};
        //Profile admProfile = [select id,name from Profile where Name = 'System Administrator'];
        
            //Create Business Role for Account
            List<Account_Business_Role__c> accBusiness = new List<Account_Business_Role__c>();  
          if(!listUsers.isEmpty() && adminProfile == 'System Administrator'){
            System.runAs(listUsers[0]){
        // Add Account Business Role
        for(Integer i=0;i<numBusinessRolesperAccount;i++) {
            Id accid = accts[i].Id;
            accBusiness.add(new Account_Business_Role__c(Service_Level_Class_Descr__c= (i >= 0 && i <= 2 ? Radlclass[i]:'Light Touch') ,
                                                         SAP_ID__c='0001022212'+i,Archive_Ind__c = 'N',Role_Descr__c='Partner',
                                                         Account_SFID__c=(i<=2?(i >= 0 && i <= 2 ? accts[i].Id:accts[0].Id):(i >= 0 && i <= 2 ? growerAccts[i].Id:growerAccts[0].Id))));
        }
        
        try{
            // Insert Business Role for all test accounts
            if(!accBusiness.isEmpty()){        
                insert accBusiness;
            }
        }
        catch(Exception e){
            System.debug('Exception Occured when createTestAccountRole '+e.getMessage());
        }}}
        return accBusiness;
    }
    public static List<Account_Farming_Area__c> createTestTotalAccountFarmingArea(Integer numAccountFarmingArea){
       accTotalFarmingArea = new List<Account_Farming_Area__c>();  
        RecordType totoalRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account_Farming_Area__c'
                                      AND DeveloperName = 'Account_Farming_Area_Total_Farming_Area' LIMIT 1];
        if(!listUsers.isEmpty() && adminProfile == 'System Administrator'){
            System.runAs(listUsers[0]){
                for(Integer i=0;i<numAccountFarmingArea;i++) {
                    accTotalFarmingArea.add(new Account_Farming_Area__c(Name='MonsantoFarmingArea '+ i ,
                                                         Account_SFID__c=accts[0].Id,Recordtypeid=totoalRecordTypeId.id,
                                                            Inbound_Total_Farm_Area_Qty__c=10000,Total_Farming_Area_Qty__c=10000,
                                                             Inbound_Area_Use_UOM_Descr__c='Acre',
                                                             Year__c=(i==0?2017:(i==1?2016:2015)),Year_Type__c='Fiscal Year'
                                                            
                                                         ));
                    
                }  
                 try{
            if(accTotalFarmingArea.size() > 0){        
                insert accTotalFarmingArea;
            }
        }
        catch(Exception e){
            System.debug('Exception Occured '+e.getMessage());
        }
            }
        }
     return accTotalFarmingArea;
    }
    public static List<Account_Farming_Area__c> createTestCropAccountFarmingAreaInsert(Integer numAccountFarmingArea){
       accCropFarmingArea = new List<Account_Farming_Area__c>();  
        RecordType strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account_Farming_Area__c'
                                      AND DeveloperName = 'Account_Farming_Area_Crop_Farming_Area' LIMIT 1];
        if(!listUsers.isEmpty() && adminProfile == 'System Administrator' && !accTotalFarmingArea.isEmpty()){
            System.runAs(listUsers[0]){
                for(Integer i=0;i<numAccountFarmingArea;i++) {
                    accCropFarmingArea.add(new Account_Farming_Area__c(Name='MonsantoFarmingArea '+ i ,
                                                         Account_SFID__c=accts[0].Id,Recordtypeid=strRecordTypeId.id,
                                                            Parent_SFID__c=(i<=2?accTotalFarmingArea[0].id:(i<=5?accTotalFarmingArea[1].id:accTotalFarmingArea[2].id)),Area_Usage_Descr__c='Corn',
                                                           Area_Qty__c=100 ,Inbound_Area_Qty__c=100,Inbound_Area_Use_UOM_Descr__c='Acre',
                                                             Year__c=2017,Year_Type__c='Fiscal Year',
                                                            Selling_Season_Descr__c=(i<=2?'2017 Safra':(i<=5?'2016 Safra':'2015 Safra'))    
                                                           
                                                         ));
                    
                }  
                 try{
            if(!accCropFarmingArea.isEmpty()){        
                insert accCropFarmingArea;
                
            }
            system.debug('============++++' +accCropFarmingArea);
                 }
        catch(Exception e){
            System.debug('Exception Occured '+e.getMessage());
        }
            }
        }
     return accCropFarmingArea;
    }
     public static List<Account_Farming_Area__c> createTestCropAccountFarmingArea(Integer numAccountFarmingArea){
       accCropFarmingArea = new List<Account_Farming_Area__c>();  
        RecordType strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account_Farming_Area__c'
                                      AND DeveloperName = 'Account_Farming_Area_Crop_Farming_Area' LIMIT 1];
        if(!listUsers.isEmpty() && adminProfile == 'System Administrator' && !accTotalFarmingArea.isEmpty()){
            System.runAs(listUsers[0]){
                for(Integer i=0;i<numAccountFarmingArea;i++) {
                    accCropFarmingArea.add(new Account_Farming_Area__c(Name='MonsantoFarmingArea '+ i ,
                                                         Account_SFID__c=accts[0].Id,Recordtypeid=strRecordTypeId.id,
                                                            Parent_SFID__c=accTotalFarmingArea[0].id,Area_Usage_Descr__c='Corn',
                                                           Area_Qty__c=(i<=1?100:20000),Inbound_Area_Qty__c=(i>=4?20000:100)        
                                                         ));
                    
                }  
                 try{
            if(!accCropFarmingArea.isEmpty()){        
                insert accCropFarmingArea;
                
            }
            system.debug('============++++' +accCropFarmingArea);
                 }
        catch(Exception e){
            System.debug('Exception Occured '+e.getMessage());
        }
            }
        }
     return accCropFarmingArea;
    }
    public static List<Account_Sales__c> createTestSales(Integer numSales){
        List<Account_Sales__c> accSales = new List<Account_Sales__c>();
        if(!listUsers.isEmpty() && adminProfile == 'System Administrator' && !accTotalFarmingArea.isEmpty()){
            System.runAs(listUsers[0]){
                for(Integer i=0;i<numSales;i++) {
                    accSales.add(new Account_Sales__c(Name='MonsantoFarmingArea '+ i ,
                                                         Account_SFID__c=accts[0].Id,Brand_Name__c='Channel',Budget__c=100,
                                                         Crop__c='Corn',Net_Sales_Qty__c=100,Opportunity__c=150,
                                                          Order_Qty__c=200,Year__c=(i==0?'2017':(i==1?'2016':'2015'))
                                                         ));
                    
                }  
                 try{
            if(!accSales.isEmpty()){        
                insert accSales;
                
            }
            system.debug('============++++' +accSales);
                 }
        catch(Exception e){
            System.debug('Exception Occured '+e.getMessage());
        }
            }
        }
     return accSales;
    }
    
    public static List<User> createTestUsers(Integer userRequired, String ProfileRequired)
    {
        if(!listUsers.isEmpty() && adminProfile == 'System Administrator'){
            System.runAs(listUsers[0]){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;                   
        for(Integer i=0;i<userRequired;i++) {
            User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: ProfileRequired].Id,
                              LastName = 'last',
                              Email = 'DeveloperMonsanto@monsanto.com',
                              Username = 'DeveloperMonsanto@monsanto.com' +i+ System.currentTimeMillis(),
                              CompanyName = 'TEST',
                              IsActive = True,
                              Title = 'title',
                              Alias = 'alias',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              EmailEncodingKey = 'UTF-8',
                              LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US',
                              UserRoleId = r.Id);
            listUsers.add(u);
        }           
        try{
            if(!listUsers.isEmpty()){
                insert listUsers; 
            }  
        }
        catch(DMLException e){
            System.debug('Exception Occured when createTestAccount'+e.getMessage());
        }}}
        return listUsers;
    }
    
    // Create test record with fake end point url
    public static void createEndPoint(){
        EndpointUrlSetting__c endPointUrl = new EndpointUrlSetting__c();
        endPointUrl.Name = 'callout:Frontier_Named_Credentials';
        endPointUrl.Authorization_Url__c = 'https://test.amp.monsanto.com/as/token.oauth2?client_id=Global-Sales-Portal&client_secret=Wa8otHw859LG4yLQxQLEkfpzlHAxw1uirDgdv0ov5NRd1VQYrMJcTnwuqJUhCtFM&grant_type=client_credentials';
        endPointUrl.Callback_Url__c = '//'+'frontier-dealer-radl-mvp/queries';
        insert endPointUrl;
    }
    // Create test record with the appropriate record type    
    public static void createRecordType(){
        Recordtypes__c recordtype = new Recordtypes__c();
        recordtype.Name = 'Event Touch Point';
        recordtype.Value__c = [select id from Recordtype where Developername='Event_Touch_Point' limit 1].id;
        insert recordtype;
    }
    public static void createEndPointCustomer360(){
        EndpointUrlSetting__c endPointUrl = new EndpointUrlSetting__c();
        endPointUrl.Name = 'Customer360Credentials';
        endPointUrl.Authorization_Url__c = 'https://api01-np.agro.services/customer360-identity-demo/v1/radl-parties?globalPartyIdentifier=1';
        endPointUrl.Auth_Token_URL__c = 'https://test.amp.monsanto.com/as/token.oauth2';
        endPointUrl.Client_Id__c='DATA-CUSTOMER360-SVC';
        endPointUrl.Client_Secret__c='OYatpgTO3P9jUtbnfmw9bNaelveZY7MjgnmXzuQwxMjmotyLc4';
        insert endPointUrl;
    }
    
    public static void createEndPointCompany360(){
        EndpointUrlSetting__c endPointUrl = new EndpointUrlSetting__c();
        endPointUrl.Name = 'Company360Credentials';
        endPointUrl.Authorization_Url__c = 'https://api01-np.agro.services/company360/0.0.1/commercial/net-sales-rc-grower';
        endPointUrl.Auth_Token_URL__c = 'https://test.amp.monsanto.com/as/token.oauth2';
        endPointUrl.Client_Id__c='Company360';
        endPointUrl.Client_Secret__c='boxb8iBJ6T8HkCmZzvgjQW4uLTMkdc9Is9Xi5PNOCFX6jT8ssbRTPs9HMRCLVvua';
        insert endPointUrl;
    } 
    public static void createtriggerControl(){
        TriggerControl__c triggerControl = new TriggerControl__c();
        triggerControl.Name='Trigger: FarmingAreaValidation';
        triggerControl.Execute_Trigger__c = true;
        insert triggerControl;
    } 
     public static void createCropRecordType(){
        Recordtypes__c recordtype = new Recordtypes__c();
        recordtype.Name = 'AccountFarmingAreaCropFarmingArea';
        recordtype.Value__c = [select id from Recordtype where Developername='Account_Farming_Area_Crop_Farming_Area' limit 1].id;
        insert recordtype;
    }
     public static void createTotalRecordType(){
        Recordtypes__c recordtype = new Recordtypes__c();
        recordtype.Name = 'AccountFarmingAreaTotalFarmingArea';
        recordtype.Value__c = [select id from Recordtype where Developername='Account_Farming_Area_Total_Farming_Area' limit 1].id;
        insert recordtype;
    }
    
}