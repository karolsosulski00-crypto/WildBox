public with sharing class OrderEndingEmailScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        OrderEndingEmailService.sendEndingEmails();
    }
}