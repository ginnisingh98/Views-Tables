--------------------------------------------------------
--  DDL for Package Body IGS_AV_VAL_ASAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_VAL_ASAU" AS
/* $Header: IGSAV03B.pls 115.4 2002/11/28 22:52:45 nsidana ship $ */

  -- To validate the advanced standing alternate units.
  FUNCTION advp_val_alt_unit(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version IN NUMBER ,
  p_adv_stnd_type IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_version IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
      -- advp_val_alt_unit
  	-- Validate that alternate units can only be specified if the
  	-- s_adv_stnd_recognition_type of the parent IGS_AV_STND_UNIT record is 'PRECLUDE'
  DECLARE
  	v_ret_val	BOOLEAN DEFAULT TRUE;
  	v_check		CHAR;
  	CURSOR	c_chk_adv_stnd_recog_type IS
  		SELECT	'x'
  		FROM	IGS_AV_STND_UNIT
  		WHERE	person_id	 		= p_person_id		AND
  			as_course_cd		= p_course_cd		AND
  			as_version_number 	= p_course_version	AND
  			s_adv_stnd_type		= p_adv_stnd_type		AND
  			unit_cd			= p_unit_cd			AND
  			version_number		= p_unit_version		AND
  			s_adv_stnd_recognition_type	= 'PRECLUSION';
  BEGIN
  	 p_message_name := null;
  	-- Validate input parameters
  	IF (p_person_id IS NULL OR
  			p_course_cd		IS NULL OR
  			p_course_version	IS NULL OR
  			p_adv_stnd_type		IS NULL OR
  			p_unit_cd		IS NULL OR
  			p_unit_version		IS NULL) 	THEN
  		RETURN TRUE;
  	END IF;
  	-- Determine the recognition type of the appropriate IGS_AV_STND_UNIT record
  	OPEN c_chk_adv_stnd_recog_type;
  	FETCH c_chk_adv_stnd_recog_type INTO v_check;
  	IF (c_chk_adv_stnd_recog_type%NOTFOUND) THEN
  		-- Alternate units cannot be recorded, report an error
  		 p_message_name  := 'IGS_AV_CANREC_TYPE_PRECLUDE';
  		v_ret_val := FALSE;
  	END IF;
  	CLOSE c_chk_adv_stnd_recog_type;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_AV_VAL_AS.ADVP_VAL_ALT_UNIT');
                Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END advp_val_alt_unit;
  --
  -- To validate the precluded and alternate units.
  FUNCTION advp_val_prclde_unit(
  p_precluded_unit_cd IN VARCHAR2 ,
  p_alternate_unit_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- advp_val_preclude_unit1
  	-- Validate that the alternate units are different from the precluded
  	-- IGS_PS_UNIT they are associated with
  DECLARE
  BEGIN
   p_message_name := null;
  	-- Validate input parameters
  	IF (p_precluded_unit_cd IS NULL OR
  			p_alternate_unit_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate that the precluded and alternate units are different
  	IF (p_precluded_unit_cd = p_alternate_unit_cd) THEN
  		 p_message_name := 'IGS_AV_ALTUNIT_DIFF_UNITASSOC';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
             Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
             Fnd_Message.Set_Token('NAME','IGS_AV_VAL_AS.ADVP_VAL_PRCLDE_UNIT');
             Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END advp_val_prclde_unit;
END IGS_AV_VAL_ASAU;

/
