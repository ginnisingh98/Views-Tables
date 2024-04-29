--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_AIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_AIA" AS
/* $Header: IGSAS12B.pls 115.8 2003/12/05 11:03:51 kdande ship $ */
  --
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  --
  -- Validate assessment assessor type closed indicator.
  FUNCTION assp_val_asst_closed(
  p_ass_assessor_type IN IGS_AS_ASSESSOR_TYPE.ass_assessor_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN 	-- assp_val_asst_closed
  	-- Validate the assessemnt assessor type closed indicator
  DECLARE
  	CURSOR c_asst(
  			cp_ass_assessor_type	IGS_AS_ASSESSOR_TYPE.ass_assessor_type%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AS_ASSESSOR_TYPE
  		WHERE	ass_assessor_type = cp_ass_assessor_type;
  	v_asst_rec		c_asst%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Cursor handling
  	OPEN c_asst(
  			p_ass_assessor_type);
  	FETCH c_asst INTO v_asst_rec;
  	IF c_asst%NOTFOUND THEN
  		CLOSE c_asst;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_asst;
  	IF (v_asst_rec.closed_ind = cst_yes) THEN
  		P_MESSAGE_NAME := 'IGS_GE_RECORD_ALREADY_EXISTS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_012.assp_val_asst_closed');
	IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_asst_closed;

  -- Validate only one primary assessor per assessment item
  FUNCTION assp_val_aia_primary(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_person_id IN IGS_AS_ITEM_ASSESSOR.person_id%TYPE ,
  p_sequence_number IN IGS_AS_ITEM_ASSESSOR.sequence_number%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_aia_primary
  	-- Validate that there is only one primary assessor per assessment item. As
  	-- the
  	-- same assessor can occur multiple times for an assessment item, we also need
  	-- to
  	-- validate that the other assessor records for the person have the indicator
  	-- set.
  DECLARE
  	cst_yes				CONSTANT CHAR := 'Y';
  	cst_no				CONSTANT CHAR := 'N';
  	CURSOR c_aia1(
  			cp_ass_id		IGS_AS_ITEM_ASSESSOR.ass_id%TYPE,
  			cp_person_id	IGS_AS_ITEM_ASSESSOR.person_id%TYPE) IS
  		SELECT	COUNT(*)
  		FROM	IGS_AS_ITEM_ASSESSOR
  		WHERE	ass_id = cp_ass_id AND
  			person_id <> cp_person_id AND
  			primary_assessor_ind = cst_yes;
  	CURSOR c_aia2(
  			cp_ass_id		IGS_AS_ITEM_ASSESSOR.ass_id%TYPE,
  			cp_person_id	IGS_AS_ITEM_ASSESSOR.person_id%TYPE,
  			cp_sequence_number	IGS_AS_ITEM_ASSESSOR.sequence_number%TYPE) IS
  		SELECT	COUNT(*)
  		FROM	IGS_AS_ITEM_ASSESSOR
  		WHERE	ass_id = cp_ass_id AND
  			person_id = cp_person_id AND
  			sequence_number <> cp_sequence_number AND
  			primary_assessor_ind = cst_no;
  	v_aia1_count			NUMBER;
  	v_aia2_count			NUMBER;
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Validate no other PERSON is tagged as the primary assessor
  	OPEN c_aia1(
  			p_ass_id,
  			p_person_id);
  	FETCH c_aia1 INTO v_aia1_count;
  	CLOSE c_aia1;
  	IF (v_aia1_count > 0) THEN
  		P_MESSAGE_NAME := 'IGS_AS_ONE_PRSN_IDENTIFY_PRIM';
  		RETURN FALSE;
  	END IF;

  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_012.assp_val_aia_primary');
	IGS_GE_MSG_STACK.ADD;
		--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_aia_primary;
  --
  -- Validate assessor links for invalid combinations.
  FUNCTION assp_val_aia_links(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_person_id IN IGS_AS_ITEM_ASSESSOR.person_id%TYPE ,
  p_sequence_number IN IGS_AS_ITEM_ASSESSOR.sequence_number%TYPE ,
  p_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_unit_mode IN IGS_AS_ITEM_ASSESSOR.unit_mode%TYPE ,
  p_unit_class IN IGS_AS_ITEM_ASSESSOR.unit_class%TYPE ,
  p_ass_assessor_type IN IGS_AS_ITEM_ASSESSOR.ass_assessor_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	p_message_name := NULL;
		RETURN TRUE;
  END assp_val_aia_links;
  --
  -- Generic links validation routine.
  FUNCTION ASSP_VAL_OPTNL_LINKS(
  p_new_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_new_unit_mode IN IGS_AS_ITEM_ASSESSOR.unit_mode%TYPE ,
  p_new_unit_class IN IGS_AS_ITEM_ASSESSOR.unit_class%TYPE ,
  p_db_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_db_unit_mode IN IGS_AS_ITEM_ASSESSOR.unit_mode%TYPE ,
  p_db_unit_class IN IGS_AS_ITEM_ASSESSOR.unit_class%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	p_message_name := NULL;
  	RETURN TRUE;
  END assp_val_optnl_links;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- Process AIA rowids in a PL/SQL TABLE for the current commit.

END IGS_AS_VAL_AIA;

/
