--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_DI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_DI" AS
 /* $Header: IGSPS40B.pls 115.3 2002/11/29 03:03:14 nsidana ship $ */

  --
  -- Validate government IGS_PS_DSCP group code for IGS_PS_DSCP records.
  FUNCTION crsp_val_di_govt_dg(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_GOVT_DSCP.closed_ind%TYPE;
  	CURSOR	c_govt_discipline IS
   		SELECT 	closed_ind
  		FROM	IGS_PS_GOVT_DSCP
  		WHERE	govt_discipline_group_cd = p_govt_discipline_group_cd;
  BEGIN
  	OPEN c_govt_discipline;
  	FETCH c_govt_discipline	INTO  v_closed_ind;
  	IF c_govt_discipline%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_govt_discipline;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_govt_discipline;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_GOVT_DISCP_GRP_CLOSED';
  		CLOSE c_govt_discipline;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_DI.crsp_val_di_govt_dg');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_di_govt_dg;
END IGS_PS_VAL_DI;

/
