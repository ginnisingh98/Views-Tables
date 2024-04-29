--------------------------------------------------------
--  DDL for Package Body IGR_AD_VAL_ES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_AD_VAL_ES" AS
/* $Header: IGSRT16B.pls 120.0 2005/06/02 04:21:10 appldev noship $ */
  --
  -- Validate if the system enquiry status is closed.
  FUNCTION admp_val_ses_closed(
  p_s_enquiry_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ses_closed
  	-- Validate if the system enquiry status is closed
  DECLARE
  	v_closed_ind	VARCHAR2(1);
  	CURSOR	c_ses IS
  		SELECT	ses.closed_ind
  		FROM	IGS_LOOKUPS_VIEW 	ses
  		WHERE	ses.lookup_type = 'IGR_ENQUIRY_STATUS' AND
		        ses.lookup_code	= p_s_enquiry_status AND
  			ses.closed_ind		= 'Y';
  BEGIN
  	p_message_name := NULL;
  	OPEN c_ses;
  	FETCH c_ses INTO v_closed_ind;
  	IF (c_ses%FOUND) THEN
  		CLOSE c_ses;
  		p_message_name := 'IGS_AD_SYSENQ_ST_CLOSED';
  		RETURN  FALSE;
  	END IF;
  	CLOSE c_ses;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF(c_ses%ISOPEN) THEN
  			CLOSE c_ses;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGR_AD_VAL_ES.admp_val_ses_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ses_closed;

END IGR_AD_VAL_ES;

/
