--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SCT" AUTHID CURRENT_USER AS
/* $Header: IGSEN66S.pls 120.0 2005/06/01 21:35:15 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed
  --kkillams    28-04-2003      Added new parameter p_uoo_id to the enrp_val_sua_trnsfr function
  --                            w.r.t. bug number 2829262
  --ckasu       20-Nov-2004     modified signature of enrp_val_sua_trnsfr  procedure by adding
  --                            p_unit_outcome as apart of program transfer build bug#4000939
  -- smaddali  21-dec-04       modified parameter in procedure enrp_val_sua_acad for bug#4083358
  -------------------------------------------------------------------------------------------
  -- Bug #1956374
  -- As part of the bug# 1956374 removed the function  crsp_val_uv_active

  --
  -- Validate the enrolment period for a transferred course_attempt.
  FUNCTION enrp_val_scae_acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_scae_acad, WNDS);
  --
  -- Validate the IGS_PS_OFR_OPT for a transferred unit_attempt
  -- smaddali modified parameter for bug#4083358
  FUNCTION enrp_val_sua_acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_uoo_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sua_acad , WNDS);
  --
  -- To validate student course transfer insert
  FUNCTION enrp_val_sct_insert(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sct_insert , WNDS);
  --
  -- To validate student course transfer 'to' course code
  FUNCTION enrp_val_sct_to(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_crv_version_number IN NUMBER ,
  p_course_attempt_status IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sct_to , WNDS);

  --
  -- To validate student course transfer 'from' course code
  FUNCTION enrp_val_sct_from(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_course_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sct_from, WNDS);

  --
  -- To validate transfer of SUA.
   FUNCTION enrp_val_sua_trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER,
  p_unit_outcome   OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_sua_trnsfr, WNDS);

  --
  -- To validate a student unit set attempt exists.
  FUNCTION enrp_val_susa_exists(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_susa_exists , WNDS);

END IGS_EN_VAL_SCT;

 

/
