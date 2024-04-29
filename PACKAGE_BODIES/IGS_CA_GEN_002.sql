--------------------------------------------------------
--  DDL for Package Body IGS_CA_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_GEN_002" AS
/* $Header: IGSCA02B.pls 115.6 2002/11/28 22:56:30 nsidana ship $ */

  /******************************************************************
  Created By         :
  Date Created By    :
  Purpose            :
  remarks            :
  Change History
  Who		When            What
  schodava	08-Jul-02	Bug # 2442220
				Modified function calp_clc_daio_cnstrt
  ******************************************************************/

FUNCTION calp_clc_daio_cnstrt(
  p_dt_alias IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_alias_val IN DATE ,
  p_message_name OUT NOCOPY varchar2 )
RETURN DATE AS
/*************************************************************
 Created By :
 Date Created By :
 Purpose :
 Know limitations, enhancements or remarks
 Change History
 Who             When		What
 schodava	 08-Jul-02	Bug # 2442220
				To improve the performance of this procedure,
				modified local functions calpl_holiday_resolve
				and calpl_inst_break_resolve.
				Replaced 2 complex cursors by 4 simple cursors.
 (reverse chronological order - newest change first)
***************************************************************/

BEGIN	-- calp_clc_daio_cnstrt
	-- This module accepts a IGS_CA_DA_INST date value which has been derived
	-- from a IGS_CA_DA_OFST, attempts to resolve any dt_alias_offset_constrts
	-- which exist for the IGS_CA_DA_OFST and then returns the modified date
	-- value. Refer to S_DT_OFFSET_CONSTRAINT_TYPE table for list of valid
	-- constraint types.
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
	cst_inst_break	CONSTANT	VARCHAR2(10)	:= 'INST BREAK';
	cst_active	CONSTANT	VARCHAR2(10)	:= 'ACTIVE';
	-- replaced declarations of the following integers to PLS_INTEGER,
	-- from NUMBER(5), to improve the performance of the procedure.
	v_mod_count			PLS_INTEGER;
	v_constraint_count		PLS_INTEGER;
	v_loop_count			PLS_INTEGER;
	v_message_name	                VARCHAR2(30) ;
	v_alias_val	                IGS_CA_DA_INST.absolute_val%TYPE;
	---------------------------------------------------------
	-- Function: calpl_holiday_resolve
	-- This function try to resolve the constraint when the
	-- s_dt_alias_offset_type = 'HOLIDAY'
	---------------------------------------------------------
	FUNCTION calpl_holiday_resolve (
		p_s_dt_offset_cnstrt_type
				IGS_CA_DA_OFFCNT.S_DT_OFFSET_CONSTRAINT_TYPE%TYPE,
		p_cnstrt_condition			IGS_CA_DA_OFFCNT.constraint_condition%TYPE,
		p_cnstrt_resolution		IGS_CA_DA_OFFCNT.constraint_resolution%TYPE,
		p_mod_count			IN OUT NOCOPY	PLS_INTEGER,
		p_alias_val			IN OUT NOCOPY	DATE)
	RETURN varchar2
	AS
	BEGIN
	DECLARE
		v_changed		BOOLEAN;
		v_dummy			VARCHAR2(1);
		v_tmp_mod_count		PLS_INTEGER;
		v_tmp_alias_val		DATE;
		v_max_alias_val		DATE	DEFAULT NULL;
		v_min_alias_val		DATE	DEFAULT NULL;

		-- Replaced cursor c_m_alias_val by 2 cursors
		-- c_m_alias_val1 and c_m_alias_val2.
		-- The cursor c_m_alias_val was using the group functions
		-- max and min, causing a performance issue.
		-- Replaced it with 2 cursors, which use and ORDER BY clause instead of a function.
		-- Also, included the calendar instance sequence number in the join condition
		-- between the dai and ci tables, to improve the performance of the cursor.
		-- The FK between the 2 tables is a composite one of cal_type and sequence_number.

		CURSOR c_m_alias_val1 IS
			SELECT	TRUNC(dai.absolute_val)
			FROM	IGS_CA_DA_INST	dai,
				IGS_CA_INST		ci,
				IGS_CA_TYPE		ct,
				IGS_CA_STAT		cs
			WHERE	dai.CAL_TYPE		= ci.CAL_TYPE AND
				dai.ci_sequence_number  = ci.sequence_number AND
				ci.CAL_TYPE		= ct.CAL_TYPE	AND
				ct.S_CAL_CAT		= cst_holiday	AND
				cs.CAL_STATUS		= ci.CAL_STATUS	AND
				cs.s_cal_status		= cst_active
			ORDER BY dai.absolute_val ASC;

		CURSOR c_m_alias_val2 IS
			SELECT	TRUNC(dai.absolute_val)
			FROM	IGS_CA_DA_INST	dai,
				IGS_CA_INST		ci,
				IGS_CA_TYPE		ct,
				IGS_CA_STAT		cs
			WHERE	dai.CAL_TYPE		= ci.CAL_TYPE AND
				dai.ci_sequence_number  = ci.sequence_number AND
				ci.CAL_TYPE		= ct.CAL_TYPE	AND
				ct.S_CAL_CAT		= cst_holiday	AND
				cs.CAL_STATUS		= ci.CAL_STATUS	AND
				cs.s_cal_status		= cst_active
			ORDER BY dai.absolute_val DESC;

		CURSOR c_holiday (
				cp_alias_val		IGS_CA_DA_INST.absolute_val%TYPE) IS
			SELECT	'x'
			FROM	IGS_CA_TYPE ct
			WHERE	ct.S_CAL_CAT		= cst_holiday	AND
			EXISTS	(SELECT	'x'
				 FROM	IGS_CA_INST ci,
					IGS_CA_STAT cs
				WHERE	ci.CAL_TYPE = ct.CAL_TYPE	AND
					ci.CAL_STATUS = cs.CAL_STATUS	AND
					cs.s_cal_status = cst_active	AND
					EXISTS 	(SELECT	'x'
					 	 FROM	IGS_CA_DA_INST dai
						 WHERE	dai.CAL_TYPE = ct.CAL_TYPE	AND
							TRUNC(dai.absolute_val) = cp_alias_val));
	BEGIN

		OPEN c_m_alias_val1;
		FETCH c_m_alias_val1 INTO	v_min_alias_val;
		CLOSE c_m_alias_val1;

		OPEN c_m_alias_val2;
		FETCH c_m_alias_val2 INTO	v_max_alias_val;
		CLOSE c_m_alias_val2;


		IF v_max_alias_val IS NULL	AND
				v_min_alias_val IS NULL THEN
			-- No HOLIDAY date alias instances have been defined which can be resolved.
			IF p_cnstrt_condition = cst_must_not THEN
				-- constraint does not require resolving
				RETURN null;
			ELSE
				-- constraint cannot be resolved
				RETURN ('IGS_CA_HOLIDAY_CONST_UNRSLVD');
			END IF;
		ELSE
			IF	p_cnstrt_condition = cst_must THEN
				IF	(p_alias_val	> v_max_alias_val AND
				 	 p_cnstrt_resolution >0 ) OR
					(p_alias_val	< v_min_alias_val AND
				 	 p_cnstrt_resolution <0 ) THEN
					-- constraint cannot be resolved
					RETURN ('IGS_CA_HOLIDAY_CONS_UNRSVLD');
				END IF;
			END IF;
			v_tmp_alias_val := p_alias_val;
			v_tmp_mod_count := p_mod_count;
			LOOP
				v_changed := FALSE;
				OPEN c_holiday (v_tmp_alias_val);
				FETCH c_holiday INTO v_dummy;
				IF c_holiday%FOUND THEN
					CLOSE c_holiday;
					IF p_cnstrt_condition = cst_must_not THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						v_changed := TRUE;
					END IF;
				ELSE	-- record not found
					CLOSE c_holiday;
					IF p_cnstrt_condition = cst_must THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						IF	(v_tmp_alias_val	> v_max_alias_val AND
						 	 p_cnstrt_resolution	>0 ) OR
							(v_tmp_alias_val	< v_min_alias_val AND
						 	 p_cnstrt_resolution 	<0 ) THEN
							-- constraint cannot be resolved
							RETURN ('IGS_CA_HOLIDAY_CONS_UNRSVLD');
						END IF;
						v_changed := TRUE;
					END IF;
				END IF;
				EXIT WHEN v_changed = FALSE;
			END LOOP;
			-- resolve success or no resolving needed.
			p_alias_val := v_tmp_alias_val;
			p_mod_count := v_tmp_mod_count;
			RETURN null;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF c_m_alias_val1%ISOPEN THEN
				CLOSE c_m_alias_val1;
			END IF;
			IF c_m_alias_val2%ISOPEN THEN
				CLOSE c_m_alias_val2;
			END IF;
			IF c_holiday%ISOPEN THEN
				CLOSE c_holiday;
			END IF;
			RAISE;
	END;
	END calpl_holiday_resolve;
	---------------------------------------------------------
	-- Function: calpl_inst_break_resolve
	-- This function try to resolve the constraint when the
	-- s_dt_alias_offset_type = 'INST BREAK'
	---------------------------------------------------------
	FUNCTION calpl_inst_break_resolve (
		p_s_dt_offset_cnstrt_type
			IGS_CA_DA_OFFCNT.S_DT_OFFSET_CONSTRAINT_TYPE%TYPE,
		p_cnstrt_condition			IGS_CA_DA_OFFCNT.constraint_condition%TYPE,
		p_cnstrt_resolution		IGS_CA_DA_OFFCNT.constraint_resolution%TYPE,
		p_mod_count			IN OUT NOCOPY	PLS_INTEGER,
		p_alias_val			IN OUT NOCOPY	DATE)
	RETURN varchar2
	AS
	BEGIN
	DECLARE
		v_changed		BOOLEAN;
		v_dummy			VARCHAR2(1);
		v_tmp_mod_count		PLS_INTEGER;
		v_tmp_alias_val		DATE;
		v_max_alias_val		DATE	DEFAULT NULL;
		v_min_alias_val		DATE	DEFAULT NULL;

		-- Replaced cursor c_m_alias_val2 by 2 cursors
		-- c_m_alias_val2a and c_m_alias_val2b.
		-- The cursor c_m_alias_val2 was using the group functions
		-- max and min, causing a performance issue.
		-- Replaced it with 2 cursors, which use and ORDER BY clause instead of a function.

			CURSOR c_m_alias_val2a IS
			SELECT	TRUNC(dai2.absolute_val)
			FROM	IGS_CA_DA_INST		dai1,
				IGS_CA_DA_INST		dai2,
				IGS_CA_DA_INST_PAIR	daip,
				IGS_CA_INST		ci,
				IGS_CA_TYPE		ct,
				IGS_CA_STAT		cs
			WHERE	ci.CAL_TYPE		= ct.CAL_TYPE				AND
				ct.S_CAL_CAT		= cst_holiday				AND
				cs.CAL_STATUS		= ci.CAL_STATUS				AND
				cs.s_cal_status		= cst_active				AND
				dai1.CAL_TYPE		= ci.CAL_TYPE				AND
				dai1.DT_ALIAS		= daip.DT_ALIAS				AND
				dai1.sequence_number	= daip.dai_sequence_number		AND
				dai1.CAL_TYPE		= daip.CAL_TYPE				AND
				dai1.ci_sequence_number = daip.ci_sequence_number		AND
				dai2.DT_ALIAS		= daip.related_dt_alias			AND
				dai2.sequence_number	= daip.related_dai_sequence_number	AND
				dai2.CAL_TYPE		= daip.related_cal_type			AND
				dai2.ci_sequence_number = daip.related_ci_sequence_number
			ORDER BY dai2.absolute_val DESC;

			CURSOR c_m_alias_val2b IS
			SELECT	TRUNC(dai1.absolute_val)
			FROM	IGS_CA_DA_INST		dai1,
				IGS_CA_DA_INST		dai2,
				IGS_CA_DA_INST_PAIR	daip,
				IGS_CA_INST		ci,
				IGS_CA_TYPE		ct,
				IGS_CA_STAT		cs
			WHERE	ci.CAL_TYPE		= ct.CAL_TYPE				AND
				ct.S_CAL_CAT		= cst_holiday				AND
				cs.CAL_STATUS		= ci.CAL_STATUS				AND
				cs.s_cal_status		= cst_active				AND
				dai1.CAL_TYPE		= ci.CAL_TYPE				AND
				dai1.DT_ALIAS		= daip.DT_ALIAS				AND
				dai1.sequence_number	= daip.dai_sequence_number		AND
				dai1.CAL_TYPE		= daip.CAL_TYPE				AND
				dai1.ci_sequence_number = daip.ci_sequence_number		AND
				dai2.DT_ALIAS		= daip.related_dt_alias			AND
				dai2.sequence_number	= daip.related_dai_sequence_number	AND
				dai2.CAL_TYPE		= daip.related_cal_type			AND
				dai2.ci_sequence_number = daip.related_ci_sequence_number
			ORDER BY dai1.absolute_val ASC;

		CURSOR c_instbreak (
				cp_alias_val		IGS_CA_DA_INST.absolute_val%TYPE) IS
			SELECT	'x'
			FROM	IGS_CA_TYPE ct
			WHERE	ct.S_CAL_CAT = cst_holiday	AND
			EXISTS	(SELECT	'x'
				 FROM	IGS_CA_INST ci,
					IGS_CA_STAT cs
				 WHERE	ci.CAL_TYPE	= ct.CAL_TYPE	AND
					ci.CAL_STATUS	= cs.CAL_STATUS	AND
					cs.s_cal_status	= cst_active	AND
					EXISTS	(SELECT	'x'
					FROM	IGS_CA_DA_INST dai1,
						IGS_CA_DA_INST dai2,
						IGS_CA_DA_INST_PAIR daip
					WHERE	dai1.CAL_TYPE	= ct.CAL_TYPE	AND
						dai1.DT_ALIAS	 = daip.DT_ALIAS    AND
 						dai1.sequence_number	= daip.dai_sequence_number  AND
 						dai1.CAL_TYPE	= daip.CAL_TYPE    AND
 						dai1.ci_sequence_number	= daip.ci_sequence_number  AND
						dai2.DT_ALIAS	= daip.related_dt_alias   AND
 						dai2.sequence_number	= daip.related_dai_sequence_number AND
	 					dai2.CAL_TYPE	= daip.related_cal_type   AND
						dai2.ci_sequence_number	= daip.related_ci_sequence_number AND
						 cp_alias_val BETWEEN TRUNC(dai1.absolute_val) AND
							TRUNC(dai2.absolute_val)));
	BEGIN
		OPEN c_m_alias_val2a;
		FETCH c_m_alias_val2a INTO v_max_alias_val;
		CLOSE c_m_alias_val2a;

		OPEN c_m_alias_val2b;
		FETCH c_m_alias_val2b INTO v_min_alias_val;
		CLOSE c_m_alias_val2b;

		IF v_max_alias_val IS NULL	AND
				v_min_alias_val IS NULL THEN
			-- No HOLIDAY date alias instances have been defined which can be resolved.
			IF p_cnstrt_condition = cst_must_not THEN
				-- constraint does not require resolving
				RETURN null;
			ELSE
				-- constraint cannot be resolved
				RETURN ('IGS_CA_INSTBREAK_CONST_UNRSLV');
			END IF;
		ELSE
			IF	p_cnstrt_condition = cst_must THEN
				IF	(p_alias_val	> v_max_alias_val AND
				 	 p_cnstrt_resolution >0 ) OR
					(p_alias_val	< v_min_alias_val AND
				 	 p_cnstrt_resolution <0 ) THEN
					-- constraint cannot be resolved
					RETURN ('IGS_CA_INSTBREAK_CONS_UNRSVLD');
				END IF;
			END IF;
			v_tmp_alias_val := p_alias_val;
			v_tmp_mod_count := p_mod_count;
			LOOP
				v_changed := FALSE;
				OPEN c_instbreak (v_tmp_alias_val);
				FETCH c_instbreak INTO v_dummy;
				IF c_instbreak%FOUND THEN
					CLOSE c_instbreak;
					IF p_cnstrt_condition = cst_must_not THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						v_changed := TRUE;
					END IF;
				ELSE	-- record not found
					CLOSE c_instbreak;
					IF p_cnstrt_condition = cst_must THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						IF	(v_tmp_alias_val	> v_max_alias_val AND
						 	 p_cnstrt_resolution	>0 ) OR
							(v_tmp_alias_val	< v_min_alias_val AND
						 	 p_cnstrt_resolution	<0 ) THEN
							-- constraint cannot be resolved
							RETURN ('IGS_CA_INSTBREAK_CONS_UNRSVLD');
						END IF;
						v_changed := TRUE;
					END IF;
				END IF;
				EXIT WHEN v_changed = FALSE;
			END LOOP;
			-- resolve success or no resolving needed.
			p_alias_val := v_tmp_alias_val;
			p_mod_count := v_tmp_mod_count;
			RETURN NULL;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF c_m_alias_val2a%ISOPEN THEN
				CLOSE c_m_alias_val2a;
			END IF;
			IF c_m_alias_val2b%ISOPEN THEN
				CLOSE c_m_alias_val2b;
			END IF;
			IF c_instbreak%ISOPEN THEN
				CLOSE c_instbreak;
			END IF;
			RAISE;
	END;
	END calpl_inst_break_resolve;
	---------------------------------------------------------
	-- Procedure: calpl_constraint_resolve
	---------------------------------------------------------
	PROCEDURE calpl_constraint_resolve (
		p_constraint_count		IN OUT NOCOPY	PLS_INTEGER,
		p_mod_count			IN OUT NOCOPY	PLS_INTEGER,
		p_alias_val			IN OUT NOCOPY	IGS_CA_DA_INST.absolute_val%TYPE,
		p_message_name			OUT NOCOPY	VARCHAR2 )
	AS
	BEGIN	-- This local procedure is try to resolve the clashed constraint record.
	DECLARE
		v_msg_name			VARCHAR2(30) ;
		v_changed			BOOLEAN;
		CURSOR c_daoc IS
			SELECT	daoc.S_DT_OFFSET_CONSTRAINT_TYPE,
				daoc.constraint_condition,
				daoc.constraint_resolution
			FROM	IGS_CA_DA_INST_OFCNT	 daoc
			WHERE	daoc.DT_ALIAS			= p_dt_alias	AND
				daoc.dai_sequence_number		= p_sequence_number	AND
				daoc.CAL_TYPE			= p_cal_type	AND
				daoc.ci_sequence_number 		= p_ci_sequence_number;
	BEGIN
		v_msg_name := null;
		FOR v_daoc_rec IN c_daoc LOOP
			p_constraint_count := p_constraint_count + 1;
			IF v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE IN (	cst_monday,
									cst_tuesday,
									cst_wednesday,
									cst_thursday,
									cst_friday,
									cst_saturday,
									cst_sunday)	THEN
				IF v_daoc_rec.constraint_condition = cst_must	THEN
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) <>
								v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				ELSE	-- NUST NOT
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) =
								v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				END IF;
			ELSIF 	v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE = cst_week_day THEN
				IF v_daoc_rec.constraint_condition = cst_must	THEN
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) NOT IN (cst_monday,
											cst_tuesday,
											cst_wednesday,
											cst_thursday,
											cst_friday) LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				ELSE	-- MUST NOT
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) IN (	cst_monday,
											cst_tuesday,
											cst_wednesday,
											cst_thursday,
											cst_friday) LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				END IF;
			ELSIF	v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE = cst_holiday THEN
				-- If the constraint type is 'HOLIDAY', check that the date does not clash
				-- against any date alias instance values in HOLIDAY calendars if the
				-- condition is 'MUST NOT' or that it matches a date alias instance value
				-- in a HOLIDAY calendar if the condition is 'MUST'.
				v_msg_name := calpl_holiday_resolve (
									v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE,
									v_daoc_rec.constraint_condition,
									v_daoc_rec.constraint_resolution,
									p_mod_count,
									p_alias_val);
				IF v_msg_name IS NOT NULL THEN
					p_message_name := v_msg_name;
				END IF;
			ELSIF	v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE = cst_inst_break THEN
				--If the constraint type is 'INST BREAK', check that the date does not fall
				-- between the dates defined by any date alias instance pairs in HOLIDAY
				-- calendars if the condition is 'MUST NOT' or that it does if the
				-- condition is 'MUST'.
				-- Use an inner loop to match the date against all defined DAIP's.
				-- Find the start and end dates of any DAI Pair.
				v_msg_name := calpl_inst_break_resolve (
									v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE,
									v_daoc_rec.constraint_condition,
									v_daoc_rec.constraint_resolution,
									p_mod_count,
									p_alias_val);
				IF v_msg_name IS NOT NULL THEN
					p_message_name := v_msg_name;
				END IF;
			END IF;
		END LOOP;	-- daoc loop
	EXCEPTION
		WHEN OTHERS THEN
			IF c_daoc%ISOPEN THEN
				CLOSE c_daoc;
			END IF;
			RAISE;
	END;
	END calpl_constraint_resolve;
