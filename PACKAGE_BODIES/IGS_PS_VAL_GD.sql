--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_GD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_GD" AS
/* $Header: IGSPS47B.pls 115.3 2002/11/29 03:05:03 nsidana ship $ */
  --
  -- Validate update of government IGS_PS_DSCP record
  FUNCTION crsp_val_gd_upd(
  p_govt_discipline_group_cd IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_disc_rec IS
  		SELECT 'x'
  		FROM   IGS_PS_DSCP
  		WHERE	govt_discipline_group_cd 	= p_govt_discipline_group_cd AND
  			closed_ind		= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_disc_rec;
  		FETCH c_check_disc_rec INTO v_check;
  		IF c_check_disc_rec%FOUND THEN
  			CLOSE c_check_disc_rec;
  			p_message_name := 'IGS_PS_CANCLS_GOVT_DISCPGRP';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_disc_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_GD.CRSP_VAL_GD_UPD');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_gd_upd;
END IGS_PS_VAL_GD;

/
