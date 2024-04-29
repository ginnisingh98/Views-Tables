--------------------------------------------------------
--  DDL for Package IGS_AU_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AU_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSAU01S.pls 115.4 2003/12/03 20:48:57 knag ship $ */
Function Audp_Get_Aah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN IGS_AD_APPL_HIST_ALL.person_id%TYPE ,
  p_admission_appl_number IN NUMBER ,
  p_hist_end_dt IN IGS_AD_APPL_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Aah_Col, WNDS,WNPS);

Function Audp_Get_Acah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN IGS_AD_PS_APPL_HIST_ALL.person_id%TYPE ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_hist_end_dt IN IGS_AD_PS_APPL_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Acah_Col, WNDS);

Function Audp_Get_Acaih_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Acaih_Col, WNDS);

Function Audp_Get_Acaiuh_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
  p_person_id IN NUMBER DEFAULT NULL,
  p_admission_appl_number IN NUMBER DEFAULT NULL,
  p_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
  p_acai_sequence_number IN NUMBER DEFAULT NULL,
  p_unit_cd IN IGS_AD_PS_APINTUNTHS_ALL.unit_cd%TYPE DEFAULT NULL,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Acaiuh_Col, WNDS);

Function Audp_Get_Cfosh_Col(
  p_course_cd  IGS_PS_FLD_STD_HIST_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_FLD_STD_HIST_ALL.version_number%TYPE ,
  p_field_of_study  IGS_PS_FLD_STD_HIST_ALL.field_of_study%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  IGS_PS_FLD_STD_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Cfosh_Col, WNDS);

Function Audp_Get_Coh_Col(
  p_course_cd  IGS_PS_OWN_HIST_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_OWN_HIST_ALL.version_number%TYPE ,
  p_org_unit_cd  IGS_PS_OWN_HIST_ALL.org_unit_cd%TYPE ,
  p_ou_start_dt  IGS_PS_OWN_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_date  IGS_PS_OWN_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Coh_Col, WNDS);

Function Audp_Get_Crch_Col(
  p_course_cd  IGS_PS_REF_CD_HIST_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_REF_CD_HIST_ALL.version_number%TYPE ,
  p_reference_cd_type  IGS_PS_REF_CD_HIST_ALL.reference_cd_type%TYPE ,
  p_reference_cd  IGS_PS_REF_CD_HIST_ALL.reference_cd%TYPE ,
  p_hist_date  IGS_PS_REF_CD_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Crch_Col, WNDS);

Function Audp_Get_Cth_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_course_type  IGS_PS_TYPE_ALL.course_type%TYPE ,
  p_hist_end_dt  IGS_PS_TYPE_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Cth_Col, WNDS);

END IGS_AU_GEN_001;

 

/
