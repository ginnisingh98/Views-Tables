--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_AUSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_AUSG" AS
/* $Header: IGSEN26B.pls 115.4 2002/11/28 23:55:30 nsidana ship $ */

  --
  -- Bug ID : 1956374
  -- sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_aus_closed
  -- removed function enrp_val_aus_discont
  --
  -- Validate the administrative unit status grade against grading schema
  FUNCTION enrp_val_ausg_gs(
  p_grading_schema_code IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_sdate			DATE;
  	v_edate			DATE;
  	CURSOR c_grading_schema IS
  		SELECT	start_dt
  			,end_dt
  		FROM	IGS_AS_GRD_SCHEMA
  		WHERE	grading_schema_cd = p_grading_schema_code AND
  			version_number = p_version_number;
  BEGIN
  	-- Check if the grading schema is current
  	p_message_name := null;
  	OPEN c_grading_schema;
  	FETCH c_grading_schema INTO v_sdate
  				    ,v_edate;
  	IF  (c_grading_schema%NOTFOUND) THEN
  		CLOSE c_grading_schema;
  		RETURN TRUE;
  	END IF;
  	IF  v_edate IS NULL THEN
  	    IF	(v_sdate <= trunc(sysdate)) THEN
  		CLOSE c_grading_schema;
  		RETURN TRUE;
  	    END IF;
  	ELSE
  	    IF	(v_sdate <= trunc(sysdate) AND trunc(sysdate) <= v_edate) THEN
  		CLOSE c_grading_schema;
  		RETURN TRUE;
  	    END IF;
  	END IF;
  	p_message_name := 'IGS_EN_INVALID_GRAD_SCHMEA';
  	CLOSE c_grading_schema;
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_AUSG.enrp_val_ausg_gs');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_ausg_gs;
END IGS_EN_VAL_AUSG;

/
