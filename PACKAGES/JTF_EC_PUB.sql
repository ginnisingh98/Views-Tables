--------------------------------------------------------
--  DDL for Package JTF_EC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EC_PUB" AUTHID CURRENT_USER as
/* $Header: jtfpecs.pls 120.5 2006/06/28 10:40:45 mpadhiar ship $ */
/*#
 * A public interface that can be used to create and update escalations for various business entities such as Service Request, Task, Customer etc.
 *
 * @rep:scope public
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Escalation Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_ESCALATION
 * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
*/

G_PKG_NAME   			CONSTANT VARCHAR2(30) := 'JTF_EC_PUB';
g_escalation_type_id           	CONSTANT NUMBER       := 22;
g_escalation_owner_type_code   	CONSTANT VARCHAR2(30) := 'RS_EMPLOYEE';
g_escalation_code              	CONSTANT VARCHAR2(30) := 'ESC';
g_escalation_name		CONSTANT VARCHAR2(30) := 'Escalation Document';
--------------------------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Esc_Rec_Type
--  Description     : Holds the escalation header attributes for creating record in
--		      JTF_TASKS table.
--  Fields     :
--      name                 type     required?      description
--      ----                 ----     ---------	    --------------
--    esc_name        	  VARCHAR2    required	   Name of the escalation. If no specific name
-- 		is entered the parameter is defaulted to g_escalation_name.
--   esc_description      VARCHAR2    optional	   Summary of the escalation.
--   status_name	  VARCHAR2    optional	   Escalation status. Valid values are
--		'Open','Closed' etc. - all of the valid values from jtf_ec_statuses_vl
--   status_id		  NUMBER      optional     It is required the Escalation document to
--		have status. If status_id or name are not passed then the value is defaulted from
--		profile Escalation: Default Status
--  esc_open_date	  DATE 	      optional	   If not enterde defaulted to sysdate
--  esc_owner_id	  NUMBER      required	   The escalation owner is of type RS_EMPLOYEE
-- 		Valid values are resource_ids from jtf_rs_emp_dtls_vl
--  customer_id		  NUMBER      optional     Valid values are party_ids from hz_parties
--		and party_type 'ORGANIZATION', 'PERSON'
--  customer_number	  VARCHAR2    optional	   party_number from hz_parties and party_type
--		'ORGANIZATION', 'PERSON'
--  cust_account_id	  NUMBER      optional	   Valid values are account_ids from hz_cust_accounts
--  cust_account_number   VARCHAR2    optional     Valid values are account_numbers from hz_cust_accounts
--  cust_address_id       NUMBER      optional	   Valid values are party_site_ids from hz_party_sites
--  esc_target_date       DATE	      optional	   Date when the escalation should be resolved.
--  reason_code		  VARCHAR2    optional	   Valid values are all active values for
-- 		lookup_type JTF_TASK_REASON_CODES, FND_LOOKUPS. When it is not passed it is defaulted to
--		profile Escalation:Default Reason Code
--  escalation_level	  VARCHAR2    optional     Valid values are all active values for
-- 		lookup_type JTF_TASK_ESC_LEVEL, FND_LOOKUPS. When it is not passed it is defaulted to
--		profile Escalation:Default Escalation Level
-- attribute1..attribute15	VARCHAR2    optional	Flex field attribute columns
--							for descriptive flexfield support
-- attribute_category	 VARCHAR2     optional	   Category column for descriptive flexfield support
--------------------------------------------------------------------------------------------

