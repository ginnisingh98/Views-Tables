--------------------------------------------------------
--  DDL for Package Body IGS_PR_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_GEN_006" AS
/* $Header: IGSPR27B.pls 120.0 2005/07/05 11:48:45 appldev noship $ */
/*
  ||==============================================================================||
  ||  Created By : Nalin Kumar                                                    ||
  ||  Created On : 19-NOV-2002                                                    ||
  ||  Purpose :                                                                   ||
  ||  Known limitations, enhancements or remarks :                                ||
  ||  Change History :                                                            ||
  ||  Who             When            What                                        ||
  ||  (reverse chronological order - newest change first)                         ||
  ||==============================================================================||
  || sarakshi   16-Nov-2004   Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG in function IGS_PR_UPD_SCA_STATUS
  || ssawhney   17-feb-2003   Bug : 2758856  : Added the parameter x_external_reference
  ||                                           in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW
  ||
  ||  NALKUMAR  19-NOV-2002   Bug NO: 2658550                                   ||
  ||                            Modified this object as per the FA110 PR Enh.     ||
  ||==============================================================================||
  ||  pkpatel   07-OCT-2002     Bug No: 2600842                             ||
  ||                                  Added the parameter auth_resp_id in the call to THB igs_pe_pers_encumb_pkg
   | nmankodi   11-Apr-2005     fnd_user.customer_id column has been changed to
 |                            fnd_user.person_party_id as an ebizsuite wide TCA mandate.
  ||==============================================================================||
*/

FUNCTION IGS_PR_GET_SCSC_COMP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cst_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
        gv_other_detail                 VARCHAR2(255);
BEGIN   -- IGS_PR_get_scsc_comp
        -- Get whether course stage has been manually completed for
        -- a student course attempt.This is signified by the existence of
        -- a student_crs_stage_cmpltn record.
DECLARE
        cst_y           CONSTANT        VARCHAR2(1)     := 'Y';
        cst_n           CONSTANT        VARCHAR2(1)     := 'N';
        v_dummy                         VARCHAR2(1);
/*      CURSOR c_scsc IS
                SELECT  'X'
                FROM    student_crs_stage_cmpltn        scsc
                WHERE   scsc.person_id                  = p_person_id AND
                        scsc.course_cd                  = p_course_cd AND
                        scsc.version_number             = p_version_number AND
                        scsc.cst_sequence_number        = p_cst_sequence_number;       */
BEGIN

/*
        OPEN c_scsc;
        FETCH c_scsc INTO v_dummy;
        IF c_scsc%FOUND THEN
                CLOSE c_scsc;
                RETURN cst_y;
        ELSE
                CLOSE c_scsc;
                RETURN cst_n;
        END IF;
        */
        RETURN cst_n;
END;
EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_SCSC_COMP');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
END IGS_PR_get_scsc_comp;

FUNCTION IGS_PR_get_spo_aply_dt(
  p_decision_status IN VARCHAR2 ,
  p_old_applied_dt IN DATE ,
  p_new_applied_dt IN DATE ,
  p_old_encmb_course_group_cd IN VARCHAR2 ,
  p_new_encmb_course_group_cd IN VARCHAR2 ,
  p_old_restricted_enrolment_cp IN NUMBER ,
  p_new_restricted_enrolment_cp IN NUMBER ,
  p_old_restricted_attend_type IN VARCHAR2 ,
  p_new_restricted_attend_type IN VARCHAR2 ,
  p_old_expiry_dt IN DATE ,
  p_new_expiry_dt IN DATE ,
  p_old_duration IN NUMBER ,
  p_new_duration IN NUMBER ,
  p_old_duration_type IN VARCHAR2 ,
  p_new_duration_type IN VARCHAR2 ,
  p_out_applied_dt OUT NOCOPY DATE )
RETURN BOOLEAN IS
        gv_other_detail                 VARCHAR2(255);
BEGIN   -- IGS_PR_get_spo_aply_dt
        -- If the student progression outcome details have been changed
        -- return the correct applied date.
        p_out_applied_dt := NULL;
        IF p_decision_status <> 'APPROVED' OR
           TRUNC(NVL(p_new_applied_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) <>
           TRUNC(NVL(p_old_applied_dt, IGS_GE_DATE.IGSDATE('9999/01/01'))) THEN
                RETURN TRUE;
        END IF;
        IF NVL(p_old_encmb_course_group_cd, 'NULL') <>
                NVL(p_new_encmb_course_group_cd, 'NULL') OR
           NVL(p_old_restricted_enrolment_cp, 0) <>
                NVL(p_new_restricted_enrolment_cp, 0) OR
           NVL(p_old_restricted_attend_type, 'NULL') <>
                NVL(p_new_restricted_attend_type, 'NULL') OR
           TRUNC(NVL(p_old_expiry_dt, IGS_GE_DATE.IGSDATE('0001/01/01'))) <>
                TRUNC(NVL(p_new_expiry_dt, IGS_GE_DATE.IGSDATE('0001/01/01'))) OR
           NVL(p_old_duration, 0) <>
                NVL(p_new_duration, 0) OR
           NVL(p_old_duration_type, 'NULL') <>
                NVL(p_new_duration_type, 'NULL') THEN
                IF TRUNC(p_new_applied_dt) <>
                   TRUNC(IGS_GE_DATE.IGSDATE('0001/01/01')) THEN
                        p_out_applied_dt := IGS_GE_DATE.IGSDATE('0001/01/01');
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_SPO_APLY_DT');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
END IGS_PR_get_spo_aply_dt;

FUNCTION IGS_PR_GET_SPO_CMT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_course_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 )
RETURN VARCHAR2 IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- IGS_PR_get_spo_cmt
        -- Get whether student progression outcome is covered by the nominated
        -- committee structure
DECLARE
        v_ou_rel_found          BOOLEAN DEFAULT FALSE;
        v_dummy                 VARCHAR2(1);
        CURSOR c_crv_cow IS
                SELECT  crv.course_type,
                        cow.org_unit_cd,
                        cow.ou_start_dt
                FROM    IGS_EN_STDNT_PS_ATT     sca,
                        IGS_PS_VER              crv,
                        IGS_PS_OWN      cow
                WHERE   sca.person_id           = p_person_id AND
                        sca.course_cd           = p_course_cd AND
                        (sca.version_number     = p_version_number OR
                        p_version_number        IS NULL) AND
                        (sca.location_cd        = p_location_cd OR
                        p_location_cd           IS NULL) AND
                        (sca.attendance_mode    = p_attendance_mode OR
                        p_attendance_mode       IS NULL) AND
                        crv.course_cd           = sca.course_cd AND
                        crv.version_number      = sca.version_number AND
                        crv.course_cd           = cow.course_cd AND
                        crv.version_number      = cow.version_number AND
                        (crv.course_type        = p_course_type OR
                        p_course_type           IS NULL);
        CURSOR c_our (
                cp_cow_org_unit_cd      IGS_OR_UNIT.org_unit_cd%TYPE,
                cp_cow_ou_start_dt      IGS_PS_VER.start_dt%TYPE,
                cp_course_type          IGS_PS_VER.course_type%TYPE) IS
                SELECT  'X'
                FROM    IGS_OR_UNIT_REL our
                WHERE   our.parent_org_unit_cd  = p_org_unit_cd AND
                        our.parent_start_dt     = p_ou_start_dt AND
                        our.child_org_unit_cd   = cp_cow_org_unit_cd AND
                        our.child_start_dt      = cp_cow_ou_start_dt AND
                        our.logical_delete_dt   IS NULL AND
                        EXISTS  (
                        SELECT  'X'
                        FROM    IGS_OR_REL_PS_TYPE      ourct
                        WHERE   our.parent_org_unit_cd  = ourct.parent_org_unit_cd AND
                                our.parent_start_dt     = ourct.parent_start_dt AND
                                our.child_org_unit_cd   = ourct.child_org_unit_cd AND
                                our.child_start_dt      = ourct.child_start_dt AND
                                our.create_dt           = ourct.our_create_dt AND
                                ourct.course_type       = cp_course_type);
BEGIN
        FOR v_crv_cow_rec IN c_crv_cow LOOP
                IF v_crv_cow_rec.org_unit_cd = p_org_unit_cd    AND
                    v_crv_cow_rec.ou_start_dt = p_ou_start_dt THEN
                        RETURN 'Y';
                END IF;
                -- Firstly search for a direct match to an organisational unit with the
                -- course type qualification, if doesn't then move onto a standard ou
                -- relationship test.
                OPEN c_our (
                        v_crv_cow_rec.org_unit_cd,
                        v_crv_cow_rec.ou_start_dt,
                        v_crv_cow_rec.course_type);
                FETCH c_our INTO v_dummy;
                IF c_our%FOUND THEN
                        CLOSE c_our;
                        v_ou_rel_found := TRUE;
                        EXIT;
                ELSE
                        CLOSE c_our;
                        IF IGS_OR_GEN_001.ORGP_GET_WITHIN_OU (
                                                p_org_unit_cd,
                                                p_ou_start_dt,
                                                v_crv_cow_rec.org_unit_cd,
                                                v_crv_cow_rec.ou_start_dt,
                                                'N') = 'Y' THEN
                                v_ou_rel_found := TRUE;
                                EXIT;
                        END IF;
                END IF;
        END LOOP;
        IF v_ou_rel_found THEN
                RETURN 'Y';
        END IF;
        RETURN 'N';
EXCEPTION
        WHEN OTHERS THEN
                IF c_crv_cow%ISOPEN THEN
                        CLOSE c_crv_cow;
                END IF;
                IF c_our%ISOPEN THEN
                        CLOSE c_our;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_SPO_CMT');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
END IGS_PR_get_spo_cmt;
FUNCTION IGS_PR_get_spo_expiry(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_spo_expiry_dt IN DATE ,
  p_expiry_dt OUT NOCOPY DATE )
RETURN VARCHAR2 IS
        gv_other_detail                 VARCHAR2(255);
BEGIN   -- IGS_PR_get_spo_expiry
        -- Calculates the expiry date of a student progression outcome record.
        -- Note: an open-ended expiry date returns with the value 01/01/4000.
        -- An un-determinable expiry date returns NULL.
DECLARE
        cst_active      CONSTANT        VARCHAR2(10) := 'ACTIVE';
        cst_progress    CONSTANT        VARCHAR2(10) := 'PROGRESS';
        cst_normal      CONSTANT        VARCHAR2(10) := 'NORMAL';
        cst_open        CONSTANT        VARCHAR2(10) := 'OPEN';
        cst_current     CONSTANT        VARCHAR2(10) := 'CURRENT';
        cst_expired     CONSTANT        VARCHAR2(10) := 'EXPIRED';
        v_expiry_dt                     IGS_CA_INST.end_dt%TYPE;
        v_period_found                  BOOLEAN DEFAULT FALSE;
        v_ci_count                      INTEGER DEFAULT 0;
        v_dummy                         VARCHAR2(1);
        CURSOR c_spo_ci_sca IS
                SELECT  spo.prg_cal_type,
                        spo.prg_ci_sequence_number,
                        spo.duration,
                        spo.duration_type,
                        ci.start_dt,
                        sca.version_number
                FROM    IGS_PR_STDNT_PR_OU      spo,
                        IGS_CA_INST                     ci,
                        IGS_EN_STDNT_PS_ATT             sca
                WHERE   spo.person_id                   = p_person_id AND
                                spo.course_cd                   = p_course_cd AND
                                spo.sequence_number             = p_sequence_number AND
                                ci.cal_type                             = spo.prg_cal_type AND
                                ci.sequence_number              = spo.prg_ci_sequence_number AND
                                sca.person_id                   = spo.person_id AND
                                sca.course_cd                   = spo.course_cd;
        v_spo_rec                       c_spo_ci_sca%ROWTYPE;
        CURSOR c_ci_ct_cs (
                cp_prg_start_dt                 IGS_CA_INST.start_dt%TYPE,
                cp_sca_version_number           IGS_EN_STDNT_PS_ATT.version_number%TYPE,
                cp_spo_duration_type            IGS_PR_STDNT_PR_OU.duration_type%TYPE,
                cp_spo_prg_cal_type             IGS_PR_STDNT_PR_OU.prg_cal_type%TYPE) IS
                SELECT  ci.cal_type,
                        ci.sequence_number
                FROM    IGS_CA_INST                     ci,
                        IGS_CA_TYPE             ct,
                        IGS_CA_STAT                     cs
                WHERE   ct.cal_type                     = ci.cal_type AND
                        ct.s_cal_cat                    = cst_progress AND
                        cs.cal_status                   = ci.cal_status AND
                        cs.s_cal_status                 = cst_active AND
                        ci.start_dt                     > cp_prg_start_dt AND
                        (       EXISTS  (SELECT 'x'
                                                 FROM   IGS_PR_S_PRG_CAL spc1,
                                                        IGS_PR_S_PRG_CAL spc2
                                                 WHERE  spc1.s_control_num = 1 AND
                                                        spc2.s_control_num = 1 AND
                                                        spc1.prg_cal_type = cp_spo_prg_cal_type AND
                                                        spc2.prg_cal_type = ci.cal_type AND
                                                        spc1.stream_num = spc2.stream_num) OR
                                EXISTS (SELECT  'x'
                                                FROM    IGS_PR_S_OU_PRG_CAL sopc1,
                                                                IGS_PR_S_OU_PRG_CAL sopc2
                                                WHERE   IGS_PR_GEN_001.PRGP_GET_CRV_CMT(   p_course_cd,
                                                                        cp_sca_version_number,
                                                                        sopc1.org_unit_cd,
                                                                        sopc1.ou_start_dt) = 'Y' AND
                                                sopc1.prg_cal_type = cp_spo_prg_cal_type AND
                                                sopc2.org_unit_cd = sopc1.org_unit_cd AND
                                                sopc2.ou_start_dt = sopc1.ou_start_dt AND
                                                sopc2.prg_cal_type = ci.cal_type AND
                                                sopc1.stream_num = sopc2.stream_num) OR
                                EXISTS (SELECT 'x'
                                                FROM    IGS_PR_S_CRV_PRG_CAL scpc1,
                                                        IGS_PR_S_CRV_PRG_CAL scpc2
                                                WHERE   scpc1.course_cd = p_course_cd AND
                                                        scpc1.version_number = cp_sca_version_number AND
                                                        scpc1.prg_cal_type = cp_spo_prg_cal_type AND
                                                        scpc2.course_cd = scpc1.course_cd AND
                                                        scpc2.version_number = scpc1.version_number AND
                                                        scpc2.prg_cal_type = ci.cal_type AND
                                                        scpc1.stream_num = scpc2.stream_num)) AND
                        (cp_spo_duration_type           = cst_normal OR
                        (IGS_PR_GEN_001.PRGP_get_drtn_efctv (
                                ci.cal_type,
                                ci.sequence_number,
                                p_person_id,
                                p_course_cd)            = 'Y') AND
                        EXISTS  (
                                SELECT  'x'
                                FROM    IGS_EN_SU_ATTEMPT sua,
                                                IGS_CA_INST_REL cir
                                WHERE   sua.person_id = p_person_id AND
                                                sua.course_cd = p_coursE_cd AND
                                                sua.unit_attempt_status IN ('ENROLLED','COMPLETED','DISCONTIN') AND
                                                cir.sup_cal_type = ci.cal_type AND
                                                cir.sup_ci_sequence_number = ci.sequence_number AND
                                                cir.sub_cal_type = sua.cal_type AND
                                                cir.sub_ci_sequence_number = sua.ci_sequence_number))
                ORDER BY ci.start_dt;
BEGIN
        -- Set the default expiry date
        p_expiry_dt := NULL;
        -- If the expiry date is set then check it and return accordingly.
        IF p_spo_expiry_dt IS NOT NULL THEN
                p_expiry_dt := p_spo_expiry_dt;
                IF p_spo_expiry_dt <= TRUNC(SYSDATE) THEN
                        RETURN cst_expired;
                ELSE
                        RETURN cst_current;
                END IF;
        END IF;
        -- Select IGS_PR_STDNT_PR_OU record
        OPEN c_spo_ci_sca;
        FETCH c_spo_ci_sca INTO v_spo_rec;
        IF c_spo_ci_sca%NOTFOUND THEN
                CLOSE c_spo_ci_sca;
                RETURN NULL;
        END IF;
        CLOSE c_spo_ci_sca;
        IF v_spo_rec.duration IS NULL THEN
                RETURN cst_open;
        END IF;
        -- Loop through progression periods from the application period forward until
        -- the ending period is found ; the calendar instance end date is the expiry
        -- date
        FOR v_ci_rec IN c_ci_ct_cs (
                                v_spo_rec.start_dt,
                                v_spo_rec.version_number,
                                v_spo_rec.duration_type,
                                v_spo_rec.prg_cal_type) LOOP
                v_ci_count := v_ci_count + 1;
                IF v_ci_count = v_spo_rec.duration THEN
                        v_expiry_dt := IGS_PR_GEN_005.IGS_PR_get_prg_pen_end(
                                                        v_ci_rec.cal_type,
                                                        v_ci_rec.sequence_number);
                        v_period_found := TRUE;
                        EXIT;
                END IF;
        END LOOP;
        IF v_period_found THEN
                p_expiry_dt := v_expiry_dt;
                IF v_expiry_dt <= TRUNC(SYSDATE) THEN
                        RETURN cst_expired;
                END IF;
        END IF;
        RETURN cst_current;
EXCEPTION
        WHEN OTHERS THEN
                IF c_spo_ci_sca%ISOPEN THEN
                        CLOSE c_spo_ci_sca;
                END IF;
                IF c_ci_ct_cs%ISOPEN THEN
                        CLOSE c_ci_ct_cs;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
END IGS_PR_get_spo_expiry;

FUNCTION IGS_PR_get_sprc_dsp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_rule_check_dt IN DATE ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- IGS_PR_get_sprc_dsp
        --  Determine if the IGS_PR_SDT_PR_RU_CK record should be displayed.
        -- 1. If there is an IGS_PR_STDNT_PR_OU record linked to it
        -- 2. If it is the most recent of passed or failed record
DECLARE
        v_dummy                 VARCHAR2(1);
        CURSOR c_spo IS
                SELECT  'X'
                FROM    IGS_PR_STDNT_PR_OU
                WHERE   person_id                       = p_person_id AND
                        course_cd                       = p_course_cd AND
                        prg_cal_type                    = p_prg_cal_type AND
                        prg_ci_sequence_number          = p_prg_ci_sequence_number AND
                        rule_check_dt                   = p_rule_check_dt AND
                        progression_rule_cat            = p_progression_rule_cat AND
                        pra_sequence_number             = p_pra_sequence_number AND
                        decision_status IN ('APPROVED', 'PENDING');
        CURSOR c_sprc IS
                SELECT  'X'
                FROM    IGS_PR_SDT_PR_RU_CK             sprc
                WHERE   sprc.person_id                  = p_person_id AND
                        sprc.course_cd                  = p_course_cd AND
                        sprc.prg_cal_type                       = p_prg_cal_type AND
                        sprc.prg_ci_sequence_number     = p_prg_ci_sequence_number AND
                        sprc.rule_check_dt                      = p_rule_check_dt AND
                        sprc.progression_rule_cat               = p_progression_rule_cat AND
                        sprc.pra_sequence_number                = p_pra_sequence_number AND
                        sprc.rule_check_dt
                                = (     SELECT  MAX(sprc2.rule_check_dt)
                                        FROM    IGS_PR_SDT_PR_RU_CK             sprc2
                                        WHERE   sprc2.person_id                 = sprc.person_id AND
                                                sprc2.course_cd                 = sprc.course_cd AND
                                                sprc2.prg_cal_type                      = sprc.prg_cal_type AND
                                                sprc2.prg_ci_sequence_number    = sprc.prg_ci_sequence_number AND
                                                sprc2.progression_rule_cat              = sprc.progression_rule_cat AND
                                                sprc2.pra_sequence_number       = sprc.pra_sequence_number);
BEGIN
        -- Check parameters
        IF p_person_id IS NULL OR
            p_course_cd  IS NULL OR
            p_prg_cal_type  IS NULL OR
            p_prg_ci_sequence_number  IS NULL OR
            p_rule_check_dt IS NULL OR
            p_progression_rule_cat  IS NULL OR
            p_pra_sequence_number  IS NULL THEN
                RETURN 'N';
        END IF;
        -- 1. Check for IGS_PR_STDNT_PR_OU records
        OPEN c_spo;
        FETCH c_spo INTO v_dummy;
        IF c_spo%FOUND THEN
                CLOSE c_spo;
                RETURN 'Y';
        END IF;
        CLOSE c_spo;
        -- 2. Check If this is the most recent of passed or failed records
        OPEN c_sprc;
        FETCH c_sprc INTO v_dummy;
        IF c_sprc%FOUND THEN
                CLOSE c_sprc;
                RETURN 'Y';
        END IF;
        CLOSE c_sprc;
        RETURN 'N';
EXCEPTION
        WHEN OTHERS THEN
                IF c_spo%ISOPEN THEN
                        CLOSE c_spo;
                END IF;
                IF c_sprc%ISOPEN THEN
                        CLOSE c_sprc;
                END IF;
                RAISE;
END;
END IGS_PR_get_sprc_dsp;
FUNCTION IGS_PR_GET_STD_GPA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER )
RETURN NUMBER IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- IGS_GR_get_std_gpa
        -- Get the 'standard' GPA figure applicable to a course version / institution.
        --      Note:   currently this routine embeds the concept of the 'standard' value
        --              within the logic, however, in future this will be expanded in a
        --              rule / configuration option.
DECLARE
        v_std_gpa               NUMBER := 0;
BEGIN
        v_std_gpa := IGS_PR_GEN_001.PRGP_get_sca_gpa(
                        p_person_id,
                        p_course_cd,
                        NULL,
                        NULL,
                        p_prg_cal_type,
                        p_prg_sequence_number,
                        NULL,                   -- No best/worst
                        'N',                    -- Don't use recommended
                        'N',                    -- Not first attempts
                        'N');                   -- Not entered grades
        RETURN v_std_gpa;
END;
EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_STD_GPA');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
END IGS_PR_get_std_gpa;


FUNCTION IGS_PR_GET_STD_WAM(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER )
RETURN NUMBER IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- IGS_PR_get_std_wam
        -- Get the 'standard' wam figure applicable to a course version / institution.
        --      Note:   currently this routine embeds the concept of the 'standard' value
        --              within the logic, however, in future this will be expanded in a
        --              rule / configuration option.
DECLARE
        v_std_wam               NUMBER := 0;
BEGIN
        v_std_wam := IGS_PR_GEN_002.PRGP_get_sca_wam(
                        p_person_id,
                        p_course_cd,
                        p_course_version,
                        NULL,
                        NULL,
                        p_prg_cal_type,
                        p_prg_sequence_number,
                        'N',                    -- Don't use recommended
                        'Y');                   -- Abort when missing
        RETURN v_std_wam;
END;
EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_STD_WAM');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
END IGS_PR_get_std_wam;


FUNCTION IGS_PR_get_within_appl(
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_application_type IN VARCHAR2 ,
  p_start_dt OUT NOCOPY DATE ,
  p_cutoff_dt OUT NOCOPY DATE )
RETURN VARCHAR2 IS
        gv_other_detail                 VARCHAR2(255);
BEGIN   -- IGS_PR_get_within_appl
        -- Get whether student course attempt is still within the processing bounds
        -- of the nominated progression calendar instance.
        -- There are three possible ranges that can be used :
        -- INITIAL Application : only eligible if within the start/end application
        --      period applicable to the students course
        -- TODO Application : only eligible if within the start application / latest
        --      of {benefit, penalty} cutoff dates
        -- BENEFIT Application : only eligible if within the start
        --      application / benefit cutoff period applicable to the students course
        -- PENALTY Application : only eligible if within the start
        --      application / penalty cutoff period applicable to the students course
        -- The applicable start/cutoff dates are returned in OUT NOCOPY parameters.
DECLARE
        cst_initial                     CONSTANT                VARCHAR2(10) := 'INITIAL';
        cst_todo                        CONSTANT                VARCHAR2(10) := 'TODO';
        cst_benefit             CONSTANT                VARCHAR2(10) := 'BENEFIT';
        cst_penalty             CONSTANT                VARCHAR2(10) := 'PENALTY';
        v_start_dt                                      DATE;
        v_cutoff_dt                                     DATE;
        v_benefit_dt                                    DATE;
        v_penalty_dt                                    DATE;
        v_apply_start_dt_alias                          IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
        v_apply_end_dt_alias                            IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
        v_end_benefit_dt_alias                          IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
        v_end_penalty_dt_alias                          IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
        v_show_cause_cutoff_dt                          IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
        v_appeal_cutoff_dt                                      IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
        v_show_cause_ind                                        IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
        v_apply_before_show_ind                         IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
        v_appeal_ind                                    IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
        v_apply_before_appeal_ind                               IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
        v_count_sus_in_time_ind                         IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
        v_count_exc_in_time_ind                         IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
        v_calculate_wam_ind                             IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
        v_calculate_gpa_ind                             IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
        v_outcome_check_type            IGS_PR_S_PRG_CONF.outcome_check_type%TYPE;
        FUNCTION prgpl_get_alias_value (
                p_dt_alias                      VARCHAR2)
        RETURN DATE
        IS
                gvl_other_detail                        VARCHAR2(255);
        BEGIN   -- prgpl_get_alias_value
        DECLARE
                v_alias_value                           DATE;
                CURSOR c_dai IS
                        SELECT  IGS_CA_GEN_001.CALP_GET_ALIAS_VAL (
                                                dai.dt_alias,
                                                dai.sequence_number,
                                                p_prg_cal_type,
                                                p_prg_sequence_number)
                        FROM    IGS_CA_DA_INST          dai
                        WHERE   dai.cal_type            = p_prg_cal_type AND
                                dai.ci_sequence_number  = p_prg_sequence_number AND
                                dai.dt_alias            = p_dt_alias
                        ORDER BY 1 DESC;
        BEGIN
                OPEN c_dai;
                FETCH c_dai INTO v_alias_value;
                IF c_dai%FOUND THEN
                        CLOSE c_dai;
                        RETURN v_alias_value;
                END IF;
                CLOSE c_dai;
                RETURN NULL;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_dai%ISOPEN THEN
                                CLOSE c_dai;
                        END IF;
                        RAISE;
        END;
        EXCEPTION
                WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_WITHIN_APPL.PRGPL_GET_ALIAS_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END prgpl_get_alias_value;

BEGIN
        IGS_PR_GEN_003.IGS_PR_get_config_parm (
                                p_course_cd,
                                p_version_number,
                                v_apply_start_dt_alias,
                                v_apply_end_dt_alias,
                                v_end_benefit_dt_alias,
                                v_end_penalty_dt_alias,
                                v_show_cause_cutoff_dt,
                                v_appeal_cutoff_dt,
                                v_show_cause_ind,
                                v_apply_before_show_ind,
                                v_appeal_ind,
                                v_apply_before_appeal_ind,
                                v_count_sus_in_time_ind,
                                v_count_exc_in_time_ind,
                                v_calculate_wam_ind,
                                v_calculate_gpa_ind,
                                v_outcome_check_type);
        v_start_dt := prgpl_get_alias_value (v_apply_start_dt_alias);
        -- Set the cutoff date according to the type of application
        IF p_application_type = cst_initial THEN
                v_cutoff_dt := prgpl_get_alias_value (v_apply_end_dt_alias);
        ELSIF p_application_type = cst_todo THEN
                p_start_dt := NULL;
                p_cutoff_dt := NULL;
                RETURN 'Y';
        ELSIF p_application_type = cst_benefit THEN
                v_cutoff_dt := prgpl_get_alias_value (v_end_benefit_dt_alias);
        ELSIF p_application_type = cst_penalty THEN
                v_cutoff_dt := prgpl_get_alias_value (v_end_penalty_dt_alias);
        ELSE
                RETURN 'N';
        END IF;
        p_start_dt := v_start_dt;
        p_cutoff_dt := v_cutoff_dt;
        -- If within dates then return 'Y'
        IF NVL(v_start_dt,TRUNC(SYSDATE)+1) <= TRUNC(SYSDATE) AND
                        NVL(v_cutoff_dt,TRUNC(SYSDATE)) >= TRUNC(SYSDATE) THEN
                RETURN 'Y';
        ELSE
                RETURN 'N';
        END IF;
END;
EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_WITHIN_APPL');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
END IGS_PR_get_within_appl;


