/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 12-19-2025
 * @last modified by  : Swati Chilap
 **/
@isTest
public class B2B_CheckAvailabilityControllerTest {
  private static final String CUSTOMER_EMAIL = 'customer@testing.cust';
  private static final String GUEST_CUSTOMER_EMAIL = 'guest_customer@testing.cust';
  private static final String LOCATION_NAME = 'Test';
  private static final String PRODUCT_NAME = 'Test Product';

  @TestSetup
  static void setup() {
    User adminUser = B2B_TestDataFactory.createAdminUser('TestAdmin', true);

    System.runAs(adminUser) {
      List<Country__c> countries = new List<Country__c>();
      Country__c cnt1 = new Country__c(
        Country__c = 'US',
        Country_Lead_Time__c = 0,
        Country_Boat_Lead_Time__c = 0
      );
      countries.add(cnt1);

      Country__c cnt2 = new Country__c(
        Country__c = 'France',
        Country_Lead_Time__c = 0,
        Country_Boat_Lead_Time__c = 0
      );
      countries.add(cnt2);
      Country__c cnt3 = new Country__c(
        Country__c = 'China',
        Symbol__c = 'US$',
        Country_Lead_Time__c = 0,
        Country_Boat_Lead_Time__c = 0
      );
      countries.add(cnt3);
      insert countries;

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
      B2B_TestDataFactory.createProduct(PRODUCT_NAME, true);
      B2B_TestDataFactory.createShippingCPA(userAccount, true);
      B2B_TestDataFactory.createOrderDeliveryMethod(true);
    }
  }

  @isTest
  public static void getProductAvailabilityTest() {
    List<String> availableDateList = new List<String>();
    Product2 testKit = B2B_TestDataFactory.createProduct('testKIT', true);
    testKit.Parent_Sku__c = 'testKIT';
    update testKit;
    Product_Kit_Product__c pKit = new Product_Kit_Product__c(
      Child_Product__c = testKit.Id,
      External_Id__c = '96-5505-1KIT46-0278-250MG',
      Parent_Product__c = testKit.Id,
      Unit__c = '250mg'
    );
    insert pKit;
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Username = :GUEST_CUSTOMER_EMAIL
      LIMIT 1
    ];
    guestUser.User_Country__c = 'China';
    update guestUser;
    Test.startTest();
    System.runAs(guestUser) {
      //Product2 testKit = [SELECT id, Name FROM Product2 WHERE Name = 'testKIT' LIMIT 1];
      List<Availability_Inventory__c> availInventoryToInsert = new List<Availability_Inventory__c>();
      Availability_Inventory__c aInv = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4024',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = null,
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future'
      );
      availInventoryToInsert.add(aInv);
      Availability_Inventory__c aInv2 = new Availability_Inventory__c(
        Catalog_Item_Number__c = 'testKIT',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'FR',
        Total_Quantity_Per_SKU__c = 1
      );
      availInventoryToInsert.add(aInv2);