BEGIN
	-- Set default value.
	p_message_name := null;
	v_message_name := null;
	v_mod_count :=0;
	v_constraint_count := 0;
	v_loop_count := 0;
	-- 1. Check parameters
	IF (		p_dt_alias		IS NULL	OR
			p_sequence_number	IS NULL 	OR
			p_cal_type		IS NULL	OR
			p_ci_sequence_number	IS NULL	OR
			p_alias_val		IS NULL) THEN
		RETURN p_alias_val;
	END IF;
	-- 2. Check if any constraints exist for the date alias.
	--    If not, no further processing required.
	v_alias_val := TRUNC(p_alias_val);
	-- 3. Set counters to be used to determine if the date constraints are
	--    unresolvable.
	WHILE v_loop_count <= 10 LOOP
		-- 4. Use a loop to select each existiong constraint record.
		--    and check the constraint against the date and if a clash exists,
		--    attempt to resolve it.
		calpl_constraint_resolve (
					v_constraint_count,
					v_mod_count,
					v_alias_val,
					v_message_name);
		IF v_message_name IS NOT NULL THEN
			p_message_name := v_message_name;
		END IF;
		IF v_mod_count > 0	AND
				v_constraint_count > 1	THEN
			-- Value has been modified by a constraint, so reset the counters and loop
			-- through constraints again to ensure that changing the value for one
			-- constraint, has not caused to clash with another constraint it had
			-- already satisfied.
			v_mod_count := 0;
			v_constraint_count := 0;
			v_loop_count := v_loop_count + 1;
		ELSE
			RETURN v_alias_val;
		END IF;
	END LOOP; -- v_loop_count<=10
	-- Constraint is deemed unresolvable
	p_message_name := ('IGS_CA_ATTEMPT_TORESOLVE_FAIL');
	RETURN p_alias_val;
