--------------------------------------------------------
--  DDL for Package PQH_RBC_LOAD_OBJECTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RBC_LOAD_OBJECTS" AUTHID CURRENT_USER as
/* $Header: pqhrbcld.pkh 120.3.12000000.2 2007/04/19 12:52:04 brsinha noship $ */
/* $Header: pqhrbcld.pkh 120.3.12000000.2 2007/04/19 12:52:04 brsinha noship $ */
--
Procedure load_rate_matrix_row
  (p_pl_short_code        in  varchar2
  ,p_name                 in  varchar2
  ,p_short_name           in  varchar2
  ,p_pl_stat_cd           in  varchar2
  ,p_pl_cd                in  varchar2
  ,p_legislation_code     in  varchar2
  ,p_effective_start_date in  varchar2
  ,p_owner                in  varchar2
  );
--
function get_plan_id(p_short_code in  varchar2,
                   p_effective_date in date,
                   p_business_group_id in number)
                    return varchar2;

Procedure load_rmn_row
  (p_pl_short_code          in  varchar2
  ,p_node_short_code        in  varchar2
  ,p_node_name              in  varchar2
  ,p_level_number           in  varchar2
  ,p_criteria_short_code    in  varchar2
  ,p_parent_node_short_code in  varchar2
  ,p_eligy_prfl_name        in  varchar2
  ,p_legislation_code       in  varchar2
  ,p_effective_date         in  varchar2
  ,p_owner                in  varchar2
  );
--
Procedure load_rmv_row
  (p_short_code             in  varchar2
  ,p_node_short_code        in  varchar2
  ,p_char_value1            in  varchar2
  ,p_char_value2            in  varchar2
  ,p_char_value3            in  varchar2
  ,p_char_value4            in  varchar2
  ,p_number_value1          in  varchar2
  ,p_number_value2          in  varchar2
  ,p_number_value3          in  varchar2
  ,p_number_value4          in  varchar2
  ,p_date_value1            in  varchar2
  ,p_date_value2            in  varchar2
  ,p_date_value3            in  varchar2
  ,p_date_value4            in  varchar2
  ,p_legislation_code       in  varchar2
  ,p_effective_date         in  varchar2
  ,p_owner                  in  varchar2
  );
--
Procedure load_rmr_row
  (p_node_short_code          in  varchar2
  ,p_crit_rt_defn_short_code   in  varchar2
  ,p_min_rate_value           in  varchar2
  ,p_max_rate_value           in  varchar2
  ,p_mid_rate_value           in  varchar2
  ,p_rate_value               in  varchar2
  ,p_legislation_code         in  varchar2
  ,p_effective_start_date     in  varchar2
  ,p_owner                    in  varchar2
  );
--
Procedure load_crd_seed_row
             (p_upload_mode             in  varchar2
             ,p_name                    in  varchar2
             ,p_short_name              in  varchar2
             ,p_uom                     in  varchar2
             ,p_currency_code           in  varchar2  default null
             ,p_reference_period_cd     in  varchar2  default null
             ,p_define_max_rate_flag    in  varchar2  default null
             ,p_define_min_rate_flag    in  varchar2  default null
             ,p_define_mid_rate_flag    in  varchar2  default null
             ,p_define_std_rate_flag    in  varchar2  default null
             ,p_rate_calc_cd            in  varchar2
             ,p_preferential_rate_cd    in  varchar2
             ,p_rounding_cd             in  varchar2  default null
             ,p_legislation_code        in  varchar2  default null
             ,p_owner                   in  varchar2  default null
);
--
Procedure load_crd_row
             (p_name                    in  varchar2
             ,p_short_name              in  varchar2
             ,p_uom                     in  varchar2
             ,p_currency_code           in  varchar2  default null
             ,p_reference_period_cd     in  varchar2  default null
             ,p_define_max_rate_flag    in  varchar2  default null
             ,p_define_min_rate_flag    in  varchar2  default null
             ,p_define_mid_rate_flag    in  varchar2  default null
             ,p_define_std_rate_flag    in  varchar2  default null
             ,p_rate_calc_cd            in  varchar2
             --,p_rate_calc_rule          in  varchar2  default null
             ,p_preferential_rate_cd    in  varchar2
             --,p_preferential_rate_rule  in  varchar2  default null
             ,p_rounding_cd             in  varchar2  default null
             --,p_rounding_rule           in  varchar2
             ,p_legislation_code        in  varchar2  default null
             ,p_owner                   in  varchar2  default null
);