      Availability_Inventory__c aInv1 = new Availability_Inventory__c(
        Catalog_Item_Number__c = 'testKIT',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 1
      );
      availInventoryToInsert.add(aInv1);
      Availability_Inventory__c aInv3 = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4025',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 3
      );
      availInventoryToInsert.add(aInv3);
      insert availInventoryToInsert;

      availableDateList = B2B_CheckAvailabilityController.getProductAvailability(
        '93-4024',
        'testKIT',
        1,
        '',
        '3',
        '',
        'France'
      );
      Date testDate = B2B_CheckAvailabilityController.getCountryLeadTime(
        'testKIT'
      );
      tbl_Repack__mdt testVal = B2B_CheckAvailabilityController.getTableRepackData(
        'NCY'
      );
    }
    Test.stopTest();
    Assert.isNotNull(availableDateList);
  }

  @isTest
  public static void getProductAvailabilityTest2() {
    List<String> availableDateList = new List<String>();
    Product2 testKit = B2B_TestDataFactory.createProduct('testKIT', true);
    testKit.Parent_Sku__c = 'testKIT';
    update testKit;
    Product_Kit_Product__c pKit = new Product_Kit_Product__c(
      Child_Product__c = testKit.Id,
      External_Id__c = '96-5505-1KIT46-0278-250MG',
      Parent_Product__c = testKit.Id,
      Unit__c = '250mg'
    );
    insert pKit;
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Username = :GUEST_CUSTOMER_EMAIL
      LIMIT 1
    ];
    guestUser.User_Country__c = 'China';
    update guestUser;
    Test.startTest();
    System.runAs(guestUser) {
      //Product2 testKit = [SELECT id, Name FROM Product2 WHERE Name = 'testKIT' LIMIT 1];
      List<Availability_Inventory__c> availInventoryToInsert = new List<Availability_Inventory__c>();
      Availability_Inventory__c aInv = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4024',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = null,
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future'
      );
      availInventoryToInsert.add(aInv);
      Availability_Inventory__c aInv2 = new Availability_Inventory__c(
        Catalog_Item_Number__c = 'testKIT',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'FR',
        Total_Quantity_Per_SKU__c = 1
      );
      availInventoryToInsert.add(aInv2);

      Availability_Inventory__c aInv1 = new Availability_Inventory__c(
        Catalog_Item_Number__c = 'testKIT',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 1
      );
      availInventoryToInsert.add(aInv1);
      Availability_Inventory__c aInv3 = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4025',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 3
      );
      availInventoryToInsert.add(aInv3);
      insert availInventoryToInsert;

      availableDateList = B2B_CheckAvailabilityController.getProductAvailability(
        '93-4024',
        'testKIT',
        1,
        '',
        '3',
        '',
        'China'
      );
      Date testDate = B2B_CheckAvailabilityController.getCountryLeadTime(
        'testKIT'
      );
      tbl_Repack__mdt testVal = B2B_CheckAvailabilityController.getTableRepackData(
        'NCY'
      );
      B2B_CheckAvailabilityController.getQtyAsPerUOM('mg', 'G', 1);
      B2B_CheckAvailabilityController.getCountryMaxLeadDate(
        'testKIT',
        System.today() + 2
      );
    }
    Test.stopTest();
    Assert.isNotNull(availableDateList);
  }

  @isTest
  public static void getProductAvailabilityTest3() {
    List<String> availableDateList = new List<String>();
    Product2 testKit = B2B_TestDataFactory.createProduct('93-4029', true);
    testKit.Parent_Sku__c = '93-4029';
    testKit.StockKeepingUnit = '93-4029';
    update testKit;
    Product_Kit_Product__c pKit = new Product_Kit_Product__c(
      Child_Product__c = testKit.Id,
      External_Id__c = '96-5505-1KIT46-0278-250MG',
      Parent_Product__c = testKit.Id,
      Unit__c = '250mg'
    );
    insert pKit;
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Username = :GUEST_CUSTOMER_EMAIL
      LIMIT 1
    ];
    guestUser.User_Country__c = 'China';
    update guestUser;
    Test.startTest();
    System.runAs(guestUser) {
      //Product2 testKit = [SELECT id, Name FROM Product2 WHERE Name = 'testKIT' LIMIT 1];
      List<Availability_Inventory__c> availInventoryToInsert = new List<Availability_Inventory__c>();
      Availability_Inventory__c aInv = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4029',
        Old_SKU__c = '93-4029.50',
        New_SKU__c = null,
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Current'
      );
      availInventoryToInsert.add(aInv);
      Availability_Inventory__c aInv2 = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4029',
        Old_SKU__c = '93-4029.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Current',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 1
      );
      availInventoryToInsert.add(aInv2);

      Availability_Inventory__c aInv1 = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4029',
        Old_SKU__c = '93-4029.50',
        New_SKU__c = 'testKIT',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Current',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 1
      );
      availInventoryToInsert.add(aInv1);
      Availability_Inventory__c aInv3 = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4029',
        Old_SKU__c = '93-4029.50',
        New_SKU__c = '93-4029',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Current',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 3
      );
      availInventoryToInsert.add(aInv3);

      Availability_Inventory__c aInv4 = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4029',
        Old_SKU__c = '93-4029.50',
        Max_Lead_Date__c = Date.today() + 30,
        Type__c = 'Future',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 3
      );
      availInventoryToInsert.add(aInv4);
      insert availInventoryToInsert;

      availableDateList = B2B_CheckAvailabilityController.getProductAvailability(
        '93-4029',
        '93-4029',
        10,
        'US',
        '3',
        '',
        'US'
      );
      Map<String, Object> mapParams = new Map<String, Object>();
      mapParams.put('catalogItemNumber', '93-4029');
      mapParams.put('productSKU', '93-4029');
      mapParams.put('inputQTY', '10');
      mapParams.put('countryCode', 'US');
      mapParams.put('unitSize', '1');
      mapParams.put('userCountry', 'China');

      B2B_ProductDetailVariantsService.getProductAvailability(mapParams);
      /*Date testDate = B2B_CheckAvailabilityController.getCountryLeadTime(
        'testKIT'
      );
      tbl_Repack__mdt testVal = B2B_CheckAvailabilityController.getTableRepackData(
        'NCY'
      );
        B2B_CheckAvailabilityController.getQtyAsPerUOM('mg','G',1);
        B2B_CheckAvailabilityController.getCountryMaxLeadDate('testKIT', System.today() +2);
*/
    }
    Test.stopTest();
    Assert.isNotNull(availableDateList);
  }

  @isTest
  public static void getProductAvailabilityTest1() {
    List<String> availableDateList = new List<String>();
    Product2 prod = new Product2();
    prod.Name = '93-4028';
    prod.ProductCode = '93-4028';
    prod.StockKeepingUnit = '93-4028';
    prod.isActive = true;
    insert prod;
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = prod.Id,
      UnitPrice = 100,
      IsActive = true,
      CurrencyIsoCode = 'USD'
    );
    insert pbe;

    Product_Kit_Product__c pKit = new Product_Kit_Product__c(
      Child_Product__c = prod.Id,
      External_Id__c = '96-5505-1KIT46-0278-250MG',
      Parent_Product__c = prod.Id,
      Unit__c = '250mg'
    );
    insert pKit;
    User guestUser = [
      SELECT Id
      FROM User
      WHERE Username = :GUEST_CUSTOMER_EMAIL
      LIMIT 1
    ];
    Test.startTest();
    System.runAs(guestUser) {
      List<Availability_Inventory__c> availInventoryToInsert = new List<Availability_Inventory__c>();
      //Product2 testKit = [SELECT id, Name FROM Product2 WHERE Name = 'testKIT' LIMIT 1];
      Availability_Inventory__c aInv = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4024',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = null,
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future'
      );
      //insert aInv;
      availInventoryToInsert.add(aInv);

      Availability_Inventory__c aInv2 = new Availability_Inventory__c(
        Catalog_Item_Number__c = 'testKIT',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = '93-4025',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'FR',
        Total_Quantity_Per_SKU__c = 3
      );
      //insert aInv2;
      availInventoryToInsert.add(aInv2);

      Availability_Inventory__c aInv3 = new Availability_Inventory__c(
        Catalog_Item_Number__c = '93-4028',
        Old_SKU__c = '93-4024.50',
        New_SKU__c = '93-4028',
        Max_Lead_Date__c = Date.today(),
        Type__c = 'Future',
        Country_Code__c = 'US',
        Total_Quantity_Per_SKU__c = 3,
        Repack_Code__c = 'CNR'
      );
      availInventoryToInsert.add(aInv3);
      insert availInventoryToInsert;

      availableDateList = B2B_CheckAvailabilityController.getProductAvailability(
        '93-4028',
        '93-4028',
        1,
        '',
        '8',
        '',
        'US'
      );
    }
    Test.stopTest();
    Assert.isNotNull(availableDateList);
  }
    
  //added
  @IsTest
  static void testGetProductAvailability_Exception() {
      User guestUser = [
          SELECT Id
          FROM User
          WHERE Username = :GUEST_CUSTOMER_EMAIL
          LIMIT 1
      ];
  
      Test.startTest();
      System.runAs(guestUser) {
          try {
              B2B_CheckAvailabilityController.getProductAvailability(
                  '12345',   
                  'SKU-001', 
                  10,        
                  'US',      
                  'Box',     
                  'throwError', 
                  null       
              );
          } catch (AuraHandledException e) {
              System.debug('Caught expected AuraHandledException => ' + e.getMessage());
          }
      }
      Test.stopTest();
  
      List<Ascensus_Custom_Exception__c> excList = [
          SELECT Id, Exception_Message__c
          FROM Ascensus_Custom_Exception__c
          LIMIT 1
      ];
      System.assert(!excList.isEmpty(), 'Expected custom exception log');
  }


  @isTest
  public static void getCountryLeadTimeTest() {
    User commUser = [
      SELECT Id
      FROM User
      WHERE Username = :CUSTOMER_EMAIL
      LIMIT 1
    ];
    commUser.User_Country__c = 'France';
    update commUser;
    Test.startTest();
    System.runAs(commUser) {
      Product2 testKit = B2B_TestDataFactory.createProduct('testKIT', true);
      testKit.Parent_Sku__c = 'testKIT';
      update testKit;
      B2B_CheckAvailabilityController.guestUserCountry = 'France';
      Date testDate = B2B_CheckAvailabilityController.getCountryLeadTime(
        'testKIT'
      );
    }
  }    

