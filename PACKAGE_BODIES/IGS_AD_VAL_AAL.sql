--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AAL" AS
/* $Header: IGSAD17B.pls 115.7 2002/11/28 21:25:55 nsidana ship $ */

  --
  -- Validate the correspondence type for an admission application letter.
  FUNCTION admp_val_aal_cort(
  p_correspondence_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	--admp_val_aal_cort
  	--This module validates the correspondence type to be used
  	--in an admission application letter
  DECLARE
  	v_slet_exists	VARCHAR2(1);
  	v_apcl_exists	VARCHAR2(1);
  	v_apcs_exists	VARCHAR2(1);
  	CURSOR c_slet IS
  		SELECT 'X'
  		FROM	IGS_CO_S_LTR	slet
  		WHERE	slet.s_letter_reference_type	= 'ADM'			AND
  			slet.correspondence_type	= p_correspondence_type;
  	CURSOR c_apcl IS
  		SELECT 'X'
  		FROM	IGS_AD_PRCS_CAT_LTR	apcl
  		WHERE	apcl.admission_cat		= p_admission_cat	AND
  			apcl.s_admission_process_type	= p_s_admission_process_type;
  	CURSOR c_apcl_2 IS
  		SELECT 'X'
  		FROM	IGS_AD_PRCS_CAT_LTR	apcl
  		WHERE	apcl.admission_cat		= p_admission_cat		AND
  			apcl.s_admission_process_type	= p_s_admission_process_type	AND
  			apcl.correspondence_type	= p_correspondence_type;
  	CURSOR c_apcs (
  		cp_step_type	IGS_AD_PRCS_CAT_STEP.s_admission_step_type%TYPE) IS
  		SELECT 'X'
  		FROM	IGS_AD_PRCS_CAT_STEP	apcs
  		WHERE	apcs.admission_cat		= p_admission_cat		AND
  			apcs.s_admission_process_type	= p_s_admission_process_type	AND
  			apcs.s_admission_step_type	= cp_step_type AND
  			apcs.step_group_type <> 'TRACK'; --2402377
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Check that admissions letters exist with this correspondence type.
  	OPEN c_slet;
  	FETCH c_slet INTO v_slet_exists;
  	IF (c_slet%NOTFOUND) THEN
  		CLOSE c_slet;
		p_message_name := 'IGS_AD_NOADM_LETTERS_EXIST';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_slet;
  	OPEN c_apcl;
  	FETCH c_apcl INTO v_apcl_exists;
  	IF (c_apcl%FOUND) THEN
  		--Check that a letter with this correspondence exists
  		--for this admission process category.
  		OPEN c_apcl_2;
  		FETCH c_apcl_2 INTO v_apcl_exists;
  		IF (c_apcl_2%NOTFOUND) THEN
  			CLOSE c_apcl;
  			CLOSE c_apcl_2;
			p_message_name := 'IGS_AD_LETTER_CORTYPE_NOTEXIS';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_apcl_2;
  	END IF;
  	CLOSE c_apcl;
  	--Validate that ACK-APP step defined for this admission process category.
  	IF (p_correspondence_type = 'ACKNOW-LET') THEN
  		OPEN c_apcs('ACK-APP');
  		FETCH c_apcs INTO v_apcs_exists;
  		IF (c_apcs%NOTFOUND) THEN
  			CLOSE c_apcs;
			p_message_name := 'IGS_AD_CORTYPE_NOTBE_ACKNOW';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_apcs;
  	END IF;
  	--Validate that OUTCOME-LT step defined for this admission process category.
  	IF (p_correspondence_type = 'OUTCOME-LT') THEN
  		OPEN c_apcs('OUTCOME-LT');
  		FETCH c_apcs INTO v_apcs_exists;
  		IF (c_apcs%NOTFOUND) THEN
  			CLOSE c_apcs;
			p_message_name := 'IGS_AD_CORTYPE_NOTBE_OUTCOME';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_apcs;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AAL.admp_val_aal_cort');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aal_cort;
  --
  -- Validate if an unsent adm appl letter exists with the same corres type
  FUNCTION admp_val_aal_exists(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_val_aal_exists
  	-- This module checks if an admission application letter exists
  	-- with the passed correspondence type and checks if it has been sent.
  DECLARE
  	CURSOR c_aal IS
  		SELECT	sequence_number
  		FROM	IGS_AD_APPL_LTR
  		WHERE	person_id 		= p_person_id AND
  			admission_appl_number 	= p_admission_appl_number AND
  			correspondence_type 	= p_correspondence_type;
  	v_sequence_number		IGS_AD_APPL_LTR.sequence_number%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	FOR v_aal_rec IN c_aal LOOP
  		IF IGS_AD_GEN_002.ADMP_GET_AAL_SENT_DT(
  				p_person_id,
  				p_admission_appl_number,
  				p_correspondence_type,
  				v_aal_rec.sequence_number) IS NULL THEN
			p_message_name := 'IGS_AD_UNISSUED_LETTER_EXISTS';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AAL.admp_val_aal_exists');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aal_exists;
  --
  -- Validate the correspondence type closed indicator.
  FUNCTION corp_val_cort_closed(
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN
  DECLARE
  	v_closed_ind	IGS_CO_TYPE.closed_ind%TYPE;
  	CURSOR 	c_cort(
  			cp_correspondence_type IGS_CO_TYPE.correspondence_type%TYPE) IS
  		SELECT	cort.closed_ind
  		FROM	IGS_CO_TYPE cort
  		WHERE	cort.correspondence_type = cp_correspondence_type;
  BEGIN
  	--  Validate if the correspondence type is closed
  	p_message_name := null;
  	OPEN	c_cort(
  			p_correspondence_type);
  	FETCH	c_cort INTO v_closed_ind;
  	IF(c_cort%FOUND = FALSE) THEN
  		CLOSE c_cort;
  		RETURN TRUE;
  	END IF;
  	IF(v_closed_ind = 'Y') THEN
  		CLOSE c_cort;
		p_message_name := 'IGS_CO_CORTYPE_IS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cort;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AAL.corp_val_cort_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END;
  END corp_val_cort_closed;

END IGS_AD_VAL_AAL;

/
