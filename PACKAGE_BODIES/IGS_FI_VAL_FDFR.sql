--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FDFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FDFR" AS
/* $Header: IGSFI28B.pls 115.4 2002/11/29 00:20:49 nsidana ship $ */
  --
  -- Validate if the IGS_RU_CALL.s_rule_call_cd and s_rule_type_cd
  FUNCTION rulp_val_rul_src(
  p_s_rule_call_cd IN IGS_RU_CALL.s_rule_call_cd%TYPE ,
  p_s_rule_type_cd IN IGS_RU_CALL.s_rule_type_cd%TYPE ,
  p_sequence_number IN IGS_RU_RULE.sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- rulp_val_rul_src
  	-- * Validate the s_rule_call_cd has the s_rule_type_cd specified.
  	-- * Validate the IGS_RU_RULE identified by rul_sequence_number is related
  	--   to the IGS_RU_CALL record with the specified s_rule_call_cd
  	--   and s_rule_type
  DECLARE
  	CURSOR c_src IS
  		SELECT	'x'
  		FROM	IGS_RU_CALL
  		WHERE	s_rule_call_cd	= p_s_rule_call_cd AND
  			s_rule_type_cd	= p_s_rule_type_cd;
  	v_c_src_exists		VARCHAR2(1) DEFAULT NULL;
  BEGIN
  	p_message_name := NULL;
  	-- check parameters
  	IF p_s_rule_call_cd IS NULL OR
  			p_s_rule_type_cd IS NULL OR
  			p_sequence_number IS NULL THEN
  		-- parameters are invalid
  		RETURN TRUE;
  	END IF;
  	-- Check if the IGS_RU_CALL.s_rule_call_cd has the
  	-- s_rule_type_cd specified.
  	OPEN c_src;
  	FETCH c_src INTO v_c_src_exists;
  	IF (c_src%NOTFOUND) THEN
  		CLOSE c_src;
  		p_message_name := 'IGS_PS_SYSRULE_CALL_CODE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_src;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_src%ISOPEN) THEN
  			CLOSE c_src;
  		END IF;
 		RAISE;
  END;
  END rulp_val_rul_src;
END IGS_FI_VAL_FDFR;

/