TYPE Esc_Rec_Type IS RECORD (
	esc_name 		jtf_tasks_tl.task_name%TYPE 	:= FND_API.G_MISS_CHAR,
	esc_description		jtf_tasks_tl.description%TYPE	:= FND_API.G_MISS_CHAR,
	status_name		jtf_task_statuses_tl.name%TYPE	:= FND_API.G_MISS_CHAR,
	status_id		jtf_task_statuses_b.task_status_id%TYPE := FND_API.G_MISS_NUM,
	esc_open_date		jtf_tasks_b.actual_start_date%TYPE	:= FND_API.G_MISS_DATE,
--	esc_close_date		jtf_tasks_b.actual_end_date%TYPE	:= FND_API.G_MISS_DATE,
	esc_owner_id		jtf_tasks_b.owner_id%TYPE		:= FND_API.G_MISS_NUM,
--bug 2723761
	esc_owner_type_code	jtf_tasks_b.owner_type_code%TYPE	:= FND_API.G_MISS_CHAR,
--	esc_territory_id	jtf_tasks_b.owner_territory_id%TYPE	:= FND_API.G_MISS_NUM,
	customer_id		jtf_tasks_b.customer_id%TYPE		:= FND_API.G_MISS_NUM,
	customer_number		hz_parties.party_number%TYPE	 	:= FND_API.G_MISS_CHAR,
	cust_account_id		jtf_tasks_b.cust_account_id%TYPE	:= FND_API.G_MISS_NUM,
	cust_account_number	hz_cust_accounts.account_number%TYPE	:= FND_API.G_MISS_CHAR,
	cust_address_id		jtf_tasks_b.address_id%TYPE		:= FND_API.G_MISS_NUM,
	cust_address_number	hz_party_sites.party_site_number%TYPE	:= FND_API.G_MISS_CHAR,
	esc_target_date		jtf_tasks_b.planned_end_date%TYPE	:= FND_API.G_MISS_DATE,
	reason_code		jtf_tasks_b.reason_code%TYPE		:= FND_API.G_MISS_CHAR,
	escalation_level	jtf_tasks_b.escalation_level%TYPE	:= FND_API.G_MISS_CHAR,
      	attribute1            	jtf_tasks_b.attribute1%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute2              jtf_tasks_b.attribute2%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute3              jtf_tasks_b.attribute3%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute4              jtf_tasks_b.attribute4%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute5              jtf_tasks_b.attribute5%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute6              jtf_tasks_b.attribute6%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute7              jtf_tasks_b.attribute7%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute8              jtf_tasks_b.attribute8%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute9              jtf_tasks_b.attribute9%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute10             jtf_tasks_b.attribute10%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute11             jtf_tasks_b.attribute11%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute12             jtf_tasks_b.attribute12%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute13             jtf_tasks_b.attribute13%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute14             jtf_tasks_b.attribute14%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute15             jtf_tasks_b.attribute15%TYPE	:= FND_API.G_MISS_CHAR,
      	attribute_category      jtf_tasks_b.attribute_category%TYPE 	:= FND_API.G_MISS_CHAR
	);

--------------------------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Esc_Ref_Docs_Rec_Type
--  Description     : Holds the details about the reference documents in the escalation. The document
--		      could be  'Escalated' (reference code 'ESC' - seeded value), or any custom reference
-- 		      type eg 'For your information'. The data is stored in JTF_TASK_REFERENCES table.
--  Fields     :
--      name              type     required?      description
--      ----              ----     ---------	  --------------
--  reference_id	NUMBER     required	Valid values are jtf_task_references_b.task_reference_id
--  object_type_code    VARCHAR2   required	Valid values are jtf_objects_vl.object_code. The objects/
--  			modules	that would like to use the Escalation module need to register the usage
--			of the Escalation Module in jtf_object_usages. Seeded values are 'SR', 'TASK', 'DF'
--  object_name		VARCHAR2   required	Valid values are the values of the column registered in
--			jtf_objects_vl.select_name for the particular object_type_code
--  object_id		NUMBER     required	Valid values are the values of the column registered in
--			jtf_objects_vl.select_id for the particular object_type_code
--  reference_code	VARCHAR2   required	Valid values are 'ESC', 'FYI' or any other custom code
-- 			entered in FND_LOOKUPS, lookup type JTF_TASK_REFERENCE_CODES
--  object_version_number NUMBER    required for update/delete reference document. object_version_number from
--		jtf_task_refernces for the updated/deleted record.
--  action_code		VARCHAR2   required	Valid values are 'I' insert reference document,
--						'U' - update reference document, 'D' - delete reference document
--  attribute1..attribute15 VARCHAR2    optional	Flex field attribute columns
--						for descriptive flexfield support
--  attribute_category	 VARCHAR2     optional	Category column for descriptive flexfield support
-------------------------------------------------------------------------------------------------------

