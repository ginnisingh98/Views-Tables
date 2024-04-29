--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_013
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_013" AUTHID CURRENT_USER AS
/* $Header: IGSAD13S.pls 115.4 2003/06/20 04:11:37 nsinha ship $ */

Function Adms_Get_Acai_Coo(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_deferred_appl IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Adms_Get_Acai_Coo,WNDS,WNPS);
Function Adms_Get_Acai_Course(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_offer_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;

Function Adms_Get_Acai_Us(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_unit_set_appl IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;

Function Adms_Get_Ads_Item(
  p_adm_doc_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Adms_Get_Ads_Item,WNDS,WNPS);

Function Adms_Get_Aeqs_Item(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Adms_Get_Aeqs_Item,WNDS,WNPS);

Function Adms_Get_Coo_Admperd(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Adms_Get_Coo_Admperd,WNPS,WNDS);


-- Place the following declaration in the package specification adm_gen_013.
Function Adms_Get_Coo_Adm_Cat(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Adms_Get_Coo_Adm_Cat,WNPS,WNDS);

Function Adms_Get_Coo_Crv(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Adms_Get_Coo_Crv,WNDS,WNPS);

FUNCTION check_apc_step(
                    p_admission_cat            VARCHAR2,
                    p_s_admission_process_type VARCHAR2,
                    p_s_adm_step_group_type    VARCHAR2,
                    p_s_admission_step_type    VARCHAR2) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (check_apc_step,WNDS,WNPS);

FUNCTION get_sys_code_status (p_name IN VARCHAR2,
				p_class IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_sys_code_status,WNDS,WNPS);

END IGS_AD_GEN_013;

 

/
