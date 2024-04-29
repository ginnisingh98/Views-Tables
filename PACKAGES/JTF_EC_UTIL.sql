--------------------------------------------------------
--  DDL for Package JTF_EC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EC_UTIL" AUTHID CURRENT_USER as
/* $Header: jtfvecus.pls 120.1 2005/07/02 01:39:45 appldev ship $ */
/*#
 * This is the private interface to the JTF Escalation Management.
 * This utility Interface is used for all validation and conversion
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Escalation Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_ESCALATION
*/

-- Start of comments
--	API name 	: JTF_EC_UTIL
--	Type		: Private.
--	Function	: Escalation utility package
--	Pre-reqs	: None.
--	Parameters	:
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version         	IN	NUMBER	  required
--      p_init_msg_list       	IN	VARCHAR2  optional  DEFAULT fnd_api.g_false
--      p_commit              	IN	VARCHAR2  optional  DEFAULT fnd_api.g_false
--      x_return_status       	OUT     VARCHAR2  required
--      x_msg_count           	OUT     NUMBER	  required
--      x_msg_data            	OUT     VARCHAR2  required
--	x_wf_process_id		OUT	NUMBER    required
--
--	Version	:	1.0
--
---------------------------------------------------------------------------------
--
-- End of comments

G_PKG_NAME   		CONSTANT VARCHAR2(30) := 'JTF_EC_UTIL';


/*#
* Validates a Owner
*
* @param p_owner_id the owner id
* @param p_owner_type the owner type
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Owner
* @rep:compatibility S
*/
PROCEDURE Validate_Owner(p_owner_id IN NUMBER,
			 p_owner_type IN VARCHAR2,
			 x_return_status OUT NOCOPY  VARCHAR2);

/*#
* Validates a Requester
*
* @param p_escalation_id the escalation id
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Requester
* @rep:compatibility S
*/
PROCEDURE Validate_Requester(p_escalation_id IN	NUMBER,
			     x_return_status OUT NOCOPY  VARCHAR2);

/*#
* Adds the invalid argument message
*
* @param p_token_api_name the API name for which the message token is passed
* @param p_token_value the message for the token
* @param p_token_parameter the token name
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Add Invalid Argument Message
* @rep:compatibility S
*/
PROCEDURE Add_Invalid_Argument_Msg
( p_token_api_name	IN VARCHAR2,
  p_token_value		IN VARCHAR2,
  p_token_parameter	IN VARCHAR2
);


/*#
* Adds message for the ignored parameter
*
* @param p_token_api_name the API name for which the message token is passed
* @param p_token_ignored_param the ignored token name
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Add Ignored Parameter Message
* @rep:compatibility S
*/
PROCEDURE Add_Param_Ignored_Msg
( p_token_api_name		VARCHAR2,
  p_token_ignored_param		VARCHAR2
);

----------------------------------------------------------------------------------------
-- Add missing parameter procedure
----------------------------------------------------------------------------------------

/*#
* Adds missing parameter
*
* @param p_token_api_name the API name for which the message token is passed
* @param p_token_miss_param the missing parameter
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Add Missing Parameter
* @rep:compatibility S
*/
PROCEDURE Add_Missing_Param_Msg
( p_token_api_name		VARCHAR2,
  p_token_miss_param		VARCHAR2
);

/*#
* Validate the Escalation Status
*
* @param p_esc_status_id the escalation status id
* @param p_esc_status_name the escalation status name
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_esc_status_id the escalation status id
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Escalation Status
* @rep:compatibility S
*/
PROCEDURE Validate_Esc_Status (
        p_esc_status_id          IN       NUMBER,
        p_esc_status_name        IN       VARCHAR2,
        x_return_status          OUT NOCOPY       VARCHAR2,
        x_esc_status_id         OUT NOCOPY       NUMBER
    );


/*#
* Validate Lookup
*
* @param p_lookup_type the lookup type
* @param p_lookup_code the lookup code
* @return the boolean value of validation on Lookup
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Lookup
* @rep:compatibility S
*/
FUNCTION Validate_Lookup(p_lookup_type        IN VARCHAR2 ,
        		 p_lookup_code        IN VARCHAR2
        		 ) RETURN BOOLEAN;