TYPE Esc_Ref_Docs_Rec_Type IS RECORD (
	reference_id		jtf_task_references_b.task_reference_id%TYPE	:= FND_API.G_MISS_NUM,
	object_type_code	jtf_task_references_b.object_type_code%TYPE	:= FND_API.G_MISS_CHAR,
	object_name		jtf_task_references_b.object_name%TYPE		:= FND_API.G_MISS_CHAR,
	object_id		jtf_task_references_b.object_id%TYPE		:= FND_API.G_MISS_NUM,
--	object_details		jtf_task_references_b.object_details%TYPE	:= FND_API.G_MISS_CHAR,
--	usage			jtf_task_references_tl.usage%TYPE		:= FND_API.G_MISS_CHAR,
	reference_code		jtf_task_references_b.reference_code%TYPE	:= FND_API.G_MISS_CHAR,
	object_version_number	jtf_task_references_b.object_version_number%TYPE	:= FND_API.G_MISS_NUM,
	action_code		varchar2(1),
      	attribute1            	jtf_tasks_b.attribute1%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute2              jtf_tasks_b.attribute2%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute3              jtf_tasks_b.attribute3%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute4              jtf_tasks_b.attribute4%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute5              jtf_tasks_b.attribute5%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute6              jtf_tasks_b.attribute6%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute7              jtf_tasks_b.attribute7%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute8              jtf_tasks_b.attribute8%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute9              jtf_tasks_b.attribute9%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute10             jtf_tasks_b.attribute10%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute11             jtf_tasks_b.attribute11%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute12             jtf_tasks_b.attribute12%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute13             jtf_tasks_b.attribute13%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute14             jtf_tasks_b.attribute14%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute15             jtf_tasks_b.attribute15%TYPE	:= FND_API.G_MISS_CHAR,
      	attribute_category      jtf_tasks_b.attribute_category%TYPE	:= FND_API.G_MISS_CHAR
	);

