--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AOS" AS
/* $Header: IGSAD36B.pls 115.4 2002/11/28 21:30:50 nsidana ship $ */
  --
  -- Validate against the system admission outcome status closed indicator.


  -- Validate the admission outcome status system default idicator.
  FUNCTION admp_val_aos_dflt(
  p_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- ADMP_VAL_AOS_DFLT
  	-- Check if another IGS_AD_OU_STAT record exists with the system
  	-- default indicator set to 'Y'
  DECLARE
  	v_count_rec		NUMBER;
  	v_sys_def_ind		IGS_AD_OU_STAT.system_default_ind%TYPE;
  	CURSOR c_count IS
  		SELECT	count(*),
  			system_default_ind
  		FROM	IGS_AD_OU_STAT aos
  		WHERE	aos.adm_outcome_status <> p_adm_outcome_status AND
  			aos.s_adm_outcome_status = p_s_adm_outcome_status AND
  			aos.system_default_ind = 'Y'
  		GROUP BY system_default_ind;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_count;
  	FETCH c_count INTO v_count_rec,
  			   v_sys_def_ind;
  	IF (c_count%FOUND) THEN
  		IF (v_count_rec > 0) AND (v_sys_def_ind = 'Y') THEN
  				p_message_name := 'IGS_AD_SYSADM_OUTST_ONLY_ONE';
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
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_AOS.admp_val_aos_dflt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aos_dflt;


END IGS_AD_VAL_AOS;

/
