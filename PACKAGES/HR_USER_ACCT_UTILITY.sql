--------------------------------------------------------
--  DDL for Package HR_USER_ACCT_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_ACCT_UTILITY" AUTHID CURRENT_USER as
/* $Header: hrusracu.pkh 120.0 2005/05/31 03:39:56 appldev noship $ */
--
-- Public Global Variables
--
g_package  varchar2(33) := 'hr_user_acct_utility.';
--
-- ----------------------------------------------------------------------------
-- NOTE: This package specification contains global variables only.  It does
--       not have any functions or procedures. The purpose of this specification
--       is to allow user hooks to communicate output information to the caller
--       api.
--       The starting index for all PL/SQL tables defined in this specification
--       is 1. So, use index = 1 as a start index when loading the tables.
-- ----------------------------------------------------------------------------
-- USAGE NOTES FOR CREATING A USER NAME:
--     user_name - required, cannot be more than 100 characters.
--
--     password - optional.  If entered, the length cannot be more than the
--                length in SIGNON_PASSWORD_LENGTH profile option.  If null
--                value, a randomly generated 8-byte alphanumeric string will be
--                generated.
--
--     start_date - optional.  If null value, the employee's Hire Date will be
--                used.
--
--     end_date - optional.  If entered, it must be greater than start_date.
--
--     email_address - optional. If entered, cannot be more than 240 characters.
--
--     fax - optional. If entered, cannot be more than 80 characters.
--
--     description - optional.  If entered, cannot be more than 240 characters.
--     password_date - optional. If null, user have to change their password
--                     after first login -- Fix 2288014
--
--     language - optional, default value is "AMERICAN".  If entered, it must
--                be one of the valid values in fnd_languages.nls_language
--                column with the installed_flag = 'B' or 'I'.
--
--     host_port - unused.  In R11.5, this field is no longer needed.  The value
--                put in here will be ignored.  The reason this field is left in
--                the record structure is to facilitate R11 users who have
--                upgraded to R11.5 without changing their user exit code.
--
--     employee_id - optional.  If the user name is to associate to an employee,
--                then this field must contain a valid person_id in
--                per_all_people_f table.
--
--     customer_id - optional.  No validation is done on this field.  This field
--                is used by non Oracle Human Resources Application and this
--                program is intended for HR Application use only.
--
--     supplier_id - optional.  No validation is done on this field.  This field
--                is used by non Oracle Human Resources Application and this
--                program is intended for HR Application use only.
-------------------------------------------------------------------------------
--
--
-- RECORD STRUCTURE FOR FND_USERS
-- ==============================
   TYPE fnd_user_rec IS RECORD
     (user_name              fnd_user.user_name%type
     ,password               varchar2(30)
     ,start_date             fnd_user.start_date%type
     ,end_date               fnd_user.end_date%type
     ,email_address          fnd_user.email_address%type
     ,fax                    fnd_user.fax%type
     ,description            fnd_user.description%type
     ,password_date          fnd_user.password_date%type
     ,language               fnd_profile_option_values.profile_option_value%type
     ,host_port              varchar2(2000)
     ,employee_id            fnd_user.employee_id%type
     ,customer_id            fnd_user.customer_id%type
     ,supplier_id            fnd_user.supplier_id%type
     );
--
   g_fnd_user_rec            fnd_user_rec;
