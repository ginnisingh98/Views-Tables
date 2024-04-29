--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_001" AS
/* $Header: IGSEN01B.pls 120.1 2005/08/17 22:56:05 appldev ship $ */
/*
    who                     when                       what
    rvivekan                9-sep-2003                 PSS integration build#3052433. modified behavior of
                                                       repeatable indicator in the igs_ps_unit_ver table
    jbegum                  25-Jun-2003                BUG#2930935
                                                       Modified local functions ENRP_CLC_SCA_PASS_CP
    npalanis                8-may-2002                 Bug - 2362467
                                                       The application id passed to function Check_HRMS_Installed
                                                       is changed to 800 because the application id for HRMS is 800
*/

     l_rowid VARCHAR2(25);
Function Check_HRMS_Installed
RETURN  VARCHAR2 IS
        L_VAR BOOLEAN;
        L_INDUSTRY VARCHAR2(10);
        L_STATUS VARCHAR2(10);
BEGIN
        L_VAR := FND_INSTALLATION.GET(800,800,L_STATUS,L_INDUSTRY);
        IF L_STATUS IS NOT NULL THEN
                RETURN 'Y';
        ELSE
                RETURN 'N';
        END IF;

END;


Procedure Enrp_Clc_Crrnt_Acad(
  p_cal_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_sequence_number OUT NOCOPY NUMBER )
AS
BEGIN
DECLARE
        cst_planned                     CONSTANT VARCHAR2(8) := 'PLANNED';
        v_effect_enr_strt_dt_alias      IGS_EN_CAL_CONF.effect_enr_strt_dt_alias%TYPE;
        v_record_found                  BOOLEAN;
        CURSOR  c_s_enr_cal_conf IS
                SELECT  effect_enr_strt_dt_alias
                FROM    IGS_EN_CAL_CONF
                WHERE   s_control_num = 1;
        CURSOR  c_dai_v(cp_cal_type IGS_CA_DA_INST_V.cal_type%TYPE,
                        cp_dt_alias IGS_CA_DA_INST_V.dt_alias%TYPE,
                        cp_effective_dt  DATE) IS
                SELECT  IGS_CA_DA_INST_V.alias_val,
                        IGS_CA_DA_INST_V.ci_sequence_number
                FROM    IGS_CA_DA_INST_V,
                        IGS_CA_INST,
                        IGS_CA_STAT
                WHERE   IGS_CA_DA_INST_V.cal_type = cp_cal_type AND
                        IGS_CA_DA_INST_V.dt_alias = cp_dt_alias AND
                        IGS_CA_DA_INST_V.alias_val <= cp_effective_dt AND
                        IGS_CA_DA_INST_V.cal_type = IGS_CA_INST.cal_type AND
                        IGS_CA_DA_INST_V.ci_sequence_number = IGS_CA_INST.sequence_number AND
                        IGS_CA_STAT.cal_status = IGS_CA_INST.cal_status AND
                        IGS_CA_STAT.s_cal_status <> cst_planned
                ORDER BY alias_val DESC;
BEGIN
        -- this module alculates the current instance of academic period calendar
        -- for the nominated academic calendar type. This is determined by searching
        -- for the ?effective enrolment start date alias? within the academic
        -- calendar instance. The dt_alias to search for is located in the
        -- IGS_EN_CAL_CONF.effect_enr_strt_dt_alias column. If no match is determinable
        -- then the returned sequence number will be set to 0.
        v_record_found := FALSE;
        p_sequence_number := 0;
        OPEN    c_s_enr_cal_conf;
        FETCH   c_s_enr_cal_conf INTO v_effect_enr_strt_dt_alias;
        IF (c_s_enr_cal_conf%NOTFOUND) THEN
                CLOSE   c_s_enr_cal_conf;
                RETURN;
        END IF;
        CLOSE   c_s_enr_cal_conf;
        FOR c_dai_v_rec IN c_dai_v(
                        p_cal_type,
                        v_effect_enr_strt_dt_alias,
                        p_effective_dt)
        LOOP
                v_record_found := TRUE;
                p_sequence_number := c_dai_v_rec.ci_sequence_number;
                EXIT;
        END LOOP;
        IF(v_record_found = FALSE) THEN
                p_sequence_number := 0;
        END IF;
        RETURN;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_001.enrp_clc_crrnt_acad');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_clc_crrnt_acad;


