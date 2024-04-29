--------------------------------------------------------
--  DDL for Package Body IGS_ST_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GEN_001" AS
/* $Header: IGSST01B.pls 120.0 2005/06/01 13:36:13 appldev noship $ */
-- smvk      03-Jun-2003     Bug # 2858436. Modified the cursor c_caw in the procedure stapl_check_same_award.
-- svenkata     25-02-02     Removed the procedure Stap_Del_Ess  as part of CCR
--                           ENCR024 .Bug # 2239050
-- smvk      09-Jul-2004     Bug # 3676145. Modified the cursors c_count_unit_mode and  c_chk_unit_mode to select active (not closed) unit classes.

Function Stap_Get_Att_Mode(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
---------------------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
--kkillams    28-04-2003      Modified the c_count_unit_mode and c_chk_unit_mode cursors where clause
--                            w.r.t. bug number 2829262
---------------------------------------------------------------------------------------------------------
        e_attend_mode_error                                     EXCEPTION;
        gv_other_details                                        VARCHAR2(255);
        gv_exception_msg                                        VARCHAR2(100);
BEGIN
DECLARE
        cst_on                                                  CONSTANT IGS_AS_UNIT_MODE.s_unit_mode%TYPE := 'ON';
        cst_off                                                 CONSTANT IGS_AS_UNIT_MODE.s_unit_mode%TYPE := 'OFF';
        cst_composite                                           CONSTANT IGS_AS_UNIT_MODE.s_unit_mode%TYPE := 'COMPOSITE';
        v_unit_mode_count                                       NUMBER;
        v_unit_mode                                             IGS_AS_UNIT_MODE.s_unit_mode%TYPE;
        v_attend_mode                                           IGS_EN_ATD_MODE.attendance_mode%TYPE;
        CURSOR c_count_unit_mode IS
                SELECT  COUNT(UNIQUE um.s_unit_mode)
                FROM            IGS_ST_GVT_STDNTLOAD gslo,
                                IGS_EN_ST_SNAPSHOT ess,
                                IGS_AS_UNIT_CLASS ucl,
                                IGS_AS_UNIT_MODE um,
                                IGS_ST_GVT_SPSHT_CTL gsc
                WHERE           gslo.submission_yr                      = p_submission_yr               AND
                                gslo.submission_number                  = p_submission_number           AND
                                gslo.person_id                          = p_person_id                   AND
                                gslo.course_cd                          = p_course_cd                   AND
                                ess.snapshot_dt_time                    = gsc.ess_snapshot_dt_time      AND
                                ess.person_id                           = gslo.person_id                AND
                                ess.course_cd                           = gslo.course_cd                AND
                                ess.unit_cd                             = gslo.unit_cd                  AND
                                ess.sua_cal_type                        = gslo.sua_cal_type             AND
                                ess.sua_ci_sequence_number              = gslo.sua_ci_sequence_number   AND
                                ess.sua_location_cd                     = gslo.sua_location_cd          AND
                                ess.unit_class                          = gslo.unit_class               AND
                                ess.tr_org_unit_cd                      = gslo.tr_org_unit_cd           AND
                                ess.tr_ou_start_dt                      = gslo.tr_ou_start_dt           AND
                                ess.discipline_group_cd                 = gslo.discipline_group_cd      AND
                                ess.govt_discipline_group_cd            = gslo.govt_discipline_group_cd AND
                                ucl.unit_class                          = ess.unit_class                AND
				ucl.closed_ind                          = 'N'                           AND
                                um.unit_mode                            = ucl.unit_mode                 AND
                                gsc.submission_yr                       = gslo.submission_yr            AND
                                gsc.submission_number                   = gslo.submission_number;
        CURSOR c_chk_unit_mode IS
                SELECT  UNIQUE um.s_unit_mode
                FROM            IGS_ST_GVT_STDNTLOAD gslo,
                                IGS_EN_ST_SNAPSHOT ess,
                                IGS_AS_UNIT_CLASS ucl,
                                IGS_AS_UNIT_MODE um,
                                IGS_ST_GVT_SPSHT_CTL gsc
                WHERE   gslo.submission_yr                              = p_submission_yr                       AND
                                gslo.submission_number                  = p_submission_number                   AND
                                gslo.person_id                          = p_person_id                           AND
                                gslo.course_cd                          = p_course_cd                           AND
                                ess.snapshot_dt_time                    = gsc.ess_snapshot_dt_time              AND
                                ess.person_id                           = gslo.person_id                        AND
                                ess.course_cd                           = gslo.course_cd                        AND
                                ess.unit_cd                             = gslo.unit_cd                          AND
                                ess.sua_cal_type                        = gslo.sua_cal_type                     AND
                                ess.sua_ci_sequence_number              = gslo.sua_ci_sequence_number           AND
                                ess.sua_location_cd                     = gslo.sua_location_cd                  AND
                                ess.unit_class                          = gslo.unit_class                       AND
                                ess.tr_org_unit_cd                      = gslo.tr_org_unit_cd                   AND
                                ess.tr_ou_start_dt                      = gslo.tr_ou_start_dt                   AND
                                ess.discipline_group_cd                 = gslo.discipline_group_cd              AND
                                ess.govt_discipline_group_cd            = gslo.govt_discipline_group_cd         AND
                                ucl.unit_class                          = ess.unit_class                        AND
				ucl.closed_ind                          = 'N'                                   AND
                                um.unit_mode                            = ucl.unit_mode                         AND
                                gsc.submission_yr                       = gslo.submission_yr                    AND
                                gsc.submission_number                   = gslo.submission_number;
        CURSOR c_get_attend_mode (
                cp_govt_attend_mode                     IGS_EN_ATD_MODE.govt_attendance_mode%TYPE ) IS
                SELECT  attendance_mode
                FROM    IGS_EN_ATD_MODE
                WHERE   govt_attendance_mode = cp_govt_attend_mode
                ORDER
                BY              attendance_mode;
BEGIN
        -- Determine the number of different attendance modes.
        OPEN c_count_unit_mode;
        FETCH c_count_unit_mode INTO v_unit_mode_count;
        CLOSE c_count_unit_mode;
        --- Determine the attendance mode for the course.
        IF v_unit_mode_count = 1 THEN
                OPEN c_chk_unit_mode;
                FETCH c_chk_unit_mode INTO v_unit_mode;
                CLOSE c_chk_unit_mode;
                IF v_unit_mode = cst_on THEN
                        -- Attendance mode is internal.
                        OPEN c_get_attend_mode( 1 );
                        FETCH c_get_attend_mode INTO v_attend_mode;
                        IF c_get_attend_mode%FOUND THEN
                                CLOSE c_get_attend_mode;
                                RETURN  v_attend_mode;
                        ELSE
                                gv_exception_msg :=
                                        'Cannot determine the Attendance Mode value (Internal).';
                                CLOSE c_get_attend_mode;
                                RAISE e_attend_mode_error;
                        END IF;
                ELSIF v_unit_mode = cst_off THEN
                        -- Attendance mode is external.
                        OPEN c_get_attend_mode( 2 );
                        FETCH c_get_attend_mode INTO v_attend_mode;
                        IF c_get_attend_mode%FOUND THEN
                                CLOSE c_get_attend_mode;
                                RETURN  v_attend_mode;
                        ELSE
                                gv_exception_msg :=
                                        'Cannot determine the Attendance Mode value (External).';
                                CLOSE c_get_attend_mode;
                                RAISE e_attend_mode_error;
                        END IF;
                ELSIF v_unit_mode = cst_composite THEN
                        -- Attendance mode is multi-modal.
                        OPEN c_get_attend_mode( 3 );
                        FETCH c_get_attend_mode INTO v_attend_mode;
                        IF c_get_attend_mode%FOUND THEN
                                CLOSE c_get_attend_mode;
                                RETURN  v_attend_mode;
                        ELSE
                                gv_exception_msg :=
                                        'Cannot determine the Attendance Mode value (Multi-modal).';
                                CLOSE c_get_attend_mode;
                                RAISE e_attend_mode_error;
                        END IF;
                END IF;
        ELSIF v_unit_mode_count > 1 THEN
                -- Attendance mode is multi-modal.
                OPEN c_get_attend_mode( 3 );
                FETCH c_get_attend_mode INTO v_attend_mode;
                IF c_get_attend_mode%FOUND THEN
                        CLOSE c_get_attend_mode;
                        RETURN  v_attend_mode;
                ELSE
                        gv_exception_msg :=
                                'Cannot determine the Attendance Mode value (Multi-modal).';
                        CLOSE c_get_attend_mode;
                        RAISE e_attend_mode_error;
                END IF;
        ELSE
                -- no records selected
                gv_exception_msg :=
                        'Cannot determine the Attendance Mode value for the course.';
                RAISE e_attend_mode_error;
        END IF;
RETURN NULL;
END;
EXCEPTION
        WHEN e_attend_mode_error THEN
                Null;
        WHEN OTHERS THEN
                Null;
     END stap_get_att_mode;

Function Stap_Get_Comm_Stdnt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_commencement_dt IN OUT NOCOPY DATE ,
  p_collection_yr IN NUMBER )
