--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_TEUA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_TEUA" AS
/* $Header: IGSAD75B.pls 120.1 2005/09/08 16:23:15 appldev noship $ */

  --
  -- Validate if IGS_PS_DSCP.discipline_group_cd is closed.
  FUNCTION crsp_val_di_closed(
  p_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--crsp_val_di_closed
  	--Validate if IGS_PS_DSCP.discipline_group_cd is closed
  DECLARE
  	v_di_exists	VARCHAR2(1);
  	CURSOR c_di IS
  		SELECT 'X'
  		FROM	IGS_PS_DSCP
  		WHERE	discipline_group_cd	= p_discipline_group_cd	AND
  			closed_ind		= 'Y';
  BEGIN
  	--Set the default message number
  	p_message_name := null;
  	--If record exists then set p_message_name
  	OPEN c_di;
  	FETCH c_di INTO v_di_exists;
  	IF (c_di%FOUND) THEN
  		CLOSE c_di;
		p_message_name := 'IGS_AD_DISCIPLINE_IS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_di;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TEUA.crsp_val_di_closed');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_di_closed;
  --
  -- Validate tertiary edu unit attempt result type.

END IGS_AD_VAL_TEUA;

/
