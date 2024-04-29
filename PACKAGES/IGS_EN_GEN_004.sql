--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSEN04S.pls 120.0 2005/06/01 22:06:00 appldev noship $ */
/* HISTORY
   WHO        WHEN             WHAT
   ayedubat  30-MAY-2002      Added the out NOCOPY parameter,p_message_name in the Function,Enrp_Get_Rec_Window
                              as part of bug fix:2337161
*/
--Updated by Sudhir.
--Update Date: 28-Feb-2002.
--Added a new parameter p_admin_unit_sta to the procedure enrp_dropall_unit

-- Enhancement Bug # 1832130
-- Added new procedure Enrp_Dropall_Unit .Added a new parameter p_uoo_id in the function Enrp_Get_Rec_Window.
-- Created By : jbegum
-- Creation date : 17/7/2001

Function Enrp_Get_Pa_Gap(
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Pa_Gap, WNDS, WNPS);

Function Enrp_Get_Pei_Dt(
  p_person_id IN NUMBER )
RETURN DATE;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Pei_Dt, WNDS);

Procedure Enrp_Get_Pe_Exists(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_alternate IN boolean ,
  p_check_address IN boolean ,
  p_check_disability IN boolean ,
  p_check_visa IN boolean ,
  p_check_finance IN boolean ,
  p_check_notes IN boolean ,
  p_check_statistics IN boolean ,
  p_check_alias IN boolean ,
  p_alternate_exists OUT NOCOPY boolean ,
  p_address_exists OUT NOCOPY boolean ,
  p_disability_exists OUT NOCOPY boolean ,
  p_visa_exists OUT NOCOPY boolean ,
  p_finance_exists OUT NOCOPY boolean ,
  p_notes_exists OUT NOCOPY boolean ,
  p_statistics_exists OUT NOCOPY boolean ,
  p_alias_exists OUT NOCOPY boolean );

Function Enrp_Get_Rule_Cutoff(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_date_type IN VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Rule_Cutoff, WNDS);

Function Enrp_Get_Scah_Col(
  p_column_name IN VARCHAR2 ,
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt IN IGS_AS_SC_ATTEMPT_H_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Scah_Col, WNDS);

Function Enrp_Get_Scae_Due(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_passing_due_date_ind IN VARCHAR2 ,
  p_enr_form_due_dt IN DATE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Scae_Due, WNDS, WNPS);

Function Enrp_Get_Rec_Window(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_effective_date IN DATE ,
  p_uoo_id IN NUMBER DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Rec_Window, WNDS);

Function Enrp_Get_Perd_Num(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_acad_start_dt IN DATE )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(Enrp_Get_Perd_Num, WNDS);

Procedure Enrp_Dropall_Unit(
  p_person_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_dcnt_reason_cd IN VARCHAR2 ,
  p_admin_unit_sta IN VARCHAR2 DEFAULT NULL,
  p_effective_date IN DATE DEFAULT SYSDATE,
  p_program_cd IN VARCHAR2,
  p_uoo_id IN NUMBER DEFAULT NULL,
  p_sub_unit IN VARCHAR2 DEFAULT 'N'
  );

END IGS_EN_GEN_004;

 

/
