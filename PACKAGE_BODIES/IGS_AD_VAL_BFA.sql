--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_BFA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_BFA" AS
/* $Header: IGSAD47B.pls 115.4 2002/11/28 21:34:14 nsidana ship $ */

  -- Validate the government basis for admission type closed indicator.
  FUNCTION admp_val_gbfat_clsd(
  p_govt_basis_for_adm_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_gbfat IS
  		SELECT	closed_ind
  		FROM	IGS_AD_GOV_BAS_FR_TY
  		WHERE	govt_basis_for_adm_type = p_govt_basis_for_adm_type;
  	v_gbfat_rec		c_gbfat%ROWTYPE;
  BEGIN
  	-- Check if the IGS_AD_GOV_BAS_FR_TY is closed
  	-- Set the default message number
  	p_message_name := Null;
  	-- Cursor handling
  	OPEN c_gbfat;
  	FETCH c_gbfat INTO v_gbfat_rec;
  	IF c_gbfat%NOTFOUND THEN
  		CLOSE c_gbfat;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_gbfat;
  	IF (v_gbfat_rec.closed_ind = 'Y') THEN
  		p_message_name := 'IGS_AD_GOVT_BASIS_ADMTYPE_CLS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_BFA.admp_val_gbfat_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_gbfat_clsd;

END IGS_AD_VAL_BFA;

/
