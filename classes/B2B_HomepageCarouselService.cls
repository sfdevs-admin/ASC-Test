/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
public with sharing class B2B_HomepageCarouselService {

    public static Map<String,Object> getData(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        List<B2B_Homepage_Carousel__mdt> imageDataList = [SELECT Id, Description__c, Image_URL__c, Heading__c, Link_URL__c, URL_Target__c FROM B2B_Homepage_Carousel__mdt ORDER BY Sort_Order__c ASC];
        if( ! imageDataList.isEmpty() ){
            mapParams.put('imageDataList', imageDataList);
            isSuccess = true;
        }else{
            message = 'No images found';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }
}