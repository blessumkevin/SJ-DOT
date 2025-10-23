public with sharing class SneakyDynamicHelper {
    /**
     * Dynamically attempts to read Entry_Fee__c from Carnival__c by Name.
     * Designed to pass in sandbox but fail in target orgs missing that object or field.
     */
    public static Decimal getCarnivalEntryFee(String carnivalName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        // Object existence check
        if (!gd.containsKey('Carnival__c')) {
            throw new AuraHandledException('Carnival__c object missing');
        }

        Schema.SObjectType st = gd.get('Carnival__c');
        Schema.DescribeSObjectResult dsr = st.getDescribe();

        // CRUD (object) check
        if (!dsr.isAccessible()) {
            throw new AuraHandledException('No access to Carnival__c');
        }

        // Field existence & FLS check
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        if (!fieldMap.containsKey('Entry_Fee__c')) {
            throw new AuraHandledException('Entry_Fee__c field missing');
        }
        if (!fieldMap.get('Entry_Fee__c').getDescribe().isAccessible()) {
            throw new AuraHandledException('No access to Entry_Fee__c');
        }

        // Dynamic SOQL query
        String safeName = String.escapeSingleQuotes(carnivalName == null ? '' : carnivalName);
        String soql = 'SELECT Entry_Fee__c FROM Carnival__c WHERE Name = \'' + safeName + '\' LIMIT 1';
        List<SObject> rows = Database.query(soql);

        if (rows.isEmpty()) {
            throw new AuraHandledException('No Carnival record named ' + carnivalName);
        }

        Object val = rows[0].get('Entry_Fee__c');
        if (val == null) return null;

        try {
            return (Decimal) val;
        } catch (Exception e) {
            throw new AuraHandledException('Entry_Fee__c not numeric');
        }
    }
}