--------------------------------------------------------
--  DDL for Package Body IGS_OR_VAL_LOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_VAL_LOT" AS
/* $Header: IGSOR06B.pls 115.4 2002/11/29 01:47:11 nsidana ship $ */
  FUNCTION assp_val_lot_loc(
  p_location_type  IGS_AD_LOCATION_TYPE_ALL.location_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN  AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_lot_loc
  	-- This module validates that the system location type for a location
  	-- type can not be changed once locations have been created.
  DECLARE
  	CURSOR	c_loc IS
  	SELECT	'x'
  	FROM	IGS_AD_LOCATION
  	WHERE	location_type	= p_location_type;
  	v_loc_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_loc;
  	FETCH c_loc INTO v_loc_exists;
  	IF (c_loc%FOUND) THEN
  		CLOSE c_loc;
  		-- The system location type may not be changed for this
  		-- location type as location records already exist.
  		p_message_name := 'IGS_AS_SYS_LOCTYPE_NOTCHG';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_loc;
  	-- Validation successful
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception ;
  END assp_val_lot_loc;
END IGS_OR_VAL_LOT;

/
