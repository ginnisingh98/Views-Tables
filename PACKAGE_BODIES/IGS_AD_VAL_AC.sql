--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AC" AS
/* $Header: IGSAD20B.pls 115.5 2003/01/08 14:30:57 rghosh ship $ */

  --
  -- Validate if the IGS_AD_CAT record can be updated.
  FUNCTION admp_val_ac_upd(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN
  DECLARE
  	v_admission_cat		IGS_AD_CAT.admission_cat%TYPE;
  	CURSOR c_apc IS
  		SELECT		apc.admission_cat
  		FROM		IGS_AD_PRCS_CAT apc
  		WHERE	apc.admission_cat = p_admission_cat
		AND     closed_ind = 'N';                    --added the closed indicator for bug# 2380108 (rghosh)
  BEGIN
  	-- Validate if the admission_cat can be updated
  	p_message_name := null;
  	OPEN c_apc;
  	FETCH c_apc INTO v_admission_cat;
  	IF (c_apc%FOUND) THEN
		p_message_name := 'IGS_AD_ADMCAT_CANNOT_UPDATED';
  		CLOSE c_apc;
  		RETURN FALSE;
  	ELSE
  		CLOSE c_apc;
  		RETURN TRUE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AC.admp_val_ac_upd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_ac_upd;

END IGS_AD_VAL_AC;

/
