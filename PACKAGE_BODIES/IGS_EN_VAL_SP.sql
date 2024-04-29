--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SP" AS
/* $Header: IGSEN67B.pls 115.3 2002/11/29 00:07:23 nsidana ship $ */
  --
  -- To validate the delete of suburb postcode
  FUNCTION enrp_val_sp_del(
  p_postcode IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_person_id	IGS_PE_PERSON.person_id%TYPE;
  	v_other_detail	 VARCHAR(255);
  	CURSOR	gc_person_statistics(
  			cp_postcode IGS_PE_SUBURB_POSTCD.postcode%TYPE) IS
  		SELECT	person_id
  		FROM	IGS_PE_STATISTICS
  		WHERE	NVL(term_location_postcode, 0) = cp_postcode OR
  			NVL(home_location_postcode, 0) = cp_postcode;
  BEGIN
  	-- validate the deletion of IGS_PE_SUBURB_POSTCD record
  	p_message_name := null;
  	IF(p_postcode IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN gc_person_statistics(
  			p_postcode);
  	FETCH gc_person_statistics INTO v_person_id;
  	IF(gc_person_statistics%FOUND) THEN
  		CLOSE gc_person_statistics;
  		p_message_name := 'IGS_EN_NOTDEL_POSTCODE';
  		RETURN FALSE;
  	ELSE
  		CLOSE gc_person_statistics;
  		RETURN TRUE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SP.enrp_val_sp_del');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_sp_del;
END IGS_EN_VAL_SP;

/
