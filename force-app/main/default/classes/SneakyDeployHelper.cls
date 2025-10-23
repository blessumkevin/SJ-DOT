public class SneakyDeployHelper {
    public static Boolean checkForSandboxRecord() {
        // Pretend we're validating some configuration record
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = 'Sandbox Dummy' LIMIT 1];
        return !accs.isEmpty();
    }
}