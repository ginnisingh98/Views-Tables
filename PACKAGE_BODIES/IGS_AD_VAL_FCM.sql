--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_FCM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_FCM" AS
/* $Header: IGSAD61B.pls 115.4 2002/11/28 21:37:31 nsidana ship $ */

  --
  -- Validate that default fee cat is not closed.
  FUNCTION admp_val_fcm_dflt_2(
  p_fee_cat IN VARCHAR2 ,
  p_dflt_cat_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- admp_val_fcm_dflt_2
  	-- Validate if the fee category mapping default is not also closed
  DECLARE
	v_message_name VARCHAR2(30);
  BEGIN
  	p_message_name := null;
  	IF (p_dflt_cat_ind = 'N') THEN
  		RETURN TRUE;
  	END IF;
  	IF (IGS_AD_VAL_FCM.finp_val_fc_closed(
  			p_fee_cat,
  			v_message_name) = FALSE) THEN
		p_message_name := 'IGS_AD_DFLTMAP_CANNOT_CLS_FEE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_FCM.admp_val_fcm_dflt_2');
  	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_fcm_dflt_2;
  --
  -- Validate that one fee cat is marked as the default for the adm cat.
  FUNCTION admp_val_fcm_dflt_1(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_FCM_DFLT_1
  	-- Validate that one fee category is marked as the default for the admission
  	-- category
  DECLARE
  	cst_no			CONSTANT CHAR := 'N';
  	cst_yes			CONSTANT CHAR := 'Y';
  	cst_error		CONSTANT CHAR := 'E';
  	cst_warn		CONSTANT CHAR := 'W';
  	v_record_found		BOOLEAN DEFAULT FALSE;
  	v_yes_found		BOOLEAN DEFAULT FALSE;
  	CURSOR c_fcm(
  		 cp_admission_cat	IGS_FI_FEE_CAT_MAP.admission_cat%TYPE)IS
  		SELECT	fcm.dflt_cat_ind
  		FROM	IGS_FI_FEE_CAT_MAP fcm
  		WHERE	fcm.admission_cat = cp_admission_cat;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	FOR v_dflt_cat_ind IN c_fcm(
  				p_admission_cat) LOOP
  		v_record_found := TRUE;
  		IF (v_dflt_cat_ind.dflt_cat_ind = cst_yes) THEN
  			v_yes_found := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_record_found = FALSE THEN
		p_message_name := 'IGS_AD_NO_FEECAT_MAPED_ADMCAT';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	IF (v_yes_found = FALSE) THEN
		p_message_name := 'IGS_AD_ONLY_ONE_FEECAT_MARKED';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	p_return_type := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_FCM.admp_val_fcm_dflt_1');
  	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_fcm_dflt_1;
  --
  -- Validate if the fee cat can be marked as the default for the adm cat.
  FUNCTION admp_val_fcm_dflt(
  p_admission_cat IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_FCM_DFLT
  	-- Validate if the fee category can be marked as the default for the admission
  	-- category
  	-- (only one fee category can be marked as the default)
  DECLARE
  	v_dflt_cat_ind		IGS_FI_FEE_CAT_MAP.dflt_cat_ind%TYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  	CURSOR c_fcm(cp_admission_cat		IGS_FI_FEE_CAT_MAP.admission_cat%TYPE,
  		     cp_fee_cat	IGS_FI_FEE_CAT_MAP.fee_cat%TYPE)IS
  		SELECT	fcm.dflt_cat_ind
  		FROM	IGS_FI_FEE_CAT_MAP fcm
  		WHERE	fcm.admission_cat = cp_admission_cat AND
  			fcm.fee_cat <> cp_fee_cat AND
  			fcm.dflt_cat_ind = cst_yes;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_fcm(p_admission_cat,
  		   p_fee_cat);
  	FETCH c_fcm INTO v_dflt_cat_ind;
  	IF (c_fcm%FOUND) THEN
		p_message_name := 'IGS_AD_ONLY_ONE_FEECAT_MARKED';
  		CLOSE c_fcm;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_fcm;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_FCM.admp_val_fcm_dflt');
  	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_fcm_dflt;
  --
  -- Validate if IGS_FI_FEE_CAT.fee_cat is closed.
 FUNCTION finp_val_fc_closed(
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN --FINP_VAL_FC_CLOSED
        --Validate if IGS_FI_FEE_CAT.fee_cat is closed
  DECLARE
        v_closed_ind IGS_FI_FEE_CAT.closed_ind%type;
        CURSOR c_fc IS
                SELECT  fc.closed_ind
                FROM    IGS_FI_FEE_CAT fc
                WHERE   fc.fee_cat = p_fee_cat;
  BEGIN
        --- Set the default message number
        p_message_name := null;
        OPEN c_fc;
        FETCH c_fc INTO v_closed_ind;
        IF (c_fc%FOUND)THEN
                IF (v_closed_ind = 'Y') THEN
                        p_message_name := 'IGS_FI_FEECAT_CLOSED';
                        CLOSE c_fc;
                        RETURN FALSE;
                END IF;
        END IF;
        CLOSE c_fc;
        RETURN TRUE;
  END;
  EXCEPTION
      WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_FCM.finp_val_fc_closed');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
  END finp_val_fc_closed;


  -- Validate if IGS_AD_CAT.admission_cat is closed.

END IGS_AD_VAL_FCM;

/