--
-- ----------------------------------------------------------------------------
-- NOTE: Since new responsibility can use a template responsibility's
--       values, we need to use API constant system defaults to differentiate
--       null value as opposed to use the template value.
--       Use the following values to indicate to use the template
--       responsibility's value:
--        1) hr_api.g_varchar2 -> means to use the template responsibility's
--           value for varchar2 data type field.
--        2) hr_api.g_number -> means to use the template responsibility's
--           value for number data type field.
--        3) hr_api.g_date -> means to use the template responsibility's
--           value for date data type field.
--       For null values, enter null in the approperiate field.
--
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- USAGE NOTES FOR CREATING/UPDATING A RESPONSIBILTY, ASSOCIATING A
-- RESPONSIBILITY, SECURITY GROUP TO A USERNAME:
--
--  ***************************************************************************
--  For R11i, fnd_user_responsibility is replaced with fnd_user_resp_groups.
--  If the profile option 'ENABLE_SECURITY_GROUPS' for the Application is 'Y',
--  then you'll need to populate the sec_group_id, sec_profile_id fields at the
--  end of this record structure.  The system will insert a row into
--  per_sec_profile_assignments as well as to fnd_user_resp_groups.
--
--  If the profile option 'ENABLE_SECURITY_GROUPS' for the Application is 'N',
--  that means you remain to use the R11 way of responsibility and security profile
--  set up.  There is no need to fill in the values of sec_group_id and
--  sec_profile_id fields.  The system will insert a row into fnd_user_resp_groups
--  only.
--  ***************************************************************************
--
--  existing_resp_id - optional.  If creating a new responsibility and would
--                     want to use an existing responsibility as a template,
--                     or to associate the new user name to an existing
--                     responsibililty, then fill in this field with
--                     the fnd_responsibility.responsibility_id value.
--                     If no template is to be used, leave this field null.
--
--  existing_resp_key - optional. If creating a new responsibility and would
--                     want to use an existing responsibility as a template,
--                     or to associate the new user name to an existing
--                     responsibililty, then fill in this field with
--                     the fnd_responsibility.responsibility_key value.
--                     If no template is to be used, leave this field null.
--
--  existing_resp_app_id - optional. If creating a new responsibility and would
--                     want to use an existing responsibility as a template,
--                     or to associate the new user name to an existing
--                     responsibililty, then fill in this field with
--                     the fnd_responsibility.application_id value.
--                     If no template is to be used, leave this field null.
--                     the fnd_responsibility.responsibility_id value.
--
--  new_resp_name - mandatory only for creating a new responsibility.  If
--                     entered, cannot exceed the length of
--                     fnd_responsibility_tl.responsibility_name, which is
--                     100 characters.  If associating the new user name to
--                     an existing responsibility, do not enter any value
--                     in this field.
--
--  new_resp_key - mandatory only for creating a new responsibility.  If
--                     entered, cannot exceed the length of
--                     fnd_responsibility.responsibility_key, which is
--                     30 characters.  If associating the new user name to
--                     an existing responsibility, do not enter any value
--                     in this field.
--
--  new_resp_app_id - mandatory only for creating a new responsibility.  If
--                     entered, cannot exceed the length of
--                     fnd_responsibility.application_id, which is a number type
--                     with a size of 15.  If associating the new user name to
--                     an existing responsibility, do not enter any value
--                     in this field.
--
--  new_resp_description - optional for creating a new responsibility.  If
--                     entered, cannot exceed the length of
--                     fnd_responsibility_tl.description, which is 240
--                     characters.  If associating the new user name to
--                     an existing responsibility, do not enter any value
--                     in this field.
--
--  new_resp_start_date - mandatory only for creating a new responsibility.  If
--                     entered, it should be in date data type.  If associating
--                     the new user name to an existing responsibility, do not
--                     enter any value in this field.
--
--  new_resp_end_date - optional for creating a new responsibility.  If
--                     entered, it should be in date data type and must be
--                     larger than or equal to new_resp_start_date.  If
--                     associating the new user name to an existing
--                     responsibility, do not enter any value in this field.