Procedure Enrp_Clc_Sca_Acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_cal_type OUT NOCOPY VARCHAR2 ,
  p_sequence_number OUT NOCOPY NUMBER )
AS
BEGIN
DECLARE
        v_cal_type              IGS_CA_INST.cal_type%TYPE;
        v_sequence_number       NUMBER(6);
        CURSOR  c_sca(
                        cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                        cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
                SELECT  IGS_EN_STDNT_PS_ATT.cal_type
                FROM    IGS_EN_STDNT_PS_ATT
                WHERE   person_id = cp_person_id AND
                        course_cd = cp_course_cd;
BEGIN
        -- calculates the current academic period in which the nominated student IGS_PS_COURSE
        -- attempt is enrolling as at the nominated date. The cal_type is selected
        -- from the IGS_EN_STDNT_PS_ATT and passed to the ENRP_CLC_CRRNT_ACAD
        -- routine to determine  the appropriate instance of that cal_type.
        OPEN c_sca(
                p_person_id,
                p_course_cd);
        FETCH c_sca INTO v_cal_type;
        IF(c_sca%NOTFOUND) THEN
                p_cal_type := NULL;
                p_sequence_number := 0;
                RETURN;
        END IF;
        enrp_clc_crrnt_acad(v_cal_type,
                            p_effective_dt,
                            v_sequence_number);
        IF(v_sequence_number = 0) THEN
                p_cal_type := NULL;
                p_sequence_number := 0;
        ELSE
                p_cal_type := v_cal_type;
                p_sequence_number := v_sequence_number;
        END IF;
        RETURN;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_001.enrp_clc_sca_acad');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_clc_sca_acad;


FUNCTION Enrp_Clc_Sca_Pass_Cp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN NUMBER AS
BEGIN
  -------------------------------------------------------------------------------------------
        -- enrp_clc_sca_pass_cp
        -- Calculate the CP passed by a student in a nominated IGS_PS_COURSE attempt,
        -- counting advanced stANDing which has been granted.
        -- The p_effective_dt parameter will cause only outcomes / advanced stANDing
        -- received prior to the date to be considered. This is required by
        -- retrospective EFTSU calculations which use annual load structures, as they
        -- need to estimate the load as at the time of the original EFTSU calculation.
        -- It should be noted, that this routine IS IN termediary until the
        -- Rules Sub-system is capable of calculating 'achievable' credit points
        -- on the same basis, which is envisaged for 1.4.2 delivery.
  --Change History:
  --Who         When            What
  --jbegum      25-jun-2003     Bug#2930935.Modified the cursor c_sua_uv
  --kkillams    24-04-2003      Modified the  c_sua_uv cursor and passing uoo_id to the
  --                            IGS_AS_GEN_003.assp_get_sua_outcome function w.r.t. bug number 2829262
  --rvivekan   9-sep-2003       PSP integration build#3052433. modified behavior of
  --                            repeatable_ind in the igs_ps_unit_ver table

  -------------------------------------------------------------------------------------------
DECLARE
        cst_completed           CONSTANT VARCHAR2(10) := 'COMPLETED';
        cst_duplicate           CONSTANT VARCHAR2(10) := 'DUPLICATE';
        cst_pass                CONSTANT VARCHAR2(10) := 'PASS';
        v_credit_point_total    NUMBER;
        v_advanced_standing     NUMBER;
        v_last_unit_cd          IGS_EN_SU_ATTEMPT.unit_cd%TYPE;
        v_result_type           IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE;
        v_outcome_dt            IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
        v_grading_schema_cd     IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
        v_gs_version_number     IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
        v_grade                 IGS_AS_GRD_SCH_GRADE.grade%TYPE;
        v_mark                  IGS_AS_SU_STMPTOUT.mark%TYPE;
        v_origin_course_cd      IGS_EN_STDNT_PS_ATT.course_cd%TYPE;

        CURSOR c_sua_uv IS
                SELECT  sua.person_id,
                        sua.course_cd,
                        sua.unit_cd,
                        sua.cal_type,
                        sua.ci_sequence_number,
                        sua.unit_attempt_status,
                        sua.override_achievable_cp,
                        uv.repeatable_ind,
                        NVL(cps.achievable_credit_points,uv.achievable_credit_points) achievable_credit_points,
                        NVL(cps.enrolled_credit_points,uv.enrolled_credit_points) enrolled_credit_points,
                        sua.uoo_id
                FROM    IGS_EN_SU_ATTEMPT       sua,
                        IGS_PS_UNIT_VER         uv,
                        IGS_PS_USEC_CPS         cps,
                        IGS_CA_INST             ci
                WHERE   sua.person_id                   = p_person_id AND
                        sua.course_cd                   = p_course_cd AND
                        sua.unit_attempt_status         IN(cst_completed,
                                                        cst_duplicate) AND
                        uv.unit_cd                      = sua.unit_cd AND
                        uv.version_number               = sua.version_number AND
                        ci.cal_type                     = sua.cal_type AND
                        ci.sequence_number              = sua.ci_sequence_number AND
                        sua.uoo_id                      = cps.uoo_id (+)
                ORDER BY sua.unit_cd asc,
                         sua.ci_end_dt asc;
BEGIN
        -- Set the initial values
        v_credit_point_total := 0;
        v_last_unit_cd := NULL;
        FOR v_sua_uv_rec IN c_sua_uv LOOP
                --If same as last IGS_PS_UNIT code AND not repeatable,then skip IGS_PS_UNIT;doesn't count.
                IF v_last_unit_cd IS NOT NULL AND
                                v_sua_uv_rec.repeatable_ind = 'X' AND
                                v_last_unit_cd = v_sua_uv_rec.unit_cd THEN
                        -- The IGS_PS_UNIT has been attempted earlier AND was passed but it was not
                        -- a repeatable IGS_PS_UNIT,hence further attempts attain NO credit points.
                        NULL;
                ELSE -- repeatable IGS_PS_UNIT
                        --Retrieve the outcome FROM the assessments tables
                        v_result_type := IGS_AS_GEN_003.assp_get_sua_outcome(
                                                v_sua_uv_rec.person_id,
                                                v_sua_uv_rec.course_cd,
                                                v_sua_uv_rec.unit_cd,
                                                v_sua_uv_rec.cal_type,
                                                v_sua_uv_rec.ci_sequence_number,
                                                v_sua_uv_rec.unit_attempt_status,
                                                'Y',
                                                v_outcome_dt,
                                                v_grading_schema_cd,
                                                v_gs_version_number,
                                                v_grade,
                                                v_mark,
                                                v_origin_course_cd,
                                                v_sua_uv_rec.uoo_id,
--added by LKAKI----
						'N');
                        --Only consider outcomes before or on the effective date
                        IF  v_result_type = cst_pass AND
                                        (p_effective_dt IS NULL OR
                                        TRUNC(v_outcome_dt) <= p_effective_dt) THEN
                                --Add passed grades to total
                                v_credit_point_total := v_credit_point_total +
                                                                NVL(v_sua_uv_rec.override_achievable_cp,
                                                                        NVL(v_sua_uv_rec.achievable_credit_points,
                                                                                v_sua_uv_rec.enrolled_credit_points));
                                --Set the last IGS_PS_UNIT processed
                                v_last_unit_cd := v_sua_uv_rec.unit_cd;
                        END IF;
                END IF; -- repeateable IGS_PS_UNIT
        END LOOP;
        --Add advanced standing before or on the effective date.
        v_advanced_standing := IGS_AV_GEN_001.advp_get_as_total(p_person_id,
                                                p_course_cd,
                                                p_effective_dt  );
        --add v_advanced_standing to v_credit_point_total
        v_credit_point_total := v_credit_point_total + v_advanced_standing;
        RETURN v_credit_point_total;
EXCEPTION
        WHEN OTHERS THEN
                IF c_sua_uv%ISOPEN THEN
                        CLOSE c_sua_uv;
                END IF;
                RAISE;
END;
/*
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        App_Exception.Raise_Exception;
*/
END enrp_clc_sca_pass_cp;


PROCEDURE Enrp_Del_Suao_Discon(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_discontinued_dt     IN DATE,
  p_uoo_id              IN NUMBER ) AS
 -------------------------------------------------------------------------------------------
 --Change History:
 --Who         When            What
 --kkillams    24-04-2003      New parameter p_uoo_id is added to the procedure and cursor
 --                            c_suao_find_details modified w.r.t. bug number 2829262
 -------------------------------------------------------------------------------------------
BEGIN
DECLARE
        --v_suao_rec            IGS_AS_SU_STMPTOUT%ROWTYPE;
        CURSOR  c_suao_find_details
                (cp_person_id           IGS_EN_SU_ATTEMPT.person_id%TYPE,
                 cp_course_cd           IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                 cp_uoo_id              IGS_EN_SU_ATTEMPT.uoo_id%TYPE,
                 cp_discontinued_dt     IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE) IS
                SELECT  rowid
                FROM    IGS_AS_SU_STMPTOUT
                WHERE   person_id                    = cp_person_id AND
                        course_cd                    = cp_course_cd AND
                        uoo_id                       = cp_uoo_id AND
                        TRUNC(outcome_dt)            = TRUNC(cp_discontinued_dt) AND
                        s_grade_creation_method_type = 'DISCONTIN';
BEGIN
        -- This module deletes a student IGS_PS_UNIT attempt
        -- outcome record when student IGS_PS_UNIT attempt has
        -- removed their discontinued date.
        OPEN c_suao_find_details(p_person_id,
                                 p_course_cd,
                                 p_uoo_id,
                                 p_discontinued_dt);
        FETCH c_suao_find_details INTO  l_rowid;
        -- check if a record has been found
        -- if so, the record can be deleted.
        IF (c_suao_find_details%FOUND) THEN
                IGS_AS_SU_STMPTOUT_PKG.DELETE_ROW(l_rowid);
                CLOSE c_suao_find_details;
        ELSE
                CLOSE c_suao_find_details;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_001.enrp_del_suao_discon');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_del_suao_discon;


FUNCTION Enrp_Del_Sua_Sut(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER)
RETURN BOOLEAN AS
-------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
--kkillams    24-04-2003      New parameter p_uoo_id is added to the function.
--                            Cursor c_sua_delete is modified w.r.t. bug number 2829262
-------------------------------------------------------------------------------------------
        e_resource_busy_exception               EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
BEGIN   -- enrp_del_sua_sut
        -- This module validates if a duplicate IGS_EN_SU_ATTEMPT can be deleted,
        -- and deletes associated IGS_PS_STDNT_UNT_TRN detail.
DECLARE
        cst_duplicate           VARCHAR2(10) := 'DUPLICATE';
        v_person_id             IGS_PS_STDNT_UNT_TRN.person_id%TYPE;
        -- cursor to locate duplicate in another IGS_PS_COURSE.
        CURSOR  c_sut_duplicate IS
                SELECT  person_id
                FROM    IGS_PS_STDNT_UNT_TRN sut
                WHERE   sut.person_id           = p_person_id AND
                        sut.transfer_course_cd  = p_course_cd AND
                        sut.uoo_id              = p_uoo_id;
        --cursor to acquire lock for delete
        CURSOR c_sut_delete IS
                SELECT  rowid,person_id
                FROM    IGS_PS_STDNT_UNT_TRN sut
                WHERE   sut.person_id           = p_person_id AND
                        sut.course_cd           = p_course_cd AND
                        sut.uoo_id              = p_uoo_id
                FOR UPDATE OF sut.person_id NOWAIT;
BEGIN
        IF p_unit_attempt_status = cst_duplicate THEN
                -- Validate the duplicate student attempt is not a duplicate in another IGS_PS_COURSE
                OPEN c_sut_duplicate;
                FETCH c_sut_duplicate INTO v_person_id;
                IF (c_sut_duplicate%FOUND) THEN
                        CLOSE c_sut_duplicate;
                        p_message_name := 'IGS_EN_DUPL_STUD_UNIT_ATTEMPT';
                        RETURN FALSE;
                END IF;
                CLOSE c_sut_duplicate;
                FOR v_sut_delete_rec IN c_sut_delete LOOP
                      IGS_PS_STDNT_UNT_TRN_PKG.DELETE_ROW(v_sut_delete_rec.rowid);
                END LOOP;
        END IF;
        p_message_name := Null;
        RETURN TRUE;
EXCEPTION
        -- If record cannot be locked for deletion
        -- this exception was unable to be tested because only insertions and deletions
        -- are applicable to the Student IGS_PS_UNIT Transfer table.
        WHEN e_resource_busy_exception THEN
                IF (c_sut_delete%ISOPEN) THEN
                        CLOSE c_sut_delete;
                END IF;
                p_message_name := 'IGS_EN_SU_TRANSFER_NOTDEL';
                RETURN FALSE;
        -- handling any other exception
        WHEN OTHERS THEN
                IF (c_sut_duplicate%ISOPEN) THEN
                        CLOSE c_sut_duplicate;
                END IF;
                IF (c_sut_delete%ISOPEN) THEN
                        CLOSE c_sut_delete;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_001.enrp_del_sua_sut');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_del_sua_sut;


FUNCTION Enrp_Del_Sua_Trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER )
RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    24-04-2003      New parameter p_uoo_id is added to the function.
  --                            Cursor c_sua_delete is modified.
  --                            w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
