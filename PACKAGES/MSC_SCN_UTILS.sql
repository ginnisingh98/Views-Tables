--------------------------------------------------------
--  DDL for Package MSC_SCN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SCN_UTILS" AUTHID CURRENT_USER AS
    /* $Header: MSCSCNUS.pls 120.13.12010000.2 2010/03/31 12:59:08 wexia ship $ */


    TYPE number_arr IS TABLE OF number;

    FUNCTION get_plan_name(p_plan_type in number,
                           p_plan_id in number,
                           p_plan_run_id in number) return varchar2;

    Function get_proc_act_name(p_activity_type in number) return varchar2;

    FUNCTION get_owner_name(p_owner_id in number) return varchar2;

    FUNCTION get_scn_version(p_version date) return varchar2;

    FUNCTION get_plan_version (p_plan_run_id in number) return varchar2;

    FUNCTION get_scn_users(p_scn_id in number) return varchar2;

    FUNCTION Scenario_Status(p_Scenario_id in number) return varchar2;

    FUNCTION Plan_Status(p_Plan_id in number) return varchar2;

    FUNCTION get_scenario_name(p_scenario_id in number) return varchar2;

    function plan_scns_count(p_plan_id in number, p_scn_id in number, p_plan_run_id in number) return number;

    FUNCTION get_scenario_set_name(p_scenario_set_id in number) return varchar2;

    procedure archive_scn_conc( errbuf out nocopy varchar2, retcode out nocopy varchar2 , p_scn_id in number);

    procedure purge_scn_conc( errbuf out nocopy varchar2, retcode out nocopy varchar2 , p_scn_id in number);

    procedure purge_plan_conc( errbuf out nocopy varchar2, retcode out nocopy varchar2 , p_plan_id in number, p_plan_type in number);

    procedure populate_act_params_for_lov(p_activity_type in number);

    procedure get_Activity_Summary(where_clause IN OUT NOCOPY varchar2, activity_summary IN out NOCOPY varchar2);

    function get_plan_run_date (p_plan_type in number,p_plan_id in number) return date;

    function get_process_status(p_process_id in number,p_curr_run_seq in number) return number;

    procedure copy_scn_plans(p_src_scnId in number, p_dest_scnId in number);

    procedure populate_default_params(p_activity_type IN OUT NOCOPY  number,param_default IN OUT NOCOPY varchar2);

    procedure create_scenario( errbuf out nocopy varchar2, retcode out nocopy varchar2,
      p_scn_name varchar2, p_description varchar2,
      p_owner number, p_scn_version date,
      p_scn_access number, p_scn_comment varchar2,
      p_valid_from date, p_valid_to date,
      p_plan_id_arr msc_scn_utils.number_arr,
      p_users_arr  msc_scn_utils.number_arr
      );

end MSC_SCN_UTILS;

/
