/**********************************************************************
 * @name: AttachmentUpload
 * @author: David Perez
 * @date: 01/18/2017
 * @url: /services/apex/soapAPI
 * @data:
 *  {
       standard Attachment 
    }
*************************************************************************/
global with sharing class AttachmentUploadController {
 
 	public AttachmentUploadController(){

 	}

	public Attachment attachment {
	get {
	  if (attachment == null)
	    attachment = new Attachment();
	  return attachment;
	}
	set;
	}

	webservice static void uploadAttachment(String externalID, Blob content, String name){    
		
		//retrieve the ExternalID of Billing records
		List<Attachment> attachments = new List<Attachment>();

		Billing__c billing = [select Id, External_Id__c from Billing__c where External_Id__c =: externalID];
		
		attachments = [SELECT Body,BodyLength,ContentType,Id,Name,ParentId FROM Attachment WHERE ParentId =: billing.Id AND Name =: name];
		
		if(!(attachments.size() > 1)){
			//Blob body = Blob.valueOf(content);
			//Blob body = Blob.valueOf(httpResponse.getBody());
			Attachment attachment = new Attachment(); 
			attachment.Name = name;
			attachment.OwnerId = UserInfo.getUserId();
			attachment.Body = content; //not content needed
			//attachment.Body = httpResponse.getBodyAsBlob();
			attachment.ParentId = billing.Id; // the record the file is attached to, You may need to do a query to get your parent recordid</font></strong>
			try {
					insert attachment;
			} catch (DMLException e) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
			}
		}	
	}
}