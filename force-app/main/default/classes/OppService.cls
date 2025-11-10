// OppService.cls
// Purpose: triggers Graph Engine / security / taint-flow violations safely

public without sharing class OppService {

    // Tainted input simulation
    public static String taintedInput;

    // Example method: takes "user input" and builds dynamic SOQL (unsafe pattern)
    public static String buildUnsafeQuery(String input) {
        taintedInput = input; // mark as source
        // dangerous dynamic query (do NOT execute)
        String query = 'SELECT Id, Name FROM Account WHERE Name = \'' + taintedInput + '\'';
        return query; // sink
    }

    // Example method: "unsafe DML in loop" pattern (commented to remain safe)
    public static void unsafeDmlLoop(List<String> names) {
        for (String n : names) {
            // Pattern detection only: do NOT execute
            // Account a = new Account(Name = n);
            // insert a; 
        }
    }

    // Nested dynamic queries / concatenation (triggers path-based analysis)
    public static String buildComplexQuery(String name, String filter) {
        String query = 'SELECT Id, Name FROM Opportunity WHERE Name = \'' + name + '\'';
        if (filter != null) {
            query += ' AND StageName = \'' + filter + '\'';
        }
        return query; // sink
    }

    // Methods to simulate taint flow across multiple methods
    public static String propagateTaint(String input) {
        return intermediateStep(input);
    }

    private static String intermediateStep(String v) {
        return finalSink(v);
    }

    private static String finalSink(String v) {
        // Dynamic query string is a “sink”
        return 'SELECT Id FROM Account WHERE Name = \'' + v + '\'';
    }

    // Safe wrapper to call all flows for test coverage
    public static void runDemo() {
        buildUnsafeQuery('Acme');
        unsafeDmlLoop(new List<String>{'Test1','Test2'});
        buildComplexQuery('Acme', 'Closed Won');
        propagateTaint('Injected');
    }
}