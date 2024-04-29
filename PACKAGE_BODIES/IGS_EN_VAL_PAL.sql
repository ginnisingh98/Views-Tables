--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PAL" AS
/* $Header: IGSEN49B.pls 115.6 2003/02/28 07:32:11 pkpatel ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_STRT_END_DT removed
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --pkpatel     28-FEB-2003     Bug No. 2808871 .Modified IGS_PE_PERSON to IGS_PE_PERSON_BASE_V
  -------------------------------------------------------------------------------------------

  -- Validate the IGS_PE_PERSON alias name and IGS_PE_TITLE
  FUNCTION enrp_val_pal_alias(
  p_person_id IN NUMBER ,
  p_surname IN VARCHAR2 ,
  p_given_names IN VARCHAR2 ,
  p_title IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN
  	-- Validate that at least one of surname, given_names or
  	-- IGS_PE_TITLE form IGS_PE_PERSON_ALIAS table is differenct from
  	-- surname, given_names and IGS_PE_TITLE from person_table

  DECLARE
  	v_surname	IGS_PE_PERSON_ALIAS.surname%TYPE;
  	v_given_names	IGS_PE_PERSON_ALIAS.given_names%TYPE;
  	v_title		IGS_PE_PERSON_ALIAS.title%TYPE;
  	CURSOR c_person IS
  		SELECT	last_name surname,
  			first_name given_names,
  			title
  		from	igs_pe_person_base_v
  		WHERE 	person_id = p_person_id;
  BEGIN
  	-- at least one of the IGS_PE_PERSON_ALIAS.surname or given_names
  	-- must be set
  	IF (p_surname IS NULL) AND (p_given_names is NULL) THEN
  		p_message_name := 'IGS_EN_SURNAM_GIVNAM_NOT_NULL';
  		RETURN FALSE;
  	END IF;

  	OPEN c_person;
  	FETCH c_person INTO 	v_surname,
  				v_given_names,
  				v_title;
  	IF (c_person%NOTFOUND) THEN
  		CLOSE c_person;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_person;
  	-- at least one of surname, given_names or
  	-- IGS_PE_TITLE must be difference

        -- changes done as a part of fix for bug number 2045753

  	IF ( UPPER(v_surname) 		= UPPER(p_surname)	AND
  	    UPPER(v_given_names)	= UPPER(p_given_names)	AND
  	    UPPER(v_title)              = UPPER(p_title)) THEN
  		p_message_name := 'IGS_EN_DUPL_NAMES';
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PAL.enrp_val_pal_alias');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_pal_alias;
  --
  -- Validate the alternate IGS_PE_PERSON id end date.
  FUNCTION enrp_val_api_end_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  BEGIN
  	-- Perform validation when the end_dt is set
  	IF (p_end_dt IS NOT NULL) THEN
  		IF (p_start_dt IS NOT NULL) THEN
  			p_message_name := null;
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_EN_CANT_SPECIFY_END_DATE';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PAL.enrp_val_api_end_dt');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_api_end_dt;
  --
  -- Validate the IGS_PE_PERSON alias names
  FUNCTION enrp_val_pal_names(
  p_given_names IN VARCHAR2 ,
  p_surname IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  BEGIN
  	-- Validate the surname and given_names from IGS_PE_PERSON_ALIAS
  	IF (p_surname IS NULL AND p_given_names IS NULL) THEN
  		p_message_name := 'IGS_EN_SURNAM_GIVNAM_NOT_NULL';
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PAL.enrp_val_pal_names');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;


  END;
  END enrp_val_pal_names;

END IGS_EN_VAL_PAL;

/
