/**
 * @description       : 
 * @author            : Swati Chilap
 * @group             : 
 * @last modified on  : 12-18-2025
 * @last modified by  : Swati Chilap
**/
@isTest
public class B2B_CountrySelectorControllerTest {

    private static final String CUSTOMER_EMAIL = 'customer@testing.cust';
    private static final String GUEST_CUSTOMER_EMAIL = 'guest_customer@testing.cust';

    @TestSetup
    static void setup() {
        User adminUser = B2B_TestDataFactory.createAdminUser('TestAdmin', true);

        System.runAs(adminUser) {
            Account userAccount = B2B_TestDataFactory.createAccount(
                'TestAccount',
                true
            );
            Contact userContact = B2B_TestDataFactory.createContact(
                'TestContact',
                userAccount.Id,
                true
            );
            User customerUser = B2B_TestDataFactory.createUser(
                'Customer',
                CUSTOMER_EMAIL,
                userContact.Id,
                true
            );
            User guestUser = B2B_TestDataFactory.createGuestUser(
                'GuestCus',
                GUEST_CUSTOMER_EMAIL,
                null,
                true
            );
        }
    }

     /* -------------------------
     * Test: getLogedInUser
     * ------------------------- */
    @IsTest
    static void testGetLoggedInUser() {

        User testUser = [SELECT Id FROM User WHERE Username = :CUSTOMER_EMAIL LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            User result = B2B_CountrySelectorController.getLogedInUser();
            Test.stopTest();

            System.assertNotEquals(null, result, 'User should not be null');
            System.assertEquals(testUser.Id, result.Id, 'Returned user should be logged-in user');
        }
    }

    /* -------------------------
     * Test: getUserAccount
     * ------------------------- */
    @IsTest
    static void testGetUserAccount() {

        Contact con = [SELECT Id, Name, AccountId FROM Contact LIMIT 1];

        Test.startTest();
        Account acct = B2B_CountrySelectorController.getUserAccount(con.Id);
        Test.stopTest();

        System.assertNotEquals(null, acct, 'Account should not be null');
        System.assertEquals(con.AccountId, acct.Id, 'Account Id should match Contact AccountId');
        System.assertEquals('USD', acct.CurrencyIsoCode, 'Currency should be USD');
    }

    /* -------------------------
     * Test: updateUserRelatedRecords
     * ------------------------- */
    @IsTest
    static void testUpdateUserRelatedRecords() {
        User testUser = [SELECT Id FROM User WHERE Username = :CUSTOMER_EMAIL LIMIT 1];

        String country = 'United States Of America';
        String currencyIsoCode = 'USD';
        System.runAs(testUser) {
            Test.startTest();
            Map<String,Object> result = B2B_CountrySelectorController.updateUserRelatedRecords(country, currencyIsoCode);
            Test.stopTest();
            System.debug('result updateUserRelatedRecords----> ' + result);
            System.assertEquals(true,result.get('isSuccess'),'Update should be successful');
        }
    }

    /* -------------------------
     * Test: updateUserRelatedRecords
     * ------------------------- */
    @IsTest
    static void testUpdateCountryInOrgCache() {
        User testUser = [SELECT Id FROM User WHERE Username = :CUSTOMER_EMAIL LIMIT 1];

        String country = 'United States Of America';
        String currencyIsoCode = 'USD';
        String guestIpAddress = '1.1.1.1';
        System.runAs(testUser) {
            Test.startTest();
            Map<String,Object> result = B2B_CountrySelectorController.updateCountryInOrgCache(country, currencyIsoCode, guestIpAddress);
            Test.stopTest();
            System.debug('result updateCountryInOrgCache----> ' + result);
            System.assertEquals(true,result.get('isSuccess'),'Org cache update should succeed');
        }
    }

    /* -------------------------
     * Test: updateUserRelatedRecords for logged in user
     * ------------------------- */
    @IsTest
    static void testGetInitdata() {
        User testUser = [SELECT Id FROM User WHERE Username = :CUSTOMER_EMAIL LIMIT 1];

        Boolean loggedinUserCountryEmpty = true;
        String countryCode = 'US';
        String guestIpAddress = '1.1.1.1';
        System.runAs(testUser) {
            Test.startTest();
            B2B_CountrySelectorController.InitDataWrapper result = B2B_CountrySelectorController.getInitData(guestIpAddress, countryCode, loggedinUserCountryEmpty);
            Test.stopTest();
            System.debug('result getInitData----> ' + result);
            System.assertNotEquals(null, result);
            System.assertNotEquals(null, result.countriesData);
        }
    }

    /* -------------------------
     * Test: updateUserRelatedRecords for guest user
     * ------------------------- */
    @IsTest
    static void testGetInitdataGuestUser() {
        User guestUser = [SELECT Id FROM User WHERE Username = :GUEST_CUSTOMER_EMAIL LIMIT 1];

        Boolean loggedinUserCountryEmpty = true;
        String countryCode = 'US';
        String guestIpAddress = '1.1.1.1';
        System.runAs(guestUser) {
            Test.startTest();
            B2B_CountrySelectorController.InitDataWrapper result = B2B_CountrySelectorController.getInitData(guestIpAddress, countryCode, loggedinUserCountryEmpty);
            Test.stopTest();
            System.debug('result getInitData gguest ----> ' + result);
            System.assertNotEquals(null, result);
            System.assertNotEquals(null, result.countriesData);
        }
    }

    /* -------------------------
     * Test: updateUserRelatedRecords for guest user with null IP address
     * ------------------------- */
    @IsTest
    static void testGetInitdataGuestUserNullIpAddress() {
        User guestUser = [SELECT Id FROM User WHERE Username = :GUEST_CUSTOMER_EMAIL LIMIT 1];

        Boolean loggedinUserCountryEmpty = true;
        String countryCode = 'US';
        String guestIpAddress = null;
        System.runAs(guestUser) {
            Test.startTest();
            B2B_CountrySelectorController.InitDataWrapper result = B2B_CountrySelectorController.getInitData(guestIpAddress, countryCode, loggedinUserCountryEmpty);
            Test.stopTest();
            System.debug('result getInitData with null----> ' + result);
            System.assertNotEquals(null, result);
            System.assertNotEquals(null, result.countriesData);
        }
    }

}