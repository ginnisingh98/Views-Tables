--------------------------------------------------------
--  DDL for Package IGS_AU_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AU_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSAU04S.pls 120.0 2005/06/01 22:21:57 appldev noship $ */

Function Audp_Get_Trh_Col(
  p_unit_cd  IGS_PS_TCH_RESP_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_TCH_RESP_HIST_ALL.version_number%TYPE ,
  p_org_unit_cd  IGS_PS_TCH_RESP_HIST_ALL.org_unit_cd%TYPE ,
  p_ou_start_dt  IGS_PS_TCH_RESP_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_date  IGS_PS_TCH_RESP_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Trh_Col, WNDS);

Function Audp_Get_Troh_Col(
  p_unit_cd  IGS_PS_TCH_RSOV_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_TCH_RSOV_HIST_ALL.version_number%TYPE ,
  p_cal_type  IGS_PS_TCH_RSOV_HIST_ALL.cal_type%TYPE ,
  p_ci_sequence_number  IGS_PS_TCH_RSOV_HIST_ALL.ci_sequence_number%TYPE ,
  p_location_cd  IGS_PS_TCH_RSOV_HIST_ALL.location_cd%TYPE ,
  p_unit_class  IGS_PS_TCH_RSOV_HIST_ALL.unit_class%TYPE ,
  p_org_unit_cd  IGS_PS_TCH_RSOV_HIST_ALL.org_unit_cd%TYPE ,
  p_ou_start_dt  IGS_PS_TCH_RSOV_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_date  IGS_PS_TCH_RSOV_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Troh_Col, WNDS);

Function Audp_Get_Udh_Col(
  p_unit_cd  IGS_PS_UNT_DSCP_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_UNT_DSCP_HIST_ALL.version_number%TYPE ,
  p_discipline_group_cd  IGS_PS_UNT_DSCP_HIST_ALL.discipline_group_cd%TYPE ,
  p_hist_date  IGS_PS_UNT_DSCP_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Udh_Col, WNDS);

Function Audp_Get_Uiclh_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_unit_int_course_level_cd  IGS_PS_UNT_INLV_HIST_ALL.unit_int_course_level_cd%TYPE ,
  p_hist_end_dt  IGS_PS_UNT_INLV_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Uiclh_Col, WNDS);

Function Audp_Get_Urch_Col(
  p_unit_cd  IGS_PS_UNIT_REF_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_UNIT_REF_HIST_ALL.version_number%TYPE ,
  p_reference_cd_type  IGS_PS_UNIT_REF_HIST_ALL.reference_cd_type%TYPE ,
  p_reference_cd  IGS_PS_UNIT_REF_HIST_ALL.reference_cd%TYPE ,
  p_hist_date  IGS_PS_UNIT_REF_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Urch_Col, WNDS);

Function Audp_Get_Ush_Col(
  p_unit_set_cd  IGS_EN_UNIT_SET_HIST_ALL.unit_set_cd%TYPE ,
  p_version_number  IGS_EN_UNIT_SET_HIST_ALL.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_end_dt  IGS_EN_UNIT_SET_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Ush_Col, WNDS);

Function Audp_Get_Uvh_Col(
  p_unit_cd  IGS_PS_UNIT_VER_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_UNIT_VER_HIST_ALL.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  IGS_PS_UNIT_VER_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Uvh_Col, WNDS);

END IGS_AU_GEN_004;

 

/