/*#
* Checks if escalated
*
* @param p_object_type_code the object type code
* @param p_object_id the object id
* @param p_object_name the object name
* @param x_task_ref_id the parameter that returns task reference id
* @return the boolean value if escalated
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check If Escalated
* @rep:compatibility S
*/
FUNCTION  Check_If_Escalated (p_object_type_code IN VARCHAR2,
                              p_object_id IN NUMBER,
			      p_object_name IN VARCHAR2,
			      x_task_ref_id OUT NOCOPY  NUMBER) RETURN BOOLEAN;

/*#
* Checks if the reference is duplicated
*
* @param p_object_type_code the object type code
* @param p_object_id the object id
* @param p_object_name the object name
* @param p_reference_code the reference code
* @param p_escalation_id the escalation id
* @return the boolean value in context of reference is duplicated
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Duplicate Reference
* @rep:compatibility S
*/
FUNCTION  Reference_Duplicated (p_object_type_code IN VARCHAR2,
                               p_object_id IN NUMBER,
			       p_object_name IN VARCHAR2,
			       p_reference_code IN VARCHAR2,
			       p_escalation_id IN NUMBER) RETURN BOOLEAN;


/*#
* Checks if the contact is duplicated
*
* @param p_contact_id the contact id
* @param p_contact_type_code the contact type code
* @param p_escalation_id the escalation id
* @return the boolean value in context of contact is duplicated
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Duplicate Contact
* @rep:compatibility S
*/
FUNCTION Contact_Duplicated(p_contact_id IN NUMBER,
			    p_contact_type_code IN VARCHAR2,
			    p_escalation_id IN NUMBER) RETURN BOOLEAN;

/*#
* Validates the descriptive flex field items
*
* @param p_api_name the API name
* @param p_application_short_name the application short name
* @param p_desc_flex_name the name of the flex fields
* @param p_desc_segment1 the value of the flex field attribute1
* @param p_desc_segment2 the value of the flex field attribute2
* @param p_desc_segment3 the value of the flex field attribute3
* @param p_desc_segment4 the value of the flex field attribute4
* @param p_desc_segment5 the value of the flex field attribute5
* @param p_desc_segment6 the value of the flex field attribute6
* @param p_desc_segment7 the value of the flex field attribute7
* @param p_desc_segment8 the value of the flex field attribute8
* @param p_desc_segment9 the value of the flex field attribute9
* @param p_desc_segment10 the value of the flex field attribute10
* @param p_desc_segment11 the value of the flex field attribute11
* @param p_desc_segment12 the value of the flex field attribute12
* @param p_desc_segment13 the value of the flex field attribute13
* @param p_desc_segment14 the value of the flex field attribute14
* @param p_desc_segment15 the value of the flex field attribute15
* @param p_desc_context the value of the flex field attribute category
* @param p_resp_appl_id the responsibility application id
* @param p_resp_id the responsibility id
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Descriptive FlexFields
* @rep:compatibility S
*/
PROCEDURE Validate_Desc_Flex
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_desc_flex_name		IN	VARCHAR2,
  p_desc_segment1		IN	VARCHAR2,
  p_desc_segment2		IN	VARCHAR2,
  p_desc_segment3		IN	VARCHAR2,
  p_desc_segment4		IN	VARCHAR2,
  p_desc_segment5		IN	VARCHAR2,
  p_desc_segment6		IN	VARCHAR2,
  p_desc_segment7		IN	VARCHAR2,
  p_desc_segment8		IN	VARCHAR2,
  p_desc_segment9		IN	VARCHAR2,
  p_desc_segment10		IN	VARCHAR2,
  p_desc_segment11		IN	VARCHAR2,
  p_desc_segment12		IN	VARCHAR2,
  p_desc_segment13		IN	VARCHAR2,
  p_desc_segment14		IN	VARCHAR2,
  p_desc_segment15		IN	VARCHAR2,
  p_desc_context		IN	VARCHAR2,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  x_return_status		OUT NOCOPY 	VARCHAR2
);

/*#
* Validate the Escalation document
*
* @param p_esc_id the escalation id
* @param p_esc_number the escalation number
* @param x_esc_id the parameter that returns the escalation id
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Escalation Document
* @rep:compatibility S
*/
PROCEDURE Validate_Esc_Document(p_esc_id 	IN NUMBER,
				p_esc_number 	IN VARCHAR2,
				x_esc_id	OUT NOCOPY  NUMBER,
				x_return_status	OUT NOCOPY  VARCHAR2);


