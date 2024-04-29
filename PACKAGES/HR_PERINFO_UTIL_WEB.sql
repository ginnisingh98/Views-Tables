--------------------------------------------------------
--  DDL for Package HR_PERINFO_UTIL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERINFO_UTIL_WEB" AUTHID CURRENT_USER AS
/* $Header: hrpiutlw.pkh 120.3 2005/12/13 13:50:17 svittal noship $ */

-- ----------------------------------------------------------------------------
-- Screen/Canvas Names for TIPS
-- ----------------------------------------------------------------------------
g_bdt_form VARCHAR2(1000) := 'PERINFO_BASIC_DETAILS_FORM';
g_bdt_review VARCHAR2(1000) := 'PERINFO_BASIC_DETAILS_REVIEW';
g_bdt_toc VARCHAR2(1000) := 'PERINFO_BASIC_DETAILS_TOC';

g_address_form VARCHAR2(1000) := 'PERINFO_ADDRESS_FORM';
g_address_toc VARCHAR2(1000) := 'PERINFO_ADDRESS_TOC';
g_address_review VARCHAR2(1000) := 'PERINFO_ADDRESS_REVIEW';
g_address_deletion_review VARCHAR2(1000) := 'PERINFO_ADDRESS_DELETION_REVW';

g_contacts_form VARCHAR2(1000) := 'PERINFO_CONTACTS_FORM';
g_add_contacts_form VARCHAR2(1000) := 'PERINFO_ADD_CONTACTS_FORM';
g_contacts_toc VARCHAR2(1000) := 'PERINFO_CONTACTS_TOC';
g_contacts_review VARCHAR2(1000) := 'PERINFO_CONTACTS_REVIEW';

g_phones_form VARCHAR2(1000) := 'PERINFO_PHONES_FORM';
g_phones_review VARCHAR2(1000) := 'PERINFO_PHONES_REVIEW';
-- ----------------------------------------------------------------------------
-- End of Screen Names for TIPS
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Following global variables will hold the Function Attribute
-- Internal Name. ( For Workflow )
-- ----------------------------------------------------------------------------
g_basic_details VARCHAR2(100) := 'BASIC_DETAILS';
g_contacts VARCHAR2(100) := 'CONTACTS';
g_phone_numbers VARCHAR2(100) := 'PHONE_NUMBERS';
g_main_address VARCHAR2(100) := 'MAIN_ADDRESS';
g_secondary_address VARCHAR2(100) := 'SECONDARY_ADDRESS';
g_national_identifier VARCHAR2(100) := 'NATIONAL_IDENTIFIER';
g_date_of_birth VARCHAR2(100) := 'DATE_OF_BIRTH';
g_marital_status VARCHAR2(100) := 'MARITAL_STATUS';
-- Bug 1835437 fix starts
g_perinfo_check_pending   constant varchar2(200) := 'HR_PERINFO_CHECK_PENDING';
-- ----------------------------------------------------------------------------
-- For Tip and Error - Test Mode
-- ----------------------------------------------------------------------------
g_tiperror_mode BOOLEAN := FALSE;

-- ----------------------------------------------------------------------------
-- User Defined Exception
-- ----------------------------------------------------------------------------
g_no_changes EXCEPTION;
g_past_effective_date EXCEPTION;
g_past_current_start_date EXCEPTION;
g_invalid_address_style EXCEPTION;
-- ----------------------------------------------------------------------------
-- Following Global variables are used for Transaction API
-- ----------------------------------------------------------------------------
TYPE transaction_row IS RECORD
	(param_name VARCHAR2(200)
	,param_value LONG
	,param_data_type VARCHAR2(200));


TYPE transaction_table IS TABLE OF transaction_row INDEX BY BINARY_INTEGER;

TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE validate_field_rec IS RECORD
	(name VARCHAR2(200)
	,prompt VARCHAR2(200)
	);

TYPE validate_field_list IS TABLE OF validate_field_rec INDEX BY BINARY_INTEGER;
g_number_tab_default g_number_tab_type;


        FUNCTION isR11i(p_application_id in number default 800)
                RETURN BOOLEAN;


/*------------------------------------------------------------------------------
|
|       Name           : isDateLessThanCreationDate
|
|       Purpose        :
|
|       This  function will check if the passed in date is less than the date
|       on which the person was created.
|
|       In Parameters  :
|
|       p_date         : The date to be checked.
|       p_person_id    : The ID of person for whom this check is done.
|
|       Returns        :
|
|       Boolean        :
|
|       TRUE           : If the date is less than the creation date.
|       FALSE          : If the date is equal to or greater than the creation
|                        date.
+-----------------------------------------------------------------------------*/

FUNCTION isDateLessThanCreationDate
		(p_date IN DATE
		,p_person_id IN NUMBER) RETURN BOOLEAN;
/*------------------------------------------------------------------------------
|
|       Name           : isLessThanCurrentStartDate
|
|       Purpose        :
|
|       This  function will check if the passed in date is less than the
|       Effective Start Date of the person reocrd which is current for a
|       given Object Version Number and Person ID.
|
|       In Parameters  :
|
|       p_date         : The date to be checked.
|       p_person_id    : The ID of person for whom this check is done.
|       p_ovn          : The Object Version of the Person row in question.
|
|       Returns        :
|
|       Boolean        :
|
|       TRUE           : If the date is less than the Effective Start Date.
|       FALSE          : If the date is equal to or greater than the Effective
|                        Start date.
+-----------------------------------------------------------------------------*/

	FUNCTION isLessThanCurrentStartDate
			(p_effective_date IN DATE
			,p_person_id IN NUMBER
			,p_ovn IN NUMBER) RETURN BOOLEAN ;

END hr_perinfo_util_web;

 

/
