--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_GHL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_GHL" AS
/* $Header: IGSGR09B.pls 115.4 2002/11/29 00:41:10 nsidana ship $ */
  --
  -- Validate if government honours level is closed.
  FUNCTION grdp_val_ghl_closed(
  p_govt_honours_level IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--grdp_val_ghl_closed
  	--Validate if the government honours level is closed
  DECLARE
  	v_closed_ind		VARCHAR2(1);
  	CURSOR	c_ghl IS
  		SELECT	'x'
  		FROM	IGS_GR_GOVT_HNS_LVL
  		WHERE	govt_honours_level	= p_govt_honours_level AND
  			closed_ind		= 'Y';
  BEGIN
     	--set default message number
     	p_message_name := NULL;
  	OPEN c_ghl;
  	FETCH c_ghl INTO v_closed_ind;
  	IF c_ghl%FOUND THEN
  		CLOSE c_ghl;
  		p_message_name := 'IGS_GR_GOV_HNRS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ghl;
  	RETURN TRUE;
  EXCEPTION
     	WHEN OTHERS THEN
  		IF(c_ghl%ISOPEN) THEN
  			CLOSE c_ghl;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
     	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		App_Exception.Raise_Exception;
  END grdp_val_ghl_closed;
  --
  -- Validate no open honours level using govt honours level to be closed.
  FUNCTION grdp_val_ghl_upd(
  p_govt_honours_level IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_ghl_upd
  	-- This module validates that there are no open user defined honours level
  	-- records mapped to this government honours level.
  DECLARE
  	v_hl		IGS_GR_HONOURS_LEVEL.govt_honours_level%TYPE;
  	CURSOR c_hl IS
  		SELECT 	'x'
  		FROM	IGS_GR_HONOURS_LEVEL hl
  		WHERE	hl.govt_honours_level 	= p_govt_honours_level AND
  			hl.closed_ind 		= 'N';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_hl;
  		FETCH c_hl INTO v_hl;
  		IF (c_hl%ROWCOUNT) > 0 THEN
  			CLOSE c_hl;
  			p_message_name := 'IGS_GR_GOV_HNRS_CANNOT_CLOSED';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_hl;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_ghl_upd;
END IGS_GR_VAL_GHL;

/
