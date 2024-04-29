--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_APCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_APCS" AS
/* $Header: IGSAD42B.pls 115.8 2002/11/28 21:32:21 nsidana ship $ */
  -- Validate the IGS_AD_PRCS_CAT_STEP.mandatory_step_ind.
  FUNCTION admp_val_apcs_mndtry(
  p_s_admission_step_type IN VARCHAR2 ,
  p_mandatory_step_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
    RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN   -- admp_val_apcs_mndtry
  	-- Validate the admission_process_cat_step.mandatory_step_ind
  DECLARE
  	cst_no				CONSTANT CHAR := 'N';
  	v_step_order_applicable_ind
  			IGS_LOOKUPS_view.step_order_applicable_ind%TYPE;
  	CURSOR c_apcs (
  		cp_s_admission_step_type	IGS_AD_PRCS_CAT_STEP.s_admission_step_type%TYPE) IS
                  SELECT  sasgt.step_order_applicable_ind
                  FROM    IGS_LOOKUPS_view sasgt,
                          IGS_LOOKUPS_view sast
                  WHERE   sasgt.lookup_code = sast.step_group_type AND
                          sast.lookup_code = cp_s_admission_step_type AND
                          sast.lookup_type = 'ADMISSION_STEP_TYPE' AND --2402377
                          sasgt.lookup_Type = 'ADM_STEP_GROUP_TYPE'; --2402377
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	OPEN c_apcs(p_s_admission_step_type);
  	FETCH c_apcs INTO v_step_order_applicable_ind;
  	IF (c_apcs%FOUND) THEN
  		IF (v_step_order_applicable_ind = cst_no) AND
  			(p_mandatory_step_ind = cst_no) THEN
  			p_message_name := 'IGS_AD_MAND_STEP_IND_SETTO_Y';
  			CLOSE c_apcs;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_apcs;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCS.admp_val_apcs_mndtry');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcs_mndtry;
  --
  -- Validate the IGS_AD_PRCS_CAT_STEP.step_order_num.
  FUNCTION admp_val_apcs_order(
  p_s_admission_step_type IN VARCHAR2 ,
  p_step_order_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN   -- admp_val_apcs_order
  	-- Validate the IGS_AD_PRCS_CAT_STEP.step_order_num
  DECLARE
  	cst_no				CONSTANT CHAR := 'N';
  	cst_yes				CONSTANT CHAR := 'Y';
  	v_step_order_num		IGS_LOOKUPS_view.step_type_restriction_num_ind%TYPE;
  	CURSOR c_order(
  		cp_s_admission_step_type	IGS_AD_PRCS_CAT_STEP.s_admission_step_type%TYPE) IS
                  SELECT  sasgt.step_order_applicable_ind
                  FROM    IGS_LOOKUPS_view sasgt,
                          IGS_LOOKUPS_view sast
                  WHERE   sasgt.lookup_code = sast.step_group_type AND
                          sast.lookup_code = cp_s_admission_step_type AND
                          sast.lookup_type = 'ADMISSION_STEP_TYPE' AND --2402377
                          sasgt.lookup_Type = 'ADM_STEP_GROUP_TYPE'; --2402377

  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	OPEN c_order(p_s_admission_step_type);
  	FETCH c_order INTO v_step_order_num;
  	IF (c_order%FOUND) THEN
  		IF (v_step_order_num = cst_yes) AND (p_step_order_num IS NULL) THEN
  			p_message_name := 'IGS_AD_STEPORDER_MUST_VALUE';
  			CLOSE c_order;
  			RETURN FALSE;
  		ELSIF (v_step_order_num = cst_no) AND (p_step_order_num IS NOT NULL) THEN
  			p_message_name := 'IGS_AD_STEPORDER_MUSTNOT_VALU';
  			CLOSE c_order;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_order;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCS.admp_val_apcs_order');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcs_order;
  --
  -- Validate the IGS_AD_PRCS_CAT_STEP.step_type_restriction_num.
  FUNCTION admp_val_apcs_rstrct(
  p_s_admission_step_type IN VARCHAR2 ,
  p_step_type_restriction_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN   -- admp_val_apcs_rstrct
  	-- Validate the IGS_AD_PRCS_CAT_STEP.step_type_restriction_num
  DECLARE
  	cst_no					CONSTANT CHAR := 'N';
  	cst_yes					CONSTANT CHAR := 'Y';
  	v_step_type_rest_num_ind
  			IGS_LOOKUPS_view.step_type_restriction_num_ind%TYPE;
  	CURSOR c_rstrct(
  		cp_s_admission_step_type	IGS_AD_PRCS_CAT_STEP.s_admission_step_type%TYPE) IS
  		SELECT	sast.step_type_restriction_num_ind
  		FROM	IGS_LOOKUPS_view sast
  		WHERE	sast.lookup_code = cp_s_admission_step_type  AND
  		        sast.lookup_Type = 'ADMISSION_STEP_TYPE';
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	OPEN c_rstrct(p_s_admission_step_type);
  	FETCH c_rstrct INTO v_step_type_rest_num_ind;
  	IF (c_rstrct%FOUND) THEN
  		IF (v_step_type_rest_num_ind = cst_yes) AND
  			(p_step_type_restriction_num IS NULL) THEN
  			p_message_name := 'IGS_AD_NUMRES_MUST_HAVE_VALUE';
  			CLOSE c_rstrct;
  			RETURN FALSE;
  		ELSIF (v_step_type_rest_num_ind = cst_no) AND
  			(p_step_type_restriction_num IS NOT NULL) THEN
  			p_message_name := 'IGS_AD_NUMRES_MUSTNOT_VALUE';
  			CLOSE c_rstrct;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_rstrct;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCS.admp_val_apcs_rstrct');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcs_rstrct;
  --
  -- Validate if IGS_AD_CAT.admission_cat is closed.

  --
  -- Validate if s_admission_step_type.s_admission_step_type is closed.
  FUNCTION admp_val_sasty_clsd(
  p_s_admission_step_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN   -- ADMP_VAL_SASTY_CLOSED
  	-- Validate if s_admission_step_type.s_admission_step_type is closed.
  DECLARE
  	v_closed_ind		IGS_LOOKUPS_view.closed_ind%type;
  	CURSOR c_sasty IS
  		SELECT	sasty.closed_ind
  		FROM	IGS_LOOKUPS_view sasty
  		WHERE	sasty.lookup_code = p_s_admission_step_type AND
  		        sasty.lookup_type = 'ADMISSION_STEP_TYPE';
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	OPEN c_sasty;
  	FETCH c_sasty INTO v_closed_ind;
  	IF (c_sasty%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_STEPTYPE_CLOSED';
  			CLOSE c_sasty;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sasty;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCS.admp_val_sasty_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_sasty_clsd;

END IGS_AD_VAL_APCS;

/
