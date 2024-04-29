--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_SACCO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_SACCO" AS
/* $Header: IGSAD67B.pls 115.3 2002/11/28 21:39:03 nsidana ship $ */

  --
  -- Validate the IGS_AD_CAL_CONF date alias values.
  FUNCTION admp_val_sacco_da(
  p_dt_alias IN VARCHAR2 ,
  p_dt_alias_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_sacco_da
  	-- Validate the IGS_AD_CAL_CONF date alias values
  DECLARE
  	v_s_cal_cat	IGS_CA_DA.s_cal_cat%TYPE;
  	v_closed_ind	IGS_CA_DA.closed_ind%TYPE;
  	CURSOR	c_s_cal_cat IS
  		SELECT	NVL(s_cal_cat, 'NULL'),
  			closed_ind
  		FROM	IGS_CA_DA
  		WHERE	dt_alias = p_dt_alias;
  BEGIN
  	p_message_name := null;
  	OPEN	c_s_cal_cat;
  	FETCH	c_s_cal_cat INTO v_s_cal_cat,
  				v_closed_ind;
  	IF (c_s_cal_cat%NOTFOUND) THEN
  		CLOSE c_s_cal_cat;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_s_cal_cat;
  	-- validate the date alias is of the correct calendar category
  	IF p_dt_alias_type IN (	'INITIALISE_ADM_PERD_DT_ALIAS',
  				'ADM_APPL_ENCMB_CHK_DT_ALIAS',
  				'ADM_APPL_COURSE_STRT_DT_ALIAS',
  				'ADM_APPL_SHORT_STRT_DT_ALIAS',
  				'ADM_APPL_DUE_DT_ALIAS',
  				'ADM_APPL_FINAL_DT_ALIAS',
  				'ADM_APPL_CHNG_OF_PREF_DT_ALIAS',
  				'ADM_APPL_OFFER_RESP_DT_ALIAS') THEN
  		IF (v_s_cal_cat <> 'ADMISSION') THEN
			p_message_name := 'IGS_AD_DTALIAS_MUST_ADMCALCAT';
  			RETURN FALSE;
  		END IF;
  	ELSIF	p_dt_alias_type IN (	'ADM_APPL_E_COMP_PERD_DT_ALIAS',
  					'ADM_APPL_M_COMP_PERD_DT_ALIAS',
  					'ADM_APPL_S_COMP_PERD_DT_ALIAS') THEN
  		IF (v_s_cal_cat <> 'ACADEMIC') THEN
			p_message_name := 'IGS_AD_DTALIAS_ACADEMIC_CALCA';
  			RETURN FALSE;
  		END IF;
  	ELSE
		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	-- Validate the date alias is open
  	IF (v_closed_ind = 'Y') THEN
		p_message_name := 'IGS_CA_DTALIAS_IS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SACCO.admp_val_sacco_da');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_sacco_da;
END IGS_AD_VAL_SACCO;

/
