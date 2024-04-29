--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_ASST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_ASST" AS
/* $Header: IGSAS14B.pls 115.5 2002/11/28 22:42:51 nsidana ship $ */

  --
  -- Validate assessor type dflt ind set at least and only once.
  FUNCTION assp_val_asst_dflt(
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_asst_dflt
  	-- Validate the assessor type default indicator is set
  	-- at least and only once
  DECLARE
  	cst_yes			CONSTANT 	CHAR := 'Y';
  	cst_no			CONSTANT 	CHAR := 'N';
  	v_asst_count		NUMBER;
  	CURSOR c_asst IS
  		SELECT	COUNT(*)
  		FROM	IGS_AS_ASSESSOR_TYPE
  		WHERE	dflt_ind = cst_yes AND
  			closed_ind = cst_no;
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Cursor handling
  	OPEN c_asst;
  	FETCH c_asst INTO v_asst_count;
  	IF c_asst%NOTFOUND THEN
  		CLOSE c_asst;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_asst;
  	-- Check the selected data
  	IF (v_asst_count = 0) THEN
  		P_MESSAGE_NAME := 'IGS_AS_ONE_ASSESSORTYPE_DFLT';
  		RETURN FALSE;
  	ELSIF (v_asst_count > 1) THEN
  		P_MESSAGE_NAME := 'IGS_AS_MORE_ASSESSORTYPE_DFLT';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	  Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_014.assp_val_asst_dflt');
	  IGS_GE_MSG_STACK.ADD;
  END assp_val_asst_dflt;
END IGS_AS_VAL_ASST;

/
