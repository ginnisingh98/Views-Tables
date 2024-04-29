--------------------------------------------------------
--  DDL for Package HR_USER_ACCT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_ACCT_INTERNAL" AUTHID CURRENT_USER as
/* $Header: hrusrbsi.pkh 120.1 2005/06/05 23:28:19 appldev noship $ */
--
-- Public Glboal Variables
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------- < create_fnd_user > ---------------------------|
-- | NOTE: The fnd api fup.create_user that this api will be calling |
-- |       does not have code to handle AK securing attributes.  Thus, this   |
-- |       api will not do any inserts into ak_web_user_sec_attr_values table.|
-- |       So, this api does not do everything that the FND Create User form  |
-- |       does.                                                              |
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_user
  (p_hire_date                     in     date     default null
  ,p_user_name                     in     varchar2
  ,p_password                      in out nocopy varchar2
  ,p_user_start_date               in     date     default null
  ,p_user_end_date                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_fax                           in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_password_date                 in     date     default null -- Fix 2288014
  ,p_language                      in     varchar2 default 'AMERICAN'
  ,p_host_port                     in     varchar2 default null
  ,p_employee_id                   in     varchar2 default null
  ,p_customer_id                   in     varchar2 default null
  ,p_supplier_id                   in     varchar2 default null
  ,p_user_id                       out nocopy    number
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------- < create_fnd_responsibility > ----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_responsibility
  (p_resp_key              in fnd_responsibility.responsibility_key%type
  ,p_resp_name             in fnd_responsibility_tl.responsibility_name%type
  ,p_resp_app_id           in fnd_responsibility.application_id%type
  ,p_resp_description      in fnd_responsibility_tl.description%type
                                default null
  ,p_start_date            in fnd_responsibility.start_date%type
  ,p_end_date              in fnd_responsibility.end_date%type default null
  ,p_data_group_name       in fnd_data_groups_standard_view.data_group_name%type
  ,p_data_group_app_id     in fnd_responsibility.data_group_application_id%type
  ,p_menu_name             in fnd_menus.menu_name%type
  ,p_request_group_name    in fnd_request_groups.request_group_name%type
                                default null
  ,p_request_group_app_id  in fnd_responsibility.group_application_id%type
                                default null
  ,p_version               in fnd_responsibility.version%type default '4'
  ,p_web_host_name         in fnd_responsibility.web_host_name%type default null
  ,p_web_agent_name        in fnd_responsibility.web_agent_name%type
                                default null
  ,p_responsibility_id     out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------- < create_fnd_user_resp_groups > ---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_user_resp_groups
  (p_user_id               in fnd_user.user_id%type
  ,p_responsibility_id     in fnd_responsibility.responsibility_id%type
  ,p_application_id        in
                       fnd_user_resp_groups.responsibility_application_id%type
  ,p_sec_group_id          in fnd_user_resp_groups.security_group_id%type
  ,p_start_date            in fnd_user_resp_groups.start_date%type
  ,p_end_date              in fnd_user_resp_groups.end_date%type
                              default null
  ,p_description           in fnd_user_resp_groups.description%type
                              default null
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------- < create_sec_profile_asg > ------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sec_profile_asg
  (p_user_id               in fnd_user.user_id%type
  ,p_sec_group_id          in fnd_security_groups.security_group_id%type
  ,p_sec_profile_id        in per_security_profiles.security_profile_id%type
  ,p_resp_key              in fnd_responsibility.responsibility_key%type
  ,p_resp_app_id           in
			per_sec_profile_assignments.responsibility_application_id%type
  ,p_start_date            in per_sec_profile_assignments.start_date%type
  ,p_end_date              in per_sec_profile_assignments.end_date%type
                              default null
  ,p_business_group_id     in per_sec_profile_assignments.business_group_id%type
                              default null
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------- < create_fnd_profile_values > -----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_profile_values
   (p_profile_opt_name in fnd_profile_options.profile_option_name%type
   ,p_profile_opt_value in fnd_profile_option_values.profile_option_value%type
   ,p_profile_level_name  in varchar2
   ,p_profile_level_value in fnd_profile_option_values.level_value%type
   ,p_profile_lvl_val_app_id in
       fnd_profile_option_values.level_value_application_id%type  default null
   ,p_profile_value_saved    out nocopy boolean
   );
   --
   --
-- ----------------------------------------------------------------------------
-- |--------------------- < validate_profile_opt_value > ----------------------|
-- | Validate profile options which use SQL validation.  The SQL validation    |
-- | will be hard coded here for a given profile option name because there is  |
-- | no pl/sql parser to parse the SQL statement.                              |
-- |                                                                           |
-- | OUTPUT:                                                                   |
-- |   p_profile_opt_value_valid - boolean, indicating whether the value is    |
-- |                               valid or not after validation.              |
-- |   p_num_data - number, not always has a value in this output. This is to  |
-- |                save another database call if certain values can be        |
-- |                retrieved while validating the profile option value. For   |
-- |                example, PER_SECURITY_PROFILE_ID, the business group id can|
-- |                be derived while running the sql to validate the security  |
-- |                profile id.                                                |
-- |   p_varchar2_data - varchar2, not always has a value in this output. This |
-- |                is to save another database call if certain values can be  |
-- |                retrieved while validating the profile option value. See   |
-- |                p_num_data above.                                          |
-- ----------------------------------------------------------------------------
--  There are only 19 profile options (application_id between 800 and 899)
--  which use SQL validation at the time of coding (March 2000):
--  Profile Option Name                 Validation Table
--  ---------------------------------   ----------------------------------------
--  HR_USER_TYPE                        FND_COMMON_LOOKUPS where lookup_type =
--                                       'HR_USER_TYPE'
--  PER_QUERY_ONLY_MODE                 fnd_lookups where lookup_type ='YES_NO'
--  PER_ATTACHMENT_USAGE                fnd_lookups where lookup_type ='YES_NO'
--  PER_SECURITY_PROFILE_ID             PER_SECURITY_PROFILES and
--                                      HR_ALL_ORGANIZATION_UNITS
--  HR:EXECUTE_LEG_FORMULA              fnd_lookups where lookup_type ='YES_NO'
--  HR_DISPLAY_SKILLS                   FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--  PER_NI_UNIQUE_ERROR_WARNING         fnd_common_lookups where lookup_type =
--                                       NI_UNIQUE_ERROR_WARNING'
--  HR_TIPS_TEST_MODE                   FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--
--  VIEW_UNPUBLISHED_360_SELF_APPR      FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--  PER_DEFAULT_NATIONALITY             FND_COMMON_LOOKUPS where lookup_type =
--                                       'NATIONALITY'
--  HR_PAYROLL_CURRENCY_RATES           pay_payrolls_f and per_business_groups
--  HR:EXECUTE_LEG_FORMULA              fnd_lookups where lookup_type ='YES_NO'
--  HR:COST_MAND_SEG_CHECK              fnd_lookups where lookup_type ='YES_NO'
--  HR_BG_LOCATIONS                     FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--  HR_ELE_ENTRY_PURGE_CONTROL          hr_lookups where lookup_type =
--                                        'HR_ELE_ENTRY_PURGE_CONTROL'
--  PER_ABSENCE_DURATION_AUTO_OVERWRITE FND_COMMON_LOOKUPS where lookup_type =
--                                       'YES_NO'
--
--  DATETRACK:SESSION_DATE_WARNING      FND_COMMON_LOOKUPS where lookup_type =
--                                       'DATETRACK:SESSION_DATE_WARNING'
--  DATETRACK:DATE_SECURITY             FND_COMMON_LOOKUPS where lookup_type =
--                                       'DATETRACK:DATE_SECURITY'
--  HR_BIS_REPORTING_HIERARCHY          PER_ORGANIZATION_STRUCTURES_V
--
--
-- ----------------------------------------------------------------------------
PROCEDURE validate_profile_opt_value
   (p_profile_opt_name         in fnd_profile_options.profile_option_name%type
   ,p_profile_opt_value        in
                           fnd_profile_option_values.profile_option_value%type
   ,p_profile_level_name       in varchar2
   ,p_profile_level_value      in fnd_profile_option_values.level_value%type
   ,p_sql_validation           in fnd_profile_options.sql_validation%type
   ,p_profile_opt_value_valid  out nocopy boolean
   ,p_num_data                 out nocopy number
   ,p_varchar2_data            out nocopy varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |----------------------- < build_resp_profile_val > -----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE build_resp_profile_val
          (p_template_resp_id      in fnd_responsibility.responsibility_id%type
                                      default null
          ,p_template_resp_app_id  in fnd_responsibility.application_id%type
                                      default null
          ,p_new_resp_key          in fnd_responsibility.responsibility_key%type
          ,p_new_resp_app_id       in fnd_responsibility.application_id%type
          ,p_fnd_profile_opt_val_tbl in
                    hr_user_acct_utility.fnd_profile_opt_val_tbl
          ,p_out_profile_opt_val_tbl out
                    hr_user_acct_utility.fnd_profile_opt_val_tbl
          );
--
-- ----------------------------------------------------------------------------
-- |-------------------- < build_func_sec_exclusion_rules > -------------------|
-- ----------------------------------------------------------------------------
PROCEDURE build_func_sec_exclusion_rules
   (p_func_sec_excl_tbl   in hr_user_acct_utility.fnd_resp_functions_tbl
   ,p_out_func_sec_excl_tbl out nocopy hr_user_acct_utility.func_sec_excl_tbl);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------- < create_fnd_resp_functions > ----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_fnd_resp_functions
            (p_resp_key           in fnd_responsibility.responsibility_key%type
            ,p_rule_type          in fnd_resp_functions.rule_type%type
            ,p_rule_name          in varchar2
            ,p_delete_flag        in varchar2 default 'N');
--
-- ----------------------------------------------------------------------------
-- |-------------------------- < update_fnd_user > ---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_fnd_user
  (p_user_id               in number
  ,p_old_password          in varchar2 default hr_api.g_varchar2
  ,p_new_password          in varchar2 default hr_api.g_varchar2
  ,p_end_date              in date default hr_api.g_date
  ,p_email_address         in varchar2 default hr_api.g_varchar2
  ,p_fax                   in varchar2 default hr_api.g_varchar2
  ,p_known_as              in varchar2 default hr_api.g_varchar2
  ,p_language              in varchar2 default hr_api.g_varchar2
  ,p_host_port             in varchar2 default hr_api.g_varchar2
  ,p_employee_id           in number default hr_api.g_number
  ,p_customer_id           in number default hr_api.g_number
  ,p_supplier_id           in number default hr_api.g_number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------- < update_fnd_user_resp_groups > ----------------------|
-- |This procedure is called to update the fnd_user_resp_groups row when the   |
-- |profile option 'ENABLE_SECURITY_GROUPS' = 'N'.                             |
-- ----------------------------------------------------------------------------
--
PROCEDURE update_fnd_user_resp_groups
  (p_user_id               in number
  ,p_responsibility_id     in number
  ,p_resp_application_id   in number
  ,p_security_group_id     in fnd_user_resp_groups.security_group_id%type
  ,p_start_date            in date default hr_api.g_date
  ,p_end_date              in date default hr_api.g_date
  ,p_description           in varchar2 default hr_api.g_varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------- < update_sec_profile_asg > ------------------------|
-- |This procedure is called to update the per_sec_profile_assignments row    |
-- |when the profile option 'ENABLE_SECURITY_GROUPS' = 'N'.                   |
-- ----------------------------------------------------------------------------
--
PROCEDURE update_sec_profile_asg
  (p_sec_profile_asg_id    in
	 per_sec_profile_assignments.sec_profile_assignment_id%type default null
  ,p_user_id               in fnd_user.user_id%type default null
  ,p_responsibility_id     in per_sec_profile_assignments.responsibility_id%type
						default null
  ,p_resp_app_id           in
    per_sec_profile_assignments.responsibility_application_id%type default null
  ,p_security_group_id     in fnd_user_resp_groups.security_group_id%type
						default null
  ,p_start_date            in per_sec_profile_assignments.start_date%type
						default null
  ,p_end_date              in per_sec_profile_assignments.end_date%type
					     default null
  ,p_object_version_number in
      per_sec_profile_assignments.object_version_number%type   default null
  );

--
--
--
END hr_user_acct_internal;

 

/
