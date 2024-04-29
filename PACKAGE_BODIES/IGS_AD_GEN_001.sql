--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_001" AS
/* $Header: IGSAD01B.pls 120.3 2005/09/22 05:26:17 appldev ship $ */
Function Admp_Del_Aa_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
BEGIN   -- admp_del_aa_hist
    -- Removes the history record/s from IGS_AD_APPL by calling another a
    -- sub-function.
    -- If true is returned then we will know that the record either not there or
    -- has been deleted.
    -- If false is returned then we know that the record or table is locked.
    -- Another check needs
    -- to be made to see whether the values that have been passed actually exist in
    --  the db. If they don't,
    -- then return true, otherwise return false with the knowledge that the table
    -- or record is locked.
DECLARE
    CURSOR c_aah_sel (
            cp_person_id        IGS_AD_APPL_HIST.person_id%TYPE,
            cp_admission_appl_number    IGS_AD_APPL_HIST.admission_appl_number%TYPE) IS
        SELECT  person_id
        FROM    IGS_AD_APPL_HIST
        WHERE person_id             = cp_person_id
        AND admission_appl_number   = cp_admission_appl_number;
    v_aah_sel_rec       c_aah_sel%ROWTYPE;
    FUNCTION admpl_del_if_not_locked(
        p_adinl_person_id           IN  IGS_AD_APPL_HIST.person_id%TYPE,
        p_adinl_admission_appl_number   IN  IGS_AD_APPL_HIST.admission_appl_number%TYPE)
    RETURN
        BOOLEAN
    IS
        e_resource_busy_exception       EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
    BEGIN   -- admpl_del_if_not_locked
        -- This function will simply return false if the IGS_AD_APPL_HIST table or
        -- rows are locked. Otherwise, it will delete the appropriate records from the
        -- table and return true.
    DECLARE
        CURSOR c_aah (
                cp_adinl_person_id  IGS_AD_APPL_HIST.person_id%TYPE,
                cp_adinl_admission_appl_number
                            IGS_AD_APPL_HIST.admission_appl_number%TYPE) IS
            SELECT  rowid, aah.*
            FROM    IGS_AD_APPL_HIST  aah
            WHERE person_id = cp_adinl_person_id AND
                admission_appl_number = cp_adinl_admission_appl_number
            FOR UPDATE OF person_id NOWAIT;
    BEGIN
        FOR v_aah_rec IN c_aah (
                    p_adinl_person_id,
                    p_adinl_admission_appl_number)
        LOOP
           IGS_AD_APPL_HIST_PKG.DELETE_ROW (
                X_ROWID => v_aah_rec.rowid );
        END LOOP;
        RETURN TRUE;
    END;
    EXCEPTION
        WHEN e_resource_busy_exception THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_if_not_locked');
            IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
    END admpl_del_if_not_locked;
BEGIN
    p_message_name := null;
    IF admpl_del_if_not_locked (
                p_person_id,
                p_admission_appl_number)= FALSE THEN
        OPEN c_aah_sel(
                p_person_id,
                p_admission_appl_number);
        FETCH c_aah_sel INTO v_aah_sel_rec;
        IF c_aah_sel%FOUND THEN
            CLOSE c_aah_sel;
            p_message_name := 'IGS_AD_NODEL_ADMAPPL_RECORD';
            RETURN FALSE;
        END IF;
        CLOSE c_aah_sel;
    END IF;
    RETURN TRUE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admp_del_aa_hist');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_del_aa_hist;

Function Admp_Del_Acaiu_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
BEGIN   -- admp_del_acaiu_hist
    -- Routine to remove the history for an IGS_AD_PS_APLINSTUNT.
DECLARE
    e_resource_busy_exception       EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
    CURSOR c_acaiuh IS
        SELECT rowid,acaiuh.*
        FROM    IGS_AD_PS_APINTUNTHS    acaiuh
        WHERE   acaiuh.person_id            = p_person_id           AND
            acaiuh.admission_appl_number    = p_admission_appl_number   AND
            acaiuh.nominated_course_cd  = p_nominated_course_cd     AND
            acaiuh.acai_sequence_number = p_acai_sequence_number    AND
            acaiuh.unit_cd          = p_unit_cd
        FOR UPDATE OF acaiuh.person_id NOWAIT;
BEGIN
    -- Set default value
    p_message_name := null;
    FOR v_acaiuh_rec IN c_acaiuh LOOP

        IGS_AD_PS_APINTUNTHS_PKG.DELETE_ROW (
            X_ROWID => v_acaiuh_rec.rowid );

    END LOOP;
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy_exception THEN
        -- Close unlclosed local cursor
        IF c_acaiuh%ISOPEN THEN
            CLOSE c_acaiuh;
        END IF;
        -- Set error message number
        p_message_name := 'IGS_AD_UNABLE_TO_DELETE';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_acaiuh%ISOPEN THEN
            CLOSE c_acaiuh;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admp_del_acaiu_hist');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_del_acaiu_hist;

Function Admp_Del_Acai_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
BEGIN   -- admp_del_acai_hist
    -- Deletes records from IGS_AD_PS_APLINSTHST table
DECLARE
    FUNCTION admp_del_if_not_locked(
        p_person_id             IGS_AD_PS_APLINSTHST.person_id%TYPE,
        p_admission_appl_number
                IGS_AD_PS_APLINSTHST.admission_appl_number%TYPE,
        p_nominated_course_cd   IGS_AD_PS_APLINSTHST.nominated_course_cd%TYPE,
        p_sequence_number           IGS_AD_PS_APLINSTHST.sequence_number%TYPE)
    RETURN  BOOLEAN IS
        e_resource_busy_exception       EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
    BEGIN   -- admp_del_if_not_locked
        -- This function will return false if the IGS_AD_PS_APLINSTHST table
        -- rows are locked. Otherwise, it will delete the appropriate records from the
        -- table and return true.
    DECLARE
        CURSOR c_acaih (
            cp_person_id            IGS_AD_PS_APLINSTHST.person_id%TYPE,
            cp_admission_appl_number
                IGS_AD_PS_APLINSTHST.admission_appl_number%TYPE,
            cp_nominated_course_cd
                IGS_AD_PS_APLINSTHST.nominated_course_cd%TYPE,
            cp_sequence_number      IGS_AD_PS_APLINSTHST.sequence_number%TYPE) IS

        SELECT  rowid, acaih.*
        FROM    IGS_AD_PS_APLINSTHST    acaih
        WHERE   acaih.person_id         = cp_person_id AND
            acaih.admission_appl_number     = cp_admission_appl_number AND
            acaih.nominated_course_cd   = cp_nominated_course_cd AND
            acaih.sequence_number       = cp_sequence_number
            FOR UPDATE OF acaih.person_id NOWAIT;
    BEGIN
        FOR v_del_acaih_rec IN c_acaih (
                    p_person_id,
                    p_admission_appl_number,
                    p_nominated_course_cd,
                    p_sequence_number) LOOP

            IGS_AD_PS_APLINSTHST_PKG.DELETE_ROW (
                    X_ROWID => v_del_acaih_rec.rowid );

        END LOOP;
        RETURN TRUE;
    END;
    EXCEPTION
        WHEN e_resource_busy_exception THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admp_del_if_not_locked');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END admp_del_if_not_locked;
BEGIN
    p_message_name := null;
    IF(admp_del_if_not_locked (
                p_person_id,
                p_admission_appl_number,
                p_nominated_course_cd,
                p_sequence_number)= FALSE) THEN
            p_message_name := 'IGS_AD_UNABLEDEL_ADMPRG_APPL';
            RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admp_del_acai_hist');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_del_acai_hist;

Function Admp_Del_Aca_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
BEGIN   -- admp_del_aca_hist
    -- Deletes records from IGS_AD_PS_APPL_HIST table
DECLARE
    FUNCTION admp_del_if_not_locked(
        p_person_id             IGS_AD_PS_APPL_HIST.person_id%TYPE,
        p_admission_appl_number         IGS_AD_PS_APPL_HIST.admission_appl_number%TYPE,
        p_nominated_course_cd           IGS_AD_PS_APPL_HIST.nominated_course_cd%TYPE)
    RETURN  BOOLEAN IS
        e_resource_busy_exception       EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
    BEGIN
            -- admp_del_if_not_locked
        -- This function will return false if the IGS_AD_PS_APPL_HIST table
        -- rows are locked. Otherwise, it will delete the appropriate records from the
        -- table and return true.
    DECLARE
        CURSOR c_acah (
            cp_person_id            IGS_AD_PS_APPL_HIST.person_id%TYPE,
            cp_admission_appl_number    IGS_AD_PS_APPL_HIST.admission_appl_number%TYPE,
            cp_nominated_course_cd      IGS_AD_PS_APPL_HIST.nominated_course_cd%TYPE) IS
        SELECT  ROWID, acah.*
        FROM    IGS_AD_PS_APPL_HIST         acah
        WHERE   acah.person_id          = cp_person_id AND
            acah.admission_appl_number  = cp_admission_appl_number AND
            acah.nominated_course_cd    = cp_nominated_course_cd
            FOR UPDATE OF acah.person_id NOWAIT;
    BEGIN
        FOR v_del_acah_rec IN c_acah (
                    p_person_id,
                    p_admission_appl_number,
                    p_nominated_course_cd) LOOP

            IGS_AD_PS_APPL_HIST_PKG.DELETE_ROW (
                 X_ROWID => v_del_acah_rec.rowid );

        END LOOP;
        RETURN TRUE;
    END;
    EXCEPTION
        WHEN e_resource_busy_exception THEN
            RETURN FALSE;
        WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admp_del_if_not_locked');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END admp_del_if_not_locked;
BEGIN
    p_message_name := null;
    IF(admp_del_if_not_locked (
                p_person_id,
                p_admission_appl_number,
                p_nominated_course_cd)= FALSE) THEN
            p_message_name := 'IGS_AD_UNABLE_DEL_ADMPRG_APPL';
            RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admp_del_aca_hist');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_del_aca_hist;

--removed the  Function Admp_Del_Eap_Cepi (bug 2664699) rghosh

