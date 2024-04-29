--------------------------------------------------------
--  DDL for Package IGS_AU_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AU_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSAU03S.pls 115.10 2003/05/23 06:51:02 knaraset ship $ */
-- WHO		 WHEN 		WHAT
-- pradhakr      02/07/2001	Added a function enrp_get_sph_col in this package.
-- 				Changes in the function Audp_Get_scah_col,
--				Audp_Get_Suah_Col.
-- smaddali 	 02/07/2001	adding a new function audp_get_enrs_stat in the
--				enrollment processes build of nov 2001
-- knaraset  29-Apr-03   added p_uoo_id as parameter,also removed the other parameters unit_cd,cal_type and sequence_number
--                       in functions Audp_Get_Suah_Col and ENRP_RET_WAIVE_PERSON_ID ,
--                       as part of MUS build bug 2829262

Function Audp_Get_Enrs_Stat(
  p_stat_column IN VARCHAR2 ,
  p_uoo_id IN NUMBER
   )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Enrs_Stat, WNDS);

Function Audp_Get_Gach_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_create_dt IN DATE ,
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_hist_date IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Gach_Col, WNDS);

Function Audp_Get_Grh_Col(
  p_person_id  IGS_GR_GRADUAND_HIST_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_HIST_ALL.create_dt%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_dt  IGS_GR_GRADUAND_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Grh_Col, WNDS);

Function Audp_Get_Ih_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_institution_cd IN IGS_OR_INST_HIST_ALL.institution_cd%TYPE ,
  p_hist_end_dt IN IGS_OR_INST_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Ih_Col, WNDS);

Function Audp_Get_Ouh_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_org_unit_cd IN IGS_OR_UNIT_HIST_ALL.institution_cd%TYPE ,
  p_ou_start_dt IN IGS_OR_UNIT_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_end_dt IN IGS_OR_UNIT_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Ouh_Col, WNDS);

Function Audp_Get_Scah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt IN IGS_AS_SC_ATTEMPT_H_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Scah_Col, WNDS);

FUNCTION Enrp_Get_Sph_col (
  p_column_name IN VARCHAR2,
  p_spl_perm_request_h_id IN NUMBER,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sph_col, WNDS);

Function Audp_Get_Suah_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_person_id  IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt  IGS_EN_SU_ATTEMPT_H_ALL.hist_end_dt%TYPE,
  p_uoo_id  IGS_EN_SU_ATTEMPT_H_ALL.uoo_id%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Suah_Col, WNDS);

Function Audp_Get_Suaoh_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_hist_end_dt IN DATE,
  p_uoo_id IN NUMBER)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Suaoh_Col, WNDS);

Function Audp_Get_Susah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Audp_Get_Susah_Col, WNDS);

FUNCTION ENRP_RET_WAIVE_PERSON_ID(
  P_H_RULE_WAIVED_PERSON_ID IN NUMBER,
  P_person_id IN NUMBER,
  P_course_cd IN VARCHAR2,
  P_hist_end_dt IN DATE,
  p_uoo_id IN IGS_EN_SU_ATTEMPT_H_ALL.uoo_id%TYPE)
  RETURN NUMBER;

END igs_au_gen_003;

 

/
