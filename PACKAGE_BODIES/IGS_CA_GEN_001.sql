--------------------------------------------------------
--  DDL for Package Body IGS_CA_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_GEN_001" AS
 /* $Header: IGSCA01B.pls 115.3 2002/11/28 22:56:08 nsidana ship $ */
FUNCTION calp_get_alias_val(
  p_dt_alias IN IGS_CA_DA_INST.DT_ALIAS%TYPE ,
  p_sequence_num  IGS_CA_DA_INST.sequence_number%TYPE ,
  p_cal_type IN IGS_CA_DA_INST.CAL_TYPE%TYPE ,
  p_ci_sequence_num IN IGS_CA_DA_INST.ci_sequence_number%TYPE )
RETURN DATE AS
BEGIN
DECLARE
	-- this cursor finds the alias value for a date alias instance
	CURSOR c_dai ( 	cp_dt_alias  IGS_CA_DA_INST.DT_ALIAS%TYPE,
			cp_sequence_num  IGS_CA_DA_INST.sequence_number%TYPE,
			cp_cal_type  IGS_CA_DA_INST.CAL_TYPE%TYPE,
			cp_ci_sequence_num IGS_CA_DA_INST.ci_sequence_number%TYPE) IS
	SELECT	absolute_val
	FROM 	IGS_CA_DA_INST
	WHERE	DT_ALIAS = cp_dt_alias AND
		sequence_number = cp_sequence_num AND
		CAL_TYPE = cp_cal_type AND
		ci_sequence_number = cp_ci_sequence_num;
	v_alias_val 	IGS_CA_DA_INST.absolute_val%TYPE;
	v_message_name	 varchar2(30);
BEGIN
	IF p_dt_alias IS NULL OR
		p_sequence_num IS NULL OR
		p_cal_type IS NULL OR
		p_ci_sequence_num IS NULL THEN
		RETURN NULL;
	END IF;
	OPEN c_dai(	p_dt_alias,
			p_sequence_num,
			p_cal_type,
			p_ci_sequence_num);
	FETCH c_dai INTO v_alias_val;
	IF (c_dai%NOTFOUND) THEN
		CLOSE c_dai;
		RETURN NULL;
	END IF;
	CLOSE c_dai;
	IF (v_alias_val IS NULL) THEN
            -- alias defined by an offset dt alias instance
            v_alias_val := IGS_CA_GEN_002.calp_clc_dt_from_dai(p_ci_sequence_num,
	 							p_cal_type,
								p_dt_alias,
								p_sequence_num,
								v_message_name);
	END IF;
	RETURN v_alias_val;
END;
END calp_get_alias_val;
--
FUNCTION CALP_GET_ALT_CD(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER )
RETURN VARCHAR2 AS
BEGIN
DECLARE
	CURSOR c_ci (
		cp_cal_type		IGS_CA_INST.CAL_TYPE%TYPE,
		cp_sequence_number 	IGS_CA_INST.sequence_number%TYPE) IS
		SELECT	ci.alternate_code
		FROM	IGS_CA_INST	ci
		WHERE	ci.CAL_TYPE = cp_cal_type AND
			ci.sequence_number = cp_sequence_number;
	v_alternate_code	IGS_CA_INST.alternate_code%TYPE;
BEGIN
	-- Load the start/end date from the source calendar instance.
	OPEN	c_ci(
			p_cal_type,
			p_sequence_number);
	FETCH	c_ci	INTO	v_alternate_code;
	IF (c_ci%NOTFOUND)THEN
		CLOSE	c_ci;
		RETURN NULL;
	END IF;
	CLOSE	c_ci;
	RETURN v_alternate_code;
