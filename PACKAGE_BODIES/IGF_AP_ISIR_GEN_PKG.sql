--------------------------------------------------------
--  DDL for Package Body IGF_AP_ISIR_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_ISIR_GEN_PKG" AS
/* $Header: IGFAP47B.pls 120.5 2006/02/23 01:38:51 rajagupt noship $ */
------------------------------------------------------------------
--Created by  : ugummall, Oracle India
--Date created: 04-AUG-2004
--
--Purpose:  Generic routines used in self-service pages and ISIR Import Process.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-- cdcruz     16-Dec-2004     Bug 4068284 Function chk_pell_orig cursor if condition corrected
--brajendr    02-Nov-2004     Bug 3031287 FA152 and FA137 COA Updates and Repackaging
--                            Added procedure upd_ant_data_awd_prc_status for Updating Anticipated Data and Award Prcoess status
-------------------------------------------------------------------

PROCEDURE attach_isir( cp_si_id       IN igf_ap_isir_ints_all.si_id%TYPE ,
                       cp_batch_year  IN igf_ap_isir_ints_all.batch_year_num%TYPE,
                       cp_message_out OUT NOCOPY VARCHAR2)
AS
    /*
    ||  Created By  : rasahoo
    ||  Created On  : 13-OCT-2004
    ||  Purpose     :Attch an ISIR to an existing person
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */
errbuf VARCHAR2(2000);
retcode NUMBER;

BEGIN
igf_ap_matching_process_pkg.main(errbuf            =>   errbuf,          --OUT NOCOPY VARCHAR2,
             retcode           =>   retcode,        -- OUT NOCOPY NUMBER,
             p_force_add       =>   NULL,           --IN VARCHAR2,
             p_create_inquiry  =>   NULL,           --IN VARCHAR2,
             p_adm_source_type =>   NULL,           --IN VARCHAR2,
             p_batch_year      =>   cp_batch_year,  --IN VARCHAR2,
             p_match_code      =>   NULL,           --IN VARCHAR2,
             p_del_int         =>   NULL,           --IN VARCHAR2,
             p_parent_req_id   =>   NULL,           --IN VARCHAR2,             -- when called as sub request
             p_sub_req_num     =>   NULL,           --IN VARCHAR2,             -- when called as sub request
             p_si_id           =>   cp_si_id,       --IN VARCHAR2             -- when called for single si id
         p_upd_ant_val     =>   'Y'
                );

EXCEPTION
WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.attach_isir');
      cp_message_out:= fnd_message.get;