END;
END calp_clc_daio_cnstrt;
--

FUNCTION calp_clc_dao_cnstrt(
  p_dt_alias IN VARCHAR2 ,
  p_alias_val IN DATE ,
  p_message_name OUT NOCOPY varchar2 )
RETURN DATE AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- calp_clc_dao_cnstrt
	-- This module accepts a IGS_CA_DA_INST date value which has been derived
	-- from a IGS_CA_DA_OFST, attempts to resolve any dt_alias_offset_constrts
	-- which exist for the IGS_CA_DA_OFST and then returns the modified date
	-- value. Refer to S_DT_OFFSET_CONSTRAINT_TYPE table for list of valid
	-- constraint types.
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
	cst_inst_break	CONSTANT	VARCHAR2(10)	:= 'INST BREAK';
	cst_active	CONSTANT	VARCHAR2(10)	:= 'ACTIVE';
	v_mod_count			NUMBER(5);
	v_constraint_count		NUMBER(5);
	v_loop_count			NUMBER(5);
	v_message_name	 varchar2(30);
	v_alias_val	IGS_CA_DA_INST.absolute_val%TYPE;
	---------------------------------------------------------
	-- Function: calpl_holiday_resolve
	-- This function try to resolve the constraint when the
	-- s_dt_alias_offset_type = 'HOLIDAY'
	---------------------------------------------------------
	FUNCTION calpl_holiday_resolve (
		p_s_dt_offset_cnstrt_type
				IGS_CA_DA_OFFCNT.S_DT_OFFSET_CONSTRAINT_TYPE%TYPE,
		p_cnstrt_condition			IGS_CA_DA_OFFCNT.constraint_condition%TYPE,
		p_cnstrt_resolution			IGS_CA_DA_OFFCNT.constraint_resolution%TYPE,
		p_mod_count			IN OUT NOCOPY	NUMBER,
		p_alias_val			IN OUT NOCOPY	DATE)
	RETURN VARCHAR2
	AS
	BEGIN
	DECLARE
		v_changed		BOOLEAN;
		v_dummy			VARCHAR2(1);
		v_tmp_mod_count		NUMBER;
		v_tmp_alias_val		DATE;
		v_max_alias_val		DATE	DEFAULT NULL;
		v_min_alias_val		DATE	DEFAULT NULL;
		CURSOR c_m_alias_val IS
			SELECT	TRUNC(max(dai.absolute_val)), TRUNC(min(dai.absolute_val))
			FROM	IGS_CA_DA_INST	dai,
				IGS_CA_INST		ci,
				IGS_CA_TYPE		ct,
				IGS_CA_STAT		cs
			WHERE	ci.CAL_TYPE		= ct.CAL_TYPE	AND
				ct.S_CAL_CAT		= cst_holiday	AND
				cs.s_cal_status		= ci.CAL_STATUS	AND
				cs.s_cal_status		= cst_active	AND
				dai.CAL_TYPE		= ci.CAL_TYPE;
		CURSOR c_holiday (
				cp_alias_val		IGS_CA_DA_INST.absolute_val%TYPE) IS
			SELECT	'x'
			FROM	IGS_CA_TYPE ct
			WHERE	ct.S_CAL_CAT		= cst_holiday	AND
			EXISTS	(SELECT	'x'
				 FROM	IGS_CA_INST ci,
					IGS_CA_STAT cs
				WHERE	ci.CAL_TYPE	= ct.CAL_TYPE	AND
					ci.CAL_STATUS	= cs.CAL_STATUS	AND
					cs.s_cal_status	= cst_active	AND
					EXISTS 	(SELECT	'x'
					 	 FROM	IGS_CA_DA_INST dai
						 WHERE	dai.CAL_TYPE = ct.CAL_TYPE	AND
							TRUNC(dai.absolute_val)= cp_alias_val));
	BEGIN
		OPEN c_m_alias_val;
		FETCH c_m_alias_val INTO	v_max_alias_val,
						v_min_alias_val;
		CLOSE c_m_alias_val;
		IF v_max_alias_val IS NULL	AND
				v_min_alias_val IS NULL THEN
			-- No HOLIDAY date alias instances have been defined which can be resolved.
			IF p_cnstrt_condition = cst_must_not THEN
				-- constraint does not require resolving
				RETURN null;
			ELSE
				-- constraint cannot be resolved
				RETURN ('IGS_CA_HOLIDAY_CONST_UNRSLVD');
			END IF;
		ELSE
			IF	p_cnstrt_condition = cst_must THEN
				IF	(p_alias_val	> v_max_alias_val AND
				 	 p_cnstrt_resolution >0 ) OR
					(p_alias_val	< v_min_alias_val AND
				 	 p_cnstrt_resolution <0 ) THEN
					-- constraint cannot be resolved
					RETURN ('IGS_CA_HOLIDAY_CONS_UNRSVLD');
				END IF;
			END IF;
			v_tmp_alias_val := p_alias_val;
			v_tmp_mod_count := p_mod_count;
			LOOP
				v_changed := FALSE;
				OPEN c_holiday (v_tmp_alias_val);
				FETCH c_holiday INTO v_dummy;
				IF c_holiday%FOUND THEN
					CLOSE c_holiday;
					IF p_cnstrt_condition = cst_must_not THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						v_changed := TRUE;
					END IF;
				ELSE	-- record not found
					CLOSE c_holiday;
					IF p_cnstrt_condition = cst_must THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						IF	(v_tmp_alias_val	> v_max_alias_val AND
						 	 p_cnstrt_resolution	>0 ) OR
							(v_tmp_alias_val	< v_min_alias_val AND
						 	 p_cnstrt_resolution 	<0 ) THEN
							-- constraint cannot be resolved
							RETURN ('IGS_CA_HOLIDAY_CONS_UNRSVLD');
						END IF;
						v_changed := TRUE;
					END IF;
				END IF;
				EXIT WHEN v_changed = FALSE;
			END LOOP;
			-- resolve success or no resolving needed.
			p_alias_val := v_tmp_alias_val;
			p_mod_count := v_tmp_mod_count;
			RETURN null;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF c_m_alias_val%ISOPEN THEN
				CLOSE c_m_alias_val;
			END IF;
			IF c_holiday%ISOPEN THEN
				CLOSE c_holiday;
			END IF;
			RAISE;
	END;
	END calpl_holiday_resolve;
	---------------------------------------------------------
	-- Function: calpl_inst_break_resolve
	-- This function try to resolve the constraint when the
	-- s_dt_alias_offset_type = 'INST BREAK'
	---------------------------------------------------------
	FUNCTION calpl_inst_break_resolve (
		p_s_dt_offset_cnstrt_type
			IGS_CA_DA_OFFCNT.S_DT_OFFSET_CONSTRAINT_TYPE%TYPE,
		p_cnstrt_condition			IGS_CA_DA_OFFCNT.constraint_condition%TYPE,
		p_cnstrt_resolution			IGS_CA_DA_OFFCNT.constraint_resolution%TYPE,
		p_mod_count			IN OUT NOCOPY	NUMBER,
		p_alias_val			IN OUT NOCOPY	DATE)
	RETURN varchar2
	AS
	BEGIN
	DECLARE
		v_changed		BOOLEAN;
		v_dummy			VARCHAR2(1);
		v_tmp_mod_count		NUMBER;
		v_tmp_alias_val		DATE;
		v_max_alias_val		DATE	DEFAULT NULL;
		v_min_alias_val		DATE	DEFAULT NULL;
		CURSOR c_m_alias_val2 IS
			SELECT	TRUNC(MAX(dai2.absolute_val)), TRUNC(MIN(dai1.absolute_val))
			FROM	IGS_CA_DA_INST		dai1,
				IGS_CA_DA_INST		dai2,
				IGS_CA_DA_INST_PAIR	daip,
				IGS_CA_INST		ci,
				IGS_CA_TYPE		ct,
				IGS_CA_STAT		cs
			WHERE	ci.CAL_TYPE		= ct.CAL_TYPE				AND
				ct.S_CAL_CAT		= cst_holiday				AND
				cs.s_cal_status		= ci.CAL_STATUS				AND
				cs.s_cal_status		= cst_active				AND
				dai1.CAL_TYPE		= ci.CAL_TYPE				AND
				dai1.DT_ALIAS		= daip.DT_ALIAS				AND
				dai1.sequence_number	= daip.dai_sequence_number		AND
				dai1.CAL_TYPE		= daip.CAL_TYPE				AND
				dai1.ci_sequence_number = daip.ci_sequence_number		AND
				dai2.DT_ALIAS		= daip.related_dt_alias			AND
				dai2.sequence_number	= daip.related_dai_sequence_number	AND
				dai2.CAL_TYPE		= daip.related_cal_type			AND
				dai2.ci_sequence_number = daip.related_ci_sequence_number;
		CURSOR c_instbreak (
				cp_alias_val		IGS_CA_DA_INST.absolute_val%TYPE) IS
			SELECT	'x'
			FROM	IGS_CA_TYPE ct
			WHERE	ct.S_CAL_CAT = cst_holiday	AND
			EXISTS	(SELECT	'x'
				 FROM	IGS_CA_INST ci,
					IGS_CA_STAT cs
				 WHERE	ci.CAL_TYPE	= ct.CAL_TYPE	AND
					ci.CAL_STATUS	= cs.CAL_STATUS	AND
					cs.s_cal_status	= cst_active	AND
					EXISTS	(SELECT	'x'
					FROM	IGS_CA_DA_INST dai1,
						IGS_CA_DA_INST dai2,
						IGS_CA_DA_INST_PAIR daip
					WHERE	dai1.CAL_TYPE	= ct.CAL_TYPE	AND
						dai1.DT_ALIAS	 = daip.DT_ALIAS    AND
 						dai1.sequence_number	= daip.dai_sequence_number  AND
 						dai1.CAL_TYPE	= daip.CAL_TYPE    AND
 						dai1.ci_sequence_number	= daip.ci_sequence_number  AND
						dai2.DT_ALIAS	= daip.related_dt_alias   AND
 						dai2.sequence_number	= daip.related_dai_sequence_number AND
	 					dai2.CAL_TYPE	= daip.related_cal_type   AND
						dai2.ci_sequence_number	= daip.related_ci_sequence_number AND
						 cp_alias_val BETWEEN TRUNC(dai1.absolute_val) AND
							TRUNC(dai2.absolute_val)));
	BEGIN
		OPEN c_m_alias_val2;
		FETCH c_m_alias_val2 INTO	v_max_alias_val,
						v_min_alias_val;
		CLOSE c_m_alias_val2;
		IF v_max_alias_val IS NULL	AND
				v_min_alias_val IS NULL THEN
			-- No HOLIDAY date alias instances have been defined which can be resolved.
			IF p_cnstrt_condition = cst_must_not THEN
				-- constraint does not require resolving
				RETURN null;
			ELSE
				-- constraint cannot be resolved
				RETURN ('IGS_CA_INSTBREAK_CONST_UNRSLV');
			END IF;
		ELSE
			IF	p_cnstrt_condition = cst_must THEN
				IF	(p_alias_val	> v_max_alias_val AND
				 	 p_cnstrt_resolution >0 ) OR
					(p_alias_val	< v_min_alias_val AND
				 	 p_cnstrt_resolution <0 ) THEN
					-- constraint cannot be resolved
					RETURN ('IGS_CA_INSTBREAK_CONS_UNRSVLD');
				END IF;
			END IF;
			v_tmp_alias_val := p_alias_val;
			v_tmp_mod_count := p_mod_count;
			LOOP
				v_changed := FALSE;
				OPEN c_instbreak (v_tmp_alias_val);
				FETCH c_instbreak INTO v_dummy;
				IF c_instbreak%FOUND THEN
					CLOSE c_instbreak;
					IF p_cnstrt_condition = cst_must_not THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						v_changed := TRUE;
					END IF;
				ELSE	-- record not found
					CLOSE c_instbreak;
					IF p_cnstrt_condition = cst_must THEN
						--update the date value and test again.
						v_tmp_alias_val := v_tmp_alias_val + p_cnstrt_resolution;
						v_tmp_mod_count := v_tmp_mod_count + 1;
						IF	(v_tmp_alias_val	> v_max_alias_val AND
						 	 p_cnstrt_resolution	>0 ) OR
							(v_tmp_alias_val	< v_min_alias_val AND
						 	 p_cnstrt_resolution	<0 ) THEN
							-- constraint cannot be resolved
							RETURN ('IGS_CA_INSTBREAK_CONS_UNRSVLD');
						END IF;
						v_changed := TRUE;
					END IF;
				END IF;
				EXIT WHEN v_changed = FALSE;
			END LOOP;
			-- resolve success or no resolving needed.
			p_alias_val := v_tmp_alias_val;
			p_mod_count := v_tmp_mod_count;
			RETURN null;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF c_m_alias_val2%ISOPEN THEN
				CLOSE c_m_alias_val2;
			END IF;
			IF c_instbreak%ISOPEN THEN
				CLOSE c_instbreak;
			END IF;
			RAISE;
	END;
	END calpl_inst_break_resolve;
	---------------------------------------------------------
	-- Procedure: calpl_constraint_resolve
	---------------------------------------------------------
	PROCEDURE calpl_constraint_resolve (
		p_constraint_count		IN OUT NOCOPY	NUMBER,
		p_mod_count			IN OUT NOCOPY	NUMBER,
		p_alias_val			IN OUT NOCOPY	IGS_CA_DA_INST.absolute_val%TYPE,
		p_message_name			OUT NOCOPY	 varchar2)
	AS
	BEGIN	-- This local procedure is try to resolve the clashed constraint record.
	DECLARE
		v_msg_name			 VARCHAR2(30);
		v_changed			BOOLEAN;
		CURSOR c_daoc IS
			SELECT	daoc.S_DT_OFFSET_CONSTRAINT_TYPE,
				daoc.constraint_condition,
				daoc.constraint_resolution
			FROM	IGS_CA_DA_OFFCNT	 daoc
			WHERE	daoc.DT_ALIAS			= p_dt_alias;
	BEGIN
		v_msg_name := NULL;
		FOR v_daoc_rec IN c_daoc LOOP
			p_constraint_count := p_constraint_count + 1;
			IF v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE IN (	cst_monday,
									cst_tuesday,
									cst_wednesday,
									cst_thursday,
									cst_friday,
									cst_saturday,
									cst_sunday)	THEN
				IF v_daoc_rec.constraint_condition = cst_must	THEN
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) <>
								v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				ELSE	-- NUST NOT
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) =
								v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				END IF;
			ELSIF 	v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE = cst_week_day THEN
				IF v_daoc_rec.constraint_condition = cst_must	THEN
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) NOT IN (cst_monday,
											cst_tuesday,
											cst_wednesday,
											cst_thursday,
											cst_friday) LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				ELSE	-- MUST NOT
					-- Use an inner loop to check and resolve any clash.
					WHILE RTRIM(TO_CHAR(p_alias_val,'DAY')) IN (	cst_monday,
											cst_tuesday,
											cst_wednesday,
											cst_thursday,
											cst_friday) LOOP
						p_alias_val := p_alias_val + v_daoc_rec.constraint_resolution;
						p_mod_count := p_mod_count + 1;
					END LOOP;
				END IF;
			ELSIF	v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE = cst_holiday THEN
				-- If the constraint type is 'HOLIDAY', check that the date does not clash
				-- against any date alias instance values in HOLIDAY calendars if the
				-- condition is 'MUST NOT' or that it matches a date alias instance value
				-- in a HOLIDAY calendar if the condition is 'MUST'.
				v_msg_name := calpl_holiday_resolve (
									v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE,
									v_daoc_rec.constraint_condition,
									v_daoc_rec.constraint_resolution,
									p_mod_count,
									p_alias_val);
				IF v_msg_name IS NOT NULL THEN
					p_message_name := v_msg_name;
				END IF;
			ELSIF	v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE = cst_inst_break THEN
				--If the constraint type is 'INST BREAK', check that the date does not fall
				-- between the dates defined by any date alias instance pairs in HOLIDAY
				-- calendars if the condition is 'MUST NOT' or that it does if the
				-- condition is 'MUST'.
				-- Use an inner loop to match the date against all defined DAIP's.
				-- Find the start and end dates of any DAI Pair.
				v_msg_name := calpl_inst_break_resolve (
									v_daoc_rec.S_DT_OFFSET_CONSTRAINT_TYPE,
									v_daoc_rec.constraint_condition,
									v_daoc_rec.constraint_resolution,
									p_mod_count,
									p_alias_val);
				IF v_msg_name IS NOT NULL THEN
					p_message_name := v_msg_name;
				END IF;
			END IF;
		END LOOP;	-- daoc loop
	EXCEPTION
		WHEN OTHERS THEN
			IF c_daoc%ISOPEN THEN
				CLOSE c_daoc;
			END IF;
			RAISE;
	END;
	END calpl_constraint_resolve;
