--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACAIU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACAIU" AUTHID CURRENT_USER AS
/* $Header: IGSAD23S.pls 115.6 2003/12/03 20:49:00 knag ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function  crsp_val_um_closed

  -- Validate the ins/upd/del admission course application instance unit
  FUNCTION admp_val_acaiu_iud(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_restr_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate the admission course application instance unit
  FUNCTION admp_val_acaiu_unit(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the admission course application instance unit
  FUNCTION admp_val_acaiu_opt(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the admission course application instance unit outcome status
  FUNCTION admp_val_acaiu_auos(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_unit_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the admission course application instance unit cal. instance
  FUNCTION admp_val_acaiu_ci(
  p_teach_cal_type IN VARCHAR2 ,
  p_teach_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_val_adm_only_ind IN VARCHAR2 DEFAULT 'N',
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the unit mode of the admission course application inst unit.
  FUNCTION admp_val_acaiu_um(
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the admission course application instance unit restr number
  FUNCTION admp_val_acaiu_restr(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_restriction_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_uv_version_number IN NUMBER ,   -- Added for bug 3083148
  p_cal_type IN VARCHAR2 ,          -- Added for bug 3083148
  p_ci_sequence_number IN NUMBER ,  -- Added for bug 3083148
  p_location_cd IN VARCHAR2 ,       -- Added for bug 3083148
  p_unit_class IN VARCHAR2 )        -- Added for bug 3083148
RETURN BOOLEAN;
  --
  -- Validate if IGS_AD_OU_STAT.IGS_AD_OU_STAT is closed.
  FUNCTION admp_val_auos_closed(
  p_adm_unit_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the admission course application instance unit alternate code
  FUNCTION admp_val_acaiu_altcd(
  p_alternate_code IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the unit version of the admission course application.
  FUNCTION admp_val_acaiu_uv(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offered_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Do encumbrance check for admission_course_appl_instance_unit.unit_cd.
  FUNCTION admp_val_acaiu_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_unit_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate an admission course application instance research unit.
  FUNCTION admp_val_res_unit(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
   --
  -- Validate the adm course appl inst unit against the teaching period.
  FUNCTION admp_val_acaiu_uv_ci(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 ,
  p_teach_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_ACAIU;

 

/