TYPE Esc_Ref_Docs_Tbl_Type is TABLE of Esc_Ref_Docs_Rec_Type INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Esc_Contacts_Rec_Type
--  Description     : Holds the escalation contacts attributes for creating a record in
--		      JTF_TASK_CONTACTS table.
--                    Creating records in JTF_NOTES_B
--  Fields     :
--      name              type     required?      description
--      ----              ----     ---------	  --------------
--  contact_id		NUMBER      required	Valid values are employee_id from per_employees_current_x
-- 		when the contact_type = 'EMP' or subject_party_id from jtf_party_all_contacts_v
-- 		where object_party_id = customer_id
--  task_contact_id     NUMBER	    required for update/delete_escalation. task_contact_id from
--		jtf_task_contacts
--  object_version_number NUMBER    required for update/delete_escalation. object_version_number from
--		jtf_task_contacts of the updated/deleted record.
--  contact_type_code  	VARCHAR2    required  for create_escalation. Valid values are 'EMP', 'CUST'
--  escalation_notify_flag VARCHAR2 optional	Specify whether notifications will be sent to the contact.
--		Valid values are 'Y' or 'N'.
--  escalation_requester_flag VARCHAR2 required There must be one and only one contact per escalation
--  		which has escalation_requester_flag set to 'Y'. Valid values are 'Y' or 'N'.
--  action_code		VARCHAR2     required	Valid values are 'I' insert contact,
--						'U' - update contact, 'D' - delete contact
--  attribute1..attribute15	VARCHAR2    optional	Flex field attribute columns
--							for descriptive flexfield support.
--  attribute_category	 VARCHAR2     optional	   Category column for descriptive flexfield support
--------------------------------------------------------------------------------------------

 TYPE Esc_Contacts_Rec_Type IS RECORD (
	contact_id			jtf_task_contacts.contact_id%TYPE		:=FND_API.G_MISS_NUM,
	task_contact_id			jtf_task_contacts.task_contact_id%TYPE		:=FND_API.G_MISS_NUM,
	object_version_number		jtf_task_contacts.object_version_number%TYPE	:=FND_API.G_MISS_NUM,
	contact_type_code   		jtf_task_contacts.contact_type_code%TYPE 	:=FND_API.G_MISS_CHAR,
	escalation_notify_flag		jtf_task_contacts.escalation_notify_flag%TYPE	:=FND_API.G_MISS_CHAR,
	escalation_requester_flag	jtf_task_contacts.escalation_requester_flag%TYPE :=FND_API.G_MISS_CHAR,
	action_code			varchar2(1),
      	attribute1            	jtf_tasks_b.attribute1%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute2              jtf_tasks_b.attribute2%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute3              jtf_tasks_b.attribute3%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute4              jtf_tasks_b.attribute4%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute5              jtf_tasks_b.attribute5%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute6              jtf_tasks_b.attribute6%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute7              jtf_tasks_b.attribute7%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute8              jtf_tasks_b.attribute8%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute9              jtf_tasks_b.attribute9%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute10             jtf_tasks_b.attribute10%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute11             jtf_tasks_b.attribute11%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute12             jtf_tasks_b.attribute12%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute13             jtf_tasks_b.attribute13%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute14             jtf_tasks_b.attribute14%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute15             jtf_tasks_b.attribute15%TYPE	:= FND_API.G_MISS_CHAR,
      	attribute_category      jtf_tasks_b.attribute_category%TYPE	:= FND_API.G_MISS_CHAR
	);

TYPE Esc_Contacts_Tbl_Type is TABLE of Esc_Contacts_Rec_Type INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Esc_Cont_Points_Rec_Type
--  Description     : Holds the escalation header attributes for creating record in
--		      JTF_TASK_PHONES table.
--  Fields     :
--      name                 type     required?      description
--      ----                 ----     ---------	    --------------
--  contact_id		NUMBER      required	Valid values are employee_id from per_employees_current_x
-- 		when the contact_type = 'EMP' or subject_party_id from jtf_party_all_contacts_v
-- 		where object_party_id = customer_id
--  contact_type_code  	VARCHAR2    required  for create_escalation. Valid values are 'EMP', 'CUST'
--  contact_point_id	NUMBER      required    Valid values are contact_point_id from hz_contact_points
--  task_phone_id	NUMBER	    required    for update/delete_escalation. Valid values are task_phone_id
--						from jtf_task_phones
--  object_version_number NUMBER    required for update/delete_escalation. object_version_number from
--		jtf_task_phones of the updated/deleted record.
--  action_code		VARCHAR2     required	Valid values are 'I' insert contact,
--						'U' - update contact, 'D' - delete contact
--  attribute1..attribute15	VARCHAR2    optional	Flex field attribute columns
--							for descriptive flexfield support.
--  attribute_category	 VARCHAR2     optional	   Category column for descriptive flexfield support
--------------------------------------------------------------------------------------------