BEGIN
	-- Set default value.
	p_message_name := NULL;
	v_message_name := NULL;
	v_mod_count :=0;
	v_constraint_count := 0;
	v_loop_count := 0;
	-- 1. Check parameters
	IF (		p_dt_alias		IS NULL	OR
			p_alias_val		IS NULL) THEN
		RETURN p_alias_val;
	END IF;
	-- 2. Check if any constraints exist for the date alias.
	--    If not, no further processing required.
	IF IGS_CA_VAL_DAOC.calp_val_daoc_exist (
					p_dt_alias,
					v_message_name) = TRUE THEN
		RETURN p_alias_val;
	END IF;
	v_alias_val := TRUNC(p_alias_val);
	-- 3. Set counters to be used to determine if the date constraints are
	--    unresolvable.
	WHILE v_loop_count <= 10 LOOP
		-- 4. Use a loop to select each existiong constraint record.
		--    and check the constraint against the date and if a clash exists,
		--    attempt to resolve it.
		calpl_constraint_resolve (
					v_constraint_count,
					v_mod_count,
					v_alias_val,
					v_message_name);
		IF v_message_name <> 0 THEN
			p_message_name := v_message_name;
		END IF;
		IF v_mod_count > 0	AND
				v_constraint_count > 1	THEN
			-- Value has been modified by a constraint, so reset the counters and loop
			-- through constraints again to ensure that changing the value for one
			-- constraint, has not caused to clash with another constraint it had
			-- already satisfied.
			v_mod_count := 0;
			v_constraint_count := 0;
			v_loop_count := v_loop_count + 1;
		ELSE
			RETURN v_alias_val;
		END IF;
	END LOOP; -- v_loop_count<=10
	-- Constraint is deemed unresolvable
	p_message_name := 'IGS_CA_ATTEMPT_TORESOLVE_FAIL';
	RETURN p_alias_val;
