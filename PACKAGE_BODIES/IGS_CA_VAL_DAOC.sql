--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_DAOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_DAOC" AS
/* $Header: IGSCA12B.pls 115.4 2002/11/28 22:58:54 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "calp_val_sdoct_clsd"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "calp_val_sdoct_clash"
  -------------------------------------------------------------------------------------------

  --
  -- Validate if date alias offset constraints exist.
  FUNCTION calp_val_daoc_exist(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail	VARCHAR2(255);
  BEGIN	--calp_val_daoc_exist
  	--This module Validates if date alias offset constraints
  	-- exist for the date alias offset.
  DECLARE
  	v_daoc_exists	VARCHAR2(1);
  	CURSOR c_daoc IS
  		SELECT 	'X'
  		FROM	IGS_CA_DA_OFST	dao,
  			IGS_CA_DA_OFFCNT	daoc
  		WHERE	dao.dt_alias = p_dt_alias AND
  			daoc.dt_alias = dao.dt_alias;
  BEGIN
  	--Set the default message number
  	p_message_name := NULL;
  	--If record exists then constraints exist, therefore set
  	-- p_message_name (warning only).
  	OPEN c_daoc;
  	FETCH c_daoc INTO v_daoc_exists;
  	IF (c_daoc%FOUND) THEN
  		p_message_name := 'IGS_CA_MORE_CONSTRAINTS_EXIST';
  		CLOSE c_daoc;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_daoc;
  	RETURN TRUE;
  END;
   END calp_val_daoc_exist;
END IGS_CA_VAL_DAOC;

/
