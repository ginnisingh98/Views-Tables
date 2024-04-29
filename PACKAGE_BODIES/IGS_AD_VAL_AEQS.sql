--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AEQS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AEQS" AS
/* $Header: IGSAD32B.pls 120.0 2005/06/01 16:59:41 appldev noship $ */
  --
  -- Check against the system adm entry qualification status closed ind.
  FUNCTION admp_val_saeqs_clsd(
  p_s_adm_entry_qual_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--AMDP_VAL_SADS_CLSD
  	--Check if the s_adm_doc_status is closed
  DECLARE
  	v_closed_ind	VARCHAR(1);
  	CURSOR c_saeqs IS
  		SELECT	saeqs.closed_ind
  		FROM	IGS_LOOKUP_VALUES saeqs
  		WHERE   saeqs.lookup_type = 'ADM_ENTRY_QUAL_STATUS' AND
		        saeqs.lookup_code = p_s_adm_entry_qual_status;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_saeqs;
  	FETCH c_saeqs INTO v_closed_ind;
  	IF (c_saeqs%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_SYSADM_ENTRYSTATUS_CLS';
  			CLOSE c_saeqs;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_saeqs;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AEQS.admp_val_saeqs_clsd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_saeqs_clsd;
  --
  -- Process AEQS rowids in a PL/SQL TABLE for the current commit.

  -- Validate the admission entry qualification status system default ind.
  FUNCTION admp_val_aeqs_dflt(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_s_adm_entry_qual_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_AEQS_DFLT
  	-- Check if another adm_entry_qual_status record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_ENT_QF_STAT.system_default_ind%TYPE;
  	CURSOR c_count IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_ENT_QF_STAT aeqs
  		WHERE	aeqs.adm_entry_qual_status <> p_adm_entry_qual_status AND
  			aeqs.s_adm_entry_qual_status = p_s_adm_entry_qual_status AND
  			aeqs.system_default_ind = 'Y'
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_count;
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = 'Y') THEN
  				p_message_name := 'IGS_AD_SYSADM_ENTRY_ONLY_ONE';
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
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AEQS.admp_val_aeqs_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aeqs_dflt;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.


END IGS_AD_VAL_AEQS;

/
