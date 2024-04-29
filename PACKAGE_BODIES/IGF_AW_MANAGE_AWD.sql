--------------------------------------------------------
--  DDL for Package Body IGF_AW_MANAGE_AWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_MANAGE_AWD" AS
/* $Header: IGFAW19B.pls 120.6 2006/02/08 23:42:35 ridas noship $ */

------------------------------------------------------------------------------
-- Who        When          What
--------------------------------------------------------------------------------


 PROCEDURE process_award(p_award_id          IN  igf_aw_award.award_id%TYPE,
                         p_base_id           IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_run_mode          IN  VARCHAR2,
                         p_awd_proc_status   IN  VARCHAR2
                         ) IS
  ------------------------------------------------------------------
  --Created by  : ridas, Oracle India
  --Date created: 12-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --veramach    31-May-2005     FA 140 Student SS Enhancements
  --                            Added logic to publish/unpublish awards from student self-service
  --
  --ridas       14-Sep-2005     Bug #4103343. Added a new message to print in the log file when the
  --                            Award Process Status gets update
  -------------------------------------------------------------------

   --
   -- This cursor is opened for udpating awards based on run mode
   --
   CURSOR c_awd_mode(c_award_id    igf_aw_award.award_id%TYPE,
                     c_base_id     igf_ap_fa_base_rec_all.base_id%TYPE,
                     c_run_mode    VARCHAR2
                     ) IS
   SELECT
   awd.ROWID row_id,awd.*,fmast.fund_code
   FROM
   igf_aw_award_all     awd,
   igf_aw_fund_mast_all fmast
   WHERE
   awd.award_id   = c_award_id    AND
   awd.base_id    = c_base_id     AND
   fmast.fund_id  = awd.fund_id   AND
   DECODE(c_run_mode,
          'L',NVL(awd.lock_award_flag,'N'),
          'U',NVL(awd.lock_award_flag,'N'),
         'PB',NVL(awd.publish_in_ss_flag,'N'),
         'UP',NVL(awd.publish_in_ss_flag,'N')
         ) <> DECODE(c_run_mode,
                       'L','Y',
                       'U','N',
                      'PB','Y',
                      'UP','N'
               )
   FOR UPDATE OF awd.lock_award_flag,awd.awd_proc_status_code,awd.publish_in_ss_flag NOWAIT;


   --
   -- This cursor is opened for udpating awards
   --
   CURSOR c_awd(c_award_id igf_aw_award.award_id%TYPE,c_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
   SELECT
   awd.ROWID row_id,awd.*,fmast.fund_code
   FROM
   igf_aw_award_all     awd,
   igf_aw_fund_mast_all fmast
   WHERE
   awd.award_id   = c_award_id    AND
   awd.base_id    = c_base_id     AND
   fmast.fund_id  = awd.fund_id
   FOR UPDATE OF awd.lock_award_flag,
                 awd.awd_proc_status_code,
                 awd.publish_in_ss_flag NOWAIT;

   lc_awd                   c_awd%ROWTYPE;

   lv_lock_award_flag       igf_aw_award_all.lock_award_flag%TYPE;
   lv_publish_in_ss_flag    igf_aw_award_all.publish_in_ss_flag%TYPE;
   lv_awd_proc_status_code  igf_aw_award_all.awd_proc_status_code%TYPE;

  BEGIN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.process_award.debug','Starting process_award with award_id:'||p_award_id);
        END IF;

        --open cursor based on run mode
        IF p_run_mode IN ('L','U','PB','UP') THEN
            OPEN  c_awd_mode(p_award_id,p_base_id,p_run_mode);
            FETCH c_awd_mode INTO lc_awd;

            IF c_awd_mode%NOTFOUND THEN
                CLOSE c_awd_mode;
                RETURN;
            END IF;
            CLOSE c_awd_mode;
        ELSE
            OPEN  c_awd(p_award_id,p_base_id);
            FETCH c_awd INTO lc_awd;

            IF c_awd%NOTFOUND THEN
                CLOSE c_awd;
                RETURN;
            END IF;
            CLOSE c_awd;
        END IF;


        IF p_run_mode = 'L' THEN
            lv_lock_award_flag      := 'Y';
            lv_publish_in_ss_flag   := lc_awd.publish_in_ss_flag;
            lv_awd_proc_status_code := lc_awd.awd_proc_status_code;

            fnd_message.set_name('IGF','IGF_AW_LOCK_STUD');
            fnd_message.set_token('FUND',lc_awd.fund_code);
            fnd_message.set_token('AWARD',p_award_id);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        ELSIF p_run_mode = 'U' THEN
            lv_lock_award_flag      := 'N';
            lv_publish_in_ss_flag   := lc_awd.publish_in_ss_flag;
            lv_awd_proc_status_code := lc_awd.awd_proc_status_code;

            fnd_message.set_name('IGF','IGF_AW_UNLOCK_STUD');
            fnd_message.set_token('FUND',lc_awd.fund_code);
            fnd_message.set_token('AWARD',p_award_id);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        ELSIF p_run_mode = 'PB' THEN
            lv_lock_award_flag      := lc_awd.lock_award_flag;
            lv_publish_in_ss_flag   := 'Y';
            lv_awd_proc_status_code := lc_awd.awd_proc_status_code;

            fnd_message.set_name('IGF','IGF_AW_AWD_PUBLISH');
            fnd_message.set_token('FUNDCODE',lc_awd.fund_code);
            fnd_message.set_token('AWDID',p_award_id);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        ELSIF p_run_mode = 'UP' THEN
            lv_lock_award_flag      := lc_awd.lock_award_flag;
            lv_publish_in_ss_flag   := 'N';
            lv_awd_proc_status_code := lc_awd.awd_proc_status_code;

            fnd_message.set_name('IGF','IGF_AW_AWD_UNPUBLISH');
            fnd_message.set_token('FUNDCODE',lc_awd.fund_code);
            fnd_message.set_token('AWDID',p_award_id);
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        ELSIF p_run_mode = 'S' THEN
            lv_lock_award_flag      := lc_awd.lock_award_flag;
            lv_publish_in_ss_flag   := lc_awd.publish_in_ss_flag;
            lv_awd_proc_status_code := p_awd_proc_status;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.process_award.debug','Updating igf_aw_award_all with lock='||lv_lock_award_flag||' and process_status='||lv_awd_proc_status_code);
        END IF;

        igf_aw_award_pkg.update_row (
            x_mode                              => 'R',
            x_rowid                             => lc_awd.ROW_ID,
            x_award_id                          => lc_awd.AWARD_ID,
            x_fund_id                           => lc_awd.FUND_ID,
            x_base_id                           => lc_awd.BASE_ID,
            x_offered_amt                       => lc_awd.OFFERED_AMT,
            x_accepted_amt                      => lc_awd.ACCEPTED_AMT,
            x_paid_amt                          => lc_awd.PAID_AMT,
            x_packaging_type                    => lc_awd.PACKAGING_TYPE,
            x_batch_id                          => lc_awd.BATCH_ID,
            x_manual_update                     => lc_awd.MANUAL_UPDATE,
            x_rules_override                    => lc_awd.RULES_OVERRIDE,
            x_award_date                        => lc_awd.AWARD_DATE,
            x_award_status                      => lc_awd.AWARD_STATUS,
            x_attribute_category                => lc_awd.ATTRIBUTE_CATEGORY,
            x_attribute1                        => lc_awd.ATTRIBUTE1,
            x_attribute2                        => lc_awd.ATTRIBUTE2,
            x_attribute3                        => lc_awd.ATTRIBUTE3,
            x_attribute4                        => lc_awd.ATTRIBUTE4,
            x_attribute5                        => lc_awd.ATTRIBUTE5,
            x_attribute6                        => lc_awd.ATTRIBUTE6,
            x_attribute7                        => lc_awd.ATTRIBUTE7,
            x_attribute8                        => lc_awd.ATTRIBUTE8,
            x_attribute9                        => lc_awd.ATTRIBUTE9,
            x_attribute10                       => lc_awd.ATTRIBUTE10,
            x_attribute11                       => lc_awd.ATTRIBUTE11,
            x_attribute12                       => lc_awd.ATTRIBUTE12,
            x_attribute13                       => lc_awd.ATTRIBUTE13,
            x_attribute14                       => lc_awd.ATTRIBUTE14,
            x_attribute15                       => lc_awd.ATTRIBUTE15,
            x_attribute16                       => lc_awd.ATTRIBUTE16,
            x_attribute17                       => lc_awd.ATTRIBUTE17,
            x_attribute18                       => lc_awd.ATTRIBUTE18,
            x_attribute19                       => lc_awd.ATTRIBUTE19,
            x_attribute20                       => lc_awd.ATTRIBUTE20,
            x_rvsn_id                           => lc_awd.RVSN_ID ,
            x_alt_pell_schedule                 => lc_awd.ALT_PELL_SCHEDULE,
            x_award_number_txt                  => lc_awd.AWARD_NUMBER_TXT,
            x_legacy_record_flag                => lc_awd.legacy_record_flag,
            x_adplans_id                        => lc_awd.adplans_id,
            x_lock_award_flag                   => lv_lock_award_flag,
            x_app_trans_num_txt                 => lc_awd.app_trans_num_txt,
            x_awd_proc_status_code              => lv_awd_proc_status_code,
            x_notification_status_code          => lc_awd.notification_status_code,
            x_notification_status_date          => lc_awd.notification_status_date,
            x_publish_in_ss_flag                => lv_publish_in_ss_flag
          );

    IF p_run_mode = 'S' THEN
      fnd_message.set_name('IGF','IGF_AW_AWD_PROC');
      fnd_message.set_token('PROC_STATUS',p_awd_proc_status);
      fnd_message.set_token('AWARD',p_award_id);
      fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.process_award.debug','End of Update');
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.process_award.debug','process_award is done');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_MANAGE_AWD.PROCESS_AWARD :' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_manage_awd.process_award.exception','sql error:'||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;

  END process_award;


 --Procedure to Lock/Unlock Award at the Student Level
 PROCEDURE lock_unlock_stud(p_base_id           IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_run_mode          IN  VARCHAR2
                            ) IS
  ------------------------------------------------------------------
  --Created by  : ridas, Oracle India
  --Date created: 12-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------


   --This cursor is to fetch person details
   CURSOR  cur_upd_base (c_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                         c_run_mode   VARCHAR2) IS
   SELECT  fab.*
   FROM    igf_ap_fa_base_rec fab
   WHERE   fab.base_id = c_base_id
     AND   NVL(lock_awd_flag,'N') <> DECODE(c_run_mode,'L','Y','N')
   FOR UPDATE OF lock_coa_flag NOWAIT;

   cur_fbr_rec              cur_upd_base%ROWTYPE;

   lv_lock_award_flag       igf_aw_award_all.lock_award_flag%TYPE;

  BEGIN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.lock_unlock_stud.debug','Starting lock_unlock_stud with base_id:'||p_base_id);
        END IF;

        OPEN  cur_upd_base(p_base_id,p_run_mode);
        FETCH cur_upd_base INTO cur_fbr_rec;

        IF cur_upd_base%NOTFOUND THEN
            CLOSE cur_upd_base;
            RETURN;
        END IF;
        CLOSE cur_upd_base;

        IF p_run_mode = 'L' THEN
            lv_lock_award_flag      := 'Y';
            fnd_message.set_name('IGF','IGF_AW_LOCK_STUD_LVL');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

        ELSIF p_run_mode = 'U' THEN
            lv_lock_award_flag      := 'N';
            fnd_message.set_name('IGF','IGF_AW_UNLOCK_STUD_LVL');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.lock_unlock_stud.debug','Updating igf_ap_fa_base_rec_all with lock='||lv_lock_award_flag);
        END IF;

        igf_ap_fa_base_rec_pkg.update_row
                                        (x_Mode                              => 'R',
                                         x_rowid                             => cur_fbr_rec.row_id,
                                         x_base_id                           => cur_fbr_rec.base_id,
                                         x_ci_cal_type                       => cur_fbr_rec.ci_cal_type,
                                         x_person_id                         => cur_fbr_rec.person_id,
                                         x_ci_sequence_number                => cur_fbr_rec.ci_sequence_number,
                                         x_org_id                            => cur_fbr_rec.org_id,
                                         x_coa_pending                       => cur_fbr_rec.coa_pending,
                                         x_verification_process_run          => cur_fbr_rec.verification_process_run,
                                         x_inst_verif_status_date            => cur_fbr_rec.inst_verif_status_date,
                                         x_manual_verif_flag                 => cur_fbr_rec.manual_verif_flag,
                                         x_fed_verif_status                  => cur_fbr_rec.fed_verif_status,
                                         x_fed_verif_status_date             => cur_fbr_rec.fed_verif_status_date,
                                         x_inst_verif_status                 => cur_fbr_rec.inst_verif_status,
                                         x_nslds_eligible                    => cur_fbr_rec.nslds_eligible,
                                         x_ede_correction_batch_id           => cur_fbr_rec.ede_correction_batch_id,
                                         x_fa_process_status_date            => cur_fbr_rec.fa_process_status_date,
                                         x_ISIR_corr_status                  => cur_fbr_rec.ISIR_corr_status,
                                         x_ISIR_corr_status_date             => cur_fbr_rec.ISIR_corr_status_date,
                                         x_ISIR_status                       => cur_fbr_rec.ISIR_status,
                                         x_ISIR_status_date                  => cur_fbr_rec.ISIR_status_date,
                                         x_coa_code_f                        => cur_fbr_rec.coa_code_f,
                                         x_coa_code_i                        => cur_fbr_rec.coa_code_i,
                                         x_coa_f                             => cur_fbr_rec.coa_f,
                                         x_coa_i                             => cur_fbr_rec.coa_i,
                                         x_disbursement_hold                 => cur_fbr_rec.disbursement_hold,
                                         x_fa_process_status                 => cur_fbr_rec.fa_process_status,
                                         x_notification_status               => cur_fbr_rec.notification_status,
                                         x_notification_status_date          => cur_fbr_rec.notification_status_date,
                                         x_packaging_status                  => cur_fbr_rec.packaging_status,
                                         x_packaging_status_date             => cur_fbr_rec.packaging_status_date,
                                         x_total_package_accepted            => cur_fbr_rec.total_package_accepted,
                                         x_total_package_offered             => cur_fbr_rec.total_package_offered,
                                         x_admstruct_id                      => cur_fbr_rec.admstruct_id,
                                         x_admsegment_1                      => cur_fbr_rec.admsegment_1,
                                         x_admsegment_2                      => cur_fbr_rec.admsegment_2,
                                         x_admsegment_3                      => cur_fbr_rec.admsegment_3,
                                         x_admsegment_4                      => cur_fbr_rec.admsegment_4,
                                         x_admsegment_5                      => cur_fbr_rec.admsegment_5,
                                         x_admsegment_6                      => cur_fbr_rec.admsegment_6,
                                         x_admsegment_7                      => cur_fbr_rec.admsegment_7,
                                         x_admsegment_8                      => cur_fbr_rec.admsegment_8,
                                         x_admsegment_9                      => cur_fbr_rec.admsegment_9,
                                         x_admsegment_10                     => cur_fbr_rec.admsegment_10,
                                         x_admsegment_11                     => cur_fbr_rec.admsegment_11,
                                         x_admsegment_12                     => cur_fbr_rec.admsegment_12,
                                         x_admsegment_13                     => cur_fbr_rec.admsegment_13,
                                         x_admsegment_14                     => cur_fbr_rec.admsegment_14,
                                         x_admsegment_15                     => cur_fbr_rec.admsegment_15,
                                         x_admsegment_16                     => cur_fbr_rec.admsegment_16,
                                         x_admsegment_17                     => cur_fbr_rec.admsegment_17,
                                         x_admsegment_18                     => cur_fbr_rec.admsegment_18,
                                         x_admsegment_19                     => cur_fbr_rec.admsegment_19,
                                         x_admsegment_20                     => cur_fbr_rec.admsegment_20,
                                         x_packstruct_id                     => cur_fbr_rec.packstruct_id,
                                         x_packsegment_1                     => cur_fbr_rec.packsegment_1,
                                         x_packsegment_2                     => cur_fbr_rec.packsegment_2,
                                         x_packsegment_3                     => cur_fbr_rec.packsegment_3,
                                         x_packsegment_4                     => cur_fbr_rec.packsegment_4,
                                         x_packsegment_5                     => cur_fbr_rec.packsegment_5,
                                         x_packsegment_6                     => cur_fbr_rec.packsegment_6,
                                         x_packsegment_7                     => cur_fbr_rec.packsegment_7,
                                         x_packsegment_8                     => cur_fbr_rec.packsegment_8,
                                         x_packsegment_9                     => cur_fbr_rec.packsegment_9,
                                         x_packsegment_10                    => cur_fbr_rec.packsegment_10,
                                         x_packsegment_11                    => cur_fbr_rec.packsegment_11,
                                         x_packsegment_12                    => cur_fbr_rec.packsegment_12,
                                         x_packsegment_13                    => cur_fbr_rec.packsegment_13,
                                         x_packsegment_14                    => cur_fbr_rec.packsegment_14,
                                         x_packsegment_15                    => cur_fbr_rec.packsegment_15,
                                         x_packsegment_16                    => cur_fbr_rec.packsegment_16,
                                         x_packsegment_17                    => cur_fbr_rec.packsegment_17,
                                         x_packsegment_18                    => cur_fbr_rec.packsegment_18,
                                         x_packsegment_19                    => cur_fbr_rec.packsegment_19,
                                         x_packsegment_20                    => cur_fbr_rec.packsegment_20,
                                         x_miscstruct_id                     => cur_fbr_rec.miscstruct_id,
                                         x_miscsegment_1                     => cur_fbr_rec.miscsegment_1,
                                         x_miscsegment_2                     => cur_fbr_rec.miscsegment_2,
                                         x_miscsegment_3                     => cur_fbr_rec.miscsegment_3,
                                         x_miscsegment_4                     => cur_fbr_rec.miscsegment_4,
                                         x_miscsegment_5                     => cur_fbr_rec.miscsegment_5,
                                         x_miscsegment_6                     => cur_fbr_rec.miscsegment_6,
                                         x_miscsegment_7                     => cur_fbr_rec.miscsegment_7,
                                         x_miscsegment_8                     => cur_fbr_rec.miscsegment_8,
                                         x_miscsegment_9                     => cur_fbr_rec.miscsegment_9,
                                         x_miscsegment_10                    => cur_fbr_rec.miscsegment_10,
                                         x_miscsegment_11                    => cur_fbr_rec.miscsegment_11,
                                         x_miscsegment_12                    => cur_fbr_rec.miscsegment_12,
                                         x_miscsegment_13                    => cur_fbr_rec.miscsegment_13,
                                         x_miscsegment_14                    => cur_fbr_rec.miscsegment_14,
                                         x_miscsegment_15                    => cur_fbr_rec.miscsegment_15,
                                         x_miscsegment_16                    => cur_fbr_rec.miscsegment_16,
                                         x_miscsegment_17                    => cur_fbr_rec.miscsegment_17,
                                         x_miscsegment_18                    => cur_fbr_rec.miscsegment_18,
                                         x_miscsegment_19                    => cur_fbr_rec.miscsegment_19,
                                         x_miscsegment_20                    => cur_fbr_rec.miscsegment_20,
                                         x_prof_judgement_flg                => cur_fbr_rec.prof_judgement_flg,
                                         x_nslds_data_override_flg           => cur_fbr_rec.nslds_data_override_flg,
                                         x_target_group                      => cur_fbr_rec.target_group,
                                         x_coa_fixed                         => cur_fbr_rec.coa_fixed,
                                         x_profile_status                    => cur_fbr_rec.profile_status,
                                         x_profile_status_date               => cur_fbr_rec.profile_status_date,
                                         x_profile_fc                        => cur_fbr_rec.profile_fc,
                                         x_coa_pell                          => cur_fbr_rec.coa_pell,
                                         x_manual_disb_hold                  => cur_fbr_rec.manual_disb_hold,
                                         x_pell_alt_expense                  => cur_fbr_rec.pell_alt_expense,
                                         x_assoc_org_num                     => cur_fbr_rec.assoc_org_num,
                                         x_award_fmly_contribution_type      => cur_fbr_rec.award_fmly_contribution_type,
                                         x_packaging_hold                    => cur_fbr_rec.packaging_hold,
                                         x_isir_locked_by                    => cur_fbr_rec.isir_locked_by ,
                                         x_adnl_unsub_loan_elig_flag         => cur_fbr_rec.adnl_unsub_loan_elig_flag,
                                         x_lock_awd_flag                     => lv_lock_award_flag,
                                         x_lock_coa_flag                     => cur_fbr_rec.lock_coa_flag
                                         );

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.lock_unlock_stud.debug','End of Update');
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.lock_unlock_stud.debug','lock_unlock_stud is done');
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_MANAGE_AWD.LOCK_UNLOCK_STUD :' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_manage_awd.lock_unlock_stud.exception','sql error:'||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;

  END lock_unlock_stud;



 -- This procedure is the callable from concurrent manager
 PROCEDURE run(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_award_period                IN  igf_aw_award_prd.award_prd_cd%TYPE,
                p_run_type                    IN  VARCHAR2,
                p_pid_group                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                p_run_mode                    IN  VARCHAR2,
                p_awd_proc_status             IN  VARCHAR2,
                p_fund_id                     IN  igf_aw_fund_mast_all.fund_id%TYPE
               ) IS
  --------------------------------------------------------------------------------
  -- this procedure is called from concurrent manager.
  -- if the parameters passed are not correct then procedure exits
  -- giving reasons for errors.
  -- Created by  : ridas, Oracle India
  -- Date created: 12-OCT-2004

  -- Change History:
  -- Who				When            What
  -- ridas      08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in
  --                            call to igf_ap_ss_pkg.get_pid
  -- tsailaja		13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  -- veramach   31-May-2005     FA 140 Student SS Enhancements
  --                            Added logic to log parameters only if they are not null
  --------------------------------------------------------------------------------

    param_exception  EXCEPTION;

    -- Variables for the dynamic person id group
    lv_status        VARCHAR2(1);
    lv_sql_stmt      VARCHAR(32767);
    lv_group_type    igs_pe_persid_group_v.group_type%TYPE;

    TYPE CpregrpCurTyp IS REF CURSOR ;
    cur_per_grp CpregrpCurTyp ;

    TYPE CpergrpTyp IS RECORD(
                              person_id     igf_ap_fa_base_rec_all.person_id%TYPE,
                              person_number igs_pe_person_base_v.person_number%TYPE
                             );
    per_grp_rec CpergrpTyp ;


    --Cursor below retrieves all the students belonging to a given AWARD YEAR
    CURSOR c_per_awd_yr(
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                       ) IS
      SELECT fa.base_id
        FROM igf_ap_fa_base_rec_all fa
       WHERE fa.ci_cal_type        =  c_ci_cal_type
         AND fa.ci_sequence_number =  c_ci_sequence_number
       ORDER BY fa.base_id;


    --Cursor below retrieves the group code for the given group id
    CURSOR c_group_code(
                        c_grp_id igs_pe_prsid_grp_mem_all.group_id%TYPE
                       ) IS
      SELECT group_cd
        FROM igs_pe_persid_group_all
       WHERE group_id = c_grp_id;

    l_grp_cd    c_group_code%ROWTYPE;


    --Curson below retrieves the fund code for the given fund id
    CURSOR c_fund_code(
                       c_fund_id   igf_aw_fund_mast_all.fund_id%TYPE
                      ) IS
      SELECT fund_code
        FROM igf_aw_fund_mast_all
       WHERE fund_id = c_fund_id;

    l_fund_code    c_fund_code%ROWTYPE;


    --Cursor to filter out those awards that fall within the awarding period
    CURSOR c_awards(
                    c_ci_cal_type          igf_aw_award_prd.ci_cal_type%TYPE,
                    c_ci_sequence_number   igf_aw_award_prd.ci_sequence_number%TYPE,
                    c_award_prd_cd         igf_aw_award_prd.award_prd_cd%TYPE,
                    c_base_id              igf_ap_fa_base_rec_all.base_id%TYPE ,
                    c_fund_id              igf_aw_fund_mast_all.fund_id%TYPE
                   ) IS
    SELECT awd.award_id
    FROM   igf_aw_award_all      awd
    WHERE  awd.base_id  =  c_base_id                    AND
           awd.fund_id  =  NVL(c_fund_id, awd.fund_id)  AND
           NOT EXISTS
               (SELECT disb.ld_cal_type,
                       disb.ld_sequence_number
                FROM   igf_aw_awd_disb_all  disb
                WHERE  disb.award_id  =  awd.award_id
                MINUS
                SELECT ld_cal_type,
                       ld_sequence_number
                FROM   igf_aw_awd_prd_term  apt
                WHERE  apt.ci_cal_type  =   c_ci_cal_type             AND
                       apt.ci_sequence_number = c_ci_sequence_number  AND
                       apt.award_prd_cd       = c_award_prd_cd
               );


    --Cursor to fetch person no based on person id
    CURSOR  c_person_no (c_person_id  hz_parties.party_id%TYPE)
    IS
    SELECT  party_number
    FROM    hz_parties
    WHERE   party_id = c_person_id;

    l_person_no  c_person_no%ROWTYPE;


    --Cursor to retrieve all awards for the award year
    CURSOR c_award_yr(
                      c_base_id              igf_ap_fa_base_rec_all.base_id%TYPE,
                      c_fund_id              igf_aw_fund_mast_all.fund_id%TYPE
                     ) IS
    SELECT awd.award_id
    FROM   igf_aw_award_all      awd
    WHERE  awd.base_id  =  c_base_id                    AND
           awd.fund_id  =  NVL(c_fund_id, awd.fund_id);


    lv_run_type            VARCHAR2(100);
    lv_ci_cal_type         igs_ca_inst_all.cal_type%TYPE;
    ln_ci_sequence_number  igs_ca_inst_all.sequence_number%TYPE;
    ln_base_id             igf_ap_fa_base_rec_all.base_id%TYPE;
    lv_err_msg             fnd_new_messages.message_name%TYPE;


  BEGIN
	igf_aw_gen.set_org_id(NULL);
    retcode               := 0;
    errbuf                := NULL;
    lv_ci_cal_type        := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    ln_ci_sequence_number := TO_NUMBER(SUBSTR(p_award_year,11));
    lv_status             := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_award_year:'||p_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_award_period:'||p_award_period);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_run_type:'||p_run_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_pid_group:'||p_pid_group);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_run_mode:'||p_run_mode);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_awd_proc_status:'||p_awd_proc_status);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','p_fund_id:'||p_fund_id);
    END IF;

    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS'));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'),40) ||': '|| igf_gr_gen.get_alt_code(lv_ci_cal_type,ln_ci_sequence_number));
    IF p_award_period IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_PERIOD'),40)||': '||p_award_period );
    END IF;

    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','RUN_TYPE'),40)||': '||p_run_type );

    IF p_pid_group IS NOT NULL THEN
      OPEN  c_group_code(p_pid_group);
      FETCH c_group_code INTO l_grp_cd;
      CLOSE c_group_code;

      fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'),40) ||': '|| l_grp_cd.group_cd);
    END IF;
    IF p_base_id IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),40) ||': '|| igf_gr_gen.get_per_num(p_base_id));
    END If;
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','RUN_MODE'),40) ||': '||igf_aw_gen.lookup_desc('IGF_AW_LOCK_MODE',p_run_mode));
    IF p_awd_proc_status IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_PROC_STATUS'),40) ||': '|| igf_aw_gen.lookup_desc('IGF_AW_AWD_PROC_STAT',p_awd_proc_status));
    END IF;

    IF p_fund_id IS NOT NULL THEN
      OPEN  c_fund_code(p_fund_id);
      FETCH c_fund_code INTO l_fund_code;
      CLOSE c_fund_code;

      fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','FUND_CODE'),40) ||': '|| l_fund_code.fund_code);
    END IF;


    IF (p_award_year IS NULL) OR (p_run_type IS NULL) OR (p_run_mode IS NULL) THEN
      RAISE param_exception;

    ELSIF lv_ci_cal_type IS NULL OR ln_ci_sequence_number IS NULL THEN
      RAISE param_exception;

    ELSIF (p_pid_group IS NOT NULL) AND (p_base_id IS NOT NULL) THEN
      RAISE param_exception;

    --If person selection is for all persons in the Person ID Group and
    --Person ID Group is NULL then log error with exception
    ELSIF p_run_type = 'P' AND p_pid_group IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_P');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    --If person selection is for a single person and
    --Base ID is NULL then log error with exception
    ELSIF p_run_type = 'S' AND p_base_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_S');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    --If the Run Mode is 'Set Award Process Status' and
    --Fund ID is NOT NULL then log error with exception
    ELSIF p_run_mode = 'S' AND p_fund_id IS NOT NULL THEN
      fnd_message.set_name('IGF','IGF_AW_MANG_AW_FUND_ERR');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;
    END IF;

    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');

    --COMPUTATION ONLY IF PERSON NUMBER IS PRESENT
    IF p_run_type = 'S' AND (p_pid_group IS NULL) AND (p_base_id IS NOT NULL) THEN

       fnd_file.new_line(fnd_file.log,1);
       fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
       fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(p_base_id));
       fnd_file.put_line(fnd_file.log,fnd_message.get);

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','Starting Run_Type=S with base_id:'||p_base_id);
       END IF;

       IF p_award_period IS NOT NULL THEN
          FOR l_awards IN c_awards(lv_ci_cal_type,ln_ci_sequence_number,p_award_period,p_base_id,p_fund_id)
          LOOP
                    process_award(l_awards.award_id,
                                  p_base_id,
                                  p_run_mode,
                                  p_awd_proc_status
                                  );

          END LOOP; -- end of cursor c_awards
       ELSE
          FOR l_award_year IN c_award_yr(p_base_id,p_fund_id)
          LOOP
                    process_award(l_award_year.award_id,
                                  p_base_id,
                                  p_run_mode,
                                  p_awd_proc_status
                                  );
          END LOOP; -- end of cursor c_award_year

          -- update lock/unlock award at the student level
          IF (p_award_period IS NULL AND p_fund_id IS NULL AND p_run_mode IN ('L','U')) THEN
              lock_unlock_stud(p_base_id,p_run_mode);
          END IF;
       END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','Run_Type=S done');
      END IF;

    --COMPUTATION FOR AWARD YEAR ONLY
    ELSIF p_run_type = 'Y' AND (p_pid_group IS NULL) AND (p_base_id IS NULL) THEN
      FOR l_per_awd_rec IN c_per_awd_yr(lv_ci_cal_type,ln_ci_sequence_number)
      LOOP
       fnd_file.new_line(fnd_file.log,1);
       fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
       fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(l_per_awd_rec.base_id));
       fnd_file.put_line(fnd_file.log,fnd_message.get);

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','Starting Run_Type=Y with base_id:'||l_per_awd_rec.base_id);
       END IF;

       IF p_award_period IS NOT NULL THEN
          FOR l_awards IN c_awards(lv_ci_cal_type,ln_ci_sequence_number,p_award_period,l_per_awd_rec.base_id,p_fund_id)
          LOOP
                    process_award(l_awards.award_id,
                                  l_per_awd_rec.base_id,
                                  p_run_mode,
                                  p_awd_proc_status
                                  );

          END LOOP; -- end of cursor c_awards
       ELSE
          FOR l_award_year IN c_award_yr(l_per_awd_rec.base_id,p_fund_id)
          LOOP
                    process_award(l_award_year.award_id,
                                  l_per_awd_rec.base_id,
                                  p_run_mode,
                                  p_awd_proc_status
                                  );
          END LOOP; -- end of cursor c_award_year

          -- update lock/unlock award at the student level
          IF (p_award_period IS NULL AND p_fund_id IS NULL AND p_run_mode IN ('L','U')) THEN
              lock_unlock_stud(l_per_awd_rec.base_id,p_run_mode);
          END IF;
       END IF;
      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','Run_Type=Y done');
      END IF;

    --COMPUTATION FOR ALL PERSONS IN THE PERSON ID GROUP
    ELSIF (p_run_type = 'P' AND p_pid_group IS NOT NULL) THEN
          --Bug #5021084
          lv_sql_stmt   := igf_ap_ss_pkg.get_pid(p_pid_group,lv_status,lv_group_type);

          --Bug #5021084. Passing Group ID if the group type is STATIC.
          IF lv_group_type = 'STATIC' THEN
            OPEN cur_per_grp FOR
            'SELECT person_id,
                    person_number
               FROM igs_pe_person_base_v
              WHERE person_id IN ('||lv_sql_stmt||') ' USING p_pid_group;
          ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN cur_per_grp FOR
            'SELECT person_id,
                    person_number
               FROM igs_pe_person_base_v
              WHERE person_id IN ('||lv_sql_stmt||')';
          END IF;

          FETCH cur_per_grp INTO per_grp_rec;

          IF (cur_per_grp%NOTFOUND) THEN
            fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          ELSE
            LOOP
              -- check if person has a fa base record
              ln_base_id := NULL;
              lv_err_msg := NULL;

              igf_gr_gen.get_base_id(
                                     lv_ci_cal_type,
                                     ln_ci_sequence_number,
                                     per_grp_rec.person_id,
                                     ln_base_id,
                                     lv_err_msg
                                     );

              IF lv_err_msg = 'NULL' THEN
                    fnd_file.new_line(fnd_file.log,1);
                    fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
                    fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(ln_base_id));
                    fnd_file.put_line(fnd_file.log,fnd_message.get);

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','Starting Run_Type=P with base_id:'||ln_base_id);
                    END IF;

                    IF p_award_period IS NOT NULL THEN
                         FOR l_awards IN c_awards(lv_ci_cal_type,ln_ci_sequence_number,p_award_period,ln_base_id,p_fund_id)
                         LOOP
                                process_award(l_awards.award_id,
                                             ln_base_id,
                                             p_run_mode,
                                             p_awd_proc_status
                                             );

                         END LOOP; -- end of cursor c_awards
                    ELSE
                         FOR l_award_year IN c_award_yr(ln_base_id,p_fund_id)
                         LOOP
                                process_award(l_award_year.award_id,
                                             ln_base_id,
                                             p_run_mode,
                                             p_awd_proc_status
                                             );
                         END LOOP; -- end of cursor c_award_year

                         -- update lock/unlock award at the student level
                         IF (p_award_period IS NULL AND p_fund_id IS NULL AND p_run_mode IN ('L','U')) THEN
                            lock_unlock_stud(ln_base_id,p_run_mode);
                         END IF;
                    END IF;

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_manage_awd.run.debug','Run_Type=P done');
                    END IF;

              ELSE
                OPEN  c_person_no(per_grp_rec.person_id);
                FETCH c_person_no INTO l_person_no;
                CLOSE c_person_no;

                fnd_message.set_name('IGF','IGF_AP_NO_BASEREC');
                fnd_message.set_token('STUD',l_person_no.party_number);
                fnd_file.new_line(fnd_file.log,1);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;

              FETCH cur_per_grp INTO per_grp_rec;
              EXIT WHEN cur_per_grp%NOTFOUND;
            END LOOP;
            CLOSE cur_per_grp;

          END IF; -- end of IF (cur_per_grp%NOTFOUND)

    END IF;

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');


    COMMIT;

  EXCEPTION
      WHEN param_exception THEN
        retcode:=2;
        fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN app_exception.record_lock_exception THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN OTHERS THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get || SQLERRM;
  END run;

END igf_aw_manage_awd;

/
