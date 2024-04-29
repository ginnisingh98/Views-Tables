--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_007" AUTHID CURRENT_USER AS
/* $Header: IGSEN07S.pls 120.0 2005/06/01 20:49:59 appldev noship $ */
 -------------------------------------------------------------------------------------------
 --Change History:
 --Who         When            What
 --kkillams    25-04-2003      New parameter p_uoo_id is added to Enrp_Get_Suah_Col, Enrp_Get_Sua_Incur
 --                            and Enrp_Get_Sua_Status  functions w.r.t. bug number 2829262
 -------------------------------------------------------------------------------------------

Function Enrp_Get_Student_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES(Enrp_Get_Student_Ind, WNDS);

FUNCTION Enrp_Get_Suah_Col(
  p_column_name         IN user_tab_columns.column_name%TYPE ,
  p_person_id           IN IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd           IN IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_unit_cd             IN IGS_EN_SU_ATTEMPT_H_ALL.unit_cd%TYPE ,
  p_cal_type            IN IGS_EN_SU_ATTEMPT_H_ALL.cal_type%TYPE ,
  p_ci_sequence_number  IN IGS_EN_SU_ATTEMPT_H_ALL.ci_sequence_number%TYPE ,
  p_hist_end_dt         IN IGS_EN_SU_ATTEMPT_H_ALL.hist_end_dt%TYPE,
  p_uoo_id              IN IGS_EN_SU_ATTEMPT_H_ALL.uoo_id%TYPE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Suah_Col, WNDS);

FUNCTION Enrp_Get_Sua_Incur(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_unit_version_number         IN NUMBER ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_unit_attempt_status         IN VARCHAR2 ,
  p_discontinued_dt             IN DATE ,
  p_administrative_unit_status  IN VARCHAR2,
  p_uoo_id                      IN NUMBER)
RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sua_Incur, WNDS, WNPS);

FUNCTION Enrp_Get_Sua_Status(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_version_number      IN NUMBER ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_enrolled_dt         IN DATE ,
  p_rule_waived_dt      IN DATE ,
  p_discontinued_dt     IN DATE ,
  p_waitlisted_dt       IN DATE DEFAULT NULL, -- Added p_waitlist_dt parameter as per the Bug# 2335455.
  p_uoo_id              IN NUMBER)
RETURN VARCHAR2;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Sua_Status, WNDS);

Function Enrp_Get_Susa_Status(
  p_selection_dt IN DATE ,
  p_student_confirmed_ind IN VARCHAR2 ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2 )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES(Enrp_Get_Susa_Status, WNDS, WNPS);

END IGS_EN_GEN_007;

 

/
