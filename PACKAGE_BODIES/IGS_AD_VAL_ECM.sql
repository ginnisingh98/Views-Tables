--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ECM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ECM" AS
/* $Header: IGSAD55B.pls 115.4 2002/11/28 21:36:15 nsidana ship $ */
  -- Validate that default enr cat is not closed.
  FUNCTION admp_val_ecm_dflt_2(
  p_enrolment_cat IN VARCHAR2 ,
  p_dflt_cat_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN   -- admp_val_ecm_dflt_2
  	-- Validate if the enrolment category mapping default is not also
  	-- closed
  DECLARE
  	v_message_name			VARCHAR2(30);
  BEGIN
  	p_message_name := null;
  	IF (p_dflt_cat_ind = 'N') THEN
  		RETURN TRUE;
  	END IF;
  	IF (IGS_AD_VAL_ECM.enrp_val_ec_closed(
  			p_enrolment_cat,
  			v_message_name) = FALSE) THEN
		p_message_name := 'IGS_AD_DFLTMAP_CANNOT_CLS_ENR';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_ECM.admp_val_ecm_dflt_2');
		IGS_GE_MSG_STACK.ADD;
  END admp_val_ecm_dflt_2;
  --
  -- Validate that one enr cat is marked as the default for the adm cat.
  FUNCTION admp_val_ecm_dflt_1(
  p_admission_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN   -- ADMP_VAL_ECM_DFLT_1
  	-- Validate that one enrolment category is marked as the default for the
  	-- admission category
  DECLARE
  	cst_no			CONSTANT CHAR := 'N';
  	cst_yes			CONSTANT CHAR := 'Y';
  	cst_error		CONSTANT CHAR := 'E';
  	cst_warn		CONSTANT CHAR := 'W';
  	v_record_found		BOOLEAN DEFAULT FALSE;
  	v_yes_found		BOOLEAN DEFAULT FALSE;
  	CURSOR c_ecm(
  		 cp_admission_cat	IGS_EN_CAT_MAPPING.admission_cat%TYPE)IS
  		SELECT	ecm.dflt_cat_ind
  		FROM	IGS_EN_CAT_MAPPING ecm
  		WHERE	ecm.admission_cat = cp_admission_cat;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	FOR v_dflt_cat_ind IN c_ecm(
  				p_admission_cat) LOOP
  		v_record_found := TRUE;
  		IF (v_dflt_cat_ind.dflt_cat_ind = cst_yes) THEN
  			v_yes_found := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_record_found = FALSE THEN
		p_message_name := 'IGS_AD_NO_ENRCAT_MAPED_ADMCAT';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	IF (v_yes_found = FALSE) THEN
		p_message_name := 'IGS_AD_ONLY_ONE_ENRCAT_MARKED';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	p_return_type := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_ECM.admp_val_ecm_dflt_1');
		IGS_GE_MSG_STACK.ADD;
  END admp_val_ecm_dflt_1;
  --
  -- Validate if the enr cat can be marked as the default for the adm cat.
  FUNCTION admp_val_ecm_dflt(
  p_admission_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN   -- ADMP_VAL_ECM_DFLT
  	-- Validate if the enrolment category can be marked as the default for the
  	-- admission category
  	-- (only one enrolment category can be marked as the default)
  DECLARE
  	v_dflt_cat_ind		IGS_EN_CAT_MAPPING.dflt_cat_ind%TYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  	CURSOR c_ecm(cp_admission_cat		IGS_EN_CAT_MAPPING.admission_cat%TYPE,
  		     cp_enrolment_cat		IGS_EN_CAT_MAPPING.enrolment_cat%TYPE)IS
  		SELECT	ecm.dflt_cat_ind
  		FROM	IGS_EN_CAT_MAPPING ecm
  		WHERE	ecm.admission_cat = cp_admission_cat AND
  			ecm.enrolment_cat <> cp_enrolment_cat AND
  			ecm.dflt_cat_ind = cst_yes;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_ecm(p_admission_cat,
  		   p_enrolment_cat);
  	FETCH c_ecm INTO v_dflt_cat_ind;
  	IF (c_ecm%FOUND) THEN
		p_message_name := 'IGS_AD_ONLY_ONE_ENRCAT_MARKED';
  		CLOSE c_ecm;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ecm;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_ECM.admp_val_ecm_dflt');
		IGS_GE_MSG_STACK.ADD;
  END admp_val_ecm_dflt;
  --
  -- Validate the enrolment category closed indicator
  FUNCTION enrp_val_ec_closed(
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN
  DECLARE
  	v_closed_ind		IGS_EN_ENROLMENT_CAT.closed_ind%TYPE;
  	CURSOR c_closed_ind IS
  		SELECT 	closed_ind
  		FROM		IGS_EN_ENROLMENT_CAT
  		WHERE	enrolment_cat = p_enrolment_cat;
  BEGIN
  	-- This module validates whether the
  	-- enrolment_cat is closed
  	OPEN c_closed_ind;
  	FETCH c_closed_ind INTO v_closed_ind;
  	-- closed_ind is closed
  	IF (v_closed_ind = 'Y') THEN
  		CLOSE c_closed_ind;
		p_message_name := 'IGS_EN_ENR_CAT_CLOSED';
  		RETURN FALSE;
  	ELSE
  		-- closed_ind is not closed
  		CLOSE c_closed_ind;
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_closed_ind;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_ECM.enrp_val_ec_closed');
		IGS_GE_MSG_STACK.ADD;
  END;
  END enrp_val_ec_closed;
  --
  -- Validate if IGS_AD_CAT.admission_cat is closed.

END IGS_AD_VAL_ECM;

/
