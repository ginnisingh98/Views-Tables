--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_UDDC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_UDDC" AS
/* $Header: IGSEN71B.pls 115.3 2002/11/29 00:08:40 nsidana ship $ */
  --
  -- Validate the administrative unit status closed indicator
  FUNCTION enrp_val_aus_closed(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		VARCHAR2(1);
  	CURSOR c_aus IS
  		SELECT	closed_ind
  		FROM	IGS_AD_ADM_UNIT_STAT
  		WHERE	administrative_unit_status = p_aus;
  BEGIN
  	-- Check if the IGS_AD_ADM_UNIT_STAT is closed
  	p_message_name := null;
  	OPEN c_aus;
  	FETCH c_aus INTO v_closed_ind;
  	IF  (c_aus%NOTFOUND) THEN
  		CLOSE c_aus;
  		RETURN TRUE;
  	END IF;
  	IF  (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_EN_ADM_UNT_STAT_CLOSED';
  		CLOSE c_aus;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_aus;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_UDDC.enrp_val_aus_closed');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_aus_closed;
  --
  -- Validate the AUS unit attempt status is 'DISCONTIN'
  FUNCTION enrp_val_aus_discont(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
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
  	IF  (v_unit_att_status = 'DISCONTIN') THEN
  		CLOSE c_aus;
  		RETURN TRUE;
  	END IF;
  	p_message_name := 'IGS_EN_GRAD_ONLY_APPL_ADMN';
  	CLOSE c_aus;
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_UDDC.enrp_val_aus_discont');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_aus_discont;
  --
  -- To validate TEACHING date alias.
  FUNCTION enrp_val_teaching_da(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		IGS_CA_DA.closed_ind%TYPE;
  	v_s_cal_cat		IGS_CA_DA.s_cal_cat%TYPE;
  	CURSOR	c_dt_alias IS
  		SELECT 	s_cal_cat,
  			closed_ind
  		FROM	IGS_CA_DA
  		WHERE	dt_alias = p_dt_alias;
  BEGIN
  	-- This module checks if the IGS_CA_DA is closed
  	-- and if the SI_CA_S_CA_CAT is specified, then it must
  	-- be 'TEACHING'
  	p_message_name := null;
  	OPEN  c_dt_alias;
  	FETCH c_dt_alias INTO 	v_s_cal_cat,
  				v_closed_ind;
  	-- check if a record has been found
  	IF (c_dt_alias%NOTFOUND) THEN
  		CLOSE c_dt_alias;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_dt_alias;
  	-- check if the closed_ind is 'Y'
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_CA_DTALIAS_IS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- check if the SI_CA_S_CA_CAT is not null and not of
  	-- type teaching
  	IF (v_s_cal_cat IS NOT NULL AND v_s_cal_cat <> 'TEACHING') THEN
  		p_message_name := 'IGS_EN_DA_MUST_BE_CAT_TEACHIN';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_UDDC.enrp_val_teaching_da');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_teaching_da;
  --
  -- Validate either the admin unit status or delete indicator is set.
  FUNCTION enrp_val_uddc_fields(
  p_aus IN VARCHAR2 ,
  p_delete_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  BEGIN
  	--When inserting/updating unit discontinuation date criteria, ensure that
  	-- either the IGS_AD_ADM_UNIT_STAT field or the delete_ind field
  	-- is set.
  	p_message_name := null;
  	IF (p_aus IS NULL AND
  			p_delete_ind <> 'Y') THEN
  		p_message_name := 'IGS_EN_ADMIN_UNIT_ST_DEL';
  		RETURN FALSE;
  	END IF;
  	IF (p_aus IS NOT NULL AND
  			p_delete_ind = 'Y') THEN
  		p_message_name := 'IGS_EN_ADMIN_UNIT_ST_NOTSET';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_UDDC.enrp_val_uddc_fields');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_uddc_fields;
END IGS_EN_VAL_UDDC;

/
