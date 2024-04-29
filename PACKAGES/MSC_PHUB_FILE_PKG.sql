--------------------------------------------------------
--  DDL for Package MSC_PHUB_FILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PHUB_FILE_PKG" AUTHID CURRENT_USER as
    /* $Header: MSCHBPFS.pls 120.1.12010000.5 2009/08/14 17:08:45 wexia noship $ */
    transfer_staging number := 1;
    transfer_file number := 2;
    transfer_blob number := 3;
    transfer_other_staging number := 4;

    status_transfering number := 1;
    status_transfered number := 2;
    status_purging number := 3;

    function get_plan_type_meaning(p_plan_type number) return varchar2;

    function prepare_transfer_tables_ui(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_query_id number) return number;

    function prepare_transfer_tables(
        p_export_level number,
        p_import_level number,
        p_upload_mode number,
        p_directory varchar2,
        p_source_plan_id number,
        p_source_plan_run_id number,
        p_source_dblink varchar2,
        p_source_version varchar2,
        p_include_pds number,
        p_include_ods number,
        p_plan_name varchar2,
        p_plan_type number,
        p_plan_description varchar2,
        p_instance_code varchar2,
        p_organization_code varchar2,
        p_plan_start_date date,
        p_plan_cutoff_date date,
        p_plan_completion_date date) return number;

    procedure save_overwrite_date(p_transfer_id number, p_fact_type number,
        p_overwrite_after_date date);

    procedure prepare_export(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number);

    procedure prepare_import(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number);

    procedure finalize_export(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number);

    procedure finalize_import(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number);

    procedure export_table(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number, p_fact_type number);

    procedure import_table(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number, p_fact_type number);

    procedure cleanup(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number);

    procedure purge_apcc_tables(errbuf out nocopy varchar2, retcode out nocopy varchar2);

    procedure prepare_context(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number, p_validate_only number);

    function create_plan(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number) return number;

    procedure prepare_partitions(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number);

    function list_staging_tables return msc_phub_pkg.object_names;
    function get_staging_table(p_fact_type number) return varchar2;

    procedure purge_plan_summary(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number default null);

end msc_phub_file_pkg;

/
