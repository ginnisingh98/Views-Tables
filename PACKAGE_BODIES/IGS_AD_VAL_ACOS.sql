--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACOS" AS
/* $Header: IGSAD30B.pls 120.1 2005/09/08 14:50:23 appldev noship $ */
  --
  -- Validate against the system adm conditional offer status closed ind.
  FUNCTION admp_val_sacoos_clsd(
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--AMDP_VAL_SACOOS_CLSD
  	--Check if the s_adm_cndtnl_offer_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_sacos IS
  		SELECT	sacos.closed_ind
  		FROM	IGS_LOOKUP_VALUES sacos
  		WHERE   sacos.lookup_type = 'ADM_CNDTNL_OFFER_STATUS' AND
		        sacos.lookup_code = p_s_adm_cndtnl_offer_status;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_sacos;
  	FETCH c_sacos INTO v_closed_ind;
  	IF (c_sacos%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_COND_STATUS_CLS';
  			CLOSE c_sacos;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sacos;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACOS.admp_val_sacoos_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_sacoos_clsd;

  -- Validate the admission conditional offer status system default ind.
  FUNCTION admp_val_acos_dflt(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_ACOS_DFLT
  	-- Check if another adm_cndtnl_offer_status record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_CNDNL_OFRSTAT.system_default_ind%TYPE;
  	CURSOR c_count IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_CNDNL_OFRSTAT acos
  		WHERE	acos.adm_cndtnl_offer_status <> p_adm_cndtnl_offer_status AND
  			acos.s_adm_cndtnl_offer_status = p_s_adm_cndtnl_offer_status AND
  			acos.system_default_ind = 'Y'
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_count;
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = 'Y') THEN
  				p_message_name := 'IGS_AD_SYSADM_CNDOFR_ONLY_ONE';
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
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACOS.admp_val_acos_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_acos_dflt;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

END IGS_AD_VAL_ACOS;

/
