--------------------------------------------------------
--  DDL for Package Body IGS_PR_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_GEN_004" AS
/* $Header: IGSPR25B.pls 120.5 2006/02/08 02:52:18 sepalani ship $ */
--------------------------------------------------------------------------------
--Change History:
--Who         When            What
--sarakshi    16-Nov-2004     Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG
--
--nalkumar    19-NOV-2002     Bug NO: 2658550
--                            Modified this object as per the FA110 PR Enh.
--svenkata  20-NOV-2002       Modified the call to the function igs_en_val_sua.enrp_val_sua_discont to add value 'N' for the parameter
--                            p_legacy. Bug#2661533.
--amuthu       01-Oct-2002    Added call to drop_all_workflow as part of Drop Transfer Build.
--                            the calls to the drop_all workflow is done after either dropping or
--                            discontinuing a unit attempt. created new local procedure invoke_drop_workflow Bug 2599925.
--mesriniv    12-sep-2002     Added a new parameter waitlist_manual_ind in TBH call of IGS_EN_SU_ATTEMPT
--                            for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
--Nishikant   15-may-2002     Condition in an IF clause in the procedure IGS_PR_upd_out_apply modified as part of the bug#2364216.
--                            And also the unit attempt was being deleted earlier if any student unit attempt outcome record not found for the person,
--                            now its modified to be update the unit attempt record to DROPPED status.
-- pradhakr    15-Dec-2002    Changed the call to the update_row of igs_en_su_attempt table to igs_en_sua_api.update_unit_attempt.
--                            Changes wrt ENCR031 build. Bug#2643207
--anilk       03-Jan-2003     Removed the message numbers and used the appropriate IGS messages, Bug# 2413841
--svanukur   26-jun-2003    Passing discontinued date with a nvl substitution of sysdate in the call to the update_row api of
  --                          ig_en_su_attmept in case of a "dropped" unit attempt status as part of bug 2898213.
--rvivekan    3-SEP-2003     Waitlist Enhacements build # 3052426. 2 new columns added to
--                           IGS_EN_SU_ATTEMPT_PKG procedures and consequently to IGS_EN_SUA_API procedures
--rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
--                           added as part of Prevent Dropping Core Units. Enh Bug# 3052432
--------------------------------------------------------------------------------
--
-- kdande; 23-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the PROCEDURE igs_pr_ins_suao_todo
--
PROCEDURE igs_pr_ins_suao_todo(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_version_number IN NUMBER,
  p_unit_cd IN VARCHAR2,
  p_cal_type IN VARCHAR2,
  p_ci_sequence_number IN NUMBER,
  p_old_grading_schema_cd IN VARCHAR2,
  p_new_grading_schema_cd IN VARCHAR ,
  p_old_gs_version_number IN NUMBER,
  p_new_gs_version_number IN NUMBER,
  p_old_grade IN VARCHAR2,
  p_new_grade IN VARCHAR2,
  p_old_mark IN NUMBER,
  p_new_mark IN NUMBER,
  p_old_finalised_outcome_ind IN VARCHAR2,
  p_new_finalised_outcome_ind IN VARCHAR2,
  p_uoo_id IN NUMBER)
IS
    gv_other_detail         VARCHAR2(255);
BEGIN   -- IGS_PR_ins_suao_todo
    -- Insert a IGS_PE_STD_TODO entry for an amendment of grade, providing the
    -- student has already undergone a progression check in the appropriate
    -- period.
DECLARE
    cst_progress    CONSTANT    VARCHAR2(10) := 'PROGRESS';
    cst_active  CONSTANT    VARCHAR2(10) := 'ACTIVE';
    cst_todo    CONSTANT    VARCHAR2(10) := 'TODO';
    cst_prg_check   CONSTANT    VARCHAR2(10) := 'PRG_CHECK';
    v_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE;
    v_sequence_number       NUMBER;
    v_insert_todo           BOOLEAN DEFAULT FALSE;
    v_start_dt          DATE;
    v_cutoff_dt         DATE;
    CURSOR c_sca IS
        SELECT  sca.version_number
        FROM    IGS_EN_STDNT_PS_ATT         sca
        WHERE   sca.person_id           = p_person_id AND
            sca.course_cd           = p_course_cd;
    CURSOR c_cir IS
        SELECT  cir.sup_cal_type,
            cir.sup_ci_sequence_number
        FROM    IGS_CA_INST_REL         cir,
            IGS_CA_INST         ci,
            IGS_CA_TYPE             ct,
            IGS_CA_STAT         cs
        WHERE   cir.sub_cal_type            = p_cal_type AND
            cir.sub_ci_sequence_number  = p_ci_sequence_number AND
            ci.cal_type         = cir.sup_cal_type AND
            ci.sequence_number      = cir.sup_ci_sequence_number AND
            ct.cal_type         = ci.cal_type AND
            ct.s_cal_cat            = cst_progress AND
            cs.CAL_STATUS           = ci.CAL_STATUS AND
            cs.s_CAL_STATUS         = cst_active AND
            EXISTS
            (SELECT 'X'
            FROM    IGS_PR_STDNT_PR_CK  spc
            WHERE   spc.person_id           = p_person_id AND
                spc.course_cd           = p_course_cd AND
                spc.prg_cal_type            = cir.sup_cal_type AND
                spc.prg_ci_sequence_number  = cir.sup_ci_sequence_number)
        ORDER BY ci.start_dt DESC;
BEGIN
    IF NVL(p_old_grading_schema_cd, ' ') = NVL(p_new_grading_schema_cd, ' ') AND
            NVL(p_old_gs_version_number, 0) = NVL(p_new_gs_version_number, 0) AND
            NVL(p_old_grade, ' ') = NVL(p_new_grade, ' ') AND
            NVL(p_old_mark, 0) = NVL(p_new_mark, 0) AND
            NVL(p_old_finalised_outcome_ind, ' ') =
                            NVL(p_new_finalised_outcome_ind, ' ') THEN
        -- No changes made ; no update required
        RETURN;
    END IF;
    -- If version number not passed then load it from IGS_EN_STDNT_PS_ATT
    -- record
    IF p_version_number IS NULL THEN
        OPEN c_sca;
        FETCH c_sca INTO v_version_number;
        IF c_sca%NOTFOUND THEN
            CLOSE c_sca;
            RETURN;
        END IF;
        CLOSE c_sca;
    ELSE
        v_version_number := p_version_number;
    END IF;
    -- Determine if the student has had a progression check in the related
    -- progression periods
    FOR v_cir_rec IN c_cir LOOP
        IF IGS_PR_GEN_006.IGS_PR_get_within_appl (
                v_cir_rec.sup_cal_type,
                v_cir_rec.sup_ci_sequence_number,
                p_course_cd,
                v_version_number,
                cst_todo,
                v_start_dt,
                v_cutoff_dt) = 'Y' THEN
            v_insert_todo := TRUE;
            EXIT;
        END IF;
    END LOOP;
    IF v_insert_todo THEN
      -- Insert todo entry
      v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO (
                             p_person_id,
                             cst_prg_check,
                             NULL,
                             'Y');
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added p_uoo_id param to IGS_GE_GEN_003.GENP_INS_TODO_REF FUNCTION call
      --
      igs_ge_gen_003.genp_ins_todo_ref (
        p_person_id,
        cst_prg_check,
        v_sequence_number,
        p_cal_type,
        p_ci_sequence_number,
        p_course_cd,
        p_unit_cd,
        NULL,
        p_uoo_id
      );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF c_sca%ISOPEN THEN
            CLOSE c_sca;
        END IF;
        IF c_cir%ISOPEN THEN
            CLOSE c_cir;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_INS_SUAO_TODO');
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
END igs_pr_ins_suao_todo;


  PROCEDURE invoke_drop_workflow(p_uoo_id IN NUMBER,
                               p_unit_CD IN VARCHAR2,
                               p_teach_cal_type IN VARCHAR2,
                               p_teach_ci_sequence_number IN NUMBER,
                               p_person_id IN NUMBER,
                               p_course_cd IN VARCHAR2,
                               p_message_name IN OUT NOCOPY VARCHAR2)
  AS
/*
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        08-10-2003      Remove the call to drop_all_workflow procedure and setting the
  ||                                  student unit attempt package variables as part of bug#3160856
*/
    CURSOR c_tl IS
      SELECT load_cal_type, load_ci_sequence_number
      FROM IGS_CA_TEACH_TO_LOAD_V
      WHERE teach_cal_type = p_teach_cal_type
      AND   teach_ci_sequence_number = p_teach_ci_sequence_number
      ORDER BY LOAD_START_DT ASC;

    l_load_cal_type            IGS_CA_INST.CAL_TYPE%TYPE;
    l_load_ci_sequence_number  IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_return_status            VARCHAR2(10);

  BEGIN

    OPEN c_tl;
    FETCH c_tl INTO l_load_cal_type, l_load_ci_sequence_number;
    CLOSE c_tl;

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_REASON_ACA_HOLD');
    FND_MESSAGE.SET_TOKEN('UNIT',p_unit_cd);
    igs_ss_en_wrappers.drop_notif_variable(FND_MESSAGE.GET(),'ACADEMIC-HOLDS' );

  END invoke_drop_workflow;



PROCEDURE IGS_PR_upd_out_apply(
  p_prg_cal_type IN VARCHAR2,
  p_prg_sequence_number IN NUMBER,
  p_course_type IN VARCHAR2,
  p_org_unit_cd IN VARCHAR2,
  p_ou_start_dt IN DATE ,
  p_course_cd IN VARCHAR2,
  p_location_cd IN VARCHAR2,
  p_attendance_mode IN VARCHAR2,
  p_progression_status IN VARCHAR2,
  p_enrolment_cat IN VARCHAR2,
  p_group_id IN NUMBER,
  p_spo_person_id IN NUMBER,
  p_spo_course_cd IN VARCHAR2,
  p_spo_sequence_number IN NUMBER,
  p_message_text IN OUT NOCOPY VARCHAR2,
  p_message_level IN OUT NOCOPY VARCHAR2,
  p_log_creation_dt OUT NOCOPY DATE )
IS
    gv_other_detail         VARCHAR2(255);

BEGIN   -- IGS_PR_upd_out_apply
    -- Apply outcomes to a studentes enrolment via the appropriate method, being
    -- either encumbrances or through enrolment discontinuations.
    -- The routine will process outcomes that have been approved but have not yet
    -- had their applied date set.
    -- Also processed will be students who have had outcomes applied, but where
    -- the decision status has been changed to Cancelled or Removed.
    -- Note: this routine can be called via either the job scheduler (in which
    -- case a batch of students is processed) or directly from forms. In the case
    -- of the form call the p_spo_ parameters are set, indicating to process
    -- only a single progression outcome.
