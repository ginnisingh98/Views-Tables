--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AORS" AS
/* $Header: IGSAD35B.pls 120.0 2005/06/01 18:55:14 appldev noship $ */
  --
  -- Validate against the system adm offer response status closed indicator
  FUNCTION admp_val_saors_clsd(
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--AMDP_VAL_SAORS_CLSD
  	--Check if the s_adm_offer_resp_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_saors IS
  		SELECT	saors.closed_ind
  		FROM	IGS_LOOKUP_VALUES saors
  		WHERE   saors.lookup_type = 'ADM_OFFER_RESP_STATUS' AND
		        saors.lookup_code = p_s_adm_offer_resp_status;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_saors;
  	FETCH c_saors INTO v_closed_ind;
  	IF (c_saors%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_OFFERRES_ST_CLS';
  			CLOSE c_saors;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_saors;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AORS.admp_val_saors_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_saors_clsd;

  --
  -- Validate the admission offer response status system default indicator.
  FUNCTION admp_val_aors_dflt(
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_AORS_DFLT
  	-- Check if another IGS_AD_OFR_RESP_STAT record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_OFR_RESP_STAT.system_default_ind%TYPE;
  	CURSOR c_count IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_OFR_RESP_STAT aors
  		WHERE	aors.adm_offer_resp_status <> p_adm_offer_resp_status AND
  			aors.s_adm_offer_resp_status = p_s_adm_offer_resp_status AND
  			aors.system_default_ind = 'Y'
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_count;
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = 'Y') THEN
  				p_message_name := 'IGS_AD_SYSADM_OFRRESP_STATUS';
  				CLOSE c_count;
  				RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_count;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AORS.admp_val_aors_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aors_dflt;


END IGS_AD_VAL_AORS;

/
