--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_PRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_PRA" AS
/* $Header: IGSPR04B.pls 115.5 2002/11/29 02:44:31 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_OU_ACTIVE) - from the spec and body. -- kdande
*/
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_att_closed
  --
  --
  -- Validate the IGS_PR_RU_APPL record.
  FUNCTION prgp_val_pra_rqrd(
  p_s_relation_type IN VARCHAR2 ,
  p_progression_rule_cd IN VARCHAR2 ,
  p_rul_sequence_number IN NUMBER ,
  p_ou_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_course_type IN VARCHAR2 ,
  p_crv_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_sca_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_pro_progression_rule_cat IN VARCHAR2 ,
  p_pro_pra_sequence_number IN NUMBER ,
  p_pro_sequence_number IN NUMBER ,
  p_spo_person_id IN NUMBER ,
  p_spo_course_cd IN VARCHAR2 ,
  p_spo_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prg_val_pra_rqrd
  	-- Check that the IGS_PR_RU_APPL record does not have both
  	-- progression_rule_cd and rul_sequence_number set and has the required
  	-- information entered for the s_relation_type.
  DECLARE
  BEGIN
  	IF p_s_relation_type IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	-- Check both progression_rule_cd and rul_sequence_number are not set
  	IF p_progression_rule_cd IS NOT NULL AND
  	   p_rul_sequence_number IS NOT NULL THEN
  		p_message_name := 'IGS_PR_BTH_RUL_CD_SEQ_NO_NA';
  		RETURN FALSE;
  	END IF;
  	-- Check one of either progression_rule_cd and rul_sequence_number are set
  	IF p_progression_rule_cd IS NULL AND
  	    p_rul_sequence_number IS NULL AND
  	    p_s_relation_type <> 'PRGC' AND
  	    p_s_relation_type <> 'PRR' THEN
  		p_message_name := 'IGS_PR_ENTER_PRG_RULE_SEQ_NO.';
  		RETURN FALSE;
  	END IF;
  	-- Check that the record has valid values for the s_relation_type specified.
  	IF p_s_relation_type = 'PRGC' THEN
  		IF p_progression_rule_cd IS NOT NULL OR
  				p_rul_sequence_number IS NOT NULL THEN
  			p_message_name := 'IGS_PR_CHK_WHEN_LNK_TO_PRG_RU';
  			RETURN FALSE;
  		END IF;
  	ELSIF p_s_relation_type = 'PRR' THEN
  		IF p_progression_rule_cd IS NULL OR
  				p_rul_sequence_number IS NOT NULL THEN
  			p_message_name := 'IGS_PR_RUL_MUST_BE_ENTERED';
  			RETURN FALSE;
  		END IF;
  	ELSIF p_s_relation_type = 'CTY' THEN
  		IF p_course_type IS NULL THEN
  			p_message_name := 'IGS_GE_MANDATORY_FLD';
  			RETURN FALSE;
  		END IF;
  	ELSIF p_s_relation_type = 'OU' THEN
  		IF p_ou_org_unit_cd IS NULL OR
  				p_ou_start_dt IS NULL THEN
  			p_message_name := 'IGS_PR_ORG_UNIT_ST_DT_NOT_NUL';
  			RETURN FALSE;
  		END IF;
  	ELSIF p_s_relation_type = 'CRV' THEN
  		IF p_crv_course_cd IS NULL OR
  				p_crv_version_number IS NULL THEN
  			p_message_name := 'IGS_GE_MANDATORY_FLD';
  			RETURN FALSE;
  		END IF;
  	ELSIF p_s_relation_type = 'SCA' THEN
  		IF p_sca_person_id IS NULL OR
  				p_sca_course_cd IS NULL THEN
  			p_message_name := 'IGS_PR_PERSID_COUR_CD_NOT_NUL';
  			RETURN FALSE;
  		END IF;
  	ELSIF p_s_relation_type = 'PRO' THEN
  		IF p_pro_progression_rule_cat IS NULL OR
  				p_pro_pra_sequence_number IS NULL OR
  				p_pro_sequence_number IS NULL THEN
  			p_message_name := 'IGS_PR_CHK_PRA_PRC_SEQ_NUMBER';
  			RETURN FALSE;
  		END IF;
  	ELSIF p_s_relation_type = 'SPO' THEN
  		IF p_spo_person_id IS NULL OR
  				p_spo_course_cd IS NULL OR
  				p_spo_sequence_number IS NULL THEN
  			p_message_name := 'IGS_PR_PERID_CC_SEQNO_NOT_NUL';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRA.PRGP_VAL_PRA_RQRD');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_pra_rqrd;
  --
  -- Validate that the IGS_PR_RU_CAT is not closed.
  FUNCTION prgp_val_prgc_closed(
  p_progression_rule_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_prgc_closed
  	-- Validate the IGS_PR_RU_CAT is not closed
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_prgc IS
  		SELECT	'X'
  		FROM	IGS_PR_RU_CAT	prgc
  		WHERE	prgc.progression_rule_cat = p_progression_rule_cat AND
  			prgc.closed_ind = 'N';
  BEGIN
  	IF p_progression_rule_cat IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	OPEN c_prgc;
  	FETCH c_prgc INTO v_dummy;
  	IF c_prgc%NOTFOUND THEN
  		CLOSE c_prgc;
  		p_message_name := 'IGS_PR_RULE_CAT_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_prgc;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_prgc%ISOPEN) THEN
  			CLOSE c_prgc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRA.PRGP_VAL_PRGC_CLOSED');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_prgc_closed;
  --
  -- Validate that the IGS_PR_RULE is not closed.
  FUNCTION prgp_val_prr_closed(
  p_progression_rule_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_prr_closed
  	-- Validate the IGS_PR_RULE is not closed
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_prr IS
  		SELECT	'X'
  		FROM	IGS_PR_RULE	prr
  		WHERE	prr.progression_rule_cd = p_progression_rule_cd AND
  			prr.closed_ind = 'N';
  BEGIN
  	IF p_progression_rule_cd IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	OPEN c_prr;
  	FETCH c_prr INTO v_dummy;
  	IF c_prr%NOTFOUND THEN
  		CLOSE c_prr;
  		p_message_name := 'IGS_PR_RULE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_prr;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_prr%ISOPEN) THEN
  			CLOSE c_prr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRA.PRGP_VAL_PRR_CLOSED');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_prr_closed;
  --
  -- Validate the IGS_PS_COURSE version is active.
  FUNCTION crsp_val_crv_active(
  p_course_cd IN IGS_PS_VER_ALL.course_cd%TYPE ,
  p_version_number IN IGS_PS_VER_ALL.version_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- crsp_val_crv_active
  	-- Validate the IGS_PS_VER is ACTIVE
  DECLARE
  	cst_active	CONSTANT	IGS_PS_STAT.s_course_status%TYPE := 'ACTIVE';
  	v_dummy		VARCHAR2(1);
  	CURSOR c_crv_crst IS
  		SELECT 	'X'
  		FROM	IGS_PS_VER	cst,
  			IGS_PS_STAT	crst
  		WHERE	cst.course_cd		= p_course_cd AND
  			cst.version_number	= p_version_number AND
  			cst.course_status	= crst.course_status AND
  			crst.s_course_status	= cst_active;
  BEGIN
  	IF p_course_cd IS NOT NULL AND
  			p_version_number IS NOT NULL THEN
  		OPEN c_crv_crst;
  		FETCH c_crv_crst INTO v_dummy;
  		IF (c_crv_crst%NOTFOUND) THEN
  			CLOSE c_crv_crst;
  			p_message_name := 'IGS_PS_CHG_CANNOT_BEMADE_PRG';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_crv_crst;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_crv_crst%ISOPEN) THEN
  			CLOSE c_crv_crst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRA.CRSP_VAL_CRV_ACTIVE');
                --IGS_GE_MSG_STACK.ADD;

  END crsp_val_crv_active;
END IGS_PR_VAL_PRA;

/
