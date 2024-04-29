--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_PE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_PE" AS
/* $Header: IGSAD66B.pls 115.5 2003/12/05 11:51:48 rboddu ship $ */

  --
  -- To validate duplicate person records using surname and birthdate
  FUNCTION admp_val_pe_dplct(
  p_person_id IN NUMBER ,
  p_surname IN VARCHAR2 ,
  p_birth_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  BEGIN
  DECLARE
  	v_person_id		IGS_PE_PERSON.person_id%TYPE;
          CURSOR c_pe IS
             SELECT pe.person_id
	     FROM igs_pe_person_base_v pe   /* Replaced IGS_PE_PERSON with igs_pe_person_base_v Bug 3150054 */
             WHERE pe.person_id = p_person_id AND
		   pe.last_name = p_surname AND
		   pe.birth_date = p_birth_dt;

  BEGIN
  	-- Check for a duplicate person by checking for another person record with the
  	-- same surname and date of birth. Note: this routine is only treated as a
  	-- warning.
  	p_message_name := null;
  	-- 1. The check cannot be applied if all parameters are not set.
  	IF (p_birth_dt IS NULL) OR
  			(p_surname IS NULL) OR
  			(p_birth_dt IS NULL) THEN
	  	p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	OPEN	c_pe;
  	FETCH	c_pe	INTO	v_person_id;
  	IF (c_pe%FOUND) THEN
  		CLOSE	c_pe;
		p_message_name := 'IGS_AD_PEREXT_SAME_SURNAM_DOB';
  		RETURN FALSE;
  	END IF;
  	CLOSE	c_pe;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_PE.admp_val_pe_dplct');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_pe_dplct;
  --
  -- Validate the person deceased indicator.
  FUNCTION admp_val_pe_deceased(
  p_deceased_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_pe_deceased
  	-- Validate the person deceased indicator. On creation of a person record the
  	-- deceased indicator cannot be set to Yes.
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF (p_deceased_ind = 'Y') THEN
		p_message_name := 'IGS_AD_CANNOT_CREATE_DEADPRSN';
  		RETURN FALSE;
  	END IF;
  	--- Return no error
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_PE.admp_val_pe_deceased');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_pe_deceased;
  --
  END igs_ad_val_pe;

/