BEGIN   -- enrp_del_sua_trnsfr
        -- This module deletes a transferred IGS_EN_SU_ATTEMPT record.
DECLARE
        e_resource_busy_exception       EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
        -- cursor to lock records for delete
        CURSOR c_sua_delete IS
                SELECT  rowid rowid1,person_id
                FROM    IGS_EN_SU_ATTEMPT       sua
                WHERE   sua.person_id   = p_person_id AND
                        sua.course_cd   = p_course_cd AND
                        sua.uoo_id      = p_uoo_id
                FOR UPDATE OF sua.person_id NOWAIT;
BEGIN
        p_message_name := null;
        -- Check parameters
        IF p_person_id IS NULL OR
           p_course_cd IS NULL OR
           p_unit_cd IS NULL OR
           p_cal_type IS NULL OR
           p_ci_sequence_number IS NULL OR
           p_uoo_id IS NULL THEN
                 RETURN TRUE;
        END IF;

        FOR v_sua_delete_rec IN c_sua_delete
        LOOP
        -- Delete current record
                IGS_EN_SU_ATTEMPT_PKG.DELETE_ROW(v_sua_delete_rec.rowid1 );
        END LOOP;
        -- Record successfuly deleted
        RETURN TRUE;
EXCEPTION
        -- Record cannot be locked for deletion
        WHEN e_resource_busy_exception THEN
                IF (c_sua_delete%ISOPEN) THEN
                        CLOSE c_sua_delete;
                END IF;
                p_message_name := 'IGS_EN_TRNS_SUA_NOTDEL';
                RETURN FALSE;
        -- Any other exception.
        WHEN OTHERS THEN
                IF (c_sua_delete%ISOPEN) THEN
                        CLOSE c_sua_delete;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_001.enrp_del_sua_trnsfr');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_del_sua_trnsfr;