RETURN VARCHAR2 AS
        gv_other_detail                         VARCHAR2(255);
BEGIN
DECLARE
        E_NO_SCA_RECORD_FOUND                   EXCEPTION;
        E_COMM_DT_NULL                          EXCEPTION;
        v_gse_record_found                      BOOLEAN DEFAULT FALSE;
        v_prev_sca_rec_found                    BOOLEAN DEFAULT FALSE;
        v_exclusion_level                       VARCHAR2(15);
        v_commencement_dt                       IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_curr_generic_course_ind               IGS_PS_VER.generic_course_ind%TYPE;
        v_curr_govt_course_type                 IGS_PS_TYPE.govt_course_type%TYPE;
        v_curr_responsible_org_unit_cd          IGS_PS_VER.responsible_org_unit_cd%TYPE;
        v_curr_course_level                     NUMBER;
        v_prev_generic_course_ind               IGS_PS_VER.generic_course_ind%TYPE;
        v_prev_govt_course_type                 IGS_PS_TYPE.govt_course_type%TYPE;
        v_prev_responsible_org_unit_cd          IGS_PS_VER.responsible_org_unit_cd%TYPE;
        v_prev_course_level                     NUMBER;
        v_prev_course_cd                        IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
        v_prev_version_number                   IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_prev_commencement_dt                  IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
        v_march_string                          VARCHAR2(10);
        v_march_dt                              DATE;
        v_april_string                          VARCHAR2(10);
        v_april_dt                              DATE;
        CURSOR  c_sca IS
                        SELECT  sca.commencement_dt
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id   = p_person_id AND
                        sca.course_cd   = p_course_cd;
        CURSOR  c_crv_cty(
                        cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                        cp_version_number IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
                SELECT  crv.generic_course_ind,
                        cty.govt_course_type,
                        crv.responsible_org_unit_cd,
                        IGS_ST_GEN_002.stap_get_course_lvl(
                                        cp_course_cd,
                                        cp_version_number,
                                        cty.govt_course_type)
                FROM    IGS_PS_VER crv,
                        IGS_PS_TYPE cty
                WHERE   crv.course_cd           = cp_course_cd AND
                        crv.version_number      = cp_version_number AND
                        cty.course_type         = crv.course_type;
        CURSOR  c_prev_sca(
                        cp_april_dt     DATE) IS
                SELECT  sca.course_cd,
                        sca.version_number,
                        sca.commencement_dt
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   sca.person_id = p_person_id AND
                        sca.course_cd <> p_course_cd AND
                        sca.commencement_dt < cp_april_dt
                ORDER BY sca.commencement_dt DESC;
        FUNCTION stapl_retrieve_curr_prior_gse(
                p_person_id             IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                p_course_cd             IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_collection_yr         NUMBER)
        RETURN BOOLEAN IS
        BEGIN
        DECLARE
                CURSOR  c_gse IS
                        SELECT   'x'
                        FROM    IGS_ST_GOVT_STDNT_EN gse
                        WHERE   gse.person_id           = p_person_id AND
                                gse.course_cd           = p_course_cd AND
                                gse.submission_yr       = p_collection_yr - 1;
                v_cge_exists            VARCHAR2(1);
        BEGIN
                -- This module checks if there is matching record for the current
                -- student_course_attempt in the prior years' Student Enrolment File.
                OPEN c_gse;
                FETCH c_gse INTO v_cge_exists;
                IF c_gse%FOUND THEN
                        CLOSE c_gse;
                        RETURN TRUE;
                END IF;
                CLOSE c_gse;
                RETURN FALSE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_gse%ISOPEN THEN
                                CLOSE c_gse;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_retrieve_curr_prior_gse');
                IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END stapl_retrieve_curr_prior_gse;

        FUNCTION stapl_check_curr_prior_gse(
                                        p_person_id             IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                                        p_course_cd             IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                                        p_collection_yr         NUMBER)
        RETURN BOOLEAN
        AS
        BEGIN
        DECLARE
                v_person_id             IGS_EN_STDNT_PS_ATT.person_id%TYPE;
                v_continue              BOOLEAN;
                CURSOR  c_api_pit(
                                cp_person_id IGS_PE_ALT_PERS_ID.pe_person_id%TYPE) IS
                        SELECT  api.api_person_id
                        FROM    IGS_PE_ALT_PERS_ID api,
                                IGS_PE_PERSON_ID_TYP pit
                        WHERE   api.pe_person_id        = cp_person_id AND
                                pit.person_id_type      = api.person_id_type AND
                                pit.s_person_id_type    = 'OBSOLETE';
        BEGIN
                -- This module checks if there is matching record for the current
                -- student_course_attempt in the prior years' Student Enrolment File.
                IF NOT stapl_retrieve_curr_prior_gse(
                                        p_person_id,
                                        p_course_cd,
                                        p_collection_yr) THEN
                        v_person_id := p_person_id;
                        FOR v_api_pit_rec IN c_api_pit(
                                                        v_person_id) LOOP
                                BEGIN
                                        v_continue := TRUE;
                                        v_person_id :=  TO_NUMBER(v_api_pit_rec.api_person_id);
                                EXCEPTION
                                        WHEN VALUE_ERROR THEN
                                                v_continue := FALSE;
                                END;
                                IF v_continue  AND
                                                stapl_check_curr_prior_gse(
                                                                v_person_id,
                                                                p_course_cd,
                                                                p_collection_yr) THEN
                                        RETURN TRUE;
                                END IF;
                        END LOOP;
                        RETURN FALSE;
                ELSE
                        RETURN TRUE;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_api_pit%ISOPEN THEN
                                CLOSE c_api_pit;
                        END IF;
                App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_curr_prior_gse');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END stapl_check_curr_prior_gse;

        FUNCTION stapl_retrieve_prev_prior_gse(
                                        p_person_id             IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                                        p_course_cd             IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                                        p_collection_yr         NUMBER)
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                CURSOR  c_gse IS
                        SELECT 'x'
                        FROM    IGS_ST_GOVT_STDNT_EN gse
                        WHERE   gse.person_id           = p_person_id AND
                                gse.course_cd           = p_course_cd AND
                                gse.submission_yr       < p_collection_yr;
                v_cge_exists            VARCHAR2(1);
        BEGIN
                -- This module checks if there is matching record for the previous
                -- student_course_attempt in the prior years' Student Enrolment File.
                OPEN c_gse;
                FETCH c_gse INTO v_cge_exists;
                IF c_gse%FOUND THEN
                        CLOSE c_gse;
                        RETURN TRUE;
                END IF;
                CLOSE c_gse;
                RETURN FALSE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_gse%ISOPEN THEN
                                CLOSE c_gse;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_retrieve_prev_prior_gse');
                IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END stapl_retrieve_prev_prior_gse;

        FUNCTION stapl_check_prev_prior_gse(
                                        p_person_id             IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                                        p_course_cd             IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                                        p_collection_yr         NUMBER)
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                v_person_id             IGS_EN_STDNT_PS_ATT.person_id%TYPE;
                v_continue              BOOLEAN;
                CURSOR  c_api_pit(
                                cp_person_id IGS_PE_ALT_PERS_ID.pe_person_id%TYPE) IS
                        SELECT  api.api_person_id
                        FROM    IGS_PE_ALT_PERS_ID api,
                                IGS_PE_PERSON_ID_TYP pit
                        WHERE   api.pe_person_id        = cp_person_id AND
                                pit.person_id_type      = api.person_id_type AND
                                pit.s_person_id_type    = 'OBSOLETE';
        BEGIN
                -- This module checks if there is matching record for the previous
                -- IGS_EN_STDNT_PS_ATT in the prior years' Student Enrolment File.
                IF NOT stapl_retrieve_prev_prior_gse(
                                        p_person_id,
                                        p_course_cd,
                                        p_collection_yr) THEN
                        v_person_id := p_person_id;
                        FOR v_api_pit_rec IN c_api_pit(
                                                        v_person_id) LOOP
                                BEGIN
                                        v_continue := TRUE;
                                        v_person_id :=  TO_NUMBER(v_api_pit_rec.api_person_id);
                                EXCEPTION
                                        WHEN VALUE_ERROR THEN
                                                v_continue := FALSE;
                                END;
                                IF v_continue AND
                                                stapl_check_curr_prior_gse(
                                                                        v_person_id,
                                                                        p_course_cd,
                                                                        p_collection_yr)  THEN
                                        RETURN TRUE;
                                END IF;
                        END LOOP;
                        RETURN FALSE;
                ELSE
                        RETURN TRUE;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_api_pit%ISOPEN THEN
                                CLOSE c_api_pit;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_prev_prior_gse');
                IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END stapl_check_prev_prior_gse;

        FUNCTION stapl_check_prev_crs_enrolled(
                p_person_id             IGS_EN_SU_ATTEMPT.person_id%TYPE,
                p_course_cd             IGS_EN_SU_ATTEMPT.course_cd%TYPE)
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                CURSOR  c_sua IS
                        SELECT  'x'
                        FROM    IGS_EN_SU_ATTEMPT sua
                        WHERE   sua.person_id           = p_person_id AND
                                sua.course_cd           = p_course_cd AND
                                sua.unit_attempt_status IN (
                                                        'ENROLLED',
                                                        'COMPLETED');
                v_sua_exists    VARCHAR2(1);
        BEGIN
                -- This module checks if previous course attempt was enrolled.
                OPEN c_sua;
                FETCH c_sua INTO v_sua_exists;
                IF c_sua%FOUND THEN
                        CLOSE c_sua;
                        RETURN TRUE;
                END IF;
                CLOSE c_sua;
                RETURN FALSE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_sua%ISOPEN THEN
                                CLOSE c_sua;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_prev_crs_enrolled');
                IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
        END stapl_check_prev_crs_enrolled;
        FUNCTION stapl_check_same_award(
                p_course_cd             IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_version_nunber        IGS_EN_STDNT_PS_ATT.version_number%TYPE,
                p_prev_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_prev_version_number   IGS_EN_STDNT_PS_ATT.version_number%TYPE)
        RETURN BOOLEAN AS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              :
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_caw to select open program awards only.
   ***************************************************************/
        BEGIN
        DECLARE
                CURSOR c_caw IS
                        SELECT  'x'
                        FROM    IGS_PS_AWARD caw
                        WHERE   caw.course_cd           = p_course_cd AND
                                caw.version_number      = p_version_number AND
                                caw.closed_ind          = 'N' AND
                                EXISTS (SELECT  'x'
                                        FROM    IGS_PS_AWARD caw1
                                        WHERE   caw1.course_cd          = p_prev_course_cd AND
                                                caw1.version_number     = p_prev_version_number AND
                                                caw1.award_cd           <> caw.award_cd AND
                                                caw1.closed_ind         = 'N');
                v_caw_exists    VARCHAR2(1);
        BEGIN
                -- This module checks if the award(s) for the current course attempt and the
                -- previous course attempt match.
                OPEN c_caw;
                FETCH c_caw INTO v_caw_exists;
                IF c_caw%FOUND THEN
                        CLOSE c_caw;
                        RETURN FALSE;
                END IF;
                CLOSE c_caw;
                RETURN TRUE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_caw%ISOPEN THEN
                                CLOSE c_caw;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_same_award');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END stapl_check_same_award;
        FUNCTION stapl_check_same_equiv(
                                p_course_cd             IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                                p_version_nunber        IGS_EN_STDNT_PS_ATT.version_number%TYPE,
                                p_prev_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                                p_prev_version_number   IGS_EN_STDNT_PS_ATT.version_number%TYPE)
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                v_course_equivalance_cd         IGS_PS_GRP_MBR.course_group_cd%TYPE;
                v_course_group_cd               IGS_PS_GRP_MBR.course_group_cd%TYPE;
                CURSOR c_cgm IS
                        SELECT  'X'
                        FROM    IGS_PS_GRP_MBR  cgm1
                        WHERE   cgm1.course_cd          = p_prev_course_cd AND
                                cgm1.version_number     = p_prev_version_number AND
                                EXISTS (
                                        SELECT 'X'
                                        FROM    IGS_PS_GRP_MBR  cgm,
                                                IGS_PS_GRP              cgr,
                                                IGS_PS_GRP_TYPE         cgt
                                        WHERE   cgm.course_cd           = p_course_cd AND
                                                cgm.version_number      = p_version_number AND
                                                cgr.course_group_cd     = cgm.course_group_cd AND
                                                cgt.course_group_type   = cgr.course_group_type AND
                                                cgt.s_course_group_type = 'EQUIV' AND
                                                cgm.course_group_cd     = cgm1.course_group_cd);
                v_cgm_exists    VARCHAR2(1);
        BEGIN
                -- This module checks if the current course attempt and previous course
                -- attempt are members of the same course equivalence group.
                -- Retrieve all course equivalence groups the current course belongs to.
                OPEN c_cgm;
                FETCH c_cgm INTO v_cgm_exists;
                IF c_cgm%FOUND THEN
                        CLOSE c_cgm;
                        RETURN TRUE;
                END IF;
                CLOSE c_cgm;
                RETURN FALSE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_cgm%ISOPEN THEN
                                CLOSE c_cgm;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_same_equiv');
                IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
        END stapl_check_same_equiv;
        FUNCTION stapl_check_combined(
                p_course_cd             IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_version_nunber        IGS_EN_STDNT_PS_ATT.version_number%TYPE)
        RETURN BOOLEAN AS
        BEGIN
        DECLARE
                v_cgm_cgr_cgt_exists    VARCHAR2(1);
                CURSOR c_cgm_cgr_cgt IS
                        SELECT  'X'
                        FROM    IGS_PS_GRP_MBR cgm,
                                IGS_PS_GRP cgr,
                                IGS_PS_GRP_TYPE cgt
                        WHERE   cgm.course_cd           = p_course_cd AND
                                cgm.version_number      = p_version_number AND
                                cgr.course_group_cd     = cgm.course_group_cd AND
                                cgt.course_group_type   = cgr.course_group_type AND
                                cgt.s_course_group_type = 'COMBINED';
        BEGIN
                -- This module checks if the course attempt is member of a combined
                -- course group.
                OPEN c_cgm_cgr_cgt;
                FETCH c_cgm_cgr_cgt INTO v_cgm_cgr_cgt_exists;
                IF c_cgm_cgr_cgt%FOUND THEN
                        CLOSE c_cgm_cgr_cgt;
                        RETURN TRUE;
                END IF;
                CLOSE c_cgm_cgr_cgt;
                RETURN FALSE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_cgm_cgr_cgt%ISOPEN THEN
                                CLOSE c_cgm_cgr_cgt;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_combined');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
      END stapl_check_combined;

FUNCTION stapl_check_comp_req(
                        p_person_id             IGS_EN_SU_ATTEMPT.person_id%TYPE,
                        p_course_cd             IGS_EN_SU_ATTEMPT.course_cd%TYPE)
RETURN BOOLEAN AS
-------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
--kkillams    28-04-2003      Modified the c_sua cursor w.r.t. bug number 2829262
-------------------------------------------------------------------------------------------
BEGIN
DECLARE
        v_grading_schema_cd     VARCHAR2(10);
        v_grade                 VARCHAR2(10);
        v_gs_version_number     NUMBER;
        CURSOR  c_sua IS
                SELECT  sua.course_cd,
                        sua.unit_cd,
                        sua.cal_type,
                        sua.ci_sequence_number,
                        sua.unit_attempt_status,
                        sua.uoo_id
                FROM    IGS_EN_SU_ATTEMPT sua
                WHERE   sua.person_id           = p_person_id AND
                        sua.course_cd           = p_course_cd AND
                        sua.unit_attempt_status = 'COMPLETED';
BEGIN
        -- This module checks if the student has completed part of the requirements
        -- of the previous course.
        FOR v_sua_rec IN c_sua LOOP
                IF IGS_AS_GEN_003.assp_get_sua_grade(
                                p_person_id,
                                v_sua_rec.course_cd,
                                v_sua_rec.unit_cd,
                                v_sua_rec.cal_type,
                                v_sua_rec.ci_sequence_number,
                                v_sua_rec.unit_attempt_status,
                                'Y',                    -- (Finalised indicator)
                                v_grading_schema_cd,    -- (Output parameter; not used)
                                v_gs_version_number,    -- (Output parameter; not used)
                                v_grade,
                                v_sua_rec.uoo_id)               -- (Output parameter; not used)
                                = 'PASS' THEN
                        RETURN TRUE;
                END IF;
        END LOOP;
        RETURN FALSE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_sua%ISOPEN THEN
                        CLOSE c_sua;
                END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_comp_req');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END stapl_check_comp_req;

        FUNCTION stapl_check_course_transfer(
                                p_person_id             IGS_EN_SU_ATTEMPT.person_id%TYPE,
                                p_course_cd             IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                                p_version_number        IGS_EN_SU_ATTEMPT.version_number%TYPE,
                                p_transfer_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                                p_trnsfr_version_number IGS_EN_SU_ATTEMPT.version_number%TYPE)
        RETURN BOOLEAN
        AS
        BEGIN
        DECLARE
                v_exists        VARCHAR2(1);
                v_cgm_exists    VARCHAR2(1);
                cst_govt_ret    CONSTANT VARCHAR2(10) := 'GOVT-RET';
                CURSOR c_sct IS
                        SELECT  'X'
                        FROM    IGS_PS_STDNT_TRN        sct
                        WHERE   sct.person_id           = p_person_id AND
                                sct.course_cd           = p_course_cd AND
                                sct.transfer_course_cd  = p_transfer_course_cd;
                CURSOR c_cgm IS
                        SELECT  'x'
                        FROM    IGS_PS_GRP_MBR  cgm1
                        WHERE   cgm1.course_cd          = p_course_cd AND
                                cgm1.version_number     = p_version_number AND
                                EXISTS (
                                        SELECT  'x'
                                        FROM    IGS_PS_GRP_MBR  cgm2,
                                                IGS_PS_GRP              cgp,
                                                IGS_PS_GRP_TYPE cgt
                                        WHERE   cgm2.course_cd          = p_transfer_course_cd AND
                                                cgm2.version_number     = p_trnsfr_version_number AND
                                                cgm2.course_group_cd    = cgm1.course_group_cd AND
                                                cgm2.course_group_cd    = cgp.course_group_cd AND
                                                cgp.course_group_type   = cgt.course_group_type AND
                                                cgt.s_course_group_type = cst_govt_ret);
        BEGIN
                -- This function checks if the student has transferred from a previous course
                -- attempt to the current course attempt.
                /**************************************
                This check has been removed as it is thought
                the IGS_PS_STDNT_TRN is not needed for the
                student to still be considered continuing.
                OPEN c_sct;
                FETCH c_sct INTO v_exists;
                IF c_sct%NOTFOUND THEN
                        CLOSE c_sct;
                        RETURN FALSE;
                END IF;
                CLOSE c_sct;
                ***************************************/
                OPEN c_cgm;
                FETCH c_cgm INTO v_cgm_exists;
                IF c_cgm%NOTFOUND THEN
                        CLOSE c_cgm;
                        RETURN FALSE;
                END IF;
                CLOSE c_cgm;
                RETURN TRUE;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_sct%ISOPEN THEN
                                CLOSE c_sct;
                        END IF;
                        IF c_cgm%ISOPEN THEN
                                CLOSE c_cgm;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_check_course_transfer');
                IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
        END stapl_check_course_transfer;
        FUNCTION stapl_get_comm_dt(
                p_prev_course_cd                IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                p_prev_version_number           IGS_EN_SU_ATTEMPT.version_number%TYPE,
                p_prev_commencement_dt          IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE)
        RETURN DATE
        AS
        BEGIN
        DECLARE
                v_comm_dt       IGS_ST_GOVT_STDNT_EN.commencement_dt%TYPE;
                CURSOR c_gse IS
                        SELECT  gse.commencement_dt
                        FROM    IGS_ST_GOVT_STDNT_EN    gse
                        WHERE   gse.submission_yr       < p_collection_yr AND
                                gse.submission_number   = 1 AND -- enrolment file is only ever submission 1
                                gse.person_id           = p_person_id AND
                                gse.course_cd           = p_prev_course_cd AND
                                gse.version_number      = p_prev_version_number
                        ORDER BY gse.submission_yr DESC;
        BEGIN
                OPEN c_gse;
                FETCH c_gse INTO v_comm_dt;
                IF c_gse%NOTFOUND THEN
                        v_comm_dt := p_prev_commencement_dt;
                END IF;
                CLOSE c_gse;
                RETURN v_comm_dt;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_gse%ISOPEN THEN
                                CLOSE c_gse;
                        END IF;
                        App_Exception.Raise_Exception;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stapl_get_comm_dt');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END stapl_get_comm_dt;
BEGIN   -- main
        -- Routine to determine the commencing student indicator for a student's
        -- course attempt. The logic has been determined by the DEETYA Element
        -- Definition of a commencing student (DEETYA element 922) and the Glossary
        -- Definition. The logic will need to be enhanced when the course Transfer
        -- process is developed in Enrolments Phase 1 / Priority 2.
        -- Determine the student course attempt commencement date.
        IF (p_commencement_dt IS NULL) THEN
                OPEN    c_sca;
                FETCH   c_sca INTO v_commencement_dt;
                IF c_sca%NOTFOUND THEN
                        CLOSE   c_sca;
                        RAISE E_NO_SCA_RECORD_FOUND;
                END IF;
                CLOSE   c_sca;
                IF (v_commencement_dt IS NULL) THEN
                        RAISE E_COMM_DT_NULL;
                END IF;
        ELSE
                v_commencement_dt := p_commencement_dt;
        END IF;
        -- check if there is a matching record for the current sutdent course attempt
        -- in the prior years Student Enrolment File
        IF stapl_check_curr_prior_gse(
                                p_person_id,
                                p_course_cd,
                                p_collection_yr) THEN
                v_gse_record_found := TRUE;
        ELSE
                v_gse_record_found := FALSE;
        END IF;
        v_march_string := TO_CHAR(p_collection_yr - 1)||'03/31';
        v_march_dt :=   IGS_GE_DATE.igsdate(v_march_string);
        v_april_string := TO_CHAR(p_collection_yr - 1)||'04/01';
        v_april_dt :=  IGS_GE_DATE.igsdate(v_april_string);
        -- Check for a commencing student
        IF(v_commencement_dt > v_march_dt AND
                        v_gse_record_found = FALSE) THEN
                -- Retrieve course version details for the current course attempt.
                OPEN    c_crv_cty(
                                p_course_cd,
                                p_version_number);
                FETCH   c_crv_cty INTO  v_curr_generic_course_ind,
                                        v_curr_govt_course_type,
                                        v_curr_responsible_org_unit_cd,
                                        v_curr_course_level;
                CLOSE   c_crv_cty;
                -- Retrieve previous course attemptsfor the student.
                FOR v_prev_sca_rec IN c_prev_sca(
                                                v_april_dt) LOOP
                        v_prev_sca_rec_found := TRUE;
                        v_prev_course_cd := v_prev_sca_rec.course_cd;
                        v_prev_version_number := v_prev_sca_rec.version_number;
                        v_prev_commencement_dt := v_prev_sca_rec.commencement_dt;
                        IF((IGS_ST_GEN_003.stap_get_rptbl_govt(
                                        p_person_id,
                                        v_prev_course_cd,
                                        v_prev_version_number,
                                        NULL, -- Input Parameter: Unit Code
                                        NULL, -- Input Parameter: Unit Version Number
                                        NULL, -- Input Parameter: Teaching Calendar Type
                                        NULL, -- Input Parameter: Teaching Calendar Sequence Number
                                        NULL, -- Input Parameter: Teaching Responsibility - OU code
                                        NULL, -- Input Parameter: Teaching Responsibility - OU start date
                                        NULL, -- Input Parameter: EFTSU
                                        NULL, -- Input Parameter: Effective Date
                                        v_exclusion_level,
                                        NULL) = 'N') AND
                                                (v_exclusion_level IN ('COURSE','PERSON-COURSE'))) THEN
                                NULL; -- Don't do anything
                        ELSE
                                -- Retrieve course version details for the previous course attempt.
                                OPEN    c_crv_cty(
                                                v_prev_course_cd,
                                                v_prev_version_number);
                                FETCH   c_crv_cty INTO  v_prev_generic_course_ind,
                                                                v_prev_govt_course_type,
                                                                v_prev_responsible_org_unit_cd,
                                                                v_prev_course_level;
                                CLOSE   c_crv_cty;
                                -- Process Exceptions.
                                -- Check for a non-commencing student.
                                -- students who are starting a specialised program of studies after
                                -- completing, at the institution or an antecedent institution, a common
                                -- initial year or years of a general program.
                                IF(v_curr_generic_course_ind = 'N' AND
                                                v_prev_generic_course_ind = 'Y') THEN
                                        -- Check if the previous student course attempt has been reported
                                        -- before
                                        IF stapl_check_prev_prior_gse(
                                                                p_person_id,
                                                                v_prev_course_cd,
                                                                p_collection_yr) THEN
                                                v_gse_record_found := TRUE;
                                        ELSE
                                                v_gse_record_found := FALSE;
                                        END IF;
                                        IF (v_prev_commencement_dt < v_april_dt OR
                                                                v_gse_record_found = TRUE) THEN
                                                -- Check if the student has transferred from the previous course
                                                -- attempt to the current course attempt.
                                                IF stapl_check_course_transfer(
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        p_version_number,
                                                                        v_prev_course_cd,
                                                                        v_prev_version_number) THEN
                                                        -- derive commencement date from previous course
                                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                                        RETURN 'N';
                                                END IF;
                                        END IF;
                                END IF;
                                -- students who, having completed an initial year of study at the
                                -- institution or an antecedent institution then exercise a standard
                                -- option of continuing their studies but at a lower level (i.e. their
                                -- studies would then lead to an award at a level lower than that which
                                -- pertains to the program of studies undertaken in the first year).
                                -- Check if the previous course attempt was enrolled.
                                IF stapl_check_prev_crs_enrolled(
                                                        p_person_id,
                                                        v_prev_course_cd) THEN
                                        IF v_curr_course_level < v_prev_course_level THEN
                                                -- Check if the student has transferred from the previous course
                                                -- attempt to the current course attempt.
                                                IF stapl_check_course_transfer(
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        p_version_number,
                                                                        v_prev_course_cd,
                                                                        v_prev_version_number) THEN
                                                        -- Derive commencement date from previous course
                                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                                        RETURN 'N';
                                                END IF;
                                        END IF;
                                END IF;
                                -- students who are admitted to or transfer to a bachelor's honours course
                                -- having previously been enrolled, at the institution or an antecedent
                                -- institution, in the related bachelor's pass course.
                                IF (v_curr_govt_course_type = 9 AND
                                                v_prev_govt_course_type = 10) THEN
                                        -- Check if the previous course attempt was enrolled.
                                        IF stapl_check_prev_crs_enrolled(
                                                                        p_person_id,
                                                                        v_prev_course_cd) THEN
                                                -- Check if the previous course is an articulate course for the
                                                -- current course.
                                                IF IGS_RU_VAL_CRS_RULE.rulp_val_crs_artcltn(
                                                                                        p_course_cd,
                                                                                        p_version_number,
                                                                                        v_prev_course_cd,
                                                                                        v_prev_version_number) THEN
                                                        -- Derive commencement date from previous course
                                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                                        RETURN 'N';
                                                END IF;
                                        END IF;
                                END IF;
                                -- students who are admitted to or transfer to a master's honours course
                                -- having previously been enrolled, at the institution or an antecedent
                                -- institution , in the related master's pass course.
                                IF(v_curr_govt_course_type = 4 AND
                                                v_prev_govt_course_type = 4) THEN
                                        -- Check if the previous course attempt was enrolled.
                                        IF stapl_check_prev_crs_enrolled(
                                                        p_person_id,
                                                        v_prev_course_cd) THEN
                                                -- Check if the previous course is an articulate course for the
                                                -- current course.
                                                IF IGS_RU_VAL_CRS_RULE.rulp_val_crs_artcltn(
                                                                        p_course_cd,
                                                                        p_version_number,
                                                                        v_prev_course_cd,
                                                                        v_prev_version_number) THEN
                                                        -- Derive commencement date from previous course
                                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                                        RETURN 'N';
                                                END IF;
                                        END IF;
                                END IF;
                                -- students who transfer within the institution or an antecedent institution
                                --  from a course in one academic organisational unit to a course in another
                                -- academic organisational unit, where the courses lead to the same award.
                                IF (v_curr_responsible_org_unit_cd <> v_prev_responsible_org_unit_cd) THEN
                                        IF stapl_check_same_award(
                                                                p_course_cd,
                                                                p_version_number,
                                                                v_prev_course_cd,
                                                                v_prev_version_number) THEN
                                                -- Check if the student has transferred from the previous course
                                                -- attempt to the current course attempt.
                                                IF stapl_check_course_transfer(
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        p_version_number,
                                                                        v_prev_course_cd,
                                                                        v_prev_version_number) THEN
                                                        -- Derive commencement date from previous course
                                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                                        RETURN 'N';
                                                END IF;
                                        END IF;
                                END IF;
                                -- students who are enrolled in a course at the institution or an antecedent
                                --  institution which is upgraded in level or renamed.
                                -- Check if the current course attempt and previous course attempt are
                                -- members of the same course equivalence group.
                                IF stapl_check_same_equiv(
                                                        p_course_cd,
                                                        p_version_number,
                                                        v_prev_course_cd,
                                                        v_prev_version_number) THEN
                                        -- Derive commencement date from previous course
                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                        RETURN 'N';
                                END IF;
                                -- students who have completed part of the requirements of a combined course
                                --  at the
                                -- institution and then change their enrolment to one of the components of
                                -- that
                                -- combined course.
                                -- Check if the previous course attempt is a member of a combined course
                                -- group
                                -- and the current course attempt is NOT a member of a combined course
                                -- group.
                                IF stapl_check_combined(
                                                v_prev_course_cd,
                                                v_prev_version_number) AND NOT
                                        stapl_check_combined(
                                                        p_course_cd,
                                                        p_version_number) THEN
                                        -- Check if the student has completed part of the requirements of the
                                        -- previous course.
                                        IF stapl_check_comp_req(
                                                                p_person_id,
                                                                v_prev_course_cd) THEN
                                                -- Check if the student has transferred from the previous course
                                                -- attempt to the current course attempt.
                                                IF stapl_check_course_transfer(
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        p_version_number,
                                                                        v_prev_course_cd,
                                                                        v_prev_version_number) THEN
                                                        -- Derive commencement date from previous course
                                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                                        RETURN 'N';
                                                END IF;
                                        END IF;
                                END IF;
                                -- students who have completed part of the requirements of a unitary course
                                -- at the
                                -- institution and then change their enrolment to a related combined course
                                -- which leads
                                -- to an award or awards that subsume the award applicable to the unitary
                                -- course.
                                -- Check if the previous course attempt is NOT a member of a combined course
                                --  group
                                -- and the current course attempt is a member of a combined course group.
                                IF NOT stapl_check_combined(
                                                v_prev_course_cd,
                                                v_prev_version_number) AND
                                        stapl_check_combined(
                                                        p_course_cd,
                                                        p_version_number) THEN
                                        -- Check if the student has completed part of the requirements of the
                                        -- previous course.
                                        IF stapl_check_comp_req(
                                                                p_person_id,
                                                                v_prev_course_cd) THEN
                                                -- Check if the student has transferred from the previous course
                                                -- attempt to the current course attempt.
                                                IF stapl_check_course_transfer(
                                                                        p_person_id,
                                                                        p_course_cd,
                                                                        p_version_number,
                                                                        v_prev_course_cd,
                                                                        v_prev_version_number) THEN
                                                        -- Derive commencement date from previous course
                                                        p_commencement_dt := stapl_get_comm_dt(
                                                                                v_prev_course_cd,
                                                                                v_prev_version_number,
                                                                                v_prev_commencement_dt);
                                                        RETURN 'N';
                                                END IF;
                                        END IF;
                                END IF;
                        END IF;
                END LOOP;
                -- no previous course attempts exist for the student or
                -- no IGS_GE_EXCEPTIONS - student is commencing
                p_commencement_dt := v_commencement_dt;
                RETURN 'Y';
        END IF;
        -- Check for a non-commencing student.
        IF(v_commencement_dt < v_april_dt OR
                        v_gse_record_found = TRUE) THEN
                p_commencement_dt := v_commencement_dt;
                RETURN 'N';
        END IF;
EXCEPTION
        WHEN E_NO_SCA_RECORD_FOUND THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_ST_COMM_DT_NOT_DETER');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
        WHEN E_COMM_DT_NULL THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.Stap_Get_Comm_Stdnt');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
        WHEN OTHERS THEN
                        IF c_sca%ISOPEN THEN
                                CLOSE c_sca;
                        END IF;
                        IF c_crv_cty%ISOPEN THEN
                                CLOSE c_crv_cty;
                        END IF;
                        IF c_prev_sca%ISOPEN THEN
                                CLOSE c_prev_sca;
                        END IF;
                APP_EXCEPTION.RAISE_EXCEPTION;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_001.stap_get_comm_stdnt');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
    END stap_get_comm_stdnt;

END IGS_ST_GEN_001;

/
