--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_006" AUTHID CURRENT_USER AS
/* $Header: IGSEN06S.pls 120.1 2006/02/19 22:37:30 ctyagi noship $ */

Function Enrp_Get_Sca_Acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number OUT NOCOPY NUMBER ,
  p_enrolment_cat OUT NOCOPY VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Acad, WNDS);

Function Enrp_Get_Sca_Am(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER )
RETURN VARCHAR2;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Am, WNDS);

Function Enrp_Get_Sca_Att(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN VARCHAR2;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Att, WNDS);

Function Enrp_Get_Sca_Comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_effective_date IN DATE )
RETURN boolean;
 PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Comm, WNDS, WNPS);

Function Enrp_Get_Sca_Elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_comm_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_dflt_confirmed_course_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name out NOCOPY Varchar2 )
RETURN boolean;
 --PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Elgbl, WNDS, WNPS);


Function Enrp_Get_Sca_Latt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER )
RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Latt, WNDS, WNPS);


Function Enrp_Get_Sca_Perd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Perd, WNDS);

Function Enrp_Get_Sca_Status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_attempt_status IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_discontinued_dt IN DATE ,
  p_lapsed_dt IN DATE ,
  p_course_rqrmnt_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_logical_delete_dt IN DATE )
RETURN VARCHAR2;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Status, WNDS);

Function Enrp_Get_Sca_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sca_Trnsfr, WNDS, WNPS);

END IGS_EN_GEN_006;

 

/
