--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: perriutl.pkh 120.2.12010000.2 2008/11/28 17:54:14 psengupt ship $ */

  g_enterprise_short_name       per_ri_config_information.config_information1%type;

  FUNCTION create_key_flexfield
             (p_appl_short_Name         in varchar2
             ,p_flex_code               in varchar2
             ,p_structure_code          in varchar2
             ,p_structure_title         in varchar2
             ,p_description             in varchar2
             ,p_view_name               in varchar2 default null
             ,p_freeze_flag             in varchar2 default 'N'
             ,p_enabled_flag            in varchar2 default 'Y'
             ,p_cross_val_flag          in varchar2 default 'N'
             ,p_freeze_rollup_flag      in varchar2 default 'N'
             ,p_dynamic_insert_flag     in varchar2 default 'Y'
             ,p_shorthand_enabled_flag  in varchar2 default 'N'
             ,p_shorthand_prompt        in varchar2 default null
             ,p_shorthand_length        in number   default null)
    RETURN number;

  PROCEDURE create_flex_segments
             (p_appl_short_Name           in varchar2
             ,p_flex_code                 in varchar2
             ,p_structure_code            in varchar2
             ,p_segment_name              in varchar2
             ,p_column_name               in varchar2
             ,p_segment_number            in varchar2
             ,p_enabled_flag              in varchar2 default 'Y'
             ,p_displayed_flag            in varchar2 default 'Y'
             ,p_indexed_flag              in varchar2 default 'Y'
             ,p_value_set                 in varchar2
             ,p_display_size              in number   default 60
             ,p_description_size          in number   default 60
             ,p_concat_size               in number   default 60
             ,p_lov_prompt                in varchar2
             ,p_window_prompt             in varchar2
             ,p_segment_type              in varchar2 default 'CHAR'
             ,p_fed_seg_attribute         in varchar2 default 'N');

  FUNCTION business_group_decision
             (p_configuration_code           in varchar2 default null
             ,p_country_code                 in varchar2
             ,p_number_of_employees          in varchar2 default null
             ,p_payroll_to_process_employees in varchar2 default null
             ,p_hr_support_for_this_country  in varchar2 default null)
    RETURN varchar2;

  FUNCTION legislation_support
              (p_legislation_code       in varchar2
              ,p_application_short_name in varchar2)
    RETURN boolean;

  PROCEDURE set_profile_option_value
             (p_level                in number
             ,p_level_value          in varchar2
             ,p_level_value_app      in varchar2
             ,p_profile_name         in varchar2
             ,p_profile_option_value in varchar2
             ,p_custom_mode          in varchar2 DEFAULT 'FORCE'
             ,p_owner                in varchar2 DEFAULT 'CUSTOM');

  PROCEDURE write_log
             (p_message    in varchar2
             ,p_write_to_log_flag in boolean default TRUE);

  FUNCTION get_enterprise_short_name
             (p_configuration_code    in varchar2)
    RETURN varchar2;

  FUNCTION get_ent_primary_industry
             (p_configuration_code    in varchar2)
    RETURN varchar2;


  FUNCTION get_enterprise_name (p_configuration_code    in varchar2)
                        RETURN varchar2;


  FUNCTION regional_variance_defined (p_configuration_code  in varchar2
                                    ,p_rv_type             in varchar2)
                             RETURN boolean;

  FUNCTION jpg_defined (p_configuration_code  in varchar2
                      ,p_seg_type             in varchar2)
                             RETURN boolean;

  FUNCTION get_bg_job_keyflex_name (p_configuration_code    in varchar2
                                   ,p_bg_country_code       in varchar2)
                        RETURN varchar2;

  FUNCTION get_bg_pos_keyflex_name (p_configuration_code    in varchar2
                                   ,p_bg_country_code       in varchar2)
                        RETURN varchar2;

  FUNCTION get_bg_grd_keyflex_name (p_configuration_code    in varchar2
                                   ,p_bg_country_code       in varchar2)
                        RETURN varchar2;

  FUNCTION get_oc_bg_name(p_configuration_code      in varchar2
                         ,p_operating_company_name  in varchar2)
                        RETURN varchar2;


  FUNCTION get_enterprise_bg_name(p_configuration_code      in varchar2
                                 ,p_enterprise_name         in varchar2)
                        RETURN varchar2;

  FUNCTION get_config_location_code(p_configuration_code      in varchar2
                                   ,p_location_id             in number)
                        RETURN varchar2;

  FUNCTION get_le_bg_name(p_configuration_code          in varchar2
                         ,p_legal_entity_name           in varchar2)
                        RETURN varchar2;

  FUNCTION mandatory_org_info_types(p_legislation_code    in varchar2
                                   ,p_org_classification  in varchar2)
                        RETURN boolean;

  FUNCTION check_currency_enabled(p_legislation_code  in varchar2)
                        RETURN varchar2;

  FUNCTION get_country_currency(p_legislation_code  in varchar2)
                        RETURN varchar2;

  PROCEDURE enable_country_currency(p_legislation_code  in varchar2);

  FUNCTION check_org_class_lookup_tag(p_legislation_code  in varchar2
                                     ,p_lookup_code       in varchar2)
                        RETURN boolean;


  PROCEDURE create_valueset(p_valueset_name           in varchar2
                           ,p_valueset_type           in varchar2);

  PROCEDURE get_selected_country_list(p_configuration_code  varchar2
                                     ,p_config_info_category varchar2
                                     ,p_reg_var_name varchar2
                                     ,p_country_list out nocopy varchar2
                                     ,p_selected_list out nocopy varchar2);

  FUNCTION get_display_country_list(p_configuration_code varchar2
                                   ,p_reg_var_name varchar2
                                   ,p_config_info_category varchar2)
                         RETURN varchar2;

  FUNCTION get_country_list(p_configuration_code varchar2
                           ,p_reg_var_name varchar2
                           ,p_config_info_category varchar2)
                       RETURN varchar2;

  PROCEDURE freeze_and_compile_flexfield
                   (p_appl_short_Name           in varchar2
                   ,p_flex_code                 in varchar2
                   ,p_structure_code            in varchar2);

  FUNCTION get_country_display_name(p_territory_code          in varchar2)
                        RETURN varchar2;

  PROCEDURE submit_int_payroll_request
              (errbuf                   out nocopy varchar2
              ,retcode                  out nocopy number
              ,p_country_tab            in  per_ri_config_datapump_entity.country_tab
              ,p_technical_summary_mode in  boolean default FALSE
              ,p_int_hrms_setup_tab     in  out nocopy
                                            per_ri_config_tech_summary.int_hrms_setup_tab);

  PROCEDURE create_security_profile_assign(
                      p_security_profile_tab       in per_ri_config_fnd_hr_entity.security_profile_tab);

  FUNCTION check_selected_product(p_configuration_code    in varchar2
                                 ,p_product_name          in varchar2)
                        RETURN boolean;

  PROCEDURE update_configuration_status(p_configuration_code    in varchar2);

  FUNCTION determine_country_resp(p_country_code          in varchar2
                                ,p_assign_responsibility in varchar2)
                        RETURN varchar2;

  FUNCTION responsibility_exists(p_country_code          in varchar2
                                ,p_assign_responsibility in varchar2)
                        RETURN boolean;

  PROCEDURE submit_enable_mult_sg_process
                (errbuf                      out nocopy varchar2
                ,retcode                     out nocopy number);

  FUNCTION check_fresh_installation RETURN boolean;

  FUNCTION check_data_pump_exception(p_patch_header_id    in number)
                return boolean;

  PROCEDURE write_data_pump_exception_log
                (p_patch_header_id           in number);

  PROCEDURE assign_misc_responsibility
                (p_configuration_code           in varchar2
                ,p_technical_summary_mode in boolean default FALSE
                ,p_hrms_misc_resp_tab in out nocopy per_ri_config_tech_summary.hrms_misc_resp_tab);

  FUNCTION return_config_entity_name(entity_name       in varchar2)
                        RETURN varchar2;

  FUNCTION return_config_entity_name_pre(entity_name       in varchar2)
                        RETURN varchar2;

  FUNCTION get_location_prompt(p_style            in varchar2
                              ,p_app_column_name  in varchar2)
                        RETURN varchar2;

  PROCEDURE create_valueset_ts_data(p_valueset_name   in varchar2
                           ,p_valueset_type           in varchar2
                           ,p_structure_code          in varchar2
                           ,p_segment_name            in varchar2
                           ,p_segment_number          in varchar2
                           ,p_fed_seg_attribute       in varchar2 default 'N'
                           ,p_valueset_tab            in out nocopy
                                                        per_ri_config_tech_summary.valueset_tab);
  PROCEDURE create_responsibility
             (p_app_short_name            in fnd_application.application_short_name%type
             ,p_resp_key                  in fnd_responsibility_vl.responsibility_name%type
             ,p_responsibility_id         in fnd_responsibility.responsibility_id%type
             ,p_responsibility_name       in fnd_responsibility_tl.responsibility_name%type
             ,p_owner                     in varchar2
             ,p_data_group_app_short_name in fnd_application.application_short_name%type
             ,p_data_group_name           in fnd_data_groups_standard_view.data_group_name%type
             ,p_menu_name                 in fnd_menus.menu_name%type
             ,p_start_date                in varchar2
             ,p_end_date                  in varchar2
             ,p_description               in varchar2
             ,p_group_app_short_name      in fnd_application.application_short_name%type
             ,p_request_group_name        in fnd_request_groups.request_group_name%type
             ,p_version                   in varchar2
             ,p_web_host_name             in fnd_responsibility.web_host_name%type
             ,p_web_agent_name            in fnd_responsibility.web_agent_name%type);

  PROCEDURE create_more_hrms_resps
              (p_configuration_code        in varchar2
              ,p_security_profile_tab      in per_ri_config_fnd_hr_entity.security_profile_tab
              ,p_int_bg_resp_tab           in per_ri_config_fnd_hr_entity.int_bg_resp_tab
              ,p_technical_summary_mode    in boolean default FALSE
              ,p_hrms_resp_main_tab        in out nocopy per_ri_config_tech_summary.hrms_resp_tab
              ,p_more_profile_resp_tab     in out nocopy per_ri_config_tech_summary.profile_resp_tab
              ,p_more_int_profile_resp_tab in out nocopy per_ri_config_tech_summary.profile_resp_tab);

  PROCEDURE create_resp_and_profile
              (p_configuration_code        in varchar2
              ,p_security_profile_name     in varchar2
              ,p_responsibility_key        in varchar2
              ,p_technical_summary_mode    in boolean default FALSE
              ,p_bg_sg_ut_profile_resp_tab in out nocopy per_ri_config_tech_summary.profile_resp_tab
              ,p_hrms_resp_one_tab in out nocopy per_ri_config_tech_summary.hrms_resp_tab);

  FUNCTION get_responsibility_name (p_responsibility_key    in varchar2)
                        RETURN varchar2;

   FUNCTION get_business_group_name
    RETURN varchar2;

END per_ri_config_utilities;

/
