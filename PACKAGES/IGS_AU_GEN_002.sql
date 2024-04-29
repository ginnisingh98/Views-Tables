--------------------------------------------------------
--  DDL for Package IGS_AU_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AU_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSAU02S.pls 120.0 2005/06/02 00:23:11 appldev noship $ */
Function Audp_Get_Culh_Col(
  p_unit_cd  IGS_PS_UNIT_LVL_HIST_ALL.unit_cd%TYPE ,
  p_course_type  IGS_PS_UNIT_LVL_HIST_ALL.course_type%TYPE DEFAULT NULL,
  p_version_number  IGS_PS_UNIT_LVL_HIST_ALL.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  IGS_PS_UNIT_LVL_HIST_ALL.hist_start_dt%TYPE,
  p_course_cd   IGS_PS_UNIT_LVL_HIST_ALL.course_cd%TYPE,
  p_course_version_number   IGS_PS_UNIT_LVL_HIST_ALL.course_version_number%TYPE
  )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Culh_Col, WNDS);

Function Audp_Get_Cvh_Col(
  p_course_cd  IGS_PS_VER_HIST_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_VER_HIST_ALL.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  IGS_PS_VER_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Cvh_Col, WNDS);

Function Audp_Get_Dh_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_dscplne_grp_cd  IGS_PS_DSCP_HIST_ALL.discipline_group_cd%TYPE ,
  p_hist_end_dt  IGS_PS_DSCP_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Dh_Col, WNDS);

Function Audp_Get_Fcflh_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_fee_cat IN IGS_FI_F_CAT_F_LBL_H_ALL.fee_cat%TYPE ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN IGS_FI_F_CAT_F_LBL_H_ALL.fee_type%TYPE ,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Fcflh_Col, WNDS);

Function Audp_Get_Fosh_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_field_of_study  IGS_PS_FLD_STDY_HIST_ALL.field_of_study%TYPE ,
  p_hist_end_dt  IGS_PS_FLD_STDY_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Fosh_Col, WNDS);

Function Audp_Get_Fsh_Col(
  p_funding_source  IGS_FI_FUND_SRC_HIST_ALL.funding_source%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_end_dt  IGS_FI_FUND_SRC_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Fsh_Col, WNDS);

Function Audp_Get_Fsrh_Col(
  p_course_cd  IGS_FI_FD_SRC_RSTN_H_ALL.course_cd%TYPE ,
  p_version_number  IGS_FI_FD_SRC_RSTN_H_ALL.version_number%TYPE ,
  p_funding_source  IGS_FI_FD_SRC_RSTN_H_ALL.funding_source%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  IGS_FI_FD_SRC_RSTN_H_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Fsrh_Col, WNDS);

Function Audp_Get_Ftcih_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_CI_H_ALL.fee_type%TYPE ,
  p_fee_cal_type IN IGS_FI_FEE_TYPE_CI_H_ALL.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_hist_end_dt IN IGS_FI_FEE_TYPE_CI_H_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Ftcih_Col, WNDS);

END IGS_AU_GEN_002;

 

/
