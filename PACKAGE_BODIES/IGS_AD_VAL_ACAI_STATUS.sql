--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACAI_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACAI_STATUS" AS
/* $Header: IGSAD24B.pls 120.8 2005/11/25 04:51:02 appldev ship $ */
  --bug 1956374 msrinivi Removed duplicate func enrp_val_trnsfr_act 27 aug,01
  -- Validate the IGS_AD_PS_APPL_INST.adm_entry_qual_status.
  -- hreddych #2602077  SF Integration Added the FUNCTION admp_val_aods_update
  --sarakshi    27-Feb-2003    Enh#2797116,modified procedure admp_val_lafs_coo ,added delete_falg check in the where clause
  --                           of the cursor c_coo
  FUNCTION admp_val_acai_aeqs(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_aeqs
  	-- Validate the IGS_AD_PS_APPL_INST.adm_entry_qual_status.
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_s_adm_entry_qual_status	igs_ad_ent_qf_stat.s_adm_entry_qual_status%TYPE;
  	v_s_adm_outcome_status	        igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Perform item level validations.
  	IF	IGS_AD_VAL_ACAI_STATUS.admp_val_aeqs_item (
  				p_adm_entry_qual_status,
  				p_s_admission_process_type,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Perform cross-status validations.
  	-- Get the system status values.
  	v_s_adm_entry_qual_status := IGS_AD_GEN_007.ADMP_GET_SAEQS (p_adm_entry_qual_status);
  	v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (p_adm_outcome_status);
  	-- Validate against the admission outcome status.
  	IF IGS_AD_VAL_ACAI_STATUS.admp_val_aeqs_aos (
  				v_s_adm_entry_qual_status,
  				v_s_adm_outcome_status,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	   IF p_message_name <> 'IGS_GE_UNHANDLED_EXP' AND FND_MSG_PUB.Count_Msg < 1 THEN
	     p_message_name := 'IGS_GE_UNHANDLED_EXP';
	     Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	     Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aeqs');
	     IGS_GE_MSG_STACK.ADD;
           END IF;
	    App_Exception.Raise_Exception;

  END admp_val_acai_aeqs;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_entry_qual_status.
  FUNCTION admp_val_aeqs_item(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aeqs_item
  	-- Validate the IGS_AD_PS_APPL_INST.adm_entry_qual_status.
  	-- It must be open and valid.
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_s_adm_entry_qual_status	igs_ad_ent_qf_stat.s_adm_entry_qual_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the closed indicator
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_aeqs_closed(
  				p_adm_entry_qual_status,
  				v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate against the system admission process type.
  	v_s_adm_entry_qual_status := NVL(IGS_AD_GEN_007.ADMP_GET_SAEQS(
  						p_adm_entry_qual_status), 'NULL');
  	IF p_s_admission_process_type = 'NON-AWARD' THEN
  		-- The admission entry qualification status must be
  		-- Not Applicable for Non Award applications
  		IF v_s_adm_entry_qual_status <> 'NOT-APPLIC' THEN
  			p_message_name := 'IGS_AD_ADMENTRY_QUALIFY_ST';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- The admission entry qualification status must be
  		-- a value other than Not Applicable for applications
  		-- that are not Non Award
  		IF v_s_adm_entry_qual_status = 'NOT-APPLIC' THEN
  			p_message_name := 'IGS_AD_ADM_ENTRY_QUALIFYST' ;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  END admp_val_aeqs_item;
  --
  -- Validate if IGS_AD_ENT_QF_STAT.adm_entry_qual_status is closed.
  FUNCTION admp_val_aeqs_closed(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_aeqs_closed
  	-- Validate the adm_entry_qual_status closed indicator
  DECLARE
  	CURSOR c_aeqs(
  			cp_adm_entry_qual_status	IGS_AD_ENT_QF_STAT.adm_entry_qual_status%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AD_ENT_QF_STAT
  		WHERE	adm_entry_qual_status = cp_adm_entry_qual_status;
  	v_aeqs_rec			c_aeqs%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cursor handling
  	OPEN c_aeqs(
  			p_adm_entry_qual_status);
  	FETCH c_aeqs INTO v_aeqs_rec;
  	IF c_aeqs%NOTFOUND THEN
  		CLOSE c_aeqs;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_aeqs;
  	IF (v_aeqs_rec.closed_ind = cst_yes) THEN
  		p_message_name := 'IGS_AD_ADM_ENTRY_CLS_ST_CLOSE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END admp_val_aeqs_closed;
  --
  -- Validates adm_entry_qual_status against adm_outcome_status.
  FUNCTION admp_val_aeqs_aos(
  p_s_adm_entry_qual_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aeqs_aos
  	-- This module validates IGS_AD_PS_APPL_INST.adm_entry_qual_status
  	-- against IGS_AD_PS_APPL_INST.adm_outcome_status
  	-- Validations are:
  	--	If the admission entry qualification status is applicable for the
  	-- admission application, then it cannot be pending if an offer has been made.
  	--	If the admission entry qualification status is applicable for the admission
  	-- application, then it cannot be not-qualified if an offer is being made.
  DECLARE
  	cst_not_applic	CONSTANT
  					IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE:= 'NOT-APPLIC';
  	cst_pending	CONSTANT
  					IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE := 'PENDING';
  	cst_not_qual	CONSTANT
  					IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE := 'NOT-QUAL';
  	cst_offer		CONSTANT	IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'OFFER';
  	cst_cond_offer	CONSTANT
  					IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'COND-OFFER';
  	cst_withdrawn	CONSTANT
  					IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'WITHDRAWN';
  	cst_voided	CONSTANT	IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'VOIDED';
  BEGIN
    	p_message_name := NULL;
  	-- Only validate the admission entry qualification status if
  	-- it has a system value other then not-applicable
  	IF (p_s_adm_entry_qual_status <> cst_not_applic) THEN
  		-- The admission entry qualification status cannot
  		-- be pending if an offer has been made.
  		IF (p_s_adm_entry_qual_status = cst_pending AND
  				p_s_adm_outcome_status IN (
  							cst_offer,
  							cst_cond_offer,
  							cst_withdrawn,
  							cst_voided)) THEN
  			p_message_name := 'IGS_AD_NOTBE_PENDING_OFR_MADE';
  			RETURN FALSE;
  		END IF;
  		-- The admission entry qualification status cannot
  		-- be not-qualified if an offer is being made.
  		IF (p_s_adm_entry_qual_status = cst_not_qual AND
  				p_s_adm_outcome_status IN (
  							cst_offer,
  							cst_cond_offer)) THEN
  			p_message_name := 'IGS_AD_NOTBE_NOTQUALIF_OFRMAD';
  			RETURN FALSE;
  		END IF;
  	END IF;

  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
            p_message_name := 'IGS_GE_UNHANDLED_EXP';
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aeqs_aos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aeqs_aos;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_doc_status.
  FUNCTION admp_val_acai_ads(
  p_adm_doc_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_cond_offer_doc_allowed IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_ads
  	-- Validate the IGS_AD_PS_APPL_INST.adm_doc_status.
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_s_adm_doc_status		igs_ad_doc_stat.s_adm_doc_status%TYPE;
  	v_s_adm_outcome_status		igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_s_adm_cndtnl_offer_status	igs_ad_cndnl_ofrstat.s_adm_cndtnl_offer_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Perform item level validations.
  	IF	IGS_AD_VAL_ACAI_STATUS.admp_val_ads_item (
  				p_adm_doc_status,
  				p_s_admission_process_type,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Perform cross-status validations.
  	-- Get the system status values.
  	v_s_adm_doc_status := IGS_AD_GEN_007.ADMP_GET_SADS (p_adm_doc_status);
  	v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (p_adm_outcome_status);
  	v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS (p_adm_cndtnl_offer_status);
  	-- Validate against the admission outcome status.
  	IF	IGS_AD_VAL_ACAI_STATUS.admp_val_ads_aos (
  				v_s_adm_doc_status,
  				v_s_adm_outcome_status,
  				v_s_adm_cndtnl_offer_status,
  				p_cond_offer_doc_allowed,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	 IF p_message_name <> 'IGS_GE_UNHANDLED_EXP' AND FND_MSG_PUB.Count_Msg < 1 THEN
	     p_message_name := 'IGS_GE_UNHANDLED_EXP';
             Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	     Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_ads');
	     IGS_GE_MSG_STACK.ADD;
           END IF;
	    App_Exception.Raise_Exception;

  END admp_val_acai_ads;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_doc_status.
  FUNCTION admp_val_ads_item(
  p_adm_doc_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ads_item
  	-- Validate the IGS_AD_PS_APPL_INST.adm_doc_status,
  	-- It must be open and valid
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_s_adm_doc_status		igs_ad_doc_stat.s_adm_doc_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the closed indicator
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_ads_closed(
  				p_adm_doc_status,
  				v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate against the system admission process type.
  	v_s_adm_doc_status := NVL(IGS_AD_GEN_007.ADMP_GET_SADS(
  						p_adm_doc_status), 'NULL');
  	IF p_s_admission_process_type = 'NON-AWARD' THEN
  		-- The admission documentation status must be
  		-- Not Applicable for Non Award applications
  		IF v_s_adm_doc_status <> 'NOT-APPLIC' THEN
  			p_message_name := 'IGS_AD_ADMDOC_STATUS';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- The admission documentation status must be
  		-- a value other than Not Applicable for applications
  		-- that are not Non Award
  		IF v_s_adm_doc_status = 'NOT-APPLIC' THEN
  			p_message_name := 'IGS_AD_ADM_DOC_STATUS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
   END admp_val_ads_item;
  --
  -- Validate if IGS_AD_DOC_STAT.adm_doc_status is closed.
  FUNCTION admp_val_ads_closed(
  p_adm_doc_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_ads_closed
  	-- Validate the IGS_AD_DOC_STAT closed indicator
  DECLARE
  	CURSOR c_ads(
  			cp_adm_doc_status	IGS_AD_DOC_STAT.adm_doc_status%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AD_DOC_STAT
  		WHERE	adm_doc_status = cp_adm_doc_status;
  	v_ads_rec			c_ads%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cursor handling
  	OPEN c_ads(
  		p_adm_doc_status);
  	FETCH c_ads INTO v_ads_rec;
  	IF c_ads%NOTFOUND THEN
  		CLOSE c_ads;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ads;
  	IF (v_ads_rec.closed_ind = cst_yes) THEN
  		p_message_name := 'IGS_AD_ADMDOC_STATUS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
    END admp_val_ads_closed;
  --
  -- Validates adm_doc_status against adm_outcome_status.
  FUNCTION admp_val_ads_aos(
  p_s_adm_doc_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cond_offer_doc_allowed IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ads_aos
  	-- This module validates IGS_AD_PS_APPL_INST.adm_doc_status against
  	-- IGS_AD_PS_APPL_INST.adm_outcome_status.
  	-- Validations are:
  	--	If the admission documentation status is applicable for the admission
  	-- application, then it cannot be pending if an offer has been made.
  	--	The admission documentation status cannot be incomplete, unsatisfactory
  	-- or rejected if a non-conditional offer has been made or a conditional offer
  	-- has been made but documentation conditional offers are not allowed.
  	--	The admission documentation status cannot be incomple, unsatisfactory or
  	-- rejected if a conditional offer has been satisfied.
  DECLARE
  	cst_not_applic		CONSTANT
  						IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE := 'NOT-APPLIC';
  	cst_pending		CONSTANT
  						IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE := 'PENDING';
  	cst_incomplete		CONSTANT
  						IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE := 'INCOMPLETE';
  	cst_unsatisfac		CONSTANT
  						IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE := 'UNSATISFAC';
  	cst_rejected_f		CONSTANT
  						IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE := 'REJECTED-F';
  	cst_offer		CONSTANT	IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'OFFER';
  	cst_cond_offer		CONSTANT
  						IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'COND-OFFER';
  	cst_withdrawn		CONSTANT
  						IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'WITHDRAWN';
  	cst_voided		CONSTANT	IGS_AD_OU_STAT.s_adm_outcome_status%TYPE := 'VOIDED';
  	cst_satisfied		CONSTANT
  						IGS_AD_CNDNL_OFRSTAT.s_adm_cndtnl_offer_status%TYPE := 'SATISFIED';
  BEGIN
  	p_message_name := NULL;
	-- Only validate the admission documentation status if
  	-- it has a system value other then not-applicable.
  	IF (p_s_adm_doc_status <> cst_not_applic) THEN
  		-- The admission documentation status cannot
  		-- be pending if an offer has been made.
  		IF (p_s_adm_doc_status = cst_pending AND
  				p_s_adm_outcome_status IN (
  							cst_offer,
  							cst_cond_offer,
  							cst_withdrawn,
  							cst_voided)) THEN
  			p_message_name := 'IGS_AD_NOTBE_PENDNG_OFR_MADE';
  			RETURN FALSE;
  		END IF;
  		-- The admission documentation status cannot be incomplete, unsatisfactory
  		-- or rejected if a non-conditional offer has been made, or a conditional
  		-- offer has been made, but documentation conditional offers are not
  		-- allowed.
  		IF p_s_adm_doc_status IN (
  					cst_incomplete,
  					cst_unsatisfac,
  					cst_rejected_f) THEN
  			IF p_s_adm_outcome_status = cst_offer THEN
  				p_message_name := 'IGS_AD_NOTBE_INCOMPL_OFR_MADE';
  				RETURN FALSE;
  			END IF;
  			IF p_s_adm_outcome_status = cst_cond_offer AND
  					p_cond_offer_doc_allowed = 'N' THEN
  				p_message_name := 'IGS_AD_ADMDOC_NOTBE_IMCOMPL';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- The admission documentation status cannot be unsatisfactory
  		-- or rejected if a conditional offer has been satisfied.
  		IF (p_s_adm_doc_status IN (cst_incomplete, cst_unsatisfac, cst_rejected_f) AND
  				p_s_adm_outcome_status = cst_cond_offer AND
  				p_s_adm_cndtnl_offer_status = cst_satisfied) THEN
  			p_message_name := 'IGS_AD_NOTBE_INCOMP_OFR_MADE';
  			RETURN FALSE;
  		END IF;
  	END IF;

  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
            p_message_name := 'IGS_GE_UNHANDLED_EXP';
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_ads_aos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ads_aos;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status.
  FUNCTION admp_val_acai_aods(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_adm_dfrmnt_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_aods
  	-- Validate the IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status.
  DECLARE
  	v_s_adm_offer_dfrmnt_status
  					IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status%TYPE;
  	v_old_s_adm_dfrmnt_status
  					IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status%TYPE;
  	v_s_adm_offer_resp_status
  					IGS_AD_PS_APPL_INST.adm_offer_resp_status%TYPE;
  	v_message_name			VARCHAR2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Perform item level validations.
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_aods_item (
  				p_person_id,
  				p_admission_appl_number,
  				p_nominated_course_cd,
  				p_acai_sequence_number,
  				p_course_cd,
  				p_adm_offer_dfrmnt_status,
  				p_s_admission_process_type,
  				p_deferral_allowed,
  				v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Set local variables to system values
  	v_s_adm_offer_dfrmnt_status := IGS_AD_GEN_008.ADMP_GET_SAODS (
  						p_adm_offer_dfrmnt_status);
  	v_old_s_adm_dfrmnt_status := IGS_AD_GEN_008.ADMP_GET_SAODS (
  						p_old_adm_dfrmnt_status);
  	v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS (
  						p_adm_offer_resp_status);
  	-- Validate against the admission offer response status.
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_aods_aors (
  			v_s_adm_offer_dfrmnt_status,
  			v_old_s_adm_dfrmnt_status,
  			v_s_adm_offer_resp_status,
  			v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aods');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_acai_aods;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status.
  FUNCTION admp_val_aods_item(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aods_item
  	-- This module validates the IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status.
  	-- Perform item level validations only.
  	-- Validations are:
  	-- ? The adm_offer_dfrmnt_status must be open.  (AODS01)
  	-- ? If the deferment is not allowed for the admission application,
  	--   then the admission offer deferment status must have a value of
  	--   not-applicable.  (AODS02)
  	-- ? If the admission application is re-admission, course transfer
  	--   or non-Award, then the admission offer deferment status must have
  	--   a value of not-applicable.  (AODS03)
  	-- ? Deferment cannot be rejected if the course has been
  	--   confirmed.  (AODS04)
  DECLARE
  	CURSOR c_sca IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id 				= p_person_id AND
  			NVL(sca.adm_nominated_course_cd, 'NULL') =
  							NVL(p_nominated_course_cd, 'NULL') AND
  			NVL(sca.adm_admission_appl_number, -1)	= NVL(p_admission_appl_number, -1) AND
  			NVL(sca.adm_sequence_number, -1) 	= NVL(p_acai_sequence_number, -1) AND
  			sca.student_confirmed_ind		= 'Y';
  	v_sca_exists			VARCHAR2(1);
  	v_s_adm_offer_dfrmnt_status
  					IGS_AD_OFRDFRMT_STAT.s_adm_offer_dfrmnt_status%TYPE;
  	v_message_name			VARCHAR2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the closed indicator.
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_aods_closed (
  			p_adm_offer_dfrmnt_status,
  			v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	v_s_adm_offer_dfrmnt_status := IGS_AD_GEN_008.ADMP_GET_SAODS(
  						p_adm_offer_dfrmnt_status);
  	-- Validate the offer response status against the system admission
  	-- process type and the admission process category step.
  	IF v_s_adm_offer_dfrmnt_status <> 'NOT-APPLIC' THEN
  		-- Deferments are not allowed for this admission application.
  		-- The admission offer deferment status must be set to not-applicable.
  		IF p_deferral_allowed = 'N' THEN
  			-- deferment is not allowed
  			p_message_name := 'IGS_AD_DFRMNT_NOT_ALLOW';
  			RETURN FALSE;
  		END IF;
  		-- Validate the offer response status against the
  		-- system admission process type.
  		-- Deferment is not applicable for re-admission, course transfer
  		-- or non-Award admission applications.  The admission offer
  		-- deferment status must be set to not-applicable.
  		IF p_s_admission_process_type IN (
  						'RE-ADMIT',
  						'TRANSFER',
  						'NON-AWARD') THEN
  			p_message_name := 'IGS_AD_DFRMNT_NOT_APPLICABLE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate against student course attempt
  	IF v_s_adm_offer_dfrmnt_status = 'REJECTED' THEN
  		-- Cannot reject deferral if the course is confirmed
  		-- If the applicant accepted the initial offer,
  		-- then this status can be set to withdrawn.
  		OPEN c_sca;
  		FETCH c_sca INTO v_sca_exists;
  		IF c_sca%FOUND THEN
  			CLOSE c_sca;
  			p_message_name := 'IGS_AD_DFRMNT_NOT_REJECT';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_sca;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aods_item');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_aods_item;
  --
  -- Validate if IGS_AD_OFRDFRMT_STAT.adm_offer_dfrmnt_status is closed.
  FUNCTION admp_val_aods_closed(
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_aods_closed
  	-- Validate the adm_offer_dfrmnt_status closed indicator
  DECLARE
  	CURSOR c_aods(
  			cp_adm_offer_dfrmnt_status
  				IGS_AD_OFRDFRMT_STAT.adm_offer_dfrmnt_status%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AD_OFRDFRMT_STAT
  		WHERE	adm_offer_dfrmnt_status = cp_adm_offer_dfrmnt_status;
  	v_aods_rec			c_aods%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cursor handling
  	OPEN c_aods(
  			p_adm_offer_dfrmnt_status);
  	FETCH c_aods INTO v_aods_rec;
  	IF c_aods%NOTFOUND THEN
  		CLOSE c_aods;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_aods;
  	IF (v_aods_rec.closed_ind = cst_yes) THEN
  		p_message_name := 'IGS_AD_ADMOFR_DEFER_ST_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aods_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_aods_closed;
  --
  -- Validates adm_offer_dfrmnt_status against adm_offer_resp_status.
  FUNCTION admp_val_aods_aors(
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_s_adm_dfrmnt_status IN VARCHAR2 ,
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aods_aors
  	-- This module validates IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status
  	-- against IGS_AD_PS_APPL_INST.adm_offer_resp_status.
  	-- Validations are:
  	-- * The admission offer deferment status must have a system value
  	--   of not-applicable when the admission offer response status is
  	--   pending, lapsed or not-applicable.  (AODS05)
  	-- * The admission offer deferment status cannot be changed from
  	--   not-applicable when the admission offer response status does
  	--   not have a system value of deferral.  (AODS06)
  	-- * The admission offer deferment status must not have a system
  	--   value of not-applicable when the admission offer response
  	--   status is deferral.  (AODS07, AORS10)
  DECLARE
  	cst_pending			CONSTANT VARCHAR2(10) := 'PENDING';
  	cst_lapsed			CONSTANT VARCHAR2(10) := 'LAPSED';
  	cst_not_applic			CONSTANT VARCHAR2(10) := 'NOT-APPLIC';
  	cst_deferral			CONSTANT VARCHAR2(10) := 'DEFERRAL';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_s_adm_offer_dfrmnt_status <> cst_not_applic THEN
  		-- Cannot set to values other than not applicable if the
  		-- offer response status is pending, lapsed or not applicable
  		IF p_s_adm_offer_resp_status IN (
  						cst_pending,
  						cst_lapsed,
  						cst_not_applic) THEN
  			p_message_name := 'IGS_AD_OFFER_DFRMNT_STATUS';
  			RETURN FALSE;
  		END IF;
  		-- Cannot change from not applicable if the offer
  		-- response status is not deferral
  		IF p_old_s_adm_dfrmnt_status = cst_not_applic AND
  				p_s_adm_offer_resp_status <> cst_deferral THEN
  			p_message_name := 'IGS_AD_DFRMNT_STATUS_NOT_CHG';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Cannot be not applicable if offer response
  	-- status is deferral.
  	IF p_s_adm_offer_dfrmnt_status = cst_not_applic AND
  			p_s_adm_offer_resp_status = cst_deferral THEN
  		p_message_name := 'IGS_AD_DFRMNT_ST_NOT_APPL';
  		Return FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aods_aors');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_aods_aors;
  --
  -- Validate the IGS_AD_PS_APPL_INST.late_adm_fee_status.
  FUNCTION admp_val_acai_lafs(
  p_late_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2,
  p_late_fees_required IN VARCHAR2,
  p_cond_offer_fee_allowed IN VARCHAR2,
  p_appl_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_lafs
  	-- Validate the IGS_AD_PS_APPL_INST.late_adm_fee_status.
  DECLARE
  	v_s_late_adm_fee_status		igs_ad_fee_stat.s_adm_fee_status%TYPE;
  	v_s_adm_outcome_status          igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_s_adm_cndtnl_offer_status     igs_ad_cndnl_ofrstat.s_adm_cndtnl_offer_status%TYPE ;
  	v_message_name			VARCHAR2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Perform item level validations.
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_lafs_item (
  			p_late_adm_fee_status,
  			p_late_appl_allowed,
  			v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	v_s_late_adm_fee_status := IGS_AD_GEN_008.ADMP_GET_SAFS (
  					p_late_adm_fee_status);
  	-- Validate against the course offering option details.
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_lafs_coo (
  					v_s_late_adm_fee_status,
  					p_late_appl_allowed,
  					p_late_fees_required,
  					p_appl_dt,
  					p_course_cd,
  					p_crv_version_number,
  					p_acad_cal_type,
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					p_adm_cal_type,
  					p_adm_ci_sequence_number,
  					p_admission_cat,
  					p_s_admission_process_type,
  					v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (
  					p_adm_outcome_status);
  	v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS (
  					p_adm_cndtnl_offer_status);
  	-- Validate against the admission outcome status.
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_lafs_aos (
  			v_s_late_adm_fee_status,
  			v_s_adm_outcome_status,
  			v_s_adm_cndtnl_offer_status,
  			p_cond_offer_fee_allowed,
  			v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_lafs');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_acai_lafs;
  --
  -- Validate the IGS_AD_PS_APPL_INST.late_adm_fee_status.
  FUNCTION admp_val_lafs_item(
  p_late_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_lafs_item
  	-- Validate the IGS_AD_PS_APPL_INST.late_adm_fee_status.
  	-- Perform item level validations only.
  	-- Validations are:
  	-- * The late_adm_fee_status must be open.  (LAFS01)
  	-- * If late applications are not allowed the late_adm_fee_status
  	--   must have a system value of not-applicable.  (LAFS02)
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_s_late_adm_fee_status		igs_ad_fee_stat.s_adm_fee_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the closed indicator
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_afs_closed (
  				p_late_adm_fee_status,
  				v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Get the late admission fee status system value.
  	v_s_late_adm_fee_status := IGS_AD_GEN_008.ADMP_GET_SAFS(
  						p_late_adm_fee_status);
  	-- Validate when late applications are not allowed.
  	IF p_late_appl_allowed = 'N' AND
  			v_s_late_adm_fee_status <> 'NOT-APPLIC' THEN
  		-- If late applications are not allowed the late admission
  		-- fee status must have a value of not-applicable.
  		p_message_name := 'IGS_AD_LATE_ADMFEE_STATUS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_lafs_item');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_lafs_item;
  --
  -- Validate if IGS_AD_FEE_STAT.adm_fee_status is closed.
  FUNCTION admp_val_afs_closed(
  p_adm_fee_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_afs_closed
  	-- Validate if IGS_AD_FEE_STAT.adm_fee_status is closed
  DECLARE
  	CURSOR c_afs IS
  		SELECT	closed_ind
  		FROM	IGS_AD_FEE_STAT
  		WHERE	adm_fee_status = p_adm_fee_status;
  	v_closed_ind		IGS_AD_FEE_STAT.closed_ind%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cursor handling
  	OPEN c_afs;
  	FETCH c_afs INTO v_closed_ind;
  	IF c_afs%FOUND THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_afs;
  			p_message_name := 'IGS_AD_ADMFEE_STATUS_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	CLOSE c_afs;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_afs_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_afs_closed;
  --
  -- Validates late_adm_fee_status against the course offering option.
  FUNCTION admp_val_lafs_coo(
  p_s_late_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2,
  p_late_fees_required IN VARCHAR2,
  p_appl_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2
 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_lafs_coo
  	-- This module validates the IGS_AD_PS_APPL_INST.late_adm_fee_status
  	-- against the course offering option details of the admission course
  	-- application instance.
  	-- Validations are :
  	-- If late applications are allowed and the application is late and late
  	-- fees are required, then the late_adm_fee_status must not have a system
  	-- value of not-applicable.  (LAFS03)
  DECLARE
  	CURSOR c_coo IS
  		SELECT	coo.location_cd,
  			coo.attendance_mode,
  			coo.attendance_type
  		FROM	IGS_PS_OFR_OPT	coo
  		WHERE	coo.course_cd 		= p_course_cd AND
  			coo.version_number 	= p_crv_version_number AND
  			coo.cal_type 		= p_acad_cal_type AND
                        coo.delete_flag = 'N';
  	v_coo_match		BOOLEAN DEFAULT TRUE;
  	v_return_flag 		BOOLEAN DEFAULT FALSE;
  	v_message_name		VARCHAR2(30) DEFAULT NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate when late applications are allowed and the application is
  	-- late and late fees are required.
  	IF p_late_appl_allowed = 'Y' AND
  			p_late_fees_required = 'Y' THEN
  		v_coo_match := FALSE;
  		FOR v_coo_rec IN c_coo LOOP
  			-- Restrict the course offering options to match on input parameters
  			IF (p_location_cd IS NULL OR
  					v_coo_rec.location_cd = p_location_cd) AND
  					(p_attendance_mode IS NULL OR
  					v_coo_rec.attendance_mode = p_attendance_mode) AND
  					(p_attendance_type IS NULL OR
  					v_coo_rec.attendance_type = p_attendance_type) THEN
  				v_coo_match := TRUE;
  				-- Check if the app[lication is late.
  				IF IGS_AD_VAL_ACAI.admp_val_acai_late(
  						p_appl_dt,
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						v_coo_rec.location_cd,
  						v_coo_rec.attendance_mode,
  						v_coo_rec.attendance_type,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_admission_cat,
  						p_s_admission_process_type,
  						p_late_appl_allowed,
  						v_message_name) THEN
  					v_return_flag := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  		IF v_return_flag THEN
  			RETURN TRUE;
  		END IF;
  		-- Check if any course offering options were validated.
  		-- If they were, and this point is reached, then the
  		-- admission course application instance must be late.
  		IF v_coo_match THEN
  			IF p_s_late_adm_fee_status = 'NOT-APPLIC' THEN
  				-- The late admission fee status must have a value
  				-- other than not-applicable for a late application
  				-- that requires late fees.
  				p_message_name := 'IGS_AD_LATE_ADMFEE';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_coo%ISOPEN THEN
  			CLOSE c_coo;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_lafs_coo');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_lafs_coo;
  --
  -- Validates late_adm_fee_status against adm_outcome_status.
  FUNCTION admp_val_lafs_aos(
  p_s_late_adm_fee_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cond_offer_fee_allowed IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_lafs_aos
  	-- This module validates IGS_AD_PS_APPL_INST.adm_late_fee_status
  	-- against IGS_AD_PS_APPL_INST.adm_outcome_status.
  	-- Validations are:
  	-- * The late admission fee status cannot be pending
  	--   if an offer has been made.  (LAFS04)
  	-- * An offer cannot be made if late fees have been
  	--   assessed but not received in total.  (LAFS05)
  	-- * Fees cannot be outstanding for a satisfied conditional offer.
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := 0;
  	-- Validate when late fees are pending and an offer has been made.
  	-- Cannot be determining late fees if an offer has been made.
  	IF p_s_late_adm_fee_status = 'PENDING' AND
  			p_s_adm_outcome_status IN (
  						'OFFER',
  						'COND-OFFER',
  						'WITHDRAWN',
  						'VOIDED') THEN
  		p_message_name := 'IGS_AD_LATE_ADMFEE_NOTPENDING';
  		RETURN FALSE;
  	END IF;
  	-- Validate when late fees are assessed and an offer is being made.
  	IF p_s_late_adm_fee_status = 'ASSESSED' THEN
  		-- Cannot make an offer if late fees have been assessed but not
  		-- received in total.
  		IF p_s_adm_outcome_status = 'OFFER' THEN
  			p_message_name := 'IGS_AD_OFFER_CANNOT_MADE';
  			RETURN FALSE;
  		END IF;
  		IF p_s_adm_outcome_status = 'COND-OFFER' AND
  			p_cond_offer_fee_allowed = 'N' THEN
  			p_message_name := 'IGS_AD_LATEFEE_CANNOT_ASSESS';
  			RETURN FALSE;
  		END IF;
  		-- Cannot have outstanding fees for a conditional offer
  		-- that has been satisfied
  		IF p_s_adm_outcome_status = 'COND-OFFER' AND
  				p_s_adm_cndtnl_offer_status = 'SATISFIED' THEN
  			p_message_name := 'IGS_AD_FEE_CANNOT_BE_OUTSTAND';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_lafs_aos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_lafs_aos;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_resp_status.
  FUNCTION admp_val_acai_aors(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_old_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_actual_response_dt IN DATE ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2,
  p_multi_offer_allowed IN VARCHAR2,
  p_multi_offer_limit IN NUMBER ,
  p_pre_enrol_step IN VARCHAR2 ,
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2,
  p_cndtnl_offer_satisfied_dt IN DATE ,
  p_called_from IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_decline_ofr_reason IN VARCHAR2,		-- IGSM
  p_attent_other_inst_cd IN VARCHAR2		-- igsm
)
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_aors
  	-- Validate the IGS_AD_PS_APPL_INST.adm_offer_resp_status.
  DECLARE
  	cst_accepted		CONSTANT VARCHAR2(10) := 'ACCEPTED';
  	cst_form		CONSTANT VARCHAR2(5) := 'FORM';
  	cst_trg_br		CONSTANT VARCHAR2(7) := 'TRG_BR';
  	cst_trg_as		CONSTANT VARCHAR2(7) := 'TRG_AS';
	cst_notcoming		CONSTANT VARCHAR2(10) := 'NOT-COMING';
  	cst_rejected		CONSTANT VARCHAR2(10) := 'REJECTED';
	cst_otherinst		CONSTANT VARCHAR2(10) := 'OTHER-INST';
  	v_s_adm_offer_resp_status	igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  	v_old_s_adm_offer_resp_status	igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  	v_s_adm_outcome_status		igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_s_adm_offer_dfrmnt_status     igs_ad_ofrdfrmt_stat.s_adm_offer_dfrmnt_status%TYPE;
  	v_old_s_adm_dfrmnt_status       igs_ad_ofrdfrmt_stat.s_adm_offer_dfrmnt_status%TYPE;
  	v_message_name			VARCHAR2(30);

  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF (p_called_from IN (cst_form, cst_trg_br)) THEN
  		-- Perform item level validations.
  		IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_aors_item (
  					p_person_id,
  					p_admission_appl_number,
  					p_nominated_course_cd,
  					p_acai_sequence_number,
  					p_course_cd,
  					p_adm_offer_resp_status,
  					p_actual_response_dt,
  					p_s_admission_process_type,
  					p_deferral_allowed,
  					p_pre_enrol_step,
  					v_message_name,
					p_decline_ofr_reason,
					p_attent_other_inst_cd	) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;

  		v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS (
  							p_adm_offer_resp_status);
  		v_old_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS (
  							p_old_adm_offer_resp_status);
  		v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (
  							p_adm_outcome_status);

		IF v_s_adm_offer_resp_status IN (cst_notcoming, cst_rejected) AND p_decline_ofr_reason IS NULL THEN		--arvsrini igsm
			p_message_name := 'IGS_AD_ADMOFR_WITH_REAS';
			RETURN FALSE;
		END IF;

		IF p_decline_ofr_reason = cst_otherinst AND p_attent_other_inst_cd IS NULL THEN					--arvsrini igsm
			p_message_name := 'IGS_AD_NO_OTH_INST';
			RETURN FALSE;
		END IF;


		-- Validate against the admission outcome status.
  		IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_aors_aos (
  				v_s_adm_offer_resp_status,
  				v_old_s_adm_offer_resp_status,
  				v_s_adm_outcome_status,
  				p_adm_outcome_status_auth_dt,
  				v_message_name) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		v_s_adm_offer_dfrmnt_status := IGS_AD_GEN_008.ADMP_GET_SAODS (
  							p_adm_offer_dfrmnt_status);
  		v_old_s_adm_dfrmnt_status := IGS_AD_GEN_008.ADMP_GET_SAODS (
  							p_old_adm_offer_dfrmnt_status);
  		-- Validate against the admission offer deferment status.
  		IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_aods_aors (
  						v_s_adm_offer_dfrmnt_status,
  						v_old_s_adm_dfrmnt_status,
  						v_s_adm_offer_resp_status,
  						v_message_name) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate a conditional offer that must be satisfied before
  		-- it can be accepted.
  		IF v_s_adm_offer_resp_status =  cst_accepted AND
  				p_cndtnl_off_must_be_stsfd_ind = 'Y' AND
  				p_cndtnl_offer_satisfied_dt IS NULL THEN
  			p_message_name := 'IGS_AD_CONDOFR_ACCEPTED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Perform the following validations when the module has been called from the
  	-- Form or from the after statement database trigger.
  	IF (p_called_from IN (cst_form, cst_trg_as)) THEN
  		-- Determine the system admission outcome status and system admission
  		-- offer response status.  Will have already been determined if
  		-- called from FORM.
  		IF p_called_from = cst_trg_as THEN
  			v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (p_adm_outcome_status);
  			v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS (p_adm_offer_resp_status);
  		END IF;
  		-- Validate multiple offers.
  		IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_offer_mult (
  							p_person_id,
  							p_admission_appl_number,
  							p_nominated_course_cd,
  							p_acai_sequence_number,
  							p_course_cd,
  							v_s_adm_outcome_status,
  							v_s_adm_offer_resp_status,
  							p_adm_cal_type,
  							p_adm_ci_sequence_number,
  							p_admission_cat,
  							p_s_admission_process_type,
  							p_multi_offer_allowed,
  							p_multi_offer_limit,
  							p_message_name) THEN
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aors');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
       END admp_val_acai_aors;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_resp_status.
  FUNCTION admp_val_aors_item(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_actual_response_dt IN DATE ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2 ,
  p_pre_enrol_step IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2,
  p_decline_ofr_reason IN VARCHAR2,
  p_attent_other_inst_cd IN VARCHAR2

 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aors_item
  	-- This module validates the IGS_AD_PS_APPL_INST.adm_offer_resp_status.
  	-- Perform item level validations only.
  	-- Validations are:
  	-- * The adm_offer_resp_status must be open.  (AORS01)
  	-- * The admission offer response status cannot be set to pending for
  	--	a re-admission application.  (AORS02)
  	-- * The admission offer response status cannot be set to pending when
  	--	the applicant has already responded.  (AORS06)
  	-- * The admission offer response status cannot be set to rejected when
  	--	the applicant has confirmed their course attempt.  (AORS08)
  	-- * If the deferment is not allowed for the admission application, then
  	--	the admission offer response status cannot be set to deferral.  (AORS05)
  	-- * If the admission application is re-admission, course transfer or
  	--	non-Award, then the admission offer response status cannot be set
  	--	to deferral.  (AORS04)
  	-- * The admission offer response status cannot be set to deferral when
  	--	the applicant has confirmed their course attempt.  (AORS09)
  	-- * The admission offer response status cannot be set to lapsed for a
  	--	re-admission application. (AORS03)
  	-- * The admission offer response status cannot be set to lapsed when the
  	--	applicant has already responded.  (AORS07)
  	-- * The admission offer response status cannot be set to accepted if the
  	--	admission course application is a transfer and IGS_PS_STDNT_TRN
  	--	details do not exist.  (AORS17)
  	--	(these are created via ENRF4150 ? course Transfer)
  DECLARE
  	CURSOR c_sca_conf IS
  		SELECT	sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id 			= p_person_id AND
  			sca.course_cd			= p_course_cd AND
  			sca.adm_admission_appl_number	IS NOT NULL AND
  			sca.adm_admission_appl_number	= p_admission_appl_number AND
  			sca.adm_nominated_course_cd	IS NOT NULL AND
  			sca.adm_nominated_course_cd	= p_nominated_course_cd AND
  			sca.adm_sequence_number		IS NOT NULL AND
  			sca.adm_sequence_number		= p_acai_sequence_number AND
  			sca.student_confirmed_ind	= 'Y';
  	v_sca_conf_rec			c_sca_conf%ROWTYPE;
  	v_message_name			VARCHAR2(30);
  	v_s_adm_offer_resp_status	igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  	cst_pending		CONSTANT VARCHAR2(10) := 'PENDING';
  	cst_readmit		CONSTANT VARCHAR2(10) := 'RE-ADMIT';
  	cst_rejected		CONSTANT VARCHAR2(10) := 'REJECTED';
  	cst_discontin		CONSTANT VARCHAR2(10) := 'DISCONTIN';
  	cst_lapsed		CONSTANT VARCHAR2(10) := 'LAPSED';
  	cst_transfer		CONSTANT VARCHAR2(10) := 'TRANSFER';
  	cst_nonaward		CONSTANT VARCHAR2(10) := 'NON-AWARD';
  	cst_deferral		CONSTANT VARCHAR2(10) := 'DEFERRAL';
  	cst_accepted		CONSTANT VARCHAR2(10) := 'ACCEPTED';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the closed indicator.
  	IF IGS_AD_VAL_ACAI_STATUS.admp_val_aors_closed (
  					p_adm_offer_resp_status,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate each value of offer response status.
  	v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(
  					p_adm_offer_resp_status);
  	IF v_s_adm_offer_resp_status = cst_pending THEN
  		-- Re-admission only has accepted or rejected response status.
  		IF p_s_admission_process_type = cst_readmit THEN
  			p_message_name := 'IGS_AD_ADMOFR_READM_APPL';
  			RETURN FALSE;
  		END IF;
  		-- Cannot set to pending if a response has been given
  		-- (this is recognised by the actual response date being set).
  		IF p_actual_response_dt IS NOT NULL THEN
  			p_message_name := 'IGS_AD_ADMOFR_RESPONDED';
  			RETURN FALSE;
  		END IF;
  	END IF;

	/*
	IF v_s_adm_offer_resp_status = cst_rejected THEN
  		-- Can only reject if applicant has not already enrolled
  		OPEN c_sca_conf;
  		FETCH c_sca_conf INTO v_sca_conf_rec;
  		IF c_sca_conf%FOUND THEN
  			CLOSE c_sca_conf;
  			IF p_s_admission_process_type = cst_readmit THEN
  				IF v_sca_conf_rec.course_attempt_status NOT IN (
  									cst_discontin,
  									cst_lapsed) THEN
  					p_message_name := 'IGS_AD_ADMOFR_NOT_SET_REJECT' ;
  					RETURN  FALSE;
  				END IF;
  			ELSE
  				p_message_name := 'IGS_AD_ADMOFR_NOT_SET_REJECT';
  				RETURN  FALSE;
  			END IF;
  		ELSE -- %NOTFOUND
  			CLOSE c_sca_conf;
  		END IF;
  	END IF;
	*/
  	IF v_s_adm_offer_resp_status = cst_deferral THEN
  		IF p_deferral_allowed = 'N' THEN
  			-- deferment not allowed
  			p_message_name := 'IGS_AD_DFRMNT_NOT_ALLOW_ADM';
  			RETURN FALSE;
  		END IF;
  		-- Can only defer if process types are course or SHORT-ADM
  		IF p_s_admission_process_type IN (
  						cst_readmit,
  						cst_transfer,
  						cst_nonaward) THEN
  			p_message_name := 'IGS_AD_DFRMNT_NOT_APPLI_READM';
  			RETURN FALSE;
  		END IF;

		/*
		-- Can only defer if the applicant has not already enrolled
  		-- (NOTE, can use same cursor as With rejected)
  		OPEN c_sca_conf;
  		FETCH c_sca_conf INTO v_sca_conf_rec;
  		IF c_sca_conf%FOUND THEN
  			CLOSE c_sca_conf;
  			p_message_name := 'IGS_AD_OFRST_NOTSET_DEFERRAL';
  			RETURN  FALSE;
  		END IF;
  		CLOSE c_sca_conf;
		*/
  	END IF;
  	IF v_s_adm_offer_resp_status = cst_lapsed THEN
  		-- Re-admission only has accepted or rejected response status
  		IF p_s_admission_process_type = cst_readmit THEN
  			p_message_name := 'IGS_AD_OFRST_NOTSET_LAPSED';
  			RETURN  FALSE;
  		END IF;
  		-- Can only set to lapsed if pending or lapsed (lapsing
  		-- is done by a background process)
  		-- This is recognised by the setting of the actual response date
  		IF p_actual_response_dt IS NOT NULL THEN
  			p_message_name := 'IGS_AD_OFRST_NOTSET_RESPONDED';
  			RETURN  FALSE;
  		END IF;
  	END IF;
  	IF v_s_adm_offer_resp_status = cst_accepted THEN
  		-- Can only accept admission application for transfer if
  		-- IGS_PS_STDNT_TRN details exist
  		IF p_s_admission_process_type = cst_transfer THEN
  			IF IGS_EN_VAL_SCA.enrp_val_trnsfr_acpt(
  					p_person_id,
  					p_course_cd,
  					NULL,	-- student confirmed ind
  					p_admission_appl_number,
  					p_nominated_course_cd,
  					p_adm_offer_resp_status,
  					v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;



  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca_conf%ISOPEN THEN
  			CLOSE c_sca_conf;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aors_item');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_aors_item;
  --
  -- Validate if IGS_AD_OFR_RESP_STAT.adm_offer_resp_status is closed.
  FUNCTION admp_val_aors_closed(
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_closed_ind		IGS_AD_OFR_RESP_STAT.closed_ind%TYPE;
  	CURSOR c_aors IS
  		SELECT	aors.closed_ind
  		FROM	IGS_AD_OFR_RESP_STAT	aors
  		WHERE	aors.adm_offer_resp_status = p_adm_offer_resp_status;
  BEGIN
  	-- Validate if IGS_AD_OFR_RESP_STAT.adm_offer_resp_status is closed.
  	OPEN c_aors;
  	FETCH c_aors INTO v_closed_ind;
  	IF (c_aors%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_aors;
  			p_message_name := 'IGS_AD_ADMOFR_RESP_ST_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_aors;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aors_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END;
  END admp_val_aors_closed;
  --
  -- Validates adm_offer_resp_status against adm_outcome_status.
  FUNCTION admp_val_aors_aos(
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_old_s_adm_offer_resp_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aors_aos
  	-- This module validates the IGS_AD_PS_APPL_INST.adm_offer_resp_status
  	-- against IGS_AD_PS_APPL_INST.adm_outcome_status.
  	-- Validations are:
  	-- ? The admission offer response status cannot be pending if an offer
  	--   has not been made.  (AORS11)
  	-- ? The admission offer response status cannot be accepted, rejected
  	--   or deferral unless an offer has been made.  (AORS12)
  	-- ? The admission offer response status cannot be changed to accepted,
  	--   rejected or deferral from lapsed unless overriding of status
  	--   validation is permitted.  (AORS13)
  	-- ? The admission offer response cannot be lapsed unless an offer has
  	--   been made.  (AORS14)
  	-- ? The admission offer response cannot be not-applicable when an offer
  	--   has been made.  (AORS15)
  DECLARE
  	cst_pending			CONSTANT VARCHAR2(10) := 'PENDING';
  	cst_rejected			CONSTANT VARCHAR2(10) := 'REJECTED';
  	cst_no_quota			CONSTANT VARCHAR2(10) := 'NO-QUOTA';
  	cst_accepted			CONSTANT VARCHAR2(10) := 'ACCEPTED';
  	cst_offer				CONSTANT VARCHAR2(10) := 'OFFER';
  	cst_cond_offer			CONSTANT VARCHAR2(10) := 'COND-OFFER';
  	cst_withdrawn			CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  	cst_voided			CONSTANT VARCHAR2(10) := 'VOIDED';
  	cst_deferral			CONSTANT VARCHAR2(10) := 'DEFERRAL';
  	cst_lapsed			CONSTANT VARCHAR2(10) := 'LAPSED';
  	cst_not_applic			CONSTANT VARCHAR2(10) := 'NOT-APPLIC';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cannot be pending without having made an offer
  	IF p_s_adm_offer_resp_status = cst_pending AND
  			p_s_adm_outcome_status IN (
  						cst_pending,
  						cst_rejected,
  						cst_no_quota) THEN
  		p_message_name := 'IGS_AD_OFRST_NOTPENDING';
  		RETURN FALSE;
  	END IF;
  	IF p_s_adm_offer_resp_status IN (
  					cst_accepted,
  					cst_rejected,
  					cst_deferral) THEN
  		-- Cannot have an offer response if not being made an offer
  		IF p_s_adm_outcome_status NOT IN (
  						cst_offer,
  						cst_cond_offer,
  						cst_withdrawn,
  						cst_voided) THEN
  			p_message_name := 'IGS_AD_OFRST_NOTACCEPTED';
  			RETURN FALSE;
  		END IF;

  	END IF;
  	-- Cannot lapse if offer has not been made
  	IF p_s_adm_offer_resp_status = cst_lapsed AND
  			p_s_adm_outcome_status NOT IN (
  						cst_offer,
  						cst_cond_offer,
  						cst_withdrawn,
  						cst_voided) THEN
  		p_message_name := 'IGS_AD_OFR_RESP_NOTLAPSED';
  		RETURN FALSE;
  	END IF;
  	-- Cannot be not applicable if offer is being made
  	IF p_s_adm_offer_resp_status = cst_not_applic AND
  			p_s_adm_outcome_status IN (
  						cst_offer,
  						cst_cond_offer) THEN
  		p_message_name := 'IGS_AD_OFR_RESP_NOTAPPLICABLE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aors_aos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_aors_aos;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_acai_aos(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_fee_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_adm_doc_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_late_adm_fee_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_old_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_set_outcome_allowed IN VARCHAR2 ,
  p_cond_offer_assess_allowed IN VARCHAR2,
  p_cond_offer_fee_allowed IN VARCHAR2 ,
  p_cond_offer_doc_allowed IN VARCHAR2,
  p_late_appl_allowed IN VARCHAR2 ,
  p_fees_required IN VARCHAR2 ,
  p_multi_offer_allowed IN VARCHAR2 ,
  p_multi_offer_limit IN NUMBER ,
  p_pref_allowed IN VARCHAR2,
  p_unit_set_appl IN VARCHAR2,
  p_check_person_encumb IN VARCHAR2,
  p_check_course_encumb IN VARCHAR2,
  p_called_from IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_aos
  	-- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status
  DECLARE
  	cst_form	CONSTANT	VARCHAR2(6) := 'FORM';
  	cst_trg_br	CONSTANT	VARCHAR2(6) := 'TRG_BR';
  	cst_trg_as	CONSTANT	VARCHAR2(6) := 'TRG_AS';
  	v_message_name			VARCHAR2(30);
  	v_s_adm_outcome_status		igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_old_s_adm_outcome_status	igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_s_adm_doc_status		igs_ad_doc_stat.s_adm_doc_status%TYPE;
  	v_s_adm_fee_status		igs_ad_fee_stat.s_adm_fee_status%TYPE;
  	v_late_s_adm_fee_status		igs_ad_fee_stat.s_adm_fee_status%TYPE;
  	v_s_adm_entry_qual_status	igs_ad_ent_qf_stat.s_adm_entry_qual_status%TYPE;
  	v_s_adm_cndtnl_offer_status     igs_ad_cndnl_ofrstat.s_adm_cndtnl_offer_status%TYPE;
  	v_s_adm_offer_resp_status	igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  	v_old_s_adm_offer_resp_status   igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  BEGIN
  	-- Perform the following validations when the module has been called
  	-- from the form or from the before row database trigger
  	IF (p_called_from IN (
  				cst_form,
  				cst_trg_br)) THEN
  		-- Perform item level validations
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_aos_item(
  						p_adm_outcome_status,
  						p_old_adm_outcome_status,
  						p_adm_fee_status,
  						p_set_outcome_allowed,
  						p_cond_offer_assess_allowed,
  						p_cond_offer_fee_allowed,
  						p_cond_offer_doc_allowed,
  						p_person_id,
  						p_admission_appl_number,
  						p_nominated_course_cd,
  						p_acai_sequence_number,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(p_adm_outcome_status);
  		v_old_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(p_old_adm_outcome_status);
  		v_s_adm_doc_status := IGS_AD_GEN_007.ADMP_GET_SADS(p_adm_doc_status);
  		v_s_adm_fee_status := IGS_AD_GEN_008.ADMP_GET_SAFS(p_adm_fee_status);
  		v_late_s_adm_fee_status := IGS_AD_GEN_008.ADMP_GET_SAFS(p_late_adm_fee_status);
  		-- Validate against the other admission course
  		-- application instance status values
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_aos_status(
  						v_s_adm_outcome_status,
  						v_old_s_adm_outcome_status,
  						v_s_adm_doc_status,
  						v_s_adm_fee_status,
  						v_late_s_adm_fee_status,
  						p_cond_offer_assess_allowed,
  						p_cond_offer_fee_allowed,
  						p_cond_offer_doc_allowed,
  						p_late_appl_allowed,
  						p_fees_required,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		v_s_adm_entry_qual_status := IGS_AD_GEN_007.ADMP_GET_SAEQS(p_adm_entry_qual_status);
  		-- Validate the admission outcome status against
  		-- the admission entry qualification status
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_aeqs_aos(
  						v_s_adm_entry_qual_status,
  						v_s_adm_outcome_status,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS(p_adm_cndtnl_offer_status);
  		-- Validate the admission outcome status
  		-- against the admission documentation status
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_ads_aos(
  						v_s_adm_doc_status,
  						v_s_adm_outcome_status,
  						v_s_adm_cndtnl_offer_status,
  						p_cond_offer_doc_allowed,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate the admission outcome status
  		-- against the late admission fee status
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_lafs_aos(
  						v_late_s_adm_fee_status,
  						v_s_adm_outcome_status,
  						v_s_adm_cndtnl_offer_status,
  						p_cond_offer_fee_allowed,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(p_adm_offer_resp_status);
  		v_old_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(p_old_adm_offer_resp_status);
  		-- Validate the admission outcome status against
  		-- the admission offer response status
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_aors_aos(
  						v_s_adm_offer_resp_status,
  						v_old_s_adm_offer_resp_status,
  						v_s_adm_outcome_status,
  						p_adm_outcome_status_auth_dt,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF (p_called_from IN (
  				cst_form,
  				cst_trg_as)) THEN
  		-- Determine the system admission outcome status and system admission offer
  		-- response status.
  		--  If called from Form then this will have already  been determined.
  		IF p_called_from = cst_trg_as THEN
  			v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(p_adm_outcome_status);
  			v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(p_adm_offer_resp_status);
  		END IF;
  		-- Validate the admission course application instance outcome
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_acai_otcome(
  						p_person_id,
  						p_admission_appl_number,
  						p_nominated_course_cd,
  						p_acai_sequence_number,
  						p_course_cd,
  						p_crv_version_number,
  						p_location_cd,
  						p_attendance_mode,
  						p_attendance_type,
  						p_unit_set_cd,
  						p_us_version_number,
  						p_acad_cal_type,
  						p_acad_ci_sequence_number,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_admission_cat,
  						p_s_admission_process_type,
  						p_appl_dt,
  						p_fee_cat,
  						p_correspondence_cat,
  						p_enrolment_cat,
  						v_s_adm_outcome_status,
  						p_adm_outcome_status_auth_dt,
  						p_check_person_encumb,
  						p_check_course_encumb,
  						p_pref_allowed,
  						p_late_appl_allowed,
  						p_unit_set_appl,
  						p_called_from,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate multiple offers
  		IF (IGS_AD_VAL_ACAI_STATUS.admp_val_offer_mult(
  						p_person_id,
  						p_admission_appl_number,
  						p_nominated_course_cd,
  						p_acai_sequence_number,
  						p_course_cd,
  						v_s_adm_outcome_status,
  						v_s_adm_offer_resp_status,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_admission_cat,
  						p_s_admission_process_type,
  						p_multi_offer_allowed,
  						p_multi_offer_limit,
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_acai_aos;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_aos_item(
  p_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_set_outcome_allowed IN VARCHAR2 ,
  p_cond_offer_assess_allowed IN VARCHAR2,
  p_cond_offer_fee_allowed IN VARCHAR2,
  p_cond_offer_doc_allowed IN VARCHAR2,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_aos_item
  	-- This module validates the IGS_AD_PS_APPL_INST.adm_outcome_status.
  	-- The adm_outcome_status must be open.  (AOS01)
  	-- The admission outcome status may not be set to a value other than pending
  	-- when setting of the admission outcome status is not allowed for the
  	-- admission application.  (AOS02)
  	-- A conditional offer cannot be made when conditional offers are not allowed
  	-- for the admission application.  (AOS22)
  	-- The admission outcome status can only be changed to withdrawn or voided
  	-- after an offer has been made.  (AOS17)
  	-- A conditional offer cannot be made when application fees are outstanding
  	-- and fee conditional offers are not allowed.  (AOS25)

  	-- Enh# : 2217104, DLD Admit to Future Term.
	-- Navin Sinha 13-Feb-2002, Added condition for 'OFFER-FUTURE-TERM'.
  	-- 1. s_adm_outcome_status can be set to 'OFFER-FUTURE-TERM' only if s_admission_process_type IN ('COURSE', 'NON-AWARD', 'SHORT-ADM')
  DECLARE
  	cst_pending			CONSTANT 	VARCHAR2(7)  := 'PENDING';
  	cst_cond_offer			CONSTANT 	VARCHAR2(10) := 'COND-OFFER';
  	cst_withdrawn			CONSTANT 	VARCHAR2(9)  := 'WITHDRAWN';
  	cst_voided			CONSTANT 	VARCHAR2(6)  := 'VOIDED';
  	cst_rejected			CONSTANT 	VARCHAR2(8)  := 'REJECTED';
  	cst_no_quota			CONSTANT 	VARCHAR2(8)  := 'NO-QUOTA';
  	cst_received			CONSTANT 	VARCHAR2(8)  := 'RECEIVED';
  	cst_exempt			CONSTANT 	VARCHAR2(8)  := 'EXEMPT';
  	cst_not_applic			CONSTANT 	VARCHAR2(10) := 'NOT-APPLIC';
  	cst_deleted			CONSTANT 	VARCHAR2(7) := 'DELETED';
  	cst_unconfirmed			CONSTANT 	VARCHAR2(11) := 'UNCONFIRM';
  	cst_offer_future_term		CONSTANT 	VARCHAR2(20) := 'OFFER-FUTURE-TERM';
  	v_s_adm_outcome_status		igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_old_s_adm_outcome_status	igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_s_adm_fee_status		igs_ad_fee_stat.s_adm_fee_status%TYPE;
  	v_message_name			VARCHAR2(30);
  	v_dummy				VARCHAR2(1);
  	CURSOR c_sca IS
  		SELECT 'x'
  		FROM	IGS_EN_STDNT_PS_ATT sca
  		WHERE	sca.person_id 			= p_person_id AND
  			sca.adm_admission_appl_number 	IS NOT NULL AND
  			sca.adm_admission_appl_number 	= p_admission_appl_number AND
  			sca.adm_nominated_course_cd 	IS NOT NULL AND
  			sca.adm_nominated_course_cd 	= p_nominated_course_cd AND
  			sca.adm_sequence_number 	IS NOT NULL AND
  			sca.adm_sequence_number 	= p_acai_sequence_number AND
  			sca.course_attempt_status NOT IN (cst_deleted, cst_unconfirmed);

  	CURSOR c_sap(cp_person_id NUMBER, cp_admission_appl_number NUMBER) IS
        SELECT s_admission_process_type
        FROM   igs_ad_appl
        WHERE  person_id = cp_person_id
        AND    admission_appl_number = cp_admission_appl_number;
        c_sap_rec c_sap%ROWTYPE;
  BEGIN
  	p_message_name := NULL;
  	-- Validate the closed indicator
  	IF(IGS_AD_VAL_ACAI_STATUS.admp_val_aos_closed (
  					p_adm_outcome_status,
  					v_message_name) = FALSE) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (
  					p_adm_outcome_status);
  	-- Validate the admission outcome status against the admission process
  	-- category steps.
  	-- Validate if outcome can be set.
  	IF(p_set_outcome_allowed = 'N' AND
  			v_s_adm_outcome_status <> cst_pending AND
  			p_adm_outcome_status <> p_old_adm_outcome_status) THEN
  		-- The admission outcome status must be pending when
  		-- the outcome cannot be set.
  		p_message_name := 'IGS_AD_OFRST_VALUE_PENDING';
  		RETURN FALSE;
  	END IF;
  	-- Validate if a conditional offer can be made.
  	IF(p_cond_offer_assess_allowed = 'N' AND
  			p_cond_offer_fee_allowed = 'N' AND
  			p_cond_offer_doc_allowed = 'N' AND
  			v_s_adm_outcome_status = cst_cond_offer) THEN
  		-- The admission outcome status status must be conditional offers
  		-- when conditional offers are not allowed.
  		p_message_name := 'IGS_AD_CONDOFR_NOT_MADE';
  		RETURN FALSE;
  	END IF;
  	v_old_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(
  						p_old_adm_outcome_status);
  	-- Validate change of the admission outcome status value.
  	IF(v_s_adm_outcome_status IN (cst_withdrawn, cst_voided) AND
  			v_old_s_adm_outcome_status IN (cst_pending, cst_rejected, cst_no_quota) AND
			NVL(igs_ad_cancel_reconsider.g_cancel_recons_on,'N') <> 'Y' )THEN
  		-- Cannot withdraw or void and unless an offer is made first. In case the update is made from the cancel
		-- reconsideration job, this restriction should not be there.
  		p_message_name := 'IGS_AD_OUTCOME_STATUS_CHG';
  		RETURN FALSE;
  	END IF;
  	IF v_s_adm_outcome_status IN (cst_pending, cst_rejected, cst_no_quota) THEN
  		OPEN c_sca;
  		FETCH c_sca INTO v_dummy;
  		IF (c_sca%FOUND) THEN
  			-- Cannot set outcome pending, rejected or no-quota when the
  			-- applicant has an existing course attempt.
  			CLOSE c_sca;
  			p_message_name := 'IGS_AD_OUTCOME_CANNOT_SETTO';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_sca;
  	END IF;

        -- Enh# : 2217104, DLD Admit to Future Term.
	IF v_s_adm_outcome_status = cst_offer_future_term THEN
  		OPEN c_sap(p_person_id, p_admission_appl_number);
  		FETCH c_sap INTO c_sap_rec;
  		IF (c_sap%FOUND) AND c_sap_rec.s_admission_process_type NOT IN ('COURSE', 'NON-AWARD', 'SHORT-ADM') THEN
  		    CLOSE c_sap;
  		    p_message_name := 'IGS_AD_OUTCOME_FUTURE_TERM';
  		    RETURN FALSE;
  		END IF;
  		CLOSE c_sap;
  	END IF;

	v_s_adm_fee_status := IGS_AD_GEN_008.ADMP_GET_SAFS (
  					p_adm_fee_status);
  	-- Validate a non-fee conditional offer.
  	IF(v_s_adm_outcome_status = cst_cond_offer AND
  			p_cond_offer_fee_allowed = 'N' AND
  			v_s_adm_fee_status NOT IN (cst_received, cst_exempt, cst_not_applic)) THEN
  		p_message_name := 'IGS_AD_APPLFEES_OUTSTANDING';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_sap%ISOPEN THEN
  			CLOSE c_sap;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aos_item'|| SQLERRM);
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_aos_item;
  --
  -- Validate if IGS_AD_OU_STAT.adm_outcome_status is closed.
  FUNCTION admp_val_aos_closed(
  p_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_closed_ind		IGS_AD_OU_STAT.closed_ind%TYPE;
  	CURSOR c_aos IS
  		SELECT	aos.closed_ind
  		FROM	IGS_AD_OU_STAT	aos
  		WHERE	aos.adm_outcome_status = p_adm_outcome_status;
  BEGIN
  	-- Validate if IGS_AD_OU_STAT.adm_outcome_status is closed.
  	OPEN c_aos;
  	FETCH c_aos INTO v_closed_ind;
  	IF (c_aos%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_aos;
  			p_message_name := 'IGS_AD_ADM_OUCOME_ST_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_aos;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aos_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END;
  END admp_val_aos_closed;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_aos_status(
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_old_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_doc_status IN VARCHAR2 ,
  p_s_adm_fee_status IN VARCHAR2 ,
  p_late_s_adm_fee_status IN VARCHAR2 ,
  p_cond_offer_assess_allowed IN VARCHAR2,
  p_cond_offer_fee_allowed IN VARCHAR2,
  p_cond_offer_doc_allowed IN VARCHAR2,
  p_late_appl_allowed IN VARCHAR2,
  p_fees_required IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_aos_status
  	-- This module validates the IGS_AD_PS_APPL_INST.adm_outcome_status
  	-- against
  	-- other statuses in IGS_AD_PS_APPL_INST.
  	-- Validations are:
  	-- If a documentation conditional offer is being made, then the admission
  	-- documentation status must be incomplete.  (AOS24).
  	-- If a fee conditional offer is being made, then the admission application
  	-- fee status must be assessed or the late admission fee status must be
  	-- assessed. (AOS27).
  	-- An offer cannot be made while there are outstanding admission application
  	-- fees.  (AFS04, AFS05, AOS20)
  DECLARE
  	cst_cond_offer			CONSTANT 	VARCHAR2(10)  := 'COND-OFFER';
  	cst_incomplete			CONSTANT 	VARCHAR2(10)  := 'INCOMPLETE';
  	cst_assessed			CONSTANT 	VARCHAR2(8)   := 'ASSESSED';
  	cst_offer			CONSTANT 	VARCHAR2(5)   := 'OFFER';
  	cst_pending			CONSTANT 	VARCHAR2(7)   := 'PENDING';
  BEGIN
  	p_message_name := NULL;
  	-- Validate when outcome status is changed to conditional offer.
  	IF(p_s_adm_outcome_status = cst_cond_offer AND
  			p_old_s_adm_outcome_status <> cst_cond_offer) THEN
  		IF(p_cond_offer_assess_allowed = 'N') THEN -- assessor conditions allowed
  			IF(p_cond_offer_doc_allowed = 'Y') THEN-- documentation conditions allowed
  				--Check for a documentation condition
  				IF(p_s_adm_doc_status = cst_incomplete) THEN
  					p_message_name := NULL;
  					RETURN TRUE;
  				END IF;
  			END IF;
  			IF(p_cond_offer_fee_allowed = 'Y') THEN -- fee conditions allowed
  				IF(p_s_adm_fee_status = cst_assessed) THEN
  					p_message_name := NULL;
  					RETURN TRUE;
  				END IF;
  				-- Check for late fee condition
  				IF(p_late_appl_allowed = 'Y') THEN
  					IF(p_late_s_adm_fee_status = cst_assessed) THEN
  						p_message_name := NULL;
  						RETURN TRUE;
  					END IF;
  				END IF;
  			END IF;
  			-- If reached here, then it is invalid to make a conditional offer
  			p_message_name := 'IGS_AD_INVALID_COND_OFFER';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate the application fees when outcome status is set to offer.
  	IF(p_s_adm_outcome_status = cst_offer) THEN
  		IF(p_fees_required = 'Y') THEN
  			-- Cannot make an offer if admission fees are outstanding
  			IF(p_s_adm_fee_status IN (cst_pending, cst_assessed)) THEN
  				p_message_name := 'IGS_AD_ADMAPL_FEES_OUTSTANDIN';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aos_status');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_aos_status;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_acai_otcome(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_fee_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_check_person_encumb IN VARCHAR2,
  p_check_course_encumb IN VARCHAR2,
  p_pref_allowed IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2,
  p_unit_set_appl IN VARCHAR2,
  p_called_from IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_otcome
  	-- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  	-- Validations are -
  	-- * The outcome cannot be set to pending for a non-preference application for
  	--	which an outcome letter has been created.  (This is with the exception of
  	--	reconsideration and deferment processing).  (AOS03)
  	-- * The outcome cannot be set to pending for a preference application for
  	--	which an outcome letter has been created and there are no other admission
  	--	course application instances with an outcome of other than pending.
  	--	(This is with the exception of reconsideration and deferment processing).
  	--	(AOS04)
  	-- * An admission course application instance cannot be offered while the
  	--	outcome of admission units is still pending.  (AOS05)
  	-- * An admission course application instance cannot be offered if it is
  	--	incomplete.  (AOS06)
  	-- * An admission course application instance cannot be offered if IGS_PE_PERSON
  	--	encumbrance checking is required for the admission application and the
  	--	IGS_PE_PERSON has an encumbrance.  (AOS07)
  	-- * An admission course application instance cannot be offered if course
  	--	encumbrance checking is required for the admission application and the
  	--	IGS_PE_PERSON has an encumbrance on the course being offered.  (AOS08)
  	-- * An admission course application instance cannot be offered if the full
  	--	components of a valid course offering pattern are not specified.  NOTE,
  	--	late applications can be overridden.  (AOS09)
  	-- * An admission course application instance cannot be offered if the
  	--	existing student course attempt is not valid.  (AOS10)
  	-- * An admission course application instance cannot be offered if IGS_PS_UNIT sets
  	--	are applicable for the admission application and the IGS_PS_UNIT set is not vaild.
  	--	(AOS11)
  	-- * An admission course application instance cannot be offered if course
  	--	encumbrance checking is required for the admission application and IGS_PS_UNIT
  	--	sets are applicable for the admission application and the IGS_PE_PERSON has an
  	--	encumbrance on the IGS_PS_UNIT set being offered.  (AOS11-A)
  	-- * An admission course application instance cannot be offered if the
  	--	proposed commencement date is not valid (AOS32).
  	-- * An admission course application instance can only be withdrawn or voided
  	--	if the IGS_PE_PERSON is not enrolled the admission course.  (AOS17-A)
  DECLARE
  	v_check			CHAR;
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_pending		CONSTANT VARCHAR2(10) := 'PENDING';
  	cst_outcome_lt		CONSTANT VARCHAR2(10) := 'OUTCOME-LT';
  	cst_offer		CONSTANT VARCHAR2(10) := 'OFFER';
  	cst_cond_offer		CONSTANT VARCHAR2(10) := 'COND-OFFER';
  	cst_withdrawn		CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  	cst_voided		CONSTANT VARCHAR2(10) := 'VOIDED';
  	cst_unconfirm		CONSTANT VARCHAR2(10) := 'UNCONFIRM';
  	cst_discontin		CONSTANT VARCHAR2(10) := 'DISCONTIN';
  	cst_deleted		CONSTANT VARCHAR2(10) := 'DELETED';
  	cst_lapsed		CONSTANT VARCHAR2(10) := 'LAPSED';
  	v_deferment_processing 		BOOLEAN ;
  	v_reconsideration_processing 	BOOLEAN ;
  	v_defermt_processing		BOOLEAN ;
  	v_reconsideratn_processing	BOOLEAN ;
  	v_message_name			VARCHAR2(30);
  	v_return_type			VARCHAR2(1);
  	v_late_ind			VARCHAR2(1);
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	v_adm_outcome_status		IGS_AD_OU_STAT.adm_outcome_status%TYPE;
  	v_effective_dt			DATE;
  	v_prpsd_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	v_ca_sequence_number		NUMBER;
  	CURSOR c_aal IS
  		SELECT	'x'
  		FROM	IGS_AD_APPL_LTR	aal
  		WHERE	aal.person_id			= p_person_id 		AND
  			aal.admission_appl_number	= p_admission_appl_number AND
  			aal.correspondence_type		= cst_outcome_lt;
  	CURSOR c_acai_aos IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_AD_OU_STAT		aos
  		WHERE	acai.person_id			= p_person_id		AND
  			acai.admission_appl_number	= p_admission_appl_number AND
  			(acai.nominated_course_cd	<> p_nominated_course_cd OR
  			 acai.sequence_number		<> p_acai_sequence_number) AND
  			acai.adm_outcome_status		= aos.adm_outcome_status AND
  			aos.s_adm_outcome_status	<> cst_pending;
  	CURSOR	c_acaiu_auos IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APLINSTUNT 	acaiu,
  			IGS_AD_UNIT_OU_STAT		auos
  		WHERE	acaiu.person_id			= p_person_id AND
  			acaiu.admission_appl_number	= p_admission_appl_number AND
  			acaiu.nominated_course_cd	= p_nominated_course_cd AND
  			acaiu.acai_sequence_number	= p_acai_sequence_number AND
  			auos.s_adm_outcome_status	= cst_pending		AND
  			acaiu.adm_unit_outcome_status	= auos.adm_unit_outcome_status;
  	CURSOR c_sca IS
  		SELECT	sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT 	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd AND
  			sca.adm_admission_appl_number	= p_admission_appl_number AND
  			sca.adm_nominated_course_cd	= p_nominated_course_cd AND
  			sca.adm_sequence_number		= p_acai_sequence_number;


        v_cty_res_typ_ind       IGS_PS_TYPE.research_type_ind%TYPE;

        CURSOR c_crv_cty IS
                SELECT  cty.research_type_ind
                FROM    IGS_PS_VER      crv,
                        IGS_PS_TYPE     cty
                WHERE   crv.course_cd           = p_course_cd AND
                        crv.version_number      = p_crv_version_number AND
                        crv.course_type         = cty.course_type;

  --------------------------------------------SUB-FUNCTION-----------------------
  	FUNCTION admpl_chk_res_or_def(
  		p_person_id			IGS_AD_PS_APPL_INST.person_id%TYPE,
  		p_admission_appl_number		IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
  		p_nominated_course_cd		IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
  		p_acai_sequence_number		IGS_AD_PS_APPL_INST.sequence_number%TYPE,
  		v_defermt_processing		IN OUT NOCOPY BOOLEAN,
  		v_reconsideratn_processing	IN OUT NOCOPY BOOLEAN)
  	RETURN BOOLEAN
  	AS
  	BEGIN	-- admpl_chk_res_or_def
  		-- Determine if reconsideration or deferment is being processed
  	DECLARE
  		cst_trg_as	CONSTANT VARCHAR2(10) := 'TRG_AS';
  		cst_deferral	CONSTANT VARCHAR2(10) := 'DEFERRAL';
  		cst_approved	CONSTANT VARCHAR2(10) := 'APPROVED';
  		cst_no_quota	CONSTANT VARCHAR2(10) := 'NO-QUOTA';
  		cst_rejected	CONSTANT VARCHAR2(10) := 'REJECTED';
  		v_s_adm_outcome_status		IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
  		v_s_adm_offer_resp_status	IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE;
  		v_s_adm_offer_dfrmnt_status 	IGS_LOOKUPS_VIEW.lookup_code%TYPE;
  		v_ret_val			BOOLEAN;
  		v_check				CHAR := NULL;
  		v_counter			NUMBER := 0;
  		CURSOR 	c_recent_his IS
  			SELECT	aos.s_adm_outcome_status,
  				aors.s_adm_offer_resp_status,
  				aods.s_adm_offer_dfrmnt_status
  			FROM	IGS_AD_PS_APLINSTHST	acaih,
  				IGS_AD_OU_STAT		aos,
  				IGS_AD_OFR_RESP_STAT		aors,
  				IGS_AD_OFRDFRMT_STAT		aods
  			WHERE	acaih.person_id 		= p_person_id 			AND
  				acaih.admission_appl_number 	= p_admission_appl_number 	AND
  				acaih.nominated_course_cd 	= p_nominated_course_cd 	AND
  				acaih.sequence_number 		= p_acai_sequence_number 	AND
  				acaih.adm_outcome_status	= aos.adm_outcome_status (+)	AND
  				acaih.adm_offer_resp_status 	= aors.adm_offer_resp_status (+)AND
  				acaih.adm_offer_dfrmnt_status   = aods.adm_offer_dfrmnt_status (+)
  			ORDER BY acaih.hist_start_dt DESC;
  		CURSOR c_sca IS
  			SELECT 'x'
  			FROM	IGS_AD_PS_APPL
  			WHERE	person_id 			= p_person_id AND
  				admission_appl_number 		= p_admission_appl_number AND
  				nominated_course_cd 		= p_nominated_course_cd AND
  				req_for_reconsideration_ind 	= 'Y';
  	BEGIN
  		v_ret_val := FALSE;
  		IF p_called_from = cst_trg_as THEN
  			v_defermt_processing 		:= FALSE;
  			v_reconsideratn_processing 	:= FALSE;
  			-- Select the first record only.
  			-- (This is the most recent history record inserted.  This history record
  			-- will have been
  			--  inserted as a part of reconsideration or deferment processing.)
  			-- Determine if deferment is being processed
  			FOR v_recent_his_rec IN c_recent_his LOOP
  				IF c_recent_his%ROWCOUNT = 1 THEN
  					IF v_recent_his_rec.s_adm_offer_resp_status IS NOT NULL AND
  							v_recent_his_rec.s_adm_offer_resp_status = cst_deferral AND
  							v_recent_his_rec.s_adm_offer_dfrmnt_status IS NOT NULL AND
  							v_recent_his_rec.s_adm_offer_dfrmnt_status = cst_approved THEN
  						v_defermt_processing := TRUE;
  						v_ret_val := TRUE;
  						EXIT;
  					END IF;
  					-- Determine if reconsideration is being processed.
  					IF NOT v_defermt_processing THEN
  						IF v_recent_his_rec.s_adm_outcome_status IN (
  											cst_no_quota,
  											cst_rejected) THEN
  							OPEN c_sca;
  							FETCH c_sca INTO v_check;
  							IF c_sca%FOUND THEN
  								CLOSE c_sca;
  								v_reconsideratn_processing := TRUE;
  								v_ret_val := TRUE;
  								EXIT;
  							END IF;
  							CLOSE c_sca;
  						END IF;
  					END IF; -- NOT v_defermt_processing
  				END IF;  -- if first record
  			END LOOP;
  		END IF; -- p_called_from = cst_trg_as
  		RETURN  v_ret_val;
  	EXCEPTION
  		WHEN OTHERS THEN
  			IF c_recent_his%ISOPEN THEN
  				CLOSE c_recent_his;
  			END IF;
  			IF c_sca%ISOPEN THEN
  				CLOSE c_sca;
  			END IF;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admpl_chk_res_or_def');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    	END admpl_chk_res_or_def;
  --------------------------------------------------MAIN-------------------------
  BEGIN
    v_deferment_processing := FALSE;
    v_reconsideration_processing := FALSE;
    v_defermt_processing := FALSE;
    v_reconsideratn_processing := FALSE;

	p_message_name := NULL;
  	------------------------------------------------------------------------------
  	-- Validate an outcome of pending.
  	------------------------------------------------------------------------------
  	IF p_s_adm_outcome_status = cst_pending THEN
  		-- Check for the existence of an admission application letter
  		OPEN c_aal;
  		FETCH c_aal INTO v_check;
  		IF c_aal%FOUND THEN
  			CLOSE c_aal;
  			IF p_pref_allowed = 'N' THEN
  				IF NOT admpl_chk_res_or_def(
  							p_person_id,
  							p_admission_appl_number,
  							p_nominated_course_cd,
  							p_acai_sequence_number,
  							v_defermt_processing,
  							v_reconsideratn_processing) THEN
  					v_deferment_processing 		:= v_defermt_processing;
  					v_reconsideration_processing 	:= v_reconsideratn_processing;
  					-- Determine if reconsideration or deferment is being processed.
  					IF NOT v_deferment_processing  AND
  							NOT v_reconsideration_processing THEN
  						-- (only one course to an application)
  						-- Outcome status cannot be pending if an admission outcome
  						-- letter has already been inserted (the letter will need to be deleted).
  						p_message_name := 'IGS_AD_ST_NOTBE_PENDING_DEL';
  						RETURN FALSE;
  					END IF;
  				END IF;
  			ELSE -- p_pref_allowed = 'N'
  				-- Cannot have an admission outcome letter if setting this instance to
  				-- pending means that there are no IGS_AD_PS_APPL_INST with an outcome
  				--  in the
  				-- admission application (exclude this instance in select)
  				OPEN c_acai_aos;
  				FETCH c_acai_aos INTO v_check;
  				IF c_acai_aos%NOTFOUND THEN
  					CLOSE c_acai_aos;
  					IF NOT admpl_chk_res_or_def(
  								p_person_id,
  								p_admission_appl_number,
  								p_nominated_course_cd,
  								p_acai_sequence_number,
  								v_defermt_processing,
  								v_reconsideratn_processing) THEN
  						v_deferment_processing 		:= v_defermt_processing;
  						v_reconsideration_processing    := v_reconsideratn_processing;
  						-- Determine if reconsideration or deferment is being processed.
  						IF NOT v_deferment_processing AND
  								NOT v_reconsideration_processing THEN
  							p_message_name := 'IGS_AD_ST_NOTBE_PENDING';
  							RETURN FALSE;
  						END IF;
  					END IF; -- admpl_chk_res_or_def(...)
  				ELSE -- c_acai_aos%NOTFOUND
  					CLOSE c_acai_aos;
  				END IF; -- c_acai_aos%NOTFOUND
  			END IF; -- p_pref_allowed = 'N'
  		ELSE -- c_aal%FOUND
  			CLOSE c_aal;
  		END IF;
  	END IF;	-- (PENDING)
  	------------------------------------------------------------------------------
  	-- Validate an outcome of offer or conditional offer.
  	------------------------------------------------------------------------------
  	IF p_s_adm_outcome_status IN (	cst_offer,
  					cst_cond_offer) THEN
  	------------------------------------------------------------------------------
  		-- Cannot make an offer if pending IGS_PS_UNIT outcome status exists.
  	------------------------------------------------------------------------------
  		OPEN c_acaiu_auos;
  		FETCH c_acaiu_auos INTO v_check;
  		IF c_acaiu_auos%FOUND THEN
  			p_message_name := 'IGS_AD_CANNOT_MAKE_OFR_PENDIN';
  			CLOSE c_acaiu_auos;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_acaiu_auos;
  	------------------------------------------------------------------------------
  	-- Cannot make an offer if the admission application is incomplete.
  	------------------------------------------------------------------------------
  		-- Determine the effective date for performing the complete check.
  --		v_effective_dt := IGS_AD_GEN_005.ADMP_GET_CRV_STRT_DT (
  --						p_adm_cal_type,
  --						p_adm_ci_sequence_number);
  		v_effective_dt := TRUNC(SYSDATE);
  		-- Perform complete check.
  		IF NOT IGS_AD_VAL_ACAI.admp_val_offer_comp(
  						p_person_id,
  						p_admission_appl_number,
  						p_nominated_course_cd,
  						p_acai_sequence_number,
  						p_course_cd,
  						p_crv_version_number,
  						p_admission_cat,
  						p_s_admission_process_type,
  						 v_effective_dt,
  						p_called_from,
  						p_message_name) THEN
  			RETURN FALSE;
  		END IF;
  		-----------------------------------------------------------------------------
  		-- Cannot make an offer if IGS_PE_PERSON encumbrance checking is required and the
  		-- applicant is encumbered.
  		-----------------------------------------------------------------------------
  		IF p_check_person_encumb = 'Y' THEN
  			-- Determine the effective date for performing the encumbrance check.
  			v_effective_dt := NVL(IGS_AD_GEN_006.ADMP_GET_ENCMB_DT (
  						p_adm_cal_type,
  						p_adm_ci_sequence_number),SYSDATE);
  			IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (
  						p_person_id,
  						NULL,	-- Input parameter course code: not applicable
  						 v_effective_dt,
  						 v_message_name) THEN
  				p_message_name := 'IGS_AD_OFR_CANNOT_BEMADE';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-----------------------------------------------------------------------------
  		-- Cannot make an offer if course encumbrance checking is required and the
  		-- applicant course
  		-- is encumbered.
  		-----------------------------------------------------------------------------
  		IF p_check_course_encumb = 'Y' THEN
  			IF NOT IGS_AD_VAL_ACAI.admp_val_acai_encmb(
  						p_person_id,
  						p_course_cd,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_check_course_encumb,
  						'Y',	-- Offer indicator
  						p_message_name,
  						 v_return_type) THEN
  				IF v_return_type = cst_error THEN	-- (cst_error - 'E')
  					RETURN FALSE;
  				END IF;
  			END IF;
  		END IF;
  		-----------------------------------------------------------------------------
  		-- Cannot make an offer if course version is planned.
  		-----------------------------------------------------------------------------
  		IF NOT IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_crv(
  					p_course_cd,
  					p_crv_version_number,
  					p_s_admission_process_type,
  					'Y',	-- Offer indicator,
  					p_message_name) THEN
  			RETURN FALSE;
  		END IF;
  		-----------------------------------------------------------------------------
  		-- Cannot make an offer if the course offering option is not valid.
  		-----------------------------------------------------------------------------
  		IF NOT IGS_AD_VAL_ACAI.admp_val_acai_cop (
  					p_course_cd,
  					p_crv_version_number,
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					p_acad_cal_type,
  					p_acad_ci_sequence_number,
  					p_adm_cal_type,
  					p_adm_ci_sequence_number,
  					p_admission_cat,
  					p_s_admission_process_type,
  					'Y',	-- Offer indicator,
  					p_appl_dt,
  					p_late_appl_allowed,
  					'N',	-- Deferred application
  					p_message_name,
  					 v_return_type,
  					 v_late_ind) THEN
  			IF v_return_type = cst_error THEN
  				IF v_late_ind = 'Y' THEN
  					-- If overriding outcome is allowed for the admission application,
  					-- then the late application is valid.
  					IF p_adm_outcome_status_auth_dt IS NULL THEN
  						RETURN FALSE;
  					END IF;
  				ELSE
  					RETURN FALSE;
  				END IF;
  			END IF;
  		END IF;
  		-----------------------------------------------------------------------------
  		-- Cannot make an offer if the course is not valid against existing student
  		-- course attempts.
  		-----------------------------------------------------------------------------
  		IF NOT IGS_AD_VAL_ACAI.admp_val_aca_sca (
  					p_person_id,
  					p_course_cd,
  					p_appl_dt,
  					p_admission_cat,
  					p_s_admission_process_type,
  					p_fee_cat,
  					p_correspondence_cat,
  					p_enrolment_cat,
  					'Y',	-- Offer indicator,
  					p_message_name,
  					 v_return_type) THEN
  			IF v_return_type = cst_error THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-----------------------------------------------------------------------------
  		-- Cannot make offer if IGS_PS_UNIT set is applicable for the admission application
  		-- and the IGS_PS_UNIT set is invalid.
  		-----------------------------------------------------------------------------
  		IF p_unit_set_appl = 'Y' THEN
  			IF NOT IGS_AD_VAL_ACAI.admp_val_acai_us (
  						p_unit_set_cd,
  						p_us_version_number,
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						p_location_cd,
  						p_attendance_mode,
  						p_attendance_type,
  						p_admission_cat,
  						'Y',	-- Offer indicator,
  						p_unit_set_appl,
  						p_message_name,
  						 v_return_type) THEN
  				IF v_return_type = cst_error THEN
  					RETURN FALSE;
  				END IF;
  			END IF;
  			----------------------------------------------------------------------------
  			-- Cannot make an offer if course encumbrance checking is required and IGS_PS_UNIT
  			-- set is applicable for the application and the applicant IGS_PS_UNIT set is
  			-- encumbered.
  			----------------------------------------------------------------------------
  			IF p_check_course_encumb = 'Y' THEN
  				IF NOT IGS_AD_VAL_ACAI.admp_val_us_encmb (
  						p_person_id,
  						p_course_cd,
  						p_unit_set_cd,
  						p_us_version_number,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_check_course_encumb,	-- Check course encumbrance indicator,
  						'Y', 	-- Offer indicator,
  						p_message_name,
  						v_return_type) THEN
  					IF v_return_type = cst_error THEN
  						RETURN FALSE;
  					END IF;
  				END IF;
  			END IF; -- p_check_course_encumb = 'Y'
  		END IF; -- p_unit_set_appl = 'Y'
  		-----------------------------------------------------------------------------
  		-- Cannot make an offer if the proposed commencement  date is not valid.
  		-----------------------------------------------------------------------------
  		--Determine the proposed commencement date.
  		v_prpsd_commencement_dt := IGS_EN_GEN_002.ENRP_GET_ACAD_COMM (
  							p_acad_cal_type,
  							p_acad_ci_sequence_number,
  							p_person_id,
  							p_course_cd,
  							p_admission_appl_number,
  							p_nominated_course_cd,
  							p_acai_sequence_number,
  							'Y');	-- Check proposed commencement date indicator.
  		--Determine the user defined outcome status.
  		v_adm_outcome_status := IGS_AD_GEN_009.ADMP_GET_SYS_AOS(
  							p_s_adm_outcome_status);

		-- Need to by pass the check for research programs

		OPEN c_crv_cty;
                FETCH c_crv_cty INTO v_cty_res_typ_ind;

		IF c_crv_cty%FOUND THEN
		 -- bug no 2124050
	         -- ADDED the CLOSE c_cr_cty after checking FOUND in the cursor
		 -- previously it was done before checking the cursor
                 -- by rrengara on 12-MAR-2002
		  CLOSE c_crv_cty;
			IF v_cty_res_typ_ind = 'Y' THEN
  				IF NOT IGS_RE_VAL_CA.admp_val_acai_comm (
  						p_person_id,
  						p_course_cd,
  						p_crv_version_number,
  						p_admission_appl_number,
  						p_nominated_course_cd,
  						p_acai_sequence_number,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						 v_adm_outcome_status,
  						 v_prpsd_commencement_dt,
  						NULL,			-- Minimum_Submission_Date
  						 v_ca_sequence_number,	-- IGS_RE_CANDIDATURE Sequence Number
  						'ACAI',			-- Parent
  						p_message_name) THEN
  					RETURN FALSE;
  				END IF;
			END IF;
		END IF;
  	END IF;	-- (OFFER, COND-OFFER)
  	------------------------------------------------------------------------------
  	-- Validate an outcome of withdrawn or voided.
  	------------------------------------------------------------------------------
  	IF p_s_adm_outcome_status IN (	cst_withdrawn,
  					cst_voided) THEN
  		-- Cannot withdraw or void offer if applicant is currently enrolled in their
  		-- course of admission.
  		OPEN c_sca;
  		FETCH c_sca INTO v_course_attempt_status;
  		IF c_sca%FOUND THEN
  			IF v_course_attempt_status NOT IN (
  							cst_unconfirm,
  							cst_discontin,
  							cst_deleted,
  							cst_lapsed) THEN
  				CLOSE c_sca;
  				p_message_name := 'IGS_AD_INST_NOTBE_WITHDRAWN';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_sca;
  	END IF; -- (WITHDRAWN, VOIDED)
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_aal%ISOPEN THEN
  			CLOSE c_aal;
  		END IF;
  		IF c_acai_aos%ISOPEN THEN
  			CLOSE c_acai_aos;
  		END IF;
  		IF c_acaiu_auos%ISOPEN THEN
  			CLOSE c_acaiu_auos;
  		END IF;
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_otcome');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
   END admp_val_acai_otcome;
  --
  -- This module validates multiple IGS_AD_PS_APPL_INST offers.
  FUNCTION admp_val_offer_mult(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_multi_offer_allowed IN VARCHAR2,
  p_multi_offer_limit IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN  -- Validates multiple IGS_AD_PS_APPL_INST offers
  	-- Validations are
  	-- * If the admission application does not allow multiple offers then only one
  	-- admission
  	--   course application instance can be currently offered to the IGS_PE_PERSON within
  	-- the
  	--   admission period and admission process category.  (AOS13)
  	-- * If the admission application allows multiple offers then the number of
  	-- current offers
  	--   for the IGS_PE_PERSON within the same admission period and admission process
  	-- category must
  	--   be less than or equal to the number of offers allowed for the admission
  	-- process
  	--   category (AOS14)
  	-- * The admission course application instance cannot be offered if the IGS_PE_PERSON
  	-- has already
  	--   been has a current offered for the same course in the same admission
  	-- period.  (AOS15)
  DECLARE
  	v_check		CHAR;
  	v_count		NUMBER(5);
  	cst_offer	CONSTANT VARCHAR2(10)	:= 'OFFER';
  	cst_cond_offer	CONSTANT VARCHAR2(10)	:= 'COND-OFFER';
  	cst_rejected	CONSTANT VARCHAR2(10)   := 'REJECTED';
  	cst_not_applic	CONSTANT VARCHAR2(10)   := 'NOT-APPLIC';
  	CURSOR c_acaiv_aos IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APPL_INST	acaiv,  /* References to IGS_AD_PS_APPL_INST_APLINST_V replaced with IGS_AD_PS_APPL_INST Bug 3150054 */
  			IGS_AD_OU_STAT	aos,
  			IGS_AD_OFR_RESP_STAT 	aors
  		WHERE	acaiv.person_id			= p_person_id				AND
  			(acaiv.admission_appl_number	<> p_admission_appl_number 		OR
  			 acaiv.nominated_course_cd	<> p_nominated_course_cd   		OR
  			 acaiv.sequence_number		<> p_acai_sequence_number) 		AND
  			acaiv.course_cd			= p_course_cd				AND
  			acaiv.adm_cal_type		= p_adm_cal_type			AND
  			acaiv.adm_ci_sequence_number	= p_adm_ci_sequence_number		AND
  			aos.s_adm_outcome_status 	IN (cst_offer, cst_cond_offer)		AND
  			aors.s_adm_offer_resp_status 	NOT IN (cst_rejected, cst_not_applic) 	AND
  			acaiv.adm_outcome_status	= aos.adm_outcome_status		AND
  			acaiv.adm_offer_resp_status	= aors.adm_offer_resp_status;
  	CURSOR c_cnt_acaiv_aa_aos IS
  		SELECT	count(*)
  		FROM	IGS_AD_PS_APPL_INST	acaiv,  /* References to IGS_AD_PS_APPL_INST_APLINST_V replaced with IGS_AD_PS_APPL_INST Bug 3150054 */
  			IGS_AD_APPL		aa,
  			IGS_AD_OU_STAT	aos,
  			IGS_AD_OFR_RESP_STAT 	aors
  		WHERE	acaiv.person_id			= p_person_id			AND
  			(acaiv.admission_appl_number	<> p_admission_appl_number 	OR
  			 acaiv.nominated_course_cd	<> p_nominated_course_cd   	OR
  			 acaiv.sequence_number		<> p_acai_sequence_number)	AND
  			acaiv.adm_cal_type		= p_adm_cal_type		AND
  			acaiv.adm_ci_sequence_number	= p_adm_ci_sequence_number	AND
  			aa.admission_cat		= p_admission_cat		AND
  			aa.s_admission_process_type	= p_s_admission_process_type	AND
  			aos.s_adm_outcome_status IN (cst_offer, cst_cond_offer)		AND
  			aors.s_adm_offer_resp_status NOT IN (cst_rejected, cst_not_applic)  AND
  			aa.person_id			= acaiv.person_id		AND
  			aa.admission_appl_number	= acaiv.admission_appl_number	AND
  		--	aa.acad_cal_type		= acaiv.acad_cal_type 		AND  -- Commented this line as the join is not required Bug 3150054
  		--	aa.acad_ci_sequence_number	= acaiv.acad_ci_sequence_number AND  -- Commented this line as the join is not required Bug 3150054
  			aos.adm_outcome_status		= acaiv.adm_outcome_status	AND
  			acaiv.adm_offer_resp_status	= aors.adm_offer_resp_status;
  BEGIN
  	p_message_name := NULL;
  	-- Only perform multiple offer validations when the admission course
  	-- application instance has been
  	-- offered or conditionally offered.
  	IF p_s_adm_outcome_status IN (cst_offer, cst_cond_offer) AND
  			p_s_adm_offer_resp_status NOT IN (cst_rejected,cst_not_applic)THEN
  		OPEN c_cnt_acaiv_aa_aos;
  		FETCH c_cnt_acaiv_aa_aos INTO v_count;
  		CLOSE c_cnt_acaiv_aa_aos;
  		-- Validate when multiple offers are not allowed.
  		IF p_multi_offer_allowed = 'N' THEN
  			IF v_count > 0 THEN
  				-- Cannot make an offer to more than one course in the same admission
  				-- process category if multiple offers are not allowed.
  				p_message_name := 'IGS_AD_MULTIPLE_OFRS_NOTALLOW';
  				RETURN FALSE;
  			END IF;
  		ELSE
  				-- Validate when multiple offers are allowed.
  			IF v_count >= p_multi_offer_limit THEN
  				-- Multiple offer limit has been reached.  No more offers can be made.
  				p_message_name := 'IGS_AD_MULTIPLE_OFFER_LIMIT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- Validate offers within the same admission period
  		OPEN c_acaiv_aos;
  		FETCH c_acaiv_aos INTO v_check;
  		IF (c_acaiv_aos%FOUND) THEN
  			-- Cannot make an offer if this course is already being offered to this
  			-- applicant in this admission period.
  			CLOSE c_acaiv_aos;
  			p_message_name := 'IGS_AD_PRSN_CANNOTOFR_SAMEPRG';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_acaiv_aos;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_acaiv_aos%ISOPEN) THEN
  			CLOSE c_acaiv_aos;
  		END IF;
  		IF (c_cnt_acaiv_aa_aos%ISOPEN) THEN
  			CLOSE c_acaiv_aos;
  		END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_offer_mult');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_offer_mult;
  --
  -- Validate offers across admission process categories (same adm period).
  FUNCTION admp_val_offer_x_apc(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_offer_x_apc
  	-- Validate admission application offers across admission process categories
  	-- within the same admission period.
  	-- Validations are :
  	-- *	Warn if the IGS_PE_PERSON is being made an offer and they already have a
  	--	current offer in another admission process category for
  	--	this admission period.
  DECLARE
  	cst_offer	CONSTANT	IGS_AD_OU_STAT.s_adm_outcome_status%TYPE :='OFFER';
  	cst_cond_offer	CONSTANT
  					IGS_AD_OU_STAT.s_adm_outcome_status%TYPE :='COND-OFFER';
  	cst_rejected	CONSTANT
  					IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE :='REJECTED';
  	cst_not_applic	CONSTANT
  					IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE :='NOT-APPLIC';
  	cst_warn	CONSTANT	VARCHAR2(1) := 'W';
  	cst_error	CONSTANT	VARCHAR2(1) := 'E';
  	v_aaaa_exists			VARCHAR2(1);
  	v_s_adm_outcome_status		igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_s_adm_offer_resp_status	igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE;
  	CURSOR c_aaaa IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APPL_INST acaiv,  /* References to IGS_AD_PS_APPL_INST_APLINST_V replaced with IGS_AD_PS_APPL_INST Bug 3150054 */
  			IGS_AD_APPL		aa,
  			IGS_AD_OU_STAT	aos,
  			IGS_AD_OFR_RESP_STAT	aors
  		WHERE	acaiv.person_id			= p_person_id AND
  			(acaiv.admission_appl_number	<> p_admission_appl_number OR
  			acaiv.nominated_course_cd	<> p_nominated_course_cd OR
  			acaiv.sequence_number		<> p_acai_sequence_number) AND
  			aa.person_id			= acaiv.person_id AND
  			aa.admission_appl_number	= acaiv.admission_appl_number AND
  			(aa.admission_cat		<> p_admission_cat OR
  			aa.s_admission_process_type	<> p_s_admission_process_type) AND
  			acaiv.adm_cal_type		= p_adm_cal_type AND
  			acaiv.adm_ci_sequence_number	= p_adm_ci_sequence_number AND
  			aos.s_adm_outcome_status	IN (
  							cst_offer,
  							cst_cond_offer) AND
  			aors.s_adm_offer_resp_status	NOT IN (
  							cst_rejected,
  							cst_not_applic) AND
  			acaiv.adm_outcome_status 	= aos.adm_outcome_status AND
  			acaiv.adm_offer_resp_status	= aors.adm_offer_resp_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	p_return_type := NULL;
  	-- Get the status system values.
  	v_s_adm_outcome_status		:= (IGS_AD_GEN_008.ADMP_GET_SAOS (p_adm_outcome_status));
  	v_s_adm_offer_resp_status	:= (IGS_AD_GEN_008.ADMP_GET_SAORS (p_adm_offer_resp_status));
  	IF v_s_adm_outcome_status IN (
  				cst_offer,
  				cst_cond_offer)	AND
  			v_s_adm_offer_resp_status not in (cst_rejected, cst_not_applic) THEN
  		OPEN c_aaaa;
  		FETCH c_aaaa INTO v_aaaa_exists;
  		IF c_aaaa%FOUND THEN
  			CLOSE c_aaaa;
  			p_message_name := 'IGS_AD_PRSN_CUROFR_ADMPRC';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_aaaa;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_aaaa%ISOPEN THEN
  			CLOSE c_aaaa;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_offer_x_apc');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_offer_x_apc;
  --
  -- Validate update of the admission outcome status.
  FUNCTION admp_val_aos_update(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aos_update
  	-- Validate update of the admission outcome status.
  	-- On update of the admission outcome status warn if outcome letter
  	-- correspondence is yet to be issued and phrases relating to the old status
  	-- are attached
  DECLARE
  	v_aal_seq_no	IGS_AD_APPL_LTR.sequence_number%TYPE;
  	v_sent_dt	DATE;
  	cst_warn	CONSTANT VARCHAR2(1) := 'W';
  	cst_error	CONSTANT VARCHAR2(1) := 'E';
  	CURSOR c_seq_no IS
  		SELECT	aal.sequence_number
  		FROM	IGS_AD_APPL_LTR aal,
  			IGS_AD_APPL_LTR_PHR aalp
  		WHERE	aalp.person_id 		   = p_person_id AND
  			aalp.admission_appl_number = p_admission_appl_number AND
  			aalp.correspondence_type   = 'OUTCOME-LT' AND
  			aal.person_id		   = aalp.person_id AND
  			aal.admission_appl_number  = aalp.admission_appl_number AND
  			aal.correspondence_type	   = aalp.correspondence_type AND
  			aal.sequence_number	   = aalp.aal_sequence_number;
  BEGIN
  	-- Check if the outcome status has been updated
  	IF p_adm_outcome_status <> p_old_adm_outcome_status THEN
  		-- Warn on change of outcome status if outcome letter correspondence
  		-- is yet to be issued and has phrases relating to the old status attached
  		OPEN c_seq_no;
  		FETCH c_seq_no INTO v_aal_seq_no;
  		IF (c_seq_no%FOUND)THEN
  			-- Determine if the correspondence has been sent
  			v_sent_dt := IGS_AD_GEN_002.ADMP_GET_AAL_SENT_DT (
  							p_person_id,
  							p_admission_appl_number,
  							'OUTCOME-LT',
  							v_aal_seq_no);
  			IF v_sent_dt IS NULL THEN
  				-- Current correspondence may need to be corrected
  				p_message_name := 'IGS_AD_CHG_ADMOUTCOME_STATUS';
  				p_return_type := cst_warn;
  				CLOSE c_seq_no;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_seq_no;
  	END IF;
  	p_message_name := NULL;
  	p_return_type := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aos_update');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_aos_update;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status.
  FUNCTION admp_val_acai_acos(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_old_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_doc_status IN VARCHAR2 ,
  p_late_adm_fee_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2,
  p_fees_required IN VARCHAR2,
  p_cond_offer_assess_allowed IN VARCHAR2,
  p_cond_offer_fee_allowed IN VARCHAR2,
  p_cond_offer_doc_allowed IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--admp_val_acai_acos
  	--Validate the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_s_adm_cndtnl_offer_status     igs_ad_cndnl_ofrstat.s_adm_cndtnl_offer_status%TYPE;
  	v_old_s_adm_cndtnl_offer_stat   igs_ad_cndnl_ofrstat.s_adm_cndtnl_offer_status%TYPE;
  	v_s_adm_outcome_status 		igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  	v_s_adm_doc_status 		igs_ad_doc_stat.s_adm_doc_status%TYPE;
  	v_late_s_adm_fee_status 	igs_ad_fee_stat.s_adm_fee_status%TYPE;
  BEGIN
  	--set the default message number
  	p_message_name	:= NULL;
  	--Perform item level validations.
  	IF (IGS_AD_VAL_ACAI_STATUS.admp_val_acos_item (
  				p_adm_cndtnl_offer_status,
  				p_adm_fee_status,
  				p_fees_required,
  				p_cond_offer_assess_allowed,
  				p_cond_offer_fee_allowed,
  				p_cond_offer_doc_allowed,
  				v_message_name) = FALSE) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	v_s_adm_cndtnl_offer_status 	:= IGS_AD_GEN_007.ADMP_GET_SACOS(
  							p_adm_cndtnl_offer_status);
  	v_old_s_adm_cndtnl_offer_stat := IGS_AD_GEN_007.ADMP_GET_SACOS(
  							p_old_adm_cndtnl_offer_status);
  	v_s_adm_outcome_status 		:= IGS_AD_GEN_008.ADMP_GET_SAOS(
  							p_adm_outcome_status);
  	v_s_adm_doc_status 		:= IGS_AD_GEN_007.ADMP_GET_SADS(
  							p_adm_doc_status);
  	v_late_s_adm_fee_status 	:= IGS_AD_GEN_008.ADMP_GET_SAFS(
  							p_late_adm_fee_status);
  	--Validate against the other admission course application instance status
  	-- values.
  	IF (IGS_AD_VAL_ACAI_STATUS.admp_val_acos_status (
  				v_s_adm_cndtnl_offer_status,
  				v_old_s_adm_cndtnl_offer_stat,
  				v_s_adm_outcome_status,
  				v_s_adm_doc_status,
  				v_late_s_adm_fee_status,
  				p_late_appl_allowed,
  				v_message_name) = FALSE) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_acos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_acai_acos;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status.
  FUNCTION admp_val_acos_item(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_fees_required IN VARCHAR2 ,
  p_cond_offer_assess_allowed IN VARCHAR2 ,
  p_cond_offer_fee_allowed IN VARCHAR2 ,
  p_cond_offer_doc_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--admp_val_acos_item
  	--Validate the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status.
  	--The IGS_AD_CNDNL_OFRSTAT must be open.  (ACOS01)
  	--The conditional offer status must be not-applicable when conditional
  	--offers are not allowed.  (ACOS02)
  	--If fees are required for the application, then fees must not be outstanding
  	--for the conditional offer to be satisfied.  (ACOS08)
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_s_adm_fee_status		igs_ad_fee_stat.s_adm_fee_status%TYPE;
  	v_s_adm_cndtnl_offer_status     igs_ad_cndnl_ofrstat.s_adm_cndtnl_offer_status%TYPE;
  BEGIN
  	--set the default message number
  	p_message_name	:= NULL;
  	--validate the closed indicator
  	IF (IGS_AD_VAL_ACAI_STATUS.admp_val_acos_closed (
  				p_adm_cndtnl_offer_status,
  				v_message_name) = FALSE) THEN
  		p_message_name	:= v_message_name;
  		RETURN FALSE;
  	END IF;
  	v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS (p_adm_cndtnl_offer_status);
  	--Validate the conditional offer status against
  	---the admission process category steps.
  	IF (p_cond_offer_assess_allowed = 'N'	AND
  			p_cond_offer_fee_allowed 	= 'N' AND
  			p_cond_offer_doc_allowed 	= 'N' AND
  			v_s_adm_cndtnl_offer_status	<> 'NOT-APPLIC') THEN
  		--The conditional offer status must be not-applicable
  		--when conditional offers are not allowed.
  		p_message_name := 'IGS_AD_CONDOFRST_NOTAPPLICABL';
  		RETURN FALSE;
  	END IF;
  	--Validate the conditional offer status against the admission application fee
  	-- status.
  	IF (p_fees_required = 'Y' AND
  			v_s_adm_cndtnl_offer_status = 'SATISFIED') THEN
  		--The admission conditional offer status cannot be satisfied if
  		--application fees are still being assessed or haven't been determined.
  		v_s_adm_fee_status := IGS_AD_GEN_008.ADMP_GET_SAFS(p_adm_fee_status);
  		IF (v_s_adm_fee_status IN ('PENDING', 'ASSESSED')) THEN
  			p_message_name := 'IGS_AD_CONDOFR_NOTSATISFIED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acos_item');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_acos_item;
  --
  -- Validate if IGS_AD_CNDNL_OFRSTAT.adm_cndtnl_offer_status is closed.
  FUNCTION admp_val_acos_closed(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_acos_closed
  	-- Validate the IGS_AD_CNDNL_OFRSTAT closed indicator
  DECLARE
  	CURSOR c_acos(
  			cp_adm_cndtnl_offer_status
  				IGS_AD_CNDNL_OFRSTAT.adm_cndtnl_offer_status%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AD_CNDNL_OFRSTAT
  		WHERE	adm_cndtnl_offer_status =cp_adm_cndtnl_offer_status;
  	v_acos_rec			c_acos%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cursor handling
  	OPEN c_acos(
  			p_adm_cndtnl_offer_status);
  	FETCH c_acos INTO v_acos_rec;
  	IF c_acos%NOTFOUND THEN
  		CLOSE c_acos;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_acos;
  	IF (v_acos_rec.closed_ind = cst_yes) THEN
  		p_message_name := 'IGS_AD_ADMCOND_OFR_ST_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acos_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_acos_closed;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status.
  FUNCTION admp_val_acos_status(
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_old_s_adm_cndtnl_offer_sts IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_doc_status IN VARCHAR2 ,
  p_late_s_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--admp_val_acos_status
  	--This module validates the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status
  	--against other IGS_AD_PS_APPL_INST statuses.
  DECLARE
  BEGIN
  	--set the default message number
  	p_message_name	:= NULL;
  	--Validate the admission conditional offer status against the admission outcome
  	--  status.
  	IF (p_s_adm_cndtnl_offer_status <> 'NOT-APPLIC' AND
  			p_old_s_adm_cndtnl_offer_sts	= 'NOT-APPLIC' AND
  			p_s_adm_outcome_status 		<> 'COND-OFFER') THEN
  		--The admission conditional offer status cannot be changed from
  		--not-applicable if the admission outcome status is not conditional offer.
  		p_message_name := 'IGS_AD_CONDOFR_NOTCHANGED' ;
  		RETURN FALSE;
  	END IF;
  	IF (p_s_adm_cndtnl_offer_status = 'PENDING' AND
  			p_s_adm_outcome_status NOT IN('COND-OFFER', 'WITHDRAWN', 'VOIDED')) THEN
  		--The admission conditional offer status cannot be pending
  		--if a conditional offer has not been made.
  		p_message_name := 'IGS_AD_CONDOFR_NOTPENDING';
  		RETURN FALSE;
  	END IF;
  	IF (p_s_adm_cndtnl_offer_status = 'SATISFIED') THEN
  		IF( p_s_adm_outcome_status NOT IN ('COND-OFFER', 'WITHDRAWN', 'VOIDED')) THEN
  			--The admission conditional offer status cannot be satisfied if a
  			--conditional offer has not been made.
  			p_message_name := 'IGS_AD_CONDOFR_ST_NOT_SATISFI';
  			RETURN FALSE;
  		END IF;
  		--Validate the admission conditional offer status against the
  		--admission documentation status.
  		IF( p_s_adm_doc_status IN (
  				'PENDING', 'UNSATISFAC', 'REJECTED-F', 'INCOMPLETE')) THEN
  			--The admission conditional offer status cannot be satisfied if
  			--documentation is unsatisfactory, rejected, incomplete or hasn't been
  			-- determined.
  			p_message_name := 'IGS_AD_CONDOFR_NOT_SATISFIED';
  			RETURN FALSE;
  		END IF;
  		--Validate the admission conditional offer status against the late
  		--admission fee status.
  		IF (p_late_appl_allowed = 'Y' AND
  				p_late_s_adm_fee_status IN('PENDING', 'ASSESSED')) THEN
  			--The admission conditional offer status cannot be satisfied
  			--if late fees are still being assessed or haven't been determined.
  			p_message_name := 'IGS_AD_OFRST_LATE_FEES';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF (p_s_adm_cndtnl_offer_status = 'WAIVED' AND
  			p_s_adm_outcome_status NOT IN('COND-OFFER', 'WITHDRAWN', 'VOIDED')) THEN
  		--The admission conditional offer status cannot be waived if a
  		--conditional offer has not been made.
  		p_message_name := 'IGS_AD_CONDOFR_NOTWAIVED';
  		RETURN FALSE;
  	END IF;
--Removed this validation as part of the bug 2395305
/*  	IF (p_s_adm_cndtnl_offer_status = 'UNSATISFAC' AND
  			p_s_adm_outcome_status NOT IN('WITHDRAWN', 'VOIDED')) THEN
  		--The admission conditional offer status cannot be unsatisfactory
  		--if the conditional offer has not been withdrawn or voided.
  		p_message_name := 'IGS_AD_ST_NOTBE_UNSATISFACTOR';
  		RETURN FALSE;
  	END IF;
*/
  	IF (p_s_adm_cndtnl_offer_status = 'NOT-APPLIC' AND
  			p_s_adm_outcome_status = 'COND-OFFER') THEN
  		--The admission conditional offer status cannot be not-applicable
  		--if a conditional offer has been made.
  		p_message_name := 'IGS_AD_CONDOFR_NOT_NOTAPPL';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acos_status');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_acos_status;

  FUNCTION admp_val_aods_update(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_offer_deferment_status IN VARCHAR2,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS
    BEGIN
  -- hreddych #2602077  SF Integration Added the FUNCTION admp_val_aods_update
  -- This function validates the change in the offer deferment status
  -- The offer deferment status can be moved to CONFIRM only when the
  -- status is APPROVED.
  DECLARE
   CURSOR cur_offer_dfrmnt_status(p_person_id igs_ad_ps_appl_inst.person_id%TYPE ,
                                  p_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE ,
                                  p_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE ,
                                  p_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE) IS
   SELECT adm_offer_dfrmnt_status
   FROM   igs_ad_ps_appl_inst
   WHERE  person_id = p_person_id AND
	  admission_appl_number = p_admission_appl_number AND
	  nominated_course_cd = p_nominated_course_cd AND
	  sequence_number = p_sequence_number ;

   v_new_ofr_dfrmnt_status  igs_ad_ofrdfrmt_stat.s_adm_offer_dfrmnt_status%TYPE;
   v_ofr_dfrmnt_status igs_ad_ps_appl_inst.adm_offer_dfrmnt_status%TYPE;
   v_s_ofr_dfrmnt_status igs_ad_ofrdfrmt_stat.s_adm_offer_dfrmnt_status%TYPE;
  BEGIN
   v_new_ofr_dfrmnt_status := igs_ad_gen_008.admp_get_saods(p_offer_deferment_status);
	   IF v_new_ofr_dfrmnt_status = 'CONFIRM' THEN
	      OPEN cur_offer_dfrmnt_status (p_person_id,p_admission_appl_number,p_nominated_course_cd,
					    p_sequence_number);
	      FETCH cur_offer_dfrmnt_status INTO v_ofr_dfrmnt_status ;
	      CLOSE cur_offer_dfrmnt_status;
	      v_s_ofr_dfrmnt_status :=igs_ad_gen_008.admp_get_saods(v_ofr_dfrmnt_status) ;
		      IF v_s_ofr_dfrmnt_status NOT IN ('APPROVED','CONFIRM') THEN
			 p_message_name := 'IGS_AD_CONF_WITHOUT_APR';
			 RETURN FALSE;
		      ELSE
			 p_message_name :=NULL;
			 RETURN TRUE;
		      END IF;
	  ELSE
	     p_message_name :=NULL;
	     RETURN TRUE;
	  END IF;
   END ;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_aods_update');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aods_update;



  FUNCTION admp_val_acai_ais(								--arvsrini igsm
  p_appl_inst_status IN VARCHAR2 ,
  p_ais_reason IN VARCHAR2,
  p_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_ais
  	-- Validate the IGS_AD_PS_APPL_INST.appl_inst_status
  DECLARE
  	v_s_appl_inst_status		IGS_AD_PS_APPL_INST.appl_inst_status%TYPE;
  	v_s_adm_outcome_status		IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
  	v_message_name			VARCHAR2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Perform item level validations.
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_ais_item (
				p_appl_inst_status,
				p_ais_reason,
  				v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;

  	-- Set local variables to system values
  	v_s_appl_inst_status := IGS_AD_GEN_007.ADMP_GET_SAAS(p_appl_inst_status);
  	v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS(p_adm_outcome_status);

	IF v_s_appl_inst_status = 'WITHDRAWN' and p_ais_reason IS NULL THEN
  			p_message_name := 'IGS_AD_WITHD_RSN_MISSING';
  			RETURN FALSE;
  	END IF;


  	-- Validate against the admission outcome status
  	IF NOT IGS_AD_VAL_ACAI_STATUS.admp_val_ais_aos (
			  v_s_appl_inst_status,
			  v_s_adm_outcome_status,
  			  v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_acai_ais');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_acai_ais;




  FUNCTION admp_val_ais_item(								--arvsrini igsm
  p_appl_inst_status IN VARCHAR2 ,
  p_ais_reason IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
	-- admp_val_ais_item
  	-- This module validates the IGS_AD_PS_APPL_INST.appl_inst_status.
  	-- Validations are:
  	-- The appl_inst_status must be open.
  	-- If the appl_inst_status is present then the ais_reason should also be present

  	v_message_name			VARCHAR2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the closed indicator.
  	IF (IGS_AD_VAL_ACAI_STATUS.admp_val_ais_closed (
  			p_appl_inst_status,
  			v_message_name)=FALSE) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;

  	-- Return the default value
  	RETURN TRUE;

   EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_ais_item');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
   END admp_val_ais_item;



  FUNCTION admp_val_ais_closed(								--arvsrini igsm
  p_appl_inst_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		igs_ad_appl_stat.closed_ind%TYPE;
  	CURSOR c_ais IS
  		SELECT	ais.closed_ind
  		FROM	igs_ad_appl_stat ais
  		WHERE   ais.adm_appl_status = p_appl_inst_status;
  BEGIN
  	-- Validate if igs_ad_appl_stat.adm_appl_status is closed.
  	OPEN c_ais;
  	FETCH c_ais INTO v_closed_ind;
  	IF (c_ais%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_ais;
  			p_message_name := 'IGS_AD_AIS_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_ais;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_ais_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ais_closed;



  FUNCTION admp_val_ais_aos(								--arvsrini igsm
  p_s_appl_inst_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  	cst_pending			CONSTANT VARCHAR2(10) := 'PENDING';
  	cst_withdrawn			CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_s_appl_inst_status = cst_withdrawn AND p_s_adm_outcome_status <> cst_pending THEN
  			p_message_name := 'IGS_AD_AIS_OUT_PEND';
  			RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;

  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAI_STATUS.admp_val_ais_aos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ais_aos;

END igs_ad_val_acai_status;

/
