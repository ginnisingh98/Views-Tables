--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACA" AUTHID CURRENT_USER AS
/* $Header: IGSAD21S.pls 115.7 2002/11/28 21:27:00 nsidana ship $ */

  TYPE r_aca_aa IS RECORD
  (
  person_id NUMBER(15),
  admission_appl_number NUMBER(2),
  adm_appl_status VARCHAR2(10));

  -- To validate discontinuation and student course transfer
  FUNCTION enrp_val_sca_trnsfr(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2 ,
  p_discontinued_dt IN DATE ,
  p_validation_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name   OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  --

  -- To validate the admission application preference limit.
  FUNCTION admp_val_pref_limit(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_pref_limit  NUMBER ,
  p_message_name   OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate the course code of the admission application.


  --
  -- Perform encumbrance check for admission_course_appl_instance.course_cd


  --
  -- Validate course appl process type against the student course attempt.

  --
  -- Validate admission course application transfer details.
  FUNCTION admp_val_aca_trnsfr(
  p_person_id IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_nominated_version_number IN NUMBER ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_message_name   OUT NOCOPY  VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate if IGS_AD_CD.IGS_AD_CD is closed.
  FUNCTION admp_val_aco_closed(
  p_admission_cd IN VARCHAR2 ,
  p_message_name   OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate if IGS_AD_BASIS_FOR_AD.basis_for_admission_type is closed.
  FUNCTION admp_val_bfa_closed(
  p_basis_for_admission_type IN VARCHAR2 ,
  p_message_name   OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate IGS_AD_PS_APPL.req_for_reconsideration_ind.
  FUNCTION admp_val_aca_req_rec(
  p_req_for_reconsideration_ind IN VARCHAR2 DEFAULT 'N',
  p_req_reconsider_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name   OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate IGS_AD_PS_APPL.req_for_adv_standing_ind.
  FUNCTION admp_val_aca_req_adv(
  p_req_for_adv_standing_ind IN VARCHAR2 DEFAULT 'N',
  p_req_adv_standing_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name   OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_ACA;

 

/
