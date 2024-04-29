--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AODS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AODS" AS
 /* $Header: IGSAD34B.pls 120.0 2005/06/01 16:19:49 appldev noship $ */
  --
  -- Validate against system adm offer deferement status closed indicator.
  FUNCTION admp_val_saods_clsd(
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--AMDP_VAL_SAODS_CLSD
  	--Check if the s_adm_offer_dfrmnt_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_saods IS
  		SELECT	saods.closed_ind
  		FROM	IGS_LOOKUP_VALUES saods
  		WHERE   saods.lookup_type = 'ADM_OFFER_DFRMNT_STATUS' AND
		        saods.lookup_code = p_s_adm_offer_dfrmnt_status ;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_saods;
  	FETCH c_saods INTO v_closed_ind;
  	IF (c_saods%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_OFFERDFR_ST_CLS';
  			CLOSE c_saods;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_saods;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AODS.admp_val_saods_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_saods_clsd;

  --
  -- Validate the admission offer deferement status system default ind.
  FUNCTION admp_val_aods_dflt(
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_AODS_DFLT
  	-- Check if another IGS_AD_OFRDFRMT_STAT record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_OFRDFRMT_STAT.system_default_ind%TYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  	CURSOR c_count(cp_adm_offer_dfrmnt_status
  			IGS_AD_OFRDFRMT_STAT.adm_offer_dfrmnt_status%TYPE,
  			cp_s_adm_offer_dfrmnt_status
  			IGS_AD_OFRDFRMT_STAT.s_adm_offer_dfrmnt_status%TYPE)IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_OFRDFRMT_STAT aods
  		WHERE	aods.adm_offer_dfrmnt_status <> cp_adm_offer_dfrmnt_status AND
  			aods.s_adm_offer_dfrmnt_status = cp_s_adm_offer_dfrmnt_status AND
  			aods.system_default_ind = cst_yes
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_count(p_adm_offer_dfrmnt_status, p_s_adm_offer_dfrmnt_status);
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = 'Y') THEN
  				p_message_name := 'IGS_AD_SYSADM_OFRDFR_ONLY_ONE';
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
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AODS.admp_val_aods_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aods_dflt;


END IGS_AD_VAL_AODS;

/
