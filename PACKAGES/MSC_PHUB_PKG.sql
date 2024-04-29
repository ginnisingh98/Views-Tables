--------------------------------------------------------
--  DDL for Package MSC_PHUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PHUB_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCHBPBS.pls 120.12.12010000.12 2010/03/03 23:40:11 wexia ship $ */

  sys_yes constant number := 1;
  sys_no constant number := 2;

   g_log_flag number := 2; --0 no-log, 1 log-to-file, 2 log-to-conc-log
   g_log_row number := 0;
   g_log_file_dir varchar2(250);
   g_log_file_name varchar2(250);
   g_log_file_handle utl_file.file_type;

    type plan_info is record (
        plan_id number,
        plan_name varchar2(50),
        plan_description varchar2(100),
        plan_type number,
        sr_instance_id number,
        organization_id number,
        plan_start_date date,
        plan_cutoff_date date,
        plan_completion_date date
    );

    procedure println(p_msg varchar2);

    type object_names is table of varchar2(30);
    function meta_info return msc_apcc_fact_type_table;
    function list_plan_fact_tables return object_names;

    function populate_plan_run_info(p_plan_id number,
        p_plan_type number default null,
        p_scenario_name varchar2 default null,
        p_local_archive_flag number default sys_yes,
        p_pi plan_info default null)
        return number;

    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number,
        p_plan_run_id number default null,
        p_archive_flag number default sys_yes,
        p_target_plan_name varchar2 default null,
        p_dblink varchar2 default null,
        p_include_ods number default sys_no,
        p_plan_type number default null,
        p_scenario_name in varchar2 default null);

    procedure purge_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number default null);

    procedure refresh_mvs(p_refresh_mode varchar2);
    procedure refresh_mvs(errbuf out nocopy varchar2, retcode out nocopy varchar2, p_refresh_mode varchar2);

    procedure populate_demantra_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number, p_archive_flag number default -1,
        p_dblink varchar2 default null,
        p_include_ods number default sys_no);

    procedure populate_sno_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number,
        p_plan_run_id number default null,
        p_archive_flag number default -1,
        p_scenario_name in varchar2 default null);

    procedure manage_partitions(p_tables object_names, p_partition_id number, p_mode number);

    function msc_wait_for_request(p_request_id in  number) return number;

    procedure finalize_plan_run(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number,
        p_etl_flag number, p_success number, p_keep_previous number);

    function get_plan_info(p_plan_id number, p_plan_type number) return plan_info;

    function create_plan_run(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_scenario_name varchar2 default null,
        p_local_archive_flag number default sys_yes,
        p_pi plan_info default null)
        return number;

    procedure populate_demantra_ods(errbuf out nocopy varchar2, retcode out nocopy varchar2);

    procedure populate_each(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_package varchar2, p_plan_id number, p_plan_run_id number);

    procedure build_items_from_pds(p_plan_id number);
    procedure build_items_from_apcc(p_plan_id number, p_plan_run_id number);
    procedure purge_items(p_plan_id number);
    procedure populate_ods_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_sr_instance_id number, p_refresh_mode number, p_param1 varchar2 default null);

    function populate_ods_facts(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number) return number;

    procedure maintain_data_model(errbuf out nocopy varchar2, retcode out nocopy varchar2);
    procedure check_migrate(errbuf out nocopy varchar2, retcode out nocopy varchar2);

END msc_phub_pkg;

/