TYPE Esc_Cont_Points_Rec_Type IS RECORD (
	contact_id		jtf_task_contacts.contact_id%TYPE		:= FND_API.G_MISS_NUM,
	contact_type_code   	jtf_task_contacts.contact_type_code%TYPE 	:= FND_API.G_MISS_CHAR,
	contact_point_id	jtf_task_phones.phone_id%TYPE			:= FND_API.G_MISS_NUM,
	task_phone_id		jtf_task_phones.task_phone_id%TYPE		:= FND_API.G_MISS_NUM,
	object_version_number	jtf_task_phones.object_version_number%TYPE	:= FND_API.G_MISS_NUM,
	action_code		varchar2(1),
      	attribute1            	jtf_tasks_b.attribute1%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute2              jtf_tasks_b.attribute2%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute3              jtf_tasks_b.attribute3%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute4              jtf_tasks_b.attribute4%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute5              jtf_tasks_b.attribute5%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute6              jtf_tasks_b.attribute6%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute7              jtf_tasks_b.attribute7%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute8              jtf_tasks_b.attribute8%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute9              jtf_tasks_b.attribute9%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute10             jtf_tasks_b.attribute10%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute11             jtf_tasks_b.attribute11%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute12             jtf_tasks_b.attribute12%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute13             jtf_tasks_b.attribute13%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute14             jtf_tasks_b.attribute14%TYPE 	:= FND_API.G_MISS_CHAR,
      	attribute15             jtf_tasks_b.attribute15%TYPE	:= FND_API.G_MISS_CHAR,
      	attribute_category      jtf_tasks_b.attribute_category%TYPE	:= FND_API.G_MISS_CHAR
	);

TYPE Esc_Cont_Points_Tbl_Type is TABLE of Esc_Cont_Points_Rec_Type INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Notes_Rec_Type
--  Description     : Holds the notes attributes for creating record in
--		      JTF_NOTES_B table.
--  Fields     :
--      name                 type     required?      description
--      ----                 ----     ---------	    --------------
--  action_code		VARCHAR2     required	Valid values are 'I' insert contact,
--						'U' - update contact, 'D' - delete contact
--  note_id		NUMBER	     required   for update. A valid value is jtf_notes.jtf_note_id
--  note		VARCHAR2     optional   Free text.
--  note_detail		VARCHAR2     optional   Free text.
--  note_type		VARCHAR2     optional
--  note_status		VARCHAR2     optional   'I' if not passed.
--  note_context_type_01  VARCHAR2   optional
--  note_context_type_id_01 NUMBER   optional
--  note_context_type_02  VARCHAR2   optional
--  note_context_type_id_02 NUMBER   optional
--  note_context_type_03  VARCHAR2   optional
--  note_context_type_id_03 NUMBER   optional
--------------------------------------------------------------------------------------------

TYPE Notes_Rec_Type IS RECORD (
    action_code			varchar2(1),
    note_id			NUMBER		:= FND_API.G_MISS_NUM,
    note			VARCHAR2(2000)	:= FND_API.G_MISS_CHAR,
    note_detail			VARCHAR2(32767)	:= FND_API.G_MISS_CHAR,
    note_type			VARCHAR2(240)	:= FND_API.G_MISS_CHAR,
    note_status			VARCHAR2(1)	:= FND_API.G_MISS_CHAR,
    note_context_type_01	VARCHAR2(240)	:= FND_API.G_MISS_CHAR,
    note_context_type_id_01	NUMBER		:= FND_API.G_MISS_NUM,
    note_context_type_02	VARCHAR2(240)	:= FND_API.G_MISS_CHAR,
    note_context_type_id_02	NUMBER		:= FND_API.G_MISS_NUM,
    note_context_type_03 	VARCHAR2(240)	:= FND_API.G_MISS_CHAR,
    note_context_type_id_03 	NUMBER		:= FND_API.G_MISS_NUM
);

TYPE Notes_Tbl_Type IS TABLE OF Notes_Rec_Type INDEX BY BINARY_INTEGER;

g_miss_esc_ref_docs_tbl		Esc_Ref_Docs_Tbl_Type;
g_miss_esc_contacts_tbl		Esc_Contacts_Tbl_Type;
g_miss_esc_cont_points_tbl	Esc_Cont_Points_Tbl_Type;
g_miss_esc_notes_tbl		Notes_Tbl_Type;

