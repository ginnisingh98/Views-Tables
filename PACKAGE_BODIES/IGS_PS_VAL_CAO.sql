--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CAO" AS
/* $Header: IGSPS16B.pls 115.4 2002/11/29 02:57:15 nsidana ship $ */

  --
  -- Validate if IGS_PS_COURSE IGS_PS_AWD ownership records exist for a IGS_PS_COURSE IGS_PS_AWD.
  FUNCTION crsp_val_cao_exists(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    	v_check		CHAR;
  	CURSOR c_sel_course_award_ownership IS
  		SELECT 'x'
  		FROM 	IGS_PS_AWD_OWN
  		WHERE	course_cd	= p_course_cd		AND
  			version_number	= p_version_number	AND
  			award_cd	= p_award_cd;
  BEGIN
  	OPEN c_sel_course_award_ownership;
  	FETCH c_sel_course_award_ownership INTO v_check;
  	-- validate if IGS_PS_COURSE IGS_PS_AWD ownership records exist
  	IF (c_sel_course_award_ownership%NOTFOUND) THEN
  		CLOSE c_sel_course_award_ownership;
  		p_message_name := 'IGS_PS_PRGAWARD_OWNERSHIP';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sel_course_award_ownership;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CAO.crsp_val_cao_exists');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_cao_exists;
  --
  -- Validate IGS_PS_COURSE IGS_PS_AWD ownership % for the IGS_PS_COURSE version IGS_PS_AWD.
  FUNCTION crsp_val_cao_perc(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_course_award_own	CHAR;
  	gv_course_status	IGS_PS_STAT.s_course_status%TYPE;
    	CURSOR	gc_course_status IS
  		SELECT	CS.s_course_status
  		FROM	IGS_PS_VER CV,
  			IGS_PS_STAT CS
  		WHERE	CV.course_cd = p_course_cd AND
  			CV.version_number = p_version_number AND
  			CV.course_status = CS.course_status;
  	CURSOR	gc_course_award_own_exists IS
  		SELECT	'x'
  		FROM	IGS_PS_AWD_OWN
  		WHERE	course_cd = p_course_cd AND
  			version_number = p_version_number AND
  			award_cd = p_award_cd;
	gv_percent IGS_PS_AWD_OWN.percentage%type;
		CURSOR gc_percent IS
			  	SELECT	SUM(percentage)
  				FROM	IGS_PS_AWD_OWN
			  	WHERE	course_cd = p_course_cd AND
				  	version_number = p_version_number AND
					award_cd = p_award_cd;
  BEGIN
  	-- finding the s_course_status
  	OPEN  gc_course_status;
  	FETCH gc_course_status INTO gv_course_status;
  	-- finding IGS_PS_AWD_OWN records
  	OPEN  gc_course_award_own_exists;
  	FETCH gc_course_award_own_exists INTO gv_course_award_own;
  	-- Find the sum of all percentages
	OPEN gc_percent;
	FETCH gc_percent INTO gv_percent;
		IF gc_percent%NOTFOUND THEN
			RAISE no_data_found;
		END IF;
	CLOSE gc_percent;
  	-- when the percentage totals 100
  	IF gv_percent = 100.0 THEN
  		CLOSE gc_course_status;
  		CLOSE gc_course_award_own_exists;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		-- when the percentage doesn't total 100 and
  		-- when the IGS_PS_STAT.s_unit_status is PLANNED
  		-- and no IGS_PS_AWD_OWN records exist
  		IF (gv_course_status = 'PLANNED' AND gc_course_award_own_exists%NOTFOUND) THEN
  			CLOSE gc_course_status;
  			CLOSE gc_course_award_own_exists;
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			-- when the percentage doesn't total 100 and
  			-- when the IGS_PS_STAT.s_unit_status is not PLANNED
  			-- or IGS_PS_AWD_OWN records exist
  			CLOSE gc_course_status;
  			CLOSE gc_course_award_own_exists;
  			p_message_name := 'IGS_PS_PRCALLOC_PRGAWARD_100';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
  		IF gc_percent%ISOPEN THEN
  			CLOSE gc_percent;
  		App_Exception.Raise_Exception;
  		END IF;
      WHEN OTHERS THEN
  		IF gc_percent%ISOPEN THEN
		CLOSE gc_percent;
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CAO.crsp_val_cao_perc');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
  END crsp_val_cao_perc;


END IGS_PS_VAL_CAO;

/
