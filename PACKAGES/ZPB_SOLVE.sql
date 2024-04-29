--------------------------------------------------------
--  DDL for Package ZPB_SOLVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_SOLVE" AUTHID CURRENT_USER AS
/* $Header: zpbsolve.pls 120.3 2007/12/04 15:47:27 mbhat ship $ */
TYPE ref_cursor IS REF CURSOR;
TYPE MemberList is table of VARCHAR2(50);
TYPE MemberNameList is table of VARCHAR2(256);
TYPE MemberOrderList is table of NUMBER;
TYPE MemberSourceType is table of NUMBER;
TYPE DimensionType is table of VARCHAR2(50);
  propagateList MemberList;
  propagateName MemberNameList;
  propagateOrder MemberOrderList;
  propagateSourceType MemberSourceType;
  propagateDefDHDimList DimensionType;
  propagateDefInputSelDimList DimensionType;

  LOADED_SOURCE INTEGER := 1000;
  WS_INPUT_SOURCE INTEGER := 1100;
  INIT_WS_INPUT_SOURCE INTEGER := 1130;
  AGGREGATED_SOURCE INTEGER := 1160;
  CALCULATED_SOURCE INTEGER := 1200;
  iTrueValue   INTEGER  := 1;
  iFalseValue  INTEGER := 0;
  PROCEDURE propagateSolve (
                       p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                       p_from_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                       p_view_dim_name IN VARCHAR2,
                       p_view_member_column IN VARCHAR2,
                       p_view_short_lbl_column IN VARCHAR2,
                       p_prop_calc IN INTEGER,
                       p_prop_alloc IN INTEGER,
                       p_prop_input IN INTEGER,
                       p_prop_output IN INTEGER,
                       p_prop_dimhandling IN INTEGER);

  FUNCTION getDimSettingMeaning(
                       p_lookup_code IN FND_LOOKUP_VALUES_VL.LOOKUP_CODE%TYPE
                       ) RETURN VARCHAR2;

  PROCEDURE updateCleanup(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                        p_line_member IN ZPB_SOLVE_MEMBER_DEFS.MEMBER%TYPE,
                        p_src_type IN ZPB_SOLVE_MEMBER_DEFS.SOURCE_TYPE%TYPE);

 PROCEDURE deleteOutputSelections(p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE,
                                  p_targetIndex IN INTEGER );
 PROCEDURE  insertDefaultOutput(p_ac_id IN ZPB_SOLVE_OUTPUT_SELECTIONS.ANALYSIS_CYCLE_ID%TYPE,
                        p_line_member IN ZPB_SOLVE_OUTPUT_SELECTIONS.MEMBER%TYPE,
                        p_memberOrder IN ZPB_SOLVE_OUTPUT_SELECTIONS.MEMBER_ORDER%TYPE,
                        p_dimension IN ZPB_SOLVE_OUTPUT_SELECTIONS.DIMENSION%TYPE);

 PROCEDURE initialize_solve_selections
    (p_ac_id   IN zpb_analysis_cycles.analysis_cycle_id%TYPE);

procedure run_solve (errbuf out nocopy varchar2,
                     retcode out nocopy varchar2,
                     p_business_area_id in number,
			   p_instance_id in number);



END ZPB_SOLVE;

/