--  new_resp_data_group_name - mandatory only for creating a new responsibility.
--                     Length cannot exceed the length of
--                     fnd_data_groups.data_group_name, which is 30 characters.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  new_resp_data_grp_app_id - mandatory only for creating a new responsibility.
--                     Length cannot exceed the length of
--                     fnd_responsibility.data_group_application_id, which is
--                     a number data type with a size of 15.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  new_resp_menu_name - mandatory only for creating a new responsibility.
--                     Length cannot exceed the length of
--                     fnd_menus.menu_name, which is the internal name for a
--                     menu with a size of 30 characters.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  new_resp_request_group_name - optional for creating a new responsibility.
--                     If entered, cannot exceed the length of
--                     fnd_request_groups.request_group_name, which is
--                     30 characters.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  new_resp_req_grp_app_id - optional for creating a new responsibility.
--                     If entered, cannot exceed the length of
--                     fnd_request_groups.application_id, which is a number
--                     data type with a size of 15.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  new_resp_version - optional for creating a new responsibility.
--                     If entered, cannot exceed the length of
--                     fnd_responsibility.version, which is 1 character with
--                     the following valid values:
--                       '4' = Oracle Applications, ie. Forms
--                       'W' = Oracle Self Service Web Applications.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  new_resp_web_host_name - optional for creating a new responsibility.
--                     If entered, this field will supercede the APPS_WEB_AGENT
--                     profile option value.
--                     Under normal circumstances, this field should NOT be
--                     used even for creating a new responsibility.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  new_resp_web_agent_name - optional for creating a new responsibility.
--                     If entered, this field will supercede the APPS_WEB_AGENT
--                     profile option value.
--                     Under normal circumstances, this field should NOT be
--                     used even for creating a new responsibility.
--                     If associating the new user name to an existing
--                     responsibility, do not enter any value in this field.
--
--  user_resp_start_date - mandatory for associating the above responsibility to
--                     the new user.  It should be in date data type.
--                     Length cannot exceed the length of
--                     fnd_user_resp_groups.start_date.
--                     Do not fill in this field with a hr_api.g_date
--                     because each user should have his/her own start_date.
--
--  user_resp_end_date - optional for associating the above responsibility to
--                     the new user.  It should be in date data type and must be
--                     larger than or equal to user_resp_start_date.
--                     Length can not exceed the length of
--                     fnd_user_resp_groups.end_date.
--                     Do not fill in this field with a hr_api.g_date
--                     because each user should have his/her own end_date.
--                     If no end_date is aniticpated, set this field to null.
--
--  user_resp_description - optional for associating the responsibility to the
--                     new user.  Length cannot exceed the length of
--                     fnd_user_resp_groups.description.
--                     Do not fill in this field with a hr_api.g_varchar2
--                     because each user should have his/her own description.
--
-- **** The following two fields sec_group_id and sec_profile_id
-- **** are to be populated only if the 'ENABLE_SECURITY_GROUPS' profile
-- **** option is 'Y'.  Filling these two fields means associating
-- **** an existing responsibility (if existing_resp_id is not null and
-- **** new_resp_key is null) or a new responsibility (if existing_resp_id is
-- **** not null and new_resp_key is not null OR existing_resp_id is null
-- **** and new_resp_key is NOT null) to the new user using the sec_group_id
-- **** and the sec_profile_id entered.  However, you have an option to leave
-- **** these two fields to null if you want to use the view-all security
-- **** profile of the employee's business group.  In this case, only
-- **** fnd_user_resp_groups will be populated but not
-- **** per_security_profile_assignment.
-- **** If 'ENABLE_SECURITY_GROUPS' = 'N', ignore these two fields.
--
--  sec_group_id - optional for 'ENABLE_SECURITY_GROUPS' profile option =
--                     'Y'. Length cannot exceed
--                     per_sec_profile_assignments.security_group_id, which is
--                     a number data type.  It must be a valid value in
--                     fnd_security_groups.security_group_id.
--                     Do not fill in this field with a hr_api.g_number
--                     because each user should use his/her own security group
--                     id.  If this field is null or sec_profile_id is null,
--                     then the view-all security profile for the employee's
--                     business group will be used.  No row will be inserted
--                     into per_security_profile_assignments.  Only 1 row will
--                     be inserted into fnd_user_resp_groups table.
--                     If 'ENABLE_SECURITY_GROUPS' profile option = 'N', leave
--                     this field null.
--
--  sec_profile_id - optional for 'ENABLE_SECURITY_GROUPS' profile option
--                     = 'Y'.  Length cannot exceed
--                     per_sec_profile_assignments.security_profile_id, which is
--                     a number data type.  It must be a valid value in
--                     per_security_profiles.security_profile_id.
--                     Do not fill in this field with a hr_api.g_number
--                     because each user should use his/her own security profile
--                     id.  If this field is null or sec_profile_id is null,
--                     then the view-all security profile for the employee's
--                     business group will be used.  No row will be inserted
--                     into per_security_profile_assignments.  Only 1 row will
--                     be inserted into fnd_user_resp_groups table.
--                     If 'ENABLE_SECURITY_GROUPS' profile option = 'N', leave
--                     this field null.
--
-------------------------------------------------------------------------------
--
-- RECORD STRUCTURE FOR FND_RESPONSIBILITIES
-- =========================================
   TYPE fnd_responsibility_rec IS RECORD
     (existing_resp_id            fnd_responsibility.responsibility_id%type
     ,existing_resp_key           fnd_responsibility.responsibility_key%type
     ,existing_resp_app_id        fnd_responsibility.application_id%type
     ,new_resp_name               fnd_responsibility_tl.responsibility_name%type
     ,new_resp_key                fnd_responsibility.responsibility_key%type
     ,new_resp_app_id             fnd_application.application_id%type
     ,new_resp_description        fnd_responsibility_tl.description%type
     ,new_resp_start_date         fnd_responsibility.start_date%type
     ,new_resp_end_date           fnd_responsibility.end_date%type
     ,new_resp_data_group_name
                           fnd_data_groups_standard_view.data_group_name%type
     ,new_resp_data_grp_app_id
                           fnd_responsibility.data_group_application_id%type
     ,new_resp_menu_name          fnd_menus.menu_name%type
     ,new_resp_request_group_name fnd_request_groups.request_group_name%type
     ,new_resp_req_grp_app_id     fnd_application.application_id%type
     ,new_resp_version            fnd_responsibility.version%type
     ,new_resp_web_host_name      fnd_responsibility.web_host_name%type
     ,new_resp_web_agent_name     fnd_responsibility.web_agent_name%type
     ,user_resp_start_date        fnd_user_resp_groups.start_date%type
     ,user_resp_end_date          fnd_user_resp_groups.end_date%type
     ,user_resp_description       fnd_user_resp_groups.description%type
     ,sec_group_id
                           per_sec_profile_assignments.security_group_id%type
     ,sec_profile_id       per_sec_profile_assignments.security_profile_id%type
     );

   TYPE fnd_responsibility_tbl IS TABLE OF fnd_responsibility_rec
     INDEX BY BINARY_INTEGER;
