--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_RCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_RCT" AS
/* $Header: IGSPS53B.pls 115.3 2002/11/29 03:06:54 nsidana ship $ */
  --
  -- Validate the system reference code type for reference code type.
  FUNCTION crsp_val_rct_srct(
  p_s_reference_cd_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_LOOKUPS_VIEW.closed_ind%TYPE;
  	CURSOR	c_ref_cd_type_closed_ind IS
  	SELECT	closed_ind
  	FROM	IGS_LOOKUPS_VIEW
  	WHERE	Lookup_code = p_s_reference_cd_type
	AND Lookup_type = 'REFERENCE_CD_TYPE'
  	AND	closed_ind = 'Y';
  BEGIN
  	OPEN c_ref_cd_type_closed_ind;
  	FETCH c_ref_cd_type_closed_ind INTO v_closed_ind;
  --- If a record was not found, then return TRUE, else return FALSE
  	IF c_ref_cd_type_closed_ind%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_ref_cd_type_closed_ind;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_SYSREFCD_TYPE_CLOSED';
  		CLOSE c_ref_cd_type_closed_ind;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_RCT.crsp_val_rct_srct');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_rct_srct;
END IGS_PS_VAL_RCT;

/
