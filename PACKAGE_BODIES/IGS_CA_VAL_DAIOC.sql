--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_DAIOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_DAIOC" AS
/* $Header: IGSCA09B.pls 115.3 2002/11/28 22:58:13 nsidana ship $ */
  -- Ensure dt alias instance offset constraints can be created.
  FUNCTION calp_val_daioc_ins(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_daioc_ins
  	-- Validate IGS_CA_TYPE.s_cal_cat.  If IGS_CA_TYPE.s_cal_cat = ?HOLIDAY?, then
  	--  offset constraints cannot be defined.
  DECLARE
  	CURSOR c_ct(
  			cp_cal_type		IGS_CA_TYPE.cal_type%TYPE) IS
  		SELECT	s_cal_cat
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type = cp_cal_type;
  	v_ct_rec			c_ct%ROWTYPE;
  	cst_holiday		CONSTANT VARCHAR2(7) := 'HOLIDAY';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check parameters
  	IF p_cal_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the system calendar category of the IGS_CA_TYPE.
  	OPEN c_ct (p_cal_type);
  	FETCH c_ct INTO v_ct_rec;
  	IF c_ct%NOTFOUND THEN
  		CLOSE c_ct;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ct;
  	IF v_ct_rec.s_cal_cat = cst_holiday THEN
  		p_message_name := 'IGS_CA_NOTDEFINE_HOLIDAY_CAT';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	 	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	 	FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_DAIOC.calp_val_daioc_ins');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END calp_val_daioc_ins;
  --
  -- Validate dt alias offset constraints do not clash.
  FUNCTION calp_val_sdoct_clash(
  p_dt_alias IN VARCHAR2 ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_offset_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_s_dt_offset_constraint_type IN VARCHAR2 ,
  p_constraint_condition IN VARCHAR2 ,
  p_constraint_resolution IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_sdoct_clash
  	-- Validate that IGS_CA_DA_OFFCNT or IGS_CA_DA_INST_OFCNT records
  	-- do not result in constraints that cannot be resolved. (eg. MUST BE MONDAY,
  	-- MUST BE WEDNESDAY).
  	-- Note that the primary keys prevent cases such as MUST BE MONDAY, MUST NOT
  	-- BE MONDAY from occurring.
  	-- Refer to S_DT_OFFSET_CONSTRAINT_TYPE table for list of valid constraint
  	-- types.
  DECLARE
  	v_message_name 	VARCHAR2(30);
  	CURSOR c_daoc IS
  		SELECT	daoc.s_dt_offset_constraint_type,
  			daoc.constraint_condition,
  			daoc.constraint_resolution
  		FROM	IGS_CA_DA_OFFCNT	 daoc
  		WHERE	daoc.dt_alias			= p_dt_alias		AND
  			daoc.offset_dt_alias		= p_offset_dt_alias	AND
  			daoc.s_dt_offset_constraint_type <> p_s_dt_offset_constraint_type;
  	CURSOR c_daioc IS
  		SELECT	daioc.s_dt_offset_constraint_type,
  			daioc.constraint_condition,
  			daioc.constraint_resolution
  		FROM	IGS_CA_DA_INST_OFCNT	 daioc
  		WHERE	daioc.dt_alias			= p_dt_alias		AND
  			daioc.dai_sequence_number	= p_dai_sequence_number	AND
  			daioc.cal_type			= p_cal_type		AND
  			daioc.ci_sequence_number	= p_ci_sequence_number	AND
  			daioc.offset_dt_alias		= p_offset_dt_alias	AND
  			daioc.offset_dai_sequence_number = p_offset_dai_sequence_number AND
  			daioc.offset_cal_type		= p_offset_cal_type	AND
  			daioc.offset_ci_sequence_number = p_offset_ci_sequence_number	AND
  			daioc.s_dt_offset_constraint_type <> p_s_dt_offset_constraint_type;
  	FUNCTION calpl_val_constraint (
  		p_s_dt_offset_constraint_type
  			IGS_CA_DA_OFFCNT.s_dt_offset_constraint_type%TYPE,
  		p_constraint_condition		IGS_CA_DA_OFFCNT.constraint_condition%TYPE,
  		p_db_s_dt_offset_cstrnt_type
  			IGS_CA_DA_OFFCNT.s_dt_offset_constraint_type%TYPE,
  		p_db_constraint_condition	IGS_CA_DA_OFFCNT.constraint_condition%TYPE,
  		p_db_constraint_resolution	IGS_CA_DA_OFFCNT.constraint_resolution%TYPE)
  	RETURN VARCHAR2
  	AS
  	BEGIN
  	DECLARE
  		cst_must	CONSTANT	VARCHAR2(10)	:= 'MUST';
  		cst_must_not	CONSTANT	VARCHAR2(10)	:= 'MUST NOT';
  		cst_monday	CONSTANT	VARCHAR2(10)	:= 'MONDAY';
  		cst_tuesday	CONSTANT	VARCHAR2(10)	:= 'TUESDAY';
  		cst_wednesday	CONSTANT	VARCHAR2(10)	:= 'WEDNESDAY';
  		cst_thursday	CONSTANT	VARCHAR2(10)	:= 'THURSDAY';
  		cst_friday	CONSTANT	VARCHAR2(10)	:= 'FRIDAY';
  		cst_saturday	CONSTANT	VARCHAR2(10)	:= 'SATURDAY';
  		cst_sunday	CONSTANT	VARCHAR2(10)	:= 'SUNDAY';
  		cst_week_day	CONSTANT	VARCHAR2(10)	:= 'WEEK DAY';
  		cst_holiday	CONSTANT	VARCHAR2(10)	:= 'HOLIDAY';
  	BEGIN
  		-- If both constraint types are particular days of the week, then check that
  		-- the constraint conditions are not both set to 'MUST'.  If so, an
  		-- unresolvable situation will occur.
  		IF	p_s_dt_offset_constraint_type	IN (	cst_monday,
  								cst_tuesday,
  								cst_wednesday,
  								cst_thursday,
  								cst_friday,
  								cst_saturday,
  								cst_sunday)	AND
  			p_constraint_condition		= cst_must		AND
  			p_db_s_dt_offset_cstrnt_type	IN (	cst_monday,
  								cst_tuesday,
  								cst_wednesday,
  								cst_thursday,
  								cst_friday,
  								cst_saturday,
  								cst_sunday)	AND
  			p_db_constraint_condition	= cst_must		THEN
  			RETURN 'IGS_CA_CONSTRAINTS_CONFLICT';
  		END IF;
    		-- If both constraint types are particular days of the week and both
    		-- constraint conditions are set to 'MUST NOT', check that the resolution
  		-- values will allow the constraint to be resolved.
  		-- eg. MUST NOT BE MONDAY (+4) combined with MUST NOT BE FRIDAY (+3),
  		-- will result in an unsolvable situation.
    		IF	p_s_dt_offset_constraint_type	IN (	cst_monday,
    								cst_tuesday,
    								cst_wednesday,
    								cst_thursday,
    								cst_friday,
    								cst_saturday,
    								cst_sunday)	AND
    			p_constraint_condition		= cst_must_not		AND
    			p_db_s_dt_offset_cstrnt_type	IN (	cst_monday,
    								cst_tuesday,
    								cst_wednesday,
    								cst_thursday,
    								cst_friday,
    								cst_saturday,
    								cst_sunday)	AND
    			p_db_constraint_condition	= cst_must_not		THEN
  			IF (p_constraint_resolution +
  			   p_db_constraint_resolution) IN (7, -7, 0) THEN
    				RETURN 'IGS_CA_MUSTNOT_CONST_UNRSLVD';
  			END IF;
    		END IF;
  		-- If current constraint type is a weekend day and the constraint type of
  		-- the fetched record is 'WEEK DAY', check that the constraint conditions
  		-- are different. Vice-versa.
  		IF 	((	p_s_dt_offset_constraint_type	IN (	cst_saturday,
  									cst_sunday)	AND
  				p_db_s_dt_offset_cstrnt_type	= cst_week_day
  			 )
  			 OR	-- vice-versa
  			 (	p_s_dt_offset_constraint_type	= cst_week_day		AND
  		 		p_db_s_dt_offset_cstrnt_type	IN (	cst_saturday,
  									cst_sunday)
  			 )
    			)	THEN
  				IF p_constraint_condition = cst_must AND
  				   p_db_constraint_condition = cst_must THEN
  		  			RETURN 'IGS_CA_CONSTRAINTS_CONFLICT';
  				END IF;
  		END IF;
  		-- If current constraint type is a week day and the constraint type of the
  		-- fetched record is 'WEEK DAY', check that the constraint conditions are
  		-- not different. Vice-versa
  		IF	((	p_s_dt_offset_constraint_type	IN (	cst_monday,
  									cst_tuesday,
  									cst_wednesday,
  									cst_thursday,
  									cst_friday)	AND
  				p_db_s_dt_offset_cstrnt_type	= cst_week_day  AND
  				p_constraint_condition = 'MUST' AND
  				p_db_constraint_condition = 'MUST NOT'
  			 )
  			 OR	-- vice-versa
  			 (	p_s_dt_offset_constraint_type	= cst_week_day		AND
  				p_db_s_dt_offset_cstrnt_type	IN (	cst_monday,
  									cst_tuesday,
  									cst_wednesday,
  									cst_thursday,
  									cst_friday) AND
  				p_constraint_condition = 'MUST NOT' AND
  				p_db_constraint_condition = 'MUST'
  			 )) THEN
  			RETURN 'IGS_CA_CONSTRAINTS_CONFLICT';
  		END IF;
  		-- If current constraint type is 'HOLIDAY'and the constraint type of the
  		-- fetched record is 'SATURDAY' or 'SUNDAY', check that the conditions
  		-- do not clash.
  		-- Note : This check does not cause the function to return FALSE. Processing
  		-- continues and if no further checks cause an error, the function will
  		-- return TRUE and the message number will be recognised as a warning.
  		IF	((	p_s_dt_offset_constraint_type	= cst_holiday		AND
  				p_db_s_dt_offset_cstrnt_type	IN (	cst_saturday,
  									cst_sunday)
  			 )
  			 OR	-- vice-versa
  			 (	p_s_dt_offset_constraint_type	IN (	cst_saturday,
  									cst_sunday)	AND
  				p_db_s_dt_offset_cstrnt_type	= cst_holiday
  			 )
  			)	AND
  			p_constraint_condition			= cst_must		AND
  			p_db_constraint_condition		= cst_must		THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		IF	p_s_dt_offset_constraint_type	= cst_holiday	AND
  			p_db_s_dt_offset_cstrnt_type	= cst_week_day	AND
  			p_constraint_condition		= cst_must	AND
  			p_db_constraint_condition	= cst_must_not	THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		-- Vice-versa
  		IF	p_s_dt_offset_constraint_type	= cst_week_day	AND
  			p_db_s_dt_offset_cstrnt_type	= cst_holiday	AND
  			p_constraint_condition		= cst_must_not	AND
  			p_db_constraint_condition	= cst_must	THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		RETURN NULL;
  		END;
   		END calpl_val_constraint;
  BEGIN
  	-- Set default value.
  	p_message_name := NULL;
  	v_message_name := NULL;
  	-- 1. Check parameters
  	IF (		p_dt_alias			IS NULL	OR
  			p_offset_dt_alias		IS NULL	OR
  			p_s_dt_offset_constraint_type	IS NULL	OR
  			p_constraint_condition		IS NULL	OR
  			p_constraint_resolution		IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. Check constraint type / constraint resolution.
  	-- If constraint resolution is zero, resolution will be impossible.
  	IF	p_constraint_resolution = 0 THEN
  			p_message_name := 'IGS_GE_INVALID_VALUE';
  			RETURN FALSE;
  	END IF;
  	-- If constraint type is a particular day, check that the resolution is not
  	-- plus or minus 7, as this will result in an unresolvable situation.
  	IF	p_s_dt_offset_constraint_type	IN (	'MONDAY',
  							 'TUESDAY',
  							'WEDNESDAY',
  							'THURSDAY',
  							'FRIDAY',
  							'SATURDAY',
  							'SUNDAY',
  							'WEEK DAY')	AND
  		p_constraint_resolution	IN (7, -7, 0)	THEN
  			p_message_name := 'IGS_CA_CONSTRAINT_NOT_RESOLVE';
  			RETURN FALSE;
  	END IF;
  	-- 3. Use a loop to select each existing constraint record and determine if
  	--    the current s_dt_offset_constraint_type clashes with an existing
  	--    s_dt_offset_constraint_type for the same dt_alias/offset_dt_alias.
  	IF p_cal_type IS NULL THEN
  		-- function has been called from IGS_CA_DA_OFFCNT
  		FOR v_daoc_rec IN c_daoc LOOP
  			v_message_name := calpl_val_constraint(
  								p_s_dt_offset_constraint_type,
  								p_constraint_condition,
  								v_daoc_rec.s_dt_offset_constraint_type,
  								v_daoc_rec.constraint_condition,
  								v_daoc_rec.constraint_resolution);
  			IF v_message_name IN ('IGS_CA_CONSTRAINTS_CONFLICT','IGS_CA_CONSTRAINT_NOT_RESOLVE','IGS_CA_MUSTNOT_CONST_UNRSLVD')
		 THEN
  				p_message_name := v_message_name;
  				EXIT;
  			ELSIF v_message_name = 'IGS_CA_INVALID_CONSTRAINT' THEN
  				p_message_name := v_message_name;
  				-- continue check next record.
  			ELSE
  				-- continue check next record.
  				NULL;
  			END IF;
  		END LOOP;
  	ELSE
  		-- function has been called from IGS_CA_DA_INST_OFCNT
  		FOR v_daioc_rec IN c_daioc LOOP
  			v_message_name := calpl_val_constraint(
  								p_s_dt_offset_constraint_type,
  								p_constraint_condition,
  								v_daioc_rec.s_dt_offset_constraint_type,
  								v_daioc_rec.constraint_condition,
  								v_daioc_rec.constraint_resolution);
  			IF v_message_name IN ('IGS_CA_CONSTRAINTS_CONFLICT','IGS_CA_CONSTRAINT_NOT_RESOLVE','IGS_CA_MUSTNOT_CONST_UNRSLVD')
		THEN
  				p_message_name := v_message_name;
  				EXIT;
  			ELSIF v_message_name = 'IGS_CA_INVALID_CONSTRAINT' THEN
  				p_message_name := v_message_name;
  				-- continue check next record.
  			ELSE
  				-- continue check next record.
  				NULL;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_message_name IS NULL OR
  			v_message_name = 'IGS_CA_INVALID_CONSTRAINT' THEN
  		RETURN TRUE;
  	ELSE
  		RETURN FALSE;
  	END IF;
  END;

  END calp_val_sdoct_clash;
  --
  -- Validate if date alias instance offset constraints exist.
  FUNCTION calp_val_daioc_exist(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail	VARCHAR2(255);
  BEGIN	--calp_val_daioc_exist
  	--This module Validates if date alias instance offset constraints
  	-- exist for the date alias instance offset.
  DECLARE
  	v_daioc_exists	VARCHAR2(1);
  	CURSOR c_daioc IS
  		SELECT 	'X'
  		FROM	IGS_CA_DA_INST_OFST	daio,
  			IGS_CA_DA_INST_OFCNT	daioc
  		WHERE	daio.dt_alias = p_dt_alias AND
  			daio.dai_sequence_number = p_dai_sequence_number AND
  			daio.cal_type = p_cal_type AND
  			daio.ci_sequence_number = p_ci_sequence_number AND
  			daioc.dt_alias = daio.dt_alias AND
  			daioc.dai_sequence_number = daio.dai_sequence_number AND
  			daioc.cal_type = daio.cal_type AND
  			daioc.ci_sequence_number = daio.ci_sequence_number;
  BEGIN
  	--Set the default message number
  	p_message_name := NULL;
  	--If record exists then constraints exist, therefore set
  	-- p_message_name (warning only).
  	OPEN c_daioc;
  	FETCH c_daioc INTO v_daioc_exists;
  	IF (c_daioc%FOUND) THEN
  		p_message_name := 'IGS_CA_CONFLICTING_CONSTRAINT';
  		CLOSE c_daioc;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_daioc;
  	RETURN TRUE;
  END;
  END calp_val_daioc_exist;
  --
  -- Validate if offset constraint type code is closed.
  FUNCTION calp_val_sdoct_clsd(
  p_s_dt_offset_constraint_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_closed_ind		IGS_LOOKUPS_VIEW.closed_ind%TYPE;
  	CURSOR c_sdoct IS
  		SELECT	sdoct.closed_ind
  		FROM	IGS_LOOKUPS_VIEW	sdoct
  		WHERE	sdoct.LOOKUP_CODE = p_s_dt_offset_constraint_type
		AND	sdoct.LOOKUP_TYPE = 'DT_OFFSET_CONSTRAINT_TYPE';
  BEGIN
  	-- Validate if S_DT_OFFSET_CONSTRAINT_TYPE.s_dt_offset_constraint_type
  	-- is closed.
  	OPEN c_sdoct;
  	FETCH c_sdoct INTO v_closed_ind;
  	IF (c_sdoct%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_sdoct;
  			p_message_name := 'IGS_CA_SYSOFFSET_CONSTYPE_CLS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sdoct;
  	p_message_name := NULL;
  	RETURN TRUE;
   END;
  END calp_val_sdoct_clsd;
END IGS_CA_VAL_DAIOC;

/
