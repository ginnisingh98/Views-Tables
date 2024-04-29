--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_COOAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_COOAC" AS
/* $Header: IGSAD50B.pls 115.4 2002/11/28 21:35:07 nsidana ship $ */
  -- Validate if IGS_AD_CAT.admission_cat is closed.

  --
  -- Validates if the admission cat is in an admission cat course type
  FUNCTION admp_val_ac_acct(
    p_admission_cat IN VARCHAR2 ,
    p_course_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN	--admp_val_ac_acct
  	--This module checks if admission category course type records exist relating
  	--to a certain admission category. If the admission category course type
  	-- records
  	--do exist then check if the passed admission category is linked to the
  	--passed course versions course type
  DECLARE
  	v_acct_exists	VARCHAR2(1);
  	CURSOR c_acct IS
  		SELECT 'X'
  		FROM	IGS_AD_CAT_PS_TYPE acct
  		WHERE	acct.admission_cat = p_admission_cat;
  	CURSOR c_acct2 IS
  		SELECT 'X'
  		FROM	IGS_AD_CAT_PS_TYPE	acct,
  			IGS_PS_VER		cv
  		WHERE	acct.admission_cat	= p_admission_cat	AND
  			cv.course_cd		= p_course_cd		AND
  			cv.version_number	= p_version_number	AND
  			acct.course_type	= cv.course_type;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--If no records are found then there is no restriction
  	OPEN c_acct;
  	FETCH c_acct INTO v_acct_exists;
  	IF (c_acct%NOTFOUND) THEN
  		CLOSE c_acct;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_acct;
  	--Check if the cousre type is valid for this admission category,
  	--  if not set p_message_name
  	OPEN c_acct2;
  	FETCH c_acct2 INTO v_acct_exists;
  	IF (c_acct2%NOTFOUND) THEN
  		CLOSE c_acct2;
  		--p_message_num := 2809;
            p_message_name := 'IGS_AD_ADMCAT_NOTVALID_PRGTYP';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_acct2;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_COOAC.admp_val_ac_acct');
		IGS_GE_MSG_STACK.ADD;
  END admp_val_ac_acct;
END IGS_AD_VAL_COOAC;

/