Procedure download_rbc(
          errbuf                     out nocopy varchar2
         ,retcode                    out nocopy number
         ,p_loader_file              in varchar2
         ,p_data_file                in varchar2
         ,p_entity                   in varchar2
         ,p_crit_rate_defn_code      in varchar2 default null
         ,p_rate_matrix_code         in varchar2 default null
         ,p_effective_date           in varchar2
         ,p_business_group_id        in number
         ,p_validate                 in  varchar2 default 'N'
       );
--
Procedure upload_rbc(
          errbuf                     out nocopy varchar2
         ,retcode                    out nocopy number
         ,p_loader_file              in varchar2
         ,p_data_file                in varchar2
         ,p_entity                   in varchar2
         ,p_crit_rate_defn_code      in varchar2 default null
         ,p_rate_matrix_code         in varchar2 default null
         ,p_validate                 in  varchar2 default 'N'
       );
--
Procedure load_crf_row
  (
   p_crit_rt_defn_short_name   in      VARCHAR2  default hr_api.g_varchar2
  ,p_parent_crit_rt_def_name   in       VARCHAR2  default hr_api.g_varchar2
  ,p_owner                     in      VARCHAR2  default hr_api.g_varchar2
  ,p_parent_rate_matrix_code   in      VARCHAR2  default hr_api.g_varchar2
  ,p_legislation_code          in      VARCHAR2  default hr_api.g_varchar2
  ,p_effective_start_date      in      varchar2  default hr_api.g_varchar2
);

Procedure load_cre_row
  (
   p_crit_rt_defn_short_name   in      VARCHAR2  default hr_api.g_varchar2
  ,p_element_type_name         in      VARCHAR2  default hr_api.g_varchar2
  ,p_input_value_name          in      VARCHAR2  default hr_api.g_varchar2
  ,p_owner                     in      VARCHAR2  default hr_api.g_varchar2
  ,p_legislation_code          in      VARCHAR2  default hr_api.g_varchar2
  ,p_effective_start_date      in      varchar2  default hr_api.g_varchar2
);

Procedure load_rer_row
  (
   p_crit_rt_defn_short_name   in      VARCHAR2  default hr_api.g_varchar2
  ,p_element_type_name         in      VARCHAR2  default hr_api.g_varchar2
--  ,p_input_value_name          in      VARCHAR2  default hr_api.g_varchar2
  ,p_owner                     in      VARCHAR2  default hr_api.g_varchar2
  ,p_relation_type_code        in      VARCHAR2  default hr_api.g_varchar2
  ,p_rel_element_name          in      VARCHAR2  default hr_api.g_varchar2
  ,p_rel_input_val_name        in      VARCHAR2  default hr_api.g_varchar2
  ,p_legislation_code          in      VARCHAR2  default hr_api.g_varchar2
  ,p_effective_start_date      in      varchar2  default hr_api.g_varchar2
);

Procedure load_rfe_row
  (p_crit_rt_defn_short_name   in      VARCHAR2  default hr_api.g_varchar2
  ,p_parent_crit_rt_def_name   in      VARCHAR2  default hr_api.g_varchar2
  ,p_owner                     in      VARCHAR2  default hr_api.g_varchar2
  ,p_element_type_name         in      VARCHAR2  default hr_api.g_varchar2
  ,p_rate_factor_val_record_tbl   in      VARCHAR2 default hr_api.g_varchar2
  ,p_rate_factor_val_record_col   in      VARCHAR2  default hr_api.g_varchar2
  ,p_legislation_code          in      VARCHAR2  default hr_api.g_varchar2
  ,p_effective_start_date      in      VARCHAR2  default hr_api.g_varchar2
);


--
procedure add_language;     --  Added as a fix for bug 5484366
--

End pqh_rbc_load_objects;

 

/
