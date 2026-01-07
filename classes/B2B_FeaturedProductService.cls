/**
 * @description       : 
 * @author            : surya.thakur
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
 * @Test Class        :  B2B_FeaturedProductControllerTest
 *
**/
public without sharing class B2B_FeaturedProductService {
    public static Map<String,Object> getFeaturedProducts(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        System.debug('getFeaturedProducts mapParams-- '+JSON.serialize(mapParams));
        if( mapParams.containsKey('currentCategoryId') && mapParams.containsKey('productId')){
            String catId = (String) mapParams.get('currentCategoryId');
            String prodId = (String) mapParams.get('productId');
            List<ProductCategoryProduct> prodToCatList = [SELECT Id,  Name, CurrencyIsoCode, ProductCategoryId, ProductCategory.Name, ProductId, Product.Name, Product.Featured_Priority__c,  IsPrimaryCategory, CatalogId, Catalog.Name, ProductToCategory FROM ProductCategoryProduct WHERE ProductCategoryId = :catId AND Product.Featured_Priority__c != null ORDER BY Product.Featured_Priority__c ASC LIMIT 10];
            if( ! prodToCatList.isEmpty() ){
                mapParams.put('prodToCatList', prodToCatList);
                isSuccess = true;
            }else{
                message = 'No featured product found';
            }
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }
}