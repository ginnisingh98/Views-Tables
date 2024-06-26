--------------------------------------------------------
--  DDL for Package MSC_PHUB_BUDGET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PHUB_BUDGET_PKG" AUTHID CURRENT_USER as
/* $Header: MSCHBBDS.pls 120.2.12010000.2 2010/03/03 23:32:47 wexia noship $ */
    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number);

    procedure export_budgets_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2);

    procedure import_budgets_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2);

end msc_phub_budget_pkg;

/
