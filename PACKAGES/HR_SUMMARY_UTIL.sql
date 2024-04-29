--------------------------------------------------------
--  DDL for Package HR_SUMMARY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SUMMARY_UTIL" AUTHID CURRENT_USER as
/* $Header: hrbsutil.pkh 120.0 2005/05/30 23:06:37 appldev noship $ */
--
item_type_usage_id number;
zero_item_value_id number;
g_business_group_id number;
year varchar2(4);
end_of_year varchar2(80);
process_run_id number;
--
OTHER varchar2(1000) := fnd_message.get_string('PER','PER_74885_OTHER');
--
l_gender_other boolean;
l_age_other boolean;
l_employee_category_other boolean;
l_nationality_other boolean;
l_seniority_other boolean;
--
gender_clause varchar2(2000);
age_clause varchar2(2000);
emp_cat_clause varchar2(2000);
nationality_clause varchar2(2000);
seniority_clause varchar2(2000);
--
store_data boolean;
--
TYPE prmRecType IS RECORD
   (name varchar2(240)
   ,value varchar2(4000));
TYPE prmTabType IS TABLE of prmRecType INDEX BY BINARY_INTEGER;
--
nullprmTab prmTabType;
--
function create_other_kv(p_business_group_id number
                        ,p_key_type_id number) return boolean;
--
function get_lookup_values(p_lookup_type varchar2
                          ,p_db_column varchar2
                          ,p_key_type_id number) return varchar2;
--
function get_alternate_values(p_table_name varchar2
                             ,p_column varchar2
                             ,p_db_column varchar2
                             ,p_key_type_id number) return varchar2;
--
--
function get_band_values(p_table_name varchar2
                        ,p_low_column varchar2
                        ,p_high_column varchar2
                        ,p_db_column varchar2
                        ,p_key_type_id number) return varchar2;
--
procedure initialize_run(p_store_data boolean
                        ,p_business_group_id number
                        ,p_template_id number
                        ,p_process_run_name varchar2
                        ,p_process_type varchar2
                        ,p_parameters prmTabType);
procedure initialize_procedure (p_business_group_id number);
procedure load_item_value(p_business_group_id number
                         ,p_value number);
/*
procedure load_item_key_value(p_business_group_id number
                             ,p_key_type_id number
                             ,p_other_entry IN OUT boolean
                             ,p_value varchar2);
*/
function get_cagr_values (p_key_type_id in number
                         ,p_db_column   in varchar2
                         ,p_table_name  in varchar2
                         ,p_column_name in varchar2) return varchar2;
function get_month (p_key_type_id in number
                   ,p_db_column   in varchar2) return varchar2;
--
--
--
end;

 

/
