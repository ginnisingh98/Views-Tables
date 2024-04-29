--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_SLET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_SLET" AS
/* $Header: IGSCO19B.pls 115.5 2002/11/28 23:06:44 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cort_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate if System Letter Object is closed.
  FUNCTION corp_val_slo_closed(
  p_s_letter_object IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- corp_val_slo_closed
  	-- Validate if s_letter_object is closed.
  DECLARE
  	v_closed_ind	IGS_LOOKUPS_view.closed_ind%TYPE DEFAULT NULL;
  	CURSOR c_slo IS
  		SELECT	closed_ind
  		FROM	IGS_LOOKUPS_view
  		WHERE	lookup_code = p_s_letter_object
		AND	lookup_type='LETTER_OBJECT';
  BEGIN
  	p_message_name   := Null;
  	OPEN c_slo;
  	FETCH c_slo INTO v_closed_ind;
  	CLOSE c_slo;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name   := 'IGS_CO_SYS_LETTER_OBJ_CLS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;

  END corp_val_slo_closed;
  --
  --  Validate if the IGS_CO_TYPE is a system generated type.
  FUNCTION corp_val_cort_sysgen(
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- corp_val_cort_sysgen
  	-- Validate if the IGS_CO_TYPE is a system generated type.
  DECLARE
  	v_sys_generated_ind	IGS_CO_TYPE.sys_generated_ind%TYPE DEFAULT NULL;
  	CURSOR c_cort IS
  		SELECT	sys_generated_ind
  		FROM	IGS_CO_TYPE
  		WHERE	correspondence_type = p_correspondence_type;
  BEGIN
  	p_message_name   := null;
  	OPEN c_cort;
  	FETCH c_cort INTO v_sys_generated_ind;
  	CLOSE c_cort;
  	IF (v_sys_generated_ind = 'N') THEN
  		p_message_name   := 'IGS_CO_CORTYPE_ISNOT_SYSGEN';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;

  END corp_val_cort_sysgen;
END IGS_CO_VAL_SLET;

/
