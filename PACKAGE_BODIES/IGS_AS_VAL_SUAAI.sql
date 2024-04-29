--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_SUAAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_SUAAI" AS
/* $Header: IGSAS30B.pls 115.11 2003/12/03 08:45:44 ijeddy ship $ */


  -- Val IGS_PS_UNIT assess item applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
  FUNCTION ASSP_VAL_UAI_LOC_UC(
  p_student_location_cd IN VARCHAR2 ,
  p_student_unit_class IN VARCHAR2 ,
  p_student_unit_mode IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS

  BEGIN	-- assp_val_uai_loc_uc
    -- ijeddy, Bug 3201661, Grade Book. Obsoleted
    RETURN TRUE;
  END assp_val_uai_loc_uc;
  --
  -- Validate that date is not after the assessment variation cutoff date.
  --
  -- Validate Assessment Item IGS_PS_COURSE Type restrictions.
  FUNCTION ASSP_VAL_AI_ACOT(
  p_ass_id IN NUMBER ,
  p_course_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_ai_acot
  	-- Validate that if the assessment item is of an examinable type,
  	-- then validate if there exists IGS_AS_COURSE_TYPE records that restrict
  	-- the assessment item to particular IGS_PS_COURSE types.
  DECLARE
  	cst_no			CONSTANT CHAR := 'N';
  	v_rows_exist			BOOLEAN := FALSE;
  	v_valid_item			BOOLEAN := FALSE;
  	v_examinable_ind			IGS_AS_ASSESSMNT_TYP.examinable_ind%TYPE;
  	v_course_type			IGS_AS_COURSE_TYPE.course_type%TYPE;
  	CURSOR c_atyp(
  			cp_ass_id		IGS_AS_ASSESSMNT_ITM.ass_id%TYPE) IS
  		SELECT	atyp.examinable_ind
  		FROM	IGS_AS_ASSESSMNT_TYP atyp,
  			IGS_AS_ASSESSMNT_ITM ai
  		WHERE	ai.ass_id 		= cp_ass_id AND
  			ai.assessment_type 	= atyp.assessment_type;
  	CURSOR c_act(
  			cp_ass_id		IGS_AS_ASSESSMNT_ITM.ass_id%TYPE) IS
  		SELECT	course_type
  		FROM	IGS_AS_COURSE_TYPE
  		WHERE	ass_id = cp_ass_id;
  BEGIN
  	-- Set the default message number
  	p_message_name  := NULL;
  	-- Cursor handling
  	OPEN c_atyp(p_ass_id);
  	FETCH c_atyp INTO v_examinable_ind;
  	IF c_atyp%NOTFOUND THEN
  		CLOSE c_atyp;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_atyp;
  	IF (v_examinable_ind = cst_no) THEN
  		RETURN TRUE;
  	END IF;
  	FOR v_act_rec IN c_act(p_ass_id)
  	LOOP
  		v_rows_exist := TRUE;
  		IF (v_act_rec.course_type = p_course_type) THEN
  			v_valid_item := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_rows_exist THEN
  		IF v_valid_item THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name  := 'IGS_AS_EXAM_ASSITEM_NA';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		RETURN TRUE;
  	END IF;
  END;

  	  END assp_val_ai_acot;
  --
  --
  -- Validate if assessment item completed for discontinued IGS_PS_UNIT.
  FUNCTION ASSP_VAL_ASS_COUNT(
  p_unit_attempt_status IN VARCHAR2 ,
  p_tracking_id IN NUMBER )
  RETURN VARCHAR2 IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_ass_count
  	-- This module will check that if the status is discontinued, determine if the
  	-- assignment has been returned by the student, if it has, then include it
  	-- in the count.
  	-- This module is called from a view suaai_extension_v which is used in the
  	-- report "Assignment Due Date Summary Report".
  DECLARE
  	v_check		CHAR;
  	CURSOR c_trst IS
  		SELECT	'x'
  		FROM	IGS_TR_STEP	trst
  		WHERE	trst.tracking_id		= p_tracking_id AND
  			trst.s_tracking_step_type	= 'ASSIGN-DUE' AND
  			trst.completion_dt IS NOT NULL;
  BEGIN
  	-- Invalid status so do not count this record.
  	IF (p_unit_attempt_status = 'INVALID') THEN
  		RETURN 'N';
  	-- If status is discontinued, determine if the assignment has been returned by
  	-- the student ready for marking.
  	ELSIF (p_unit_attempt_status = 'DISCONTIN') THEN
  		OPEN c_trst;
  		FETCH c_trst INTO v_check;
  		IF (c_trst%FOUND) THEN
  			-- Assignment returned to include it to be counted.
  			CLOSE c_trst;
  			RETURN 'Y';
  		ELSE
  			-- Assignment not to be counted as student has not returned the assignment.
  			CLOSE c_trst;
  			RETURN 'N';
  		END IF;
  		CLOSE c_trst;
  	-- Valid status (ie. COMPLETED, UNCONFIRMED, ENROLLED), include record
  	-- to be counted.
  	ELSE
  		RETURN 'Y';
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_trst%ISOPEN) THEN
  			CLOSE c_trst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
               Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
  	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SUAAI.assp_val_ass_count');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_ass_count;
  --
  -- Validate the attempt number is unique within the student assigment.
  FUNCTION assp_val_suaai_atmpt(
  p_person_id  IGS_AS_SU_ATMPT_ITM.person_id%TYPE ,
  p_course_cd  IGS_AS_SU_ATMPT_ITM.course_cd%TYPE ,
  p_unit_cd  IGS_AS_SU_ATMPT_ITM.unit_cd%TYPE ,
  p_cal_type  IGS_AS_SU_ATMPT_ITM.cal_type%TYPE ,
  p_ci_sequence_number  IGS_AS_SU_ATMPT_ITM.ci_sequence_number%TYPE ,
  p_ass_id  IGS_AS_SU_ATMPT_ITM.ass_id%TYPE ,
  p_creation_dt IN DATE ,
  p_attempt_number  NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN BOOLEAN IS

  BEGIN	-- assp_val_suaai_atmpt
  	-- Validate that the attempt number for a student's assessment item is unique.
  DECLARE
  	v_attempt_number	IGS_AS_SU_ATMPT_ITM.attempt_number%TYPE;
  	CURSOR c_suaai_atmpt_num IS
  		SELECT	suaai.attempt_number
  		FROM	IGS_AS_SU_ATMPT_ITM	suaai
  		WHERE	suaai.person_id		= p_person_id			AND
  			suaai.course_cd		= p_course_cd			AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
  			suaai.uoo_id            = p_uoo_id                      AND
  			suaai.ass_id		= p_ass_id			AND
  			suaai.creation_dt		<> p_creation_dt			AND
  			suaai.attempt_number	= p_attempt_number		AND
  			suaai.logical_delete_dt IS NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name  := NULL;
  	-- Determine if the attempt number is unique within
  	-- the assessment item for the student.
  	OPEN c_suaai_atmpt_num;
  	FETCH c_suaai_atmpt_num INTO v_attempt_number;
  	IF c_suaai_atmpt_num%FOUND THEN
  		CLOSE c_suaai_atmpt_num;
  		p_message_name  := 'IGS_GE_DUPLICATE_VALUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_suaai_atmpt_num;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_suaai_atmpt_num%ISOPEN THEN
  			CLOSE c_suaai_atmpt_num;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	null;
         --Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
--         App_Exception.Raise_Exception;
  END assp_val_suaai_atmpt;
  --
  -- Validate item still applies to student as a uai or part of a pattern.

--ijeddy, Bug 3201661, Grade Book.
  FUNCTION ASSP_VAL_SUAAI_VALID(
  p_person_id IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_ass_id IN NUMBER ,
  p_suaai_logical_delete_dt IN DATE ,
  p_message_name  OUT NOCOPY VARCHAR2 ,
 -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER DEFAULT NULL )
  RETURN BOOLEAN IS

  BEGIN	-- assp_val_suaai_valid
  	-- This module validate IGS_AD_PS_APLINSTUNT unit version.
  DECLARE
  	v_logical_del_dt	IGS_AS_UNTAS_PATTERN.logical_delete_dt%TYPE;
  	v_uapi_dummy		VARCHAR2(1);
  	v_rec_found		BOOLEAN := FALSE;

   -- This cursor is changed by DDEY as a part of bug # 2358821
   -- The Assessment Item can be set at Unit level and the Unit Section Level
   -- this cursor checks if the Assessmsnt Item is stil valid for the Unit Section
   -- or at the Unit level.

     CURSOR c_suv IS
  	   SELECT	uai.logical_delete_dt
  		FROM
                 IGS_EN_SU_ATTEMPT  sua,
                 IGS_AS_UNITASS_ITEM  uai
  		WHERE 	sua.person_id 			= p_person_id 	AND
  			sua.course_cd			= p_course_cd 	AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
			sua.uoo_id                      = p_uoo_id  AND
  			uai.ass_id			= p_ass_id  AND
            	      	sua.unit_cd = uai.unit_cd  AND
			sua.version_number = uai.version_number  AND
			sua.cal_type = uai.cal_type AND
			sua.ci_sequence_number = uai.ci_sequence_number AND
			IGS_AS_VAL_UAI.assp_val_sua_ai_acot(uai.ass_id,
			     sua.person_id,
 			   	 sua.course_cd) = 'TRUE'
          UNION
          SELECT	psuai.logical_delete_dt
  		FROM
                  IGS_EN_SU_ATTEMPT  sua,
                  IGS_PS_UNITASS_ITEM_V  psuai
  		WHERE 	sua.person_id 			= p_person_id 	AND
  			sua.course_cd			= p_course_cd 	AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
  			sua.uoo_id      		= p_uoo_id      AND
  			psuai.ass_id = p_ass_id   AND
	              	sua.uoo_id = psuai.uoo_id  AND
			IGS_AS_VAL_UAI.assp_val_sua_ai_acot(psuai.ass_id,
			     sua.person_id,
 			   	 sua.course_cd) = 'TRUE' ;


  BEGIN
  	p_message_name  := NULL;
  	-- Check if part of a pattern or not, whether the item is still valid.
  	-- There may have been IGS_PS_COURSE restrictions placed on the item.
  	-- Determine if the item is still valid for the student
  	FOR v_suv_rec IN c_suv LOOP
  		IF v_suv_rec.logical_delete_dt IS NOT NULL AND
     			p_suaai_logical_delete_dt IS NULL THEN
  			-- Item has been logically deleted but the item belonging
  			-- to student has not been logically deleted, hence it is
  			-- invalid. Do nothing at this point as there may still
  			-- be records to process and a valid one is yet to be found.
  			NULL;
  		ELSE
  			IF (v_suv_rec.logical_delete_dt IS NULL AND
     				p_suaai_logical_delete_dt IS NULL) OR
    				(p_suaai_logical_delete_dt IS NOT NULL) THEN
  				-- The record is valid or a valid item has been found
  				-- but the student's record has been deleted.
  				v_rec_found := TRUE;
  				EXIT;
  			END IF;
  		END IF;
  	END LOOP;
  	-- Applicable offering options may have changed or IGS_PS_COURSE restriction placed on
  	-- the item, hence the item is no longer valid for the student.
  	IF v_rec_found = FALSE THEN
  		p_message_name   := 'IGS_AS_SUA_ASSITEM_INVALID';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_suv%ISOPEN) THEN
  			CLOSE c_suv;
  		END IF;
  END;

  END assp_val_suaai_valid;

END IGS_AS_VAL_SUAAI;

/
