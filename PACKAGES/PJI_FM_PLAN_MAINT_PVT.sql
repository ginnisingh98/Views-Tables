--------------------------------------------------------
--  DDL for Package PJI_FM_PLAN_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_PLAN_MAINT_PVT" AUTHID CURRENT_USER AS
/* $Header: PJIPP02S.pls 120.5.12000000.2 2007/10/23 12:34:55 csriperu ship $ */


--
-- This line is for reference only: pji_empty_num_tbl is a sql type
-- of nested table of numbers. Source: $PA_TOP/.../par1tt20.sql
--
pji_empty_num_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
pji_empty_varchar2_30_tbl SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();



------------------------------------------------------------------
------------------------------------------------------------------
--              Helper Apis Declaration                         --
------------------------------------------------------------------
------------------------------------------------------------------

----------------------------------------------
--- Extract apis
----------------------------------------------

PROCEDURE VALIDATE_SET_PR_PARAMS(
  p_rbs_version_id  IN NUMBER
, p_plan_type_id    IN NUMBER
, p_context         IN VARCHAR2      -- Valid values are 'RBS' or 'PLANTYPE'.
, x_num_rows        OUT NOCOPY NUMBER
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 );

PROCEDURE OBTAIN_RELEASE_LOCKS (
  p_context         IN          VARCHAR2
, p_lock_mode       IN          VARCHAR2
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 );

PROCEDURE EXTRACT_FIN_PLAN_VERS_BULK(
  p_slice_type        IN   VARCHAR2 := NULL -- 'PRI' or 'SEC'
);

PROCEDURE EXTRACT_FIN_PLAN_VERSIONS(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_slice_type        IN   VARCHAR2 := NULL -- 'PRI' or 'SEC'
);

PROCEDURE EXTRACT_PLAN_AMOUNTS_PRIRBS;

PROCEDURE EXTRACT_PLAN_AMTS_PRIRBS_GLC12
(p_pull_dangling_flag IN VARCHAR2 := 'Y'); -- Reversals to be computed only if pull_dangling flag is 'Y'

PROCEDURE EXTRACT_PLAN_AMTS_SECRBS_GLC12
(p_pull_dangling_flag IN VARCHAR2 := 'Y'); -- Reversals to be computed only if pull_dangling flag is 'Y'

PROCEDURE EXTRACT_DANGL_REVERSAL;

PROCEDURE EXTRACT_ACTUALS(
  p_extrn_type        IN   VARCHAR2 := NULL -- 'FULL' or 'INCR'
);


PROCEDURE PROCESS_PENDING_PLAN_UPDATES(
  p_extrn_type    IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2);


----------------------------------------------
--- Overridden ETC Pull apis.
----------------------------------------------

PROCEDURE RETRIEVE_OVERRIDDEN_WP_ETC;

PROCEDURE EXTRACT_PLAN_ETC_PRIRBS(
  p_slice_type      IN VARCHAR2 := 'PRI' -- 'PRI' or 'SEC'
);

PROCEDURE DELETE_PLAN_LINES ( x_return_status OUT NOCOPY VARCHAR2 ) ;


----------------------------------------------
--- FP Time, WBS, RBS, Program, etc Rollup apis
----------------------------------------------

PROCEDURE CREATE_WBSRLP; -- WBS, Program rollups.

PROCEDURE ROLLUP_FPR_RBS; -- Renamed.. ROLLUP_XBS_AFTER_WBSRLP; -- RBS, Program rollups.

PROCEDURE ROLLUP_FPR_RBS_T_SLICE;


----------------------------------------------
--- FP Insert/Merge apis
----------------------------------------------

PROCEDURE INSERT_INTO_FP_FACT (p_slice_type IN VARCHAR2 := NULL);

PROCEDURE MERGE_INTO_FP_FACT;

PROCEDURE CLEANUP_FP_RMAP_FPR;

PROCEDURE GET_FP_ROW_IDS;

PROCEDURE UPDATE_FP_ROWS;

PROCEDURE INSERT_FP_ROWS;


----------------------------------------------
--- AC Insert/Merge apis
----------------------------------------------

PROCEDURE INSERT_INTO_AC_FACT;

PROCEDURE MERGE_INTO_AC_FACT;

PROCEDURE CLEANUP_AC_RMAP_FPR;

PROCEDURE GET_AC_ROW_IDS;

PROCEDURE UPDATE_AC_ROWS;

PROCEDURE INSERT_AC_ROWS;


PROCEDURE DELETE_GLOBAL_EXCHANGE_RATES;

----------------------------------------------
--- Handling deltas in budget line entries
----------------------------------------------

-- PROCEDURE RETRIEVE_DELTA_SLICE;

PROCEDURE POPULATE_PLN_VER_TABLE;


----------------------------------------------
--- Misc extraction/secondary creation helper apis
----------------------------------------------

PROCEDURE GET_PRI_SLICE_DATA(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F');

PROCEDURE GET_GLOBAL_EXCHANGE_RATES;

PROCEDURE CONV_TO_GLOBAL_CURRENCIES;



----------------------------------------------
--- Prorate apis
----------------------------------------------

PROCEDURE GET_PRORATE_FORMAT;

PROCEDURE GET_SPREAD_DATE_RANGE_AMOUNTS;

PROCEDURE SPREAD_NON_TIME_PHASE_AMOUNTS;


PROCEDURE PRORATE_TO_OTHER_CALENDAR(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
);

PROCEDURE PRORATE_TO_ALL_CALENDARS;

PROCEDURE PRORATE_TO_PA;

PROCEDURE PRORATE_TO_GL;

PROCEDURE PRORATE_TO_ENT;

PROCEDURE PRORATE(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
);


----------------------------------------------
--- Dangling check/pull apis
----------------------------------------------

PROCEDURE MARK_EXTRACTED_PLANS(p_slice_type IN VARCHAR2);


PROCEDURE MARK_DANGLING_PLAN_VERSIONS;

PROCEDURE DELETE_DNGLRATE_PLNVER_DATA;

PROCEDURE PULL_DANGLING_PLANS;


----------------------------------------------
--- RBS update apis
----------------------------------------------

PROCEDURE RETRIEVE_ENTERED_SLICE (
  p_pln_ver_id IN NUMBER := NULL ) ;


----------------------------------------------
--- XBS update apis
----------------------------------------------

PROCEDURE COMPUTE_XBS_UPDATED_ROLLUPS;



----------------------------------------------
----- Populate WBS, RBS header tables... -----
----------------------------------------------

PROCEDURE POPULATE_RBS_HDR;

PROCEDURE POPULATE_WBS_HDR;

PROCEDURE UPDATE_WBS_HDR;



------------------------------------------------------------------------
--- Misc apis needed to do clean up of interim tables, etc.
------------------------------------------------------------------------

PROCEDURE CLEANUP_INTERIM_TABLES;

-- Bug 6520936
PROCEDURE UPDATE_WBS_HDR (p_worker_id in number);

PROCEDURE MERGE_INTO_FP_FACTS;
-- Bug 6520936

END PJI_FM_PLAN_MAINT_PVT;

 

/
