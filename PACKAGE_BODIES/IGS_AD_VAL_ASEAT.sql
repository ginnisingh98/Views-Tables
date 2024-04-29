--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ASEAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ASEAT" AS
/* $Header: IGSAD44B.pls 115.4 2002/11/28 21:33:07 nsidana ship $ */
  -- Validate the TAC Aus Secondary Edu Assessment Type closed ind
  FUNCTION ADMP_VAL_TASEATCLOSE(
  p_tac_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_taseatclose
  	-- Validate if IGS_AD_TAC_AUSCED_AS.tac_aus_scndry_edu_ass_type  	-- is closed.
  DECLARE
  	v_closed_ind	IGS_AD_TAC_AUSCED_AS.closed_ind%TYPE DEFAULT NULL;
  	CURSOR c_taseat	IS
  		SELECT	closed_ind
  		FROM	IGS_AD_TAC_AUSCED_AS	taseat
  		WHERE	taseat.tac_aus_scndry_edu_ass_type =
  				p_tac_aus_scndry_edu_ass_type;
  BEGIN
  	p_message_name := Null;
  	IF (p_tac_aus_scndry_edu_ass_type IS NOT NULL) THEN
  		OPEN c_taseat;
  		FETCH c_taseat INTO v_closed_ind;
  		CLOSE c_taseat;
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_TRTY_ADM_SEC_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ASEAT.admp_val_taseatclose');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_taseatclose;

END IGS_AD_VAL_ASEAT;

/
