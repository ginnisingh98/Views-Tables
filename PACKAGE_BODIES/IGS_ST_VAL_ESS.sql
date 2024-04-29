--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_ESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_ESS" AS
/* $Header: IGSST05B.pls 115.5 2002/11/29 04:11:10 nsidana ship $ */

  --
  -- Validate no warnings exist for excluded pid,crs,unit records
  FUNCTION stap_val_eswv_xandw(
  p_snapshot_dt_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- stap_val_eswv_xandw
  	-- This module validates that no warning (ie.'W') records exist int the
  	-- IGS_EN_ST_SNAPSHOT table for person_id, course_cd, unit_cd records
  	-- which have been excluded (ie.'X').
  DECLARE
  	v_dummy			VARCHAR2(1);
  	v_warning_found		BOOLEAN DEFAULT FALSE;
  	CURSOR c_eswv_excluded IS
  		SELECT	eswv_excluded.snapshot_dt_time,
  			eswv_excluded.ci_cal_type,
  			eswv_excluded.ci_sequence_number,
  			eswv_excluded.person_id,
  			eswv_excluded.course_version,
  			eswv_excluded.unit_version
  		FROM	IGS_EN_ST_SNAPSHOT_WARNING_V	eswv_excluded
  		WHERE	eswv_excluded.snapshot_dt_time	= p_snapshot_dt_time AND
  			eswv_excluded.govt_reportable_ind = 'X';
  	CURSOR c_eswv_warning (
  				cp_snapshot_dt_time
IGS_EN_ST_SNAPSHOT_WARNING_V.snapshot_dt_time%TYPE,
  				cp_ci_cal_type		IGS_EN_ST_SNAPSHOT_WARNING_V.ci_cal_type%TYPE,
  				cp_ci_sequence_number
IGS_EN_ST_SNAPSHOT_WARNING_V.ci_sequence_number%TYPE,
  				cp_person_id		IGS_EN_ST_SNAPSHOT_WARNING_V.person_id%TYPE,
  				cp_course_version
IGS_EN_ST_SNAPSHOT_WARNING_V.course_version%TYPE,
  				cp_unit_version		IGS_EN_ST_SNAPSHOT_WARNING_V.unit_version%TYPE)
IS
  		SELECT	'X'
  		FROM	IGS_EN_ST_SNAPSHOT_WARNING_V	eswv_warning
  		WHERE	eswv_warning.snapshot_dt_time 	= cp_snapshot_dt_time AND
  			eswv_warning.ci_cal_type 	= cp_ci_cal_type AND
  			eswv_warning.ci_sequence_number	= cp_ci_sequence_number AND
  			eswv_warning.person_id 		= cp_person_id AND
  			eswv_warning.course_version	= cp_course_version AND
  			eswv_warning.unit_version	= cp_unit_version AND
  			eswv_warning.govt_reportable_ind = 'W';
  BEGIN
  	-- Set the default message name
    	p_message_name := null;
  	FOR v_eswv_excluded IN c_eswv_excluded LOOP
  		OPEN c_eswv_warning (
  					v_eswv_excluded.snapshot_dt_time,
  					v_eswv_excluded.ci_cal_type,
  					v_eswv_excluded.ci_sequence_number,
  					v_eswv_excluded.person_id,
  					v_eswv_excluded.course_version,
  					v_eswv_excluded.unit_version);
  		FETCH c_eswv_warning INTO v_dummy;
  		IF c_eswv_warning%FOUND THEN
  			CLOSE c_eswv_warning;
  			p_message_name := 'IGS_ST_WARN_RECORD_EXISTS';
  			v_warning_found	:= TRUE;
  			exit;
  		END IF;
  		CLOSE c_eswv_warning;
  	END LOOP;
  	IF v_warning_found THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_eswv_excluded%ISOPEN THEN
  			CLOSE c_eswv_excluded;
  		END IF;
  		IF c_eswv_warning%ISOPEN THEN
  			CLOSE c_eswv_warning;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_ESS.stap_val_eswv_xandw');
		IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END stap_val_eswv_xandw;
END IGS_ST_VAL_ESS;

/
