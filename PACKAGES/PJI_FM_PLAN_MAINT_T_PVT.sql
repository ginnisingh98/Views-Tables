--------------------------------------------------------
--  DDL for Package PJI_FM_PLAN_MAINT_T_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_PLAN_MAINT_T_PVT" AUTHID CURRENT_USER AS
/* $Header: PJIPP03S.pls 120.0 2005/05/29 12:20:10 appldev noship $ */


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
--- Copy apis
----------------------------------------------

PROCEDURE COPY_PRIMARY(
  p_source_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_dest_fp_version_ids      IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_source_fp_version_status IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_dest_fp_version_status   IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_commit                   IN   VARCHAR2 := 'F'
);


PROCEDURE COPY_PLANS(
  p_source_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_dest_fp_version_ids      IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_source_fp_version_status IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_dest_fp_version_status   IN   SYSTEM.pa_VARCHAR2_30_tbl_type := pji_empty_VARCHAR2_30_tbl
, p_commit                   IN   VARCHAR2 := 'F'
);


PROCEDURE COPY_PRIMARY_SINGLE
(
  p_source_plan_ver_id  IN NUMBER := NULL
, p_target_plan_ver_id  IN NUMBER := NULL
, p_commit              IN VARCHAR2 := 'F');


----------------------------------------------
--- Extract apis
----------------------------------------------

PROCEDURE EXTRACT_FIN_PLAN_VERS_BULK(
  p_slice_type        IN   VARCHAR2 := NULL -- 'PRI' or 'SEC'
);

PROCEDURE EXTRACT_FIN_PLAN_VERSIONS(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_slice_type        IN   VARCHAR2 := NULL -- 'PRI' or 'SEC'
);

PROCEDURE EXTRACT_CB_CO_PLAN_VERSIONS;

PROCEDURE EXTRACT_PLAN_AMOUNTS_PRIRBS;

PROCEDURE EXTRACT_PLAN_AMOUNTS_SECRBS;

PROCEDURE EXTRACT_PLAN_AMTS_PRIRBS_GLC12;

PROCEDURE EXTRACT_PLAN_AMTS_SECRBS_GLC12;

PROCEDURE REVERSE_PLAN_AMTS;


----------------------------------------------
--- FP Time, WBS, RBS, Program, etc Rollup apis
----------------------------------------------

PROCEDURE CREATE_WBSRLP; -- WBS, Program rollups.

PROCEDURE ROLLUP_FPR_RBS; -- Renamed.. ROLLUP_XBS_AFTER_WBSRLP; -- RBS, Program rollups.

PROCEDURE ROLLUP_FPR_RBS_T_SLICE;

----------------------------------------------
--- Handling non-time phased amounts
----------------------------------------------

PROCEDURE DELETE_PRI_NONTIMEPH_ENTDAMTS;

-- PROCEDURE RETRIEVE_BL_SECSLC_NONTIMEPH;

-- PROCEDURE RETRIEVE_RL_SECSLC_TIMEPH;


----------------------------------------------
--- FP Insert/Merge apis
----------------------------------------------

PROCEDURE INSERT_INTO_FP_FACT (p_slice_type IN VARCHAR2 := NULL);

PROCEDURE MERGE_INTO_FP_FACT;

PROCEDURE GET_FP_ROW_IDS;

PROCEDURE UPDATE_FP_ROWS;

PROCEDURE INSERT_FP_ROWS;


----------------------------------------------
--- AC Insert/Merge apis
----------------------------------------------

PROCEDURE INSERT_INTO_AC_FACT;

PROCEDURE MERGE_INTO_AC_FACT;

PROCEDURE GET_AC_ROW_IDS;

PROCEDURE UPDATE_AC_ROWS;

PROCEDURE INSERT_AC_ROWS;


----------------------------------------------
--- Handling deltas in budget line entries
----------------------------------------------

PROCEDURE RETRIEVE_DELTA_SLICE;

PROCEDURE POPULATE_PLN_VER_TABLE;


----------------------------------------------
--- Misc extraction/secondary creation helper apis
----------------------------------------------

PROCEDURE GET_PRI_SLICE_DATA(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F');

PROCEDURE GET_GLOBAL_EXCHANGE_RATES;

PROCEDURE DELETE_GLOBAL_EXCHANGE_RATES;

-- PROCEDURE CONV_TO_GLOBAL_CURRENCIES;
-- PROCEDURE UPDATE_CURR_RCD_TYPES_GL1_GL2;

PROCEDURE DO_CURRENCY_DANGLING_CHECK;

-- PROCEDURE CREATE_GL1_GL2_CURR_RCDS;
-- PROCEDURE AGGREGATE ;


----------------------------------------------
--- Prorate apis
----------------------------------------------

PROCEDURE GET_PRORATE_FORMAT;

PROCEDURE GET_SPREAD_DATE_RANGE_AMOUNTS;

PROCEDURE SPREAD_NON_TIME_PHASE_AMOUNTS;

PROCEDURE PRORATE_NON_TIME_PHASED_AMTS(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
);

PROCEDURE PRORATE_TO_OTHER_CALENDAR(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
);

PROCEDURE PRORATE_TO_ALL_CALENDARS;

-- PROCEDURE PRORATE_TO_PA;
-- PROCEDURE PRORATE_TO_GL;

PROCEDURE PRORATE_TO_ENT;

PROCEDURE PRORATE(
  p_calENDar_type    IN   VARCHAR2 := NULL -- Values can be GL, PA, ENT, ENTW.
);


----------------------------------------------
--- Dangling check/pull apis
----------------------------------------------

PROCEDURE MARK_EXTRACTED_PLANS(p_slice_type IN VARCHAR2);

PROCEDURE MARK_TIME_DANGLING_VERSIONS;

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

PROCEDURE GET_ACTUALS (
   p_new_pub_version_id  IN NUMBER
 , p_prev_pub_version_id IN  NUMBER := NULL  ) ;

PROCEDURE REVERSE_ETC (
   p_new_pub_version_id  IN NUMBER
 , p_prev_pub_version_id IN  NUMBER := NULL  ) ;

PROCEDURE UPDATE_ACTUALS_TO_NULL;

PROCEDURE MAP_ORG_CAL_INFO ( p_fpm_upgrade IN VARCHAR2 := 'Y');


END PJI_FM_PLAN_MAINT_T_PVT;

 

/
