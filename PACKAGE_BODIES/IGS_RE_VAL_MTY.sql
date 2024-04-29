--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_MTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_MTY" AS
/* $Header: IGSRE10B.pls 115.3 2002/11/29 03:28:58 nsidana ship $ */

  --
  -- To validate IGS_PR_MILESTONE type notification days
  FUNCTION RESP_VAL_MTY_DAYS(
  p_reminder_days IN NUMBER ,
  p_re_reminder_days IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_mty_days
  	-- Validate IGS_PR_MILESTONE_TYPE.{ntfctn_imminent_days,
  	--			ntfctn_reminder_days,
  	--			ntfctn_re_reminder_days}, checking,
  	--  That the re_reminder days cannot be set if the reminder_days aren't set.
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_reminder_days IS NULL AND
  			p_re_reminder_days IS NOT NULL THEN
  		p_message_name := 'IGS_RE_CANT_SET_REMINDER_DAYS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_mty_days;
END IGS_RE_VAL_MTY;

/
