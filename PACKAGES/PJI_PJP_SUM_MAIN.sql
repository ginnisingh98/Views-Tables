--------------------------------------------------------
--  DDL for Package PJI_PJP_SUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJP_SUM_MAIN" AUTHID CURRENT_USER as
  /* $Header: PJISP01S.pls 120.2.12010000.6 2010/05/13 23:11:41 rkuttiya ship $ */

  g_parallel_processes  number       := 10;
  g_process             varchar2(30) := 'PJI_PJP';
  g_null                varchar2(8)  := 'PJI$NULL';
  g_parameter_date_mask varchar2(21) := 'YYYY/MM/DD HH24:MI:SS';
  g_date_mask           varchar2(21) := 'YYYY/MM/DD';
  g_full_disp_name      varchar2(30) := 'PJI_PJP_SUMMARIZE_FULL';
  g_incr_disp_name      varchar2(30) := 'PJI_PJP_SUMMARIZE_INCR';
  g_prtl_disp_name      varchar2(30) := 'PJI_PJP_SUMMARIZE_PRTL';
  g_rbs_disp_name       varchar2(30) := 'PJI_PJP_SUMMARIZE_RBS';
  g_retcode             varchar2(255);

  function WORKER_STATUS (p_worker_id in number,
                          p_mode in varchar2) return boolean;

  procedure OUTPUT_FAILED_RUNS;

  procedure INIT_PROCESS(
    p_worker_id               in out nocopy number,
    p_run_mode                in            varchar2,
    p_operating_unit          in            number   default null,
    p_project_type            in            varchar2 default null,
    p_project_organization_id in            number   default null,
/*  p_from_project_id         in            number   default null,
    p_to_project_id           in            number   default null,*/
    p_from_project            in            varchar2   default null,
    p_to_project              in            varchar2   default null,
    p_plan_type_id            in            number   default null,
    p_rbs_header_id           in            number   default null,
    p_only_pt_projects_flag   in            varchar2 default null,
    p_transaction_type    in         varchar2 default null,	 --  Bug#5099574 - New parameter for Partial Refresh
    p_plan_versions     in         varchar2 default null,--  Bug#5099574 - New parameter for Partial Refresh
    p_project_status          in          varchar2   default null -- 12.1.3
    );

  procedure RUN_PROCESS (p_worker_id in number);

  procedure WRAPUP_PROCESS (p_worker_id in number);

  procedure WRAPUP_FAILURE (p_worker_id in number);

  procedure SUMMARIZE
  (
    errbuf                    out nocopy varchar2,
    retcode                   out nocopy varchar2,
    p_run_mode                in         varchar2,
    p_operating_unit          in         number   default null,         --new parameter
    p_project_organization_id in         number   default null,
    p_project_type            in         varchar2 default null,
    /* These two parameter will be changed to p_from_project and p_to_project
    p_from_project_id         in         number   default null,
    p_to_project_id           in         number   default null,*/
    p_from_project            in         varchar2  default null,
    p_to_project              in         varchar2  default null,
    p_plan_type_id            in         number   default null,
    p_rbs_header_id           in         number   default null,
    p_transaction_type    in         varchar2 default null,	 --  Bug#5099574 - New parameter for Partial Refresh
    p_plan_versions     in         varchar2 default null,	 --  Bug#5099574 - New parameter for Partial Refresh
    p_project_status          in    varchar2 default null,
    p_only_pt_projects_flag   in         varchar2 default null
  );

end PJI_PJP_SUM_MAIN;

/
