--------------------------------------------------------
--  DDL for Package PJI_FM_SUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_SUM_MAIN" AUTHID CURRENT_USER as
  /* $Header: PJISF01S.pls 120.4 2006/07/22 02:41:02 svermett noship $ */

  g_process             varchar2(30) := 'PJI_EXTR';
  g_null                varchar2(8)  := 'PJI$NULL';
  g_parameter_date_mask varchar2(21) := 'YYYY/MM/DD HH24:MI:SS';
  g_date_mask           varchar2(21) := 'YYYY/MM/DD';
  g_full_disp_name      varchar2(30) := 'PJI_FM_SUMMARIZE_FULL';
  g_incr_disp_name      varchar2(30) := 'PJI_FM_SUMMARIZE_INCR';
  g_prtl_disp_name      varchar2(30) := 'PJI_FM_SUMMARIZE_PRTL';
  g_helper_name         varchar2(30) := 'PJI_FM_HELPER_1';
  g_parallel_processes  number       := 8;
  g_process_delay       number       := 10;
  g_commit_threshold    number       := 10000;

  procedure RUN_SETUP;

  function PRIOR_ITERATION_SUCCESSFUL return boolean;

  procedure INIT_PROCESS
  (
    p_run_mode            in         varchar2,
    p_extract_commitments in         varchar2 default 'N',
    p_organization_id     in         number   default null,
    p_include_sub_org     in         varchar2 default null,
    p_operating_unit      in         number   default null,
    p_from_project        in         varchar2 default null,
    p_to_project          in         varchar2 default null,
    p_plan_type           in         varchar2 default null,
    p_cmt_operating_unit  in         number   default null,
    p_cmt_from_project    in         varchar2 default null,
    p_cmt_to_project      in         varchar2 default null
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

  procedure WRAPUP_SETUP;

  procedure WRAPUP_PROCESS;

  procedure WRAPUP_FAILURE;

  procedure SUMMARIZE
  (
    errbuf                out nocopy varchar2,
    retcode               out nocopy varchar2,
    p_run_mode            in         varchar2,
    p_extract_commitments in         varchar2 default 'N',
    p_organization_id     in         number   default null,
    p_include_sub_org     in         varchar2 default null,
    p_operating_unit      in         number   default null,
    p_from_project        in         varchar2 default null,
    p_to_project          in         varchar2 default null,
    p_plan_type           in         varchar2 default null,
    p_cmt_operating_unit  in         number   default null,
    p_cmt_from_project    in         varchar2 default null,
    p_cmt_to_project      in         varchar2 default null
  );

end PJI_FM_SUM_MAIN;

 

/