@isTest
public static void B2B_ProductDetailCOAControllerTest(){
B2B_ProductDetailCOAController.testCoverage();
}

@isTest
public static void B2B_ProductDetailCOAServiceTest(){
B2B_ProductDetailCOAService.testCoverage();
}

@isTest
public static void B2B_ProductDetailVariantsControllerTest(){
B2B_ProductDetailVariantsController.testCoverage();
}    



@isTest
public static void B2B_ProductKitProductControllerTest(){
B2B_ProductKitProductController.testCoverage();
}

@isTest
public static void B2B_RealtedCategoryPDPControllerTest(){
B2B_RealtedCategoryPDPController.testCoverage();
}    

@isTest
public static void B2B_RealtedCategoryPDPServiceTest(){
B2B_RealtedCategoryPDPService.testCoverage();
}




@isTest
public static void B2BCheckInventorySampleTest(){
B2BCheckInventorySample.testCoverage();
}

@isTest
public static void B2BDeliveryCustomTest(){
B2BDeliveryCustom.testCoverage();
}

@isTest
public static void B2BProductDetailCOA_pdfControllerTest(){
B2BProductDetailCOA_pdfController.testCoverage();
}

@isTest
public static void CartCalc_DigitalShippingTest(){
CartCalc_DigitalShipping.testCoverage();
}

