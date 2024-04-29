--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_POSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_POSP" AS
/* $Header: IGSPS51B.pls 115.4 2002/11/29 03:06:23 nsidana ship $ */

   -- Validate the calendar type is categorised teaching and is not closed.
  FUNCTION crsp_val_posp_cat(
  p_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- crsp_val_posp_cat
  	-- Validate the cal_type is not closed and the s_cal_cat is set to
  	-- 'TEACHING'.
  DECLARE
  	v_cat_closed_ind	IGS_CA_TYPE.closed_ind%TYPE;
  	v_cat_s_cal_cat		IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR c_cat IS
  		SELECT		cat.closed_ind,
  				cat.s_cal_cat
  		FROM		IGS_CA_TYPE		cat
  		WHERE		cat.cal_type 		= p_cal_type;
  BEGIN
  	IF p_cal_type IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		OPEN c_cat;
  		FETCH c_cat INTO 	v_cat_closed_ind,
  				 	v_cat_s_cal_cat;
  		IF (c_cat%FOUND) THEN
  			-- Check if the calendar type is closed
  			IF v_cat_closed_ind = 'Y' THEN
  				CLOSE c_cat;
  				p_message_name:= 'IGS_CA_CALTYPE_CLOSED';
  				RETURN FALSE;
  			END IF;
  			-- Check if the calendar type is of category 'TEACHING'
  			IF v_cat_s_cal_cat <> 'TEACHING' THEN
  				CLOSE c_cat;
  				p_message_name:= 'IGS_PS_CALTYPE_TEACHING_CAL';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_cat;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cat%ISOPEN) THEN
  			CLOSE c_cat;
  		END IF;
  		RAISE;
  END;
  END crsp_val_posp_cat;
  --
  -- Validate future relationship between IGS_CA_TYPE and teach_cal_type.
  FUNCTION crsp_val_posp_cir(
  p_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_teach_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN 	-- crsp_val_posp_cir
  	-- Warn the user if there isn't a relationship between future instances
  	-- of the IGS_CA_TYPE and teach_cal_type, with the teaching calendar as the
  	-- subordinate to the academic calendar.
  DECLARE
  	v_dummy			VARCHAR(1);
  	CURSOR c_cir_ci IS
  		SELECT	'X'
  		FROM	IGS_CA_INST_REL	cir,
  			IGS_CA_INST			ci_sub,
  			IGS_CA_INST			ci_sup
  		WHERE	cir.sub_cal_type		= p_teach_cal_type AND
  			cir.sub_cal_type		= ci_sub.cal_type AND
  			cir.sub_ci_sequence_number	= ci_sub.sequence_number AND
  			ci_sub.end_dt			> SYSDATE AND
  			cir.sup_cal_type		= p_cal_type AND
  			cir.sup_cal_type		= ci_sup.cal_type AND
  			cir.sup_ci_sequence_number	= ci_sup.sequence_number AND
  			ci_sup.end_dt 			> SYSDATE;
  BEGIN
  	IF p_cal_type IS NULL OR
  			p_teach_cal_type IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		-- Check for IGS_CA_INST_REL records where the p_teach_cal_type
  		-- is the sub_cal_type and the p_cal_type is the sup_cal_type and the
  		-- related calendar_instance records have an end date greater than todays
  		-- date
  		OPEN c_cir_ci;
  		FETCH c_cir_ci INTO v_dummy;
  		IF (c_cir_ci%NOTFOUND) THEN
  			CLOSE c_cir_ci;
  			p_message_name := 'IGS_PS_NO_FUTURE_CAL_INST_REL';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_cir_ci;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cir_ci%ISOPEN) THEN
  			CLOSE c_cir_ci;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POSp.crsp_val_posp_cir');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_posp_cir;
  --
  -- Validate pattern of study period record is unique.
  FUNCTION crsp_val_posp_iu(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_pos_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_acad_period_num IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN 	-- crsp_val_posp_iu
  	-- Validate IGS_PS_PAT_STUDY_PRD records. More than one record cannot
  	-- exist with the same academic period number and teaching calendar type
  	-- for a parent IGS_PS_PAT_OF_STUDY.
  DECLARE
  	v_dummy			VARCHAR(1);
  	CURSOR c_posp IS
  		SELECT	'X'
  		FROM	IGS_PS_PAT_STUDY_PRD		posp
  		WHERE	posp.course_cd 			= p_course_cd AND
  			posp.version_number		= p_version_number AND
  			posp.cal_type			= p_cal_type AND
  			posp.pos_sequence_number	= p_pos_sequence_number AND
  			(p_sequence_number  IS NULL OR
  			posp.sequence_number		<> p_sequence_number) AND
  			posp.acad_period_num		= p_acad_period_num AND
  			posp.teach_cal_type		= p_teach_cal_type;
  BEGIN
  	IF p_course_cd 				IS NULL OR
  			p_version_number 	IS NULL OR
  			p_cal_type 		IS NULL OR
  			p_pos_sequence_number 	IS NULL OR
  			p_acad_period_num 	IS NULL OR
  			p_teach_cal_type 	IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		OPEN c_posp;
  		FETCH c_posp INTO v_dummy;
  		IF (c_posp%FOUND) THEN
  			CLOSE c_posp;
  			p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_posp;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_posp%ISOPEN) THEN
  			CLOSE c_posp;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_POSp.crsp_val_posp_iu');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_posp_iu;
  --
END IGS_PS_VAL_POSp;

/
