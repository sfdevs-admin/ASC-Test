/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 12-18-2025
 * @last modified by  : Swati Chilap
**/
public class B2B_CountrySelectorController {

    @AuraEnabled
    public static InitDataWrapper getInitData(String guestIpAddress, String countryCode, Boolean loggedinUserCountryEmpty){
    // public static InitDataWrapper getInitData(String guestIpAddress, String countryCode){
        system.debug('guestIpAddress => '+guestIpAddress);
        system.debug('countryCode => '+countryCode);
        
        List<CountryWithISOCode__mdt> countriesMDTList = new List<CountryWithISOCode__mdt>();
        //User logedInUser = new User();
        InitDataWrapper idw = new InitDataWrapper();
        String valueMapData = 'USD-United States of America';
        String countryNameFromApi;
        String countryCodeFromApi;
        try {
            countriesMDTList = !Test.isRunningTest()
                 ? [SELECT Id, Country_Name__c, ISO_code__c, Currency_Code__c, Country_Code__c FROM CountryWithISOCode__mdt order by Country_Name__c ASC]
                 : B2B_TestDataFactory.getCountryIsoCmdtData();
            System.debug('countriesMDTList => '+countriesMDTList.size());
            idw.countriesData = countriesMDTList;

            // Safely find matching country metadata
            if (String.isNotBlank(countryCode) && countriesMDTList != null && !countriesMDTList.isEmpty()) {
                for (CountryWithISOCode__mdt country : countriesMDTList) {
                    if (country.Country_Code__c != null && country.Country_Code__c.equalsIgnoreCase(countryCode)) {
                        valueMapData = country.Currency_Code__c + '-' + country.Country_Name__c;
                        countryNameFromApi = country.Country_Name__c;
                        countryCodeFromApi = country.Currency_Code__c;
                        break;
                    }
                }
            }


            if(!Auth.CommunitiesUtil.isGuestUser()){
                if (loggedinUserCountryEmpty) {
                    updateUserRelatedRecords(countryNameFromApi, countryCodeFromApi);
                }
                User logedInUser = getLogedInUser();
                System.debug('logedInUser => '+logedInUser);
                system.debug('user type =>'+UserInfo.getUserType());
                idw.currentUser = logedInUser;
            }else if(Auth.CommunitiesUtil.isGuestUser() && guestIpAddress != null){
                
                Map<String, String> valueMap = new Map<String, String>();
                Cache.OrgPartition orgPart = Cache.Org.getPartition('local.IPAddressCache');
                System.debug('orgPart ::::: ' + orgPart);
                System.debug('orgPart Get Ipaddress::::: ' + orgPart.get('ipAddress'));

                if(orgPart.contains('ipAddress')){
                    valueMap = (Map<String, String>)orgPart.get('ipAddress');
                    System.debug('valueMap :::: ' + valueMap);
                }
                if(valueMap.containsKey(guestIpAddress)){
                    valueMapData = valueMap.get(guestIpAddress);
                }else{
                    valueMap.put(guestIpAddress, valueMapData);
                    orgPart.put('ipAddress',valueMap);
                    System.debug('orgPart Get Ipaddress::::: ' + orgPart.get('ipAddress'));
                }
                //idw.userIpAddress = ipAddress;
                idw.guestCountryInfo = valueMapData;
            }else{
                idw.guestCountryInfo = valueMapData;
            }
            
            
        } catch (Exception e) {
            System.debug('exception : ' + e.getMessage());
            throw new AuraHandledException('Unable to fetch required data.');
        }

        return idw;
    }

    public class InitDataWrapper {
        @AuraEnabled
        public List<CountryWithISOCode__mdt> countriesData;
        @AuraEnabled
        public User currentUser;
        // @AuraEnabled
        // public String userIpAddress;
        @AuraEnabled
        public String guestCountryInfo;
    }

    @AuraEnabled
    public static Map<String,Object> updateUserRelatedRecords(String country, String currencyIsoCode){
        Map<String,Object> responseMap = new Map<String,Object>();
        try{
            User logedInUser = getLogedInUser();
            logedInUser.Country = country;
            logedInUser.User_Country__c = country;
            logedInUser.CurrencyIsoCode = currencyIsoCode;
            update logedInUser;

            Account acct = getUserAccount(logedInUser.ContactId);
            acct.CurrencyIsoCode = currencyIsoCode;
            update acct;
            responseMap.put('isSuccess',true);
            responseMap.put('User', logedInUser);
            responseMap.put('Account', acct);
        } catch (Exception e) {
            System.debug('exception : ' + e.getMessage());
            throw new AuraHandledException('Unable to update user country.');
        }
        
        return responseMap;
    }

    @AuraEnabled
    public static Map<String,Object>  updateCountryInOrgCache(String country, String currencyIsoCode, String guestIpAddress){
        Map<String,Object> responseMap = new Map<String,Object>();
        Map<String, String> valueMap = new Map<String, String>();
        String valueMapData = '';
        try{
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.IPAddressCache');
            if(orgPart.contains('ipAddress')){
                valueMap = (Map<String, String>)orgPart.get('ipAddress');
            }
            valueMap.put(guestIpAddress,currencyIsoCode+'-'+country);
            orgPart.put('ipAddress',valueMap);
            responseMap.put('isSuccess',true);
        } catch (Exception e) {
            System.debug('exception : ' + e.getMessage());
            throw new AuraHandledException('Unable to update user country.');
        }
        return responseMap;
    }

    @AuraEnabled
    public static user getLogedInUser(){
        String userId = UserInfo.getUserId();
        User logedInUser = [SELECT Id, Country, User_Country__c, CurrencyIsoCode, ContactId FROM User WHERE Id = :userId];
        return logedInUser;
    }

    @AuraEnabled
    public static Account getUserAccount(String contactId){
        Contact cont = [SELECT Id, AccountId FROM Contact WHERE Id =: contactId];
        Account acct = [SELECT Id, CurrencyIsoCode FROM Account WHERE Id =: cont.AccountId];
        return acct;
    }


}