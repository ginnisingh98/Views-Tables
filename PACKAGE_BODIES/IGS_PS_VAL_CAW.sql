--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CAW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CAW" AS
/* $Header: IGSPS17B.pls 115.4 2002/11/29 02:57:29 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function GRDP_VAL_AWARD_TYPE removed.
  --                            Also call to IGS_PS_VAL_CAW.grdp_val_award_type is replaced by
  --                            IGS_GR_VAL_AWC.GRDP_VAL_AWARD_TYPE
  --avenkatr    30-AUG-2001     Bug No 1956374. Removed function "crsp_val_aw_closed"
  --avenkatr    30-AUG-2001     Bug No 1956374. Removed function "crsp_val_cfos_caw"
  -------------------------------------------------------------------------------------------
  -- Validate the IGS_PS_COURSE IGS_PS_AWD - IGS_PS_AWD code.
  FUNCTION crsp_val_caw_award(
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	-- check the IGS_PS_AWD is open
  	IF IGS_gr_val_awc.crsp_val_aw_closed(
  			p_award_cd,
  			p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	-- validate the system IGS_PS_AWD type is IGS_PS_COURSE
  	IF igs_gr_val_awc.grdp_val_award_type(
  			p_award_cd,
  			'COURSE',
  			p_message_name) = FALSE THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CAW.crsp_val_caw_award');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_caw_award;
  --
  --
  -- Validate an insert on the IGS_PS_COURSE IGS_PS_AWD table.
  FUNCTION crsp_val_caw_insert(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_award_crs_ind		IGS_PS_TYPE.award_course_ind%TYPE;
  	CURSOR c_get_award_crs_ind IS
  		SELECT	award_course_ind
  		FROM	IGS_PS_VER,
  			IGS_PS_TYPE
  		WHERE	course_cd		= p_course_cd		AND
  			version_number		= p_version_number	AND
  			IGS_PS_VER.course_type	= IGS_PS_TYPE.course_type;
  BEGIN
  	OPEN c_get_award_crs_ind;
  	FETCH c_get_award_crs_ind INTO v_award_crs_ind;
  	IF (c_get_award_crs_ind%FOUND) THEN
  		CLOSE c_get_award_crs_ind;
  		-- validate the insert of IGS_PS_AWARD record
  		IF (v_award_crs_ind <> 'Y') THEN
  			p_message_name := 'IGS_PS_PRGAWARD_MAYNOT_CREAT';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_get_award_crs_ind;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CAW.crsp_val_caw_insert');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_caw_insert;
END IGS_PS_VAL_CAW;

/
