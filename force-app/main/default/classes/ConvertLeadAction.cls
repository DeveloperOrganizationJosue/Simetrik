/**
* @author Clouder
* @description Utility class for Lead Convertion action.
* @date 07/30/2022
* @group Actions
* Version
* ---------------------------------------------------------------------------------------------------
* No.   Date        Author                  Description
* ---   -----       -------                 ---------------------------------------------------------
* 1.0   07/30/2022  Clouder                 Class creation
*/
global class ConvertLeadAction {
    /**
    * @description Converts a lead based on the parameters received.
    * @param requests List of lead convertion parameters
    * @return List<ConvertLeadActionResult> List of convertion results
    */
    @InvocableMethod(   label='Convert Lead'
                        description='Converts a lead based on the parameters received'
                        category='Lead' )
    global static List<ConvertLeadActionResult> convertLeads(List<ConvertLeadActionRequest> requests) {
      List<ConvertLeadActionResult> results = new List<ConvertLeadActionResult>();
      for (ConvertLeadActionRequest request : requests) {
        results.add(convertLead(request));
      }
      return results;
    }
  
    public static ConvertLeadActionResult convertLead(ConvertLeadActionRequest request) {
      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(request.leadId);
      lc.setConvertedStatus(request.convertedStatus);
  
      if (request.accountId != null) {
          lc.setAccountId(request.accountId);
      }
  
      if (request.contactId != null) {
        lc.setContactId(request.contactId);
      }
  
      if (request.overWriteLeadSource != null && request.overWriteLeadSource) {
        lc.setOverwriteLeadSource(request.overWriteLeadSource);
      }
  
      if (request.createOpportunity != null && !request.createOpportunity) {
        lc.setDoNotCreateOpportunity(!request.createOpportunity);
      }
  
      if (request.opportunityName != null && ( request.createOpportunity == null || request.createOpportunity ) ){
        lc.setOpportunityName(request.opportunityName);
      }
  
      if (request.ownerId != null) {
        lc.setOwnerId(request.ownerId);
      }
  
      if (request.sendEmailToOwner != null && request.sendEmailToOwner) {
        lc.setSendNotificationEmail(request.sendEmailToOwner);
      }
  
      Database.LeadConvertResult lcr = Database.convertLead(lc, true);
      if (lcr.isSuccess()) {
        ConvertLeadActionResult result = new ConvertLeadActionResult();
        result.accountId = lcr.getAccountId();
        result.contactId = lcr.getContactId();
        result.opportunityId = lcr.getOpportunityId();
        return result;
      } else {
        throw new ConvertLeadActionException(lcr.getErrors()[0].getMessage());
      }
    }
  
    global class ConvertLeadActionRequest {
      @InvocableVariable(required=true)
      global ID leadId;
  
      @InvocableVariable(required=true)
      global String convertedStatus;
  
      @InvocableVariable
      global ID accountId;
  
      @InvocableVariable
      global ID contactId;
  
      @InvocableVariable
      global Boolean overWriteLeadSource;
  
      @InvocableVariable
      global Boolean createOpportunity;
  
      @InvocableVariable
      global String opportunityName;
  
      @InvocableVariable
      global ID ownerId;
  
      @InvocableVariable
      global Boolean sendEmailToOwner;
    }
  
    global class ConvertLeadActionResult {
      @InvocableVariable
      global ID accountId;
  
      @InvocableVariable
      global ID contactId;
  
      @InvocableVariable
      global ID opportunityId;
    }
  
    class ConvertLeadActionException extends Exception {}
  }