--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SCAE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SCAE" AS
/* $Header: IGSEN62B.pls 115.3 2002/11/29 00:05:56 nsidana ship $ */
  --
  -- Validate the student COURSE attempt enrolment category.
  FUNCTION ENRP_VAL_SCAE_EC(
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
   	v_closed_ind	VARCHAR2(1);
  	CURSOR	c_enrolment_cat IS
  		SELECT closed_ind
  		FROM	IGS_EN_ENROLMENT_CAT
  		WHERE	enrolment_cat = p_enrolment_cat;
  BEGIN
  	-- Validate if stdnt_crs_atmpt_enr.enrolment_cat is open
  	p_message_name := null;
  	OPEN c_enrolment_cat;
  	FETCH c_enrolment_cat INTO v_closed_ind;
  	IF (c_enrolment_cat%NOTFOUND) THEN
  		CLOSE c_enrolment_cat;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_enrolment_cat;
  	IF (v_closed_ind = 'N') THEN
  		RETURN TRUE;
  	END IF;
  	-- IGS_EN_ENROLMENT_CAT is closed
  	p_message_name := 'IGS_EN_ENR_CAT_CLOSED';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCAE.enrp_val_scae_ec');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END enrp_val_scae_ec;
END IGS_EN_VAL_SCAE;

/
