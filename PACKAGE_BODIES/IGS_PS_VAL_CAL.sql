--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CAL" AS
/* $Header: IGSPS14B.pls 115.5 2002/11/29 02:56:45 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_strt_end_dt removed
  -------------------------------------------------------------------------------------------

  -- Validate there are IGS_PS_COURSE annual load IGS_PS_UNIT links to copy.
  FUNCTION crsp_val_calul_copy(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_yr_num IN NUMBER ,
  p_effective_start_dt IN DATE )
  RETURN BOOLEAN AS
  	gv_effective_start_dt	IGS_PS_ANL_LOAD.effective_start_dt%TYPE	DEFAULT NULL;
  	gv_result		CHAR;
  	CURSOR	c_find_cal IS
  		SELECT	MAX(effective_start_dt)
  		FROM	IGS_PS_ANL_LOAD
  		WHERE	course_cd 			= p_course_cd		AND
  			version_number			= p_version_number	AND
  			yr_num 			= p_yr_num		AND
  			effective_start_dt 		< p_effective_start_dt;
  	CURSOR	c_find_calul IS
  		SELECT	'x'
  		FROM	IGS_PS_ANL_LOAD_U_LN
  		WHERE	course_cd 			= p_course_cd		AND
  			crv_version_number		= p_version_number	AND
  			yr_num 			= p_yr_num		AND
  			effective_start_dt 		= gv_effective_start_dt;
  BEGIN
  	--- This cursor gets the most recent effective start date.  If one is not found
  	--- then return FALSE.
  	OPEN c_find_cal;
  	FETCH c_find_cal INTO gv_effective_start_dt;
  	IF gv_effective_start_dt IS NULL THEN
  		CLOSE c_find_cal;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_find_cal;
  	--- This is cursor checks for the existance of a IGS_PS_COURSE annual load IGS_PS_UNIT link
  	--- based on the most recent effective start date found previously and returns
  	--- TRUE if at least one is retrieved.
  	OPEN c_find_calul;
  	FETCH c_find_calul INTO gv_result;
  	IF c_find_calul%NOTFOUND THEN
  		CLOSE c_find_calul;
  		RETURN FALSE;
  	ELSE
  		CLOSE c_find_calul;
  		RETURN TRUE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CAL.crsp_val_calul_copy');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_calul_copy;


  -- Validate the IGS_PS_COURSE annual load end date.
  FUNCTION crsp_val_cal_end_dt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_yr_num IN NUMBER ,
  p_effective_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_check			CHAR;
  	CURSOR c_get_course_annual_load_rec IS
  		SELECT	'x'
  		FROM	IGS_PS_ANL_LOAD
  		WHERE	course_cd		= p_course_cd		AND
  			version_number		= p_version_number	AND
  			yr_num			= p_yr_num		AND
  			effective_start_dt    	 <> p_effective_start_dt	AND
  			effective_end_dt		IS NULL;
  BEGIN
  	-- validate that no other open ended IGS_PS_COURSE annual load
  	-- exists for the IGS_PS_COURSE version with the same yr_desc.
  	OPEN c_get_course_annual_load_rec;
  	FETCH c_get_course_annual_load_rec INTO v_check;
  	IF (c_get_course_annual_load_rec%NOTFOUND) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_END_DATE_MUSTBE_SET';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  		 Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CAL.crsp_val_cal_end_dt');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_cal_end_dt;

END IGS_PS_VAL_CAL;

/
