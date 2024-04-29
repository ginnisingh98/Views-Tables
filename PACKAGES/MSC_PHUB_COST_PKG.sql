--------------------------------------------------------
--  DDL for Package MSC_PHUB_COST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PHUB_COST_PKG" AUTHID CURRENT_USER as
/* $Header: MSCHBCTS.pls 120.3.12010000.2 2010/03/03 23:32:52 wexia noship $ */
    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number);

    procedure summarize_costs_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number);

    procedure export_costs_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2);

    procedure import_costs_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2);

    function need_migrate return number;
    procedure migrate;

end msc_phub_cost_pkg;

/
