--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_AUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_AUS" AS
/* $Header: IGSEN25B.pls 120.0 2005/06/01 21:34:56 appldev noship $ */

  --
  -- Validate AUSG records exist for an administrative _UNIT status
  FUNCTION enrp_val_aus_ausg(
  p_aus IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_count		NUMBER;
  	CURSOR c_ausg IS
  		SELECT	count(*)
  		FROM	IGS_AD_ADM_UT_STA_GD	ausg
  		WHERE	ausg.administrative_unit_status = p_aus;
  BEGIN
  	--Validate if administrative IGS_PS_UNIT status grade records exist
  	-- for the administrative IGS_PS_UNIT status.
  	p_message_name := null;
  	OPEN c_ausg;
  	FETCH c_ausg INTO v_count;
  	CLOSE c_ausg;
  	IF v_count > 0 THEN
  		p_message_name := 'IGS_EN_ADMIN_UNITST_GRD_EXIST';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_AUS.enrp_val_aus_ausg');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
   END enrp_val_aus_ausg;

FUNCTION calp_val_ddcv_clash(
   ------------------------------------------------------------------
  --Created by  : ashok.Pelleti Oracle India
  --Date created: 3-APR-2001
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  p_non_std_disc_dl_stp_id IN NUMBER,
  p_offset_cons_type_cd IN VARCHAR2 ,
  p_constraint_condition IN VARCHAR2 ,
  p_constraint_resolution IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_sdoct_clash
  	-- Validate that IGS_EN_DISC_DL_CONS records
  	-- do not result in constraints that cannot be resolved. (eg. MUST BE MONDAY,
  	-- MUST BE WEDNESDAY).
  	-- Note that the primary keys prevent cases such as MUST BE MONDAY, MUST NOT
  	-- BE MONDAY from occurring.
  	-- Refer to S_DT_OFFSET_CONSTRAINT_TYPE table for list of valid constraint
  	-- types.
  DECLARE
  	v_message_name		VARCHAR2(30);
  	CURSOR c_ddcv IS
  		SELECT  ddcv.offset_cons_type_cd,
  			ddcv.constraint_condition,
  			ddcv.constraint_resolution
  		FROM	IGS_EN_DISC_DL_CONS	 ddcv
  		WHERE	ddcv.offset_cons_type_cd        <>p_offset_cons_type_cd		AND

  			ddcv.non_std_disc_dl_stp_id = p_non_std_disc_dl_stp_id;

  	FUNCTION calpl_val_constraint (
  		p_offset_cons_type_cd
  			IGS_EN_DISC_DL_CONS.offset_cons_type_cd%TYPE,
  		p_constraint_condition		IGS_EN_DISC_DL_CONS.constraint_condition%TYPE,
  		p_db_offset_cons_type_cd
  	                                        IGS_EN_DISC_DL_CONS.offset_cons_type_cd%TYPE,
  		p_db_constraint_condition	IGS_EN_DISC_DL_CONS.constraint_condition%TYPE,
  		p_db_constraint_resolution	IGS_EN_DISC_DL_CONS.constraint_resolution%TYPE)
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
  		IF	p_offset_cons_type_cd	IN (	cst_monday,
  								cst_tuesday,
  								cst_wednesday,
  								cst_thursday,
  								cst_friday,
  								cst_saturday,
  								cst_sunday)	AND
  			p_constraint_condition		= cst_must		AND
  			p_db_offset_cons_type_cd	IN (	cst_monday,
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
    		IF	p_offset_cons_type_cd	IN (	cst_monday,
    								cst_tuesday,
    								cst_wednesday,
    								cst_thursday,
    								cst_friday,
    								cst_saturday,
    								cst_sunday)	AND
    			p_constraint_condition		= cst_must_not		AND
    			p_db_offset_cons_type_cd	IN (	cst_monday,
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
  		IF 	((	p_offset_cons_type_cd	IN (	cst_saturday,
  									cst_sunday)	AND
  				p_db_offset_cons_type_cd	= cst_week_day
  			 )
  			 OR	-- vice-versa
  			 (	p_offset_cons_type_cd	= cst_week_day		AND
  		 		p_db_offset_cons_type_cd	IN (	cst_saturday,
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
  		IF	((	p_offset_cons_type_cd	IN (	cst_monday,
  									cst_tuesday,
  									cst_wednesday,
  									cst_thursday,
  									cst_friday)	AND
  				p_db_offset_cons_type_cd	= cst_week_day  AND
  				p_constraint_condition = 'MUST' AND
  				p_db_constraint_condition = 'MUST NOT'
  			 )
  			 OR	-- vice-versa
  			 (	p_offset_cons_type_cd	= cst_week_day		AND
  				p_db_offset_cons_type_cd	IN (	cst_monday,
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
  		IF	((	p_offset_cons_type_cd	= cst_holiday		AND
  				p_db_offset_cons_type_cd	IN (	cst_saturday,
  									cst_sunday)
  			 )
  			 OR	-- vice-versa
  			 (	p_offset_cons_type_cd	IN (	cst_saturday,
  									cst_sunday)	AND
  				p_db_offset_cons_type_cd	= cst_holiday
  			 )
  			)	AND
  			p_constraint_condition			= cst_must		AND
  			p_db_constraint_condition		= cst_must		THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		IF	p_offset_cons_type_cd	= cst_holiday	AND
  			p_db_offset_cons_type_cd	= cst_week_day	AND
  			p_constraint_condition		= cst_must	AND
  			p_db_constraint_condition	= cst_must_not	THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		-- Vice-versa
  		IF	p_offset_cons_type_cd	= cst_week_day	AND
  			p_db_offset_cons_type_cd	= cst_holiday	AND
  			p_constraint_condition		= cst_must_not	AND
  			p_db_constraint_condition	= cst_must	THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		RETURN null;
  		END;
   		END calpl_val_constraint;
  BEGIN
  	-- Set default value.
  	p_message_name := NULL;
  	v_message_name := NULL;
  	-- 1. Check parameters
  	IF (		p_non_std_disc_dl_stp_id	IS NULL	OR
  			p_offset_cons_type_cd	        IS NULL	OR
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
  	IF	p_offset_cons_type_cd	IN (	'MONDAY',
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
        -- function has been called from IGS_CA_DA_OFFCNT
  		FOR v_ddcv_rec IN c_ddcv LOOP
  			v_message_name := calpl_val_constraint(
  								p_offset_cons_type_cd,
  								p_constraint_condition,
  								v_ddcv_rec.offset_cons_type_cd,
  								v_ddcv_rec.constraint_condition,
  								v_ddcv_rec.constraint_resolution);

  			IF v_message_name IN ('IGS_CA_CONSTRAINTS_CONFLICT','IGS_CA_CONSTRAINT_NOT_RESOLVE','IGS_CA_MUSTNOT_CONST_UNRSLVD') THEN
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


  	IF v_message_name IS NULL OR
  			v_message_name = 'IGS_CA_INVALID_CONSTRAINT' THEN
  		RETURN TRUE;
  	ELSE
  		RETURN FALSE;
  	END IF;
  END;
  END calp_val_ddcv_clash;


FUNCTION calp_val_doscv_clash(
  ------------------------------------------------------------------
  --Created by  : nishikanth.behera Oracle India
  --Date created: 5-APR-2001
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk       14-Sep-2004      Bug # 3888835. Added parameter p_deadline_type.
  -------------------------------------------------------------------

  p_non_std_usec_dls_id IN NUMBER,
  p_offset_cons_type_cd IN VARCHAR2 ,
  p_constraint_condition IN VARCHAR2 ,
  p_constraint_resolution IN NUMBER ,
  p_deadline_type IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- calp_val_sdoct_clash
  	-- Validate that IGS_EN_DL_OFFSET_CONS records
  	-- do not result in constraints that cannot be resolved. (eg. MUST BE MONDAY,
  	-- MUST BE WEDNESDAY).
  	-- Note that the primary keys prevent cases such as MUST BE MONDAY, MUST NOT
  	-- BE MONDAY from occurring.
  	-- Refer to S_DT_OFFSET_CONSTRAINT_TYPE table for list of valid constraint
  	-- types.
  DECLARE
  	v_message_name		VARCHAR2(30);
  	CURSOR c_doscv(cp_c_offset_cons_type_cd in varchar2,
                       cp_n_non_std_usec_dls_id in number,
                       cp_c_deadline_type in varchar2)IS
  		SELECT  doscv.offset_cons_type_cd,
  			doscv.constraint_condition,
  			doscv.constraint_resolution
  		FROM	IGS_EN_DL_OFFSET_CONS	 doscv
  		WHERE	doscv.offset_cons_type_cd <> cp_c_offset_cons_type_cd AND
  			doscv.non_std_usec_dls_id = cp_n_non_std_usec_dls_id AND
                        doscv.deadline_type = cp_c_deadline_type;

  	FUNCTION calpl_val_constraint (
  		p_offset_cons_type_cd
  			IGS_EN_DL_OFFSET_CONS.offset_cons_type_cd%TYPE,
  		p_constraint_condition		IGS_EN_DL_OFFSET_CONS.constraint_condition%TYPE,
  		p_db_offset_cons_type_cd
  	                                        IGS_EN_DL_OFFSET_CONS.offset_cons_type_cd%TYPE,
  		p_db_constraint_condition	IGS_EN_DL_OFFSET_CONS.constraint_condition%TYPE,
  		p_db_constraint_resolution	IGS_EN_DL_OFFSET_CONS.constraint_resolution%TYPE)
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
  		IF	p_offset_cons_type_cd	IN (	cst_monday,
  								cst_tuesday,
  								cst_wednesday,
  								cst_thursday,
  								cst_friday,
  								cst_saturday,
  								cst_sunday)	AND
  			p_constraint_condition		= cst_must		AND
  			p_db_offset_cons_type_cd	IN (	cst_monday,
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
    		IF	p_offset_cons_type_cd	IN (	cst_monday,
    								cst_tuesday,
    								cst_wednesday,
    								cst_thursday,
    								cst_friday,
    								cst_saturday,
    								cst_sunday)	AND
    			p_constraint_condition		= cst_must_not		AND
    			p_db_offset_cons_type_cd	IN (	cst_monday,
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
  		IF 	((	p_offset_cons_type_cd	IN (	cst_saturday,
  									cst_sunday)	AND
  				p_db_offset_cons_type_cd	= cst_week_day
  			 )
  			 OR	-- vice-versa
  			 (	p_offset_cons_type_cd	= cst_week_day		AND
  		 		p_db_offset_cons_type_cd	IN (	cst_saturday,
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
  		IF	((	p_offset_cons_type_cd	IN (	cst_monday,
  									cst_tuesday,
  									cst_wednesday,
  									cst_thursday,
  									cst_friday)	AND
  				p_db_offset_cons_type_cd	= cst_week_day  AND
  				p_constraint_condition = 'MUST' AND
  				p_db_constraint_condition = 'MUST NOT'
  			 )
  			 OR	-- vice-versa
  			 (	p_offset_cons_type_cd	= cst_week_day		AND
  				p_db_offset_cons_type_cd	IN (	cst_monday,
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
  		IF	((	p_offset_cons_type_cd	= cst_holiday		AND
  				p_db_offset_cons_type_cd	IN (	cst_saturday,
  									cst_sunday)
  			 )
  			 OR	-- vice-versa
  			 (	p_offset_cons_type_cd	IN (	cst_saturday,
  									cst_sunday)	AND
  				p_db_offset_cons_type_cd	= cst_holiday
  			 )
  			)	AND
  			p_constraint_condition			= cst_must		AND
  			p_db_constraint_condition		= cst_must		THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		IF	p_offset_cons_type_cd	= cst_holiday	AND
  			p_db_offset_cons_type_cd	= cst_week_day	AND
  			p_constraint_condition		= cst_must	AND
  			p_db_constraint_condition	= cst_must_not	THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		-- Vice-versa
  		IF	p_offset_cons_type_cd	= cst_week_day	AND
  			p_db_offset_cons_type_cd	= cst_holiday	AND
  			p_constraint_condition		= cst_must_not	AND
  			p_db_constraint_condition	= cst_must	THEN
  			RETURN 'IGS_CA_INVALID_CONSTRAINT';
  		END IF;
  		RETURN null;
  		END;
   		END calpl_val_constraint;
  BEGIN
  	-- Set default value.
  	p_message_name := NULL;
  	v_message_name := NULL;
  	-- 1. Check parameters
  	IF (		p_non_std_usec_dls_id   	IS NULL	OR
  			p_offset_cons_type_cd	        IS NULL	OR
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
  	IF	p_offset_cons_type_cd	IN (	'MONDAY',
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
  	--    s_dt_offset_constraint_type
  		-- function has been called from IGS_CA_DA_OFFCNT
  		FOR v_doscv_rec IN c_doscv(p_offset_cons_type_cd,
                                           p_non_std_usec_dls_id,
                                           p_deadline_type)  LOOP
  			v_message_name := calpl_val_constraint(
  								p_offset_cons_type_cd,
  								p_constraint_condition,
  								v_doscv_rec.offset_cons_type_cd,
  								v_doscv_rec.constraint_condition,
  								v_doscv_rec.constraint_resolution);

  			IF v_message_name IN ('IGS_CA_CONSTRAINTS_CONFLICT','IGS_CA_CONSTRAINT_NOT_RESOLVE','IGS_CA_MUSTNOT_CONST_UNRSLVD') THEN
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


  	IF v_message_name IS NULL OR
  			v_message_name = 'IGS_CA_INVALID_CONSTRAINT' THEN
  		RETURN TRUE;
  	ELSE
  		RETURN FALSE;
  	END IF;
  END;
  END calp_val_doscv_clash;
  --

END IGS_EN_VAL_AUS;

/
