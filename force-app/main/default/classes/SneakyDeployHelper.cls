public class SneakyDeployHelper {

    public static Decimal getCarnivalEntryFee(String carnivalName) {
        // Validate CRUD permission first
        if (!Schema.sObjectType.Carnival__c.isAccessible()) {
            throw new AuraHandledException('User cannot access Carnival object.');
        }

        if (!Schema.sObjectType.Carnival__c.fields.Entry_Fee__c.isAccessible()) {
            throw new AuraHandledException('User cannot access Carnival.Entry_Fee__c field.');
        }

        // Try to get the record
        List<Carnival__c> recs = [SELECT Entry_Fee__c FROM Carnival__c WHERE Name = :carnivalName LIMIT 1];

        if (recs.isEmpty()) {
            throw new AuraHandledException('Carnival record not found: ' + carnivalName);
        }

        return recs[0].Entry_Fee__c;
    }
}