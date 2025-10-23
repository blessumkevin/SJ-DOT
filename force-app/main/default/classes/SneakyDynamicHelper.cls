public class SneakyDynamicHelper {

    public static Boolean validateDynamicData(String recordName) {
        // Query dynamically based on input
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = :recordName LIMIT 1];

        if (accs.isEmpty()) {
            throw new AuraHandledException('Required dynamic record missing: ' + recordName);
        }

        return true;
    }
}