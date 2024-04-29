--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_GFOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_GFOS" AS
/* $Header: IGSPS48B.pls 115.3 2002/11/29 03:05:21 nsidana ship $ */

  -- To validate the update of a government field of study record
  FUNCTION crsp_val_gfos_upd(
  p_govt_field_of_study IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_fos_rec IS
  		SELECT 'x'
  		FROM	IGS_PS_FLD_OF_STUDY
  		WHERE	govt_field_of_study		= p_govt_field_of_study AND
  			IGS_PS_FLD_OF_STUDY.closed_ind	= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_fos_rec;
  		FETCH c_check_fos_rec INTO v_check;
  		IF c_check_fos_rec%FOUND THEN
  			CLOSE c_check_fos_rec;
  			p_message_name := 'IGS_PS_CANCLS_GOVT_FOS';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_fos_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_GFOS.CRSP_VAL_GFOS_UPD');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_gfos_upd;
END IGS_PS_VAL_GFOS;

/
