/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
public without sharing class B2B_PeriodicTableController {
    @AuraEnabled
    public static Map<String,Object> getProductCategory(Map<String,Object> mapParams){
        try {
            B2B_PeriodicTableService.getProductCategory(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }
}