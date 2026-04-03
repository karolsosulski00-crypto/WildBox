@IsTest
private class OrderEndingEmailServiceTest {

    @IsTest
    static void testSendEndingEmails() {
        Account acc = new Account(Name = 'Test Customer');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Jakub',
            LastName = 'Adamski',
            Email = 'karamur4elove@gmail.com',
            AccountId = acc.Id
        );
        insert con;

        Order__c orderRecord = new Order__c(
            Name = 'Order-001',
            Customer__c = acc.Id,
            Number_of_Deliveries_Left__c = 2,
            Total_Number_of_Deliveries__c = 5,
            Is_Order_Ending_Email_Sent__c = false
        );
        insert orderRecord;

        Test.startTest();
        OrderEndingEmailService.sendEndingEmails();
        Test.stopTest();

        Order__c updatedOrder = [
            SELECT Id, Is_Order_Ending_Email_Sent__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals(true, updatedOrder.Is_Order_Ending_Email_Sent__c);
    }

    @IsTest
    static void testScheduler() {
        Account acc = new Account(Name = 'Scheduler Customer');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Denis',
            LastName = 'Lukieniuk',
            Email = 'denisluk@gmail.com',
            AccountId = acc.Id
        );
        insert con;

        Order__c orderRecord = new Order__c(
            Name = 'Order-002',
            Customer__c = acc.Id,
            Number_of_Deliveries_Left__c = 2,
            Total_Number_of_Deliveries__c = 6,
            Is_Order_Ending_Email_Sent__c = false
        );
        insert orderRecord;

        Test.startTest();
        String cronExp = '0 0 20 * * ?';
        System.schedule('Test Order Ending Email Job', cronExp, new OrderEndingEmailScheduler());
        Test.stopTest();

        Order__c updatedOrder = [
            SELECT Id, Is_Order_Ending_Email_Sent__c
            FROM Order__c
            WHERE Id = :orderRecord.Id
        ];

        System.assertEquals(true, updatedOrder.Is_Order_Ending_Email_Sent__c);
    }
}