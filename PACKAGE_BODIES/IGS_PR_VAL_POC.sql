--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_POC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_POC" AS
/* $Header: IGSPR16B.pls 115.5 2002/11/29 02:47:57 nsidana ship $ */
  --
  -- Warn if the course does not have an active course version
  FUNCTION prgp_val_crv_active(
  p_course_cd IN CHAR ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- PRGP_VAL_CRV_ACTIVE
  	-- Purpose: Warn the user is the supplied course_cd has no ACTIVE
  	--	course_version records.
  DECLARE
  	v_exists	VARCHAR2(1);
  	CURSOR c_crv_cst IS
  		SELECT	'x'
  		FROM	IGS_PS_VER	crv,
  			IGS_PS_STAT  	cst
  		WHERE	crv.course_cd		= p_course_cd AND
  			crv.course_status	= cst.course_status AND
  			cst.s_course_status	= 'ACTIVE';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_crv_cst;
  	FETCH c_crv_cst INTO v_exists;
  	IF c_crv_cst%NOTFOUND THEN
  		CLOSE c_crv_cst;
  		p_message_name := 'IGS_PR_WA_CRS_CON_NOACT_VER';
  		RETURN TRUE;
  	END IF;
  	CLOSE c_crv_cst;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_crv_cst %ISOPEN THEN
  			CLOSE c_crv_cst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END; -- Function PRGP_VAL_CRV_ACTIVE
  --
  -- Validate that a prg_outcome_course record can be created
  FUNCTION prgp_val_poc_pro(
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_poc_pro
  	-- When creating a Progression Outcome Course record validate that the record
  	-- is related to a  progression_rule_outcome with a progression_outcome_type
  	-- that relates to a s_encmb_effect_type of EXC_COURSE or SUS_COURSE
  DECLARE
  	cst_exc_course	CONSTANT	VARCHAR(10) := 'EXC_COURSE';
  	cst_sus_course	CONSTANT	VARCHAR(10) := 'SUS_COURSE';
  	v_dummy                         VARCHAR2(1);
  	CURSOR c_pro_pot_etde IS
  		SELECT 	'X'
  		FROM		IGS_PR_RU_OU	pro,
  				IGS_PR_OU_TYPE 	pot,
  				IGS_FI_ENC_DFLT_EFT		etde
  		WHERE		pro.progression_rule_cat	= p_progression_rule_cat AND
  				pro.pra_sequence_number		= p_pra_sequence_number AND
  				pro.sequence_number		= p_sequence_number AND
  				pro.progression_outcome_type 	= pot.progression_outcome_type AND
  				pot. encumbrance_type		= etde.encumbrance_type  AND
  				etde.s_encmb_effect_type	IN (
  								cst_exc_course,
  								cst_sus_course);
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_rule_cat IS NULL OR
  			p_pra_sequence_number IS NULL OR
  				p_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pro_pot_etde;
  	FETCH c_pro_pot_etde INTO v_dummy;
  	IF c_pro_pot_etde%NOTFOUND THEN
  		CLOSE c_pro_pot_etde;
                --
		-- kdande; 19-Jul-2002; Bug#2462120
		-- Created a new message IGS_PR_OUT_ENCTY_EXC_SUS_PR for message number 5102.
		--
  		p_message_name := 'IGS_PR_OUT_ENCTY_EXC_SUS_PR';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pro_pot_etde;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pro_pot_etde%ISOPEN THEN
  			CLOSE c_pro_pot_etde;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_poc_pro;
END igs_pr_val_poc;

/
