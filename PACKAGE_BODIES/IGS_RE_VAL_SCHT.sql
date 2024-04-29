--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_SCHT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_SCHT" AS
/* $Header: IGSRE13B.pls 115.4 2002/11/29 03:29:45 nsidana ship $ */
  --
  -- To validate IGS_RE_SCHL_TYPE person_id/org_unit_cd/start_dt
  FUNCTION RESP_VAL_SCHT_PID_OU(
  p_person_id_from IN NUMBER ,
  p_org_unit_cd_from IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_scht_pid_ou
  	-- This module validates that only one of the person_id_from and
  	-- the org_unit_cd_from fields of a scholarship record has been set.
  BEGIN
  	p_message_name := NULL;
  	IF p_person_id_from IS NOT NULL AND
  			p_org_unit_cd_from IS NOT NULL THEN
  		p_message_name := 'IGS_RE_SPECIFY_PERSID_ORG_CD';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_scht_pid_ou;

END IGS_RE_VAL_SCHT;

/
