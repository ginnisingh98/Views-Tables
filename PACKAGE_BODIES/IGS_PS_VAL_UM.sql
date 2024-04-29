--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UM" AS
/* $Header: IGSPS62B.pls 115.3 2002/11/29 03:09:07 nsidana ship $ */

  --
  -- To validate the update of a IGS_PS_UNIT mode record
  FUNCTION crsp_val_um_upd(
  p_unit_mode IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_uc_rec IS
  		SELECT 'x'
  		FROM IGS_AS_UNIT_CLASS
  		WHERE	unit_mode	= p_unit_mode AND
  			closed_ind	= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_uc_rec;
  		FETCH c_check_uc_rec INTO v_check;
  		IF c_check_uc_rec%FOUND THEN
  			CLOSE c_check_uc_rec;
  			p_message_name := 'IGS_PS_CANNOTCLS_UNIT_MODE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_uc_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UM.crsp_val_um_upd');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_um_upd;
END IGS_PS_VAL_UM;

/