END;
END calp_clc_dao_cnstrt;
--
FUNCTION CALP_CLC_DT_FROM_DA(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN DATE AS
	v_other_detail	VARCHAR(255);
	v_alias_value	DATE;
	v_dt_alias_offset_rec	IGS_CA_DA_OFST%ROWTYPE;
	v_dt_alias_instance_rec	IGS_CA_DA_INST_V%ROWTYPE;
	v_date_offset		DATE := NULL;
	CURSOR	c_dt_alias_offset
	IS
	SELECT 	*
	FROM	IGS_CA_DA_OFST
	WHERE	DT_ALIAS = p_dt_alias;
	CURSOR	c_dt_alias_instance
	IS
	SELECT 	*
	FROM	IGS_CA_DA_INST_V
	WHERE	DT_ALIAS = v_dt_alias_offset_rec.offset_dt_alias and
		CAL_TYPE = p_cal_type and
		ci_sequence_number = p_ci_sequence_number
	ORDER BY 	alias_val ASC;
BEGIN
 	BEGIN
		OPEN c_dt_alias_offset;
		LOOP
			FETCH 	c_dt_alias_offset
			INTO	v_dt_alias_offset_rec;
			EXIT WHEN c_dt_alias_offset%NOTFOUND;
		END LOOP;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			p_message_name := NULL;
			v_alias_value := NULL;
			RETURN v_alias_value;
	END;
	BEGIN
		OPEN 	c_dt_alias_instance;
		LOOP
			FETCH 	c_dt_alias_instance
			INTO	v_dt_alias_instance_rec;
			EXIT;
		END LOOP;
		v_alias_value := v_dt_alias_instance_rec.alias_val;
		IF (NVL(v_dt_alias_offset_rec.year_offset,0) <> 0) THEN
			v_alias_value := add_months(v_dt_alias_instance_rec.alias_val,
						   (v_dt_alias_offset_rec.year_offset * 12));
		END IF;
		IF (NVL(v_dt_alias_offset_rec.month_offset,0) <> 0) THEN
			v_alias_value := add_months(v_alias_value,
						    v_dt_alias_offset_rec.month_offset);
		END IF;
		IF (NVL(v_dt_alias_offset_rec.week_offset,0) <> 0) THEN
			v_alias_value := v_alias_value +
				        (v_dt_alias_offset_rec.week_offset * 7);
		END IF;
		IF (NVL(v_dt_alias_offset_rec.day_offset,0) <> 0) THEN
			v_alias_value := v_alias_value +
					 v_dt_alias_offset_rec.day_offset;
		END IF;
		CLOSE 	c_dt_alias_instance;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			p_message_name :='IGS_CA_DTALIAS_NOT_PRESENT';
			v_alias_value := NULL;
			RETURN v_alias_value;
	END;
	IF(c_dt_alias_offset%ISOPEN) THEN
		CLOSE c_dt_alias_offset;
	END IF;
	IF(c_dt_alias_instance%ISOPEN) THEN
		CLOSE c_dt_alias_instance;
	END IF;
	RETURN v_alias_value;
END calp_clc_dt_from_da;
--
FUNCTION CALP_CLC_DT_FROM_DAI(
  p_ci_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN DATE AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- calp_clc_dt_from_dai
	-- Calculate a IGS_CA_DA_INST.alias_value from a
	-- IGS_CA_DA_INST_OFST.
DECLARE
	CURSOR c_daio IS
		SELECT 	daio.DT_ALIAS,
			daio.dai_sequence_number,
			daio.CAL_TYPE,
			daio.ci_sequence_number,
			daio.offset_dt_alias,
			daio.offset_dai_sequence_number,
			daio.offset_cal_type,
			daio.offset_ci_sequence_number,
			daio.day_offset,
			daio.week_offset,
			daio.month_offset,
			daio.year_offset
		FROM	IGS_CA_DA_INST_OFST daio
		WHERE	daio.DT_ALIAS 			= p_dt_alias AND
			daio.dai_sequence_number 	= p_dai_sequence_number AND
			daio.CAL_TYPE 			= p_cal_type AND
			daio.ci_sequence_number 	= p_ci_sequence_number;
	v_c_daio_rec		c_daio%ROWTYPE;
	CURSOR c_dai IS
		SELECT 	dai.DT_ALIAS,
			dai.sequence_number,
			dai.CAL_TYPE,
			dai.ci_sequence_number,
			dai.absolute_val
		FROM	IGS_CA_DA_INST	dai
		WHERE	dai.DT_ALIAS 		= v_c_daio_rec.offset_dt_alias AND
			dai.sequence_number 	= v_c_daio_rec.offset_dai_sequence_number AND
			dai.CAL_TYPE 		= v_c_daio_rec.offset_cal_type AND
			dai.ci_sequence_number 	= v_c_daio_rec.offset_ci_sequence_number;
	CURSOR c_daioc IS
		SELECT 	daioc.DT_ALIAS,
			daioc.dai_sequence_number,
			daioc.CAL_TYPE,
			daioc.ci_sequence_number
		FROM	IGS_CA_DA_INST_OFCNT	daioc
		WHERE	daioc.DT_ALIAS 		= p_dt_alias AND
			daioc.dai_sequence_number 	= p_dai_sequence_number AND
			daioc.CAL_TYPE 		= p_cal_type AND
			daioc.ci_sequence_number 	= p_ci_sequence_number;
	v_c_dai_rec		c_dai%ROWTYPE;
	v_c_daioc_rec		c_daioc%ROWTYPE;
	v_alias_value		DATE DEFAULT NULL;
	dt_alias_inst_offset_c_row	IGS_CA_DA_INST_OFCNT%ROWTYPE;
	v_other_detail		VARCHAR(255);
BEGIN
	p_message_name :=NULL;
	-- Find IGS_CA_DA_INST_OFST
	OPEN c_daio;
	FETCH c_daio INTO v_c_daio_rec;
	IF (c_daio%NOTFOUND) THEN
		CLOSE c_daio;
		p_message_name := 'IGS_CA_NO_DATE_ALIAS';
		v_alias_value := NULL;
		RETURN v_alias_value;
	END IF;
	CLOSE c_daio;
	-- Find IGS_CA_DA_INST
	OPEN c_dai;
	FETCH c_dai INTO v_c_dai_rec;
	IF (c_dai%NOTFOUND) THEN
		CLOSE c_dai;
		v_alias_value := NULL;
		RETURN v_alias_value;
	END IF;
	CLOSE c_dai;
	-- Calculate alias_value
	IF v_c_dai_rec.absolute_val IS NULL THEN
		v_alias_value := calp_clc_dt_from_dai(
				v_c_daio_rec.offset_ci_sequence_number,
				v_c_daio_rec.offset_cal_type,
				v_c_daio_rec.offset_dt_alias,
				v_c_daio_rec.offset_dai_sequence_number,
				p_message_name);
	ELSE
		v_alias_value := v_c_dai_rec.absolute_val;
	END IF;
	IF (NVL(v_c_daio_rec.year_offset,0) <> 0) THEN
		v_alias_value :=
		add_months(v_alias_value, (v_c_daio_rec.year_offset * 12));
	END IF;
	IF (NVL(v_c_daio_rec.month_offset,0) <> 0) THEN
		v_alias_value :=
		add_months(v_alias_value, v_c_daio_rec.month_offset);
	END IF;
	IF (NVL(v_c_daio_rec.week_offset,0) <> 0) THEN
		v_alias_value :=
		v_alias_value + (v_c_daio_rec.week_offset * 7);
	END IF;
	IF (NVL(v_c_daio_rec.day_offset,0) <> 0) THEN
		v_alias_value :=
		v_alias_value + v_c_daio_rec.day_offset;
	END IF;
	-- Following code relating to the resolution of offset constraints has been
	-- disabled due to performance issues.
	-- Test if offset constraints exist.
	OPEN c_daioc;
	FETCH c_daioc INTO v_c_daioc_rec;
	IF (c_daioc%NOTFOUND) THEN
		CLOSE c_daioc;
		RETURN v_alias_value;
	END IF;
	CLOSE c_daioc;
	-- Resolve the offset constraints.
	v_alias_value := calp_clc_daio_cnstrt(
				p_dt_alias,
				p_dai_sequence_number,
				p_cal_type,
				p_ci_sequence_number,
				v_alias_value,
				p_message_name);
	RETURN v_alias_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_daio%ISOPEN) THEN
			CLOSE c_daio;
		END IF;
		IF (c_dai%ISOPEN) THEN
			CLOSE c_dai;
		END IF;
		RAISE;
END;
END calp_clc_dt_from_dai;
--
FUNCTION CALP_CLC_WK_OF_MONTH(
  p_indate IN DATE )
RETURN INTEGER AS
BEGIN
DECLARE
    v_first_date DATE;
    v_month_str VARCHAR(255);
    v_first_dt_str VARCHAR(255);
    v_first_day NUMBER;
    v_wk_of_month NUMBER;
BEGIN
    -- Find out NOCOPY first date/day of this month
    v_month_str    := TO_CHAR(p_indate, 'MM/YYYY');
    v_first_dt_str := '01/' || v_month_str;
    v_first_date   := TO_DATE(v_first_dt_str, 'DD/MM/YYYY' );
    -- Get the day (number) of the week  for the first date,
    -- giving the offset in days for the whole month.
    v_first_day    := TO_NUMBER(TO_CHAR(v_first_date,'D'));
    v_wk_of_month  := TO_NUMBER((TO_CHAR(p_indate, 'DD') +
				 v_first_day - 1) / 7);
    RETURN CEIL(v_wk_of_month);
END;
END calp_clc_wk_of_month;
--
FUNCTION calp_val_ci_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS
	v_other_detail	VARCHAR2(255);
	v_closed_ind	IGS_CA_TYPE.closed_ind%TYPE;
	CURSOR c_get_closed_ind IS
		SELECT closed_ind
		FROM IGS_CA_TYPE
		WHERE CAL_TYPE = p_cal_type;
BEGIN
	p_message_name := NULL;
	OPEN c_get_closed_ind;
	FETCH c_get_closed_ind INTO v_closed_ind;
	IF (c_get_closed_ind%NOTFOUND) THEN
		CLOSE c_get_closed_ind;
		RETURN TRUE;
	END IF;
	CLOSE c_get_closed_ind;
	IF (v_closed_ind = 'N') THEN
		RETURN TRUE;
	ELSE
		p_message_name := 'IGS_CA_CALTYPE_CLOSED';
		RETURN FALSE;
	END IF;

END calp_val_ci_cat;
--
FUNCTION CALS_CLC_DT_FROM_DAI(
  p_ci_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER )
RETURN DATE AS
v_message_name	VARCHAR2(30);
BEGIN
	RETURN calp_clc_dt_from_dai(p_ci_sequence_number,
				p_cal_type,
				p_dt_alias,
				p_dai_sequence_number,
				v_message_name);
END cals_clc_dt_from_dai;
--
END IGS_CA_GEN_002 ;

/
