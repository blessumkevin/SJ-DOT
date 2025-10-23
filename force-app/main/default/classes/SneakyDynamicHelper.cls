public class SneakyDynamicHelper {

    public static Boolean validateDynamicData(String recordName) {
        // Check if user can access Account object
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AuraHandledException('User does not have access to Account object.');
        }

        // Now perform safe SOQL
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = :recordName LIMIT 1];

        if (accs.isEmpty()) {
            throw new AuraHandledException('Required dynamic record missing: ' + recordName);
        }

        return true;
    }
}