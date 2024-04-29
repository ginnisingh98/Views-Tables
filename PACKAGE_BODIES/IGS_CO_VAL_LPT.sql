--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_LPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_LPT" AS
/* $Header: IGSCO13B.pls 115.4 2002/11/28 23:05:46 nsidana ship $ */
  -- Validate if System Letter Parameter Type allows letter text to exist.
  FUNCTION corp_val_lpt_ltr_txt(
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_letter_text IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- corp_val_lpt_ltr_txt
  	-- Validate IGS_CO_LTR_PARAM_TYPE.letter_text can not be null if
  	-- IGS_CO_S_LTR_PARAM = 'LETTERTEXT'. IGS_CO_LTR_PARAM_TYPE.letter_text
  	-- is mandatory if the IGS_CO_S_LTR_PARAM = 'LETTERTEXT'.
  DECLARE
  BEGIN
  	p_message_name   :=Null;
  	IF (p_s_letter_parameter_type = 'LETTERTEXT') THEN
  		IF (p_letter_text IS NULL) THEN
  			p_message_name   := 'IGS_CO_LETTERTXT_MAND_SYSLET';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF (p_letter_text IS NOT NULL) THEN
  			p_message_name   := 'IGS_CO_LETTERTXT_EXIST_SYSLET';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;

  END corp_val_lpt_ltr_txt;
  --
  -- Validate if System Letter Parameter Type is closed.
  FUNCTION corp_val_slpt_closed(
  p_s_letter_parameter_type IN CHAR ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- corp_val_slpt_closed
  	-- Validate if IGS_CO_S_LTR_PARAM is closed.
  DECLARE
  	v_closed_ind	IGS_CO_S_LTR_PARAM.closed_ind%TYPE DEFAULT NULL;
  	CURSOR c_slpt IS
  		SELECT	closed_ind
  		FROM	IGS_CO_S_LTR_PARAM
  		WHERE	s_letter_parameter_type = p_s_letter_parameter_type;
  BEGIN
  	p_message_name   := Null;
  	OPEN c_slpt;
  	FETCH c_slpt INTO v_closed_ind;
  	CLOSE c_slpt;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name   := 'IGS_CO_SYS_LETTER_PARAM_CLS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;

  END corp_val_slpt_closed;
END IGS_CO_VAL_LPT;

/
