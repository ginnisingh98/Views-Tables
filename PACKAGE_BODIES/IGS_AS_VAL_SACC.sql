--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_SACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_SACC" AS
/* $Header: IGSAS27B.pls 115.4 2002/11/28 22:46:13 nsidana ship $ */
  --
  -- Validate the IGS_AS_CAL_CONF date alias values.
  FUNCTION assp_val_sacc_da(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_sacc_da
  	-- Validate the IGS_AD_CAL_CONF date alias values
  DECLARE
  	v_closed_ind	IGS_CA_DA.closed_ind%TYPE;
  	CURSOR	c_dt_alias IS
  		SELECT	closed_ind
  		FROM	IGS_CA_DA
  		WHERE	dt_alias = p_dt_alias;
  BEGIN
  	p_message_name := null;
  	OPEN	c_dt_alias;
  	FETCH	c_dt_alias INTO v_closed_ind;
  	IF (c_dt_alias%NOTFOUND) THEN
  		CLOSE c_dt_alias;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_dt_alias;
  	-- Validate the date alias is open
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_CA_DTALIAS_IS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
 	      Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
 	      FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_SACC.assp_val_sacc_da');
 	      IGS_GE_MSG_STACK.ADD;
       	      App_Exception.Raise_Exception;
  END assp_val_sacc_da;
END IGS_AS_VAL_SACC;

/