FUNCTION IGS_PR_INS_COPY_PRA(
  p_progression_rule_cat IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_new_course_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_new_org_unit_cd IN VARCHAR2 ,
  p_new_ou_start_dt IN DATE ,
  p_new_spo_person_id IN NUMBER ,
  p_new_spo_course_cd IN VARCHAR2 ,
  p_new_spo_sequence_number IN NUMBER ,
  p_new_sca_person_id IN NUMBER ,
  p_new_sca_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN NUMBER IS
        gcst_max_error_range    CONSTANT NUMBER := -20999;
        gcst_min_error_range    CONSTANT NUMBER := -20000;
        --kdande; 19-Jul-2002; Bug# 2462120; Changed the message name from 301 to IGS_PS_FAIL_COPY_PRGVER_DETAI
        gcst_ret_message_num    CONSTANT VARCHAR2(30) := 'IGS_PS_FAIL_COPY_PRGVER_DETAI';
        gv_other_detail         VARCHAR2(255);
        gv_err_inserting        VARCHAR2(255);
        gv_err_ins_rule         VARCHAR2(255);  -- creating progression rule
        gv_err_ins_pra          VARCHAR2(255);  -- IGS_PR_RU_APPL
        gv_err_ins_prrc         VARCHAR2(255);  -- IGS_PR_RU_CA_TYPE
        gv_err_ins_pro          VARCHAR2(255);  -- IGS_PR_RU_OU
        gv_err_ins_poc          VARCHAR2(255);  -- IGS_PR_OU_RS
        gv_err_ins_pous         VARCHAR2(255);  -- IGS_PR_OU_UNIT_SET
        gv_err_ins_popu         VARCHAR2(255);  -- IGS_PR_OU_UNIT
        gv_err_ins_popf         VARCHAR2(255);  -- IGS_PR_OU_FND
        gv_new_pra_sequence_number      IGS_PR_RU_APPL.sequence_number%TYPE;
BEGIN   -- IGS_PR_ins_copy_pra
        -- Copy a IGS_PR_RU_APPL structure. This is used when parent object
        -- such as course versions are rolled over and need new generations of these
        -- structures.
        -- The routine also makes new copies of rules which are defined as one-off
        -- within the progression rule application.
DECLARE
        v_call_again                    BOOLEAN;
        PROCEDURE prgpl_ins_poc_pous_popu(
                p_progression_rule_cat          IGS_PR_RU_APPL.progression_rule_cat%TYPE,
                p_pra_sequence_number           IGS_PR_RU_APPL.sequence_number%TYPE,
                p_pro_sequence_number           IGS_PR_RU_OU.sequence_number%TYPE,
                p_new_pra_sequence_number       IGS_PR_RU_APPL.sequence_number%TYPE,
                p_new_pro_sequence_number       IGS_PR_RU_OU.sequence_number%TYPE,
                p_message_name          IN OUT NOCOPY   IGS_PR_S_SCRATCH_PAD.MESSAGE_NAME%TYPE)
        IS
        BEGIN   -- prgpl_ins_poc
                -- Prodecdure to create new IGS_PR_OU_RS, IGS_PR_OU_UNIT_SET
                -- and IGS_PR_OU_UNIT records

                --Modified as part of Academic Standing and Progression build
                -- to add records to the IGS_PR_OU_AWD table as well
                -- amuthu 6-Dec-2001
        DECLARE
                CURSOR c_poc IS
                        SELECT  poc.course_cd
                        FROM    IGS_PR_OU_PS    poc
                        WHERE   poc.progression_rule_cat        = p_progression_rule_cat AND
                                poc.pra_sequence_number         = p_pra_sequence_number AND
                                poc.pro_sequence_number         = p_pro_sequence_number;
                CURSOR c_pous IS
                        SELECT  pous.unit_set_cd,
                                pous.us_version_number
                        FROM    IGS_PR_OU_UNIT_SET      pous
                        WHERE   pous.progression_rule_cat       = p_progression_rule_cat AND
                                pous.pra_sequence_number        = p_pra_sequence_number AND
                                pous.pro_sequence_number        = p_pro_sequence_number;

                CURSOR c_poa IS
               SELECT poa.award_cd
                           FROM   IGS_PR_OU_AWD  poa
                           WHERE  poa.progression_rule_cat = p_progression_rule_cat AND
                                  poa.pra_sequence_number  = p_pra_sequence_number AND
                                          poa.pro_sequence_number  = p_pro_sequence_number;
                CURSOR c_popu IS
                        SELECT  popu.unit_cd,
                                popu.s_unit_type
                        FROM    IGS_PR_OU_UNIT  popu
                        WHERE   popu.progression_rule_cat       = p_progression_rule_cat AND
                                popu.pra_sequence_number        = p_pra_sequence_number AND
                                popu.pro_sequence_number        = p_pro_sequence_number;
                --
                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                --
                CURSOR c_popf IS
                        SELECT  popf.fund_Code
                        FROM    IGS_PR_OU_FND   popf
                        WHERE   popf.progression_rule_cat       = p_progression_rule_cat AND
                                popf.pra_sequence_number        = p_pra_sequence_number AND
                                popf.pro_sequence_number        = p_pro_sequence_number;
                --
                -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                --

        BEGIN
                FOR v_poc_rec IN c_poc LOOP
                        BEGIN
              DECLARE
                lv_rowid VARCHAR2(25);
                l_org_id NUMBER(15);
              BEGIN
                l_org_id := igs_ge_gen_003.get_org_id;
                IGS_PR_OU_PS_PKG.INSERT_ROW (
                  X_ROWID =>LV_ROWID,
                  X_PROGRESSION_RULE_CAT =>p_progression_rule_cat,
                  X_PRA_SEQUENCE_NUMBER =>p_new_pra_sequence_number,
                  X_PRO_SEQUENCE_NUMBER =>p_new_pro_sequence_number,
                  X_COURSE_CD =>v_poc_rec.course_cd,
                  X_MODE =>'R',
                  X_ORG_ID => l_org_id
                );
              END;
                        EXCEPTION
                                WHEN OTHERS THEN
                                      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                                      FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.C_POC');
                                      IGS_GE_MSG_STACK.ADD;
                                      App_Exception.Raise_Exception;
                        END;
                END LOOP;
                FOR v_pous_rec IN c_pous LOOP
                        BEGIN

              DECLARE
                lv_rowid VARCHAR2(25);
                l_org_id NUMBER(15);
              BEGIN
                l_org_id := igs_ge_gen_003.get_org_id;
                IGS_PR_OU_UNIT_SET_PKG.INSERT_ROW (
                  X_ROWID =>LV_ROWID,
                  X_PROGRESSION_RULE_CAT =>p_progression_rule_cat,
                  X_PRA_SEQUENCE_NUMBER =>p_new_pra_sequence_number,
                  X_PRO_SEQUENCE_NUMBER =>p_new_pro_sequence_number,
                  X_UNIT_SET_CD =>v_pous_rec.unit_set_cd,
                  X_US_VERSION_NUMBER =>v_pous_rec.us_version_number,
                  X_MODE =>'R',
                  X_ORG_ID => l_org_id
                );
              END;
                EXCEPTION
                  WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.C_POUS');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                   END;
                END LOOP;



                FOR v_poa_rec IN c_poa LOOP

                  BEGIN
                    DECLARE
                          lv_rowid VARCHAR2(25);
                          l_org_id NUMBER(15);
                        BEGIN
                          l_org_id := igs_ge_gen_003.get_org_id();
                          IGS_PR_OU_AWD_PKG.INSERT_ROW (
                                X_ROWID                => lv_rowid,
                                X_PROGRESSION_RULE_CAT => p_progression_rule_cat,
                                X_PRA_SEQUENCE_NUMBER  => p_new_pra_sequence_number,
                                X_PRO_SEQUENCE_NUMBER  => p_new_pro_sequence_number,
                                X_AWARD_CD             => v_poa_rec.award_cd,
                                X_MODE                 => 'R'
                          );
                        END;
                  EXCEPTION
                    WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.C_POA');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                  END;

                END LOOP;

                FOR v_popu_rec IN c_popu LOOP
                        BEGIN
                               DECLARE
                                 lv_rowid VARCHAR2(25);
                                 l_org_id NUMBER(15);
                               BEGIN
                                 l_org_id := igs_ge_gen_003.get_org_id;
                                 IGS_PR_OU_UNIT_PKG.INSERT_ROW (
                                   X_ROWID =>LV_ROWID,
                                   X_PROGRESSION_RULE_CAT =>p_progression_rule_cat,
                                   X_PRA_SEQUENCE_NUMBER =>p_new_pra_sequence_number,
                                   X_PRO_SEQUENCE_NUMBER =>p_new_pro_sequence_number,
                                   X_UNIT_CD =>v_popu_rec.unit_cd,
                                   X_S_UNIT_TYPE =>v_popu_rec.s_unit_type,
                                   X_MODE =>'R',
                                   X_ORG_ID => l_org_id
                                   );
                               END;
                        EXCEPTION
                                WHEN OTHERS THEN
                                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.C_POPU');
                                    IGS_GE_MSG_STACK.ADD;
                                    App_Exception.Raise_Exception;
                        END;
                END LOOP;

                --
                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                --
                FOR v_popf_rec IN c_popf LOOP
                       BEGIN
                         DECLARE
                           lv_rowid VARCHAR2(25);
                         BEGIN
                           IGS_PR_OU_FND_PKG.INSERT_ROW (
                             X_ROWID => lv_rowid,
                             X_PROGRESSION_RULE_CAT =>p_progression_rule_cat,
                             X_PRA_SEQUENCE_NUMBER =>p_new_pra_sequence_number,
                             X_PRO_SEQUENCE_NUMBER =>p_new_pro_sequence_number,
                             X_FUND_CODE => v_popf_rec.fund_code,
                             X_MODE =>'R'
                             );
                         END;
                        EXCEPTION
                          WHEN OTHERS THEN
                            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                            FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.C_POPF');
                            IGS_GE_MSG_STACK.ADD;
                            App_Exception.Raise_Exception;
                       END;
                END LOOP;
                --
                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                --

        EXCEPTION
                WHEN OTHERS THEN
                        IF c_poc%ISOPEN THEN
                                CLOSE c_poc;
                        END IF;
                        IF c_pous%ISOPEN THEN
                                CLOSE c_pous;
                        END IF;
                        IF c_poa%ISOPEN THEN
                                CLOSE c_poa;
                        END IF;
                        IF c_popu%ISOPEN THEN
                                CLOSE c_popu;
                        END IF;
                        IF c_popf%ISOPEN THEN
                                CLOSE c_popf;
                        END IF;
                        RAISE;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_INS_COPY_PRA.PRGPL_INS_POC_POUS_POPU.');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
        END prgpl_ins_poc_pous_popu;

        FUNCTION prgpl_ins_copy_pra(
                p_progression_rule_cat          IGS_PR_RU_APPL.progression_rule_cat%TYPE,
                p_sequence_number               IGS_PR_RU_APPL.sequence_number%TYPE,
                p_prev_progression_rule_cat
                                                IGS_PR_RU_OU.progression_rule_cat%TYPE,
                p_prev_pra_sequence_number      IGS_PR_RU_OU.pra_sequence_number%TYPE,
                p_prev_pro_sequence_number      IGS_PR_RU_OU.sequence_number%TYPE,
                p_new_course_cd                 IGS_PR_RU_APPL.crv_course_cd%TYPE,
                p_new_version_number            IGS_PR_RU_APPL.crv_version_number%TYPE,
                p_new_org_unit_cd               IGS_PR_RU_APPL.ou_org_unit_cd%TYPE,
                p_new_ou_start_dt               IGS_PR_RU_APPL.ou_start_dt%TYPE,
                p_new_spo_person_id             IGS_PR_STDNT_PR_OU.person_id%TYPE,
                p_new_spo_course_cd             IGS_PR_STDNT_PR_OU.course_cd%TYPE,
                p_new_spo_sequence_number       IGS_PR_STDNT_PR_OU.sequence_number%TYPE,
                p_call_again                    BOOLEAN,
                p_message_name          IN OUT NOCOPY   IGS_PR_S_SCRATCH_PAD.MESSAGE_NAME%TYPE)
        RETURN NUMBER
        IS
        BEGIN   -- prgpl_ins_copy_pra
                -- This local routine performs all of the logic and inserts of
                -- IGS_PR_ins_copy_pra because in some cases we are required to
                -- call this routine again.
        DECLARE
                cst_sca                 CONSTANT        VARCHAR2(10) := 'SCA';
                cst_spo                 CONSTANT        VARCHAR2(10) := 'SPO';
                v_error_ins_pra                         BOOLEAN;
                v_error_ins_pro                         BOOLEAN;
                v_call_again                            BOOLEAN;
                v_new_rule_num                          IGS_RU_RULE.sequence_number%TYPE;
                v_pra_s_relation_type                   IGS_PR_RU_APPL.s_relation_type%TYPE;
                v_pra_progression_rule_cd               IGS_PR_RU_APPL.progression_rule_cd%TYPE;
                v_pra_rul_sequence_number               IGS_PR_RU_APPL.rul_sequence_number%TYPE;
                v_pra_attendance_type                   IGS_PR_RU_APPL.attendance_type%TYPE;
                v_pra_ou_org_unit_cd                    IGS_PR_RU_APPL.ou_org_unit_cd%TYPE;
                v_pra_ou_start_dt                       IGS_PR_RU_APPL.ou_start_dt%TYPE;
                v_pra_course_type                       IGS_PR_RU_APPL.course_type%TYPE;
                v_pra_crv_course_cd                     IGS_PR_RU_APPL.crv_course_cd%TYPE;
                v_pra_crv_version_number                IGS_PR_RU_APPL.crv_version_number%TYPE;
                v_pra_sca_person_id                     IGS_PR_RU_APPL.sca_person_id%TYPE;
                v_pra_sca_course_cd                     IGS_PR_RU_APPL.sca_course_cd%TYPE;
                v_pra_pro_progression_rule_cat
                                                        IGS_PR_RU_APPL.pro_progression_rule_cat%TYPE;
                v_pra_pro_pra_sequence_number
                                                        IGS_PR_RU_APPL.pro_pra_sequence_number%TYPE;
                v_pra_pro_sequence_number               IGS_PR_RU_APPL.pro_sequence_number%TYPE;
                v_pra_spo_person_id                     IGS_PR_RU_APPL.spo_person_id%TYPE;
                v_pra_spo_course_cd                     IGS_PR_RU_APPL.spo_course_cd%TYPE;
                v_pra_spo_sequence_number               IGS_PR_RU_APPL.spo_sequence_number%TYPE;
                v_pra_message                           IGS_PR_RU_APPL.message%TYPE;
                v_pra_reference_cd                      IGS_PR_RU_APPL.reference_cd%TYPE;
                v_s_rule_call_cd                        IGS_PR_RU_CAT.s_rule_call_cd%TYPE;
                v_new_pra_sequence_number               IGS_PR_RU_APPL.sequence_number%TYPE;
                v_new_pro_sequence_number               IGS_PR_RU_OU.sequence_number%TYPE;
                v_rul_sequence_number                   IGS_PR_RU_APPL.rul_sequence_number%TYPE;
                v_progression_rule_cat                  IGS_PR_RU_APPL.progression_rule_cat%TYPE;
                v_sequence_number                       IGS_PR_RU_APPL.sequence_number%TYPE;
                CURSOR c_pra IS
                        SELECT  pra.s_relation_type,
                                pra.progression_rule_cd,
                                pra.rul_sequence_number,
                                pra.attendance_type,
                                pra.ou_org_unit_cd,
                                pra.ou_start_dt,
                                pra.course_type,
                                pra.crv_course_cd,
                                pra.crv_version_number,
                                pra.sca_person_id,
                                pra.sca_course_cd,
                                pra.pro_progression_rule_cat,
                                pra.pro_pra_sequence_number,
                                pra.pro_sequence_number,
                                pra.spo_person_id,
                                pra.spo_course_cd,
                                pra.spo_sequence_number,
                                pra.message,
                                pra.reference_cd
                        FROM    IGS_PR_RU_APPL  pra
                        WHERE   pra.progression_rule_cat        = p_progression_rule_cat AND
                                pra.sequence_number             = p_sequence_number AND
                                pra.logical_delete_dt           IS NULL;
                CURSOR c_prgc IS
                        SELECT  prgc.s_rule_call_cd
                        FROM    IGS_PR_RU_CAT   prgc
                        WHERE   prgc.progression_rule_cat       = p_progression_rule_cat;
                CURSOR c_pra_sequence_number IS
                        SELECT  IGS_PR_PRA_SEQUENCE_NO_S.NEXTVAL
                        FROM    dual;
                CURSOR c_pro_sequence_number IS
--gjha Changed the sequence fromPRA to PRO.

                        SELECT  IGS_PR_PRO_SEQUENCE_NO_S.NEXTVAL
                        FROM    dual;
                -- Retrieve child of old IGS_PR_RU_APPL record
                CURSOR c_prrc IS
                        SELECT  prrc.prg_cal_type,
                                prrc.start_sequence_number,
                                prrc.end_sequence_number,
                                prrc.start_effective_period,
                                prrc.num_of_applications
                        FROM    IGS_PR_RU_CA_TYPE       prrc
                        WHERE   prrc.progression_rule_cat       = p_progression_rule_cat AND
                                prrc.pra_sequence_number        = p_sequence_number;
                -- Retrieve child of old IGS_PR_RU_APPL record
                CURSOR c_pro IS
                        SELECT  pro.sequence_number,
                                pro.number_of_failures,
                                pro.progression_outcome_type,
                                pro.apply_automatically_ind,
                                pro.prg_rule_repeat_fail_type,
                                pro.override_show_cause_ind,
                                pro.override_appeal_ind,
                                pro.duration,
                                pro.duration_type,
                                pro.rank,
                                pro.encmb_course_group_cd,
                                pro.restricted_enrolment_cp,
                                pro.restricted_attendance_type,
                                pro.comments
                        FROM    IGS_PR_RU_OU    pro
                        WHERE   pro.progression_rule_cat        = p_progression_rule_cat AND
                                pro.pra_sequence_number         = p_sequence_number AND
                                -- anilk, bug#2784198
																pro.logical_delete_dt IS NULL;
                CURSOR c_pra_check_pro (
                        cp_pro_progression_rule_cat
                                                        IGS_PR_RU_OU.progression_rule_cat%TYPE,
                        cp_pro_pra_sequence_number      IGS_PR_RU_OU.pra_sequence_number%TYPE,
                        cp_pro_sequence_number          IGS_PR_RU_OU.sequence_number%TYPE) IS
                        SELECT  pra.progression_rule_cat,
                                pra.sequence_number
                        FROM    IGS_PR_RU_APPL  pra
                        WHERE   pra.pro_progression_rule_cat    = cp_pro_progression_rule_cat AND
                                pra.pro_pra_sequence_number     = cp_pro_pra_sequence_number AND
                                pra.pro_sequence_number         = cp_pro_sequence_number;
        BEGIN
                -- varaibles to determine if child records can be created
                v_error_ins_pra := FALSE;
                v_error_ins_pro := FALSE;
                v_call_again := p_call_again;
                -- Select detail from specified record
                OPEN c_pra;
                FETCH c_pra INTO        v_pra_s_relation_type,
                                        v_pra_progression_rule_cd,
                                        v_pra_rul_sequence_number,
                                        v_pra_attendance_type,
                                        v_pra_ou_org_unit_cd,
                                        v_pra_ou_start_dt,
                                        v_pra_course_type,
                                        v_pra_crv_course_cd,
                                        v_pra_crv_version_number,
                                        v_pra_sca_person_id,
                                        v_pra_sca_course_cd,
                                        v_pra_pro_progression_rule_cat,
                                        v_pra_pro_pra_sequence_number,
                                        v_pra_pro_sequence_number,
                                        v_pra_spo_person_id,
                                        v_pra_spo_course_cd,
                                        v_pra_spo_sequence_number,
                                        v_pra_message,
                                        v_pra_reference_cd;
                IF c_pra%NOTFOUND THEN
                        CLOSE c_pra;
                        RETURN NULL;
                END IF;
                CLOSE c_pra;
                -- If illogical org unit parameters against record abort
                IF p_new_org_unit_cd IS NOT NULL AND
                                v_pra_ou_org_unit_cd IS NULL THEN
                        RETURN NULL;
                END IF;
                -- If illogical course version parameters against record abort
                IF p_new_course_cd IS NOT NULL AND
                                v_pra_crv_course_cd IS NULL THEN
                        RETURN NULL;
                END IF;
                IF v_pra_rul_sequence_number IS NOT NULL THEN
                        OPEN c_prgc;
                        FETCH c_prgc INTO v_s_rule_call_cd;
                        CLOSE c_prgc;
                        BEGIN
                                v_new_rule_num := IGS_RU_GEN_003.RULP_INS_COPY_RULE(
                                                                v_s_rule_call_cd,
                                                                v_pra_rul_sequence_number);
                        EXCEPTION
                                WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_INS_COPY_PRA.RULE_COPY');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                        END;
                END IF;
                OPEN c_pra_sequence_number;
                FETCH c_pra_sequence_number INTO gv_new_pra_sequence_number;
                CLOSE c_pra_sequence_number;
                -- If not called recursively
                IF v_call_again THEN
                        IF p_new_course_cd IS NOT NULL THEN
                                v_pra_crv_course_cd := p_new_course_cd;
                                v_pra_crv_version_number := p_new_version_number;
                        END IF;
                        IF p_new_org_unit_cd IS NOT NULL THEN
                                v_pra_ou_org_unit_cd := p_new_org_unit_cd;
                                v_pra_ou_start_dt := p_new_ou_start_dt;
                        END IF;
                        IF p_new_spo_person_id IS NOT NULL AND
                                        p_new_sca_person_id IS NULL THEN
                                v_pra_s_relation_type := cst_spo;
                                v_pra_spo_person_id := p_new_spo_person_id;
                                v_pra_spo_course_cd := p_new_spo_course_cd;
                                v_pra_spo_sequence_number := p_new_spo_sequence_number;
                                v_pra_pro_progression_rule_cat := NULL;
                                v_pra_pro_pra_sequence_number := NULL;
                                v_pra_pro_sequence_number := NULL;
                        END IF;
                        IF p_new_sca_person_id IS NOT NULL THEN
                                v_pra_s_relation_type := cst_sca;
                                v_pra_sca_person_id := p_new_sca_person_id;
                                v_pra_sca_course_cd := p_new_sca_course_cd;
                                v_pra_spo_person_id := p_new_spo_person_id;
                                v_pra_spo_course_cd := p_new_spo_course_cd;
                                v_pra_spo_sequence_number := p_new_spo_sequence_number;
                        END IF;
                ELSE
                        -- set pro_sequence_number to pro_sequence_number found before the
                        -- function was called again.
                        v_pra_pro_progression_rule_cat  := p_prev_progression_rule_cat;
                        v_pra_pro_pra_sequence_number   := p_prev_pra_sequence_number;
                        v_pra_pro_sequence_number       := p_prev_pro_sequence_number;
                END IF;
                IF v_pra_rul_sequence_number IS NOT NULL THEN
                        v_pra_rul_sequence_number := v_new_rule_num;
                END IF;
                BEGIN
                                DECLARE
                                lv_rowid VARCHAR2(25);
                                l_org_id NUMBER(15);
                                BEGIN
                                l_org_id := igs_ge_gen_003.get_org_id;
                                IGS_PR_RU_APPL_PKG.INSERT_ROW (
                                  X_ROWID =>LV_ROWID,
                                  X_PROGRESSION_RULE_CAT =>p_progression_rule_cat,
                                  X_SEQUENCE_NUMBER =>gv_new_pra_sequence_number,
                                  X_S_RELATION_TYPE =>v_pra_s_relation_type,
                                  X_PROGRESSION_RULE_CD =>v_pra_progression_rule_cd,
                                  X_REFERENCE_CD =>v_pra_reference_cd,
                                  X_RUL_SEQUENCE_NUMBER =>v_pra_rul_sequence_number,
                                  X_ATTENDANCE_TYPE =>v_pra_attendance_type,
                                  X_OU_ORG_UNIT_CD =>v_pra_ou_org_unit_cd,
                                  X_OU_START_DT =>v_pra_ou_start_dt,
                                  X_COURSE_TYPE =>v_pra_course_type,
                                  X_CRV_COURSE_CD =>v_pra_crv_course_cd,
                                  X_CRV_VERSION_NUMBER =>v_pra_crv_version_number,
                                  X_SCA_PERSON_ID =>v_pra_sca_person_id,
                                  X_SCA_COURSE_CD =>v_pra_sca_course_cd,
                                  X_PRO_PROGRESSION_RULE_CAT =>v_pra_pro_progression_rule_cat,
                                  X_PRO_PRA_SEQUENCE_NUMBER =>v_pra_pro_pra_sequence_number,
                                  X_PRO_SEQUENCE_NUMBER =>v_pra_pro_sequence_number,
                                  X_SPO_PERSON_ID =>v_pra_spo_person_id,
                                  X_SPO_COURSE_CD =>v_pra_spo_course_cd,
                                  X_SPO_SEQUENCE_NUMBER =>v_pra_spo_sequence_number,
                                  X_LOGICAL_DELETE_DT =>NULL,
                                  X_MESSAGE =>v_pra_message,
                                  X_MODE =>'R',
                                  X_ORG_ID => l_org_id
                                  );
                                  END;
                EXCEPTION
                        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_INS_COPY_PRA.INESRT_RULE_APPL');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                END;
                IF v_error_ins_pra = FALSE THEN
                        FOR v_prrc_rec IN c_prrc LOOP
                                BEGIN
                                                DECLARE
                                                lv_rowid VARCHAR2(25);
                                                l_org_id NUMBER(15);
                                                BEGIN
                                                l_org_id := igs_ge_gen_003.get_org_id;
                                                IGS_PR_RU_CA_TYPE_PKG.INSERT_ROW (
                                                  X_ROWID =>LV_ROWID,
                                                  X_PROGRESSION_RULE_CAT =>p_progression_rule_cat,
                                                  X_PRA_SEQUENCE_NUMBER=> gv_new_pra_sequence_number,
                                                  X_PRG_CAL_TYPE =>v_prrc_rec.prg_cal_type,
                                                  X_START_SEQUENCE_NUMBER =>v_prrc_rec.start_sequence_number,
                                                  X_END_SEQUENCE_NUMBER =>v_prrc_rec.end_sequence_number,
                                                  X_START_EFFECTIVE_PERIOD =>v_prrc_rec.start_effective_period,
                                                  X_NUM_OF_APPLICATIONS =>v_prrc_rec.num_of_applications,
                                                  X_MODE =>'R',
                                                  X_ORG_ID => l_org_id
                                                  );
                                                  END;
                                EXCEPTION
                                        WHEN OTHERS THEN
                                            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                                            FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_INS_COPY_PRA.INSERT_RU_CA');
                                            IGS_GE_MSG_STACK.ADD;
                                            App_Exception.Raise_Exception;
                                END;
                        END LOOP;
                        FOR v_pro_rec IN c_pro LOOP
                                OPEN c_pro_sequence_number;
--Gjha Changed from c_pra_sequence_number
                                FETCH c_pro_sequence_number INTO v_new_pro_sequence_number;
                                CLOSE c_pro_sequence_number;
                                BEGIN
                                                DECLARE
                                                lv_rowid VARCHAR2(25);
                                                l_org_id NUMBER(15);
                                                BEGIN
                                                l_org_id := igs_ge_gen_003.get_org_id;
                                                IGS_PR_RU_OU_pkg.INSERT_ROW (
                                                  X_ROWID =>lv_rowid,
                                                  X_PROGRESSION_RULE_CAT=> p_progression_rule_cat,
                                                  X_PRA_SEQUENCE_NUMBER=> gv_new_pra_sequence_number,
                                                  X_SEQUENCE_NUMBER =>v_new_pro_sequence_number,
                                                  X_NUMBER_OF_FAILURES =>v_pro_rec.number_of_failures,
                                                  X_PROGRESSION_OUTCOME_TYPE =>v_pro_rec.progression_outcome_type,
                                                  X_APPLY_AUTOMATICALLY_IND =>v_pro_rec.apply_automatically_ind,
                                                  X_PRG_RULE_REPEAT_FAIL_TYPE =>v_pro_rec.prg_rule_repeat_fail_type,
                                                  X_OVERRIDE_SHOW_CAUSE_IND =>v_pro_rec.override_show_cause_ind,
                                                  X_OVERRIDE_APPEAL_IND =>v_pro_rec.override_appeal_ind,
                                                  X_DURATION =>v_pro_rec.duration,
                                                  X_DURATION_TYPE =>v_pro_rec.duration_type,
                                                  X_RANK => v_pro_rec.rank,
                                                  X_ENCMB_COURSE_GROUP_CD =>v_pro_rec.encmb_course_group_cd,
                                                  X_RESTRICTED_ENROLMENT_CP =>v_pro_rec.restricted_enrolment_cp,
                                                  X_RESTRICTED_ATTENDANCE_TYPE =>v_pro_rec.restricted_attendance_type,
                                                  X_COMMENTS =>v_pro_rec.comments,
                                                  X_MODE =>'R',
                                                  X_ORG_ID => l_org_id
                                                  );
                                                  END;
                                EXCEPTION
                                        WHEN OTHERS THEN
                                                v_error_ins_pro := TRUE;
                                                gv_err_ins_pro  := 'IGS_PR_RU_OU ';
                                                IF (SQLCODE >= gcst_max_error_range AND
                                                                SQLCODE <= gcst_min_error_range) THEN
                                                        p_message_name := gcst_ret_message_num;
                                                ELSE
                                                        RAISE;
                                                END IF;
                                END;
                                -- Where existing, copy IGS_PR_OU_RS, IGS_PR_OU_UNIT_SET and
                                -- IGS_PR_OU_UNIT records, moving from the old to new pro record
                                IF v_error_ins_pro = FALSE THEN
                                        prgpl_ins_poc_pous_popu(
                                                        p_progression_rule_cat,
                                                        p_sequence_number,              -- old pra_sequence_number
                                                        v_pro_rec.sequence_number,      -- old
                                                        gv_new_pra_sequence_number,
                                                        v_new_pro_sequence_number,
                                                        p_message_name);                        -- IN OUT NOCOPY
                                ELSE
                                        gv_err_ins_poc  := 'IGS_PR_OU_RS ';
                                        gv_err_ins_pous := 'IGS_PR_OU_UNIT_SET ';
                                        gv_err_ins_popu := 'IGS_PR_OU_UNIT ';
                                END IF;
                                OPEN c_pra_check_pro (
                                                p_progression_rule_cat,
                                                p_sequence_number,
                                                v_pro_rec.sequence_number);
                                FETCH c_pra_check_pro INTO      v_progression_rule_cat,
                                                                v_sequence_number;
                                IF c_pra_check_pro%FOUND THEN
                                        CLOSE c_pra_check_pro;
                                -- Perform entire logic again
                                -- Only do this one level deep - do not recurse.
                                        IF v_call_again THEN
                                                IF v_progression_rule_cat IS NOT NULL AND
                                                                v_sequence_number IS NOT NULL THEN
                                                        v_call_again := FALSE;
                                                        v_new_pra_sequence_number := prgpl_ins_copy_pra (
                                                                                        v_progression_rule_cat,
                                                                                        v_sequence_number,
                                                                                        p_progression_rule_cat,
                                                                                        gv_new_pra_sequence_number,
                                                                                        v_new_pro_sequence_number,
                                                                                        p_new_course_cd,
                                                                                        p_new_version_number,
                                                                                        p_new_org_unit_cd,
                                                                                        p_new_ou_start_dt,
                                                                                        p_new_spo_person_id,
                                                                                        p_new_spo_course_cd,
                                                                                        p_new_spo_sequence_number,
                                                                                        v_call_again,
                                                                                        p_message_name); -- IN OUT NOCOPY
                                                        IF v_new_pra_sequence_number IS NOT NULL THEN
                                                                gv_new_pra_sequence_number := v_new_pra_sequence_number;
                                                        END IF;
                                                        v_call_again := TRUE;
                                                END IF;
                                        END IF;
                                ELSE
                                        CLOSE c_pra_check_pro;
                                END IF;
                        END LOOP;
                ELSE
                        -- Records cannot be inserted because a new IGS_PR_RU_APPL
                        -- record was not created.
                        gv_err_ins_prrc := 'IGS_PR_RU_CA_TYPE ';
                        gv_err_ins_pro  := 'IGS_PR_RU_OU ';
                        gv_err_ins_poc  := 'IGS_PR_OU_RS ';
                        gv_err_ins_pous := 'IGS_PR_OU_UNIT_SET ';
                        gv_err_ins_popu := 'IGS_PR_OU_UNIT ';
                        gv_err_ins_popf := 'IGS_PR_OU_FND';
                END IF;
                RETURN gv_new_pra_sequence_number;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_pra%ISOPEN THEN
                                CLOSE c_pra;
                        END IF;
                        IF c_prgc%ISOPEN THEN
                                CLOSE c_prgc;
                        END IF;
                        IF c_pra_sequence_number%ISOPEN THEN
                                CLOSE c_pra_sequence_number;
                        END IF;
                        IF c_pro_sequence_number%ISOPEN THEN
                                CLOSE c_pro_sequence_number;
                        END IF;
                        IF c_prrc%ISOPEN THEN
                                CLOSE c_prrc;
                        END IF;
                        IF c_pro%ISOPEN THEN
                                CLOSE c_pro;
                        END IF;
                        IF c_pra_check_pro%ISOPEN THEN
                                CLOSE c_pra_check_pro;
                        END IF;
                        RAISE;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_INS_COPY_PRA.PRGPL_INS_COPY_PRA');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
        END prgpl_ins_copy_pra;
BEGIN
        --kdande; 19-Jul-2002; Bug# 2462120; Changed the message name from 300 to IGS_PS_SUCCESS_COPY_PRGVER
        p_message_name := 'IGS_PS_SUCCESS_COPY_PRGVER';
        v_call_again := TRUE;
        gv_new_pra_sequence_number := prgpl_ins_copy_pra (
                                                p_progression_rule_cat,
                                                p_sequence_number,
                                                NULL, -- p_prev_progression_rule_cat
                                                NULL, -- p_prev_pra_sequence_number
                                                NULL, -- p_prev_pro_sequence_number
                                                p_new_course_cd,
                                                p_new_version_number,
                                                p_new_org_unit_cd,
                                                p_new_ou_start_dt,
                                                p_new_spo_person_id,
                                                p_new_spo_course_cd,
                                                p_new_spo_sequence_number,
                                                v_call_again,
                                                p_message_name);                -- IN OUT NOCOPY
        IF gv_err_ins_rule IS NOT NULL OR
                        gv_err_ins_pra IS NOT NULL OR
                        gv_err_ins_prrc IS NOT NULL OR
                        gv_err_ins_pro IS NOT NULL OR
                        gv_err_ins_poc IS NOT NULL OR
                        gv_err_ins_pous IS NOT NULL OR
                        gv_err_ins_popf IS NOT NULL OR
                        gv_err_ins_popu IS NOT NULL THEN
                gv_err_inserting := 'Creation OF NEW records failed FOR the '
                                        || 'following TABLES :'
                                        || gv_err_ins_rule
                                        || gv_err_ins_pra
                                        || gv_err_ins_prrc
                                        || gv_err_ins_pro
                                        || gv_err_ins_poc
                                        || gv_err_ins_pous
                                        || gv_err_ins_popf
                                        || gv_err_ins_popu;
        END IF;
        RETURN gv_new_pra_sequence_number;
END;
EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_INS_COPY_PRA');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
END IGS_PR_ins_copy_pra;

FUNCTION IGS_PR_INS_SSP_CMP_DTL(
  p_rule_text IN VARCHAR2 ,
  p_message_text IN VARCHAR2 ,
  p_log_dt IN DATE ,
  p_key IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
        gv_other_detail                 VARCHAR2(255);
BEGIN   -- IGS_PR_ins_ssp_cmp_dtl
        -- This routine is used by the functionality associated with the form PRGF9030
        -- Inquire On Student Completion. The form displays the completion rules
        -- associated with a course. This routine is called to break up the text
        -- fields returned from the Rule system. It will store them into a temporary
        -- table where the data will be queried and displayed by the form. This
        -- routine may be called by other modules, such as routines associated
        -- with a report.
DECLARE
        v_loop_count                    NUMBER(4);
        v_rstart                        NUMBER(4);
        v_mstart                        NUMBER(4);
        v_rend                          NUMBER(4);
        v_mend                          NUMBER(4);
        v_sub_rule_text                 IGS_RU_NAMED_RULE.rule_text%TYPE;
        v_sub_message_text              IGS_RU_NAMED_RULE.rule_text%TYPE;
        v_fail_text_separator_posn      NUMBER(4);
        v_rule_result                   IGS_RU_NAMED_RULE.rule_text%TYPE;
        v_rule_fail_text                        IGS_RU_NAMED_RULE.rule_text%TYPE;
        v_ssp_sequence_number           IGS_PR_s_scratch_pad.sequence_number%TYPE;
BEGIN
        -- set the default message number
        p_message_name := NULL;
        --Initialise a counter as a safety check that an infinite loop does not occur.
        --(4000 has chosen as the current maximum length of a VARCHAR2 field.)
        v_loop_count := 0;
        --Initialise place holders
        v_rstart := 1;
        v_mstart := 1;
        LOOP
                v_loop_count := v_loop_count + 1;
                IF v_loop_count > 4000 THEN
--                      p_message_name := 5199;
                        p_message_name := 'IGS_PR_INTERNAL_ERR';
                        EXIT;
                END IF;
        -- Determine if the rule text and rule messages need to be split up.
        -- The rules and messages are separated by carriage returns.
        v_rend  := INSTR(p_rule_text, fnd_global.local_chr(10), v_rstart);
        v_mend  := INSTR(p_message_text, fnd_global.local_chr(10), v_mstart);
        IF v_rend = 0 THEN
                v_sub_rule_text         := SUBSTR(p_rule_text, v_rstart);
                v_sub_message_text      := SUBSTR(p_message_text, v_mstart);
                                                                                --Get the substring of the rule and message text fields.
        ELSE
                v_sub_rule_text         := SUBSTR(p_rule_text, v_rstart, v_rend - v_rstart);
                v_sub_message_text      := SUBSTR(p_message_text, v_mstart, v_mend - v_mstart);
                                                                                --There are more carriage returns in the string, hence, determine a
        END IF;                                                                 --substring of the rule and message text fields.
        --Determine if the separator exists '::' in the message. The separator is used
        --to identify the rule result and the message.
        v_fail_text_separator_posn := INSTR(v_sub_message_text, '::');
        IF v_fail_text_separator_posn > 0 THEN
                                                        --The separator exists, split the result from the message.
                v_rule_result           := SUBSTR(v_sub_message_text, 1,
                                                        v_fail_text_separator_posn - 1);
                v_rule_fail_text        := SUBSTR(v_sub_message_text,
                                                        v_fail_text_separator_posn + 2);
        ELSE
                v_rule_result :=  v_sub_message_text;
                v_rule_fail_text := NULL;
        END IF;
        -- Insert the values into the s_scratch_pad table (similar to the s_log_entry).
        IGS_PR_GEN_003.IGS_PR_INS_SSP(
                p_log_dt,
                p_key ,
                NULL,
                v_sub_rule_text || '|' ||
                v_rule_result || '|' ||
                v_rule_fail_text,
                v_ssp_sequence_number);
        --Check if at the end of the string
        IF v_rend = 0 THEN
                EXIT;
        ELSE
                v_rstart := v_rend + 1;
                v_mstart := v_mend + 1;
        END IF;
        END LOOP;
        -- Check the result of the processing.
        IF p_message_name <> NULL THEN
                RETURN FALSE;
        ELSE
                RETURN TRUE;
        END IF;
END;
EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_INS_SSP_CMP_DTL');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
END IGS_PR_ins_ssp_cmp_dtl;


FUNCTION IGS_PR_upd_pen_clash(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_spo_sequence_number IN NUMBER ,
  p_application_type IN VARCHAR2 ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  p_message_level OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
        gv_other_detail                 VARCHAR2(255);
        v_message_text2                 VARCHAR2(200);
BEGIN   -- IGS_PR_upd_pen_clash
        -- Get whether a clash exists between progression based encumbrance effects
        -- against a course and those trying to be applied.
        -- This routine returns a message number and one of three return types :
        -- WARNING      : Report the message as a warning and proceed with application.
        -- BLOCK        : Report the message as an error and do not proceed with the
        --                application.
        -- EXPIRED      : Report the message as a warning - the process has expired an
        --                outcome to  resolve a clash.
        -- ERROR        : Report the message as an error - this indicates locking problems.
DECLARE
        cst_batch       CONSTANT        VARCHAR2(10) := 'BATCH';
        cst_manual      CONSTANT        VARCHAR2(10) := 'MANUAL';
        cst_approved    CONSTANT        VARCHAR2(10) := 'APPROVED';
        cst_expired     CONSTANT        VARCHAR2(10) := 'EXPIRED';
        cst_block       CONSTANT        VARCHAR2(10) := 'BLOCK';
        cst_error               CONSTANT        VARCHAR2(10) := 'ERROR';
        cst_expire      CONSTANT        VARCHAR2(10) := 'EXPIRE';
        cst_ok          CONSTANT        VARCHAR2(10) := 'OK';
        cst_warning     CONSTANT        VARCHAR2(10) := 'WARNING';
        cst_rstr_ge_cp  CONSTANT        VARCHAR2(10) := 'RSTR_GE_CP';
        cst_rstr_le_cp  CONSTANT        VARCHAR2(10) := 'RSTR_LE_CP';
        cst_rstr_at_ty  CONSTANT        VARCHAR2(10) := 'RSTR_AT_TY';
        cst_sus_course  CONSTANT        VARCHAR2(10) := 'SUS_COURSE';
        cst_exc_course  CONSTANT        VARCHAR2(10) := 'EXC_COURSE';
        cst_exc_crs_gp  CONSTANT        VARCHAR2(10) := 'EXC_CRS_GP';
        cst_exc_crs_us  CONSTANT        VARCHAR2(10) := 'EXC_CRS_US';
        cst_exc_crs_u   CONSTANT        VARCHAR2(10) := 'EXC_CRS_U';
        cst_rqrd_crs_u  CONSTANT        VARCHAR2(10) := 'RQRD_CRS_U';
        cst_message_len CONSTANT        INTEGER := 255;
        e_record_locked                 EXCEPTION;
        PRAGMA EXCEPTION_INIT (e_record_locked, -54);
        v_message_text1                 VARCHAR2(255) DEFAULT NULL;
        v_message_text2                 VARCHAR2(255) DEFAULT NULL;
        v_message_level                 VARCHAR2(10) DEFAULT NULL;
        v_encumbrance_type              igs_pr_ou_type.encumbrance_type%TYPE;
        v_spo_expiry_dt                 IGS_PR_STDNT_PR_OU.expiry_dt%TYPE;
        v_unresolved_clash              BOOLEAN DEFAULT FALSE;
        v_clash_type                    VARCHAR2(10);
        v_expire                        BOOLEAN;
        v_warning                       BOOLEAN;
        v_dummy                         VARCHAR2(1);
        CURSOR c_spo1 IS
                SELECT  pot.encumbrance_type
                FROM    IGS_PR_STDNT_PR_OU      spo,
                        igs_pr_ou_type  pot
                WHERE   spo.person_id                   = p_person_id AND
                        spo.course_cd                   = p_course_cd AND
                        spo.sequence_number             = p_spo_sequence_number AND
                        pot.progression_outcome_type    = spo.progression_outcome_type;
        CURSOR c_spo2 IS
                SELECT  spo.sequence_number,
                        spo.progression_outcome_type,
                        spo.expiry_dt,
                        pot.encumbrance_type
                FROM    IGS_PR_STDNT_PR_OU      spo,
                        igs_pr_ou_type  pot
                WHERE   spo.person_id                   = p_person_id AND
                        spo.course_cd                   = p_course_cd AND
                        spo.sequence_number             <> p_spo_sequence_number AND
                        spo.decision_status             = cst_approved AND
                        pot.progression_outcome_type    = spo.progression_outcome_type AND
                        pot.encumbrance_type            IS NOT NULL AND
                        IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY (
                                p_person_id,
                                p_course_cd,
                                spo.sequence_number,
                                spo.expiry_dt)          <> cst_expired;
        CURSOR c_pee (
                cp_encumbrance_type     igs_pr_ou_type.encumbrance_type%TYPE) IS
                SELECT  'X'
                FROM    IGS_PE_PERSENC_EFFCT            pee,
                        IGS_PE_PERS_ENCUMB              pen
                WHERE   pen.person_id           = p_person_id AND
                        pen.spo_course_cd       IS NULL AND
                        (pen.expiry_dt          IS NULL OR
                         pen.expiry_dt           > TRUNC(SYSDATE)) AND
                        pee.person_id           = pen.person_id AND
                        pee.encumbrance_type    = pen.encumbrance_type AND
                        pee.pen_start_dt                = pen.start_dt AND
                        (pee.expiry_dt          IS NULL OR
                         pee.expiry_dt          > TRUNC(SYSDATE)) AND
                        pee.s_encmb_effect_type IN
                        (
                        SELECT  s_encmb_effect_type
                        FROM    igs_fi_enc_dflt_eft     etde
                        WHERE   etde.encumbrance_type   = cp_encumbrance_type);
        CURSOR c_spo_expire (
                cp_spo_sequence_number          IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
                SELECT  spo.*, spo.ROWID
                FROM    IGS_PR_STDNT_PR_OU      spo
                WHERE   spo.person_id                   = p_person_id AND
                        spo.course_cd                   = p_course_cd AND
                        spo.sequence_number             = cp_spo_sequence_number
                FOR UPDATE NOWAIT;

    v_spo_expire_rec  c_spo_expire%ROWTYPE;
        CURSOR c_edte (
                cp_encumbrance_type             igs_pr_ou_type.encumbrance_type%TYPE) IS
                SELECT  edte.s_encmb_effect_type
                FROM    igs_fi_enc_dflt_eft             edte
                WHERE   edte.encumbrance_type           = cp_encumbrance_type AND
                                edte.s_encmb_effect_type        IN (
                                                        cst_sus_course,
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_exc_crs_us,
                                                        cst_exc_crs_u,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp);
        CURSOR c_pen_pee (
                cp_spo_sequence_number          IGS_PR_STDNT_PR_OU.sequence_number%TYPE,
                cp_spo_expiry_dt                        IGS_PR_STDNT_PR_OU.expiry_dt%TYPE) IS
                SELECT  pee.s_encmb_effect_type
                FROM    IGS_PE_PERS_ENCUMB              pen,
                        IGS_PE_PERSENC_EFFCT    pee
                WHERE   pen.person_id                   = p_person_id AND
                        pen.spo_course_cd               = p_course_cd AND
                        pen.spo_sequence_number         = cp_spo_sequence_number AND
                        pen.person_id                   = pee.person_id AND
                        pen.encumbrance_type            = pee.encumbrance_type AND
                        pen.start_dt                    = pee.pen_start_dt AND
                        pee.s_encmb_effect_type         IN (
                                                        cst_sus_course,
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_exc_crs_us,
                                                        cst_exc_crs_u,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) AND
                        (
                        ( pee.expiry_dt IS NOT NULL AND
                           pee.expiry_dt > TRUNC(SYSDATE)) OR
                        (  pee.expiry_dt IS NULL AND
                           IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY (
                                p_person_id,
                                p_course_cd,
                                cp_spo_sequence_number,
                                cp_spo_expiry_dt)       <> cst_expired)
                        );
        FUNCTION prgpl_upd_pen_check_clash (
                p_old_effect                    IGS_EN_ENCMB_EFCTTYP_V.s_encmb_effect_type%TYPE,
                p_new_effect                    IGS_EN_ENCMB_EFCTTYP_V.s_encmb_effect_type%TYPE)
        RETURN VARCHAR2
        IS
                gvl_other_detail                VARCHAR2(255);
        BEGIN   -- prgpl_upd_pen_check_clash
        BEGIN
                IF p_old_effect = cst_sus_course THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_block;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp) THEN
                                        RETURN cst_expire;
                                ELSIF p_new_effect IN (
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_block;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_rstr_at_ty THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_block;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_rqrd_crs_u) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_block;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_rqrd_crs_u THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp) THEN
                                        RETURN cst_expire;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_exc_crs_u THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_ok;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_ok;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_exc_course THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_sus_course) THEN
                                        RETURN cst_block;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_sus_course) THEN
                                        RETURN cst_block;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_exc_crs_gp THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp) THEN
                                        RETURN cst_block;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp) THEN
                                        RETURN cst_block;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_exc_crs_us THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_ok;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u,
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp,
                                                        cst_sus_course) THEN
                                        RETURN cst_ok;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_rstr_ge_cp THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_block;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_block;
                                END IF;
                        END IF;
                ELSIF p_old_effect = cst_rstr_le_cp THEN
                        IF p_application_type = cst_manual THEN
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_block;
                                END IF;
                        ELSE    -- batch process
                                IF p_new_effect IN (
                                                        cst_exc_crs_u,
                                                        cst_exc_crs_us,
                                                        cst_rqrd_crs_u) THEN
                                        RETURN cst_ok;
                                ELSIF p_new_effect IN (
                                                        cst_exc_course,
                                                        cst_exc_crs_gp,
                                                        cst_sus_course) THEN
                                        RETURN cst_warning;
                                ELSIF p_new_effect IN (
                                                        cst_rstr_at_ty,
                                                        cst_rstr_ge_cp,
                                                        cst_rstr_le_cp) THEN
                                        RETURN cst_block;
                                END IF;
                        END IF;
                END IF;
                RETURN cst_ok;
        END;
        EXCEPTION
                WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_UPD_PEN_CLASH.PRGPL_UPD_PEN_CHECK_CLASH');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
        END prgpl_upd_pen_check_clash;
