--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_CCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_CCM" AS
/* $Header: IGSAD48B.pls 115.5 2002/11/28 21:34:36 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cc_closed"
  -------------------------------------------------------------------------------------------


  -- Validate that default correspondence cat is not closed.
  FUNCTION admp_val_ccm_dflt_2(
  p_correspondence_cat IN VARCHAR2 ,
  p_dflt_cat_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN   -- admp_val_ccm_dflt_2
  	-- Validate if the correspondence category mapping default is not also
  	-- closed
 DECLARE
v_message_name			VARCHAR2(30);
  BEGIN
  	p_message_name := null;
  	IF (p_dflt_cat_ind = 'N') THEN
  		RETURN TRUE;
  	END IF;
  	IF (IGS_AD_VAL_ACAI.corp_val_cc_closed(
  			p_correspondence_cat,
  			v_message_name) = FALSE) THEN
  		p_message_name := 'IGS_AD_DFLTMAP_CANNOT_CLS_COR';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_CCM.admp_val_ccm_dflt_2');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ccm_dflt_2;
  --
  -- Validate that one cor cat is marked as the default for the adm cat.
  FUNCTION admp_val_ccm_dflt_1(
  p_admission_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN   -- ADMP_VAL_CCM_DFLT_1
  	-- Validate that one correspondence category is marked as the default for the
  	-- admission category
  DECLARE
  	cst_no			CONSTANT CHAR := 'N';
  	cst_yes			CONSTANT CHAR := 'Y';
  	cst_error		CONSTANT CHAR := 'E';
  	cst_warn		CONSTANT CHAR := 'W';
  	v_record_found		BOOLEAN DEFAULT FALSE;
  	v_yes_found		BOOLEAN DEFAULT FALSE;
  	CURSOR c_ccm(
  		 cp_admission_cat	IGS_CO_CAT_MAP.admission_cat%TYPE)IS
  		SELECT	ccm.dflt_cat_ind
  		FROM	IGS_CO_CAT_MAP ccm
  		WHERE	ccm.admission_cat = cp_admission_cat;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	FOR v_dflt_cat_ind IN c_ccm(
  				p_admission_cat) LOOP
  		v_record_found := TRUE;
  		IF (v_dflt_cat_ind.dflt_cat_ind = cst_yes) THEN
  			v_yes_found := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_record_found = FALSE THEN
  		--p_message_num := 2351;
		p_message_name := 'IGS_AD_NO_CORCAT_MAPED_ADMCAT';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	IF (v_yes_found = FALSE) THEN
  		--p_message_num := 2348;
		p_message_name := 'IGS_AD_ONLY_ONE_CORCAT_MARKED';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	p_return_type := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_CCM.admp_val_ccm_dflt_1');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ccm_dflt_1;
  --
  -- Validate if the cor cat can be marked as the default for the adm cat.
  FUNCTION admp_val_ccm_dflt(
  p_admission_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN   -- ADMP_VAL_CCM_DFLT
  	-- Validate if the correspondence category can be marked as the default for the
  	--  admission category
  	-- (only one correspondence category can be marked as the default)
  DECLARE
  	v_dflt_cat_ind		IGS_CO_CAT_MAP.dflt_cat_ind%TYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  	CURSOR c_ccm(cp_admission_cat		IGS_CO_CAT_MAP.admission_cat%TYPE,
  		cp_correspondence_cat	IGS_CO_CAT_MAP.correspondence_cat%TYPE) IS
  		SELECT	ccm.dflt_cat_ind
  		FROM	IGS_CO_CAT_MAP ccm
  		WHERE	ccm.admission_cat = cp_admission_cat AND
  			ccm.correspondence_cat <> cp_correspondence_cat AND
  			ccm.dflt_cat_ind = cst_yes;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_ccm(p_admission_cat,
  		   p_correspondence_cat);
  	FETCH c_ccm INTO v_dflt_cat_ind;
  	IF (c_ccm%FOUND) THEN
  		--p_message_num := 2348;
		p_message_name := 'IGS_AD_ONLY_ONE_CORCAT_MARKED';
  		CLOSE c_ccm;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ccm;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_CCM.admp_val_ccm_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ccm_dflt;


END IGS_AD_VAL_CCM;

/
