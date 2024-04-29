--------------------------------------------------------
--  DDL for Package Body IGS_AV_VAL_ASULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_VAL_ASULE" AS
/* $Header: IGSAV06B.pls 115.7 2003/04/14 09:57:18 anilk ship $ */

--
-- bug id : 1956374
-- sjadhav  , 28-aug-2001
-- removed ENRP_VAL_EXCLD_PRSN
--

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed

  --
  -- Validate the IGS_PS_UNIT level closed indicator.
  FUNCTION advp_val_ule_closed(
  p_unit_level IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN
  DECLARE
  	v_other_detail		VARCHAR2(255);
  	v_closed_ind		CHAR;
  	CURSOR c_unit_level IS
  		SELECT	closed_ind
  		FROM	IGS_PS_UNIT_LEVEL
  		WHERE	unit_level = p_unit_level;
  BEGIN
  	-- Check if the IGS_PS_UNIT level is closed
  	 p_message_name := null;
  	OPEN c_unit_level;
  	FETCH c_unit_level INTO v_closed_ind;
  	IF (c_unit_level%NOTFOUND) THEN
  		CLOSE c_unit_level;
  		RETURN TRUE;
  	END IF;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_UNITLVL_CLOSED';
  		CLOSE c_unit_level;
  		RETURN FALSE;
  	END IF;
  	-- record is not closed
  	CLOSE c_unit_level;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AV_VAL_ASULE.ADVP_VAL_ULE_CLOSED');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;

  END;
  END advp_val_ule_closed;


END IGS_AV_VAL_ASULE;

/
