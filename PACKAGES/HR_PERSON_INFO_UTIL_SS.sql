--------------------------------------------------------
--  DDL for Package HR_PERSON_INFO_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_INFO_UTIL_SS" AUTHID CURRENT_USER AS
/* $Header: hrperuts.pkh 115.20 2002/12/05 19:33:37 snachuri noship $*/

-- Global variables
   gv_default_result_code     constant
                             wf_item_activity_statuses.activity_result_code%type
                             := 'HR_SUBMIT_FOR_APPROVAL';
   gv_wf_process_sect_attr_name    constant wf_item_attributes.name%type
                             := 'HR_PERINFO_PROCESS_SECTION';

   gv_wf_action_type_attr_name    constant wf_item_attributes.name%type
                             := 'HR_PERINFO_ACTION_TYPE';

   gv_update_attr_value           constant wf_item_attribute_values.text_value%type
                             := 'UPDATE';

   gv_add_attr_value              constant wf_item_attribute_values.text_value%type
                             := 'ADD';

   --
   -- PB : For Contacts module.
   --
   gv_add_upd_attr_value          constant wf_item_attribute_values.text_value%type
                             := 'ADD_OR_UPDATE';

   gv_del_attr_value              constant wf_item_attribute_values.text_value%type
                             := 'DELETE';

   gv_view_future_changes_value constant wf_item_attribute_values.text_value%type
                             := 'VIEW_FUTURE_CHANGES';

   gv_view_pending_approval_value constant wf_item_attribute_values.text_value%type
                             := 'VIEW_PENDING_APPROVAL_CHANGES';

   gv_basic_details_sect     constant wf_item_attribute_values.text_value%type
                             := 'BASIC_DETAILS';

   gv_main_address_sect      constant wf_item_attribute_values.text_value%type
                             := 'MAIN_ADDRESS';

   gv_secondary_address_sect constant wf_item_attribute_values.text_value%type
                             := 'SECONDARY_ADDRESS';

   --
   -- PB : For Contacts module.
   --
   gv_contacts_sect          constant wf_item_attribute_values.text_value%type
                             := 'CONTACTS';

   gv_update_basic_details_value constant wf_item_attribute_values.text_value%type
                             := 'HR_UPDATE_BASIC_DETAILS';

   gv_view_basic_details_value constant wf_item_attribute_values.text_value%type
                             := 'HR_VIEW_BASIC_DETAILS';

   gv_update_main_address_value constant wf_item_attribute_values.text_value%type
                             := 'HR_UPDATE_MAIN_ADDRESS';

   gv_add_main_address_value constant wf_item_attribute_values.text_value%type
                             := 'HR_ADD_MAIN_ADDRESS';

   gv_view_main_address_value constant wf_item_attribute_values.text_value%type
                             := 'HR_VIEW_MAIN_ADDRESS';

   gv_update_second_address_value constant wf_item_attribute_values.text_value%type
                             := 'HR_UPDATE_SECONDARY_ADDRESS';

   gv_add_second_address_value constant wf_item_attribute_values.text_value%type
                              := 'HR_ADD_SECONDARY_ADDRESS';

   gv_view_second_address_value constant wf_item_attribute_values.text_value%type
                              := 'HR_VIEW_SECONDARY_ADDRESS';
   --
   -- PB : For Contacts module.
   --
   gv_add_upd_contacts_value constant wf_item_attribute_values.text_value%type
                              := 'HR_ADD_UPD_CONTACT';

   gv_del_contacts_value     constant wf_item_attribute_values.text_value%type
                              := 'HR_DEL_CONTACT';

--
--
-- ---------------------------------------------------------------------------
-- --------------------- < check_pending_approval_items> ---------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will check whether there are any pending approval
--          items in workflow for a given process name and process section
--          name.  If the p_process_name parameter is passed in, then this
--          procedure will be searching for Personal Information pending
--          approval items.  This procedure returns three output parameters.
--
-- Input Parameters:
--   p_item_type - required.
--   p_process_name - required.  It is the process name coded in the FND Form
--                    function parameters.
--   p_api_name      - This api_name in conjunction with the p_item_type and
--                     p_item_key parameters will uniquely identify the
--                     activity_id which was used to save recs to the trans
--                     table.
--   p_result_code - This result code is used in collaboration with the derived
--                   activity_id to check for pending approval items.
--                   If it is null,it will be defaulted to 'SUBMIT_FOR_APPROVAL'
--                   result code.
--   p_current_person_id - the person_id for whom the action is to be performed.
--
--   p_address_context - this is used by Address section in the Personal
--                       Information Overview page.  Since primary and secondary
--                       address use the same api name, we need this parameter
--                       to indicate further filtering by transaction values for
--                       "P_PRIMARY_FLAG" equals to "Y" or "N".
--                       Valid values are "PRIMARY" or "SECONDARY".
--
--  Output Parameters:
--   1) p_multiple_item_keys - this parameter will have a value only if p_trans_rec_count >1.
--                             If not it is null.
--   2) p_pending_item_key - this parameter will return the pending item key value.
--
-- Inovked by: Java code.
-- ---------------------------------------------------------------------------
PROCEDURE check_pending_approval_items (
    p_item_type                       in  varchar2
   ,p_process_name                    in  varchar2
   ,p_api_name                        in  varchar2
   ,p_result_code                     in  varchar2 default null
   ,p_current_person_id               in  number
   ,p_address_context                 in  varchar2 default null
   ,p_multiple_item_keys              out nocopy varchar2
   ,p_pending_item_key                out nocopy varchar2
);

