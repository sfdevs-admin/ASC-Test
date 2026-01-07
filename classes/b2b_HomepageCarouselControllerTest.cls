/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
**/
@IsTest
public with sharing class b2b_HomepageCarouselControllerTest {
    @IsTest
    static void testGetData_successOrNoData() {

        Map<String, Object> mapParams = new Map<String, Object>();

        Test.startTest();
        Map<String, Object> result =
            b2bHomepageCarouselController.getData(mapParams);
        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'Returned map should not be null'
        );

        System.assert(
            result.containsKey('isSuccess'),
            'isSuccess key must be present'
        );

        System.assert(
            result.containsKey('message'),
            'message key must be present'
        );

        if ((Boolean) result.get('isSuccess')) {
            System.assert(
                result.containsKey('imageDataList'),
                'imageDataList should be present when isSuccess = true'
            );
        }
    }

    @IsTest
    static void testGetData_exceptionHandling() {

        Map<String, Object> mapParams = null;

        Test.startTest();
        Map<String, Object> result =
            b2bHomepageCarouselController.getData(mapParams);
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
}