public with sharing class OrderEndingEmailService {

    public static void sendEndingEmails() {
        List<Order__c> orders = [
            SELECT Id, Name, Customer__c, Customer__r.Name, Number_of_Deliveries_Left__c, Is_Order_Ending_Email_Sent__c 
            FROM Order__c WHERE Number_of_Deliveries_Left__c = 2 AND Is_Order_Ending_Email_Sent__c = false  AND Customer__c != null
        ];

        if (orders.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        for (Order__c orderRecord : orders) {
            accountIds.add(orderRecord.Customer__c);
        }

        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE AccountId IN :accountIds AND Email != null
        ];

        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        for (Contact con : contacts) {
            if (!contactsByAccountId.containsKey(con.AccountId)) {
                contactsByAccountId.put(con.AccountId, new List<Contact>());
            }
            contactsByAccountId.get(con.AccountId).add(con);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Order__c> ordersToUpdate = new List<Order__c>();

        for (Order__c orderRecord : orders) {
            List<Contact> accountContacts = contactsByAccountId.get(orderRecord.Customer__c);

            if (accountContacts == null || accountContacts.isEmpty()) {
                continue;
            }

            List<String> toAddresses = new List<String>();
            for (Contact con : accountContacts) {
                if (String.isNotBlank(con.Email)) {
                    toAddresses.add(con.Email);
                }
            }

            if (toAddresses.isEmpty()) {
                continue;
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Your order is close to completion');
            mail.setPlainTextBody(
                'Hello,' + '\n\n' +
                'There are 2 deliveries left for your order "' + orderRecord.Name + '".' + '\n\n' +
                'Customer: ' + orderRecord.Customer__r.Name + '\n' +
                'Deliveries left: 2' + '\n\n' +
                'Best regards,'
            );

            emails.add(mail);

            orderRecord.Is_Order_Ending_Email_Sent__c = true;
            ordersToUpdate.add(orderRecord);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}