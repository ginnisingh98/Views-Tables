--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_PRR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_PRR" AS
/* $Header: IGSPR07B.pls 115.4 2002/11/29 02:45:21 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_PRGC_CLOSED) - from the spec and body. -- kdande
*/
  --
  -- Validate that a IGS_PR_RULE can be changed.
  FUNCTION prgp_val_prr_upd(
  p_progression_rule_cat IN VARCHAR2 ,
  p_progression_rule_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_prr_upd
  	-- Warn the user if a IGS_PR_RULE is being changed and it
  	-- is linked to a IGS_PR_RU_APPL for a s_relation_type
  	-- other than PRR or PRGC.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_pra IS
  		SELECT	'X'
  		FROM	IGS_PR_RU_APPL	pra
  		WHERE	pra.progression_rule_cat = p_progression_rule_cat
  		AND	pra.progression_rule_cd = p_progression_rule_cd
  		AND	pra.s_relation_type NOT IN ('PRR', 'PRGC');
  BEGIN
  	IF p_progression_rule_cd IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	OPEN c_pra;
  	FETCH c_pra INTO v_dummy;
  	IF c_pra%FOUND THEN
  		CLOSE c_pra;
  		p_message_name := 'IGS_PR_RULE_LNK_TO_MORE_RULES';
  		RETURN TRUE;
  	END IF;
  	CLOSE c_pra;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_pra%ISOPEN) THEN
  			CLOSE c_pra;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRR.PRGP_VAL_PRR_UPD');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_prr_upd;
END IGS_PR_VAL_PRR;

/
