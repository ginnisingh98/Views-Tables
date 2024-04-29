--------------------------------------------------------
--  DDL for Package BEN_EXTRACT_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXTRACT_SEED" AUTHID CURRENT_USER AS
/* $Header: benextse.pkh 120.5.12000000.2 2007/02/13 01:17:15 tjesumic noship $ */
--

g_business_group_id   per_business_groups.Business_group_id%type ;
g_max_errors_allowed  number ;
g_errors_count        number := 0 ;
g_Total_file          number := 0 ;
g_file_count          number := 0 ;
g_group_record       varchar2(600) ;
g_group_elmt1        varchar2(600) ;
g_group_elmt2        varchar2(600) ;
g_override           varchar2(1) ;

TYPE Ext_adv_crit_cmbn   IS RECORD
      (old_crit_val_id  number,
       new_crit_val_id  number
      );

TYPE tbl_Ext_adv_crit_cmbn IS TABLE OF Ext_adv_crit_cmbn  INDEX BY Binary_Integer ;


Procedure  load_business_group(p_owner             IN VARCHAR2
                               ,p_legislation_code IN VARCHAR2
                               ,p_business_group   in VARCHAR2
                               ,p_totalcount       in VARCHAR2 default null
                               ,p_allow_override   in VARCHAR2 default null

                              ) ;




FUNCTION get_value (p_crit_typ_cd in VARCHAR2
                   ,p_val         in VARCHAR2
                   ,p_val_order   IN VARCHAR2
                   ,p_bg_group_id in number default null
                  )return varchar2;
--
FUNCTION decode_value (p_crit_typ_cd in VARCHAR2,
                  p_meaning in VARCHAR2
                  ,p_val_order IN VARCHAR2
                  ,p_parent_meaning IN VARCHAR2
                  )return varchar2;
--
PROCEDURE load_extract(p_file_name         IN VARCHAR2
                       ,p_owner            IN VARCHAR2
                       ,p_last_update_date IN VARCHAR2
                       ,p_legislation_code IN VARCHAR2
                       ,p_business_group   in VARCHAR2
                       ,p_xml_tag_name     in VARCHAR2
                       ,p_ext_group_record in  VARCHAR2
                       ,p_ext_group_elmt1  in  VARCHAR2
                       ,p_ext_group_elmt2  in  VARCHAR2
                          );
--
PROCEDURE load_record(p_record_name      IN VARCHAR2
                     ,p_owner            IN VARCHAR2
                     ,p_last_update_date IN VARCHAR2
                     ,p_rcd_type_cd      IN VARCHAR2
                     ,p_low_lvl_cd       IN VARCHAR2
                     ,p_legislation_code IN VARCHAR2
                     ,p_business_group   in VARCHAR2
                     ,p_xml_tag_name     in VARCHAR2);
--
PROCEDURE load_record_in_file(p_file_name            IN VARCHAR2
                             ,p_parent_record_name   IN VARCHAR2
                             ,p_owner                IN VARCHAR2
                             ,p_last_update_date     IN VARCHAR2
                             ,p_rqd_flag             IN VARCHAR2 DEFAULT 'N'
                             ,p_hide_flag            IN VARCHAR2 DEFAULT 'N'
                             ,p_CHG_RCD_UPD_FLAG     IN VARCHAR2 DEFAULT 'N'
                             ,p_seq_num              IN VARCHAR2 DEFAULT null
                             ,p_sprs_cd              IN VARCHAR2 DEFAULT NULL
                             ,p_any_or_all_cd        IN VARCHAR2 DEFAULT 'N'
                             ,p_sort1_element        IN VARCHAR2 DEFAULT NULL
                             ,p_sort2_element        IN VARCHAR2 DEFAULT NULL
                             ,p_sort3_element        IN VARCHAR2 DEFAULT NULL
                             ,p_sort4_element        IN VARCHAR2 DEFAULT NULL
                             ,p_legislation_code     IN VARCHAR2
                             ,p_business_group       in VARCHAR2
                             );
