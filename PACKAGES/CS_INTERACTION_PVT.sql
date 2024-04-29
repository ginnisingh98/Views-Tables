--------------------------------------------------------
--  DDL for Package CS_INTERACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INTERACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: csvcis.pls 115.0 99/07/16 09:05:13 porting s $ */

/****************************************************************************
 *			   Global constants				    *
 ****************************************************************************/

--  Pre-defined validation level:
--	INT	: Validate attributes specific to Customer Interaction. If
--		  p_validation_level is set to G_VALID_LEVEL_INT, only the
--		  following attributes are not validated:
--			p_user_id, p_login_id, p_org_id, p_customer_id,
--			p_contact_id, p_employee_id

G_VALID_LEVEL_INT CONSTANT NUMBER := 50;

/****************************************************************************
 *			  API Specification				    *
 ****************************************************************************/

-- Start of comments
--  Procedure	: Create_Interaction
--  Type	: Private API
--  Usage	: Creates a customer interaction record in the table
--		  CS_INTERACTIONS
--  Pre-reqs	: None
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level		IN	NUMBER		Optional(1)
--		Default = FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters:
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--
--  Customer Interaction IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional(2)
--		Application identifier
--	p_resp_id			IN	NUMBER		Optional(2)
--		Responsibility identifier
--	p_user_id			IN	NUMBER		Required
--		Corresponds to the column USER_ID in the table FND_USER, and
--		identifies the Oracle Applications user
--	p_login_id			IN	NUMBER		Optional
--		Corresponds to the column LOGIN_ID in the table FND_LOGINS,
--		and identifies the login session
--	p_org_id			IN	NUMBER		Optional
--		Operating unit identifier of this interaction record
--	p_customer_id			IN	NUMBER		Required
--		Corresponds to the column CUSTOMER_ID in the table
--		RA_CUSTOMERS, and identifies the customer who is the subject
--		of this interaction
--	p_contact_id			IN	NUMBER		Optional(3)
--		Corresponds to the column CONTACT_ID in the table RA_CONTACTS,
--		and identifies the contact who interacted on behalf of the
--		customer
--	p_contact_lastname		IN	VARCHAR2(50)	Optional(3)
--		Last name of the contact who interacted on behalf of the
--		customer
--	p_contact_firstname		IN	VARCHAR2(40)	Optional(3)
--		First name of the contact who interacted on behalf of the
--		customer
--	p_phone_area_code		IN	VARCHAR2(10)	Optional(4)
--		Area code of contact's phone number
--	p_phone_number			IN	VARCHAR2(25)	Optional(4)
--		Contact's phone number
--	p_phone_extension		IN	VARCHAR2(20)	Optional(4)
--		Extension of contact's phone number
--	p_fax_area_code			IN	VARCHAR2(10)	Optional(4)
--		Area code of contact's fax number
--	p_fax_number			IN	VARCHAR2(25)	Optional(4)
--		Contact's fax number
--	p_email_address			IN	VARCHAR2(240)	Optional(4)
--		Contact's email address
--	p_interaction_type_code		IN	VARCHAR2(30)	Required
--		Lookup code for interaction type
--	p_interaction_category_code	IN	VARCHAR2(30)	Required
--		Lookup code for interaction category
--	p_interaction_method_code	IN	VARCHAR2(30)	Required
--		Lookup code for interaction method
--	p_interaction_date		IN	DATE		Required
--		Date and time this interaction occurred
--	p_interaction_document_code	IN	VARCHAR2(30)	Optional
--		Lookup code for interaction document type
--	p_source_document_id		IN	NUMBER		Optional(5)
--		Internal identifier of the reference document
--	p_source_document_name		IN	VARCHAR2(80)	Optional(4,5)
--		User-visible identifier of the reference document
--	p_reference_form		IN	VARCHAR2(2000)	Optional(4,5,6)
--		Oracle Applications internal function name of a form and any
--		optional form parameters
--	p_source_document_status	IN	VARCHAR2(80)	Optional(4,5)
--		Status of the reference document
--	p_employee_id			IN	NUMBER		Optional
--		Corresponds to the column PERSON_ID in the table
--		PER_ALL_PEOPLE_F, and identifies the employee who interacted
--		with the customer or contact
--	p_public_flag			IN	VARCHAR2(1)	Optional
--		Indicates whether this interaction is public ('Y') or private
--		('N')
--	p_follow_up_action		IN	VARCHAR2(80)	Optional(4)
--		Follow-up action for this interaction
--	p_notes				IN	VARCHAR2(2000)	Optional(4)
--		Explanations, comments, or claims regarding this interaction
--	p_parent_interaction_id		IN	NUMBER		Optional(7)
--		Identifier of the parent interaction that resulted in this
--		interaction
--		Default = x_interaction_id
--	p_attribute1			IN	VARCHAR2(150)	Optional(8)
--		Customer interaction descriptive flexfield segments 1-15
--	p_attribute2			IN	VARCHAR2(150)	Optional(8)
--	p_attribute3			IN	VARCHAR2(150)	Optional(8)
--	p_attribute4			IN	VARCHAR2(150)	Optional(8)
--	p_attribute5			IN	VARCHAR2(150)	Optional(8)
--	p_attribute6			IN	VARCHAR2(150)	Optional(8)
--	p_attribute7			IN	VARCHAR2(150)	Optional(8)
--	p_attribute8			IN	VARCHAR2(150)	Optional(8)
--	p_attribute9			IN	VARCHAR2(150)	Optional(8)
--	p_attribute10			IN	VARCHAR2(150)	Optional(8)
--	p_attribute11			IN	VARCHAR2(150)	Optional(8)
--	p_attribute12			IN	VARCHAR2(150)	Optional(8)
--	p_attribute13			IN	VARCHAR2(150)	Optional(8)
--	p_attribute14			IN	VARCHAR2(150)	Optional(8)
--	p_attribute15			IN	VARCHAR2(150)	Optional(8)
--	p_attribute_category		IN	VARCHAR2(30)	Optional(8)
--		Descriptive flexfield structure defining column
--
--  Customer Interaction OUT Parameters
--	x_interaction_id		OUT	NUMBER
--		System generated identifier of the customer interaction record
--
--  Version	: Initial version	1.0
--
--  Notes	:
--	(1) The validation level determines which validation steps are
--	    executed and which steps are skipped. Valid values are:
--		FND_API.G_VALID_LEVEL_FULL =>	Perform all validation steps
--		CS_Interaction_GRP.G_VALID_LEVEL_INT =>
--			Skip validation steps for non-Service attributes (see
--			above)
--		FND_API.G_VALID_LEVEL_NONE =>	Perform no validation steps
--	(2) The application ID, responsibility ID, and user ID are used for
--	    validation.
--	(3) You may pass in either a valid contact ID, or you may pass in a
--	    last name and first name if the contact is not in the RA_CONTACTS
--	    table.
--	(4) For value parameters that are stored in the database directly,
--	    without validation, this API checks to ensure that the passed
--	    string's length does not exceed the length of its destination
--	    column. If the check fails, the value truncates and a warning is
--	    appended to the message list.
--	(5) If you do not pass in an interaction document type, the source
--	    document ID, name, status, and reference form are ignored. If you
--	    do not pass in a source document name, the reference form and
--	    source document status are ignored.
--	(6) The value must be passed in using the following format:
--		function_name:parameter1=value1 ... parameterN=valueN
--	    where valueN can be a text string enclosed in double quotes, or a
--	    token substituted with the p_source_document_id or
--	    p_source_document_name parameter in the following ways:
--		parameterN="&ID"
--		parameterN="&NAME"
--	    where &ID represents the value of p_source_document_id, and &NAME
--	    represents the value of p_source_document_name.
--	    The reference form is passed to the Customer Interactions form to
--	    let a user drill down to the form to see additional information
--	    related to the interaction.
--	(7) If you do not pass in a parent interaction ID, the system-
--	    generated interaction ID is inserted as the parent interaction ID.
--	(8) You must pass in segment IDs for none or all descriptive flexfield
--	    columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Create_Interaction
( p_api_version			IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level		IN	NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status		OUT	VARCHAR2,
  x_msg_count			OUT	NUMBER,
  x_msg_data			OUT	VARCHAR2,
  p_resp_appl_id		IN	NUMBER   DEFAULT NULL,
  p_resp_id			IN	NUMBER   DEFAULT NULL,
  p_user_id			IN	NUMBER,
  p_login_id			IN	NUMBER   DEFAULT NULL,
  p_org_id			IN	NUMBER   DEFAULT NULL,
  p_customer_id			IN	NUMBER,
  p_contact_id			IN	NUMBER   DEFAULT NULL,
  p_contact_lastname		IN	VARCHAR2 DEFAULT NULL,
  p_contact_firstname		IN	VARCHAR2 DEFAULT NULL,
  p_phone_area_code		IN	VARCHAR2 DEFAULT NULL,
  p_phone_number		IN	VARCHAR2 DEFAULT NULL,
  p_phone_extension		IN	VARCHAR2 DEFAULT NULL,
  p_fax_area_code		IN	VARCHAR2 DEFAULT NULL,
  p_fax_number			IN	VARCHAR2 DEFAULT NULL,
  p_email_address		IN	VARCHAR2 DEFAULT NULL,
  p_interaction_type_code	IN	VARCHAR2,
  p_interaction_category_code	IN	VARCHAR2,
  p_interaction_method_code	IN	VARCHAR2,
  p_interaction_date		IN	DATE,
  p_interaction_document_code	IN	VARCHAR2 DEFAULT NULL,
  p_source_document_id		IN	NUMBER   DEFAULT NULL,
  p_source_document_name	IN	VARCHAR2 DEFAULT NULL,
  p_reference_form		IN	VARCHAR2 DEFAULT NULL,
  p_source_document_status	IN	VARCHAR2 DEFAULT NULL,
  p_employee_id			IN	NUMBER   DEFAULT NULL,
  p_public_flag			IN	VARCHAR2 DEFAULT NULL,
  p_follow_up_action		IN	VARCHAR2 DEFAULT NULL,
  p_notes			IN	VARCHAR2 DEFAULT NULL,
  p_parent_interaction_id	IN	NUMBER   DEFAULT NULL,
  p_attribute1			IN	VARCHAR2 DEFAULT NULL,
  p_attribute2			IN	VARCHAR2 DEFAULT NULL,
  p_attribute3			IN	VARCHAR2 DEFAULT NULL,
  p_attribute4			IN	VARCHAR2 DEFAULT NULL,
  p_attribute5			IN	VARCHAR2 DEFAULT NULL,
  p_attribute6			IN	VARCHAR2 DEFAULT NULL,
  p_attribute7			IN	VARCHAR2 DEFAULT NULL,
  p_attribute8			IN	VARCHAR2 DEFAULT NULL,
  p_attribute9			IN	VARCHAR2 DEFAULT NULL,
  p_attribute10			IN	VARCHAR2 DEFAULT NULL,
  p_attribute11			IN	VARCHAR2 DEFAULT NULL,
  p_attribute12			IN	VARCHAR2 DEFAULT NULL,
  p_attribute13			IN	VARCHAR2 DEFAULT NULL,
  p_attribute14			IN	VARCHAR2 DEFAULT NULL,
  p_attribute15			IN	VARCHAR2 DEFAULT NULL,
  p_attribute_category		IN	VARCHAR2 DEFAULT NULL,
  x_interaction_id		OUT	NUMBER
);

END CS_Interaction_PVT;

 

/
