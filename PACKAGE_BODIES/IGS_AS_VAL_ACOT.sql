--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_ACOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_ACOT" AS
/* $Header: IGSAS10B.pls 115.4 2002/11/28 22:41:43 nsidana ship $ */
  -----
  -- Validate COURSE type closed indicator.
  FUNCTION crsp_val_cty_closed(
  p_course_type IN IGS_PS_TYPE_ALL.course_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  V_MESSAGE_NAME VARCHAR2(30);
  BEGIN 	-- crsp_val_cty_closed
  	-- Validate the COURSE type closed indicator
  DECLARE

  	CURSOR c_cty(
  			cp_course_type	IGS_PS_TYPE.course_type%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_PS_TYPE
  		WHERE	course_type = cp_course_type;
  	v_cty_rec			c_cty%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME :=NULL;
  	-- Cursor handling
  	OPEN c_cty(
  			p_course_type);
  	FETCH c_cty INTO v_cty_rec;
  	IF c_cty%NOTFOUND THEN
  		CLOSE c_cty;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cty;
  	IF (v_cty_rec.closed_ind = cst_yes) THEN
  		P_MESSAGE_NAME := 'IGS_PS_PRGTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;

  END crsp_val_cty_closed;
END IGS_AS_VAL_ACOT;

/
