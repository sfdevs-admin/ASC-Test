/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
public with sharing class b2bHomepageCarouselController {
    
    @AuraEnabled
    public static Map<String,Object> getData(Map<String,Object> mapParams){
        try {
            B2B_HomepageCarouselService.getData(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }
}