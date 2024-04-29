--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_EC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_EC" AS
/* $Header: IGSEN34B.pls 115.4 2002/11/28 23:57:29 nsidana ship $ */
  --
  --
  -- bug id : 1956374
  -- sjadhav ,28-aug-2001
  -- removed FUNCTION enrp_val_ec_closed
  --
  -- Validate update of enrolment category closed indicator.
  FUNCTION enrp_val_ec_clsd_upd(
  p_enrolment_cat IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_ec_clsd_upd
  	-- Validate update of the IGS_EN_ENROLMENT_CAT.closed_ind.
  DECLARE
  	v_check		VARCHAR2(1);
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  	CURSOR c_ecm IS
  		SELECT	'x'
  		FROM	IGS_EN_CAT_MAPPING
  		WHERE	enrolment_cat = p_enrolment_cat AND
  			dflt_cat_ind = 'Y';
  BEGIN
  	p_message_name := null;
  	IF (p_closed_ind = 'Y') THEN
  		-- Validate if the enrolment category is the default for an admission category
  		OPEN c_ecm;
  		FETCH c_ecm INTO v_check;
  		IF (c_ecm%FOUND) THEN
  			p_message_name := 'IGS_EN_ENRCAT_NOTCLOSED';
  			v_ret_val := FALSE;
  		END IF;
  		CLOSE c_ecm;
  	END IF;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_EC.enrp_val_ec_clsd_upd');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_ec_clsd_upd;
  --
END IGS_EN_VAL_EC;

/
