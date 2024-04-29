--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_COW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_COW" AS
 /* $Header: IGSPS30B.pls 115.4 2002/11/29 03:01:09 nsidana ship $ */

  --
  -- Validate IGS_PS_COURSE ownership percentage for the IGS_PS_COURSE version.
  FUNCTION crsp_val_cow_perc(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  --	gv_percent		NUMBER;
  	gv_course_ownership	CHAR;
  	gv_course_status	IGS_PS_STAT.s_course_status%TYPE;
  	CURSOR	gc_course_status IS
  		SELECT	CS.s_course_status
  		FROM	IGS_PS_VER CV,
  			IGS_PS_STAT CS
  		WHERE	CV.course_cd = p_course_cd AND
  			CV.version_number = p_version_number AND
  			CV.course_status = CS.course_status;
  	CURSOR	gc_course_ownership_exists IS
  		SELECT	'x'
  		FROM	IGS_PS_OWN
  		WHERE	course_cd = p_course_cd AND
  			version_number = p_version_number;
	gv_percent  IGS_PS_OWN.PERCENTAGE%TYPE;

	 CURSOR  cur_user  IS
     	   SELECT	SUM(percentage)
     	    	   FROM	IGS_PS_OWN
  	   WHERE	course_cd = p_course_cd AND
  		version_number = p_version_number;


  BEGIN
  	-- finding the s_course_status
  	OPEN  gc_course_status;
  	FETCH gc_course_status INTO gv_course_status;
  	-- finding IGS_PS_OWN records
  	OPEN  gc_course_ownership_exists;
  	FETCH gc_course_ownership_exists INTO gv_course_ownership;
 -- Find the sum of all percentages

     OPEN cur_user;
     FETCH  cur_user INTO gv_percent;
     IF cur_user%NOTFOUND THEN
       RAISE no_data_found ;
     END IF;
     CLOSE cur_user ;

  	-- when the percentage totals 100
  	IF gv_percent = 100.00 THEN
  		CLOSE gc_course_status;
  		CLOSE gc_course_ownership_exists;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		-- when the percentage doesn't total 100 and
  		-- when the IGS_PS_STAT.s_unit_status is PLANNED
  		-- and no IGS_PS_OWN records exist
  		IF (gv_course_status = 'PLANNED' AND gc_course_ownership_exists%NOTFOUND) THEN
  			CLOSE gc_course_status;
  			CLOSE gc_course_ownership_exists;
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			-- when the percentage doesn't total 100 and
  			-- when the IGS_PS_STAT.s_unit_status is not PLANNED
  			-- or IGS_PS_OWN records exist
  			CLOSE gc_course_status;
  			CLOSE gc_course_ownership_exists;
  			p_message_name := 'IGS_PS_PRCALLOC_PRGOWN_100';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
	   IF cur_user%ISOPEN THEN
	     CLOSE cur_user;
	   END IF;
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
         Fnd_Message.Set_Token('NAME','IGS_PS_VAL_COw.crsp_val_cow_perc');
	 IGS_GE_MSG_STACK.ADD;
	   APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_cow_perc;

END IGS_PS_VAL_COw;

/
