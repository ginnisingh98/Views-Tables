--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_002" AUTHID CURRENT_USER as
/* $Header: IGSEN02S.pls 120.0 2005/06/02 04:01:10 appldev noship $ */

Function Enrp_Ext_Enrl_Form(
  p_key IN VARCHAR2 ,
  p_log_type IN VARCHAR2,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(Enrp_Ext_Enrl_Form, WNDS);

Function Enrp_Get_1st_Enr_Crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_1st_Enr_Crs, WNDS);

Function Enrp_Get_Acad_Alt_Cd(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_acad_ci_start_dt OUT NOCOPY DATE ,
  p_acad_ci_end_dt OUT NOCOPY DATE ,
  p_message_name out NOCOPY Varchar2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Acad_Alt_Cd, WNDS, WNPS);

Function Enrp_Get_Acad_Comm(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_admission_appl_number IN NUMBER ,
  p_adm_nominated_course_cd IN VARCHAR2 ,
  p_adm_sequence_number IN NUMBER ,
  p_chk_adm_prpsd_comm_ind IN VARCHAR2 DEFAULT NULL)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Acad_Comm, WNDS, WNPS);

Function Enrp_Get_Acad_P_Att(
  p_load_figure IN NUMBER )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Acad_P_Att, WNDS);

Function Enrp_Get_Acai_Offer(
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Acai_Offer, WNDS,WNPS);

Function Enrp_Get_Att_Dflt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_attendance_type IN VARCHAR2 ,
  p_load_cal_type IN VARCHAR2 ,
  p_eftsu IN OUT NOCOPY NUMBER ,
  p_credit_points OUT NOCOPY NUMBER )
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Att_Dflt, WNDS);

Procedure Enrp_Get_Crs_Exists(
  P_PERSON_ID IN NUMBER ,
  P_COURSE_CD IN VARCHAR2 ,
  P_EFFECTIVE_DT IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_check_hecs IN boolean ,
  p_check_unitset IN boolean ,
  p_check_notes IN boolean ,
  p_check_research IN boolean ,
  p_check_prenrol IN boolean ,
  p_hecs_exists OUT NOCOPY boolean ,
  p_unitset_exists OUT NOCOPY boolean ,
  p_notes_exists OUT NOCOPY boolean ,
  p_research_exists OUT NOCOPY boolean ,
  p_prenrol_exists OUT NOCOPY boolean );

END IGS_EN_GEN_002;

 

/
