--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AA" AUTHID CURRENT_USER AS
/* $Header: IGSAD76S.pls 115.4 2002/11/28 21:41:31 nsidana ship $ */

  --
  -- Validate delete of an IGS_AD_APPL record.
  FUNCTION admp_val_aa_delete(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate insert of an IGS_AD_APPL record.
  FUNCTION admp_val_aa_insert(
  p_person_id IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_title_required_ind IN VARCHAR2 DEFAULT 'N',
  p_birth_dt_required_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate update of an IGS_AD_APPL record.
  FUNCTION admp_val_aa_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the IGS_AD_APPL.appl_dt.
  FUNCTION admp_val_aa_appl_dt(
  p_appl_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the admission application academic calendar.
  FUNCTION admp_val_aa_acad_cal(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the admission application admission calendar.
  FUNCTION admp_val_aa_adm_cal(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the IGS_AD_APPL.admission_cat.
  FUNCTION admp_val_aa_adm_cat(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the IGS_AD_APPL.adm_appl_status.
  FUNCTION admp_val_aa_aas(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if IGS_AD_APPL_STAT.adm_appl_status is closed.
  FUNCTION admp_val_aas_closed(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the IGS_AD_APPL.adm_fee_status.
  FUNCTION admp_val_aa_afs(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_fee_status IN VARCHAR2 ,
  p_fees_required_ind IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if IGS_AD_FEE_STAT.adm_fee_status is closed.

  -- Validate the IGS_AD_APPL.tac_appl_ind.
  FUNCTION admp_val_aa_tac_appl(
  p_person_id IN NUMBER ,
  p_tac_appl_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_AA;

 

/