--
-- USE INDEX = 1 TO START LOADING THE TABLE.
   g_fnd_resp_tbl             fnd_responsibility_tbl;

--
-- ----------------------------------------------------------------------------
-- USAGE NOTES FOR ASSOCIATING FUNCTION SECURITY EXCLUSION RULES TO A NEW
-- RESPONSIBILITY:
--
--   Function exclusions are to be entered only for new responsibilities
--   listed in g_fnd_resp_tbl above if function exclusion rules are to be
--   applied to the new responsbilities.  For those new responsibilities
--   which do not use function exclusions, you don't need to fill in
--   a row in this g_fnd_resp_functions_tbl.
--
--   existing_resp_key - optional.  If a new responsibility is based on a
--                  template responsibility and the template responsibility's
--                  function security exclusion rules are to be copied to the
--                  new responsibility, then this field can be filled in with
--                  an existing responsibility key in the database.
--                  If entered, cannot exceed the length of
--                  fnd_responsibility.responsibility_key, which is
--                  30 characters.
--                  If you want to add a new function exclusion rule, you need
--                  to create a new entry in this table with this field being
--                  null.
--
--   new_resp_key - mandatory for a new responsibility listed in
--                  g_fnd_resp_tbl above. Length cannot exceed the length
--                  of fnd_responsibility.responsibility_key, which is
--                  30 characters.
--
--   rule_type - optional.  If the function security exclusion rules of a
--                  template responsibility are to be used, this field can be
--                  left null unless you want to add new function exclusion
--                  rules in addition to the template responsibility's
--                  exclusion rules.  If entered, cannot exceed
--                  the length of fnd_resp_functions.rule_type, which is 1
--                  character with the following valid values:
--                    'F' = Function
--                    'M' = Menu
--
--   rule_name - optional.  If the function security exclusion rules of a
--                  template responsibility are to be used, this field can be
--                  left null unless you want to add new function exclusion
--                  rules in addition to the template responsibility's
--                  exclusion rules.  If entered, cannot exceed
--                  the length of either fnd_form_functions.function_name or
--                  fnd_menus.menu_name, both are 30 characters each. The
--                  valid values in this field are one of the following:
--                     i) fnd_form_functions.function_name if rule_type = 'F'.
--                    ii) fnd_menus.menu_name if rule_type = 'M'.
--
--   delete_flag - NOT USED.  This field is for future use.
--                  The default value is 'N'.  This field is ignored in
--                  the current delivery.
--
--   For example, if you cant to copy all the function exclusion rules from
--   "HR_LMDA_RESPONSIBILITY" (assuming the repsonsibility_key is the same)
--   to the new responsibility created in g_fnd_resp_tbl and you want to add
--   a new function exclusion rule to this new responsibility, then you will
--   fill out the following entries in this g_fnd_resp_functions_tbl array:
--     Entry Existing_Resp_Key       New_Resp_key     Rule  Rule          Delete
--     #                                              Type  Name          Flag
--     ----- ----------------------- ---------------  ----- ------------- ------
--      1    HR_LMDA_RESPONSIBILITY  <new resp key>   null  null          null
--      2    null                    <new resp key>   F     <func name>   null
--  OR
--      2    null                    <new resp key>   M     <menu name>   null
--
-- ----------------------------------------------------------------------------
--
-- RECORD STRUCTURE FOR FND_RESP_FUNCTIONS:
-- =========================================
   TYPE fnd_resp_functions_rec IS RECORD
     (existing_resp_key           fnd_responsibility.responsibility_key%type
     ,new_resp_key                fnd_responsibility.responsibility_key%type
     ,rule_type                   fnd_resp_functions.rule_type%type
     ,rule_name                   varchar2(30)
     ,delete_flag                 varchar2(1));
