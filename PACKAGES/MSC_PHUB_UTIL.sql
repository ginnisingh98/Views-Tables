--------------------------------------------------------
--  DDL for Package MSC_PHUB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PHUB_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCHBUTS.pls 120.0.12010000.12 2010/03/03 23:37:27 wexia ship $ */
   g_rpt_curr_code varchar2(20);
   g_version constant varchar2(20) := '12.1.3';

    upload_append constant number := 1;
    upload_replace constant number := 2;
    upload_create constant number := 3;
    upload_create_purge_prev constant number := 4;
    conv_date_filtered constant number := -1;

    conv_key_err_organization constant number := 1;
    conv_key_err_item constant number := 2;
    conv_key_err_customer constant number := 3;
    conv_key_err_supplier constant number := 4;
    conv_key_err_project constant number := 5;
    conv_key_err_resource constant number := 6;
    conv_key_err_category constant number := 7;
    conv_key_err_date constant number := 8;


   FUNCTION get_conversion_rate(p_func_currency in varchar2,p_sr_instance_id in number, p_date in date) return number;
   FUNCTION get_conversion_rate(p_sr_instance_id in number, p_organization_id in number, p_date in date) return number;
   FUNCTION get_planning_hub_message(p_mesg_code in varchar2) return varchar2;
   FUNCTION get_reporting_currency_code return varchar2;
   FUNCTION get_exception_group(p_exception_type_id in number) return varchar2;
   FUNCTION get_list_price(p_plan_id in number,p_inst_id in number,p_org_id in number, p_item_id in number) return number;
   FUNCTION is_plan_constrained (l_daily number, l_weekly number, l_monthly number, l_dailym number, l_weeklym number, l_monthlym number) return number;
   FUNCTION is_plan_constrained(p_plan_id number) return number;
   FUNCTION get_plan_type(p_plan_id number) return number;
   function get_default_plan_run_id(p_scenario_id number, p_plan_type number, p_plan_run_name varchar2) return number;
   FUNCTION get_user_name(p_user_id number) return varchar2;


  procedure validate_icx_session(p_icx_cookie varchar2, p_user varchar2, p_pwd varchar2);

    procedure log(p_message varchar2);
    function suffix(p_dblink varchar2) return varchar2;

    function decode_organization_key(p_staging_table varchar2, p_st_transaction_id number,
        p_def_instance_code varchar2,
        p_sr_instance_id_col varchar2, p_organization_id_col varchar2, p_organization_code_col varchar2)
        return number;

    function decode_item_key(p_staging_table varchar2, p_st_transaction_id number,
        p_item_id_col varchar2, p_item_name_col varchar2) return number;

    function decode_category_key(p_staging_table varchar2, p_st_transaction_id number) return number;
    function decode_resource_key(p_staging_table varchar2, p_st_transaction_id number) return number;
    function decode_project_key(p_staging_table varchar2, p_st_transaction_id number) return number;

    function decode_customer_key(p_staging_table varchar2, p_st_transaction_id number,
        p_customer_id_col varchar2,
        p_customer_site_id_col varchar2,
        p_region_id_col varchar2,
        p_customer_name_col varchar2,
        p_customer_site_code_col varchar2,
        p_zone_col varchar2)
        return number;

    function decode_supplier_key(p_staging_table varchar2, p_st_transaction_id number,
        p_supplier_id_col varchar2,
        p_supplier_site_id_col varchar2,
        p_region_id_col varchar2,
        p_supplier_name_col varchar2,
        p_supplier_site_code_col varchar2,
        p_zone_col varchar2)
        return number;

    function prepare_staging_dates(p_staging_table varchar2,
        date_col varchar2, p_st_transaction_id number,
        p_upload_mode number, p_overwrite_after_date date,
        p_plan_start_date date, p_plan_cutoff_date date)
        return number;

    function prepare_fact_dates(p_fact_table varchar2, p_is_plan_data number,
        date_col varchar2, p_plan_id number, p_plan_run_id number,
        p_upload_mode number, p_overwrite_after_date date)
        return number;

    function apps_schema return varchar2;
    function get_resource_rn_qid (p_plan_id number, p_plan_run_id number) return number;
    function get_item_rn_qid(p_plan_id number, p_plan_run_id number) return number;
    function get_owning_currency_code(p_plan_run_id number) return varchar2;
    function get_reporting_dates(p_plan_start_date date, p_plan_cutoff_date date) return number;

    function validate_customer_site_id(p_customer_id number, p_customer_site_id number)
        return number;

END msc_phub_util;

/
