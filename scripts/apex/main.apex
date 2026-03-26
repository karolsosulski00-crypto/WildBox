List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new List<String>{'b.levy@expressl&t.net'});
mail.setSubject('New active coupon: ');


String body =
    'Order something delicious and take advantage of this special offer today!\n\n' +
    'Best regards,\n' +
    'The WildBox Team';

mail.setPlainTextBody(body);
emails.add(mail);
        


if (!emails.isEmpty()) {
    Messaging.sendEmail(emails);
}


delete [SELECT Id from Case];