BEGIN
        -- Initialise output parameters
        p_message_level := NULL;
        p_message_text := NULL;
        SAVEPOINT sp_before_check;
        OPEN c_spo1;
        FETCH c_spo1 INTO v_encumbrance_type;
        IF c_spo1%NOTFOUND THEN
                CLOSE c_spo1;
                -- No match - return with no error ; problem with calling routine
                RETURN TRUE;
        ELSE
                CLOSE c_spo1;
                IF v_encumbrance_type IS NULL THEN
                        -- No encumbrances to apply ; no possible clashes
                        RETURN TRUE;
                END IF;
        END IF;
        -- Check for non-progression encumbrances containing same effect types.
        OPEN c_pee (v_encumbrance_type);
        FETCH c_pee INTO v_dummy;
        IF c_pee%FOUND THEN
                CLOSE c_pee;
        --      p_message_text := IGS_GE_GEN_002.GENP_GET_MESSAGE(5605);
                p_message_level := cst_error;
                RETURN FALSE;
        ELSE
                CLOSE c_pee;
        END IF;
        -- Select other progression outcomes that are currently active and are
        -- related to encumbrances
        FOR v_spo2_rec IN c_spo2 LOOP
                v_expire := FALSE;
                v_warning := FALSE;
                -- Loop through the effects that are to be applied. Only effect types
                -- that can potentially clash are tested.
                FOR v_edte_rec IN c_edte (v_encumbrance_type) LOOP
                        FOR v_pen_pee_rec IN c_pen_pee (
                                                        v_spo2_rec.sequence_number,
                                                        v_spo2_rec.expiry_dt) LOOP
                                -- Check for a clash
                                v_clash_type := prgpl_upd_pen_check_clash (
                                                                        v_pen_pee_rec.s_encmb_effect_type,
                                                                        v_edte_rec.s_encmb_effect_type);
                                IF v_clash_type = cst_block THEN
                                        IF p_application_type = cst_manual THEN

                                                -- Modified by Prajeesh on 08-Jul-2002
                                                -- Previously it was hardcoded and hence it was not NLS Complaint
                                                -- Now it is registered in Messages and messages are called instead of hardcoded values
                                                FND_MESSAGE.SET_NAME('IGS','IGS_PR_ENC_MAN_BLOCK_TYP');
                                                FND_MESSAGE.SET_TOKEN('OUT_TYP',v_spo2_rec.progression_outcome_type);
                                                IGS_GE_MSG_STACK.ADD;
                                                v_message_text1 := FND_MESSAGE.GET;

                                        ELSE
                                                -- Modified by Prajeesh on 08-Jul-2002
                                                -- Previously it was hardcoded and hence it was not NLS Complaint
                                                -- Now it is registered in Messages and messages are called instead of hardcoded values

                                                FND_MESSAGE.SET_NAME('IGS','IGS_PR_ENC_NMAN_BLOCK_TYP');
                                                FND_MESSAGE.SET_TOKEN('OUT_TYP',v_spo2_rec.progression_outcome_type);
                                                IGS_GE_MSG_STACK.ADD;
                                                v_message_text1 := FND_MESSAGE.GET;

                                        END IF;
                                        v_message_level := cst_block;
                                        v_unresolved_clash := TRUE;
                                        -- Exit the routine ; no point in continuing
                                        EXIT;
                                ELSIF v_clash_type = cst_expire THEN
                                        v_expire := TRUE;
                                ELSIF v_clash_type = cst_warning THEN
                                        v_warning := TRUE;
                                END IF;
                        END LOOP; -- c_pen_pee
                        IF v_unresolved_clash THEN
                                EXIT;
                        END IF;
                        IF v_expire THEN
                                IF p_application_type = cst_manual THEN
                                        IF v_message_text1 IS NULL OR v_message_level = cst_warning THEN
                                                -- Modified by Prajeesh on 08-Jul-2002
                                                -- Previously it was hardcoded and hence it was not NLS Complaint
                                                -- Now it is registered in Messages and messages are called instead of hardcoded values

                                                FND_MESSAGE.SET_NAME('IGS','IGS_PR_ENC_MAN_EXP_TYP');
                                                FND_MESSAGE.SET_TOKEN('OUT_TYP',v_spo2_rec.progression_outcome_type);
                                                IGS_GE_MSG_STACK.ADD;
                                                v_message_text1 := FND_MESSAGE.GET;
                                                v_message_level := cst_expire;
                                        END IF;
                                ELSE
                                        IF v_message_text1 IS NULL THEN
                                                v_message_text1 := '';
                                        END IF;
                                        -- Modified by Prajeesh on 08-Jul-2002
                                        -- Previously it was hardcoded and hence it was not NLS Complaint
                                        -- Now it is registered in Messages and messages are called instead of hardcoded values

                                        FND_MESSAGE.SET_NAME('IGS','IGS_PR_ENC_NMAN_EXP_TYP');
                                        FND_MESSAGE.SET_TOKEN('OUT_TYP',v_spo2_rec.progression_outcome_type);
                                        IGS_GE_MSG_STACK.ADD;
                                        v_message_text2 := FND_MESSAGE.GET;

                                        v_message_text1 := v_message_text1 ||v_message_text2;

                                        v_message_level := cst_expire;
                                END IF;
                                -- Call routine to expire the spo that is causing the issue. It will
                                -- apply the changes immediately so that the clashing effects will be
                                -- removed.
                                BEGIN
                                        OPEN c_spo_expire (
                                                v_spo2_rec.sequence_number);
                                        FETCH c_spo_expire INTO v_spo_expire_rec;
                    IGS_PR_STDNT_PR_OU_PKG.UPDATE_ROW(
                      X_ROWID                         => v_spo_expire_rec.ROWID,
                      X_PERSON_ID                     => v_spo_expire_rec.PERSON_ID,
                      X_COURSE_CD                     => v_spo_expire_rec.COURSE_CD,
                      X_SEQUENCE_NUMBER               => v_spo_expire_rec.SEQUENCE_NUMBER,
                      X_PRG_CAL_TYPE                  => v_spo_expire_rec.PRG_CAL_TYPE,
                      X_PRG_CI_SEQUENCE_NUMBER        => v_spo_expire_rec.PRG_CI_SEQUENCE_NUMBER,
                      X_RULE_CHECK_DT                 => v_spo_expire_rec.RULE_CHECK_DT,
                      X_PROGRESSION_RULE_CAT          => v_spo_expire_rec.PROGRESSION_RULE_CAT,
                      X_PRA_SEQUENCE_NUMBER           => v_spo_expire_rec.PRA_SEQUENCE_NUMBER,
                      X_PRO_SEQUENCE_NUMBER           => v_spo_expire_rec.PRO_SEQUENCE_NUMBER,
                      X_PROGRESSION_OUTCOME_TYPE      => v_spo_expire_rec.PROGRESSION_OUTCOME_TYPE,
                      X_DURATION                      => v_spo_expire_rec.DURATION,
                      X_DURATION_TYPE                 => v_spo_expire_rec.DURATION_TYPE,
                      X_DECISION_STATUS               => v_spo_expire_rec.DECISION_STATUS,
                      X_DECISION_DT                   => v_spo_expire_rec.DECISION_DT,
                      X_DECISION_ORG_UNIT_CD          => v_spo_expire_rec.DECISION_ORG_UNIT_CD,
                      X_DECISION_OU_START_DT          => v_spo_expire_rec.DECISION_OU_START_DT,
                      X_APPLIED_DT                    => v_spo_expire_rec.APPLIED_DT,
                      X_SHOW_CAUSE_EXPIRY_DT          => v_spo_expire_rec.SHOW_CAUSE_EXPIRY_DT,
                      X_SHOW_CAUSE_DT                 => v_spo_expire_rec.SHOW_CAUSE_DT,
                      X_SHOW_CAUSE_OUTCOME_DT         => v_spo_expire_rec.SHOW_CAUSE_OUTCOME_DT,
                      X_SHOW_CAUSE_OUTCOME_TYPE       => v_spo_expire_rec.SHOW_CAUSE_OUTCOME_TYPE,
                      X_APPEAL_EXPIRY_DT              => v_spo_expire_rec.APPEAL_EXPIRY_DT,
                      X_APPEAL_DT                     => v_spo_expire_rec.APPEAL_DT,
                      X_APPEAL_OUTCOME_DT             => v_spo_expire_rec.APPEAL_OUTCOME_DT,
                      X_APPEAL_OUTCOME_TYPE           => v_spo_expire_rec.APPEAL_OUTCOME_TYPE,
                      X_ENCMB_COURSE_GROUP_CD         => v_spo_expire_rec.ENCMB_COURSE_GROUP_CD,
                      X_RESTRICTED_ENROLMENT_CP       => v_spo_expire_rec.RESTRICTED_ENROLMENT_CP,
                      X_RESTRICTED_ATTENDANCE_TYPE    => v_spo_expire_rec.RESTRICTED_ATTENDANCE_TYPE,
                      X_COMMENTS                      => v_spo_expire_rec.COMMENTS,
                      X_SHOW_CAUSE_COMMENTS           => v_spo_expire_rec.SHOW_CAUSE_COMMENTS,
                      X_APPEAL_COMMENTS               => v_spo_expire_rec.APPEAL_COMMENTS,
                      X_EXPIRY_DT                     => v_spo_expire_rec.EXPIRY_DT,
                      X_PRO_PRA_SEQUENCE_NUMBER       => v_spo_expire_rec.PRO_PRA_SEQUENCE_NUMBER,
                      X_MODE                          => 'R'
                                        );
                                        CLOSE c_spo_expire;
                                EXCEPTION
                                        WHEN e_record_locked THEN
                                                IF c_spo_expire%ISOPEN THEN
                                                        CLOSE c_spo_expire;
                                                END IF;
                                                v_unresolved_clash := TRUE;
                                        --      p_message_text := IGS_GE_GEN_002.GENP_GET_MESSAGE(5287);
                                                p_message_level := cst_error;
                                                EXIT;
                                        WHEN OTHERS THEN
                                                RAISE;
                                END;
                        ELSIF v_warning THEN
                                IF p_application_type = cst_manual THEN
                                        IF v_message_text1 IS NULL THEN

                                                -- Modified by Prajeesh on 08-Jul-2002
                                                -- Previously it was hardcoded and hence it was not NLS Complaint
                                                -- Now it is registered in Messages and messages are called instead of hardcoded values

                                                FND_MESSAGE.SET_NAME('IGS','IGS_PR_ENC_MAN_WARN_TYP');
                                                FND_MESSAGE.SET_TOKEN('OUT_TYP',v_spo2_rec.progression_outcome_type);
                                                IGS_GE_MSG_STACK.ADD;
                                                v_message_text1 := FND_MESSAGE.GET;

                                                v_message_level := cst_warning;
                                        END IF;
                                ELSE

                                                -- Modified by Prajeesh on 08-Jul-2002
                                                -- Previously it was hardcoded and hence it was not NLS Complaint
                                                -- Now it is registered in Messages and messages are called instead of hardcoded values

                                                FND_MESSAGE.SET_NAME('IGS','IGS_PR_ENC_NMAN_WARN_TYP');
                                                FND_MESSAGE.SET_TOKEN('OUT_TYP',v_spo2_rec.progression_outcome_type);
                                                IGS_GE_MSG_STACK.ADD;
                                                v_message_text1 := FND_MESSAGE.GET;

                                                 v_message_level := cst_warning;
                                END IF;
                        END IF;
                END LOOP; -- c_edte
                IF v_unresolved_clash THEN
                        EXIT;
                END IF;
        END LOOP; -- c_spo2
        IF v_message_level IS NOT NULL THEN
                p_message_level := v_message_level;
                p_message_text := v_message_text1 || '.';
        END IF;
        IF v_unresolved_clash THEN
                ROLLBACK TO sp_before_check;
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_spo1%ISOPEN THEN
                        CLOSE c_spo1;
                END IF;
                IF c_pee%ISOPEN THEN
                        CLOSE c_pee;
                END IF;
                IF c_pen_pee%ISOPEN THEN
                        CLOSE c_pen_pee;
                END IF;
                IF c_spo_expire%ISOPEN THEN
                        CLOSE c_spo_expire;
                END IF;
                IF c_edte%ISOPEN THEN
                        CLOSE c_edte;
                END IF;
                IF c_spo2%ISOPEN THEN
                        CLOSE c_spo2;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_UPD_PEN_CLASH');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
