--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_FND_DEF_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_FND_DEF_ENTITY" AUTHID CURRENT_USER AS
/* $Header: perricfd.pkh 120.3 2005/07/28 15:45 dgarg noship $ */



  PROCEDURE create_user (p_technical_summary_mode      in boolean default FALSE
                        ,p_user_tab in out nocopy
                                           per_ri_config_tech_summary.user_tab);

  PROCEDURE attach_default_responsibility
                         (p_configuration_code          in varchar2
                         ,p_technical_summary_mode      in boolean default FALSE
                         ,p_resp_tab in out nocopy
                                  per_ri_config_tech_summary.resp_tab);

  PROCEDURE  create_site_profile_options(p_configuration_code   in varchar2
                                        ,p_technical_summary_mode      in boolean default FALSE
                                        ,p_profile_tab in out nocopy
                                                 per_ri_config_tech_summary.profile_tab);

END per_ri_config_fnd_def_entity;


 

/
