--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_CNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_CNC" AS
/* $Header: IGSEN30B.pls 115.3 2002/11/28 23:56:31 nsidana ship $ */


  --
  -- Validate the country government country code.
  FUNCTION enrp_val_cnc_govt(
  p_govt_country_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	gv_other_detail		VARCHAR(255);
  	gv_closed_ind		IGS_PE_GOV_COUNTRYCD.closed_ind%TYPE;
  	CURSOR	gc_govt_country_cd(
  			cp_govt_country_cd IGS_PE_GOV_COUNTRYCD.govt_country_cd%TYPE) IS
  		SELECT	IGS_PE_GOV_COUNTRYCD.closed_ind
  		FROM	IGS_PE_GOV_COUNTRYCD
  		WHERE	IGS_PE_GOV_COUNTRYCD.govt_country_cd = cp_govt_country_cd;
  BEGIN
  	-- This module validates if IGS_PE_GOV_COUNTRYCD.govt_country_cd
  	-- is closed
  	p_message_name := null;
  	OPEN gc_govt_country_cd(
  			p_govt_country_cd);
  	FETCH gc_govt_country_cd INTO gv_closed_ind;
  	IF (gc_govt_country_cd%FOUND) THEN
  		IF (gv_closed_ind = 'Y' ) THEN
  			CLOSE gc_govt_country_cd;
  			p_message_name := 'IGS_EN_GOV_COUNTRY_CD_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE gc_govt_country_cd;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_CNC.enrp_val_cnc_govt');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_cnc_govt;
  --
  -- To validate the delete of country code
  FUNCTION enrp_val_cnc_del(
  p_country_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_person_id	 IGS_PE_PERSON.person_id%TYPE;
  	v_other_detail	 VARCHAR(255);
  	CURSOR	gc_person_statistics(
  			cp_country_cd IGS_PE_COUNTRY_CD.country_cd%TYPE) IS
  		SELECT	person_id
  		FROM	IGS_PE_STATISTICS
  		WHERE	NVL(birth_country_cd, 'NULL') = cp_country_cd OR
  			NVL(term_location_country, 'NULL') = cp_country_cd OR
  			NVL(home_location_country, 'NULL') = cp_country_cd;
  BEGIN
  	-- validate the deletion of IGS_PE_COUNTRY_CD record
  	p_message_name := null;
  	IF(p_country_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN gc_person_statistics(
  			p_country_cd);
  	FETCH gc_person_statistics INTO v_person_id;
  	IF(gc_person_statistics%FOUND) THEN
  		CLOSE gc_person_statistics;
  		p_message_name := 'IGS_EN_NOTDEL_COUNTRY_CD';
  		RETURN FALSE;
  	ELSE
  		CLOSE gc_person_statistics;
  		RETURN TRUE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_CNC.enrp_val_cnc_del');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_cnc_del;
END IGS_EN_VAL_CNC;

/
