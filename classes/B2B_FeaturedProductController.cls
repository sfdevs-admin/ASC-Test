/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
 * @Test Class        :  B2B_FeaturedProductControllerTest
**/
public with sharing class B2B_FeaturedProductController {

    @AuraEnabled
    public static Map<String,Object> getFeaturedProducts(Map<String,Object> mapParams){
        try {
            B2B_FeaturedProductService.getFeaturedProducts(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }
}