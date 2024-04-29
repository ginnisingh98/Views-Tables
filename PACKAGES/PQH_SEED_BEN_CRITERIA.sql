--------------------------------------------------------
--  DDL for Package PQH_SEED_BEN_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SEED_BEN_CRITERIA" AUTHID CURRENT_USER AS
/* $Header: pqcritld.pkh 120.1 2005/10/12 20:18 srajakum noship $ */

procedure load_criteria_seed_row(p_owner in varchar2
                        ,p_short_code in varchar2
                        ,p_name in varchar2
                        ,p_description in varchar2
                        ,p_crit_col1_val_type_cd in varchar2
                        ,p_crit_col1_datatype in varchar2
                        ,p_col1_lookup_type in varchar2
                        ,p_col1_value_set_name in varchar2
                        ,p_access_table_name1 in varchar2
                        ,p_access_column_name1 in varchar2
                        ,p_crit_col2_val_type_cd in varchar2
                        ,p_crit_col2_datatype in varchar2
                        ,p_col2_lookup_type in varchar2
                        ,p_col2_value_set_name in varchar2
                        ,p_access_table_name2 in varchar2
                        ,p_access_column_name2 in varchar2
                        ,p_allow_range_validation_flag in varchar2
                        ,p_allow_range_validation_flag2 in varchar2
                        ,p_user_defined_flag in varchar2
                        ,p_business_group_id in varchar2
                        ,p_legislation_code in varchar2
                        ,p_last_update_date in varchar2
                        );

end pqh_seed_ben_criteria;

 

/
