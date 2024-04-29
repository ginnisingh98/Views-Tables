--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_DAIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_DAIP" AS
/* $Header: IGSCA10B.pls 115.3 2002/11/28 22:58:27 nsidana ship $ */
  -- Validate dt alias instance pair related value.
  FUNCTION calp_val_daip_value(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_related_dt_alias IN VARCHAR2 ,
  p_related_dai_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_daip_value
  	-- This module validate IGS_AD_PS_APLINSTUNT unit version.
  DECLARE
  	v_original_date		IGS_CA_DA_INST_V.alias_val%TYPE;
  	v_related_date		IGS_CA_DA_INST_V.alias_val%TYPE;
  	CURSOR c_daiv_org IS
  		SELECT	alias_val
  		FROM	IGS_CA_DA_INST_V daiv
  		WHERE	daiv.dt_alias 		= p_dt_alias AND
  			daiv.sequence_number 	= p_dai_sequence_number AND
  			daiv.cal_type 		= p_cal_type AND
  			daiv.ci_sequence_number = p_ci_sequence_number;
  	CURSOR c_daiv_new IS
  		SELECT	alias_val
  		FROM	IGS_CA_DA_INST_V daiv
  		WHERE	daiv.dt_alias 		= p_related_dt_alias AND
  			daiv.sequence_number 	= p_related_dai_sequence_number AND
  			daiv.cal_type 		= p_related_cal_type AND
  			daiv.ci_sequence_number = p_related_ci_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- 1. Check parameters :
  	IF p_dt_alias IS NULL OR
  			p_dai_sequence_number IS NULL OR
  			p_cal_type IS NULL OR
  			p_ci_sequence_number IS NULL OR
  			p_related_dt_alias IS NULL OR p_related_dai_sequence_number IS NULL OR
  			p_related_cal_type IS NULL OR p_related_ci_sequence_number IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. Determine the value of each date alias instance in the record
  	OPEN c_daiv_org;
  	FETCH c_daiv_org INTO v_original_date;
  	CLOSE c_daiv_org;
  	OPEN c_daiv_new;
  	FETCH c_daiv_new INTO v_related_date;
  	CLOSE c_daiv_new;
  	IF v_related_date <= v_original_date THEN
  		p_message_name := 'IGS_GE_REL_DT_GT_DT';
  		RETURN FALSE;
  	END IF;
  	-- 3.  	Return no error:
  	RETURN TRUE;
  END;
  END calp_val_daip_value;
  --
  -- Validate dt alias instance pair calendar type.
  FUNCTION calp_val_daip_ct(
  p_cal_type IN VARCHAR2 ,
  p_related_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_daip_ct
  	-- Validate that IGS_CA_DA_INST_PAIR.cal_type and
  	-- IGS_CA_DA_INST_PAIR.related_cal_type are the same.
  DECLARE
  BEGIN
  	-- 1. Check parameters
  	IF (p_cal_type IS NULL OR
  			p_related_cal_type IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. Check that calendar types are the same
  	IF (p_cal_type <> p_related_cal_type) THEN
  		p_message_name := 'IGS_CA_CALTYPE_SAME_DTALIAS';
  		RETURN FALSE;
  	END IF;
  	-- 3. Return no error
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  END calp_val_daip_ct;
  --
  -- Validate dt alias instance pair values are different.
  FUNCTION calp_val_daip_dai(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_related_dt_alias IN VARCHAR2 ,
  p_related_dai_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_daip_dai
  	-- Validate that the related IGS_CA_DA_INST is different to the parent
  	-- IGS_CA_DA_INST
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- 1. Check parameters :
  	IF p_dt_alias IS NULL OR
  		p_dai_sequence_number IS NULL OR
  		p_cal_type IS NULL OR
  		p_ci_sequence_number IS NULL OR
  		p_related_dt_alias IS NULL OR
  		p_related_dai_sequence_number IS NULL OR
  		p_related_cal_type IS NULL OR
  		p_related_ci_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. Determine if the dt_alias_instances are the same.
  	IF p_dt_alias = p_related_dt_alias	AND
  		p_dai_sequence_number = p_related_dai_sequence_number AND
  		p_cal_type = p_related_cal_type AND
  		p_ci_sequence_number = p_related_ci_sequence_number THEN
  		p_message_name := 'IGS_CA_RELATED_DTALIAS_DIFF';
  		RETURN FALSE;
  	END IF;
  	-- 3.  	Return no error:
  	RETURN TRUE;
  END;
  END calp_val_daip_dai;
  --
  -- Validate only one date alias instance pair exists.
  FUNCTION calp_val_daip_unique(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_related_dt_alias IN VARCHAR2 ,
  p_related_dai_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_daip_unique
  	-- Validate that only one IGS_CA_DA_INST_PAIR record is defined for each
  	-- IGS_CA_DA_INST.
  DECLARE
  	CURSOR c_daip IS
  		SELECT	'x'
  		FROM	IGS_CA_DA_INST_PAIR daip
  		WHERE	daip.dt_alias 			= p_dt_alias AND
  			daip.dai_sequence_number 	= p_dai_sequence_number AND
  			daip.cal_type 			= p_cal_type AND
  			daip.ci_sequence_number 	= p_ci_sequence_number AND
  			(daip.related_dt_alias 		<> p_related_dt_alias OR
  			daip.related_dai_sequence_number <>  p_related_dai_sequence_number OR
  			daip.related_cal_type 		<> p_related_cal_type OR
  			daip.related_ci_sequence_number <> p_related_ci_sequence_number);
  	v_rec 	VARCHAR2(1) := NULL;
  BEGIN
  	-- 1. Check parameters :
  	IF p_dt_alias IS NULL OR
  			p_dai_sequence_number IS NULL OR
  			p_cal_type IS NULL OR
  			p_ci_sequence_number IS NULL OR
  			p_related_dt_alias IS NULL OR
  			p_related_dai_sequence_number IS NULL OR
  			p_related_cal_type IS NULL OR
  			p_related_ci_sequence_number IS NULL THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	-- 2. Determine if a record already exists (other than the current record)
  	OPEN c_daip;
  	FETCH c_daip INTO v_rec;
  	IF  (c_daip%FOUND) THEN
  		CLOSE c_daip;
  		p_message_name := 'IGS_CA_ONE_DTALIAS_DEFIINED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_daip;
  	-- 3.  	Return no error:
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_daip%ISOPEN) THEN
  			CLOSE c_daip;
  		END IF;
  END;

  END calp_val_daip_unique;
END IGS_CA_VAL_DAIP;

/
