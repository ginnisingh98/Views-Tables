--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_GBFAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_GBFAT" AS
/* $Header: IGSAD62B.pls 115.3 2002/11/28 21:37:47 nsidana ship $ */

  --
  -- Validate the update of a government basis for admission type record
  FUNCTION admp_val_gbfat_upd(
  p_govt_basis_for_adm_type IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	CURSOR c_gbfat IS
  		SELECT	COUNT(*)
  		FROM	IGS_AD_BASIS_FOR_AD
  		WHERE	govt_basis_for_adm_type = p_govt_basis_for_adm_type AND
  			closed_ind = 'N';
  	v_gbfat_count		NUMBER;
  BEGIN
  	-- Validate the update of a govt_basis_for_adm_type record. A record cannot
  	-- be closed if there are records mapped onto it which are still open.
  	-- Set the default message number
  	p_message_name := null;
  	IF (p_closed_ind = 'Y') THEN
  		-- Cursor handling
  		OPEN c_gbfat;
  		FETCH c_gbfat INTO v_gbfat_count;
  		IF c_gbfat%NOTFOUND THEN
  			CLOSE c_gbfat;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_gbfat;
  		IF (v_gbfat_count > 0) THEN
			p_message_name := 'IGS_AD_CANNOT_CLS_GOVT_ADMTYP';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_GBFAT.admp_val_gbfat_upd');
  	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
  END admp_val_gbfat_upd;
END IGS_AD_VAL_GBFAT;

/
