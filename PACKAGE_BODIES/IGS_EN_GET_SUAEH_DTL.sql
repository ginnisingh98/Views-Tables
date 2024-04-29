--------------------------------------------------------
--  DDL for Package Body IGS_EN_GET_SUAEH_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GET_SUAEH_DTL" AS
/* $Header: IGSEN16B.pls 115.6 2003/06/23 10:36:29 rvivekan ship $ */

  -- Get student unit attempt effective history column value
  FUNCTION enrp_get_suaeh_col(
  p_column_name                 IN VARCHAR2 ,
  p_column_value                IN VARCHAR2 ,
  p_person_id                   IN hz_parties.party_id%TYPE ,
  p_course_cd                   IN IGS_PS_COURSE.course_cd%TYPE ,
  p_unit_cd                     IN IGS_PS_UNIT.unit_cd%TYPE ,
  p_cal_type                    IN IGS_CA_TYPE.cal_type%TYPE ,
  p_ci_seq_num                  IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_hist_start_dt               IN DATE ,
  p_unit_attempt_status         IN VARCHAR2,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      New parameter p_uoo_id is added to this function and
  --                            c_sua and c_last_e_suah got modified due to change of pk of
  --                            student unit attempt w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  RETURN VARCHAR2  AS
        gv_other_detail                 VARCHAR2(255);
  BEGIN
  DECLARE
        -- cursor to get the current student unit attempt status
        CURSOR c_sua (  cp_column_name          user_tab_columns.column_name%TYPE,
                        cp_person_id            igs_en_su_attempt.person_id%TYPE,
                        cp_course_cd            igs_en_su_attempt.course_cd%TYPE,
                        cp_uoo_id               igs_en_su_attempt.uoo_id%TYPE) IS
                SELECT  /*+ ROWID(IGS_EN_SU_ATTEMPT) */
                        unit_attempt_status,
                        enrolled_dt,
                        DECODE (cp_column_name,
                                'VERSION_NUMBER',               TO_CHAR(version_number),
                                'LOCATION_CD',                  location_cd,
                                'UNIT_CLASS',                   unit_class,
                                'ENROLLED_DT',                  IGS_GE_DATE.IGSCHARDT(enrolled_dt),
                                'UNIT_ATTEMPT_STATUS',          unit_attempt_status,
                                'ADMINISTRATIVE_UNIT_STATUS',   administrative_unit_status,
                                'DISCONTINUED_DT',              IGS_GE_DATE.IGSCHARDT(discontinued_dt),
                                'RULE_WAIVED_DT',               IGS_GE_DATE.IGSCHARDT(rule_waived_dt),
                                'RULE_WAIVED_PERSON_ID',        TO_CHAR(rule_waived_person_id),
                                'NO_ASSESSMENT_IND',            no_assessment_ind,
                                'EXAM_LOCATION_CD',             exam_location_cd,
                                'SUP_VERSION_NUMBER',           TO_CHAR(sup_version_number),
                                'ALTERNATIVE_TITLE',            alternative_title,
                                'OVERRIDE_ENROLLED_CP',         TO_CHAR(override_enrolled_cp),
                                'OVERRIDE_EFTSU',               TO_CHAR(override_eftsu),
                                'OVERRIDE_ACHIEVABLE_CP',       TO_CHAR(override_achievable_cp),
                                'OVERRIDE_OUTCOME_DUE_DT',      IGS_GE_DATE.IGSCHARDT(override_outcome_due_dt),
                                'OVERRIDE_CREDIT_REASON',       override_credit_reason)
                FROM    IGS_EN_SU_ATTEMPT
                WHERE   person_id = cp_person_id AND
                        course_cd = cp_course_cd AND
                        uoo_id    = cp_uoo_id;
        -- cursor to get the last enrolled history
        CURSOR c_last_e_suah (
                        cp_column_name          user_tab_columns.column_name%TYPE,
                        cp_person_id            igs_en_su_attempt_h.person_id%TYPE,
                        cp_course_cd            igs_en_su_attempt_h.course_cd%TYPE,
                        cp_uoo_id               igs_en_su_attempt_h.uoo_id%TYPE) IS
                SELECT  /*+ FIRST_ROWS */
                        hist_start_dt,
                        hist_end_dt,
                        DECODE (cp_column_name,
                                'VERSION_NUMBER',               TO_CHAR(version_number),
                                'LOCATION_CD',                  location_cd,
                                'UNIT_CLASS',                   unit_class,
                                'ENROLLED_DT',                  IGS_GE_DATE.IGSCHARDT(enrolled_dt),
                                'UNIT_ATTEMPT_STATUS',          unit_attempt_status,
                                'ADMINISTRATIVE_UNIT_STATUS',   administrative_unit_status,
                                'DISCONTINUED_DT',              IGS_GE_DATE.IGSCHARDT(discontinued_dt),
                                'RULE_WAIVED_DT',               IGS_GE_DATE.IGSCHARDT(rule_waived_dt),
                                'RULE_WAIVED_PERSON_ID',        TO_CHAR(rule_waived_person_id),
                                'NO_ASSESSMENT_IND',            no_assessment_ind,
                                'EXAM_LOCATION_CD',             exam_location_cd,
                                'SUP_VERSION_NUMBER',           TO_CHAR(sup_version_number),
                                'ALTERNATIVE_TITLE',            alternative_title,
                                'OVERRIDE_ENROLLED_CP',         TO_CHAR(override_enrolled_cp),
                                'OVERRIDE_EFTSU',               TO_CHAR(override_eftsu),
                                'OVERRIDE_ACHIEVABLE_CP',       TO_CHAR(override_achievable_cp),
                                'OVERRIDE_OUTCOME_DUE_DT',      IGS_GE_DATE.IGSCHARDT(override_outcome_due_dt),
                                'OVERRIDE_CREDIT_REASON',       override_credit_reason)
                FROM    IGS_EN_SU_ATTEMPT_H
                WHERE   person_id           = cp_person_id AND
                        course_cd           = cp_course_cd AND
                        uoo_id              = cp_uoo_id AND
                        unit_attempt_status = 'ENROLLED'
                ORDER BY hist_start_dt DESC;
        v_last_hist_start_dt    IGS_EN_SU_ATTEMPT_H.hist_start_dt%TYPE;
        v_last_hist_end_dt      IGS_EN_SU_ATTEMPT_H.hist_end_dt%TYPE;
        v_current_cas           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        v_current_e_dt          IGS_EN_SU_ATTEMPT.enrolled_dt%TYPE;
        v_current_col_value     VARCHAR2(2000);
        v_hist_col_value        VARCHAR2(2000);
        BEGIN
                -- get the current unit attempt status
                OPEN    c_sua(  p_column_name,
                                p_person_id,
                                p_course_cd,
                                p_uoo_id);
                FETCH   c_sua   INTO    v_current_cas,
                                        v_current_e_dt,
                                        v_current_col_value;
                CLOSE   c_sua;
                -- The following assumptions have been made;
                -- A student unit attempt with unit attempt status = 'ENROLLED' can be
                -- changed to any other status
                -- A student unit attempt with unit attempt status = 'DISCONTIN' can be
                -- changed to 'ENROLLED' only
                -- A student unit attempt with unit attempt status = 'UNCONFIRM' can be
                -- changed to 'ENROLLED'
                IF v_current_cas = 'DISCONTIN' THEN
                        IF p_unit_attempt_status = 'DISCONTIN' THEN
                                -- All prior 'DISCONTINued histories are converted to match
                                -- the current student unit attempt.
                                RETURN v_current_col_value;
                        ELSE -- history is not discontinued
                                -- Cannot be effectively discontinued before being
                                -- effectively enrolled.
                                -- All histories prior to discontinuation are considered
                                -- enrolled.
                                -- Find the last enrolled history entry
                                OPEN    c_last_e_suah(  p_column_name,
                                                        p_person_id,
                                                        p_course_cd,
                                                        p_uoo_id);
                                FETCH   c_last_e_suah   INTO    v_last_hist_start_dt,
                                                                v_last_hist_end_dt,
                                                                v_hist_col_value;
                                IF (c_last_e_suah%NOTFOUND) THEN
                                        CLOSE   c_last_e_suah;
                                        RETURN p_column_value;
                                ELSE
                                        CLOSE   c_last_e_suah;
                                        IF v_hist_col_value IS NULL THEN
                                                -- get the value of the first history instance
                                                -- with a value for the column
                                                v_hist_col_value := IGS_EN_GEN_007.ENRP_GET_SUAH_COL(
                                                                        p_column_name,
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        p_unit_cd,
                                                                        p_cal_type,
                                                                        p_ci_seq_num,
                                                                        v_last_hist_end_dt,
                                                                        p_uoo_id);
                                                IF v_hist_col_value IS NULL AND
                                                        p_column_name <> 'ADMINISTRATIVE_UNIT_STATUS' AND
                                                        p_column_name <> 'DISCONTINUED_DT'
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
                        IF v_current_e_dt IS NOT NULL THEN
                                -- attempt to find the last enrolled history entry
                                OPEN    c_last_e_suah(  p_column_name,
                                                        p_person_id,
                                                        p_course_cd,
                                                        p_uoo_id);
                                FETCH   c_last_e_suah   INTO    v_last_hist_start_dt,
                                                                v_last_hist_end_dt,
                                                                v_hist_col_value;
                                IF (c_last_e_suah%NOTFOUND) THEN
                                        CLOSE   c_last_e_suah;
                                        RETURN p_column_value;
                                ELSE
                                        CLOSE   c_last_e_suah;
                                        IF p_hist_start_dt <= v_last_hist_start_dt THEN
                                                -- All histories prior to and including the
                                                -- last ENROLLED history are converted to the
                                                -- last ENROLLED definition.
                                                IF v_hist_col_value IS NULL THEN
                                                        -- get the value of the first history
                                                        -- instance with a value for the column
                                                        v_hist_col_value := IGS_EN_GEN_007.ENRP_GET_SUAH_COL(
                                                                        p_column_name,
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        p_unit_cd,
                                                                        p_cal_type,
                                                                        p_ci_seq_num,
                                                                        v_last_hist_end_dt,
                                                                        p_uoo_id);
                                                        IF v_hist_col_value IS NULL  AND
                                                                p_column_name <> 'ADMINISTRATIVE_UNIT_STATUS' AND
                                                                p_column_name <> 'DISCONTINUED_DT'
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
                        || ' p_unit_cd - ' || p_unit_cd
                        || ' p_cal_type - ' || p_cal_type
                        || ' p_ci_seq_num - ' || TO_CHAR(p_ci_seq_num)
                        || ' p_unit_attempt_status - ' || p_unit_attempt_status
                        || ' p_hist_start_dt - ' || IGS_GE_DATE.IGSCHARDT(p_hist_start_dt)
                        || ' p_uoo_id - '||TO_CHAR(p_uoo_id);
                RAISE;
  END enrp_get_suaeh_col;
  --
  -- Routine to get the effective end date for a SUA history
  FUNCTION enrp_get_suaeh_eff_end(
  p_person_id                   IN IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd                   IN IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_unit_cd                     IN IGS_EN_SU_ATTEMPT_H_ALL.unit_cd%TYPE ,
  p_cal_type                    IN IGS_EN_SU_ATTEMPT_H_ALL.cal_type%TYPE ,
  p_ci_sequence_num             IN IGS_EN_SU_ATTEMPT_H_ALL.ci_sequence_number%TYPE ,
  p_hist_end_dt                 IN IGS_EN_SU_ATTEMPT_H_ALL.hist_end_dt%TYPE ,
  p_unit_attempt_status         IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rvivekan    23-Jun-2003	modified cursor c_last_e_suah as it was giving rise to
  --				perfomance issues. (Bug#2879291)
  --kkillams    28-04-2003      New parameter p_uoo_id is added to this function and
  --                            c_sua and c_last_e_suah got modified due to change of pk of
  --                            student unit attempt w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  RETURN DATE  AS
        gv_other_detail                 VARCHAR2(255);
  BEGIN
  DECLARE
        -- cursor to get the current student unit attempt status
        CURSOR c_sua (
                        cp_person_id            IGS_EN_SU_ATTEMPT.person_id%TYPE,
                        cp_course_cd            IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                        cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
                SELECT  /*+ ROWID(IGS_EN_SU_ATTEMPT) */
                        unit_attempt_status,
                        enrolled_dt,
                        discontinued_dt
                FROM    IGS_EN_SU_ATTEMPT
                WHERE   person_id = cp_person_id AND
                        course_cd = cp_course_cd AND
                        uoo_id    = cp_uoo_id;
        -- cursor to get the last enrolled history..modified cursor due perfomance issues
        CURSOR c_last_e_suah (
                        cp_person_id            IGS_EN_SU_ATTEMPT_H.person_id%TYPE,
                        cp_course_cd            IGS_EN_SU_ATTEMPT_H.course_cd%TYPE,
                        cp_uoo_id               IGS_EN_SU_ATTEMPT_H.uoo_id%TYPE) IS
		SELECT MAX(SUAH1.hist_end_dt)
		FROM IGS_EN_SU_ATTEMPT_H suah1, IGS_EN_SU_ATTEMPT sua1
		WHERE SUA1.person_id = SUAH1.person_id AND SUA1.course_cd = SUAH1.course_cd AND SUA1.uoo_id = SUAH1.uoo_id
		AND SUAH1.person_id =  cp_person_id AND SUAH1.course_cd = cp_course_cd AND SUAH1.uoo_id = cp_uoo_id
		AND SUBSTR(NVL(SUAH1.unit_attempt_status, NVL(Igs_Au_Gen_003.audp_get_suah_col('UNIT_ATTEMPT_STATUS', SUAH1.person_id, SUAH1.course_cd, SUAH1.hist_end_dt, SUAH1.uoo_id ), SUA1.unit_attempt_status)),1,10)='ENROLLED'  ;

        v_current_uas           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        v_current_e_dt          IGS_EN_SU_ATTEMPT.enrolled_dt%TYPE;
        v_current_d_dt          IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;
        v_last_hist_end_dt      IGS_EN_SU_ATTEMPT_H.hist_end_dt%TYPE;
        BEGIN   -- enrp_get_scahl_eff_end
                -- get the current unit attempt status
                OPEN    c_sua(  p_person_id,
                                p_course_cd,
                                p_uoo_id);
                FETCH   c_sua   INTO    v_current_uas,
                                        v_current_e_dt,
                                        v_current_d_dt;
                CLOSE   c_sua;
                -- The following assumptions have been made;
                -- A student unit attempt with unit attempt status = 'ENROLLED' can be
                -- changed to any other status
                -- A student unit attempt with unit attempt status = 'DISCONTIN' can be
                -- changed to 'ENROLLED' only
                -- A student unit attempt with unit attempt status = 'UNCONFIRM' can be
                -- changed to 'ENROLLED'
                IF v_current_uas = 'DISCONTIN' THEN
                        IF p_unit_attempt_status = 'DISCONTIN' THEN
                                -- All prior 'DISCONTINued histories are converted to match
                                -- the current student unit attempt.
                                -- End the history at the same time as the current
                                -- student unit attempt ie. now
                                RETURN IGS_GE_DATE.IGSDATE(IGS_GE_DATE.IGSCHAR(SYSDATE)||' 23:59:59');
                        ELSE -- history is not discontinued
                                -- Cannot be effectively discontinued before being
                                -- effectively enrolled.
                                -- All histories prior to discontinuation are considered
                                -- enrolled and ended at the start of the discontinuation
                                RETURN v_current_d_dt;
                        END IF;
                ELSIF v_current_uas = 'ENROLLED' THEN
                        -- All histories converted to the ENROLLED definition.
                        -- End the history at the same time as the current
                        -- student unit attempt ie. now
                        RETURN IGS_GE_DATE.IGSDATE(IGS_GE_DATE.IGSCHAR(SYSDATE)||' 23:59:59');
                ELSIF v_current_uas = 'UNCONFIRM' THEN
                        -- All histories converted to the UNCONFIRMed definition.
                        -- End the history at the same time as the current
                        -- student unit attempt ie. now
                        RETURN IGS_GE_DATE.IGSDATE(IGS_GE_DATE.IGSCHAR(SYSDATE)||' 23:59:59');
                ELSE
                        IF v_current_e_dt IS NOT NULL THEN
                                -- attempt to find the last enrolled history entry
                                OPEN    c_last_e_suah(
                                                p_person_id,
                                                p_course_cd,
                                                p_uoo_id);
                                FETCH   c_last_e_suah   INTO    v_last_hist_end_dt;
                                IF (c_last_e_suah%NOTFOUND) THEN
                                        CLOSE   c_last_e_suah;
                                        RETURN p_hist_end_dt;
                                ELSE
                                        CLOSE   c_last_e_suah;
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
                gv_other_detail := 'Parm: p_person_id - '|| TO_CHAR(p_person_id)
                                   || ' p_course_cd - '|| p_course_cd
                                   || ' p_unit_cd - '|| p_unit_cd
                                   || ' p_cal_type - '|| p_cal_type
                                   || ' p_ci_sequence_num - '|| TO_CHAR(p_ci_sequence_num)
                                   || ' p_hist_end_dt - '|| IGS_GE_DATE.IGSCHAR(p_hist_end_dt)
                                   || ' p_unit_attempt_status - '|| p_unit_attempt_status
                                   || ' p_uoo_id - '||TO_CHAR(p_uoo_id);
                RAISE;
  END enrp_get_suaeh_eff_end;
  --
  -- Routine to get the effective start date for a SUA history
  FUNCTION enrp_get_suaeh_eff_st(
  p_person_id                   IN IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd                   IN IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_unit_cd                     IN IGS_EN_SU_ATTEMPT_H_ALL.unit_cd%TYPE ,
  p_cal_type                    IN IGS_EN_SU_ATTEMPT_H_ALL.cal_type%TYPE ,
  p_ci_sequence_num             IN IGS_EN_SU_ATTEMPT_H_ALL.ci_sequence_number%TYPE ,
  p_hist_start_dt               IN IGS_EN_SU_ATTEMPT_H_ALL.hist_start_dt%TYPE ,
  p_unit_attempt_status         IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      New parameter p_uoo_id is added to this function and
  --                            c_sua and c_last_e_suah got modified due to change of pk of
  --                            student unit attempt w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  RETURN DATE  AS
        gv_other_detail                 VARCHAR2(255);
  BEGIN
  DECLARE
        -- cursor to get the current student unit attempt status
        CURSOR c_sua (
                        cp_person_id            IGS_EN_SU_ATTEMPT.person_id%TYPE,
                        cp_course_cd            IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                        cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
                SELECT  unit_attempt_status,
                        enrolled_dt,
                        discontinued_dt
                FROM    IGS_EN_SU_ATTEMPT
                WHERE   person_id = cp_person_id AND
                        course_cd = cp_course_cd AND
                        uoo_id    = cp_uoo_id;
        CURSOR c_last_e_suah (
                        cp_person_id            IGS_EN_SU_ATTEMPT_H.person_id%TYPE,
                        cp_course_cd            IGS_EN_SU_ATTEMPT_H.course_cd%TYPE,
                        cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
                SELECT  MAX(hist_start_dt)
                FROM    IGS_EN_SU_ATTEMPT_H
                WHERE   person_id = cp_person_id AND
                        course_cd = cp_course_cd AND
                        uoo_id    = cp_uoo_id AND
                        unit_attempt_status = 'ENROLLED';
        v_last_hist_start_dt    IGS_EN_SU_ATTEMPT_H.hist_start_dt%TYPE;
        v_current_uas           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        v_current_e_dt          IGS_EN_SU_ATTEMPT.enrolled_dt%TYPE;
        v_current_d_dt          IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;
        BEGIN   -- enrp_get_scahl_eff_st
                -- get the current unit attempt status
                OPEN    c_sua(  p_person_id,
                                p_course_cd,
                                p_uoo_id);
                FETCH   c_sua   INTO    v_current_uas,
                                        v_current_e_dt,
                                        v_current_d_dt;
                CLOSE   c_sua;
                -- The following assumptions have been made;
                -- A student unit attempt with unit attempt status = 'ENROLLED' can be
                -- changed to any other status
                -- A student unit attempt with unit attempt status = 'DISCONTIN' can be
                -- changed to 'ENROLLED' only
                -- A student unit attempt with unit attempt status = 'UNCONFIRM' can be
                -- changed to 'ENROLLED'
                IF v_current_uas = 'DISCONTIN' THEN
                        IF p_unit_attempt_status = 'DISCONTIN' THEN
                                -- All prior 'DISCONTINued histories are converted to match
                                -- the current student unit attempt.
                                -- Start the history at the same effective time as the current
                                -- student unit attempt ie. now
                                RETURN v_current_d_dt;
                        ELSE -- history is not discontinued
                                -- Cannot be effectively discontinued before being
                                -- effectively enrolled.
                                -- All histories prior to discontinuation are considered
                                -- enrolled and commenced at the start of the enrolment
                                RETURN v_current_e_dt;
                        END IF;
                ELSIF v_current_uas = 'ENROLLED' THEN
                        -- All histories converted to the ENROLLED definition.
                        -- Start the history at the same time as the current
                        -- student unit attempt ie. now
                        RETURN v_current_e_dt;
                ELSIF v_current_uas = 'UNCONFIRM' THEN
                        -- All histories converted to the UNCONFIRMed definition.
                        -- Start the history at the same time as the current
                        -- student unit attempt ie. now
                        RETURN TRUNC(SYSDATE);
                ELSE
                        IF v_current_e_dt IS NOT NULL THEN
                                -- attempt to find the last enrolled history entry
                                OPEN    c_last_e_suah(
                                                p_person_id,
                                                p_course_cd,
                                                p_uoo_id);
                                FETCH   c_last_e_suah   INTO    v_last_hist_start_dt;
                                IF (c_last_e_suah%NOTFOUND) THEN
                                        CLOSE   c_last_e_suah;
                                        RETURN p_hist_start_dt;
                                ELSE
                                        CLOSE   c_last_e_suah;
                                        IF p_hist_start_dt <= v_last_hist_start_dt THEN
                                                -- all histories prior to and including the
                                                -- last ENROLLED history are converted to
                                                -- the last ENROLLED definition using it's
                                                -- commencement dt as the start
                                                RETURN v_current_e_dt;
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
                gv_other_detail := 'Parm: p_person_id - '|| TO_CHAR(p_person_id)
                                   || ' p_course_cd - '|| p_course_cd
                                   || ' p_unit_cd - '|| p_unit_cd
                                   || ' p_cal_type - '|| p_cal_type
                                   || ' p_ci_sequence_num - '|| TO_CHAR(p_ci_sequence_num)
                                   || ' p_hist_start_dt - '|| IGS_GE_DATE.IGSCHAR(p_hist_start_dt)
                                   || ' p_unit_attempt_status - '|| p_unit_attempt_status
                                   || ' p_uoo_id - '||TO_CHAR(p_uoo_id);
                RAISE;
  END enrp_get_suaeh_eff_st;
END IGS_EN_GET_SUAEH_DTL;

/
