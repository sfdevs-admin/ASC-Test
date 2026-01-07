/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
public without sharing class B2B_PeriodicTableService {

    public static Map<String,Object> getProductCategory(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if( !mapParams.isEmpty() && mapParams.containsKey('elementVal')){
            String elementVal = (String) mapParams.get('elementVal');
            List<B2B_Periodic_Table_Elements_Map__c> elementsList = [SELECT Id, Name, Element_Key__c, Element_Active__c, Category_Id__c FROM B2B_Periodic_Table_Elements_Map__c WHERE Element_Key__c =: elementVal AND Category_Id__c != NULL];
            if( ! elementsList.isEmpty() ){
                isSuccess = true;
                mapParams.put('elementsList', elementsList);
            }else{
                message = 'No data found';
            }
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }
}