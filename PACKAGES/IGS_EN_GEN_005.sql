--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_005" AUTHID CURRENT_USER AS
/* $Header: IGSEN05S.pls 120.0 2005/06/02 03:42:05 appldev noship $ */
/******************************************************************
Created By        :
Date Created By   :
Purpose           :
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
vchappid 30-Jul-01   function Enrp_Get_Load_Incur specification has been changed to include uoo_id
                     which is passed to the function igs_en_gen_008.enrp_get_uddc_aus. This function
                     definition has been changed as per Enrollment process DLD
******************************************************************/
-- Bug #1956374
-- As part of the bug# 1956374 removed the function enrp_get_load_incur

FUNCTION Enrp_Get_Fee_Student(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 )
RETURN NUMBER;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Fee_Student, WNDS);

FUNCTION Enrp_Get_Pos_Elgbl(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_pos_sequence_number IN NUMBER ,
  p_always_pre_enrol_ind IN VARCHAR2 ,
  p_acad_period_num IN NUMBER ,
  p_log_creation_dt IN DATE ,
  p_warn_level OUT NOCOPY VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN VARCHAR2;


FUNCTION Enrp_Get_Pre_Uoo(
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_crs_location_cd IN VARCHAR2 ,
  p_uoo_id OUT NOCOPY NUMBER )
RETURN boolean;
-- PRAGMA RESTRICT_REFERENCES(Enrp_Get_Pre_Uoo, WNDS);

FUNCTION Enrp_Get_Pos_Links(
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_pos_location_cd IN VARCHAR2 ,
  p_pos_attendance_mode IN VARCHAR2 ,
  p_pos_attendance_type IN VARCHAR2 ,
  p_pos_unit_set_cd IN VARCHAR2 ,
  p_pos_adm_cal_type IN VARCHAR2 ,
  p_pos_admission_cat IN VARCHAR2 )
RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES(Enrp_Get_Pos_Links, WNDS, WNPS);

FUNCTION Enrp_Get_First_Enr(
  p_person_id IN NUMBER )
RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES(Enrp_Get_First_Enr, WNDS);

FUNCTION Enrp_Get_Frst_Enr_Yr(
  p_person_id IN NUMBER )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Frst_Enr_Yr, WNDS);


FUNCTION Enrp_Get_Last_Enr(
  p_person_id IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Last_Enr, WNDS);

FUNCTION Enrp_Get_Last_Enr_Yr(
  p_person_id IN NUMBER )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(Enrp_Get_Last_Enr_Yr, WNDS);

END IGS_EN_GEN_005;

 

/
