--------------------------------------------------------
--  DDL for Package MSC_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ITEM_PKG" AUTHID CURRENT_USER as
/* $Header: MSCHBITS.pls 120.2.12010000.5 2010/03/03 23:43:31 wexia ship $ */



procedure populate_details(errbuf out nocopy varchar2,
                             retcode out  nocopy varchar2,
                     p_plan_id number,
                 p_plan_run_id number default null);

    procedure summarize_item_inventory_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number);

    procedure summarize_item_orders_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number);

    procedure export_item_inventory_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2);

    procedure export_item_orders_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2);

    procedure import_item_inventory_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2);

    procedure import_item_orders_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2);

end msc_item_pkg;

/
