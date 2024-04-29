--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_SNAPSHOT" AS
/* $Header: IGSST15B.pls 115.4 2002/11/29 04:12:49 nsidana ship $ */
  -- Validate whether or not an org unit belongs to the local institution.
  FUNCTION stap_val_local_ou(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_results_flag		CHAR;
  	CURSOR c_chk_institute_ou IS
  		SELECT	'x'
  		FROM	IGS_OR_INSTITUTION ins,
  			IGS_OR_INST_STAT ist,
  			IGS_OR_UNIT ou
  		WHERE	ins.local_institution_ind = 'Y' 		AND
  			ist.institution_status = ist.institution_status	AND
  			ist.s_institution_status = 'ACTIVE'		AND
  			ou.institution_cd	= ins.institution_cd	AND
  			ou.org_unit_cd		= p_org_unit_cd		AND
  			ou.start_dt		= p_ou_start_dt;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	-- Check if the organisational unit belongs to the local institution.
  	OPEN c_chk_institute_ou;
  	FETCH c_chk_institute_ou INTO v_results_flag;
  	IF c_chk_institute_ou%NOTFOUND THEN
  		CLOSE c_chk_institute_ou;
  		--p_message_num := 2009;
		p_message_name := 'IGS_ST_CHK_ORG_UNIT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_chk_institute_ou;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_SNAPSHOT.stap_val_local_ou');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END stap_val_local_ou;
END IGS_ST_VAL_SNAPSHOT;

/
