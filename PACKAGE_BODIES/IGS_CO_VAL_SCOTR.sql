--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_SCOTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_SCOTR" AS
/* $Header: IGSCO18B.pls 120.1 2006/01/18 23:16:48 skpandey noship $ */
  -- Validate a IGS_PE_PERSON id.
  FUNCTION genp_val_prsn_id(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_person_id	IGS_PE_PERSON.person_id%TYPE;
-- skpandey, Bug#4937960: Changed c_person cursor definition to optimize query
	CURSOR	c_person(cp_person_id hz_parties.party_id%TYPE) IS
  		SELECT	person_id
  		FROM	igs_pe_person_base_v
  		WHERE	person_id = cp_person_id;
  BEGIN
  	-- validate the person_id is valid
  	OPEN c_person(p_person_id);
  	FETCH c_person INTO v_person_id;
  	IF (c_person%NOTFOUND) THEN
  		CLOSE c_person;
  		p_message_name   := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_person;
  	p_message_name   := Null;
  	RETURN TRUE;
  END;

  END genp_val_prsn_id;
END IGS_CO_VAL_SCOTR;

/
