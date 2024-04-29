--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_GCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_GCT" AS
/* $Header: IGSPS46B.pls 115.3 2002/11/29 03:04:46 nsidana ship $ */
  --
  -- Validate update of government IGS_PS_COURSE type record
  FUNCTION crsp_val_gct_upd(
  p_govt_course_type IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_ct_rec IS
  		SELECT 'x'
  		FROM	IGS_PS_TYPE
  		WHERE	govt_course_type	= p_govt_course_type AND
  			closed_ind		= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_ct_rec;
  		FETCH c_check_ct_rec INTO v_check;
  		IF c_check_ct_rec%FOUND THEN
  			CLOSE c_check_ct_rec;
  			p_message_name := 'IGS_PS_CANCLS_GOVT_PRGTYPE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_ct_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_VAL_GCT.CRSP_VAL_GCT_UPD');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
END IGS_PS_VAL_GCT;

/