END attach_isir;

  FUNCTION can_unlock_isir(
                           p_base_id     IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_user_id     IN      fnd_user.user_id%TYPE
                          )
  RETURN VARCHAR2 IS
    /*
    ||  Created By  : ugummall
    ||  Created On  : 04-AUG-2004
    ||  Purpose     : Returns 'Y' if the user can unlock the ISIR
    ||                otherwise returns 'N'
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */

    -- Cursor to check wether the user locked the specified ISIR or not.
    CURSOR cur_is_user_locked_isir( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                                    cp_user_id fnd_user.user_id%TYPE
                                  ) IS
      SELECT 'X'
        FROM IGF_AP_FA_BASE_REC_ALL fabase
       WHERE fabase.base_id = cp_base_id
         AND (fabase.isir_locked_by IS NULL OR fabase.isir_locked_by = cp_user_id);

    -- Cursor to check wether the user is system administrator or not.
    CURSOR cur_is_user_sysadmin( cp_user_id fnd_user.user_id%TYPE ) IS
        SELECT 'X'
         FROM FND_USER_RESP_GROUPS userresp,
              FND_RESPONSIBILITY resp
        WHERE resp.responsibility_id = userresp.responsibility_id
          AND resp.responsibility_key = 'SYSTEM_ADMINISTRATOR'
          AND userresp.user_id = cp_user_id;

    lv_dummy  VARCHAR2(1);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.can_unlock_isir.debug','starting can_unlock_isir with p_base_id : ' || p_base_id ||' p_user_id : '|| p_user_id);
    END IF;

    -- if base id or user id is null then return 'N'
    IF (p_base_id IS NULL OR p_user_id IS NULL) THEN
      RETURN 'N';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.can_unlock_isir.debug','Before opening cursor cur_is_user_locked_isir ');
    END IF;

    -- check if the ISIR is locked by the user
    lv_dummy := null;
    OPEN cur_is_user_locked_isir(p_base_id, p_user_id);
    FETCH cur_is_user_locked_isir INTO lv_dummy;
    CLOSE cur_is_user_locked_isir;

    IF (lv_dummy = 'X') THEN
      RETURN 'Y';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.can_unlock_isir.debug','Before opening cursor cur_is_user_sysadmin ');
    END IF;

    -- ISIR is not locked by user. Check if user is system administrator
    lv_dummy := null;
    OPEN cur_is_user_sysadmin(p_user_id);
    FETCH cur_is_user_sysadmin INTO lv_dummy;
    CLOSE cur_is_user_sysadmin;

    IF (lv_dummy = 'X') THEN
      RETURN 'Y';
    END IF;

    -- Neither user locked the ISIR, nor is system administrator.
    -- That means user has no privileges.
    RETURN 'N';

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.can_unlock_isir.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.can_unlock_isir');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      RETURN 'N';

  END can_unlock_isir;


  FUNCTION update_lock_status (
                               p_base_id     IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_user_id     IN      fnd_user.user_id%TYPE
                              )
  RETURN VARCHAR2 IS
    /*
    ||  Created By  : ugummall
    ||  Created On  : 04-AUG-2004
    ||  Purpose     : To lock/unlock the ISIR. Returns 'Y' upon successfull update,
    ||                returns 'N' otherwise
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */

    -- Cursor to get fa base record
    CURSOR cur_fa_base( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) IS
      SELECT fabase.*
        FROM IGF_AP_FA_BASE_REC fabase
       WHERE fabase.base_id = cp_base_id;

    rec_fa_base cur_fa_base%ROWTYPE;


  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.update_lock_status.debug','starting update_lock_status with p_base_id : ' || p_base_id ||' p_user_id : '|| p_user_id);
    END IF;

    -- if p_base_id is null, return 'N'
    IF (p_base_id IS NULL) THEN
      RETURN 'N';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.update_lock_status.debug','Before opening cursor cur_fa_base ');
    END IF;

    OPEN cur_fa_base(p_base_id);
    FETCH cur_fa_base INTO rec_fa_base;
    IF cur_fa_base%NOTFOUND THEN
      CLOSE cur_fa_base;
      RETURN 'N';
    END IF;
    CLOSE cur_fa_base;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.update_lock_status.debug','Calling igf_ap_fa_base_rec_pkg.update_row for baseid : '||rec_fa_base.base_id);
    END IF;

    -- if p_user_id is null, unlock the ISIR., update fa base record with ISIR lock status (ISIR_LOCKED_BY ) to null
    -- If NOT NULL, update fa base record with ISIR lock status (ISIR_LOCKED_BY) to p_user_id
    igf_ap_fa_base_rec_pkg.update_row(
            x_Mode                                   => 'R' ,
            x_rowid                                  => rec_fa_base.row_id ,
            x_base_id                                => rec_fa_base.base_id ,
            x_ci_cal_type                            => rec_fa_base.ci_cal_type ,
            x_person_id                              => rec_fa_base.person_id ,
            x_ci_sequence_number                     => rec_fa_base.ci_sequence_number ,
            x_org_id                                 => rec_fa_base.org_id ,
            x_coa_pending                            => rec_fa_base.coa_pending ,
            x_verification_process_run               => rec_fa_base.verification_process_run ,
            x_inst_verif_status_date                 => rec_fa_base.inst_verif_status_date ,
            x_manual_verif_flag                      => rec_fa_base.manual_verif_flag ,
            x_fed_verif_status                       => rec_fa_base.fed_verif_status ,
            x_fed_verif_status_date                  => rec_fa_base.fed_verif_status_date ,
            x_inst_verif_status                      => rec_fa_base.inst_verif_status ,
            x_nslds_eligible                         => rec_fa_base.nslds_eligible ,
            x_ede_correction_batch_id                => rec_fa_base.ede_correction_batch_id ,
            x_fa_process_status_date                 => rec_fa_base.fa_process_status_date ,
            x_isir_corr_status                       => rec_fa_base.isir_corr_status ,
            x_isir_corr_status_date                  => rec_fa_base.isir_corr_status_date ,
            x_isir_status                            => rec_fa_base.isir_status ,
            x_isir_status_date                       => rec_fa_base.isir_status_date,
            x_coa_code_f                             => rec_fa_base.coa_code_f ,
            x_coa_code_i                             => rec_fa_base.coa_code_i ,
            x_coa_f                                  => rec_fa_base.coa_f ,
            x_coa_i                                  => rec_fa_base.coa_i ,
            x_disbursement_hold                      => rec_fa_base.disbursement_hold ,
            x_fa_process_status                      => rec_fa_base.fa_process_status ,
            x_notification_status                    => rec_fa_base.notification_status ,
            x_notification_status_date               => rec_fa_base.notification_status_date ,
            x_packaging_status                       => rec_fa_base.packaging_status ,
            x_packaging_status_date                  => rec_fa_base.packaging_status_date ,
            x_total_package_accepted                 => rec_fa_base.total_package_accepted ,
            x_total_package_offered                  => rec_fa_base.total_package_offered ,
            x_admstruct_id                           => rec_fa_base.admstruct_id ,
            x_admsegment_1                           => rec_fa_base.admsegment_1 ,
            x_admsegment_2                           => rec_fa_base.admsegment_2 ,
            x_admsegment_3                           => rec_fa_base.admsegment_3 ,
            x_admsegment_4                           => rec_fa_base.admsegment_4 ,
            x_admsegment_5                           => rec_fa_base.admsegment_5 ,
            x_admsegment_6                           => rec_fa_base.admsegment_6 ,
            x_admsegment_7                           => rec_fa_base.admsegment_7 ,
            x_admsegment_8                           => rec_fa_base.admsegment_8 ,
            x_admsegment_9                           => rec_fa_base.admsegment_9 ,
            x_admsegment_10                          => rec_fa_base.admsegment_10 ,
            x_admsegment_11                          => rec_fa_base.admsegment_11 ,
            x_admsegment_12                          => rec_fa_base.admsegment_12 ,
            x_admsegment_13                          => rec_fa_base.admsegment_13 ,
            x_admsegment_14                          => rec_fa_base.admsegment_14 ,
            x_admsegment_15                          => rec_fa_base.admsegment_15 ,
            x_admsegment_16                          => rec_fa_base.admsegment_16 ,
            x_admsegment_17                          => rec_fa_base.admsegment_17 ,
            x_admsegment_18                          => rec_fa_base.admsegment_18 ,
            x_admsegment_19                          => rec_fa_base.admsegment_19 ,
            x_admsegment_20                          => rec_fa_base.admsegment_20 ,
            x_packstruct_id                          => rec_fa_base.packstruct_id ,
            x_packsegment_1                          => rec_fa_base.packsegment_1 ,
            x_packsegment_2                          => rec_fa_base.packsegment_2 ,
            x_packsegment_3                          => rec_fa_base.packsegment_3 ,
            x_packsegment_4                          => rec_fa_base.packsegment_4 ,
            x_packsegment_5                          => rec_fa_base.packsegment_5 ,
            x_packsegment_6                          => rec_fa_base.packsegment_6 ,
            x_packsegment_7                          => rec_fa_base.packsegment_7 ,
            x_packsegment_8                          => rec_fa_base.packsegment_8 ,
            x_packsegment_9                          => rec_fa_base.packsegment_9 ,
            x_packsegment_10                         => rec_fa_base.packsegment_10 ,
            x_packsegment_11                         => rec_fa_base.packsegment_11 ,
            x_packsegment_12                         => rec_fa_base.packsegment_12 ,
            x_packsegment_13                         => rec_fa_base.packsegment_13 ,
            x_packsegment_14                         => rec_fa_base.packsegment_14 ,
            x_packsegment_15                         => rec_fa_base.packsegment_15 ,
            x_packsegment_16                         => rec_fa_base.packsegment_16 ,
            x_packsegment_17                         => rec_fa_base.packsegment_17 ,
            x_packsegment_18                         => rec_fa_base.packsegment_18 ,
            x_packsegment_19                         => rec_fa_base.packsegment_19 ,
            x_packsegment_20                         => rec_fa_base.packsegment_20 ,
            x_miscstruct_id                          => rec_fa_base.miscstruct_id ,
            x_miscsegment_1                          => rec_fa_base.miscsegment_1 ,
            x_miscsegment_2                          => rec_fa_base.miscsegment_2 ,
            x_miscsegment_3                          => rec_fa_base.miscsegment_3 ,
            x_miscsegment_4                          => rec_fa_base.miscsegment_4 ,
            x_miscsegment_5                          => rec_fa_base.miscsegment_5 ,
            x_miscsegment_6                          => rec_fa_base.miscsegment_6 ,
            x_miscsegment_7                          => rec_fa_base.miscsegment_7 ,
            x_miscsegment_8                          => rec_fa_base.miscsegment_8 ,
            x_miscsegment_9                          => rec_fa_base.miscsegment_9 ,
            x_miscsegment_10                         => rec_fa_base.miscsegment_10 ,
            x_miscsegment_11                         => rec_fa_base.miscsegment_11 ,
            x_miscsegment_12                         => rec_fa_base.miscsegment_12 ,
            x_miscsegment_13                         => rec_fa_base.miscsegment_13 ,
            x_miscsegment_14                         => rec_fa_base.miscsegment_14 ,
            x_miscsegment_15                         => rec_fa_base.miscsegment_15 ,
            x_miscsegment_16                         => rec_fa_base.miscsegment_16 ,
            x_miscsegment_17                         => rec_fa_base.miscsegment_17 ,
            x_miscsegment_18                         => rec_fa_base.miscsegment_18 ,
            x_miscsegment_19                         => rec_fa_base.miscsegment_19 ,
            x_miscsegment_20                         => rec_fa_base.miscsegment_20 ,
            x_prof_judgement_flg                     => rec_fa_base.prof_judgement_flg ,
            x_nslds_data_override_flg                => rec_fa_base.nslds_data_override_flg ,
            x_target_group                           => rec_fa_base.target_group ,
            x_coa_fixed                              => rec_fa_base.coa_fixed ,
            x_coa_pell                               => rec_fa_base.coa_pell ,
            x_profile_status                         => rec_fa_base.profile_status ,
            x_profile_status_date                    => rec_fa_base.profile_status_date ,
            x_profile_fc                             => rec_fa_base.profile_fc ,
            x_tolerance_amount                       => rec_fa_base.tolerance_amount ,
            x_manual_disb_hold                       => rec_fa_base.manual_disb_hold ,
            x_pell_alt_expense                       => rec_fa_base.pell_alt_expense,
            x_assoc_org_num                          => rec_fa_base.assoc_org_num,
            x_award_fmly_contribution_type           => rec_fa_base.award_fmly_contribution_type,
            x_isir_locked_by                         => p_user_id,
            x_adnl_unsub_loan_elig_flag              => rec_fa_base.adnl_unsub_loan_elig_flag,
            x_lock_awd_flag                          => rec_fa_base.lock_awd_flag,
            x_lock_coa_flag                          => rec_fa_base.lock_coa_flag

           );
    RETURN 'Y';

  END update_lock_status;


  FUNCTION is_awarding_pymnt_isir_exists(
                                         p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE
                                        )
  RETURN VARCHAR2 IS
    /*
    ||  Created By  : ugummall
    ||  Created On  : 04-AUG-2004
    ||  Purpose     : Returns 'Y' if student has any outstanding corrections with status 'BATCHED' or 'READY'
    ||                otherwise returns 'N'
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */

    -- Cursor to check wether the student has any outstanding corrections with status 'BATCHED' or 'READY'
    CURSOR cur_isir( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) IS
    SELECT 'X'
      FROM igf_ap_isir_matched_all
     WHERE base_id = p_base_id
       AND system_record_type IN ('ORIGINAL','CORRECTION')
       AND (NVL(payment_isir,'N') = 'Y' OR NVL(active_isir,'N') = 'Y')
       AND ROWNUM < 2;

    lv_dummy VARCHAR2(1);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.is_awarding_pymnt_isir_exists.debug','starting is_awarding_pymnt_isir_exists with p_base_id : ' || p_base_id );
    END IF;

    -- validate the input parameters
    IF (p_base_id IS NULL) THEN
      RETURN 'N';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.is_awarding_pymnt_isir_exists.debug','before opening cursor cur_isir ');
    END IF;

    -- check wether the student is having any outstanding corrections or not.
    lv_dummy := NULL;
    OPEN cur_isir(p_base_id);
    FETCH cur_isir INTO lv_dummy;
    CLOSE cur_isir;

    IF (lv_dummy = 'X') THEN
      RETURN 'Y';
    END IF;

    RETURN 'N';

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.is_awarding_pymnt_isir_exists.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.is_awarding_pymnt_isir_exists');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      RETURN 'N';

  END is_awarding_pymnt_isir_exists;


  FUNCTION are_corrections_exists (
                                   p_base_id     IN      igf_ap_fa_base_rec_all.base_id%TYPE
                                  )
  RETURN VARCHAR2 IS
    /*
    ||  Created By  : ugummall
    ||  Created On  : 04-AUG-2004
    ||  Purpose     : Returns 'Y' if student has any outstanding corrections with status 'BATCHED'
    ||                otherwise returns 'N'
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */

    -- Cursor to check wether the student has any outstanding corrections with status 'BATCHED'
    CURSOR cur_corrections( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) IS
    SELECT 'X'
      FROM IGF_AP_ISIR_CORR_ALL ic
     WHERE ic.correction_status = 'BATCHED'
       AND ic.isir_id IN (  SELECT im.isir_id
                              FROM IGF_AP_ISIR_MATCHED_ALL im
                             WHERE im.base_id = cp_base_id );

    lv_dummy VARCHAR2(1);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.are_corrections_exists.debug','starting are_corrections_exists with p_base_id : ' || p_base_id);
    END IF;

    -- validate the input parameters
    IF (p_base_id IS NULL) THEN
      RETURN 'N';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.are_corrections_exists.debug','Before opening cursor cur_corrections ');
    END IF;

    -- check wether the student is having any outstanding corrections or not.
    lv_dummy := NULL;
    OPEN cur_corrections(p_base_id);
    FETCH cur_corrections INTO lv_dummy;
    CLOSE cur_corrections;

    IF (lv_dummy = 'X') THEN
      RETURN 'Y';
    END IF;

    RETURN 'N';

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.are_corrections_exists.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.are_corrections_exists');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      RETURN 'N';

  END are_corrections_exists;


  PROCEDURE delete_isir_validations(
                                    p_base_id        IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                                    p_isir_id        IN         igf_ap_isir_matched_all.isir_id%TYPE,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2,
                                    x_return_status  OUT NOCOPY VARCHAR2
                                   ) IS
    /*
    ||  Created By  : ugummall
    ||  Created On  : 04-AUG-2004
    ||  Purpose     : Returns 'A' if student has Non-Simulated awards
    ||                Returns 'C' if correction ISIR exists
    ||                If no non-simulated awards, no correction ISIR then deletes ISIR
    ||                and returns 'Y' upon successful deletion. Otherwise returns 'N'
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */

    -- Cursor to check wether the student has any non-simulated awards.
    CURSOR cur_stud_non_simulated_awards( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) IS
      SELECT 'X'
        FROM IGF_AW_AWARD_ALL awards
       WHERE awards.base_id = cp_base_id
         AND awards.award_status <> 'SIMULATED';

    -- Cursor to check if internal created correction ISIR exists for the student or not.
    CURSOR cur_stud_correction_isir( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) IS
      SELECT 'X'
        FROM IGF_AP_ISIR_MATCHED_ALL im
       WHERE im.base_id = cp_base_id
         AND im.system_record_type = 'CORRECTION';

    lv_dummy   VARCHAR2(1);
    RETURN_EXP EXCEPTION;
    l_err_msg  VARCHAR2(2000);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir_validations.debug','starting delete_isir_validations with p_base_id : ' || p_base_id ||' p_isir_id : '|| p_isir_id);
    END IF;

    SAVEPOINT IGFAP47_DELETE_ISIR_VAL;
    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir_validations.debug','Before opening cursor cur_stud_non_simulated_awards ');
    END IF;

    -- check if non-simulated awards exists for the student.
    lv_dummy := null;
    OPEN cur_stud_non_simulated_awards(p_base_id);
    FETCH cur_stud_non_simulated_awards INTO lv_dummy;
    CLOSE cur_stud_non_simulated_awards;

    IF (lv_dummy = 'X') THEN
        x_return_status := 'A';
        RAISE RETURN_EXP;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir_validations.debug','Before opening cursor cur_stud_correction_isir ');
    END IF;

    -- check if internal created correction ISIR exists for the student.
    lv_dummy := null;
    OPEN cur_stud_correction_isir(p_base_id);
    FETCH cur_stud_correction_isir INTO lv_dummy;
    CLOSE cur_stud_correction_isir;

    IF (lv_dummy = 'X') THEN
        x_return_status := 'C';
        RAISE RETURN_EXP;
    END IF;

    x_return_status := 'S';
    fnd_msg_pub.count_and_get(
                              p_encoded  => fnd_api.g_false,
                              p_count    => x_msg_count,
                              p_data     => x_msg_data
                             );

  EXCEPTION
    WHEN RETURN_EXP THEN
      fnd_msg_pub.count_and_get(
                                p_encoded  => fnd_api.g_false,
                                p_count    => x_msg_count,
                                p_data     => x_msg_data
                               );

    WHEN OTHERS THEN

      ROLLBACK TO IGFAP47_DELETE_ISIR_VAL;

      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.delete_isir');

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_err_msg := fnd_message.get||SQLERRM;
      fnd_msg_pub.count_and_get(
                                p_encoded  => fnd_api.g_false,
                                p_count    => x_msg_count,
                                p_data     => l_err_msg --x_msg_data
                               );
  END delete_isir_validations;


  PROCEDURE delete_isir(
                        p_base_id        IN         igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_isir_id        IN         igf_ap_isir_matched_all.isir_id%TYPE,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2,
                        x_return_status  OUT NOCOPY VARCHAR2
                       ) IS
    /*
    ||  Created By  : ugummall
    ||  Created On  : 04-AUG-2004
    ||  Purpose     : Returns 'A' if student has Non-Simulated awards
    ||                Returns 'C' if correction ISIR exists
    ||                If no non-simulated awards, no correction ISIR then deletes ISIR
    ||                and returns 'Y' upon successful deletion. Otherwise returns 'N'
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */

    -- Cursor to get rowid of the ISIR to be deleted.
    CURSOR cur_chk_isir_in_ints(
                                cp_batch_year        igf_ap_isir_matched_all.batch_year%TYPE,
                                cp_transaction_num   igf_ap_isir_matched_all.transaction_num%TYPE,
                                cp_original_ssn      igf_ap_isir_matched_all.original_ssn%TYPE,
                                cp_orig_name_id      igf_ap_isir_matched_all.orig_name_id%TYPE
                               ) IS
      SELECT ROWID row_id, si_id
        FROM igf_ap_isir_ints i
       WHERE batch_year_num       = cp_batch_year
         AND transaction_num_txt  = cp_transaction_num
         AND original_ssn_txt     = cp_original_ssn
         AND orig_name_id_txt     = cp_orig_name_id;

    rec_chk_isir_in_ints  cur_chk_isir_in_ints%ROWTYPE;

    -- Cursor to get rowid of the ISIR to be deleted.
    CURSOR cur_get_rowid_nslds( cp_isir_id igf_ap_isir_matched_all.isir_id%TYPE ) IS
      SELECT ROWID row_id
        FROM igf_ap_nslds_data_all n
       WHERE n.isir_id = cp_isir_id;

    rec_get_rowid_nslds  cur_get_rowid_nslds%ROWTYPE;

    -- Cursor to get rowid of the ISIR to be deleted.
    CURSOR cur_get_rowid_isir( cp_isir_id igf_ap_isir_matched_all.isir_id%TYPE ) IS
      SELECT ROWID row_id, batch_year, transaction_num, original_ssn, orig_name_id, base_id, system_record_type
        FROM igf_ap_isir_matched_all im
       WHERE im.isir_id = cp_isir_id;

    rec_get_rowid_isir cur_get_rowid_isir%ROWTYPE;

    CURSOR cur_isir_int ( cp_isir_id igf_ap_isir_matched_all.isir_id%TYPE ) IS
    SELECT i.batch_year, i.transaction_num, i.current_ssn, i.ssn_name_change, i.original_ssn, i.orig_name_id, i.last_name, i.first_name, i.middle_initial,
           i.perm_mail_add, i.perm_city, i.perm_state, i.perm_zip_code, i.date_of_birth, i.phone_number, i.driver_license_number, i.driver_license_state,
           i.citizenship_status, i.alien_reg_number, i.s_marital_status, i.s_marital_status_date, i.summ_enrl_status, i.fall_enrl_status, i.winter_enrl_status,
           i.spring_enrl_status, i.summ2_enrl_status, i.fathers_highest_edu_level, i.mothers_highest_edu_level, i.s_state_legal_residence, i.legal_residence_before_date,
           i.s_legal_resd_date, i.ss_r_u_male, i.selective_service_reg, i.degree_certification, i.grade_level_in_college, i.high_school_diploma_ged,
           i.first_bachelor_deg_by_date, i.interest_in_loan, i.interest_in_stud_employment, i.drug_offence_conviction, i.s_tax_return_status, i.s_type_tax_return,
           i.s_elig_1040ez, i.s_adjusted_gross_income, i.s_fed_taxes_paid, i.s_exemptions, i.s_income_from_work, i.spouse_income_from_work, i.s_toa_amt_from_wsa,
           i.s_toa_amt_from_wsb, i.s_toa_amt_from_wsc, i.s_investment_networth, i.s_busi_farm_networth, i.s_cash_savings, i.va_months, i.va_amount, i.stud_dob_before_date,
           i.deg_beyond_bachelor, i.s_married, i.s_have_children, i.legal_dependents, i.orphan_ward_of_court, i.s_veteran, i.p_marital_status, i.father_ssn, i.f_last_name,
           i.mother_ssn, i.m_last_name, i.p_num_family_member, i.p_num_in_college, i.p_state_legal_residence, i.p_state_legal_res_before_dt, i.p_legal_res_date,
           i.age_older_parent, i.p_tax_return_status, i.p_type_tax_return, i.p_elig_1040aez, i.p_adjusted_gross_income, i.p_taxes_paid, i.p_exemptions, i.f_income_work,
           i.m_income_work, i.p_income_wsa, i.p_income_wsb, i.p_income_wsc, i.p_investment_networth, i.p_business_networth, i.p_cash_saving, i.s_num_family_members,
           i.s_num_in_college, i.first_college, i.first_house_plan, i.second_college, i.second_house_plan, i.third_college, i.third_house_plan, i.fourth_college,
           i.fourth_house_plan, i.fifth_college, i.fifth_house_plan, i.sixth_college, i.sixth_house_plan, i.date_app_completed, i.signed_by, i.preparer_ssn,
           i.preparer_emp_id_number, i.preparer_sign, i.transaction_receipt_date, i.dependency_override_ind, i.faa_fedral_schl_code, i.faa_adjustment, i.input_record_type,
           i.serial_number, i.batch_number, i.early_analysis_flag, i.app_entry_source_code, i.eti_destination_code, i.reject_override_b, i.reject_override_n,
           i.reject_override_w, i.assum_override_1, i.assum_override_2, i.assum_override_3, i.assum_override_4, i.assum_override_5, i.assum_override_6,
           i.dependency_status, i.s_email_address, i.nslds_reason_code, i.app_receipt_date, i.processed_rec_type, i.hist_correction_for_tran_id,
           i.system_generated_indicator, i.dup_request_indicator, i.source_of_correction, i.p_cal_tax_status, i.s_cal_tax_status, i.graduate_flag, i.auto_zero_efc,
           i.efc_change_flag, i.sarc_flag, i.simplified_need_test, i.reject_reason_codes, i.select_service_match_flag, i.select_service_reg_flag, i.ins_match_flag,
           i.ins_verification_number, i.sec_ins_match_flag, i.sec_ins_ver_number, i.ssn_match_flag, i.ssa_citizenship_flag, i.ssn_date_of_death, i.nslds_match_flag,
           i.va_match_flag, i.prisoner_match, i.verification_flag, i.subsequent_app_flag, i.app_source_site_code, i.tran_source_site_code, i.drn, i.tran_process_date,
           i.computer_batch_number, i.correction_flags, i.highlight_flags, i.paid_efc, i.primary_efc, i.secondary_efc, i.fed_pell_grant_efc_type, i.primary_efc_type,
           i.sec_efc_type, i.primary_alternate_month_1, i.primary_alternate_month_2, i.primary_alternate_month_3, i.primary_alternate_month_4, i.primary_alternate_month_5,
           i.primary_alternate_month_6, i.primary_alternate_month_7, i.primary_alternate_month_8, i.primary_alternate_month_10, i.primary_alternate_month_11,
           i.primary_alternate_month_12, i.sec_alternate_month_1, i.sec_alternate_month_2, i.sec_alternate_month_3, i.sec_alternate_month_4, i.sec_alternate_month_5,
           i.sec_alternate_month_6, i.sec_alternate_month_7, i.sec_alternate_month_8, i.sec_alternate_month_10, i.sec_alternate_month_11, i.sec_alternate_month_12,
           i.total_income, i.allow_total_income, i.state_tax_allow, i.employment_allow, i.income_protection_allow, i.available_income, i.contribution_from_ai,
           i.discretionary_networth, i.efc_networth, i.asset_protect_allow, i.parents_cont_from_assets, i.adjusted_available_income, i.total_student_contribution,
           i.total_parent_contribution, i.parents_contribution, i.student_total_income, i.sati, i.sic, i.sdnw, i.sca, i.fti, i.secti, i.secati, i.secstx, i.secea,
           i.secipa, i.secai, i.seccai, i.secdnw, i.secnw, i.secapa, i.secpca, i.secaai, i.sectsc, i.sectpc, i.secpc, i.secsti, i.secsic, i.secsati, i.secsdnw, i.secsca,
           i.secfti, i.a_citizenship, i.a_student_marital_status, i.a_student_agi, i.a_s_us_tax_paid, i.a_s_income_work, i.a_spouse_income_work, i.a_s_total_wsc,
           i.a_date_of_birth, i.a_student_married, i.a_have_children, i.a_s_have_dependents, i.a_va_status, i.a_s_num_in_family, i.a_s_num_in_college,
           i.a_p_marital_status, i.a_father_ssn, i.a_mother_ssn, i.a_parents_num_family, i.a_parents_num_college, i.a_parents_agi, i.a_p_us_tax_paid, i.a_f_work_income,
           i.a_m_work_income, i.a_p_total_wsc, i.comment_codes, i.sar_ack_comm_code, i.pell_grant_elig_flag, i.reprocess_reason_code, i.duplicate_date,
           i.isir_transaction_type, i.fedral_schl_code_indicator, i.multi_school_code_flags, i.dup_ssn_indicator, i.verif_track_flag, i.fafsa_data_verify_flags,
           i.reject_override_a, i.reject_override_c, i.parent_marital_status_date, i.father_first_name_initial_txt, i.father_step_father_birth_date,
           i.mother_first_name_initial_txt, i.mother_step_mother_birth_date, i.parents_email_address_txt, i.address_change_type, i.cps_pushed_isir_flag,
           i.electronic_transaction_type, i.sar_c_change_type, i.father_ssn_match_type, i.mother_ssn_match_type, i.reject_override_g_flag, i.dhs_verification_num_txt,
           i.data_file_name_txt, n.nslds_transaction_num, n.nslds_database_results_f, n.nslds_f, n.nslds_pell_overpay_f, n.nslds_pell_overpay_contact,
           n.nslds_seog_overpay_f, n.nslds_seog_overpay_contact, n.nslds_perkins_overpay_f, n.nslds_perkins_overpay_cntct, n.nslds_defaulted_loan_f,
           n.nslds_dischged_loan_chng_f, n.nslds_satis_repay_f, n.nslds_act_bankruptcy_f, n.nslds_agg_subsz_out_prin_bal, n.nslds_agg_unsbz_out_prin_bal,
           n.nslds_agg_comb_out_prin_bal, n.nslds_agg_cons_out_prin_bal, n.nslds_agg_subsz_pend_dismt, n.nslds_agg_unsbz_pend_dismt, n.nslds_agg_comb_pend_dismt,
           n.nslds_agg_subsz_total, n.nslds_agg_unsbz_total, n.nslds_agg_comb_total, n.nslds_agg_consd_total, n.nslds_perkins_out_bal, n.nslds_perkins_cur_yr_dismnt,
           n.nslds_default_loan_chng_f, n.nslds_discharged_loan_f,
           n.nslds_satis_repay_chng_f, n.nslds_act_bnkrupt_chng_f, n.nslds_overpay_chng_f, n.nslds_agg_loan_chng_f, n.nslds_perkins_loan_chng_f, n.nslds_pell_paymnt_chng_f,
           n.nslds_addtnl_pell_f, n.nslds_addtnl_loan_f, n.direct_loan_mas_prom_nt_f, n.nslds_pell_seq_num_1, n.nslds_pell_verify_f_1, n.nslds_pell_efc_1,
           n.nslds_pell_school_code_1, n.nslds_pell_transcn_num_1, n.nslds_pell_last_updt_dt_1, n.nslds_pell_scheduled_amt_1, n.nslds_pell_amt_paid_todt_1,
           n.nslds_pell_remng_amt_1, n.nslds_pell_pc_schd_awd_us_1, n.nslds_pell_award_amt_1, n.nslds_pell_seq_num_2, n.nslds_pell_verify_f_2, n.nslds_pell_efc_2,
           n.nslds_pell_school_code_2, n.nslds_pell_transcn_num_2, n.nslds_pell_last_updt_dt_2, n.nslds_pell_scheduled_amt_2, n.nslds_pell_amt_paid_todt_2,
           n.nslds_pell_remng_amt_2, n.nslds_pell_pc_schd_awd_us_2, n.nslds_pell_award_amt_2, n.nslds_pell_seq_num_3, n.nslds_pell_verify_f_3, n.nslds_pell_efc_3,
           n.nslds_pell_school_code_3, n.nslds_pell_transcn_num_3, n.nslds_pell_last_updt_dt_3, n.nslds_pell_scheduled_amt_3, n.nslds_pell_amt_paid_todt_3,
           n.nslds_pell_remng_amt_3, n.nslds_pell_pc_schd_awd_us_3, n.nslds_pell_award_amt_3, n.nslds_loan_seq_num_1, n.nslds_loan_type_code_1, n.nslds_loan_chng_f_1,
           n.nslds_loan_prog_code_1, n.nslds_loan_net_amnt_1, n.nslds_loan_cur_st_code_1, n.nslds_loan_cur_st_date_1, n.nslds_loan_agg_pr_bal_1,
           n.nslds_loan_out_pr_bal_dt_1, n.nslds_loan_begin_dt_1, n.nslds_loan_end_dt_1, n.nslds_loan_ga_code_1, n.nslds_loan_cont_type_1, n.nslds_loan_schol_code_1,
           n.nslds_loan_cont_code_1, n.nslds_loan_grade_lvl_1, n.nslds_loan_xtr_unsbz_ln_f_1, n.nslds_loan_capital_int_f_1, n.nslds_loan_seq_num_2,
           n.nslds_loan_type_code_2, n.nslds_loan_chng_f_2, n.nslds_loan_prog_code_2, n.nslds_loan_net_amnt_2, n.nslds_loan_cur_st_code_2, n.nslds_loan_cur_st_date_2,
           n.nslds_loan_agg_pr_bal_2, n.nslds_loan_out_pr_bal_dt_2, n.nslds_loan_begin_dt_2, n.nslds_loan_end_dt_2, n.nslds_loan_ga_code_2, n.nslds_loan_cont_type_2,
           n.nslds_loan_schol_code_2, n.nslds_loan_cont_code_2, n.nslds_loan_grade_lvl_2, n.nslds_loan_xtr_unsbz_ln_f_2, n.nslds_loan_capital_int_f_2,
           n.nslds_loan_seq_num_3, n.nslds_loan_type_code_3, n.nslds_loan_chng_f_3, n.nslds_loan_prog_code_3, n.nslds_loan_net_amnt_3, n.nslds_loan_cur_st_code_3,
           n.nslds_loan_cur_st_date_3, n.nslds_loan_agg_pr_bal_3, n.nslds_loan_out_pr_bal_dt_3, n.nslds_loan_begin_dt_3, n.nslds_loan_end_dt_3, n.nslds_loan_ga_code_3,
           n.nslds_loan_cont_type_3, n.nslds_loan_schol_code_3, n.nslds_loan_cont_code_3, n.nslds_loan_grade_lvl_3, n.nslds_loan_xtr_unsbz_ln_f_3,
           n.nslds_loan_capital_int_f_3, n.nslds_loan_seq_num_4, n.nslds_loan_type_code_4, n.nslds_loan_chng_f_4, n.nslds_loan_prog_code_4, n.nslds_loan_net_amnt_4,
           n.nslds_loan_cur_st_code_4, n.nslds_loan_cur_st_date_4, n.nslds_loan_agg_pr_bal_4, n.nslds_loan_out_pr_bal_dt_4, n.nslds_loan_begin_dt_4,
           n.nslds_loan_end_dt_4, n.nslds_loan_ga_code_4, n.nslds_loan_cont_type_4, n.nslds_loan_schol_code_4, n.nslds_loan_cont_code_4, n.nslds_loan_grade_lvl_4,
           n.nslds_loan_xtr_unsbz_ln_f_4, n.nslds_loan_capital_int_f_4, n.nslds_loan_seq_num_5, n.nslds_loan_type_code_5, n.nslds_loan_chng_f_5, n.nslds_loan_prog_code_5,
           n.nslds_loan_net_amnt_5, n.nslds_loan_cur_st_code_5, n.nslds_loan_cur_st_date_5, n.nslds_loan_agg_pr_bal_5, n.nslds_loan_out_pr_bal_dt_5,
           n.nslds_loan_begin_dt_5, n.nslds_loan_end_dt_5, n.nslds_loan_ga_code_5, n.nslds_loan_cont_type_5, n.nslds_loan_schol_code_5, n.nslds_loan_cont_code_5,
           n.nslds_loan_grade_lvl_5, n.nslds_loan_xtr_unsbz_ln_f_5, n.nslds_loan_capital_int_f_5, n.nslds_loan_seq_num_6, n.nslds_loan_type_code_6, n.nslds_loan_chng_f_6,
           n.nslds_loan_prog_code_6, n.nslds_loan_net_amnt_6, n.nslds_loan_cur_st_code_6, n.nslds_loan_cur_st_date_6, n.nslds_loan_agg_pr_bal_6,
           n.nslds_loan_out_pr_bal_dt_6, n.nslds_loan_begin_dt_6, n.nslds_loan_end_dt_6, n.nslds_loan_ga_code_6, n.nslds_loan_cont_type_6, n.nslds_loan_schol_code_6,
           n.nslds_loan_cont_code_6, n.nslds_loan_grade_lvl_6, n.nslds_loan_xtr_unsbz_ln_f_6, n.nslds_loan_capital_int_f_6, n.nslds_loan_last_d_amt_1,
           n.nslds_loan_last_d_date_1, n.nslds_loan_last_d_amt_2, n.nslds_loan_last_d_date_2, n.nslds_loan_last_d_amt_3, n.nslds_loan_last_d_date_3,
           n.nslds_loan_last_d_amt_4, n.nslds_loan_last_d_date_4, n.nslds_loan_last_d_amt_5, n.nslds_loan_last_d_date_5, n.nslds_loan_last_d_amt_6,
           n.nslds_loan_last_d_date_6, n.dlp_master_prom_note_flag, n.subsidized_loan_limit_type, n.combined_loan_limit_type,
           i.system_record_type
      FROM igf_ap_isir_matched_all i, igf_ap_nslds_data_all n
     WHERE i.isir_id = n.isir_id(+)
       AND i.isir_id = cp_isir_id;

    cur_isir_int_rec cur_isir_int%ROWTYPE;
   CURSOR get_isir(cp_base_id NUMBER)
   IS
   SELECT 'X'
   FROM IGF_AP_ISIR_MATCHED_ALL
   WHERE base_id = cp_base_id;

   l_isir VARCHAR2(1);

   CURSOR todo_items_for_isir_cur(cp_base_id NUMBER) IS
   SELECT ii.rowid,
          ii.*
   FROM   igf_ap_td_item_mst im, igf_ap_td_item_inst ii
   WHERE  ii.base_id = cp_base_id
     AND  im.todo_number = ii.item_sequence_number
     AND  im.system_todo_type_code = 'ISIR'; -- for ISIR type only

   -- Get
   CURSOR max_seq IS
     SELECT max(si_id) max_si_id
       FROM igf_ap_isir_ints_all;


    todo_items_for_isir_rec todo_items_for_isir_cur%ROWTYPE;

    max_seq_rec max_seq%ROWTYPE;

    lv_dummy   VARCHAR2(1);
    l_err_msg  VARCHAR2(2000);
    l_isir_data_from_mtch_tbl  BOOLEAN;
    RETURN_EXP  EXCEPTION;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.debug','starting delete_isir with p_base_id : ' || p_base_id ||' p_isir_id : '|| p_isir_id);
    END IF;


    SAVEPOINT IGFAP47_DELETE_ISIR;
    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_isir_data_from_mtch_tbl := FALSE;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.debug','Before opening cursor cur_get_rowid_isir ');
    END IF;

    -- Check whether the ISIR is still present in the ISIR Interface table, If so, change the status to UNMATCHED and delete the ISIR AND NSLDS
    -- If not present then Create the ISIR record from the ISIR and NSLDS data and delete the ISIR and NSLDS data from the matched tables.
    rec_get_rowid_isir := null;
    OPEN cur_get_rowid_isir(p_isir_id);
    FETCH cur_get_rowid_isir INTO rec_get_rowid_isir;
    CLOSE cur_get_rowid_isir;

    -- If the selected record is a Simulation ISIR, then dele the Simulated ISIR from the Matched table.
    IF rec_get_rowid_isir.system_record_type = 'SIMULATION' THEN
      igf_ap_isir_matched_pkg.delete_row(rec_get_rowid_isir.row_id);
      RAISE RETURN_EXP ;

    ELSE
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.debug','Before opening cursor cur_chk_isir_in_ints ');
      END IF;

      rec_chk_isir_in_ints := NULL;
      OPEN cur_chk_isir_in_ints( rec_get_rowid_isir.batch_year, rec_get_rowid_isir.transaction_num, rec_get_rowid_isir.original_ssn, rec_get_rowid_isir.orig_name_id );
      FETCH cur_chk_isir_in_ints INTO rec_chk_isir_in_ints;
      CLOSE cur_chk_isir_in_ints;

      -- IF the record is present in the ISIR Interface table, then update the status.
      IF rec_chk_isir_in_ints.si_id IS NOT NULL THEN


        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.debug','Before calling UPDATE igf_ap_isir_ints_all for si_id : '|| rec_chk_isir_in_ints.si_id);
        END IF;

        UPDATE igf_ap_isir_ints_all
           SET record_status = 'UNMATCHED',
               last_updated_by = fnd_global.user_id,
               last_update_date = TRUNC(SYSDATE),
               last_update_login = fnd_global.login_id
         WHERE si_id = rec_chk_isir_in_ints.si_id;

        l_isir_data_from_mtch_tbl := TRUE;

      ELSE

        -- If the ISIR data is not present in the ISIR Interface table, then insert the data from the ISIR Matched table and NSLDS data table.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.debug','Before opening cursor cur_isir_int and insert row into igf_ap_isir_ints_all');
        END IF;


        OPEN cur_isir_int(p_isir_id);
        FETCH cur_isir_int INTO cur_isir_int_rec;
        CLOSE cur_isir_int;

        OPEN max_seq;
        FETCH max_seq INTO max_seq_rec;
        CLOSE max_seq;

        INSERT INTO igf_ap_isir_ints_all (
                si_id,
                batch_year_num,
                transaction_num_txt,
                current_ssn_txt,
                ssn_name_change_type,
                original_ssn_txt,
                orig_name_id_txt,
                last_name,
                first_name,
                middle_initial_txt,
                perm_mail_address_txt,
                perm_city_txt,
                perm_state_txt,
                perm_zip_cd,
                birth_date,
                phone_number_txt,
                driver_license_number_txt,
                driver_license_state_txt,
                citizenship_status_type,
                alien_reg_number_txt,
                s_marital_status_type,
                s_marital_status_date,
                summ_enrl_status_type,
                fall_enrl_status_type,
                winter_enrl_status_type,
                spring_enrl_status_type,
                summ2_enrl_status_type,
                fathers_highst_edu_lvl_type,
                mothers_highst_edu_lvl_type,
                s_state_legal_residence,
                legal_res_before_year_flag,
                s_legal_resd_date,
                ss_r_u_male_flag,
                selective_service_reg_flag,
                degree_certification_type,
                grade_level_in_college_type,
                high_schl_diploma_ged_flag,
                first_bachlr_deg_year_flag,
                interest_in_loan_flag,
                interest_in_stu_employ_flag,
                drug_offence_convict_type,
                s_tax_return_status_type,
                s_type_tax_return_type,
                s_elig_1040ez_type,
                s_adjusted_gross_income_amt,
                s_fed_taxes_paid_amt,
                s_exemptions_amt,
                s_income_from_work_amt,
                spouse_income_from_work_amt,
                s_total_from_wsa_amt,
                s_total_from_wsb_amt,
                s_total_from_wsc_amt,
                s_investment_networth_amt,
                s_busi_farm_networth_amt,
                s_cash_savings_amt,
                va_months_num,
                va_amt,
                stud_dob_before_year_flag,
                deg_beyond_bachelor_flag,
                s_married_flag,
                s_have_children_flag,
                legal_dependents_flag,
                orphan_ward_of_court_flag,
                s_veteran_flag,
                p_marital_status_type,
                father_ssn_txt,
                f_last_name,
                mother_ssn_txt,
                m_last_name,
                p_family_members_num,
                p_in_college_num,
                p_state_legal_residence_txt,
                p_legal_res_before_dt_flag,
                p_legal_res_date,
                age_older_parent_num,
                p_tax_return_status_type,
                p_type_tax_return_type,
                p_elig_1040aez_type,
                p_adjusted_gross_income_amt,
                p_taxes_paid_amt,
                p_exemptions_amt,
                f_income_work_amt,
                m_income_work_amt,
                p_income_wsa_amt,
                p_income_wsb_amt,
                p_income_wsc_amt,
                p_investment_networth_amt,
                p_business_networth_amt,
                p_cash_saving_amt,
                s_family_members_num,
                s_in_college_num,
                first_college_cd,
                first_house_plan_type,
                second_college_cd,
                second_house_plan_type,
                third_college_cd,
                third_house_plan_type,
                fourth_college_cd,
                fourth_house_plan_type,
                fifth_college_cd,
                fifth_house_plan_type,
                sixth_college_cd,
                sixth_house_plan_type,
                app_completed_date,
                signed_by_type,
                preparer_ssn_txt,
                preparer_emp_id_number_txt,
                preparer_sign_flag,
                transaction_receipt_date,
                dependency_override_type,
                faa_fedral_schl_cd,
                faa_adjustment_type,
                input_record_type,
                serial_num,
                batch_number_txt,
                early_analysis_flag,
                app_entry_source_type,
                eti_destination_cd,
                reject_override_b_flag,
                reject_override_n_flag,
                reject_override_w_flag,
                assum_override_1_flag,
                assum_override_2_flag,
                assum_override_3_flag,
                assum_override_4_flag,
                assum_override_5_flag,
                assum_override_6_flag,
                dependency_status_type,
                s_email_address_txt,
                nslds_reason_cd,
                app_receipt_date,
                processed_rec_type,
                hist_corr_for_tran_num,
                sys_generated_indicator_type,
                dup_request_indicator_type,
                source_of_correction_type,
                p_cal_tax_status_type,
                s_cal_tax_status_type,
                graduate_flag,
                auto_zero_efc_flag,
                efc_change_flag,
                sarc_flag,
                simplified_need_test_flag,
                reject_reason_codes_txt,
                select_service_match_type,
                select_service_reg_type,
                ins_match_flag,
                ins_verification_num,
                sec_ins_match_type,
                sec_ins_ver_num,
                ssn_match_type,
                ssa_citizenship_type,
                ssn_death_date,
                nslds_match_type,
                va_match_type,
                prisoner_match_flag,
                verification_flag,
                subsequent_app_flag,
                app_source_site_cd,
                tran_source_site_cd,
                drn_num,
                tran_process_date,
                computer_batch_num,
                correction_flags_txt,
                highlight_flags_txt,
                paid_efc_amt,
                primary_efc_amt,
                secondary_efc_amt,
                fed_pell_grant_efc_type,
                primary_efc_type,
                sec_efc_type,
                primary_alt_month_1_amt,
                primary_alt_month_2_amt,
                primary_alt_month_3_amt,
                primary_alt_month_4_amt,
                primary_alt_month_5_amt,
                primary_alt_month_6_amt,
                primary_alt_month_7_amt,
                primary_alt_month_8_amt,
                primary_alt_month_10_amt,
                primary_alt_month_11_amt,
                primary_alt_month_12_amt,
                sec_alternate_month_1_amt,
                sec_alternate_month_2_amt,
                sec_alternate_month_3_amt,
                sec_alternate_month_4_amt,
                sec_alternate_month_5_amt,
                sec_alternate_month_6_amt,
                sec_alternate_month_7_amt,
                sec_alternate_month_8_amt,
                sec_alternate_month_10_amt,
                sec_alternate_month_11_amt,
                sec_alternate_month_12_amt,
                total_income_amt,
                allow_total_income_amt,
                state_tax_allow_amt,
                employment_allow_amt,
                income_protection_allow_amt,
                available_income_amt,
                contribution_from_ai_amt,
                discretionary_networth_amt,
                efc_networth_amt,
                asset_protect_allow_amt,
                parents_cont_from_assets_amt,
                adjusted_avail_income_amt,
                total_student_contrib_amt,
                total_parent_contrib_amt,
                parents_contribution_amt,
                student_total_income_amt,
                sati_amt,
                sic_amt,
                sdnw_amt,
                sca_amt,
                fti_amt,
                secti_amt,
                secati_amt,
                secstx_amt,
                secea_amt,
                secipa_amt,
                secai_amt,
                seccai_amt,
                secdnw_amt,
                secnw_amt,
                secapa_amt,
                SECPCA_AMT,
                secaai_amt,
                sectsc_amt,
                sectpc_amt,
                secpc_amt,
                secsti_amt,
                secsic_amt,
                secsati_amt,
                secsdnw_amt,
                secsca_amt,
                secfti_amt,
                a_citizenship_flag,
                a_studnt_marital_status_flag,
                a_student_agi_amt,
                a_s_us_tax_paid_amt,
                a_s_income_work_amt,
                a_spouse_income_work_amt,
                a_s_total_wsc_amt,
                a_date_of_birth_flag,
                a_student_married_flag,
                a_have_children_flag,
                a_s_have_dependents_flag,
                a_va_status_flag,
                a_s_in_family_num,
                a_s_in_college_num,
                a_p_marital_status_flag,
                a_father_ssn_txt,
                a_mother_ssn_txt,
                a_parents_family_num,
                a_parents_college_num,
                a_parents_agi_amt,
                a_p_us_tax_paid_amt,
                a_f_work_income_amt,
                a_m_work_income_amt,
                a_p_total_wsc_amt,
                comment_codes_txt,
                sar_ack_comm_codes_txt,
                pell_grant_elig_flag,
                reprocess_reason_cd,
                duplicate_date,
                isir_transaction_type,
                fedral_schl_type,
                multi_school_cd_flags_txt,
                dup_ssn_indicator_flag,
                verif_track_type,
                fafsa_data_verification_txt,
                reject_override_a_flag,
                reject_override_c_flag,
                parent_marital_status_date,
                fathr_first_name_initial_txt,
                fathr_step_father_birth_date,
                mothr_first_name_initial_txt,
                mothr_step_mother_birth_date,
                parents_email_address_txt,
                address_change_type,
                cps_pushed_isir_flag,
                electronic_transaction_type,
                sar_c_change_type,
                father_ssn_match_type,
                mother_ssn_match_type,
                reject_override_g_flag,
                dhs_verification_num_txt,
                data_file_name_txt,
                nslds_transaction_num,
                nslds_database_results_type,
                nslds_flag,
                nslds_pell_overpay_type,
                nslds_pell_overpay_cont_txt,
                nslds_seog_overpay_type,
                nslds_seog_overpay_cont_txt,
                nslds_perkins_overpay_type,
                nslds_perk_ovrpay_cntct_txt,
                nslds_defaulted_loan_flag,
                nslds_dischgd_loan_chng_flag,
                nslds_satis_repay_flag,
                nslds_act_bankruptcy_flag,
                nslds_agg_subsz_out_pbal_amt,
                nslds_agg_unsbz_out_pbal_amt,
                nslds_agg_comb_out_pbal_amt,
                nslds_agg_cons_out_pbal_amt,
                nslds_agg_subsz_pnd_disb_amt,
                nslds_agg_unsbz_pnd_disb_amt,
                nslds_agg_comb_pend_disb_amt,
                nslds_agg_subsz_total_amt,
                nslds_agg_unsbz_total_amt,
                nslds_agg_comb_total_amt,
                nslds_agg_consd_total_amt,
                nslds_perkins_out_bal_amt,
                nslds_perkin_cur_yr_disb_amt,
                nslds_default_loan_chng_flag,
                nslds_discharged_loan_type,
                nslds_satis_repay_chng_flag,
                nslds_act_bnkrupt_chng_flag,
                nslds_overpay_chng_flag,
                nslds_agg_loan_chng_flag,
                nslds_perkins_loan_chng_flag,
                nslds_pell_paymnt_chng_flag,
                nslds_addtnl_pell_flag,
                nslds_addtnl_loan_flag,
                direct_loan_mas_prom_nt_type,
                nslds_pell_1_seq_num,
                nslds_pell_1_verify_f_txt,
                nslds_pell_1_efc_amt,
                nslds_pell_1_school_num,
                nslds_pell_1_transcn_num,
                nslds_pell_1_last_updt_date,
                nslds_pell_1_scheduled_amt,
                nslds_pell_1_paid_todt_amt,
                nslds_pell_1_remng_amt,
                nslds_pell_1_pc_scwd_use_amt,
                nslds_pell_1_award_amt,
                nslds_pell_2_seq_num,
                nslds_pell_2_verify_f_txt,
                nslds_pell_2_efc_amt,
                nslds_pell_2_school_num,
                nslds_pell_2_transcn_num,
                nslds_pell_2_last_updt_date,
                nslds_pell_2_scheduled_amt,
                nslds_pell_2_paid_todt_amt,
                nslds_pell_2_remng_amt,
                nslds_pell_2_pc_scwd_use_amt,
                nslds_pell_2_award_amt,
                nslds_pell_3_seq_num,
                nslds_pell_3_verify_f_txt,
                nslds_pell_3_efc_amt,
                nslds_pell_3_school_num,
                nslds_pell_3_transcn_num,
                nslds_pell_3_last_updt_date,
                nslds_pell_3_scheduled_amt,
                nslds_pell_3_paid_todt_amt,
                nslds_pell_3_remng_amt,
                nslds_pell_3_pc_scwd_use_amt,
                nslds_pell_3_award_amt,
                nslds_loan_1_seq_num,
                nslds_loan_1_type,
                nslds_loan_1_chng_flag,
                nslds_loan_1_prog_cd,
                nslds_loan_1_net_amt,
                nslds_loan_1_cur_st_cd,
                nslds_loan_1_cur_st_date,
                nslds_loan_1_agg_pr_bal_amt,
                nslds_loan_1_out_pr_bal_date,
                nslds_loan_1_begin_date,
                nslds_loan_1_end_date,
                nslds_loan_1_ga_cd,
                nslds_loan_1_cont_type,
                nslds_loan_1_schol_cd,
                nslds_loan_1_cont_cd,
                nslds_loan_1_grade_lvl_txt,
                nslds_loan_1_x_unsbz_ln_type,
                nslds_loan_1_captal_int_flag,
                nslds_loan_2_seq_num,
                nslds_loan_2_type,
                nslds_loan_2_chng_flag,
                nslds_loan_2_prog_cd,
                nslds_loan_2_net_amt,
                nslds_loan_2_cur_st_cd,
                nslds_loan_2_cur_st_date,
                nslds_loan_2_agg_pr_bal_amt,
                nslds_loan_2_out_pr_bal_date,
                nslds_loan_2_begin_date,
                nslds_loan_2_end_date,
                nslds_loan_2_ga_cd,
                nslds_loan_2_cont_type,
                nslds_loan_2_schol_cd,
                nslds_loan_2_cont_cd,
                nslds_loan_2_grade_lvl_txt,
                nslds_loan_2_x_unsbz_ln_type,
                nslds_loan_2_captal_int_flag,
                nslds_loan_3_seq_num,
                nslds_loan_3_type,
                nslds_loan_3_chng_flag,
                nslds_loan_3_prog_cd,
                nslds_loan_3_net_amt,
                nslds_loan_3_cur_st_cd,
                nslds_loan_3_cur_st_date,
                nslds_loan_3_agg_pr_bal_amt,
                nslds_loan_3_out_pr_bal_date,
                nslds_loan_3_begin_date,
                nslds_loan_3_end_date,
                nslds_loan_3_ga_cd,
                nslds_loan_3_cont_type,
                nslds_loan_3_schol_cd,
                nslds_loan_3_cont_cd,
                nslds_loan_3_grade_lvl_txt,
                nslds_loan_3_x_unsbz_ln_type,
                nslds_loan_3_captal_int_flag,
                nslds_loan_4_seq_num,
                nslds_loan_4_type,
                nslds_loan_4_chng_flag,
                nslds_loan_4_prog_cd,
                nslds_loan_4_net_amt,
                nslds_loan_4_cur_st_cd,
                nslds_loan_4_cur_st_date,
                nslds_loan_4_agg_pr_bal_amt,
                nslds_loan_4_out_pr_bal_date,
                nslds_loan_4_begin_date,
                nslds_loan_4_end_date,
                nslds_loan_4_ga_cd,
                nslds_loan_4_cont_type,
                nslds_loan_4_schol_cd,
                nslds_loan_4_cont_cd,
                nslds_loan_4_grade_lvl_txt,
                nslds_loan_4_x_unsbz_ln_type,
                nslds_loan_4_captal_int_flag,
                nslds_loan_5_seq_num,
                nslds_loan_5_type,
                nslds_loan_5_chng_flag,
                nslds_loan_5_prog_cd,
                nslds_loan_5_net_amt,
                nslds_loan_5_cur_st_cd,
                nslds_loan_5_cur_st_date,
                nslds_loan_5_agg_pr_bal_amt,
                nslds_loan_5_out_pr_bal_date,
                nslds_loan_5_begin_date,
                nslds_loan_5_end_date,
                nslds_loan_5_ga_cd,
                nslds_loan_5_cont_type,
                nslds_loan_5_schol_cd,
                nslds_loan_5_cont_cd,
                nslds_loan_5_grade_lvl_txt,
                nslds_loan_5_x_unsbz_ln_type,
                nslds_loan_5_captal_int_flag,
                nslds_loan_6_seq_num,
                nslds_loan_6_type,
                nslds_loan_6_chng_flag,
                nslds_loan_6_prog_cd,
                nslds_loan_6_net_amt,
                nslds_loan_6_cur_st_cd,
                nslds_loan_6_cur_st_date,
                nslds_loan_6_agg_pr_bal_amt,
                nslds_loan_6_out_pr_bal_date,
                nslds_loan_6_begin_date,
                nslds_loan_6_end_date,
                nslds_loan_6_ga_cd,
                nslds_loan_6_cont_type,
                nslds_loan_6_schol_cd,
                nslds_loan_6_cont_cd,
                nslds_loan_6_grade_lvl_txt,
                nslds_loan_6_x_unsbz_ln_type,
                nslds_loan_6_captal_int_flag,
                nslds_loan_1_last_disb_amt,
                nslds_loan_1_last_disb_date,
                nslds_loan_2_last_disb_amt,
                nslds_loan_2_last_disb_date,
                nslds_loan_3_last_disb_amt,
                nslds_loan_3_last_disb_date,
                nslds_loan_4_last_disb_amt,
                nslds_loan_4_last_disb_date,
                nslds_loan_5_last_disb_amt,
                nslds_loan_5_last_disb_date,
                nslds_loan_6_last_disb_amt,
                nslds_loan_6_last_disb_date,
                dlp_master_prom_note_type,
                subsidized_loan_limit_type,
                combined_loan_limit_type,
                record_status,
                creation_date,
                created_by,
                last_updated_by,
                last_update_login,
                last_update_date
                ) VALUES (
                max_seq_rec.max_si_id + 1,
                cur_isir_int_rec.batch_year,
                cur_isir_int_rec.transaction_num,
                cur_isir_int_rec.current_ssn,
                cur_isir_int_rec.ssn_name_change,
                cur_isir_int_rec.original_ssn,
                cur_isir_int_rec.orig_name_id,
                cur_isir_int_rec.last_name,
                cur_isir_int_rec.first_name,
                cur_isir_int_rec.middle_initial,
                cur_isir_int_rec.perm_mail_add,
                cur_isir_int_rec.perm_city,
                cur_isir_int_rec.perm_state,
                cur_isir_int_rec.perm_zip_code,
                cur_isir_int_rec.date_of_birth,
                cur_isir_int_rec.phone_number,
                cur_isir_int_rec.driver_license_number,
                cur_isir_int_rec.driver_license_state,
                cur_isir_int_rec.citizenship_status,
                cur_isir_int_rec.alien_reg_number,
                cur_isir_int_rec.s_marital_status,
                cur_isir_int_rec.s_marital_status_date,
                cur_isir_int_rec.summ_enrl_status,
                cur_isir_int_rec.fall_enrl_status,
                cur_isir_int_rec.winter_enrl_status,
                cur_isir_int_rec.spring_enrl_status,
                cur_isir_int_rec.summ2_enrl_status,
                cur_isir_int_rec.fathers_highest_edu_level,
                cur_isir_int_rec.mothers_highest_edu_level,
                cur_isir_int_rec.s_state_legal_residence,
                cur_isir_int_rec.legal_residence_before_date,
                cur_isir_int_rec.s_legal_resd_date,
                cur_isir_int_rec.ss_r_u_male,
                cur_isir_int_rec.selective_service_reg,
                cur_isir_int_rec.degree_certification,
                cur_isir_int_rec.grade_level_in_college,
                cur_isir_int_rec.high_school_diploma_ged,
                cur_isir_int_rec.first_bachelor_deg_by_date,
                cur_isir_int_rec.interest_in_loan,
                cur_isir_int_rec.interest_in_stud_employment,
                cur_isir_int_rec.drug_offence_conviction,
                cur_isir_int_rec.s_tax_return_status,
                cur_isir_int_rec.s_type_tax_return,
                cur_isir_int_rec.s_elig_1040ez,
                cur_isir_int_rec.s_adjusted_gross_income,
                cur_isir_int_rec.s_fed_taxes_paid,
                cur_isir_int_rec.s_exemptions,
                cur_isir_int_rec.s_income_from_work,
                cur_isir_int_rec.spouse_income_from_work,
                cur_isir_int_rec.s_toa_amt_from_wsa,
                cur_isir_int_rec.s_toa_amt_from_wsb,
                cur_isir_int_rec.s_toa_amt_from_wsc,
                cur_isir_int_rec.s_investment_networth,
                cur_isir_int_rec.s_busi_farm_networth,
                cur_isir_int_rec.s_cash_savings,
                cur_isir_int_rec.va_months,
                cur_isir_int_rec.va_amount,
                cur_isir_int_rec.stud_dob_before_date,
                cur_isir_int_rec.deg_beyond_bachelor,
                cur_isir_int_rec.s_married,
                cur_isir_int_rec.s_have_children,
                cur_isir_int_rec.legal_dependents,
                cur_isir_int_rec.orphan_ward_of_court,
                cur_isir_int_rec.s_veteran,
                cur_isir_int_rec.p_marital_status,
                cur_isir_int_rec.father_ssn,
                cur_isir_int_rec.f_last_name,
                cur_isir_int_rec.mother_ssn,
                cur_isir_int_rec.m_last_name,
                cur_isir_int_rec.p_num_family_member,
                cur_isir_int_rec.p_num_in_college,
                cur_isir_int_rec.p_state_legal_residence,
                cur_isir_int_rec.p_state_legal_res_before_dt,
                cur_isir_int_rec.p_legal_res_date,
                cur_isir_int_rec.age_older_parent,
                cur_isir_int_rec.p_tax_return_status,
                cur_isir_int_rec.p_type_tax_return,
                cur_isir_int_rec.p_elig_1040aez,
                cur_isir_int_rec.p_adjusted_gross_income,
                cur_isir_int_rec.p_taxes_paid,
                cur_isir_int_rec.p_exemptions,
                cur_isir_int_rec.f_income_work,
                cur_isir_int_rec.m_income_work,
                cur_isir_int_rec.p_income_wsa,
                cur_isir_int_rec.p_income_wsb,
                cur_isir_int_rec.p_income_wsc,
                cur_isir_int_rec.p_investment_networth,
                cur_isir_int_rec.p_business_networth,
                cur_isir_int_rec.p_cash_saving,
                cur_isir_int_rec.s_num_family_members,
                cur_isir_int_rec.s_num_in_college,
                cur_isir_int_rec.first_college,
                cur_isir_int_rec.first_house_plan,
                cur_isir_int_rec.second_college,
                cur_isir_int_rec.second_house_plan,
                cur_isir_int_rec.third_college,
                cur_isir_int_rec.third_house_plan,
                cur_isir_int_rec.fourth_college,
                cur_isir_int_rec.fourth_house_plan,
                cur_isir_int_rec.fifth_college,
                cur_isir_int_rec.fifth_house_plan,
                cur_isir_int_rec.sixth_college,
                cur_isir_int_rec.sixth_house_plan,
                cur_isir_int_rec.date_app_completed,
                cur_isir_int_rec.signed_by,
                cur_isir_int_rec.preparer_ssn,
                cur_isir_int_rec.preparer_emp_id_number,
                cur_isir_int_rec.preparer_sign,
                cur_isir_int_rec.transaction_receipt_date,
                cur_isir_int_rec.dependency_override_ind,
                cur_isir_int_rec.faa_fedral_schl_code,
                cur_isir_int_rec.faa_adjustment,
                cur_isir_int_rec.input_record_type,
                cur_isir_int_rec.serial_number,
                cur_isir_int_rec.batch_number,
                cur_isir_int_rec.early_analysis_flag,
                cur_isir_int_rec.app_entry_source_code,
                cur_isir_int_rec.eti_destination_code,
                cur_isir_int_rec.reject_override_b,
                cur_isir_int_rec.reject_override_n,
                cur_isir_int_rec.reject_override_w,
                cur_isir_int_rec.assum_override_1,
                cur_isir_int_rec.assum_override_2,
                cur_isir_int_rec.assum_override_3,
                cur_isir_int_rec.assum_override_4,
                cur_isir_int_rec.assum_override_5,
                cur_isir_int_rec.assum_override_6,
                cur_isir_int_rec.dependency_status,
                cur_isir_int_rec.s_email_address,
                cur_isir_int_rec.nslds_reason_code,
                cur_isir_int_rec.app_receipt_date,
                cur_isir_int_rec.processed_rec_type,
                cur_isir_int_rec.hist_correction_for_tran_id,
                cur_isir_int_rec.system_generated_indicator,
                cur_isir_int_rec.dup_request_indicator,
                cur_isir_int_rec.source_of_correction,
                cur_isir_int_rec.p_cal_tax_status,
                cur_isir_int_rec.s_cal_tax_status,
                cur_isir_int_rec.graduate_flag,
                cur_isir_int_rec.auto_zero_efc,
                cur_isir_int_rec.efc_change_flag,
                cur_isir_int_rec.sarc_flag,
                cur_isir_int_rec.simplified_need_test,
                cur_isir_int_rec.reject_reason_codes,
                cur_isir_int_rec.select_service_match_flag,
                cur_isir_int_rec.select_service_reg_flag,
                cur_isir_int_rec.ins_match_flag,
                cur_isir_int_rec.ins_verification_number,
                cur_isir_int_rec.sec_ins_match_flag,
                cur_isir_int_rec.sec_ins_ver_number,
                cur_isir_int_rec.ssn_match_flag,
                cur_isir_int_rec.ssa_citizenship_flag,
                cur_isir_int_rec.ssn_date_of_death,
                cur_isir_int_rec.nslds_match_flag,
                cur_isir_int_rec.va_match_flag,
                cur_isir_int_rec.prisoner_match,
                cur_isir_int_rec.verification_flag,
                cur_isir_int_rec.subsequent_app_flag,
                cur_isir_int_rec.app_source_site_code,
                cur_isir_int_rec.tran_source_site_code,
                cur_isir_int_rec.drn,
                cur_isir_int_rec.tran_process_date,
                cur_isir_int_rec.computer_batch_number,
                cur_isir_int_rec.correction_flags,
                cur_isir_int_rec.highlight_flags,
                cur_isir_int_rec.paid_efc,
                cur_isir_int_rec.primary_efc,
                cur_isir_int_rec.secondary_efc,
                cur_isir_int_rec.fed_pell_grant_efc_type,
                cur_isir_int_rec.primary_efc_type,
                cur_isir_int_rec.sec_efc_type,
                cur_isir_int_rec.primary_alternate_month_1,
                cur_isir_int_rec.primary_alternate_month_2,
                cur_isir_int_rec.primary_alternate_month_3,
                cur_isir_int_rec.primary_alternate_month_4,
                cur_isir_int_rec.primary_alternate_month_5,
                cur_isir_int_rec.primary_alternate_month_6,
                cur_isir_int_rec.primary_alternate_month_7,
                cur_isir_int_rec.primary_alternate_month_8,
                cur_isir_int_rec.primary_alternate_month_10,
                cur_isir_int_rec.primary_alternate_month_11,
                cur_isir_int_rec.primary_alternate_month_12,
                cur_isir_int_rec.sec_alternate_month_1,
                cur_isir_int_rec.sec_alternate_month_2,
                cur_isir_int_rec.sec_alternate_month_3,
                cur_isir_int_rec.sec_alternate_month_4,
                cur_isir_int_rec.sec_alternate_month_5,
                cur_isir_int_rec.sec_alternate_month_6,
                cur_isir_int_rec.sec_alternate_month_7,
                cur_isir_int_rec.sec_alternate_month_8,
                cur_isir_int_rec.sec_alternate_month_10,
                cur_isir_int_rec.sec_alternate_month_11,
                cur_isir_int_rec.sec_alternate_month_12,
                cur_isir_int_rec.total_income,
                cur_isir_int_rec.allow_total_income,
                cur_isir_int_rec.state_tax_allow,
                cur_isir_int_rec.employment_allow,
                cur_isir_int_rec.income_protection_allow,
                cur_isir_int_rec.available_income,
                cur_isir_int_rec.contribution_from_ai,
                cur_isir_int_rec.discretionary_networth,
                cur_isir_int_rec.efc_networth,
                cur_isir_int_rec.asset_protect_allow,
                cur_isir_int_rec.parents_cont_from_assets,
                cur_isir_int_rec.adjusted_available_income,
                cur_isir_int_rec.total_student_contribution,
                cur_isir_int_rec.total_parent_contribution,
                cur_isir_int_rec.parents_contribution,
                cur_isir_int_rec.student_total_income,
                cur_isir_int_rec.sati,
                cur_isir_int_rec.sic,
                cur_isir_int_rec.sdnw,
                cur_isir_int_rec.sca,
                cur_isir_int_rec.fti,
                cur_isir_int_rec.secti,
                cur_isir_int_rec.secati,
                cur_isir_int_rec.secstx,
                cur_isir_int_rec.secea,
                cur_isir_int_rec.secipa,
                cur_isir_int_rec.secai,
                cur_isir_int_rec.seccai,
                cur_isir_int_rec.secdnw,
                cur_isir_int_rec.secnw,
                cur_isir_int_rec.secapa,
                cur_isir_int_rec.secpca,
                cur_isir_int_rec.secaai,
                cur_isir_int_rec.sectsc,
                cur_isir_int_rec.sectpc,
                cur_isir_int_rec.secpc,
                cur_isir_int_rec.secsti,
                cur_isir_int_rec.secsic,
                cur_isir_int_rec.secsati,
                cur_isir_int_rec.secsdnw,
                cur_isir_int_rec.secsca,
                cur_isir_int_rec.secfti,
                cur_isir_int_rec.a_citizenship,
                cur_isir_int_rec.a_student_marital_status,
                cur_isir_int_rec.a_student_agi,
                cur_isir_int_rec.a_s_us_tax_paid,
                cur_isir_int_rec.a_s_income_work,
                cur_isir_int_rec.a_spouse_income_work,
                cur_isir_int_rec.a_s_total_wsc,
                cur_isir_int_rec.a_date_of_birth,
                cur_isir_int_rec.a_student_married,
                cur_isir_int_rec.a_have_children,
                cur_isir_int_rec.a_s_have_dependents,
                cur_isir_int_rec.a_va_status,
                cur_isir_int_rec.a_s_num_in_family,
                cur_isir_int_rec.a_s_num_in_college,
                cur_isir_int_rec.a_p_marital_status,
                cur_isir_int_rec.a_father_ssn,
                cur_isir_int_rec.a_mother_ssn,
                cur_isir_int_rec.a_parents_num_family,
                cur_isir_int_rec.a_parents_num_college,
                cur_isir_int_rec.a_parents_agi,
                cur_isir_int_rec.a_p_us_tax_paid,
                cur_isir_int_rec.a_f_work_income,
                cur_isir_int_rec.a_m_work_income,
                cur_isir_int_rec.a_p_total_wsc,
                cur_isir_int_rec.comment_codes,
                cur_isir_int_rec.sar_ack_comm_code,
                cur_isir_int_rec.pell_grant_elig_flag,
                cur_isir_int_rec.reprocess_reason_code,
                cur_isir_int_rec.duplicate_date,
                cur_isir_int_rec.isir_transaction_type,
                cur_isir_int_rec.fedral_schl_code_indicator,
                cur_isir_int_rec.multi_school_code_flags,
                cur_isir_int_rec.dup_ssn_indicator,
                cur_isir_int_rec.verif_track_flag,
                cur_isir_int_rec.fafsa_data_verify_flags,
                cur_isir_int_rec.reject_override_a,
                cur_isir_int_rec.reject_override_c,
                cur_isir_int_rec.parent_marital_status_date,
                cur_isir_int_rec.father_first_name_initial_txt,
                cur_isir_int_rec.father_step_father_birth_date,
                cur_isir_int_rec.mother_first_name_initial_txt,
                cur_isir_int_rec.mother_step_mother_birth_date,
                cur_isir_int_rec.parents_email_address_txt,
                cur_isir_int_rec.address_change_type,
                cur_isir_int_rec.cps_pushed_isir_flag,
                cur_isir_int_rec.electronic_transaction_type,
                cur_isir_int_rec.sar_c_change_type,
                cur_isir_int_rec.father_ssn_match_type,
                cur_isir_int_rec.mother_ssn_match_type,
                cur_isir_int_rec.reject_override_g_flag,
                cur_isir_int_rec.dhs_verification_num_txt,
                cur_isir_int_rec.data_file_name_txt,
                cur_isir_int_rec.nslds_transaction_num,
                cur_isir_int_rec.nslds_database_results_f,
                cur_isir_int_rec.nslds_f,
                cur_isir_int_rec.nslds_pell_overpay_f,
                cur_isir_int_rec.nslds_pell_overpay_contact,
                cur_isir_int_rec.nslds_seog_overpay_f,
                cur_isir_int_rec.nslds_seog_overpay_contact,
                cur_isir_int_rec.nslds_perkins_overpay_f,
                cur_isir_int_rec.nslds_perkins_overpay_cntct,
                cur_isir_int_rec.nslds_defaulted_loan_f,
                cur_isir_int_rec.nslds_dischged_loan_chng_f,
                cur_isir_int_rec.nslds_satis_repay_f,
                cur_isir_int_rec.nslds_act_bankruptcy_f,
                cur_isir_int_rec.nslds_agg_subsz_out_prin_bal,
                cur_isir_int_rec.nslds_agg_unsbz_out_prin_bal,
                cur_isir_int_rec.nslds_agg_comb_out_prin_bal,
                cur_isir_int_rec.nslds_agg_cons_out_prin_bal,
                cur_isir_int_rec.nslds_agg_subsz_pend_dismt,
                cur_isir_int_rec.nslds_agg_unsbz_pend_dismt,
                cur_isir_int_rec.nslds_agg_comb_pend_dismt,
                cur_isir_int_rec.nslds_agg_subsz_total,
                cur_isir_int_rec.nslds_agg_unsbz_total,
                cur_isir_int_rec.nslds_agg_comb_total,
                cur_isir_int_rec.nslds_agg_consd_total,
                cur_isir_int_rec.nslds_perkins_out_bal,
                cur_isir_int_rec.nslds_perkins_cur_yr_dismnt,
                cur_isir_int_rec.nslds_default_loan_chng_f,
                cur_isir_int_rec.nslds_discharged_loan_f,
                cur_isir_int_rec.nslds_satis_repay_chng_f,
                cur_isir_int_rec.nslds_act_bnkrupt_chng_f,
                cur_isir_int_rec.nslds_overpay_chng_f,
                cur_isir_int_rec.nslds_agg_loan_chng_f,
                cur_isir_int_rec.nslds_perkins_loan_chng_f,
                cur_isir_int_rec.nslds_pell_paymnt_chng_f,
                cur_isir_int_rec.nslds_addtnl_pell_f,
                cur_isir_int_rec.nslds_addtnl_loan_f,
                cur_isir_int_rec.direct_loan_mas_prom_nt_f,
                cur_isir_int_rec.nslds_pell_seq_num_1,
                cur_isir_int_rec.nslds_pell_verify_f_1,
                cur_isir_int_rec.nslds_pell_efc_1,
                cur_isir_int_rec.nslds_pell_school_code_1,
                cur_isir_int_rec.nslds_pell_transcn_num_1,
                cur_isir_int_rec.nslds_pell_last_updt_dt_1,
                cur_isir_int_rec.nslds_pell_scheduled_amt_1,
                cur_isir_int_rec.nslds_pell_amt_paid_todt_1,
                cur_isir_int_rec.nslds_pell_remng_amt_1,
                cur_isir_int_rec.nslds_pell_pc_schd_awd_us_1,
                cur_isir_int_rec.nslds_pell_award_amt_1,
                cur_isir_int_rec.nslds_pell_seq_num_2,
                cur_isir_int_rec.nslds_pell_verify_f_2,
                cur_isir_int_rec.nslds_pell_efc_2,
                cur_isir_int_rec.nslds_pell_school_code_2,
                cur_isir_int_rec.nslds_pell_transcn_num_2,
                cur_isir_int_rec.nslds_pell_last_updt_dt_2,
                cur_isir_int_rec.nslds_pell_scheduled_amt_2,
                cur_isir_int_rec.nslds_pell_amt_paid_todt_2,
                cur_isir_int_rec.nslds_pell_remng_amt_2,
                cur_isir_int_rec.nslds_pell_pc_schd_awd_us_2,
                cur_isir_int_rec.nslds_pell_award_amt_2,
                cur_isir_int_rec.nslds_pell_seq_num_3,
                cur_isir_int_rec.nslds_pell_verify_f_3,
                cur_isir_int_rec.nslds_pell_efc_3,
                cur_isir_int_rec.nslds_pell_school_code_3,
                cur_isir_int_rec.nslds_pell_transcn_num_3,
                cur_isir_int_rec.nslds_pell_last_updt_dt_3,
                cur_isir_int_rec.nslds_pell_scheduled_amt_3,
                cur_isir_int_rec.nslds_pell_amt_paid_todt_3,
                cur_isir_int_rec.nslds_pell_remng_amt_3,
                cur_isir_int_rec.nslds_pell_pc_schd_awd_us_3,
                cur_isir_int_rec.nslds_pell_award_amt_3,
                cur_isir_int_rec.nslds_loan_seq_num_1,
                cur_isir_int_rec.nslds_loan_type_code_1,
                cur_isir_int_rec.nslds_loan_chng_f_1,
                cur_isir_int_rec.nslds_loan_prog_code_1,
                cur_isir_int_rec.nslds_loan_net_amnt_1,
                cur_isir_int_rec.nslds_loan_cur_st_code_1,
                cur_isir_int_rec.nslds_loan_cur_st_date_1,
                cur_isir_int_rec.nslds_loan_agg_pr_bal_1,
                cur_isir_int_rec.nslds_loan_out_pr_bal_dt_1,
                cur_isir_int_rec.nslds_loan_begin_dt_1,
                cur_isir_int_rec.nslds_loan_end_dt_1,
                cur_isir_int_rec.nslds_loan_ga_code_1,
                cur_isir_int_rec.nslds_loan_cont_type_1,
                cur_isir_int_rec.nslds_loan_schol_code_1,
                cur_isir_int_rec.nslds_loan_cont_code_1,
                cur_isir_int_rec.nslds_loan_grade_lvl_1,
                cur_isir_int_rec.nslds_loan_xtr_unsbz_ln_f_1,
                cur_isir_int_rec.nslds_loan_capital_int_f_1,
                cur_isir_int_rec.nslds_loan_seq_num_2,
                cur_isir_int_rec.nslds_loan_type_code_2,
                cur_isir_int_rec.nslds_loan_chng_f_2,
                cur_isir_int_rec.nslds_loan_prog_code_2,
                cur_isir_int_rec.nslds_loan_net_amnt_2,
                cur_isir_int_rec.nslds_loan_cur_st_code_2,
                cur_isir_int_rec.nslds_loan_cur_st_date_2,
                cur_isir_int_rec.nslds_loan_agg_pr_bal_2,
                cur_isir_int_rec.nslds_loan_out_pr_bal_dt_2,
                cur_isir_int_rec.nslds_loan_begin_dt_2,
                cur_isir_int_rec.nslds_loan_end_dt_2,
                cur_isir_int_rec.nslds_loan_ga_code_2,
                cur_isir_int_rec.nslds_loan_cont_type_2,
                cur_isir_int_rec.nslds_loan_schol_code_2,
                cur_isir_int_rec.nslds_loan_cont_code_2,
                cur_isir_int_rec.nslds_loan_grade_lvl_2,
                cur_isir_int_rec.nslds_loan_xtr_unsbz_ln_f_2,
                cur_isir_int_rec.nslds_loan_capital_int_f_2,
                cur_isir_int_rec.nslds_loan_seq_num_3,
                cur_isir_int_rec.nslds_loan_type_code_3,
                cur_isir_int_rec.nslds_loan_chng_f_3,
                cur_isir_int_rec.nslds_loan_prog_code_3,
                cur_isir_int_rec.nslds_loan_net_amnt_3,
                cur_isir_int_rec.nslds_loan_cur_st_code_3,
                cur_isir_int_rec.nslds_loan_cur_st_date_3,
                cur_isir_int_rec.nslds_loan_agg_pr_bal_3,
                cur_isir_int_rec.nslds_loan_out_pr_bal_dt_3,
                cur_isir_int_rec.nslds_loan_begin_dt_3,
                cur_isir_int_rec.nslds_loan_end_dt_3,
                cur_isir_int_rec.nslds_loan_ga_code_3,
                cur_isir_int_rec.nslds_loan_cont_type_3,
                cur_isir_int_rec.nslds_loan_schol_code_3,
                cur_isir_int_rec.nslds_loan_cont_code_3,
                cur_isir_int_rec.nslds_loan_grade_lvl_3,
                cur_isir_int_rec.nslds_loan_xtr_unsbz_ln_f_3,
                cur_isir_int_rec.nslds_loan_capital_int_f_3,
                cur_isir_int_rec.nslds_loan_seq_num_4,
                cur_isir_int_rec.nslds_loan_type_code_4,
                cur_isir_int_rec.nslds_loan_chng_f_4,
                cur_isir_int_rec.nslds_loan_prog_code_4,
                cur_isir_int_rec.nslds_loan_net_amnt_4,
                cur_isir_int_rec.nslds_loan_cur_st_code_4,
                cur_isir_int_rec.nslds_loan_cur_st_date_4,
                cur_isir_int_rec.nslds_loan_agg_pr_bal_4,
                cur_isir_int_rec.nslds_loan_out_pr_bal_dt_4,
                cur_isir_int_rec.nslds_loan_begin_dt_4,
                cur_isir_int_rec.nslds_loan_end_dt_4,
                cur_isir_int_rec.nslds_loan_ga_code_4,
                cur_isir_int_rec.nslds_loan_cont_type_4,
                cur_isir_int_rec.nslds_loan_schol_code_4,
                cur_isir_int_rec.nslds_loan_cont_code_4,
                cur_isir_int_rec.nslds_loan_grade_lvl_4,
                cur_isir_int_rec.nslds_loan_xtr_unsbz_ln_f_4,
                cur_isir_int_rec.nslds_loan_capital_int_f_4,
                cur_isir_int_rec.nslds_loan_seq_num_5,
                cur_isir_int_rec.nslds_loan_type_code_5,
                cur_isir_int_rec.nslds_loan_chng_f_5,
                cur_isir_int_rec.nslds_loan_prog_code_5,
                cur_isir_int_rec.nslds_loan_net_amnt_5,
                cur_isir_int_rec.nslds_loan_cur_st_code_5,
                cur_isir_int_rec.nslds_loan_cur_st_date_5,
                cur_isir_int_rec.nslds_loan_agg_pr_bal_5,
                cur_isir_int_rec.nslds_loan_out_pr_bal_dt_5,
                cur_isir_int_rec.nslds_loan_begin_dt_5,
                cur_isir_int_rec.nslds_loan_end_dt_5,
                cur_isir_int_rec.nslds_loan_ga_code_5,
                cur_isir_int_rec.nslds_loan_cont_type_5,
                cur_isir_int_rec.nslds_loan_schol_code_5,
                cur_isir_int_rec.nslds_loan_cont_code_5,
                cur_isir_int_rec.nslds_loan_grade_lvl_5,
                cur_isir_int_rec.nslds_loan_xtr_unsbz_ln_f_5,
                cur_isir_int_rec.nslds_loan_capital_int_f_5,
                cur_isir_int_rec.nslds_loan_seq_num_6,
                cur_isir_int_rec.nslds_loan_type_code_6,
                cur_isir_int_rec.nslds_loan_chng_f_6,
                cur_isir_int_rec.nslds_loan_prog_code_6,
                cur_isir_int_rec.nslds_loan_net_amnt_6,
                cur_isir_int_rec.nslds_loan_cur_st_code_6,
                cur_isir_int_rec.nslds_loan_cur_st_date_6,
                cur_isir_int_rec.nslds_loan_agg_pr_bal_6,
                cur_isir_int_rec.nslds_loan_out_pr_bal_dt_6,
                cur_isir_int_rec.nslds_loan_begin_dt_6,
                cur_isir_int_rec.nslds_loan_end_dt_6,
                cur_isir_int_rec.nslds_loan_ga_code_6,
                cur_isir_int_rec.nslds_loan_cont_type_6,
                cur_isir_int_rec.nslds_loan_schol_code_6,
                cur_isir_int_rec.nslds_loan_cont_code_6,
                cur_isir_int_rec.nslds_loan_grade_lvl_6,
                cur_isir_int_rec.nslds_loan_xtr_unsbz_ln_f_6,
                cur_isir_int_rec.nslds_loan_capital_int_f_6,
                cur_isir_int_rec.nslds_loan_last_d_amt_1,
                cur_isir_int_rec.nslds_loan_last_d_date_1,
                cur_isir_int_rec.nslds_loan_last_d_amt_2,
                cur_isir_int_rec.nslds_loan_last_d_date_2,
                cur_isir_int_rec.nslds_loan_last_d_amt_3,
                cur_isir_int_rec.nslds_loan_last_d_date_3,
                cur_isir_int_rec.nslds_loan_last_d_amt_4,
                cur_isir_int_rec.nslds_loan_last_d_date_4,
                cur_isir_int_rec.nslds_loan_last_d_amt_5,
                cur_isir_int_rec.nslds_loan_last_d_date_5,
                cur_isir_int_rec.nslds_loan_last_d_amt_6,
                cur_isir_int_rec.nslds_loan_last_d_date_6,
                cur_isir_int_rec.dlp_master_prom_note_flag,
                cur_isir_int_rec.subsidized_loan_limit_type,
                cur_isir_int_rec.combined_loan_limit_type,
                'UNMATCHED',
                SYSDATE,
                fnd_global.user_id,
                fnd_global.user_id,
                fnd_global.login_id,
                SYSDATE
                );

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.debug','After insert row into igf_ap_isir_ints ');
        END IF;
        l_isir_data_from_mtch_tbl := TRUE;

      END IF;

    END IF;

    IF l_isir_data_from_mtch_tbl THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.debug','Before opening the cursor cur_get_rowid_nslds ');
      END IF;

      -- Delete the NSLDS Data
      rec_get_rowid_nslds := null;
      OPEN cur_get_rowid_nslds(p_isir_id);
      FETCH cur_get_rowid_nslds INTO rec_get_rowid_nslds;
      CLOSE cur_get_rowid_nslds;


      IF (rec_get_rowid_nslds.row_id IS NOT NULL) THEN
        igf_ap_nslds_data_pkg.delete_row(rec_get_rowid_nslds.row_id);
      END IF; -- NSLDS

        -- Delete the ISIR Data
        IF (rec_get_rowid_isir.row_id IS NOT NULL) THEN
          igf_ap_isir_matched_pkg.delete_row(rec_get_rowid_isir.row_id);

          -- Processing TODO Items. If the ISIR delete is the only ISIR present in system,
          --Update the status of ISIR todo Item to "REQUESTED"
            OPEN get_isir(p_base_id);
            FETCH get_isir INTO l_isir;
            IF get_isir%NOTFOUND THEN
             CLOSE get_isir;

               -- update the status to Requested
               FOR todo_items_for_isir_rec IN todo_items_for_isir_cur(p_base_id) LOOP
                  igf_ap_td_item_inst_pkg.update_row (
                    x_rowid                        => todo_items_for_isir_rec.rowid               ,
                    x_base_id                      => p_base_id                                   ,
                    x_item_sequence_number         => todo_items_for_isir_rec.item_sequence_number,
                    x_status                       => 'REQ'                                       ,
                    x_status_date                  => todo_items_for_isir_rec.status_date         ,
                    x_add_date                     => todo_items_for_isir_rec.add_date            ,
                    x_corsp_date                   => todo_items_for_isir_rec.corsp_date          ,
                    x_corsp_count                  => todo_items_for_isir_rec.corsp_count         ,
                    x_inactive_flag                => todo_items_for_isir_rec.inactive_flag       ,
                    x_freq_attempt                 => todo_items_for_isir_rec.freq_attempt        ,
                    x_max_attempt                  => todo_items_for_isir_rec.max_attempt         ,
                    x_required_for_application     => todo_items_for_isir_rec.required_for_application,
                    x_mode                         => 'R'                                        ,
                    x_legacy_record_flag           => todo_items_for_isir_rec.legacy_record_flag,
                    x_clprl_id                     => todo_items_for_isir_rec.clprl_id
                 );
               END LOOP;
            ELSE
             CLOSE get_isir;
            END IF;
        END IF; -- ISIR


    END IF; -- l_isir_data_from_mtch_tbl


    x_return_status := 'S';
    fnd_msg_pub.count_and_get(
                              p_encoded  => fnd_api.g_false,
                              p_count    => x_msg_count,
                              p_data     => x_msg_data
                             );

  EXCEPTION

    WHEN RETURN_EXP THEN
      x_return_status := 'S';
      fnd_msg_pub.count_and_get(
                                p_encoded  => fnd_api.g_false,
                                p_count    => x_msg_count,
                                p_data     => x_msg_data
                               );

    WHEN OTHERS THEN

      ROLLBACK TO IGFAP47_DELETE_ISIR;

      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.delete_isir.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.delete_isir');

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_err_msg := fnd_message.get||SQLERRM;
      fnd_msg_pub.count_and_get(
                                p_encoded  => fnd_api.g_false,
                                p_count    => x_msg_count,
                                p_data     => l_err_msg --x_msg_data
                               );

  END delete_isir;



  PROCEDURE delete_person_match (
                                 p_si_id   IN    NUMBER
                                ) IS
    /*
    ||  Created By : ugummall
    ||  Created On : 05-Aug-2004
    ||  Purpose : This Procedure does the following tasks.
    ||          1.
    ||          2.
    ||          3.
    ||          4.
    ||          5.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

    -- Cursor to fetch apm_id from person match table of an isir interface record.
    CURSOR cur_get_person_match ( cp_si_id  igf_ap_person_match_all.si_id%TYPE) IS
      SELECT ROWID row_id, apm_id
        FROM IGF_AP_PERSON_MATCH_ALL permatch
       WHERE permatch.si_id = cp_si_id;

    -- Cursor to fetch rowids of child records (match detail records) of person match record.
    CURSOR cur_get_match_detail ( cp_apm_id  igf_ap_person_match_all.apm_id%TYPE) IS
      SELECT ROWID row_id
        FROM IGF_AP_MATCH_DETAILS matchdtls
       WHERE matchdtls.apm_id = cp_apm_id;

    rec_get_person_match  cur_get_person_match%ROWTYPE;
    rec_get_match_detail cur_get_match_detail%ROWTYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_person_match.debug','starting delete_person_match with p_si_id : ' || p_si_id);
    END IF;

    -- Get APM_ID from SI_ID
    rec_get_person_match := null;
    OPEN cur_get_person_match(p_si_id);
    FETCH cur_get_person_match INTO rec_get_person_match;
    CLOSE cur_get_person_match;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_person_match.debug','Before for-loop rec_get_match_detail ');
    END IF;

    -- Delete match detail records (child records)
    FOR rec_get_match_detail IN cur_get_match_detail(rec_get_person_match.apm_id) LOOP
      igf_ap_match_details_pkg.delete_row(rec_get_match_detail.row_id);
    END LOOP;

    -- Delete person match record (parent record)
    igf_ap_person_match_pkg.delete_row(rec_get_person_match.row_id);

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.delete_person_match.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.delete_person_match');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
  END delete_person_match;


  PROCEDURE delete_interface_record (
                                     p_si_id       IN          NUMBER,
                                     lv_status     OUT NOCOPY  VARCHAR2
                                    ) IS
    /*
    ||  Created By : ugummall
    ||  Created On : 05-Aug-2004
    ||  Purpose : This Procedure does the following tasks.
    ||          1. Deletes the record in ISIR interface table.
    ||          2. Deletes the corresponding match detail records.
    ||          3. Deletes the corresponding record in person match table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

    -- Cursor to get rowid of the ISIR interface record.
    CURSOR cur_get_rowid_interface ( cp_si_id igf_ap_isir_intrface.si_id%TYPE) IS
    SELECT ROWID row_id
      FROM IGF_AP_ISIR_INTS_ALL intface
     WHERE intface.si_id = cp_si_id;

    rec_get_rowid_interface cur_get_rowid_interface%ROWTYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_interface_record.debug','starting delete_interface_record with p_si_id : ' || p_si_id);
    END IF;

    -- get row id of the ISIR interface record to be deleted.
    OPEN cur_get_rowid_interface(p_si_id);
    FETCH cur_get_rowid_interface INTO rec_get_rowid_interface;
    IF (cur_get_rowid_interface%NOTFOUND) THEN
      CLOSE cur_get_rowid_interface;
      lv_status := 'E';
      RETURN;
    END IF;
    CLOSE cur_get_rowid_interface;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_interface_record.debug','Before deleting record from isir_ints table and person match table');
    END IF;

    -- delete the interface record.
    --igf_ap_isir_intrface_pkg.delete_row(rec_get_rowid_interface.row_id);
    DELETE IGF_AP_ISIR_INTS_ALL WHERE si_id = p_si_id;

    -- delete person match record and match details records
    delete_person_match(p_si_id => p_si_id);

    lv_status := 'S';

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.delete_interface_person_match.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.delete_interface_person_match');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      lv_status := 'E';
  END delete_interface_record;


  PROCEDURE delete_int_records (
                                p_si_ids  IN  VARCHAR2
                               ) IS
    /*
    ||  Created By : ugummall
    ||  Created On : 05-Aug-2004
    ||  Purpose : This Procedure does the following tasks.
    ||          1. Deletes the record in ISIR interface table.
    ||          2. Deletes the corresponding match detail records.
    ||          3. Deletes the corresponding record in person match table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

    l_del_si_id  VARCHAR2(10);
    l_si_id      VARCHAR2(10);
    l_si_ids     VARCHAR2(1000);
    lv_status     VARCHAR2(2);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_int_records.debug','starting delete_int_records with p_si_ids : ' || p_si_ids);
    END IF;

    l_si_ids := p_si_ids;

    LOOP

      l_si_ids := TRIM(SUBSTR(l_si_ids, INSTR(l_si_ids, '*') + 1, LENGTH(l_si_ids)));
      l_si_id  := TRIM(SUBSTR(l_si_ids, 1, INSTR(l_si_ids, '*') - 1));
      l_si_ids := TRIM(SUBSTR(l_si_ids, INSTR(l_si_ids, ',') + 1, LENGTH(l_si_ids)));

      IF (l_si_id IS NULL) THEN
        l_del_si_id := l_si_ids;
      ELSE
        l_del_si_id := l_si_id;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.delete_int_records.debug','Calling delete_interface_record with the l_del_si_id '|| l_del_si_id);
      END IF;

      delete_interface_record( p_si_id => l_del_si_id, lv_status => lv_status);

      IF (l_si_id IS NULL) THEN
        EXIT; -- exit from loop.
      END IF;

    END LOOP;

  END delete_int_records;


  PROCEDURE is_isir_exists (
                            p_si_id       IN         NUMBER,
                            p_batch_year  IN         NUMBER,
                            p_status      OUT NOCOPY VARCHAR2
                           ) IS
    /*
    ||  Created By : rasahoo
    ||  Created On :
    ||  Purpose : This Procedure does the following tasks.
    ||          1. Checks whether student has any ISIR present in ISIR Matched table
    ||             with the primary attributes of the student ISIR
    ||             If it finds then returns Y else return N
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

    CURSOR cur_isir_exists (cp_si_id NUMBER, cp_batch_year NUMBER) IS
    SELECT 1
      FROM igf_ap_isir_matched iim,
           igf_ap_isir_ints_all isir
     WHERE iim.original_ssn       = isir.original_ssn_txt
       AND iim.orig_name_id       = isir.orig_name_id_txt
       AND iim.system_record_type = 'ORIGINAL'
       AND isir.si_id             = cp_si_id
       AND iim.batch_year         = cp_batch_year;

    rec_isir_exists cur_isir_exists%ROWTYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.is_isir_exists.debug','starting is_isir_exists with p_si_id : ' || p_si_id ||' p_batch_year : '|| p_batch_year);
    END IF;

    -- Checks whether student has any ISIR present in ISIR Matched table with the primary attributes of the student ISIR
    OPEN cur_isir_exists(p_si_id,p_batch_year);
    FETCH cur_isir_exists INTO rec_isir_exists;
    IF (cur_isir_exists%NOTFOUND) THEN
      p_status := 'N';
      CLOSE cur_isir_exists;
    ELSE
       p_status := 'Y';
      CLOSE cur_isir_exists;
    END IF;

  END is_isir_exists;


  FUNCTION is_awards_exists (
                             p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE
                            ) RETURN VARCHAR2 IS
    /*
    ||  Created By : rasahoo
    ||  Created On :
    ||  Purpose : This Procedure does the following tasks.
    ||          1. check if the student has already some awards then return 'A'
    ||          2. check if non-simulated awards exists for the student.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

    -- Cursor to check wether the student has any non-simulated awards.
    CURSOR cur_stud_non_simulated_awards( cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) IS
    SELECT 'X'
      FROM IGF_AW_AWARD_ALL awards
     WHERE awards.base_id = cp_base_id
       AND awards.award_status <> 'SIMULATED';

    lv_dummy VARCHAR2(1);

  BEGIN


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.is_awards_exists.debug','starting is_awards_exists with p_base_id : ' || p_base_id);
    END IF;

    -- validate the input parameters
    IF p_base_id IS NULL THEN
      RETURN 'N';
    END IF;

    -- check if the student has already some awards then return 'A'
    -- check if non-simulated awards exists for the student.
    lv_dummy := null;
    OPEN cur_stud_non_simulated_awards(p_base_id);
    FETCH cur_stud_non_simulated_awards INTO lv_dummy;
    CLOSE cur_stud_non_simulated_awards;
    IF (lv_dummy = 'X') THEN
      RETURN 'A';
    END IF;

    RETURN 'N';

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.is_awards_exists.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.is_awards_exists');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      RETURN 'N';
  END is_awards_exists;


  FUNCTION chk_pell_orig (
                          p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_isir_id         IN     igf_ap_isir_matched_all.isir_id%TYPE
                         ) RETURN VARCHAR2 IS
    /*
    ||  Created By : rasahoo
    ||  Created On :
    ||  Purpose : This Procedure does the following tasks.
    ||          1. Checks whether the Pell Origination transaction number is same as the
    ||             current Payment ISIR transaction number If not same, it returns 'P' else return 'N'
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

    -- Cursor to check wether the student has any non-simulated awards.
    CURSOR cur_pell_orig_chk(
                             cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                             cp_isir_id   igf_ap_isir_matched_all.isir_id%TYPE
                            ) IS
    SELECT
      isir.transaction_num isir_trans,
      rfms.transaction_num rfms_trans
     FROM igf_ap_isir_matched_all isir, igf_gr_rfms_all rfms
     WHERE isir.base_id = rfms.base_id
       AND isir.base_id = cp_base_id
       AND isir.isir_id = cp_isir_id ;

    lv_pell_orig_rec cur_pell_orig_chk%ROWTYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.chk_pell_orig.debug','starting chk_pell_orig with p_base_id : ' || p_base_id ||' p_isir_id : '|| p_isir_id);
    END IF;

    -- validate the input parameters
    IF (p_base_id IS NULL OR p_isir_id IS NULL) THEN
      RETURN 'N';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.chk_pell_orig.debug','Before calling cur_pell_orig_chk ');
    END IF;

    -- if the PELL origination isir is different from the selected ISIR then return 'P'
    lv_pell_orig_rec := null;
    OPEN cur_pell_orig_chk(p_base_id, p_isir_id);
    FETCH cur_pell_orig_chk INTO lv_pell_orig_rec;
    IF cur_pell_orig_chk%FOUND THEN
      CLOSE cur_pell_orig_chk;

      -- Raise the message only if the RFMS Transaction Number is different
      -- from the current Payment ISIR Transaction Number.
      IF lv_pell_orig_rec.isir_trans <> NVL(lv_pell_orig_rec.rfms_trans,-1) THEN
        RETURN 'P';
      ELSE
        RETURN 'N';
      END IF;
    ELSE
      CLOSE cur_pell_orig_chk;
      RETURN 'N';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.chk_pell_orig.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.chk_pell_orig');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      RETURN 'N';
  END chk_pell_orig;


  FUNCTION make_awarding_isir (
                               p_base_id         IN      igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_isir_id         IN     igf_ap_isir_matched_all.isir_id%TYPE
                              ) RETURN VARCHAR2 IS
    /*
    ||  Created By : rasahoo
    ||  Created On :
    ||  Purpose : This Procedure does the following tasks.
    ||          1. Marks the given ISIR ID as both Awarding and Payment ISIR
    ||          2. Un-Marks all other ISIRs for the given baseid as NON-Payment and NON-Awarding.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

    -- Get all the ISIRs of the given person for marking it as Awarding and Payment
    CURSOR cur_isir_matched (
                             cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE
                            ) IS
    SELECT *
      FROM igf_ap_isir_matched m
     WHERE m.base_id = cp_base_id;

    lv_dummy VARCHAR2(1);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.make_awarding_isir.debug','starting make_awarding_isir with p_base_id : ' || p_base_id ||' p_isir_id : '|| p_isir_id);
    END IF;

    -- validate the input parameters
    IF (p_base_id IS NULL OR p_isir_id IS NULL) THEN
      RETURN 'N';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.make_awarding_isir.debug','Looping the cursor cur_isir_matched');
    END IF;

    -- if no errors, then make the current ISIR as both Awarding and Payment
    -- then set status to N  for the existing payment ISIR and Awarding ISIRs.
    FOR cur_isir_matched_rec IN cur_isir_matched(p_base_id) LOOP

       IF cur_isir_matched_rec.isir_id = p_isir_id THEN
         cur_isir_matched_rec.payment_isir := 'Y';
         cur_isir_matched_rec.active_isir := 'Y';
       ELSE
         cur_isir_matched_rec.payment_isir := 'N';
         cur_isir_matched_rec.active_isir := 'N';
       END IF;

       -- Call the Update_row of using rowtype present in the TBH
       igf_ap_isir_matched_pkg.update_row_rectype(cur_isir_matched_rec);

    END LOOP;

    RETURN 'Y';


  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.make_awarding_isir.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.make_awarding_isir');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      RETURN 'N';
  END make_awarding_isir;


  FUNCTION get_isir_message_class (
                                   p_message_class   IN      igf_ap_isir_matched_all.message_class_txt%TYPE
                                  ) RETURN VARCHAR2 IS
    /*
    ||  Created By  : brajendr
    ||  Created On  : 04-AUG-2004
    ||  Purpose     : Returns ISIR Type meaning for the given Message Class
    ||                If the message class is NULL, then it will return NULL else return the ISIR Type description.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */

    -- Get
    CURSOR get_message_class(
                             cp_message_class   igf_ap_isir_matched_all.message_class_txt%TYPE
                            ) IS
    SELECT tlkp.meaning isir_type_desc, tlkp.lookup_code isir_type
    FROM igf_lookups_view mlkp, igf_lookups_view tlkp
    WHERE mlkp.enabled_flag = 'Y'
      AND tlkp.enabled_flag = 'Y'
      AND mlkp.lookup_type = 'IGF_AP_ISIR_MESSAGE_CLASS'
      AND tlkp.lookup_type = 'IGF_AP_ISIR_TYPE'
      AND mlkp.tag = tlkp.lookup_code
      AND mlkp.lookup_code = cp_message_class;

    get_message_class_rec   get_message_class%ROWTYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.get_isir_message_class.debug','starting get_isir_message_class with p_message_class : ' || p_message_class);
    END IF;

    -- if the message class is NULL then return NULL
    -- else get the ISIR type using the tag provided at the lookup code.
    IF p_message_class IS NULL THEN
      RETURN NULL;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.get_isir_message_class.debug','Before opening the cursor get_message_class');
    END IF;

    get_message_class_rec := NULL;
    OPEN get_message_class(p_message_class);
    FETCH get_message_class INTO get_message_class_rec;
    CLOSE get_message_class;

    RETURN get_message_class_rec.isir_type_desc;

  END get_isir_message_class;


 PROCEDURE upd_ant_data_awd_prc_status(
                                        p_old_active_isir_id  IN         igf_ap_isir_matched_all.isir_id%TYPE,
                                        p_new_active_isir_id  IN         igf_ap_isir_matched_all.isir_id%TYPE,
                                        p_upd_ant_val         IN         VARCHAR2,
                                        p_anticip_status      OUT NOCOPY VARCHAR2,
                                        p_awd_prc_status      OUT NOCOPY VARCHAR2
                                      ) AS
  ------------------------------------------------------------------
  --Created by  : brajendr, Oracle India
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    -- Get the ISIR details of the student.
    CURSOR cur_isir_data( cp_isir_id   igf_ap_isir_matched_all.isir_id%TYPE ) IS
    SELECT isir_id, base_id, batch_year, summ_enrl_status, grade_level_in_college, first_house_plan, second_house_plan, third_house_plan,
           fourth_house_plan, fifth_house_plan, sixth_house_plan, fedral_schl_code_indicator, primary_efc, primary_alternate_month_1,
           primary_alternate_month_2, primary_alternate_month_3, primary_alternate_month_4, primary_alternate_month_5, primary_alternate_month_6,
           primary_alternate_month_7, primary_alternate_month_8, primary_alternate_month_10, primary_alternate_month_11, primary_alternate_month_12
      FROM igf_ap_isir_matched_all
     WHERE isir_id = cp_isir_id;

    new_active_isir   cur_isir_data%ROWTYPE;
    old_active_isir   cur_isir_data%ROWTYPE;

    -- Get the anticipated data for the student.
    CURSOR c_ant_data(
                      cp_base_id                 igf_ap_fa_ant_data.base_id%TYPE
                     ) IS
    SELECT rowid row_id, a.*
      FROM igf_ap_fa_ant_data a
     WHERE base_id = cp_base_id;

    lc_ant_data  c_ant_data%ROWTYPE;

    -- Derive the attendance type fromt he setup with the ISIR data.
    CURSOR c_attendance_type(
                             cp_batch_year        igf_ap_isir_matched_all.batch_year%TYPE,
                             cp_summ_enrl_status  igf_ap_isir_matched_all.summ_enrl_status%TYPE
                            ) IS
    SELECT atm.attendance_type, atm.ap_att_code
      FROM igf_ap_attend_map_v atm, igf_ap_batch_aw_map_all bam
     WHERE atm.cal_type = bam.ci_cal_type
       AND atm.sequence_number = bam.ci_sequence_number
       AND bam.batch_year = cp_batch_year
       AND atm.ap_att_code = cp_summ_enrl_status;

    lc_attendance_type  c_attendance_type%ROWTYPE;

    -- Derive the class standing from the ISIR Grade level.
    CURSOR c_class_standing( cp_grade_level_in_college  igf_ap_isir_matched_all.grade_level_in_college%TYPE ) IS
    SELECT class_standing, ap_std_code
      FROM igf_ap_class_std_map_v
     WHERE ap_std_code = cp_grade_level_in_college;

    lc_class_standing   c_class_standing%ROWTYPE;

    -- Derive the Attendace mode based on the housing code
    CURSOR c_attendance_mode(
                             cp_batch_year                  igf_ap_isir_matched_all.batch_year%TYPE,
                             cp_first_house_plan            igf_ap_isir_matched_all.first_house_plan%TYPE,
                             cp_second_house_plan           igf_ap_isir_matched_all.second_house_plan%TYPE,
                             cp_third_house_plan            igf_ap_isir_matched_all.third_house_plan%TYPE,
                             cp_fourth_house_plan           igf_ap_isir_matched_all.fourth_house_plan%TYPE,
                             cp_fifth_house_plan            igf_ap_isir_matched_all.fifth_house_plan%TYPE,
                             cp_sixth_house_plan            igf_ap_isir_matched_all.sixth_house_plan%TYPE,
                             cp_fedral_schl_code_indicator  igf_ap_isir_matched_all.fedral_schl_code_indicator%TYPE
                            ) IS
    SELECT housing_stat_code, ap_house_plan_code
      FROM igf_ap_housing_map hm, igf_ap_batch_aw_map_all bam
     WHERE hm.ci_cal_type = bam.ci_cal_type
       AND hm.ci_sequence_number = bam.ci_sequence_number
       AND bam.batch_year = cp_batch_year
       AND hm.AP_HOUSE_PLAN_CODE = DECODE(cp_fedral_schl_code_indicator, 1, cp_first_house_plan,
                                                                      2, cp_second_house_plan,
                                                                      3, cp_third_house_plan,
                                                                      4, cp_fourth_house_plan,
                                                                      5, cp_fifth_house_plan,
                                                                      6, cp_sixth_house_plan,
                                                                      '**');

    lc_attendance_mode  c_attendance_mode%ROWTYPE;

  BEGIN

    IF p_new_active_isir_id  IS NULL THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','One of the input parameter is null');
      END IF;

      p_anticip_status := 'ERROR';
      p_awd_prc_status := 'ERROR';
      RETURN;
    END IF;

    -- Get New Active ISIR details
    new_active_isir := NULL;
    OPEN cur_isir_data(p_new_active_isir_id);
    FETCH cur_isir_data INTO new_active_isir;
    CLOSE cur_isir_data;

    IF p_upd_ant_val = 'Y' THEN

      -- Update the Anticipated data
      lc_ant_data := NULL;
      OPEN c_ant_data(new_active_isir.base_id);
      FETCH c_ant_data INTO lc_ant_data;

      -- If there is a difference in the anticipated data then
      IF c_ant_data%FOUND THEN
        CLOSE c_ant_data;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','Anticipated data was found, hence updating');
        END IF;

        -- Derive the Attendance Type value and compare the the anticipated value.
        lc_attendance_type := NULL;
        OPEN c_attendance_type(new_active_isir.batch_year, new_active_isir.summ_enrl_status);
        FETCH c_attendance_type INTO lc_attendance_type;
        IF c_attendance_type%NOTFOUND THEN
          fnd_message.set_name('IGF','IGF_AW_ATTEND_TYPE_NOT_DEF');
          fnd_message.set_token('STATUS',new_active_isir.summ_enrl_status);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;
        CLOSE c_attendance_type;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','Derived the attendance Type : '||lc_attendance_type.attendance_type);
        END IF;

        -- Get the Class standing using the ISIR grde level
        lc_class_standing := NULL;
        OPEN c_class_standing(new_active_isir.grade_level_in_college);
        FETCH c_class_standing INTO lc_class_standing;
        IF c_class_standing%NOTFOUND THEN
          fnd_message.set_name('IGF','IGF_AW_CLASS_STANDING_NOT_DEF');
          fnd_message.set_token('GD_LEVEL',new_active_isir.grade_level_in_college);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;
        CLOSE c_class_standing;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','Derived the Class standing : '||lc_class_standing.class_standing);
        END IF;

        -- Get the Attendance Mode based on the housing plan codes and federal school code.
        lc_attendance_mode := NULL;
        OPEN c_attendance_mode(
                               new_active_isir.batch_year,
                               new_active_isir.first_house_plan,
                               new_active_isir.second_house_plan,
                               new_active_isir.third_house_plan,
                               new_active_isir.fourth_house_plan,
                               new_active_isir.fifth_house_plan,
                               new_active_isir.sixth_house_plan,
                               new_active_isir.fedral_schl_code_indicator
                              );
        FETCH c_attendance_mode INTO lc_attendance_mode;
        IF c_attendance_mode%FOUND THEN
        lc_ant_data.housing_status_code := lc_attendance_mode.housing_stat_code;
        ELSE
          fnd_message.set_name('IGF','IGF_AW_ATTEND_MODE_NOT_DEF');
          fnd_message.set_token('H_PLAN',new_active_isir.fedral_schl_code_indicator);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;
        CLOSE c_attendance_mode;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','Derived the housing status : '||lc_attendance_mode.housing_stat_code);
        END IF;

        IF lc_class_standing.class_standing IS NOT NULL     OR
           lc_attendance_type.attendance_type IS NOT NULL   OR
           lc_attendance_mode.housing_stat_code IS NOT NULL THEN

          -- Update the anticipated data with the derived values for all anticipated records of a student.
          FOR lfc_ant_data IN c_ant_data(new_active_isir.base_id) LOOP

            IF lc_class_standing.class_standing IS NOT NULL THEN
             lfc_ant_data.class_standing  := lc_class_standing.class_standing;
            END IF;

            IF lc_attendance_type.attendance_type IS NOT NULL THEN
              lfc_ant_data.attendance_type := lc_attendance_type.attendance_type;
            END IF;

            IF lc_attendance_mode.housing_stat_code IS NOT NULL THEN
              lfc_ant_data.housing_status_code := lc_attendance_mode.housing_stat_code;
            END IF;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','Updating Anticipated data for base_id : '|| lfc_ant_data.base_id);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug',' ld_cal_type : '|| lfc_ant_data.ld_cal_type ||' Ld_seq_num : '||lfc_ant_data.ld_sequence_number);
            END IF;

            igf_ap_fa_ant_data_pkg.update_row(
                   x_rowid                   => lfc_ant_data.row_id,
                   x_base_id                 => lfc_ant_data.base_id,
                   x_ld_cal_type             => lfc_ant_data.ld_cal_type,
                   x_ld_sequence_number      => lfc_ant_data.ld_sequence_number,
                   x_org_unit_cd             => lfc_ant_data.org_unit_cd,
                   x_program_type            => lfc_ant_data.program_type,
                   x_program_location_cd     => lfc_ant_data.program_location_cd,
                   x_program_cd              => lfc_ant_data.program_cd,
                   x_class_standing          => lfc_ant_data.class_standing,
                   x_residency_status_code   => lfc_ant_data.residency_status_code,
                   x_housing_status_code     => lfc_ant_data.housing_status_code,
                   x_attendance_type         => lfc_ant_data.attendance_type,
                   x_attendance_mode         => lfc_ant_data.attendance_mode,
                   x_months_enrolled_num     => lfc_ant_data.months_enrolled_num,
                   x_credit_points_num       => lfc_ant_data.credit_points_num,
                   x_mode                    => 'R'
                   );
          END LOOP;

          p_anticip_status := 'SUCCESS';
          fnd_message.set_name('IGF','IGF_AW_ANTICIP_DATA_UPDATED');
          fnd_file.put_line(fnd_file.log,fnd_message.get);

        END IF;

      ELSE
        p_anticip_status := 'NO_DATA';
        CLOSE c_ant_data;
      END IF;

    END IF; -- p_upd_ant_val

    -- Check for the EFC values for everymonth and if not same then update the award process status of the awards
    IF p_old_active_isir_id IS NOT NULL THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','Old Active ISIR is present : '||p_old_active_isir_id);
      END IF;

      old_active_isir := NULL;
      OPEN cur_isir_data(p_old_active_isir_id);
      FETCH cur_isir_data INTO old_active_isir;
      CLOSE cur_isir_data;

      IF ( NVL(old_active_isir.primary_efc,-1)                <> NVL(new_active_isir.primary_efc,-1)                OR
           NVL(old_active_isir.primary_alternate_month_1,-1)  <> NVL(new_active_isir.primary_alternate_month_1,-1)  OR
           NVL(old_active_isir.primary_alternate_month_2,-1)  <> NVL(new_active_isir.primary_alternate_month_2,-1)  OR
           NVL(old_active_isir.primary_alternate_month_3,-1)  <> NVL(new_active_isir.primary_alternate_month_3,-1)  OR
           NVL(old_active_isir.primary_alternate_month_4,-1)  <> NVL(new_active_isir.primary_alternate_month_4,-1)  OR
           NVL(old_active_isir.primary_alternate_month_5,-1)  <> NVL(new_active_isir.primary_alternate_month_5,-1)  OR
           NVL(old_active_isir.primary_alternate_month_6,-1)  <> NVL(new_active_isir.primary_alternate_month_6,-1)  OR
           NVL(old_active_isir.primary_alternate_month_7,-1)  <> NVL(new_active_isir.primary_alternate_month_7,-1)  OR
           NVL(old_active_isir.primary_alternate_month_8,-1)  <> NVL(new_active_isir.primary_alternate_month_8,-1)  OR
           NVL(old_active_isir.primary_alternate_month_10,-1) <> NVL(new_active_isir.primary_alternate_month_10,-1) OR
           NVL(old_active_isir.primary_alternate_month_11,-1) <> NVL(new_active_isir.primary_alternate_month_11,-1) OR
           NVL(old_active_isir.primary_alternate_month_12,-1) <> NVL(new_active_isir.primary_alternate_month_12,-1)
      ) THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','EFC values were different, hence upadate the Awd process status');
        END IF;

        p_awd_prc_status := NULL;
        p_awd_prc_status := igf_aw_coa_gen.set_awd_proc_status( p_base_id => new_active_isir.base_id,
                                                                p_award_prd_code => NULL);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug','after updating Awd process status : '||p_awd_prc_status);
        END IF;

        IF p_awd_prc_status IS NOT NULL THEN
          fnd_message.set_name('IGF','IGF_AW_AWD_PRC_STATUS_CHNGED');
          fnd_message.set_token('STATUS',igf_aw_gen.lookup_desc('IGF_AW_AWD_PROC_STAT',p_awd_prc_status));
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;

      END IF;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.debug',' -- Successfull returning with p_anticip_status : '||p_anticip_status ||' p_awd_prc_status : '||p_awd_prc_status);
    END IF;

    RETURN;

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status.exception','The exception is : ' || SQLERRM );
      END IF;
      p_anticip_status := 'ERROR';
      p_awd_prc_status := 'ERROR';
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_isir_gen_pkg.upd_anticip_data_awd_prc_status'||SQLERRM);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
  END upd_ant_data_awd_prc_status;

END igf_ap_isir_gen_pkg;

/
