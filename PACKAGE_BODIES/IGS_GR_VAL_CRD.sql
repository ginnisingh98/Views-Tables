--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_CRD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_CRD" AS
/* $Header: IGSGR06B.pls 115.5 2002/11/29 00:40:22 nsidana ship $ */
  --
  -- Validate if the calendar instance has a category of GRADUATION
  FUNCTION grdp_val_ci_grad(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_ci_grad
  	-- Validate that the IGS_CA_TYPE specified has a SI_CA_S_CA_CAT
  	-- of GRADUATION.
  DECLARE
  	v_ct_found		VARCHAR2(1);
  	cst_graduation		CONSTANT VARCHAR2(10) := 'GRADUATION';
  	CURSOR	c_ct IS
  		SELECT	'x'
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type	= p_cal_type AND
  			s_cal_cat	= cst_graduation;
  BEGIN
  	p_message_name := NULL;
  	-- Check paramter
  	IF p_cal_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Check for IGS_CA_TYPE records with a IGS_CA_TYPE of p_cal_type and a
  	-- SI_CA_S_CA_CAT of GRADUATION.
  	OPEN c_ct;
  	FETCH c_ct INTO v_ct_found;
  	IF (c_ct%NOTFOUND) THEN
  		CLOSE c_ct;
  		p_message_name := 'IGS_GR_CERM_CAL_MUST_BE_GRAD';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ct;
  	-- Return no error
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_ci_grad;
  --
  -- To validate the calendar instance system cal status is not 'INACTIVE'

END IGS_GR_VAL_CRD;

/
