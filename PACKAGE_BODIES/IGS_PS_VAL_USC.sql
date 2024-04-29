--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_USC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_USC" AS
/* $Header: IGSPS69B.pls 115.5 2002/11/29 03:10:07 nsidana ship $ */

  --
  -- Validate IGS_PS_UNIT set cat rank changes if IGS_PS_UNIT sets exist for the category
  FUNCTION crsp_val_usc_us(
  p_unit_set_cat IN VARCHAR2 ,
  p_old_rank IN NUMBER ,
  p_new_rank IN NUMBER ,
  p_old_s_unit_set_cat IN VARCHAR2,
  p_new_s_unit_set_cat IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_usc_us
  	-- This module provides a warning if the IGS_PS_UNIT set is active
  	-- when the IGS_PS_UNIT set category is being changed.
  DECLARE
  	v_s_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	CURSOR c_us IS
  		SELECT	us.unit_set_cd
  		FROM	IGS_EN_UNIT_SET	us
  		WHERE	us.unit_set_cat = p_unit_set_cat;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;

       IF (p_old_rank <> p_new_rank) OR (p_old_s_unit_set_cat <> p_new_s_unit_set_cat) THEN
  		OPEN c_us;
  		FETCH c_us INTO v_s_unit_set_status;
  		IF (c_us%FOUND) THEN
  			CLOSE c_us;
  			p_message_name := 'IGS_PS_UNIT_SET_EXIST';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_us;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_us%ISOPEN) THEN
  			CLOSE c_us;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_USc.crsp_val_usc_us');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_usc_us ;
END IGS_PS_VAL_USc;

/
