--------------------------------------------------------
--  DDL for Package PJI_PROCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PROCESS_UTIL" AUTHID CURRENT_USER as
  /* $Header: PJIUT03S.pls 120.2.12010000.2 2009/08/28 05:59:45 dlella ship $ */

  -- ----------------------------------------------------------
  -- function SUMMARIZATION_STARTED
  -- ----------------------------------------------------------
  function SUMMARIZATION_STARTED
  (
    p_stage in varchar2 default 'STAGE1_EXTR'
  ) return varchar2;

  -- ----------------------------------------------------------
  -- function NEED_TO_RUN_STEP
  --
  -- This function returns FALSE if a given process step
  -- did not run before or has failed during prior
  -- process iteration.
  -- ----------------------------------------------------------
  function NEED_TO_RUN_STEP
  (
    p_process in varchar2,
    p_step    in  varchar2
  ) return boolean;


  -- ----------------------------------------------------------
  -- procedure REGISTER_STEP_COMPLETION
  --
  -- This utility procedure is called from individual steps.
  -- Procedure updates process log table with successful
  -- completion status for a given step.
  -- ----------------------------------------------------------
  procedure REGISTER_STEP_COMPLETION
  (
    p_process in varchar2,
    p_step    in varchar2
  );


  -- ----------------------------------------------------------
  -- procedure CHECK_STEP
  --
  -- This utility is for debugging purposes.
  -- If check step is not set to 'Y' any step can be run in
  -- the summarization process without looking at
  -- PJI_SYSTEM_PRC_STATUS to see if the step has run before.
  -- ----------------------------------------------------------
  procedure CHECK_STEP (p_check_step in varchar2 default 'Y');


  -- ----------------------------------------------------------
  -- procedure WRAPUP_PROCESS
  --
  -- If process completed successfuly, we clean up process
  -- log table from the step status records.
  -- ----------------------------------------------------------
  procedure WRAPUP_PROCESS (p_process in varchar2);


  -- ----------------------------------------------------------
  -- procedure ADD_STEPS
  -- ----------------------------------------------------------
  procedure ADD_STEPS
  (
    p_process         in varchar2,
    p_step_process    in varchar2,
    p_extraction_type in varchar2
  );


  -- ----------------------------------------------------------
  -- function PRIOR_ITERATION_SUCCESSFUL
  --
  -- This function returns TRUE if prior load process
  -- completed successful.
  -- If prior iteration is successful, process log table
  -- does not have any records for the process.
  -- ----------------------------------------------------------
  function PRIOR_ITERATION_SUCCESSFUL (p_process in varchar2) return boolean;


  -- ----------------------------------------------------------
  -- function GET_PROCESS_PARAMETER
  -- ----------------------------------------------------------
  function GET_PROCESS_PARAMETER
  (
    p_process   in varchar2,
    p_parameter in varchar2
  ) return varchar2;


  -- ----------------------------------------------------------
  -- procedure SET_PROCESS_PARAMETER
  -- ----------------------------------------------------------
  procedure SET_PROCESS_PARAMETER
  (
    p_process   in varchar2,
    p_parameter in varchar2,
    p_value     in varchar2
  );


  -- ----------------------------------------------------------
  -- procedure SLEEP
  -- ----------------------------------------------------------
  procedure SLEEP (p_time_in_seconds in number);


  -- ----------------------------------------------------------
  -- procedure TRUNC_INT_TABLE
  -- ----------------------------------------------------------
  procedure TRUNC_INT_TABLE
  ( p_schema      in varchar2
    , p_tablename in varchar2
    , p_trunc_type in varchar2
	, p_partition in varchar2
  );


  -- ----------------------------------------------------------
  -- function WAIT_FOR_STEP
  --
  -- This function waits until all applicable workers have
  -- completed p_step.
  -- ----------------------------------------------------------
  function WAIT_FOR_STEP
  (
    p_process in varchar2,
    p_step    in varchar2,
    p_timeout in number,
    p_exists  in varchar2 default 'ONLY_IF_EXISTS'
  ) return boolean;


  -- ----------------------------------------------------------
  -- procedure CLEAN_HELPER_BATCH_TABLE
  -- ----------------------------------------------------------
  procedure CLEAN_HELPER_BATCH_TABLE;


  -- -----------------------------------------------------
  -- function REQUEST_STATUS
  -- -----------------------------------------------------
  function REQUEST_STATUS
  (
    p_mode         in varchar2,
    p_request_id   in number,
    p_request_name in varchar2
  ) return boolean;


  -- -----------------------------------------------------
  -- procedure WAIT_FOR_REQUEST
  -- -----------------------------------------------------
  procedure WAIT_FOR_REQUEST
  (
    p_request_id in number,
    p_delay in number
  );

  -- ----------------------------------------------------------
  -- procedure REFRESH_STEP_TABLE
  -- ----------------------------------------------------------
  procedure REFRESH_STEP_TABLE;

/* Added for Bug 7551819 */
/* The following procedures have been added to implement partition clause
   for parallel processing of data */

  procedure EXECUTE_ROLLUP_FPR_WBS (p_worker_id in number default null,
                                    p_level in number default null,
                                    p_partial_mode in varchar2,
                                    p_fpm_upgrade in varchar2);

  procedure EXECUTE_ROLLUP_ACR_WBS (p_worker_id in number default null,
                                    p_level in number default null);

  procedure EXECUTE_ROLLUP_FPR_PRG (p_worker_id in number default null,
                                    p_level in number default null);

  procedure EXECUTE_ROLLUP_ACR_PRG (p_worker_id in number default null,
                                    p_level in number default null);

  procedure EXECUTE_AGGREGATE_PLAN_DATA (p_worker_id in number default null);
/* Added for Bug 7551819 */


end pji_process_util;

/
