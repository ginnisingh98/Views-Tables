--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CST" AS
 /* $Header: IGSPS36B.pls 115.4 2002/11/29 03:02:26 nsidana ship $ */

  ----------------------------------------------------------------------------
  --  Change History :
  --  Who             When            What
  -- avenkatr    30-AUG-2001   Bug Id 1956374. Removed procedure "crsp_val_iud_crv_dtl"
  ----------------------------------------------------------------------------

  -- Validate if the IGS_PS_COURSE stage type is unique for this IGS_PS_COURSE version
  FUNCTION crsp_val_cst_cstt(
  p_course_cd IN IGS_PS_STAGE.course_cd%TYPE ,
  p_version_number IN IGS_PS_STAGE.version_number%TYPE ,
  p_sequence_number IN IGS_PS_STAGE.sequence_number%TYPE ,
  p_course_stage_type IN IGS_PS_STAGE.course_stage_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_cst_cstt
  	-- Validate that the IGS_PS_STAGE_TYPE is unique for
  	-- IGS_PS_STAGE records for the same IGS_PS_VER.
  DECLARE
  	CURSOR	c_cst IS
  		SELECT	'x'
  		FROM	IGS_PS_STAGE
  		WHERE	course_cd		= p_course_cd AND
  			version_number		= p_version_number AND
  			sequence_number		<> NVL(p_sequence_number, -1) AND
  			course_stage_type	= p_course_stage_type;
  	v_c_cst_exists		VARCHAR2(1) DEFAULT NULL;
  BEGIN
  	p_message_name := NULL;
  	-- Check parameters
  	IF p_course_cd IS NULL OR
  			p_version_number IS NULL OR
  			p_course_stage_type IS NULL THEN
  		--parameters are invalid
  		RETURN TRUE;
  	END IF;
  	-- Check that no record exists for the same IGS_PS_VER
  	-- with the same course_cd.
  	OPEN c_cst;
  	FETCH c_cst INTO v_c_cst_exists;
  	IF (c_cst%FOUND) THEN
  		CLOSE c_cst;
  		p_message_name := 'IGS_PS_PRG_STAGETYOE_UNIQUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cst;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cst%ISOPEN) THEN
  			CLOSE c_cst;
  		END IF;
  		APP_EXCEPTION.RAISE_EXCEPTION;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CST.crsp_val_cst_cstt');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
END crsp_val_cst_cstt;
  --
  -- Validate the IGS_PS_COURSE stage type closed indicator.
  FUNCTION crsp_val_cstt_closed(
  p_course_stage_type IN IGS_PS_STAGE_TYPE.course_stage_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_cstt_closed
  	-- Validate the IGS_PS_COURSE stage type closed indicator
  DECLARE
  	v_closed_ind		IGS_PS_STAGE_TYPE.closed_ind%TYPE;
  	CURSOR c_cstt IS
  		SELECT	closed_ind
  		FROM	IGS_PS_STAGE_TYPE
  		WHERE	course_stage_type = p_course_stage_type;
  BEGIN
  	OPEN c_cstt;
  	FETCH c_cstt INTO v_closed_ind;
  	IF (c_cstt%NOTFOUND) THEN
  		CLOSE c_cstt;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cstt;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_STAGE_TYPE_STATUS_CLOS';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cstt%ISOPEN) THEN
  			CLOSE c_cstt;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CST.crsp_val_cstt_closed');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_cstt_closed;

END IGS_PS_VAL_CST;

/