/*#
* Checks for the completed status of the escalation
*
* @param p_status_id the status id of the escalation
* @param p_esc_id the escalation id
* @param p_esc_level the escalation level
* @param x_closed_flag the parameter that returns value for the completed status
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Check Completed Status
* @rep:compatibility S
*/
PROCEDURE Check_Completed_Status(p_status_id	IN 	NUMBER,
				 p_esc_id	IN	NUMBER,
				 p_esc_level	IN	VARCHAR2,
				 x_closed_flag	OUT NOCOPY 	VARCHAR2,
			     	 x_return_status	OUT NOCOPY 	VARCHAR2);

/*#
* Converts a missed number
*
* @param p_number the number value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Missed Number
* @rep:compatibility S
*/
PROCEDURE Conv_Miss_Num(p_number IN OUT NOCOPY  NUMBER);

/*#
* Converts a missed date
*
* @param p_date the date value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Missed Date
* @rep:compatibility S
*/
PROCEDURE Conv_Miss_Date(p_date IN OUT NOCOPY  DATE);

/*#
* Converts a missed char
*
* @param p_char the date value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Convert Missed Character
* @rep:compatibility S
*/
PROCEDURE Conv_Miss_Char(p_char IN OUT NOCOPY  VARCHAR2);

/*#
* Validates the Task Phone ID
*
* @param p_task_phone_id the task phone ID
* @param p_escalation_id the escalation ID
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Task Phone ID
* @rep:compatibility S
*/
PROCEDURE Validate_Task_Phone_Id(p_task_phone_id IN NUMBER,
		    	         p_escalation_id IN NUMBER,
		    	         x_return_status OUT NOCOPY  VARCHAR2);

/*#
* Validates the Task Contact ID
*
* @param p_task_contact_id the task contact ID
* @param p_escalation_id the escalation ID
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Task Contact ID
* @rep:compatibility S
*/
PROCEDURE Validate_Task_Contact_Id(p_task_contact_id IN NUMBER,
		    	      	   p_escalation_id IN NUMBER,
		    	           x_return_status OUT NOCOPY  VARCHAR2);

/*#
* Validates the Contact ID
*
* @param p_contact_id the contact ID
* @param p_contact_type_code the contact type code
* @param p_escalation_id the escalation ID
* @param x_task_contact_id the parameter that returns the task contact ID
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Contact ID
* @rep:compatibility S
*/
PROCEDURE Validate_Contact_Id( 	p_contact_id 		IN NUMBER,
				p_contact_type_code 	IN VARCHAR2,
		    	      	p_escalation_id 	IN NUMBER,
				x_task_contact_id	OUT NOCOPY  NUMBER,
				x_return_status 	OUT NOCOPY  VARCHAR2);

/*#
* Validates the Task Reference ID
*
* @param p_task_reference_id the task reference ID
* @param p_escalation_id the escalation ID
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Task Reference ID
* @rep:compatibility S
*/
PROCEDURE Validate_Task_Reference_Id(p_task_reference_id IN NUMBER,
		    	      	     p_escalation_id IN NUMBER,
		    	             x_return_status OUT NOCOPY  VARCHAR2);

/*#
* Validates the WHO column information
*
* @param p_api_name the API name
* @param p_user_id the user id
* @param p_login_id the login id
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Who Information
* @rep:compatibility S
*/
PROCEDURE Validate_Who_Info(	p_api_name	IN  	VARCHAR2,
				p_user_id	IN  	NUMBER,
				p_login_id	IN  	NUMBER,
				x_return_status	OUT NOCOPY   	VARCHAR2
  				);

/*#
* Validates the Note ID
*
* @param p_note_id the note id
* @param p_escalation_id the escalation id
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Validate Note ID
* @rep:compatibility S
*/
PROCEDURE Validate_Note_Id(p_note_id IN NUMBER,
		    	   p_escalation_id IN NUMBER,
		    	   x_return_status OUT NOCOPY  VARCHAR2);

/*#
* Gets the requester name
*
* @param p_escalation_id the escalation id
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @return the requester name
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get Requester Name
* @rep:compatibility S
*/
FUNCTION Get_Requester_Name(p_escalation_id in NUMBER) RETURN VARCHAR2;

END JTF_EC_UTIL;

 

/
