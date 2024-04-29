--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_AIEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_AIEM" AS
/* $Header: IGSAS13B.pls 115.5 2002/11/28 22:42:32 nsidana ship $ */

  --
  -- Retrofitted
  FUNCTION assp_val_aiem_catqty(
  p_s_material_cat  IGS_AS_ITM_EXAM_MTRL.s_material_cat%TYPE ,
  p_quantity_per_student  IGS_AS_ITM_EXAM_MTRL.quantity_per_student%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_aiem_catqty
  	-- Validate s_material_cat = 'SUPPLIED' if the quantity_per_student
  	-- is specified.
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	IF (
  		p_s_material_cat <> 'SUPPLIED' AND
  		p_quantity_per_student IS NOT NULL) THEN
  		P_MESSAGE_NAME := 'IGS_AS_SYS_MATCAT_SUPPLIED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_013.assp_val_aiem_catqty');
	IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_aiem_catqty;
  --
  -- Retrofitted
  FUNCTION assp_val_ai_exmnbl(
  p_ass_id  IGS_AS_ASSESSMNT_ITM_ALL.ass_id%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_ai_exmnbl
  	-- Validate the assessment item is examinable.
  DECLARE
  	CURSOR c_atyp IS
  	SELECT	'x'
  	FROM	IGS_AS_ASSESSMNT_TYP	atyp,
  		IGS_AS_ASSESSMNT_ITM	ai
  	WHERE	atyp.assessment_type	= ai.assessment_type	AND
  		ai.ass_id		= p_ass_id		AND
  		atyp.examinable_ind = 'N';
  	v_atyp_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	OPEN c_atyp;
  	FETCH c_atyp INTO v_atyp_exists;
  	IF (c_atyp%FOUND) THEN
  		CLOSE c_atyp;
  		-- The assessment item is not examinable.
  		P_MESSAGE_NAME := 'IGS_AS_ASSITEM_NOT_EXAMINABLE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_atyp;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_013.assp_val_ai_exmnbl');
	IGS_GE_MSG_STACK.ADD;
	--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_ai_exmnbl;
  --
  -- Retrofitted
  FUNCTION assp_val_exmt_closed(
  p_exam_material_type  IGS_AS_EXM_MTRL_TYPE.exam_material_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_exmt_closed
  	-- Validate the exam material type closed indicator.
  DECLARE
  	CURSOR c_exmt IS
  	SELECT	'x'
  	FROM	IGS_AS_EXM_MTRL_TYPE
  	WHERE	exam_material_type	= p_exam_material_type	AND
  		closed_ind = 'Y';
  	v_exmt_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	OPEN c_exmt;
  	FETCH c_exmt INTO v_exmt_exists;
  	IF (c_exmt%FOUND) THEN
  		CLOSE c_exmt;
  		-- Examination material type is closed.
  		P_MESSAGE_NAME := 'IGS_AS_EXAM_MATERIAL_TYPE_CLS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_exmt;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_013.assp_val_exmt_closed');
	IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_exmt_closed;
END IGS_AS_VAL_AIEM;

/