--
PROCEDURE load_ext_data_elmt(p_data_elemt_name     IN VARCHAR2
                            ,p_parent_data_element IN VARCHAR2 DEFAULT NULL
                            ,p_field_short_name    IN VARCHAR2 DEFAULT NULL
                            ,p_parent_record_name  IN VARCHAR2 DEFAULT NULL
                            ,p_owner               IN VARCHAR2
                            ,p_last_update_date    IN VARCHAR2
                            ,p_ttl_fnctn_cd        IN VARCHAR2
                            ,p_ttl_cond_oper_cd    IN VARCHAR2
                            ,p_ttl_cond_val        IN VARCHAR2
                            ,p_data_elmt_typ_cd    IN VARCHAR2
                            ,p_data_elmt_rl        IN VARCHAR2
                            ,p_frmt_mask_cd        IN VARCHAR2
                            ,p_string_val          IN VARCHAR2
                            ,p_dflt_val            IN VARCHAR2
                            ,p_max_length_num      IN VARCHAR2
                            ,p_just_cd             IN VARCHAR2
                            ,p_legislation_code    IN VARCHAR2
                            ,p_business_group      in VARCHAR2
                            ,p_xml_tag_name        in VARCHAR2
                            ,p_defined_balance     in VARCHAR2 DEFAULT NULL
                             );
--
PROCEDURE load_ext_data_elmt_in_rcd(p_data_element_name  IN VARCHAR2
                                   ,p_record_name        IN VARCHAR2
                                   ,p_owner              IN VARCHAR2
                                   ,p_last_update_date   IN VARCHAR2
                                   ,p_rqd_flag           IN VARCHAR2
                                   ,p_hide_flag          IN VARCHAR2
                                   ,p_seq_num            IN VARCHAR2
                                   ,p_strt_pos           IN VARCHAR2
                                   ,p_dlmtr_val          IN VARCHAR2
                                   ,p_sprs_cd            IN VARCHAR2
                                   ,p_any_or_all_cd      IN VARCHAR2
                                   ,p_legislation_code   IN VARCHAR2
                                   ,p_business_group   in VARCHAR2
                                   );
--
PROCEDURE load_ext_where_clause(p_data_elmt_name         IN VARCHAR2
                               ,p_record_name            IN VARCHAR2 default null
                               ,p_file_name              IN VARCHAR2 DEFAULT NULL
                               ,p_record_data_elmt_name  IN VARCHAR2 DEFAULT NULL
                               ,p_cond_ext_data_elmt_name IN VARCHAR2 DEFAULT NULL
                               ,p_owner                  IN VARCHAR2
                               ,p_last_update_date       IN VARCHAR2
                               ,p_seq_num                IN VARCHAR2
                               ,p_oper_cd                IN VARCHAR2
                               ,p_val                    IN VARCHAR2
                               ,p_and_or_cd              IN VARCHAR2
                               ,p_legislation_code       IN VARCHAR2
                               ,p_business_group         IN VARCHAR2
                                );

--
PROCEDURE load_incl_chgs(p_data_elmt_name    IN VARCHAR2 DEFAULT NULL
                         ,p_record_name      IN VARCHAR2
                         ,p_file_name        IN VARCHAR2 DEFAULT NULL
                         ,p_chg_evt_cd       IN VARCHAR2
                         ,p_owner            IN VARCHAR2
                         ,p_last_update_date IN VARCHAR2
                         ,p_legislation_code IN VARCHAR2
                         ,p_business_group   in VARCHAR2
                         ,p_chg_evt_source   in VARCHAR2 DEFAULT NULL
                         ) ;

--
PROCEDURE load_profile(p_profile_name     IN VARCHAR2
                      ,p_owner            IN VARCHAR2
                      ,p_last_update_date IN VARCHAR2
                      ,p_legislation_code IN VARCHAR2
                      ,p_business_group   in VARCHAR2
                      ,p_ext_Global_flag  in VARCHAR2  default 'N'
                      );
--
PROCEDURE load_criteria_type(p_profile_name     IN VARCHAR2
                            ,p_type_code        IN VARCHAR2
                            ,p_owner            IN VARCHAR2
                            ,p_last_update_date IN VARCHAR2
                            ,p_crit_typ_cd      IN VARCHAR2
                            ,p_excld_flag       IN VARCHAR2
                            ,p_legislation_code IN VARCHAR2
                            ,p_business_group   in VARCHAR2 );