--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< process_action >----------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will be called from the overview page, which will route
--          for the process section (e.g:- BASIC_DETAILS or MAIN_ADDRESS) to either
--          type of change or update page, depending on the link on the overview page.
--
-- Parameters:
--   Input
--   p_item_type - required. It is the item type for the workflow process.
--   p_item_key  - required.  It is the item key for the workflow process.
--   p_actid  - required. It is the item key for the workflow process.
--   p_funcmode  - required.  It is the func mode for the workflow process.

--  Output Parameters:
--   1) p_resultout - will populate the result code for the activity
-- ---------------------------------------------------------------------------

PROCEDURE process_action
  (p_item_type     in  varchar2
  ,p_item_key      in  varchar2
  ,p_actid         in  number
  ,p_funcmode      in  varchar2
  ,p_resultout     out nocopy varchar2
);

-- ----------------------------------------------------------------------------
-- |-------------------------------< is_duplicate_person >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure can be used to check if there are any duplicate persons
--          this will internally call hr_generl2.is_duplicate_person function.
--
-- Parameters:
--   Input
--   p_first_name - required.
--   p_last_name  - required.
--   p_national_identifier  - required.
--   p_date_of_birth  - required.

--  Output Parameters:
--   1) p_resultout - will have a value of 0 for flase
--                                         1 for true
-- ---------------------------------------------------------------------------

PROCEDURE is_duplicate_person
  (p_first_name                  in  varchar2
  ,p_last_name                   in  varchar2
  ,p_national_identifier         in  varchar2
  ,p_date_of_birth               in  date
  ,p_effective_date              in  date
  ,p_resultout                   out nocopy number
);

--
-- Fix 2091186 Start
-- ----------------------------------------------------------------------------
-- |--------------------< create_ignore_df_validation >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: To add descriptive flex field to ignorable list.
-- Parameters:
--   Input
--   p_flex_name - required.
-- ----------------------------------------------------------------------------

PROCEDURE create_ignore_df_validation
( p_flex_name varchar2
);

--
-- ----------------------------------------------------------------------------
-- |--------------------< remove_ignore_df_validation >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: To remove descriptive flex field validation.
-- Parameters:
--   Input
--   none.
-- ----------------------------------------------------------------------------

PROCEDURE remove_ignore_df_validation
;
--
-- Fix 2091186 End

-- |--------------------< get_trns_employee_number >-----------------------|
-- ----------------------------------------------------------------------------
-- Purpose: To get the employee number stored in the basic details step. This
-- procedure will be called from assignment and supervisor wrappers to get the
-- employee number while hiring an applicant.
-- Parameters:
--   Input
--   none.
-- ----------------------------------------------------------------------------

PROCEDURE get_trns_employee_number
( p_item_type varchar2
 ,p_item_key  varchar2
 ,p_employee_number out nocopy varchar2
);

-- ----------------------------------------------------------------------------
-- |-------------------------< check_ni_unique>------------------------|
-- ----------------------------------------------------------------------------
-- this procedure checks if the SSN entered is duplicate or not.If value of profile
-- HR: NI Unique Error or Warning is 'Warning' then warning is raised for duplicate
-- SSN entered else if value is 'Error' or null then error is raised.

procedure check_ni_unique
(p_national_identifier in  varchar2 default null
,p_business_group_id            in        number
,p_person_id                    in        number
,p_ni_duplicate_warn_or_err out nocopy varchar2);
--

-- ----------------------------------------------------------------------------
-- |-----------------------< validate_national_identifier>--------------------|
-- ----------------------------------------------------------------------------
-- this procedure checks if the national identifier entered is in valid format
-- or not.If value of profile HR: National Identifier Validation is 'Warning on Fail'
-- then warning is raised.

procedure validate_national_identifier(
  p_national_identifier    VARCHAR2,
  p_birth_date             DATE,
  p_gender                 VARCHAR2,
  p_event                  VARCHAR2 default 'WHEN-VALIDATE-RECORD',
  p_person_id              NUMBER,
  p_business_group_id      NUMBER,
  p_legislation_code       VARCHAR2,
  p_effective_date         DATE,
  p_warning            OUT NOCOPY VARCHAR2,
  p_person_type_id         NUMBER default NULL,
  p_region_of_birth         VARCHAR2 default NULL,
  p_country_of_birth        VARCHAR2 default NULL);
--

END hr_person_info_util_ss;

--

 

/
