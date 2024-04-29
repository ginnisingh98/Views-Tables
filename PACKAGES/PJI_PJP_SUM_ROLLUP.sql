--------------------------------------------------------
--  DDL for Package PJI_PJP_SUM_ROLLUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PJP_SUM_ROLLUP" AUTHID CURRENT_USER as
  /* $Header: PJISP02S.pls 120.2.12000000.2 2007/05/04 16:46:29 sacgupta ship $ */

  G_PROGRESS_COMMIT_SIZE NUMBER := 10;

  procedure CREATE_EVENTS_SNAPSHOT (p_worker_id in number);

  procedure PROCESS_RBS_CHANGES (p_worker_id in number);

  procedure CREATE_MAPPING_RULES (p_worker_id in number);

  procedure MAP_RBS_HEADERS (p_worker_id in number);

  procedure UPDATE_XBS_DENORM_FULL (p_worker_id in number);

  procedure LOCK_HEADERS (p_worker_id in number);

  procedure UPDATE_PROGRAM_WBS (p_worker_id in number);

  procedure PURGE_EVENT_DATA (p_worker_id in number);

  procedure UPDATE_PROGRAM_RBS (p_worker_id in number);

  procedure SET_ONLINE_CONTEXT (p_event_id              in number,
                                p_project_id            in number,
                                p_plan_type_id          in number,
                                p_old_baselined_version in number,
                                p_new_baselined_version in number,
                                p_old_original_version  in number,
                                p_new_original_version  in number,
                                p_old_struct_version    in number,
                                p_new_struct_version    in number,
                                p_rbs_version in number default null);

  procedure POPULATE_XBS_DENORM_DELTA (p_worker_id in number default null);

  procedure POPULATE_RBS_DENORM_DELTA (p_worker_id in number);

  procedure AGGREGATE_FP_SLICES (p_worker_id in number);

  procedure AGGREGATE_AC_SLICES (p_worker_id in number);

  procedure MARK_EXTRACTED_PROJECTS (p_worker_id in number);

  procedure AGGREGATE_FP_CUST_SLICES (p_worker_id in number);

  procedure AGGREGATE_AC_CUST_SLICES (p_worker_id in number);

  procedure PULL_DANGLING_PLANS (p_worker_id in number);

  procedure PULL_PLANS_FOR_PR (p_worker_id in number);

  procedure PULL_PLANS_FOR_RBS (p_worker_id in number);

  procedure ROLLUP_FPR_RBS_TOP (p_worker_id in number);

  procedure ROLLUP_FPR_WBS (p_worker_id in number default null);

  procedure ROLLUP_FPR_RBS_SMART_SLICES (p_worker_id in number default null);

  procedure ROLLUP_ACR_WBS (p_worker_id in number default null);

  procedure ROLLUP_FPR_PRG (p_worker_id in number);

  procedure ROLLUP_ACR_PRG (p_worker_id in number);

  procedure POPULATE_TIME_DIMENSION (p_worker_id in number);

  procedure ROLLUP_FPR_CAL_NONTP (p_worker_id in number);

  procedure ROLLUP_FPR_CAL_PA (p_worker_id in number);

  procedure ROLLUP_FPR_CAL_GL (p_worker_id in number);

  procedure ROLLUP_FPR_CAL_EN (p_worker_id in number);

  procedure ROLLUP_FPR_CAL_ALL (p_worker_id in number);

  procedure ROLLUP_ACR_CAL_PA (p_worker_id in number);

  procedure ROLLUP_ACR_CAL_GL (p_worker_id in number);

  procedure ROLLUP_ACR_CAL_EN (p_worker_id in number);

  procedure ROLLUP_ACR_CAL_ALL (p_worker_id in number);

  procedure AGGREGATE_PLAN_DATA (p_worker_id in number);

  procedure PURGE_PLAN_DATA (p_worker_id in number);

  procedure GET_FPR_ROWIDS (p_worker_id in number);

  procedure UPDATE_FPR_ROWS (p_worker_id in number);

  procedure INSERT_FPR_ROWS (p_worker_id in number);

  procedure CLEANUP_FPR_ROWID_TABLE (p_worker_id in number);

  procedure GET_ACR_ROWIDS (p_worker_id in number);

  procedure UPDATE_ACR_ROWS (p_worker_id in number);

  procedure INSERT_ACR_ROWS (p_worker_id in number);

  procedure CLEANUP_ACR_ROWID_TABLE (p_worker_id in number);

  procedure UPDATE_XBS_DENORM (p_worker_id in number default null);

  procedure UPDATE_RBS_DENORM (p_worker_id in number default null);

  procedure PROCESS_PENDING_EVENTS (p_worker_id in number);

  procedure PROCESS_PENDING_PLAN_UPDATES (p_worker_id in number);

  procedure GET_PLANRES_ACTUALS (p_worker_id in number);

  procedure GET_TASK_ROLLUP_ACTUALS (p_worker_id in number);

  procedure UNLOCK_ALL_HEADERS (p_worker_id in number);

  procedure EXTRACT_FIN_PLAN_VERS_BULK (p_worker_id in number);

  procedure POPULATE_WBS_HDR (p_worker_id in number);

  procedure UPDATE_WBS_HDR (p_worker_id in number);

  procedure POPULATE_RBS_HDR (p_worker_id in number);

  procedure EXTRACT_PLAN_AMOUNTS_PRIRBS (p_worker_id in number);

  procedure ROLLUP_FPR_RBS_T_SLICE (p_worker_id in number);

  procedure CREATE_FP_PA_PRI_ROLLUP (p_worker_id in number);

  procedure CREATE_FP_GL_PRI_ROLLUP (p_worker_id in number);

  procedure CREATE_FP_ALL_PRI_ROLLUP (p_worker_id in number);

  procedure INSERT_INTO_FP_FACT (p_worker_id in number);

  procedure MARK_EXTRACTED_PLANS (p_worker_id in number);

  procedure REMAP_RBS_TXN_ACCUM_HDRS (p_worker_id in number);

  procedure RETRIEVE_OVERRIDDEN_WP_ETC (p_worker_id in number);

  procedure EXTRACT_PLAN_ETC_PRIRBS (p_worker_id in number);

  procedure CLEANUP (p_worker_id in number default null);

  -- Bug 5957219
  procedure MERGE_INTO_FP_FACTS (p_worker_id in number);

end PJI_PJP_SUM_ROLLUP;

 

/
