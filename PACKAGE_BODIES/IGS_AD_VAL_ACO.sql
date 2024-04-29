--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACO" AS
 /* $Header: IGSAD29B.pls 115.4 2002/11/28 21:29:00 nsidana ship $ */
  --
  -- Validate the Tertiary Admissions Centre admission code closed ind
  FUNCTION admp_val_tac_closed(
  p_tac_admission_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	CURSOR c_tac IS
  		SELECT	closed_ind
  		FROM	IGS_AD_TAC_AD_CD
  		WHERE	tac_admission_cd = p_tac_admission_cd;
  	v_tac_rec			c_tac%ROWTYPE;
  BEGIN
  	-- Check if the tac_admission_cd is closed
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cursor handling
  	OPEN c_tac  ;
  	FETCH c_tac INTO v_tac_rec;
  	IF c_tac%NOTFOUND THEN
  		CLOSE c_tac;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_tac;
  	IF (v_tac_rec.closed_ind = 'Y') THEN
  		p_message_name := 'IGS_AD_TRTY_ADMCD_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACO.admp_val_tac_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_tac_closed;
  --
  -- Validate if IGS_AD_BASIS_FOR_AD.basis_for_admission_type is closed.


END IGS_AD_VAL_ACO;

/
