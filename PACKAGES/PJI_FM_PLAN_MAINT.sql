--------------------------------------------------------
--  DDL for Package PJI_FM_PLAN_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_FM_PLAN_MAINT" AUTHID CURRENT_USER AS
/* $Header: PJIPP01S.pls 120.4 2005/09/10 19:19:43 appldev noship $ */

-- This line is could be deleted, for reference only: pji_empty_num_tbl is a sql type of nested table of numbers. Source: $PA_TOP/.../par1tt20.sql

pji_empty_num_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
pji_empty_varchar2_30_tbl SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();


------------------------------------------------------------------
------------------------------------------------------------------
--              Public Apis Declaration                         --
------------------------------------------------------------------
------------------------------------------------------------------

PROCEDURE MAP_RESOURCE_LIST (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_context           IN   VARCHAR2 := 'BULK');


------------------------------------------------------------------
------------------------------------------------------------------
--              Private Apis Declaration                        --
------------------------------------------------------------------
------------------------------------------------------------------

PROCEDURE CREATE_PRIMARY_UPGRD_PVT
( p_context    IN VARCHAR2 := 'FPM_UPGRADE' -- Valid values: 'FPM_UPGRADE' and 'TRUNCATE'
) ;

PROCEDURE CREATE_PRIMARY_PVT(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_is_primary_rbs    IN   VARCHAR2 -- Valid values are T/F
, p_commit            IN   VARCHAR2 := 'F'
, p_fp_src_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
,p_copy_mode  IN VARCHAR2 :=NULL
 );


PROCEDURE DELETE_ALL_PVT (
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F');


PROCEDURE CREATE_SECONDARY_PVT(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F'
, p_process_all       IN   VARCHAR2 := 'F');


PROCEDURE CREATE_SECONDARY_T_PVT(
  p_fp_version_ids    IN   SYSTEM.pa_num_tbl_type := pji_empty_num_tbl
, p_commit            IN   VARCHAR2 := 'F'
, p_process_all       IN   VARCHAR2 := 'F');


PROCEDURE UPDATE_PRIMARY_PVT(
  p_plan_version_ids  IN   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
, p_commit            IN   VARCHAR2 := 'F');


PROCEDURE UPDATE_PRIMARY_PVT_ACT_ETC (
      p_commit               IN   VARCHAR2 := 'F'
    , p_plan_version_id      IN   NUMBER := NULL
    , p_prev_pub_version_id  IN   NUMBER := NULL
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_processing_code     OUT NOCOPY VARCHAR2);


PROCEDURE POPULATE_FIN8(
  p_worker_id		IN	NUMBER
, p_extraction_type     IN	VARCHAR2
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_data        OUT NOCOPY  VARCHAR2 );


----------------------------------------------
----- Partial refresh of plan data...    -----
----------------------------------------------

PROCEDURE PULL_PLANS_FOR_PR (
  p_rbs_version_id  IN NUMBER
, p_plan_type_id    IN NUMBER
, p_context         IN VARCHAR2    -- Valid values are 'RBS' or 'PLANTYPE'.
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 ) ;


---------------------------------------------------------
----- Full and Incr summarization of actuals ...    -----
---------------------------------------------------------

PROCEDURE GET_ACTUALS_SUMM (
  p_extr_type       IN VARCHAR2    -- Valid values are 'FULL' and 'INCR'.
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_code        OUT NOCOPY  VARCHAR2 ) ;


----------------------------------------------
----- Misc apis...    -----
----------------------------------------------

FUNCTION CHECK_VER3_NOT_EMPTY ( p_online IN VARCHAR2 := 'T')  -- Valid values T/F
RETURN VARCHAR2;


END PJI_FM_PLAN_MAINT;

 

/
