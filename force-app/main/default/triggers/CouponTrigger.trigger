trigger CouponTrigger on Coupon__c (after update) {
    List<Coupon__c> activatedCoupons = new List<Coupon__c>();

    for (Coupon__c newCoupon : Trigger.new) {
        Coupon__c oldCoupon = Trigger.oldMap.get(newCoupon.Id);

        if (
            oldCoupon != null &&
            oldCoupon.Status__c == 'Draft' &&
            newCoupon.Status__c == 'Active'
        ) {
            activatedCoupons.add(newCoupon);
        }
    }
    if (activatedCoupons.isEmpty()) {
        return;
    }

    List<Contact> contactsToEmail = [SELECT Id, FirstName, Email FROM Contact WHERE Email != null AND HasOptedOutOfEmail = false
    ];

    if (contactsToEmail.isEmpty()) {
        return;
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Coupon__c coupon : activatedCoupons) {
        for (Contact con : contactsToEmail) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ con.Email });
            mail.setSubject('New active coupon: ' + coupon.Name);

            String validToText = coupon.Valid_To_Date__c != null
                ? String.valueOf(coupon.Valid_To_Date__c)
                : 'no expiration date provided';

            String body =
                'Hello' + (con.FirstName != null ? ' ' + con.FirstName : '') + '!\n\n' +
                'We have some great news for you—a new coupon ' + coupon.Name + ' is now active.\n' +
                'The coupon is valid until: ' + validToText + '.\n\n' +
                'Order something delicious and take advantage of this special offer today!\n\n' +
                'Best regards,\n' +
                'The WildBox Team';

            mail.setPlainTextBody(body);
            emails.add(mail);
        }
    }

    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}