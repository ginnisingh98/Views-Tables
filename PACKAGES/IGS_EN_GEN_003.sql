--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_003" AUTHID CURRENT_USER as
/* $Header: IGSEN03S.pls 120.1 2005/09/08 15:11:34 appldev noship $ */

Function Enrp_Get_Dflt_Dr(
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Dflt_Dr, WNDS);

Function Enrp_Get_Dflt_Fs(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Dflt_Fs, WNDS);

Function Enrp_Get_Ecps_Group(
  p_s_enrolment_step_type IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Ecps_Group, WNDS,WNPS);

Function Enrp_Get_Encmbrd_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Encmbrd_Ind, WNDS,WNPS);

Function Enrp_Get_Enr_Cat(
  p_person_id                IN NUMBER ,
  p_course_cd                IN VARCHAR2 ,
  p_cal_type                 IN VARCHAR2 ,
  p_ci_sequence_number       IN NUMBER ,
  p_session_enrolment_cat    IN VARCHAR2 ,
  p_enrol_cal_type           OUT NOCOPY VARCHAR2 ,
  p_enrol_ci_sequence_number OUT NOCOPY NUMBER ,
  p_commencement_type        OUT NOCOPY VARCHAR2,
  p_enr_categories           OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Enr_Cat, WNDS);

Function Enrp_Get_Enr_Ci(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_sequence_number IN NUMBER ,
  p_enr_cal_type OUT NOCOPY VARCHAR2 ,
  p_enr_sequence_number OUT NOCOPY NUMBER )
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Enr_Ci, WNDS);

Procedure Enrp_Get_Enr_Pp(
  p_username IN VARCHAR2 ,
  p_cal_type OUT NOCOPY VARCHAR2 ,
  p_sequence_number OUT NOCOPY NUMBER ,
  p_enrolment_cat OUT NOCOPY VARCHAR2 ,
  p_enr_method_type OUT NOCOPY VARCHAR2 );

Function Enrp_Get_Excld_Unit(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Excld_Unit, WNDS);

Function Get_Student_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Encmbrd_Ind, WNDS,WNPS);

Function Get_Staff_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Encmbrd_Ind, WNDS,WNPS);

 Function Stdnt_Crs_Atmpt_Stat(
    perid NUMBER)
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(Stdnt_Crs_Atmpt_Stat, WNDS,WNPS);

PROCEDURE UPD_MAT_MRADM_CAT_TERMS(
    p_person_id IN NUMBER,
    p_program_cd IN VARCHAR2,
    p_unit_attempt_status IN VARCHAR2,
    p_teach_cal_type IN VARCHAR2,
    p_teach_ci_seq_num IN NUMBER);


END IGS_EN_GEN_003;

 

/
