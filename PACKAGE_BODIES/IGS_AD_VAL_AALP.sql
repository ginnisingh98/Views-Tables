--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AALP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AALP" AS
/* $Header: IGSAD18B.pls 115.6 2002/11/28 21:26:09 nsidana ship $ */

  --
  -- Validate if letter parameter type is closed.
  FUNCTION corp_val_lpt_closed(
  p_letter_parameter_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- corp_val_lpt_closed
  	-- Validate if letter_parameter_type is closed.
  DECLARE
  	v_closed_ind	IGS_CO_LTR_PHR.closed_ind%TYPE	DEFAULT 'N';
  	CURSOR c_lpt IS
  		SELECT	closed_ind
  		FROM	IGS_CO_LTR_PARM_TYPE
  		WHERE	letter_parameter_type = p_letter_parameter_type;
  BEGIN
  	p_message_name := null;
  	OPEN c_lpt;
  	FETCH c_lpt INTO v_closed_ind;
  	CLOSE c_lpt;
  	IF (v_closed_ind = 'Y') THEN
		p_message_name := 'IGS_CO_LETTER_PARAM_TYPE_CLS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AALP.corp_val_lpt_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END corp_val_lpt_closed;
  --
  -- Validate  letter_parameter_type has  IGS_CO_S_LTR_PARAM = PHRASE
  FUNCTION corp_val_lpt_phrase(
  p_letter_parameter_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- corp_val_lpt_phrase
  	-- Validate if letter_parameter_type has a IGS_CO_S_LTR_PARAM = 'PHRASE'
  DECLARE
  	v_check		CHAR;
  	CURSOR c_lpt IS
  		SELECT	'x'
  		FROM	IGS_CO_LTR_PARM_TYPE
  		WHERE	letter_parameter_type 	= p_letter_parameter_type AND
  			s_letter_parameter_type = 'PHRASE' AND
  			closed_ind 		= 'N';
  BEGIN
  	p_message_name := null;
  	OPEN c_lpt;
  	FETCH c_lpt INTO v_check;
  	IF (c_lpt%NOTFOUND) THEN
  		CLOSE c_lpt;
		p_message_name := 'IGS_CO_LETTER_PARAM_PHRASE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_lpt;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AALP.corp_val_lpt_phrase');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END corp_val_lpt_phrase;
  --
  -- Validate if letter phrase is closed.
  FUNCTION corp_val_ltp_closed(
  p_phrase_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- corp_val_ltp_closed
  	-- Validate if IGS_CO_LTR_PHR is closed.
  DECLARE
  	v_closed_ind	IGS_CO_LTR_PHR.closed_ind%TYPE	DEFAULT 'N';
  	CURSOR c_ltp IS
  		SELECT	closed_ind
  		FROM	IGS_CO_LTR_PHR
  		WHERE	phrase_cd = p_phrase_cd;
  BEGIN
  	p_message_name := null;
  	OPEN c_ltp;
  	FETCH c_ltp INTO v_closed_ind;
  	CLOSE c_ltp;
  	IF (v_closed_ind = 'Y') THEN
		p_message_name := 'IGS_CO_LETTER_PHRASE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AALP.corp_val_ltp_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END corp_val_ltp_closed;

END IGS_AD_VAL_AALP;

/
