--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_AI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_AI" AS
/* $Header: IGSAS11B.pls 115.5 2002/11/28 22:42:00 nsidana ship $ */
  --
  -- Validate the appropriate assessment item details set and are not set
  FUNCTION assp_val_ai_details(
  p_assessment_type IN IGS_AS_ASSESSMNT_ITM_ALL.assessment_type%TYPE ,
  p_exam_scheduled_ind IN IGS_AS_ASSESSMNT_ITM_ALL.exam_scheduled_ind%TYPE ,
  p_exam_working_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_working_time%TYPE ,
  p_exam_announcements IN IGS_AS_ASSESSMNT_ITM_ALL.exam_announcements%TYPE ,
  p_exam_short_paper_name IN IGS_AS_ASSESSMNT_ITM_ALL.exam_short_paper_name%TYPE ,
  p_exam_paper_name IN IGS_AS_ASSESSMNT_ITM_ALL.exam_paper_name%TYPE ,
  p_exam_perusal_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_perusal_time%TYPE ,
  p_exam_supervisor_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_supervisor_instrctn%TYPE ,
  p_exam_allowable_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_allowable_instrctn%TYPE ,
  p_exam_non_allowed_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_non_allowed_instrctn%TYPE ,
  p_exam_supplied_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_supplied_instrctn%TYPE ,
  p_question_or_title IN IGS_AS_ASSESSMNT_ITM_ALL.question_or_title%TYPE ,
  p_ass_length_or_duration IN IGS_AS_ASSESSMNT_ITM_ALL.ass_length_or_duration%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  V_MESSAGE_NAME VARCHAR2(30);
  BEGIN
  DECLARE
  	CURSOR c_atyp(
  			cp_assessment_type		IGS_AS_ASSESSMNT_ITM.assessment_type%TYPE) IS
  		SELECT	examinable_ind
  		FROM	IGS_AS_ASSESSMNT_TYP
  		WHERE	assessment_type = cp_assessment_type;
  	v_atyp_rec				c_atyp%ROWTYPE;
  	cst_yes				CONSTANT CHAR	:= 'Y';
  BEGIN
  	-- Validate the apropriate assessment item details are set/not set
  	-- for the respective assessment type's examinable indicator settings.
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Cursor handling
  	OPEN c_atyp(
  			p_assessment_type);
  	FETCH c_atyp INTO v_atyp_rec;
  	IF c_atyp%NOTFOUND THEN
  		CLOSE c_atyp;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_atyp;
  	IF (v_atyp_rec.examinable_ind = cst_yes) THEN
  		-- Check if any non-exam related fields are set
  		IF (p_question_or_title IS NOT NULL OR
  				p_ass_length_or_duration IS NOT NULL) THEN
  			P_MESSAGE_NAME := 'IGS_AS_ASS_ITEM_DET_CONFLICT';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- Check if any exam related fields are set
  		IF (p_exam_working_time IS NOT NULL OR
  				p_exam_announcements IS NOT NULL OR
  				p_exam_short_paper_name IS NOT NULL OR
  				p_exam_paper_name IS NOT NULL OR
  				p_exam_perusal_time IS NOT NULL OR
  				p_exam_supervisor_instrctn IS NOT NULL OR
  				p_exam_allowable_instrctn IS NOT NULL OR
  				p_exam_non_allowed_instrctn IS NOT NULL OR
  				p_exam_supplied_instrctn IS NOT NULL OR
  				p_exam_scheduled_ind = cst_yes) THEN
  			P_MESSAGE_NAME := 'IGS_AS_ASS_ITEM_DET_CONFLICT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
   END;
  EXCEPTION
  	WHEN OTHERS THEN
  		FND_MESSAGE.SET_NAME('IGS',v_message_name);
             IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_ai_details;
  --
  -- Validate exam times
  FUNCTION assp_val_ai_ex_times(
  p_assessment_type IN IGS_AS_ASSESSMNT_ITM_ALL.assessment_type%TYPE ,
  p_exam_working_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_working_time%TYPE ,
  p_exam_perusal_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_perusal_time%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY  VARCHAR2 )
  RETURN BOOLEAN AS
  V_MESSAGE_NAME VARCHAR2(30);

  BEGIN
  DECLARE
  	CURSOR c_atyp(
  			cp_assessment_type		IGS_AS_ASSESSMNT_ITM.assessment_type%TYPE) IS
  		SELECT	examinable_ind
  		FROM	IGS_AS_ASSESSMNT_TYP
  		WHERE	assessment_type = cp_assessment_type;
  	v_atyp_rec				c_atyp%ROWTYPE;
  	cst_yes			CONSTANT CHAR	:= 'Y';
  	v_exam_working_time			VARCHAR2(10);
  	v_exam_perusal_time			VARCHAR2(10);
  BEGIN
  	-- Validate the exam times if they have been entered.
  	-- Only validate when both times are set.
  	-- Check whether the perusal time is greater than the
  	-- working time and set off an appropriate message.
  	-- Set the default message number
  	P_MESSAGE_NAME := 'NULL';
  	-- Cursor handling
  	OPEN c_atyp(
  			p_assessment_type);
  	FETCH c_atyp INTO v_atyp_rec;
  	IF c_atyp%NOTFOUND THEN
  		CLOSE c_atyp;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_atyp;
  	IF (v_atyp_rec.examinable_ind = cst_yes) THEN
  		IF (p_exam_working_time IS NOT NULL AND
  				p_exam_perusal_time IS NOT NULL) THEN
  			v_exam_perusal_time := SUBSTR(IGS_GE_DATE.IGSCHARDT(p_exam_perusal_time), 12, 5);
  			v_exam_working_time := SUBSTR(IGS_GE_DATE.IGSCHARDT(p_exam_working_time), 12, 5);
  			IF (v_exam_perusal_time >= v_exam_working_time) THEN
  				P_MESSAGE_NAME := 'IGS_AS_PERUSALTIME_LT_WORKTIM';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		FND_MESSAGE.SET_NAME('IGS',v_message_name);
               IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_ai_ex_times;
  --
  -- Validate assessment type closed indicator.
  FUNCTION assp_val_atyp_closed(
  p_assessment_type IN IGS_AS_ASSESSMNT_TYP.assessment_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  V_MESSAGE_NAME VARCHAR2(30);
  BEGIN 	-- assp_val_atyp_closed
  	-- Validate the assessemnt type closed indicator
  DECLARE
  	CURSOR c_atyp(
  			cp_assessment_type	IGS_AS_ASSESSMNT_TYP.assessment_type%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AS_ASSESSMNT_TYP
  		WHERE	assessment_type = cp_assessment_type;
  	v_atyp_rec		c_atyp%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Cursor handling
  	OPEN c_atyp(
  			p_assessment_type);
  	FETCH c_atyp INTO v_atyp_rec;
  	IF c_atyp%NOTFOUND THEN
  		CLOSE c_atyp;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_atyp;
  	IF (v_atyp_rec.closed_ind = cst_yes) THEN
  		P_MESSAGE_NAME := 'IGS_AS_ASSTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		FND_MESSAGE.SET_NAME('IGS',v_message_name);
                    IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_atyp_closed;
  --
  -- Validate updating ass type, does not cause non-unique uai.reference
  FUNCTION ASSP_VAL_AI_TYPE(
  p_ass_id IN NUMBER ,
  p_assessment_type IN VARCHAR2 ,
  p_old_assessment_type IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  V_MESSAGE_NAME VARCHAR2(30);
  BEGIN 	-- ASSP_VAL_AI_TYPE
  	-- This module will be called when the assessment type is being altered for an
  	-- existing assessment item. It will check that when altering the assessment
  	-- type, that no IGS_AS_UNITASS_ITEM records exist within a unitoffering
  	-- pattern that will have the same reference and type.
  DECLARE
  	v_dummy 				VARCHAR2(1);
  	v_atyp_s_ass_type			IGS_AS_ASSESSMNT_TYP.s_assessment_type%TYPE;
  	v_atyp_examinable_ind			IGS_AS_ASSESSMNT_TYP.examinable_ind%TYPE;
  	cst_assignment		CONSTANT 	VARCHAR2(10) := 'ASSIGNMENT';
  	CURSOR c_uai IS
  		SELECT	'x'
  		FROM	IGS_AS_UNITASS_ITEM uai
  		WHERE 	ass_id	= p_ass_id AND
  			EXISTS (
  				SELECT	'x'
  				FROM	IGS_AS_UNITASS_ITEM uai2
  				WHERE	uai2.unit_cd 		= uai.unit_cd AND
  					uai2.version_number 	= uai.version_number AND
  					uai2.cal_type 		= uai.cal_type AND
  					uai2.ci_sequence_number = uai.ci_sequence_number AND
  					uai2.sequence_number 	<> uai.sequence_number AND
  					uai2.reference 		= uai.reference AND
  					uai2.logical_delete_dt 	IS NULL AND
  					EXISTS (
  						SELECT	'x'
  						FROM	IGS_AS_ASSESSMNT_ITM ai
  						WHERE	ai.ass_id 		= uai2.ass_id AND
  							ai.assessment_type 	= p_assessment_type)) AND
  		uai.logical_delete_dt IS NULL;
  	CURSOR c_atyp (	cp_assessment_type	IGS_AS_ASSESSMNT_TYP.assessment_type%TYPE) IS
  		SELECT	atyp.s_assessment_type,
  			atyp.examinable_ind
  		FROM	IGS_AS_ASSESSMNT_TYP atyp
  		WHERE	atyp.assessment_type = cp_assessment_type;
  	CURSOR c_suaai IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_ATMPT_ITM suaai
  		WHERE	ass_id			= p_ass_id AND
  			suaai.logical_delete_dt IS NULL AND
  			suaai.tracking_id 	IS NOT NULL;
  	-- If an examinable item, then reference must be unique across all examinable
  	-- items within the IGS_PS_UNIT offering pattern.
  	CURSOR c_uai2 IS
  		SELECT	'x'
  		FROM	IGS_AS_UNITASS_ITEM uai
  		WHERE 	ass_id	= p_ass_id AND
  			EXISTS (
  				SELECT	'x'
  				FROM	IGS_AS_UNITASS_ITEM uai2,
  					IGS_AS_ASSESSMNT_ITM ai,
  					IGS_AS_ASSESSMNT_TYP atyp
  				WHERE	uai2.unit_cd = uai.unit_cd AND
  					uai2.version_number = uai.version_number AND
  					uai2.cal_type = uai.cal_type AND
  					uai2.ci_sequence_number = uai.ci_sequence_number AND
  					uai2.sequence_number <> uai.sequence_number AND
  					uai2.reference = uai.reference AND
  					uai2.logical_delete_dt IS NULL AND
  					uai2.ass_id = ai.ass_id AND
  					ai.assessment_type = atyp.assessment_type AND
  					atyp.examinable_ind = 'Y');
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	OPEN c_atyp (p_assessment_type);
  	FETCH c_atyp INTO 	v_atyp_s_ass_type,
  				v_atyp_examinable_ind;
  	-- This should never happen!
  	IF c_atyp%NOTFOUND THEN
  		CLOSE c_atyp;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_atyp;
  	IF v_atyp_examinable_ind = 'N' THEN
  		-- If not an examinable item, then check if reference is unique within the
  		-- type.
  		OPEN c_uai;
  		FETCH c_uai INTO v_dummy;
  		IF c_uai%FOUND THEN
  			CLOSE c_uai;
  			P_MESSAGE_NAME := 'IGS_AS_REF_NOT_UNIQUE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_uai;
  	ELSE
  		-- If an examinable item, then reference must be unique across all examinable
  		-- items within the UNIT offering pattern.
  		OPEN c_uai2;
  		FETCH c_uai2 INTO v_dummy;
  		IF c_uai2%FOUND THEN
  			CLOSE c_uai2;
  			P_MESSAGE_NAME := 'IGS_AS_REF_NOT_UNIQUE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_uai2;
  	END IF;
  	-- Verify that if the item is being altered from an assignment type,
  	-- check if tracking exists against the item.
  	OPEN c_atyp (p_old_assessment_type);
  	FETCH c_atyp INTO 	v_atyp_s_ass_type,
  				v_atyp_examinable_ind;
  	-- This should never happen!
  	IF c_atyp%NOTFOUND THEN
  		CLOSE c_atyp;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_atyp;
  	IF NVL(v_atyp_s_ass_type, 'NULL') = cst_assignment THEN
  		-- Determine if a tracking item exists against the item.
  		OPEN c_suaai;
  		FETCH c_suaai INTO v_dummy;
  		IF c_suaai%FOUND THEN
  			CLOSE c_suaai;
  			P_MESSAGE_NAME := 'IGS_AS_CANALT_ASSTYPE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_suaai;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uai%ISOPEN THEN
  			CLOSE c_uai;
  		END IF;
  		IF c_atyp%ISOPEN THEN
  			CLOSE c_atyp;
  		END IF;
  		IF c_suaai%ISOPEN THEN
  			CLOSE c_suaai;
  		END IF;
  		IF c_uai2%ISOPEN THEN
  			CLOSE c_uai2;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		FND_MESSAGE.SET_NAME('IGS',v_message_name);
               IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_ai_type;
  --
  -- Routine to process rowids in a PL/SQL TABLE for the current commit.
  --
  -- Routine to save ai records in a PL/SQL RECORD for current commit.
END IGS_AS_VAL_AI;

/