--
   TYPE fnd_resp_functions_tbl IS TABLE OF fnd_resp_functions_rec
   INDEX BY BINARY_INTEGER;
--
-- USE INDEX = 1 TO START LOADING THE TABLE.
   g_fnd_resp_functions_tbl       fnd_resp_functions_tbl;
--
--
--
--------------------------------------------------------------------------------
-- USAGE NOTES FOR CREATING PROFILE OPTION VALUE AT THE RESPONSIBILITY OR USER
-- LEVEL:
--
--
-- 1) 'SITE' or 'APPL' level profile option values cannot be added because these
--    should have been set at the initial installation/implementation via online
--    entries to the form. The batch job is not intended to replace the online
--    form.
--
-- 2) This is intended to use for creating profile option values for a new
--    responsibility at the responsibility level or for a new user at the user
--    level.  It is not intended to use for updating an existing profile option
--    value at responsibility or user level.
--
-- 3) For a new responsibility, three profile option values must be set in
--    order for the new responsibility to function correctly:
--        i) PER_BUSINESS_GROUP_ID    \   Site level profile option value will
--       ii) PER_SECURITY_PROFILE_ID  /   be used if not set at the resp level
--      iii) HR_USER_TYPE
--
-- 4) It is assumed that various security profiles have already been created
--    before running the program so that a security profile can be set as a
--    a value in the profile option "PER_SECURITY_PROFILE_ID".

