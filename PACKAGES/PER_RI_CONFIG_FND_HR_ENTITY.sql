--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_FND_HR_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_FND_HR_ENTITY" AUTHID CURRENT_USER AS
/* $Header: perrichd.pkh 120.2.12000000.1 2007/01/22 03:39:40 appldev noship $ */

  TYPE security_profile_rec IS RECORD (security_profile_name   varchar2(60)
                                      ,responsibility_key      varchar2(60));

  TYPE security_profile_tab IS TABLE OF
      security_profile_rec
  INDEX BY BINARY_INTEGER;

  TYPE int_bg_resp_rec IS RECORD (security_profile_name   varchar2(60)
                                 ,responsibility_key      varchar2(60));

  TYPE int_bg_resp_tab IS TABLE OF
      int_bg_resp_rec
  INDEX BY BINARY_INTEGER;

  l_security_profile_tab              security_profile_tab;
  l_security_profile_tab              security_profile_tab;


  PROCEDURE create_global_grp_cmp_cost_kf
              (p_configuration_code           in  varchar2
              ,p_technical_summary_mode       in  boolean default FALSE
              ,p_kf_grp_tab                   in out nocopy per_ri_config_tech_summary.kf_grp_tab
              ,p_kf_cmp_tab                   in out nocopy per_ri_config_tech_summary.kf_cmp_tab
              ,p_kf_cost_tab                  in out nocopy per_ri_config_tech_summary.kf_cost_tab
              ,p_kf_grp_seg_tab               in out nocopy per_ri_config_tech_summary.kf_grp_seg_tab
              ,p_kf_cmp_seg_tab               in out nocopy per_ri_config_tech_summary.kf_cmp_seg_tab
              ,p_kf_cost_seg_tab              in out nocopy per_ri_config_tech_summary.kf_cost_seg_tab
              );

  PROCEDURE create_global_job_pos_kf (p_configuration_code in varchar2
                                     ,p_technical_summary_mode in boolean default FALSE
                                     ,p_kf_job_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_tab
                                     ,p_kf_pos_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_tab
                                     ,p_kf_job_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_seg_tab
                                     ,p_kf_pos_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_seg_tab);

  PROCEDURE create_global_pos_kf (p_configuration_code in varchar2
                                 ,p_technical_summary_mode in boolean default FALSE
                                 ,p_kf_pos_tab in out nocopy
                                           per_ri_config_tech_summary.kf_pos_tab
                                 ,p_kf_pos_seg_tab in out nocopy
                                           per_ri_config_tech_summary.kf_pos_seg_tab);

  PROCEDURE create_global_grd_kf (p_configuration_code in varchar2
                                 ,p_technical_summary_mode in boolean default FALSE
                                 ,p_kf_grd_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_tab
                                 ,p_kf_grd_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_seg_tab);

  PROCEDURE create_default_value_sets (p_configuration_code in varchar2);

 PROCEDURE create_hrms_responsibility (p_configuration_code   in varchar2
                                      ,p_security_profile_tab in out nocopy security_profile_tab
                                      ,p_technical_summary_mode in boolean default FALSE
                                      ,p_hrms_resp_tab in out nocopy
                                         per_ri_config_tech_summary.hrms_resp_tab);

  PROCEDURE create_jobs_rv_keyflex (p_configuration_code in varchar2
                                   ,p_technical_summary_mode in boolean default FALSE
                                   ,p_kf_job_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_rv_tab
                                   ,p_kf_job_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_rv_seg_tab);

  PROCEDURE create_positions_rv_keyflex (p_configuration_code in varchar2
                                        ,p_technical_summary_mode in boolean default FALSE
                                        ,p_kf_pos_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_rv_tab
                                        ,p_kf_pos_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_rv_seg_tab);

  PROCEDURE create_grades_rv_keyflex (p_configuration_code in varchar2
                                     ,p_technical_summary_mode in boolean default FALSE
                                     ,p_kf_grd_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_rv_tab
                                     ,p_kf_grd_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_rv_seg_tab);

  PROCEDURE create_jobs_no_rv_keyflex (p_configuration_code in varchar2
                                      ,p_technical_summary_mode in boolean default FALSE
                                      ,p_kf_job_no_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_no_rv_tab
                                      ,p_kf_job_no_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_no_rv_seg_tab);

  PROCEDURE create_positions_no_rv_keyflex (p_configuration_code in varchar2
                                           ,p_technical_summary_mode in boolean default FALSE
                                           ,p_kf_pos_no_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_no_rv_tab
                                      ,p_kf_pos_no_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_no_rv_seg_tab);

  PROCEDURE create_grades_no_rv_keyflex (p_configuration_code in varchar2
                                        ,p_technical_summary_mode in boolean default FALSE
                                        ,p_kf_grd_no_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_no_rv_tab
                                        ,p_kf_grd_no_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_no_rv_seg_tab);

  PROCEDURE create_application_level_resp(p_configuration_code     in varchar2
                                         ,p_technical_summary_mode in boolean default FALSE
                                         ,p_profile_apps_tab       in out nocopy
                                                 per_ri_config_tech_summary.profile_apps_tab);


  PROCEDURE create_resp_level_profile(p_configuration_code  in varchar2
                                     ,p_responsibility_key  in varchar2
                                     ,p_technical_summary_mode in boolean default FALSE
                                     ,p_profile_resp_tab    in out nocopy
                                                               per_ri_config_tech_summary.profile_resp_tab);

    PROCEDURE create_bg_id_and_sg_id_profile(p_configuration_code    in varchar2
                                          ,p_responsibility_key    in varchar2
                                          ,p_business_group_name   in varchar2
                                          ,p_technical_summary_mode  in boolean default FALSE
                                          ,p_bg_sg_ut_profile_resp_tab in out nocopy
                                                       per_ri_config_tech_summary.profile_resp_tab);

END per_ri_config_fnd_hr_entity;


 

/
