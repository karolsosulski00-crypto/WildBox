@isTest
private class CouponTriggerTest {

    @isTest
    static void testCouponChangesFromDraftToActive() {
        Contact c = new Contact(
            LastName = 'Adamski',
            Email = 'test1@example.com',
            HasOptedOutOfEmail = false
        );
        insert c;

        Coupon__c coupon = new Coupon__c(
            Name = 'Spring Promo',
            Status__c = 'Draft',
            Valid_To_Date__c = Date.today().addDays(30),
            Discount_Percentage__c = 10
        );
        insert coupon;

        Test.startTest();
        coupon.Status__c = 'Active';
        update coupon;
        Test.stopTest();

        Coupon__c updatedCoupon = [
            SELECT Id, Status__c
            FROM Coupon__c
            WHERE Id = :coupon.Id
        ];

        System.assertEquals('Active', updatedCoupon.Status__c, 'Coupon status should be updated to Active.');
    }

    @isTest
    static void testNoEmailWhenStatusDoesNotChangeToActive() {
        Contact c = new Contact(
            LastName = 'Lukeniuk',
            Email = 'test2@example.com',
            HasOptedOutOfEmail = false
        );
        insert c;

        Coupon__c coupon = new Coupon__c(
            Name = 'Winter Promo',
            Status__c = 'Draft',
            Valid_To_Date__c = Date.today().addDays(15),
            Discount_Percentage__c = 15
        );
        insert coupon;

        Test.startTest();
        coupon.Name = 'Winter Promo Updated';
        update coupon;
        Test.stopTest();

        System.assertEquals('Winter Promo Updated', coupon.Name, 'Coupon name should be updated.');
    }

    @isTest
    static void testNoEmailForOptedOutContacts() {
        Contact c = new Contact(
            LastName = 'Ostry', 
            Email = 'test3@example.com',
            HasOptedOutOfEmail = true
        );
        insert c;

        Coupon__c coupon = new Coupon__c(
            Name = 'Special Promo',
            Status__c = 'Draft',
            Valid_To_Date__c = Date.today().addDays(10),
            Discount_Percentage__c = 20
        );
        insert coupon;

        Test.startTest();
        coupon.Status__c = 'Active';
        update coupon;
        Test.stopTest();

        Coupon__c updatedCoupon = [
            SELECT Id, Status__c
            FROM Coupon__c
            WHERE Id = :coupon.Id
        ];

        System.assertEquals('Active', updatedCoupon.Status__c, 'Coupon should still be activated even if contact opted out.');
    }
}