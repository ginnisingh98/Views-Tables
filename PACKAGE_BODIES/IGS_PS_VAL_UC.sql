--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UC" AS
/* $Header: IGSPS59B.pls 115.4 2002/11/29 03:08:25 nsidana ship $ */


  -- Validate the IGS_PS_UNIT category for IGS_PS_UNIT categorisation
  FUNCTION crsp_val_uc_unit_cat(
  p_unit_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_UNIT_CAT.closed_ind%TYPE;
  	CURSOR	c_unit_cat IS
   		SELECT 	closed_ind
  		FROM	IGS_PS_UNIT_CAT
  		WHERE	unit_cat = p_unit_cat;
  BEGIN
  	OPEN c_unit_cat;
  	FETCH c_unit_cat INTO v_closed_ind;
  	IF c_unit_cat%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_unit_cat;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_unit_cat;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_UNITCAT_CLOSED';
  		CLOSE c_unit_cat;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
			Fnd_Message.Set_Token('NAME','IGS_PS_VAL_UC.crsp_val_uc_unit_cat');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END crsp_val_uc_unit_cat;
END IGS_PS_VAL_UC;

/