END IGS_PR_upd_pen_clash;

FUNCTION IGS_PR_UPD_SCA_STATUS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_current_progression_status IN VARCHAR2 ,
  p_course_version IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
        gv_other_detail                 VARCHAR2(255);
BEGIN   -- IGS_PR_upd_sca_status
        -- Re-derive the course attempt status for a single student course attempt.
        -- This routine will call the derivation, and if the result is different from
        -- the current status, will update with the new status. Locking is considered.
DECLARE
        e_resource_busy                 EXCEPTION;
        PRAGMA EXCEPTION_INIT (e_resource_busy, -54);
        v_course_version                IGS_EN_STDNT_PS_ATT.version_number%TYPE;
        v_progression_status            IGS_EN_STDNT_PS_ATT.progression_status%TYPE;
        v_current_progression_status    IGS_EN_STDNT_PS_ATT.progression_status%TYPE;
        v_dummy                         VARCHAR2(1);
        CURSOR c_sca_upd IS
                SELECT  sca.*, sca.ROWID
                FROM    IGS_EN_STDNT_PS_ATT             sca
                WHERE   sca.person_id                   = p_person_id AND
                        sca.course_cd                   = p_course_cd
                FOR UPDATE NOWAIT;

        v_sca_upd_rec c_sca_upd%ROWTYPE;
        CURSOR c_sca IS
                SELECT  sca.version_number,
                        sca.progression_status
                FROM    IGS_EN_STDNT_PS_ATT             sca
                WHERE   sca.person_id                   = p_person_id AND
                        sca.course_cd                   = p_course_cd;

        CURSOR c_person(cp_party_id Number) IS
                 SELECT PARTY_NUMBER FROM HZ_PARTIES
                 WHERE PARTY_ID = cp_party_id;

        lv_person_number HZ_PARTIES.PARTY_NUMBER%TYPE;

BEGIN
        -- Set the default message number
        --kdande; 19-Jul-2002; Bug# 2462120; Nullified the message name since it was defaulted to 0.
        p_message_name := '';
        IF p_person_id IS NULL OR
                        p_course_cd IS NULL THEN
                RETURN TRUE;
        END IF;
        IF p_course_version IS NULL OR
                        p_current_progression_status IS NULL THEN
                OPEN c_sca;
                FETCH c_sca INTO
                                v_course_version,
                                v_current_progression_status;
                IF c_sca%NOTFOUND THEN
                        CLOSE c_sca;
                        RETURN TRUE;
                END IF;
                CLOSE c_sca;
        ELSE
                v_course_version := p_course_version;
                v_current_progression_status := p_current_progression_status;
        END IF;

        -- Call derivation routine
        v_progression_status := IGS_PR_GEN_005.IGS_PR_get_prg_status(
                              p_person_id,
                              p_course_cd,
                              v_course_version,
                              NULL,
                              NULL
                            );
        IF v_progression_status <>NVL( v_current_progression_status, 'NONE' ) THEN
                BEGIN
                        OPEN c_sca_upd;
                        FETCH c_sca_upd INTO v_sca_upd_rec;
                        IF c_sca_upd%FOUND THEN
                IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                  X_ROWID                         => v_sca_upd_rec.ROWID,
                  X_PERSON_ID                     => v_sca_upd_rec.PERSON_ID,
                  X_COURSE_CD                     => v_sca_upd_rec.COURSE_CD,
                  X_ADVANCED_STANDING_IND         => v_sca_upd_rec.ADVANCED_STANDING_IND,
                  X_FEE_CAT                       => v_sca_upd_rec.FEE_CAT,
                  X_CORRESPONDENCE_CAT            => v_sca_upd_rec.CORRESPONDENCE_CAT,
                  X_SELF_HELP_GROUP_IND           => v_sca_upd_rec.SELF_HELP_GROUP_IND,
                  X_LOGICAL_DELETE_DT             => v_sca_upd_rec.LOGICAL_DELETE_DT,
                  X_ADM_ADMISSION_APPL_NUMBER     => v_sca_upd_rec.ADM_ADMISSION_APPL_NUMBER,
                  X_ADM_NOMINATED_COURSE_CD       => v_sca_upd_rec.ADM_NOMINATED_COURSE_CD,
                  X_ADM_SEQUENCE_NUMBER           => v_sca_upd_rec.ADM_SEQUENCE_NUMBER,
                  X_VERSION_NUMBER                => v_sca_upd_rec.VERSION_NUMBER,
                  X_CAL_TYPE                      => v_sca_upd_rec.CAL_TYPE,
                  X_LOCATION_CD                   => v_sca_upd_rec.LOCATION_CD,
                  X_ATTENDANCE_MODE               => v_sca_upd_rec.ATTENDANCE_MODE,
                  X_ATTENDANCE_TYPE               => v_sca_upd_rec.ATTENDANCE_TYPE,
                  X_COO_ID                        => v_sca_upd_rec.COO_ID,
                  X_STUDENT_CONFIRMED_IND         => v_sca_upd_rec.STUDENT_CONFIRMED_IND,
                  X_COMMENCEMENT_DT               => v_sca_upd_rec.COMMENCEMENT_DT,
                  X_COURSE_ATTEMPT_STATUS         => v_sca_upd_rec.COURSE_ATTEMPT_STATUS,
                  X_PROGRESSION_STATUS            => v_progression_status, --updating this column
                  X_DERIVED_ATT_TYPE              => v_sca_upd_rec.DERIVED_ATT_TYPE,
                  X_DERIVED_ATT_MODE              => v_sca_upd_rec.DERIVED_ATT_MODE,
                  X_PROVISIONAL_IND               => v_sca_upd_rec.PROVISIONAL_IND,
                  X_DISCONTINUED_DT               => v_sca_upd_rec.DISCONTINUED_DT,
                  X_DISCONTINUATION_REASON_CD     => v_sca_upd_rec.DISCONTINUATION_REASON_CD,
                  X_LAPSED_DT                     => v_sca_upd_rec.LAPSED_DT,
                  X_FUNDING_SOURCE                => v_sca_upd_rec.FUNDING_SOURCE,
                  X_EXAM_LOCATION_CD              => v_sca_upd_rec.EXAM_LOCATION_CD,
                  X_DERIVED_COMPLETION_YR         => v_sca_upd_rec.DERIVED_COMPLETION_YR,
                  X_DERIVED_COMPLETION_PERD       => v_sca_upd_rec.DERIVED_COMPLETION_PERD,
                  X_NOMINATED_COMPLETION_YR       => v_sca_upd_rec.NOMINATED_COMPLETION_YR,
                  X_NOMINATED_COMPLETION_PERD     => v_sca_upd_rec.NOMINATED_COMPLETION_PERD,
                  X_RULE_CHECK_IND                => v_sca_upd_rec.RULE_CHECK_IND,
                  X_WAIVE_OPTION_CHECK_IND        => v_sca_upd_rec.WAIVE_OPTION_CHECK_IND,
                  X_LAST_RULE_CHECK_DT            => v_sca_upd_rec.LAST_RULE_CHECK_DT,
                  X_PUBLISH_OUTCOMES_IND          => v_sca_upd_rec.PUBLISH_OUTCOMES_IND,
                  X_COURSE_RQRMNT_COMPLETE_IND    => v_sca_upd_rec.COURSE_RQRMNT_COMPLETE_IND,
                  X_COURSE_RQRMNTS_COMPLETE_DT    => v_sca_upd_rec.COURSE_RQRMNTS_COMPLETE_DT,
                  X_S_COMPLETED_SOURCE_TYPE       => v_sca_upd_rec.S_COMPLETED_SOURCE_TYPE,
                  X_OVERRIDE_TIME_LIMITATION      => v_sca_upd_rec.OVERRIDE_TIME_LIMITATION,
                  X_MODE                          => 'R',
                  X_LAST_DATE_OF_ATTENDANCE       => v_sca_upd_rec.LAST_DATE_OF_ATTENDANCE,
                  X_DROPPED_BY                    => v_sca_upd_rec.DROPPED_BY,
                  X_IGS_PR_CLASS_STD_ID           => v_sca_upd_rec.IGS_PR_CLASS_STD_ID,
                  X_PRIMARY_PROGRAM_TYPE          => v_sca_upd_rec.PRIMARY_PROGRAM_TYPE,
                  X_PRIMARY_PROG_TYPE_SOURCE      => v_sca_upd_rec.PRIMARY_PROG_TYPE_SOURCE,
                  X_CATALOG_CAL_TYPE              => v_sca_upd_rec.CATALOG_CAL_TYPE,
                  X_CATALOG_SEQ_NUM               => v_sca_upd_rec.CATALOG_SEQ_NUM,
                  X_KEY_PROGRAM                   => v_sca_upd_rec.KEY_PROGRAM,
                  X_MANUAL_OVR_CMPL_DT_IND      => v_sca_upd_rec.MANUAL_OVR_CMPL_DT_IND   ,
                 X_OVERRIDE_CMPL_DT             => v_sca_upd_rec.OVERRIDE_CMPL_DT        ,
                 X_ATTRIBUTE_CATEGORY           => v_sca_upd_rec.ATTRIBUTE_CATEGORY      ,
                 X_ATTRIBUTE1                   => v_sca_upd_rec.ATTRIBUTE1              ,
                 X_ATTRIBUTE2                   => v_sca_upd_rec.ATTRIBUTE2              ,
                 X_ATTRIBUTE3                   => v_sca_upd_rec.ATTRIBUTE3              ,
                 X_ATTRIBUTE4                   => v_sca_upd_rec.ATTRIBUTE4              ,
                 X_ATTRIBUTE5                   => v_sca_upd_rec.ATTRIBUTE5              ,
                 X_ATTRIBUTE6                   => v_sca_upd_rec.ATTRIBUTE6              ,
                 X_ATTRIBUTE7                   => v_sca_upd_rec.ATTRIBUTE7              ,
                 X_ATTRIBUTE8                   => v_sca_upd_rec.ATTRIBUTE8              ,
                 X_ATTRIBUTE9                   => v_sca_upd_rec.ATTRIBUTE9              ,
                 X_ATTRIBUTE10                  => v_sca_upd_rec.ATTRIBUTE10             ,
                 X_ATTRIBUTE11                  => v_sca_upd_rec.ATTRIBUTE11             ,
                 X_ATTRIBUTE12                  => v_sca_upd_rec.ATTRIBUTE12             ,
                 X_ATTRIBUTE13                  => v_sca_upd_rec.ATTRIBUTE13             ,
                 X_ATTRIBUTE14                  => v_sca_upd_rec.ATTRIBUTE14             ,
                 X_ATTRIBUTE15                  => v_sca_upd_rec.ATTRIBUTE15             ,
                 X_ATTRIBUTE16                  => v_sca_upd_rec.ATTRIBUTE16             ,
                 X_ATTRIBUTE17                  => v_sca_upd_rec.ATTRIBUTE17             ,
                 X_ATTRIBUTE18                  => v_sca_upd_rec.ATTRIBUTE18             ,
                 X_ATTRIBUTE19                  => v_sca_upd_rec.ATTRIBUTE19             ,
                 X_ATTRIBUTE20                  => v_sca_upd_rec.ATTRIBUTE20             ,
                 X_FUTURE_DATED_TRANS_FLAG      => v_sca_upd_rec.future_dated_trans_flag
                );
                                CLOSE c_sca_upd;
                        ELSE
                                CLOSE c_sca_upd;
                        END IF;
                EXCEPTION
                        WHEN e_resource_busy THEN
                                IF c_sca_upd%ISOPEN THEN
                                        CLOSE c_sca_upd;
                                END IF;
                                p_message_name := 'IGS_PR_LOCK_DETECTED';
                                RETURN FALSE;
                END;

        ELSE
          OPEN c_person(p_person_id);
          FETCH c_person INTO lv_person_number;
          CLOSE c_person;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'No Change in Progression Status for the Person = '||lv_person_number
                                          ||'Course Code :='||P_COURSE_CD);
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_sca_upd%ISOPEN THEN
                        CLOSE c_sca_upd;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_UPD_SCA_STATUS');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
END IGS_PR_upd_sca_status;


