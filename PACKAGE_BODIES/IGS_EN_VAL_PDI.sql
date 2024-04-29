--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PDI" AS
/* $Header: IGSEN52B.pls 115.3 2002/11/29 00:02:47 nsidana ship $ */
  --
  -- To validate disability type of IGS_PE_PERSON disability record
  FUNCTION ENRP_VAL_PDI_DIT(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN 	-- enrp_val_pdi_dit
  DECLARE
  	cst_none		CONSTANT VARCHAR2(10) := 'NONE';
  	CURSOR	c_pdi	 IS
  		SELECT	'x'
  		FROM	IGS_PE_PERS_DISABLTY pdi,
  			IGS_AD_DISBL_TYPE dit
  		WHERE	pdi.person_id	= p_person_id AND
  			dit.disability_type	= pdi.disability_type AND
  			dit.govt_disability_type	= cst_NONE AND
  			EXISTS	(
  				SELECT	'x'
  				FROM	IGS_PE_PERS_DISABLTY pdi1,
  					IGS_AD_DISBL_TYPE dit1
  				WHERE	pdi1.person_id	= p_person_id AND
  					dit1.disability_type	= pdi1.disability_type AND
  					dit1.govt_disability_type	 <>  cst_NONE
  				);
  	v_flag	VARCHAR2(1);
  BEGIN
  	p_message_name := NULL;
  	OPEN c_pdi;
  	FETCH c_pdi INTO v_flag;
  	IF c_pdi%FOUND THEN
  		CLOSE c_pdi;
  		p_message_name := 'IGS_EN_PRSN_NOTHAVE_DIABREC';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pdi;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_pdi%ISOPEN) THEN
  			CLOSE c_pdi;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PDI.enrp_val_pdi_dit');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END enrp_val_pdi_dit;
  --
  -- To validate the IGS_PE_PERSON disability contact indicator
  FUNCTION ENRP_VAL_PD_CONTACT(
  p_disability_type IN VARCHAR2 ,
  p_contact_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN 	-- enrp_val_pd_contact
  	-- Validate the IGS_PE_PERSON disability contact indicator
  	-- against the disability type being recorded.
  	-- It is not possible for the contact indicator to be
  	-- set against disability types which have a government disability type of
  	-- 'NONE'
  DECLARE
  	cst_none		CONSTANT VARCHAR2(10) := 'NONE';
  	v_govt_disability_type	VARCHAR2(30);
  	CURSOR c_dit IS
  		SELECT	govt_disability_type
  		FROM	IGS_AD_DISBL_TYPE	dit
  		WHERE	dit.disability_type = p_disability_type;
  BEGIN
  	p_message_name := NULL;
  	IF (p_contact_ind = 'N') THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_dit;
  	FETCH c_dit INTO v_govt_disability_type;
  	IF (c_dit%FOUND) THEN
  		IF (v_govt_disability_type = cst_none) THEN
  			CLOSE c_dit;
  			p_message_name := 'IGS_EN_CONIND_NOTSET_NONE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_dit;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_dit%ISOPEN) THEN
  			CLOSE c_dit;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PDI.enrp_val_pd_contact');
		IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;


  END enrp_val_pd_contact;
  --
  -- Validate the disability type closed indicator
  FUNCTION enrp_val_dit_closed(
  p_disability_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		VARCHAR2(1);
  	CURSOR c_disability_type IS
  		SELECT	closed_ind
  		FROM	IGS_AD_DISBL_TYPE
  		WHERE	disability_type = p_disability_type;
  BEGIN
  	-- Check if the disability_type is closed
  	p_message_name := NULL;
  	OPEN c_disability_type;
  	FETCH c_disability_type INTO v_closed_ind;
  	IF (c_disability_type%NOTFOUND) THEN
  		CLOSE c_disability_type;
  		RETURN TRUE;
  	END IF;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_EN_DISABILITY_TYPE_CLOSED';
  		CLOSE c_disability_type;
  		RETURN FALSE;
  	END IF;
  	-- record is not closed
  	CLOSE c_disability_type;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PDI.enrp_val_dit_closed');
		IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;


  END;
  END enrp_val_dit_closed;
END IGS_EN_VAL_PDI;

/
