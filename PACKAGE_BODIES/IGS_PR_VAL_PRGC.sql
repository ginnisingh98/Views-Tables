--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_PRGC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_PRGC" AS
/* $Header: IGSPR06B.pls 115.3 2002/11/29 02:45:01 nsidana ship $ */
  --
  -- Validate the IGS_PR_RU_CAT.s_rule_call_cd field.
  FUNCTION prgp_val_src_prg(
  p_s_rule_call_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_src_prg
  	-- Validate the IGS_PR_RU_CAT.s_rule_call_cd field can
  	-- only be linked to IGS_RU_CALL records with a s_rule_type_cd of 'PRG'.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_src IS
  		SELECT	'X'
  		FROM	IGS_RU_CALL	src
  		WHERE	src.s_rule_call_cd = p_s_rule_call_cd AND
  			src.s_rule_type_cd = 'PRG';
  BEGIN
  	IF p_s_rule_call_cd IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	OPEN c_src;
  	FETCH c_src INTO v_dummy;
  	IF c_src%NOTFOUND THEN
  		CLOSE c_src;
  		p_message_name := 'IGS_PR_CHK_SYSTEM_RULE_CALL';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_src;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_src%ISOPEN) THEN
  			CLOSE c_src;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRGC.PRGP_VAL_SRC_PRG');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_src_prg;
  --
  -- Validate the IGS_PR_RU_CAT.s_rule_call_cd.
  FUNCTION prgp_val_prgc_upd(
  p_progression_rule_cat IN VARCHAR2 ,
  p_old_s_rule_call_cd IN VARCHAR2 ,
  p_new_s_rule_call_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_prgc_upd
  	-- Validate the IGS_PR_RU_CAT.s_rule_call_cd can only be updated if
  	-- there are no IGS_PR_RULE or IGS_PR_RU_APPL records linked to
  	-- this IGS_PR_RU_CAT.
  DECLARE
  	v_dummy				VARCHAR2(1);
  	CURSOR c_prr IS
  		SELECT	'X'
  		FROM	IGS_PR_RULE		prr
  		WHERE	prr.progression_rule_cat	= p_progression_rule_cat;
  	CURSOR c_pra IS
  		SELECT	'X'
  		FROM	IGS_PR_RU_APPL		pra
  		WHERE	pra.progression_rule_cat = p_progression_rule_cat AND
  			pra.rul_sequence_number 	IS NOT NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_rule_cat IS NULL OR
  			p_old_s_rule_call_cd IS NULL OR
  			p_new_s_rule_call_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- If the s_rule_call_cd has been changed
  	IF p_old_s_rule_call_cd <>
  			p_new_s_rule_call_cd THEN
  		-- Check for any IGS_PR_RULE records using this IGS_PR_RU_CAT
  		OPEN c_prr;
  		FETCH c_prr INTO v_dummy;
  		IF c_prr%FOUND THEN
  			CLOSE c_prr;
  			p_message_name := 'IGS_PR_RUL_RECORD_IN_USE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_prr;
  		-- Check for any IGS_PR_RU_APPL records using this
  		-- progression_rule_cat
  		OPEN c_pra;
  		FETCH c_pra INTO v_dummy;
  		IF c_pra%FOUND THEN
  			CLOSE c_pra;
  			p_message_name := 'IGS_PR_RUL_APPL_REC_IN_USE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_pra;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_prr%ISOPEN THEN
  			CLOSE c_prr;
  		END IF;
  		IF c_pra%ISOPEN THEN
  			CLOSE c_pra;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRGC.PRGP_VAL_PRGC_UPD');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_prgc_upd;
END IGS_PR_VAL_PRGC;

/
