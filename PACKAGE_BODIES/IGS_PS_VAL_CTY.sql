--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CTY" AS
 /* $Header: IGSPS37B.pls 115.4 2003/06/09 05:08:06 smvk ship $ */

  --
  -- Validate IGS_PS_COURSE type government IGS_PS_COURSE type.
  FUNCTION crsp_val_cty_govt(
  p_govt_course_type IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_TYPE.closed_ind%TYPE;
  	CURSOR	c_govt_course_type IS
  		SELECT closed_ind
  		FROM   IGS_PS_GOVT_TYPE
  		WHERE  govt_course_type = p_govt_course_type;
  BEGIN
  	OPEN c_govt_course_type;
  	FETCH c_govt_course_type INTO v_closed_ind;
  	IF c_govt_course_type%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_govt_course_type;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_govt_course_type;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_GOVT_PRGTYPE_CLOSED';
  		CLOSE c_govt_course_type;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CTY.crsp_val_cty_govt');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_cty_govt;
  --
  -- Validate IGS_PS_COURSE type IGS_PS_COURSE type group code.
  FUNCTION crsp_val_cty_group(
  p_course_type_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_TYPE_GRP.closed_ind%TYPE;
  	CURSOR	c_course_type_group IS
  		SELECT closed_ind
  		FROM   IGS_PS_TYPE_GRP
  		WHERE  course_type_group_cd = p_course_type_group_cd;
  BEGIN
  	OPEN c_course_type_group;
  	FETCH c_course_type_group INTO v_closed_ind;
  	IF c_course_type_group%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_course_type_group;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_course_type_group;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_PRGTYPE_GRPCD_CLOSED';
  		CLOSE c_course_type_group;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CTY.crsp_val_cty_group');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_cty_group;
  --
  -- Validate IGS_PS_COURSE type IGS_PS_AWD IGS_PS_COURSE indicator.
  FUNCTION crsp_val_cty_award(
  p_course_type IN VARCHAR2 ,
  p_award_course_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              :
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_sel_course_award to select open program awards only.
   ***************************************************************/

  	v_check			CHAR;
  	CURSOR c_sel_course_award IS
  		SELECT	'x'
  		FROM	IGS_PS_VER	cv,
  			IGS_PS_AWARD	ca
  		WHERE	course_type	= p_course_type		AND
  			cv.course_cd	= ca.course_cd		AND
  			cv.version_number	= ca.version_number AND
                        ca.closed_ind = 'N';
  BEGIN
  	IF (p_award_course_ind = 'N') THEN
  		OPEN c_sel_course_award;
  		FETCH c_sel_course_award INTO v_check;
  		-- no IGS_PS_AWARD record should exist for
  		-- IGS_PS_VER that have current IGS_PS_TYPE
  		IF c_sel_course_award%FOUND THEN
  			CLOSE c_sel_course_award;
  			p_message_name := 'IGS_PS_AWARD_PRG_NOTSET_N';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_sel_course_award;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CTY.crsp_val_cty_award');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_cty_award;
END IGS_PS_VAL_CTY;

/
