/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
@IsTest
public with sharing class B2B_PeriodicTableControllerTest {

    @IsTest
    static void testGetProductCategory_noDataFound() {

        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('elementVal', 'XYZ');

        Test.startTest();
        Map<String, Object> result =
            B2B_PeriodicTableController.getProductCategory(mapParams);
        Test.stopTest();

        System.assertEquals(
            false,
            result.get('isSuccess'),
            'isSuccess should be false when no data is found'
        );

        System.assertEquals(
            'No data found',
            result.get('message'),
            'Correct message should be returned'
        );
    }

    @IsTest
    static void testGetProductCategory_missingParam() {

        Map<String, Object> mapParams = new Map<String, Object>();

        Test.startTest();
        Map<String, Object> result =
            B2B_PeriodicTableController.getProductCategory(mapParams);
        Test.stopTest();

        System.assertEquals(
            false,
            result.get('isSuccess'),
            'isSuccess should be false when input is invalid'
        );
    }

    @IsTest
    static void testGetProductCategory_exceptionHandling() {

        Map<String, Object> mapParams = null;

        Test.startTest();
        Map<String, Object> result =
            B2B_PeriodicTableController.getProductCategory(mapParams);
        Test.stopTest();

        System.assertEquals(
            false,
            result.get('isSuccess'),
            'isSuccess should be false on exception'
        );

        System.assert(
            result.containsKey('message'),
            'Error message should be populated'
        );
    }
}