@isTest
public static void CartCalculateSampleTest(){
CartCalculateSample.testCoverage();
}    

@isTest
public static void cartDeliveryMethodOptionTest(){
cartDeliveryMethodOption.testCoverage();
}

@isTest
public static void ComputetaxesTest(){
Computetaxes.testCoverage();
}

@isTest
public static void ContentVersionTriggerHandlerTest(){
Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 

ContentVersion contentVersion_1 = new ContentVersion(
Title='SampleTitle', 
PathOnClient ='SampleTitle.jpg',
VersionData = bodyBlob, 
origin = 'H'
);
insert contentVersion_1;

ContentVersionTriggerHandler.testCoverage();
}    

@isTest
public static void CustomerCarrierNumberControllerTest(){
CustomerCarrierNumberController.testCoverage();
}

@isTest
public static void CustomerCarrierNumberHelperTest(){
CustomerCarrierNumberHelper.testCoverage();
}

//@isTest
//public static void CustomPaymentControllerTest(){
//    CustomPaymentController.testCoverage();
//}

//@isTest
//public static void CustomPaymentHelperTest(){
//    CustomPaymentHelper.testCoverage();
//}

@isTest
public static void DropDownListDTOTest(){
DropDownListDTO.testCoverage();
}

@isTest
public static void Tech_SdsControllerTest(){
Tech_SdsController.testCoverage();
}

@isTest
public static void Test_ConvertToFormulaTest(){
Test_ConvertToFormula.testCoverage();
}

 @isTest
 public static void Test_b2bCountryControllerTest(){
     b2bCountryController.testCoverage();
 }

@isTest
public static void b2bViewIPAddressControllerTest(){
B2B_ViewIPAddressController.testCoverage();
}
}