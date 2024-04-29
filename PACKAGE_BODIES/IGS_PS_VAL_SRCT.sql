--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_SRCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_SRCT" AS
/* $Header: IGSPS55B.pls 115.3 2002/11/29 03:07:25 nsidana ship $ */
  --
  -- To validate the update of a system IGS_PS_COURSE group type record
  FUNCTION CRSP_VAL_SRCT_UPD(
  p_s_reference_cd_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_rct_rec IS
  		SELECT 'x'
  		FROM IGS_GE_REF_CD_TYPE
  		WHERE	s_reference_cd_type	= p_s_reference_cd_type AND
  			closed_ind		= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_rct_rec;
  		FETCH c_check_rct_rec INTO v_check;
  		IF c_check_rct_rec%FOUND THEN
  			CLOSE c_check_rct_rec;
  			p_message_name := 'IGS_PS_CANNOTCLS_SYSREFCD_TYP';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_rct_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
			Fnd_Message.Set_Token('NAME','IGS_PS_VAL_SRCT.crsp_val_srct_upd');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END crsp_val_srct_upd;
END IGS_PS_VAL_SRCT;

/
