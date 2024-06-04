@isTest
private class ConvertLeadActionTest {
    
    @isTest
    static void test_convert_lead_yes_opportunity() {

        Account acc = new Account();
        acc.name = 'Account Test';
            
        insert acc;
        
        Lead ld = new Lead(
            firstName = 'Marc',
            lastName = 'Benioff',
            company = 'Salesforce',
            email = 'test@test.com',
            Account__c = acc.Id,
            AllowConversion__c = true
        );

        insert ld;

        Test.startTest();

        ConvertLeadAction.ConvertLeadActionRequest request = new ConvertLeadAction.ConvertLeadActionRequest();
        request.leadId = ld.id;
        request.accountId = acc.Id;
        request.convertedStatus = [ SELECT id, ApiName FROM LeadStatus WHERE isConverted = true LIMIT 1 ].ApiName;
        request.createOpportunity = true;
        request.opportunityName = 'Test Opportunity';

        List<ConvertLeadAction.ConvertLeadActionResult> results = ConvertLeadAction.convertLeads( new List<ConvertLeadAction.ConvertLeadActionRequest>{ request } );

        Test.stopTest();

        System.assert( results != null );
        System.assertEquals( 1, results.size() );

        ConvertLeadAction.ConvertLeadActionResult result = results[0];

        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId ] );
        System.assertEquals( 1, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );

    }

    @isTest
    static void test_convert_lead_no_opportunity() {

        Account acct = new Account(
            name = 'Salesforce'
        );

        insert acct;

        Contact cont = new Contact(
            accountId = acct.id,
            firstName = 'Marc',
            lastName = 'Benioff'
        );

        insert cont;

        Lead ld = new Lead(
            firstName = 'Marc',
            lastName = 'Benioff',
            company = 'Salesforce',
            Account__c = acct.Id
        );

        insert ld;

        Test.startTest();

        ConvertLeadAction.ConvertLeadActionRequest request = new ConvertLeadAction.ConvertLeadActionRequest();
        request.leadId = ld.id;
        request.convertedStatus = [ SELECT id, ApiName FROM LeadStatus WHERE isConverted = true LIMIT 1 ].ApiName;
        request.createOpportunity = false;
        request.accountId = acct.id;
        request.contactId = cont.id;
        request.overwriteLeadSource = true;

        List<ConvertLeadAction.ConvertLeadActionResult> results = ConvertLeadAction.convertLeads( new List<ConvertLeadAction.ConvertLeadActionRequest>{ request } );

        Test.stopTest();

        System.assert( results != null );
        System.assertEquals( 1, results.size() );

        ConvertLeadAction.ConvertLeadActionResult result = results[0];

        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId AND id = :acct.id ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId AND id = :cont.id ] );
        System.assertEquals( 0, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );

    }
}