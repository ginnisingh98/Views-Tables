--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_IV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_IV" AS
/* $Header: IGSEN46B.pls 120.0 2005/06/01 16:21:58 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The Function genp_val_staff_prsn removed
  -------------------------------------------------------------------------------------------
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  --asbala      15-APR-04       3349171 - Wrong usage of fnd_lookup_values
  --
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_cnc_closed
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_cnc_closed
  --
  --
  -- Validate the international visa contact
  FUNCTION enrp_val_iv_contact(
  p_org_unit_cd IN VARCHAR2 ,
  p_contact_name IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  BEGIN
  	-- Validate the IGS_OR_UNIT and contact name from IGS_AD_INTL_VISA
  	IF (p_org_unit_cd IS NULL AND p_contact_name IS NOT  NULL) THEN
  		p_message_name := 'IGS_EN_CANT_SPECIFY_CNTCT_NAM';
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_IV.enrp_val_iv_contact');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_iv_contact;
  --
  -- Validate the international visa IGS_PE_PERSON id
  FUNCTION enrp_val_iv_person(
  p_org_unit_cd IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  BEGIN
  	-- Validate the IGS_OR_UNIT and contact name from IGS_AD_INTL_VISA
  	IF (p_org_unit_cd IS NULL AND p_person_id IS NOT  NULL) THEN
  		p_message_name := 'IGS_EN_ENTER_ORG_UNIT';
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_IV.enrp_val_iv_person');
		IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_iv_person;
  --
  -- Validate the visa type closed indicator
  FUNCTION enrp_val_vit_closed(
  p_visa_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_closed_ind		VARCHAR2(1);
  	CURSOR	c_visa_type IS
  		SELECT	enabled_flag
  		FROM 	fnd_lookup_values
  		WHERE   lookup_type = 'PER_US_VISA_TYPES'
                AND     view_application_id = 3
		AND     security_group_id = 0
		AND     language = USERENV('LANG')
                AND     lookup_code = p_visa_type;
  BEGIN
  	-- Check if the IGS_AD_VISA_TYPE is closed
  	p_message_name := null;
  	OPEN c_visa_type;
  	FETCH c_visa_type INTO v_closed_ind;
  	IF (c_visa_type%NOTFOUND) THEN
  		CLOSE c_visa_type;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_visa_type;
  	IF (v_closed_ind = 'N') THEN
  		p_message_name := 'IGS_EN_VISA_TYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- IGS_AD_VISA_TYPE is not closed
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_IV.enrp_val_vit_closed');
		IGS_GE_MSG_STACK.ADD;
	       	App_Exception.Raise_Exception;


  END;
  END enrp_val_vit_closed;
END IGS_EN_VAL_IV;

/