/*#
* Creates an escalation for a specific business entity. Only one open escalation may be maintained for each instance of the business entity.
*
*
* @param p_api_version The standard API version number.
* @param p_init_msg_list The standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit The standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function.
* By default, the commit will not be performed.
* @param x_return_status The parameter that returns the result of all the operations performed
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_count The parameter that returns the number of messages in the FND message list.
* @param x_msg_data The parameter that returns the FND message in encoded format.
* @param p_resp_appl_id	The application id used to get profile value for a specific user/resp/appl combo.
* @param p_resp_id The responsibility id used to get profile value for a specific user/resp/appl combo.
* @param p_user_id The user id used to get profile value for a specific user/resp/appl combo.
* @param p_login_id The login id for record update tracking.
* @param p_esc_id The Escalation ID for the created Escalation.
* @param p_esc_record The Escalation Data (Escalation Record). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_reference_documents The List of Reference Documents (Reference Records). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_esc_contacts	The List of Escalation Contacts (Contact's Records). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_cont_points The List of Phones for the Escalation Contacts (Contact Point Records). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_notes The Notes attached to the Escalation. For details see: Oracle Common Application Calendar - API Reference Guide.
* @param x_esc_id The parameter that returns the Escalation ID for the created Escalation.
* @param x_esc_number The parameter that returns the Escalation Number for the created Escalation.
* @param x_workflow_process_id The parameter that returns the Workflow Process ID for notifications of the Escalation.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Escalation
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
* @rep:category BUSINESS_ENTITY CAC_CAL_TASK
*/
PROCEDURE CREATE_ESCALATION  (
	p_api_version         	IN	NUMBER,
	p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	x_return_status       	OUT NOCOPY     VARCHAR2,
	x_msg_count           	OUT NOCOPY     NUMBER,
	x_msg_data            	OUT NOCOPY     VARCHAR2,
  	p_resp_appl_id		IN      NUMBER	:= NULL,
  	p_resp_id		IN      NUMBER	:= NULL,
  	p_user_id		IN      NUMBER	:= NULL,
  	p_login_id		IN      NUMBER	:= NULL,
	p_esc_id		IN	jtf_tasks_b.task_id%TYPE	:=NULL,
--	p_esc_number		IN	jtf_tasks_b.task_number%TYPE	:=NULL,
	p_esc_record		IN	Esc_Rec_Type,
	p_reference_documents	IN	Esc_Ref_Docs_Tbl_Type 		DEFAULT g_miss_esc_ref_docs_tbl,
	p_esc_contacts		IN	Esc_Contacts_Tbl_Type,
	p_cont_points		IN	Esc_Cont_Points_Tbl_Type 	DEFAULT g_miss_esc_cont_points_tbl,
	p_notes			IN	Notes_Tbl_Type 			DEFAULT g_miss_esc_notes_tbl,
	x_esc_id		OUT NOCOPY     NUMBER,
	x_esc_number		OUT NOCOPY	NUMBER,
	x_workflow_process_id	OUT NOCOPY	VARCHAR2);

