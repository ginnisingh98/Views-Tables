--------------------------------------------------------
--  DDL for Package MSC_SUPPLIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SUPPLIER_PKG" AUTHID CURRENT_USER as
/* $Header: MSCHBSPS.pls 120.3.12010000.5 2010/03/03 23:37:59 wexia ship $ */


   --function is_plan_constrained (l_daily number,l_weekly number,l_monthly number,l_dailym number,l_weeklym number,l_monthlym number) return number;
   function supplier_spend_value (p_new_order_quantity number, p_list_price number, p_order_type number) return number;
   function is_new_buy_order(p_order_type number , p_plan_type number, p_purchasing_enabled_flag number) return number;
   function is_rescheduled_po(p_order_type number, p_rescheduled_flag number, new_schedule_date date, old_schedule_date date) return number;
   function is_cancelled_po(p_order_type number, p_disposition_status_type number) return number;

   procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
    p_plan_id number, p_plan_run_id number);

    procedure summarize_suppliers_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number);

    procedure export_suppliers_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2);

    procedure import_suppliers_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2);

END msc_supplier_pkg;

/