END;
END calp_get_alt_cd;
--
FUNCTION calp_get_cat_closed(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean AS
v_closed_ind	IGS_CA_TYPE.closed_ind%TYPE;
CURSOR 	c_cal_type IS
SELECT 	closed_ind
FROM	IGS_CA_TYPE
WHERE	CAL_TYPE = p_cal_type;
v_other_detail	VARCHAR2(255);
BEGIN
	p_message_name := null;
	OPEN 	c_cal_type;
	LOOP
		FETCH 	c_cal_type
		INTO	v_closed_ind;
		EXIT WHEN c_cal_type%NOTFOUND;
		IF (v_closed_ind = 'Y') THEN
			CLOSE c_cal_type;
			p_message_name := 'IGS_CA_CALTYPE_CLOSED';
			RETURN TRUE;
		ELSIF (v_closed_ind = 'N') THEN
			CLOSE c_cal_type;
			RETURN FALSE;
		END IF;
	END LOOP;
	CLOSE c_cal_type;
END calp_get_cat_closed;
--
PROCEDURE CALP_GET_CI_DATES(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE )
AS
BEGIN	--calp_get_ci_dates
	--Module returns the start/end dates as output parameters for a nominated
	--calendar instance. This routine is used in triggers which have surrogate
	--start/end dates which should be populated automatically.
DECLARE
	v_ci_start_dt	IGS_CA_INST.start_dt%TYPE;
	v_ci_end_dt	IGS_CA_INST.end_dt%TYPE;
	CURSOR c_ci IS
		SELECT	ci.start_dt,
			ci.end_dt
		FROM	IGS_CA_INST ci
		WHERE	CAL_TYPE	= p_cal_type	AND
			sequence_number	= p_ci_sequence_number;
BEGIN
	--Validate parameters
	IF (p_cal_type IS NOT NULL AND
			p_ci_sequence_number IS NOT NULL) THEN
		--If record exists then set output params acordingly
		OPEN c_ci ;
		FETCH c_ci  INTO v_ci_start_dt,
				 v_ci_end_dt;
			IF (c_ci%FOUND) THEN
				p_start_dt	:= v_ci_start_dt;
				p_end_dt	:= v_ci_end_dt;
			ELSE
				p_start_dt	:= NULL;
				p_end_dt	:= NULL;
			END IF;
		CLOSE c_ci;
	ELSE
		p_start_dt	:= NULL;
		p_end_dt	:= NULL;
	END IF;
	RETURN;
END;
EXCEPTION
	WHEN OTHERS THEN
		    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		    FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_GEN_001.calp_get_ci_dates');
                    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;

END calp_get_ci_dates;
--
FUNCTION calp_get_ci_start_dt(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER )
RETURN DATE AS
BEGIN	-- calp_get_ci_start_dt
	-- Return the calendar instance start date.
DECLARE
	v_start_dt	IGS_CA_INST.start_dt%TYPE;
	CURSOR	c_ci IS
		SELECT	ci.start_dt
		FROM	IGS_CA_INST	ci
		WHERE	ci.CAL_TYPE 	= p_cal_type 	AND
			sequence_number = p_sequence_number;
BEGIN
	OPEN c_ci;
	FETCH c_ci INTO v_start_dt;
	IF (c_ci%FOUND) THEN
		CLOSE c_ci;
		RETURN v_start_dt;
	ELSE
		CLOSE c_ci;
		RETURN NULL;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_ci%ISOPEN) THEN
			CLOSE c_ci;
		END IF;
		RAISE;
END;

END calp_get_ci_start_dt;
--
FUNCTION CALP_GET_RLTV_TIME(
  p_source_cal_type IN VARCHAR2 ,
  p_source_ci_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER )
RETURN VARCHAR2 AS
BEGIN
DECLARE
	cst_before		CONSTANT VARCHAR2(8) := 'BEFORE';
	cst_current		CONSTANT VARCHAR2(8) := 'CURRENT';
	cst_after		CONSTANT VARCHAR2(8) := 'AFTER';
	cst_null		CONSTANT VARCHAR2(4) := 'NULL';
	v_census_dt_alias	IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE;
	v_start_dt		IGS_CA_INST.start_dt%TYPE;
	v_end_dt		IGS_CA_INST.end_dt%TYPE;
	v_alias_val		IGS_CA_DA_INST_V.alias_val%TYPE;
	v_within		BOOLEAN;
	v_before		BOOLEAN;
	v_after			BOOLEAN;
	CURSOR c_sgcc IS
		SELECT	sgcc.census_dt_alias
		FROM	IGS_GE_S_GEN_CAL_CON 	sgcc
		WHERE	sgcc.s_control_num = 1;
	CURSOR c_ci (
		cp_source_cal_type		IGS_CA_INST.CAL_TYPE%TYPE,
		cp_source_ci_sequence_number 	IGS_CA_INST.sequence_number%TYPE) IS
		SELECT	ci.start_dt,
			ci.end_dt
		FROM	IGS_CA_INST	ci
		WHERE	ci.CAL_TYPE = cp_source_cal_type AND
			ci.sequence_number = cp_source_ci_sequence_number;
	CURSOR c_daiv (
		cp_related_cal_type		IGS_CA_INST.CAL_TYPE%TYPE,
		cp_related_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE,
		cp_census_dt_alias		IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE) IS
		SELECT	daiv.alias_val
		FROM	IGS_CA_DA_INST_V	daiv
		WHERE	daiv.CAL_TYPE = cp_related_cal_type AND
			daiv.ci_sequence_number = cp_related_ci_sequence_number AND
			daiv.DT_ALIAS = cp_census_dt_alias;
