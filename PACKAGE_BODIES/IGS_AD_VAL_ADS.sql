--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ADS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ADS" AS
/* $Header: IGSAD31B.pls 120.0 2005/06/02 03:40:56 appldev noship $ */
  -- Check against the system adm documentatio status closed indcator.
  FUNCTION admp_val_sads_clsd(
  p_s_adm_doc_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--AMDP_VAL_SADS_CLSD
  	--Check if the s_adm_doc_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_sads IS
  		SELECT	sads.closed_ind
  		FROM	IGS_LOOKUP_VALUES sads
  		WHERE   sads.lookup_type = 'ADM_DOC_STATUS' AND
		        sads.lookup_code = p_s_adm_doc_status;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_sads;
  	FETCH c_sads INTO v_closed_ind;
  	IF (c_sads%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_DOC_STATUS_CLS';
  			CLOSE c_sads;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sads;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                     App_Exception.Raise_Exception;
  END admp_val_sads_clsd;
  --

  --
  -- Validate the admission documentation status system default indicator.
  FUNCTION admp_val_ads_dflt(
  p_adm_doc_status IN VARCHAR2 ,
  p_s_adm_doc_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_ADS_DFLT
  	-- Check if another adm_doc_status record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_DOC_STAT.system_default_ind%TYPE;
  	CURSOR c_count IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_DOC_STAT ads
  		WHERE	ads.adm_doc_status <> p_adm_doc_status AND
  			ads.s_adm_doc_status = p_s_adm_doc_status AND
  			ads.system_default_ind = 'Y'
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_count;
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = 'Y') THEN
  				p_message_name := 'IGS_AD_SYSADM_DOCST_ONLY_ONE';
  				CLOSE c_count;
  				RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_count;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                     App_Exception.Raise_Exception;
  END admp_val_ads_dflt;
  --

END IGS_AD_VAL_ADS;

/
