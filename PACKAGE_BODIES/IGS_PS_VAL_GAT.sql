--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_GAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_GAT" AS
/* $Header: IGSPS45B.pls 115.3 2002/11/29 03:04:31 nsidana ship $ */
  --
  -- To validate the update of a govt attendance mode record
  FUNCTION crsp_val_gat_upd(
  p_govt_attendance_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_at_rec IS
  		SELECT 'x'
  		FROM IGS_EN_ATD_TYPE
  		WHERE	govt_attendance_type	= p_govt_attendance_type AND
  			closed_ind		= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_at_rec;
  		FETCH c_check_at_rec INTO v_check;
  		IF c_check_at_rec%FOUND THEN
  			CLOSE c_check_at_rec;
  			p_message_name := 'IGS_PS_CANNOTCLS_GOVTATTEND';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_at_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                        Fnd_Message.Set_Token('NAME','IGS_PS_VAL_GAT.CRSP_VAL_GAT_UPD');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END crsp_val_gat_upd;
END IGS_PS_VAL_GAT;

/
