--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AFS" AS
/* $Header: IGSAD33B.pls 120.0 2005/06/01 22:34:50 appldev noship $ */
  --
  -- Validate against the system admission fee status closed indicator.
  FUNCTION admp_val_safs_clsd(
  p_s_adm_fee_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN	--AMDP_VAL_SAFS_CLSD
  	--Check if the s_adm_fee_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_safs IS
  		SELECT	safs.closed_ind
  		FROM	IGS_LOOKUP_VALUES safs
  		WHERE   safs.lookup_type = 'ADM_FEE_STATUS' AND
		        safs.lookup_code = p_s_adm_fee_status;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_safs;
  	FETCH c_safs INTO v_closed_ind;
  	IF (c_safs%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_FEE_STATUS_CLS';
  			CLOSE c_safs;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_safs;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AFS.admp_val_safs_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_safs_clsd;

  -- Validate the admission fee status system default indicator.
  FUNCTION admp_val_afs_dflt(
  p_adm_fee_status IN VARCHAR2 ,
  p_s_adm_fee_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_AFS_DFLT
  	-- Check if another adm_fee_status record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_FEE_STAT.system_default_ind%TYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  	CURSOR c_count (cp_adm_fee_status	IGS_AD_FEE_STAT.adm_fee_status%TYPE,
  			cp_s_adm_fee_status IGS_AD_FEE_STAT.s_adm_fee_status%TYPE)IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_FEE_STAT afs
  		WHERE	afs.adm_fee_status <> cp_adm_fee_status AND
  			afs.s_adm_fee_status = cp_s_adm_fee_status AND
  			afs.system_default_ind = cst_yes
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_count(p_adm_fee_status, p_s_adm_fee_status);
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = cst_yes) THEN
  				p_message_name := 'IGS_AD_SYSADM_FEEST_ONLY_ONE';
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
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AFS.admp_val_afs_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_afs_dflt;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

END IGS_AD_VAL_AFS;

/
