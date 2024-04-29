--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AAS" AS
/* $Header: IGSAD19B.pls 120.0 2005/06/02 00:05:25 appldev noship $ */

  --
  -- Validate against the system adm application status closed indicator.
  FUNCTION admp_val_saas_clsd(
  p_s_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	--AMDP_VAL_SAAS_CLSD
  	--Check if the s_adm_appl_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_saas IS
  		SELECT	slv.closed_ind
  		FROM	IGS_LOOKUP_VALUES slv
  		WHERE   slv.lookup_type = 'ADM_APPL_STATUS' AND
		        slv.Lookup_code = p_s_adm_appl_status;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_saas;
  	FETCH c_saas INTO v_closed_ind;
  	IF (c_saas%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
			p_message_name := 'IGS_AD_SYSADM_APPL_STATUS_CLS';
  			CLOSE c_saas;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_saas;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AAS.admp_val_saas_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_saas_clsd;
  --
  -- Process AAS rowids in a PL/SQL TABLE for the current commit.
  --
  -- Validate the admission application status system default indicator.
  FUNCTION admp_val_aas_dflt(
  p_adm_appl_status IN VARCHAR2 ,
  p_s_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN   -- ADMP_VAL_AAS_DFLT
  	-- Check if another adm_appl_status record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_APPL_STAT.system_default_ind%TYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  	CURSOR c_count(cp_adm_appl_status	IGS_AD_APPL_STAT.adm_appl_status%TYPE,
  			cp_s_adm_appl_status IGS_AD_APPL_STAT.s_adm_appl_status%TYPE)IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_APPL_STAT aas
  		WHERE	aas.adm_appl_status <> cp_adm_appl_status AND
  			aas.s_adm_appl_status = cp_s_adm_appl_status AND
  			aas.system_default_ind = cst_yes
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	OPEN c_count(p_adm_appl_status, p_s_adm_appl_status);
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = cst_yes) THEN
				p_message_name := 'IGS_AD_SYSADM_APPLST_ONLY_ONE';
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
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AAS.admp_val_aas_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aas_dflt;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

END IGS_AD_VAL_AAS;

/
