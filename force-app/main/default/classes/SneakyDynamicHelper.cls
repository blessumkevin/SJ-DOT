/**
 * Helper class for dynamically retrieving the Entry_Fee__c field
 * from the Carnival__c object. 
 * 
 * Purpose:
 * - Exists primarily for validation and testing scenarios.
 * - Passes in sandbox if the object and field exist.
 * - Fails validation in target orgs missing Carnival__c or Entry_Fee__c.
 */
public with sharing class SneakyDynamicHelper {

    /**
     * Retrieves the Entry_Fee__c value for a Carnival__c record by its Name.
     *
     * @param carnivalName The Name value of the Carnival__c record to query.
     * @return The Entry_Fee__c as a Decimal if found; null otherwise.
     * @throws AuraHandledException if the object or field is missing, inaccessible, or invalid.
     */
    public static Decimal getCarnivalEntryFee(String carnivalName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        // Check object existence
        if (!globalDescribe.containsKey('Carnival__c')) {
            throw new AuraHandledException('Carnival__c object missing');
        }

        Schema.SObjectType carnivalType = globalDescribe.get('Carnival__c');
        Schema.DescribeSObjectResult carnivalDescribe = carnivalType.getDescribe();

        // Check CRUD (object) access
        if (!carnivalDescribe.isAccessible()) {
            throw new AuraHandledException('No access to Carnival__c');
        }

        // Check field existence and FLS
        Map<String, Schema.SObjectField> fieldMap = carnivalDescribe.fields.getMap();
        if (!fieldMap.containsKey('Entry_Fee__c')) {
            throw new AuraHandledException('Entry_Fee__c field missing');
        }

        Schema.DescribeFieldResult entryFeeDescribe = fieldMap.get('Entry_Fee__c').getDescribe();
        if (!entryFeeDescribe.isAccessible()) {
            throw new AuraHandledException('No access to Entry_Fee__c');
        }

        // Dynamic SOQL query
        String safeName = String.escapeSingleQuotes(carnivalName == null ? '' : carnivalName);
        String soql = 'SELECT Entry_Fee__c FROM Carnival__c WHERE Name = \'' + safeName + '\' LIMIT 1';
        List<SObject> results = Database.query(soql);

        if (results.isEmpty()) {
            throw new AuraHandledException('No Carnival record named ' + carnivalName);
        }

        Object val = results[0].get('Entry_Fee__c');
        if (val == null) {
            return null;
        }

        try {
            return (Decimal) val;
        } catch (Exception e) {
            throw new AuraHandledException('Entry_Fee__c not numeric');
        }
    }
}