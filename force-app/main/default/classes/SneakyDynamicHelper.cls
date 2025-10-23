public class SneakyDynamicHelper {

    /**
     * Attempts to read Entry_Fee__c from Carnival__c by Name.
     * Uses dynamic describes and dynamic SOQL so there is no compile-time
     * reference to Carnival__c or Entry_Fee__c.
     *
     * @param carnivalName Name of the carnival record to locate
     * @return Entry_Fee__c value as Decimal
     * @throws AuraHandledException if object/field/record missing or not accessible
     */
    public static Decimal getCarnivalEntryFee(String carnivalName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        // Make sure the object exists
        if (!gd.containsKey('Carnival__c')) {
            throw new AuraHandledException('Carnival__c object is not present in this org.');
        }

        Schema.SObjectType st = gd.get('Carnival__c');
        Schema.DescribeSObjectResult dsr = st.getDescribe();

        // Check CRUD (object) access
        if (!dsr.isAccessible()) {
            throw new AuraHandledException('Current user does not have access to Carnival__c.');
        }

        // Check the field exists and is accessible
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        if (!fieldMap.containsKey('Entry_Fee__c')) {
            throw new AuraHandledException('Entry_Fee__c field is not present on Carnival__c in this org.');
        }
        if (!fieldMap.get('Entry_Fee__c').getDescribe().isAccessible()) {
            throw new AuraHandledException('Current user does not have access to Carnival__c.Entry_Fee__c field.');
        }

        // Build dynamic SOQL - escape the input
        String safeName = String.escapeSingleQuotes(carnivalName == null ? '' : carnivalName);
        String soql = 'SELECT Entry_Fee__c FROM Carnival__c WHERE Name = \'' + safeName + '\' LIMIT 1';

        // Execute and return the field via dynamic SObject access
        List<SObject> rows = Database.query(soql);
        if (rows.isEmpty()) {
            throw new AuraHandledException('Carnival record not found: ' + carnivalName);
        }

        Object val = rows[0].get('Entry_Fee__c');
        if (val == null) {
            return null;
        }
        // Ensure numeric cast (may throw if field type isn't numeric)
        try {
            return (Decimal) val;
        } catch (Exception ex) {
            throw new AuraHandledException('Entry_Fee__c value could not be converted to Decimal: ' + ex.getMessage());
        }
    }
}