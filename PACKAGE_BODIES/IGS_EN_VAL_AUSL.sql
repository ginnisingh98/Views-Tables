--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_AUSL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_AUSL" AS
/* $Header: IGSEN27B.pls 115.4 2002/11/28 23:55:44 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (STAP_VAL_CI_STATUS) - from the spec and body. -- kdande
--msrinivi bug 1956374 Removed func genp_prc_clear_rowid
*/
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed enrp_val_aus_closed
  --
  -- Validate the AUS UNIT attempt status is 'DISCONTIN'
  FUNCTION enrp_val_ausl_aus(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_unit_att_status	IGS_AD_ADM_UNIT_STAT.unit_attempt_status%TYPE;
  	CURSOR c_aus IS
  		SELECT	unit_attempt_status
  		FROM	IGS_AD_ADM_UNIT_STAT
  		WHERE	administrative_unit_status = p_aus;
  BEGIN
  	-- Check if the IGS_AD_ADM_UNIT_STAT is closed
  	p_message_name := null;
  	OPEN c_aus;
  	FETCH c_aus INTO v_unit_att_status;
  	IF  (c_aus%NOTFOUND) THEN
  		CLOSE c_aus;
  		RETURN TRUE;
  	END IF;
  	IF  (v_unit_att_status <> 'DISCONTIN') THEN
  		CLOSE c_aus;
  		p_message_name := 'IGS_EN_LOAD_APPLICABLE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_aus;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_AUSL.enrp_val_ausl_aus');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_ausl_aus;
END IGS_EN_VAL_AUSL;

/
