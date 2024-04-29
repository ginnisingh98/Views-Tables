--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_TECH_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_TECH_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: perricts.pkh 120.1.12000000.2 2007/09/21 11:07:22 vdabgar noship $ */

  -- Keyflex Value Set Record
  TYPE tech_summary_keyflex_value_set IS RECORD
         (value_set_name            fnd_flex_value_sets.flex_value_set_name%type
         ,description               fnd_flex_value_sets.description%type
         ,security_available        fnd_flex_value_sets.security_enabled_flag%type
         ,enable_longlist           fnd_flex_value_sets.longlist_flag%type
         ,format_type               fnd_flex_value_sets.format_type%type
         ,maximum_size              fnd_flex_value_sets.maximum_size%type
         ,precision                 fnd_flex_value_sets.number_precision%type
         ,numbers_only              fnd_flex_value_sets.numeric_mode_enabled_flag%type
         ,uppercase_only            fnd_flex_value_sets.uppercase_only_flag%type
         ,right_justify_zero_fill   fnd_flex_value_sets.numeric_mode_enabled_flag%type
         ,min_value                 fnd_flex_value_sets.minimum_value%type
         ,max_value                 fnd_flex_value_sets.maximum_value%type);

  TYPE valueset_tab IS TABLE OF
         tech_summary_keyflex_value_set
  INDEX BY BINARY_INTEGER;

  -- Keyflex Segment Record
  TYPE tech_summary_keyflex_segment IS RECORD
         (appl_short_name  fnd_application.application_short_name%type
         ,flex_code        fnd_id_flex_structures_vl.id_flex_structure_code%type
         ,structure_code   fnd_id_flex_structures_vl.id_flex_structure_name%type
         ,segment_name     fnd_id_flex_segments_vl.segment_name%type
         ,column_name      fnd_id_flex_segments_vl.application_column_name%type
         ,segment_number   number(8)
         ,value_set        fnd_flex_value_sets.flex_value_set_name%type
         ,lov_prompt       fnd_id_flex_segments_vl.segment_name%type
         ,segment_type     varchar2(80)
         ,window_prompt    fnd_id_flex_segments_vl.segment_name%type
         --
         ,vs_value_set_name            fnd_flex_value_sets.flex_value_set_name%type
         ,vs_description               fnd_flex_value_sets.description%type
         ,vs_security_available        fnd_flex_value_sets.security_enabled_flag%type
         ,vs_enable_longlist           fnd_flex_value_sets.longlist_flag%type
         ,vs_format_type               fnd_flex_value_sets.format_type%type
         ,vs_maximum_size              fnd_flex_value_sets.maximum_size%type
         ,vs_precision                 fnd_flex_value_sets.number_precision%type
         ,vs_numbers_only              fnd_flex_value_sets.numeric_mode_enabled_flag%type
         ,vs_uppercase_only            fnd_flex_value_sets.uppercase_only_flag%type
         ,vs_right_justify_zero_fill   fnd_flex_value_sets.numeric_mode_enabled_flag%type
         ,vs_min_value                 fnd_flex_value_sets.minimum_value%type
         ,vs_max_value                 fnd_flex_value_sets.maximum_value%type
         );

  TYPE kf_segment_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_job_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_job_rv_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_pos_rv_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_grd_rv_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_grd_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_pos_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_grp_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_grd_no_rv_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_cmp_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_cost_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  TYPE kf_pos_no_rv_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;


  -- Keyflex Structure Record
  TYPE tech_summary_keyflex_structure IS RECORD
         (appl_short_name   fnd_application.application_short_name%type
         ,flex_code         fnd_id_flex_structures_vl.id_flex_structure_code%type
         ,structure_code    fnd_id_flex_structures_vl.id_flex_structure_name%type
         ,structure_title   fnd_id_flex_structures_vl.id_flex_structure_name%type
         ,description       fnd_id_flex_structures_vl.description%type
         );

  -- Keyflex Structure  Table
  TYPE kf_structure_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure JOB Table
  TYPE kf_job_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure JOB Table (create_jobs_no_rv_keyflex)
  TYPE kf_job_no_rv_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Segments JOB Table (create_jobs_no_rv_keyflex)
  TYPE kf_job_no_rv_seg_tab IS TABLE OF
         tech_summary_keyflex_segment
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure POS Table (create_positions_no_rv_keyflex)
  TYPE kf_pos_no_rv_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure GRD Table (create_grades_no_rv_keyflex)
  TYPE kf_grd_no_rv_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure GRD Table (create_grades_rv_keyflex)
  TYPE kf_grd_rv_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure JOB Table (create_jobs_rv_keyflex)
  TYPE kf_job_rv_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure POS Table (create_positions_rv_keyflex)
  TYPE kf_pos_rv_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure POS Table
  TYPE kf_pos_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure GRD Table
  TYPE kf_grd_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure CMP Table
  TYPE kf_cmp_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure GRP Table
  TYPE kf_grp_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Keyflex Structure COST Table
  TYPE kf_cost_tab IS TABLE OF
         tech_summary_keyflex_structure
  INDEX BY BINARY_INTEGER;

  -- Users Record
  TYPE tech_summary_user_rec IS RECORD
         (user_name                     fnd_user.user_name%type
         ,start_date                    date
         ,description                   fnd_user.description%type
         );


  -- Users Table
  TYPE user_tab IS TABLE OF
         tech_summary_user_rec
  INDEX BY BINARY_INTEGER;


  -- User Responsibility Record
   TYPE tech_summary_resp_rec IS RECORD
           (user_name                    fnd_user.user_name%type
           ,resp_key                     fnd_responsibility_vl.responsibility_name%type
           ,app_short_name               fnd_application.application_short_name%type
           ,security_group               fnd_security_groups_vl.security_group_name%type
           ,owner                        varchar2(100)
           ,start_date                   varchar2(80)
           ,end_date                     varchar2(80)
           --,start_date                   fnd_responsibility_vl.start_date%type
           --,end_date                     fnd_responsibility_vl.end_date%type
           ,description                  fnd_responsibility_vl.description%type);

  --User Responsibility Table
  TYPE resp_tab IS TABLE OF
          tech_summary_resp_rec
  INDEX BY BINARY_INTEGER;

  --User HRMS Responsibility Table
  TYPE hrms_resp_tab IS TABLE OF
          tech_summary_resp_rec
  INDEX BY BINARY_INTEGER;

  --User Misc HRMS Responsibility Table
  TYPE hrms_misc_resp_tab IS TABLE OF
          tech_summary_resp_rec
  INDEX BY BINARY_INTEGER;

  -- Profile Options Record
  TYPE tech_summary_profile_rec IS RECORD
         (level                varchar2(80)
         ,level_value          varchar2(80)
         ,level_value_app      varchar2(80)
         ,profile_name         fnd_profile_options.profile_option_name%type
         ,profile_option_value fnd_profile_option_values.profile_option_value%type);

  --Profile Options Table Site Level
  TYPE profile_tab IS TABLE OF
          tech_summary_profile_rec
  INDEX BY BINARY_INTEGER;

  --Profile Options Table Application  Level
  TYPE profile_apps_tab IS TABLE OF
          tech_summary_profile_rec
  INDEX BY BINARY_INTEGER;

  --Profile Options Table Resposibility  Level
  TYPE profile_resp_tab IS TABLE OF
          tech_summary_profile_rec
  INDEX BY BINARY_INTEGER;

  --Profile Options Table Site Level
  TYPE profile_dpe_ent_tab IS TABLE OF
          tech_summary_profile_rec
  INDEX BY BINARY_INTEGER;

  -- Organizations Record
  TYPE tech_summary_org_rec IS RECORD
          (effective_date               date
          ,date_from                    date
          ,business_grp_name            per_business_groups.name%type
          ,name                         per_business_groups.name%type
          ,location_code                per_ri_config_locations.description%type -- fix for 4457389
          ,internal_external_flag       hr_all_organization_units.internal_external_flag%type);

  -- Enterprise Table
  TYPE org_ent_tab IS TABLE OF
      tech_summary_org_rec
  INDEX BY BINARY_INTEGER;

  -- Operating Company table
  TYPE org_oc_tab IS TABLE OF
      tech_summary_org_rec
  INDEX BY BINARY_INTEGER;

  -- Legal Entity table
  TYPE org_le_tab IS TABLE OF
      tech_summary_org_rec
  INDEX BY BINARY_INTEGER;

  -- Organizations Hierarchy Record
  TYPE org_hierarchy_rec IS RECORD
          (name                             per_organization_structures.name%type
          ,org_structure_version_id         per_org_structure_versions.org_structure_version_id%type);

  -- Organizations Hierarchy Table
  TYPE org_hierarchy_tab IS TABLE OF
      org_hierarchy_rec
  INDEX BY BINARY_INTEGER;

  -- Organizations Hierarchy Elements Record
  TYPE org_hierarchy_ele_rec IS RECORD
          (org_structure_version_id     per_org_structure_versions.org_structure_version_id%type
          ,parent_organization_name     hr_all_organization_units.name%type
          ,child_organization_name      hr_all_organization_units.name%type);

  -- Organizations Hierarchy Elements OC Table
  TYPE org_hierarchy_ele_oc_tab IS TABLE OF
      org_hierarchy_ele_rec
  INDEX BY BINARY_INTEGER;

  -- Organizations Hierarchy Elements LE Table
  TYPE org_hierarchy_ele_le_tab IS TABLE OF
      org_hierarchy_ele_rec
  INDEX BY BINARY_INTEGER;


  -- Organizations Classification Record
  TYPE org_class_rec IS RECORD
          (effective_date               date
          ,date_from                    date
          ,business_grp_name            per_business_groups.name%type
          ,org_classif_code             per_business_groups.name%type
          ,organization_name            hr_all_organization_units.name%type);


  -- Organizations Classification Record

  -- Enterprise Org Class Table
  TYPE org_ent_class_tab IS TABLE OF
      org_class_rec
  INDEX BY BINARY_INTEGER;

  -- Operating Company Org Class table
  TYPE org_oc_class_tab IS TABLE OF
      org_class_rec
  INDEX BY BINARY_INTEGER;

  -- Legal Entity Org Class table
  TYPE org_le_class_tab IS TABLE OF
      org_class_rec
  INDEX BY BINARY_INTEGER;


  TYPE location_rec IS RECORD
          (location_code                  per_ri_config_locations.description%type --fix for 4457389
          ,description                    per_ri_config_locations.description%type
          ,address_line_1                 per_ri_config_locations.address_line_1%type
          ,address_line_2                 per_ri_config_locations.address_line_2%type
          ,address_line_3                 per_ri_config_locations.address_line_3%type
          ,bill_to_site_flag              hr_locations_all.bill_to_site_flag%type
          ,country                        per_ri_config_locations.country%type
          ,in_organization_flag           hr_locations_all.in_organization_flag%type
          ,postal_code                    per_ri_config_locations.postal_code%type
          ,receiving_site_flag            hr_locations_all.receiving_site_flag%type
          ,region_1                       per_ri_config_locations.region_1%type
          ,region_2                       per_ri_config_locations.region_2%type
          ,region_3                       per_ri_config_locations.region_3%type
          ,ship_to_site_flag              hr_locations_all.ship_to_site_flag%type
          ,style                          per_ri_config_locations.style%type
          ,telephone_number_1             per_ri_config_locations.telephone_number_1%type
          ,telephone_number_2             per_ri_config_locations.telephone_number_2%type
          ,telephone_number_3             per_ri_config_locations.telephone_number_3%type
          ,town_or_city                   per_ri_config_locations.town_or_city%type
          ,loc_information13              per_ri_config_locations.loc_information13%type
          ,loc_information14              per_ri_config_locations.loc_information14%type
          ,loc_information15              per_ri_config_locations.loc_information15%type
          ,loc_information16              per_ri_config_locations.loc_information16%type
          ,loc_information17              per_ri_config_locations.loc_information17%type
          ,loc_information18              per_ri_config_locations.loc_information18%type
          ,loc_information19              per_ri_config_locations.loc_information19%type
          ,loc_information20              per_ri_config_locations.loc_information20%type
          ,ship_to_location_code          per_ri_config_locations.description%type); -- fix for 4457389

  TYPE location_tab IS TABLE OF
      location_rec
  INDEX BY BINARY_INTEGER;

  TYPE bg_rec IS RECORD
          (effective_date             date
          ,language_code              fnd_languages.language_code%type
          ,date_from                  date
          ,name                       hr_all_organization_units.name%type
          ,type                       hr_all_organization_units.type%type
          ,internal_external_flag     hr_all_organization_units.internal_external_flag%type
          ,short_name                 hr_all_organization_units.name%type
          ,emp_gen_method             per_business_groups.method_of_generation_emp_num%type
          ,app_gen_method             per_business_groups.method_of_generation_apl_num%type
          ,cwk_gen_method             per_business_groups.method_of_generation_cwk_num%type
          ,legislation_code           per_business_groups.legislation_code%type
          ,currency_code              per_business_groups.currency_code%type
          ,fiscal_year_start          date
          ,min_work_age               number(8)
          ,max_work_age               number(8)
          ,location_code              hr_all_organization_units.name%type
          ,grade_flex_stru_code       per_business_groups.grade_structure%type
          ,group_flex_stru_code       per_business_groups.people_group_structure%type
          ,job_flex_stru_code         per_business_groups.job_structure%type
          ,cost_flex_stru_code        per_business_groups.cost_allocation_structure%type
          ,position_flex_stru_code    per_business_groups.position_structure%type
          ,security_group_name        per_business_groups.security_group_id%type
          ,competence_flex_stru_code  per_business_groups.competence_structure%type);

  TYPE bg_tab IS TABLE OF
      bg_rec
  INDEX BY BINARY_INTEGER;

  TYPE sg_rec IS RECORD
          (security_group_name        fnd_security_groups_vl.security_group_name%type
          ,business_group_name        per_business_groups.name%type);

  TYPE sg_tab IS TABLE OF
      sg_rec
  INDEX BY BINARY_INTEGER;

  TYPE l_clob_rec_type is RECORD
          (table_name  varchar2(30),
           xmldoc      clob);


  -- International HRMS Setup Record
  TYPE tech_summary_int_hrms_setup IS RECORD
         (legislation_code  pay_leg_setup_defaults.legislation_code%type
         ,currency_code     pay_leg_setup_defaults.currency_code%type
         ,tax_start_date    pay_leg_setup_defaults.tax_start_date%type
         ,install_tax_unit  pay_leg_setup_defaults.tax_unit_flag%type);

  --International HRMS Setup Table
  TYPE int_hrms_setup_tab IS TABLE OF
          tech_summary_int_hrms_setup
  INDEX BY BINARY_INTEGER;

  -- Post Install Steps Record
  TYPE tech_summary_post_install IS RECORD
         (legislation_code        per_business_groups.legislation_code%type
         ,applicaton_short_name   fnd_application.application_short_name%type);

  --Post Install Steps Table
  TYPE post_install_tab IS TABLE OF
          tech_summary_post_install
  INDEX BY BINARY_INTEGER;

  -- Get SQLS for various entities
  FUNCTION get_business_grp_sql
             (p_business_grp_tab            in out nocopy per_ri_config_tech_summary.bg_tab)
              return clob;


  FUNCTION get_org_sql (p_org_ent_tab in out nocopy
                                 per_ri_config_tech_summary.org_ent_tab
                          ,p_org_oc_tab in out nocopy
                                 per_ri_config_tech_summary.org_oc_tab
                          ,p_org_le_tab in out nocopy
                                 per_ri_config_tech_summary.org_le_tab)
             return clob ;

  FUNCTION get_org_class_sql (p_org_ent_class_tab in out nocopy
                                 per_ri_config_tech_summary.org_ent_class_tab
                          ,p_org_oc_class_tab in out nocopy
                                 per_ri_config_tech_summary.org_oc_class_tab
                          ,p_org_le_class_tab in out nocopy
                                 per_ri_config_tech_summary.org_le_class_tab)
             return clob ;

  FUNCTION get_org_class_sql_for_pv ( p_org_ent_tab               in per_ri_config_tech_summary.org_ent_tab
                                    ,p_org_oc_tab               in per_ri_config_tech_summary.org_oc_tab
                                    ,p_org_le_tab               in per_ri_config_tech_summary.org_le_tab
                                    ,p_org_ent_class_tab        in per_ri_config_tech_summary.org_ent_class_tab
                                    ,p_org_oc_class_tab         in per_ri_config_tech_summary.org_oc_class_tab
                                    ,p_org_le_class_tab         in per_ri_config_tech_summary.org_le_class_tab)
                            return clob;


  FUNCTION get_locations_sql (p_location_tab in out nocopy
                                per_ri_config_tech_summary.location_tab)
             return clob;

  FUNCTION get_user_sql (p_user_tab in out nocopy per_ri_config_tech_summary.user_tab)

            return clob;

  FUNCTION get_resp_sql (
                          p_resp_tab            in out nocopy per_ri_config_tech_summary.resp_tab
                         ,p_hrms_resp_tab       in out nocopy per_ri_config_tech_summary.hrms_resp_tab
                         ,p_hrms_misc_resp_tab  in out nocopy per_ri_config_tech_summary.hrms_resp_tab
                        )
            return clob;

  FUNCTION get_profile_sql (
                                 p_profile_tab in out nocopy per_ri_config_tech_summary.profile_tab,
                                 p_profile_dpe_ent_tab in out nocopy per_ri_config_tech_summary.profile_dpe_ent_tab
                             )
                      return clob;

  FUNCTION get_profile_apps_sql (
                                 p_profile_apps_tab in out nocopy per_ri_config_tech_summary.profile_apps_tab
                                )
                                return clob;


  FUNCTION get_profile_resp_sql (
                                  p_profile_resp_tab in out nocopy per_ri_config_tech_summary.profile_resp_tab
                               )
                                return clob ;

  FUNCTION get_keyflex_structure_sql
                                 (
                                    p_kf_job_tab                in out nocopy per_ri_config_tech_summary.kf_job_tab,
                                    p_kf_job_rv_tab             in out nocopy per_ri_config_tech_summary.kf_job_rv_tab,
                                    p_kf_job_no_rv_tab          in out nocopy per_ri_config_tech_summary.kf_job_no_rv_tab,
                                    p_kf_pos_tab                in out nocopy per_ri_config_tech_summary.kf_pos_tab,
                                    p_kf_pos_rv_tab             in out nocopy per_ri_config_tech_summary.kf_pos_rv_tab,
                                    p_kf_pos_no_rv_tab          in out nocopy per_ri_config_tech_summary.kf_pos_no_rv_tab,
                                    p_kf_grd_tab                in out nocopy per_ri_config_tech_summary.kf_grd_tab,
                                    p_kf_grd_rv_tab             in out nocopy per_ri_config_tech_summary.kf_grd_rv_tab,
                                    p_kf_grd_no_rv_tab          in out nocopy per_ri_config_tech_summary.kf_grd_no_rv_tab,
                                    p_kf_cmp_tab                in out nocopy per_ri_config_tech_summary.kf_cmp_tab,
                                    p_kf_grp_tab                in out nocopy per_ri_config_tech_summary.kf_grp_tab,
                                    p_kf_cost_tab               in out nocopy per_ri_config_tech_summary.kf_cost_tab,
                                    p_kf_job_str_clob           out nocopy clob,
                                    p_kf_job_rv_str_clob        out nocopy clob,
                                    p_kf_job_no_rv_str_clob     out nocopy clob,
                                    p_kf_pos_str_clob           out nocopy clob,
                                    p_kf_pos_rv_str_clob        out nocopy clob,
                                    p_kf_pos_no_rv_str_clob     out nocopy clob,
                                    p_kf_grd_str_clob           out nocopy clob,
                                    p_kf_cmp_str_clob           out nocopy clob,
                                    p_kf_grp_str_clob           out nocopy clob,
                                    p_kf_cost_str_clob          out nocopy clob
                                  )
                                return clob ;

  FUNCTION   get_keyflex_segment_sql
                                  (
                                    p_kf_job_seg_tab            in out nocopy per_ri_config_tech_summary.kf_job_seg_tab,
                                    p_kf_job_rv_seg_tab         in out nocopy per_ri_config_tech_summary.kf_job_rv_seg_tab,
                                    p_kf_job_no_rv_seg_tab      in out nocopy per_ri_config_tech_summary.kf_job_no_rv_seg_tab,
                                    p_kf_pos_seg_tab            in out nocopy per_ri_config_tech_summary.kf_pos_seg_tab,
                                    p_kf_pos_rv_seg_tab         in out nocopy per_ri_config_tech_summary.kf_pos_rv_seg_tab,
                                    p_kf_pos_no_rv_seg_tab      in out nocopy per_ri_config_tech_summary.kf_pos_no_rv_seg_tab,
                                    p_kf_grd_seg_tab            in out nocopy per_ri_config_tech_summary.kf_grd_seg_tab,
                                    p_kf_grd_rv_seg_tab         in out nocopy per_ri_config_tech_summary.kf_grd_rv_seg_tab,
                                    p_kf_grd_no_rv_seg_tab      in out nocopy per_ri_config_tech_summary.kf_grd_no_rv_seg_tab,
                                    p_kf_grp_seg_tab            in out nocopy per_ri_config_tech_summary.kf_grp_seg_tab,
                                    p_kf_cmp_seg_tab            in out nocopy per_ri_config_tech_summary.kf_cmp_seg_tab,
                                    p_kf_cost_seg_tab           in out nocopy per_ri_config_tech_summary.kf_cost_seg_tab,
                                    p_kf_job_seg_clob           out nocopy clob,
                                    p_kf_job_rv_seg_clob        out nocopy clob,
                                    p_kf_job_no_rv_seg_clob     out nocopy clob,
                                    p_kf_pos_seg_clob           out nocopy clob,
                                    p_kf_pos_rv_seg_clob        out nocopy clob,
                                    p_kf_pos_no_rv_seg_clob     out nocopy clob,
                                    p_kf_grd_seg_clob           out nocopy clob,
                                    p_kf_grd_rv_seg_clob        out nocopy clob,
                                    p_kf_grd_no_rv_seg_clob     out nocopy clob,
                                    p_kf_grp_seg_clob           out nocopy clob,
                                    p_kf_cmp_seg_clob           out nocopy clob,
                                    p_kf_cost_seg_clob          out nocopy clob
                                  )
                                return clob;

  FUNCTION   get_keyflex_str_seg_sql_for_pv
                                 (  p_kf_job_tab 		in per_ri_config_tech_summary.kf_job_tab,
				    p_kf_job_rv_tab 		in per_ri_config_tech_summary.kf_job_rv_tab,
				    p_kf_job_no_rv_tab 		in per_ri_config_tech_summary.kf_job_no_rv_tab,
				    p_kf_pos_tab 		in per_ri_config_tech_summary.kf_pos_tab,
				    p_kf_pos_rv_tab 		in per_ri_config_tech_summary.kf_pos_rv_tab,
				    p_kf_pos_no_rv_tab 		in per_ri_config_tech_summary.kf_pos_no_rv_tab,
				    p_kf_grd_tab 		in per_ri_config_tech_summary.kf_grd_tab,
				    p_kf_grd_rv_tab 		in per_ri_config_tech_summary.kf_grd_rv_tab,
				    p_kf_grd_no_rv_tab 		in per_ri_config_tech_summary.kf_grd_no_rv_tab,
				    p_kf_cmp_tab 		in per_ri_config_tech_summary.kf_cmp_tab,
				    p_kf_grp_tab 		in per_ri_config_tech_summary.kf_grp_tab,
				    p_kf_cost_tab 		in per_ri_config_tech_summary.kf_cost_tab,
				    p_kf_job_seg_tab 		in per_ri_config_tech_summary.kf_job_seg_tab,
                                    p_kf_job_rv_seg_tab 	in per_ri_config_tech_summary.kf_job_rv_seg_tab,
                                    p_kf_job_no_rv_seg_tab 	in per_ri_config_tech_summary.kf_job_no_rv_seg_tab,
                                    p_kf_pos_seg_tab 		in per_ri_config_tech_summary.kf_pos_seg_tab,
                                    p_kf_pos_rv_seg_tab 	in per_ri_config_tech_summary.kf_pos_rv_seg_tab,
                                    p_kf_pos_no_rv_seg_tab 	in per_ri_config_tech_summary.kf_pos_no_rv_seg_tab,
                                    p_kf_grd_seg_tab 		in per_ri_config_tech_summary.kf_grd_seg_tab,
                                    p_kf_grd_rv_seg_tab 	in per_ri_config_tech_summary.kf_grd_rv_seg_tab,
                                    p_kf_grd_no_rv_seg_tab 	in per_ri_config_tech_summary.kf_grd_no_rv_seg_tab,
                                    p_kf_grp_seg_tab 		in per_ri_config_tech_summary.kf_grp_seg_tab,
                                    p_kf_cmp_seg_tab 		in per_ri_config_tech_summary.kf_cmp_seg_tab,
                                    p_kf_cost_seg_tab 		in per_ri_config_tech_summary.kf_cost_seg_tab
                                  ) return clob;

  FUNCTION  get_int_hrms_setup_sql (
                                    p_int_hrms_setup_tab in out nocopy per_ri_config_tech_summary.int_hrms_setup_tab
                                  )
                                return clob ;



  FUNCTION  get_security_profile_sql (
                                    p_security_profile_tab in out nocopy per_ri_config_tech_summary.sg_tab
                                  )
                                return clob ;

  FUNCTION  get_org_hierarchy_sql (
                                    p_org_hierarchy_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_tab
                                  )
                                return clob ;

  FUNCTION  get_org_hierarchy_ele_sql (
                                     p_org_hierarchy_ele_oc_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_oc_tab
                                    ,p_org_hierarchy_ele_le_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_le_tab
                                  )
                                return clob ;

  FUNCTION  get_org_hier_ele_sql_for_pv (
				     p_org_hierarchy_ele_oc_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_oc_tab
				    ,p_org_hierarchy_ele_le_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_le_tab
				  )
				return clob ;

  FUNCTION  get_post_install_sql (
                                    p_post_install_tab  in out nocopy per_ri_config_tech_summary.post_install_tab
                                  )return clob ;


  FUNCTION fetch_clob(p_in_clob IN CLOB,
		    p_row_tag IN VARCHAR2,
		    p_row_set_tag IN VARCHAR2)
         return clob ;

  FUNCTION form_xml(P_NODE_TYPE IN varchar2,  -- Indicates the node type (i.e start_tag/end_tag/value)
		  P_NODE IN VARCHAR2, -- Indicates the node value
		  P_DATA IN VARCHAR2) -- Indicates the data value
		  return clob;

  FUNCTION get_keyflex_str_seg_dat_for_pv
                                 (  p_kf_structure_tab 		in per_ri_config_tech_summary.kf_structure_tab,
				    p_kf_segment_tab 		in per_ri_config_tech_summary.kf_segment_tab,
				    p_keyflex_name		in varchar2
                                  ) return clob;

END per_ri_config_tech_summary;


 

/