FUNCTION igs_pr_upd_spo_pen(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_spo_sequence_number IN NUMBER ,
  p_authorising_person_id IN NUMBER ,
  p_application_type IN VARCHAR2 ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  p_message_level OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 03-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || ssawhney   17-feb-2003   Bug : 2758856  : Added the parameter x_external_reference in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW
  ||  kdande          17-Dec-2002     Bug# 2543601. Changed the query for c_pe
  ||                                  cursor to use hz_parties instead of igs_pe_person
  ||  nalkumar        19-NOV-2002     Bug NO: 2658550. Modified this function as per the FA110 PR Enh.
  ||  pkpatel         7-OCT-2002      Bug No: 2600842
  ||                                  Added the parameter x_auth_resp_id in the call to igs_pe_pers_encumb_pkg
  ||  (reverse chronological order - newest change first)
  */
        gv_other_detail                 VARCHAR2(255);
        gcst_sysdate    CONSTANT        DATE := TRUNC(SYSDATE);
        gcst_sysdatetime CONSTANT       DATE := SYSDATE;
BEGIN   -- IGS_PR_upd_spo_pen
        -- Maintain the person encumbrance structure related to a
        -- IGS_PR_STDNT_PR_OU that has been approved. The encumbrance details
        -- resulting from spo detail are only maintainable through this routine, via
        -- changes through the progression screens. The routine also handles the
        -- removal of encumbrances if the outcome has been Cancelled/Removed.
        -- A database relationship exists between the IGS_PE_PERS_ENCUMB and
        -- IGS_PR_STDNT_PR_OU from which it has resulted.
        -- Note: If a student has multiple IGS_PR_STDNT_PR_OUs then they
        -- will result in separate IGS_PE_PERS_ENCUMB entries related accordingly.
        -- Overlap between encumbrance effects is possible and is resolved where
        -- required.
        -- Note: the authorising person ID parameter is designed to be passed from
        -- calling routines and will be recorded against the person encumbrance
        -- records added (only when being added and not altered).
DECLARE
        cst_cancelled   CONSTANT        VARCHAR2(10) := 'CANCELLED';
        cst_pending     CONSTANT        VARCHAR2(10) := 'PENDING';
        cst_removed     CONSTANT        VARCHAR2(10) := 'REMOVED';
        cst_waived      CONSTANT        VARCHAR2(10) := 'WAIVED';
        cst_rstr_ge_cp  CONSTANT        VARCHAR2(10) := 'RSTR_GE_CP';
        cst_rstr_le_cp  CONSTANT        VARCHAR2(10) := 'RSTR_LE_CP';
        cst_rstr_at_ty  CONSTANT        VARCHAR2(10) := 'RSTR_AT_TY';
        cst_sus_course  CONSTANT        VARCHAR2(10) := 'SUS_COURSE';
        cst_exc_course  CONSTANT        VARCHAR2(10) := 'EXC_COURSE';
        cst_exc_crs_gp  CONSTANT        VARCHAR2(10) := 'EXC_CRS_GP';
        cst_exc_crs_us  CONSTANT        VARCHAR2(10) := 'EXC_CRS_US';
        cst_exc_crs_u   CONSTANT        VARCHAR2(10) := 'EXC_CRS_U';
        cst_rqrd_crs_u  CONSTANT        VARCHAR2(10) := 'RQRD_CRS_U';
--
        cst_exc_sp_awd  CONSTANT        VARCHAR2(10) := 'EX_SP_AWD';
        cst_exc_sp_disb CONSTANT        VARCHAR2(15) := 'EX_SP_DISB';
        cst_exc_awd     CONSTANT        VARCHAR2(10) := 'EX_AWD';
        cst_exc_disb    CONSTANT        VARCHAR2(10) := 'EX_DISB';
--
        cst_excluded    CONSTANT        VARCHAR2(10) := 'EXCLUDED';
        cst_expired     CONSTANT        VARCHAR2(10) := 'EXPIRED';
        cst_error       CONSTANT        VARCHAR2(10) := 'ERROR';
        cst_required    CONSTANT        VARCHAR2(10) := 'REQUIRED';
        e_record_locked                 EXCEPTION;
        v_decode_val1                   NUMBER(6,3);
        v_decode_val2                   VARCHAR2(2);
        lv_spo_sequence_number          IGS_PE_PERS_ENCUMB.SPO_SEQUENCE_NUMBER%TYPE;
        PRAGMA EXCEPTION_INIT (e_record_locked, -54);
        v_authorising_person_id         IGS_PE_PERSON.person_id%TYPE;
        v_message_text                  VARCHAR2(2000) DEFAULT NULL;
        v_message_level                 VARCHAR2(10) DEFAULT NULL;
        v_action_expiry_dt                      IGS_PE_PERS_ENCUMB.expiry_dt%TYPE;
        v_pen_expiry_dt                 IGS_PE_PERS_ENCUMB.expiry_dt%TYPE;
        v_pen_exists                    BOOLEAN;
        v_expiry_status                 VARCHAR2(10);
        v_expiry_dt                     DATE;
        v_course_cd_found               BOOLEAN;
        v_course_grp_cd_found           BOOLEAN;
        v_unit_set_found                        BOOLEAN;
        v_unit_cd_found                 BOOLEAN;
        v_pee_sequence_number           IGS_PE_PERSENC_EFFCT.sequence_number%TYPE;
        v_dummy                         VARCHAR2(1);
        v_fund_cd_found                 BOOLEAN;
        CURSOR c_spo IS
                SELECT  spo.decision_status,
                        spo.encmb_course_group_cd,
                        spo.restricted_enrolment_cp,
                        spo.restricted_attendance_type,
                        spo.expiry_dt,
                        pot.encumbrance_type,
                        att.closed_ind
                FROM    IGS_PR_STDNT_PR_OU      spo,
                        igs_pr_ou_type          pot,
                        igs_en_atd_type                 att
                WHERE   spo.person_id                   = p_person_id AND
                        spo.course_cd                   = p_course_cd AND
                        spo.sequence_number             = p_spo_sequence_number AND
                        pot.progression_outcome_type    = spo.progression_outcome_type AND
                        att.attendance_type             (+)= spo.restricted_attendance_type;
                v_spo_rec c_spo%ROWTYPE;
        CURSOR c_pe IS
          SELECT   p.party_id person_id
          FROM     hz_parties p,
                   fnd_user u
          WHERE    u.user_id = FND_GLOBAL.USER_ID
          AND      u.person_party_id = p.party_id
          AND      SUBSTR (igs_en_gen_003.get_staff_ind (p.party_id), 1, 1) = 'Y';
        CURSOR c_pen IS
                SELECT  pen.expiry_dt
                FROM    IGS_PE_PERS_ENCUMB              pen
                WHERE   pen.person_id                   = p_person_id AND
                        pen.spo_course_cd               = p_course_cd AND
                        pen.spo_sequence_number         = p_spo_sequence_number;
        CURSOR c_etde (
                cp_encumbrance_type             IGS_PR_OU_TYPE.encumbrance_type%TYPE) IS
                SELECT  etde.s_encmb_effect_type
                FROM    igs_fi_enc_dflt_eft             etde
                WHERE   etde.encumbrance_type           = cp_encumbrance_type;

        CURSOR c_pee IS
                SELECT  pee.*,
                        pee.ROWID
                FROM    IGS_PE_PERS_ENCUMB              pen,
                        IGS_PE_PERSENC_EFFCT    pee,
                        igs_fi_enc_dflt_eft             etde
                WHERE   pen.person_id                   = p_person_id AND
                        pen.spo_course_cd               = p_course_cd AND
                        pen.spo_sequence_number         = p_spo_sequence_number AND
                        pen.person_id                   = pee.person_id AND
                        pen.encumbrance_type            = pee.encumbrance_type AND
                        pen.start_dt                    = pee.pen_start_dt AND
                        pee.encumbrance_type            = etde.encumbrance_type AND
                        pee.s_encmb_effect_type         = etde.s_encmb_effect_type AND
                        (pee.expiry_dt                  IS NULL OR
                        pee.expiry_dt                   > gcst_sysdate)
                FOR UPDATE NOWAIT;

        CURSOR c_pee_seq_num IS
                SELECT  IGS_PR_PEE_SEQUEN_S.NEXTVAL
                FROM    DUAL;

        CURSOR c_pce (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                SELECT  pce.*, pce.ROWID
                FROM    igs_pe_course_excl              pce
                WHERE   pce.person_id                   = p_person_id AND
                        pce.encumbrance_type            = cp_encumbrance_type AND
                        pce.pen_start_dt                = cp_pen_start_dt AND
                        pce.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                        pce.pee_start_dt                = cp_pee_start_dt AND
                        pce.pee_sequence_number         = cp_pee_sequence_number AND
                        (pce.expiry_dt                  IS NULL OR
                        pce.expiry_dt                   > gcst_sysdate)
                FOR UPDATE NOWAIT;

        TYPE t_pce_table IS TABLE OF igs_pe_course_excl.course_cd%TYPE

                INDEX BY BINARY_INTEGER;


        v_pce_table                     t_pce_table;

        v_pce_index                     BINARY_INTEGER;

        CURSOR c_pce_dup (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE,
                cp_course_cd                    igs_pe_course_excl.course_cd%TYPE,
                cp_pce_start_dt                 igs_pe_course_excl.pce_start_dt%TYPE) IS
                SELECT  pce.*, pce.ROWID
                FROM    igs_pe_course_excl              pce
                WHERE   pce.person_id                   = p_person_id AND
                        pce.encumbrance_type            = cp_encumbrance_type AND
                        pce.pen_start_dt                = cp_pen_start_dt AND
                        pce.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                        pce.pee_start_dt                = cp_pee_start_dt AND
                        pce.pee_sequence_number         = cp_pee_sequence_number AND
                        pce.course_cd                   = cp_course_cd AND
                        pce.pce_start_dt                = cp_pce_start_dt
                FOR UPDATE NOWAIT;
                v_pce_dup_rec  c_pce_dup%ROWTYPE;

        CURSOR c_spc IS
                SELECT  spc.course_cd
                FROM    igs_pr_stdnt_pr_ps              spc
                WHERE   spc.person_id                   = p_person_id AND
                        spc.spo_course_cd               = p_course_cd AND
                        spc.spo_sequence_number         = p_spo_sequence_number;
        TYPE t_spc_type IS TABLE OF igs_pr_stdnt_pr_ps.course_cd%TYPE
        INDEX BY BINARY_INTEGER;

        v_spc_table                     t_spc_type;
        v_spc_index                     BINARY_INTEGER;

        CURSOR c_pcge (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                SELECT  pcge.*, pcge.ROWID
                FROM    igs_pe_crs_grp_excl     pcge
                WHERE   pcge.person_id          = p_person_id AND
                        pcge.encumbrance_type   = cp_encumbrance_type AND
                        pcge.pen_start_dt               = cp_pen_start_dt AND
                        pcge.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                        pcge.pee_start_dt               = cp_pee_start_dt AND
                        pcge.pee_sequence_number        = cp_pee_sequence_number AND
                        (pcge.expiry_dt         IS NULL OR
                        pcge.expiry_dt          > gcst_sysdate)
                FOR UPDATE NOWAIT;
                TYPE t_pcge_table IS TABLE OF igs_pe_crs_grp_excl.course_group_cd%TYPE
                INDEX BY BINARY_INTEGER;

        v_pcge_table                    t_pcge_table;
        v_pcge_index                    BINARY_INTEGER;

        CURSOR c_pcge_dup (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE,
                cp_course_group_cd              igs_pe_crs_grp_excl.course_group_cd%TYPE,
                cp_pcge_start_dt                igs_pe_crs_grp_excl.pcge_start_dt%TYPE) IS
                SELECT  pcge.*, pcge.ROWID
                FROM    igs_pe_crs_grp_excl     pcge
                WHERE   pcge.person_id          = p_person_id AND
                        pcge.encumbrance_type   = cp_encumbrance_type AND
                        pcge.pen_start_dt               = cp_pen_start_dt AND
                        pcge.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                        pcge.pee_start_dt               = cp_pee_start_dt AND
                        pcge.pee_sequence_number        = cp_pee_sequence_number AND
                        pcge.course_group_cd    = cp_course_group_cd AND
                        pcge.pcge_start_dt              = cp_pcge_start_dt
                FOR UPDATE NOWAIT;

                v_pcge_dup_rec c_pcge_dup%ROWTYPE;

        CURSOR c_puse (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                SELECT  puse.*, puse.ROWID
                FROM    igs_pe_unt_set_excl     puse
                WHERE   puse.person_id                  = p_person_id AND
                        puse.encumbrance_type           = cp_encumbrance_type AND
                        puse.pen_start_dt               = cp_pen_start_dt AND
                        puse.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                        puse.pee_start_dt               = cp_pee_start_dt AND
                        puse.pee_sequence_number        = cp_pee_sequence_number AND
                        (puse.expiry_dt                 IS NULL OR
                        puse.expiry_dt                  > gcst_sysdate)
                FOR UPDATE NOWAIT;

                TYPE r_puse_record_type IS RECORD (
                unit_set_cd             igs_pe_unt_set_excl.unit_set_cd%TYPE,
                us_version_number       igs_pe_unt_set_excl.us_version_number%TYPE);

        r_puse_record                   r_puse_record_type;
        TYPE t_puse_table IS TABLE OF r_puse_record%TYPE
                INDEX BY BINARY_INTEGER;

        v_puse_table                    t_puse_table;
        v_puse_index                    BINARY_INTEGER;

        CURSOR c_puse_dup (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE,
                cp_unit_set_cd                  igs_pe_unt_set_excl.unit_set_cd%TYPE,
                cp_us_version_number            igs_pe_unt_set_excl.us_version_number%TYPE,
                cp_puse_start_dt                igs_pe_unt_set_excl.puse_start_dt%TYPE) IS
                SELECT  puse.*, puse.ROWID
                FROM    igs_pe_unt_set_excl     puse
                WHERE   puse.person_id                  = p_person_id AND
                        puse.encumbrance_type           = cp_encumbrance_type AND
                        puse.pen_start_dt               = cp_pen_start_dt AND
                        puse.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                        puse.pee_start_dt               = cp_pee_start_dt AND
                        puse.pee_sequence_number        = cp_pee_sequence_number AND
                        puse.unit_set_cd                = cp_unit_set_cd AND
                        puse.us_version_number          = cp_us_version_number AND
                        puse.puse_start_dt              = cp_puse_start_dt
                FOR UPDATE NOWAIT;

                v_puse_dup_rec  c_puse_dup%ROWTYPE;

        CURSOR c_spus IS
                SELECT  spus.unit_set_cd,
                        spus.version_number
                FROM    igs_pr_sdt_pr_unt_st            spus
                WHERE   spus.person_id                  = p_person_id AND
                        spus.course_cd                  = p_course_cd AND
                        spus.spo_sequence_number        = p_spo_sequence_number;

                TYPE r_spus_record_type IS RECORD (
                unit_set_cd             igs_pr_sdt_pr_unt_st.unit_set_cd%TYPE,
                version_number          igs_pr_sdt_pr_unt_st.version_number%TYPE);
                r_spus_record           r_spus_record_type;

        TYPE t_spus_table IS TABLE OF r_spus_record%TYPE
                INDEX BY BINARY_INTEGER;

        v_spus_table                    t_spus_table;
        v_spus_index                    BINARY_INTEGER;

        CURSOR c_pue (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                SELECT  pue.*, pue.ROWID
                FROM    igs_pe_pers_unt_excl            pue
                WHERE   pue.person_id                   = p_person_id AND
                        pue.encumbrance_type            = cp_encumbrance_type AND
                        pue.pen_start_dt                = cp_pen_start_dt AND
                        pue.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                        pue.pee_start_dt                = cp_pee_start_dt AND
                        pue.pee_sequence_number         = cp_pee_sequence_number AND
                        (pue.expiry_dt                  IS NULL OR
                        pue.expiry_dt                   > gcst_sysdate)
                FOR UPDATE NOWAIT;


        TYPE t_pue_table IS TABLE OF igs_pe_pers_unt_excl.unit_cd%TYPE
                INDEX BY BINARY_INTEGER;

        v_pue_table                     t_pue_table;
        v_pue_index                     BINARY_INTEGER;

        CURSOR c_pue_dup (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE,
                cp_unit_cd                      igs_pe_pers_unt_excl.unit_cd%TYPE,
                cp_pue_start_dt                 igs_pe_pers_unt_excl.pue_start_dt%TYPE) IS

                SELECT  pue.*, pue.ROWID
                FROM    igs_pe_pers_unt_excl            pue
                WHERE   pue.person_id                   = p_person_id AND
                        pue.encumbrance_type            = cp_encumbrance_type AND
                        pue.pen_start_dt                = cp_pen_start_dt AND
                        pue.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                        pue.pee_start_dt                = cp_pee_start_dt AND
                        pue.pee_sequence_number         = cp_pee_sequence_number AND
                        pue.unit_cd                     = cp_unit_cd AND
                        pue.pue_start_dt                = cp_pue_start_dt
                FOR UPDATE NOWAIT;

                v_pue_dup_rec c_pue_dup%ROWTYPE;

        CURSOR c_pur (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                SELECT  pur.*, pur.ROWID
                FROM    igs_pe_unt_requirmnt            pur
                WHERE   pur.person_id                   = p_person_id AND
                        pur.encumbrance_type            = cp_encumbrance_type AND
                        pur.pen_start_dt                = cp_pen_start_dt AND
                        pur.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                        pur.pee_start_dt                = cp_pee_start_dt AND
                        pur.pee_sequence_number         = cp_pee_sequence_number AND
                        (pur.expiry_dt                  IS NULL OR
                        pur.expiry_dt                   > gcst_sysdate)
                FOR UPDATE NOWAIT;

                TYPE t_pur_table IS TABLE OF igs_pe_unt_requirmnt.unit_cd%TYPE
                INDEX BY BINARY_INTEGER;

                v_pur_table                     t_pur_table;
                v_pur_index                     BINARY_INTEGER;

        CURSOR c_pur_dup (
                cp_encumbrance_type             IGS_PE_PERSENC_EFFCT.encumbrance_type%TYPE,
                cp_pen_start_dt                 IGS_PE_PERSENC_EFFCT.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                cp_pee_sequence_number          IGS_PE_PERSENC_EFFCT.sequence_number%TYPE,
                cp_unit_cd                      igs_pe_unt_requirmnt.unit_cd%TYPE,
                cp_pur_start_dt                 igs_pe_unt_requirmnt.pur_start_dt%TYPE) IS
                SELECT  pur.*, pur.ROWID
                FROM    igs_pe_unt_requirmnt            pur
                WHERE   pur.person_id                   = p_person_id AND
                        pur.encumbrance_type            = cp_encumbrance_type AND
                        pur.pen_start_dt                = cp_pen_start_dt AND
                        pur.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                        pur.pee_start_dt                = cp_pee_start_dt AND
                        pur.pee_sequence_number         = cp_pee_sequence_number AND
                        pur.unit_cd                     = cp_unit_cd AND
                        pur.pur_start_dt                = cp_pur_start_dt
                FOR UPDATE NOWAIT;

           v_pur_dup_rec  c_pur_dup%ROWTYPE;

        CURSOR c_spu (
                cp_s_unit_type          igs_pr_stdnt_pr_unit.s_unit_type%TYPE) IS
                SELECT  spu.unit_cd
                FROM    igs_pr_stdnt_pr_unit            spu
                WHERE   spu.person_id                   = p_person_id AND
                        spu.course_cd                   = p_course_cd AND
                        spu.spo_sequence_number         = p_spo_sequence_number AND
                        spu.s_unit_type                 = cp_s_unit_type;

                TYPE t_spu_type IS TABLE OF igs_pr_stdnt_pr_unit.unit_cd%TYPE
                INDEX BY BINARY_INTEGER;
                v_spu_table                     t_spu_type;
                v_spu_index                     BINARY_INTEGER;

        CURSOR c_seet (
                cp_s_encmb_effect_type  igs_en_encmb_efcttyp.s_encmb_effect_type%TYPE) IS
                SELECT  apply_to_course_ind
                FROM    igs_en_encmb_efcttyp    seet
                WHERE   seet.s_encmb_effect_type        = cp_s_encmb_effect_type;

                v_apply_to_course_ind   igs_en_encmb_efcttyp.apply_to_course_ind%TYPE;
                v_apply_course_cd               IGS_PE_PERSENC_EFFCT.course_cd%TYPE;

                TYPE r_etde_record_type IS RECORD (
                  s_encmb_effect_type   igs_fi_enc_dflt_eft.s_encmb_effect_type%TYPE);
                  r_etde_record                 r_etde_record_type;

        TYPE t_etde_type IS TABLE OF r_etde_record%TYPE
        INDEX BY BINARY_INTEGER;

        v_etde_table                    t_etde_type;
        v_etde_index                    BINARY_INTEGER;
        v_index1                        BINARY_INTEGER;
        v_index2                        BINARY_INTEGER;

        --
        -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
        --
        CURSOR c_pfe (
                cp_encumbrance_type             igs_pe_persenc_effct.encumbrance_type%TYPE,
                cp_pen_start_dt                 igs_pe_persenc_effct.pen_start_dt%TYPE,
                cp_s_encmb_effect_type          igs_pe_persenc_effct.s_encmb_effect_type%TYPE,
                cp_pee_start_dt                 igs_pe_persenc_effct.pee_start_dt%TYPE,
                cp_pee_sequence_number          igs_pe_persenc_effct.sequence_number%TYPE) IS
                SELECT  pfe.*, pfe.rowid
                FROM    igs_pe_fund_excl pfe
                WHERE   pfe.person_id           = p_person_id AND
                        pfe.encumbrance_type    = cp_encumbrance_type AND
                        pfe.pen_start_dt        = cp_pen_start_dt AND
                        pfe.s_encmb_effect_type = cp_s_encmb_effect_type AND
                        pfe.pee_start_dt        = cp_pee_start_dt AND
                        pfe.pee_sequence_number = cp_pee_sequence_number AND
                        (pfe.expiry_dt          IS NULL OR
                         pfe.expiry_dt          > gcst_sysdate)
                FOR UPDATE NOWAIT;

        TYPE t_pfe_table IS TABLE OF igs_pe_fund_excl.fund_code%TYPE
        INDEX BY BINARY_INTEGER;
        v_pfe_table                     t_pfe_table;
        v_pfe_index                     BINARY_INTEGER;

        CURSOR c_pfe_dup (
                cp_encumbrance_type     igs_pe_persenc_effct.encumbrance_type%TYPE,
                cp_pen_start_dt         igs_pe_persenc_effct.pen_start_dt%TYPE,
                cp_s_encmb_effect_type  igs_pe_persenc_effct.s_encmb_effect_type%TYPE,
                cp_pee_start_dt         igs_pe_persenc_effct.pee_start_dt%TYPE,
                cp_pee_sequence_number  igs_pe_persenc_effct.sequence_number%TYPE,
                cp_fund_code            igs_pr_ou_fnd.fund_code%TYPE,
                cp_pfe_start_dt         igs_pe_fund_excl.pfe_start_dt%TYPE ) IS
                SELECT  pfe.*, pfe.ROWID
                FROM    igs_pe_fund_excl        pfe
                WHERE   pfe.person_id           = p_person_id AND
                        pfe.encumbrance_type    = cp_encumbrance_type AND
                        pfe.pen_start_dt        = cp_pen_start_dt AND
                        pfe.s_encmb_effect_type = cp_s_encmb_effect_type AND
                        pfe.pee_start_dt        = cp_pee_start_dt AND
                        pfe.pee_sequence_number = cp_pee_sequence_number AND
                        pfe.fund_code           = cp_fund_code AND
                        pfe.pfe_start_dt        = cp_pfe_start_dt
                FOR UPDATE NOWAIT;
            v_pfe_dup_rec c_pfe_dup%ROWTYPE;

          CURSOR c_spf IS
                        SELECT  spf.fund_code
                        FROM    igs_pr_stdnt_pr_fnd spf
                        WHERE   spf.person_id   = p_person_id AND
                                spf.course_cd   = p_course_cd AND
                                spf.spo_sequence_number = p_spo_sequence_number;

                TYPE t_spf_type IS TABLE OF igs_pr_stdnt_pr_fnd.fund_code%TYPE
                        INDEX BY BINARY_INTEGER;
                v_spf_table t_spf_type;
                v_spf_index BINARY_INTEGER;
          --
          -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
          --
        FUNCTION prgpl_upd_expiry_dt1 (
                p_expiry_dt                     IGS_PE_PERS_ENCUMB.expiry_dt%TYPE,
                p_local_message_level           OUT NOCOPY VARCHAR2,
                p_local_message_text            OUT NOCOPY VARCHAR2)
        RETURN BOOLEAN
        IS
          /*
          ||  Created By : prabhat.patel
          ||  Created On : 03-OCT-2002
          ||  Purpose : Validates the Foreign Keys for the table.
          ||  Known limitations, enhancements or remarks :
          ||  Change History :
          ||  Who             When            What
	  || ssawhney   17-feb-2003   Bug : 2758856  : Added the parameter x_external_reference in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW
          ||  pkpatel         7-OCT-2002      Bug No: 2600842
          ||                                  Added the parameter x_auth_resp_id in the call to igs_pe_pers_encumb_pkg
          ||  (reverse chronological order - newest change first)
          */
                gvl_other_detail        VARCHAR2(255);

        BEGIN   -- prgpl_upd_expiry_dt1

        DECLARE

                CURSOR c_pen (
                        cp_expiry_dt    IGS_PE_PERS_ENCUMB.expiry_dt%TYPE) IS
                        SELECT  pen.*,
                                pen.ROWID
                        FROM    IGS_PE_PERS_ENCUMB              pen
                        WHERE   pen.person_id                   = p_person_id AND
                                pen.spo_course_cd               = p_course_cd AND
                                pen.spo_sequence_number         = p_spo_sequence_number AND
                                ((cp_expiry_dt                  IS NULL OR
                                  cp_expiry_dt                  > gcst_sysdate) OR
                                 (pen.expiry_dt                 IS NULL OR
                                  pen.expiry_dt                 > gcst_sysdate))
                        FOR UPDATE NOWAIT;

                CURSOR c_pee (
                        cp_encumbrance_type             IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt                 IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_expiry_dt                    IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE) IS
                        SELECT  pee.*,
                                pee.ROWID
                        FROM    IGS_PE_PERSENC_EFFCT    pee
                        WHERE   pee.person_id                   = p_person_id AND
                                pee.encumbrance_type            = cp_encumbrance_type AND
                                pee.pen_start_dt                        = cp_pen_start_dt AND
                                ((cp_expiry_dt                  IS NULL OR
                                   cp_expiry_dt                 > gcst_sysdate) OR
                                 (pee.expiry_dt                 IS NULL OR
                                  pee.expiry_dt                 > gcst_sysdate))
                        FOR UPDATE NOWAIT;

                CURSOR c_pce (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pce.*,pce.ROWID
                        FROM    igs_pe_course_excl              pce
                        WHERE   pce.person_id                   = p_person_id AND
                                pce.encumbrance_type            = cp_encumbrance_type AND
                                pce.pen_start_dt                = cp_pen_start_dt AND
                                pce.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                                pce.pee_start_dt                = cp_pee_start_dt AND
                                pce.pee_sequence_number         = cp_pee_sequence_number AND
                                (pce.expiry_dt                  IS NULL OR
                                pce.expiry_dt                   > gcst_sysdate)
                        FOR UPDATE NOWAIT;

                CURSOR c_pcge (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pcge.*, pcge.ROWID
                        FROM    igs_pe_crs_grp_excl     pcge
                        WHERE   pcge.person_id                  = p_person_id AND
                                pcge.encumbrance_type           = cp_encumbrance_type AND
                                pcge.pen_start_dt               = cp_pen_start_dt AND
                                pcge.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                                pcge.pee_start_dt               = cp_pee_start_dt AND
                                pcge.pee_sequence_number        = cp_pee_sequence_number AND
                                (pcge.expiry_dt                 IS NULL OR
                                pcge.expiry_dt                  > gcst_sysdate)
                        FOR UPDATE NOWAIT;

                CURSOR c_puse (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  puse.*,puse.ROWID
                        FROM    igs_pe_unt_set_excl     puse
                        WHERE   puse.person_id                  = p_person_id AND
                                puse.encumbrance_type           = cp_encumbrance_type AND
                                puse.pen_start_dt               = cp_pen_start_dt AND
                                puse.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                                puse.pee_start_dt               = cp_pee_start_dt AND
                                puse.pee_sequence_number        = cp_pee_sequence_number AND
                                (puse.expiry_dt                 IS NULL OR
                                puse.expiry_dt                  > gcst_sysdate)
                        FOR UPDATE NOWAIT;

                CURSOR c_pue (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pue.*, pue.ROWID
                        FROM    igs_pe_pers_unt_excl            pue
                        WHERE   pue.person_id                   = p_person_id AND
                                pue.encumbrance_type            = cp_encumbrance_type AND
                                pue.pen_start_dt                = cp_pen_start_dt AND
                                pue.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                                pue.pee_start_dt                = cp_pee_start_dt AND
                                pue.pee_sequence_number         = cp_pee_sequence_number AND
                                (pue.expiry_dt                  IS NULL OR
                                pue.expiry_dt                   > gcst_sysdate)
                        FOR UPDATE NOWAIT;

                CURSOR c_pur (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pur.*, pur.ROWID
                        FROM    igs_pe_unt_requirmnt            pur
                        WHERE   pur.person_id                   = p_person_id AND
                                pur.encumbrance_type            = cp_encumbrance_type AND
                                pur.pen_start_dt                = cp_pen_start_dt AND
                                pur.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                                pur.pee_start_dt                = cp_pee_start_dt AND
                                pur.pee_sequence_number         = cp_pee_sequence_number AND
                                (pur.expiry_dt                  IS NULL OR
                                pur.expiry_dt                   > gcst_sysdate)
                        FOR UPDATE NOWAIT;

                --
                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                --
                CURSOR c_pfe (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pfe.*, pfe.ROWID
                        FROM    igs_pe_fund_excl                pfe
                        WHERE   pfe.person_id                   = p_person_id AND
                                pfe.encumbrance_type            = cp_encumbrance_type AND
                                pfe.pen_start_dt                = cp_pen_start_dt AND
                                pfe.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                                pfe.pee_start_dt                = cp_pee_start_dt AND
                                pfe.pee_sequence_number         = cp_pee_sequence_number AND
                                (pfe.expiry_dt                  IS NULL OR
                                pfe.expiry_dt                   > gcst_sysdate)
                        FOR UPDATE NOWAIT;
                --
                -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                --
        BEGIN
                FOR v_pen_rec IN c_pen (
                                p_expiry_dt)  LOOP
                        FOR v_pee_rec IN c_pee (
                                                v_pen_rec.encumbrance_type,
                                                v_pen_rec.start_dt,
                                                p_expiry_dt) LOOP
                                FOR v_pce_rec IN c_pce (
                                                        v_pen_rec.encumbrance_type,
                                                        v_pen_rec.start_dt,
                                                        v_pee_rec.s_encmb_effect_type,
                                                        v_pee_rec.pee_start_dt,
                                                        v_pee_rec.sequence_number) LOOP
                                    igs_pe_course_excl_pkg.UPDATE_ROW(
                                      X_ROWID                 => v_pce_rec.ROWID,
                                      X_PERSON_ID             => v_pce_rec.PERSON_ID,
                                      X_ENCUMBRANCE_TYPE      => v_pce_rec.ENCUMBRANCE_TYPE,
                                      X_PEN_START_DT          => v_pce_rec.PEN_START_DT,
                                      X_S_ENCMB_EFFECT_TYPE   => v_pce_rec.S_ENCMB_EFFECT_TYPE,
                                      X_PEE_START_DT          => v_pce_rec.PEE_START_DT,
                                      X_PEE_SEQUENCE_NUMBER   => v_pce_rec.PEE_SEQUENCE_NUMBER,
                                      X_COURSE_CD             => v_pce_rec.COURSE_CD,
                                      X_PCE_START_DT          => v_pce_rec.PCE_START_DT,
                                      X_EXPIRY_DT             => p_expiry_dt,
                                      X_MODE                  => 'R'
                                        );

                                END LOOP; -- c_pce
                                FOR v_pcge_rec IN c_pcge (
                                                        v_pen_rec.encumbrance_type,
                                                        v_pen_rec.start_dt,
                                                        v_pee_rec.s_encmb_effect_type,
                                                        v_pee_rec.pee_start_dt,
                                                        v_pee_rec.sequence_number) LOOP
                                    igs_pe_crs_grp_excl_pkg.UPDATE_ROW(
                                      X_ROWID                 => v_pcge_rec.ROWID,
                                      X_PERSON_ID             => v_pcge_rec.PERSON_ID,
                                      X_ENCUMBRANCE_TYPE      => v_pcge_rec.ENCUMBRANCE_TYPE,
                                      X_PEN_START_DT          => v_pcge_rec.PEN_START_DT,
                                      X_S_ENCMB_EFFECT_TYPE   => v_pcge_rec.S_ENCMB_EFFECT_TYPE,
                                      X_PEE_START_DT          => v_pcge_rec.PEE_START_DT,
                                      X_PEE_SEQUENCE_NUMBER   => v_pcge_rec.PEE_SEQUENCE_NUMBER,
                                      X_COURSE_GROUP_CD       => v_pcge_rec.COURSE_GROUP_CD,
                                      X_PCGE_START_DT         => v_pcge_rec.PCGE_START_DT,
                                      X_EXPIRY_DT             => p_expiry_dt,
                                      X_MODE                  => 'R'
                                        );
                                END LOOP; -- c_pcge

                                FOR v_puse_rec IN c_puse (
                                                        v_pen_rec.encumbrance_type,
                                                        v_pen_rec.start_dt,
                                                        v_pee_rec.s_encmb_effect_type,
                                                        v_pee_rec.pee_start_dt,
                                                        v_pee_rec.sequence_number) LOOP
                                    igs_pe_unt_set_excl_pkg.UPDATE_ROW(
                                      X_ROWID                 => v_puse_rec.ROWID,
                                      X_PERSON_ID             => v_puse_rec.PERSON_ID,
                                      X_ENCUMBRANCE_TYPE      => v_puse_rec.ENCUMBRANCE_TYPE,
                                      X_PEN_START_DT          => v_puse_rec.PEN_START_DT,
                                      X_S_ENCMB_EFFECT_TYPE   => v_puse_rec.S_ENCMB_EFFECT_TYPE,
                                      X_PEE_START_DT          => v_puse_rec.PEE_START_DT,
                                      X_PEE_SEQUENCE_NUMBER   => v_puse_rec.PEE_SEQUENCE_NUMBER,
                                      X_UNIT_SET_CD           => v_puse_rec.UNIT_SET_CD,
                                      X_US_VERSION_NUMBER     => v_puse_rec.US_VERSION_NUMBER,
                                      X_PUSE_START_DT         => v_puse_rec.PUSE_START_DT,
                                      X_EXPIRY_DT             => p_expiry_dt,
                                      X_MODE                  => 'R'
                                        );

                                END LOOP; -- c_puse

                                FOR v_pue_rec IN c_pue (
                                                        v_pen_rec.encumbrance_type,
                                                        v_pen_rec.start_dt,
                                                        v_pee_rec.s_encmb_effect_type,
                                                        v_pee_rec.pee_start_dt,
                                                        v_pee_rec.sequence_number) LOOP
                                    igs_pe_pers_unt_excl_pkg.UPDATE_ROW(
                                      X_ROWID                 => v_pue_rec.ROWID,
                                      X_PERSON_ID             => v_pue_rec.PERSON_ID,
                                      X_ENCUMBRANCE_TYPE      => v_pue_rec.ENCUMBRANCE_TYPE,
                                      X_PEN_START_DT          => v_pue_rec.PEN_START_DT,
                                      X_S_ENCMB_EFFECT_TYPE   => v_pue_rec.S_ENCMB_EFFECT_TYPE,
                                      X_PEE_START_DT          => v_pue_rec.PEE_START_DT,
                                      X_PEE_SEQUENCE_NUMBER   => v_pue_rec.PEE_SEQUENCE_NUMBER,
                                      X_UNIT_CD               => v_pue_rec.UNIT_CD,
                                      X_PUE_START_DT          => v_pue_rec.PUE_START_DT,
                                      X_EXPIRY_DT             => P_EXPIRY_DT,
                                      X_MODE                  => 'R'
                                        );
                                END LOOP; -- c_pue

                                FOR v_pur_rec IN c_pur (
                                                        v_pen_rec.encumbrance_type,
                                                        v_pen_rec.start_dt,
                                                        v_pee_rec.s_encmb_effect_type,
                                                        v_pee_rec.pee_start_dt,
                                                        v_pee_rec.sequence_number) LOOP
                                    igs_pe_unt_requirmnt_pkg.update_row(
                                      X_ROWID                 => v_pur_rec.ROWID,
                                      X_PERSON_ID             => v_pur_rec.PERSON_ID,
                                      X_ENCUMBRANCE_TYPE      => v_pur_rec.ENCUMBRANCE_TYPE,
                                      X_PEN_START_DT          => v_pur_rec.PEN_START_DT,
                                      X_S_ENCMB_EFFECT_TYPE   => v_pur_rec.S_ENCMB_EFFECT_TYPE,
                                      X_PEE_START_DT          => v_pur_rec.PEE_START_DT,
                                      X_PEE_SEQUENCE_NUMBER   => v_pur_rec.PEE_SEQUENCE_NUMBER,
                                      X_UNIT_CD               => v_pur_rec.UNIT_CD,
                                      X_PUR_START_DT          => v_pur_rec.PUR_START_DT,
                                      X_EXPIRY_DT             => P_EXPIRY_DT,
                                      X_MODE                  => 'R'
                                        );
                                END LOOP; -- c_pur

                                --
                                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                                --
                                FOR v_pur_rec IN c_pfe (v_pen_rec.encumbrance_type,
                                                        v_pen_rec.start_dt,
                                                        v_pee_rec.s_encmb_effect_type,
                                                        v_pee_rec.pee_start_dt,
                                                        v_pee_rec.sequence_number) LOOP
                                      igs_pe_fund_excl_pkg.update_row(
                                        X_ROWID                => v_pur_rec.rowid              ,
                                        X_FUND_EXCL_ID         => v_pur_rec.fund_excl_id       ,
                                        X_PERSON_ID            => v_pur_rec.person_id          ,
                                        X_ENCUMBRANCE_TYPE     => v_pur_rec.encumbrance_type   ,
                                        X_PEN_START_DT         => v_pur_rec.pen_start_dt       ,
                                        X_S_ENCMB_EFFECT_TYPE  => v_pur_rec.s_encmb_effect_type,
                                        X_PEE_START_DT         => v_pur_rec.pee_start_dt       ,
                                        X_PEE_SEQUENCE_NUMBER  => v_pur_rec.pee_sequence_number,
                                        X_FUND_CODE            => v_pur_rec.fund_code          ,
                                        X_PFE_START_DT         => v_pur_rec.pfe_start_dt       ,
                                        X_EXPIRY_DT            => p_expiry_dt                  ,
                                        X_MODE                 => 'R');
                                END LOOP; -- c_pfe
                                --
                                -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                                --


                                -- If the encumbrance effect is being re-opened then check for clashes.
                                IF v_pee_rec.expiry_dt IS NOT NULL AND
                                    v_pee_rec.expiry_dt <= TRUNC(SYSDATE) AND
                                    (p_expiry_dt IS NULL OR p_expiry_dt > TRUNC(SYSDATE)) THEN
                                        IF NOT IGS_PR_GEN_006.IGS_PR_upd_pen_clash (
                                                        p_person_id,
                                                        p_course_cd,
                                                        p_spo_sequence_number,
                                                        p_application_type,
                                                        v_message_text,
                                                        v_message_level) THEN
                                                p_local_message_text := v_message_text;
                                                p_local_message_level := v_message_level;
                                                RETURN FALSE;
                                        ELSIF v_message_level IS NOT NULL THEN
                                                p_local_message_text := v_message_text;
                                                p_local_message_level := v_message_level;
                                        END IF;
                                END IF;
                                igs_pe_persenc_effct_pkg.update_row(
                                  X_ROWID                         => v_pee_rec.ROWID,
                                  X_PERSON_ID                     => v_pee_rec.PERSON_ID,
                                  X_ENCUMBRANCE_TYPE              => v_pee_rec.ENCUMBRANCE_TYPE,
                                  X_PEN_START_DT                  => v_pee_rec.PEN_START_DT,
                                  X_S_ENCMB_EFFECT_TYPE           => v_pee_rec.S_ENCMB_EFFECT_TYPE,
                                  X_PEE_START_DT                  => v_pee_rec.PEE_START_DT,
                                  X_SEQUENCE_NUMBER               => v_pee_rec.SEQUENCE_NUMBER,
                                  X_EXPIRY_DT                     => P_EXPIRY_DT,
                                  X_COURSE_CD                     => v_pee_rec.COURSE_CD,
                                  X_RESTRICTED_ENROLMENT_CP       => v_pee_rec.RESTRICTED_ENROLMENT_CP,
                                  X_RESTRICTED_ATTENDANCE_TYPE    => v_pee_rec.RESTRICTED_ATTENDANCE_TYPE,
                                  X_MODE                          => 'R'
                                );
                        END LOOP; -- c_pee
                            IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW(
                              X_ROWID                         => v_pen_rec.ROWID,
                              X_PERSON_ID                     => v_pen_rec.PERSON_ID,
                              X_ENCUMBRANCE_TYPE              => v_pen_rec.ENCUMBRANCE_TYPE,
                              X_START_DT                      => v_pen_rec.START_DT,
                              X_EXPIRY_DT                     => p_expiry_dt,
                              X_AUTHORISING_PERSON_ID         => v_pen_rec.AUTHORISING_PERSON_ID,
                              X_COMMENTS                      => v_pen_rec.COMMENTS,
                              X_SPO_COURSE_CD                 => v_pen_rec.SPO_COURSE_CD,
                              X_SPO_SEQUENCE_NUMBER           => v_pen_rec.SPO_SEQUENCE_NUMBER,
                              X_CAL_TYPE                      => v_pen_rec.CAL_TYPE,
                              X_SEQUENCE_NUMBER               => v_pen_rec.SEQUENCE_NUMBER,
                              x_auth_resp_id                  => v_pen_rec.auth_resp_id,
			      x_external_reference            => v_pen_rec.external_reference,
                              X_MODE                          => 'R'
                        );

                END LOOP; -- c_pen
                RETURN TRUE;
        EXCEPTION
                WHEN e_record_locked THEN
                        IF c_pce%ISOPEN THEN
                                CLOSE c_pce;
                        END IF;
                        IF c_pcge%ISOPEN THEN
                                CLOSE c_pcge;
                        END IF;
                        IF c_puse%ISOPEN THEN
                                CLOSE c_puse;
                        END IF;
                        IF c_pue%ISOPEN THEN
                                CLOSE c_pue;
                        END IF;
                        IF c_pfe%ISOPEN THEN
                                CLOSE c_pfe;
                        END IF;
                        IF c_pur%ISOPEN THEN
                                CLOSE c_pur;
                        END IF;
                        IF c_pee%ISOPEN THEN
                                CLOSE c_pee;
                        END IF;
                        IF c_pen%ISOPEN THEN
                                CLOSE c_pen;
                        END IF;
                        IF c_seet%ISOPEN THEN
                                CLOSE c_seet;
                        END IF;
                        RETURN FALSE;
                WHEN OTHERS THEN
                        IF c_pce%ISOPEN THEN
                                CLOSE c_pce;
                        END IF;
                        IF c_pcge%ISOPEN THEN
                                CLOSE c_pcge;
                        END IF;
                        IF c_puse%ISOPEN THEN
                                CLOSE c_puse;
                        END IF;
                        IF c_pue%ISOPEN THEN
                                CLOSE c_pue;
                        END IF;
                        IF c_pur%ISOPEN THEN
                                CLOSE c_pur;
                        END IF;
                        IF c_pee%ISOPEN THEN
                                CLOSE c_pee;
                        END IF;
                        IF c_pfe%ISOPEN THEN
                                CLOSE c_pfe;
                        END IF;
                        IF c_pen%ISOPEN THEN
                                CLOSE c_pen;
                        END IF;
                        IF c_seet%ISOPEN THEN
                                CLOSE c_seet;
                        END IF;
                        RAISE;
        END;
    EXCEPTION
      WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_UPD_SPO_PEN.PRGPL_UPD_EXPIRY_DT1');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
        END prgpl_upd_expiry_dt1;


        FUNCTION prgpl_upd_expiry_dt2
        RETURN BOOLEAN
        IS
                gvl_other_detail        VARCHAR2(255);

        BEGIN   -- prgpl_upd_expiry_dt2
                -- Expire the encumbrance effect and all applicable subordinate tables
        DECLARE
                CURSOR c_pee IS
                        SELECT  pee.*,
                                pee.ROWID
                        FROM    IGS_PE_PERS_ENCUMB              pen,
                                IGS_PE_PERSENC_EFFCT    pee,
                                igs_fi_enc_dflt_eft             etde
                        WHERE   pen.person_id                   = p_person_id AND
                                pen.spo_course_cd               = p_course_cd AND
                                pen.spo_sequence_number         = p_spo_sequence_number AND
                                pen.person_id                   = pee.person_id AND
                                pen.encumbrance_type            = pee.encumbrance_type AND
                                pen.start_dt                    = pee.pen_start_dt AND
                                pee.encumbrance_type            = etde.encumbrance_type AND
                                pee.s_encmb_effect_type         <> etde.s_encmb_effect_type AND
                                (pee.expiry_dt                  IS NULL OR
                                pee.expiry_dt                   >= gcst_sysdate)
                        FOR UPDATE NOWAIT;

                CURSOR c_pce (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pce.*, pce.ROWID
                        FROM    igs_pe_course_excl              pce
                        WHERE   pce.person_id                   = p_person_id AND
                                pce.encumbrance_type            = cp_encumbrance_type AND
                                pce.pen_start_dt                = cp_pen_start_dt AND
                                pce.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                                pce.pee_start_dt                = cp_pee_start_dt AND
                                pce.pee_sequence_number         = cp_pee_sequence_number
                        FOR UPDATE NOWAIT;

                CURSOR c_pcge (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pcge.*, pcge.ROWID
                        FROM    igs_pe_crs_grp_excl     pcge
                        WHERE   pcge.person_id                  = p_person_id AND
                                pcge.encumbrance_type           = cp_encumbrance_type AND
                                pcge.pen_start_dt               = cp_pen_start_dt AND
                                pcge.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                                pcge.pee_start_dt               = cp_pee_start_dt AND
                                pcge.pee_sequence_number        = cp_pee_sequence_number
                        FOR UPDATE NOWAIT;

                CURSOR c_puse (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  puse.*, puse.ROWID
                        FROM    igs_pe_unt_set_excl     puse
                        WHERE   puse.person_id                  = p_person_id AND
                                puse.encumbrance_type           = cp_encumbrance_type AND
                                puse.pen_start_dt               = cp_pen_start_dt AND
                                puse.s_encmb_effect_type        = cp_s_encmb_effect_type AND
                                puse.pee_start_dt               = cp_pee_start_dt AND
                                puse.pee_sequence_number        = cp_pee_sequence_number
                        FOR UPDATE NOWAIT;

                CURSOR c_pue (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pue.*, pue.ROWID
                        FROM    igs_pe_pers_unt_excl            pue
                        WHERE   pue.person_id                   = p_person_id AND
                                pue.encumbrance_type            = cp_encumbrance_type AND
                                pue.pen_start_dt                = cp_pen_start_dt AND
                                pue.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                                pue.pee_start_dt                = cp_pee_start_dt AND
                                pue.pee_sequence_number         = cp_pee_sequence_number
                        FOR UPDATE NOWAIT;

                CURSOR c_pur (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pur.*, pur.ROWID
                        FROM    igs_pe_unt_requirmnt            pur
                        WHERE   pur.person_id                   = p_person_id AND
                                pur.encumbrance_type            = cp_encumbrance_type AND
                                pur.pen_start_dt                = cp_pen_start_dt AND
                                pur.s_encmb_effect_type         = cp_s_encmb_effect_type AND
                                pur.pee_start_dt                = cp_pee_start_dt AND
                                pur.pee_sequence_number         = cp_pee_sequence_number
                        FOR UPDATE NOWAIT;

                --
                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                --
                CURSOR c_pfe (
                        cp_encumbrance_type     IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
                        cp_pen_start_dt         IGS_PE_PERS_ENCUMB.start_dt%TYPE,
                        cp_s_encmb_effect_type  IGS_PE_PERSENC_EFFCT.s_encmb_effect_type%TYPE,
                        cp_pee_start_dt         IGS_PE_PERSENC_EFFCT.pee_start_dt%TYPE,
                        cp_pee_sequence_number  IGS_PE_PERSENC_EFFCT.sequence_number%TYPE) IS
                        SELECT  pfe.*, pfe.ROWID
                        FROM    IGS_PE_FUND_EXCL        pfe
                        WHERE   pfe.person_id           = p_person_id AND
                                pfe.encumbrance_type    = cp_encumbrance_type AND
                                pfe.pen_start_dt        = cp_pen_start_dt AND
                                pfe.s_encmb_effect_type = cp_s_encmb_effect_type AND
                                pfe.pee_start_dt        = cp_pee_start_dt AND
                                pfe.pee_sequence_number = cp_pee_sequence_number
                        FOR UPDATE NOWAIT;
                --
                -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                --

        BEGIN
                FOR v_pee_rec IN c_pee LOOP

                        FOR v_pce_rec IN c_pce (
                                                v_pee_rec.encumbrance_type,
                                                v_pee_rec.pen_start_dt,
                                                v_pee_rec.s_encmb_effect_type,
                                                v_pee_rec.pee_start_dt,
                                                v_pee_rec.sequence_number) LOOP
                                igs_pe_course_excl_pkg.UPDATE_ROW(
                                  X_ROWID                 => v_pce_rec.ROWID,
                                  X_PERSON_ID             => v_pce_rec.PERSON_ID,
                                  X_ENCUMBRANCE_TYPE      => v_pce_rec.ENCUMBRANCE_TYPE,
                                  X_PEN_START_DT          => v_pce_rec.PEN_START_DT,
                                  X_S_ENCMB_EFFECT_TYPE   => v_pce_rec.S_ENCMB_EFFECT_TYPE,
                                  X_PEE_START_DT          => v_pce_rec.PEE_START_DT,
                                  X_PEE_SEQUENCE_NUMBER   => v_pce_rec.PEE_SEQUENCE_NUMBER,
                                  X_COURSE_CD             => v_pce_rec.COURSE_CD,
                                  X_PCE_START_DT          => v_pce_rec.PCE_START_DT,
                                  X_EXPIRY_DT             => gcst_sysdatetime, --gjha1
                                  X_MODE                  => 'R'
                                );
                        END LOOP; -- c_pce

                        FOR v_pcge_rec IN c_pcge (
                                                v_pee_rec.encumbrance_type,
                                                v_pee_rec.pen_start_dt,
                                                v_pee_rec.s_encmb_effect_type,
                                                v_pee_rec.pee_start_dt,
                                                v_pee_rec.sequence_number) LOOP
                                igs_pe_crs_grp_excl_pkg.UPDATE_ROW(
                                  X_ROWID                 => v_pcge_rec.ROWID,
                                  X_PERSON_ID             => v_pcge_rec.PERSON_ID,
                                  X_ENCUMBRANCE_TYPE      => v_pcge_rec.ENCUMBRANCE_TYPE,
                                  X_PEN_START_DT          => v_pcge_rec.PEN_START_DT,
                                  X_S_ENCMB_EFFECT_TYPE   => v_pcge_rec.S_ENCMB_EFFECT_TYPE,
                                  X_PEE_START_DT          => v_pcge_rec.PEE_START_DT,
                                  X_PEE_SEQUENCE_NUMBER   => v_pcge_rec.PEE_SEQUENCE_NUMBER,
                                  X_COURSE_GROUP_CD       => v_pcge_rec.COURSE_GROUP_CD,
                                  X_PCGE_START_DT         => v_pcge_rec.PCGE_START_DT,
                                  X_EXPIRY_DT             => gcst_sysdatetime , --gjha1
                                  X_MODE                  => 'R'
                                );
                        END LOOP; -- c_pcge

                        FOR v_puse_rec IN c_puse (
                                                v_pee_rec.encumbrance_type,
                                                v_pee_rec.pen_start_dt,
                                                v_pee_rec.s_encmb_effect_type,
                                                v_pee_rec.pee_start_dt,
                                                v_pee_rec.sequence_number) LOOP
                                igs_pe_unt_set_excl_pkg.UPDATE_ROW(
                                  X_ROWID                 => v_puse_rec.ROWID,
                                  X_PERSON_ID             => v_puse_rec.PERSON_ID,
                                  X_ENCUMBRANCE_TYPE      => v_puse_rec.ENCUMBRANCE_TYPE,
                                  X_PEN_START_DT          => v_puse_rec.PEN_START_DT,
                                  X_S_ENCMB_EFFECT_TYPE   => v_puse_rec.S_ENCMB_EFFECT_TYPE,
                                  X_PEE_START_DT          => v_puse_rec.PEE_START_DT,
                                  X_PEE_SEQUENCE_NUMBER   => v_puse_rec.PEE_SEQUENCE_NUMBER,
                                  X_UNIT_SET_CD           => v_puse_rec.UNIT_SET_CD,
                                  X_US_VERSION_NUMBER     => v_puse_rec.US_VERSION_NUMBER,
                                  X_PUSE_START_DT         => v_puse_rec.PUSE_START_DT,
                                  X_EXPIRY_DT             => gcst_sysdatetime, --gjha1
                                  X_MODE                  => 'R'
                                );
                        END LOOP; -- c_puse

                        FOR v_pue_rec IN c_pue (
                                                v_pee_rec.encumbrance_type,
                                                v_pee_rec.pen_start_dt,
                                                v_pee_rec.s_encmb_effect_type,
                                                v_pee_rec.pee_start_dt,
                                                v_pee_rec.sequence_number) LOOP
                                igs_pe_pers_unt_excl_pkg.UPDATE_ROW(
                                  X_ROWID                 => v_pue_rec.ROWID,
                                  X_PERSON_ID             => v_pue_rec.PERSON_ID,
                                  X_ENCUMBRANCE_TYPE      => v_pue_rec.ENCUMBRANCE_TYPE,
                                  X_PEN_START_DT          => v_pue_rec.PEN_START_DT,
                                  X_S_ENCMB_EFFECT_TYPE   => v_pue_rec.S_ENCMB_EFFECT_TYPE,
                                  X_PEE_START_DT          => v_pue_rec.PEE_START_DT,
                                  X_PEE_SEQUENCE_NUMBER   => v_pue_rec.PEE_SEQUENCE_NUMBER,
                                  X_UNIT_CD               => v_pue_rec.UNIT_CD,
                                  X_PUE_START_DT          => v_pue_rec.PUE_START_DT,
                                  X_EXPIRY_DT             => gcst_sysdatetime, --gjha1
                                  X_MODE                  => 'R'
                                );
                        END LOOP; -- c_pue

                        --
                        -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                        --
                        FOR v_pfe_rec IN c_pfe (v_pee_rec.encumbrance_type,
                                                v_pee_rec.pen_start_dt,
                                                v_pee_rec.s_encmb_effect_type,
                                                v_pee_rec.pee_start_dt,
                                                v_pee_rec.sequence_number) LOOP
                                      igs_pe_fund_excl_pkg.update_row(
                                        X_ROWID                => v_pfe_rec.rowid              ,
                                        X_FUND_EXCL_ID         => v_pfe_rec.fund_excl_id       ,
                                        X_PERSON_ID            => v_pfe_rec.person_id          ,
                                        X_ENCUMBRANCE_TYPE     => v_pfe_rec.encumbrance_type   ,
                                        X_PEN_START_DT         => v_pfe_rec.pen_start_dt       ,
                                        X_S_ENCMB_EFFECT_TYPE  => v_pfe_rec.s_encmb_effect_type,
                                        X_PEE_START_DT         => v_pfe_rec.pee_start_dt       ,
                                        X_PEE_SEQUENCE_NUMBER  => v_pfe_rec.pee_sequence_number,
                                        X_FUND_CODE            => v_pfe_rec.fund_code          ,
                                        X_PFE_START_DT         => v_pfe_rec.pfe_start_dt       ,
                                        X_EXPIRY_DT            => gcst_sysdatetime             ,
                                        X_MODE                 => 'R');
                        END LOOP; -- c_pfe
                        --
                        -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                        --

                        FOR v_pur_rec IN c_pur (
                                                v_pee_rec.encumbrance_type,
                                                v_pee_rec.pen_start_dt,
                                                v_pee_rec.s_encmb_effect_type,
                                                v_pee_rec.pee_start_dt,
                                                v_pee_rec.sequence_number) LOOP
/*
                                UPDATE  igs_pe_unt_requirmnt
                                SET     expiry_dt               = gcst_sysdate
                                WHERE CURRENT OF c_pur;
*/
                                igs_pe_unt_requirmnt_pkg.UPDATE_ROW(
                                  X_ROWID                 => v_pur_rec.ROWID,
                                  X_PERSON_ID             => v_pur_rec.PERSON_ID,
                                  X_ENCUMBRANCE_TYPE      => v_pur_rec.ENCUMBRANCE_TYPE,
                                  X_PEN_START_DT          => v_pur_rec.PEN_START_DT,
                                  X_S_ENCMB_EFFECT_TYPE   => v_pur_rec.S_ENCMB_EFFECT_TYPE,
                                  X_PEE_START_DT          => v_pur_rec.PEE_START_DT,
                                  X_PEE_SEQUENCE_NUMBER   => v_pur_rec.PEE_SEQUENCE_NUMBER,
                                  X_UNIT_CD               => v_pur_rec.UNIT_CD,
                                  X_PUR_START_DT          => v_pur_rec.PUR_START_DT,
                                  X_EXPIRY_DT             => gcst_sysdatetime,--gjha1
                                  X_MODE                  => 'R'
                                );
                        END LOOP; -- c_pur
                            IGS_PE_PERSENC_EFFCT_PKG.UPDATE_ROW(
                              X_ROWID                         => v_pee_rec.ROWID,
                              X_PERSON_ID                     => v_pee_rec.PERSON_ID,
                              X_ENCUMBRANCE_TYPE              => v_pee_rec.ENCUMBRANCE_TYPE,
                              X_PEN_START_DT                  => v_pee_rec.PEN_START_DT,
                              X_S_ENCMB_EFFECT_TYPE           => v_pee_rec.S_ENCMB_EFFECT_TYPE,
                              X_PEE_START_DT                  => v_pee_rec.PEE_START_DT,
                              X_SEQUENCE_NUMBER               => v_pee_rec.SEQUENCE_NUMBER,
                              X_EXPIRY_DT                     => gcst_sysdatetime, --updated
                              X_COURSE_CD                     => v_pee_rec.COURSE_CD,
                              X_RESTRICTED_ENROLMENT_CP       => v_pee_rec.RESTRICTED_ENROLMENT_CP,
                              X_RESTRICTED_ATTENDANCE_TYPE    => v_pee_rec.RESTRICTED_ATTENDANCE_TYPE,
                              X_MODE                          => 'R'
                        );
                END LOOP; -- c_pee
                RETURN TRUE;
        EXCEPTION
                WHEN e_record_locked THEN
                        IF c_pce%ISOPEN THEN
                                CLOSE c_pce;
                        END IF;
                        IF c_pcge%ISOPEN THEN
                                CLOSE c_pcge;
                        END IF;
                        IF c_puse%ISOPEN THEN
                                CLOSE c_puse;
                        END IF;
                        IF c_pue%ISOPEN THEN
                                CLOSE c_pue;
                        END IF;
                        IF c_pur%ISOPEN THEN
                                CLOSE c_pur;
                        END IF;
                        IF c_pee%ISOPEN THEN
                                CLOSE c_pee;
                        END IF;
                        IF c_pfe%ISOPEN THEN
                                CLOSE c_pfe;
                        END IF;
                        RETURN FALSE;
                WHEN OTHERS THEN
                        IF c_pce%ISOPEN THEN
                                CLOSE c_pce;
                        END IF;
                        IF c_pcge%ISOPEN THEN
                                CLOSE c_pcge;
                        END IF;
                        IF c_puse%ISOPEN THEN
                                CLOSE c_puse;
                        END IF;
                        IF c_pue%ISOPEN THEN
                                CLOSE c_pue;
                        END IF;
                        IF c_pur%ISOPEN THEN
                                CLOSE c_pur;
                        END IF;
                        IF c_pee%ISOPEN THEN
                                CLOSE c_pee;
                        END IF;
                        IF c_seet%ISOPEN THEN
                                CLOSE c_seet;
                        END IF;
                        IF c_pfe%ISOPEN THEN
                                CLOSE c_pfe;
                        END IF;
                        RAISE;
        END;
    EXCEPTION
      WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_UPD_SPO_PEN.PRGPL_UPD_EXPIRY_DT2');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
    END prgpl_upd_expiry_dt2;

BEGIN

        SAVEPOINT sp_before_update;
        OPEN c_spo;
        FETCH c_spo INTO v_spo_rec;
        IF c_spo%NOTFOUND THEN
                CLOSE c_spo;
                RETURN TRUE;
        END IF;
        CLOSE c_spo;

        -- Check that authorising person ID is set ; if not, then set to current
        -- person ID (which is likely to be a batch queue user).
        IF p_authorising_person_id IS NULL THEN
                OPEN c_pe;
                FETCH c_pe INTO v_authorising_person_id;
                IF c_pe%NOTFOUND THEN
                        CLOSE c_pe;
--                      p_message_text := IGS_GE_GEN_002.GENP_GET_MESSAGE(5274);
                        p_message_level := cst_error;
                        RETURN FALSE;
                END IF;
                CLOSE c_pe;
        ELSE
                v_authorising_person_id := p_authorising_person_id;
        END IF;

        OPEN c_pen;
        FETCH c_pen INTO v_pen_expiry_dt;
        IF c_pen%FOUND THEN
                CLOSE c_pen;
                v_pen_exists := TRUE;
        ELSE
                CLOSE c_pen;
                v_pen_exists := FALSE;
        END IF;

        IF v_spo_rec.decision_status IN (
                                        cst_cancelled,
                                        cst_removed,
                                        cst_pending,
                                        cst_waived) OR
                        v_spo_rec.encumbrance_type IS NULL THEN
                IF v_pen_exists THEN
                        -- If the outcome has been cancelled then expire the encumbrance effective
                        -- immediately
                        IF NOT prgpl_upd_expiry_dt1 (gcst_sysdatetime, --gjha1
                                                v_message_level,
                                                v_message_text) THEN
                                -- Record locked
                                ROLLBACK TO sp_before_update;
                                p_message_level := cst_error;
                                RETURN FALSE;
                        END IF;
                END IF;
                RETURN TRUE;
        ELSE

                -- Select encumbrances resulting
                v_etde_index := 0;
                FOR v_edte_rec IN c_etde (v_spo_rec.encumbrance_type) LOOP
                        v_etde_index := v_etde_index + 1;
                        v_etde_table(v_etde_index).s_encmb_effect_type := v_edte_rec.s_encmb_effect_type;
                END LOOP; -- c_etde

                IF v_pen_exists THEN
                        -- Remove effects that no longer apply
                        IF NOT prgpl_upd_expiry_dt2 THEN
                                -- Record locked
                                ROLLBACK TO sp_before_update;
                        --      p_message_text := IGS_GE_GEN_002.GENP_GET_MESSAGE(5273);
                                p_message_level := cst_error;
                                RETURN FALSE;
                        END IF;
                        -- Alter expiry date of person encumbrance structures where required

                        IF v_spo_rec.expiry_dt <= TRUNC(SYSDATE) THEN
                                v_expiry_status := IGS_PR_GEN_006.IGS_PR_get_spo_expiry (
                                                                p_person_id,
                                                                p_course_cd,
                                                                p_spo_sequence_number,
                                                                v_spo_rec.expiry_dt,
                                                                v_expiry_dt);

                        ELSE

                                -- Don't pass the spo.expiry_dt forcing re-derivation ; this will CHECK FOR
                                -- differences.
                                v_expiry_status := IGS_PR_get_spo_expiry (
                                                                p_person_id,
                                                                p_course_cd,
                                                                p_spo_sequence_number,
                                                                NULL,
                                                                v_expiry_dt);
                        END IF;

                        IF NVL(v_pen_expiry_dt,IGS_GE_DATE.IGSDATE('9999/01/01')) <>
                            NVL(v_expiry_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) THEN
                                IF NVL(v_expiry_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) < gcst_sysdate THEN
                                        v_action_expiry_dt := gcst_sysdatetime;
                                ELSE
                                        v_action_expiry_dt := v_expiry_dt;
                                END IF;
                                -- Update the elements of the structure to reflect the new expiry date
                                IF NOT prgpl_upd_expiry_dt1 (v_action_expiry_dt,
                                                        v_message_level,
                                                        v_message_text) THEN
                                        ROLLBACK TO sp_before_update;
                                        IF v_message_level IS NOT NULL THEN
                                                -- Encumbrance clash.
                                                p_message_text := v_message_text;
                                                p_message_level := v_message_level;
                                        ELSE

                                        -- Record locked
                                        --      p_message_text := IGS_GE_GEN_002.GENP_GET_MESSAGE(5273);
                                                p_message_level := cst_error;
                                        END IF;
                                        RETURN FALSE;
                                ELSIF v_message_level IS NOT NULL THEN
                                        -- Encumbrance warning only.
                                        IF p_message_level IS NULL OR
                                                        v_message_level = cst_expired THEN
                                                p_message_text := v_message_text;
                                                p_message_level := v_message_level;
                                        END IF;
                                END IF;
                        END IF;
                        IF v_expiry_dt < gcst_sysdate THEN
                                v_expiry_dt := gcst_sysdatetime;
                        END IF;

                        -- Alter effects that currently exist where required
                        FOR v_pee_rec IN c_pee LOOP

                                IF v_pee_rec.s_encmb_effect_type IN (
                                                                cst_rstr_ge_cp,
                                                                cst_rstr_le_cp) AND
                                                NVL(v_pee_rec.restricted_enrolment_cp, -1) <>
                                                NVL(v_spo_rec.restricted_enrolment_cp, -1) THEN

                                            IGS_PE_PERSENC_EFFCT_PKG.UPDATE_ROW(
                                              X_ROWID                         => v_pee_rec.ROWID,
                                              X_PERSON_ID                     => v_pee_rec.PERSON_ID,
                                              X_ENCUMBRANCE_TYPE              => v_pee_rec.ENCUMBRANCE_TYPE,
                                              X_PEN_START_DT                  => v_pee_rec.PEN_START_DT,
                                              X_S_ENCMB_EFFECT_TYPE           => v_pee_rec.S_ENCMB_EFFECT_TYPE,
                                              X_PEE_START_DT                  => v_pee_rec.PEE_START_DT,
                                              X_SEQUENCE_NUMBER               => v_pee_rec.SEQUENCE_NUMBER,
                                              X_EXPIRY_DT                     => v_expiry_dt, --updated
                                              X_COURSE_CD                     => v_pee_rec.COURSE_CD,
                                              X_RESTRICTED_ENROLMENT_CP       => v_spo_rec.restricted_enrolment_cp, --updated
                                              X_RESTRICTED_ATTENDANCE_TYPE    => v_pee_rec.RESTRICTED_ATTENDANCE_TYPE,
                                              X_MODE                          => 'R'
                                        );


                                ELSIF v_pee_rec.s_encmb_effect_type = cst_rstr_at_ty AND
                                                NVL(v_pee_rec.restricted_attendance_type,'NULL') <>
                                                NVL(v_spo_rec.restricted_attendance_type,'NULL') AND
                                                v_spo_rec.closed_ind = 'N' THEN

                                            IGS_PE_PERSENC_EFFCT_PKG.UPDATE_ROW(
                                              X_ROWID                         => v_pee_rec.ROWID,
                                              X_PERSON_ID                     => v_pee_rec.PERSON_ID,
                                              X_ENCUMBRANCE_TYPE              => v_pee_rec.ENCUMBRANCE_TYPE,
                                              X_PEN_START_DT                  => v_pee_rec.PEN_START_DT,
                                              X_S_ENCMB_EFFECT_TYPE           => v_pee_rec.S_ENCMB_EFFECT_TYPE,
                                              X_PEE_START_DT                  => v_pee_rec.PEE_START_DT,
                                              X_SEQUENCE_NUMBER               => v_pee_rec.SEQUENCE_NUMBER,
                                              X_EXPIRY_DT                     => v_expiry_dt, --updated
                                              X_COURSE_CD                     => v_pee_rec.COURSE_CD,
                                              X_RESTRICTED_ENROLMENT_CP       => v_pee_rec.restricted_enrolment_cp,
                                              X_RESTRICTED_ATTENDANCE_TYPE    => v_spo_rec.restricted_attendance_type, --updated
                                              X_MODE                          => 'R'
                                        );


                                ELSIF v_pee_rec.s_encmb_effect_type IN (
                                                                        cst_sus_course,
                                                                        cst_exc_course) THEN
                                        -- Add spc.course_cd's TO spc PL/SQL TABLE
                                        v_spc_index := 0;

                                        FOR v_spc_rec IN c_spc LOOP
                                                v_spc_index := v_spc_index + 1;
                                                v_spc_table(v_spc_index) := v_spc_rec.course_cd;
                                        END LOOP; -- c_spc

                                        v_pce_index := 0;
                                        FOR v_pce_rec IN c_pce (
                                                                v_pee_rec.encumbrance_type,
                                                                v_pee_rec.pen_start_dt,
                                                                v_pee_rec.s_encmb_effect_type,
                                                                v_pee_rec.pee_start_dt,
                                                                v_pee_rec.sequence_number) LOOP
                                                -- Add pce.course_cd to pce PL/SQL table
                                                v_pce_index := v_pce_index + 1;
                                                v_pce_table(v_pce_index) := v_pce_rec.course_cd;

                                                -- Check if pce.course_cd in spc PL/SQL table
                                                v_course_cd_found := FALSE;
                                                FOR v_index1 IN 1..v_spc_index LOOP
                                                        IF v_spc_table(v_index1) = v_pce_rec.course_cd THEN
                                                                v_course_cd_found := TRUE;
                                                                EXIT;
                                                        END IF;

                                                END LOOP;
                                                IF NOT v_course_cd_found THEN

                                                            igs_pe_course_excl_pkg.UPDATE_ROW(
                                                              X_ROWID                 => v_pce_rec.ROWID,
                                                              X_PERSON_ID             => v_pce_rec.PERSON_ID,
                                                              X_ENCUMBRANCE_TYPE      => v_pce_rec.ENCUMBRANCE_TYPE,
                                                              X_PEN_START_DT          => v_pce_rec.PEN_START_DT,
                                                              X_S_ENCMB_EFFECT_TYPE   => v_pce_rec.S_ENCMB_EFFECT_TYPE,
                                                              X_PEE_START_DT          => v_pce_rec.PEE_START_DT,
                                                              X_PEE_SEQUENCE_NUMBER   => v_pce_rec.PEE_SEQUENCE_NUMBER,
                                                              X_COURSE_CD             => v_pce_rec.COURSE_CD,
                                                              X_PCE_START_DT          => v_pce_rec.PCE_START_DT,
                                                              X_EXPIRY_DT             => gcst_sysdatetime,
                                                              X_MODE                  => 'R'
                                                        );


                                                END IF;
                                        END LOOP; -- c_pce
                                        -- Check if all spc.course_cd's IN pce PL/SQL TABLE, IF NOT ADD NEW
                                        -- pce record
                                        FOR v_index1 IN 1..v_spc_index LOOP
                                                v_course_cd_found := FALSE;
                                                FOR v_index2 IN 1..v_pce_index LOOP
                                                        IF v_spc_table(v_index1) = v_pce_table(v_index2) THEN
                                                                v_course_cd_found := TRUE;
                                                                EXIT;
                                                        END IF;
                                                END LOOP;
                                                IF NOT v_course_cd_found THEN

                                                        OPEN c_pce_dup (
                                                                v_pee_rec.encumbrance_type,
                                                                v_pee_rec.pen_start_dt,
                                                                v_pee_rec.s_encmb_effect_type,
                                                                v_pee_rec.pee_start_dt,
                                                                v_pee_rec.sequence_number,
                                                                v_spc_table(v_index1),
                                                                gcst_sysdate);
                                                        FETCH c_pce_dup INTO v_pce_dup_rec;
                                                        IF c_pce_dup%FOUND THEN
                                                                -- Re-open closed record.

                                                                igs_pe_course_excl_pkg.UPDATE_ROW(
                                                                  X_ROWID                 => v_pce_dup_rec.ROWID,
                                                                  X_PERSON_ID             => v_pce_dup_rec.PERSON_ID,
                                                                  X_ENCUMBRANCE_TYPE      => v_pce_dup_rec.ENCUMBRANCE_TYPE,
                                                                  X_PEN_START_DT          => v_pce_dup_rec.PEN_START_DT,
                                                                  X_S_ENCMB_EFFECT_TYPE   => v_pce_dup_rec.S_ENCMB_EFFECT_TYPE,
                                                                  X_PEE_START_DT          => v_pce_dup_rec.PEE_START_DT,
                                                                  X_PEE_SEQUENCE_NUMBER   => v_pce_dup_rec.PEE_SEQUENCE_NUMBER,
                                                                  X_COURSE_CD             => v_pce_dup_rec.COURSE_CD,
                                                                  X_PCE_START_DT          => v_pce_dup_rec.PCE_START_DT,
                                                                  X_EXPIRY_DT             => v_expiry_dt,
                                                                  X_MODE                  => 'R'
                                                                );


                                                                CLOSE c_pce_dup;
                                                        ELSE
                                                                CLOSE c_pce_dup;
                                                                /*INSERT INTO igs_pe_course_excl (
                                                                        person_id,
                                                                        encumbrance_type,
                                                                        pen_start_dt,
                                                                        s_encmb_effect_type,
                                                                        pee_start_dt,
                                                                        pee_sequence_number,
                                                                        course_cd,
                                                                        pce_start_dt,
                                                                        expiry_dt)
                                                                VALUES (
                                                                        p_person_id,
                                                                        v_pee_rec.encumbrance_type,
                                                                        v_pee_rec.pen_start_dt,
                                                                        v_pee_rec.s_encmb_effect_type,
                                                                        v_pee_rec.pee_start_dt,
                                                                        v_pee_rec.sequence_number,
                                                                        v_spc_table(v_index1),
                                                                        gcst_sysdate,
                                                                        v_expiry_dt); */
                                                                        DECLARE
                                                                        lv_rowid VARCHAR2(25);
                                                                        BEGIN
                                                                          BEGIN
                                                                                  igs_pe_course_excl_pkg.INSERT_ROW (
                                                                                        X_ROWID =>lv_rowid,
                                                                                        X_PERSON_ID =>p_person_id,
                                                                                        X_ENCUMBRANCE_TYPE =>v_pee_rec.encumbrance_type,
                                                                                        X_PEN_START_DT =>v_pee_rec.pen_start_dt,
                                                                                        X_S_ENCMB_EFFECT_TYPE =>v_pee_rec.s_encmb_effect_type,
                                                                                        X_PEE_START_DT =>v_pee_rec.pee_start_dt,
                                                                                        X_PEE_SEQUENCE_NUMBER =>v_pee_rec.sequence_number,
                                                                                        X_COURSE_CD =>v_spc_table(v_index1),
                                                                                        X_PCE_START_DT =>gcst_sysdatetime, ---- GJHA Changed it from gcst_sysdate
                                                                                        X_EXPIRY_DT =>v_expiry_dt,
                                                                                        X_MODE =>'R'
                                                                                      );
                                                                        EXCEPTION WHEN OTHERS THEN
                                                                          RAISE;
                                                                        END;
                                                                    END;
                                                        END IF;
                                                END IF;
                                        END LOOP;
                                ELSIF v_pee_rec.s_encmb_effect_type = cst_exc_crs_gp THEN
                                        v_pcge_index := 0;
                                        FOR v_pcge_rec IN c_pcge (
                                                                v_pee_rec.encumbrance_type,
                                                                v_pee_rec.pen_start_dt,
                                                                v_pee_rec.s_encmb_effect_type,
                                                                v_pee_rec.pee_start_dt,
                                                                v_pee_rec.sequence_number) LOOP
                                                -- Add pcge.course_cd to pcge PL/SQL table
                                                v_pcge_index := v_pcge_index + 1;
                                                v_pcge_table(v_pcge_index) := v_pcge_rec.course_group_cd;
                                                IF v_pcge_rec.course_group_cd <> v_spo_rec.encmb_course_group_cd THEN
                                                    igs_pe_crs_grp_excl_pkg.UPDATE_ROW(
                                                      X_ROWID                 => v_pcge_rec.ROWID,
                                                      X_PERSON_ID             => v_pcge_rec.PERSON_ID,
                                                      X_ENCUMBRANCE_TYPE      => v_pcge_rec.ENCUMBRANCE_TYPE,
                                                      X_PEN_START_DT          => v_pcge_rec.PEN_START_DT,
                                                      X_S_ENCMB_EFFECT_TYPE   => v_pcge_rec.S_ENCMB_EFFECT_TYPE,
                                                      X_PEE_START_DT          => v_pcge_rec.PEE_START_DT,
                                                      X_PEE_SEQUENCE_NUMBER   => v_pcge_rec.PEE_SEQUENCE_NUMBER,
                                                      X_COURSE_GROUP_CD       => v_pcge_rec.COURSE_GROUP_CD,
                                                      X_PCGE_START_DT         => v_pcge_rec.PCGE_START_DT,
                                                      X_EXPIRY_DT             => gcst_sysdatetime,
                                                      X_MODE                  => 'R'
                                                        );
                                                END IF;
                                        END LOOP; -- c_pcge
                                        -- Check if spo.course_group_cd in pcge PL/SQL table, if not add new
                                        -- pcge record
                                        v_course_grp_cd_found := FALSE;
                                        FOR v_index1 IN 1..v_pcge_index LOOP
                                                IF v_pcge_table(v_index1) = v_spo_rec.encmb_course_group_cd THEN
                                                        v_course_grp_cd_found := TRUE;
                                                        EXIT;
                                                END IF;
                                        END LOOP;
                                        IF NOT v_course_grp_cd_found THEN
                                                OPEN c_pcge_dup (
                                                                v_pee_rec.encumbrance_type,
                                                                v_pee_rec.pen_start_dt,
                                                                v_pee_rec.s_encmb_effect_type,
                                                                v_pee_rec.pee_start_dt,
                                                                v_pee_rec.sequence_number,
                                                                v_spo_rec.encmb_course_group_cd,
                                                                gcst_sysdate);
                                                FETCH c_pcge_dup INTO v_pcge_dup_rec;
                                                IF c_pcge_dup%FOUND THEN
                                                    igs_pe_crs_grp_excl_pkg.UPDATE_ROW(
                                                      X_ROWID                 => v_pcge_dup_rec.ROWID,
                                                      X_PERSON_ID             => v_pcge_dup_rec.PERSON_ID,
                                                      X_ENCUMBRANCE_TYPE      => v_pcge_dup_rec.ENCUMBRANCE_TYPE,
                                                      X_PEN_START_DT          => v_pcge_dup_rec.PEN_START_DT,
                                                      X_S_ENCMB_EFFECT_TYPE   => v_pcge_dup_rec.S_ENCMB_EFFECT_TYPE,
                                                      X_PEE_START_DT          => v_pcge_dup_rec.PEE_START_DT,
                                                      X_PEE_SEQUENCE_NUMBER   => v_pcge_dup_rec.PEE_SEQUENCE_NUMBER,
                                                      X_COURSE_GROUP_CD       => v_pcge_dup_rec.COURSE_GROUP_CD,
                                                      X_PCGE_START_DT         => v_pcge_dup_rec.PCGE_START_DT,
                                                      X_EXPIRY_DT             => v_expiry_dt,
                                                      X_MODE                  => 'R'
                                                        );
                                                        CLOSE c_pcge_dup;
                                                ELSE
                                                        CLOSE c_pcge_dup;
                                                          DECLARE
                                                            lv_rowid VARCHAR2(25);
                                                          BEGIN
                                                            igs_pe_crs_grp_excl_pkg.INSERT_ROW(
                                                              X_ROWID                 => lv_rowid,
                                                              X_PERSON_ID             => P_PERSON_ID,
                                                              X_ENCUMBRANCE_TYPE      => v_pee_rec.ENCUMBRANCE_TYPE,
                                                              X_PEN_START_DT          => v_pee_rec.PEN_START_DT,
                                                              X_S_ENCMB_EFFECT_TYPE   => v_pee_rec.S_ENCMB_EFFECT_TYPE,
                                                              X_PEE_START_DT          => v_pee_rec.PEE_START_DT,
                                                              X_PEE_SEQUENCE_NUMBER   => v_pee_rec.SEQUENCE_NUMBER,
                                                              X_COURSE_GROUP_CD       => v_spo_rec.encmb_course_group_cd,
                                                              X_PCGE_START_DT         => gcst_sysdatetime, --gjha Changed it from gcst_sysdate
                                                              X_EXPIRY_DT             => v_expiry_dt,
                                                              X_MODE                  => 'R'
                                                            );
                                                          END;
                                                END IF;
                                        END IF;
                                ELSIF v_pee_rec.s_encmb_effect_type = cst_exc_crs_us THEN
                                        -- Add spus.course_cd's TO spus PL/SQL TABLE
                                        v_spus_index := 0;
                                        FOR v_spus_rec IN c_spus LOOP
                                                v_spus_index := v_spus_index + 1;
                                                v_spus_table(v_spus_index).unit_set_cd := v_spus_rec.unit_set_cd;
                                                v_spus_table(v_spus_index).version_number := v_spus_rec.version_number;
                                        END LOOP; -- c_spus
                                        v_puse_index := 0;
                                        FOR v_puse_rec IN c_puse (
                                                                v_pee_rec.encumbrance_type,
                                                                v_pee_rec.pen_start_dt,
                                                                v_pee_rec.s_encmb_effect_type,
                                                                v_pee_rec.pee_start_dt,
                                                                v_pee_rec.sequence_number) LOOP
                                                -- Add puse.unit_set_cd, us_version_number to pce PL/SQL table
                                                v_puse_index := v_puse_index + 1;
                                                v_puse_table(v_puse_index).unit_set_cd := v_puse_rec.unit_set_cd;
                                                v_puse_table(v_puse_index).us_version_number :=
                                                                                        v_puse_rec.us_version_number;
                                                -- Check if unit set in spus PL/SQL table
                                                v_unit_set_found := FALSE;
                                                FOR v_index1 IN 1..v_spus_index LOOP
                                                        IF v_spus_table(v_index1).unit_set_cd = v_puse_rec.unit_set_cd AND
                                                                        v_spus_table(v_index1).version_number =
                                                                        v_puse_rec.us_version_number THEN
                                                                v_unit_set_found := TRUE;
                                                                EXIT;
                                                        END IF;
                                                END LOOP;

                                                IF NOT v_unit_set_found THEN
                                                    igs_pe_unt_set_excl_pkg.UPDATE_ROW(
                                                      X_ROWID                 => v_puse_rec.ROWID,
                                                      X_PERSON_ID             => v_puse_rec.PERSON_ID,
                                                      X_ENCUMBRANCE_TYPE      => v_puse_rec.ENCUMBRANCE_TYPE,
                                                      X_PEN_START_DT          => v_puse_rec.PEN_START_DT,
                                                      X_S_ENCMB_EFFECT_TYPE   => v_puse_rec.S_ENCMB_EFFECT_TYPE,
                                                      X_PEE_START_DT          => v_puse_rec.PEE_START_DT,
                                                      X_PEE_SEQUENCE_NUMBER   => v_puse_rec.PEE_SEQUENCE_NUMBER,
                                                      X_UNIT_SET_CD           => v_puse_rec.UNIT_SET_CD,
                                                      X_US_VERSION_NUMBER     => v_puse_rec.US_VERSION_NUMBER,
                                                      X_PUSE_START_DT         => v_puse_rec.PUSE_START_DT,
                                                      X_EXPIRY_DT             => gcst_sysdate,
                                                      X_MODE                  => 'R'
                                                        );

                                                END IF;
                                        END LOOP; -- c_puse
                                        -- Check if all spus unit sets in puse PL/SQL table, if not add new
                                        -- puse record
                                        FOR v_index1 IN 1..v_spus_index LOOP
                                                v_unit_set_found := FALSE;
                                                FOR v_index2 IN 1..v_puse_index LOOP
                                                        IF v_spus_table(v_index1).unit_set_cd =
                                                                        v_puse_table(v_index2).unit_set_cd AND
                                                                        v_spus_table(v_index1).version_number =
                                                                        v_puse_table(v_index2).us_version_number THEN
                                                                v_unit_set_found := TRUE;
                                                                EXIT;
                                                        END IF;
                                                END LOOP;
                                                IF NOT v_unit_set_found THEN
                                                        OPEN c_puse_dup (
                                                                        v_pee_rec.encumbrance_type,
                                                                        v_pee_rec.pen_start_dt,
                                                                        v_pee_rec.s_encmb_effect_type,
                                                                        v_pee_rec.pee_start_dt,
                                                                        v_pee_rec.sequence_number,
                                                                        v_spus_table(v_index1).unit_set_cd,
                                                                        v_spus_table(v_index1).version_number,
                                                                        gcst_sysdate);
                                                        FETCH c_puse_dup INTO v_puse_dup_rec;
                                                        IF c_puse_dup%FOUND THEN
                                                                igs_pe_unt_set_excl_pkg.UPDATE_ROW(
                                                                  X_ROWID                 => v_puse_dup_rec.ROWID,
                                                                  X_PERSON_ID             => v_puse_dup_rec.PERSON_ID,
                                                                  X_ENCUMBRANCE_TYPE      => v_puse_dup_rec.ENCUMBRANCE_TYPE,
                                                                  X_PEN_START_DT          => v_puse_dup_rec.PEN_START_DT,
                                                                  X_S_ENCMB_EFFECT_TYPE   => v_puse_dup_rec.S_ENCMB_EFFECT_TYPE,
                                                                  X_PEE_START_DT          => v_puse_dup_rec.PEE_START_DT,
                                                                  X_PEE_SEQUENCE_NUMBER   => v_puse_dup_rec.PEE_SEQUENCE_NUMBER,
                                                                  X_UNIT_SET_CD           => v_puse_dup_rec.UNIT_SET_CD,
                                                                  X_US_VERSION_NUMBER     => v_puse_dup_rec.US_VERSION_NUMBER,
                                                                  X_PUSE_START_DT         => v_puse_dup_rec.PUSE_START_DT,
                                                                  X_EXPIRY_DT             => v_EXPIRY_DT,
                                                                  X_MODE                  => 'R'
                                                                );

                                                                CLOSE c_puse_dup;
                                                        ELSE
                                                          CLOSE c_puse_dup;
                                                                DECLARE
                                                                lv_rowid VARCHAR2(25);
                                                                BEGIN
                                                                igs_pe_unt_set_excl_pkg.INSERT_ROW (
                                                                      X_ROWID =>lv_rowid,
                                                                      X_PERSON_ID =>p_person_id,
                                                                      X_ENCUMBRANCE_TYPE=> v_pee_rec.encumbrance_type,
                                                                      X_PEN_START_DT=> v_pee_rec.pen_start_dt,
                                                                      X_S_ENCMB_EFFECT_TYPE =>v_pee_rec.s_encmb_effect_type,
                                                                      X_PEE_START_DT =>v_pee_rec.pee_start_dt,
                                                                      X_PEE_SEQUENCE_NUMBER =>v_pee_rec.sequence_number,
                                                                      X_UNIT_SET_CD =>v_spus_table(v_index1).unit_set_cd,
                                                                      X_US_VERSION_NUMBER =>v_spus_table(v_index1).version_number,
                                                                      X_PUSE_START_DT =>gcst_sysdatetime, -- GJHA Changed it from gcst_sysdate
                                                                      X_EXPIRY_DT =>v_expiry_dt,
                                                                      X_MODE =>'R'
                                                                      );
                                                                    END;
                                                        END IF;
                                                END IF;
                                        END LOOP;
                                ELSIF v_pee_rec.s_encmb_effect_type = cst_exc_crs_u THEN
                                        -- Add spu.unit_cd's TO spu PL/SQL TABLE
                                        v_spu_index := 0;
                                        FOR v_spu_rec IN c_spu (cst_excluded) LOOP
                                                v_spu_index := v_spu_index + 1;
                                                v_spu_table(v_spu_index) := v_spu_rec.unit_cd;
                                        END LOOP; -- c_spu
                                        v_pue_index := 0;
                                        FOR v_pue_rec IN c_pue (
                                                                v_pee_rec.encumbrance_type,
                                                                v_pee_rec.pen_start_dt,
                                                                v_pee_rec.s_encmb_effect_type,
                                                                v_pee_rec.pee_start_dt,
                                                                v_pee_rec.sequence_number) LOOP
                                                -- Add pue.unit_cd to pue PL/SQL table
                                                v_pue_index := v_pue_index + 1;
                                                v_pue_table(v_pue_index) := v_pue_rec.unit_cd;
                                                -- Check if pue.unit_cd in spu PL/SQL table
                                                v_unit_cd_found := FALSE;
                                                FOR v_index1 IN 1..v_spu_index LOOP
                                                        IF v_spu_table(v_index1) = v_pue_rec.unit_cd THEN
                                                                v_unit_cd_found := TRUE;
                                                                EXIT;
                                                        END IF;
                                                END LOOP;
                                                IF NOT v_unit_cd_found THEN
                                                    igs_pe_pers_unt_excl_pkg.UPDATE_ROW(
                                                      X_ROWID                 => v_pue_rec.ROWID,
                                                      X_PERSON_ID             => v_pue_rec.PERSON_ID,
                                                      X_ENCUMBRANCE_TYPE      => v_pue_rec.ENCUMBRANCE_TYPE,
                                                      X_PEN_START_DT          => v_pue_rec.PEN_START_DT,
                                                      X_S_ENCMB_EFFECT_TYPE   => v_pue_rec.S_ENCMB_EFFECT_TYPE,
                                                      X_PEE_START_DT          => v_pue_rec.PEE_START_DT,
                                                      X_PEE_SEQUENCE_NUMBER   => v_pue_rec.PEE_SEQUENCE_NUMBER,
                                                      X_UNIT_CD               => v_pue_rec.UNIT_CD,
                                                      X_PUE_START_DT          => v_pue_rec.PUE_START_DT,
                                                      X_EXPIRY_DT             => gcst_sysdatetime,
                                                      X_MODE                  => 'R'
                                                        );

                                                END IF;
                                        END LOOP; -- c_pue
                                        -- Check if all spu.unit_cd's IN pue PL/SQL TABLE, IF NOT ADD NEW
                                        -- pue record
                                        FOR v_index1 IN 1..v_spu_index LOOP
                                                v_unit_cd_found := FALSE;
                                                FOR v_index2 IN 1..v_pue_index LOOP
                                                        IF v_spu_table(v_index1) = v_pue_table(v_index2) THEN
                                                                v_unit_cd_found := TRUE;
                                                                EXIT;
                                                        END IF;
                                                END LOOP;
                                                IF NOT v_unit_cd_found THEN
                                                        OPEN c_pue_dup (
                                                                        v_pee_rec.encumbrance_type,
                                                                        v_pee_rec.pen_start_dt,
                                                                        v_pee_rec.s_encmb_effect_type,
                                                                        v_pee_rec.pee_start_dt,
                                                                        v_pee_rec.sequence_number,
                                                                        v_spu_table(v_index1),
                                                                        gcst_sysdate);
                                                        FETCH c_pue_dup INTO v_pue_dup_rec;
                                                        IF c_pue_dup%FOUND THEN
                                                                igs_pe_pers_unt_excl_pkg.UPDATE_ROW(
                                                                   X_ROWID                 => v_pue_dup_rec.ROWID,
                                                                   X_PERSON_ID             => v_pue_dup_rec.PERSON_ID,
                                                                   X_ENCUMBRANCE_TYPE      => v_pue_dup_rec.ENCUMBRANCE_TYPE,
                                                                   X_PEN_START_DT          => v_pue_dup_rec.PEN_START_DT,
                                                                   X_S_ENCMB_EFFECT_TYPE   => v_pue_dup_rec.S_ENCMB_EFFECT_TYPE,
                                                                   X_PEE_START_DT          => v_pue_dup_rec.PEE_START_DT,
                                                                   X_PEE_SEQUENCE_NUMBER   => v_pue_dup_rec.PEE_SEQUENCE_NUMBER,
                                                                   X_UNIT_CD               => v_pue_dup_rec.UNIT_CD,
                                                                   X_PUE_START_DT          => v_pue_dup_rec.PUE_START_DT,
                                                                   X_EXPIRY_DT             => v_expiry_dt,
                                                                   X_MODE                  => 'R'
                                                                 );
                                                                CLOSE c_pue_dup;
                                                        ELSE
                                                                CLOSE c_pue_dup;
                                                                        DECLARE
                                                                        LV_ROWID VARCHAR2(25);
                                                                        BEGIN
                                                                        igs_pe_pers_unt_excl_PKG.INSERT_ROW (
                                                                              X_ROWID =>LV_ROWID,
                                                                              X_PERSON_ID =>p_person_id,
                                                                              X_ENCUMBRANCE_TYPE =>v_pee_rec.encumbrance_type,
                                                                              X_PEN_START_DT =>v_pee_rec.pen_start_dt,
                                                                              X_S_ENCMB_EFFECT_TYPE =>v_pee_rec.s_encmb_effect_type,
                                                                              X_PEE_START_DT =>v_pee_rec.pee_start_dt,
                                                                              X_PEE_SEQUENCE_NUMBER =>v_pee_rec.sequence_number,
                                                                              X_UNIT_CD =>v_spu_table(v_index1),
                                                                              X_PUE_START_DT =>gcst_sysdatetime, --GJHA Changed it from gcst_sysdate
                                                                              X_EXPIRY_DT=>v_expiry_dt,
                                                                              X_MODE =>'R'
                                                                              );
                                                                            END;
                                                        END IF;
                                                END IF;
                                        END LOOP;
                                ELSIF v_pee_rec.s_encmb_effect_type = cst_rqrd_crs_u THEN
                                        -- Add spu.unit_cd's TO spu PL/SQL TABLE
                                        v_spu_index := 0;
                                        FOR v_spu_rec IN c_spu (cst_required) LOOP
                                                v_spu_index := v_spu_index + 1;
                                                v_spu_table(v_spu_index) := v_spu_rec.unit_cd;
                                        END LOOP; -- c_spu
                                        v_pur_index := 0;
                                        FOR v_pur_rec IN c_pur (
                                                                v_pee_rec.encumbrance_type,
                                                                v_pee_rec.pen_start_dt,
                                                                v_pee_rec.s_encmb_effect_type,
                                                                v_pee_rec.pee_start_dt,
                                                                v_pee_rec.sequence_number) LOOP
                                                -- Add pur.unit_cd to pur PL/SQL table
                                                v_pur_index := v_pur_index + 1;
                                                v_pur_table(v_pur_index) := v_pur_rec.unit_cd;
                                                -- Check if pur.unit_cd in spu PL/SQL table
                                                v_unit_cd_found := FALSE;
                                                FOR v_index1 IN 1..v_spu_index LOOP
                                                        IF v_spu_table(v_index1) = v_pur_rec.unit_cd THEN
                                                                v_unit_cd_found := TRUE;
                                                                EXIT;
                                                        END IF;
                                                END LOOP;
                                                IF NOT v_unit_cd_found THEN
                                                    igs_pe_unt_requirmnt_pkg.UPDATE_ROW(
                                                      X_ROWID                 => v_pur_rec.ROWID,
                                                      X_PERSON_ID             => v_pur_rec.PERSON_ID,
                                                      X_ENCUMBRANCE_TYPE      => v_pur_rec.ENCUMBRANCE_TYPE,
                                                      X_PEN_START_DT          => v_pur_rec.PEN_START_DT,
                                                      X_S_ENCMB_EFFECT_TYPE   => v_pur_rec.S_ENCMB_EFFECT_TYPE,
                                                      X_PEE_START_DT          => v_pur_rec.PEE_START_DT,
                                                      X_PEE_SEQUENCE_NUMBER   => v_pur_rec.PEE_SEQUENCE_NUMBER,
                                                      X_UNIT_CD               => v_pur_rec.UNIT_CD,
                                                      X_PUR_START_DT          => v_pur_rec.PUR_START_DT,
                                                      X_EXPIRY_DT             => gcst_sysdatetime,
                                                      X_MODE                  => 'R'
                                                        );
                                                END IF;
                                        END LOOP; -- c_pur
                                        -- Check if all spu.unit_cd's IN pur PL/SQL TABLE, IF NOT ADD NEW
                                        -- pur record
                                        FOR v_index1 IN 1..v_spu_index LOOP
                                                v_unit_cd_found := FALSE;
                                                FOR v_index2 IN 1..v_pur_index LOOP
                                                        IF v_spu_table(v_index1) = v_pur_table(v_index2) THEN
                                                                v_unit_cd_found := TRUE;
                                                                EXIT;
                                                        END IF;
                                                END LOOP;
                                                IF NOT v_unit_cd_found THEN
                                                        OPEN c_pur_dup (
                                                                        v_pee_rec.encumbrance_type,
                                                                        v_pee_rec.pen_start_dt,
                                                                        v_pee_rec.s_encmb_effect_type,
                                                                        v_pee_rec.pee_start_dt,
                                                                        v_pee_rec.sequence_number,
                                                                        v_spu_table(v_index1),
                                                                        gcst_sysdate);
                                                        FETCH c_pur_dup INTO v_pur_dup_rec;
                                                        IF c_pur_dup%FOUND THEN
                                                                igs_pe_unt_requirmnt_pkg.UPDATE_ROW(
                                                                  X_ROWID                 => v_pur_dup_rec.ROWID,
                                                                  X_PERSON_ID             => v_pur_dup_rec.PERSON_ID,
                                                                  X_ENCUMBRANCE_TYPE      => v_pur_dup_rec.ENCUMBRANCE_TYPE,
                                                                  X_PEN_START_DT          => v_pur_dup_rec.PEN_START_DT,
                                                                  X_S_ENCMB_EFFECT_TYPE   => v_pur_dup_rec.S_ENCMB_EFFECT_TYPE,
                                                                  X_PEE_START_DT          => v_pur_dup_rec.PEE_START_DT,
                                                                  X_PEE_SEQUENCE_NUMBER   => v_pur_dup_rec.PEE_SEQUENCE_NUMBER,
                                                                  X_UNIT_CD               => v_pur_dup_rec.UNIT_CD,
                                                                  X_PUR_START_DT          => v_pur_dup_rec.PUR_START_DT,
                                                                  X_EXPIRY_DT             => v_expiry_dt,
                                                                  X_MODE                  => 'R'
                                                                );
                                                                CLOSE c_pur_dup;
                                                        ELSE
                                                                CLOSE c_pur_dup;
                                                            DECLARE
                                                              lv_rowid VARCHAR2(25);
                                                            BEGIN
                                                        igs_pe_unt_requirmnt_pkg.INSERT_ROW (
                                                              X_ROWID =>lv_rowid,
                                                              X_PERSON_ID =>p_person_id,
                                                              X_ENCUMBRANCE_TYPE=> v_pee_rec.encumbrance_type,
                                                              X_PEN_START_DT=> v_pee_rec.pen_start_dt,
                                                              X_S_ENCMB_EFFECT_TYPE=> v_pee_rec.s_encmb_effect_type,
                                                              X_PEE_START_DT =>v_pee_rec.pee_start_dt,
                                                              X_PEE_SEQUENCE_NUMBER =>v_pee_rec.sequence_number,
                                                              X_UNIT_CD =>v_spu_table(v_index1),
                                                              X_PUR_START_DT =>gcst_sysdatetime, --GJHA Changed it from gcst_sysdate
                                                              X_EXPIRY_DT=>v_expiry_dt,
                                                              X_MODE =>'R'
                                                              );
                                                            END;
                                                        END IF;
                                                END IF;
                                        END LOOP;
                        --
                        -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                        --
                        ELSIF v_pee_rec.s_encmb_effect_type IN (cst_exc_sp_awd, cst_exc_sp_disb) THEN
                          -- Add spf.fund_code's TO spf PL/SQL TABLE
                          v_spf_index := 0;
                          FOR v_spf_rec IN c_spf LOOP
                            v_spf_index := v_spf_index + 1;
                            v_spf_table(v_spf_index) := v_spf_rec.fund_code;
                          END LOOP; -- c_spf

                          v_pfe_index := 0;
                          FOR v_pfe_rec IN c_pfe (v_pee_rec.encumbrance_type,
                                v_pee_rec.pen_start_dt,
                                v_pee_rec.s_encmb_effect_type,
                                v_pee_rec.pee_start_dt,
                                v_pee_rec.sequence_number) LOOP

                            -- Add pfe.fund_code to pue PL/SQL table
                            v_pfe_index := v_pfe_index + 1;
                            v_pfe_table(v_pfe_index) := v_pfe_rec.fund_code;

                            -- Check if pfe.fund_code in spf PL/SQL table
                            v_fund_cd_found := FALSE;

                            FOR v_index1 IN 1..v_spf_index LOOP
                              IF v_spf_table(v_index1) = v_pfe_rec.fund_code THEN
                                v_fund_cd_found := TRUE;
                                EXIT;
                              END IF;
                            END LOOP;
                            IF NOT v_fund_cd_found THEN
                                      igs_pe_fund_excl_pkg.update_row(
                                        X_ROWID                => v_pfe_rec.rowid              ,
                                        X_FUND_EXCL_ID         => v_pfe_rec.fund_excl_id       ,
                                        X_PERSON_ID            => v_pfe_rec.person_id          ,
                                        X_ENCUMBRANCE_TYPE     => v_pfe_rec.encumbrance_type   ,
                                        X_PEN_START_DT         => v_pfe_rec.pen_start_dt       ,
                                        X_S_ENCMB_EFFECT_TYPE  => v_pfe_rec.s_encmb_effect_type,
                                        X_PEE_START_DT         => v_pfe_rec.pee_start_dt       ,
                                        X_PEE_SEQUENCE_NUMBER  => v_pfe_rec.pee_sequence_number,
                                        X_FUND_CODE            => v_pfe_rec.fund_code          ,
                                        X_PFE_START_DT         => v_pfe_rec.pfe_start_dt       ,
                                        X_EXPIRY_DT            => gcst_sysdatetime             ,
                                        X_MODE                 => 'R');
                            END IF;
                          END LOOP; -- c_pfe

                          -- Check if all spf.fund_cd's IN pue PL/SQL TABLE, IF NOT ADD NEW
                          -- pue record
                          FOR v_index1 IN 1..v_spf_index LOOP
                            v_fund_cd_found := FALSE;
                            FOR v_index2 IN 1..v_pfe_index LOOP
                              IF v_spf_table(v_index1) = v_pfe_table(v_index2) THEN
                                v_fund_cd_found := TRUE;
                                EXIT;
                              END IF;
                            END LOOP;
                            IF NOT v_fund_cd_found THEN
                              OPEN c_pfe_dup (
                                  v_pee_rec.encumbrance_type,
                                  v_pee_rec.pen_start_dt,
                                  v_pee_rec.s_encmb_effect_type,
                                  v_pee_rec.pee_start_dt,
                                  v_pee_rec.sequence_number,
                                  v_spf_table(v_index1),
                                  gcst_sysdate);
                              FETCH c_pfe_dup INTO v_pfe_dup_rec;

                              IF c_pfe_dup%FOUND THEN
                                igs_pe_fund_excl_pkg.update_row(
                                  X_ROWID                => v_pfe_dup_rec.rowid              ,
                                  X_FUND_EXCL_ID         => v_pfe_dup_rec.fund_excl_id       ,
                                  X_PERSON_ID            => v_pfe_dup_rec.person_id          ,
                                  X_ENCUMBRANCE_TYPE     => v_pfe_dup_rec.encumbrance_type   ,
                                  X_PEN_START_DT         => v_pfe_dup_rec.pen_start_dt       ,
                                  X_S_ENCMB_EFFECT_TYPE  => v_pfe_dup_rec.s_encmb_effect_type,
                                  X_PEE_START_DT         => v_pfe_dup_rec.pee_start_dt       ,
                                  X_PEE_SEQUENCE_NUMBER  => v_pfe_dup_rec.pee_sequence_number,
                                  X_FUND_CODE            => v_pfe_dup_rec.fund_code          ,
                                  X_PFE_START_DT         => v_pfe_dup_rec.pfe_start_dt       ,
                                  X_EXPIRY_DT            => v_expiry_dt                      ,
                                  X_MODE                 => 'R');
                                CLOSE c_pue_dup;
                              ELSE
                                CLOSE c_pfe_dup;
                                DECLARE
                                  l_rowid VARCHAR2(25);
                                  l_fund_excl_id igs_pe_fund_excl.fund_excl_id%TYPE;
                                BEGIN
                                 igs_pe_fund_excl_pkg.insert_row (
                                        X_ROWID                => l_rowid,
                                        X_FUND_EXCL_ID         => l_fund_excl_id,
                                        X_PERSON_ID            => p_person_id,
                                        X_ENCUMBRANCE_TYPE     => v_pee_rec.encumbrance_type,
                                        X_PEN_START_DT         => v_pee_rec.pee_start_dt,
                                        X_S_ENCMB_EFFECT_TYPE  => v_pee_rec.s_encmb_effect_type,
                                        X_PEE_START_DT         => v_pee_rec.pee_start_dt,
                                        X_PEE_SEQUENCE_NUMBER  => v_pee_rec.sequence_number,
                                        X_FUND_CODE            => v_spf_table(v_index1),
                                        X_PFE_START_DT         => gcst_sysdatetime,
                                        X_EXPIRY_DT            => v_expiry_dt,
                                        X_MODE                 => 'R' );
                                END;
                              END IF;

                            END IF;
                          END LOOP;
                          --
                          -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                          --
                     END IF;
                  END LOOP; -- c_pee
                ELSE    -- PEN doesn't exist ; NEW encumbrance.
                        -- Get the expiry date of the encumbrance

                        IF v_spo_rec.expiry_dt <= TRUNC(SYSDATE) THEN
                                v_expiry_status := IGS_PR_get_spo_expiry (
                                                                p_person_id,
                                                                p_course_cd,
                                                                p_spo_sequence_number,
                                                                v_spo_rec.expiry_dt,
                                                                v_expiry_dt);

                        ELSE
                                -- Don't pass the spo.expiry_dt forcing re-derivation ; this will check for
                                -- differences.
                                v_expiry_status := IGS_PR_get_spo_expiry (
                                                                p_person_id,
                                                                p_course_cd,
                                                                p_spo_sequence_number,
                                                                NULL,
                                                                v_expiry_dt);

                        END IF;
                        -- Cannot expire retrospectively
                        IF v_expiry_dt < gcst_sysdate THEN
                                RETURN TRUE;
                        END IF;

                        IF NOT IGS_PR_GEN_006.IGS_PR_upd_pen_clash (
                                                p_person_id,
                                                p_course_cd,
                                                p_spo_sequence_number,
                                                p_application_type,
                                                v_message_text,
                                                v_message_level) THEN
                                ROLLBACK TO sp_before_update;
                                p_message_text := v_message_text;
                                p_message_level := v_message_level;
                                RETURN FALSE;
                        ELSIF v_message_level IS NOT NULL THEN
                                -- Set the message level only if not already set, or the new
                                -- value is expiry
                                IF p_message_level IS NULL OR
                                                v_message_level = cst_expired THEN
                                        p_message_text := v_message_text;
                                        p_message_level := v_message_level;
                                END IF;
                        END IF;
                        -- Insert new encumbrance details
                                lv_spo_sequence_number:= p_spo_sequence_number;
                                DECLARE
                                  lv_rowid VARCHAR2(25);
                                BEGIN

                                IGS_PE_PERS_ENCUMB_pkg.INSERT_ROW (
                                  X_ROWID =>lv_rowid,
                                  X_PERSON_ID =>p_person_id,
                                  X_ENCUMBRANCE_TYPE =>v_spo_rec.encumbrance_type,
                                  X_START_DT=> gcst_sysdatetime, --gjha Chaged from  gcst_sysdatetime -- Modified by Prajeesh to sysdatetime
                                  X_EXPIRY_DT =>v_expiry_dt,
                                  X_AUTHORISING_PERSON_ID=> v_authorising_person_id,
                                  X_COMMENTS =>NULL,
                                  X_SPO_COURSE_CD => p_course_cd,
                                  X_SPO_SEQUENCE_NUMBER => lv_spo_sequence_number,
                                  x_auth_resp_id        => NULL,
				  x_external_reference  => NULL, -- ssawhney, should always be NULL when created from internal system
                                  X_MODE =>'R'
                                  );

                                END;
                        -- Loop through edte applicable records (from PL/SQL table)
                        FOR v_index1 IN 1..v_etde_index LOOP
                                OPEN c_pee_seq_num;
                                FETCH c_pee_seq_num INTO v_pee_sequence_number;
                                CLOSE c_pee_seq_num;
                                OPEN c_seet (v_etde_table(v_index1).s_encmb_effect_type);
                                FETCH c_seet INTO v_apply_to_course_ind;
                                CLOSE c_seet;
                                IF v_apply_to_course_ind = 'Y' THEN
                                        v_apply_course_cd := p_course_cd;
                                ELSE
                                        v_apply_course_cd := NULL;
                                END IF;
                                IF v_etde_table(v_index1).s_encmb_effect_type <> cst_rstr_at_ty OR
                                   NVL(v_spo_rec.closed_ind,'N') = 'N' THEN
                                           DECLARE
                                                             CURSOR c_decode1 IS
                                               SELECT DECODE( v_etde_table(v_index1).s_encmb_effect_type,
                                                                                cst_rstr_ge_cp, v_spo_rec.restricted_enrolment_cp,
                                                                                cst_rstr_le_cp, v_spo_rec.restricted_enrolment_cp,
                                                                                NULL) FROM DUAL;

                                                             CURSOR c_decode2 IS
                                               SELECT DECODE(   v_etde_table(v_index1).s_encmb_effect_type,
                                                                                cst_rstr_at_ty, v_spo_rec.restricted_attendance_type,
                                                                                NULL) FROM DUAL;
                                                      lv_rowid VARCHAR2(25);
                                           BEGIN

                                             OPEN c_decode1;
                                             FETCH c_decode1 INTO v_decode_val1 ;
                                             CLOSE c_decode1;

                                             OPEN c_decode2;
                                             FETCH c_decode2 INTO v_decode_val2 ;
                                             CLOSE c_decode2;

                                             IGS_PE_PERSENC_EFFCT_pkg.INSERT_ROW (
                                               X_ROWID =>lv_rowid,
                                               X_PERSON_ID =>p_person_id,
                                               X_ENCUMBRANCE_TYPE =>v_spo_rec.encumbrance_type,
                                               X_PEN_START_DT=> gcst_sysdatetime, --gjha Changed it from gcst_sysdatetime --Modified by Prajeesh to sysdatetime
                                               X_S_ENCMB_EFFECT_TYPE=> v_etde_table(v_index1).s_encmb_effect_type,
                                               X_PEE_START_DT=> gcst_sysdatetime, --gjha Changed it from gcst_sysdate
                                               X_SEQUENCE_NUMBER =>v_pee_sequence_number,
                                               X_EXPIRY_DT=> v_expiry_dt,
                                               X_COURSE_CD =>v_apply_course_cd,
                                               X_RESTRICTED_ENROLMENT_CP =>v_decode_val1,
                                               X_RESTRICTED_ATTENDANCE_TYPE =>v_decode_val2,
                                               X_MODE =>'R'
                                              );


                                            END;
                                END IF;
                                IF v_etde_table(v_index1).s_encmb_effect_type IN (
                                                                                cst_sus_course,
                                                                                cst_exc_course) THEN
                                        FOR v_spc_rec IN c_spc LOOP
                                            DECLARE
                                              lv_rowid VARCHAR2(25);
                                            BEGIN

                                              igs_pe_course_excl_pkg.INSERT_ROW (
                                                X_ROWID =>lv_rowid,
                                                X_PERSON_ID =>p_person_id,
                                                X_ENCUMBRANCE_TYPE =>v_spo_rec.encumbrance_type,
                                                X_PEN_START_DT =>gcst_sysdatetime,  --gjha Changed it from datetime --Modified by Prajeesh to sysdatetime
                                                X_S_ENCMB_EFFECT_TYPE =>v_etde_table(v_index1).s_encmb_effect_type,
                                                X_PEE_START_DT =>gcst_sysdatetime,
                                                X_PEE_SEQUENCE_NUMBER =>v_pee_sequence_number,
                                                X_COURSE_CD =>v_spc_rec.course_cd,
                                                X_PCE_START_DT =>gcst_sysdatetime, --GJHA Changed it from gcst_sysdate
                                                X_EXPIRY_DT =>v_expiry_dt,
                                                X_MODE =>'R'
                                                );
                                            END;

                                        END LOOP; -- c_spc
                                ELSIF v_etde_table(v_index1).s_encmb_effect_type = cst_exc_crs_gp THEN
                                        DECLARE
                                          lv_rowid VARCHAR2(25);
                                        BEGIN
                                          igs_pe_crs_grp_excl_pkg.INSERT_ROW (
                                            X_ROWID =>lv_rowid,
                                            X_PERSON_ID =>p_person_id,
                                            X_ENCUMBRANCE_TYPE=> v_spo_rec.encumbrance_type,
                                            X_PEN_START_DT =>gcst_sysdatetime, --gjha Changed it from sysdatetime --Modified by Prajeesh to sysdatetime
                                            X_S_ENCMB_EFFECT_TYPE =>v_etde_table(v_index1).s_encmb_effect_type,
                                            X_PEE_START_DT =>gcst_sysdatetime,
                                            X_PEE_SEQUENCE_NUMBER =>v_pee_sequence_number,
                                            X_COURSE_GROUP_CD =>v_spo_rec.encmb_course_group_cd,
                                            X_PCGE_START_DT=> gcst_sysdatetime, --GJHA Changed it from gcst_sysdate
                                            X_EXPIRY_DT =>v_expiry_dt,
                                            X_MODE =>'R'
                                            );
                                          END;
                                ELSIF v_etde_table(v_index1).s_encmb_effect_type = cst_exc_crs_us THEN
                                        FOR v_spus_rec IN c_spus LOOP
                                            DECLARE
                                              lv_rowid VARCHAR2(25);
                                            BEGIN
                                              igs_pe_unt_set_excl_pkg.INSERT_ROW (
                                                X_ROWID =>lv_rowid,
                                                X_PERSON_ID =>p_person_id,
                                                X_ENCUMBRANCE_TYPE=> v_spo_rec.encumbrance_type,
                                                X_PEN_START_DT=> gcst_sysdatetime, --gjha Changed it from sysdatetime --modified by Prajeesh
                                                X_S_ENCMB_EFFECT_TYPE =>v_etde_table(v_index1).s_encmb_effect_type,
                                                X_PEE_START_DT =>gcst_sysdatetime,
                                                X_PEE_SEQUENCE_NUMBER =>v_pee_sequence_number,
                                                X_UNIT_SET_CD =>v_spus_rec.unit_set_cd,
                                                X_US_VERSION_NUMBER =>v_spus_rec.version_number,
                                                X_PUSE_START_DT =>gcst_sysdatetime,  --GJHA Changed it from gcst_sysdate
                                                X_EXPIRY_DT =>v_expiry_dt,
                                                X_MODE =>'R'
                                                );
                                            END;
                                        END LOOP; -- c_spus
                                ELSIF v_etde_table(v_index1).s_encmb_effect_type = cst_exc_crs_u THEN
                                        FOR v_spu_rec IN c_spu (cst_excluded) LOOP
                                            DECLARE
                                              LV_ROWID VARCHAR2(25);
                                            BEGIN
                                              igs_pe_pers_unt_excl_PKG.INSERT_ROW (
                                                X_ROWID =>LV_ROWID,
                                                X_PERSON_ID =>p_person_id,
                                                X_ENCUMBRANCE_TYPE =>v_spo_rec.encumbrance_type,
                                                X_PEN_START_DT =>gcst_sysdatetime, --gjha Changed it from sysdatetime --Modified by Prajeesh
                                                X_S_ENCMB_EFFECT_TYPE =>v_etde_table(v_index1).s_encmb_effect_type,
                                                X_PEE_START_DT =>gcst_sysdatetime,
                                                X_PEE_SEQUENCE_NUMBER =>v_pee_sequence_number,
                                                X_UNIT_CD =>v_spu_rec.unit_cd,
                                                X_PUE_START_DT => gcst_sysdatetime, --  gjha Changed it from v_spu_table(v_index1),
                                                X_EXPIRY_DT=>v_expiry_dt,  --Gjha Changed it from gcst_sysdate,
                                                X_MODE =>'R'
                                                );
                                            END;
                                        END LOOP; -- c_spu
                                ELSIF v_etde_table(v_index1).s_encmb_effect_type = cst_rqrd_crs_u THEN
                                        FOR v_spu_rec IN c_spu (cst_required) LOOP
                                            DECLARE
                                              lv_rowid VARCHAR2(25);
                                            BEGIN
                                              igs_pe_unt_requirmnt_pkg.INSERT_ROW (
                                                X_ROWID =>lv_rowid,
                                                X_PERSON_ID =>p_person_id,
                                                X_ENCUMBRANCE_TYPE=> v_spo_rec.encumbrance_type,
                                                X_PEN_START_DT=> gcst_sysdatetime, --gjha Changed it from gcst_sysdatetime --Modified by Prajeesh
                                                X_S_ENCMB_EFFECT_TYPE=> v_etde_table(v_index1).s_encmb_effect_type,
                                                X_PEE_START_DT =>gcst_sysdatetime,
                                                X_PEE_SEQUENCE_NUMBER =>v_pee_sequence_number,
                                                X_UNIT_CD =>v_spu_rec.unit_cd,
                                                X_PUR_START_DT =>gcst_sysdatetime,
                                                X_EXPIRY_DT=>v_expiry_dt,
                                                X_MODE =>'R'
                                                );
                                            END;
                                        END LOOP; -- c_spu
                                --
                                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                                --
                                ELSIF v_etde_table(v_index1).s_encmb_effect_type IN (cst_exc_sp_awd, cst_exc_sp_disb)THEN
                                        FOR v_spf_rec IN c_spf LOOP
                                            DECLARE
                                              l_rowid VARCHAR2(25);
                                              l_fund_excl_id igs_pe_fund_excl.fund_excl_id%TYPE;
                                            BEGIN
                                                 igs_pe_fund_excl_pkg.insert_row (
                                                   X_ROWID                => l_rowid,
                                                   X_FUND_EXCL_ID         => l_fund_excl_id,
                                                   X_PERSON_ID            => p_person_id,
                                                   X_ENCUMBRANCE_TYPE     => v_spo_rec.encumbrance_type,
                                                   X_PEN_START_DT         => gcst_sysdatetime,
                                                   X_S_ENCMB_EFFECT_TYPE  => v_etde_table(v_index1).s_encmb_effect_type,
                                                   X_PEE_START_DT         => gcst_sysdatetime,
                                                   X_PEE_SEQUENCE_NUMBER  => v_pee_sequence_number,
                                                   X_FUND_CODE            => v_spf_rec.fund_code,
                                                   X_PFE_START_DT         => gcst_sysdatetime,
                                                   X_EXPIRY_DT            => v_expiry_dt,
                                                   X_MODE                 => 'R' );
                                            END;
                                        END LOOP; -- c_spf
                                --
                                -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                                --
                                END IF;
                        END LOOP; -- PL/SQL table
                END IF;
        END IF;

        RETURN TRUE;
EXCEPTION
        WHEN e_record_locked THEN
                IF c_spo%ISOPEN THEN
                        CLOSE c_spo;
                END IF;
                IF c_pe%ISOPEN THEN
                        CLOSE c_pe;
                END IF;
                IF c_pen%ISOPEN THEN
                        CLOSE c_pen;
                END IF;
                IF c_etde%ISOPEN THEN
                        CLOSE c_etde;
                END IF;
                IF c_pce%ISOPEN THEN
                        CLOSE c_pce;
                END IF;
                IF c_pce_dup%ISOPEN THEN
                        CLOSE c_pce_dup;
                END IF;
                IF c_spc%ISOPEN THEN
                        CLOSE c_spc;
                END IF;
                IF c_pcge%ISOPEN THEN
                        CLOSE c_pcge;
                END IF;
                IF c_pcge_dup%ISOPEN THEN
                        CLOSE c_pcge_dup;
                END IF;
                IF c_puse%ISOPEN THEN
                        CLOSE c_puse;
                END IF;
                IF c_puse_dup%ISOPEN THEN
                        CLOSE c_puse_dup;
                END IF;
                IF c_spus%ISOPEN THEN
                        CLOSE c_spus;
                END IF;
                IF c_pue%ISOPEN THEN
                        CLOSE c_pue;
                END IF;
                IF c_pue_dup%ISOPEN THEN
                        CLOSE c_pue_dup;
                END IF;
                IF c_pur%ISOPEN THEN
                        CLOSE c_pur;
                END IF;
                IF c_pur_dup%ISOPEN THEN
                        CLOSE c_pur_dup;
                END IF;
                IF c_spu%ISOPEN THEN
                        CLOSE c_spu;
                END IF;
                IF c_pee%ISOPEN THEN
                        CLOSE c_pee;
                END IF;
                IF c_seet%ISOPEN THEN
                        CLOSE c_seet;
                END IF;
                IF c_pfe%ISOPEN THEN
                        CLOSE c_pfe;
                END IF;
                IF c_pfe_dup %ISOPEN THEN
                        CLOSE c_pfe_dup;
                END IF;
                IF c_spf%ISOPEN THEN
                        CLOSE c_spf;
                END IF;

                ROLLBACK TO sp_before_update;
                p_message_level := cst_error;
                RETURN FALSE;
        WHEN OTHERS THEN
                IF c_spo%ISOPEN THEN
                        CLOSE c_spo;
                END IF;
                IF c_pe%ISOPEN THEN
                        CLOSE c_pe;
                END IF;
                IF c_pen%ISOPEN THEN
                        CLOSE c_pen;
                END IF;
                IF c_etde%ISOPEN THEN
                        CLOSE c_etde;
                END IF;
                IF c_pce%ISOPEN THEN
                        CLOSE c_pce;
                END IF;
                IF c_pce_dup%ISOPEN THEN
                        CLOSE c_pce_dup;
                END IF;
                IF c_spc%ISOPEN THEN
                        CLOSE c_spc;
                END IF;
                IF c_pcge%ISOPEN THEN
                        CLOSE c_pcge;
                END IF;
                IF c_pcge_dup%ISOPEN THEN
                        CLOSE c_pcge_dup;
                END IF;
                IF c_puse%ISOPEN THEN
                        CLOSE c_puse;
                END IF;
                IF c_puse_dup%ISOPEN THEN
                        CLOSE c_puse_dup;
                END IF;
                IF c_spus%ISOPEN THEN
                        CLOSE c_spus;
                END IF;
                IF c_pue%ISOPEN THEN
                        CLOSE c_pue;
                END IF;
                IF c_pue_dup%ISOPEN THEN
                        CLOSE c_pue_dup;
                END IF;
                IF c_pur%ISOPEN THEN
                        CLOSE c_pur;
                END IF;
                IF c_pur_dup%ISOPEN THEN
                        CLOSE c_pur_dup;
                END IF;
                IF c_spu%ISOPEN THEN
                        CLOSE c_spu;
                END IF;
                IF c_pee%ISOPEN THEN
                        CLOSE c_pee;
                END IF;
                IF c_seet%ISOPEN THEN
                        CLOSE c_seet;
                END IF;
                IF c_pfe%ISOPEN THEN
                        CLOSE c_pfe;
                END IF;
                IF c_pfe_dup %ISOPEN THEN
                        CLOSE c_pfe_dup;
                END IF;
                IF c_spf%ISOPEN THEN
                        CLOSE c_spf;
                END IF;
                IF c_pee_seq_num%ISOPEN THEN
                        CLOSE c_pee_seq_num;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_UPD_SPO_PEN');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
END igs_pr_upd_spo_pen;

FUNCTION igs_pr_get_spo_expiry(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_spo_expiry_dt IN DATE )

RETURN VARCHAR2 IS

        gv_other_detail                 VARCHAR2(255);

BEGIN   -- IGS_PR_get_spo_expiry

DECLARE

        v_expiry_dt     DATE;

        v_return_val    VARCHAR2(10);

BEGIN


        v_return_val := IGS_PR_GET_SPO_EXPIRY(
                                p_person_id,
                                p_course_cd,
                                p_sequence_number,
                                p_spo_expiry_dt,
                                v_expiry_dt);
        RETURN v_return_val;
END;

EXCEPTION
        WHEN OTHERS THEN
                    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
END igs_pr_get_spo_expiry;

FUNCTION get_antcp_compl_dt(
                           p_person_id   igs_en_stdnt_ps_att_all.person_id%TYPE,
                           p_course_cd   igs_en_stdnt_ps_att_all.course_cd%TYPE
                           )
RETURN DATE
IS
  -- function to get enrollment estimated completion date
  l_date             DATE;
  l_message_name     VARCHAR2(400);

BEGIN
  l_date := NULL;
  l_date := igs_en_gen_015.enrf_drv_cmpl_dt(
                                p_person_id                    => p_person_id,
                                p_course_cd                    => p_course_cd,
                                p_achieved_cp                  => NULL,
                                p_attendance_type              => NULL,
                                p_load_cal_type                => NULL,
                                p_load_ci_seq_num              => NULL,
                                p_load_ci_alt_code             => NULL,
                                p_load_ci_start_dt             => NULL,
                                p_load_ci_end_dt               => NULL,
                                p_message_name                 => l_message_name
                                            );

  RETURN l_date;

EXCEPTION
     WHEN OTHERS THEN
     RETURN NULL;

END get_antcp_compl_dt;

END  IGS_PR_GEN_006;

/
