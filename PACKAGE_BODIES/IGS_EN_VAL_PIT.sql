--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PIT" AS
/* $Header: IGSEN55B.pls 115.3 2002/11/29 00:03:34 nsidana ship $ */
  --
  -- Validate the person id type institution code is active.
  FUNCTION enrp_val_pit_inst_cd(
  p_institution_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN -- enrp_val_pit_inst_cd
  	-- validate that the institution code for a person_id is active
  DECLARE
  	v_s_ins_status	IGS_OR_INST_STAT.s_institution_status%TYPE;
  	CURSOR	c_get_s_ins_status IS
  		SELECT	s_institution_status
  		FROM	IGS_OR_INSTITUTION		ins,
  			IGS_OR_INST_STAT	ins_s
  		WHERE	ins.institution_cd	= p_institution_cd	AND
  			ins.institution_status	= ins_s.institution_status;
  BEGIN
  	OPEN c_get_s_ins_status;
  	FETCH c_get_s_ins_status INTO v_s_ins_status;
  	IF (c_get_s_ins_status%NOTFOUND) THEN
  		CLOSE c_get_s_ins_status;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_get_s_ins_status;
  	IF (v_s_ins_status = 'ACTIVE') THEN
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_EN_CANT_CRETE_PERSID';
  		RETURN FALSE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PIT.enrp_val_pit_inst_cd');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;

  END enrp_val_pit_inst_cd;
END IGS_EN_VAL_PIT;

/