/*#
* Updates an existing escalation. Only one open escalation may be maintained for each instance of the business entity.
*
* @param p_api_version The standard API version number.
* @param p_init_msg_list The standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit The standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function.
* By default, the commit will not be performed.
* @param x_return_status The parameter that returns the result of all the operations performed
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_count The parameter that returns the number of messages in the FND message list.
* @param x_msg_data The parameter that returns the FND Message in encoded format.
* @param p_resp_appl_id	The application id used to get profile value for a specific user/resp/appl combo.
* @param p_resp_id The responsibility id used to get profile value for a specific user/resp/appl combo.
* @param p_user_id The user id used to Get profile value for a specific user/resp/appl combo.
* @param p_login_id The login id for record update tracking.
* @param p_esc_id The Escalation ID for the created Escalation.
* @param p_esc_number The Escalation Number for the created Escalation.
* @param p_object_version The Object Version Number for the Escalation Record.
* @param p_esc_record The Escalation Data (Escalation Record). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_reference_documents The List of Reference Documents (Reference Records). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_esc_contacts The List of Escalation Contacts (Contacts' Records). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_cont_points The List of Phones for the Escalation Contacts (Contact Point Records). For details see: Oracle Common Application Calendar - API Reference Guide.
* @param p_notes The Notes attached to the Escalation. For details see: Oracle Common Application Calendar - API Reference Guide.
* @param x_object_version_number The parameter that returns the Object Version Number after update.
* @param x_workflow_process_id The parameter that returns the Workflow Process ID for notifications of the Escalation.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Escalation
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
* @rep:category BUSINESS_ENTITY CAC_CAL_TASK
*/
PROCEDURE UPDATE_ESCALATION  (
	p_api_version         	IN	NUMBER,
	p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	x_return_status       	OUT NOCOPY     VARCHAR2,
	x_msg_count           	OUT NOCOPY     NUMBER,
	x_msg_data            	OUT NOCOPY     VARCHAR2,
  	p_resp_appl_id		IN      NUMBER	:= NULL,
  	p_resp_id		IN      NUMBER	:= NULL,
  	p_user_id		IN      NUMBER	:= NULL, -- used for last updated by
  	p_login_id		IN      NUMBER	:= NULL,
	p_esc_id		IN	jtf_tasks_b.task_id%TYPE	:=NULL,
	p_esc_number		IN	jtf_tasks_b.task_number%TYPE	:=NULL,
	p_object_version	IN	NUMBER,
	p_esc_record		IN	Esc_Rec_Type,
	p_reference_documents	IN	Esc_Ref_Docs_Tbl_Type		DEFAULT g_miss_esc_ref_docs_tbl,
	p_esc_contacts		IN	Esc_Contacts_Tbl_Type		DEFAULT g_miss_esc_contacts_tbl,
	p_cont_points		IN	Esc_Cont_Points_Tbl_Type 	DEFAULT g_miss_esc_cont_points_tbl,
	p_notes			IN	Notes_Tbl_Type			DEFAULT g_miss_esc_notes_tbl,
        x_object_version_number OUT NOCOPY	NUMBER,
	x_workflow_process_id	OUT NOCOPY	VARCHAR2);

/*#
* Deletes an Escalation.  Validation on User Hooks and user are done before deletion.
*
* @param p_api_version The standard API version number.
* @param p_init_msg_list The standard API flag allows API callers to request.
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit The standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function.
* By default, the commit will not be performed.
* @param x_return_status The parameter that returns the result of all the operations performed
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_count The parameter that returns the number of messages in the FND message list.
* @param x_msg_data The parameter that returns the FND Message in encoded format.
* @param p_user_id The user id to validate the user.
* @param p_login_id The login id for record delete tracking.
* @param p_esc_id The Escalation ID to be deleted.
* @param p_esc_number The Escalation Number to be deleted.
* @param p_object_version The Object Version Number for the Escalation Record.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Delete Escalation
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
* @rep:category BUSINESS_ENTITY CAC_CAL_TASK
*/
PROCEDURE DELETE_ESCALATION(
	p_api_version         	IN	NUMBER,
	p_init_msg_list       	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	p_commit              	IN	VARCHAR2 DEFAULT fnd_api.g_false,
	x_return_status       	OUT NOCOPY     VARCHAR2,
	x_msg_count           	OUT NOCOPY     NUMBER,
	x_msg_data            	OUT NOCOPY     VARCHAR2,
  	p_user_id		IN      NUMBER,
  	p_login_id		IN      NUMBER		:= NULL,
	p_esc_id		IN	jtf_tasks_b.task_id%TYPE	:= fnd_api.g_miss_num,
	p_esc_number		IN	jtf_tasks_b.task_number%TYPE	:= fnd_api.g_miss_char,
	p_object_version	IN	NUMBER);


END JTF_EC_PUB;


 

/
