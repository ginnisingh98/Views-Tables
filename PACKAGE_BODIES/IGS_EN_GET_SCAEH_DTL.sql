--------------------------------------------------------
--  DDL for Package Body IGS_EN_GET_SCAEH_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GET_SCAEH_DTL" AS
/* $Header: IGSEN15B.pls 115.5 2002/02/11 13:43:21 pkm ship    $ */


  -- Get student course attempt effective history column value
  FUNCTION enrp_get_scaeh_col(
  p_column_name IN VARCHAR2 ,
  p_column_value IN VARCHAR2 ,
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd  IGS_PS_COURSE.course_cd%TYPE ,
  p_hist_start_dt IN DATE ,
  p_course_attempt_status  VARCHAR2 )
  RETURN VARCHAR2  AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN
  DECLARE
  	-- cursor to get the current student course attempt status
  	CURSOR c_sca (
  			cp_column_name		user_tab_columns.column_name%TYPE,
  			cp_person_id		IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  			cp_course_cd		IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  		SELECT	/*+ ROWID(IGS_EN_STDNT_PS_ATT) */
  			course_attempt_status,
  			commencement_dt,
  			DECODE(cp_column_name,	'VERSION_NUMBER', TO_CHAR(version_number),
  						'CAL_TYPE', cal_type,
  						'LOCATION_CD', location_cd,
  						'ATTENDANCE_MODE', attendance_mode,
  						'ATTENDANCE_TYPE', attendance_type,
  						'STUDENT_CONFIRMED_IND', student_confirmed_ind,
  						'COMMENCEMENT_DT', IGS_GE_DATE.IGSCHARDT(commencement_dt),
  						'COURSE_ATTEMPT_STATUS', course_attempt_status,
  						'DERIVED_ATT_TYPE', derived_att_type,
  						'DERIVED_ATT_MODE', derived_att_mode,
  						'PROVISIONAL_IND', provisional_ind,
  						'DISCONTINUED_DT', IGS_GE_DATE.IGSCHARDT(discontinued_dt),
  						'DISCONTINUATION_REASON_CD', discontinuation_reason_cd,
  						'FUNDING_SOURCE', funding_source,
  						'EXAM_LOCATION_CD', exam_location_cd,
  						'DERIVED_COMPLETION_YR', TO_CHAR(derived_completion_yr),
  						'DERIVED_COMPLETION_PERD', derived_completion_perd,
  						'NOMINATED_COMPLETION_YR', TO_CHAR(nominated_completion_yr),
  						'NOMINATED_COMPLETION_PERD', nominated_completion_perd,
  						'RULE_CHECK_IND', rule_check_ind,
  						'WAIVE_OPTION_CHECK_IND', waive_option_check_ind,
  						'LAST_RULE_CHECK_DT', IGS_GE_DATE.IGSCHARDT(last_rule_check_dt),
  						'PUBLISH_OUTCOMES_IND', publish_outcomes_ind,
  						'COURSE_RQRMNT_COMPLETE_IND', course_rqrmnt_complete_ind,
  						'OVERRIDE_TIME_LIMITATION', TO_CHAR(override_time_limitation),
  						'ADVANCED_STANDING_IND', advanced_standing_ind,
  						'FEE_CAT', fee_cat,
  						'CORRESPONDENCE_CAT', correspondence_cat,
  						'SELF_HELP_GROUP_IND', self_help_group_ind,
  						'PRIMARY_PROGRAM_TYPE', primary_program_type,  --Bug 2162747 by vvutukur
  						'KEY_PROGRAM', key_program)                    --Bug 2162747 by vvutukur
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd;
  	-- cursor to get the last enrolled history
  	CURSOR c_last_e_scah (
  			cp_column_name		user_tab_columns.column_name%TYPE,
  			cp_person_id		IGS_AS_SC_ATTEMPT_H.person_id%TYPE,
  			cp_course_cd		IGS_AS_SC_ATTEMPT_H.course_cd%TYPE) IS
  		SELECT	/*+ FIRST_ROWS */
  			hist_start_dt,
  			hist_end_dt,
  			DECODE(cp_column_name,	'VERSION_NUMBER', TO_CHAR(version_number),
  						'CAL_TYPE', cal_type,
  						'LOCATION_CD', location_cd,
  						'ATTENDANCE_MODE', attendance_mode,
  						'ATTENDANCE_TYPE', attendance_type,
  						'STUDENT_CONFIRMED_IND', student_confirmed_ind,
  						'COMMENCEMENT_DT', IGS_GE_DATE.IGSCHARDT(commencement_dt),
  						'COURSE_ATTEMPT_STATUS', course_attempt_status,
  						'DERIVED_ATT_TYPE', derived_att_type,
  						'DERIVED_ATT_MODE', derived_att_mode,
  						'PROVISIONAL_IND', provisional_ind,
  						'DISCONTINUED_DT', IGS_GE_DATE.IGSCHARDT(discontinued_dt),
  						'DISCONTINUATION_REASON_CD', discontinuation_reason_cd,
  						'FUNDING_SOURCE', funding_source,
  						'EXAM_LOCATION_CD', exam_location_cd,
  						'DERIVED_COMPLETION_YR', TO_CHAR(derived_completion_yr),
  						'DERIVED_COMPLETION_PERD', derived_completion_perd,
  						'NOMINATED_COMPLETION_YR', TO_CHAR(nominated_completion_yr),
  						'NOMINATED_COMPLETION_PERD', nominated_completion_perd,
  						'RULE_CHECK_IND', rule_check_ind,
  						'WAIVE_OPTION_CHECK_IND', waive_option_check_ind,
  						'LAST_RULE_CHECK_DT', IGS_GE_DATE.IGSCHARDT(last_rule_check_dt),
  						'PUBLISH_OUTCOMES_IND', publish_outcomes_ind,
  						'COURSE_RQRMNT_COMPLETE_IND', course_rqrmnt_complete_ind,
  						'OVERRIDE_TIME_LIMITATION', TO_CHAR(override_time_limitation),
  						'ADVANCED_STANDING_IND', advanced_standing_ind,
  						'FEE_CAT', fee_cat,
  						'CORRESPONDENCE_CAT', correspondence_cat,
  						'SELF_HELP_GROUP_IND', self_help_group_ind,
  						'PRIMARY_PROGRAM_TYPE', primary_program_type,
  						'KEY_PROGRAM', key_program)
  		FROM	IGS_AS_SC_ATTEMPT_H
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd AND
  			course_attempt_status = 'ENROLLED'
  		ORDER BY hist_start_dt DESC;
  	v_last_hist_start_dt	IGS_AS_SC_ATTEMPT_H.hist_start_dt%TYPE;
  	v_last_hist_end_dt	IGS_AS_SC_ATTEMPT_H.hist_end_dt%TYPE;
  	v_current_cas		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	v_current_c_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	v_current_col_value	VARCHAR2(2000);
  	v_hist_col_value	VARCHAR2(2000);
  	BEGIN
  		-- get the current course attempt status
  		OPEN	c_sca(	p_column_name,
  				p_person_id,
  				p_course_cd);
  		FETCH	c_sca	INTO	v_current_cas,
  					v_current_c_dt,
  					v_current_col_value;
  		CLOSE	c_sca;
  		-- The following assumptions have been made;
  		-- A student course attempt with course attempt status = 'ENROLLED' can be
  		-- changed to any other status
  		-- A student course attempt with course attempt status = 'DISCONTIN' can be
  		-- changed to 'ENROLLED' only
  		-- A student course attempt with course attempt status = 'UNCONFIRM' can be
  		-- changed to 'ENROLLED'
  		IF v_current_cas = 'DISCONTIN' THEN
  			IF p_course_attempt_status = 'DISCONTIN' THEN
  				-- All prior 'DISCONTINued histories are converted to match
  				-- the current student course attempt.
  				RETURN v_current_col_value;
  			ELSE -- history is not discontinued
  				-- Cannot be effectively discontinued before being
  				-- effectively enrolled.
  				-- All histories prior to discontinuation are considered
  				-- enrolled.
  				-- Find the last enrolled history entry
  				OPEN	c_last_e_scah(	p_column_name,
  							p_person_id,
  							p_course_cd);
  				FETCH	c_last_e_scah	INTO	v_last_hist_start_dt,
  								v_last_hist_end_dt,
  								v_hist_col_value;
  				IF (c_last_e_scah%NOTFOUND) THEN
  					CLOSE	c_last_e_scah;
  					RETURN p_column_value;
  				ELSE
  					CLOSE	c_last_e_scah;
  					IF v_hist_col_value IS NULL THEN
  						-- get the value of the first history instance
  						-- with a value for the column
  						v_hist_col_value := IGS_EN_GEN_004.ENRP_GET_SCAH_COL(
  									p_column_name,
  									p_person_id,
  									p_course_cd,
  									v_last_hist_end_dt);
  						IF v_hist_col_value IS NULL AND
  							p_column_name <> 'DISCONTINUED_DT' AND
  							p_column_name <> 'DISCONTINUATION_REASON_CD'
  						THEN
  							v_hist_col_value := v_current_col_value;
  						END IF;
  					END IF;
  					RETURN v_hist_col_value;
  				END IF;
  			END IF;
  		ELSIF v_current_cas = 'ENROLLED' THEN
  			-- All histories converted to the ENROLLED definition.
  			RETURN v_current_col_value;
  		ELSIF v_current_cas = 'UNCONFIRM' THEN
  			-- All histories converted to the UNCONFIRMed definition.
  			RETURN v_current_col_value;
  		ELSE
  			IF v_current_c_dt IS NOT NULL THEN
  				-- attempt to find the last enrolled history entry
  				OPEN	c_last_e_scah(	p_column_name,
  							p_person_id,
  							p_course_cd);
  				FETCH	c_last_e_scah	INTO	v_last_hist_start_dt,
  								v_last_hist_end_dt,
  								v_hist_col_value;
  				IF (c_last_e_scah%NOTFOUND) THEN
  					CLOSE	c_last_e_scah;
  					RETURN p_column_value;
  				ELSE
  					CLOSE	c_last_e_scah;
  					IF p_hist_start_dt <= v_last_hist_start_dt THEN
  						-- All histories prior to and including the
  						-- last ENROLLED history are converted to the
  						-- last ENROLLED definition.
  						IF v_hist_col_value IS NULL THEN
  							-- get the value of the first history
  							-- instance with a value for the column
  							v_hist_col_value := IGS_EN_GEN_004.ENRP_GET_SCAH_COL(
  									p_column_name,
  									p_person_id,
  									p_course_cd,
  									v_last_hist_end_dt);
  							IF v_hist_col_value IS NULL AND
  								p_column_name <> 'DISCONTINUED_DT' AND
  								p_column_name <> 'DISCONTINUATION_REASON_CD'
  							THEN
  								v_hist_col_value := v_current_col_value;
  							END IF;
  						END IF;
  						RETURN v_hist_col_value;
  					ELSE
  						RETURN p_column_value;
  					END IF;
  				END IF;
  			ELSE
  				RETURN p_column_value;
  			END IF;
  		END IF;
  	END;
  EXCEPTION
  	WHEN OTHERS THEN
  		gv_other_detail := 'Parm: p_column_name - ' || p_column_name
  			|| ' p_person_id - ' || TO_CHAR(p_person_id)
  			|| ' p_course_cd - ' || p_course_cd
  			|| ' p_course_attempt_status - ' || p_course_attempt_status
  			|| ' p_hist_start_dt - ' || IGS_GE_DATE.IGSCHARDT(p_hist_start_dt);

  		RAISE;
  END enrp_get_scaeh_col;
  --
  -- Routine to get the effective end date for a SCA history
  FUNCTION enrp_get_scaeh_eff_end(
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt IN DATE ,
  p_course_attempt_status IN VARCHAR2 )
  RETURN DATE  AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN
  DECLARE
  	-- cursor to get the current student course attempt status
  	CURSOR c_sca (
  			cp_person_id		IGS_AS_SC_ATTEMPT_H.person_id%TYPE,
  			cp_course_cd		IGS_AS_SC_ATTEMPT_H.course_cd%TYPE) IS
  		SELECT	/*+ ROWID(IGS_EN_STDNT_PS_ATT) */
  			course_attempt_status,
  			commencement_dt,
  			discontinued_dt
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd;
  	-- cursor to get the last enrolled history
  	CURSOR c_last_e_scah (
  			cp_person_id		IGS_AS_SC_ATTEMPT_H.person_id%TYPE,
  			cp_course_cd		IGS_AS_SC_ATTEMPT_H.course_cd%TYPE) IS
  		SELECT	MAX(hist_end_dt)
  		FROM	IGS_AS_SC_ATTEMPT_H
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd AND
  			course_attempt_status = 'ENROLLED';
  	v_current_cas		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	v_current_c_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	v_current_d_dt		IGS_EN_STDNT_PS_ATT.discontinued_dt%TYPE;
  	v_last_hist_end_dt	IGS_AS_SC_ATTEMPT_H.hist_end_dt%TYPE;
  	BEGIN	-- enrp_get_scaeh_eff_end
  		-- get the current course attempt status
  		OPEN	c_sca(	p_person_id,
  				p_course_cd);
  		FETCH	c_sca	INTO	v_current_cas,
  					v_current_c_dt,
  					v_current_d_dt;
  		CLOSE	c_sca;
  		-- The following assumptions have been made;
  		-- A student course attempt with course attempt status = 'ENROLLED' can be
  		-- changed to any other status
  		-- A student course attempt with course attempt status = 'DISCONTIN' can be
  		-- changed to 'ENROLLED' only
  		-- A student course attempt with course attempt status = 'UNCONFIRM' can be
  		-- changed to 'ENROLLED'
  		IF v_current_cas = 'DISCONTIN' THEN
  			IF p_course_attempt_status = 'DISCONTIN' THEN
  				-- All prior 'DISCONTINued histories are converted to match
  				-- the current student course attempt.
  				-- End the history at the same time as the current
  				-- student course attempt ie. now
  				RETURN IGS_GE_DATE.IGSDATE(IGS_GE_DATE.IGSCHAR(SYSDATE)||' 23:59:59');
  			ELSE -- history is not discontinued
  				-- Cannot be effectively discontinued before being
  				-- effectively enrolled.
  				-- All histories prior to discontinuation are considered
  				-- enrolled and ended at the start of the discontinuation
  				RETURN v_current_d_dt;
  			END IF;
  		ELSIF v_current_cas = 'ENROLLED' THEN
  			-- All histories converted to the ENROLLED definition.
  			-- End the history at the same time as the current
  			-- student course attempt ie. now
  			RETURN IGS_GE_DATE.IGSDATE(IGS_GE_DATE.IGSCHAR(SYSDATE)||' 23:59:59');
  		ELSIF v_current_cas = 'UNCONFIRM' THEN
  			-- All histories converted to the UNCONFIRMed definition.
  			-- End the history at the same time as the current
  			-- student course attempt ie. now
  			RETURN IGS_GE_DATE.IGSDATE(IGS_GE_DATE.IGSCHAR(SYSDATE)||' 23:59:59');
  		      ELSE
  			IF v_current_c_dt IS NOT NULL THEN
  				-- attempt to find the last enrolled history entry
  				OPEN	c_last_e_scah(
  						p_person_id,
  						p_course_cd);
  				FETCH	c_last_e_scah	INTO	v_last_hist_end_dt;
  				IF (c_last_e_scah%NOTFOUND) THEN
  					CLOSE	c_last_e_scah;
  					RETURN p_hist_end_dt;
  				ELSE
  					CLOSE	c_last_e_scah;
  					IF p_hist_end_dt <= v_last_hist_end_dt THEN
  						-- all histories prior to and including the
  						-- last ENROLLED history are converted to the
  						-- last ENROLLED definition
  						RETURN v_last_hist_end_dt;
  					ELSE
  						RETURN p_hist_end_dt;
  					END IF;
  				END IF;
  			ELSE
  				RETURN p_hist_end_dt;
  			END IF;
  		END IF;
  	END;
  EXCEPTION
  	WHEN OTHERS THEN
  		gv_other_detail := 'Parm: p_person_id - '
  			|| TO_CHAR(p_person_id)
  			|| ' p_course_cd - '
    			|| p_course_cd
  			|| ' p_hist_end_dt - '
  			|| IGS_GE_DATE.IGSCHAR(p_hist_end_dt)
  			|| ' p_course_attempt_status - '
  			|| p_course_attempt_status;

  		RAISE;
  END enrp_get_scaeh_eff_end;
  --
  -- Routine to get the effective start date for a SCA history
  FUNCTION enrp_get_scaeh_eff_st(
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_start_dt IN DATE ,
  p_course_attempt_status IN VARCHAR2 )
  RETURN DATE  AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN
  DECLARE
  	-- cursor to get the current student course attempt status
  	CURSOR c_sca (
  			cp_person_id		IGS_AS_SC_ATTEMPT_H.person_id%TYPE,
  			cp_course_cd		IGS_AS_SC_ATTEMPT_H.course_cd%TYPE) IS
  		SELECT	/*+ ROWID(IGS_EN_STDNT_PS_ATT) */
  			course_attempt_status,
  			commencement_dt,
  			discontinued_dt
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd;
  	CURSOR c_last_e_scah (
  			cp_person_id		IGS_AS_SC_ATTEMPT_H.person_id%TYPE,
  			cp_course_cd		IGS_AS_SC_ATTEMPT_H.course_cd%TYPE) IS
  		SELECT	MAX(hist_start_dt)
  		FROM	IGS_AS_SC_ATTEMPT_H
  		WHERE	person_id = cp_person_id AND
  			course_cd = cp_course_cd AND
  			course_attempt_status = 'ENROLLED';
  	v_last_hist_start_dt	IGS_AS_SC_ATTEMPT_H.hist_start_dt%TYPE;
  	v_current_cas		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	v_current_c_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	v_current_d_dt		IGS_EN_STDNT_PS_ATT.discontinued_dt%TYPE;
  	BEGIN	-- enrp_get_scaeh_eff_st
  		-- get the current course attempt status
  		OPEN	c_sca(	p_person_id,
  				p_course_cd);
  		FETCH	c_sca	INTO	v_current_cas,
  					v_current_c_dt,
  					v_current_d_dt;
  		CLOSE	c_sca;
  		-- The following assumptions have been made;
  		-- A student course attempt with course attempt status = 'ENROLLED' can be
  		-- changed to any other status
  		-- A student course attempt with course attempt status = 'DISCONTIN' can be
  		-- changed to 'ENROLLED' only
  		-- A student course attempt with course attempt status = 'UNCONFIRM' can be
  		-- changed to 'ENROLLED'
  		IF v_current_cas = 'DISCONTIN' THEN
  			IF p_course_attempt_status = 'DISCONTIN' THEN
  				-- All prior 'DISCONTINued histories are converted to match
  				-- the current student course attempt.
  				-- Start the history at the same effective time as the current
  				-- student course attempt ie. now
  				RETURN v_current_d_dt;
  			ELSE -- history is not discontinued
  				-- Cannot be effectively discontinued before being
  				-- effectively enrolled.
  				-- All histories prior to discontinuation are considered
  				-- enrolled and commenced at the start of the enrolment
  				IF TRUNC(v_current_c_dt) <= TRUNC(SYSDATE) THEN
  					RETURN v_current_c_dt;
  				ELSE -- commencing in the future
  					RETURN TRUNC(SYSDATE);
  				END IF;
  			END IF;
  		ELSIF v_current_cas = 'ENROLLED' THEN
  			-- All histories converted to the ENROLLED definition.
  			-- Start the history at the same time as the current
  			-- student course attempt ie. now
  			IF TRUNC(v_current_c_dt) <= TRUNC(SYSDATE) THEN
  				RETURN v_current_c_dt;
  			ELSE -- commencing in the future
  				RETURN TRUNC(SYSDATE);
  			END IF;
  		ELSIF v_current_cas = 'UNCONFIRM' THEN
  			-- All histories converted to the UNCONFIRMed definition.
  			-- Start the history at the same time as the current
  			-- student course attempt ie. now
  			RETURN TRUNC(SYSDATE);
  		ELSE
  			IF v_current_c_dt IS NOT NULL THEN
  				-- attempt to find the last enrolled history entry
  				OPEN	c_last_e_scah(
  						p_person_id,
  						p_course_cd);
  				FETCH	c_last_e_scah	INTO	v_last_hist_start_dt;
  				IF (c_last_e_scah%NOTFOUND) THEN
  					CLOSE	c_last_e_scah;
  					RETURN p_hist_start_dt;
  				ELSE
  					CLOSE	c_last_e_scah;
  					IF p_hist_start_dt <= v_last_hist_start_dt THEN
  						-- all histories prior to and including the
  						-- last ENROLLED history are converted to
  						-- the last ENROLLED definition using it's
  						-- commencement dt as the start
  						IF TRUNC(v_current_c_dt) <= TRUNC(SYSDATE) THEN
  							RETURN v_current_c_dt;
  						ELSE -- commencing in the future
  							RETURN TRUNC(SYSDATE);
  						END IF;
  					ELSE
  						RETURN p_hist_start_dt;
  					END IF;
  				END IF;
  			ELSE
  				RETURN p_hist_start_dt;
  			END IF;
  		END IF;
  	END;
  EXCEPTION
  	WHEN OTHERS THEN
  		gv_other_detail := 'Parm: p_person_id - '
  			|| TO_CHAR(p_person_id)
  			|| ' p_course_cd - '
    			|| p_course_cd
    			|| ' p_hist_start_dt - '
  			|| IGS_GE_DATE.IGSCHARDT(p_hist_start_dt)
  			|| ' p_course_attempt_status - '
  			|| p_course_attempt_status;

  		RAISE;
  END enrp_get_scaeh_eff_st;
END IGS_EN_GET_SCAEH_DTL;

/
