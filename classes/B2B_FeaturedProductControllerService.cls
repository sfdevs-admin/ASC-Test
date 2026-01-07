/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
public with sharing class B2B_FeaturedProductControllerService {

    public static Map<String,Object> getFeaturedProducts(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        System.debug('getFeaturedProducts mapParams-- '+JSON.serialize(mapParams));
        if( mapParams.containsKey('enteredLotNumber') && mapParams.containsKey('productId') ){
            isSuccess = true;
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

}