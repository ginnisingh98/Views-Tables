--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ASES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ASES" AS
/* $Header: IGSAD45B.pls 120.0 2005/06/01 14:25:38 appldev noship $ */
  -- Validate the secondary school type closed indicator.
  FUNCTION admp_val_ssst_closed(
  p_s_scndry_school_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_ssst IS
  		SELECT	closed_ind
  		FROM	IGS_LOOKUP_VALUES
  		WHERE	lookup_type = 'SCNDRY_SCHOOL_TYPE'  AND
		        lookup_code = p_s_scndry_school_type;
  	v_ssst_rec			c_ssst%ROWTYPE;
  BEGIN
  	-- Check if the s_scndry_school_type is closed.
  	-- Set the default message number
  	p_message_name := Null;
  	-- Cursor handling
  	OPEN c_ssst;
  	FETCH c_ssst INTO v_ssst_rec;
  	IF c_ssst %NOTFOUND THEN
  		CLOSE c_ssst;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ssst;
  	IF (v_ssst_rec.closed_ind = 'Y') THEN
  		p_message_name := 'IGS_AD_SCDRY_SCHOOL_TYPE_CLS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ASES.admp_val_ssst_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ssst_closed;

END IGS_AD_VAL_ASES;

/
