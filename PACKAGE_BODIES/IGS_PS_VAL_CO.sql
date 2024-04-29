--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CO" AS
/* $Header: IGSPS23B.pls 115.4 2002/11/29 02:59:21 nsidana ship $ */

  --
  -- Validate IGS_PS_COURSE Offering Calendar Type.
  FUNCTION crsp_val_co_cal_type(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	cst_academic	CONSTANT VARCHAR2(10) := 'ACADEMIC';
  	v_closed_ind	IGS_CA_TYPE.closed_ind%TYPE;
  	v_s_cal_cat	IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR 	c_cal_type(
  			cp_cal_type IGS_CA_TYPE.cal_type%TYPE)IS
  		SELECT 	closed_ind,s_cal_cat
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type = cp_cal_type;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_cal_type(
  		p_cal_type);
  	FETCH c_cal_type INTO v_closed_ind, v_s_cal_cat;
  	CLOSE c_cal_type;
  	IF (v_closed_ind = 'N' AND v_s_cal_cat = cst_academic) THEN
  		RETURN TRUE;
  	ELSIF (v_closed_ind <> 'N') THEN
  		p_message_name := 'IGS_CA_CALTYPE_CLOSED';
  		RETURN FALSE;
  	ELSE
  		p_message_name := 'IGS_PS_CALCAT_MUSTBE_ACADEMIC';
  		RETURN FALSE;
  	END IF;
  END crsp_val_co_cal_type;
END IGS_PS_VAL_CO;

/
