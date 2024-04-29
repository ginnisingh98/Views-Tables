--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_SCGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_SCGT" AS
/* $Header: IGSPS54B.pls 115.3 2002/11/29 03:07:11 nsidana ship $ */
  --
  -- To validate the update of a system IGS_PS_COURSE group type record
  FUNCTION crsp_val_scgt_upd(
  p_s_course_group_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_cgt_rec IS
  		SELECT 'x'
  		FROM IGS_PS_GRP_TYPE
  		WHERE	s_course_group_type	= p_s_course_group_type AND
  			closed_ind		= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_cgt_rec;
  		FETCH c_check_cgt_rec INTO v_check;
  		IF c_check_cgt_rec%FOUND THEN
  			CLOSE c_check_cgt_rec;
  			p_message_name := 'IGS_PS_CANNOTCLS_SYSPRG_GRP';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_cgt_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
			Fnd_Message.Set_Token('NAME','IGS_PS_VAL_SCGT.crsp_val_scgt_upd');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END crsp_val_scgt_upd;
END IGS_PS_VAL_SCGT;

/
