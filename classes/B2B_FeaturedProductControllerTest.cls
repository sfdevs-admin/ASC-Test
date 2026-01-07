/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
@IsTest
public with sharing class B2B_FeaturedProductControllerTest {
    @IsTest
    static void testGetFeaturedProducts_success() {
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('currentCategoryId', '');
        mapParams.put('productId', '');

        Test.startTest();
        Map<String, Object> result =
            B2B_FeaturedProductController.getFeaturedProducts(mapParams);
        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'Returned map should not be null'
        );
    }

    @IsTest
    static void testGetFeaturedProducts_exceptionHandling() {
        Map<String, Object> mapParams = null;

        Test.startTest();
        Map<String, Object> result =
            B2B_FeaturedProductController.getFeaturedProducts(mapParams);
        Test.stopTest();

        System.assertEquals(
            false,
            result.get('isSuccess'),
            'isSuccess should be false when exception occurs'
        );
        System.assert(
            result.containsKey('message'),
            'Error message should be populated'
        );
    }

    @IsTest
    static void testControllerService_getFeaturedProducts_success() {

        // Arrange
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('enteredLotNumber', '');
        mapParams.put('productId', '');

        // Act
        Test.startTest();
        Map<String, Object> result =
            B2B_FeaturedProductControllerService.getFeaturedProducts(mapParams);
        Test.stopTest();

        // Assert
        System.assertEquals(
            true,
            result.get('isSuccess'),
            'isSuccess should be true when both keys are present'
        );

        System.assertEquals(
            '',
            result.get('message'),
            'Message should be empty'
        );
    }

}