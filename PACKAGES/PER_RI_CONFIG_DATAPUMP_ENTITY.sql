--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_DATAPUMP_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_DATAPUMP_ENTITY" AUTHID CURRENT_USER AS
/* $Header: perridpe.pkh 120.2.12010000.3 2008/12/16 10:26:51 psengupt ship $ */

  TYPE location_rec IS RECORD (location_string   varchar2(3200));

  TYPE location_tab IS TABLE OF
      location_rec
  INDEX BY BINARY_INTEGER;

  TYPE country_rec IS RECORD (territory_code   varchar2(60));

  TYPE country_tab IS TABLE OF
      country_rec
  INDEX BY BINARY_INTEGER;

  l_country_tab                   country_tab;

  PROCEDURE create_locations_batch_lines
              (p_configuration_code          in varchar2
              ,p_batch_header_id             in number
              ,p_multiple_config_upload      in boolean default FALSE
              ,p_technical_summary_mode      in boolean default FALSE
              ,p_location_tab                in out nocopy per_ri_config_tech_summary.location_tab
              );

  PROCEDURE create_enterprise_batch_lines
              (p_configuration_code          in varchar2
              ,p_batch_header_id             in number
              ,p_multiple_config_upload      in boolean default FALSE
              ,p_technical_summary_mode      in boolean default FALSE
              ,p_org_ent_tab                 in out nocopy per_ri_config_tech_summary.org_ent_tab
              ,p_org_ent_class_tab           in out nocopy per_ri_config_tech_summary.org_ent_class_tab
              ,p_org_hierarchy_tab           in out nocopy per_ri_config_tech_summary.org_hierarchy_tab
              ,p_profile_dpe_ent_tab         in out nocopy per_ri_config_tech_summary.profile_dpe_ent_tab
              );

  PROCEDURE create_oper_comp_batch_lines
              (p_configuration_code          in varchar2
              ,p_batch_header_id             in number
              ,p_multiple_config_upload      in boolean default FALSE
              ,p_technical_summary_mode      in boolean default FALSE
              ,p_org_oc_tab                  in out nocopy per_ri_config_tech_summary.org_oc_tab
              ,p_org_oc_class_tab            in out nocopy per_ri_config_tech_summary.org_oc_class_tab
              ,p_org_hierarchy_ele_oc_tab    in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_oc_tab
              );

  PROCEDURE create_le_batch_lines
              (p_configuration_code          in varchar2
              ,p_batch_header_id             in number
              ,p_multiple_config_upload      in boolean default FALSE
              ,p_technical_summary_mode      in boolean default FALSE
              ,p_org_le_tab                  in out nocopy per_ri_config_tech_summary.org_le_tab
              ,p_org_le_class_tab            in out nocopy per_ri_config_tech_summary.org_le_class_tab
              ,p_org_hierarchy_ele_le_tab    in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_le_tab
              );
  PROCEDURE create_bg_batch_lines
              (p_batch_header_id             in number
              ,p_configuration_code          in varchar2
              ,p_country_tab_out             in out nocopy country_tab
              ,p_multiple_config_upload      in boolean default FALSE
              ,p_technical_summary_mode      in boolean default FALSE
              ,p_bg_tab                      in out nocopy per_ri_config_tech_summary.bg_tab
              ,p_sg_tab                      in out nocopy per_ri_config_tech_summary.sg_tab
              ,p_post_install_tab            in out nocopy per_ri_config_tech_summary.post_install_tab
              ,p_int_bg_resp_tab             in out nocopy per_ri_config_fnd_hr_entity.int_bg_resp_tab
              );


END per_ri_config_datapump_entity;

/