DECLARE
    cst_prg_outcm   CONSTANT    VARCHAR2(10) := 'PRG-OUTCM';
    cst_active      CONSTANT    VARCHAR2(10) := 'ACTIVE';
    cst_approved    CONSTANT    VARCHAR2(10) := 'APPROVED';
    cst_batch       CONSTANT    VARCHAR2(10) := 'BATCH';
    cst_cancelled   CONSTANT    VARCHAR2(10) := 'CANCELLED';
    cst_current     CONSTANT    VARCHAR2(10) := 'CURRENT';
    cst_discontin   CONSTANT    VARCHAR2(10) := 'DISCONTIN';
    cst_enrolled    CONSTANT    VARCHAR2(10) := 'ENROLLED';
    cst_error       CONSTANT    VARCHAR2(10) := 'ERROR';
    cst_warn        CONSTANT    VARCHAR2(10) := 'WARNING';
    cst_exclusion   CONSTANT    VARCHAR2(10) := 'EXCLUSION';
    cst_AWARD       CONSTANT    VARCHAR2(10) := 'AWARD';
    cst_excluded    CONSTANT    VARCHAR2(10) := 'EXCLUDED';
    cst_expulsion   CONSTANT    VARCHAR2(10) := 'EXPULSION';
    cst_inactive    CONSTANT    VARCHAR2(10) := 'INACTIVE';
    cst_intermit    CONSTANT    VARCHAR2(10) := 'INTERMIT';
    cst_lapsed      CONSTANT    VARCHAR2(10) := 'LAPSED';
    cst_manual      CONSTANT    VARCHAR2(10) := 'MANUAL';
    cst_nopenalty   CONSTANT    VARCHAR2(10) := 'NOPENALTY';
    cst_no_cal      CONSTANT    VARCHAR2(10) := 'NO-CAL';
    cst_open        CONSTANT    VARCHAR2(10) := 'OPEN';
    cst_progress    CONSTANT    VARCHAR2(10) := 'PROGRESS';
    cst_removed     CONSTANT    VARCHAR2(10) := 'REMOVED';
    cst_sca         CONSTANT    VARCHAR2(10) := 'SCA';
    cst_spo         CONSTANT    VARCHAR2(10) := 'SPO';
    cst_suspension  CONSTANT    VARCHAR2(10) := 'SUSPENSION';
    cst_disclift    CONSTANT    VARCHAR2(10) := 'DISCLIFT';
    cst_disc_other  CONSTANT    VARCHAR2(10) := 'DISC-OTHER';
    cst_encumb      CONSTANT    VARCHAR2(10) := 'ENCUMB';
    cst_encumblift  CONSTANT    VARCHAR2(10) := 'ENCUMBLIFT';
    cst_disc_err    CONSTANT    VARCHAR2(10) := 'DISC-ERR';
    cst_udisc_err   CONSTANT    VARCHAR2(10) := 'UDISC-ERR';
    cst_usdisc_err  CONSTANT    VARCHAR2(10) := 'USDISC-ERR';
    cst_discl_err   CONSTANT    VARCHAR2(10) := 'DISCL-ERR';
    cst_udiscontin  CONSTANT    VARCHAR2(10) := 'UDISCONTIN';
    cst_encumb_err  CONSTANT    VARCHAR2(10) := 'ENCUMB-ERR';
    cst_encumb_warn CONSTANT    VARCHAR2(11) := 'ENCUMB-WARN';
    cst_warning     CONSTANT    VARCHAR2(10) := 'WARNING';

    e_record_locked         EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    e_application           EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_application, -20000);

    v_apply_start_dt_alias      IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
    v_apply_end_dt_alias        IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
    v_end_benefit_dt_alias      IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
    v_end_penalty_dt_alias      IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
    v_show_cause_cutoff_dt_alias    IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
    v_appeal_cutoff_dt_alias        IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
    v_show_cause_ind            IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
    v_apply_before_show_ind     IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
    v_appeal_ind                IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
    v_apply_before_appeal_ind   IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
    v_count_sus_in_time_ind     IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
    v_count_exc_in_time_ind     IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
    v_calculate_wam_ind         IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
    v_calculate_gpa_ind         IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
    v_outcome_check_type        IGS_PR_S_PRG_CONF.outcome_check_type%TYPE;
    v_application_type          VARCHAR2(10);
    v_log_creation_dt           DATE DEFAULT NULL;
    v_key                       IGS_GE_s_log.KEY%TYPE;
    v_process_next_spo          BOOLEAN;
    v_other_encumbrance         BOOLEAN;
    v_exit_procedure            BOOLEAN DEFAULT FALSE;
    v_discont_reason_cd         IGS_EN_DCNT_REASONCD.discontinuation_reason_cd%TYPE;
    v_s_discont_reason_type     IGS_EN_DCNT_REASONCD.s_discontinuation_reason_type%TYPE;
    v_expiry_status             VARCHAR2(10);
    v_expiry_dt                 DATE;
    v_authorising_person_id     IGS_PE_person.person_id%TYPE;
    v_new_pra_sequence_number   IGS_PR_RU_APPL.sequence_number%TYPE;
    v_ci_sequence_number        IGS_CA_INST.sequence_number%TYPE;
    v_message_text              VARCHAR2(2000);
    v_message_level             VARCHAR2(10);
    v_message_name              VARCHAR2(30);
    v_administrative_unit_status   IGS_PS_UNIT_DISC_CRT.administrative_unit_status%TYPE;
    v_admin_unit_status_str     VARCHAR2(2000);
    v_alias_val                 DATE;
    v_sua_upd_or_del            BOOLEAN;
    v_dummy                     VARCHAR2(1);
    v_spa_award_cd              IGS_PS_AWD.AWARD_CD%TYPE;

    CURSOR c_spo IS
        SELECT  spo.person_id,
            spo.course_cd,
            spo.sequence_number,
            spo.pro_pra_sequence_number,
            spo.prg_cal_type,
            spo.prg_ci_sequence_number,
            spo.progression_outcome_type,
            spo.duration,
            spo.duration_type,
            spo.decision_status,
            spo.decision_dt,
            spo.show_cause_expiry_dt,
            spo.show_cause_dt,
            spo.show_cause_outcome_dt,
            spo.appeal_expiry_dt,
            spo.appeal_dt,
            spo.appeal_outcome_dt,
            spo.expiry_dt,
            spo.encmb_course_group_cd,
            pot.s_progression_outcome_type,
            sca.version_number,
            sca.commencement_dt,
            sca.course_attempt_status,
            sca.discontinuation_reason_cd
        FROM    IGS_PR_STDNT_PR_OU  spo,
            IGS_PR_OU_TYPE  pot,
            IGS_EN_STDNT_PS_ATT     sca,
            IGS_PS_VER          crv
        WHERE   (
                p_spo_person_id     IS NULL
                AND
                  -- Decision Status is approved and applied_dt is null/'0001/01/01
                  -- or
                  -- Decision Status is removed /cancelled and applied date is not null
                  (
                    (spo.decision_status        = cst_approved AND
                       (
                        spo.applied_dt          IS NULL OR
                        spo.applied_dt          = igs_ge_date.igsdate('0001/01/01')
                       )
                    )
                    OR
                    ( spo.decision_status  IN (
                                     cst_removed,
                                     cst_cancelled
                                  )
                      AND
                      spo.applied_dt        IS NOT NULL
                    )
                  )
                AND
                  (
                   p_course_cd          IS NULL OR
                   spo.course_cd        LIKE p_course_cd
                  )
                AND
                  (
                                   p_progression_status     IS NULL OR
                   sca.progression_status   = p_progression_status
                  )
                AND
                  pot.progression_outcome_type  = spo.progression_outcome_type
                AND
                  sca.person_id         = spo.person_id
                AND
                  sca.course_cd         = spo.course_cd
                AND
                  crv.course_cd         = sca.course_cd
                AND
                  crv.version_number        = sca.version_number
                AND
                   -- group_id has not been specified or if specified then take out NOCOPY person_id's for that group_id
                   -- such that the person has a valid student program attempt record as given in table igs_en_stdnt_ps_att
                  (
                    p_group_id          IS NULL
                    OR
                    sca.person_id IN    (
                        SELECT  person_id
                        FROM    IGS_PE_PIGM_PIDGRP_MEM_V
                        WHERE   group_id = p_group_id AND
                            person_id = sca.person_id
                            )
                  )
                AND
                  (
                                    p_prg_cal_type      IS NULL
                    OR
                      (
                     spo.prg_cal_type       = p_prg_cal_type
                     AND
                     spo.prg_ci_sequence_number = p_prg_sequence_number
                      )
                  )
                   AND
                  (
                    p_course_type           IS NULL OR
                    crv.course_type         = p_course_type
                  )
                AND
                 (
                     p_attendance_mode      IS NULL OR
                     sca.attendance_mode        = p_attendance_mode
                  )
                AND
                 (
                   p_org_unit_cd        IS NULL
                   OR
                   IGS_PR_GEN_001.PRGP_get_crv_cmt
                    (
                      sca.course_cd,
                      sca.version_number,
                      p_org_unit_cd,
                      p_ou_start_dt
                    )       = 'Y'
                 )
                AND
                 (
                   p_enrolment_cat      IS NULL
                   OR
                   EXISTS
                     (
                    SELECT  'X'
                    FROM    IGS_AS_SC_ATMPT_ENR     scae,
                        IGS_CA_INST         ci1
                    WHERE   sca.person_id           = scae.person_id AND
                        sca.course_cd           = scae.course_cd AND
                        scae.enrolment_cat      = p_enrolment_cat AND
                        ci1.cal_type            = scae.cal_type AND
                        ci1.sequence_number     = scae.ci_sequence_number AND
                        ci1.end_dt          =
                        (
                          SELECT    MAX(ci2.end_dt)
                          FROM      IGS_AS_SC_ATMPT_ENR scae2,
                                IGS_CA_INST     ci2
                            WHERE
                                scae2.person_id     = scae.person_id AND
                                scae2.course_cd     = scae.course_cd AND
                                ci2.cal_type        = scae2.cal_type AND
                                ci2.sequence_number = scae2.ci_sequence_number
                        )
                     )
                  )
                AND
                  (
                    p_location_cd           IS NULL OR
                    sca.location_cd         = p_location_cd
                  )
             )
                OR
            (
                p_spo_person_id     IS NOT NULL
                AND
                spo.person_id           = p_spo_person_id
                AND
                spo.course_cd           = p_spo_course_cd
                AND
                spo.sequence_number     = p_spo_sequence_number
                AND
                pot.progression_outcome_type    = spo.progression_outcome_type
                AND
                sca.person_id           = spo.person_id
                AND
                sca.course_cd           = spo.course_cd
                AND
                crv.course_cd           = sca.course_cd
                AND
                crv.version_number      = sca.version_number
            )
        ORDER BY    spo.person_id,
                spo.course_cd,
                DECODE  (spo.decision_status,   'APPROVED', 9,
                    1),
                spo.prg_cal_type,
                spo.prg_ci_sequence_number;

    CURSOR c_dr (
        cp_discontinuation_reason_cd
                        IGS_EN_DCNT_REASONCD.discontinuation_reason_cd%TYPE) IS
        SELECT  s_discontinuation_reason_type
        FROM    IGS_EN_DCNT_REASONCD    dr
        WHERE   dr.discontinuation_reason_cd    = cp_discontinuation_reason_cd AND
            dr.s_discontinuation_reason_type    = cst_progress;
    CURSOR c_spo_pot (
        cp_person_id        IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_course_cd        IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE,
        cp_spo_encmb_course_group_cd
                    IGS_PR_STDNT_PR_OU.encmb_course_group_cd%TYPE,
        cp_sca_version_number   IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
        SELECT  /*+INDEX(spo spo_pk)*/
            spo.sequence_number,
            spo.expiry_dt
        FROM    IGS_PR_STDNT_PR_OU  spo,
            IGS_PR_OU_TYPE  pot
        WHERE
            (EXISTS (
                SELECT  'X'
                FROM    IGS_PR_STDNT_PR_PS spc
                WHERE   spc.person_id   = cp_person_id AND
                    spc.course_cd   = cp_course_cd AND
                    spc.spo_sequence_number = cp_sequence_number AND
                    spc.course_cd   = cp_course_cd
                ) OR
              (cp_spo_encmb_course_group_cd IS NOT NULL AND
               EXISTS   (
                SELECT  'X'
                FROM    IGS_PS_GRP_MBR cgm
                WHERE   cgm.course_group_cd = cp_spo_encmb_course_group_cd AND
                    cgm.course_cd       = cp_course_cd AND
                    cgm.version_number  = cp_sca_version_number))) AND
            spo.person_id           = cp_person_id AND
            spo.sequence_number     <> cp_sequence_number AND
            pot.progression_outcome_type    = spo.progression_outcome_type AND
            pot.s_progression_outcome_type  IN (
                            cst_suspension,
                            cst_exclusion,
                            cst_expulsion) AND
            spo.applied_dt          IS NOT NULL AND
            (EXISTS (
                SELECT  'X'
                FROM    IGS_PR_STDNT_PR_PS spc
                WHERE   spc.person_id   = spo.person_id AND
                    spc.course_cd   = spo.course_cd AND
                    spc.spo_sequence_number = spo.sequence_number AND
                    spc.course_cd   = cp_course_cd
                ) OR
              (spo.encmb_course_group_cd IS NOT NULL AND
               EXISTS   (
                SELECT  'X'
                FROM    IGS_PS_GRP_MBR cgm
                WHERE   cgm.course_group_cd = spo.encmb_course_group_cd AND
                    cgm.course_cd       = cp_course_cd AND
                    cgm.version_number  = cp_sca_version_number)));
    CURSOR c_sca1 (
        cp_person_id        IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        cp_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
        SELECT  sca.*,
                sca.ROWID
        FROM    IGS_EN_STDNT_PS_ATT     sca
        WHERE   sca.person_id           = cp_person_id AND
            sca.course_cd           = cp_course_cd
        FOR UPDATE NOWAIT;
    CURSOR c_sca2 (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_spo_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE,
        cp_spo_encmb_course_group_cd
                IGS_PR_STDNT_PR_OU.encmb_course_group_cd%TYPE) IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.version_number,
            sca.course_attempt_status,
            sca.commencement_dt
        FROM    IGS_EN_STDNT_PS_ATT         sca
        WHERE   sca.person_id           = cp_spo_person_id AND
            sca.course_attempt_status   IN (
                            cst_enrolled,
                            cst_inactive,
                            cst_lapsed,
                            cst_intermit) AND
            (EXISTS (
             SELECT 'X'
             FROM   IGS_PR_STDNT_PR_PS      spc
             WHERE  spc.person_id           = cp_spo_person_id AND
                spc.spo_course_cd       = cp_spo_course_cd AND
                spc.spo_sequence_number     = cp_spo_sequence_number AND
                spc.course_cd           = sca.course_cd) OR
            (cp_spo_encmb_course_group_cd   IS NOT NULL AND
             EXISTS (
                SELECT  'X'
                FROM    IGS_PS_GRP_MBR cgm
                WHERE   cgm.course_group_cd = cp_spo_encmb_course_group_cd AND
                    cgm.course_cd       = sca.course_cd AND
                    cgm.version_number  = sca.version_number)
            ));
    CURSOR  c_susa (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_spo_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
        SELECT
            susa.*,
            susa.ROWID,
            DECODE(acai.acai_ind,   'Y', 'Y', 'N') acai_ind
        FROM
            IGS_EN_STDNT_PS_ATT sca,
            IGS_AS_SU_SETATMPT        susa,
             (  SELECT  /*+INDEX(sca sca_pk)*/
                    sca.person_id,
                    sca.course_cd,
                    'Y' acai_ind
                FROM    IGS_EN_STDNT_PS_ATT sca,
                    IGS_AD_PS_APPL_INST acai
                WHERE   sca.person_id           = acai.person_id AND
                    sca.adm_admission_appl_number   = acai.admission_appl_number AND
                    sca.adm_nominated_course_cd = acai.nominated_course_cd AND
                    sca.adm_sequence_number     = acai.sequence_number) acai
        WHERE   sca.person_id       = cp_spo_person_id AND
            sca.course_cd       = cp_spo_course_cd AND
            sca.person_id       = susa.person_id AND
            sca.course_cd       = susa.course_cd AND
                    susa.student_confirmed_ind  = 'Y' AND
            susa.end_dt     IS NULL AND
                    susa.rqrmnts_complete_ind   = 'N' AND
                EXISTS (
             SELECT  'X'
            FROM    IGS_PR_SDT_PR_UNT_ST    spus
            WHERE   spus.person_id          = sca.person_id AND
                spus.course_cd          = sca.course_cd AND
                spus.spo_sequence_number        = cp_spo_sequence_number AND
                spus.unit_set_cd            = susa.unit_set_cd) AND
                acai.person_id          (+)= susa.person_id AND
                acai.course_cd          (+)= susa.course_cd  ;
            --FOR UPDATE NOWAIT;                                          -- Commente by Prajeesh
    CURSOR c_pra (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_spo_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
        SELECT  /*+INDEX(pra1 pra_spo_fk_i)*/
            pra1.progression_rule_cat,
            pra1.sequence_number
        FROM    IGS_PR_RU_APPL      pra1
        WHERE   pra1.spo_person_id      = cp_spo_person_id AND
            pra1.spo_course_cd      = cp_spo_course_cd AND
            pra1.spo_sequence_number        = cp_spo_sequence_number AND
            pra1.s_relation_type        = cst_spo AND
            pra1.logical_delete_dt      IS NULL AND
            NOT EXISTS (
            SELECT  'X'
            FROM    IGS_PR_RU_APPL      pra2
            WHERE   pra2.sca_person_id      = cp_spo_person_id AND
                pra2.sca_course_cd      = cp_spo_course_cd AND
                NVL(pra2.spo_person_id, 0)  = cp_spo_person_id AND
                NVL(pra2.spo_course_cd, 'NULL') = cp_spo_course_cd AND
                NVL(pra2.spo_sequence_number,0) = cp_spo_sequence_number AND
                pra2.s_relation_type        = cst_sca AND
                pra2.logical_delete_dt      IS NULL AND
                NVL(pra2.reference_cd, pra2.progression_rule_cd)
                                = NVL(pra1.reference_cd, pra1.progression_rule_cd));
    CURSOR c_pra_prct (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_spo_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
        SELECT  /*+INDEX(pra pra_spo_fk_i)*/
            prct.*,
            prct.ROWID
        FROM    IGS_PR_RU_APPL      pra,
            IGS_PR_RU_CA_TYPE   prct
        WHERE   pra.progression_rule_cat    = prct.progression_rule_cat AND
            pra.sequence_number = prct.pra_sequence_number AND
            pra.logical_delete_dt   IS NULL AND
            pra.s_relation_type     = cst_sca AND
            pra.sca_person_id       = cp_spo_person_id AND
            pra.sca_course_cd       = cp_spo_course_cd AND
            pra.spo_person_id       = cp_spo_person_id AND
            pra.spo_course_cd       = cp_spo_course_cd AND
            pra.spo_sequence_number = cp_spo_sequence_number ; -- commented by Prajeesh
        --FOR UPDATE NOWAIT;
    CURSOR c_ci (
        cp_prg_cal_type     IGS_CA_INST.cal_type%TYPE,
        cp_spo_cal_type     IGS_CA_INST.cal_type%TYPE,
        cp_spo_sequence_number  IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  ci1.sequence_number
        FROM    IGS_CA_INST         ci1,
            IGS_CA_STAT         cs
        WHERE   ci1.cal_type            = cp_prg_cal_type AND
            cs.CAL_STATUS           = ci1.CAL_STATUS AND
            cs.s_CAL_STATUS         = cst_active AND
            ci1.start_dt            >
            (SELECT ci2.start_dt
            FROM    IGS_CA_INST     ci2
            WHERE   ci2.cal_type        = cp_spo_cal_type AND
                ci2.sequence_number = cp_spo_sequence_number)
        ORDER BY ci1.start_dt ASC;
    CURSOR c_pra_upd1 (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_spo_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
        SELECT  pra.*,
                pra.ROWID
        FROM    IGS_PR_RU_APPL      pra
        WHERE   pra.spo_person_id       = cp_spo_person_id AND
            pra.spo_course_cd       = cp_spo_course_cd AND
            pra.spo_sequence_number     = cp_spo_sequence_number AND
            pra.sca_person_id       = cp_spo_person_id AND
            pra.sca_course_cd       = cp_spo_course_cd AND
            pra.logical_delete_dt       IS NULL AND
            pra.s_relation_type     = cst_sca ;
        --FOR UPDATE NOWAIT;                                           -- commented by Prajeesh
    CURSOR c_pra_upd2 (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_spo_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
        SELECT  pra1.*,
                pra1.ROWID
        FROM    IGS_PR_RU_APPL      pra1
        WHERE   pra1.sca_person_id      = cp_spo_person_id AND
            pra1.sca_course_cd      = cp_spo_course_cd AND
            NVL(pra1.spo_person_id, 0)  = cp_spo_person_id AND
            NVL(pra1.spo_course_cd, 'NULL') = cp_spo_course_cd AND
            NVL(pra1.spo_sequence_number,0) = cp_spo_sequence_number AND
            pra1.s_relation_type        = cst_sca AND
            pra1.logical_delete_dt      IS NULL AND
            NOT EXISTS (
            SELECT  'X'
            FROM    IGS_PR_RU_APPL  pra2
            WHERE   pra2.spo_person_id  = cp_spo_person_id AND
                pra2.spo_course_cd  = cp_spo_course_cd AND
                pra2.spo_sequence_number    = cp_spo_sequence_number AND
                pra2.s_relation_type    = cst_spo AND
                pra2.progression_rule_cat   = pra1.progression_rule_cat AND
                NVL(pra2.progression_rule_cd, nvl(pra2.reference_cd, 'X')) = NVL(pra1.progression_rule_cd, NVL(pra1.reference_cd, 'X')) AND
                pra2.logical_delete_dt      IS NULL) ;
        --FOR UPDATE NOWAIT; -- commented by Prajeesh

    CURSOR c_spa(
             cp_person_id igs_pr_stdnt_pr_awd.person_id%TYPE,
             cp_course_cd igs_pr_stdnt_pr_awd.course_cd%TYPE,
             cp_spo_sequence_number igs_pr_stdnt_pr_awd.spo_sequence_number%TYPE) IS
           SELECT spa.award_cd
           FROM   igs_pr_stdnt_pr_awd spa
           WHERE  person_id = cp_person_id
           AND    course_cd  = cp_course_cd
           AND    spa.spo_sequence_number = cp_spo_sequence_number;

    CURSOR c_sua (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_spo_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
        SELECT
                sua.*, sua.ROWID
        FROM    IGS_EN_SU_ATTEMPT       sua
        WHERE   sua.person_id           = cp_spo_person_id AND
            sua.course_cd           = cp_spo_course_cd AND
            sua.unit_attempt_status     = cst_enrolled AND
            sua.unit_cd             IN
            (SELECT spu.unit_cd
            FROM    IGS_PR_STDNT_PR_UNIT        spu
            WHERE   spu.person_id           = cp_spo_person_id AND
                spu.course_cd           = cp_spo_course_cd AND
                spu.spo_sequence_number     = cp_spo_sequence_number AND
                spu.s_unit_type         = cst_excluded);
        --FOR UPDATE NOWAIT;            -- commented by Prajeesh
    --
    -- kdande; 22-Apr-2003; Bug# 2829262
    -- Added uoo_id field to the WHERE clause of cursor c_suao
    --
    CURSOR c_suao (
        cp_spo_person_id    IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_spo_course_cd    IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_sua_unit_cd      IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
        cp_sua_cal_type     IGS_EN_SU_ATTEMPT.cal_type%TYPE,
        cp_sua_ci_seq_number    IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
        cp_sua_uoo_id       IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
        SELECT  'X'
        FROM    IGS_AS_SU_STMPTOUT  suao
        WHERE   suao.person_id      = cp_spo_person_id AND
            suao.course_cd          = cp_spo_course_cd AND
            suao.uoo_id             = cp_sua_uoo_id;

    PROCEDURE prgpl_ins_log_entry (
        p_log_creation_dt       IGS_GE_s_log.creation_dt%TYPE,
        p_record_type           VARCHAR2,
        p_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        p_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
        p_prg_cal_type          IGS_CA_INST.cal_type%TYPE,
        p_prg_sequence_number       IGS_CA_INST.sequence_number%TYPE,
        p_spo_sequence_number       IGS_PR_STDNT_PR_OU.sequence_number%TYPE,
        p_progression_outcome_type      IGS_PR_STDNT_PR_OU.progression_outcome_type%TYPE,
        p_duration_type         IGS_PR_STDNT_PR_OU.duration_type%TYPE,
        p_duration          IGS_PR_STDNT_PR_OU.duration%TYPE,
        p_ci_cal_type           IGS_CA_INST.cal_type%TYPE,
        p_message_name          VARCHAR2,
        p_text              IGS_GE_s_log_entry.text%TYPE
        ) IS
	--rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
        --added as part of Prevent Dropping Core Units. Enh Bug# 3052432
    BEGIN   -- prgpl_ins_log_entry
        -- create a log entry
    DECLARE
        v_key               IGS_GE_s_log.KEY%TYPE;
        v_text              IGS_GE_s_log_entry.text%TYPE DEFAULT NULL;
    BEGIN
        v_key :=
            p_record_type               || '|' ||
            TO_CHAR(p_person_id)            || '|' ||
            p_course_cd                 || '|' ||
            p_prg_cal_type              || '|' ||
            TO_CHAR(p_prg_sequence_number);
        IF p_record_type = cst_discontin THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)||'|'||
                p_progression_outcome_type;
        ELSIF p_record_type = cst_udiscontin THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type              || '|' ||
                p_duration_type                     || '|' ||
                TO_CHAR(p_duration);
        ELSIF p_record_type = cst_disclift THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type;
        ELSIF p_record_type = cst_disc_other THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type;
        ELSIF p_record_type = cst_encumb THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type              || '|' ||
                p_duration_type                     || '|' ||
                TO_CHAR(p_duration);
        ELSIF p_record_type = cst_encumblift THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type              || '|' ||
                p_duration_type                     || '|' ||
                TO_CHAR(p_duration);
        ELSIF p_record_type = cst_encumb_err THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type              || '|' ||
                p_duration_type                     || '|' ||
                TO_CHAR(p_duration)                 || '|' ||
                p_text;
        ELSIF p_record_type = cst_encumb_warn THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type              || '|' ||
                p_duration_type                     || '|' ||
                TO_CHAR(p_duration)                 || '|' ||
                p_text;
        ELSIF p_record_type = cst_disc_err THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type;
        ELSIF p_record_type = cst_discl_err THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type              || '|||' ||
                p_text;
        ELSIF p_record_type = cst_udisc_err THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type              || '|' ||
                p_duration_type                     || '|' ||
                TO_CHAR(p_duration);
        ELSIF p_record_type = cst_usdisc_err THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type;

        ELSIF p_record_type = cst_award THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number) || '|' ||
                p_progression_outcome_type;

        ELSIF p_record_type = cst_manual THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type;
        ELSIF p_record_type = cst_nopenalty THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type;
        ELSIF p_record_type = cst_no_cal THEN
            v_text :=
                TO_CHAR(p_spo_sequence_number)              || '|' ||
                p_progression_outcome_type || '|||' ||
                p_text;
        END IF;
        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                cst_prg_outcm,
                p_log_creation_dt,
                v_key,
                p_message_name,
                v_text);
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_OUT_APPLY.PRGPL_INS_LOG_ENTRY');
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END prgpl_ins_log_entry;

    FUNCTION prgpl_upd_spo (
        p_person_id         IGS_PR_STDNT_PR_OU.person_id%TYPE,
        p_course_cd         IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        p_sequence_number       IGS_PR_STDNT_PR_OU.sequence_number%TYPE,
        p_show_cause_ind        IGS_PR_S_PRG_CONF.show_cause_ind%TYPE,
        p_apply_before_show_ind     IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE,
        p_appeal_ind            IGS_PR_S_PRG_CONF.appeal_ind%TYPE,
        p_apply_before_appeal_ind   IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE)
    RETURN BOOLEAN
    IS
    --rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
    --                           added as part of Prevent Dropping Core Units. Enh Bug# 3052432
    BEGIN   -- prgpl_upd_spo
    DECLARE
        CURSOR c_spo IS
            SELECT  sca.course_cd sca_course_cd,
                sca.version_number,
                spo.*,
                spo.ROWID
            FROM    IGS_PR_STDNT_PR_OU  spo,
                IGS_EN_STDNT_PS_ATT sca
            WHERE   spo.person_id           = p_person_id AND
                spo.course_cd           = p_course_cd AND
                spo.sequence_number     = p_sequence_number AND
                spo.person_id           = sca.person_id AND
                spo.course_cd           = sca.course_cd ;
            --FOR UPDATE NOWAIT;                                     -- commented by Prajeesh
        v_spo_rec                   c_spo%ROWTYPE;
        v_old_show_cause_expiry_dt  DATE;
        v_orig_appeal_expiry_dt      IGS_PR_STDNT_PR_OU.appeal_expiry_dt%TYPE;
        v_orig_show_cause_expiry_dt  IGS_PR_STDNT_PR_OU.show_cause_expiry_dt%TYPE;
    BEGIN
        OPEN c_spo;
        FETCH c_spo INTO v_spo_rec;
        IF c_spo%FOUND THEN

          v_orig_appeal_expiry_dt   := v_spo_rec.appeal_expiry_dt;
          v_orig_show_cause_expiry_dt   := v_spo_rec.show_cause_expiry_dt;

          IF v_spo_rec.decision_status = cst_approved THEN

            IF p_show_cause_ind = 'Y' AND  p_apply_before_show_ind = 'Y'
                                        AND
               v_spo_rec.show_cause_expiry_dt IS NULL AND v_spo_rec.show_cause_dt IS NULL
                                        AND
                           v_spo_rec.appeal_dt IS NULL THEN
               v_old_show_cause_expiry_dt     := v_spo_rec.show_cause_expiry_dt;
                -- IGS_PR_GEN_005.IGS_PR_clc_cause_expry calculates the show cause expiry dates for a nominated
                -- rule within a nominated progression calendar. This routine also considers whether a show cause
                -- is actually permitted ,if not the date is returned as null.
                v_spo_rec.show_cause_expiry_dt := IGS_PR_GEN_005.IGS_PR_clc_cause_expry
                                                         (  p_course_cd,
                                        v_spo_rec.version_number,
                                        v_spo_rec.prg_cal_type,
                                        v_spo_rec.prg_ci_sequence_number,
                                        v_spo_rec.progression_rule_cat,
                                        v_spo_rec.pra_sequence_number,
                                        v_spo_rec.pro_sequence_number
                                         );
               -- Determines whether an appeal is permitted for a nominated outcome.
               -- If an appeal is permitted then ensure that an appeal expiry date is not earlier than
               -- the show cause expiry date.
               -- Else if an appeal is not permitted then set the old show cause expiry date.
               IF IGS_PR_GEN_005.IGS_PR_get_appeal_alwd
                            (   v_spo_rec.progression_rule_cat,
                                v_spo_rec.pra_sequence_number,
                                v_spo_rec.pro_sequence_number,
                                v_spo_rec.course_cd,
                                v_spo_rec.version_number) = 'Y' THEN

                  -- Don't permit the appeal expiry DATE TO be earlier than show cause.
                  IF v_spo_rec.show_cause_expiry_dt IS NOT NULL AND v_spo_rec.appeal_expiry_dt IS NOT NULL AND
                     v_spo_rec.appeal_expiry_dt < v_spo_rec.show_cause_expiry_dt THEN
                 v_spo_rec.appeal_expiry_dt := v_spo_rec.show_cause_expiry_dt;
                  END IF;

               ELSIF v_spo_rec.appeal_expiry_dt IS NOT NULL THEN
                 -- This is an unrecoverable error that will only happen in the
                 -- configuration settings are toyed with after appeals are entered.
                 v_spo_rec.show_cause_expiry_dt := v_old_show_cause_expiry_dt;
               END IF;

             END IF;

                         IF p_appeal_ind = 'Y' AND p_apply_before_appeal_ind = 'Y' AND
                            v_spo_rec.appeal_expiry_dt IS NULL AND v_spo_rec.appeal_dt IS NULL THEN
                            v_spo_rec.appeal_expiry_dt := IGS_PR_GEN_005.IGS_PR_clc_apl_expry
                                        (   p_course_cd,
                                        v_spo_rec.version_number,
                                        v_spo_rec.prg_cal_type,
                                        v_spo_rec.prg_ci_sequence_number,
                                        v_spo_rec.progression_rule_cat,
                                        v_spo_rec.pra_sequence_number,
                                        v_spo_rec.pro_sequence_number
                                        );
                -- Don't permit the appeal expiry date to be earlier than show cause.
                IF v_spo_rec.show_cause_expiry_dt IS NOT NULL AND v_spo_rec.appeal_expiry_dt IS NOT NULL
                                                              AND
                               v_spo_rec.appeal_expiry_dt < v_spo_rec.show_cause_expiry_dt THEN
                   v_spo_rec.appeal_expiry_dt := v_spo_rec.show_cause_expiry_dt;
                END IF;
              END IF;

              IF v_spo_rec.expiry_dt IS NULL OR v_spo_rec.expiry_dt > TRUNC(SYSDATE) THEN
                            -- IGS_PR_GEN_006.IGS_PR_get_spo_expiry calculates the expiry date of a student progression outcome record.
                            -- An open-ended expiry date returns with the value 01/01/4000.An un-determinable expiry date returns NULL.
                            v_expiry_status := IGS_PR_GEN_006.IGS_PR_get_spo_expiry
                                                                  ( p_person_id,
                                        p_course_cd,
                                        p_sequence_number,
                                        NULL,
                                        v_expiry_dt
                                           );
/*
                UPDATE  IGS_PR_STDNT_PR_OU
                    SET applied_dt      = SYSDATE,
                        expiry_dt       = v_expiry_dt,
                        show_cause_expiry_dt    = v_spo_rec.show_cause_expiry_dt,
                        appeal_expiry_dt    = v_spo_rec.appeal_expiry_dt
                    WHERE CURRENT OF c_spo;
                    */
                IGS_PR_STDNT_PR_OU_PKG.UPDATE_ROW(
                   X_ROWID                         => v_spo_rec.ROWID,
                   X_PERSON_ID                     => v_spo_rec.PERSON_ID,
                   X_COURSE_CD                     => v_spo_rec.COURSE_CD,
                   X_SEQUENCE_NUMBER               => v_spo_rec.SEQUENCE_NUMBER,
                   X_PRG_CAL_TYPE                  => v_spo_rec.PRG_CAL_TYPE,
                   X_PRG_CI_SEQUENCE_NUMBER        => v_spo_rec.PRG_CI_SEQUENCE_NUMBER,
                   X_RULE_CHECK_DT                 => v_spo_rec.RULE_CHECK_DT,
                   X_PROGRESSION_RULE_CAT          => v_spo_rec.PROGRESSION_RULE_CAT,
                   X_PRA_SEQUENCE_NUMBER           => v_spo_rec.PRA_SEQUENCE_NUMBER,
                   X_PRO_SEQUENCE_NUMBER           => v_spo_rec.PRO_SEQUENCE_NUMBER,
                   X_PROGRESSION_OUTCOME_TYPE      => v_spo_rec.PROGRESSION_OUTCOME_TYPE,
                   X_DURATION                      => v_spo_rec.DURATION,
                   X_DURATION_TYPE                 => v_spo_rec.DURATION_TYPE,
                   X_DECISION_STATUS               => v_spo_rec.DECISION_STATUS,
                   X_DECISION_DT                   => v_spo_rec.DECISION_DT,
                   X_DECISION_ORG_UNIT_CD          => v_spo_rec.DECISION_ORG_UNIT_CD,
                   X_DECISION_OU_START_DT          => v_spo_rec.DECISION_OU_START_DT,
                   X_APPLIED_DT                    => SYSDATE,
                   X_SHOW_CAUSE_EXPIRY_DT          => v_spo_rec.SHOW_CAUSE_EXPIRY_DT,
                           --the record variable above has been updated in the code before the update call
                   X_SHOW_CAUSE_DT                 => v_spo_rec.SHOW_CAUSE_DT,
                   X_SHOW_CAUSE_OUTCOME_DT         => v_spo_rec.SHOW_CAUSE_OUTCOME_DT,
                   X_SHOW_CAUSE_OUTCOME_TYPE       => v_spo_rec.SHOW_CAUSE_OUTCOME_TYPE,
                   X_APPEAL_EXPIRY_DT              => v_spo_rec.APPEAL_EXPIRY_DT,
                           --the record variable above has been updated in the code before the update call
                   X_APPEAL_DT                     => v_spo_rec.APPEAL_DT,
                   X_APPEAL_OUTCOME_DT             => v_spo_rec.APPEAL_OUTCOME_DT,
                   X_APPEAL_OUTCOME_TYPE           => v_spo_rec.APPEAL_OUTCOME_TYPE,
                   X_ENCMB_COURSE_GROUP_CD         => v_spo_rec.ENCMB_COURSE_GROUP_CD,
                   X_RESTRICTED_ENROLMENT_CP       => v_spo_rec.RESTRICTED_ENROLMENT_CP,
                   X_RESTRICTED_ATTENDANCE_TYPE    => v_spo_rec.RESTRICTED_ATTENDANCE_TYPE,
                   X_COMMENTS                      => v_spo_rec.COMMENTS,
                   X_SHOW_CAUSE_COMMENTS           => v_spo_rec.SHOW_CAUSE_COMMENTS,
                   X_APPEAL_COMMENTS               => v_spo_rec.APPEAL_COMMENTS,
                   X_EXPIRY_DT                     => v_expiry_dt,
                   X_PRO_PRA_SEQUENCE_NUMBER       => v_spo_rec.PRO_PRA_SEQUENCE_NUMBER,
                   X_MODE                          => 'R'
                 );


               ELSE
/*               UPDATE IGS_PR_STDNT_PR_OU
                             SET        applied_dt              = SYSDATE,
                    show_cause_expiry_dt    = v_spo_rec.show_cause_expiry_dt,
                    appeal_expiry_dt    = v_spo_rec.appeal_expiry_dt
                             WHERE CURRENT OF c_spo;
*/
                IGS_PR_STDNT_PR_OU_PKG.UPDATE_ROW(
                   X_ROWID                         => v_spo_rec.ROWID,
                   X_PERSON_ID                     => v_spo_rec.PERSON_ID,
                   X_COURSE_CD                     => v_spo_rec.COURSE_CD,
                   X_SEQUENCE_NUMBER               => v_spo_rec.SEQUENCE_NUMBER,
                   X_PRG_CAL_TYPE                  => v_spo_rec.PRG_CAL_TYPE,
                   X_PRG_CI_SEQUENCE_NUMBER        => v_spo_rec.PRG_CI_SEQUENCE_NUMBER,
                   X_RULE_CHECK_DT                 => v_spo_rec.RULE_CHECK_DT,
                   X_PROGRESSION_RULE_CAT          => v_spo_rec.PROGRESSION_RULE_CAT,
                   X_PRA_SEQUENCE_NUMBER           => v_spo_rec.PRA_SEQUENCE_NUMBER,
                   X_PRO_SEQUENCE_NUMBER           => v_spo_rec.PRO_SEQUENCE_NUMBER,
                   X_PROGRESSION_OUTCOME_TYPE      => v_spo_rec.PROGRESSION_OUTCOME_TYPE,
                   X_DURATION                      => v_spo_rec.DURATION,
                   X_DURATION_TYPE                 => v_spo_rec.DURATION_TYPE,
                   X_DECISION_STATUS               => v_spo_rec.DECISION_STATUS,
                   X_DECISION_DT                   => v_spo_rec.DECISION_DT,
                   X_DECISION_ORG_UNIT_CD          => v_spo_rec.DECISION_ORG_UNIT_CD,
                   X_DECISION_OU_START_DT          => v_spo_rec.DECISION_OU_START_DT,
                   X_APPLIED_DT                    => SYSDATE,
                   X_SHOW_CAUSE_EXPIRY_DT          => v_spo_rec.SHOW_CAUSE_EXPIRY_DT,
                           --the record variable above has been updated in the code before the update call
                   X_SHOW_CAUSE_DT                 => v_spo_rec.SHOW_CAUSE_DT,
                   X_SHOW_CAUSE_OUTCOME_DT         => v_spo_rec.SHOW_CAUSE_OUTCOME_DT,
                   X_SHOW_CAUSE_OUTCOME_TYPE       => v_spo_rec.SHOW_CAUSE_OUTCOME_TYPE,
                   X_APPEAL_EXPIRY_DT              => v_spo_rec.APPEAL_EXPIRY_DT,
                           --the record variable above has been updated in the code before the update call
                   X_APPEAL_DT                     => v_spo_rec.APPEAL_DT,
                   X_APPEAL_OUTCOME_DT             => v_spo_rec.APPEAL_OUTCOME_DT,
                   X_APPEAL_OUTCOME_TYPE           => v_spo_rec.APPEAL_OUTCOME_TYPE,
                   X_ENCMB_COURSE_GROUP_CD         => v_spo_rec.ENCMB_COURSE_GROUP_CD,
                   X_RESTRICTED_ENROLMENT_CP       => v_spo_rec.RESTRICTED_ENROLMENT_CP,
                   X_RESTRICTED_ATTENDANCE_TYPE    => v_spo_rec.RESTRICTED_ATTENDANCE_TYPE,
                   X_COMMENTS                      => v_spo_rec.COMMENTS,
                   X_SHOW_CAUSE_COMMENTS           => v_spo_rec.SHOW_CAUSE_COMMENTS,
                   X_APPEAL_COMMENTS               => v_spo_rec.APPEAL_COMMENTS,
                   X_EXPIRY_DT                     => v_spo_rec.expiry_dt,
                   X_PRO_PRA_SEQUENCE_NUMBER       => v_spo_rec.PRO_PRA_SEQUENCE_NUMBER,
                   X_MODE                          => 'R'
                 );
               END IF;
            ELSE
/*
              UPDATE  IGS_PR_STDNT_PR_OU
              SET     applied_dt    = NULL,
                  expiry_dt = NULL
              WHERE CURRENT OF c_spo;
*/
                IGS_PR_STDNT_PR_OU_PKG.UPDATE_ROW(
                   X_ROWID                         => v_spo_rec.ROWID,
                   X_PERSON_ID                     => v_spo_rec.PERSON_ID,
                   X_COURSE_CD                     => v_spo_rec.COURSE_CD,
                   X_SEQUENCE_NUMBER               => v_spo_rec.SEQUENCE_NUMBER,
                   X_PRG_CAL_TYPE                  => v_spo_rec.PRG_CAL_TYPE,
                   X_PRG_CI_SEQUENCE_NUMBER        => v_spo_rec.PRG_CI_SEQUENCE_NUMBER,
                   X_RULE_CHECK_DT                 => v_spo_rec.RULE_CHECK_DT,
                   X_PROGRESSION_RULE_CAT          => v_spo_rec.PROGRESSION_RULE_CAT,
                   X_PRA_SEQUENCE_NUMBER           => v_spo_rec.PRA_SEQUENCE_NUMBER,
                   X_PRO_SEQUENCE_NUMBER           => v_spo_rec.PRO_SEQUENCE_NUMBER,
                   X_PROGRESSION_OUTCOME_TYPE      => v_spo_rec.PROGRESSION_OUTCOME_TYPE,
                   X_DURATION                      => v_spo_rec.DURATION,
                   X_DURATION_TYPE                 => v_spo_rec.DURATION_TYPE,
                   X_DECISION_STATUS               => v_spo_rec.DECISION_STATUS,
                   X_DECISION_DT                   => v_spo_rec.DECISION_DT,
                   X_DECISION_ORG_UNIT_CD          => v_spo_rec.DECISION_ORG_UNIT_CD,
                   X_DECISION_OU_START_DT          => v_spo_rec.DECISION_OU_START_DT,
                   X_APPLIED_DT                    => NULL,
                   X_SHOW_CAUSE_EXPIRY_DT          => v_orig_SHOW_CAUSE_EXPIRY_DT,
                   X_SHOW_CAUSE_DT                 => v_spo_rec.SHOW_CAUSE_DT,
                   X_SHOW_CAUSE_OUTCOME_DT         => v_spo_rec.SHOW_CAUSE_OUTCOME_DT,
                   X_SHOW_CAUSE_OUTCOME_TYPE       => v_spo_rec.SHOW_CAUSE_OUTCOME_TYPE,
                   X_APPEAL_EXPIRY_DT              => v_orig_APPEAL_EXPIRY_DT,
                   X_APPEAL_DT                     => v_spo_rec.APPEAL_DT,
                   X_APPEAL_OUTCOME_DT             => v_spo_rec.APPEAL_OUTCOME_DT,
                   X_APPEAL_OUTCOME_TYPE           => v_spo_rec.APPEAL_OUTCOME_TYPE,
                   X_ENCMB_COURSE_GROUP_CD         => v_spo_rec.ENCMB_COURSE_GROUP_CD,
                   X_RESTRICTED_ENROLMENT_CP       => v_spo_rec.RESTRICTED_ENROLMENT_CP,
                   X_RESTRICTED_ATTENDANCE_TYPE    => v_spo_rec.RESTRICTED_ATTENDANCE_TYPE,
                   X_COMMENTS                      => v_spo_rec.COMMENTS,
                   X_SHOW_CAUSE_COMMENTS           => v_spo_rec.SHOW_CAUSE_COMMENTS,
                   X_APPEAL_COMMENTS               => v_spo_rec.APPEAL_COMMENTS,
                   X_EXPIRY_DT                     => NULL,
                   X_PRO_PRA_SEQUENCE_NUMBER       => v_spo_rec.PRO_PRA_SEQUENCE_NUMBER,
                   X_MODE                          => 'R'
                 );
            END IF;
        END IF;
        CLOSE c_spo;
        RETURN TRUE;
    EXCEPTION
        WHEN e_record_locked THEN
         IF c_spo%ISOPEN THEN
           CLOSE c_spo;
        END IF;
        RETURN FALSE;
        WHEN OTHERS THEN
          IF c_spo%ISOPEN THEN
            CLOSE c_spo;
          END IF;
          RAISE;
    END;
    EXCEPTION
      WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_OUT_APPLY.PRGPL_UPD_SPO');
        IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END prgpl_upd_spo;


  BEGIN
    -- Set the default out NOCOPY parameters
    p_message_text := NULL;
    p_message_level := NULL;
    IF p_spo_person_id IS NULL THEN
        v_application_type := cst_batch;
        -- Use the large rollback segment.
          -- the set transaction staement has been commented since it was carried over
          -- from callista and may not be relavant in the present CONTEXT
          -- amuthu 14-Dec-2001
        -- SET TRANSACTION USE ROLLBACK SEGMENT bigrbs;
        -- Generate a log entry
        v_key :=
            p_prg_cal_type                  || '|' ||
            TO_CHAR(p_prg_sequence_number)          || '|' ||
            p_course_type                   || '|' ||
            p_org_unit_cd                   || '|' ||
            igs_ge_date.igschardt(p_ou_start_dt)        || '|' ||
            p_course_cd                 || '|' ||
            p_location_cd                   || '|' ||
            p_attendance_mode               || '|' ||
            p_progression_status                || '|' ||
            p_enrolment_cat                 || '|' ||
            TO_CHAR(p_group_id);
        IGS_GE_GEN_003.GENP_INS_LOG (
                cst_prg_outcm,
                v_key,
                v_log_creation_dt);
        p_log_creation_dt := v_log_creation_dt;
    ELSE
        v_application_type := cst_manual;
    END IF;

    FOR v_spo_rec IN c_spo LOOP
      BEGIN  --Added to fix Bug# 3103892
        SAVEPOINT sp_before_spo_apply;
        v_process_next_spo := FALSE;
        v_message_name := NULL;
        -- Call routine to get configuration options for the course version
        IGS_PR_GEN_003.IGS_PR_get_config_parm (
                    v_spo_rec.course_cd,
                    v_spo_rec.version_number,
                    v_apply_start_dt_alias,
                    v_apply_end_dt_alias,
                    v_end_benefit_dt_alias,
                    v_end_penalty_dt_alias,
                    v_show_cause_cutoff_dt_alias,
                    v_appeal_cutoff_dt_alias,
                    v_show_cause_ind,
                    v_apply_before_show_ind,
                    v_appeal_ind,
                    v_apply_before_appeal_ind,
                    v_count_sus_in_time_ind,
                    v_count_exc_in_time_ind,
                    v_calculate_wam_ind,
                    v_calculate_gpa_ind,
                    v_outcome_check_type);
        IF v_spo_rec.decision_status = cst_approved THEN
            -- Check for show cause period ; not applied if still within period or
            -- student has shown cause and no outcome entered (assuming applying after
            -- show cause processing).
            -- Functionality
            --  A Show cause outcome cannot be applied to records which satisfy the following conditions :-
            --   1. When a show cause has not been given by a person and the show cause expiry date is set but has not expired.
            --

            --   2. If the person has given a show cause (Show cause date is set to then date when the person
            --      shows the cause for the progression outcome) and no decision on the show cause has been done yet
            --      --> denoted by the Show_cause_outcome_dt).

            --   3. Conditions 1 and 2 are valid only when a show cause expiry date is set and an outcome cannot be applied
            --      before the show cause period (denoted by apply_before_show_indicator).

            IF v_apply_before_show_ind = 'N' AND  v_spo_rec.show_cause_expiry_dt IS NOT NULL THEN
                IF (v_spo_rec.show_cause_dt IS NULL AND   TRUNC(SYSDATE) < v_spo_rec.show_cause_expiry_dt)
                                OR
                   (v_spo_rec.show_cause_dt IS NOT NULL AND v_spo_rec.show_cause_outcome_dt IS NULL)
                    THEN
                  -- Show cause is still in effect.. do not apply the outcomes yet
                  IF p_spo_person_id IS NOT NULL THEN
                      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNAB_APLY_OTCM_SC');
                      p_message_text := FND_MESSAGE.GET;
                      p_message_level := cst_warn;
                      EXIT;
                  END IF;
                   v_process_next_spo := TRUE;
                END IF;
            END IF;

            -- Check for appeal period ; not applied if still within period or appeal
            -- in progress (assuming applying after appeal processing).
            -- Functionality for appeal is the same as that for Showcause.
            IF NOT v_process_next_spo THEN
                IF v_apply_before_appeal_ind = 'N' AND  v_spo_rec.appeal_expiry_dt IS NOT NULL THEN
                    IF (v_spo_rec.appeal_dt IS NULL AND  TRUNC(SYSDATE) < v_spo_rec.appeal_expiry_dt)
                                OR
                       (v_spo_rec.appeal_dt IS NOT NULL AND v_spo_rec.appeal_outcome_dt IS NULL) THEN
                       -- Appeal period is still in effect.. do not apply outcomes
                      IF p_spo_person_id IS NOT NULL THEN
                         FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNAB_APLY_OTCM_AP');
                         p_message_text := FND_MESSAGE.GET;
                         p_message_level := cst_warn;
                         EXIT;
                      END IF;
                        v_process_next_spo := TRUE;
                    END IF;
                END IF;
            END IF;


            IF NOT v_process_next_spo THEN

              -- check for student progression outomces resulting in awards
                IF v_spo_rec.s_progression_outcome_type = cst_award THEN
                  IF NOT prgpl_upd_spo (
                           v_spo_rec.person_id,
                           v_spo_rec.course_cd,
                           v_spo_rec.sequence_number,
                           v_show_cause_ind,
                           v_apply_before_show_ind,
                           v_appeal_ind,
                           v_apply_before_appeal_ind
                           ) THEN

                    -- REcord locked
                    ROLLBACK TO sp_before_spo_apply;
                    IF p_spo_person_id IS NULL THEN
                      v_process_next_spo := TRUE;
                    ELSE
                      p_message_level := cst_error;
                    END IF;
                  ELSE

                    OPEN c_spa (v_spo_rec.person_id,
                              v_spo_rec.course_cd,
                              v_spo_rec.sequence_number);
                    FETCH c_spa INTO v_spa_award_cd;

                    IF c_spa%FOUND THEN
                      DECLARE
                        lv_rowid VARCHAR2(25);
                        lv_org_id IGS_GR_SPECIAL_AWARD_ALL.ORG_ID%TYPE;
                      BEGIN
                        lv_org_id := igs_ge_gen_003.get_org_id();
                        --Insert into special award record
                        IGS_GR_SPECIAL_AWARD_PKG.INSERT_ROW(
                          X_ROWID                         => lv_ROWID,
                          X_PERSON_ID                     => v_spo_rec.PERSON_ID,
                          X_COURSE_CD                     => v_spo_rec.COURSE_CD,
                          X_AWARD_CD                      => v_spa_AWARD_CD,
                          X_AWARD_DT                      => SYSDATE,
                          X_CEREMONY_ANNOUNCED_IND        => 'Y',
                          X_COMMENTS                      => 'Created from Progression',
                          X_MODE                          => 'R',
                          X_ORG_ID                        => lv_org_id
                                    );
                                  END;

                                  IF p_spo_person_id IS NULL THEN
                                    prgpl_ins_log_entry(
                          v_log_creation_dt,
                          cst_award,
                          v_spo_rec.person_id,
                          v_spo_rec.course_cd,
                          v_spo_rec.prg_cal_type,
                          v_spo_rec.prg_ci_sequence_number,
                          v_spo_rec.sequence_number,
                          v_spo_rec.progression_outcome_type,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL);
                      END IF;
                    END IF;
                  END IF;
                END IF;

                IF v_spo_rec.s_progression_outcome_type IN (
                                    cst_manual,
                                    cst_nopenalty) THEN
                    IF NOT prgpl_upd_spo (
                                v_spo_rec.person_id,
                                v_spo_rec.course_cd,
                                v_spo_rec.sequence_number,
                                v_show_cause_ind,
                                v_apply_before_show_ind,
                                v_appeal_ind,
                                v_apply_before_appeal_ind) THEN
                        -- Record locked
                        ROLLBACK TO sp_before_spo_apply;
                        IF p_spo_person_id IS NULL THEN
                            v_process_next_spo := TRUE;
                        ELSE
                            FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_DTLS_TA');
                            p_message_text := FND_MESSAGE.GET;
                            p_message_level := cst_error;
                            EXIT;
                        END IF;
                    ELSE
                        IF p_spo_person_id IS NULL THEN
                            IF v_spo_rec.s_progression_outcome_type = cst_manual THEN
                                prgpl_ins_log_entry (
                                    v_log_creation_dt,
                                    cst_manual,
                                    v_spo_rec.person_id,
                                    v_spo_rec.course_cd,
                                    v_spo_rec.prg_cal_type,
                                    v_spo_rec.prg_ci_sequence_number,
                                    v_spo_rec.sequence_number,
                                    v_spo_rec.progression_outcome_type,
                                    NULL,
                                    NULL,
                                    NULL,
                                    'IGS_PR_UPD_OUT_APPLY',
                                    NULL);
                            ELSE
                                prgpl_ins_log_entry (
                                    v_log_creation_dt,
                                    cst_nopenalty,
                                    v_spo_rec.person_id,
                                    v_spo_rec.course_cd,
                                    v_spo_rec.prg_cal_type,
                                    v_spo_rec.prg_ci_sequence_number,
                                    v_spo_rec.sequence_number,
                                    v_spo_rec.progression_outcome_type,
                                    NULL,
                                    NULL,
                                    NULL,
                                    'IGS_PR_UPD_NOPEN_APPLY',
                                    NULL);
                            END IF;
                        END IF;
                    END IF;
                ELSE
                    IF v_spo_rec.s_progression_outcome_type IN (
                                        cst_suspension,
                                        cst_exclusion,
                                        cst_expulsion) THEN

                        -- Call routine to determine the prospective expiry date
                        v_expiry_status := IGS_PR_GEN_006.IGS_PR_get_spo_expiry (
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd,
                                            v_spo_rec.sequence_number,
                                            v_spo_rec.expiry_dt,
                                            v_expiry_dt);
                        IF v_expiry_dt IS NULL OR  v_expiry_dt > TRUNC(SYSDATE) THEN

                            FOR v_sca_rec IN c_sca2 (
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_rec.sequence_number,
                                        v_spo_rec.encmb_course_group_cd) LOOP

                                -- Get the default discontinuation reason code applicable to progression

                                 v_discont_reason_cd := igs_en_gen_008.enrp_get_dflt_sdrt (cst_progress);    -- Modified by Prajeesh Uncommented the code and the new code added to igs_en_gen_008

                                IF v_discont_reason_cd IS NULL THEN
                                    IF p_spo_person_id IS NULL THEN
                                        prgpl_ins_log_entry (
                                                v_log_creation_dt,
                                                cst_disc_err,
                                                v_spo_rec.person_id,
                                                v_spo_rec.course_cd,
                                                v_spo_rec.prg_cal_type,
                                                v_spo_rec.prg_ci_sequence_number,
                                                v_spo_rec.sequence_number,
                                                v_spo_rec.progression_outcome_type,
                                                NULL,
                                                NULL,
                                                NULL,
                                                'IGS_PR_DISCON_RSN_CD',
                                                NULL);
                                        v_process_next_spo := TRUE;
                                        EXIT;
                                    ELSE
                                        p_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_PR_DISCON_RSN_CD');
                                        p_message_level := cst_error;
                                        v_exit_procedure := TRUE;
                                        EXIT;
                                    END IF;
                                END IF;

                            -- Call routine to discontinue the student course attempt

                                IF NOT IGS_EN_GEN_012.ENRP_UPD_SCA_DISCONT (
                                            v_sca_rec.person_id,
                                            v_sca_rec.course_cd,
                                            v_sca_rec.version_number,
                                            v_sca_rec.course_attempt_status,
                                            v_sca_rec.commencement_dt,
                                            v_spo_rec.decision_dt,
                                            v_discont_reason_cd,
                                            v_message_name,
                                            'PROGRAM_DISCONTINUE'  -- new parameter added to this procedure as part of enh bug 2599925
                                 ) THEN
                                    ROLLBACK TO sp_before_spo_apply;
                                    IF v_message_name IN (
                                            'IGS_EN_DISCONT_DT_LT_COMM_DT',
                                            'IGS_EN_UNITVERSION_INACTIVE',
                                            'IGS_EN_ONLY_SPA_ST_ENROLLED',
                                            'IGS_EN_ONLY_SPA_ST_ENROLLED',
                                            'IGS_PS_CP_MAX_DECR_ENR_CP',
                                            'IGS_EN_DISCONT_DT_GE_ENRDT',
                                            'IGS_EN_ENROL_SUA_DISCONT',
                                            'IGS_EN_DISCONT_ADM_UNIT_ST',
                                            'IGS_EN_SPA_NOTDISCONT_PRIOR',
                                            'IGS_EN_SUA_DISCONT_FUTUREDT',
                                            'IGS_EN_SUA_NOT_DISCONT',
                                            'IGS_EN_ONE_SUA_NOTBE_DISCONT',
                                            'IGS_EN_ONE_SUA_NOT_DISCONTINU') THEN
                                        v_message_name := 'IGS_EN_ONE_SUA_NOT_DISCONTINU';
                                    END IF;

                                    IF p_spo_person_id IS NULL THEN
                                        IF v_message_name <> 'IGS_EN_UNABLE_UPD_STUDENR' THEN
                                            prgpl_ins_log_entry (
                                                    v_log_creation_dt,
                                                    cst_disc_err,
                                                    v_spo_rec.person_id,
                                                    v_spo_rec.course_cd,
                                                    v_spo_rec.prg_cal_type,
                                                    v_spo_rec.prg_ci_sequence_number,
                                                    v_spo_rec.sequence_number,
                                                    v_spo_rec.progression_outcome_type,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    v_message_name,
                                                    NULL);
                                        END IF;
                                        v_process_next_spo := TRUE;
                                        EXIT;
                                    ELSE
                                        FND_MESSAGE.SET_NAME ('IGS', v_message_name);
                                        p_message_text := FND_MESSAGE.GET;
                                        p_message_level := cst_error;
                                        v_exit_procedure := TRUE;
                                        EXIT;
                                    END IF;
                                ELSE
                                    IF p_spo_person_id IS NULL THEN
                                        prgpl_ins_log_entry (
                                                v_log_creation_dt,
                                                cst_discontin,
                                                v_spo_rec.person_id,
                                                v_spo_rec.course_cd,
                                                v_spo_rec.prg_cal_type,
                                                v_spo_rec.prg_ci_sequence_number,
                                                v_spo_rec.sequence_number,
                                                v_spo_rec.progression_outcome_type,
                                                NULL,
                                                NULL,
                                                NULL,
                                                'IGS_PR_UPD_PR_ATT_DISCON',
                                                NULL);
                                    END IF;
                                END IF;
                            END LOOP; -- c_sca2
                            IF NOT v_process_next_spo AND  NOT v_exit_procedure THEN
                                BEGIN

                                    FOR v_susa_rec IN c_susa (
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd,
                                            v_spo_rec.sequence_number) LOOP

                                        IF v_susa_rec.acai_ind = 'Y' THEN
                                            -- Requires authorisation ; abort.
                                            ROLLBACK TO sp_before_spo_apply;
                                                           IF p_spo_person_id IS NULL THEN
                                                prgpl_ins_log_entry (
                                                    v_log_creation_dt,
                                                    cst_usdisc_err,
                                                    v_spo_rec.person_id,
                                                    v_spo_rec.course_cd,
                                                    v_spo_rec.prg_cal_type,
                                                    v_spo_rec.prg_ci_sequence_number,
                                                    v_spo_rec.sequence_number,
                                                    v_spo_rec.progression_outcome_type,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'IGS_PR_UPD_END_SUA',
                                                    NULL);
                                                v_process_next_spo := TRUE;
                                                EXIT;
                                             ELSE
                                                p_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_PR_UPD_END_SUA');
                                                p_message_level := cst_error;
                                                v_exit_procedure := TRUE;
                                                EXIT;
                                             END IF;
                                        ELSE
/*
                                            UPDATE IGS_AS_SU_SETATMPT
                                            SET end_dt = v_spo_rec.decision_dt,
                                                voluntary_end_ind = 'N'
                                            WHERE CURRENT OF c_susa;

*/

                                          IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW(
                                            X_ROWID => v_susa_rec.ROWID,
                                            X_PERSON_ID => v_susa_rec.PERSON_ID,
                                            X_COURSE_CD => v_susa_rec.COURSE_CD,
                                            X_UNIT_SET_CD => v_susa_rec.UNIT_SET_CD,
                                            X_SEQUENCE_NUMBER => v_susa_rec.SEQUENCE_NUMBER,
                                            X_US_VERSION_NUMBER => v_susa_rec.US_VERSION_NUMBER,
                                            X_SELECTION_DT => v_susa_rec.SELECTION_DT,
                                            X_STUDENT_CONFIRMED_IND => v_susa_rec.STUDENT_CONFIRMED_IND,
                                            X_END_DT => v_spo_rec.decision_dt,
                                            X_PARENT_UNIT_SET_CD => v_susa_rec.PARENT_UNIT_SET_CD,
                                            X_PARENT_SEQUENCE_NUMBER => v_susa_rec.PARENT_SEQUENCE_NUMBER,
                                            X_PRIMARY_SET_IND => v_susa_rec.PRIMARY_SET_IND,
                                            X_VOLUNTARY_END_IND => 'N',
                                            X_AUTHORISED_PERSON_ID => v_susa_rec.AUTHORISED_PERSON_ID,
                                            X_AUTHORISED_ON => v_susa_rec.AUTHORISED_ON,
                                            X_OVERRIDE_TITLE => v_susa_rec.OVERRIDE_TITLE,
                                            X_RQRMNTS_COMPLETE_IND => v_susa_rec.RQRMNTS_COMPLETE_IND,
                                            X_RQRMNTS_COMPLETE_DT => v_susa_rec.RQRMNTS_COMPLETE_DT,
                                            X_S_COMPLETED_SOURCE_TYPE => v_susa_rec.S_COMPLETED_SOURCE_TYPE,
                                            X_CATALOG_CAL_TYPE => v_susa_rec.CATALOG_CAL_TYPE,
                                            X_CATALOG_SEQ_NUM => v_susa_rec.CATALOG_SEQ_NUM,
                                            X_ATTRIBUTE_CATEGORY    => v_susa_rec.ATTRIBUTE_CATEGORY    ,
                                            X_ATTRIBUTE1 => v_susa_rec.ATTRIBUTE1 ,
                                            X_ATTRIBUTE2 => v_susa_rec.ATTRIBUTE2 ,
                                            X_ATTRIBUTE3 => v_susa_rec.ATTRIBUTE3 ,
                                            X_ATTRIBUTE4 => v_susa_rec.ATTRIBUTE4 ,
                                            X_ATTRIBUTE5 => v_susa_rec.ATTRIBUTE5 ,
                                            X_ATTRIBUTE6 => v_susa_rec.ATTRIBUTE6 ,
                                            X_ATTRIBUTE7 => v_susa_rec.ATTRIBUTE7 ,
                                            X_ATTRIBUTE8 => v_susa_rec.ATTRIBUTE8 ,
                                            X_ATTRIBUTE9 => v_susa_rec.ATTRIBUTE9 ,
                                            X_ATTRIBUTE10=> v_susa_rec.ATTRIBUTE10,
                                            X_ATTRIBUTE11=> v_susa_rec.ATTRIBUTE11,
                                            X_ATTRIBUTE12=> v_susa_rec.ATTRIBUTE12,
                                            X_ATTRIBUTE13=> v_susa_rec.ATTRIBUTE13,
                                            X_ATTRIBUTE14=> v_susa_rec.ATTRIBUTE14,
                                            X_ATTRIBUTE15=> v_susa_rec.ATTRIBUTE15,
                                            X_ATTRIBUTE16=> v_susa_rec.ATTRIBUTE16,
                                            X_ATTRIBUTE17=> v_susa_rec.ATTRIBUTE17,
                                            X_ATTRIBUTE18=> v_susa_rec.ATTRIBUTE18,
                                            X_ATTRIBUTE19=> v_susa_rec.ATTRIBUTE19,
                                            X_ATTRIBUTE20=> v_susa_rec.ATTRIBUTE20,
                                            X_MODE => 'R'
                                          );

                                        END IF;
                                    END LOOP;   -- c_susa
                                EXCEPTION
                                    WHEN e_record_locked THEN
                                        IF c_susa%ISOPEN THEN
                                            CLOSE c_susa;
                                        END IF;
                                        ROLLBACK TO sp_before_spo_apply;
                                        IF p_spo_person_id IS NOT NULL THEN
                                            FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_SUSA_TA');
                                            p_message_text := FND_MESSAGE.GET;
                                            p_message_level := cst_error;
                                            EXIT;
                                        ELSE
                                            v_process_next_spo := TRUE;
                                        END IF;
                                    WHEN OTHERS THEN
                                        RAISE;
                                END;
                            END IF;
                            IF NOT v_process_next_spo AND
                                    NOT v_exit_procedure THEN
                                -- Discontinue unit attempts
                                BEGIN
                                    v_sua_upd_or_del := FALSE;

                                    FOR v_sua_rec IN c_sua (
                                                v_spo_rec.person_id,
                                                v_spo_rec.course_cd,
                                                v_spo_rec.sequence_number) LOOP
                                        -- Check whether delete of unit attempt is permissable
                                        -- Added the OR clause in the below If condtion OR unit_attempt status is WAITLISTED
                                        -- Added by Nishikant - bug#2364216. If the status is WAITLISTED then no need to
                                        -- check whether the unit attempt can be deleted.
                                        IF ( IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD (
                                                    v_sua_rec.cal_type,
                                                    v_sua_rec.ci_sequence_number,
                                                    v_spo_rec.decision_dt,
                                                    v_sua_rec.uoo_id) = 'Y' OR
                                                    v_sua_rec.unit_attempt_status = 'WAITLISTED') THEN
                                            --
                                            -- kdande; 22-Apr-2003; Bug# 2829262
                                            -- Passing uoo_id parameter to the cursor c_suao
                                            --
                                            OPEN c_suao (
                                                v_spo_rec.person_id,
                                                v_spo_rec.course_cd,
                                                v_sua_rec.unit_cd,
                                                v_sua_rec.cal_type,
                                                v_sua_rec.ci_sequence_number,
                                                v_sua_rec.uoo_id);
                                            FETCH c_suao INTO v_dummy;
                                            IF c_suao%FOUND THEN
                                                CLOSE c_suao;
                                                IF p_spo_person_id IS NULL THEN
                                                    prgpl_ins_log_entry (
                                                        v_log_creation_dt,
                                                        cst_udisc_err,
                                                        v_spo_rec.person_id,
                                                        v_spo_rec.course_cd,
                                                        v_spo_rec.prg_cal_type,
                                                        v_spo_rec.prg_ci_sequence_number,
                                                        v_spo_rec.sequence_number,
                                                        v_spo_rec.progression_outcome_type,
                                                        v_spo_rec.duration_type,
                                                        v_spo_rec.duration,
                                                        NULL,
                                                        'IGS_PR_DISCON_UNIT',
                                                        NULL);
                                                ELSE
                                                    IF p_message_level IS NULL THEN
                                                        p_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_PR_DISCON_UNIT');
                                                        p_message_level := cst_warning;
                                                    END IF;
                                                END IF;
                                            ELSE
                                                CLOSE c_suao;
                                                -- Added by Nishikant - 15may2002 - bug#2364216
                                                -- Earlier it was deleting the student unit attempt record here and now its
                                                -- modified to update the record with unit attempt status as DROPPED.
                                                                                    invoke_drop_workflow(
                                                                                           p_uoo_id                   => v_sua_rec.uoo_id,
                                                                                           p_unit_cd                  => v_sua_rec.unit_cd,
                                                                                           p_teach_cal_type           => v_sua_rec.cal_type,
                                                                                           p_teach_ci_sequence_number => v_sua_rec.ci_sequence_number,
                                                                                           p_person_id                => v_sua_rec.person_id,
                                                                                           p_course_cd                => v_sua_rec.course_cd,
                                                                                           p_message_name             => v_message_name);
                                                                                      igs_en_sua_api.update_unit_attempt (
                                                                                              X_ROWID => v_sua_rec.rowid,
                                                                                              X_PERSON_ID  => v_sua_rec.person_id,
                                                                                              X_COURSE_CD  => v_sua_rec.course_cd,
                                                                                              X_UNIT_CD  => v_sua_rec.unit_cd,
                                                                                              X_CAL_TYPE  => v_sua_rec.cal_type,
                                                                                              X_CI_SEQUENCE_NUMBER  => v_sua_rec.ci_sequence_number,
                                                                                              X_VERSION_NUMBER  => v_sua_rec.version_number,
                                                                                              X_LOCATION_CD  => v_sua_rec.location_cd,
                                                                                              X_UNIT_CLASS  => v_sua_rec.unit_class,
                                                                                              X_CI_START_DT  => v_sua_rec.ci_start_dt,
                                                                                              X_CI_END_DT  => v_sua_rec.ci_end_dt,
                                                                                              X_UOO_ID  => v_sua_rec.uoo_id,
                                                                                              X_ENROLLED_DT  => v_sua_rec.enrolled_dt,
                                                                                              X_UNIT_ATTEMPT_STATUS  => 'DROPPED',
                                                                                              X_ADMINISTRATIVE_UNIT_STATUS  => v_sua_rec.administrative_unit_status,
                                                                                              X_DISCONTINUED_DT  => nvl(trunc(v_sua_rec.discontinued_dt), trunc(SYSDATE)),
                                                                                              X_RULE_WAIVED_DT  =>v_sua_rec.rule_waived_dt,
                                                                                              X_RULE_WAIVED_PERSON_ID  =>v_sua_rec.rule_waived_person_id,
                                                                                              X_NO_ASSESSMENT_IND  => v_sua_rec.no_assessment_ind,
                                                                                              X_SUP_UNIT_CD  => v_sua_rec.sup_unit_cd,
                                                                                              X_SUP_VERSION_NUMBER  => v_sua_rec.sup_version_number,
                                                                                              X_EXAM_LOCATION_CD  => v_sua_rec.exam_location_cd,
                                                                                              X_ALTERNATIVE_TITLE  => v_sua_rec.alternative_title,
                                                                                              X_OVERRIDE_ENROLLED_CP  => v_sua_rec.override_enrolled_cp,
                                                                                              X_OVERRIDE_EFTSU  => v_sua_rec.override_eftsu,
                                                                                              X_OVERRIDE_ACHIEVABLE_CP  => v_sua_rec.override_achievable_cp,
                                                                                              X_OVERRIDE_OUTCOME_DUE_DT  => v_sua_rec.override_outcome_due_dt,
                                                                                              X_OVERRIDE_CREDIT_REASON  => v_sua_rec.override_credit_reason,
                                                                                              X_ADMINISTRATIVE_PRIORITY  => v_sua_rec.administrative_priority,
                                                                                              X_WAITLIST_DT  => v_sua_rec.waitlist_dt,
                                                                                              X_DCNT_REASON_CD  => v_sua_rec.dcnt_reason_cd,
                                                                                              X_MODE            => 'R',
                                                                                              X_GS_VERSION_NUMBER => v_sua_rec.gs_version_number,
                                                                                              X_ENR_METHOD_TYPE   => v_sua_rec.enr_method_type,
                                                                                              X_FAILED_UNIT_RULE  => v_sua_rec.failed_unit_rule,
                                                                                              X_CART              => v_sua_rec.cart,
                                                                                              X_RSV_SEAT_EXT_ID   => v_sua_rec.rsv_seat_ext_id,
                                                                                              X_ORG_UNIT_CD   =>  v_sua_rec.org_unit_cd,
                                                                                              X_GRADING_SCHEMA_CODE => v_sua_rec.grading_schema_code,
                                                                                              X_SESSION_ID         =>  v_sua_rec.session_id,
                                                                                              X_DEG_AUD_DETAIL_ID   => v_sua_rec.deg_aud_detail_id,
                                                                                              X_SUBTITLE       =>  v_sua_rec.subtitle,
                                                                                              X_STUDENT_CAREER_TRANSCRIPT =>  v_sua_rec.student_career_transcript,
                                                                                              X_STUDENT_CAREER_STATISTICS =>  v_sua_rec.student_career_statistics,
                                                                                              X_ATTRIBUTE_CATEGORY        =>  v_sua_rec.attribute_category,
                                                                                              X_ATTRIBUTE1                =>  v_sua_rec.attribute1,
                                                                                              X_ATTRIBUTE2                =>  v_sua_rec.attribute2,
                                                                                              X_ATTRIBUTE3                =>  v_sua_rec.attribute3,
                                                                                              X_ATTRIBUTE4                =>  v_sua_rec.attribute4,
                                                                                              X_ATTRIBUTE5                =>  v_sua_rec.attribute5,
                                                                                              X_ATTRIBUTE6                =>  v_sua_rec.attribute6,
                                                                                              X_ATTRIBUTE7                =>  v_sua_rec.attribute7,
                                                                                              X_ATTRIBUTE8                =>  v_sua_rec.attribute8,
                                                                                              X_ATTRIBUTE9                =>  v_sua_rec.attribute9,
                                                                                              X_ATTRIBUTE10               =>  v_sua_rec.attribute10,
                                                                                              X_ATTRIBUTE11               =>  v_sua_rec.attribute11,
                                                                                              X_ATTRIBUTE12               =>  v_sua_rec.attribute12,
                                                                                              X_ATTRIBUTE13               =>  v_sua_rec.attribute13,
                                                                                              X_ATTRIBUTE14               =>  v_sua_rec.attribute14,
                                                                                              X_ATTRIBUTE15               =>  v_sua_rec.attribute15,
                                                                                              X_ATTRIBUTE16               =>  v_sua_rec.attribute16,
                                                                                              X_ATTRIBUTE17               =>  v_sua_rec.attribute17,
                                                                                              X_ATTRIBUTE18               =>  v_sua_rec.attribute18,
                                                                                              X_ATTRIBUTE19               =>  v_sua_rec.attribute19,
                                                                                              X_ATTRIBUTE20               =>  v_sua_rec.attribute20,
                                                                                              X_WAITLIST_MANUAL_IND       =>  v_sua_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                                                                              X_WLST_PRIORITY_WEIGHT_NUM  =>  v_sua_rec.wlst_priority_weight_num,
                                                                                              X_WLST_PREFERENCE_WEIGHT_NUM=>  v_sua_rec.wlst_preference_weight_num,
											      -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
											      X_CORE_INDICATOR_CODE       =>  v_sua_rec.core_indicator_code
                                                                                              );
                                                                                                v_sua_upd_or_del := TRUE;
                                            END IF;
                                        ELSE    -- Discontinue ; not delete
                                            -- Get the appropriate administrative status
                                            v_administrative_unit_status :=
                                                    IGS_EN_GEN_008.ENRP_GET_UDDC_AUS (
                                                            v_spo_rec.decision_dt,
                                                            v_sua_rec.cal_type,
                                                            v_sua_rec.ci_sequence_number,
                                                            v_admin_unit_status_str,
                                                            v_alias_val,
                                                            v_sua_rec.uoo_id);
                                            IF v_administrative_unit_status IS NULL THEN
                                                IF p_spo_person_id IS NULL THEN
                                                    prgpl_ins_log_entry (
                                                        v_log_creation_dt,
                                                        cst_udisc_err,
                                                        v_spo_rec.person_id,
                                                        v_spo_rec.course_cd,
                                                        v_spo_rec.prg_cal_type,
                                                        v_spo_rec.prg_ci_sequence_number,
                                                        v_spo_rec.sequence_number,
                                                        v_spo_rec.progression_outcome_type,
                                                        v_spo_rec.duration_type,
                                                        v_spo_rec.duration,
                                                        NULL,
                                                        'IGS_PR_DISCON_UNIT',
                                                        NULL);
                                                ELSE
                                                    IF p_message_level IS NULL THEN
                                                        p_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_PR_DISCON_UNIT');
                                                        p_message_level := cst_warning;
                                                    END IF;
                                                END IF;
                                            ELSE
                                                -- Validate that the discontinuation is OK
                                                IF NOT IGS_EN_VAL_SUA.enrp_val_sua_discont (
                                                        v_spo_rec.person_id,
                                                        v_spo_rec.course_cd,
                                                        v_sua_rec.unit_cd,
                                                        v_sua_rec.version_number,
                                                        v_sua_rec.ci_start_dt,
                                                        v_sua_rec.enrolled_dt,
                                                        v_administrative_unit_status,
                                                        v_sua_rec.unit_attempt_status,
                                                        v_spo_rec.decision_dt,
                                                        v_message_name,
                                                        'N') THEN
                                                    IF p_spo_person_id IS NULL THEN
                                                        prgpl_ins_log_entry (
                                                            v_log_creation_dt,
                                                            cst_udisc_err,
                                                            v_spo_rec.person_id,
                                                            v_spo_rec.course_cd,
                                                            v_spo_rec.prg_cal_type,
                                                            v_spo_rec.prg_ci_sequence_number,
                                                            v_spo_rec.sequence_number,
                                                            v_spo_rec.progression_outcome_type,
                                                            v_spo_rec.duration_type,
                                                            v_spo_rec.duration,
                                                            NULL,
                                                            'IGS_PR_DISCON_UNIT',
                                                            NULL);
                                                    ELSE
                                                        IF p_message_level IS NULL THEN
                                                            p_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_PR_DISCON_UNIT');
                                                            p_message_level := cst_warning;
                                                        END IF;
                                                    END IF;

                                                ELSE

                                                    -- Discontinue unit attempt
/*
                                                    UPDATE  IGS_EN_SU_ATTEMPT
                                                    SET discontinued_dt = v_spo_rec.decision_dt,
                                                    administrative_unit_status = v_administrative_unit_status
                                                    WHERE CURRENT OF c_sua;
*/
                                                      invoke_drop_workflow(
                                                      p_uoo_id                   => v_sua_rec.uoo_id,
                                                      p_unit_cd                  => v_sua_rec.unit_cd,
                                                      p_teach_cal_type           => v_sua_rec.cal_type,
                                                      p_teach_ci_sequence_number => v_sua_rec.ci_sequence_number,
                                                      p_person_id                => v_sua_rec.person_id,
                                                      p_course_cd                => v_sua_rec.course_cd,
                                                      p_message_name             => v_message_name );
                                                      igs_en_sua_api.update_unit_attempt(
                                                        X_ROWID                         => v_sua_rec.ROWID,
                                                        X_PERSON_ID                     => v_sua_rec.PERSON_ID,
                                                        X_COURSE_CD                     => v_sua_rec.COURSE_CD,
                                                        X_UNIT_CD                       => v_sua_rec.UNIT_CD,
                                                        X_CAL_TYPE                      => v_sua_rec.CAL_TYPE,
                                                        X_CI_SEQUENCE_NUMBER            => v_sua_rec.CI_SEQUENCE_NUMBER,
                                                        X_VERSION_NUMBER                => v_sua_rec.VERSION_NUMBER,
                                                        X_LOCATION_CD                   => v_sua_rec.LOCATION_CD,
                                                        X_UNIT_CLASS                    => v_sua_rec.UNIT_CLASS,
                                                        X_CI_START_DT                   => v_sua_rec.CI_START_DT,
                                                        X_CI_END_DT                     => v_sua_rec.CI_END_DT,
                                                        X_UOO_ID                        => v_sua_rec.UOO_ID,
                                                        X_ENROLLED_DT                   => v_sua_rec.ENROLLED_DT,
                                                        X_UNIT_ATTEMPT_STATUS           => v_sua_rec.UNIT_ATTEMPT_STATUS,
                                                        X_ADMINISTRATIVE_UNIT_STATUS    => v_administrative_unit_status,
                                                        X_DISCONTINUED_DT               => v_spo_rec.decision_dt,
                                                        X_RULE_WAIVED_DT                => v_sua_rec.RULE_WAIVED_DT,
                                                        X_RULE_WAIVED_PERSON_ID         => v_sua_rec.RULE_WAIVED_PERSON_ID,
                                                        X_NO_ASSESSMENT_IND             => v_sua_rec.NO_ASSESSMENT_IND,
                                                        X_SUP_UNIT_CD                   => v_sua_rec.SUP_UNIT_CD,
                                                        X_SUP_VERSION_NUMBER            => v_sua_rec.SUP_VERSION_NUMBER,
                                                        X_EXAM_LOCATION_CD              => v_sua_rec.EXAM_LOCATION_CD,
                                                        X_ALTERNATIVE_TITLE             => v_sua_rec.ALTERNATIVE_TITLE,
                                                        X_OVERRIDE_ENROLLED_CP          => v_sua_rec.OVERRIDE_ENROLLED_CP,
                                                        X_OVERRIDE_EFTSU                => v_sua_rec.OVERRIDE_EFTSU,
                                                        X_OVERRIDE_ACHIEVABLE_CP        => v_sua_rec.OVERRIDE_ACHIEVABLE_CP,
                                                        X_OVERRIDE_OUTCOME_DUE_DT       => v_sua_rec.OVERRIDE_OUTCOME_DUE_DT,
                                                        X_OVERRIDE_CREDIT_REASON        => v_sua_rec.OVERRIDE_CREDIT_REASON,
                                                        X_ADMINISTRATIVE_PRIORITY       => v_sua_rec.ADMINISTRATIVE_PRIORITY,
                                                        X_WAITLIST_DT                   => v_sua_rec.WAITLIST_DT,
                                                        X_DCNT_REASON_CD                => v_sua_rec.DCNT_REASON_CD,
                                                        X_MODE                          => 'R',
                                                        X_GS_VERSION_NUMBER             => v_sua_rec.GS_VERSION_NUMBER,
                                                        X_ENR_METHOD_TYPE               => v_sua_rec.ENR_METHOD_TYPE,
                                                        X_FAILED_UNIT_RULE              => v_sua_rec.FAILED_UNIT_RULE,
                                                        X_CART                          => v_sua_rec.CART,
                                                        X_RSV_SEAT_EXT_ID               => v_sua_rec.RSV_SEAT_EXT_ID,
                                                        X_ORG_UNIT_CD                   => v_sua_rec.ORG_UNIT_CD,
                                                        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                                        X_SESSION_ID                    => v_sua_rec.SESSION_ID,
                                                        X_GRADING_SCHEMA_CODE           => v_sua_rec.GRADING_SCHEMA_CODE,
                                                        X_SUBTITLE                      => v_sua_rec.SUBTITLE,
                                                        X_DEG_AUD_DETAIL_ID             => v_sua_rec.DEG_AUD_DETAIL_ID,
                                                        X_STUDENT_CAREER_TRANSCRIPT     => v_sua_rec.STUDENT_CAREER_TRANSCRIPT,
                                                        X_STUDENT_CAREER_STATISTICS     => v_sua_rec.STUDENT_CAREER_STATISTICS  ,
                                                        X_ATTRIBUTE_CATEGORY            => v_sua_rec.ATTRIBUTE_CATEGORY,
                                                        X_ATTRIBUTE1                    => v_sua_rec.ATTRIBUTE1,
                                                        X_ATTRIBUTE2                    => v_sua_rec.ATTRIBUTE2,
                                                        X_ATTRIBUTE3                    => v_sua_rec.ATTRIBUTE3,
                                                        X_ATTRIBUTE4                    => v_sua_rec.ATTRIBUTE4,
                                                        X_ATTRIBUTE5                    => v_sua_rec.ATTRIBUTE5,
                                                        X_ATTRIBUTE6                    => v_sua_rec.ATTRIBUTE6,
                                                        X_ATTRIBUTE7                    => v_sua_rec.ATTRIBUTE7,
                                                        X_ATTRIBUTE8                    => v_sua_rec.ATTRIBUTE8,
                                                        X_ATTRIBUTE9                    => v_sua_rec.ATTRIBUTE9,
                                                        X_ATTRIBUTE10                   => v_sua_rec.ATTRIBUTE10,
                                                        X_ATTRIBUTE11                   => v_sua_rec.ATTRIBUTE11,
                                                        X_ATTRIBUTE12                   => v_sua_rec.ATTRIBUTE12,
                                                        X_ATTRIBUTE13                   => v_sua_rec.ATTRIBUTE13,
                                                        X_ATTRIBUTE14                   => v_sua_rec.ATTRIBUTE14,
                                                        X_ATTRIBUTE15                   => v_sua_rec.ATTRIBUTE15,
                                                        X_ATTRIBUTE16                   => v_sua_rec.ATTRIBUTE16,
                                                        X_ATTRIBUTE17                   => v_sua_rec.ATTRIBUTE17,
                                                        X_ATTRIBUTE18                   => v_sua_rec.ATTRIBUTE18,
                                                        X_ATTRIBUTE19                   => v_sua_rec.ATTRIBUTE19,
                                                        X_ATTRIBUTE20                   => v_sua_rec.ATTRIBUTE20,
                                                        X_WAITLIST_MANUAL_IND           => v_sua_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                                        X_WLST_PRIORITY_WEIGHT_NUM      => v_sua_rec.wlst_priority_weight_num,
                                                        X_WLST_PREFERENCE_WEIGHT_NUM    => v_sua_rec.wlst_preference_weight_num,
							-- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
         						X_CORE_INDICATOR_CODE       =>  v_sua_rec.core_indicator_code
                                                                          );
                                                  v_sua_upd_or_del := TRUE;




                                                END IF;
                                            END IF;
                                        END IF;
                                    END LOOP; -- c_sua


                                    IF v_sua_upd_or_del AND
                                            p_spo_person_id IS NULL THEN
                                        prgpl_ins_log_entry (
                                                v_log_creation_dt,
                                                cst_udiscontin,
                                                v_spo_rec.person_id,
                                                v_spo_rec.course_cd,
                                                v_spo_rec.prg_cal_type,
                                                v_spo_rec.prg_ci_sequence_number,
                                                v_spo_rec.sequence_number,
                                                v_spo_rec.progression_outcome_type,
                                                v_spo_rec.duration_type,
                                                v_spo_rec.duration,
                                                NULL,
                                                'IGS_PR_ENR_DISCON',
                                                NULL);
                                    END IF;
                                EXCEPTION
                                    WHEN e_record_locked THEN
                                        IF c_sua%ISOPEN THEN
                                            CLOSE c_sua;
                                        END IF;
                                        ROLLBACK TO sp_before_spo_apply;
                                        IF p_spo_person_id IS NOT NULL THEN
                                            FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_UA_TA');
                                            p_message_text := FND_MESSAGE.GET;
                                            p_message_level := cst_error;
                                            EXIT;
                                        ELSE
                                            v_process_next_spo := TRUE;
                                        END IF;
                                    WHEN OTHERS THEN
                                        RAISE;
                                END;
                            END IF;
                        END IF;
                    END IF;

                    IF NOT v_process_next_spo AND NOT v_exit_procedure THEN

                        -- Call routine to add the encumbrances to the students enrolment
                        IF NOT IGS_PR_GEN_006.IGS_PR_upd_spo_pen (
                                    v_spo_rec.person_id,
                                    v_spo_rec.course_cd,
                                    v_spo_rec.sequence_number,
                                    v_authorising_person_id,
                                    v_application_type,
                                    v_message_text,
                                    v_message_level) THEN
                            ROLLBACK TO sp_before_spo_apply;

                            IF p_spo_person_id IS NULL THEN
                                prgpl_ins_log_entry (
                                        v_log_creation_dt,
                                        cst_encumb_err,
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_rec.prg_cal_type,
                                        v_spo_rec.prg_ci_sequence_number,
                                        v_spo_rec.sequence_number,
                                        v_spo_rec.progression_outcome_type,
                                        v_spo_rec.duration_type,
                                        v_spo_rec.duration,
                                        NULL,
                                        'IGS_PR_ERR_LIFT_ENCMB',
                                        v_message_text);
                                v_process_next_spo := TRUE;

                            ELSE

                                p_message_text := v_message_text;
                                p_message_level := v_message_level;
                                EXIT;
                            END IF;
                        ELSE

                            IF v_message_level IS NOT NULL THEN
                                IF p_spo_person_id IS NULL THEN
                                    prgpl_ins_log_entry (
                                        v_log_creation_dt,
                                        cst_encumb_warn,
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_rec.prg_cal_type,
                                        v_spo_rec.prg_ci_sequence_number,
                                        v_spo_rec.sequence_number,
                                        v_spo_rec.progression_outcome_type,
                                        v_spo_rec.duration_type,
                                        v_spo_rec.duration,
                                        NULL,
                                        'IGS_PR_WARN_LIFT_ENCMB',
                                        v_message_text);
                                ELSE
                                    p_message_text := v_message_text;
                                    p_message_level := v_message_level;
                                END IF;
                            END IF;

                            IF p_spo_person_id IS NULL THEN
                                prgpl_ins_log_entry (
                                        v_log_creation_dt,
                                        cst_encumb,
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_rec.prg_cal_type,
                                        v_spo_rec.prg_ci_sequence_number,
                                        v_spo_rec.sequence_number,
                                        v_spo_rec.progression_outcome_type,
                                        v_spo_rec.duration_type,
                                        v_spo_rec.duration,
                                        NULL,
                                        'IGS_PR_ACAD_ENCMB_ADDED',
                                        NULL);
                            END IF;

                            IF NOT prgpl_upd_spo (
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_rec.sequence_number,
                                        v_show_cause_ind,
                                        v_apply_before_show_ind,
                                        v_appeal_ind,
                                        v_apply_before_appeal_ind) THEN

                                -- Record locked
                                ROLLBACK TO sp_before_spo_apply;
                                IF p_spo_person_id IS NULL THEN
                                    v_process_next_spo := TRUE;
                                ELSE
                                    FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_DTLS_TA');
                                    p_message_text := FND_MESSAGE.GET;
                                    p_message_level := cst_error;
                                    EXIT;
                                END IF;
                            END IF;

                        END IF;

                    END IF;

                    IF NOT v_process_next_spo AND
                            NOT v_exit_procedure THEN
                        -- Process rules resulting from the outcome. This logic takes
                        -- IGS_PR_RU_APPL details (at the SPO level) and creates
                        -- SCA applications of these rules.
                        FOR v_pra_rec IN c_pra (
                                    v_spo_rec.person_id,
                                    v_spo_rec.course_cd,
                                    v_spo_rec.sequence_number) LOOP
                            -- Transfer detail to the sca level
                            v_new_pra_sequence_number :=
                                    IGS_PR_GEN_006.IGS_PR_ins_copy_pra (
                                            v_pra_rec.progression_rule_cat,
                                            v_pra_rec.sequence_number,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd,
                                            v_spo_rec.sequence_number,
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd,
                                            v_message_name);
                            -- Update the start period of records just added

                            FOR v_pra_prct_rec IN c_pra_prct (
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd,
                                            v_spo_rec.sequence_number) LOOP

                                OPEN c_ci (
                                    v_pra_prct_rec.prg_cal_type,
                                    v_spo_rec.prg_cal_type,
                                    v_spo_rec.prg_ci_sequence_number);
                                FETCH c_ci INTO v_ci_sequence_number;
                                IF c_ci%NOTFOUND THEN
                                    CLOSE c_ci;
                                    ROLLBACK TO sp_before_spo_apply;
                                    IF p_spo_person_id IS NULL THEN
                                        prgpl_ins_log_entry (
                                            v_log_creation_dt,
                                            cst_no_cal,
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd,
                                            v_spo_rec.prg_cal_type,
                                            v_spo_rec.prg_ci_sequence_number,
                                            v_spo_rec.sequence_number,
                                            v_spo_rec.progression_outcome_type,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL);/* added because of commenting the following*/
                                        v_process_next_spo := TRUE;
                                        EXIT;
                                    ELSE
                                        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_FUT_CAL_INST_NOT_EXST');
                                        p_message_text := FND_MESSAGE.GET;
                                        p_message_level := cst_error;
                                        v_exit_procedure := TRUE;
                                        EXIT;
                                    END IF;
                                ELSE
                                    -- Set the start period to the next calendar instance
                                    -- to ensure it is not tested before it should be
/*
                                    UPDATE IGS_PR_RU_CA_TYPE
                                    SET start_sequence_number = v_ci_sequence_number
                                    WHERE CURRENT OF c_pra_prct;
                                    CLOSE c_ci;

*/

                                    Close c_ci;
                                    IGS_PR_RU_CA_TYPE_PKG.UPDATE_ROW(
                                      X_ROWID                         => v_pra_prct_rec.ROWID,
                                      X_PROGRESSION_RULE_CAT          => v_pra_prct_rec.PROGRESSION_RULE_CAT,
                                      X_PRA_SEQUENCE_NUMBER           => v_pra_prct_rec.PRA_SEQUENCE_NUMBER,
                                      X_PRG_CAL_TYPE                  => v_pra_prct_rec.PRG_CAL_TYPE,
                                      X_START_SEQUENCE_NUMBER         => v_ci_sequence_number,
                                      X_END_SEQUENCE_NUMBER           => v_pra_prct_rec.END_SEQUENCE_NUMBER,
                                      X_START_EFFECTIVE_PERIOD        => v_pra_prct_rec.START_EFFECTIVE_PERIOD,
                                      X_NUM_OF_APPLICATIONS           => v_pra_prct_rec.NUM_OF_APPLICATIONS,
                                      X_MODE                          => 'R'
                                    );

                                END IF;
                            END LOOP; -- c_pra_prct
                            IF v_process_next_spo OR
                                    v_exit_procedure THEN
                                EXIT;
                            END IF;
                        END LOOP; -- c_pra
                    END IF;
                    IF NOT v_process_next_spo AND
                            NOT v_exit_procedure THEN
                        BEGIN

                            FOR v_pra_upd_rec IN c_pra_upd2 (
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd,
                                            v_spo_rec.sequence_number) LOOP
/*
                                UPDATE IGS_PR_RU_APPL
                                SET logical_delete_dt = SYSDATE
                                WHERE CURRENT OF c_pra_upd2;
*/


                                IGS_PR_RU_APPL_pkg.UPDATE_ROW(
                                  X_ROWID                         => v_pra_upd_rec.ROWID,
                                  X_PROGRESSION_RULE_CAT          => v_pra_upd_rec.PROGRESSION_RULE_CAT,
                                  X_SEQUENCE_NUMBER               => v_pra_upd_rec.SEQUENCE_NUMBER,
                                  X_S_RELATION_TYPE               => v_pra_upd_rec.S_RELATION_TYPE,
                                  X_PROGRESSION_RULE_CD           => v_pra_upd_rec.PROGRESSION_RULE_CD,
                                  X_REFERENCE_CD                  => v_pra_upd_rec.REFERENCE_CD,
                                  X_RUL_SEQUENCE_NUMBER           => v_pra_upd_rec.RUL_SEQUENCE_NUMBER,
                                  X_ATTENDANCE_TYPE               => v_pra_upd_rec.ATTENDANCE_TYPE,
                                  X_OU_ORG_UNIT_CD                => v_pra_upd_rec.OU_ORG_UNIT_CD,
                                  X_OU_START_DT                   => v_pra_upd_rec.OU_START_DT,
                                  X_COURSE_TYPE                   => v_pra_upd_rec.COURSE_TYPE,
                                  X_CRV_COURSE_CD                 => v_pra_upd_rec.CRV_COURSE_CD,
                                  X_CRV_VERSION_NUMBER            => v_pra_upd_rec.CRV_VERSION_NUMBER,
                                  X_SCA_PERSON_ID                 => v_pra_upd_rec.SCA_PERSON_ID,
                                  X_SCA_COURSE_CD                 => v_pra_upd_rec.SCA_COURSE_CD,
                                  X_PRO_PROGRESSION_RULE_CAT      => v_pra_upd_rec.PRO_PROGRESSION_RULE_CAT,
                                  X_PRO_PRA_SEQUENCE_NUMBER       => v_pra_upd_rec.PRO_PRA_SEQUENCE_NUMBER,
                                  X_PRO_SEQUENCE_NUMBER           => v_pra_upd_rec.PRO_SEQUENCE_NUMBER,
                                  X_SPO_PERSON_ID                 => v_pra_upd_rec.SPO_PERSON_ID,
                                  X_SPO_COURSE_CD                 => v_pra_upd_rec.SPO_COURSE_CD,
                                  X_SPO_SEQUENCE_NUMBER           => v_pra_upd_rec.SPO_SEQUENCE_NUMBER,
                                  X_LOGICAL_DELETE_DT             => SYSDATE,
                                  X_MESSAGE                       => v_pra_upd_rec.MESSAGE,
                                  X_MODE                          => 'R',
                                  X_MIN_CP                        => v_pra_upd_rec.MIN_CP,
                                  X_MAX_CP                        => v_pra_upd_rec.MAX_CP,
                                  X_IGS_PR_CLASS_STD_ID           => v_pra_upd_rec.IGS_PR_CLASS_STD_ID
                                );

                            END LOOP; -- c_pra_upd2
                        EXCEPTION
                            WHEN e_record_locked THEN
                                IF c_pra_upd2%ISOPEN THEN
                                    CLOSE c_pra_upd2;
                                END IF;
                                ROLLBACK TO sp_before_spo_apply;
                                IF p_spo_person_id IS NULL THEN
                                    v_process_next_spo := TRUE;
                                ELSE
                                    FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_DTLS_TA');
                                    p_message_text := FND_MESSAGE.GET;
                                    p_message_level := cst_error;
                                    EXIT;
                                END IF;
                            WHEN OTHERS THEN
                                RAISE;
                        END;
                    END IF;
                END IF;
            END IF;
        ELSE    -- decision status of 'REMOVED' or 'CANCELLED'
            -- Check that decision status is appropriate.
            IF p_spo_person_id IS NOT NULL AND
                    v_spo_rec.decision_status NOT IN (
                                    cst_removed,
                                    cst_cancelled) THEN
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_OTCM_ST_NO_EFFECT');
                p_message_text := FND_MESSAGE.GET;
                p_message_level := cst_warn;
                EXIT;
            END IF;
            -- Logic to un-apply a previously applied outcome following the decision
            -- being reversed to cancelled or removed.
            -- Call routine to lift the encumbrances resulting from the outcome. This
            -- must be done prior to any discontinuation being lifted, else enrolment
            -- validations will prevent the re-instatement.
            IF NOT IGS_PR_GEN_006.IGS_PR_upd_spo_pen (
                        v_spo_rec.person_id,
                        v_spo_rec.course_cd,
                        v_spo_rec.sequence_number,
                        v_authorising_person_id,
                        v_application_type,
                        v_message_text,
                        v_message_level) THEN
                ROLLBACK TO sp_before_spo_apply;
                IF p_spo_person_id IS NULL THEN
                    prgpl_ins_log_entry (
                            v_log_creation_dt,
                            cst_encumb_err,
                            v_spo_rec.person_id,
                            v_spo_rec.course_cd,
                            v_spo_rec.prg_cal_type,
                            v_spo_rec.prg_ci_sequence_number,
                            v_spo_rec.sequence_number,
                            v_spo_rec.progression_outcome_type,
                            v_spo_rec.duration_type,
                            v_spo_rec.duration,
                            NULL,
                            'IGS_PR_ERR_LIFT_ENCMB',
                            v_message_text);
                    v_process_next_spo := TRUE;
                ELSE
                    p_message_text := v_message_text;
                    p_message_level := v_message_level;
                    EXIT;
                END IF;
            ELSE
                IF p_spo_person_id IS NULL THEN
                    prgpl_ins_log_entry (
                            v_log_creation_dt,
                            cst_encumblift,
                            v_spo_rec.person_id,
                            v_spo_rec.course_cd,
                            v_spo_rec.prg_cal_type,
                            v_spo_rec.prg_ci_sequence_number,
                            v_spo_rec.sequence_number,
                            v_spo_rec.progression_outcome_type,
                            v_spo_rec.duration_type,
                            v_spo_rec.duration,
                            NULL,
                            'IGS_PR_ACAD_ENCMB_LIFTED',
                            NULL);
                END IF;
                IF NOT prgpl_upd_spo (
                            v_spo_rec.person_id,
                            v_spo_rec.course_cd,
                            v_spo_rec.sequence_number,
                            v_show_cause_ind,
                            v_apply_before_show_ind,
                            v_appeal_ind,
                            v_apply_before_appeal_ind) THEN
                    -- Record locked
                    ROLLBACK TO sp_before_spo_apply;
                    IF p_spo_person_id IS NULL THEN
                        v_process_next_spo := TRUE;
                    ELSE
                        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_DTLS_TA');
                        p_message_text := FND_MESSAGE.GET;
                        p_message_level := cst_error;
                        EXIT;
                    END IF;
                END IF;
            END IF;
            IF NOT v_process_next_spo THEN
                IF v_spo_rec.course_attempt_status = cst_discontin THEN
                    OPEN c_dr (v_spo_rec.discontinuation_reason_cd);
                    FETCH c_dr INTO v_s_discont_reason_type;
                    CLOSE c_dr;
                    IF v_s_discont_reason_type = cst_progress THEN
                        -- Providing no other progression outcomes exist that would enforce
                        -- the discontinuation to remain, lift it. Note: no units or unit sets
                        -- were re-instated during the making of this transaction.
                        v_other_encumbrance := FALSE;
                        FOR v_spo_pot_rec IN c_spo_pot (
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_rec.sequence_number,
                                        v_spo_rec.encmb_course_group_cd,
                                        v_spo_rec.version_number) LOOP
                            IF IGS_PR_GEN_006.IGS_PR_get_spo_expiry (
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_pot_rec.sequence_number,
                                        v_spo_pot_rec.expiry_dt,
                                        v_expiry_dt) IN (
                                                cst_current,
                                                cst_open) THEN
                                v_other_encumbrance := TRUE;
                                EXIT;
                            END IF;
                        END LOOP; -- c_spo_pot
                        IF v_other_encumbrance THEN
                            IF p_spo_person_id IS NULL THEN
                                prgpl_ins_log_entry (
                                        v_log_creation_dt,
                                        cst_disc_other,
                                        v_spo_rec.person_id,
                                        v_spo_rec.course_cd,
                                        v_spo_rec.prg_cal_type,
                                        v_spo_rec.prg_ci_sequence_number,
                                        v_spo_rec.sequence_number,
                                        v_spo_rec.progression_outcome_type,
                                        NULL,
                                        NULL,
                                        NULL,
                                        'IGS_PR_SCA_DISCON_NOT_LIFTED',
                                        NULL);
                            ELSE
                                p_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_PR_SCA_DISCON_NOT_LIFTED');
                                p_message_level := cst_error;
                            END IF;
                        ELSE
                            -- Lift the course discontinuation
                            BEGIN
                                FOR v_sca_rec IN c_sca1 (
                                            v_spo_rec.person_id,
                                            v_spo_rec.course_cd) LOOP
/*
                                    UPDATE  IGS_EN_STDNT_PS_ATT
                                    SET discontinued_dt = NULL,
                                        discontinuation_reason_cd = NULL
                                    WHERE CURRENT OF c_sca1;
*/
                                    IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                                      X_ROWID                         => v_sca_rec.ROWID,
                                      X_PERSON_ID                     => v_sca_rec.PERSON_ID,
                                      X_COURSE_CD                     => v_sca_rec.COURSE_CD,
                                      X_ADVANCED_STANDING_IND         => v_sca_rec.ADVANCED_STANDING_IND,
                                      X_FEE_CAT                       => v_sca_rec.FEE_CAT,
                                      X_CORRESPONDENCE_CAT            => v_sca_rec.CORRESPONDENCE_CAT,
                                      X_SELF_HELP_GROUP_IND           => v_sca_rec.SELF_HELP_GROUP_IND,
                                      X_LOGICAL_DELETE_DT             => v_sca_rec.LOGICAL_DELETE_DT,
                                      X_ADM_ADMISSION_APPL_NUMBER     => v_sca_rec.ADM_ADMISSION_APPL_NUMBER,
                                      X_ADM_NOMINATED_COURSE_CD       => v_sca_rec.ADM_NOMINATED_COURSE_CD,
                                      X_ADM_SEQUENCE_NUMBER           => v_sca_rec.ADM_SEQUENCE_NUMBER,
                                      X_VERSION_NUMBER                => v_sca_rec.VERSION_NUMBER,
                                      X_CAL_TYPE                      => v_sca_rec.CAL_TYPE,
                                      X_LOCATION_CD                   => v_sca_rec.LOCATION_CD,
                                      X_ATTENDANCE_MODE               => v_sca_rec.ATTENDANCE_MODE,
                                      X_ATTENDANCE_TYPE               => v_sca_rec.ATTENDANCE_TYPE,
                                      X_COO_ID                        => v_sca_rec.COO_ID,
                                      X_STUDENT_CONFIRMED_IND         => v_sca_rec.STUDENT_CONFIRMED_IND,
                                      X_COMMENCEMENT_DT               => v_sca_rec.COMMENCEMENT_DT,
                                      X_COURSE_ATTEMPT_STATUS         => v_sca_rec.COURSE_ATTEMPT_STATUS,
                                      X_PROGRESSION_STATUS            => v_sca_rec.PROGRESSION_STATUS,
                                      X_DERIVED_ATT_TYPE              => v_sca_rec.DERIVED_ATT_TYPE,
                                      X_DERIVED_ATT_MODE              => v_sca_rec.DERIVED_ATT_MODE,
                                      X_PROVISIONAL_IND               => v_sca_rec.PROVISIONAL_IND,
                                      X_DISCONTINUED_DT               => NULL,
                                      X_DISCONTINUATION_REASON_CD     => NULL,
                                      X_LAPSED_DT                     => v_sca_rec.LAPSED_DT,
                                      X_FUNDING_SOURCE                => v_sca_rec.FUNDING_SOURCE,
                                      X_EXAM_LOCATION_CD              => v_sca_rec.EXAM_LOCATION_CD,
                                      X_DERIVED_COMPLETION_YR         => v_sca_rec.DERIVED_COMPLETION_YR,
                                      X_DERIVED_COMPLETION_PERD       => v_sca_rec.DERIVED_COMPLETION_PERD,
                                      X_NOMINATED_COMPLETION_YR       => v_sca_rec.NOMINATED_COMPLETION_YR,
                                      X_NOMINATED_COMPLETION_PERD     => v_sca_rec.NOMINATED_COMPLETION_PERD,
                                      X_RULE_CHECK_IND                => v_sca_rec.RULE_CHECK_IND,
                                      X_WAIVE_OPTION_CHECK_IND        => v_sca_rec.WAIVE_OPTION_CHECK_IND,
                                      X_LAST_RULE_CHECK_DT            => v_sca_rec.LAST_RULE_CHECK_DT,
                                      X_PUBLISH_OUTCOMES_IND          => v_sca_rec.PUBLISH_OUTCOMES_IND,
                                      X_COURSE_RQRMNT_COMPLETE_IND    => v_sca_rec.COURSE_RQRMNT_COMPLETE_IND,
                                      X_COURSE_RQRMNTS_COMPLETE_DT    => v_sca_rec.COURSE_RQRMNTS_COMPLETE_DT,
                                      X_S_COMPLETED_SOURCE_TYPE       => v_sca_rec.S_COMPLETED_SOURCE_TYPE,
                                      X_OVERRIDE_TIME_LIMITATION      => v_sca_rec.OVERRIDE_TIME_LIMITATION,
                                      X_MODE                          => 'R',
                                      X_LAST_DATE_OF_ATTENDANCE       => v_sca_rec.LAST_DATE_OF_ATTENDANCE,
                                      X_DROPPED_BY                    => v_sca_rec.DROPPED_BY,
                                      X_IGS_PR_CLASS_STD_ID           => v_sca_rec.IGS_PR_CLASS_STD_ID,
                                      X_PRIMARY_PROGRAM_TYPE          => v_sca_rec.PRIMARY_PROGRAM_TYPE,
                                      X_PRIMARY_PROG_TYPE_SOURCE      => v_sca_rec.PRIMARY_PROG_TYPE_SOURCE,
                                      X_CATALOG_CAL_TYPE              => v_sca_rec.CATALOG_CAL_TYPE,
                                      X_CATALOG_SEQ_NUM               => v_sca_rec.CATALOG_SEQ_NUM,
                                      X_KEY_PROGRAM                   => v_sca_rec.KEY_PROGRAM,
                                      X_MANUAL_OVR_CMPL_DT_IND        => v_sca_rec.manual_ovr_cmpl_dt_ind,
                                      X_OVERRIDE_CMPL_DT              =>  v_sca_rec.OVERRIDE_CMPL_DT,
                                      X_ATTRIBUTE_CATEGORY      =>  v_sca_rec.ATTRIBUTE_CATEGORY,
                                      X_ATTRIBUTE1    =>  v_sca_rec.ATTRIBUTE1,
                                      X_ATTRIBUTE2    =>  v_sca_rec.ATTRIBUTE2,
                                      X_ATTRIBUTE3    =>  v_sca_rec.ATTRIBUTE3,
                                      X_ATTRIBUTE4    =>  v_sca_rec.ATTRIBUTE4,
                                      X_ATTRIBUTE5    =>  v_sca_rec.ATTRIBUTE5,
                                      X_ATTRIBUTE6    =>  v_sca_rec.ATTRIBUTE6,
                                      X_ATTRIBUTE7    =>  v_sca_rec.ATTRIBUTE7,
                                      X_ATTRIBUTE8   =>  v_sca_rec.ATTRIBUTE8,
                                      X_ATTRIBUTE9    =>  v_sca_rec.ATTRIBUTE9,
                                      X_ATTRIBUTE10   =>  v_sca_rec.ATTRIBUTE10,
                                      X_ATTRIBUTE11   =>  v_sca_rec.ATTRIBUTE11,
                                      X_ATTRIBUTE12   =>  v_sca_rec.ATTRIBUTE12,
                                      X_ATTRIBUTE13   =>  v_sca_rec.ATTRIBUTE13,
                                      X_ATTRIBUTE14   =>  v_sca_rec.ATTRIBUTE14,
                                      X_ATTRIBUTE15   =>  v_sca_rec.ATTRIBUTE15,
                                      X_ATTRIBUTE16   =>  v_sca_rec.ATTRIBUTE16,
                                      X_ATTRIBUTE17   =>  v_sca_rec.ATTRIBUTE17,
                                      X_ATTRIBUTE18   =>  v_sca_rec.ATTRIBUTE18,
                                      X_ATTRIBUTE19   =>  v_sca_rec.ATTRIBUTE19,
                                      x_ATTRIBUTE20   =>  v_sca_rec.ATTRIBUTE20,
				      X_FUTURE_DATED_TRANS_FLAG     => v_sca_rec.future_dated_trans_flag
                                      );


                                END LOOP;
                            EXCEPTION
                                WHEN e_record_locked THEN
                                    IF c_sca1%ISOPEN THEN
                                        CLOSE c_sca1;
                                    END IF;
                                    ROLLBACK TO sp_before_spo_apply;
                                    IF p_spo_person_id IS NULL THEN
                                        v_process_next_spo := TRUE;
                                    ELSE
                                        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_SCA_TA');
                                        p_message_text := FND_MESSAGE.GET;
                                        p_message_level := cst_error;
                                        EXIT;
                                    END IF;
                                WHEN e_application THEN
                                    IF c_sca1%ISOPEN THEN
                                        CLOSE c_sca1;
                                    END IF;
                                    IF p_spo_person_id IS NULL THEN
                                        prgpl_ins_log_entry (
                                                v_log_creation_dt,
                                                cst_discl_err,
                                                v_spo_rec.person_id,
                                                v_spo_rec.course_cd,
                                                v_spo_rec.prg_cal_type,
                                                v_spo_rec.prg_ci_sequence_number,
                                                v_spo_rec.sequence_number,
                                                v_spo_rec.progression_outcome_type,
                                                NULL,
                                                NULL,
                                                NULL,
                                                'IGS_PR_ERR_SCA_DISCON_LIFT',
                                                SUBSTR(SQLERRM, 12, LENGTH(SQLERRM)));
                                    ELSE
                                        p_message_text := FND_MESSAGE.GET_STRING('IGS','IGS_PR_ERR_SCA_DISCON_LIFT');
                                        p_message_level := cst_error;
                                        EXIT;
                                    END IF;
                                WHEN OTHERS THEN
                                    RAISE;
                            END;
                        END IF;
                    END IF;
                END IF;
            END IF;

            IF NOT v_process_next_spo THEN
                -- Remove any SCA rules that resulted from the outcome
                BEGIN
                    FOR v_pra_upd_rec IN c_pra_upd1 (
                                    v_spo_rec.person_id,
                                    v_spo_rec.course_cd,
                                    v_spo_rec.sequence_number) LOOP
/*
                        UPDATE IGS_PR_RU_APPL
                        SET logical_delete_dt = SYSDATE
                        WHERE CURRENT OF c_pra_upd1;
*/
                        IGS_PR_RU_APPL_PKG.UPDATE_ROW(
                         X_ROWID                         => v_pra_upd_rec.ROWID,
                         X_PROGRESSION_RULE_CAT          => v_pra_upd_rec.PROGRESSION_RULE_CAT,
                         X_SEQUENCE_NUMBER               => v_pra_upd_rec.SEQUENCE_NUMBER,
                         X_S_RELATION_TYPE               => v_pra_upd_rec.S_RELATION_TYPE,
                         X_PROGRESSION_RULE_CD           => v_pra_upd_rec.PROGRESSION_RULE_CD,
                         X_REFERENCE_CD                  => v_pra_upd_rec.REFERENCE_CD,
                         X_RUL_SEQUENCE_NUMBER           => v_pra_upd_rec.RUL_SEQUENCE_NUMBER,
                         X_ATTENDANCE_TYPE               => v_pra_upd_rec.ATTENDANCE_TYPE,
                         X_OU_ORG_UNIT_CD                => v_pra_upd_rec.OU_ORG_UNIT_CD,
                         X_OU_START_DT                   => v_pra_upd_rec.OU_START_DT,
                         X_COURSE_TYPE                   => v_pra_upd_rec.COURSE_TYPE,
                         X_CRV_COURSE_CD                 => v_pra_upd_rec.CRV_COURSE_CD,
                         X_CRV_VERSION_NUMBER            => v_pra_upd_rec.CRV_VERSION_NUMBER,
                         X_SCA_PERSON_ID                 => v_pra_upd_rec.SCA_PERSON_ID,
                         X_SCA_COURSE_CD                 => v_pra_upd_rec.SCA_COURSE_CD,
                         X_PRO_PROGRESSION_RULE_CAT      => v_pra_upd_rec.PRO_PROGRESSION_RULE_CAT,
                         X_PRO_PRA_SEQUENCE_NUMBER       => v_pra_upd_rec.PRO_PRA_SEQUENCE_NUMBER,
                         X_PRO_SEQUENCE_NUMBER           => v_pra_upd_rec.PRO_SEQUENCE_NUMBER,
                         X_SPO_PERSON_ID                 => v_pra_upd_rec.SPO_PERSON_ID,
                         X_SPO_COURSE_CD                 => v_pra_upd_rec.SPO_COURSE_CD,
                         X_SPO_SEQUENCE_NUMBER           => v_pra_upd_rec.SPO_SEQUENCE_NUMBER,
                         X_LOGICAL_DELETE_DT             => SYSDATE,
                         X_MESSAGE                       => v_pra_upd_rec.MESSAGE,
                         X_MODE                          => 'R',
                         X_MIN_CP                        => v_pra_upd_rec.MIN_CP,
                         X_MAX_CP                        => v_pra_upd_rec.MAX_CP,
                         X_IGS_PR_CLASS_STD_ID           => v_pra_upd_rec.IGS_PR_CLASS_STD_ID
                        );
                    END LOOP; -- c_pra_upd1
                EXCEPTION
                    WHEN e_record_locked THEN
                        IF c_pra_upd1%ISOPEN THEN
                            CLOSE c_pra_upd1;
                        END IF;
                        ROLLBACK TO sp_before_spo_apply;
                        IF p_spo_person_id IS NOT NULL THEN
                            FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNLO_DTLS_TA');
                            p_message_text := FND_MESSAGE.GET;
                            p_message_level := cst_error;
                            EXIT;
                        END IF;
                    WHEN OTHERS THEN
                        RAISE;
                END;
            END IF;
        END IF;
        IF v_exit_procedure THEN
            EXIT;
        END IF;
      --Added next exception part to fix Bug# 3103892
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO sp_before_spo_apply;
      END;
      --End of new code added to fix Bug# 3103892
    END LOOP; -- c_spo
    COMMIT;
         RETURN;
 EXCEPTION
    WHEN OTHERS THEN
        IF c_dr%ISOPEN THEN
            CLOSE c_dr;
        END IF;
        IF c_sca1%ISOPEN THEN
            CLOSE c_sca1;
        END IF;
        IF c_sca2%ISOPEN THEN
            CLOSE c_sca2;
        END IF;
        IF c_pra%ISOPEN THEN
            CLOSE c_pra;
        END IF;
        IF c_ci%ISOPEN THEN
            CLOSE c_ci;
        END IF;
        IF c_pra_prct%ISOPEN THEN
            CLOSE c_pra_prct;
        END IF;
        IF c_pra_upd1%ISOPEN THEN
            CLOSE c_pra_upd1;
        END IF;
        IF c_pra_upd2%ISOPEN THEN
            CLOSE c_pra_upd2;
        END IF;
        IF c_spo_pot%ISOPEN THEN
            CLOSE c_spo_pot;
        END IF;
        IF c_suao%ISOPEN THEN
            CLOSE c_suao;
        END IF;
        IF c_sua%ISOPEN THEN
            CLOSE c_sua;
        END IF;
        IF c_spo%ISOPEN THEN
            CLOSE c_spo;
        END IF;
        RAISE;
 END;
 EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_OUT_APPLY');
        IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IGS_PR_upd_out_apply;

 PROCEDURE igs_pr_upd_rule_apply (
   p_prg_cal_type        IN VARCHAR2,
   p_prg_sequence_number IN NUMBER,
   p_course_type         IN VARCHAR2,
   p_org_unit_cd         IN VARCHAR2,
   p_ou_start_dt         IN DATE,
   p_course_cd           IN VARCHAR2,
   p_location_cd         IN VARCHAR2,
   p_attendance_mode     IN VARCHAR2,
   p_progression_status  IN VARCHAR2,
   p_enrolment_cat       IN VARCHAR2,
   p_group_id            IN NUMBER,
   p_processing_type     IN VARCHAR2,
   p_log_creation_dt     OUT NOCOPY DATE
   )
 IS
    gv_other_detail         VARCHAR2(255);
 BEGIN  -- 8/9/01IGS_PR_upd_rule_apply
    -- Automatic application of rules ; for detail see associated design
    -- documentation.
    -- This routine handles the batch selection of students to be processed,
    -- and the initiation of exception reporting mechanisms. A second routine
    -- IGS_PR_UPD_SCA_APPLY is called to actually process the rules for a select
    -- course attempt within a progression period.
 DECLARE
    cst_prg_appl    CONSTANT    VARCHAR2(10) := 'PRG-APPL';
    cst_enrolled    CONSTANT    VARCHAR2(10) := 'ENROLLED';
    cst_inactive    CONSTANT    VARCHAR2(10) := 'INACTIVE';
    cst_intermit    CONSTANT    VARCHAR2(10) := 'INTERMIT';
    cst_discontin   CONSTANT    VARCHAR2(10) := 'DISCONTIN';
    cst_lapsed  CONSTANT    VARCHAR2(10) := 'LAPSED';
    cst_unconfirm   CONSTANT    VARCHAR2(10) := 'UNCONFIRM';
    cst_invalid CONSTANT    VARCHAR2(10) := 'INVALID';
    cst_initial CONSTANT    VARCHAR2(10) := 'INITIAL';
    cst_todo    CONSTANT    VARCHAR2(10) := 'TODO';
    cst_both    CONSTANT    VARCHAR2(10) := 'BOTH';
    cst_active  CONSTANT    VARCHAR2(10) := 'ACTIVE';
    cst_progress    CONSTANT    VARCHAR2(10) := 'PROGRESS';
    v_recommended_outcomes      INTEGER DEFAULT 0;
    v_approved_outcomes     INTEGER DEFAULT 0;
    v_removed_outcomes      INTEGER DEFAULT 0;
    v_last_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE := NULL;
    v_last_version_number       IGS_EN_STDNT_PS_ATT.version_number%TYPE := NULL;
    v_log_creation_dt       IGS_GE_s_log.creation_dt%TYPE;
    v_key               IGS_GE_s_log.KEY%TYPE;
    v_message_name          VARCHAR2(30);
    CURSOR c_ci IS
        SELECT  ci.cal_type,
            ci.sequence_number,
            ci.alternate_code,
            IGS_EN_GEN_014.ENRS_GET_ACAD_ALT_CD(
                                    ci.cal_type,
                        ci.sequence_number) acad_alternate_code
        FROM    IGS_CA_INST ci,
            IGS_CA_TYPE cat,
            IGS_CA_STAT cs
        WHERE   (p_prg_cal_type     IS NULL OR
            (ci.cal_type        = p_prg_cal_type AND
            ci.sequence_number  = p_prg_sequence_number)) AND
            cat.cal_type    = ci.cal_type AND
            cat.s_cal_cat   = cst_progress AND
            cs.CAL_STATUS   = ci.CAL_STATUS AND
            cs.s_CAL_STATUS = cst_active AND
            EXISTS (
                                 SELECT  'X'
                                 FROM IGS_CA_DA_INST     dai1
                                 WHERE   ci.cal_type             = dai1.cal_type AND
                                         ci.sequence_number      = dai1.ci_sequence_number  AND
                                    (
                                   EXISTS ( SELECT 1 FROM   IGS_PR_S_PRG_CONF  spc1
                                         WHERE  dai1.dt_alias   = spc1.apply_start_dt_alias)
                                       OR
                                       EXISTS (SELECT 1 FROM   IGS_PR_S_OU_PRG_CONF sopc1
                                        WHERE  dai1.dt_alias             = sopc1.apply_start_dt_alias)
                                       OR
                                       EXISTS (SELECT 1 FROM   IGS_PR_S_CRV_PRG_CON           scpc1
                                        WHERE dai1.dt_alias             = scpc1.apply_start_dt_alias)) AND
                                       IGS_CA_GEN_001.CALP_GET_ALIAS_VAL (
                                                 dai1.dt_alias,
                                                 dai1.sequence_number,
                                                 ci.cal_type,
                                                  ci.sequence_number
                         ) <= TRUNC(SYSDATE))        AND
                               EXISTS (
                                            SELECT  'X'
                                            FROM IGS_CA_DA_INST     dai2
                                            WHERE   ci.cal_type             = dai2.cal_type AND
                                                   ci.sequence_number      = dai2.ci_sequence_number  AND
                                        (
                                   EXISTS ( SELECT 1 FROM   IGS_PR_S_PRG_CONF              spc2
                                         WHERE  dai2.dt_alias               = spc2.apply_end_dt_alias)
                                        OR
                                       EXISTS (SELECT 1 FROM   IGS_PR_S_OU_PRG_CONF sopc2
                               WHERE dai2.dt_alias             = sopc2.apply_end_dt_alias)
                                        OR
                                        EXISTS (SELECT 1 FROM   IGS_PR_S_CRV_PRG_CON           scpc2
                                     WHERE dai2.dt_alias             = scpc2.apply_end_dt_alias) )
                                    AND
                                        NVL( IGS_CA_GEN_001.CALP_GET_ALIAS_VAL (
                                                 dai2.dt_alias,
                                                 dai2.sequence_number,
                                                 ci.cal_type,
                                                  ci.sequence_number
                         ), SYSDATE) >= TRUNC(SYSDATE)
           ) ;
   --
   --
   --
   FUNCTION prgpl_upd_check_readiness (
        p_sca_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        p_sca_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
        p_sca_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE,
        p_ci_cal_type           IGS_CA_INST.cal_type%TYPE,
        p_ci_sequence_number        IGS_CA_INST.sequence_number%TYPE,
        p_outcome_check_type        IGS_PR_S_PRG_CONF.outcome_check_type%TYPE)
    RETURN VARCHAR2
    IS
    BEGIN   -- prgpl_upd_check_readiness
    DECLARE
        cst_none    CONSTANT    VARCHAR2(10) := 'NONE';
        cst_missing CONSTANT    VARCHAR2(10) := 'MISSING';
        cst_recommend   CONSTANT    VARCHAR2(10) := 'RECOMMEND';
        cst_finalised   CONSTANT    VARCHAR2(10) := 'FINALISED';
        v_start_dt          DATE;
        v_cutoff_dt         DATE;
        v_result_status         VARCHAR2(10);
    BEGIN

        -- If course version is not within its first processing cycle then skip
        IF IGS_PR_GEN_006.IGS_PR_get_within_appl (
                    p_ci_cal_type,
                    p_ci_sequence_number,
                    p_sca_course_cd,
                    p_sca_version_number,
                    cst_initial,
                    v_start_dt,
                    v_cutoff_dt) = 'N' THEN

            RETURN 'N';
        END IF;
        -- Check whether student is effectively enrolled in the period
        v_result_status := IGS_PR_GEN_005.IGS_PR_get_sca_state (
                            p_sca_person_id,
                            p_sca_course_cd,
                            p_ci_cal_type,
                            p_ci_sequence_number);
        IF v_result_status = cst_none THEN

            RETURN 'N';
        ELSIF v_result_status = cst_missing THEN
            -- If the outcome check type is not missing then exclude from checking
            IF p_outcome_check_type <> cst_missing THEN

                RETURN 'N';
            END IF;
        ELSIF v_result_status = cst_recommend THEN
            -- If the outcome status is finalised (ie. ignoring recommended) then
            -- exclude
            IF p_outcome_check_type = cst_finalised THEN

                RETURN 'N';
            END IF;
        END IF;
        RETURN 'Y';
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_RULE_APPLY.PRGPL_UPD_CHECK_READINESS');
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END PRGPL_UPD_CHECK_READINESS;
    --
    --
    --
    PROCEDURE prgpl_upd_initial_appl (
      p_ci_cal_type                         igs_ca_inst.cal_type%TYPE,
      p_ci_sequence_number                  igs_ca_inst.sequence_number%TYPE
    ) IS
    BEGIN                                                                                          -- prgpl_upd_initial_appl
      DECLARE
        v_apply_start_dt_alias    igs_pr_s_prg_conf.apply_start_dt_alias%TYPE;
        v_apply_end_dt_alias      igs_pr_s_prg_conf.apply_end_dt_alias%TYPE;
        v_end_benefit_dt_alias    igs_pr_s_prg_conf.end_benefit_dt_alias%TYPE;
        v_end_penalty_dt_alias    igs_pr_s_prg_conf.end_penalty_dt_alias%TYPE;
        v_show_cause_cutoff_dt    igs_pr_s_prg_conf.show_cause_cutoff_dt_alias%TYPE;
        v_appeal_cutoff_dt        igs_pr_s_prg_conf.appeal_cutoff_dt_alias%TYPE;
        v_show_cause_ind          igs_pr_s_prg_conf.show_cause_ind%TYPE;
        v_apply_before_show_ind   igs_pr_s_prg_conf.apply_before_show_ind%TYPE;
        v_appeal_ind              igs_pr_s_prg_conf.appeal_ind%TYPE;
        v_apply_before_appeal_ind igs_pr_s_prg_conf.apply_before_appeal_ind%TYPE;
        v_count_sus_in_time_ind   igs_pr_s_prg_conf.count_sus_in_time_ind%TYPE;
        v_count_exc_in_time_ind   igs_pr_s_prg_conf.count_exc_in_time_ind%TYPE;
        v_calculate_wam_ind       igs_pr_s_prg_conf.calculate_wam_ind%TYPE;
        v_calculate_gpa_ind       igs_pr_s_prg_conf.calculate_gpa_ind%TYPE;
        v_outcome_check_type      igs_pr_s_prg_conf.outcome_check_type%TYPE;
        --
        TYPE ScaCurTyp IS REF CURSOR;
        c_sca ScaCurTyp;
        stmt_str VARCHAR2(10000);
        from_clause VARCHAR2(200);
        --
        CURSOR cur_enr_cat (
                 cp_person_id IN NUMBER,
                 cp_course_cd IN VARCHAR2
               ) IS
          SELECT   scae.enrolment_cat enrolment_cat
          FROM     igs_as_sc_atmpt_enr scae,
                   igs_ca_inst_all ci
          WHERE    scae.person_id = cp_person_id
          AND      scae.course_cd = cp_course_cd
          AND      scae.cal_type = ci.cal_type
          AND      scae.ci_sequence_number = ci.sequence_number
          ORDER BY ci.end_dt DESC;
        --
        rec_enr_cat cur_enr_cat%ROWTYPE;
        n_person_id igs_en_stdnt_ps_att_all.person_id%TYPE;
        v_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE;
        n_version_number igs_en_stdnt_ps_att_all.version_number%TYPE;
        process_record BOOLEAN := TRUE;
        --
      BEGIN
        --
        from_clause := from_clause || 'FROM igs_en_stdnt_ps_att_all sca, igs_en_su_attempt_all sua, igs_ca_inst_rel cir';
        --
        -- Append Person ID Group filter to the Where clause only when it is passed
        --
        IF (p_group_id IS NOT NULL) THEN
          from_clause := from_clause || ', igs_pe_prsid_grp_mem_all pigm';
        END IF;
        --
        -- Append Program Type filter to the Where clause only when it is passed
        --
        IF (p_course_type IS NOT NULL) THEN
          from_clause := from_clause || ', igs_ps_ver_all crv';
        END IF;
        --
        stmt_str := 'SELECT sca.person_id, sca.course_cd, sca.version_number ';
        stmt_str := stmt_str || from_clause;
        stmt_str := stmt_str ||
          ' WHERE sca.course_attempt_status IN (''ENROLLED'', ''INACTIVE'', ''INTERMIT'', ''DISCONTIN'', ''LAPSED'') ';
        --
        -- Append Program Code filter to the Where clause only when it is passed
        --
        IF (p_course_cd IS NOT NULL AND p_course_cd <> '%') THEN
          stmt_str := stmt_str || 'AND sca.course_cd = ''' || p_course_cd || ''' ';
        END IF;
        --
        IF (p_group_id IS NOT NULL) THEN
          stmt_str := stmt_str ||
            'AND pigm.group_id = ' || p_group_id  || ' ' ||
            'AND pigm.person_id = sca.person_id ';
        END IF;
        --
        IF (p_course_type IS NOT NULL) THEN
          stmt_str := stmt_str ||
            'AND crv.course_cd = sca.course_cd ' ||
            'AND crv.version_number = sca.version_number ' ||
            'AND crv.course_type = ''' || p_course_type || ''' ';
        END IF;
        --
        stmt_str := stmt_str ||
          'AND NOT EXISTS ( ' ||
          'SELECT 1 ' ||
          'FROM igs_pr_stdnt_pr_ck spc ' ||
          'WHERE sca.person_id = spc.person_id ' ||
          'AND sca.course_cd = spc.course_cd ' ||
          'AND spc.prg_cal_type = ''' || p_ci_cal_type || ''' ' ||
          'AND spc.prg_ci_sequence_number = ' || NVL (p_ci_sequence_number, 0) || ') ' ||
          'AND sca.person_id = sua.person_id ' ||
          'AND sca.course_cd = sua.course_cd ' ||
          'AND sua.unit_attempt_status NOT IN (''UNCONFIRM'', ''INVALID'') ' ||
          'AND cir.sup_cal_type = ''' || p_ci_cal_type || ''' ' ||
          'AND cir.sup_ci_sequence_number = ' || NVL (p_ci_sequence_number, 0) || ' ' ||
          'AND sua.cal_type = cir.sub_cal_type ' ||
          'AND sua.ci_sequence_number = cir.sub_ci_sequence_number ';
        --
        -- Append Location filter to the Where clause only when it is passed
        --
        IF (p_location_cd IS NOT NULL) THEN
          stmt_str := stmt_str || 'AND sca.location_cd = ''' || p_location_cd || ''' ';
        END IF;
        --
        -- Append Organization Unit filter to the Where clause only when it is passed
        --
        IF (p_org_unit_cd IS NOT NULL AND p_ou_start_dt IS NOT NULL) THEN
          stmt_str := stmt_str ||
            'AND igs_pr_gen_001.prgp_get_crv_cmt (sca.course_cd, sca.version_number, ' ||
            '''' || p_org_unit_cd || ''', TO_DATE (''' || TO_CHAR(p_ou_start_dt, 'YYYY/MM/DD') || ''', ''YYYY/MM/DD'')) = ''Y'' ';
        END IF;
        --
        -- Append Attendance Mode filter to the Where clause only when it is passed
        --
        IF (p_attendance_mode IS NOT NULL) THEN
          stmt_str := stmt_str || 'AND sca.attendance_mode = ''' || p_attendance_mode || ''' ';
        END IF;
        --
        -- Append Progression Status filter to the Where clause only when it is passed
        --
        IF (p_progression_status IS NOT NULL) THEN
          stmt_str := stmt_str || 'AND sca.progression_status = ''' || p_progression_status || ''' ';
        END IF;
        --
        stmt_str := stmt_str || 'ORDER BY sca.course_cd, sca.version_number ';
        --
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_statement,
            'igs.plsql.igs_pr_gen_004.prgpl_upd_initial_appl.dynamic_query',
            'Query Built => ' || stmt_str
          );
        END IF;
        --
        OPEN c_sca FOR stmt_str;
        --
        LOOP
          FETCH c_sca INTO n_person_id, v_course_cd, n_version_number;
          EXIT WHEN c_sca%NOTFOUND;
          process_record := TRUE;
          --
          -- Check if Student's Latest Program Attempt's Enrollment Category matches with parameter p_enrolment_cat
          --
          IF (p_enrolment_cat IS NOT NULL) THEN
            OPEN cur_enr_cat (n_person_id, v_course_cd);
            FETCH cur_enr_cat INTO rec_enr_cat;
            --
            IF ((cur_enr_cat%FOUND) AND
                (rec_enr_cat.enrolment_cat = p_enrolment_cat))THEN
              process_record := TRUE;
            ELSE
              process_record := FALSE;
            END IF;
            --
            CLOSE cur_enr_cat;
          END IF;
          --
          IF process_record THEN
            IF v_last_course_cd IS NULL OR
               (v_last_course_cd <> v_course_cd OR
                v_last_version_number <> n_version_number) THEN
              -- Determine whether considering recommended outcomes in rule checking
              igs_pr_gen_003.igs_pr_get_config_parm (
                v_course_cd,
                n_version_number,
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
                v_outcome_check_type
              );
              v_last_course_cd := v_course_cd;
              v_last_version_number := n_version_number;
            END IF;
            -- If student is ready to be checked then apply rules, by calling single SCA
            -- rule application process.
            IF prgpl_upd_check_readiness (
                 n_person_id,
                 v_course_cd,
                 n_version_number,
                 p_ci_cal_type,
                 p_ci_sequence_number,
                 v_outcome_check_type
               ) = 'Y' THEN
              igs_pr_gen_004.igs_pr_upd_sca_apply (
                n_person_id,
                v_course_cd,
                p_ci_cal_type,
                p_ci_sequence_number,
                cst_initial,
                v_log_creation_dt,
                v_recommended_outcomes,
                v_approved_outcomes,
                v_removed_outcomes,
                v_message_name
              );
            END IF;
          END IF;
        END LOOP;
        --
        CLOSE c_sca;
        --
      EXCEPTION
        WHEN OTHERS THEN
          IF c_sca%ISOPEN THEN
            CLOSE c_sca;
          END IF;
          RAISE;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_exception,
            'igs.plsql.igs_pr_gen_004.prgpl_upd_initial_appl.exit_exception',
            'Exception => ' || SQLERRM
          );
        END IF;
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_PR_GEN_004.IGS_PR_UPD_RULE_APPLY.PRGPL_UPD_INITIAL_APPL');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END prgpl_upd_initial_appl;

    PROCEDURE prgpl_upd_todo_appl
    IS
    BEGIN   -- prgpl_upd_todo_appl
    DECLARE
        cst_prg_check   CONSTANT    VARCHAR2(10) := 'PRG_CHECK';
        cst_progress    CONSTANT    VARCHAR2(10) := 'PROGRESS';
        cst_active  CONSTANT    VARCHAR2(10) := 'ACTIVE';
        v_course_type           IGS_PS_VER.course_type%TYPE;
        v_start_dt          DATE;
        v_cutoff_dt         DATE;
        v_dummy             VARCHAR2(1);
        CURSOR c_st IS
            SELECT DISTINCT st.person_id,
                st.s_student_todo_type,
                st.sequence_number,
                str.course_cd,
                sca.version_number
            FROM    IGS_PE_STD_TODO     st,
                IGS_PE_STD_TODO_REF str,
                IGS_EN_STDNT_PS_ATT sca
            WHERE   st.s_student_todo_type      = cst_prg_check AND
                st.logical_delete_dt        IS NULL AND
                st.person_id            = str.person_id AND
                st.s_student_todo_type      = str.s_student_todo_type AND
                st.sequence_number      = str.sequence_number AND
                sca.person_id           = st.person_id AND
                sca.course_cd           = str.course_cd AND
                str.course_cd           LIKE NVL(p_course_cd, str.course_cd) AND
                NVL(p_location_cd, sca.location_cd)
                                = sca.location_cd AND
                (p_org_unit_cd          IS NULL OR
                p_ou_start_dt           IS NULL OR
                IGS_PR_GEN_001.prgp_get_crv_cmt (
                    sca.course_cd,
                    sca.version_number,
                    p_org_unit_cd,
                    p_ou_start_dt)      = 'Y') AND
                (p_group_id         IS NULL OR
                 sca.person_id IN   (
                    SELECT  person_id
                    FROM    IGS_PE_PIGM_PIDGRP_MEM_V
                    WHERE   group_id = p_group_id)) AND
                (p_attendance_mode      IS NULL OR
                sca.attendance_mode     = p_attendance_mode) AND
                (p_progression_status       IS NULL OR
                sca.progression_status      = p_progression_status) AND
                (p_enrolment_cat        IS NULL OR
                EXISTS (
                SELECT  'X'
                FROM    IGS_AS_SC_ATMPT_ENR     scae,
                    IGS_CA_INST         ci1
                WHERE   sca.person_id           = scae.person_id AND
                    sca.course_cd           = scae.course_cd AND
                    scae.enrolment_cat      = p_enrolment_cat AND
                    ci1.cal_type            = scae.cal_type AND
                    ci1.sequence_number     = scae.ci_sequence_number AND
                    ci1.end_dt          =
                    (SELECT MAX(ci2.end_dt)
                    FROM    IGS_AS_SC_ATMPT_ENR scae2,
                        IGS_CA_INST         ci2
                    WHERE   scae2.person_id     = scae.person_id AND
                        scae2.course_cd     = scae.course_cd AND
                        ci2.cal_type        = scae2.cal_type AND
                        ci2.sequence_number = scae2.ci_sequence_number)));
        CURSOR  c_st_lck (
            cp_person_id        IGS_PE_STD_TODO.person_id%TYPE,
            cp_s_student_todo_type  IGS_PE_STD_TODO.s_student_todo_type%TYPE,
            cp_sequence_number  IGS_PE_STD_TODO.sequence_number%TYPE) IS
            SELECT  st.*,
                    st.ROWID
            FROM    IGS_PE_STD_TODO st
            WHERE   st.person_id = cp_person_id AND
                st.s_student_todo_type = cp_s_student_todo_type AND
                st.sequence_number = cp_sequence_number
            FOR UPDATE NOWAIT;

        v_st_lck_rec c_st_lck%ROWTYPE;

        CURSOR c_crv (
            cp_course_cd                IGS_PS_VER.course_cd%TYPE,
            cp_version_number           IGS_PS_VER.version_number%TYPE) IS
            SELECT  crv.course_type
            FROM    IGS_PS_VER          crv
            WHERE   crv.course_cd           = cp_course_cd AND
                crv.version_number      = cp_version_number;
        CURSOR c_str (
            cp_person_id                IGS_PE_STD_TODO_REF.person_id%TYPE,
            cp_s_student_todo_type          IGS_PE_STD_TODO_REF.s_student_todo_type%TYPE,
            cp_sequence_number          IGS_PE_STD_TODO_REF.sequence_number%TYPE,
            cp_course_cd                IGS_PE_STD_TODO_REF.course_cd%TYPE) IS
            SELECT  str.*,
                    str.ROWID
            FROM    IGS_PE_STD_TODO_REF     str
            WHERE   str.person_id           = cp_person_id AND
                str.s_student_todo_type     = cp_s_student_todo_type AND
                str.sequence_number     = cp_sequence_number AND
                str.course_cd           = cp_course_cd AND
                str.logical_delete_dt       IS NULL
            FOR UPDATE NOWAIT;
        CURSOR c_str_chk (
            cp_person_id                IGS_PE_STD_TODO_REF.person_id%TYPE,
            cp_s_student_todo_type          IGS_PE_STD_TODO_REF.s_student_todo_type%TYPE,
            cp_sequence_number          IGS_PE_STD_TODO_REF.sequence_number%TYPE) IS
            SELECT  'x'
            FROM    IGS_PE_STD_TODO_REF     str
            WHERE   str.person_id           = cp_person_id AND
                str.s_student_todo_type     = cp_s_student_todo_type AND
                str.sequence_number     = cp_sequence_number AND
                str.logical_delete_dt       IS NULL;
        CURSOR c_spc1 (
            cp_person_id                IGS_EN_STDNT_PS_ATT.person_id%TYPE,
            cp_course_cd                IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
            SELECT  spc.prg_cal_type,
                spc.prg_ci_sequence_number
            FROM    IGS_PR_STDNT_PR_CK  spc
            WHERE   spc.person_id           = cp_person_id AND
                spc.course_cd           = cp_course_cd;
        CURSOR c_spc2 (
            cp_cal_type             IGS_CA_INST.cal_type%TYPE,
            cp_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE,
            cp_person_id                IGS_EN_STDNT_PS_ATT.person_id%TYPE,
            cp_course_cd                IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
            SELECT  spc.prg_cal_type,
                spc.prg_ci_sequence_number
            FROM    IGS_PR_STDNT_PR_CK  spc,
                IGS_CA_INST         ci1
            WHERE   spc.person_id           = cp_person_id AND
                spc.course_cd           = cp_course_cd AND
                ci1.cal_type            = spc.prg_cal_type AND
                ci1.sequence_number     = spc.prg_ci_sequence_number AND
                ci1.start_dt            >=
                -- On or after the first progression period linked to the student unit
                -- attempt
                (SELECT MIN(ci2.start_dt)
                FROM    IGS_CA_INST_REL cir,
                    IGS_CA_INST         ci2,
                    IGS_CA_STAT         cs,
                    IGS_CA_TYPE         cat
                WHERE   cir.sub_cal_type        = cp_cal_type AND
                    cir.sub_ci_sequence_number  = cp_ci_sequence_number AND
                    ci2.cal_type            = cir.sup_cal_type AND
                    ci2.sequence_number     = cir.sup_ci_sequence_number AND
                    cat.cal_type            = ci2.cal_type AND
                    cat.s_cal_cat           = cst_progress AND
                    cs.CAL_STATUS           = ci2.CAL_STATUS AND
                    cs.s_CAL_STATUS         = cst_active);
        TYPE r_ci_record_type IS RECORD (
            cal_type        IGS_CA_INST.cal_type%TYPE,
            sequence_number     IGS_CA_INST.sequence_number%TYPE);
        r_ci_record         r_ci_record_type;
        TYPE t_ci_type IS TABLE OF r_ci_record%TYPE
            INDEX BY BINARY_INTEGER;
        v_ci_table          t_ci_type;
        v_ci_index          BINARY_INTEGER;
        v_index             BINARY_INTEGER;
        v_ci_found          BOOLEAN;
    BEGIN
        -- Process each todo ref for the person/course combination and determine the
        -- set of progression calendars to be processed
        FOR v_st_rec IN c_st LOOP
            v_ci_index := 0;
            IF p_course_type IS NOT NULL THEN
                OPEN c_crv (
                        v_st_rec.course_cd,
                        v_st_rec.version_number);
                FETCH c_crv INTO v_course_type;
                CLOSE c_crv;
            END IF;

                        -- If user has not specified a course_type or course type specified is in sink with the
            -- the course_cd and version number passed then only do the following checks else do not call
            -- the apply Progression rules process.
            IF p_course_type IS NULL OR p_course_type = v_course_type THEN
                FOR v_str_rec IN c_str (
                            v_st_rec.person_id,
                            v_st_rec.s_student_todo_type,
                            v_st_rec.sequence_number,
                            v_st_rec.course_cd) LOOP
                         -- If unit cd is null then take all the progression calendars corresponding to the person_id and course_cd and store them in
                         --  the plsql tables for processing. else if for a person_id and course_cd the unit_cd is found to be not null then
                 --  all progression calendars which start on or after the progression period and are linked to the current student unit attempt
                 --( corresponding to this person id and course code ) should be stored into the plsql table for further processing.

                    IF v_str_rec.unit_cd IS NULL THEN   -- Advanced standing
                        -- Advanced standing
                        -- Advanced standing has been altered ; re-test all previously tested
                        -- progression calendars that are still within the timeframe
                        -- c_spcl brings all progression calendars for the person id course_cd combination
                                                  -- Functionality of this for loop is:-
                        -- Store all the progression calendar records in the plsql table if the specified
                        -- course_cd and version numbers fit within the specified
                        -- bounds of the progression calendars.
                        FOR v_spc_rec IN c_spc1 (
                                    v_st_rec.person_id,
                                    v_st_rec.course_cd) LOOP
                            -- igs_pr_get_within_appl validates that the current course_cd version_number lies
                            -- is in the bounds of the current progression calendar.
                            -- If they do not qualify then do not update the plsql
                            -- table with progression calendar for which rules have to be applied
                            IF IGS_PR_GEN_006.IGS_PR_get_within_appl (
                                        v_spc_rec.prg_cal_type,
                                        v_spc_rec.prg_ci_sequence_number,
                                        v_st_rec.course_cd,
                                        v_st_rec.version_number,
                                        cst_todo,
                                        v_start_dt,
                                        v_cutoff_dt) = 'Y' THEN
                                -- Check if progression calendar is already in the PL/SQL table
                                v_ci_found := FALSE;
                                v_index := 0;
                                WHILE v_index < v_ci_index AND
                                        NOT v_ci_found LOOP
                                    v_index := v_index + 1;
                                    IF v_ci_table(v_index).cal_type = v_spc_rec.prg_cal_type AND
                                            v_ci_table(v_index).sequence_number =
                                            v_spc_rec.prg_ci_sequence_number THEN
                                        v_ci_found := TRUE;
                                    END IF;
                                END LOOP;
                                IF NOT v_ci_found THEN
                                    -- Store the progression calendar in the PL/SQL table
                                    v_ci_index := v_ci_index + 1;
                                    v_ci_table(v_ci_index).cal_type := v_spc_rec.prg_cal_type;
                                    v_ci_table(v_ci_index).sequence_number :=
                                         v_spc_rec.prg_ci_sequence_number;
                                END IF;
                            END IF;
                        END LOOP;   -- c_spc1
                    ELSE
                        -- Process all progression calendars which start after the calendar start date
                        -- Unit amendment ; re-check rules within progression calendars that are
                        -- in any way related to the teaching calendar
                        FOR v_spc_rec IN c_spc2 (
                                    v_str_rec.cal_type,
                                    v_str_rec.ci_sequence_number,
                                    v_st_rec.person_id,
                                    v_st_rec.course_cd) LOOP

                            IF IGS_PR_GEN_006.IGS_PR_get_within_appl (
                                        v_spc_rec.prg_cal_type,
                                        v_spc_rec.prg_ci_sequence_number,
                                        v_st_rec.course_cd,
                                        v_st_rec.version_number,
                                        cst_todo,
                                        v_start_dt,
                                        v_cutoff_dt) = 'Y' THEN

                                -- Check if progression calendar is already in the PL/SQL table
                                v_ci_found := FALSE;
                                v_index := 0;
                                WHILE v_index < v_ci_index AND
                                        NOT v_ci_found LOOP
                                    v_index := v_index + 1;
                                    IF v_ci_table(v_index).cal_type = v_spc_rec.prg_cal_type AND
                                            v_ci_table(v_index).sequence_number =
                                            v_spc_rec.prg_ci_sequence_number THEN
                                        v_ci_found := TRUE;
                                    END IF;
                                END LOOP;
                                IF NOT v_ci_found THEN
                                -- Store the progression calendar in the PL/SQL table
                                    v_ci_index := v_ci_index + 1;
                                    v_ci_table(v_ci_index).cal_type := v_spc_rec.prg_cal_type;
                                    v_ci_table(v_ci_index).sequence_number :=
                                                v_spc_rec.prg_ci_sequence_number;
                                END IF;
                            END IF;
                        END LOOP;   -- c_spc2
                    END IF;
                    -- Logically delete the str record
/*                  UPDATE  IGS_PE_STD_TODO_REF
                    SET logical_delete_dt = SYSDATE
                    WHERE CURRENT OF c_str;
*/
                    --
                    -- kdande; 23-Apr-2003; Bug# 2829262
                    -- Added uoo_id parameter to the
                    -- igs_pe_std_todo_ref_pkg.update_row PROCEDURE call
                    --
                    igs_pe_std_todo_ref_pkg.update_row (
                      x_rowid                 => v_str_rec.ROWID,
                      x_person_id             => v_str_rec.person_id,
                      x_s_student_todo_type   => v_str_rec.s_student_todo_type,
                      x_sequence_number       => v_str_rec.sequence_number,
                      x_reference_number      => v_str_rec.reference_number,
                      x_cal_type              => v_str_rec.cal_type,
                      x_ci_sequence_number    => v_str_rec.ci_sequence_number,
                      x_course_cd             => v_str_rec.course_cd,
                      x_unit_cd               => v_str_rec.unit_cd,
                      x_other_reference       => v_str_rec.other_reference,
                      x_logical_delete_dt     => SYSDATE,
                      x_mode                  => 'R',
                      x_uoo_id                => v_str_rec.uoo_id
                    );
                    -- **** NEED TO INSERT CHECK FOR LOCKING ON THIS UPDATE...
                END LOOP;   -- c_str
            END IF;
            -- Process the distinct progression calendars in the PL/SQL table
            FOR v_index IN 1..v_ci_index LOOP

                IGS_PR_GEN_004.IGS_PR_upd_sca_apply (
                        v_st_rec.person_id,
                        v_st_rec.course_cd,
                        v_ci_table(v_index).cal_type,
                        v_ci_table(v_index).sequence_number,
                        cst_todo,
                        v_log_creation_dt,
                        v_recommended_outcomes,
                        v_approved_outcomes,
                        v_removed_outcomes,
                        v_message_name);
            END LOOP;   -- PL/SQL table
            OPEN c_str_chk( v_st_rec.person_id,
                    v_st_rec.s_student_todo_type,
                    v_st_rec.sequence_number);
            FETCH c_str_chk INTO v_dummy;
            IF c_str_chk%NOTFOUND THEN
                OPEN c_st_lck   (   v_st_rec.person_id,
                            v_st_rec.s_student_todo_type,
                            v_st_rec.sequence_number);
                FETCH c_st_lck INTO v_st_lck_rec;
                -- Logically delete the st record
/*
                UPDATE  IGS_PE_STD_TODO
                SET logical_delete_dt = SYSDATE
                WHERE CURRENT OF c_st_lck;
*/
                IGS_PE_STD_TODO_PKG.UPDATE_ROW(
                  X_ROWID                 => v_st_lck_rec.ROWID,
                  X_PERSON_ID             => v_st_lck_rec.PERSON_ID,
                  X_S_STUDENT_TODO_TYPE   => v_st_lck_rec.S_STUDENT_TODO_TYPE,
                  X_SEQUENCE_NUMBER       => v_st_lck_rec.SEQUENCE_NUMBER,
                  X_TODO_DT               => v_st_lck_rec.TODO_DT,
                  X_LOGICAL_DELETE_DT     => SYSDATE,
                  X_MODE                  => 'R'
                );

                -- **** NEED TO INSERT CHECK FOR LOCKING ON THIS UPDATE...
                CLOSE c_st_lck;
            END IF;
            CLOSE c_str_chk;
        END LOOP;   -- c_st
    EXCEPTION
        WHEN OTHERS THEN
            IF c_st%ISOPEN THEN
                CLOSE c_st;
            END IF;
            IF c_str%ISOPEN THEN
                CLOSE c_str;
            END IF;
            IF c_crv%ISOPEN THEN
                CLOSE c_crv;
            END IF;
            IF c_spc1%ISOPEN THEN
                CLOSE c_spc1;
            END IF;
            IF c_spc2%ISOPEN THEN
                CLOSE c_spc2;
            END IF;
            IF c_str_chk%ISOPEN THEN
                CLOSE c_str_chk;
            END IF;
            IF c_st_lck%ISOPEN THEN
                CLOSE c_st_lck;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_RULE_APPLY.PRGPL_UPD_TODO_APPL');
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END prgpl_upd_todo_appl;
  BEGIN
    -- Generate a log entry
    v_key :=
         p_prg_cal_type || '|' || TO_CHAR (p_prg_sequence_number) || '|' ||
         p_course_type || '|' || p_org_unit_cd || '|' || igs_ge_date.igschardt (p_ou_start_dt) || '|' ||
         p_course_cd || '|' || p_location_cd || '|' || p_attendance_mode || '|' ||
         p_progression_status || '|' || p_enrolment_cat || '|' || TO_CHAR (p_group_id) || '|' || p_processing_type;
    --
    igs_ge_gen_003.genp_ins_log (cst_prg_appl, v_key, v_log_creation_dt);
    p_log_creation_dt := v_log_creation_dt;
    --
    IF p_processing_type IN (cst_initial, cst_both) THEN
      -- Select progression calendars to be processed
      FOR v_ci_rec IN c_ci LOOP
        prgpl_upd_initial_appl (
          v_ci_rec.cal_type,
          v_ci_rec.sequence_number
        );
      END LOOP;
    END IF;
    --
    IF p_processing_type IN (cst_todo, cst_both) THEN
      IF p_prg_cal_type IS NULL THEN
        -- Process Todo Entries - only if progression calendar is not set, as
        -- limiting todo processing to a single calendar is non-sensical.
        prgpl_upd_todo_appl;
      ELSE
        NULL;
      END IF;
    END IF;
    -- Details are always committed.
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_ci%ISOPEN THEN
        CLOSE c_ci;
      END IF;

      RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_RULE_APPLY');
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IGS_PR_upd_rule_apply;

 PROCEDURE IGS_PR_upd_sca_apply
                  (
                     p_person_id        IN NUMBER,
                     p_course_cd        IN VARCHAR2,
                     p_prg_cal_type     IN VARCHAR2,
                     p_prg_sequence_number  IN NUMBER,
                     p_application_type     IN VARCHAR2,
                     p_log_creation_dt      IN DATE ,
                     p_recommended_outcomes IN OUT NOCOPY NUMBER,
                     p_approved_outcomes    IN OUT NOCOPY NUMBER,
                     p_removed_outcomes     IN OUT NOCOPY NUMBER,
                     p_message_name     OUT NOCOPY VARCHAR2
                   )
 IS
    gv_other_detail             VARCHAR2(255);
 BEGIN  -- IGS_PR_upd_sca_apply
    -- Apply rules for a single course attempt in a nominated progression calendar
 DECLARE
    cst_eb      CONSTANT    VARCHAR2(2) :=  'EB';
    cst_ep      CONSTANT    VARCHAR2(2) :=  'EP';
    cst_sa      CONSTANT    VARCHAR2(2) :=  'SA';
    cst_initial CONSTANT    VARCHAR2(10) := 'INITIAL';
    cst_system  CONSTANT    VARCHAR2(10) := 'SYSTEM';
    cst_todo    CONSTANT    VARCHAR2(10) := 'TODO';
    cst_finalised   CONSTANT    VARCHAR2(10) := 'FINALISED';
    cst_manual  CONSTANT    VARCHAR2(10) := 'MANUAL';
    cst_missing CONSTANT    VARCHAR2(10) := 'MISSING';
    cst_none    CONSTANT    VARCHAR2(10) := 'NONE';
    cst_passed  CONSTANT    VARCHAR2(10) := 'PASSED';
    cst_nochange    CONSTANT    VARCHAR2(10) := 'NO-CHANGE';
    cst_no_load CONSTANT    VARCHAR2(10) := 'NO-LOAD';
    cst_recommend   CONSTANT    VARCHAR2(10) := 'RECOMMEND';
    cst_rec_outcome CONSTANT    VARCHAR2(15) := 'REC-OUTCOME';
    cst_apr_outcome CONSTANT    VARCHAR2(15) := 'APR-OUTCOME';
    cst_del_outcome CONSTANT    VARCHAR2(15) := 'DEL-OUTCOME';
    cst_past_ben    CONSTANT    VARCHAR2(10) := 'PAST-BEN';
    cst_past_pen    CONSTANT    VARCHAR2(10) := 'PAST-PEN';
    cst_un_noexist  CONSTANT    VARCHAR2(10) := 'UN-NOEXIST';
    cst_completed   CONSTANT    VARCHAR2(10) := 'COMPLETED';
    cst_unconfirm   CONSTANT    VARCHAR2(10) := 'UNCONFIRM';
    v_rule_check_dt         DATE DEFAULT SYSDATE;
    v_rolled_back           BOOLEAN DEFAULT FALSE;
    v_sprc_insert_count     INTEGER DEFAULT 0;
    v_sca_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE;
    v_course_type           IGS_PS_VER.course_type%TYPE;
    v_message_text          IGS_RU_ITEM.value%TYPE;
    v_start_dt          DATE;
    v_result_status         VARCHAR2(10);
    v_course_attempt_status     IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
    v_dummy             VARCHAR2(1);
    v_rules_applicable      BOOLEAN DEFAULT FALSE;
    v_all_rules_passed      BOOLEAN DEFAULT TRUE;
    v_rec_outcomes_applied  BOOLEAN DEFAULT FALSE;
    v_auto_outcomes_applied BOOLEAN DEFAULT FALSE;
    v_no_applicable_outcomes    BOOLEAN DEFAULT TRUE;
    v_beyond_penalty        BOOLEAN DEFAULT FALSE;
    v_beyond_benefit        BOOLEAN DEFAULT FALSE;
    v_rules_altered     BOOLEAN DEFAULT FALSE;
    v_outcomes_removed  BOOLEAN DEFAULT FALSE;
    v_apply_start_dt_alias      IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
    v_apply_end_dt_alias        IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
    v_end_benefit_dt_alias      IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
    v_end_penalty_dt_alias      IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
    v_show_cause_cutoff_dt_alias    IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
    v_appeal_cutoff_dt_alias        IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
    v_show_cause_ind            IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
    v_apply_before_show_ind     IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
    v_appeal_ind            IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
    v_apply_before_appeal_ind       IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
    v_count_sus_in_time_ind     IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
    v_count_exc_in_time_ind     IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
    v_calculate_wam_ind     IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
    v_calculate_gpa_ind     IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
    v_outcome_check_type        IGS_PR_S_PRG_CONF.outcome_check_type%TYPE;

    CURSOR c_sca_crv IS
        SELECT  sca.course_attempt_status,
            sca.version_number,
            crv.course_type
        FROM    IGS_EN_STDNT_PS_ATT         sca,
            IGS_PS_VER          crv
        WHERE   sca.person_id           = p_person_id AND
            sca.course_cd           = p_course_cd AND
            crv.course_cd           = sca.course_cd AND
            crv.version_number      = sca.version_number;

    PROCEDURE prgpl_ins_log_entry (
        p_record_type           VARCHAR2,
        p_progression_rule_cat      IGS_PR_RU_APPL.progression_rule_cat%TYPE,
        p_pra_sequence_number       IGS_PR_RU_APPL.sequence_number%TYPE,
        p_spo_sequence_number       IGS_PR_STDNT_PR_OU.sequence_number%TYPE,
        p_progression_rule_cd       IGS_PR_RU_APPL.progression_rule_cd%TYPE,
        p_reference_cd          IGS_PR_RU_APPL.reference_cd%TYPE,
        p_progression_outcome_type
                        IGS_PR_OU_TYPE.progression_outcome_type%TYPE,
        p_unit_cd           IGS_PS_UNIT_VER.unit_cd%TYPE)
    IS
    BEGIN   -- prgpl_ins_log_entry
        -- create a log entry
    DECLARE
        cst_prg_appl    CONSTANT    VARCHAR2(10) := 'PRG-APPL';
        v_key               IGS_GE_s_log_entry.KEY%TYPE;
        v_text              IGS_GE_s_log_entry.text%TYPE DEFAULT NULL;
    BEGIN
        v_key :=
            p_record_type               || '|' ||
            TO_CHAR(p_person_id)            || '|' ||
            p_course_cd                 || '|' ||
            p_prg_cal_type              || '|' ||
            TO_CHAR(p_prg_sequence_number)      || '|' ||
            p_application_type;
        IF p_record_type IN (
                    cst_passed,
                    cst_no_load) THEN
            v_text := NULL;
        ELSIF p_record_type IN (
                    cst_rec_outcome,
                    cst_apr_outcome,
                    cst_del_outcome) THEN
            v_text :=
                p_progression_rule_cat      || '|' ||
                p_progression_rule_cd       || '|' ||
                p_reference_cd          || '|' ||
                TO_CHAR(p_pra_sequence_number)  || '|' ||
                TO_CHAR(p_spo_sequence_number)  || '|' ||
                p_progression_outcome_type;
        ELSIF p_record_type IN (
                    cst_past_ben,
                    cst_past_pen) THEN
            v_text :=
                p_progression_rule_cat      || '|' ||
                p_progression_rule_cd       || '|' ||
                p_reference_cd          || '|' ||
                TO_CHAR(p_pra_sequence_number)  || '|' ||
                TO_CHAR(p_spo_sequence_number);
        ELSIF p_record_type IN (
                    cst_un_noexist) THEN
            v_text :=
                p_progression_rule_cat      || '|' ||
                p_progression_rule_cd       || '|' ||
                p_reference_cd          || '|' ||
                TO_CHAR(p_pra_sequence_number)  || '|' ||
                TO_CHAR(p_spo_sequence_number)  || '|' ||
                p_progression_outcome_type  || '|' ||
                p_unit_cd;
        END IF;
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY (
                cst_prg_appl,
                p_log_creation_dt,
                v_key,
                NULL,
                v_text);
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_INS_LOG_ENTRY');
        IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END prgpl_ins_log_entry;



    PROCEDURE prgpl_add_stdnt_prg_outcomes (
        p_progression_rule_cat          IGS_PR_RU_APPL.progression_rule_cat%TYPE,
        p_pra_sequence_number           IGS_PR_RU_APPL.sequence_number%TYPE,
        p_original_pra_sequence_number  IGS_PR_RU_APPL.sequence_number%TYPE,
        p_pro_sequence_number           IGS_PR_RU_OU.sequence_number%TYPE,
        p_apply_automatically_ind       IGS_PR_RU_OU.apply_automatically_ind%TYPE,
        p_sca_version_number            IGS_EN_STDNT_PS_ATT.version_number%TYPE,
        p_rule_check_dt                 DATE,
        p_progression_outcome_type      IGS_PR_STDNT_PR_OU.progression_outcome_type%TYPE,
        p_duration                      IGS_PR_STDNT_PR_OU.duration%TYPE,
        p_duration_type                 IGS_PR_STDNT_PR_OU.duration_type%TYPE,
        p_encmb_course_group_cd         IGS_PR_STDNT_PR_OU.encmb_course_group_cd%TYPE,
        p_restricted_enrolment_cp       IGS_PR_STDNT_PR_OU.restricted_enrolment_cp%TYPE,
        p_restricted_attendance_type    IGS_PR_STDNT_PR_OU.restricted_attendance_type%TYPE,
        p_progression_rule_cd           IGS_PR_RU_APPL.progression_rule_cd%TYPE,
        p_reference_cd                  IGS_PR_RU_APPL.reference_cd%TYPE)
    IS
    BEGIN   -- prgpl_add_stdnt_prg_outcomes
    DECLARE
        cst_approved          CONSTANT VARCHAR2(10) := 'APPROVED';
        cst_pending           CONSTANT VARCHAR2(10) := 'PENDING';
        cst_suspension        CONSTANT VARCHAR2(10) := 'SUSPENSION';
        cst_exclusion         CONSTANT VARCHAR2(10) := 'EXCLUSION';
        cst_sus_course        CONSTANT VARCHAR2(10) := 'SUS_COURSE';
        cst_exc_course        CONSTANT VARCHAR2(10) := 'EXC_COURSE';
        cst_pro               CONSTANT VARCHAR2(10) := 'PRO';
        cst_active            CONSTANT VARCHAR2(10) := 'ACTIVE';
        v_spo_sequence_number          INTEGER;
        v_new_pra_sequence_number      IGS_PR_RU_APPL.sequence_number%TYPE;
        v_decision_status              IGS_PR_STDNT_PR_OU_ALL.DECISION_STATUS%TYPE;
        v_decision_org_unit_cd         IGS_OR_unit.org_unit_cd%TYPE;
        v_decision_ou_start_dt         IGS_OR_unit.start_dt%TYPE;
        v_decision_dt                  IGS_PR_STDNT_PR_OU_ALL.DECISION_DT%TYPE;
        v_show_cause_expiry_dt         IGS_PR_STDNT_PR_OU_ALL.SHOW_CAUSE_EXPIRY_DT%TYPE;
        v_appeal_expiry_dt             IGS_PR_STDNT_PR_OU_ALL.APPEAL_EXPIRY_DT%TYPE;
        v_poc_rec_found                BOOLEAN DEFAULT FALSE;
        v_message_name                 VARCHAR2(30);
        v_dummy                        VARCHAR2(1);

        CURSOR c_spo IS
            SELECT  IGS_PR_SPO_SEQ_NUM_S.NEXTVAL
            FROM    DUAL;

        CURSOR c_crv IS
            SELECT  crv.responsible_org_unit_cd,
                crv.responsible_ou_start_dt
            FROM    IGS_PS_VER          crv
            WHERE   crv.course_cd           = p_course_cd AND
                crv.version_number      = p_sca_version_number;
        CURSOR c_poc IS
            SELECT  poc.course_cd
            FROM    IGS_PR_OU_PS        poc
            WHERE   poc.progression_rule_cat        = p_progression_rule_cat AND
                poc.pra_sequence_number     = p_original_pra_sequence_number AND
                poc.pro_sequence_number     = p_pro_sequence_number;
        CURSOR c_pot_etde IS
            SELECT  'X'
            FROM    IGS_PR_OU_TYPE  pot,
                IGS_FI_ENC_DFLT_EFT     etde
            WHERE   pot.progression_outcome_type    = p_progression_outcome_type AND
                pot.s_progression_outcome_type  IN (
                                cst_suspension,
                                cst_exclusion) AND
                pot.encumbrance_type        = etde.encumbrance_type AND
                etde.s_encmb_effect_type    IN (
                                cst_sus_course,
                                cst_exc_course);
        CURSOR c_popu IS
            SELECT  popu.unit_cd,
                popu.s_unit_type
            FROM    IGS_PR_OU_UNIT      popu
            WHERE   popu.progression_rule_cat   = p_progression_rule_cat AND
                popu.pra_sequence_number    = p_original_pra_sequence_number AND
                popu.pro_sequence_number    = p_pro_sequence_number;


        CURSOR c_pous IS
            SELECT  pous.unit_set_cd,
                pous.us_version_number
            FROM    IGS_PR_OU_UNIT_SET      pous
            WHERE   pous.progression_rule_cat   = p_progression_rule_cat AND
                pous.pra_sequence_number    = p_original_pra_sequence_number AND
                pous.pro_sequence_number    = p_pro_sequence_number;

        CURSOR c_poa IS
               SELECT poa.award_cd
               FROM IGS_PR_OU_AWD poa
               WHERE  poa.progression_rule_cat  = p_progression_rule_cat AND
                poa.pra_sequence_number = p_original_pra_sequence_number AND
                poa.pro_sequence_number = p_pro_sequence_number;

          --
          -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
          --
                  CURSOR c_pfnd IS
           SELECT pfnd.fund_code
           FROM    IGS_PR_OU_FND pfnd
           WHERE    pfnd.progression_rule_cat   = p_progression_rule_cat AND
                pfnd.pra_sequence_number    = p_original_pra_sequence_number AND
                pfnd.pro_sequence_number    = p_pro_sequence_number;
          --
          -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
          --

        CURSOR c_pra IS
            SELECT  pra.progression_rule_cat,
                pra.sequence_number
            FROM    IGS_PR_RU_APPL      pra
            WHERE   pra.s_relation_type     = cst_pro AND
                pra.pro_pra_sequence_number = p_original_pra_sequence_number AND
                pra.pro_sequence_number     = p_pro_sequence_number AND
                pra.logical_delete_dt       IS NULL;
        CURSOR c_uv (
            cp_unit_cd              IGS_PS_UNIT_VER.unit_cd%TYPE) IS
            SELECT  'X'
            FROM    IGS_PS_UNIT_VER         uv,
                IGS_PS_UNIT_STAT            us
            WHERE   uv.unit_cd          = cp_unit_cd AND
                uv.expiry_dt            IS NULL AND
                us.unit_status          = uv.unit_status AND
                us.s_unit_status        = cst_active;
    BEGIN
        OPEN c_spo;
        FETCH c_spo INTO v_spo_sequence_number;
        CLOSE c_spo;
        -- If the outcome is applied automatically then derive the necessary fields
        IF p_apply_automatically_ind = 'Y' THEN
            v_decision_status := cst_approved;
            -- Use the responsible OU of the course version for automatic approval.
            OPEN c_crv;
            FETCH c_crv INTO
                    v_decision_org_unit_cd,
                    v_decision_ou_start_dt;
            CLOSE c_crv;
            v_decision_dt := TRUNC(SYSDATE);
            -- Get the show cause expiry date (routine will return NULL if not
            -- applicable).
            v_show_cause_expiry_dt := IGS_PR_GEN_005.IGS_PR_clc_cause_expry (
                                p_course_cd,
                                p_sca_version_number,
                                p_prg_cal_type,
                                p_prg_sequence_number,
                                p_progression_rule_cat,
                                p_pra_sequence_number,
                                p_pro_sequence_number);
            -- Get the appeal expiry date (routine will return NULL if not applicable).
            v_appeal_expiry_dt := IGS_PR_GEN_005.IGS_PR_clc_apl_expry (
                                p_course_cd,
                                p_sca_version_number,
                                p_prg_cal_type,
                                p_prg_sequence_number,
                                p_progression_rule_cat,
                                p_pra_sequence_number,
                                p_pro_sequence_number);
        ELSE
            v_decision_status := cst_pending;
            v_decision_org_unit_cd := NULL;
            v_decision_ou_start_dt := NULL;
            v_decision_dt := NULL;
            v_show_cause_expiry_dt := NULL;
            v_appeal_expiry_dt := NULL;
        END IF;
          DECLARE
            lv_rowid VARCHAR2(25);
            lv_org_id NUMBER(15);
          BEGIN
            lv_org_id := igs_ge_gen_003.get_org_id;
            igs_pr_stdnt_pr_ou_pkg.insert_row (
              x_rowid                        =>  lv_rowid,
              x_person_id                    =>  p_person_id,
              x_course_cd                    => p_course_cd,
              x_sequence_number              => v_spo_sequence_number,
              x_prg_cal_type                 => p_prg_cal_type,
              x_prg_ci_sequence_number       => p_prg_sequence_number,
              x_rule_check_dt                => p_rule_check_dt,
              x_progression_rule_cat         => p_progression_rule_cat,
              x_pra_sequence_number          => p_pra_sequence_number,
              x_pro_sequence_number          => p_pro_sequence_number,
              x_progression_outcome_type     => p_progression_outcome_type,
              x_duration                     => p_duration,
              x_duration_type                => p_duration_type,
              x_decision_status              => v_decision_status,
              x_decision_dt                  => v_decision_dt,
              x_decision_org_unit_cd         => v_decision_org_unit_cd,
              x_decision_ou_start_dt         => v_decision_ou_start_dt,
              x_applied_dt                   => v_appeal_expiry_dt,
              x_show_cause_expiry_dt         => v_show_cause_expiry_dt,
              x_show_cause_dt                => NULL,
              x_show_cause_outcome_dt        => NULL,
              x_show_cause_outcome_type      => NULL,
              x_appeal_expiry_dt             => v_appeal_expiry_dt,
              x_appeal_dt                    => NULL,
              x_appeal_outcome_dt            => NULL,
              x_appeal_outcome_type          => NULL,
              x_encmb_course_group_cd        => p_encmb_course_group_cd,
              x_restricted_enrolment_cp      => p_restricted_enrolment_cp,
              x_restricted_attendance_type   => p_restricted_attendance_type,
              x_comments                     => NULL,
              x_show_cause_comments          => NULL,
              x_appeal_comments              => NULL,
              x_expiry_dt                    => NULL,
              x_pro_pra_sequence_number      => p_original_pra_sequence_number, --NULL, -- Modified by Prajeesh as no value was passed and primary key violation happening
              x_mode                         => 'R',
              x_org_id                       => lv_org_id
            );
          END;
        -- Copy progression outcome course details from the outcome.
        FOR v_poc_rec IN c_poc LOOP
            v_poc_rec_found := TRUE;
              DECLARE
                    LV_ROWID VARCHAR2(25);
              BEGIN
                IGS_PR_STDNT_PR_PS_PKG.INSERT_ROW (
                  X_ROWID =>LV_ROWID,
                  X_PERSON_ID =>p_person_id,
                  X_SPO_COURSE_CD => p_course_cd,
                  X_SPO_SEQUENCE_NUMBER => v_spo_sequence_number,
                  X_COURSE_CD =>v_poc_rec.course_cd,
                  X_MODE =>'R');
              END;
        END LOOP;


        IF NOT v_poc_rec_found THEN
            OPEN c_pot_etde;
            FETCH c_pot_etde INTO v_dummy;
            IF c_pot_etde%FOUND THEN
                CLOSE c_pot_etde;
                -- If no courses specified then default the exclusion or suspension to
                -- the enrolled course
                DECLARE
                  LV_ROWID VARCHAR2(25);
                BEGIN
                  IGS_PR_STDNT_PR_PS_PKG.INSERT_ROW (
                    X_ROWID =>LV_ROWID,
                    X_PERSON_ID =>p_person_id,
                    X_SPO_COURSE_CD => p_course_cd,
                    X_SPO_SEQUENCE_NUMBER => v_spo_sequence_number,
                    X_COURSE_CD => p_course_cd,
                    X_MODE =>'R'
                  );
                END;
            ELSE
                CLOSE c_pot_etde;
            END IF;
        END IF;


        FOR v_popu_rec IN c_popu LOOP
            -- Check that an offered version of the unit exists. If not, skip the unit
            -- and report an exception
            OPEN c_uv (v_popu_rec.unit_cd);
            FETCH c_uv INTO v_dummy;
            IF c_uv%FOUND THEN
                CLOSE c_uv;
                DECLARE
                  LV_ROWID VARCHAR2(25);
                BEGIN
                  IGS_PR_STDNT_PR_UNIT_PKG.INSERT_ROW (
                    X_ROWID =>LV_ROWID,
                    X_PERSON_ID =>p_person_id,
                    X_COURSE_CD =>p_course_cd,
                    X_SPO_SEQUENCE_NUMBER =>v_spo_sequence_number,
                    X_UNIT_CD => v_popu_rec.unit_cd,
                    X_S_UNIT_TYPE => v_popu_rec.s_unit_type,
                    X_MODE =>'R'
                  );
                END;
            ELSE
                CLOSE c_uv;
                IF p_log_creation_dt IS NOT NULL THEN
                    prgpl_ins_log_entry (
                        cst_un_noexist,
                        p_progression_rule_cat,
                        p_pra_sequence_number,
                        v_spo_sequence_number,
                        p_progression_rule_cd,
                        p_reference_cd,
                        p_progression_outcome_type,
                        v_popu_rec.unit_cd);
                END IF;
            END IF;
        END LOOP;


        -- Copy unit set records down from the outcome.
        FOR v_pous_rec IN c_pous LOOP
          DECLARE
            LV_ROWID VARCHAR2(25);
          BEGIN
            IGS_PR_SDT_PR_UNT_ST_PKG.INSERT_ROW (
              X_ROWID =>lv_rowid,
              X_PERSON_ID => p_person_id,
              X_COURSE_CD => P_COURSE_CD,
              X_SPO_SEQUENCE_NUMBER =>v_spo_sequence_number,
              X_UNIT_SET_CD =>v_pous_rec.unit_set_cd,
              X_VERSION_NUMBER =>v_pous_rec.us_version_number,
              X_MODE => 'R'
            );
          END;
        END LOOP;


        -- Copy award records down from the outcome.
        FOR v_poa_rec IN c_poa LOOP
          DECLARE
            LV_ROWID VARCHAR2(25);
          BEGIN
            IGS_PR_STDNT_PR_AWD_PKG.INSERT_ROW (
              X_ROWID =>lv_rowid,
              X_PERSON_ID => p_person_id,
              X_COURSE_CD => P_COURSE_CD,
              X_SPO_SEQUENCE_NUMBER =>v_spo_sequence_number,
              X_AWARD_CD =>v_poa_rec.AWARD_cd,
              X_MODE => 'R'
            );
          END;
        END LOOP;

        -- Copy Fund records down from the outcome.
        FOR v_pfnd_rec IN c_pfnd LOOP
          DECLARE
            lv_rowid VARCHAR2(25);
          BEGIN
            igs_pr_stdnt_pr_fnd_pkg.insert_row (
              X_ROWID =>lv_rowid,
              X_PERSON_ID => p_person_id,
              X_COURSE_CD => p_course_cd,
              X_SPO_SEQUENCE_NUMBER => v_spo_sequence_number,
              X_FUND_CODE => v_pfnd_rec.fund_code,
              X_MODE => 'R'
            );
          END;
        END LOOP;


        -- Copy any PRO level rules to SPO level.
        FOR v_pra_rec IN c_pra LOOP
            v_new_pra_sequence_number := IGS_PR_GEN_006.IGS_PR_ins_copy_pra (
                                v_pra_rec.progression_rule_cat,
                                v_pra_rec.sequence_number,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                p_person_id,
                                p_course_cd,
                                v_spo_sequence_number,
                                NULL,
                                NULL,
                                v_message_name);
        END LOOP;



        IF v_decision_status = cst_pending THEN
            p_recommended_outcomes := p_recommended_outcomes + 1;
            v_rec_outcomes_applied := TRUE;
            IF p_log_creation_dt IS NOT NULL THEN
                prgpl_ins_log_entry (
                    cst_rec_outcome,
                    p_progression_rule_cat,
                    p_pra_sequence_number,
                    v_spo_sequence_number,
                    p_progression_rule_cd,
                    p_reference_cd,
                    p_progression_outcome_type,
                    NULL);
            END IF;
        ELSE
            p_approved_outcomes := p_approved_outcomes + 1;
            v_auto_outcomes_applied := TRUE;
            IF p_log_creation_dt IS NOT NULL THEN
                prgpl_ins_log_entry (
                    cst_apr_outcome,
                    p_progression_rule_cat,
                    p_pra_sequence_number,
                    v_spo_sequence_number,
                    p_progression_rule_cd,
                    p_reference_cd,
                    p_progression_outcome_type,
                    NULL);
            END IF;
        END IF;

        RETURN;

    EXCEPTION
        WHEN OTHERS THEN
            IF c_spo%ISOPEN THEN
                CLOSE c_spo;
            END IF;
            IF c_crv%ISOPEN THEN
                CLOSE c_crv;
            END IF;
            IF c_poc%ISOPEN THEN
                CLOSE c_poc;
            END IF;
            IF c_pot_etde%ISOPEN THEN
                CLOSE c_pot_etde;
            END IF;
            IF c_popu%ISOPEN THEN
                CLOSE c_popu;
            END IF;
            IF c_pfnd%ISOPEN THEN
                CLOSE c_pfnd;
            END IF;
            IF c_pous%ISOPEN THEN
                CLOSE c_pous;
            END IF;
            IF c_poa%ISOPEN THEN
                CLOSE c_poa;
            END IF;
            IF c_uv%ISOPEN THEN
                CLOSE c_uv;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_ADD_STDNT_PRG_OUTCOMES');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
    END prgpl_add_stdnt_prg_outcomes;


    PROCEDURE prgpl_create_outcomes (
        p_sca_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE,
        p_progression_rule_cat      IGS_PR_RU_APPL.progression_rule_cat%TYPE,
        p_pra_sequence_number       IGS_PR_RU_APPL.sequence_number%TYPE,
        p_progression_rule_cd       IGS_PR_RU_APPL.progression_rule_cd%TYPE,
        p_reference_cd          IGS_PR_RU_APPL.reference_cd%TYPE,
        p_rule_check_dt         DATE)
    IS
    BEGIN   -- prgpl_create_outcomes
    DECLARE
        cst_consecrpt   CONSTANT    VARCHAR2(10) := 'CONSECRPT';
        cst_repeat  CONSTANT    VARCHAR2(10) := 'REPEAT';
        v_consecutive_failures      INTEGER;
        v_repeat_failures       INTEGER;
        v_last_failures         INTEGER;
        v_praov_count           INTEGER DEFAULT 0;
        v_consecutive_found     BOOLEAN DEFAULT FALSE;
        v_repeat_found          BOOLEAN DEFAULT FALSE;
        v_spo_added         BOOLEAN DEFAULT FALSE;
        CURSOR c_praov (
            cp_consecrpt            VARCHAR2,
            cp_consecutive_failures     IGS_PR_RU_OU.number_of_failures%TYPE)
            IS
            SELECT  praov.sequence_number,
                praov.number_of_failures,
                praov.progression_outcome_type,
                praov.apply_automatically_ind,
                praov.prg_rule_repeat_fail_type,
                praov.duration,
                praov.duration_type,
                praov.encmb_course_group_cd,
                praov.restricted_enrolment_cp,
                praov.restricted_attendance_type,
                praov.original_pra_sequence_number
            FROM    IGS_PR_RULE_OUT_V   praov
            WHERE   praov.progression_rule_cat  = p_progression_rule_cat AND
                    praov.pra_sequence_number   = p_pra_sequence_number AND
                    -- anilk, bug#2784198
                    praov.logical_delete_dt IS NULL AND
                    -- this condition has been modifed, when the positive outcome ind
                    -- was added. For a postive outcome category there will be no
                    -- rule repeat fail type and number of failure values
                    -- since there are no failures for a positive outcome.
                    -- Hence addition check has been added for the above case
                    -- by checking if the repeat fail type is null and outcome ind = 'Y'
                    -- otherwise if the repeat fail type is not null then the existing
                    -- check holds good.
                    (
                     (praov.prg_rule_repeat_fail_type IS NOT NULL AND
                      praov.prg_rule_repeat_fail_type = cp_consecrpt)
                     OR
                     (praov.prg_rule_repeat_fail_type IS NULL
                      AND praov.POSITIVE_OUTCOME_IND = 'Y')
                    ) AND
                    NVL(praov.number_of_failures, cp_consecutive_failures)  <= cp_consecutive_failures
            ORDER BY praov.number_of_failures DESC;
    BEGIN
        -- The logic in this section will use the record equal or closest to the
        -- number of failures by a student. Matches with 'consecutive repeat' records
        -- will always take priority. It is not expected that ambiguous  mixes of
        -- repeat and consecutive repeat records will happen too much in 'REAL life'.
        v_consecutive_failures := IGS_PR_GEN_005.IGS_PR_get_num_fail (
                            p_person_id,
                            p_course_cd,
                            p_sca_version_number,
                            p_progression_rule_cat,
                            p_pra_sequence_number,
                            p_prg_cal_type,
                            p_prg_sequence_number,
                            cst_consecrpt);
        IF v_consecutive_failures <> 0 THEN
            FOR v_praov_rec_c IN c_praov (
                            cst_consecrpt,
                            v_consecutive_failures) LOOP
                v_consecutive_found := TRUE;
                v_no_applicable_outcomes := FALSE;
                IF v_praov_rec_c.number_of_failures = v_consecutive_failures THEN
                    prgpl_add_stdnt_prg_outcomes (
                                p_progression_rule_cat,
                                p_pra_sequence_number,
                                v_praov_rec_c.original_pra_sequence_number,
                                v_praov_rec_c.sequence_number,
                                v_praov_rec_c.apply_automatically_ind,
                                p_sca_version_number,
                                p_rule_check_dt,
                                v_praov_rec_c.progression_outcome_type,
                                v_praov_rec_c.duration,
                                v_praov_rec_c.duration_type,
                                v_praov_rec_c.encmb_course_group_cd,
                                v_praov_rec_c.restricted_enrolment_cp,
                                v_praov_rec_c.restricted_attendance_type,
                                p_progression_rule_cd,
                                p_reference_cd);
                    v_spo_added := TRUE;
                END IF;
            END LOOP;
            IF v_spo_added THEN
                RETURN;
            END IF;
        END IF;
        v_repeat_failures := IGS_PR_GEN_005.IGS_PR_get_num_fail (
                            p_person_id,
                            p_course_cd,
                            p_sca_version_number,
                            p_progression_rule_cat,
                            p_pra_sequence_number,
                            p_prg_cal_type,
                            p_prg_sequence_number,
                            cst_repeat);
        FOR v_praov_rec_r IN c_praov (
                        cst_repeat,
                        v_repeat_failures) LOOP
            v_repeat_found := TRUE;
            v_no_applicable_outcomes := FALSE;
            IF v_praov_rec_r.number_of_failures = v_repeat_failures THEN
                prgpl_add_stdnt_prg_outcomes (
                            p_progression_rule_cat,
                            p_pra_sequence_number,
                            v_praov_rec_r.original_pra_sequence_number,
                            v_praov_rec_r.sequence_number,
                            v_praov_rec_r.apply_automatically_ind,
                            p_sca_version_number,
                            p_rule_check_dt,
                            v_praov_rec_r.progression_outcome_type,
                            v_praov_rec_r.duration,
                            v_praov_rec_r.duration_type,
                            v_praov_rec_r.encmb_course_group_cd,
                            v_praov_rec_r.restricted_enrolment_cp,
                            v_praov_rec_r.restricted_attendance_type,
                            p_progression_rule_cd,
                            p_reference_cd);
                v_spo_added := TRUE;
            END IF;
        END LOOP;
        IF v_spo_added THEN
            RETURN;
        END IF;
        -- Use consecutive failure records in preference to straight repeat records.
        IF v_consecutive_failures <> 0 AND
                v_consecutive_found THEN
            FOR v_praov_rec_c IN c_praov (
                            cst_consecrpt,
                            v_consecutive_failures) LOOP
                v_praov_count := v_praov_count + 1;
                IF v_praov_count > 1 THEN
                    IF v_last_failures <> v_praov_rec_c.number_of_failures THEN
                        EXIT;
                    END IF;
                END IF;
                v_last_failures := v_praov_rec_c.number_of_failures;
                prgpl_add_stdnt_prg_outcomes (
                            p_progression_rule_cat,
                            p_pra_sequence_number,
                            v_praov_rec_c.original_pra_sequence_number,
                            v_praov_rec_c.sequence_number,
                            v_praov_rec_c.apply_automatically_ind,
                            p_sca_version_number,
                            p_rule_check_dt,
                            v_praov_rec_c.progression_outcome_type,
                            v_praov_rec_c.duration,
                            v_praov_rec_c.duration_type,
                            v_praov_rec_c.encmb_course_group_cd,
                            v_praov_rec_c.restricted_enrolment_cp,
                            v_praov_rec_c.restricted_attendance_type,
                            p_progression_rule_cd,
                            p_reference_cd);
            END LOOP;
        ELSIF v_repeat_found THEN
            FOR v_praov_rec_r IN c_praov (
                            cst_repeat,
                            v_repeat_failures) LOOP
                v_praov_count := v_praov_count + 1;
                IF v_praov_count > 1 THEN
                    IF v_last_failures <> v_praov_rec_r.number_of_failures THEN
                        EXIT;
                    END IF;
                END IF;
                v_last_failures := v_praov_rec_r.number_of_failures;
                prgpl_add_stdnt_prg_outcomes (
                            p_progression_rule_cat,
                            p_pra_sequence_number,
                            v_praov_rec_r.original_pra_sequence_number,
                            v_praov_rec_r.sequence_number,
                            v_praov_rec_r.apply_automatically_ind,
                            p_sca_version_number,
                            p_rule_check_dt,
                            v_praov_rec_r.progression_outcome_type,
                            v_praov_rec_r.duration,
                            v_praov_rec_r.duration_type,
                            v_praov_rec_r.encmb_course_group_cd,
                            v_praov_rec_r.restricted_enrolment_cp,
                            v_praov_rec_r.restricted_attendance_type,
                            p_progression_rule_cd,
                            p_reference_cd);
            END LOOP;
        END IF  ;
                 RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            IF c_praov%ISOPEN THEN
                CLOSE c_praov;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_CREATE_OUTCOMES');
         IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END prgpl_create_outcomes;


    FUNCTION prgpl_rmv_stdnt_prg_outcomes (
        p_progression_rule_cat      IGS_PR_RU_APPL.progression_rule_cat%TYPE,
        p_pra_sequence_number       IGS_PR_RU_APPL.sequence_number%TYPE,
        p_progression_rule_cd       IGS_PR_RU_APPL.progression_rule_cd%TYPE,
        p_reference_cd          IGS_PR_RU_APPL.reference_cd%TYPE)
    RETURN BOOLEAN
    IS
    BEGIN   -- prgpl_rmv_stdnt_prg_outcomes
    DECLARE
        e_record_locked         EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_record_locked, -54);
        cst_pending CONSTANT    VARCHAR2(10) := 'PENDING';
        cst_approved    CONSTANT    VARCHAR2(10) := 'APPROVED';
        cst_removed CONSTANT    VARCHAR2(10) := 'REMOVED';
        cst_spo     CONSTANT    VARCHAR2(10) := 'SPO';
        v_record_locked         BOOLEAN DEFAULT FALSE;
        v_progression_outcome_type
                        IGS_PR_OU_TYPE.progression_outcome_type%TYPE;
        CURSOR c_spo IS
            SELECT  spo.*,
                spo.ROWID
            FROM    IGS_PR_STDNT_PR_OU  spo
            WHERE   spo.person_id           = p_person_id AND
                spo.course_cd           = p_course_cd AND
                spo.prg_cal_type            = p_prg_cal_type AND
                spo.prg_ci_sequence_number  = p_prg_sequence_number AND
                spo.progression_rule_cat        = p_progression_rule_cat AND
                spo.pra_sequence_number     = p_pra_sequence_number AND
                spo.decision_status     IN (
                                cst_pending,
                                cst_approved) AND
                NVL(spo.expiry_dt,igs_ge_date.igsdate('9999/01/01')) > TRUNC(SYSDATE)
            FOR UPDATE NOWAIT;
        CURSOR c_spc (
            cp_sequence_number      IGS_PR_STDNT_PR_PS.spo_sequence_number%TYPE) IS
            SELECT  spc.ROWID
            FROM    IGS_PR_STDNT_PR_PS      spc
            WHERE   spc.person_id           = p_person_id AND
                spc.spo_course_cd       = p_course_cd AND
                spc.spo_sequence_number     = cp_sequence_number
            FOR UPDATE NOWAIT;
        CURSOR c_spus (
            cp_sequence_number      IGS_PR_SDT_PR_UNT_ST.spo_sequence_number%TYPE) IS
            SELECT  spus.ROWID
            FROM    IGS_PR_SDT_PR_UNT_ST    spus
            WHERE   spus.person_id          = p_person_id AND
                spus.course_cd          = p_course_cd AND
                spus.spo_sequence_number    = cp_sequence_number
            FOR UPDATE NOWAIT;


        CURSOR c_spaw (
            cp_sequence_number      IGS_PR_SDT_PR_UNT_ST.spo_sequence_number%TYPE) IS
            SELECT  spaw.ROWID
            FROM    IGS_PR_STDNT_PR_AWD spaw
            WHERE   spaw.person_id      = p_person_id AND
                spaw.course_cd          = p_course_cd AND
                spaw.spo_sequence_number    = cp_sequence_number
            FOR UPDATE NOWAIT;


        CURSOR c_spu (
            cp_sequence_number      IGS_PR_STDNT_PR_UNIT.spo_sequence_number%TYPE) IS
            SELECT  spu.ROWID
            FROM    IGS_PR_STDNT_PR_UNIT        spu
            WHERE   spu.person_id           = p_person_id AND
                spu.course_cd           = p_course_cd AND
                spu.spo_sequence_number     = cp_sequence_number
            FOR UPDATE NOWAIT;
        CURSOR c_pra (
            cp_sequence_number      IGS_PR_RU_APPL.spo_sequence_number%TYPE) IS
            SELECT  pra.progression_rule_cat,
                pra.sequence_number, pra.ROWID
            FROM    IGS_PR_RU_APPL      pra
            WHERE   pra.spo_person_id       = p_person_id AND
                pra.spo_course_cd       = p_course_cd AND
                pra.spo_sequence_number     = cp_sequence_number AND
                pra.s_relation_type     = cst_spo
            FOR UPDATE NOWAIT;
        CURSOR c_prct (
            cp_progression_rule_cat         IGS_PR_RU_APPL.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_RU_APPL.sequence_number%TYPE) IS
            SELECT  prct.ROWID
            FROM    IGS_PR_RU_CA_TYPE   prct
            WHERE   prct.progression_rule_cat   = cp_progression_rule_cat AND
                prct.pra_sequence_number    = cp_pra_sequence_number
            FOR UPDATE NOWAIT;
        CURSOR c_pro (
            cp_progression_rule_cat         IGS_PR_RU_APPL.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_RU_APPL.sequence_number%TYPE) IS
            SELECT  pro.*
            FROM    IGS_PR_RU_OU    pro
            WHERE   pro.progression_rule_cat    = cp_progression_rule_cat AND
                pro.pra_sequence_number     = cp_pra_sequence_number
            FOR UPDATE NOWAIT;
        CURSOR c_poc (
            cp_progression_rule_cat         IGS_PR_RU_APPL.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_RU_APPL.sequence_number%TYPE,
            cp_pro_sequence_number          IGS_PR_RU_OU.sequence_number%TYPE) IS
            SELECT  poc.progression_rule_cat, poc.ROWID
            FROM    IGS_PR_OU_PS        poc
            WHERE   poc.progression_rule_cat    = cp_progression_rule_cat AND
                poc.pra_sequence_number     = cp_pra_sequence_number AND
                poc.pro_sequence_number     = cp_pro_sequence_number
            FOR UPDATE NOWAIT;


        CURSOR c_pous (
            cp_progression_rule_cat         IGS_PR_RU_APPL.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_RU_APPL.sequence_number%TYPE,
            cp_pro_sequence_number          IGS_PR_RU_OU.sequence_number%TYPE) IS
            SELECT  pous.ROWID
            FROM    IGS_PR_OU_UNIT_SET      pous
            WHERE   pous.progression_rule_cat   = cp_progression_rule_cat AND
                pous.pra_sequence_number    = cp_pra_sequence_number AND
                pous.pro_sequence_number    = cp_pro_sequence_number
            FOR UPDATE NOWAIT;

        CURSOR c_poa (
            cp_progression_rule_cat         IGS_PR_RU_APPL.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_RU_APPL.sequence_number%TYPE,
            cp_pro_sequence_number          IGS_PR_RU_OU.sequence_number%TYPE) IS
            SELECT  poa.ROWID
            FROM    IGS_PR_OU_AWD       poa
            WHERE   poa.progression_rule_cat = cp_progression_rule_cat AND
                poa.pra_sequence_number = cp_pra_sequence_number AND
                poa.pro_sequence_number = cp_pro_sequence_number
            FOR UPDATE NOWAIT;

        CURSOR c_popu (
            cp_progression_rule_cat         IGS_PR_RU_APPL.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_RU_APPL.sequence_number%TYPE,
            cp_pro_sequence_number          IGS_PR_RU_OU.sequence_number%TYPE) IS
            SELECT  popu.ROWID
            FROM    IGS_PR_OU_UNIT      popu
            WHERE   popu.progression_rule_cat   = cp_progression_rule_cat AND
                popu.pra_sequence_number    = cp_pra_sequence_number AND
                popu.pro_sequence_number    = cp_pro_sequence_number
            FOR UPDATE NOWAIT;
        --
        -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
        --
        CURSOR c_sfnd (cp_spo_sequence_number igs_pr_stdnt_pr_fnd.spo_sequence_number%TYPE) IS
         SELECT sfnd.rowid
         FROM   igs_pr_stdnt_pr_fnd sfnd
         WHERE  sfnd.person_id      = p_person_id AND
            sfnd.course_cd      = p_course_cd AND
            sfnd.spo_sequence_number = cp_spo_sequence_number
        FOR UPDATE NOWAIT;

        CURSOR c_pfnd (
            cp_progression_rule_cat         IGS_PR_RU_APPL.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_RU_APPL.sequence_number%TYPE,
            cp_pro_sequence_number          IGS_PR_RU_OU.sequence_number%TYPE) IS
        SELECT  pfnd.ROWID
        FROM    IGS_PR_OU_FND pfnd
        WHERE   pfnd.progression_rule_cat   = cp_progression_rule_cat AND
            pfnd.pra_sequence_number    = cp_pra_sequence_number  AND
            pfnd.pro_sequence_number    = cp_pro_sequence_number
        FOR UPDATE NOWAIT;
        --
        -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
        --
    BEGIN
        FOR v_spo_rec IN c_spo LOOP
            v_progression_outcome_type := v_spo_rec.progression_outcome_type;
            IF v_spo_rec.decision_status = cst_pending THEN
                -- Delete from IGS_PR_STDNT_PR_PS
                BEGIN
                    FOR v_spc_rec IN c_spc (v_spo_rec.sequence_number) LOOP
                        IGS_PR_STDNT_PR_PS_PKG.DELETE_ROW(
                          v_spc_rec.ROWID
                        );
                    END LOOP;
                EXCEPTION
                    WHEN e_record_locked THEN
                        IF c_spc%ISOPEN THEN
                            CLOSE c_spc;
                        END IF;
                        p_message_name := 'IGS_PR_UNLO_STPR_CR_ORCNT_TA';
                        v_record_locked := TRUE;
                        EXIT;
                    WHEN OTHERS THEN
                        RAISE;
                END;


                -- Delete from IGS_PR_SDT_PR_UNT_ST
                BEGIN
                    FOR v_spus_rec IN c_spus (v_spo_rec.sequence_number) LOOP
                        IGS_PR_SDT_PR_UNT_ST_PKG.DELETE_ROW(
                          v_spus_rec.ROWID
                        );
                    END LOOP;
                EXCEPTION
                    WHEN e_record_locked THEN
                        IF c_spus%ISOPEN THEN
                            CLOSE c_spus;
                        END IF;
                        p_message_name := 'IGS_PR_UNLO_STPR_USR_ORNA_TA';
                        v_record_locked := TRUE;
                        EXIT;
                    WHEN OTHERS THEN
                        RAISE;
                END;

                -- Delete from IGS_PR_STDNT_PR_AWD
                BEGIN
                    FOR v_spaw_rec IN c_spaw (v_spo_rec.sequence_number) LOOP
                        IGS_PR_STDNT_PR_AWD_PKG.DELETE_ROW(
                          v_spaw_rec.ROWID
                        );
                    END LOOP;
                EXCEPTION
                    WHEN e_record_locked THEN
                        IF c_spaw%ISOPEN THEN
                            CLOSE c_spaw;
                        END IF;
                        p_message_name := 'IGS_PR_UNLO_STPR_AWD_ORNA_TA';
                        v_record_locked := TRUE;
                        EXIT;
                    WHEN OTHERS THEN
                        RAISE;
                END;


                -- Delete from IGS_PR_STDNT_PR_UNIT
                BEGIN
                    FOR v_spu_rec IN c_spu (v_spo_rec.sequence_number) LOOP
                        IGS_PR_STDNT_PR_UNIT_PKG.DELETE_ROW(
                          v_spu_rec.ROWID
                        );
                    END LOOP;
                EXCEPTION
                    WHEN e_record_locked THEN
                        IF c_spu%ISOPEN THEN
                            CLOSE c_spu;
                        END IF;
                        p_message_name := 'IGS_PR_UNLO_STPR_UR_ORNA_TA';
                        v_record_locked := TRUE;
                        EXIT;
                    WHEN OTHERS THEN
                        RAISE;
                END;

                --
                -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                --
                -- Delete from IGS_PR_STDNT_PR_FND
                BEGIN
                  FOR v_sfnd_rec IN c_sfnd (v_spo_rec.sequence_number) LOOP
                    igs_pr_stdnt_pr_fnd_pkg.delete_row(v_sfnd_rec.ROWID);
                  END LOOP;
                EXCEPTION
                  WHEN e_record_locked THEN
                    IF c_spu%ISOPEN THEN
                      CLOSE c_spu;
                    END IF;
                    p_message_name := 'IGS_PR_UNLO_STPR_FND_ORNA_TA';
                   /* Unable to lock student progression fund records - outcomes from rule checks not applied. Please try again later. */
                    v_record_locked := TRUE;
                    EXIT;
                  WHEN OTHERS THEN
                    RAISE;
                 END;
                --
                -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                --

                -- Delete from IGS_PR_RU_APPL
                BEGIN
                    FOR v_pra_rec IN c_pra (v_spo_rec.sequence_number) LOOP
                        FOR v_prct_rec IN c_prct (
                                    v_pra_rec.progression_rule_cat,
                                    v_pra_rec.sequence_number) LOOP
                            IGS_PR_RU_CA_TYPE_PKG.DELETE_ROW(
                              v_prct_rec.ROWID
                            );
                        END LOOP;
                        -- Delete from IGS_PR_RU_OU
                        FOR v_pro_rec IN c_pro (
                                    v_pra_rec.progression_rule_cat,
                                    v_pra_rec.sequence_number) LOOP

                            -- Delete from IGS_PR_OU_PS
                            FOR v_poc_rec IN c_poc (
                                        v_pra_rec.progression_rule_cat,
                                        v_pra_rec.sequence_number,
                                        v_pro_rec.sequence_number) LOOP
                                IGS_PR_OU_PS_PKG.DELETE_ROW(
                                  v_poc_rec.ROWID
                                );
                            END LOOP;

                            -- Delete from IGS_PR_OU_UNIT_SET
                            FOR v_pous_rec IN c_pous (
                                        v_pra_rec.progression_rule_cat,
                                        v_pra_rec.sequence_number,
                                        v_pro_rec.sequence_number) LOOP
                                IGS_PR_OU_UNIT_SET_PKG.DELETE_ROW(
                                  v_pous_rec.ROWID
                                );
                            END LOOP;

                            -- Delete from IGS_PR_OU_AWD
                            FOR v_poa_rec IN c_poa (
                                        v_pra_rec.progression_rule_cat,
                                        v_pra_rec.sequence_number,
                                        v_pro_rec.sequence_number) LOOP
                                IGS_PR_OU_AWD_PKG.DELETE_ROW(v_poa_rec.ROWID);
                            END LOOP;

                            -- Delete from IGS_PR_OU_UNIT
                            FOR v_popu_rec IN c_popu (
                                        v_pra_rec.progression_rule_cat,
                                        v_pra_rec.sequence_number,
                                        v_pro_rec.sequence_number) LOOP
                                IGS_PR_OU_UNIT_PKG.DELETE_ROW(
                                  v_popu_rec.ROWID
                                );
                            END LOOP;
                            --
                            -- Start of new code added as per the FA110 PR Enh. Bug# 2658550.
                            --
                            -- Delete from IGS_PR_OU_UNIT
                            FOR v_pfnd_rec IN c_pfnd (v_pra_rec.progression_rule_cat,
                                          v_pra_rec.sequence_number,
                                          v_pro_rec.sequence_number) LOOP
                              IGS_PR_OU_FND_PKG.DELETE_ROW (v_pfnd_rec.ROWID);
                            END LOOP;
                            --
                            -- End of new code added as per the FA110 PR Enh. Bug# 2658550.
                            --

                            -- anilk, bug#2784198
                            IGS_PR_RU_OU_PKG.UPDATE_ROW(
                                X_ROWID => v_pro_rec.ROW_ID ,
                                X_PROGRESSION_RULE_CAT => v_pro_rec.PROGRESSION_RULE_CAT ,
                                X_PRA_SEQUENCE_NUMBER => v_pro_rec.PRA_SEQUENCE_NUMBER,
                                X_SEQUENCE_NUMBER => v_pro_rec.SEQUENCE_NUMBER,
                                X_NUMBER_OF_FAILURES => v_pro_rec.NUMBER_OF_FAILURES ,
                                X_PROGRESSION_OUTCOME_TYPE => v_pro_rec.PROGRESSION_OUTCOME_TYPE ,
                                X_APPLY_AUTOMATICALLY_IND => v_pro_rec.APPLY_AUTOMATICALLY_IND ,
                                X_PRG_RULE_REPEAT_FAIL_TYPE => v_pro_rec.PRG_RULE_REPEAT_FAIL_TYPE ,
                                X_OVERRIDE_SHOW_CAUSE_IND => v_pro_rec.OVERRIDE_SHOW_CAUSE_IND ,
                                X_OVERRIDE_APPEAL_IND => v_pro_rec.OVERRIDE_APPEAL_IND ,
                                X_DURATION => v_pro_rec.DURATION ,
                                X_DURATION_TYPE => v_pro_rec.DURATION_TYPE ,
                                X_RANK => v_pro_rec.RANK ,
                                X_ENCMB_COURSE_GROUP_CD => v_pro_rec.ENCMB_COURSE_GROUP_CD ,
                                X_RESTRICTED_ENROLMENT_CP => v_pro_rec.RESTRICTED_ENROLMENT_CP ,
                                X_RESTRICTED_ATTENDANCE_TYPE => v_pro_rec.RESTRICTED_ATTENDANCE_TYPE ,
                                X_COMMENTS => v_pro_rec.COMMENTS ,
                                -- anilk, bug#2784198
                                X_LOGICAL_DELETE_DT => FND_DATE.DATE_TO_CANONICAL(SYSDATE)
                             );
                        END LOOP;

                        IGS_PR_RU_APPL_PKG.DELETE_ROW(v_pra_rec.ROWID);
                    END LOOP;
                EXCEPTION
                    WHEN e_record_locked THEN
                        IF c_prct%ISOPEN THEN
                            CLOSE c_prct;
                        END IF;
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
                        IF c_pro%ISOPEN THEN
                            CLOSE c_pro;
                        END IF;
                        IF c_pra%ISOPEN THEN
                            CLOSE c_pra;
                        END IF;
                        p_message_name := 'IGS_PR_UNLO_PRAP_RE_TA';
                        v_record_locked := TRUE;
                        EXIT;
                    WHEN OTHERS THEN
                        RAISE;
                END;
                IGS_PR_STDNT_PR_OU_PKG.DELETE_ROW(
                  v_spo_rec.ROWID
                );
            ELSE
                -- Outcome has not yet been applied, so it can be removed
/*                  UPDATE  IGS_PR_STDNT_PR_OU  spo
                SET spo.decision_status     = cst_removed
                WHERE CURRENT OF c_spo;
*/
                 IGS_PR_STDNT_PR_OU_PKG.UPDATE_ROW(
                   x_rowid                         => v_spo_rec.ROWID,
                   x_person_id                     => v_spo_rec.person_id,
                   x_course_cd                     => v_spo_rec.course_cd,
                   x_sequence_number               => v_spo_rec.sequence_number,
                   x_prg_cal_type                  => v_spo_rec.prg_cal_type,
                   x_prg_ci_sequence_number        => v_spo_rec.prg_ci_sequence_number,
                   x_rule_check_dt                 => v_spo_rec.rule_check_dt,
                   x_progression_rule_cat          => v_spo_rec.progression_rule_cat,
                   x_pra_sequence_number           => v_spo_rec.pra_sequence_number,
                   x_pro_sequence_number           => v_spo_rec.pro_sequence_number,
                   x_progression_outcome_type      => v_spo_rec.progression_outcome_type,
                   x_duration                      => v_spo_rec.duration,
                   x_duration_type                 => v_spo_rec.duration_type,
                   x_decision_status               => cst_removed,
                   x_decision_dt                   => v_spo_rec.decision_dt,
                   x_decision_org_unit_cd          => v_spo_rec.decision_org_unit_cd,
                   x_decision_ou_start_dt          => v_spo_rec.decision_ou_start_dt,
                   x_applied_dt                    => v_spo_rec.applied_dt,
                   x_show_cause_expiry_dt          => v_spo_rec.show_cause_expiry_dt,
                   x_show_cause_dt                 => v_spo_rec.show_cause_dt,
                   x_show_cause_outcome_dt         => v_spo_rec.show_cause_outcome_dt,
                   x_show_cause_outcome_type       => v_spo_rec.show_cause_outcome_type,
                   x_appeal_expiry_dt              => v_spo_rec.appeal_expiry_dt,
                   x_appeal_dt                     => v_spo_rec.appeal_dt,
                   x_appeal_outcome_dt             => v_spo_rec.appeal_outcome_dt,
                   x_appeal_outcome_type           => v_spo_rec.appeal_outcome_type,
                   x_encmb_course_group_cd         => v_spo_rec.encmb_course_group_cd,
                   x_restricted_enrolment_cp       => v_spo_rec.restricted_enrolment_cp,
                   x_restricted_attendance_type    => v_spo_rec.restricted_attendance_type,
                   x_comments                      => v_spo_rec.comments,
                   x_show_cause_comments           => v_spo_rec.show_cause_comments,
                   x_appeal_comments               => v_spo_rec.appeal_comments,
                   x_expiry_dt                     => v_spo_rec.expiry_dt,
                   x_pro_pra_sequence_number       => v_spo_rec.pro_pra_sequence_number,
                   x_mode                          => 'R'
                 );

            END IF;
            p_removed_outcomes := p_removed_outcomes + 1;
            IF p_log_creation_dt IS NOT NULL THEN
                prgpl_ins_log_entry (
                        cst_del_outcome,
                        p_progression_rule_cat,
                        p_pra_sequence_number,
                        v_spo_rec.sequence_number,
                        p_progression_rule_cd,
                        p_reference_cd,
                        v_progression_outcome_type,
                        NULL);
            END IF;
        END LOOP;
        IF v_record_locked THEN
            ROLLBACK TO sp_before_rule_apply;
            RETURN FALSE;
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN e_record_locked THEN
            IF c_spo%ISOPEN THEN
                CLOSE c_spo;
            END IF;
            p_message_name := 'IGS_PR_UNLO_STPR_ORE_ORCNT_TA';
            ROLLBACK TO sp_before_rule_apply;
            RETURN FALSE;
        WHEN OTHERS THEN
            IF c_spc%ISOPEN THEN
                CLOSE c_spc;
            END IF;
            IF c_spus%ISOPEN THEN
                CLOSE c_spus;
            END IF;
            IF c_spaw%ISOPEN THEN
                CLOSE c_spaw;
            END IF;
            IF c_spu%ISOPEN THEN
                CLOSE c_spu;
            END IF;
            IF c_prct%ISOPEN THEN
                CLOSE c_prct;
            END IF;
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
            IF c_pro%ISOPEN THEN
                CLOSE c_pro;
            END IF;
            IF c_pra%ISOPEN THEN
                CLOSE c_pra;
            END IF;
            IF c_spo%ISOPEN THEN
                CLOSE c_spo;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_RMV_STDNT_PRG_OUTCOMES');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END prgpl_rmv_stdnt_prg_outcomes;


    FUNCTION prgpl_match_att_type (
        p_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        p_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
        p_prg_cal_type          IGS_CA_INST.cal_type%TYPE,
        p_prg_sequence_number       IGS_CA_INST.sequence_number%TYPE,
        p_attendance_type       IGS_EN_STDNT_PS_ATT.attendance_type%TYPE)
    RETURN VARCHAR2
    IS
    BEGIN   -- prgpl_match_att_type
        -- If the sprav.attendance_type is set, then the student must be enrolled
        -- in the appropriate attendance type within the progression period.
        -- Relationships to a load calendar are used to determine this.
    DECLARE
        cst_active  CONSTANT    VARCHAR2(10) := 'ACTIVE';
        cst_load    CONSTANT    VARCHAR2(10) := 'LOAD';
        cst_no_load CONSTANT    VARCHAR2(10) := 'NO-LOAD';
        v_sub_cal_type          IGS_CA_INST.cal_type%TYPE;
        v_sub_ci_sequence_number    IGS_CA_INST.sequence_number%TYPE;
        v_attendance_type       IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
        CURSOR c_cir IS
            SELECT  cir.sub_cal_type,
                cir.sub_ci_sequence_number
            FROM    IGS_CA_INST         ci,
                IGS_CA_INST_REL         cir,
                IGS_CA_TYPE         cat,
                IGS_CA_STAT         cs
            WHERE   cir.sup_cal_type        = p_prg_cal_type AND
                cir.sup_ci_sequence_number  = p_prg_sequence_number AND
                ci.cal_type         = cir.sub_cal_type AND
                ci.sequence_number      = cir.sub_ci_sequence_number AND
                cat.cal_type            = ci.cal_type AND
                cat.s_cal_cat           = cst_load AND
                cs.CAL_STATUS           = ci.CAL_STATUS AND
                cs.s_CAL_STATUS         = cst_active;
    BEGIN
        OPEN c_cir;
        FETCH c_cir INTO
                v_sub_cal_type,
                v_sub_ci_sequence_number;
        IF c_cir%NOTFOUND THEN
            CLOSE c_cir;
            -- No load calendar exists ; cannot check load so don't apply rule
            IF p_log_creation_dt IS NOT NULL THEN
                prgpl_ins_log_entry (
                        cst_no_load,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL);
            END IF;
            RETURN 'N';
        END IF;
        CLOSE c_cir;
        -- Call routine to derive the attendance type within the load calendar.
        v_attendance_type := IGS_EN_GEN_006.ENRP_GET_SCA_LATT (
                            p_person_id,
                            p_course_cd,
                            v_sub_cal_type,
                            v_sub_ci_sequence_number);
        IF v_attendance_type = p_attendance_type THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF c_cir%ISOPEN THEN
                CLOSE c_cir;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_MATCH_ATT_TYPE');
            IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END prgpl_match_att_type;

--------------------------------------------------------------------------------
    FUNCTION prgpl_match_class_standing (
                p_person_id                     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                p_course_cd                     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_prg_cal_type                  IGS_CA_INST.cal_type%TYPE,
                p_prg_sequence_number           IGS_CA_INST.sequence_number%TYPE,
                p_igs_pr_class_std_id           IGS_PR_CLASS_STD.igs_pr_class_std_id%TYPE)
    RETURN VARCHAR2  AS
    BEGIN   -- prgpl_match_class_standing
            -- If the sprav.igs_pr_class_std_id is set, then the student must be of
            -- the appropriate Class Standing type within the progression period.
            -- Relationships to a load calendar are used to determine this.
    DECLARE
      cst_active      CONSTANT        VARCHAR2(10) := 'ACTIVE';
      cst_load        CONSTANT        VARCHAR2(10) := 'LOAD';
      cst_no_load     CONSTANT        VARCHAR2(10) := 'NO-LOAD';
      v_sub_cal_type                  IGS_CA_INST.cal_type%TYPE;

      v_sub_ci_sequence_number        IGS_CA_INST.sequence_number%TYPE;
      v_attendance_type               IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
      v_class_standing                IGS_PR_CLASS_STD.CLASS_STANDING%TYPE;
      v_derived_class_standing        IGS_PR_CLASS_STD.CLASS_STANDING%TYPE;
      CURSOR c_cir IS
             SELECT  cir.sub_cal_type,
                     cir.sub_ci_sequence_number
             FROM    IGS_CA_INST                     ci,
                     IGS_CA_INST_REL                 cir,
                     IGS_CA_TYPE                     cat,
                     IGS_CA_STAT                     cs
             WHERE   cir.sup_cal_type                = p_prg_cal_type AND
                     cir.sup_ci_sequence_number      = p_prg_sequence_number AND
                     ci.cal_type                     = cir.sub_cal_type AND
                     ci.sequence_number              = cir.sub_ci_sequence_number AND
                     cat.cal_type                    = ci.cal_type AND
                     cat.s_cal_cat                   = cst_load AND
                     cs.CAL_STATUS                   = ci.CAL_STATUS AND
                     cs.s_CAL_STATUS                 = cst_active;

      CURSOR c_cstd IS
             SELECT  cstd.class_standing
             FROM    igs_pr_class_std  cstd
             WHERE   cstd.igs_pr_class_std_id   = p_igs_pr_class_std_id;

    BEGIN
      OPEN c_cir;
      FETCH c_cir INTO  v_sub_cal_type,
                        v_sub_ci_sequence_number;
      IF c_cir%NOTFOUND THEN
        CLOSE c_cir;
        -- No load calendar exists ; cannot check load so don't apply rule
        IF p_log_creation_dt IS NOT NULL THEN
          prgpl_ins_log_entry (
            cst_no_load,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL);
        END IF;
        RETURN 'N';
      END IF;
      CLOSE c_cir;
      -- Get Class Standing value

      OPEN c_cstd;
      FETCH c_cstd INTO v_class_standing;
      CLOSE c_cstd;

      -- Call routine to derive the class standing.
      -- NOTE: IGS_PR_GET_CLASS_STD.Get_Class_Standing is being built as part of
      -- DLD Class Standing
      v_derived_class_standing := IGS_PR_GET_CLASS_STD.Get_Class_Standing (
                                                        p_person_id,
                                                        p_course_cd,
                                                        'N',
                                                        NULL,
                                                        v_sub_cal_type,
                                                        v_sub_ci_sequence_number);
      IF v_class_standing = v_derived_class_standing THEN
        RETURN 'Y';
      ELSE
        RETURN 'N';
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF c_cir%ISOPEN THEN
          CLOSE c_cir;
        END IF;
        IF c_cstd%ISOPEN THEN
          CLOSE c_cstd;
        END IF;
        RAISE;
    END;

    EXCEPTION
      WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_MATCH_CLASS_STANDING');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END prgpl_match_class_standing;


    FUNCTION prgpl_match_cp_range (
                p_person_id                     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                p_course_cd                     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_prg_cal_type                  IGS_CA_INST.cal_type%TYPE,
                p_prg_sequence_number           IGS_CA_INST.sequence_number%TYPE,
                p_min_cp                        IGS_PR_RU_APPL.min_cp%TYPE,
                p_max_cp                        IGS_PR_RU_APPL.max_cp%TYPE)
    RETURN VARCHAR2 AS
    BEGIN   -- prgpl_match_cp_range
            -- If the sprav.min_cp and sprav.max_cp is set,
            -- then the student have an earned credit point figure within the
            -- credit point range as at progression period supplied.
            -- Relationships to a load calendar are used to determine this.
    DECLARE
      cst_active      CONSTANT        VARCHAR2(10) := 'ACTIVE';
      cst_load        CONSTANT        VARCHAR2(10) := 'LOAD';
      cst_no_load     CONSTANT        VARCHAR2(10) := 'NO-LOAD';
      v_sub_cal_type                  IGS_CA_INST.cal_type%TYPE;
      v_sub_ci_sequence_number        IGS_CA_INST.sequence_number%TYPE;
      v_attendance_type               IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
      v_earned_cp                     NUMBER;
      v_attempted_cp                  NUMBER;
      v_return_status                 VARCHAR2(1);
      v_msg_count                     NUMBER(2);
      v_msg_data                      VARCHAR2(2000);

      CURSOR c_cir IS
        SELECT  cir.sub_cal_type,
                cir.sub_ci_sequence_number
        FROM    IGS_CA_INST                     ci,
                IGS_CA_INST_REL                 cir,
                IGS_CA_TYPE                     cat,
                IGS_CA_STAT                     cs
        WHERE   cir.sup_cal_type                = p_prg_cal_type AND
                cir.sup_ci_sequence_number      = p_prg_sequence_number AND
                ci.cal_type                     = cir.sub_cal_type AND
                ci.sequence_number              = cir.sub_ci_sequence_number AND
                cat.cal_type                    = ci.cal_type AND
                cat.s_cal_cat                   = cst_load AND
                cs.CAL_STATUS                   = ci.CAL_STATUS AND
                cs.s_CAL_STATUS                 = cst_active;
      BEGIN
        OPEN c_cir;
        FETCH c_cir INTO v_sub_cal_type,
                         v_sub_ci_sequence_number;
        IF c_cir%NOTFOUND THEN
          CLOSE c_cir;
          -- No load calendar exists ; cannot check load so don't apply rule
          IF p_log_creation_dt IS NOT NULL THEN
            prgpl_ins_log_entry (
              cst_no_load,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL);
          END IF;

          RETURN 'N';
        END IF;

        CLOSE c_cir;
        -- Call routine to derive the attendance type within the load calendar.
        -- NOTE: IGS_PR_GET_CP_STATS is being built as part of
        -- DLD Academic Statistics and  GPA.
        IGS_PR_CP_GPA.GET_CP_STATS (
            p_person_id,
            p_course_cd,
            NULL, --stat_type
            v_sub_cal_type,
            v_sub_ci_sequence_number,
            NULL, -- system stat
            'Y', -- cumilative ind
            v_earned_cp,
            v_attempted_cp,
            FND_API.G_TRUE,
            v_return_status,
            v_msg_count,
            v_msg_data);

       IF v_earned_cp >= p_min_cp AND v_earned_cp <= p_max_cp THEN
         RETURN 'Y';
       ELSE
         RETURN 'N';
       END IF;

     EXCEPTION
       WHEN OTHERS THEN
         IF c_cir%ISOPEN THEN
           CLOSE c_cir;
         END IF;
         RAISE;

     END;

     EXCEPTION
       WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_MATCH_CP_RANGE');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END prgpl_match_cp_range;
---------------------------------------------------------------------------------

    FUNCTION prgpl_sca_apply_rules (
        p_sca_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE,
        p_progression_rule_cat      IGS_PR_RU_APPL.progression_rule_cat%TYPE,
        p_pra_sequence_number       IGS_PR_RU_APPL.sequence_number%TYPE,
        p_progression_rule_cd       IGS_PR_RU_APPL.progression_rule_cd%TYPE,
        p_rul_sequence_number       IGS_PR_RU_APPL.rul_sequence_number%TYPE,
        p_attendance_type           IGS_PR_RU_APPL.attendance_type%TYPE,
        p_reference_cd              IGS_PR_RU_APPL.reference_cd%TYPE,
        p_igs_pr_class_std_id       IGS_PR_CLASS_STD.IGS_PR_CLASS_STD_ID%TYPE,
        p_min_cp                    IGS_PR_RU_APPL.min_cp%TYPE,
        p_max_cp                    IGS_PR_RU_APPL.max_cp%TYPE
        )
    RETURN BOOLEAN
    IS
    BEGIN   -- prgpl_sca_apply_rules
    DECLARE
        v_rul_sequence_number       IGS_PR_RULE.rul_sequence_number%TYPE;
        v_alias_val         IGS_CA_DA_INST.absolute_val%TYPE;
        v_passed_ind            VARCHAR2(1);
        v_sprc_passed_ind       VARCHAR2(1);
        CURSOR c_pr (
            cp_progression_rule_cat         IGS_PR_RULE.progression_rule_cat%TYPE,
            cp_progression_rule_cd          IGS_PR_RULE.progression_rule_cd%TYPE) IS
            SELECT  pr.rul_sequence_number
            FROM    IGS_PR_RULE     pr
            WHERE   pr.progression_rule_cat     = cp_progression_rule_cat AND
                pr.progression_rule_cd      = cp_progression_rule_cd;
        CURSOR c_sprc (
            cp_progression_rule_cat         IGS_PR_SDT_PR_RU_CK.progression_rule_cat%TYPE,
            cp_pra_sequence_number          IGS_PR_SDT_PR_RU_CK.pra_sequence_number%TYPE) IS
            SELECT  sprc.passed_ind
            FROM    IGS_PR_SDT_PR_RU_CK     sprc
            WHERE   sprc.person_id          = p_person_id AND
                sprc.course_cd          = p_course_cd AND
                sprc.prg_cal_type       = p_prg_cal_type AND
                sprc.prg_ci_sequence_number = p_prg_sequence_number AND
                sprc.progression_rule_cat   = cp_progression_rule_cat AND
                sprc.pra_sequence_number    = cp_pra_sequence_number
            ORDER BY sprc.rule_check_dt DESC;   -- For latest record first
        v_decode_val1 VARCHAR2(2000);
        v_decode_val2 VARCHAR2(30);
    BEGIN
        v_rules_applicable := TRUE;
        -- If rule application specifies attendance type then check for match
        IF p_attendance_type IS NOT NULL THEN
            IF prgpl_match_att_type (
                        p_person_id,
                        p_course_cd,
                        p_prg_cal_type,
                        p_prg_sequence_number,
                        p_attendance_type) = 'N' THEN
                RETURN TRUE;
            END IF;
        END IF;

        -- if rule application specifies class standing then check for match
        IF p_igs_pr_class_std_id IS NOT NULL THEN
          IF prgpl_match_class_standing(
               p_person_id,
               p_course_cd,
               p_prg_cal_type,
               p_prg_sequence_number,
               p_igs_pr_class_std_id) = 'N' THEN
             RETURN TRUE;
          END IF;
        END IF;

        --if the rule application specifies a credit point range then check for match
        IF p_min_cp IS NOT NULL AND p_max_cp IS NOT NULL THEN
          IF prgpl_match_cp_range (
               p_person_id,
               p_course_cd,
               p_prg_cal_type,
               p_prg_sequence_number,
               p_min_cp,
               p_max_cp) = 'N' THEN
             RETURN TRUE;
          END IF;
        END IF;

        -- Determine the rule sequence number from either parameter or by joining to
        -- the standard rule
        IF p_rul_sequence_number IS NOT NULL THEN
            v_rul_sequence_number := p_rul_sequence_number;
        ELSE
            OPEN c_pr (
                p_progression_rule_cat,
                p_progression_rule_cd);
            FETCH c_pr INTO v_rul_sequence_number;
            IF c_pr%NOTFOUND THEN
                CLOSE c_pr;
                RETURN TRUE;
            END IF;
            CLOSE c_pr;
        END IF;
        -- Call rules engine to apply rules to student
        IF IGS_RU_GEN_005.rulp_val_sca_prg (
                v_rul_sequence_number,
                p_person_id,
                p_course_cd,
                p_sca_version_number,
                p_prg_cal_type,
                p_prg_sequence_number,
                v_message_text) THEN
            v_passed_ind := 'Y';
        ELSE
            v_passed_ind := 'N';
            v_all_rules_passed := FALSE;
        END IF;
        -- Check for change in rule state
        OPEN c_sprc (
                p_progression_rule_cat,
                p_pra_sequence_number);
        FETCH c_sprc INTO v_sprc_passed_ind;
        IF c_sprc%NOTFOUND THEN
            v_sprc_passed_ind := 'X';
        END IF;
        CLOSE c_sprc;
        IF v_sprc_passed_ind <> v_passed_ind THEN
            IF v_sprc_passed_ind <> 'X' THEN
                v_rules_altered := TRUE;
            END IF;
            v_sprc_insert_count := v_sprc_insert_count + 1;
            IF v_sprc_insert_count = 1 THEN
                /*INSERT INTO IGS_PR_STDNT_PR_CK (
                    person_id,
                    course_cd,
                    prg_cal_type,
                    prg_ci_sequence_number,
                    rule_check_dt,
                    s_prg_check_type)
                VALUES (
                    p_person_id,
                    p_course_cd,
                    p_prg_cal_type,
                    p_prg_sequence_number,
                    v_rule_check_dt,
                    DECODE(
                        p_application_type,
                        cst_initial,    cst_system,
                        cst_todo,       cst_todo,
                        cst_manual, cst_manual));*/
                        DECLARE
                          CURSOR c_decode IS
                            SELECT DECODE(
                              p_application_type,
                              cst_initial,  cst_system,
                              cst_todo,     cst_todo,
                              cst_manual,   cst_manual)FROM DUAL;

                        LV_ROWID VARCHAR2(25);
                        BEGIN
                          OPEN c_decode;
                          FETCH c_decode INTO v_decode_val2;
                          CLOSE c_decode;
                          IGS_PR_STDNT_PR_CK_PKG.INSERT_ROW (
                            X_ROWID =>LV_ROWID,
                            X_PERSON_ID =>p_person_id,
                            X_COURSE_CD =>p_course_cd,
                            X_PRG_CAL_TYPE =>p_prg_cal_type,
                            X_PRG_CI_SEQUENCE_NUMBER =>p_prg_sequence_number,
                            X_RULE_CHECK_DT =>v_rule_check_dt,
                            X_S_PRG_CHECK_TYPE =>v_decode_val2,
                            X_MODE =>'R'
                            );
                        END;
            END IF;

            DECLARE
              CURSOR c_decode2 IS
                SELECT  DECODE (
                  v_passed_ind,
                  'N',  v_message_text,
                  'Y',  NULL)FROM DUAL;

              lv_rowid VARCHAR2(25);
              l_org_id NUMBER(15);
            BEGIN
              OPEN c_decode2;
              FETCH c_decode2  INTO v_decode_val1;
              CLOSE c_decode2;
              l_org_id := igs_ge_gen_003.get_org_id;
              IGS_PR_SDT_PR_RU_CK_PKG.INSERT_ROW (
                X_ROWID => lv_rowid,
                x_PERSON_ID =>p_person_id,
                x_COURSE_CD =>p_course_cd,
                x_PRG_CAL_TYPE =>p_prg_cal_type,
                x_PRG_CI_SEQUENCE_NUMBER =>p_prg_sequence_number,
                x_RULE_CHECK_DT =>v_rule_check_dt,
                x_PROGRESSION_RULE_CAT =>p_progression_rule_cat,
                x_PRA_SEQUENCE_NUMBER =>p_pra_sequence_number,
                x_PASSED_IND =>v_passed_ind,
                x_rule_message_text => v_decode_val1,
                X_MODE => 'R',
                X_ORG_ID => l_org_id);
            END;

            IF p_application_type = cst_todo OR
                    p_application_type = cst_manual THEN
                IF v_sprc_passed_ind <> 'X' THEN
                    -- Check for timeframes for todo processing
                    IF v_passed_ind = 'Y' THEN
                        -- Check if beyond benefit cutoff date
                        v_alias_val := IGS_PR_GEN_005.IGS_PR_get_prg_dai (
                                    p_course_cd,
                                    p_sca_version_number,
                                    p_prg_cal_type,
                                    p_prg_sequence_number,
                                    cst_eb);
                        IF v_rule_check_dt > v_alias_val AND
                            v_sprc_passed_ind <> 'X' THEN
                            -- Beyond benefit cutoff date
                            IF p_log_creation_dt IS NOT NULL THEN
                                prgpl_ins_log_entry (
                                        cst_past_ben,
                                        p_progression_rule_cat,
                                        p_pra_sequence_number,
                                        NULL,
                                        p_progression_rule_cd,
                                        p_reference_cd,
                                        NULL,
                                        NULL);
                            END IF;
                            v_beyond_benefit := TRUE;
                        ELSE
                            IF NOT prgpl_rmv_stdnt_prg_outcomes (
                                        p_progression_rule_cat,
                                        p_pra_sequence_number,
                                        p_progression_rule_cd,
                                        p_reference_cd) THEN
                                v_rolled_back := TRUE;
                                RETURN FALSE;
                            END IF;
                            v_outcomes_removed := TRUE;
                        END IF;
                    ELSE
                        -- Check if beyond penalty cutoff date
                        v_alias_val := IGS_PR_GEN_005.IGS_PR_get_prg_dai (
                                    p_course_cd,
                                    p_sca_version_number,
                                    p_prg_cal_type,
                                    p_prg_sequence_number,
                                    cst_ep);
                        IF v_rule_check_dt > v_alias_val THEN
                            -- Beyond penalty cutoff date
                            IF p_log_creation_dt IS NOT NULL THEN
                                prgpl_ins_log_entry (
                                        cst_past_pen,
                                        p_progression_rule_cat,
                                        p_pra_sequence_number,
                                        NULL,
                                        p_progression_rule_cd,
                                        p_reference_cd,
                                        NULL,
                                        NULL);
                            END IF;
                            v_beyond_penalty := TRUE;
                        ELSE
                            prgpl_create_outcomes (
                                        p_sca_version_number,
                                        p_progression_rule_cat,
                                        p_pra_sequence_number,
                                        p_progression_rule_cd,
                                        p_reference_cd,
                                        v_rule_check_dt);
                        END IF;
                    END IF;
                ELSE
                    IF v_passed_ind = 'N' THEN
                        prgpl_create_outcomes (
                                p_sca_version_number,
                                p_progression_rule_cat,
                                p_pra_sequence_number,
                                p_progression_rule_cd,
                                p_reference_cd,
                                v_rule_check_dt);
                    END IF;
                END IF;
            ELSE
                -- If initial check and rule has been failed then create outcomes
                IF v_passed_ind = 'N' THEN
                    prgpl_create_outcomes (
                                p_sca_version_number,
                                p_progression_rule_cat,
                                p_pra_sequence_number,
                                p_progression_rule_cd,
                                p_reference_cd,
                                v_rule_check_dt);
                END IF;
            END IF;
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            IF c_pr%ISOPEN THEN
                CLOSE c_pr;
            END IF;
            IF c_sprc%ISOPEN THEN
                CLOSE c_sprc;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_SCA_APPLY_RULES');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
    END prgpl_sca_apply_rules;


    PROCEDURE prgpl_sca_process_rules (
        p_sca_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE,
        p_course_type           IGS_PS_VER.course_type%TYPE)
    IS
    BEGIN   -- prgpl_sca_process_rules
    DECLARE
        cst_sca     CONSTANT    VARCHAR2(10) := 'SCA';
        cst_crv     CONSTANT    VARCHAR2(10) := 'CRV';
        cst_ou      CONSTANT    VARCHAR2(10) := 'OU';
        cst_cty     CONSTANT    VARCHAR2(10) := 'CTY';
        cst_null    CONSTANT    VARCHAR2(10) := 'NULL';
        cst_start   CONSTANT    VARCHAR2(10) := 'START';
        cst_end     CONSTANT    VARCHAR2(10) := 'END';
        v_last_progression_cat  VARCHAR2(11);
        v_match_relation_type   IGS_PR_RU_APPL.s_relation_type%TYPE;
        v_process_cat           BOOLEAN;
        v_still_valid           BOOLEAN;
        v_dummy                 VARCHAR2(1);

        CURSOR c_ci (cp_prg_cal_type            IGS_CA_INST.cal_type%TYPE,
                     cp_prg_sequence_number     IGS_CA_INST.sequence_number%TYPE,
                     cp_start_sequence_number   IGS_CA_INST.sequence_number%TYPE,
                     cp_check_type              VARCHAR2) IS
                SELECT 'X'
                  FROM igs_ca_inst ci, igs_ca_inst ci1
                 WHERE ci.cal_type = cp_prg_cal_type
                   AND ci.sequence_number = cp_prg_sequence_number
                   AND ci1.cal_type = cp_prg_cal_type
                   AND ci1.sequence_number = cp_start_sequence_number
                   AND (   (cp_check_type = cst_start AND ci1.start_dt > ci.start_dt)
                        OR (cp_check_type = cst_end AND ci1.start_dt <= ci.start_dt)
                       );

        CURSOR c_progression_rule_cat(cp_cal_type IGS_CA_INST.cal_type%TYPE) IS
                SELECT pra.progression_rule_cat, pra.s_relation_type
                  FROM igs_pr_ru_appl pra, igs_pr_ru_ca_type_v prctv
                 WHERE pra.s_relation_type IN (cst_sca, cst_crv, cst_ou, cst_cty)
                   AND pra.progression_rule_cat = prctv.progression_rule_cat
                   AND pra.sequence_number = prctv.pra_sequence_number
                   AND prctv.prg_cal_type = cp_cal_type
                   AND pra.logical_delete_dt IS NULL
                  ORDER BY pra.progression_rule_cat,
                           DECODE (pra.s_relation_type,
        			   cst_sca, 1,
	        		   cst_crv, 2,
		        	   cst_ou,  3,
			           cst_cty, 4);



        CURSOR  c_pra_cst_sca (cp_prg_rule_cat     IGS_PR_RU_APPL.progression_rule_cat%TYPE,
                               cp_person_id        IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                               cp_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                               cp_cal_type         IGS_CA_INST.cal_type%TYPE) IS
                SELECT   pra.progression_rule_cat, pra.sequence_number, pra.s_relation_type,
                         pra.progression_rule_cd, pra.rul_sequence_number, pra.attendance_type,
                         pra.reference_cd, pra.igs_pr_class_std_id, pra.min_cp, pra.max_cp,
                         prctv.start_sequence_number, prctv.end_sequence_number,
                         prctv.start_effective_period, prctv.num_of_applications,
                         pra.sca_person_id, pra.sca_course_cd, pra.crv_course_cd,
                         pra.crv_version_number, pra.ou_org_unit_cd, pra.ou_start_dt,
                         pra.course_type
                    FROM igs_pr_ru_appl pra, igs_pr_ru_ca_type_v prctv
                   WHERE pra.s_relation_type = cst_sca
                          AND pra.progression_rule_cat = cp_prg_rule_cat
                          AND pra.logical_delete_dt IS NULL
                          AND pra.sca_person_id = cp_person_id
                          AND pra.sca_course_cd = cp_course_cd
                          AND pra.progression_rule_cat = prctv.progression_rule_cat
                          AND pra.sequence_number = prctv.pra_sequence_number
                          AND prctv.prg_cal_type = cp_cal_type;

        CURSOR  c_pra_cst_crv (cp_prg_rule_cat     IGS_PR_RU_APPL.progression_rule_cat%TYPE,
                               cp_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                               cp_version_number   IGS_PR_RU_APPL.crv_version_number%TYPE,
                               cp_cal_type         IGS_CA_INST.cal_type%TYPE) IS
                SELECT   pra.progression_rule_cat, pra.sequence_number, pra.s_relation_type,
                         pra.progression_rule_cd, pra.rul_sequence_number, pra.attendance_type,
                         pra.reference_cd, pra.igs_pr_class_std_id, pra.min_cp, pra.max_cp,
                         prctv.start_sequence_number, prctv.end_sequence_number,
                         prctv.start_effective_period, prctv.num_of_applications,
                         pra.sca_person_id, pra.sca_course_cd, pra.crv_course_cd,
                         pra.crv_version_number, pra.ou_org_unit_cd, pra.ou_start_dt,
                         pra.course_type
                    FROM igs_pr_ru_appl pra, igs_pr_ru_ca_type_v prctv
                    WHERE pra.s_relation_type = cst_crv
                          AND pra.progression_rule_cat = cp_prg_rule_cat
                          AND pra.logical_delete_dt IS NULL
                          AND pra.crv_course_cd = cp_course_cd
                          AND pra.crv_version_number = cp_version_number
                          AND pra.progression_rule_cat = prctv.progression_rule_cat
                          AND pra.sequence_number = prctv.pra_sequence_number
                          AND prctv.prg_cal_type = cp_cal_type;

        CURSOR  c_pra_cst_ou (cp_prg_rule_cat     IGS_PR_RU_APPL.progression_rule_cat%TYPE,
                              cp_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                              cp_version_number   IGS_PR_RU_APPL.crv_version_number%TYPE,
                              cp_cal_type     IGS_CA_INST.cal_type%TYPE) IS
                SELECT   pra.progression_rule_cat, pra.sequence_number, pra.s_relation_type,
                         pra.progression_rule_cd, pra.rul_sequence_number, pra.attendance_type,
                         pra.reference_cd, pra.igs_pr_class_std_id, pra.min_cp, pra.max_cp,
                         prctv.start_sequence_number, prctv.end_sequence_number,
                         prctv.start_effective_period, prctv.num_of_applications,
                         pra.sca_person_id, pra.sca_course_cd, pra.crv_course_cd,
                         pra.crv_version_number, pra.ou_org_unit_cd, pra.ou_start_dt,
                         pra.course_type
                    FROM igs_pr_ru_appl pra, igs_pr_ru_ca_type_v prctv
                    WHERE pra.s_relation_type = cst_ou
                          AND pra.progression_rule_cat = cp_prg_rule_cat
                          AND pra.logical_delete_dt IS NULL
                          AND igs_pr_gen_001.prgp_get_crv_cmt (
                                 cp_course_cd,
                                 cp_version_number,
                                 pra.ou_org_unit_cd,
                                 pra.ou_start_dt
                              ) = 'Y'
                          AND pra.progression_rule_cat = prctv.progression_rule_cat
                          AND pra.sequence_number = prctv.pra_sequence_number
                          AND prctv.prg_cal_type = cp_cal_type
                          AND (   EXISTS ( SELECT 'x'
                                             FROM igs_ps_own cow
                                            WHERE cow.course_cd = cp_course_cd
                                              AND cow.version_number = cp_version_number
                                              AND cow.percentage = 100)
                               OR NOT EXISTS ( SELECT 'x'
                                                 FROM igs_pr_ru_appl pra1,
                                                      igs_pr_ru_ca_type_v prctv1
                                                WHERE pra1.s_relation_type = 'OU'
                                                  AND pra1.logical_delete_dt IS NULL
                                                  AND pra1.progression_rule_cat =
                                                                      pra.progression_rule_cat
                                                  AND pra1.sequence_number <>
                                                                           pra.sequence_number
                                                  AND (   pra1.ou_org_unit_cd <>
                                                                            pra.ou_org_unit_cd
                                                       OR pra1.ou_start_dt <> pra.ou_start_dt
                                                      )
                                                  AND prctv1.progression_rule_cat =
                                                                     pra1.progression_rule_cat
                                                  AND prctv1.pra_sequence_number =
                                                                          pra1.sequence_number
                                                  AND prctv1.prg_cal_type = prctv.prg_cal_type)
                               OR EXISTS (
                                        SELECT 'x'
                                          FROM igs_ps_ver crv1
                                         WHERE crv1.course_cd = cp_course_cd
                                           AND crv1.version_number = cp_version_number
                                           AND (   (    crv1.responsible_org_unit_cd =
                                                                            pra.ou_org_unit_cd
                                                    AND crv1.responsible_ou_start_dt =
                                                                               pra.ou_start_dt
                                                   )
                                                OR igs_or_gen_001.orgp_get_within_ou (
                                                      pra.ou_org_unit_cd,
                                                      pra.ou_start_dt,
                                                      crv1.responsible_org_unit_cd,
                                                      crv1.responsible_ou_start_dt,
                                                      'N'
                                                   ) = 'Y'
                                               ))
                              );

        CURSOR  c_pra_cst_cty (cp_prg_rule_cat     IGS_PR_RU_APPL.progression_rule_cat%TYPE,
                               cp_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                               cp_version_number   IGS_PR_RU_APPL.crv_version_number%TYPE,
                               cp_cal_type         IGS_CA_INST.cal_type%TYPE) IS
                SELECT   pra.progression_rule_cat, pra.sequence_number, pra.s_relation_type,
                         pra.progression_rule_cd, pra.rul_sequence_number, pra.attendance_type,
                         pra.reference_cd, pra.igs_pr_class_std_id, pra.min_cp, pra.max_cp,
                         prctv.start_sequence_number, prctv.end_sequence_number,
                         prctv.start_effective_period, prctv.num_of_applications,
                         pra.sca_person_id, pra.sca_course_cd, pra.crv_course_cd,
                         pra.crv_version_number, pra.ou_org_unit_cd, pra.ou_start_dt,
                         pra.course_type
                    FROM igs_pr_ru_appl pra, igs_pr_ru_ca_type_v prctv, igs_ps_ver crv
                    WHERE pra.s_relation_type = cst_cty
                          AND pra.progression_rule_cat = cp_prg_rule_cat
                          AND pra.logical_delete_dt IS NULL
                          AND crv.course_type = pra.course_type
                          AND crv.course_cd = cp_course_cd
                          AND crv.version_number = cp_version_number
                          AND pra.progression_rule_cat = prctv.progression_rule_cat
                          AND pra.sequence_number = prctv.pra_sequence_number
                          AND prctv.prg_cal_type = cp_cal_type;

        v_pra_rec c_pra_cst_cty%ROWTYPE;

    BEGIN
        v_last_progression_cat := 'ABCDEFGHIJK';
        FOR v_progression_rule_cat IN c_progression_rule_cat (p_prg_cal_type) LOOP
            /*
            The loop will return all the progression_rule_cat and s_relation_type.
            If a rule is valid and gets applied then no more processing for that progression_rule_cat.
            The hierarchy of application is SCA, CRY, OU and CTY.
            */

            v_still_valid := TRUE;
            /*
            v_still_valid is used to check if the v_progression_rule_cat.progression_rule_cat and
            v_progression_rule_cat.s_relation_type combination is valid or not.
            This flag determines if it shall be applied or not.
            */
            IF v_progression_rule_cat.progression_rule_cat <> v_last_progression_cat THEN

                IF v_progression_rule_cat.s_relation_type = cst_sca THEN
                        OPEN c_pra_cst_sca (v_progression_rule_cat.progression_rule_cat,
                                            p_person_id,
                                            p_course_cd,
                                            p_prg_cal_type);
                        FETCH c_pra_cst_sca INTO v_pra_rec;
                        IF c_pra_cst_sca%NOTFOUND THEN
                        --No such rule defined at the SCA level for this person+course combination
                        --so this progression_rule_cat cannot be applied
                                v_still_valid := FALSE;
                        END IF;
                        CLOSE c_pra_cst_sca;
                        -- Ignore records where haven't yet reached the START calendar.
                        IF v_still_valid AND
                           v_pra_rec.start_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.start_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.start_sequence_number,
                                           cst_start);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                --Start calender not yet reached, so this progression_rule_cat cannot be applied
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Ignore records where haven't yet reached the end calendar.
                        IF v_still_valid AND v_pra_rec.end_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.end_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.end_sequence_number,
                                           cst_end);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                --End calender failed, so this progression_rule_cat cannot be applied
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Check that student complies with effective period and number of
                        -- applications options where applicable.
                        IF v_still_valid AND (v_pra_rec.start_effective_period IS NOT NULL
                            OR v_pra_rec.num_of_applications IS NOT NULL) THEN
                            IF IGS_PR_GEN_005.igs_pr_get_sca_appl (
                                    p_person_id,
                                    p_course_cd,
                                    p_sca_version_number,
                                    p_course_type,
                                    v_pra_rec.progression_rule_cat,
                                    v_pra_rec.sequence_number,
                                    p_prg_cal_type,
                                    p_prg_sequence_number,
                                    v_pra_rec.start_effective_period,
                                    v_pra_rec.num_of_applications,
                                    v_pra_rec.s_relation_type,
                                    v_pra_rec.sca_person_id,
                                    v_pra_rec.sca_course_cd,
                                    v_pra_rec.crv_course_cd,
                                    v_pra_rec.crv_version_number,
                                    v_pra_rec.ou_org_unit_cd,
                                    v_pra_rec.ou_start_dt,
                                    v_pra_rec.course_type) = 'N' THEN
                        -- student does not comply with effective period and number of
                        -- applications options where applicable.
                        -- so this progression_rule_cat cannot be applied
                                v_still_valid := FALSE;
                            END IF;
                        END IF;
                        /*IF v_still_valid IS TRUE then this rule is valid and can be applied*/
                        IF v_still_valid THEN
                              IF NOT prgpl_sca_apply_rules (p_sca_version_number,
                                                            v_pra_rec.progression_rule_cat,
                                                            v_pra_rec.sequence_number,
                                                            v_pra_rec.progression_rule_cd,
                                                            v_pra_rec.rul_sequence_number,
                                                            v_pra_rec.attendance_type,
                                                            v_pra_rec.reference_cd,
                                                            v_pra_rec.igs_pr_class_std_id,
                                                            v_pra_rec.min_cp,
                                                            v_pra_rec.max_cp) THEN
                                       -- Changes rolled back
                                       EXIT;
                                ELSE
                                       /*This progression_rule_cat was successfully applied.
                                         By setting v_last_progression_cat, we prevent the application
                                         of this progression_rule_cat in other s_relation_type
                                       */
                                       v_last_progression_cat := v_progression_rule_cat.progression_rule_cat;
                                END IF;
                        END IF;

                ELSIF v_progression_rule_cat.s_relation_type = cst_crv THEN
                        OPEN c_pra_cst_crv (v_progression_rule_cat.progression_rule_cat,
                                            p_course_cd,
                                            p_sca_version_number,
                                            p_prg_cal_type);
                        FETCH c_pra_cst_crv INTO v_pra_rec;
                        IF c_pra_cst_crv%NOTFOUND THEN
                                v_still_valid := FALSE;
                        END IF;
                        CLOSE c_pra_cst_crv;
                        -- Ignore records where haven't yet reached the START calendar.
                        IF v_still_valid AND
                           v_pra_rec.start_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.start_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.start_sequence_number,
                                           cst_start);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Ignore records where haven't yet reached the end calendar.
                        IF v_still_valid AND v_pra_rec.end_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.end_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.end_sequence_number,
                                           cst_end);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Check that student complies with effective period and number of
                        -- applications options where applicable.
                        IF v_still_valid AND (v_pra_rec.start_effective_period IS NOT NULL
                            OR v_pra_rec.num_of_applications IS NOT NULL) THEN
                            IF IGS_PR_GEN_005.igs_pr_get_sca_appl (
                                    p_person_id,
                                    p_course_cd,
                                    p_sca_version_number,
                                    p_course_type,
                                    v_pra_rec.progression_rule_cat,
                                    v_pra_rec.sequence_number,
                                    p_prg_cal_type,
                                    p_prg_sequence_number,
                                    v_pra_rec.start_effective_period,
                                    v_pra_rec.num_of_applications,
                                    v_pra_rec.s_relation_type,
                                    v_pra_rec.sca_person_id,
                                    v_pra_rec.sca_course_cd,
                                    v_pra_rec.crv_course_cd,
                                    v_pra_rec.crv_version_number,
                                    v_pra_rec.ou_org_unit_cd,
                                    v_pra_rec.ou_start_dt,
                                    v_pra_rec.course_type) = 'N' THEN
                                v_still_valid := FALSE;
                            END IF;
                        END IF;
                        IF v_still_valid THEN
                              IF NOT prgpl_sca_apply_rules (p_sca_version_number,
                                                            v_pra_rec.progression_rule_cat,
                                                            v_pra_rec.sequence_number,
                                                            v_pra_rec.progression_rule_cd,
                                                            v_pra_rec.rul_sequence_number,
                                                            v_pra_rec.attendance_type,
                                                            v_pra_rec.reference_cd,
                                                            v_pra_rec.igs_pr_class_std_id,
                                                            v_pra_rec.min_cp,
                                                            v_pra_rec.max_cp) THEN
                                       -- Changes rolled back
                                       EXIT;
                                ELSE
                                       v_last_progression_cat := v_progression_rule_cat.progression_rule_cat;
                                END IF;
                        END IF;

                ELSIF v_progression_rule_cat.s_relation_type = cst_ou THEN
                        OPEN c_pra_cst_ou (v_progression_rule_cat.progression_rule_cat,
                                            p_course_cd,
                                            p_sca_version_number,
                                            p_prg_cal_type);
                        FETCH c_pra_cst_ou INTO v_pra_rec;
                        IF c_pra_cst_ou%NOTFOUND THEN
                                v_still_valid := FALSE;
                        END IF;
                        CLOSE c_pra_cst_ou;
                        -- Ignore records where haven't yet reached the START calendar.
                        IF v_still_valid AND
                           v_pra_rec.start_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.start_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.start_sequence_number,
                                           cst_start);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Ignore records where haven't yet reached the end calendar.
                        IF v_still_valid AND v_pra_rec.end_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.end_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.end_sequence_number,
                                           cst_end);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Check that student complies with effective period and number of
                        -- applications options where applicable.
                        IF v_still_valid AND (v_pra_rec.start_effective_period IS NOT NULL
                            OR v_pra_rec.num_of_applications IS NOT NULL) THEN
                            IF IGS_PR_GEN_005.igs_pr_get_sca_appl (
                                    p_person_id,
                                    p_course_cd,
                                    p_sca_version_number,
                                    p_course_type,
                                    v_pra_rec.progression_rule_cat,
                                    v_pra_rec.sequence_number,
                                    p_prg_cal_type,
                                    p_prg_sequence_number,
                                    v_pra_rec.start_effective_period,
                                    v_pra_rec.num_of_applications,
                                    v_pra_rec.s_relation_type,
                                    v_pra_rec.sca_person_id,
                                    v_pra_rec.sca_course_cd,
                                    v_pra_rec.crv_course_cd,
                                    v_pra_rec.crv_version_number,
                                    v_pra_rec.ou_org_unit_cd,
                                    v_pra_rec.ou_start_dt,
                                    v_pra_rec.course_type) = 'N' THEN
                                v_still_valid := FALSE;
                            END IF;
                        END IF;
                        IF v_still_valid THEN
                              IF NOT prgpl_sca_apply_rules (p_sca_version_number,
                                                            v_pra_rec.progression_rule_cat,
                                                            v_pra_rec.sequence_number,
                                                            v_pra_rec.progression_rule_cd,
                                                            v_pra_rec.rul_sequence_number,
                                                            v_pra_rec.attendance_type,
                                                            v_pra_rec.reference_cd,
                                                            v_pra_rec.igs_pr_class_std_id,
                                                            v_pra_rec.min_cp,
                                                            v_pra_rec.max_cp) THEN
                                       -- Changes rolled back
                                       EXIT;
                                ELSE
                                       v_last_progression_cat := v_progression_rule_cat.progression_rule_cat;
                                END IF;
                        END IF;

                ELSIF v_progression_rule_cat.s_relation_type = cst_cty THEN
                        OPEN c_pra_cst_cty (v_progression_rule_cat.progression_rule_cat,
                                            p_course_cd,
                                            p_sca_version_number,
                                            p_prg_cal_type);
                        FETCH c_pra_cst_cty INTO v_pra_rec;
                        IF c_pra_cst_cty%NOTFOUND THEN
                                v_still_valid := FALSE;
                        END IF;
                        CLOSE c_pra_cst_cty;
                        -- Ignore records where haven't yet reached the START calendar.
                        IF v_still_valid AND
                           v_pra_rec.start_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.start_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.start_sequence_number,
                                           cst_start);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Ignore records where haven't yet reached the end calendar.
                        IF v_still_valid AND v_pra_rec.end_sequence_number IS NOT NULL THEN
                            IF p_prg_sequence_number <> v_pra_rec.end_sequence_number THEN
                                OPEN c_ci (p_prg_cal_type,
                                           p_prg_sequence_number,
                                           v_pra_rec.end_sequence_number,
                                           cst_end);
                                FETCH c_ci INTO v_dummy;
                                IF c_ci%NOTFOUND THEN
                                        v_still_valid := FALSE;
                                END IF;
                                CLOSE c_ci;
                            END IF;
                        END IF;
                        -- Check that student complies with effective period and number of
                        -- applications options where applicable.
                        IF v_still_valid AND (v_pra_rec.start_effective_period IS NOT NULL
                            OR v_pra_rec.num_of_applications IS NOT NULL) THEN
                            IF IGS_PR_GEN_005.igs_pr_get_sca_appl (
                                    p_person_id,
                                    p_course_cd,
                                    p_sca_version_number,
                                    p_course_type,
                                    v_pra_rec.progression_rule_cat,
                                    v_pra_rec.sequence_number,
                                    p_prg_cal_type,
                                    p_prg_sequence_number,
                                    v_pra_rec.start_effective_period,
                                    v_pra_rec.num_of_applications,
                                    v_pra_rec.s_relation_type,
                                    v_pra_rec.sca_person_id,
                                    v_pra_rec.sca_course_cd,
                                    v_pra_rec.crv_course_cd,
                                    v_pra_rec.crv_version_number,
                                    v_pra_rec.ou_org_unit_cd,
                                    v_pra_rec.ou_start_dt,
                                    v_pra_rec.course_type) = 'N' THEN
                                v_still_valid := FALSE;
                            END IF;
                        END IF;
                        IF v_still_valid THEN
                              IF NOT prgpl_sca_apply_rules (p_sca_version_number,
                                                            v_pra_rec.progression_rule_cat,
                                                            v_pra_rec.sequence_number,
                                                            v_pra_rec.progression_rule_cd,
                                                            v_pra_rec.rul_sequence_number,
                                                            v_pra_rec.attendance_type,
                                                            v_pra_rec.reference_cd,
                                                            v_pra_rec.igs_pr_class_std_id,
                                                            v_pra_rec.min_cp,
                                                            v_pra_rec.max_cp) THEN
                                       -- Changes rolled back
                                       EXIT;
                                ELSE
                                       v_last_progression_cat := v_progression_rule_cat.progression_rule_cat;
                                END IF;
                        END IF;

                END IF;

            END IF;
        END LOOP;
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            IF c_progression_rule_cat%ISOPEN THEN
                CLOSE c_progression_rule_cat ;
            END IF;
            IF c_pra_cst_crv%ISOPEN THEN
                CLOSE c_pra_cst_crv ;
            END IF;
            IF c_pra_cst_cty%ISOPEN THEN
                CLOSE c_pra_cst_cty;
            END IF;
            IF c_pra_cst_ou%ISOPEN THEN
                CLOSE c_pra_cst_ou;
            END IF;
            IF c_pra_cst_sca%ISOPEN THEN
                CLOSE c_pra_cst_sca;
            END IF;
            IF c_ci%ISOPEN THEN
                CLOSE c_ci;
            END IF;
            RAISE;
    END;
    EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY.PRGPL_SCA_PROCESS_RULES');
             IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
    END prgpl_sca_process_rules;
  BEGIN
    -- Set the default values for the out NOCOPY parameters
    -- these values will be incremented when the outocomes
    -- are created in the local procedures
    p_recommended_outcomes := 0;
    p_approved_outcomes    := 0;
    p_removed_outcomes     := 0;
    -- Set the default message number
    p_message_name         := NULL;

    SAVEPOINT sp_before_rule_apply;
    -- Load student course attempt version number and course type
    OPEN c_sca_crv;
    FETCH c_sca_crv INTO
            v_course_attempt_status,
            v_sca_version_number,
            v_course_type;
    IF c_sca_crv%NOTFOUND THEN
        CLOSE c_sca_crv;
        RETURN;
    END IF;
    CLOSE c_sca_crv;
    -- If manual application then ensure that appropriate timelines and state of
    -- person are correct. If not, reject the application of the rules.
    IF p_application_type = cst_manual THEN
        IF v_course_attempt_status = cst_completed THEN
            p_message_name := 'IGS_PR_CNT_APRRU_CMCR_ATT';
            RETURN;
        ELSIF v_course_attempt_status = cst_unconfirm THEN
            p_message_name := 'IGS_PR_CNT_AP_PRRU_UCON_CRAT';
            RETURN;
        END IF;
        v_start_dt := IGS_PR_GEN_005.IGS_PR_get_prg_dai (
                        p_course_cd,
                        v_sca_version_number,
                        p_prg_cal_type,
                        p_prg_sequence_number,
                        cst_sa);
        -- If not reached the application start date then reject manual application.
        IF v_start_dt IS NULL OR
                v_start_dt > TRUNC(SYSDATE) THEN
            p_message_name := 'IGS_PR_UNPE_MRC_STAP_DT_PCAL';
            RETURN;
        END IF;
        IGS_PR_GEN_003.IGS_PR_get_config_parm (
                    p_course_cd,
                    v_sca_version_number,
                    v_apply_start_dt_alias,
                    v_apply_end_dt_alias,
                    v_end_benefit_dt_alias,
                    v_end_penalty_dt_alias,
                    v_show_cause_cutoff_dt_alias,
                    v_appeal_cutoff_dt_alias,
                    v_show_cause_ind,
                    v_apply_before_show_ind,
                    v_appeal_ind,
                    v_apply_before_appeal_ind,
                    v_count_sus_in_time_ind,
                    v_count_exc_in_time_ind,
                    v_calculate_wam_ind,
                    v_calculate_gpa_ind,
                    v_outcome_check_type);
        -- Check the state of the students enrolment against the configuration
        -- options.
        v_result_status := IGS_PR_GEN_005.IGS_PR_get_sca_state (
                            p_person_id,
                            p_course_cd,
                            p_prg_cal_type,
                            p_prg_sequence_number);
        IF v_result_status = cst_none THEN
            p_message_name := 'IGS_PR_CNTAP_MRCK_NAP_UNEX_PRD';
            RETURN;
        ELSIF v_result_status = cst_missing THEN
            -- If the outcome check type is not missing then exclude from checking.
            IF v_outcome_check_type <> cst_missing THEN
                p_message_name := 'IGS_PR_CNT_APMAN_RCK_ROH_SUB';
                RETURN;
            END IF;
        ELSIF v_result_status =  cst_recommend THEN
            -- If the outcome type is finalised (ie. ignoring recommended) then exclude.
            IF v_outcome_check_type = cst_finalised THEN
                p_message_name := 'IGS_PR_CNT_APMAN_RCK_ROH_SUB';
                RETURN;
            END IF;
        END IF;
    END IF;
    -- Call routine to insert progression measures (eg. GPA/WAM) into measures
    -- table
    IGS_PR_GEN_003.IGS_PR_ins_prg_msr (
            p_person_id,
            p_course_cd,
            v_sca_version_number,
            p_prg_cal_type,
            p_prg_sequence_number);
    -- Process student course attempt
    prgpl_sca_process_rules (
                v_sca_version_number,
                v_course_type);
    IF p_log_creation_dt IS NOT NULL AND
            v_rules_applicable AND
            v_all_rules_passed THEN
        prgpl_ins_log_entry (
                cst_passed,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL);
    ELSIF p_log_creation_dt IS NOT NULL AND
            v_rules_applicable AND
        (
            NOT v_rec_outcomes_applied AND
            NOT v_auto_outcomes_applied AND
            NOT v_beyond_penalty AND
            NOT v_beyond_benefit AND
            NOT v_outcomes_removed
        ) THEN
        prgpl_ins_log_entry (
                cst_nochange,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL);
    END IF;
    -- If procedure is called from a form then set the message number and commit
    -- changes
    IF p_log_creation_dt IS NULL AND
            NOT v_rolled_back THEN
        IF NOT v_rules_applicable THEN
            -- NO RULES WERE TESTED.
            -- 5229: No rules applicable to the student.
            p_message_name := 'IGS_PR_NORU_APP_TO_SDTNT';
        ELSIF v_all_rules_passed THEN
            -- RULE(S) TESTED ; NO FAILURES.
            IF v_outcomes_removed THEN
                -- Rules now passed. Outcomes have been removed.
                p_message_name := 'IGS_PR_RUPA_OUT_HRED';
            ELSIF v_beyond_benefit THEN
                -- Rules now passed. No outcomes were lifted due to being beyond benefit
                -- cutoff date.
                p_message_name := 'IGS_PR_RUNPD_NOUT_BECUT_DT';
            ELSE
                -- Rules were tested. All rules were passed.
                p_message_name := 'IGS_PR_RU_TE_ALL_RE_PAS';
            END IF;
        ELSE
            -- RULE(S) TESTED ; AT LEAST ONE FAILURE.
            IF v_beyond_penalty THEN
                -- Rules were tested. No outcomes were applied due to being beyond penalty
                -- cutoff date.
                p_message_name := 'IGS_PR_RUTE_NOOU_PECU_DT';
            ELSIF v_beyond_benefit THEN
                -- Rules were tested. No outcomes were lifted due to being beyond benefit
                -- cutoff date.
                p_message_name := 'IGS_PR_RUTE_NOLF_BENCT_DT';
            ELSIF v_auto_outcomes_applied THEN
                -- Rules were tested. Rules(s) were failed and outcomes automatically
                -- applied.
                p_message_name := 'IGS_PR_RUTE_RUFA_OUT_AUAP';
            ELSIF v_rec_outcomes_applied THEN
                -- Rules were tested. Rule(s) were failed and recommended outcomes have been
                -- added.
                p_message_name :='IGS_PR_RU_TE_RFA_OTCM_ADD';
            ELSIF v_outcomes_removed THEN
                -- Rules now passed. Outcomes have been removed.
                p_message_name := 'IGS_PR_RUPA_OUT_HRED';
            ELSIF NOT v_rules_altered THEN
                -- Rules were tested. No changes made to outcomes as results are the same.
                p_message_name := 'IGS_PR_RUTE_NCHMA_REA_SAM';
            ELSE
                -- Rules were tested. No progression outcomes were added/altered.
                p_message_name := 'IGS_PR_RUTE_NOPR_OUTAD_AL';
            END IF;
        END IF;
        COMMIT;
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
        IF c_sca_crv%ISOPEN THEN
            CLOSE c_sca_crv;
        END IF;
        RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SCA_APPLY');
             IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
  END IGS_PR_upd_sca_apply;


  PROCEDURE IGS_PR_upd_spo_aply_dt(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_sequence_number IN NUMBER )
  IS
    gv_other_detail         VARCHAR2(255);
  BEGIN     -- IGS_PR_upd_spo_aply_dt
    -- Reset the applied_dt of a student progression outcome record to
    -- 01/01/0001 after any related records are changed if the record
    -- is approved. This identifies the record for automatic processing.
  DECLARE
    e_record_locked         EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    cst_approved    CONSTANT    VARCHAR2(10) := 'APPROVED';
    cst_applied_dt  CONSTANT    DATE := igs_ge_date.igsdate('0001/01/01');
    v_decision_status       IGS_PR_STDNT_PR_OU.decision_status%TYPE;
    CURSOR  c_spo_upd  IS
            SELECT  spo.*, spo.ROWID
            FROM    IGS_PR_STDNT_PR_OU spo
            WHERE   person_id       = p_person_id AND
                    course_cd       = p_course_cd AND
                    sequence_number = p_sequence_number
    FOR UPDATE NOWAIT;

    v_spo_upd_rec c_spo_upd%ROWTYPE;

  BEGIN
    -- Reset the applied date to 01/01/0001 if the parent
    -- student progression outcome record is approved.
    BEGIN
        OPEN c_spo_upd;
        FETCH c_spo_upd INTO v_spo_upd_rec;
        IF v_spo_upd_rec.decision_status = cst_approved THEN
/*
            UPDATE  IGS_PR_STDNT_PR_OU
            SET applied_dt = cst_applied_dt
            WHERE CURRENT OF c_spo_upd;
*/
            igs_pr_stdnt_pr_ou_pkg.update_row(
               x_rowid                         => v_spo_upd_rec.ROWID,
               x_person_id                     => v_spo_upd_rec.person_id,
               x_course_cd                     => v_spo_upd_rec.course_cd,
               x_sequence_number               => v_spo_upd_rec.sequence_number,
               x_prg_cal_type                  => v_spo_upd_rec.prg_cal_type,
               x_prg_ci_sequence_number        => v_spo_upd_rec.prg_ci_sequence_number,
               x_rule_check_dt                 => v_spo_upd_rec.rule_check_dt,
               x_progression_rule_cat          => v_spo_upd_rec.progression_rule_cat,
               x_pra_sequence_number           => v_spo_upd_rec.pra_sequence_number,
               x_pro_sequence_number           => v_spo_upd_rec.pro_sequence_number,
               x_progression_outcome_type      => v_spo_upd_rec.progression_outcome_type,
               x_duration                      => v_spo_upd_rec.duration,
               x_duration_type                 => v_spo_upd_rec.duration_type,
               x_decision_status               => v_spo_upd_rec.decision_status,
               x_decision_dt                   => v_spo_upd_rec.decision_dt,
               x_decision_org_unit_cd          => v_spo_upd_rec.decision_org_unit_cd,
               x_decision_ou_start_dt          => v_spo_upd_rec.decision_ou_start_dt,
               x_applied_dt                    => cst_applied_dt,
               x_show_cause_expiry_dt          => v_spo_upd_rec.show_cause_expiry_dt,
               x_show_cause_dt                 => v_spo_upd_rec.show_cause_dt,
               x_show_cause_outcome_dt         => v_spo_upd_rec.show_cause_outcome_dt,
               x_show_cause_outcome_type       => v_spo_upd_rec.show_cause_outcome_type,
               x_appeal_expiry_dt              => v_spo_upd_rec.appeal_expiry_dt,
               x_appeal_dt                     => v_spo_upd_rec.appeal_dt,
               x_appeal_outcome_dt             => v_spo_upd_rec.appeal_outcome_dt,
               x_appeal_outcome_type           => v_spo_upd_rec.appeal_outcome_type,
               x_encmb_course_group_cd         => v_spo_upd_rec.encmb_course_group_cd,
               x_restricted_enrolment_cp       => v_spo_upd_rec.restricted_enrolment_cp,
               x_restricted_attendance_type    => v_spo_upd_rec.restricted_attendance_type,
               x_comments                      => v_spo_upd_rec.comments,
               x_show_cause_comments           => v_spo_upd_rec.show_cause_comments,
               x_appeal_comments               => v_spo_upd_rec.appeal_comments,
               x_expiry_dt                     => v_spo_upd_rec.expiry_dt,
               x_pro_pra_sequence_number       => v_spo_upd_rec.pro_pra_sequence_number,
               x_mode                          => 'R'
             );

        END IF;
        CLOSE c_spo_upd;
    EXCEPTION
        WHEN e_record_locked THEN
            IF c_spo_upd%ISOPEN THEN
                CLOSE c_spo_upd;
            END IF;
        WHEN OTHERS THEN
            RAISE;
    END;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
        IF c_spo_upd%ISOPEN THEN
            CLOSE c_spo_upd;
        END IF;
        RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SPO_APLY_DT');
            IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
  END IGS_PR_upd_spo_aply_dt;
  PROCEDURE IGS_PR_upd_spo_maint
  (
   errbuf  OUT NOCOPY VARCHAR2,
   retcode OUT NOCOPY NUMBER
   )
  IS
    gv_other_detail         VARCHAR2(255);
  BEGIN     -- IGS_PR_upd_spo_maint
    -- Update the progression status of a IGS_EN_STDNT_PS_ATT when elements of
    -- progression no longer reflect the status. eg. A penalty has expired, a
    -- show cause period has expired.
  DECLARE
    cst_approved    CONSTANT    VARCHAR2(10) := 'APPROVED';
    cst_probation   CONSTANT    VARCHAR2(10) := 'PROBATION';
    cst_exclusion   CONSTANT    VARCHAR2(10) := 'EXCLUSION';
    cst_expired CONSTANT    VARCHAR2(10) := 'EXPIRED';
    cst_expulsion   CONSTANT    VARCHAR2(10) := 'EXPULSION';
    cst_goodstand   CONSTANT    VARCHAR2(10) := 'GOODSTAND';
    cst_manual  CONSTANT    VARCHAR2(10) := 'MANUAL';
    cst_nopenalty   CONSTANT    VARCHAR2(10) := 'NOPENALTY';
    cst_pending CONSTANT    VARCHAR2(10) := 'PENDING';
    cst_showcause   CONSTANT    VARCHAR2(10) := 'SHOWCAUSE';
    cst_suspension  CONSTANT    VARCHAR2(10) := 'SUSPENSION';
    cst_undconsid   CONSTANT    VARCHAR2(10) := 'UNDCONSID';
    e_record_locked         EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_record_locked, -54);
    v_expiry_type           VARCHAR2(10);
    v_expiry_dt         DATE;
    v_sca_status_updated        BOOLEAN;
    v_message_name          VARCHAR2(30);
    v_dummy             VARCHAR2(1);
    CURSOR c_spo IS
        SELECT  spo.person_id,
            spo.course_cd,
            spo.sequence_number,
            spo.expiry_dt
        FROM    IGS_PR_STDNT_PR_OU  spo,
            IGS_PR_OU_TYPE      pot
        WHERE   spo.decision_status         = cst_approved AND
            spo.applied_dt          IS NOT NULL AND
            spo.expiry_dt           IS NULL AND
            spo.duration            IS NOT NULL  AND
            pot.progression_outcome_type    = spo.progression_outcome_type AND
            pot.s_progression_outcome_type  IN
                (cst_suspension, cst_probation, cst_manual);
    CURSOR c_spo_upd (
        cp_person_id        IGS_PR_STDNT_PR_OU.person_id%TYPE,
        cp_course_cd        IGS_PR_STDNT_PR_OU.course_cd%TYPE,
        cp_sequence_number  IGS_PR_STDNT_PR_OU.sequence_number%TYPE) IS
        SELECT  spo.*, spo.ROWID
        FROM    IGS_PR_STDNT_PR_OU  spo
        WHERE   spo.person_id           = cp_person_id AND
            spo.course_cd           = cp_course_cd AND
            spo.sequence_number     = cp_sequence_number
        FOR UPDATE NOWAIT;

    v_spo_upd_rec c_spo_upd%ROWTYPE;

    CURSOR c_sca1 IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.version_number,
            sca.progression_status
        FROM    IGS_EN_STDNT_PS_ATT         sca
        WHERE   sca.progression_status      = cst_goodstand AND
                sca.course_attempt_status  NOT IN ('UNCONFIRM','DELETED','COMPLETED') AND
            EXISTS (
            SELECT  'X'
            FROM    IGS_PR_STDNT_PR_OU  spo,
                IGS_PR_OU_TYPE      pot
            WHERE   pot.progression_outcome_type    = spo.progression_outcome_type AND
                spo.person_id           = sca.person_id AND
                spo.course_cd           = sca.course_cd AND
                ((spo.decision_status       = cst_pending AND
                spo.course_cd           = sca.course_cd)
                OR
                (spo.decision_status        = cst_approved AND
                pot.s_progression_outcome_type  <> cst_nopenalty AND
                IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY (
                        spo.person_id,
                        spo.course_cd,
                        spo.sequence_number,
                        spo.expiry_dt)  <> cst_expired AND
                (
                pot.s_progression_outcome_type  IN (cst_probation,cst_manual) OR
                EXISTS (
                SELECT  'X'
                FROM    IGS_PR_STDNT_PR_PS      spc
                WHERE   spo.person_id           = spc.person_id AND
                    spo.course_cd           = spc.spo_course_cd AND
                    spo.sequence_number     = spc.spo_sequence_number AND
                    spc.course_cd           = sca.course_cd) OR
                (spo.encmb_course_group_cd      IS NOT NULL AND
                EXISTS (
                SELECT  'X'
                FROM    IGS_PS_GRP_MBR      cgm
                WHERE   cgm.course_group_cd         = spo.encmb_course_group_cd AND
                    cgm.course_cd           = sca.course_cd AND
                    cgm.version_number      = sca.version_number))))));
    CURSOR c_sca2 IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.version_number,
            sca.progression_status
        FROM    IGS_EN_STDNT_PS_ATT         sca
        WHERE   sca.progression_status      = cst_undconsid AND
                sca.course_attempt_status  NOT IN ('UNCONFIRM','DELETED','COMPLETED') AND
            NOT EXISTS (
            SELECT  'X'
            FROM    IGS_PR_STDNT_PR_OU      spo
            WHERE   sca.person_id               = spo.person_id AND
                sca.course_cd               = spo.course_cd AND
                spo.decision_status             = cst_pending);
    CURSOR c_sca3 IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.version_number,
            sca.progression_status
        FROM    IGS_EN_STDNT_PS_ATT         sca
        WHERE   sca.progression_status      = cst_showcause AND
                sca.course_attempt_status  NOT IN ('UNCONFIRM','DELETED','COMPLETED') AND
            NOT EXISTS (
            SELECT  'X'
            FROM    IGS_PR_STDNT_PR_OU spo
            WHERE   sca.person_id               = spo.person_id AND
                sca.course_cd               = spo.course_cd AND
                spo.decision_status             = cst_approved AND
                spo.show_cause_expiry_dt        IS NOT NULL AND
                ((spo.show_cause_dt             IS NOT NULL AND
                spo.show_cause_outcome_dt       IS NULL) OR
                (spo.show_cause_expiry_dt       > TRUNC(SYSDATE))));
    CURSOR c_sca4 IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.version_number,
            sca.progression_status
        FROM    IGS_EN_STDNT_PS_ATT         sca
        WHERE   sca.progression_status      IN (
                            cst_probation,
                            cst_suspension,
                            cst_exclusion,
                            cst_expulsion) AND
            sca.course_attempt_status  NOT IN ('UNCONFIRM','DELETED','COMPLETED') AND
            NOT EXISTS (
            SELECT  'X'
            FROM    IGS_PR_STDNT_PR_OU      spo,
                IGS_PR_OU_TYPE      pot
            WHERE   pot.progression_outcome_type        = spo.progression_outcome_type AND
                spo.person_id               = sca.person_id AND
                spo.course_cd               = sca.course_cd AND
                spo.decision_status             = cst_approved AND
                (spo.decision_status        = cst_approved AND
                pot.s_progression_outcome_type  <> cst_nopenalty AND
                IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY (
                        spo.person_id,
                        spo.course_cd,
                        spo.sequence_number,
                        spo.expiry_dt)  <> cst_expired AND
                (
                pot.s_progression_outcome_type  IN (cst_probation,cst_manual) OR
                EXISTS (
                SELECT  'X'
                FROM    IGS_PR_STDNT_PR_PS      spc
                WHERE   spo.person_id           = spc.person_id AND
                    spo.course_cd           = spc.spo_course_cd AND
                    spo.sequence_number     = spc.spo_sequence_number AND
                    spc.course_cd           = sca.course_cd) OR
                (spo.encmb_course_group_cd      IS NOT NULL AND
                EXISTS (
                SELECT  'X'
                FROM    IGS_PS_GRP_MBR      cgm
                WHERE   cgm.course_group_cd         = spo.encmb_course_group_cd AND
                    cgm.course_cd           = sca.course_cd AND
                    cgm.version_number      = sca.version_number)))));

     CURSOR c_person(cp_party_id Number) IS
             SELECT PARTY_NUMBER FROM HZ_PARTIES
         WHERE PARTY_ID = cp_party_id;

    lv_person_number HZ_PARTIES.PARTY_NUMBER%TYPE;
  BEGIN
    -- Check for students whose expiry date is now available ; set where
    -- appropriate
    retcode := 0;
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054
    FOR v_spo_rec IN c_spo LOOP

    --Get the person number to be displayed in log file..

    OPEN c_person(v_spo_rec.person_id);
    FETCH c_person INTO lv_person_number;
    close c_person;

        v_expiry_type := IGS_PR_GEN_006.IGS_PR_get_spo_expiry (
                            v_spo_rec.person_id,
                            v_spo_rec.course_cd,
                            v_spo_rec.sequence_number,
                            v_spo_rec.expiry_dt,
                            v_expiry_dt);
        IF v_expiry_dt IS NOT NULL THEN
            BEGIN
                OPEN c_spo_upd (
                        v_spo_rec.person_id,
                        v_spo_rec.course_cd,
                        v_spo_rec.sequence_number);
                FETCH c_spo_upd INTO v_spo_upd_rec;
/*
                UPDATE  IGS_PR_STDNT_PR_OU
                SET expiry_dt = v_expiry_dt,
                    applied_dt = igs_ge_date.igsdate('0001/01/01')
                WHERE CURRENT OF c_spo_upd;
*/
                igs_pr_stdnt_pr_ou_pkg.update_row(
                   x_rowid                         => v_spo_upd_rec.ROWID,
                   x_person_id                     => v_spo_upd_rec.person_id,
                   x_course_cd                     => v_spo_upd_rec.course_cd,
                   x_sequence_number               => v_spo_upd_rec.sequence_number,
                   x_prg_cal_type                  => v_spo_upd_rec.prg_cal_type,
                   x_prg_ci_sequence_number        => v_spo_upd_rec.prg_ci_sequence_number,
                   x_rule_check_dt                 => v_spo_upd_rec.rule_check_dt,
                   x_progression_rule_cat          => v_spo_upd_rec.progression_rule_cat,
                   x_pra_sequence_number           => v_spo_upd_rec.pra_sequence_number,
                   x_pro_sequence_number           => v_spo_upd_rec.pro_sequence_number,
                   x_progression_outcome_type      => v_spo_upd_rec.progression_outcome_type,
                   x_duration                      => v_spo_upd_rec.duration,
                   x_duration_type                 => v_spo_upd_rec.duration_type,
                   x_decision_status               => v_spo_upd_rec.decision_status,
                   x_decision_dt                   => v_spo_upd_rec.decision_dt,
                   x_decision_org_unit_cd          => v_spo_upd_rec.decision_org_unit_cd,
                   x_decision_ou_start_dt          => v_spo_upd_rec.decision_ou_start_dt,
                   x_applied_dt                    => igs_ge_date.igsdate('0001/01/01'),
                   x_show_cause_expiry_dt          => v_spo_upd_rec.show_cause_expiry_dt,
                   x_show_cause_dt                 => v_spo_upd_rec.show_cause_dt,
                   x_show_cause_outcome_dt         => v_spo_upd_rec.show_cause_outcome_dt,
                   x_show_cause_outcome_type       => v_spo_upd_rec.show_cause_outcome_type,
                   x_appeal_expiry_dt              => v_spo_upd_rec.appeal_expiry_dt,
                   x_appeal_dt                     => v_spo_upd_rec.appeal_dt,
                   x_appeal_outcome_dt             => v_spo_upd_rec.appeal_outcome_dt,
                   x_appeal_outcome_type           => v_spo_upd_rec.appeal_outcome_type,
                   x_encmb_course_group_cd         => v_spo_upd_rec.encmb_course_group_cd,
                   x_restricted_enrolment_cp       => v_spo_upd_rec.restricted_enrolment_cp,
                   x_restricted_attendance_type    => v_spo_upd_rec.restricted_attendance_type,
                   x_comments                      => v_spo_upd_rec.comments,
                   x_show_cause_comments           => v_spo_upd_rec.show_cause_comments,
                   x_appeal_comments               => v_spo_upd_rec.appeal_comments,
                   x_expiry_dt                     => v_expiry_dt,--v_spo_upd_rec.expiry_dt, -- Modified by Prajeesh as part of the bug
                   x_pro_pra_sequence_number       => v_spo_upd_rec.pro_pra_sequence_number,
                   x_mode                          => 'R'
                 );

            CLOSE c_spo_upd;
            EXCEPTION
                WHEN e_record_locked THEN
                    IF c_spo_upd%ISOPEN THEN
                        CLOSE c_spo_upd;
                    END IF;
                WHEN OTHERS THEN
                    RAISE;
            END;
            ELSE
           FND_FILE.PUT_LINE(FND_FILE.LOG,'The Person := '||lv_person_number ||
                                   ' With the Course := '||v_spo_upd_rec.COURSE_CD||' Has no Expiry date');
        END IF;
    END LOOP; -- c_spo
    --Functionality for the part of the code that follows:-
    -- Check the decision status for record in IGS_PR_STDNT_PR_OU table and check the corresponding
    -- progresssion statuses in the table IGS_EN_STDNT_PS_ATT and update these progression statuses suitably

    -- Good Standing : Select records marked as good standing where either Pending
    -- record relates directly to the course attempt, or an approved record
    -- affects the course (either directly or via course of course group effects).
    FOR v_sca_rec IN c_sca1 LOOP

    OPEN c_person(v_sca_rec.person_id);
        FETCH c_person INTO lv_person_number;
    close c_person;

        v_sca_status_updated := IGS_PR_GEN_006.IGS_PR_upd_sca_status (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd,
                            v_sca_rec.progression_status,
                            v_sca_rec.version_number,
                            v_message_name);

    IF v_message_name = 'IGS_PR_LOCK_DETECTED' THEN
            FND_MESSAGE.SET_NAME('IGS', v_message_name);
            fnd_message.set_token('RECORD', 'Student program Attempt for ' ||  lv_person_number  || ' and  course ' || v_sca_rec.course_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
        end if;
    END LOOP; -- c_sca1

    -- Corresponding to all records where decision status is still 'PENDING'
    -- set the progression status in the table 'IGS_EN_STDNT_PS_ATT' to 'UNCONSID'.
    -- Under Consideration : Selects records with status of under consideration
    -- where there are no longer any directly related progression outcomes being
    -- considered.
    FOR v_sca_rec IN c_sca2 LOOP

    OPEN c_person(v_sca_rec.person_id);
            FETCH c_person INTO lv_person_number;
    close c_person;

        v_sca_status_updated := IGS_PR_GEN_006.IGS_PR_upd_sca_status (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd,
                            v_sca_rec.progression_status,
                            v_sca_rec.version_number,
                            v_message_name);
        IF v_message_name = 'IGS_PR_LOCK_DETECTED' THEN
            FND_MESSAGE.SET_NAME('IGS', v_message_name);
            fnd_message.set_token('RECORD', 'Student program Attempt for ' ||  lv_person_number  || ' and  course ' || v_sca_rec.course_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
        end if;

    END LOOP; -- c_sca2
    -- Show Cause ; Selects records with a status of show cause where there is no
    -- longer any show cause processing in progress.
    FOR v_sca_rec IN c_sca3 LOOP

    OPEN c_person(v_sca_rec.person_id);
            FETCH c_person INTO lv_person_number;
    close c_person;

        v_sca_status_updated := IGS_PR_GEN_006.IGS_PR_upd_sca_status (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd,
                            v_sca_rec.progression_status,
                            v_sca_rec.version_number,
                            v_message_name);
    IF v_message_name = 'IGS_PR_LOCK_DETECTED' THEN
            FND_MESSAGE.SET_NAME('IGS', v_message_name);
            fnd_message.set_token('RECORD', 'Student program Attempt for ' ||  lv_person_number  || ' and  course ' || v_sca_rec.course_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
        end if;

    END LOOP; -- c_sca3
    -- Probation, Suspension, Exclusion, Expulsion : Selects records were effects
    -- of the associated progression outcome types are no longer effective
    -- (ie. typically have reached their expiry date).
    FOR v_sca_rec IN c_sca4 LOOP

    OPEN c_person(v_sca_rec.person_id);
            FETCH c_person INTO lv_person_number;
    close c_person;

        v_sca_status_updated := IGS_PR_GEN_006.IGS_PR_upd_sca_status (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd,
                            v_sca_rec.progression_status,
                            v_sca_rec.version_number,
                            v_message_name);
    IF v_message_name = 'IGS_PR_LOCK_DETECTED' THEN
            FND_MESSAGE.SET_NAME('IGS', v_message_name);
            fnd_message.set_token('RECORD', 'Student program Attempt for ' ||  lv_person_number || ' and  course ' || v_sca_rec.course_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
        end if;

    END LOOP; -- c_sca4
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
        IF c_spo%ISOPEN THEN
            CLOSE c_spo;
        END IF;
        IF c_spo%ISOPEN THEN
            CLOSE c_spo_upd;
        END IF;
        IF c_sca1%ISOPEN THEN
            CLOSE c_sca1;
        END IF;
        IF c_sca2%ISOPEN THEN
            CLOSE c_sca2;
        END IF;
        IF c_sca3%ISOPEN THEN
            CLOSE c_sca3;
        END IF;
        IF c_sca4%ISOPEN THEN
            CLOSE c_sca4;
        END IF;
        RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_GEN_004.IGS_PR_UPD_SPO_MAINT');
          IGS_GE_MSG_STACK.ADD;
      retcode := 2;
          errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXP');
          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END IGS_PR_upd_spo_maint;

END IGS_PR_GEN_004;

/
