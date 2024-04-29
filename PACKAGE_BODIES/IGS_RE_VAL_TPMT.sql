--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_TPMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_TPMT" AS
/* $Header: IGSRE18B.pls 115.3 2002/11/29 03:30:55 nsidana ship $ */
  --
  -- To validate thesis panel member type tracking type value
  FUNCTION RESP_VAL_TPMT_TRT(
  p_tracking_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpmt_trt
  	-- Validate IGS_RE_THS_PNL_MR_TP.tracking_type.
  DECLARE
  	CURSOR c_trt IS
  		SELECT	'x'
  		FROM	IGS_TR_TYPE	trt
  		WHERE	trt.tracking_type	= p_tracking_type AND
  			trt.closed_ind	= 'Y';
  	v_trt_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	If p_tracking_type IS NOT NULL THEN
  		-- Cursor handling
  		OPEN c_trt;
  		FETCH c_trt INTO v_trt_exists;
  		IF c_trt %FOUND THEN
  			CLOSE c_trt;
  			p_message_name := 'IGS_RE_TRK_TYPE_CLOSED';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_trt;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_trt %ISOPEN THEN
  			CLOSE c_trt;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpmt_trt;
END IGS_RE_VAL_TPMT;

/