Function Enrp_Del_Susa_Hist(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN AS

        resource_busy_exception EXCEPTION;
        PRAGMA EXCEPTION_INIT(resource_busy_exception, -54);
BEGIN   -- enrp_del_susa_hist
        -- This module will delete the history records associated with a
        -- IGS_AS_SU_SETATMPT record.
DECLARE
        v_person_id     IGS_AS_SU_SETATMPT_H.person_id%TYPE;
        -- Delete student_unit_set_attempt_hist record, returning false if
        -- a lock exists. Select FOR UPDATE NOWAIT to acquire locks.
        CURSOR c_susah IS
                SELECT  susah.rowid,
                        susah.person_id person_id
                FROM    IGS_AS_SU_SETATMPT_H susah
                WHERE   susah.person_id         = p_person_id           AND
                        susah.course_cd         = p_course_cd           AND
                        susah.unit_set_cd       = p_unit_set_cd         AND
                        susah.sequence_number   = p_sequence_number
                FOR UPDATE OF susah.person_id NOWAIT;
BEGIN
        -- Set the default message number
        p_message_name := null;
        FOR v_susah_rec IN c_susah LOOP
                -- Delete the current record.

                IGS_AS_SU_SETATMPT_H_PKG.DELETE_ROW(
                                                  v_susah_rec.rowid
                                                 );

        END LOOP;
        -- If processing successful then
        RETURN TRUE;
EXCEPTION
        -- If an exception raised indicating a lock on any of the records in the
        -- select set, then want to handle the exception by returning false and
        -- an error message from this routine.
        WHEN resource_busy_exception THEN
                IF (c_susah%ISOPEN) THEN
                        CLOSE c_susah;
                END IF;

                p_message_name := 'IGS_EN_UNABLE_NOTDEL_SUA_LOCK';
                RETURN FALSE;
        WHEN OTHERS THEN
                IF (c_susah%NOTFOUND) THEN
                        CLOSE c_susah;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_001.enrp_del_susa_hist');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_del_susa_hist ;


Function Enrp_Del_Susa_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN AS

BEGIN   -- enrp_del_susa_trnsfr
        -- This module deletes a transferred IGS_AS_SU_SETATMPT
        -- record.
DECLARE
        e_resource_busy         EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
        CURSOR  c_susa_delete IS
                SELECT  rowid,person_id
                FROM    IGS_AS_SU_SETATMPT susa
                WHERE   susa.person_id          = p_person_id AND
                        susa.course_cd          = p_course_cd AND
                        susa.unit_set_cd        = p_unit_set_cd AND
                        susa.us_version_number  = p_us_version_number
                FOR UPDATE OF susa.person_id NOWAIT;
BEGIN
        p_message_name := null;
        -- Check parameters
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL OR
                        p_unit_set_cd IS NULL OR
                        p_us_version_number IS NULL THEN
                RETURN TRUE;
        END IF;
        FOR v_susa_delete_rec IN c_susa_delete LOOP
                -- Delete current record

                IGS_AS_SU_SETATMPT_PKG.DELETE_ROW(
                                                    v_susa_delete_rec.rowid
                                                );

        END LOOP;
        -- Record successfuly deleted
        RETURN TRUE;
EXCEPTION
        -- Record cannot be locked for deletion
        WHEN e_resource_busy THEN
                IF (c_susa_delete%ISOPEN) THEN
                        CLOSE c_susa_delete;
                END IF;
                p_message_name := 'IGS_EN_TRNS_SUA_NOTDEL_UPD';
                RETURN FALSE;
        -- Any other exception.
        WHEN OTHERS THEN
                IF (c_susa_delete%ISOPEN) THEN
                        CLOSE c_susa_delete;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_001.enrp_del_susa_trnsfr');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_del_susa_trnsfr;

END IGS_EN_GEN_001;

/
