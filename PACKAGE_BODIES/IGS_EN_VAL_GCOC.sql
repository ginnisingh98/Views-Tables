--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_GCOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_GCOC" AS
/* $Header: IGSEN41B.pls 115.3 2002/11/28 23:59:12 nsidana ship $ */
  --
  -- Validate the update of a government country code record.
  FUNCTION enrp_val_gcoc_upd(
  p_govt_country_cd IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_country_cd		IGS_PE_COUNTRY_CD%ROWTYPE;
  	CURSOR	c_country_cd IS
  		SELECT 	*
  		FROM	IGS_PE_COUNTRY_CD
  		WHERE	govt_country_cd = p_govt_country_cd and
  			closed_ind = 'N';
  BEGIN
  	-- Validate the update on a govt_country_record.
  	-- A IGS_PE_GOV_COUNTRYCD record cannot be closed if
  	-- there are IGS_PE_COUNTRY_CD records mapped to it that
  	-- are still open
  	IF (p_closed_ind = 'Y') THEN
  		-- check if open IGS_PE_COUNTRY_CD records exist
  		OPEN  c_country_cd;
  		FETCH c_country_cd INTO v_country_cd;
  		IF (c_country_cd%FOUND) THEN
  			CLOSE c_country_cd;
  			p_message_name := 'IGS_EN_CANT_CLOSE_GOV_CONT_CD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_GCOC.enrp_val_gcoc_upd');
		IGS_GE_MSG_STACK.ADD;
	       	App_Exception.Raise_Exception;


  END;
  END enrp_val_gcoc_upd;
END IGS_EN_VAL_GCOC;

/
