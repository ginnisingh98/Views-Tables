--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_007" AUTHID CURRENT_USER AS
/* $Header: IGSAD07S.pls 115.5 2002/11/28 21:23:53 nsidana ship $ */
Function Admp_Get_Match_Prsn(
  p_surname IN VARCHAR2 ,
  p_birth_dt IN VARCHAR2 ,
  p_sex IN VARCHAR2 ,
  p_initial IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN NUMBER;

function Admp_Get_Ovrd_Comm(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR ,
  p_sequence_number IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Admp_Get_Ovrd_Comm,WNDS);

Procedure Admp_Get_Pe_Exists(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_athletics IN BOOLEAN ,
  p_check_alternate IN BOOLEAN ,
  p_check_address IN BOOLEAN ,
  p_check_disability IN BOOLEAN ,
  p_check_visa IN BOOLEAN ,
  p_check_finance IN BOOLEAN ,
  p_check_notes IN BOOLEAN ,
  p_check_statistics IN BOOLEAN ,
  p_check_alias IN BOOLEAN ,
  p_check_tertiary IN BOOLEAN ,
  p_check_aus_sec_ed IN BOOLEAN ,
  p_check_os_sec_ed IN BOOLEAN ,
  p_check_employment IN BOOLEAN ,
  p_check_membership IN BOOLEAN ,
  p_check_excurr IN BOOLEAN DEFAULT FALSE,
  p_athletics_exists OUT NOCOPY BOOLEAN ,
  p_alternate_exists OUT NOCOPY BOOLEAN ,
  p_address_exists OUT NOCOPY BOOLEAN ,
  p_disability_exists OUT NOCOPY BOOLEAN ,
  p_visa_exists OUT NOCOPY BOOLEAN ,
  p_finance_exists OUT NOCOPY BOOLEAN ,
  p_notes_exists OUT NOCOPY BOOLEAN ,
  p_statistics_exists OUT NOCOPY BOOLEAN ,
  p_alias_exists OUT NOCOPY BOOLEAN ,
  p_tertiary_exists OUT NOCOPY BOOLEAN ,
  p_aus_sec_ed_exists OUT NOCOPY BOOLEAN ,
  p_os_sec_ed_exists OUT NOCOPY BOOLEAN ,
  p_employment_exists OUT NOCOPY BOOLEAN ,
  p_membership_exists OUT NOCOPY BOOLEAN,
  p_excurr_exists OUT NOCOPY BOOLEAN);

Function Admp_Get_Resp_Dt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_admission_process_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_offer_dt IN DATE )
RETURN DATE;

Function Admp_Get_Saas(
  p_adm_appl_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sacos(
  p_adm_cndtnl_offer_status IN VARCHAR2 )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Admp_Get_Sacos,WNDS,WNPS);

Function Admp_Get_Sads(
  p_adm_doc_status IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Admp_Get_Sads,WNDS,WNPS);

Function Admp_Get_Saeqs(
  p_adm_entry_qual_status IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Admp_Get_Saeqs,WNDS,WNPS);

END IGS_AD_GEN_007;

 

/