--
PROCEDURE load_criteria_val(p_profile_name      IN VARCHAR2
                           ,p_type_code         IN VARCHAR2
                           ,p_val               IN  VARCHAR2
                           ,p_owner             IN VARCHAR2
                           ,p_last_update_date  IN VARCHAR2
                           ,p_val2              IN VARCHAR2
                           ,p_legislation_code  IN VARCHAR2
                           ,p_business_group   in VARCHAR2
                           ,p_ext_crit_val_id   in varchar2 default null
                           ,p_lookup_code1      in varchar2 default null
                           ,p_lookup_code2      in varchar2 default null
                           );
--
PROCEDURE load_combination(p_profile_name       IN VARCHAR2
                          ,p_type_code          IN VARCHAR2
                          ,p_val                IN VARCHAR2
                          ,p_val_2              IN VARCHAR2
                          ,p_crit_typ_cd        IN VARCHAR2
                          ,p_oper_cd            IN VARCHAR2
                          ,p_owner              IN VARCHAR2
                          ,p_last_update_date   IN VARCHAR2
                          ,p_legislation_code   IN VARCHAR2
                          ,p_business_group   in VARCHAR2
                          ,p_ext_crit_val_id   in varchar2 default null
                          ,p_lookup_code1      in varchar2 default null
                          ,p_lookup_code2      in varchar2 default null
                          );
--
PROCEDURE load_definition(p_definition_name          IN   VARCHAR2
                         ,p_file_name                IN  VARCHAR2
                         ,p_profile_name             IN  VARCHAR2
                         ,p_owner                    IN  VARCHAR2
                         ,p_last_update_date         IN  VARCHAR2
                         ,p_kickoff_wrt_prc_flag     IN  VARCHAR2
                         ,p_apnd_rqst_id_flag        IN  VARCHAR2
                         ,p_prmy_sort_cd             IN  VARCHAR2
                         ,p_scnd_sort_cd             IN  VARCHAR2
                         ,p_strt_dt                  IN  VARCHAR2
                         ,p_end_dt                   IN  VARCHAR2
                         ,p_spcl_hndl_flag           IN  VARCHAR2
                         ,p_upd_cm_sent_dt_flag      IN  VARCHAR2
                         ,p_use_eff_dt_for_chgs_flag IN  VARCHAR2
                         ,p_data_typ_cd              IN  VARCHAR2
                         ,p_ext_typ_cd               IN  VARCHAR2
                         ,p_drctry_name              IN  VARCHAR2
                         ,p_output_name              IN  VARCHAR2
                         ,p_post_processing_rule     IN  VARCHAR2
                         ,p_legislation_code         IN  VARCHAR2
                         ,p_business_group           in VARCHAR2
                         ,p_xml_tag_name             in VARCHAR2
                         ,p_output_type              in VARCHAR2
                         ,p_xdo_template_name        in VARCHAR2
                         ,p_ext_Global_flag          in VARCHAR2 default 'N'
                         ,p_cm_display_flag          in VARCHAR2 default 'N'
                          );

PROCEDURE load_decode(p_element_name      IN VARCHAR2
                     ,p_owner             IN VARCHAR2
                     ,p_last_update_date  IN VARCHAR2
                     ,p_val               IN VARCHAR2
                     ,p_dcd_val           IN VARCHAR2
                     ,p_legislation_code  IN VARCHAR2
                     ,p_business_group    IN VARCHAR2
                     ,p_chg_evt_source    in VARCHAR2 default null
                    )
;


function  get_lookup_code  (p_crit_typ_cd in VARCHAR2
                   ,p_val         in VARCHAR2
                   ,p_val_order   IN VARCHAR2
                   ,p_bg_group_id IN NUMBER  default null
                  )return varchar2
;




PROCEDURE validate_data(validate IN VARCHAR2 DEFAULT null  )  ;


function  get_chg_evt_cd (p_CHG_EVT_CD      varchar2 ,
                          p_chg_evt_source  varchar2,
                          p_business_group_id number
                         ) return varchar2 ;



function  set_chg_evt_cd (p_CHG_EVT_CD      varchar2 ,
                          p_chg_evt_source  varchar2,
                          p_business_group_id number
                         ) return varchar2 ;

END ben_extract_seed;

 

/