--removed Function Admp_Del_Eap_Eitpi for IGR Migration (bug 4114493) sjlaport

--removed the function Admp_Del_Eap_Eltpi (bug 2664699) rghosh

--------------------------------------------------------------------------------
-- ADMPL_DEL_INSERT_LOG_ENTRY is called from ADMP_DEL_SCA_UNCONF ---------------
--------------------------------------------------------------------------------
PROCEDURE admpl_del_ins_log_entry (
    p_message_name          VARCHAR2 ,
    p_default_msg_txt           VARCHAR2 ,
    p_sca_deleted_ind       VARCHAR2,
        p_log_creation_dt               DATE,
        p_key                           VARCHAR2,
        p_s_log_type                VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN   -- admpl_del_ins_log_entry
    -- Create a log entry
BEGIN
    IGS_GE_GEN_003.genp_ins_log_entry(
            p_s_log_type,
            p_log_creation_dt,
            p_sca_deleted_ind || '|' || p_key,
            p_message_name,
            p_default_msg_txt);
END;
COMMIT;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_ins_log_entry');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_ins_log_entry;

Procedure Admp_Del_Sca_Unconf(
  p_log_creation_dt OUT NOCOPY DATE )
IS
BEGIN   -- admp_del_sca_unconf
    -- This module deletes unconfirmed student course attempts that
    -- were created as a result of an admission course application
    -- offer that was never accepted. This process will be run
    -- nightly by the Job Scheduler.
    -- Records are deleted from the following IGS_EN_STDNT_PS_ATT
    -- child tables
    --  Student IGS_PS_UNIT Attempt (and histories)
    --  Student IGS_PS_UNIT Set Attempt
    --  Student IGS_PS_COURSE HECS Option
    --  Student IGS_PS_COURSE Attempt Enrolment
    --  Student IGS_PS_COURSE Attempt Notes
    --  Advanced Standing (and child tables
    --  IGS_RE_CANDIDATURE (by breaking the SCA parent link
    --  Fee Assessment (by reversing the fee assessment)
    --  Contract Fee Assessment Rates
    -- Records on all other student IGS_PS_COURSE child tables are to be
    -- processed as IGS_GE_EXCEPTIONS
DECLARE
    e_resource_busy     EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
    e_savepoint_lost    EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_savepoint_lost, -1086);

        cst_enrolment       CONSTANT VARCHAR2(10) := 'ENROLMENT';
    cst_admission       CONSTANT VARCHAR2(10) := 'ADMISSION';
    cst_unconfirm       CONSTANT VARCHAR2(10) := 'UNCONFIRM';
    cst_withdrawn       CONSTANT VARCHAR2(10) := 'WITHDRAWN';
    cst_voided      CONSTANT VARCHAR2(10) := 'VOIDED';
    cst_rejected        CONSTANT VARCHAR2(10) := 'REJECTED';
    cst_lapsed      CONSTANT VARCHAR2(10) := 'LAPSED';
    cst_deferral        CONSTANT VARCHAR2(10) := 'DEFERRAL';
    cst_del_un_sca      CONSTANT VARCHAR2(10) := 'DEL-UN-SCA';
    cst_academic        CONSTANT VARCHAR2(10) := 'ACADEMIC';
    cst_approved        CONSTANT VARCHAR2(10) := 'APPROVED';

    v_process_next          BOOLEAN DEFAULT FALSE;
    v_error_number          NUMBER DEFAULT NULL;
    v_error_flag            BOOLEAN DEFAULT FALSE;
    v_constraint            VARCHAR2(40) DEFAULT NULL;
    v_default_msg           VARCHAR2(300) DEFAULT NULL;
    v_message_name          VARCHAR2(30);
        v_message_num                   NUMBER;
    v_key               VARCHAR2(255) DEFAULT NULL;
    v_log_creation_dt       IGS_GE_S_LOG.creation_dt%TYPE;
    v_delete_sca_ind        VARCHAR2(1);
    v_record_locked         BOOLEAN;
    v_hist_record_locked        BOOLEAN;
    v_fee_ass_log_creation_dt   IGS_GE_S_LOG.creation_dt%TYPE DEFAULT NULL;
        l_msg_at_index                  NUMBER;
        l_entity_name                   VARCHAR2(30);

        CURSOR c_cir IS
        SELECT  cir.sup_cal_type,
            cir.sup_ci_sequence_number,
            daiv.cal_type,
            daiv.ci_sequence_number
        FROM    IGS_CA_INST_REL     cir,
            IGS_CA_DA_INST_V        daiv,
            IGS_CA_TYPE             ct,
            IGS_CA_TYPE             ct2,
            IGS_EN_CAL_CONF             secc
        WHERE   secc.s_control_num      = 1 AND
            TRUNC(daiv.alias_val)       = TRUNC(SYSDATE) AND
            daiv.dt_alias           = secc.enr_cleanup_dt_alias AND
            ct.cal_type             = daiv.cal_type AND
            ct.s_cal_cat            = cst_enrolment AND
            cir.sub_cal_type        = daiv.cal_type AND
            cir.sub_ci_sequence_number  = daiv.ci_sequence_number AND
            ct2.cal_type            = cir.sup_cal_type AND
            ct2.s_cal_cat           = cst_admission;

        CURSOR c_sca (
        cp_cal_type     IGS_CA_INST.cal_type%TYPE,
        cp_sequence_number  IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  sca.person_id,
            sca.course_cd,
            sca.course_attempt_status,
            sca.fee_cat,
            sca.adm_admission_appl_number,
            sca.adm_nominated_course_cd,
            sca.adm_sequence_number,
            acaiv.admission_appl_number,
            acaiv.nominated_course_cd,
            acaiv.sequence_number,
            aa.acad_cal_type,
            aa.acad_ci_sequence_number,
            acaiv.adm_cal_type,
            acaiv.adm_ci_sequence_number,
            aa.admission_cat,
            aa.s_admission_process_type,
            aors.s_adm_offer_resp_status,
            aods.s_adm_offer_dfrmnt_status
        FROM    igs_en_stdnt_ps_att         sca,
            igs_ad_ps_appl_inst acaiv,
            igs_ad_appl         aa,
            igs_ad_ou_stat      aos,
            igs_ad_ofr_resp_stat        aors,
            igs_ad_ofrdfrmt_stat        aods
        WHERE   sca.course_attempt_status   = cst_unconfirm AND
            sca.person_id           = acaiv.person_id AND
            sca.adm_admission_appl_number   = acaiv.admission_appl_number AND
            sca.adm_nominated_course_cd = acaiv.nominated_course_cd AND
            sca.adm_sequence_number     = acaiv.sequence_number AND
            acaiv.adm_cal_type      = cp_cal_type AND
            acaiv.adm_ci_sequence_number    = cp_sequence_number AND
            aa.person_id            = acaiv.person_id AND
            aa.admission_appl_number    = acaiv.admission_appl_number AND
            aos.adm_outcome_status      = acaiv.adm_outcome_status AND
            aors.adm_offer_resp_status  = acaiv.adm_offer_resp_status AND
            aods.adm_offer_dfrmnt_status    = acaiv.adm_offer_dfrmnt_status AND
            (aos.s_adm_outcome_status IN (
                        cst_withdrawn,
                        cst_voided,
                        cst_rejected) OR
            aors.s_adm_offer_resp_status IN (
                        cst_rejected,
                        cst_lapsed,
                        cst_deferral));

        CURSOR c_term (cp_person_id igs_en_spa_terms.person_id%TYPE,
	               cp_course_cd igs_en_spa_terms.program_cd%TYPE) IS
          SELECT sterm.person_id,sterm.program_cd
          FROM    IGS_EN_SPA_TERMS    sterm
          WHERE   sterm.person_id      = cp_person_id
          AND     sterm.program_cd      = cp_course_cd;

        l_term c_term%ROWTYPE;

        CURSOR c_sca_upd(
        cp_person_id        IGS_EN_STDNT_PS_ATT.person_id%TYPE,
        cp_course_cd        IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
        SELECT ROWID, sca.*
        FROM    IGS_EN_STDNT_PS_ATT     sca
        WHERE   sca.person_id   = cp_person_id AND
            sca.course_cd   = cp_course_cd
        FOR UPDATE OF
            sca.LAST_UPDATE_DATE NOWAIT;
    v_sca_upd_exists            c_sca_upd%ROWTYPE;

--------------------------------------------------------------------------------
-- EXTRACT_MSG_FROM_STACK ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
PROCEDURE extract_msg_from_stack (p_msg_at_index NUMBER)
IS
  l_old_msg_count               NUMBER;
  l_new_msg_count               NUMBER;
  l_msg_inc_factr               NUMBER := 1;
  l_msg_idx_start               NUMBER;
  l_msg_txt                     fnd_new_messages.message_text%TYPE;
  l_app_nme                     varchar2(1000);
  l_msg_nme                     varchar2(2000);
BEGIN
  l_old_msg_count := p_msg_at_index;
  l_new_msg_count := igs_ge_msg_stack.count_msg;

  WHILE (l_new_msg_count - l_old_msg_count) > 0
  LOOP
    igs_ge_msg_stack.get(l_old_msg_count+l_msg_inc_factr,'T',l_msg_txt,l_msg_idx_start);

    igs_ge_msg_stack.delete_msg(l_msg_idx_start);
    l_new_msg_count := l_new_msg_count -1;

    fnd_message.parse_encoded (l_msg_txt, l_app_nme, l_msg_nme);
    fnd_message.set_encoded (l_msg_txt);
    l_msg_txt := fnd_message.get;

    IF l_msg_txt IS NOT NULL THEN
      admpl_del_ins_log_entry (
                               p_message_name     => l_msg_nme,
                               p_default_msg_txt  => l_msg_txt,
                               p_sca_deleted_ind => 'N',
                               p_log_creation_dt => v_log_creation_dt,
                               p_key => v_key,
                               p_s_log_type => cst_del_un_sca);
    END IF;
  END LOOP;

  IF l_msg_txt IS NULL AND SQLCODE <> 0 THEN
    l_msg_txt := SQLERRM;
    admpl_del_ins_log_entry (
                             p_message_name     => l_msg_nme,
                             p_default_msg_txt  => l_msg_txt,
                             p_sca_deleted_ind => 'N',
                             p_log_creation_dt => v_log_creation_dt,
                             p_key => v_key,
                             p_s_log_type => cst_del_un_sca);
  END IF;
END extract_msg_from_stack;
--------------------------------------------------------------------------------
-- ADMPL_DEL_SUA ---------------------------------------------------------------
--Who         When            What
--knaraset  29-Apr-03   Modified cursors to have uoo_id reference as part of MUS build bug 2829262
--------------------------------------------------------------------------------
FUNCTION admpl_del_sua(
    p_person_id         IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd         IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_sua
    -- (1) Delete IGS_EN_SU_ATTEMPT records
DECLARE
    CURSOR c_sua IS
        SELECT  uoo_id
        FROM    IGS_EN_SU_ATTEMPT sua
        WHERE   sua.person_id = p_person_id AND
            sua.course_cd = p_course_cd;
    CURSOR c_sua_del (
        cp_uoo_id       IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
        SELECT row_id
        FROM    IGS_EN_SU_ATTEMPT   sua
        WHERE   sua.person_id       = p_person_id AND
            sua.course_cd       = p_course_cd AND
            sua.uoo_id      = cp_uoo_id
        FOR UPDATE OF
            sua.LAST_UPDATE_DATE NOWAIT;
    v_sua_del_exists    c_sua_del%ROWTYPE;


BEGIN
    v_error_flag := FALSE;
    FOR v_sua_rec IN c_sua LOOP

                -- Delete unconfirmed IGS_EN_SU_ATTEMPT
        FOR v_sua_del_exists IN c_sua_del(v_sua_rec.uoo_id) LOOP
            IGS_EN_SU_ATTEMPT_PKG.DELETE_ROW(
                X_ROWID => v_sua_del_exists.row_id );
        END LOOP;

    END LOOP;
    IF  v_error_flag THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_sua%ISOPEN THEN
            CLOSE c_sua;
        END IF;
        IF c_sua_del%ISOPEN THEN
            CLOSE c_sua_del;
        END IF;
        l_entity_name := 'IGS_EN_SU_ATTEMPT_ALL';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_sua%ISOPEN THEN
            CLOSE c_sua;
        END IF;
        IF c_sua_del%ISOPEN THEN
            CLOSE c_sua_del;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_sua');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_sua;

--------------------------------------------------------------------------------
-- ADMPL_DEL_SUAH ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_del_suah(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_suah
    -- Delete IGS_EN_SU_ATTEMPT_H records
DECLARE
    CURSOR c_suah  IS
        SELECT  suah.uoo_id,
                        suah.hist_start_dt
        FROM    IGS_EN_SU_ATTEMPT_H     suah
        WHERE   suah.person_id      = p_person_id AND
            suah.course_cd      = p_course_cd ;


    CURSOR c_suah_del (
        cp_uoo_id       IGS_EN_SU_ATTEMPT_H.uoo_id%TYPE,
        cp_hist_start_dt    IGS_EN_SU_ATTEMPT_H.hist_start_dt%TYPE) IS
        SELECT row_id
        FROM    IGS_EN_SU_ATTEMPT_H     suah
        WHERE   suah.person_id      = p_person_id AND
            suah.course_cd      = p_course_cd AND
            suah.uoo_id     = cp_uoo_id AND
            suah.hist_start_dt  = cp_hist_start_dt
        FOR UPDATE OF
            suah.LAST_UPDATE_DATE NOWAIT;
    v_suah_del_exists   c_suah_del%ROWTYPE;


BEGIN

    v_error_flag := FALSE;

    FOR v_suah_rec IN c_suah LOOP
          -- Delete IGS_EN_SU_ATTEMPT_H records
          FOR v_suah_del_exists IN c_suah_del(v_suah_rec.uoo_id, v_suah_rec.hist_start_dt) LOOP

            IGS_EN_SU_ATTEMPT_H_PKG.DELETE_ROW(
                X_ROWID => v_suah_del_exists.ROW_ID );
          END LOOP;
        END LOOP;

    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_suah%ISOPEN THEN
            CLOSE c_suah;
        END IF;
        IF c_suah_del%ISOPEN THEN
            CLOSE c_suah_del;
                END IF;
        l_entity_name := 'IGS_EN_SU_ATTEMPT_H';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_suah%ISOPEN THEN
            CLOSE c_suah;
        END IF;
        IF c_suah_del%ISOPEN THEN
            CLOSE c_suah_del;
                END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_suah');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_suah;

--------------------------------------------------------------------------------
-- ADMPL_DEL_SUSA --------------------------------------------------------------
--------------------------------------------------------------------------------
FUNCTION admpl_del_susa(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_susa
    -- (2) Delete IGS_AS_SU_SETATMPT records
DECLARE
    CURSOR c_susa IS
        SELECT
            susa.unit_set_cd,
            susa.sequence_number
        FROM    IGS_AS_SU_SETATMPT susa
        WHERE   susa.person_id      = p_person_id AND
            susa.course_cd      = p_course_cd
        START WITH
            susa.person_id      = p_person_id AND
            susa.course_cd      = p_course_cd AND
            susa.parent_unit_set_cd IS NULL
        CONNECT BY
        PRIOR   susa.person_id      = p_person_id AND
        PRIOR   susa.course_cd      = p_course_cd AND
        PRIOR   susa.unit_set_cd    = susa.parent_unit_set_cd AND
        PRIOR   susa.sequence_number    = susa.parent_sequence_number
        ORDER BY LEVEL DESC;
    CURSOR c_susa_del (
        cp_unit_set_cd      IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
        cp_sequence_number  IGS_AS_SU_SETATMPT.sequence_number%TYPE) IS
        SELECT ROWID, susa.*
        FROM    IGS_AS_SU_SETATMPT susa
        WHERE   susa.person_id      = p_person_id AND
            susa.course_cd      = p_course_cd AND
            susa.unit_set_cd    = cp_unit_set_cd AND
            susa.sequence_number    = cp_sequence_number
        FOR UPDATE OF
            susa.LAST_UPDATE_DATE NOWAIT;
    v_susa_del_exists   c_susa_del%ROWTYPE;


        CURSOR c_hes ( cp_unit_set_cd       IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
               cp_sequence_number   IGS_AS_SU_SETATMPT.sequence_number%TYPE) IS
        SELECT  hesa_en_susa_id
        FROM    IGS_HE_EN_SUSA hes
        WHERE   hes.person_id = p_person_id AND
            hes.course_cd = p_course_cd AND
                        hes.unit_set_cd = cp_unit_set_cd AND
                        hes.sequence_number = cp_sequence_number;

    CURSOR c_hes_del (
        cp_hesa_en_susa_id IGS_HE_EN_SUSA.hesa_en_susa_id%TYPE) IS
        SELECT rowid
        FROM    IGS_HE_EN_SUSA  hes
        WHERE   hes.hesa_en_susa_id = cp_hesa_en_susa_id
        FOR UPDATE OF hes.LAST_UPDATE_DATE NOWAIT ;

        CURSOR c_hesc ( cp_unit_set_cd      IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
               cp_sequence_number   IGS_AS_SU_SETATMPT.sequence_number%TYPE) IS
        SELECT  he_susa_cc_id
        FROM    IGS_HE_EN_SUSA_CC hesc
        WHERE   hesc.person_id = p_person_id AND
            hesc.course_cd = p_course_cd AND
                        hesc.unit_set_cd = cp_unit_set_cd AND
                        hesc.sequence_number = cp_sequence_number;

    CURSOR c_hesc_del (
        cp_he_susa_cc_id IGS_HE_EN_SUSA_CC.he_susa_cc_id%TYPE) IS
        SELECT rowid
        FROM    IGS_HE_EN_SUSA_CC hesc
        WHERE   hesc.he_susa_cc_id = cp_he_susa_cc_id
        FOR UPDATE OF hesc.LAST_UPDATE_DATE NOWAIT ;

        L_ROWID         VARCHAR2(25);
BEGIN
    v_error_flag := FALSE;

        -- Prevent admission application validation in database trigger
    -- Inserts a record into the s_disable_table_trigger
    -- database table.
    IGS_GE_S_DSB_TAB_TRG_PKG.INSERT_ROW(
        X_ROWID => L_ROWID ,
        X_TABLE_NAME =>'ADMP_DEL_SCA_UNCONF',
        X_SESSION_ID => userenv('SESSIONID'),
        x_mode => 'R'
        );

    FOR v_susa_rec IN c_susa LOOP

          FOR v_hes_rec IN c_hes (v_susa_rec.unit_set_cd, v_susa_rec.sequence_number )
              LOOP
                BEGIN
                        -- Delete unconfirmed IGS_HE_EN_SUSA records
                FOR v_hes_del_rec in c_hes_del(
                         v_hes_rec.hesa_en_susa_id) LOOP

                IGS_HE_EN_SUSA_PKG.DELETE_ROW(
                    X_ROWID => v_hes_del_rec.ROWID );

                END LOOP;
                        EXCEPTION
                WHEN e_resource_busy THEN
                    IF c_hes_del%ISOPEN THEN
                        CLOSE c_hes_del;
                    END IF;
                     l_entity_name := 'IGS_HE_EN_SUSA';
                    EXIT;
            END;

           END LOOP;

               FOR v_hesc_rec IN c_hesc (v_susa_rec.unit_set_cd, v_susa_rec.sequence_number )
               LOOP
                BEGIN
                        -- Delete unconfirmed IGS_HE_EN_SUSA_CC records
                FOR v_hesc_del_rec in c_hesc_del(
                         v_hesc_rec.he_susa_cc_id) LOOP

                IGS_HE_EN_SUSA_CC_PKG.DELETE_ROW(
                    X_ROWID => v_hesc_del_rec.ROWID );

                END LOOP;
                        EXCEPTION
                WHEN e_resource_busy THEN
                    IF c_hesc_del%ISOPEN THEN
                        CLOSE c_hesc_del;
                    END IF;
                     l_entity_name := 'IGS_HE_EN_SUSA_CC';
                    EXIT;
            END;

            END LOOP;

                IF l_entity_name IS NOT NULL THEN
            EXIT;
            END IF;

                -- Delete unconfirmed IGS_AS_SU_SETATMPT
        FOR v_susa_del_exists IN c_susa_del(
            v_susa_rec.unit_set_cd,
            v_susa_rec.sequence_number) LOOP
            IGS_AS_SU_SETATMPT_PKG.DELETE_ROW (
                X_ROWID => V_SUSA_DEL_EXISTS.ROWID );
        END LOOP;

    END LOOP;
    IF v_error_flag THEN
        -- Must reset database trigger validation if been turned off
        IGS_GE_MNT_SDTT.genp_del_sdtt(
                    'ADMP_DEL_SCA_UNCONF');
        RETURN FALSE;
    END IF;
    -- Must reset database trigger validation if been turned off
    IGS_GE_MNT_SDTT.genp_del_sdtt(
                'ADMP_DEL_SCA_UNCONF');

        IF l_entity_name IS NOT NULL THEN
       RETURN FALSE;
    END IF;

        RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_susa%ISOPEN THEN
            CLOSE c_susa;
        END IF;
        IF c_susa_del%ISOPEN THEN
            CLOSE c_susa_del;
        END IF;
                IF c_hes%ISOPEN THEN
            CLOSE c_hes;
        END IF;
        IF c_hes_del%ISOPEN THEN
            CLOSE c_hes_del;
        END IF;
                IF c_hesc%ISOPEN THEN
            CLOSE c_hesc;
        END IF;
        IF c_hesc_del%ISOPEN THEN
            CLOSE c_hesc_del;
        END IF;
        -- Must reset database trigger validation if been turned off
        IGS_GE_MNT_SDTT.genp_del_sdtt(
                    'ADMP_DEL_SCA_UNCONF');
                l_entity_name := 'IGS_AS_SU_SETATMPT';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_susa%ISOPEN THEN
            CLOSE c_susa;
        END IF;
        IF c_susa_del%ISOPEN THEN
            CLOSE c_susa_del;
        END IF;
                IF c_hes%ISOPEN THEN
            CLOSE c_hes;
        END IF;
        IF c_hes_del%ISOPEN THEN
            CLOSE c_hes_del;
        END IF;
        IF c_hesc%ISOPEN THEN
            CLOSE c_hesc;
        END IF;
        IF c_hesc_del%ISOPEN THEN
            CLOSE c_hesc_del;
        END IF;
                -- Must reset database trigger validation if been turned off
        IGS_GE_MNT_SDTT.genp_del_sdtt(
                    'ADMP_DEL_SCA_UNCONF');
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_susa');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_susa;
--------------------------------------------------------------------------------
-- ADMPL_DEL_SCHO --------------------------------------------------------------
--------------------------------------------------------------------------------
FUNCTION admpl_del_scho(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_scho
    -- (3) Delete IGS_EN_STDNTPSHECSOP records
DECLARE
    CURSOR c_scho IS
        SELECT  scho.start_dt
        FROM    IGS_EN_STDNTPSHECSOP scho
        WHERE   scho.person_id = p_person_id AND
            scho.course_cd = p_course_cd;
    CURSOR c_scho_del (
        cp_start_dt     IGS_EN_STDNTPSHECSOP.start_dt%TYPE) IS
        SELECT ROWID, scho.*
        FROM    IGS_EN_STDNTPSHECSOP scho
        WHERE   scho.person_id  = p_person_id AND
            scho.course_cd  = p_course_cd AND
            scho.start_dt   = cp_start_dt
        FOR UPDATE OF
            scho.LAST_UPDATE_DATE NOWAIT;
    v_scho_del_exists   c_scho_del%ROWTYPE;
BEGIN
    v_error_flag := FALSE;
    FOR v_scho_rec IN c_scho LOOP

        -- Delete unconfirmed IGS_EN_STDNTPSHECSOP
        FOR v_scho_del_exists IN c_scho_del(v_scho_rec.start_dt) LOOP
            IGS_EN_STDNTPSHECSOP_PKG.DELETE_ROW (
                X_ROWID => V_SCHO_DEL_EXISTS.ROWID );
        END LOOP;

    END LOOP;
    IF v_error_flag THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_scho%ISOPEN THEN
            CLOSE c_scho;
        END IF;
        IF c_scho_del%ISOPEN THEN
            CLOSE c_scho_del;
        END IF;
                l_entity_name := 'IGS_EN_STDNTPSHECSOP';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_scho%ISOPEN THEN
            CLOSE c_scho;
        END IF;
        IF c_scho_del%ISOPEN THEN
            CLOSE c_scho_del;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_scho');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_scho;
--------------------------------------------------------------------------------
-- ADMPL_DEL_SCAE --------------------------------------------------------------
--------------------------------------------------------------------------------
FUNCTION admpl_del_scae(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN  IS
BEGIN   -- admpl_del_scae
    -- (4) Delete IGS_AS_SC_ATMPT_ENR scae
DECLARE
    CURSOR c_scae IS
        SELECT ROWID, scae.*
        FROM    IGS_AS_SC_ATMPT_ENR scae
        WHERE   scae.person_id      = p_person_id AND
            scae.course_cd      = p_course_cd
        FOR UPDATE OF scae.LAST_UPDATE_DATE NOWAIT;
BEGIN
    FOR v_scae_rec IN c_scae
        LOOP
      IGS_AS_SC_ATMPT_ENR_PKG.DELETE_ROW(v_scae_rec.rowid);
    END LOOP;

    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_scae%ISOPEN THEN
            CLOSE c_scae;
        END IF;
                l_entity_name := 'IGS_AS_SC_ATMPT_ENR';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_scae%ISOPEN THEN
            CLOSE c_scae;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_scae');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_scae;
--------------------------------------------------------------------------------
-- ADMPL_DEL_SCAN --------------------------------------------------------------
--------------------------------------------------------------------------------
FUNCTION admpl_del_scan(
    p_person_id     IGS_AS_SC_ATMPT_NOTE.person_id%TYPE,
    p_course_cd     IGS_AS_SC_ATMPT_NOTE.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_scan
    -- Delete student IGS_PS_COURSE attempt notes (5)
DECLARE
    CURSOR c_scan IS
        SELECT ROWID, scan.*
        FROM    IGS_AS_SC_ATMPT_NOTE    scan
        WHERE   scan.person_id      = p_person_id AND
            scan.course_cd      = p_course_cd
        FOR UPDATE OF scan.reference_number NOWAIT;
BEGIN
    FOR v_scan_rec IN c_scan LOOP
      -- Call RI check routine for the IGS_AS_SC_ATMPT_NOTE table
      IGS_AS_SC_ATMPT_NOTE_PKG.DELETE_ROW(v_scan_rec.rowid);
    END LOOP;

    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_scan%ISOPEN THEN
            CLOSE c_scan;
        END IF;
                l_entity_name := 'IGS_AS_SC_ATMPT_NOTE';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_scan%ISOPEN THEN
            CLOSE c_scan;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_scan');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_scan;
--------------------------------------------------------------------------------
-- ADMPL_CHK_AS ----------------------------------------------------------------
--------------------------------------------------------------------------------
FUNCTION admpl_chk_as(
    p_person_id         IGS_AV_ADV_STANDING.person_id%TYPE,
    p_course_cd         IGS_AV_ADV_STANDING.course_cd%TYPE,
    p_s_adm_offer_resp_status   IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE,
    p_s_adm_offer_dfrmnt_status
                    IGS_AD_OFRDFRMT_STAT.s_adm_offer_dfrmnt_status%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_chk_as
        -- Advanced Standing record is NOT to be deleted since
        -- its parents are person and program-version and
        -- NOT program attempt
DECLARE
BEGIN
    v_message_name := NULL;
    v_default_msg := NULL;
    -- Do not clean up program attempt record for admission program application
    -- instances that have an approved advanced standing.
    IF NOT (p_s_adm_offer_resp_status = cst_deferral AND
            p_s_adm_offer_dfrmnt_status = cst_approved) THEN
        IF NOT IGS_AV_GEN_001.advp_del_adv_stnd(
                    p_person_id,
                    p_course_cd,
                    v_message_name,
                    v_default_msg) THEN
                  FND_MESSAGE.SET_NAME('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
          RETURN FALSE;
        END IF;
    END IF;
    RETURN TRUE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_chk_as');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_chk_as;
--------------------------------------------------------------------------------
-- ADMPL_UPD_RE_CANDIDATURE ------------------------------------------------------------
----
--------------------------------------------------------------------------------
FUNCTION admpl_upd_re_candidature(
    p_person_id         IGS_AV_ADV_STANDING.person_id%TYPE,
    p_course_cd         IGS_AV_ADV_STANDING.course_cd%TYPE,
    p_adm_admission_appl_number IGS_RE_CANDIDATURE.acai_admission_appl_number%TYPE,
    p_adm_nominated_course_cd   IGS_RE_CANDIDATURE.acai_nominated_course_cd%TYPE,
    p_adm_sequence_number       IGS_RE_CANDIDATURE.acai_sequence_number%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_upd_re_candidature
    -- Process IGS_RE_CANDIDATURE
DECLARE
    CURSOR c_ca IS
        SELECT  rowid, ca.*
        FROM    IGS_RE_CANDIDATURE  ca
        WHERE   ca.person_id            = p_person_id AND
            ca.sca_course_cd        = p_course_cd AND
            ca.acai_admission_appl_number   = p_adm_admission_appl_number AND
            ca.acai_nominated_course_cd = p_adm_nominated_course_cd AND
            ca.acai_sequence_number     = p_adm_sequence_number
        FOR UPDATE OF ca.sca_course_cd NOWAIT;
BEGIN
    FOR v_ca_rec IN c_ca LOOP

        IGS_RE_CANDIDATURE_PKG.UPDATE_ROW(
        X_ROWID             => V_CA_REC.ROWID,
        X_PERSON_ID             => V_CA_REC.PERSON_ID,
        X_SEQUENCE_NUMBER       => V_CA_REC.SEQUENCE_NUMBER,
        X_SCA_COURSE_CD         => NULL,
        X_ACAI_ADMISSION_APPL_NUMBER    => V_CA_REC.ACAI_ADMISSION_APPL_NUMBER,
        X_ACAI_NOMINATED_COURSE_CD  => V_CA_REC.ACAI_NOMINATED_COURSE_CD,
        X_ACAI_SEQUENCE_NUMBER      => V_CA_REC.ACAI_SEQUENCE_NUMBER,
        X_ATTENDANCE_PERCENTAGE     => V_CA_REC.ATTENDANCE_PERCENTAGE,
        X_GOVT_TYPE_OF_ACTIVITY_CD  => V_CA_REC.GOVT_TYPE_OF_ACTIVITY_CD,
        X_MAX_SUBMISSION_DT         => V_CA_REC.MAX_SUBMISSION_DT,
        X_MIN_SUBMISSION_DT         => V_CA_REC.MIN_SUBMISSION_DT,
        X_RESEARCH_TOPIC        => V_CA_REC.RESEARCH_TOPIC,
        X_INDUSTRY_LINKS        => V_CA_REC.INDUSTRY_LINKS );

    END LOOP;
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_ca%ISOPEN THEN
            CLOSE c_ca;
        END IF;
                l_entity_name := 'IGS_RE_CANDIDATURE_ALL';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_ca%ISOPEN THEN
            CLOSE c_ca;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_upd_re_candidature');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_upd_re_candidature;

--------------------------------------------------------------------------------
-- ADMPL_DEL_GUA ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_del_gua(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_gua
    -- Delete IGS_GR_GRADUAND_PKG records
DECLARE
    CURSOR c_gua IS
        SELECT  create_dt
        FROM    IGS_GR_GRADUAND_ALL gua
        WHERE   gua.person_id = p_person_id AND
            gua.course_cd = p_course_cd;
    CURSOR c_gua_del (
        cp_create_dt        IGS_GR_GRADUAND_ALL.create_dt%TYPE) IS
        SELECT rowid
        FROM    IGS_GR_GRADUAND_ALL     gua
        WHERE   gua.person_id       = p_person_id AND
            gua.create_dt       = cp_create_dt
        FOR UPDATE OF gua.LAST_UPDATE_DATE NOWAIT ;

    v_gua_del_exists    c_gua_del%ROWTYPE;

    CURSOR c_gach (
        cp_create_dt        IGS_GR_AWD_CRMN_HIST.create_dt%TYPE)  IS
        SELECT  gach.gach_id
        FROM    IGS_GR_AWD_CRMN_HIST gach
        WHERE   gach.person_id      = p_person_id AND
            gach.create_dt      = cp_create_dt;
    CURSOR c_gach_del (
        cp_gach_id      IGS_GR_AWD_CRMN_HIST.gach_id%TYPE) IS
        SELECT rowid
        FROM    IGS_GR_AWD_CRMN_HIST    gach
        WHERE   gach.gach_id        = cp_gach_id
        FOR UPDATE OF gach.LAST_UPDATE_DATE NOWAIT ;



        CURSOR c_gac (
        cp_create_dt        IGS_GR_AWD_CRMN.create_dt%TYPE) IS
        SELECT  gac.gac_id
        FROM    IGS_GR_AWD_CRMN gac
        WHERE   gac.person_id       = p_person_id AND
            gac.create_dt       = cp_create_dt;
    CURSOR c_gac_del (
        cp_gac_id       IGS_GR_AWD_CRMN.gac_id%TYPE) IS
        SELECT rowid
        FROM    IGS_GR_AWD_CRMN     gac
        WHERE   gac.gac_id      = cp_gac_id
        FOR UPDATE OF gac.LAST_UPDATE_DATE NOWAIT ;


BEGIN
    v_error_flag := FALSE;

    FOR v_gua_rec IN c_gua LOOP
        FOR v_gach_rec IN c_gach (v_gua_rec.create_dt) LOOP
                BEGIN
                        -- Delete unconfirmed IGS_GR_AWD_CRMN_HIST records
                FOR c_gach_del_rec in c_gach_del(
                         v_gach_rec.gach_id) LOOP

                IGS_GR_AWD_CRMN_HIST_PKG.DELETE_ROW(
                    X_ROWID => c_gach_del_rec.ROWID );

                END LOOP;
                        EXCEPTION
                WHEN e_resource_busy THEN
                    IF c_gach_del%ISOPEN THEN
                        CLOSE c_gach_del;
                    END IF;
                                        l_entity_name := 'IGS_GR_AWD_CRMN_HIST';
                    EXIT;
            END;

        END LOOP;
        IF l_entity_name IS NOT NULL THEN
            EXIT;
        END IF;

                FOR v_gca_rec IN c_gac(v_gua_rec.create_dt) LOOP
              BEGIN
                          -- Delete unconfirmed IGS_GR_AWD_CRMN records
                FOR c_gac_del_rec IN c_gac_del(
                         v_gca_rec.gac_id) LOOP

                IGS_GR_AWD_CRMN_PKG.DELETE_ROW(
                    X_ROWID => c_gac_del_rec.ROWID );

                END LOOP;
                           EXCEPTION
                WHEN e_resource_busy THEN
                    IF c_gac_del%ISOPEN THEN
                        CLOSE c_gac_del;
                    END IF;
                                        l_entity_name := 'IGS_GR_AWD_CRMN';
                    EXIT;
              END;
        END LOOP;

                IF l_entity_name IS NOT NULL THEN
            EXIT;
        END IF;
        -- Delete unconfirmed IGS_GR_GRADUAND records
        FOR v_gua_del_exists IN c_gua_del(v_gua_rec.create_dt) LOOP
            IGS_GR_GRADUAND_PKG.DELETE_ROW(
                X_ROWID => v_gua_del_exists.rowid );
        END LOOP;

    END LOOP;
    IF l_entity_name IS NOT NULL THEN
            RETURN FALSE;
    END IF;
    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_gua%ISOPEN THEN
            CLOSE c_gua;
        END IF;
        IF c_gua_del%ISOPEN THEN
            CLOSE c_gua_del;
        END IF;
        IF c_gach%ISOPEN THEN
            CLOSE c_gach;
        END IF;
        IF c_gach_del%ISOPEN THEN
            CLOSE c_gach_del;
        END IF;
                IF c_gac%ISOPEN THEN
            CLOSE c_gac;
        END IF;
        IF c_gac_del%ISOPEN THEN
            CLOSE c_gac_del;
        END IF;
                l_entity_name := 'IGS_GR_GRADUAND_ALL';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_gua%ISOPEN THEN
            CLOSE c_gua;
        END IF;
        IF c_gua_del%ISOPEN THEN
            CLOSE c_gua_del;
        END IF;
        IF c_gach%ISOPEN THEN
            CLOSE c_gach;
        END IF;
        IF c_gach_del%ISOPEN THEN
            CLOSE c_gach_del;
        END IF;
                IF c_gac%ISOPEN THEN
            CLOSE c_gac;
        END IF;
        IF c_gac_del%ISOPEN THEN
            CLOSE c_gac_del;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_gua');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_gua;
--------------------------------------------------------------------------------
-- ADMPL_DEL_GSA ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_del_gsa(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_gsa
    -- (1) Delete IGS_GR_SPECIAL_AWARD records
DECLARE
    CURSOR c_gsa IS
        SELECT  award_cd,
                        award_dt
        FROM    IGS_GR_SPECIAL_AWARD_ALL gsa
        WHERE   gsa.person_id = p_person_id AND
            gsa.course_cd = p_course_cd;

    CURSOR c_gsa_del (
        cp_award_cd         IGS_GR_SPECIAL_AWARD_ALL.award_cd%TYPE,
                cp_award_dt         IGS_GR_SPECIAL_AWARD_ALL.award_dt%TYPE) IS
        SELECT rowid
        FROM    IGS_GR_SPECIAL_AWARD_ALL    gsa
        WHERE   gsa.person_id = p_person_id AND
            gsa.course_cd = p_course_cd AND
                        gsa.award_cd  = cp_award_cd AND
                        gsa.award_dt  = cp_award_dt
        FOR UPDATE OF gsa.LAST_UPDATE_DATE NOWAIT ;

    v_gsa_del_exists    c_gsa_del%ROWTYPE;


BEGIN
    v_error_flag := FALSE;

    FOR v_gsa_rec IN c_gsa LOOP

          FOR v_gsa_del_exists IN c_gsa_del(v_gsa_rec.award_cd,
                                            v_gsa_rec.award_dt ) LOOP
            IGS_GR_SPECIAL_AWARD_PKG.DELETE_ROW(
                X_ROWID => v_gsa_del_exists.rowid );
          END LOOP;
        END LOOP;

    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_gsa%ISOPEN THEN
            CLOSE c_gsa;
        END IF;
        IF c_gsa_del%ISOPEN THEN
            CLOSE c_gsa_del;
                END IF;
                l_entity_name := 'IGS_GR_SPECIAL_AWARD_ALL';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_gsa%ISOPEN THEN
            CLOSE c_gsa;
        END IF;
        IF c_gsa_del%ISOPEN THEN
            CLOSE c_gsa_del;
                END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_gsa');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_gsa;

FUNCTION admpl_del_psaa(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_psaa
    -- Delete IGS_PS_STDNT_APV_ALT records
DECLARE
    CURSOR c_psaa IS
        SELECT  exit_course_cd,
                        exit_version_number
        FROM    IGS_PS_STDNT_APV_ALT psaa
        WHERE   psaa.person_id = p_person_id AND
            psaa.course_cd = p_course_cd;

    CURSOR c_psaa_del (
        cp_exit_course_cd   IGS_PS_STDNT_APV_ALT.exit_course_cd%TYPE,
                cp_exit_version_number  IGS_PS_STDNT_APV_ALT.exit_version_number%TYPE) IS
        SELECT rowid
        FROM    IGS_PS_STDNT_APV_ALT    psaa
        WHERE   psaa.person_id = p_person_id AND
            psaa.course_cd = p_course_cd AND
                        psaa.exit_course_cd  = cp_exit_course_cd AND
                        psaa.exit_version_number  = cp_exit_version_number
        FOR UPDATE OF psaa.LAST_UPDATE_DATE NOWAIT ;

    v_psaa_del_exists   c_psaa_del%ROWTYPE;


BEGIN
    v_error_flag := FALSE;

    FOR v_psaa_rec IN c_psaa LOOP
          -- Delete IGS_PS_STDNT_APV_ALT records
          FOR v_psaa_del_exists IN c_psaa_del(v_psaa_rec.exit_course_cd,
                                            v_psaa_rec.exit_version_number ) LOOP
            IGS_PS_STDNT_APV_ALT_PKG.DELETE_ROW(
                X_ROWID => v_psaa_del_exists.rowid );
          END LOOP;
        END LOOP;

    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_psaa%ISOPEN THEN
            CLOSE c_psaa;
        END IF;
        IF c_psaa_del%ISOPEN THEN
            CLOSE c_psaa_del;
                END IF;
                l_entity_name := 'IGS_PS_STDNT_APV_ALT';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_psaa%ISOPEN THEN
            CLOSE c_psaa;
        END IF;
        IF c_psaa_del%ISOPEN THEN
            CLOSE c_psaa_del;
                END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_psaa');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_psaa;
--------------------------------------------------------------------------------
-- ADMPL_DEL_PSSR ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_del_pssr(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_pssr
    -- Delete IGS_PS_STDNT_SPL_REQ records
DECLARE
    CURSOR c_pssr IS
        SELECT  special_requirement_cd,
                        completed_dt
        FROM    IGS_PS_STDNT_SPL_REQ pssr
        WHERE   pssr.person_id = p_person_id AND
            pssr.course_cd = p_course_cd;

    CURSOR c_pssr_del (
        cp_special_requirement_cd IGS_PS_STDNT_SPL_REQ.special_requirement_cd%TYPE,
                cp_completed_dt       IGS_PS_STDNT_SPL_REQ.completed_dt%TYPE) IS
        SELECT rowid
        FROM    IGS_PS_STDNT_SPL_REQ    pssr
        WHERE   pssr.person_id = p_person_id AND
            pssr.course_cd = p_course_cd AND
                        pssr.special_requirement_cd  = cp_special_requirement_cd AND
                        pssr.completed_dt  = cp_completed_dt
        FOR UPDATE OF pssr.LAST_UPDATE_DATE NOWAIT ;

    v_pssr_del_exists   c_pssr_del%ROWTYPE;


BEGIN
    v_error_flag := FALSE;

    FOR v_pssr_rec IN c_pssr LOOP
          -- Delete IGS_PS_STDNT_SPL_REQ records
          FOR v_pssr_del_exists IN c_pssr_del(v_pssr_rec.special_requirement_cd,
                                            v_pssr_rec.completed_dt ) LOOP
            IGS_PS_STDNT_SPL_REQ_PKG.DELETE_ROW(
                X_ROWID => v_pssr_del_exists.rowid );
          END LOOP;
        END LOOP;

    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_pssr%ISOPEN THEN
            CLOSE c_pssr;
        END IF;
        IF c_pssr_del%ISOPEN THEN
            CLOSE c_pssr_del;
                END IF;
                l_entity_name := 'IGS_PS_STDNT_SPL_REQ';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_pssr%ISOPEN THEN
            CLOSE c_pssr;
        END IF;
        IF c_pssr_del%ISOPEN THEN
            CLOSE c_pssr_del;
                END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_pssr');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_pssr;

--------------------------------------------------------------------------------
-- ADMPL_DEL_ESAA ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_del_esaa(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_esaa
    -- Delete IGS_EN_SPA_AWD_AIM records
DECLARE
    CURSOR c_esaa IS
        SELECT  award_cd
        FROM    IGS_EN_SPA_AWD_AIM esaa
        WHERE   esaa.person_id = p_person_id AND
            esaa.course_cd = p_course_cd;

    CURSOR c_esaa_del (
        cp_award_cd IGS_EN_SPA_AWD_AIM.award_cd%TYPE) IS
        SELECT rowid
        FROM    IGS_EN_SPA_AWD_AIM  esaa
        WHERE   esaa.person_id = p_person_id AND
            esaa.course_cd = p_course_cd AND
                        esaa.award_cd  = cp_award_cd
        FOR UPDATE OF esaa.LAST_UPDATE_DATE NOWAIT ;

    v_esaa_del_exists   c_esaa_del%ROWTYPE;


BEGIN
    v_error_flag := FALSE;

    FOR v_esaa_rec IN c_esaa LOOP
          -- Delete IGS_EN_SPA_AWD_AIM records
          FOR v_esaa_del_exists IN c_esaa_del(v_esaa_rec.award_cd) LOOP
            IGS_EN_SPA_AWD_AIM_PKG.DELETE_ROW(
                X_ROWID => v_esaa_del_exists.rowid );
          END LOOP;
        END LOOP;

    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_esaa%ISOPEN THEN
            CLOSE c_esaa;
        END IF;
        IF c_esaa_del%ISOPEN THEN
            CLOSE c_esaa_del;
                END IF;
                l_entity_name := 'IGS_EN_SPA_AWD_AIM';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_esaa%ISOPEN THEN
            CLOSE c_esaa;
        END IF;
        IF c_esaa_del%ISOPEN THEN
            CLOSE c_esaa_del;
                END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_esaa');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_esaa;

--------------------------------------------------------------------------------
-- ADMPL_DEL_HSSA ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_del_hssa(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_hssa
    -- Delete IGS_HE_ST_SPA_ALL records
DECLARE
    CURSOR c_hssa IS
        SELECT  hesa_st_spa_id,
                        person_id,
                        course_cd
        FROM    IGS_HE_ST_SPA_ALL hssa
        WHERE   hssa.person_id = p_person_id AND
            hssa.course_cd = p_course_cd;

    CURSOR c_hssa_del (
        cp_hesa_st_spa_id IGS_HE_ST_SPA_ALL.hesa_st_spa_id%TYPE) IS
        SELECT rowid
        FROM    IGS_HE_ST_SPA_ALL   hssa
        WHERE   hssa.hesa_st_spa_id = cp_hesa_st_spa_id
        FOR UPDATE OF hssa.LAST_UPDATE_DATE NOWAIT ;

    v_hssa_del_exists   c_hssa_del%ROWTYPE;

        CURSOR c_hssua (
        cp_person_id IGS_HE_ST_SPA_UT_ALL.person_id%TYPE,
                cp_course_cd IGS_HE_ST_SPA_ALL.course_cd%TYPE) IS
        SELECT  hesa_st_spau_id
        FROM    IGS_HE_ST_SPA_UT_ALL hssua
        WHERE   hssua.person_id  = cp_person_id AND
                        hssua.course_cd  = cp_course_cd ;

    CURSOR c_hssua_del (
        cp_hesa_st_spau_id IGS_HE_ST_SPA_UT_ALL.hesa_st_spau_id%TYPE) IS
        SELECT rowid
        FROM    IGS_HE_ST_SPA_UT_ALL    hssua
        WHERE   hssua.hesa_st_spau_id = cp_hesa_st_spau_id
        FOR UPDATE OF hssua.LAST_UPDATE_DATE NOWAIT ;


BEGIN
    v_error_flag := FALSE;

    FOR v_hssa_rec IN c_hssa LOOP

               FOR v_hssua_rec IN c_hssua (v_hssa_rec.person_id,
                                           v_hssa_rec.course_cd ) LOOP
               BEGIN
                        -- Delete unconfirmed IGS_HE_ST_SPA_UT_ALL records
                FOR v_hssua_del_rec in c_hssua_del(
                         v_hssua_rec.hesa_st_spau_id) LOOP
                        IGS_HE_ST_SPA_UT_ALL_PKG.DELETE_ROW(
                            X_ROWID => v_hssua_del_rec.ROWID );

                END LOOP;
                        EXCEPTION
                WHEN e_resource_busy THEN
                    IF c_hssua_del%ISOPEN THEN
                        CLOSE c_hssua_del;
                    END IF;
                                        l_entity_name := 'IGS_HE_ST_SPA_UT_ALL';
                    EXIT;
            END;

        END LOOP;
        IF l_entity_name IS NOT NULL THEN
            EXIT;
        END IF;

          -- Delete IGS_HE_ST_SPA_ALL records
          FOR v_hssa_del_exists IN c_hssa_del(v_hssa_rec.hesa_st_spa_id) LOOP

            IGS_HE_ST_SPA_ALL_PKG.DELETE_ROW(
                X_ROWID => v_hssa_del_exists.rowid );
          END LOOP;

        END LOOP;

        IF l_entity_name IS NOT NULL THEN
          RETURN FALSE;
    END IF;
    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_hssa%ISOPEN THEN
            CLOSE c_hssa;
        END IF;
        IF c_hssa_del%ISOPEN THEN
            CLOSE c_hssa_del;
                END IF;
        IF c_hssua%ISOPEN THEN
               CLOSE c_hssua;
        END IF;
                IF c_hssua_del%ISOPEN THEN
               CLOSE c_hssua_del;
        END IF;
                l_entity_name := 'IGS_HE_ST_SPA_ALL';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_hssa%ISOPEN THEN
            CLOSE c_hssa;
        END IF;
        IF c_hssa_del%ISOPEN THEN
            CLOSE c_hssa_del;
                END IF;
        IF c_hssua%ISOPEN THEN
               CLOSE c_hssua;
        END IF;
                IF c_hssua_del%ISOPEN THEN
               CLOSE c_hssua_del;
        END IF;
                App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_hssa');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_hssa;

--------------------------------------------------------------------------------
-- ADMPL_UPD_PR_RULE_APPL ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_upd_pr_rule_appl(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_upd_pr_rule_appl
    -- Delete IGS_PR_RU_APPL_ALL records
DECLARE
    CURSOR c_pra IS
        SELECT  progression_rule_cat,
                        sequence_number
        FROM    IGS_PR_RU_APPL_ALL pra
        WHERE   pra.sca_person_id = p_person_id AND
            pra.sca_course_cd = p_course_cd;

    CURSOR c_pra_del (
        cp_progression_rule_cat     IGS_PR_RU_APPL_ALL.progression_rule_cat%TYPE,
                cp_sequence_number  IGS_PR_RU_APPL_ALL.sequence_number%TYPE) IS
        SELECT  rowid,pra.*
        FROM    IGS_PR_RU_APPL_ALL  pra
        WHERE   pra.progression_rule_cat = cp_progression_rule_cat AND
            pra.sequence_number = cp_sequence_number
        FOR UPDATE OF pra.LAST_UPDATE_DATE NOWAIT ;

    v_pra_upd_exists    c_pra_del%ROWTYPE;


BEGIN
    v_error_flag := FALSE;

    FOR v_pra_rec IN c_pra LOOP
          -- Delete IGS_PR_RU_APPL_ALL records
          FOR v_pra_upd_exists IN c_pra_del(v_pra_rec.progression_rule_cat,
                                            v_pra_rec.sequence_number ) LOOP
            IGS_PR_RU_APPL_PKG.UPDATE_ROW (
                                        X_ROWID => v_pra_upd_exists.rowid,
                                        X_PROGRESSION_RULE_CAT => v_pra_upd_exists.progression_rule_cat ,
                                        X_SEQUENCE_NUMBER => v_pra_upd_exists.sequence_number,
                                        X_S_RELATION_TYPE => v_pra_upd_exists.s_relation_type,
                                        X_PROGRESSION_RULE_CD => v_pra_upd_exists.progression_rule_cd,
                                        X_REFERENCE_CD => v_pra_upd_exists.reference_cd,
                                        X_RUL_SEQUENCE_NUMBER => v_pra_upd_exists.rul_sequence_number,
                                        X_ATTENDANCE_TYPE => v_pra_upd_exists.attendance_type,
                                        X_OU_ORG_UNIT_CD => v_pra_upd_exists.ou_org_unit_cd,
                                        X_OU_START_DT => v_pra_upd_exists.ou_start_dt,
                                        X_COURSE_TYPE => v_pra_upd_exists.course_type,
                                        X_CRV_COURSE_CD => v_pra_upd_exists.crv_course_cd,
                                        X_CRV_VERSION_NUMBER => v_pra_upd_exists.crv_version_number,
                                        X_SCA_PERSON_ID => v_pra_upd_exists.sca_person_id,
                                        X_SCA_COURSE_CD => v_pra_upd_exists.sca_course_cd,
                                        X_PRO_PROGRESSION_RULE_CAT => v_pra_upd_exists.pro_progression_rule_cat,
                                        X_PRO_PRA_SEQUENCE_NUMBER => v_pra_upd_exists.pro_pra_sequence_number,
                                        X_PRO_SEQUENCE_NUMBER => v_pra_upd_exists.pro_sequence_number,
                                        X_SPO_PERSON_ID => v_pra_upd_exists.spo_person_id,
                                        X_SPO_COURSE_CD => v_pra_upd_exists.spo_course_cd,
                                        X_SPO_SEQUENCE_NUMBER => v_pra_upd_exists.spo_sequence_number,
                                        X_LOGICAL_DELETE_DT => TRUNC(SYSDATE),
                                        X_MESSAGE => v_pra_upd_exists.message,
                                        X_MODE => 'R',
                                        X_MIN_CP => v_pra_upd_exists.min_cp,
                                        X_MAX_CP => v_pra_upd_exists.max_cp,
                                        X_IGS_PR_CLASS_STD_ID => v_pra_upd_exists.igs_pr_class_std_id
                                      ) ;
          END LOOP;
        END LOOP;

    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_pra%ISOPEN THEN
            CLOSE c_pra;
        END IF;
        IF c_pra_del%ISOPEN THEN
            CLOSE c_pra_del;
                END IF;
                l_entity_name := 'IGS_PR_RU_APPL_ALL';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_pra%ISOPEN THEN
            CLOSE c_pra;
        END IF;
        IF c_pra_del%ISOPEN THEN
            CLOSE c_pra_del;
                END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_upd_pr_rule_appl');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_upd_pr_rule_appl;

--------------------------------------------------------------------------------
-- ADMPL_DEL_HSSC ---------------------------------------------------------------
--Who         When            What
--------------------------------------------------------------------------------
FUNCTION admpl_del_hssc(
    p_person_id     IGS_EN_STDNT_PS_ATT.person_id%TYPE,
    p_course_cd     IGS_EN_STDNT_PS_ATT.course_cd%TYPE)
RETURN BOOLEAN
IS
BEGIN   -- admpl_del_hssc
    -- Delete IGS_HE_ST_SPA_CC records
DECLARE
    CURSOR c_hssc IS
        SELECT  he_spa_cc_id
        FROM    IGS_HE_ST_SPA_CC hssc
        WHERE   hssc.person_id = p_person_id AND
            hssc.course_cd = p_course_cd;

    CURSOR c_hssc_del (cp_he_spa_cc_id  IGS_HE_ST_SPA_CC.he_spa_cc_id%TYPE) IS
        SELECT rowid
        FROM    IGS_HE_ST_SPA_CC    hssc
        WHERE   hssc.he_spa_cc_id = cp_he_spa_cc_id
        FOR UPDATE OF hssc.LAST_UPDATE_DATE NOWAIT ;

    v_hssc_del_exists   c_hssc_del%ROWTYPE;


BEGIN

    v_error_flag := FALSE;

    FOR v_hssc_rec IN c_hssc LOOP
          -- Delete IGS_HE_ST_SPA_CC records
          FOR v_hssc_del_exists IN c_hssc_del(v_hssc_rec.he_spa_cc_id) LOOP

            IGS_HE_ST_SPA_CC_PKG.DELETE_ROW(
                X_ROWID => v_hssc_del_exists.ROWID );
          END LOOP;
        END LOOP;

    -- Return the default value
    RETURN TRUE;
EXCEPTION
    WHEN e_resource_busy THEN
        IF c_hssc%ISOPEN THEN
            CLOSE c_hssc;
        END IF;
        IF c_hssc_del%ISOPEN THEN
            CLOSE c_hssc_del;
                END IF;
        l_entity_name := 'IGS_HE_ST_SPA_CC';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_hssc%ISOPEN THEN
            CLOSE c_hssc;
        END IF;
        IF c_hssc_del%ISOPEN THEN
            CLOSE c_hssc_del;
                END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admpl_del_hssc');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admpl_del_hssc;

BEGIN
    -- Create log
    IGS_GE_GEN_003.genp_ins_log (
            cst_del_un_sca,
            NULL,       -- Key
            v_log_creation_dt);
        -- Issue commit since the the child IGS_GE_S_LOG_ENTRY is populated
        -- in autonomous transaction mode and would need to reference the
        -- parent record in check child existance
        COMMIT;

        -- Determine the enrolment period cleanup dates that are on this date.
    -- Determine admission periods linked as superiors to the enrolment period
    FOR v_cir_rec IN c_cir
        LOOP
        -- Delete unconfirmed student IGS_PS_COURSE attempts that have been withdrawn
        -- or revoked, or have been made offers and rejected or lapsed.
        FOR v_sca_rec IN c_sca(
                    v_cir_rec.sup_cal_type,
                    v_cir_rec.sup_ci_sequence_number)
                LOOP

            OPEN c_term (v_sca_rec.person_id, v_sca_rec.course_cd);
	    FETCH c_term INTO l_term;

	    IF c_term%NOTFOUND THEN

	    -- Initialise variables before processing next student IGS_PS_COURSE attempt
                        l_entity_name := NULL;
            v_process_next := FALSE;
            v_delete_sca_ind := 'Y';
            v_key :=
                v_sca_rec.acad_cal_type || '|' ||
                IGS_GE_NUMBER.TO_CANN(v_sca_rec.acad_ci_sequence_number) || '|' ||
                v_sca_rec.adm_cal_type || '|' ||
                IGS_GE_NUMBER.TO_CANN(v_sca_rec.adm_ci_sequence_number) || '|' ||
                v_sca_rec.admission_cat || '|' ||
                v_sca_rec.s_admission_process_type || '|' ||
                IGS_GE_NUMBER.TO_CANN(v_sca_rec.person_id) || '|' ||
                v_sca_rec.course_cd;
                        igs_ge_msg_stack.initialize;
                        l_msg_at_index := igs_ge_msg_stack.count_msg;

               BEGIN   -- c_sca_upd_block
                OPEN c_sca_upd(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd);
                FETCH c_sca_upd INTO v_sca_upd_exists;

                SAVEPOINT sp_sca_del;
                -- Delete child records

                                -- Delete IGS_GR_GRADUAND Records (1)
                    IF NOT v_process_next THEN
                                        IF NOT admpl_del_gua(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;

                                -- Delete IGS_EN_SPA_AWD_AIM Records (2)
                                IF NOT v_process_next THEN
                                        IF NOT admpl_del_esaa(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;

                                -- Delete IGS_GR_SPECIAL_AWARD Records (3)
                                IF NOT v_process_next THEN
                                        IF NOT admpl_del_gsa(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;

                                -- Delete IGS_HE_ST_SPA_CC Records (4)
                                IF NOT v_process_next THEN
                                        IF NOT admpl_del_hssc(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;

                                -- Delete IGS_HE_ST_SPA_ALL Records (5)
                                IF NOT v_process_next THEN
                                        IF NOT admpl_del_hssa(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;

                                -- Update setup of progression rule application
                                -- record's logical_delete_date to TRUNC(current system date) (6)
                                IF NOT v_process_next THEN
                                        IF NOT admpl_upd_pr_rule_appl(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;

                                -- Delete IGS_PS_STDNT_APV_ALT Records (7)
                                IF NOT v_process_next THEN
                                        IF NOT admpl_del_psaa(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;

                                -- Delete IGS_PS_STDNT_SPL_REQ Records (8)
                                -- Do not need to handle as record cannot be created
                                -- if program attempt is unconfirmed
                                /*
                                IF NOT v_process_next THEN
                                        IF NOT admpl_del_pssr(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                                END IF;
                                */

                                -- Delete IGS_EN_SU_ATTEMPT_H (9)
                IF NOT v_process_next THEN
                        IF NOT admpl_del_suah(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                END IF;

                                -- Delete IGS_EN_SU_ATTEMPT (10)
                IF NOT v_process_next THEN
                        IF NOT admpl_del_sua(
                        v_sca_rec.person_id,
                        v_sca_rec.course_cd) THEN
                            ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                            v_process_next := TRUE;
                        END IF;
                END IF;

                                -- Delete IGS_AS_SU_SETATMPT (11)
                IF NOT v_process_next THEN
                    IF NOT admpl_del_susa(
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd) THEN
                        ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                        v_process_next := TRUE;
                    END IF;
                END IF;

                                -- Delete IGS_EN_STDNTPSHECSOP (12)
                IF NOT v_process_next THEN
                    IF NOT admpl_del_scho(
                                v_sca_rec.person_id,
                                v_sca_rec.course_cd) THEN
                        ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                        v_process_next := TRUE;
                    END IF;
                END IF;

                                -- Delete IGS_AS_SC_ATMPT_ENR (13)
                IF NOT v_process_next THEN
                    IF NOT admpl_del_scae(
                                v_sca_rec.person_id,
                                v_sca_rec.course_cd) THEN
                        ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                        v_process_next := TRUE;
                    END IF;
                END IF;

                                -- Delete from student_course_attempt_notes (14)
                IF NOT v_process_next THEN
                    IF NOT admpl_del_scan (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd) THEN
                        ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                        v_process_next := TRUE;
                    END IF;
                END IF;

                                -- Update research candidature (15)
                IF NOT v_process_next THEN
                    IF NOT admpl_upd_re_candidature (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd,
                            v_sca_rec.adm_admission_appl_number,
                            v_sca_rec.adm_nominated_course_cd,
                            v_sca_rec.adm_sequence_number) THEN
                        ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                        v_process_next := TRUE;
                    END IF;
                END IF;

                                -- Check for approved advanced standing (16)
                IF NOT v_process_next THEN
                    IF NOT admpl_chk_as (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd,
                            v_sca_rec.s_adm_offer_resp_status,
                            v_sca_rec.s_adm_offer_dfrmnt_status) THEN
                        ROLLBACK TO sp_sca_del;
                            -- Process next entity for the current program attempt
                        v_process_next := TRUE;
                    END IF;
                END IF;

                                -- Process fees, routine performs its own logging (17)
                    IF NOT v_process_next THEN
                    IGS_FI_GEN_004.finp_prc_sca_unconf (
                            v_sca_rec.person_id,
                            v_sca_rec.course_cd,
                            v_sca_rec.course_attempt_status,
                            v_sca_rec.fee_cat,
                            v_log_creation_dt,
                            v_key,
                            v_sca_rec.admission_appl_number,
                            v_sca_rec.nominated_course_cd,
                            v_sca_rec.sequence_number,
                            v_fee_ass_log_creation_dt,
                            v_delete_sca_ind);
                 END IF;

                 -- Validate if student program attempt can be deleted
                                 IF NOT v_process_next AND v_delete_sca_ind = 'Y' THEN
                                     IGS_EN_STDNT_PS_ATT_PKG.DELETE_ROW(v_sca_upd_exists.rowid);
                                     admpl_del_ins_log_entry (
                                                              p_message_name     => NULL,
                                                              p_default_msg_txt  => NULL,
                                                              p_sca_deleted_ind  => 'Y',
                                                              p_log_creation_dt => v_log_creation_dt,
                                                              p_key => v_key,
                                                              p_s_log_type => cst_del_un_sca);
                                 ELSE
                                     IF l_entity_name IS NOT NULL THEN
                                       FND_MESSAGE.SET_NAME('IGS','IGS_AD_UNCONF_SCA_REC_LOCKED');
                                       FND_MESSAGE.SET_TOKEN('ENTITY',l_entity_name);
                                       IGS_GE_MSG_STACK.ADD;
                                     END IF;
                         extract_msg_from_stack(l_msg_at_index);
                 END IF;

                                 CLOSE c_sca_upd;
            EXCEPTION
                WHEN e_resource_busy THEN
                                        l_entity_name := 'IGS_EN_STDNT_PS_ATT_ALL';
                                        FND_MESSAGE.SET_NAME('IGS','IGS_AD_UNCONF_SCA_REC_LOCKED');
                                        FND_MESSAGE.SET_TOKEN('ENTITY',l_entity_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        extract_msg_from_stack(l_msg_at_index);
                                        ROLLBACK TO sp_sca_del;
                WHEN e_savepoint_lost THEN
                    IF c_sca_upd%ISOPEN THEN
                        CLOSE c_sca_upd;
                    END IF;
                                        extract_msg_from_stack(l_msg_at_index);
                                        ROLLBACK TO sp_sca_del;
                WHEN OTHERS THEN
                    IF c_sca_upd%ISOPEN THEN
                        CLOSE c_sca_upd;
                    END IF;
                                        extract_msg_from_stack(l_msg_at_index);
                                        ROLLBACK TO sp_sca_del;
            END;        -- c_sca_upd_block

	   ELSE
	      fnd_file.put_line(fnd_file.log, 'Cannot delete unconfirm Student Program Attempt for Person ID:'|| l_term.person_id||
	                                   ' and Course Code: '|| l_term.program_cd);
           END IF;
	   CLOSE c_term;

        END LOOP;   -- c_sca
    END LOOP;   -- c_cir
    p_log_creation_dt := v_log_creation_dt;
    COMMIT;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        IF c_sca%ISOPEN THEN
            CLOSE c_sca;
        END IF;
        IF c_sca_upd%ISOPEN THEN
            CLOSE c_sca_upd;
        END IF;
        IF c_cir%ISOPEN THEN
            CLOSE c_cir;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_001.admp_del_sca_unconf');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_del_sca_unconf;

PROCEDURE Set_Token(Token Varchar2)

IS

BEGIN

FND_MESSAGE.SET_TOKEN('ADM',Token);

END Set_Token;

PROCEDURE Check_Mand_Person_Type
(
  p_person_id       IN HZ_PARTIES.PARTY_ID%TYPE,
  p_data_element    IN IGS_PE_STUP_DATA_EMT_ALL.data_element%TYPE,
  p_required_ind    OUT NOCOPY IGS_PE_STUP_DATA_EMT_ALL.required_ind%TYPE
)
IS
Cursor per_type IS
SELECT person_type_code
FROM   igs_pe_typ_instances
WHERE  person_id = p_person_id
AND    sysdate BETWEEN start_date AND NVL(end_date, sysdate);

CURSOR per_type_req_man_upd (cp_person_type_code IGS_PE_STUP_DATA_EMT.PERSON_TYPE_CODE%TYPE) IS
SELECT 'x'
FROM   igs_pe_stup_data_emt
WHERE  person_type_code = cp_person_type_code
AND    UPPER(data_element) = UPPER(p_data_element)
AND    required_ind = 'M';

CURSOR per_type_req_pre_upd (cp_person_type_code IGS_PE_STUP_DATA_EMT.PERSON_TYPE_CODE%TYPE) IS
SELECT 'x'
FROM   igs_pe_stup_data_emt
WHERE  person_type_code = cp_person_type_code
AND    UPPER(data_element) = UPPER(p_data_element)
AND    required_ind = 'P';

CURSOR per_type_req_man_ins IS
SELECT 'x'
FROM   igs_pe_stup_data_emt sdt, igs_pe_person_types pt
WHERE  sdt.person_type_code = pt.person_type_code
AND    pt.system_type = 'OTHER'
AND    UPPER(sdt.data_element) = UPPER(p_data_element)
AND    sdt.required_ind = 'M';

CURSOR per_type_req_pre_ins IS
SELECT 'x'
FROM   igs_pe_stup_data_emt sdt, igs_pe_person_types pt
WHERE  sdt.person_type_code = pt.person_type_code
AND    pt.system_type = 'OTHER'
AND    UPPER(sdt.data_element) = UPPER(p_data_element)
AND    sdt.required_ind = 'P';

BEGIN
  IF p_person_id IS NOT NULL THEN
    FOR c_per_type IN per_type LOOP

      FOR c_per_type_req_man_upd  IN per_type_req_man_upd (c_per_type.person_type_code) LOOP
           p_required_ind := 'M';
           RETURN;
      END LOOP;

      FOR c_per_type_req_man_upd  IN per_type_req_man_upd (c_per_type.person_type_code) LOOP
           p_required_ind := 'P';
           RETURN;
      END LOOP;
    END LOOP;

  ELSE

      FOR c_per_type_req_man_ins  IN per_type_req_man_ins LOOP
           p_required_ind := 'M';
           RETURN;
      END LOOP;

      FOR c_per_type_req_pre_ins  IN per_type_req_pre_ins LOOP
           p_required_ind := 'P';
           RETURN;
      END LOOP;

  END IF;
END Check_Mand_Person_Type;

FUNCTION get_user_form_name (p_function_name VARCHAR2) RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Ramesh.Rengarajan Oracle IDC (nsinha)
  --Date created: 23-Jan-2002
  --
  --Purpose: Procedure to get the User form name for the passed form Name
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  --Cursor to get the user function name for the child form.
  CURSOR c_user_form_name IS
    SELECT tl.user_form_name
    FROM   fnd_form_tl tl,
           fnd_form_functions_vl vl
    WHERE  tl.form_id = vl.form_id
    AND    tl.language = USERENV ('LANG')
    AND    tl.application_id = 8405
    AND    vl.application_id = 8405
    AND    vl.function_name = p_function_name;

    c_user_form_name_rec c_user_form_name%ROWTYPE;
BEGIN
  IF p_function_name IS NOT NULL THEN
    -- Get the user function name for the child form.
    OPEN c_user_form_name;
    FETCH c_user_form_name INTO c_user_form_name_rec;
    IF c_user_form_name%NOTFOUND THEN
      CLOSE c_user_form_name;
      RETURN NULL;
    END IF;
    CLOSE c_user_form_name;
    RETURN (c_user_form_name_rec.user_form_name);
  ELSE
    RETURN NULL;
  END IF;
END get_user_form_name;


END IGS_AD_GEN_001;

/