BEGIN
	-- This module gets the relative time period of a calendar
	-- instance in relation to another.
	-- Returns one of:
	--	BEFORE	- The related period is totally before the source period.
	--	CURRENT	- The related period overlaps the source period.
	-- 	AFTER	- The related period is totally after the source period.
	--		OR
	--	null	- When the time could not be determined. This should
	-- 		not happen in normal operation, but must be coded due to
	--		the flexibility of the calendar facility.
	-- An overlap is determined by checking whether any of the 'census date'
	-- date alias instances within the related period is within or outside
	-- the start/end date range of the source period. The assumption is being
	-- made that all teaching period calendar instances have cencus dates.
	-- Load the census date alias from the general calendar configuration table.
	OPEN	c_sgcc;
	FETCH	c_sgcc	INTO	v_census_dt_alias;
	IF (c_sgcc%NOTFOUND) THEN
		CLOSE	c_sgcc;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE	c_sgcc;
	-- Load the start/end date from the source calendar instance.
	OPEN	c_ci(
			p_source_cal_type,
			p_source_ci_sequence_number);
	FETCH	c_ci	INTO	v_start_dt,
				v_end_dt;
	IF (c_ci%NOTFOUND)THEN
		CLOSE	c_ci;
		RETURN cst_null;
	END IF;
	CLOSE	c_ci;
	-- Search for census date within the calendar instance.
	v_within := FALSE;
	v_before := FALSE;
	v_after := FALSE;
	OPEN	c_daiv(
			p_related_cal_type,
			p_related_ci_sequence_number,
			v_census_dt_alias);
	FETCH	c_daiv	INTO	v_alias_val;
	IF (c_daiv%NOTFOUND) THEN
		CLOSE	c_daiv;
		RETURN cst_null;
	END IF;
	CLOSE 	c_daiv;
	FOR	v_daiv_row	IN	c_daiv(
						p_related_cal_type,
						p_related_ci_sequence_number,
						v_census_dt_alias) LOOP
		IF (v_daiv_row.alias_val < v_start_dt) THEN
			v_before := TRUE;
		ELSIF (v_daiv_row.alias_val > v_end_dt) THEN
			v_after := TRUE;
		ELSE
			v_within := TRUE;
		END IF;
	END LOOP;
	IF (v_within = TRUE) OR
			((v_before = TRUE) AND
			(v_after = TRUE)) THEN
		RETURN cst_current;
	ELSIF (v_before = TRUE) THEN
		RETURN cst_before;
	ELSIF (v_after = TRUE) THEN
		RETURN cst_after;
	END IF;
END;
END calp_get_rltv_time;
--
FUNCTION calp_get_sup_inst(
  p_sup_cal_type IN VARCHAR2 ,
  p_sub_cal_type IN VARCHAR2 ,
  p_sub_ci_sequence_number IN NUMBER )
RETURN NUMBER AS
BEGIN	-- calp_get_sup_inst
	-- Return the superior calendar instance for a given calendar type and
	-- subordinate calendar instance.
DECLARE
	v_sup_ci_sequence_number
			IGS_CA_INST_REL.sup_ci_sequence_number%TYPE	DEFAULT NULL;
	CURSOR	c_cir IS
		SELECT	sup_ci_sequence_number
		FROM	IGS_CA_INST_REL
		WHERE	sub_cal_type 		= p_sub_cal_type 		AND
			sub_ci_sequence_number	= p_sub_ci_sequence_number 	AND
			sup_cal_type = p_sup_cal_type;
BEGIN
	-- Get the superior calendar instance.
	OPEN c_cir;
	FETCH c_cir INTO v_sup_ci_sequence_number;
	CLOSE c_cir;
	RETURN v_sup_ci_sequence_number;
END;
END calp_get_sup_inst;
--
FUNCTION calp_set_alias_value(
  p_absolute_val IN DATE ,
  p_derived_val IN DATE )
RETURN DATE AS
BEGIN
	IF p_absolute_val IS NULL THEN
		RETURN(p_derived_val);
	ELSE
		RETURN(p_absolute_val);
	END IF;
END calp_set_alias_value;
--
FUNCTION calp_set_alt_code(
  p_cal_type IN VARCHAR2 ,
  p_alternate_code IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
RETURN VARCHAR2 AS
	cst_teaching_period	CONSTANT VARCHAR2(15) := 'TEACHING';
	cst_academic_period	 CONSTANT VARCHAR2(15) := 'ACADEMIC';
	v_s_cal_cat		IGS_CA_TYPE.S_CAL_CAT%TYPE;
	v_cal_instance_rec	IGS_CA_INST%ROWTYPE;
	v_other_detail		VARCHAR2(255);
	CURSOR c_cal_type IS
		SELECT S_CAL_CAT
		FROM IGS_CA_TYPE
		WHERE	CAL_TYPE = p_cal_type;
BEGIN
	OPEN c_cal_type;
	LOOP
	FETCH c_cal_type
		INTO v_s_cal_cat;
		EXIT WHEN c_cal_type%NOTFOUND;
		IF (v_s_cal_cat = cst_teaching_period) THEN
			IF (p_alternate_code IS NULL) THEN
				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
			ELSE
				p_message_name := null;
			END IF;
			CLOSE c_cal_type;
			RETURN p_alternate_code;
		ELSIF (v_s_cal_cat = cst_academic_period) THEN
			IF (p_alternate_code IS NULL) THEN
				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
			ELSE
				p_message_name := null;
			END IF;
			CLOSE c_cal_type;
			RETURN p_alternate_code;
		ELSE
			IF (p_alternate_code IS NULL) THEN
				p_message_name := null;
			ELSE
				p_message_name := 'IGS_CA_ENRALTCD_NOT_EXIST';
			END IF;
			CLOSE c_cal_type;
			RETURN NULL;
		END IF;
	END LOOP;
	CLOSE c_cal_type;
	RETURN NULL;
END calp_set_alt_code;
--
END IGS_CA_GEN_001;

/
