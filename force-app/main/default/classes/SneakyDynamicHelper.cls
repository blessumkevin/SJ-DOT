/**
 * Helper class for dynamically retrieving the Entry_Fee__c field
 * from the Carnival__c object.
 * 
 * Purpose:
 * - Exists primarily for validation and testing scenarios.
 * - Passes in sandbox if the object and field exist.
 * - Fails validation in target orgs missing Carnival__c or Entry_Fee__c.
 * 
 * @author Your Name
 * @since 2024
 * @version 1.0
 */
public with sharing class SneakyDynamicHelper {

    // Constants for better maintainability and PMD compliance
    private static final String CARNIVAL_OBJECT_NAME = 'Carnival__c';
    private static final String ENTRY_FEE_FIELD_NAME = 'Entry_Fee__c';
    private static final String NAME_FIELD = 'Name';
    private static final Integer QUERY_LIMIT = 1;
    
    // Error messages as constants
    private static final String ERROR_OBJECT_MISSING = 'Carnival__c object missing';
    private static final String ERROR_NO_ACCESS_OBJECT = 'No access to Carnival__c';
    private static final String ERROR_FIELD_MISSING = 'Entry_Fee__c field missing';
    private static final String ERROR_NO_ACCESS_FIELD = 'No access to Entry_Fee__c';
    private static final String ERROR_NO_RECORD_FOUND = 'No Carnival record named ';
    private static final String ERROR_NOT_NUMERIC = 'Entry_Fee__c not numeric';

    /**
     * Retrieves the Entry_Fee__c value for a Carnival__c record by its Name.
     *
     * @param carnivalName The Name value of the Carnival__c record to query.
     * @return The Entry_Fee__c as a Decimal if found; null otherwise.
     * @throws AuraHandledException if the object or field is missing, inaccessible, or invalid.
     */
    public static Decimal getCarnivalEntryFee(String carnivalName) {
        // Validate input parameter
        if (String.isBlank(carnivalName)) {
            throw new AuraHandledException('Carnival name cannot be null or empty');
        }

        // Check object existence and access
        validateObjectAccess();
        
        // Check field existence and access
        Schema.DescribeFieldResult entryFeeDescribe = validateFieldAccess();

        // Execute query and return result
        return executeQueryAndExtractValue(carnivalName);
    }

    /**
     * Validates that the Carnival__c object exists and is accessible.
     * 
     * @throws AuraHandledException if object is missing or not accessible
     */
    private static void validateObjectAccess() {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        // Check object existence
        if (!globalDescribe.containsKey(CARNIVAL_OBJECT_NAME)) {
            throw new AuraHandledException(ERROR_OBJECT_MISSING);
        }

        Schema.SObjectType carnivalType = globalDescribe.get(CARNIVAL_OBJECT_NAME);
        Schema.DescribeSObjectResult carnivalDescribe = carnivalType.getDescribe();

        // Check CRUD (object) access
        if (!carnivalDescribe.isAccessible()) {
            throw new AuraHandledException(ERROR_NO_ACCESS_OBJECT);
        }
    }

    /**
     * Validates that the Entry_Fee__c field exists and is accessible.
     * 
     * @return Schema.DescribeFieldResult for the Entry_Fee__c field
     * @throws AuraHandledException if field is missing or not accessible
     */
    private static Schema.DescribeFieldResult validateFieldAccess() {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType carnivalType = globalDescribe.get(CARNIVAL_OBJECT_NAME);
        Schema.DescribeSObjectResult carnivalDescribe = carnivalType.getDescribe();
        
        // Check field existence and FLS
        Map<String, Schema.SObjectField> fieldMap = carnivalDescribe.fields.getMap();
        if (!fieldMap.containsKey(ENTRY_FEE_FIELD_NAME)) {
            throw new AuraHandledException(ERROR_FIELD_MISSING);
        }

        Schema.DescribeFieldResult entryFeeDescribe = fieldMap.get(ENTRY_FEE_FIELD_NAME).getDescribe();
        if (!entryFeeDescribe.isAccessible()) {
            throw new AuraHandledException(ERROR_NO_ACCESS_FIELD);
        }

        return entryFeeDescribe;
    }

    /**
     * Executes the SOQL query and extracts the Entry_Fee__c value.
     * 
     * @param carnivalName The name of the carnival to search for
     * @return The Entry_Fee__c value as Decimal, or null if the field value is null
     * @throws AuraHandledException if no record is found or value is not numeric
     */
    private static Decimal executeQueryAndExtractValue(String carnivalName) {
        // Dynamic SOQL query with proper escaping
        String safeName = String.escapeSingleQuotes(carnivalName);
        String soql = 'SELECT ' + ENTRY_FEE_FIELD_NAME + ' FROM ' + CARNIVAL_OBJECT_NAME + 
                     ' WHERE ' + NAME_FIELD + ' = \'' + safeName + '\' LIMIT ' + QUERY_LIMIT;
        
        List<SObject> results = Database.query(soql);

        if (results.isEmpty()) {
            throw new AuraHandledException(ERROR_NO_RECORD_FOUND + carnivalName);
        }

        Object fieldValue = results[0].get(ENTRY_FEE_FIELD_NAME);
        if (fieldValue == null) {
            return null;
        }

        try {
            return (Decimal) fieldValue;
        } catch (Exception ex) {
            throw new AuraHandledException(ERROR_NOT_NUMERIC);
        }
    }
}