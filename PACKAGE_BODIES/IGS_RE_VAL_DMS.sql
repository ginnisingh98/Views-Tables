--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_DMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_DMS" AS
/* $Header: IGSRE08B.pls 115.3 2002/11/29 03:28:28 nsidana ship $ */
  --
  -- To validate IGS_RE_DFLT_MS_SET uniqueness
  FUNCTION RESP_VAL_DMS_UNIQ(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_dms_uniq
  	-- Validate that there are not ?logically? duplicate default IGS_PR_MILESTONE
  	-- records within a IGS_PS_COURSE version/attendance type combination.
  	--	ie. same milestone_type and offset_days.
  	-- This check is designed to be placed in a post-forms-commit section
  	-- of a form or an after statement of a database trigger.
  DECLARE
  	v_return_false 	BOOLEAN;
  	CURSOR c_dms IS
  		SELECT	dms.course_cd,
  			dms.version_number,
  			dms.attendance_type,
  			dms.milestone_type,
  			dms.offset_days,
  			count('x')		duplicate_count
  		FROM	IGS_RE_DFLT_MS_SET	dms
  		WHERE	course_cd		= p_course_cd AND
  			dms.version_number	= p_version_number AND
  			dms.attendance_type	= p_attendance_type
  		GROUP BY
  			dms.course_cd,
  			dms.version_number,
  			dms.attendance_type,
  			dms.milestone_type,
  			dms.offset_days;
  BEGIN
  	-- Set the defaults
  	p_message_name := null;
  	v_return_false := FALSE;
  	FOR v_dms_rec IN c_dms LOOP
  		IF v_dms_rec.duplicate_count > 1 THEN
  			p_message_name := 'IGS_RE_2_MILSTON_HAV_SAMEOFFS';
  			v_return_false := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_return_false THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_dms%ISOPEN THEN
  			CLOSE c_dms;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_dms_uniq;
END IGS_RE_VAL_DMS;

/