-- 5) Attributes:
--    profile_option_name - mandatory for creating a new profile option value
--                at the new responsibility level or at the new user level.
--                Length cannot exceed the length of
--                fnd_profile_options.profile_option_name, which is 80
--                characters.  This should be the internal name, NOT the
--                fnd_profile_options_tl.user_profile_option_name.
--                For example, for the "HR: User Type" profile option, the value
--                to use should be "HR_USER_TYPE", the internal name.
--
--    profile_option_value - mandatory for creating a new profile option value
--                at the new responsibility level or at the new user level.
--                Length cannot exceed the length of
--                fnd_profile_option_values.profile_option_value, which is 240
--                characters.
--                Use the INTERNAL ID or VALUE for those HR profile options
--                which use SQL validations on the option values (ie. an LOV is --                used when entering a value).  The following
--                profile options have SQL validations and thus supply the
--                id or the lookup code in profile_option_value field:
--                PROFILE_OPTION_NAME            PROFILE_OPTION_VALUE
--                ---------------------------    ------------------------------
--                HR:COST_MAND_SEG_CHECK         A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--                HR:EXECUTE_LEG_FORMULA         A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--                HR_BG_LOCATIONS                A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--                HR_DISPLAY_SKILLS              A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--                HR_PAYROLL_CURRENCY_RATES      A specific value in
--                                               pay_payrolls_f.payroll_id.
--
--                HR_TIPS_TEST_MODE              A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--                HR_USER_TYPE                   A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type =
--                                               'HR_USER_TYPE'.
--
--                PER_ATTACHMENT_USAGE           A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--                PER_BUSINESS_GROUP_ID          A specific business_group_id in
--                                               PER_BUSINESS_GROUPS.
--
--                PER_DEFAULT_NATIONALITY        A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type='NATIONALITY'
--
--                PER_QUERY_ONLY_MODE            A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--                PER_SECURITY_PROFILE_ID        A security_profile_id in
--                                               per_security_profiles.
--
--                VIEW_UNPUBLISHED_360_SELF_APPR A specific value in
--                                               fnd_common_lookups.lookup_code
--                                               where lookup_type = 'YES_NO'.
--
--    profile_level_name - mandatory for creating a new profile option value
--                at the new responsibility level or at the new user level.
--                It must be either the value of "RESP" for
--                responsibility level or "USER" for user level.  Other values
--                are invalid.
--
--    profile_level_value - mandatory for creating a new profile option value
--                at the new responsibility level or at the new user level.
--                It must be one of the following values:
--                   - fnd_responsibility.responsbility_key if
--                     profile_level_name = "RESP"
--                   - fnd_user.user_id if profile_level_name = "USER".
--
--                Examples:
--                 - to create a new profile option value for the
--                   responsibility "US HRMS Manager", this field will be the
--                   fnd_responsibility.responsibility_key, which is
--                   "US_HRMS_MANAGER".  If the responsibility is new, use
--                   the fnd_responsibility_tbl.new_resp_key value.
--                 - to create a new profile option value for the user
--                   "SYSADMIN", this field will be the fnd_user.user_id, which
--                   is 0.
--
--    profile_level_value_app_id - mandatory for creating a new profile option
--                value at the new responsibility level.  If profile_level_name
--                is "USER", this field is ignored.  This field is the value
--                the application id for the responsibility specified in
--                profile_level_value.
--                For example, to create a new profile option value for the
--                responsibility "US HRMS Manager", this field will be the
--                fnd_responsibility_tl.application_id, which is 800.
--                If the responsibility is new, use the
--                fnd_responsibility_tbl.new_resp_app_id value.
--
-- Example 1: To add a profile option value for the profile option name
--            'PER_BUSINESS_GROUP_ID' at the responsibility level:
--   profile_option_name = fnd_profile_options.profile_option_name.  In this
--                         case is 'PER_BUSINESS_GROUP_ID'.
--   profile_option_value = whatever business group id value
--   profile_level_name = 'RESP' for responsibility
--   profile_level_value = the responsibility_key in this example.
--                Responsibility key is the unique key visible to the user in
--                the Define Responsibility form.
--   profile_level_value_app_id = 800 for the responsibility's application id
--                (NOTE: This field is only needed if the level id is 10003,
--                 ie. at the "RESP" level.  No need to supply a value if the
--                 level name is "USER").
--
-- Example 2: To add a profile option value for the profile option name
-- ---------
--            'HR_TIPS_TEST_MODE' at the user level, you would fill out
--            the following values:
--   profile_option_name = fnd_profile_options.profile_option_name.  In this
--                 case is 'HR_TIPS_TEST_MODE'.
--   profile_option_value = 'Y' or 'N', the quick code value for the quick code
--                 type "YES_NO".
--   profile_level_name = 'USER' for user level.
--   profile_level_value = When creating users using API, this value need not
--         be set for profiles at user level, as user id is unknown.
--   profile_level_value_app_id = null
--
--------------------------------------------------------------------------------
--
-- RECORD STRUCTURE FOR FND_PROFILE_OPTION_VALUES
-- ==============================================
   TYPE fnd_profile_opt_val_rec IS RECORD
     (profile_option_name      fnd_profile_options.profile_option_name%type
     ,profile_option_value
                           fnd_profile_option_values.profile_option_value%type
     ,profile_level_name          varchar2(2000)
     ,profile_level_value         varchar2(30)
     ,profile_level_value_app_id
                    fnd_profile_option_values.level_value_application_id%type
     );

   TYPE fnd_profile_opt_val_tbl IS TABLE OF fnd_profile_opt_val_rec
     INDEX BY BINARY_INTEGER;

--
-- USE INDEX = 1 TO START LOADING THE TABLE.
   g_fnd_profile_opt_val_tbl  fnd_profile_opt_val_tbl;

--
------------------------------------------------------------------------------
-- The following func_sec_excl_rec, func_sec_excl_tbl
-- declarations are for program internal processing.  Customers can ignore
-- these definitions.
------------------------------------------------------------------------------
   TYPE func_sec_excl_rec IS RECORD
     (resp_key       fnd_responsibility.responsibility_key%type
     ,rule_type      fnd_resp_functions.rule_type%type
     ,rule_name      fnd_form_functions.function_name%type
     ,delete_flag    varchar2(1));
--
   TYPE func_sec_excl_tbl IS TABLE OF func_sec_excl_rec
   INDEX BY BINARY_INTEGER;
--
------------------------------------------------------------------------------
-- Run Type value global variables
------------------------------------------------------------------------------
  g_cr_user_new_hires        constant varchar2(30) := 'CREATE_USER_NEW_HIRES';
  g_cr_user_all_emp          constant varchar2(30) := 'CREATE_USER_ALL_EMP';
  g_cr_n_inact_user          constant varchar2(30) :='CREATE_N_INACTIVATE_USER';
  g_inactivate_user          constant varchar2(30) := 'INACTIVATE_USER';

--
end hr_user_acct_utility;

 

/
