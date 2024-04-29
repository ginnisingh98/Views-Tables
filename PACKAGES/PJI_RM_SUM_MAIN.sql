--------------------------------------------------------
--  DDL for Package PJI_RM_SUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_RM_SUM_MAIN" AUTHID CURRENT_USER as
/* $Header: PJISR01S.pls 120.2 2005/12/07 21:54:47 appldev noship $ */

  g_process             varchar2(30) := 'PJI_PJI';
  g_parallel_limit      number       := 8;
  g_null                varchar2(8)  := 'PJI$NULL';
  g_parameter_date_mask varchar2(21) := 'YYYY/MM/DD HH24:MI:SS';
  g_date_mask           varchar2(21) := 'YYYY/MM/DD';
  g_full_disp_name      varchar2(30) := 'PJI_PJI_SUMMARIZE_FULL';
  g_incr_disp_name      varchar2(30) := 'PJI_PJI_SUMMARIZE_INCR';
  g_prtl_disp_name      varchar2(30) := 'PJI_PJI_SUMMARIZE_PRTL';
  g_helper_name         varchar2(30) := 'PJI_RM_HELPER_1';
  g_parallel_processes  number       := 8;
  g_process_delay       number       := 10;
  g_commit_threshold    number       := 10000;

  g_min_date            date         := PJI_UTILS.GET_EXTRACTION_START_DATE;
  g_max_date            date         := to_date('3000/01/01','YYYY/MM/DD');

  function PRIOR_ITERATION_SUCCESSFUL return boolean;

  procedure INIT_PROCESS
  (
    p_run_mode        in         varchar2,
    p_prtl_schedule   in         varchar2 default null, -- RM
    p_organization_id in         number   default null, -- RM parameter
    p_include_sub_org in         varchar2 default 'N',  -- RM parameter
    p_prtl_financial  in         varchar2 default null, -- FM
    p_operating_unit  in         number   default null, -- FM parameter
    p_from_project    in         varchar2 default null, -- FM parameter
    p_to_project      in         varchar2 default null, -- FM parameter
    p_plan_type       in         varchar2 default null  -- FM parameter
  );

  function PROCESS_RUNNING (p_wait in varchar2) return boolean;

  procedure RUN_PROCESS;

  function MY_PAD (p_length in number,
                   p_char   in varchar2) return varchar2;

  function GET_MISSING_TIME_HEADER return varchar2;

  function GET_MISSING_TIME_TEXT (p_calendar_name in varchar2,
                                  p_period_type   in varchar2,
                                  p_from_date     in date,
                                  p_to_date       in date) return varchar2;

  procedure DANGLING_REPORT;

  procedure WRAPUP_PROCESS;

  procedure WRAPUP_FAILURE;

  procedure SHUTDOWN_PROCESS (errbuf  out nocopy varchar2,
                              retcode out nocopy varchar2);

  procedure SUMMARIZE
  (
    errbuf            out nocopy varchar2,
    retcode           out nocopy varchar2,
    p_run_mode        in         varchar2,
    p_prtl_schedule   in         varchar2 default null, -- RM
    p_organization_id in         number   default null, -- RM parameter
    p_include_sub_org in         varchar2 default 'N',  -- RM parameter
    p_prtl_financial  in         varchar2 default null, -- FM
    p_operating_unit  in         number   default null, -- FM parameter
    p_from_project    in         varchar2 default null, -- FM parameter
    p_to_project      in         varchar2 default null, -- FM parameter
    p_plan_type       in         varchar2 default null  -- FM parameter
  );

end PJI_RM_SUM_MAIN;

 

/
