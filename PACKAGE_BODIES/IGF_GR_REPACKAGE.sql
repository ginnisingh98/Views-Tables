--------------------------------------------------------
--  DDL for Package Body IGF_GR_REPACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_REPACKAGE" AS
/* $Header: IGFGR07B.pls 120.3 2006/08/10 15:59:33 museshad noship $ */
----------------------------------------------------------------------
--museshad    10-Aug-2006  Bug 5337555. Build FA 163. TBH Impact.
----------------------------------------------------------------------
--sjadhav     06-Nov-2004  FA 149 build, do not insert into igf_gr_rfms_disb for cod year
----------------------------------------------------------------------
--ayedubat    13-OCT-04    FA 149 COD-XML Standards build bug # 3416863
--                         Changed the TBH calls of the packages: igf_aw_awd_disb_pkg and
--                         igf_gr_rfms_pkg
----------------------------------------------------------------------
-- veramach    July 2004      FA 151 HR integration (bug # 3709292)
--                            Impact of obsoleting columns from igf_aw_awd_disb_pkg
----------------------------------------------------------------------
-- veramach   12-Mar-2004  Bug 3490915
--                         in call to igf_gr_rfms_pkg.update_row, changed the
--                         value of pell_amout to l_offered_amt
--                         Also, ft_pell_amt is calculated and updated in
--                         the RFMS record.
----------------------------------------------------------------------
-- cdcruz     05-Dec-2003  FA 131 Cod Updates
--                         Reviewed the Code
--                         Re-vamped the repackage procedure to reduced multiple checks for each mode
----------------------------------------------------------------------
-- veramach   02-Dec-2003  FA 131 Cod Updates
--                         Adds new procedures log_parameters,cancel_invalid_awards,repackage
--                         Removes insert_award_t,delete_awd_disb
--                         Logic existing in repackage_pell moved to repackage
----------------------------------------------------------------------
--
-- sjadhav    01-Aug-2003  Bug 3062062
--                         Corrected re-package routine for post_award
--                         and disbursement deletions
----------------------------------------------------------------------
--
-- sjadhav,   May.29.2002  Bug 2381898
--                         Added Get Latest Oss Detail Call Before
--                         Calculating Pell Award
----------------------------------------------------------------------
--

PROCEDURE log_parameters(
                         p_cal_type             IN  igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                         p_sequence_number      IN  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                         p_base_id              IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_persid_grp           IN  igs_pe_persid_group_all.group_id%TYPE,
                         p_test_run             IN  VARCHAR2,
                         p_cancel_invalid_award IN  VARCHAR2
                        ) AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 02-DEC-2003
--
--Purpose:
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

l_param_pass_log     igf_lookups_view.meaning%TYPE ;
l_awd_yr_log         igf_lookups_view.meaning%TYPE ;
l_pers_number_log    igf_lookups_view.meaning%TYPE ;
l_pers_id_grp_log    igf_lookups_view.meaning%TYPE ;
l_test_run_log       igf_lookups_view.meaning%TYPE ;
l_cancel_inv_awd_log igf_lookups_view.meaning%TYPE ;

  -- Get person number
  CURSOR c_person_number(
                          cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
      SELECT party_number
        FROM hz_parties parties,
             igf_ap_fa_base_rec_all fabase
       WHERE fabase.person_id = parties.party_id
         AND fabase.base_id   = cp_base_id;

  l_person_number hz_parties.party_number%TYPE;

-- Get alternate code
CURSOR c_alternate_code(
                         cp_cal_type   igs_ca_inst_all.cal_type%TYPE,
                         cp_seq_number igs_ca_inst_all.sequence_number%TYPE
                       ) IS
  SELECT alternate_code
    FROM igs_ca_inst_all
   WHERE cal_type        = cp_cal_type
     AND sequence_number = cp_seq_number;

l_alternate_code igs_ca_inst_all.alternate_code%TYPE;

-- Get get group description for group_id
CURSOR c_person_group(
                      cp_persid_grp igs_pe_persid_group_all.group_id%TYPE
                     ) IS
  SELECT group_cd group_name
    FROM igs_pe_persid_group_all
   WHERE group_id = cp_persid_grp;

l_persid_grp_name c_person_group%ROWTYPE;

BEGIN

  l_param_pass_log     := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');
  l_awd_yr_log         := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YEAR');
  l_pers_number_log    := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_NUMBER');
  l_pers_id_grp_log    := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_ID_GROUP');
  l_test_run_log       := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','TEST_MODE');
  l_cancel_inv_awd_log := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','CANCEL_INVALID_AWD');

  fnd_file.new_line(fnd_file.log,2);
  fnd_file.put_line(fnd_file.log,l_param_pass_log);

  OPEN c_alternate_code(p_cal_type,p_sequence_number);
  FETCH c_alternate_code INTO l_alternate_code;
  CLOSE c_alternate_code;

  fnd_file.put_line(fnd_file.log,RPAD(l_awd_yr_log,40) || ' : ' || l_alternate_code);

  OPEN c_person_number(p_base_id);
  FETCH c_person_number INTO l_person_number;
  CLOSE c_person_number;

  OPEN c_person_group(p_persid_grp);
  FETCH c_person_group INTO l_persid_grp_name;
  CLOSE c_person_group;

  fnd_file.put_line(fnd_file.log,RPAD(l_pers_number_log,40) || ' : ' || l_person_number);
  fnd_file.put_line(fnd_file.log,RPAD(l_pers_id_grp_log,40) || ' : ' || l_persid_grp_name.group_name);
  fnd_file.put_line(fnd_file.log,RPAD(l_test_run_log,40)    || ' : ' || p_test_run);
  fnd_file.put_line(fnd_file.log,RPAD(l_cancel_inv_awd_log,40)    || ' : ' || p_cancel_invalid_award);
  fnd_file.put_line(fnd_file.log,RPAD('-',55,'-'));
  fnd_file.new_line(fnd_file.log,2);

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GE_REPACKAGE.LOG_PARAMETERS '||SQLERRM);
    igs_ge_msg_stack.add;

    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_repackage.log_parameters.exception','sql error message:'||SQLERRM);
    END IF;

    app_exception.raise_exception;
END log_parameters;

PROCEDURE cancel_invalid_award(
                               p_award_id igf_aw_award_all.award_id%TYPE
                              ) AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 01-DEC-2003
--
--Purpose: to cancel an existing award and its disbursements
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

-- Get an award
CURSOR c_award(
               cp_award_id igf_aw_award_all.award_id%TYPE
              ) IS
  SELECT awd.rowid row_id,
         awd.*
    FROM igf_aw_award_all awd
   WHERE award_id = cp_award_id;

-- Get disbursements for an award
CURSOR c_disb(
              cp_award_id igf_aw_award_all.award_id%TYPE
             ) IS
  SELECT disb.rowid row_id,
         disb.*
    FROM igf_aw_awd_disb_all disb
   WHERE award_id = cp_award_id;



BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.cancel_invalid_award.debug','starting cancel_invalid_award with award_id:'||p_award_id);
  END IF;

  FOR awd_rec IN c_award(p_award_id) LOOP

    FOR disb_rec IN c_disb(p_award_id) LOOP

      igf_aw_awd_disb_pkg.update_row(
                                     x_rowid                      =>    disb_rec.row_id,
                                     x_award_id                   =>    disb_rec.award_id,
                                     x_disb_num                   =>    disb_rec.disb_num,
                                     x_tp_cal_type                =>    disb_rec.tp_cal_type,
                                     x_tp_sequence_number         =>    disb_rec.tp_sequence_number,
                                     x_disb_gross_amt             =>    disb_rec.disb_gross_amt,
                                     x_fee_1                      =>    disb_rec.fee_1,
                                     x_fee_2                      =>    disb_rec.fee_2,
                                     x_disb_net_amt               =>    disb_rec.disb_net_amt,
                                     x_disb_date                  =>    disb_rec.disb_date,
                                     x_trans_type                 =>    'C',
                                     x_elig_status                =>    disb_rec.elig_status,
                                     x_elig_status_date           =>    disb_rec.elig_status_date,
                                     x_affirm_flag                =>    disb_rec.affirm_flag,
                                     x_hold_rel_ind               =>    disb_rec.hold_rel_ind,
                                     x_manual_hold_ind            =>    disb_rec.manual_hold_ind,
                                     x_disb_status                =>    disb_rec.disb_status,
                                     x_disb_status_date           =>    disb_rec.disb_status_date,
                                     x_late_disb_ind              =>    disb_rec.late_disb_ind,
                                     x_fund_dist_mthd             =>    disb_rec.fund_dist_mthd,
                                     x_prev_reported_ind          =>    disb_rec.prev_reported_ind,
                                     x_fund_release_date          =>    disb_rec.fund_release_date,
                                     x_fund_status                =>    disb_rec.fund_status,
                                     x_fund_status_date           =>    disb_rec.fund_status_date,
                                     x_fee_paid_1                 =>    disb_rec.fee_paid_1,
                                     x_fee_paid_2                 =>    disb_rec.fee_paid_2,
                                     x_cheque_number              =>    disb_rec.cheque_number,
                                     x_ld_cal_type                =>    disb_rec.ld_cal_type,
                                     x_ld_sequence_number         =>    disb_rec.ld_sequence_number,
                                     x_disb_accepted_amt          =>    0,
                                     x_disb_paid_amt              =>    0,
                                     x_rvsn_id                    =>    disb_rec.rvsn_id,
                                     x_int_rebate_amt             =>    disb_rec.int_rebate_amt,
                                     x_force_disb                 =>    disb_rec.force_disb,
                                     x_min_credit_pts             =>    disb_rec.min_credit_pts,
                                     x_disb_exp_dt                =>    disb_rec.disb_exp_dt,
                                     x_verf_enfr_dt               =>    disb_rec.verf_enfr_dt,
                                     x_fee_class                  =>    disb_rec.fee_class,
                                     x_show_on_bill               =>    disb_rec.show_on_bill,
                                     x_mode                       =>    'R',
                                     x_attendance_type_code       =>    disb_rec.attendance_type_code,
                                     x_base_attendance_type_code  =>    disb_rec.base_attendance_type_code,
                                     x_payment_prd_st_date        =>    disb_rec.payment_prd_st_date,
                                     x_change_type_code           =>    disb_rec.change_type_code,
                                     x_fund_return_mthd_code      =>    disb_rec.fund_return_mthd_code,
                                     x_direct_to_borr_flag        =>    disb_rec.direct_to_borr_flag
                                     );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.cancel_invalid_award.debug','updated disbursement number '||disb_rec.disb_num);
      END IF;

    END LOOP;

    igf_aw_award_pkg.update_row(
                                x_rowid              => awd_rec.row_id,
                                x_award_id           => awd_rec.award_id,
                                x_fund_id            => awd_rec.fund_id,
                                x_base_id            => awd_rec.base_id,
                                x_offered_amt        => awd_rec.offered_amt,
                                x_accepted_amt       => 0,
                                x_paid_amt           => 0,
                                x_packaging_type     => awd_rec.packaging_type,
                                x_batch_id           => awd_rec.batch_id,
                                x_manual_update      => awd_rec.manual_update,
                                x_rules_override     => awd_rec.rules_override,
                                x_award_date         => awd_rec.award_date,
                                x_award_status       => 'CANCELLED',
                                x_attribute_category => awd_rec.attribute_category,
                                x_attribute1         => awd_rec.attribute1,
                                x_attribute2         => awd_rec.attribute2,
                                x_attribute3         => awd_rec.attribute3,
                                x_attribute4         => awd_rec.attribute4,
                                x_attribute5         => awd_rec.attribute5,
                                x_attribute6         => awd_rec.attribute6,
                                x_attribute7         => awd_rec.attribute7,
                                x_attribute8         => awd_rec.attribute8,
                                x_attribute9         => awd_rec.attribute9,
                                x_attribute10        => awd_rec.attribute10,
                                x_attribute11        => awd_rec.attribute11,
                                x_attribute12        => awd_rec.attribute12,
                                x_attribute13        => awd_rec.attribute13,
                                x_attribute14        => awd_rec.attribute14,
                                x_attribute15        => awd_rec.attribute15,
                                x_attribute16        => awd_rec.attribute16,
                                x_attribute17        => awd_rec.attribute17,
                                x_attribute18        => awd_rec.attribute18,
                                x_attribute19        => awd_rec.attribute19,
                                x_attribute20        => awd_rec.attribute20,
                                x_rvsn_id            => awd_rec.rvsn_id,
                                x_alt_pell_schedule  => awd_rec.alt_pell_schedule,
                                x_mode               => 'R',
                                x_award_number_txt   => awd_rec.award_number_txt,
                                x_legacy_record_flag => awd_rec.legacy_record_flag,
                                x_adplans_id         => awd_rec.adplans_id,
                                x_lock_award_flag    => awd_rec.lock_award_flag,
                                x_app_trans_num_txt  => awd_rec.app_trans_num_txt,
                                x_awd_proc_status_code  => awd_rec.awd_proc_status_code,
                                x_notification_status_code	=> awd_rec.notification_status_code,
                                x_notification_status_date	=> awd_rec.notification_status_date,
                                x_publish_in_ss_flag        => awd_rec.publish_in_ss_flag
                               );
  END LOOP;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.cancel_invalid_award.debug','finsihed cancel_invalid_award for award_id:'||p_award_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_REPACKAGE.CANCEL_INVALID_AWARD ' || SQLERRM);
    igs_ge_msg_stack.add;

    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_gr_repackage.cancel_invalid_award.exception','sql error message:'||SQLERRM);
    END IF;

    app_exception.raise_exception;

END cancel_invalid_award;


PROCEDURE repackage(
                    p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE
                   ) AS
------------------------------------------------------------------
--Created by  : veramach, Oracle India
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

  CURSOR c_stud_det(
                    cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                   ) IS
    SELECT awd.base_id,
           awd.award_id,
           awd.fund_id,
           awd.award_status,
           fmast.fund_code
    FROM   igf_aw_fund_cat_all fcat,
           igf_aw_fund_mast_all fmast,
           igf_aw_award_all awd
    WHERE fcat.fed_fund_code = 'PELL'
      AND fcat.fund_code = fmast.fund_code
      AND fmast.fund_id = awd.fund_id
      AND awd.base_id   = cp_base_id
      AND NVL(awd.lock_award_flag,'N') = 'N';

  -- Cursor to get the RFMS records for the particular award id
  CURSOR c_rfms(
                cp_award_id igf_aw_award_all.award_id%TYPE
               ) IS
      SELECT rfms.*
        FROM igf_gr_rfms rfms
       WHERE award_id = cp_award_id;

  -- Cursor to get the RFMS Disbursement records for the RFMS Records
  CURSOR c_rfms_disb(
                     cp_origination_id igf_gr_rfms_disb_v.origination_id%TYPE
                    ) IS
      SELECT row_id,
             disb_ack_act_status
        FROM igf_gr_rfms_disb rfmd
       WHERE origination_id = cp_origination_id;

  -- Cursor to get the awards
  --modified in FA131 to choose adplans_id,offered_amt also
  CURSOR c_award(
                 cp_award_id igf_aw_award_all.award_id%TYPE
                ) IS
       SELECT awd.rowid row_id,
              awd.*
         FROM igf_aw_award_all awd
        WHERE awd.award_id = cp_award_id
          AND awd.award_status IN ('OFFERED','ACCEPTED');

  lc_stud_det          c_stud_det%ROWTYPE;
  lc_rfms              c_rfms%ROWTYPE;
  lc_rfms_disb         c_rfms_disb%ROWTYPE;
  lc_award             c_award%ROWTYPE;

  l_offered_amt        igf_aw_fund_mast_all.offered_amt%TYPE;
  l_process            igf_aw_award_t.process_id%TYPE;

  e_next_record        EXCEPTION;


  -- Get active ISIR
  CURSOR c_active_isir(
                       cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                      ) IS
    SELECT isir_id
      FROM igf_ap_isir_matched_all
     WHERE base_id     = cp_base_id
       AND active_isir = 'Y';
  l_active_isir c_active_isir%ROWTYPE;

  -- Get payment isir
  CURSOR c_payment_isir(
                        cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                       ) IS
    SELECT isir_id
      FROM igf_ap_isir_matched_all
     WHERE base_id     = cp_base_id
       AND payment_isir = 'Y';
  l_payment_isir c_payment_isir%ROWTYPE;

lb_valid_pell BOOLEAN := FALSE;

l_pell_tab        igf_gr_pell_calc.pell_tab := igf_gr_pell_calc.pell_tab();
lv_message        fnd_new_messages.message_text%TYPE := NULL;
lv_return_status  VARCHAR2(1) := NULL;

lv_message_ft        fnd_new_messages.message_text%TYPE := NULL;
lv_return_status_ft  VARCHAR2(1) := NULL;
l_pell_ft_aid        igf_gr_rfms_all.pell_amount%TYPE := NULL;
l_pell_aid           igf_gr_rfms_all.ft_pell_amount%TYPE := NULL;


l_log_message     VARCHAR2(4000);

-- Get alternate code
CURSOR c_alternate_code(
                        cp_cal_type          igs_ca_inst_all.cal_type%TYPE,
                        cp_sequence_number   igs_ca_inst_all.sequence_number%TYPE
                       ) IS
  SELECT alternate_code
    FROM igs_ca_inst_all
   WHERE cal_type = cp_cal_type
     AND sequence_number = cp_sequence_number;
l_alternate_code c_alternate_code%ROWTYPE;

-- Get pell setup values
CURSOR c_pell_setup(
                    cp_pell_seq_id igf_gr_pell_setup.pell_seq_id%TYPE
                   ) IS
  SELECT *
    FROM igf_gr_pell_setup
   WHERE pell_seq_id = cp_pell_seq_id;
l_pell_setup   c_pell_setup%ROWTYPE;


l_rfmsd_rec   igf_gr_rfms_disb%ROWTYPE;

lv_row_id  VARCHAR2(25);
lv_rfmd_id NUMBER;

-- Get disbursements which should be cancelled
CURSOR c_disb_cancel(
                     cp_award_id    igf_aw_award_all.award_id%TYPE,
                     cp_disb_num    igf_aw_awd_disb_all.disb_num%TYPE
                    ) IS
  SELECT *
    FROM igf_aw_awd_disb
   WHERE award_id = cp_award_id
     AND disb_num > cp_disb_num;

-- Get context disbursement record
CURSOR c_disb(
              cp_award_id igf_aw_award_all.award_id%TYPE,
              cp_disb_num igf_aw_awd_disb_all.disb_num%TYPE
             ) IS
  SELECT disb.rowid row_id,
         disb.*
    FROM igf_aw_awd_disb_all disb
   WHERE
    award_id = cp_award_id AND
    disb_num = cp_disb_num ;

l_disb_rec c_disb%ROWTYPE;
l_last_disb_num NUMBER;

  CURSOR c_rfmb_disb(
                     cp_origination_id igf_gr_rfms_disb_v.origination_id%TYPE,
                     cp_disb_num igf_gr_rfms_disb_all.disb_ref_num%TYPE
                    ) IS
      SELECT rfmd.rowid row_id,
             rfmd.*
        FROM igf_gr_rfms_disb_all rfmd
       WHERE
       rfmd.origination_id = cp_origination_id AND
       rfmd.disb_ref_num   = cp_disb_num ;


  CURSOR c_rfmd_extra(
                     cp_origination_id igf_gr_rfms_disb_v.origination_id%TYPE,
                     cp_disb_num igf_gr_rfms_disb_all.disb_ref_num%TYPE
                    ) IS
      SELECT rfmd.rowid row_id,
             rfmd.*
        FROM igf_gr_rfms_disb_all rfmd
       WHERE
       rfmd.origination_id = cp_origination_id AND
       rfmd.disb_ref_num   > cp_disb_num ;

  l_rfmb_disb_rec c_rfmb_disb%ROWTYPE;

  lv_rfms_exits_flag BOOLEAN ;

  l_pell_disb_cnt     NUMBER;
  lv_rowid            VARCHAR2(25);
  l_pell_seq_id       igf_gr_pell_setup_all.pell_seq_id%TYPE;
  l_pell_schedule_code igf_aw_award_all.alt_pell_schedule%TYPE;

  -- Get person number
  CURSOR c_person_number(
                          cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
      SELECT party_number
        FROM hz_parties parties,
             igf_ap_fa_base_rec_all fabase
       WHERE fabase.person_id = parties.party_id
         AND fabase.base_id   = cp_base_id;

  l_person_number hz_parties.party_number%TYPE;

    lv_msg_text             VARCHAR2(2000);
    ln_msg_index            NUMBER;

BEGIN

  fnd_file.new_line(fnd_file.log,1);
  fnd_message.set_name('IGF', 'IGF_AW_PROCESS_STUD');
  OPEN c_person_number(p_base_id);
  FETCH c_person_number INTO l_person_number;
  fnd_message.set_token('STUD',l_person_number);
  fnd_file.put_line(fnd_file.log, fnd_message.get);

  OPEN c_stud_det(
                  p_base_id
                 );
  FETCH c_stud_det INTO lc_stud_det;
  IF c_stud_det%NOTFOUND THEN
    CLOSE c_stud_det;

    fnd_message.set_name('IGF', 'IGF_AW_NO_PELL_STUDENT');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RETURN;
  END IF;

  --
  -- Logic : For each student detail records fetch the record from interface
  --         and rfms and rfms disbursement tables. If records doesnot exists
  --         raise a proper exception and skip the record. Also check
  --         if the origination action code is
  --         sent. If both the case then
  --         raise the exception and skip the record. If the record exists in
  --         RFMS AND RFMS Disbursement tables then delete from it.
  --


  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','***********person_number:'||l_person_number||'********');
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','award_id:'||lc_stud_det.award_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','fund_id:'||lc_stud_det.fund_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','award_status:'||lc_stud_det.award_status);
  END IF;

  SAVEPOINT sv_student;
  FOR lc_rfms IN c_rfms(lc_stud_det.award_id) LOOP

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lc_rfms.orig_action_code:'||lc_rfms.orig_action_code);
    END IF;


    FOR lc_rfms_disb IN c_rfms_disb(lc_rfms.origination_id) LOOP


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lc_rfms_disb.disb_ack_act_status:'||lc_rfms_disb.disb_ack_act_status);
    END IF;

      IF lc_rfms_disb.disb_ack_act_status NOT IN ('R','N') THEN
        fnd_message.set_name('IGF', 'IGF_GR_DISB_SENT_NO_RECALC');
        fnd_file.put_line( fnd_file.log, fnd_message.get);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','pell orig sent...erroring out');
        END IF;

        RAISE e_next_record;

      END IF;

    END LOOP;

  END LOOP;

  IF c_award%ISOPEN THEN
    CLOSE c_award;
  END IF;

  OPEN  c_award(
                lc_stud_det.award_id
               );
  FETCH c_award INTO lc_award;

  IF c_award%NOTFOUND THEN
    fnd_message.set_name('IGF', 'IGF_AW_NO_AWARD_REC');
    fnd_file.put_line( fnd_file.log, fnd_message.get);
    CLOSE c_award;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','no PELL award for student');
    END IF;

    RAISE e_next_record;
  END IF;

  CLOSE c_award;

  --if student does not have a valid ISIR or does not have COA defined, we have to error out
  lv_return_status  := NULL;
  igs_ge_msg_stack.initialize;
  igf_gr_pell_calc.pell_elig(p_base_id,lv_return_status);

  IF NVL(lv_return_status,'S') = 'E'  THEN
    lb_valid_pell := FALSE;
  ELSE
    lb_valid_pell := TRUE;
  END IF;

  IF NOT lb_valid_pell THEN

    --log messages
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','pell elig failed for :'||l_person_number);
    END IF;

    IF igs_ge_msg_stack.count_msg > 0 THEN
      lv_message := NULL;
      FOR i IN 1..igs_ge_msg_stack.count_msg
      LOOP
        igs_ge_msg_stack.get(i,'F',lv_msg_text, ln_msg_index);
        lv_message := lv_message         ||
                      fnd_global.newline ||
                      lv_msg_text;
      END LOOP;
      fnd_file.put_line(fnd_file.log, lv_message);
    END IF;


    IF g_test_run = 'Y' THEN

      IF g_cancel_invalid_awds = 'Y' THEN
        --cancel the award only if the user selects to cancel invalid awards

        fnd_message.set_name('IGF','IGF_AW_AWARD_CANCELLED');
        fnd_message.set_token('AWD',lc_stud_det.award_id);
        fnd_message.set_token('FUND',lc_stud_det.fund_code);
        fnd_file.put_line(fnd_file.log,fnd_message.get);

      ELSE -- Test run but not in Cancel Mode
        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);

      END IF;


    ELSE -- Running in Actual Mode

      IF g_cancel_invalid_awds = 'Y' THEN
        --cancel the award only if the user selects to cancel invalid awards

        fnd_message.set_name('IGF','IGF_AW_AWARD_CANCELLED');
        fnd_message.set_token('AWD',lc_stud_det.award_id);
        fnd_message.set_token('FUND',lc_stud_det.fund_code);
        fnd_file.put_line(fnd_file.log,fnd_message.get);

        cancel_invalid_award(lc_stud_det.award_id);
        COMMIT;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','cancelled invalid award '||lc_stud_det.award_id);
        END IF;

      ELSE -- Actual Mode but Cancel Awards not set to Yes

       fnd_message.set_name('IGF','IGF_SL_SKIPPING');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.new_line(fnd_file.log,1);

     END IF;

    END IF;

    RETURN;
  END IF;

  --check is the active isir is the payment isir.if not error out
  OPEN c_payment_isir(p_base_id);
  FETCH c_payment_isir INTO l_payment_isir;
  CLOSE c_payment_isir;

  OPEN c_active_isir(p_base_id);
  FETCH c_active_isir INTO l_active_isir;
  CLOSE c_active_isir;

  IF NVL(l_payment_isir.isir_id, -1) <> NVL(l_active_isir.isir_id, -2) THEN

    --log messages
    fnd_message.set_name('IGF','IGF_AP_PELL_ISIR_CHK');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','payment isir is not active isir..error');
    END IF;

    IF g_test_run <> 'Y' AND  g_cancel_invalid_awds = 'Y' THEN
      --cancel award and disbursements
      fnd_message.set_name('IGF','IGF_AP_PELL_ISIR_CHK');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      fnd_message.set_name('IGF','IGF_AW_AWARD_CANCELLED');
      fnd_message.set_token('AWD',lc_stud_det.award_id);
      fnd_message.set_token('FUND',lc_stud_det.fund_code);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      cancel_invalid_award(lc_stud_det.award_id);
      COMMIT;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','cancelled invalid award '||lc_stud_det.award_id);
      END IF;

    ELSE
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log,1);
    END IF;

    RETURN ;

  END IF; -- Payment ISIR not equal to Active ISIR

  l_offered_amt := NULL;
  --  Call the procedure to get the offered amount
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lc_stud_det.fund_id:'||lc_stud_det.fund_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lc_award.adplans_id:'||lc_award.adplans_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lc_stud_det.base_id:'||lc_stud_det.base_id);
  END IF;

  lv_message := NULL;
  l_pell_seq_id := NULL;

  l_pell_tab := igf_gr_pell_calc.pell_tab();
  igf_gr_pell_calc.calc_pell(
                             cp_fund_id       => lc_stud_det.fund_id,
                             cp_plan_id       => lc_award.adplans_id,
                             cp_base_id       => lc_stud_det.base_id,
                             cp_aid           => l_offered_amt,
                             cp_pell_tab      => l_pell_tab,
                             cp_return_status => lv_return_status,
                             cp_message       => lv_message,
                             cp_called_from   => 'PACKAGING',
                             cp_pell_seq_id   => l_pell_seq_id,
                             cp_pell_schedule_code => l_pell_schedule_code
                            );

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lv_return_status:'||lv_return_status);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lv_message:'||lv_message);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_pell_seq_id:'||l_pell_seq_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_offered_amt returned by the wrapper:'||l_offered_amt);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_pell_schedule_code:'||l_pell_schedule_code);
  END IF;

-- ========== Calculation Complete at this Point of Time ===========---
-- ==========  Now do Table Insert ===========---

    -- Check for Failure
    IF lv_return_status <> 'S' THEN
        fnd_file.put_line(fnd_file.log,lv_message);
        RAISE e_next_record;
    END IF;

    -- Check for new pall amount match in which case abort processing
    IF l_offered_amt = lc_award.offered_amt THEN
         fnd_message.set_name('IGF','IGF_GR_PELL_VALID_PELL_AWARD');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         RAISE e_next_record;
    END IF;

    -- Check if Origination Exists
    OPEN c_rfms(lc_stud_det.award_id);
    FETCH c_rfms INTO lc_rfms;
    IF c_rfms%FOUND THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','Found Pell Origination.Finding FT_PELL_AMT');
      END IF;

      igf_gr_pell_calc.calc_ft_max_pell(
                                        cp_base_id         => lc_stud_det.base_id,
                                        cp_cal_type        => lc_rfms.ci_cal_type,
                                        cp_sequence_number => lc_rfms.ci_sequence_number,
                                        cp_flag            => 'FULL_TIME',
                                        cp_aid             => l_pell_aid,
                                        cp_ft_aid          => l_pell_ft_aid,
                                        cp_return_status   => lv_return_status_ft,
                                        cp_message         => lv_message_ft
                                       );

      -- Check for Failure
      IF lv_return_status_ft <> 'S' THEN
        fnd_file.put_line(fnd_file.log,lv_message_ft);
        RAISE e_next_record;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','Full time PELL Amount:'||l_pell_ft_aid);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','updating igf_gr_rfms with pell_amount:'||l_offered_amt);
      END IF;

      -- Update the Origination Record
      igf_gr_rfms_pkg.update_row(
                                 x_rowid                  => lc_rfms.row_id,
                                 x_origination_id         => lc_rfms.origination_id,
                                 x_ci_cal_type            => lc_rfms.ci_cal_type,
                                 x_ci_sequence_number     => lc_rfms.ci_sequence_number,
                                 x_base_id                => lc_rfms.base_id,
                                 x_award_id               => lc_rfms.award_id,
                                 x_rfmb_id                => lc_rfms.rfmb_id,
                                 x_sys_orig_ssn           => lc_rfms.sys_orig_ssn,
                                 x_sys_orig_name_cd       => lc_rfms.sys_orig_name_cd,
                                 x_transaction_num        => lc_rfms.transaction_num,
                                 x_efc                    => lc_rfms.efc,
                                 x_ver_status_code        => lc_rfms.ver_status_code,
                                 x_secondary_efc          => lc_rfms.secondary_efc,
                                 x_secondary_efc_cd       => lc_rfms.secondary_efc_cd,
                                 x_pell_amount            => l_offered_amt,
                                 x_pell_profile           => lc_rfms.pell_profile,
                                 x_enrollment_status      => lc_rfms.enrollment_status,
                                 x_enrollment_dt          => lc_rfms.enrollment_dt,
                                 x_coa_amount             => lc_rfms.coa_amount,
                                 x_academic_calendar      => lc_rfms.academic_calendar,
                                 x_payment_method         => lc_rfms.payment_method,
                                 x_total_pymt_prds        => lc_rfms.total_pymt_prds,
                                 x_incrcd_fed_pell_rcp_cd => lc_rfms.incrcd_fed_pell_rcp_cd,
                                 x_attending_campus_id    => lc_rfms.attending_campus_id,
                                 x_est_disb_dt1           => lc_rfms.est_disb_dt1,
                                 x_orig_action_code       => lc_rfms.orig_action_code,
                                 x_orig_status_dt         => lc_rfms.orig_status_dt,
                                 x_orig_ed_use_flags      => lc_rfms.orig_ed_use_flags,
                                 x_ft_pell_amount         => l_pell_ft_aid,
                                 x_prev_accpt_efc         => lc_rfms.prev_accpt_efc,
                                 x_prev_accpt_tran_no     => lc_rfms.prev_accpt_tran_no,
                                 x_prev_accpt_sec_efc_cd  => lc_rfms.prev_accpt_sec_efc_cd,
                                 x_prev_accpt_coa         => lc_rfms.prev_accpt_coa,
                                 x_orig_reject_code       => lc_rfms.orig_reject_code,
                                 x_wk_inst_time_calc_pymt => lc_rfms.wk_inst_time_calc_pymt,
                                 x_wk_int_time_prg_def_yr => lc_rfms.wk_int_time_prg_def_yr,
                                 x_cr_clk_hrs_prds_sch_yr => lc_rfms.cr_clk_hrs_prds_sch_yr,
                                 x_cr_clk_hrs_acad_yr     => lc_rfms.cr_clk_hrs_acad_yr,
                                 x_inst_cross_ref_cd      => lc_rfms.inst_cross_ref_cd,
                                 x_low_tution_fee         => lc_rfms.low_tution_fee,
                                 x_rec_source             => lc_rfms.rec_source,
                                 x_pending_amount         => lc_rfms.pending_amount,
                                 x_mode                   => 'R',
                                 x_birth_dt               => lc_rfms.birth_dt,
                                 x_last_name              => lc_rfms.last_name,
                                 x_first_name             => lc_rfms.first_name,
                                 x_middle_name            => lc_rfms.middle_name,
                                 x_current_ssn            => lc_rfms.current_ssn,
                                 x_legacy_record_flag     => lc_rfms.legacy_record_flag,
                                 x_reporting_pell_cd      => lc_rfms.rep_pell_id,
                                 x_rep_entity_id_txt      => lc_rfms.rep_entity_id_txt,
                                 x_atd_entity_id_txt      => lc_rfms.atd_entity_id_txt,
                                 x_note_message           => lc_rfms.note_message,
                                 x_full_resp_code         => lc_rfms.full_resp_code,
                                 x_document_id_txt        => lc_rfms.document_id_txt
                                 );

      lv_rfms_exits_flag := TRUE ;
    ELSE
      lv_rfms_exits_flag := FALSE ;
    END IF;
    CLOSE c_rfms;

    IF igf_aw_packng_subfns.is_over_award_occured(lc_stud_det.base_id) THEN
      /*
       Since PELL is an entitlement, we should not insert overaward holds on the award.
       we show a message to the user saying that this award will result in an overaward, but we are not
       inserting overaward holds as the fund is an entitlement
      */
      fnd_message.set_name('IGF','IGF_AW_ENTITLE_OVAWD');
      fnd_message.set_token('FUND_CODE',lc_stud_det.fund_code);
      fnd_message.set_token('AWD',TO_CHAR(l_offered_amt));
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

   -- Loop thru the disbursements and post data
        fnd_file.put_line(fnd_file.log, RPAD('-',210,'-'));
--        fnd_file.put(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','DISBURSEMENT_NUMBER'), 18, ' '));
        fnd_file.put(fnd_file.log, RPAD('#', 3, ' '));
        fnd_file.put(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','DISBURSEMENT_DATE'), 30, ' '));
        fnd_file.put(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAD_CALENDAR'), 30, ' '));
        fnd_file.put(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','TEACHING_CALENDAR'), 30, ' '));
        fnd_file.put(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','OFFERED_AMT'), 30, ' '));
        fnd_file.put(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','ACCEPTED_AMT'), 30, ' '));
        fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','BASE_ATTEND_TYPE'), 30, ' '));
        fnd_file.put_line(fnd_file.log, RPAD('-',210,'-'));

   FOR i IN 1..l_pell_tab.COUNT
   LOOP
        l_log_message := RPAD(TO_CHAR(l_pell_tab(i).sl_number) ,3,' ');
        l_log_message := l_log_message || RPAD(TO_CHAR(l_pell_tab(i).disb_dt),30,' ');

        OPEN c_alternate_code(l_pell_tab(i).ld_cal_type,l_pell_tab(i).ld_sequence_number);
        FETCH c_alternate_code INTO l_alternate_code;
        CLOSE c_alternate_code;

        l_log_message := l_log_message || RPAD(l_alternate_code.alternate_code,30,' ');

        OPEN c_alternate_code(l_pell_tab(i).tp_cal_type,l_pell_tab(i).tp_sequence_number);
        FETCH c_alternate_code INTO l_alternate_code;
        CLOSE c_alternate_code;

        l_log_message := l_log_message || RPAD(l_alternate_code.alternate_code,30,' ');
        l_log_message := l_log_message || RPAD(TO_CHAR(l_pell_tab(i).offered_amt) ,30,' ');
        l_log_message := l_log_message || RPAD(TO_CHAR(l_pell_tab(i).accepted_amt) ,30,' ');
        l_log_message := l_log_message || RPAD(igf_aw_gen.lookup_desc('IGF_GR_RFMS_ENROL_STAT',l_pell_tab(i).base_attendance_type_code) ,30,' ');

        fnd_file.put_line(fnd_file.log, l_log_message);
        --update the disbursement here, if it exists
        --else insert the disbursement

        -- Update only if run in the the Non Test Mode
        IF NVL(g_test_run,'N') <> 'Y' THEN

        -- Check if a Disbursement Exits for the context Number
        OPEN c_disb(lc_stud_det.award_id,l_pell_tab(i).sl_number);
        FETCH c_disb INTO l_disb_rec;
        IF c_disb%FOUND THEN


             -- Update the Award Disbursement Table
             igf_aw_awd_disb_pkg.update_row(
                                    x_rowid                     =>    l_disb_rec.row_id,
                                    x_award_id                  =>    lc_stud_det.award_id,
                                    x_disb_num                  =>    l_pell_tab(i).sl_number,
                                    x_tp_cal_type               =>    l_pell_tab(i).tp_cal_type,
                                    x_tp_sequence_number        =>    l_pell_tab(i).tp_sequence_number,
                                    x_disb_gross_amt            =>    l_pell_tab(i).offered_amt,
                                    x_fee_1                     =>    l_disb_rec.fee_1,
                                    x_fee_2                     =>    l_disb_rec.fee_2,
                                    x_disb_net_amt              =>    l_pell_tab(i).accepted_amt,
                                    x_disb_date                 =>    l_pell_tab(i).disb_dt,
                                    x_trans_type                =>    l_disb_rec.trans_type,
                                    x_elig_status               =>    l_disb_rec.elig_status,
                                    x_elig_status_date          =>    l_disb_rec.elig_status_date,
                                    x_affirm_flag               =>    l_disb_rec.affirm_flag,
                                    x_hold_rel_ind              =>    l_disb_rec.hold_rel_ind,
                                    x_manual_hold_ind           =>    l_disb_rec.manual_hold_ind,
                                    x_disb_status               =>    l_disb_rec.disb_status,
                                    x_disb_status_date          =>    l_disb_rec.disb_status_date,
                                    x_late_disb_ind             =>    l_disb_rec.late_disb_ind,
                                    x_fund_dist_mthd            =>    l_disb_rec.fund_dist_mthd,
                                    x_prev_reported_ind         =>    l_disb_rec.prev_reported_ind,
                                    x_fund_release_date         =>    l_disb_rec.fund_release_date,
                                    x_fund_status               =>    l_disb_rec.fund_status,
                                    x_fund_status_date          =>    l_disb_rec.fund_status_date,
                                    x_fee_paid_1                =>    l_disb_rec.fee_paid_1,
                                    x_fee_paid_2                =>    l_disb_rec.fee_paid_2,
                                    x_cheque_number             =>    l_disb_rec.cheque_number,
                                    x_ld_cal_type               =>    l_pell_tab(i).ld_cal_type,
                                    x_ld_sequence_number        =>    l_pell_tab(i).ld_sequence_number,
                                    x_disb_accepted_amt         =>    l_pell_tab(i).accepted_amt,
                                    x_disb_paid_amt             =>    l_disb_rec.disb_paid_amt,
                                    x_rvsn_id                   =>    l_disb_rec.rvsn_id,
                                    x_int_rebate_amt            =>    l_disb_rec.int_rebate_amt,
                                    x_force_disb                =>    l_disb_rec.force_disb,
                                    x_min_credit_pts            =>    l_pell_tab(i).min_credit_pts,
                                    x_disb_exp_dt               =>    l_pell_tab(i).disb_exp_dt,
                                    x_verf_enfr_dt              =>    l_pell_tab(i).verf_enfr_dt,
                                    x_fee_class                 =>    l_disb_rec.fee_class,
                                    x_show_on_bill              =>    l_pell_tab(i).show_on_bill,
                                    x_mode                      =>    'R',
                                    x_attendance_type_code      =>    l_pell_tab(i).attendance_type_code,
                                    x_base_attendance_type_code =>    l_pell_tab(i).base_attendance_type_code,
                                    x_payment_prd_st_date       =>    l_disb_rec.payment_prd_st_date,
                                    x_change_type_code          =>    l_disb_rec.change_type_code,
                                    x_fund_return_mthd_code     =>    l_disb_rec.fund_return_mthd_code,
                                    x_direct_to_borr_flag       =>    l_disb_rec.direct_to_borr_flag
                                   );


            ELSE -- Disbursement Does not Exist ..So Insert it
             --

                     lv_row_id  := NULL;

             igf_aw_awd_disb_pkg.insert_row(
                                              x_rowid                     =>    lv_row_id,
                                              x_award_id                  =>    lc_stud_det.award_id,
                                              x_disb_num                  =>    l_pell_tab(i).sl_number,
                                              x_tp_cal_type               =>    l_pell_tab(i).tp_cal_type,
                                              x_tp_sequence_number        =>    l_pell_tab(i).tp_sequence_number,
                                              x_disb_gross_amt            =>    l_pell_tab(i).offered_amt,
                                              x_fee_1                     =>    NULL,
                                              x_fee_2                     =>    NULL,
                                              x_disb_net_amt              =>    l_pell_tab(i).accepted_amt,
                                              x_disb_date                 =>    l_pell_tab(i).disb_dt,
                                              x_trans_type                =>    'P',
                                              x_elig_status               =>    'N',
                                              x_elig_status_date          =>    NULL,
                                              x_affirm_flag               =>    'N',
                                              x_hold_rel_ind              =>    NULL,
                                              x_manual_hold_ind           =>    'N',
                                              x_disb_status               =>    NULL,
                                              x_disb_status_date          =>    NULL,
                                              x_late_disb_ind             =>    NULL,
                                              x_fund_dist_mthd            =>    'E',
                                              x_prev_reported_ind         =>    'N',
                                              x_fund_release_date         =>    NULL,
                                              x_fund_status               =>    NULL,
                                              x_fund_status_date          =>    NULL,
                                              x_fee_paid_1                =>    0,
                                              x_fee_paid_2                =>    0,
                                              x_cheque_number             =>    NULL,
                                              x_ld_cal_type               =>    l_pell_tab(i).ld_cal_type,
                                              x_ld_sequence_number        =>    l_pell_tab(i).ld_sequence_number,
                                              x_disb_accepted_amt         =>    l_pell_tab(i).accepted_amt,
                                              x_disb_paid_amt             =>    0,
                                              x_rvsn_id                   =>    NULL,
                                              x_int_rebate_amt            =>    0,
                                              x_force_disb                =>    NULL,
                                              x_min_credit_pts            =>    l_pell_tab(i).min_credit_pts,
                                              x_disb_exp_dt               =>    l_pell_tab(i).disb_exp_dt,
                                              x_verf_enfr_dt              =>    l_pell_tab(i).verf_enfr_dt,
                                              x_fee_class                 =>    NULL,
                                              x_show_on_bill              =>    l_pell_tab(i).show_on_bill,
                                              x_mode                      =>    'R',
                                              x_attendance_type_code      =>    l_pell_tab(i).attendance_type_code,
                                              x_base_attendance_type_code =>    l_pell_tab(i).base_attendance_type_code,
                                              x_payment_prd_st_date       =>    NULL,
                                              x_change_type_code          =>    NULL,
                                              x_fund_return_mthd_code     =>    NULL,
                                              x_direct_to_borr_flag       =>    'N'
                                          );

            END IF; -- Disbursement Record Insert
          CLOSE c_disb;
        END IF; -- Test Mode Flag Not Set
        -- Check if a RFMS Disbursement Exits for the context Number
        IF lv_rfms_exits_flag THEN

            -- Update only if run in the the Non Test Mode
            IF NVL(g_test_run,'N') <> 'Y' THEN
              IF NOT igf_sl_dl_validation.check_full_participant (lc_rfms.ci_cal_type,lc_rfms.ci_sequence_number,'PELL') THEN
                OPEN c_rfmb_disb(lc_rfms.origination_id,i);
                FETCH c_rfmb_disb INTO l_rfmb_disb_rec;
                IF c_rfmb_disb%FOUND THEN

                       l_rfmb_disb_rec.disb_ref_num  := i;
                       l_rfmb_disb_rec.disb_dt       := l_pell_tab(i).disb_dt ;
                       l_rfmb_disb_rec.disb_amt      := l_pell_tab(i).accepted_amt ;

                       IF  l_rfmb_disb_rec.disb_amt >= 0 THEN
                         l_rfmb_disb_rec.db_cr_flag       := 'P' ;
                       ELSE
                         l_rfmb_disb_rec.db_cr_flag       := 'N' ;
                       END IF;

                       l_rfmb_disb_rec.disb_ack_act_status     := 'R' ;
                       l_rfmb_disb_rec.disb_status_dt          := TRUNC(SYSDATE);
                       l_rfmb_disb_rec.disb_accpt_amt          := NULL ;
                       l_rfmb_disb_rec.accpt_db_cr_flag        := NULL ;
                       l_rfmb_disb_rec.disb_ytd_amt            := NULL ;
                       l_rfmb_disb_rec.pymt_prd_start_dt       := NULL ;
                       l_rfmb_disb_rec.accpt_pymt_prd_start_dt := NULL ;
                       l_rfmb_disb_rec.edit_code               := NULL ;
                       l_rfmb_disb_rec.rfmb_id                 := NULL ;


                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_rfmb_disb_rec.disb_ref_num:'||l_rfmb_disb_rec.disb_ref_num);
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_rfmb_disb_rec.disb_dt:'||l_rfmb_disb_rec.disb_dt);
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_rfmb_disb_rec.disb_amt:'||l_rfmb_disb_rec.disb_amt);
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_rfmb_disb_rec.db_cr_flag:'||l_rfmb_disb_rec.db_cr_flag);
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_rfmb_disb_rec.disb_ack_act_status:'||l_rfmb_disb_rec.disb_ack_act_status);
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','l_rfmb_disb_rec.disb_status_dt:'||l_rfmb_disb_rec.disb_status_dt);
                       END IF;


                                    igf_gr_rfms_disb_pkg.update_row(
                                          x_mode                              => 'R',
                                          x_rowid                             => l_rfmb_disb_rec.row_id,
                                          x_rfmd_id                           => l_rfmb_disb_rec.rfmd_id,
                                          x_origination_id                    => l_rfmb_disb_rec.origination_id,
                                          x_disb_ref_num                      => l_rfmb_disb_rec.disb_ref_num,
                                          x_disb_dt                           => l_rfmb_disb_rec.disb_dt,
                                          x_disb_amt                          => l_rfmb_disb_rec.disb_amt,
                                          x_db_cr_flag                        => l_rfmb_disb_rec.db_cr_flag,
                                          x_disb_ack_act_status               => l_rfmb_disb_rec.disb_ack_act_status ,
                                          x_disb_status_dt                    => l_rfmb_disb_rec.disb_status_dt ,
                                          x_accpt_disb_dt                     => l_rfmb_disb_rec.accpt_disb_dt ,
                                          x_disb_accpt_amt                    => l_rfmb_disb_rec.disb_accpt_amt ,
                                          x_accpt_db_cr_flag                  => l_rfmb_disb_rec.accpt_db_cr_flag ,
                                          x_disb_ytd_amt                      => l_rfmb_disb_rec.disb_ytd_amt ,
                                          x_pymt_prd_start_dt                 => l_rfmb_disb_rec.pymt_prd_start_dt ,
                                          x_accpt_pymt_prd_start_dt           => l_rfmb_disb_rec.accpt_pymt_prd_start_dt ,
                                          x_edit_code                         => l_rfmb_disb_rec.edit_code ,
                                          x_rfmb_id                           => l_rfmb_disb_rec.rfmb_id,
                                          x_ed_use_flags                      => l_rfmb_disb_rec.ed_use_flags
                                         );
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','lv_rfmd_id:'||lv_rfmd_id);
                 END IF;

                ELSE -- RFMS Disbursement does not exist so add

                                   lv_row_id  := NULL;
                                   lv_rfmd_id := NULL;

                                    igf_gr_rfms_disb_pkg.insert_row(
                                          x_mode                              => 'R',
                                          x_rowid                             => lv_row_id,
                                          x_rfmd_id                           => lv_rfmd_id,
                                          x_origination_id                    => lc_rfms.origination_id,
                                          x_disb_ref_num                      => i,
                                          x_disb_dt                           => l_pell_tab(i).disb_dt ,
                                          x_disb_amt                          => l_pell_tab(i).accepted_amt ,
                                          x_db_cr_flag                        => 'P',
                                          x_disb_ack_act_status               => 'R',
                                          x_disb_status_dt                    => TRUNC(SYSDATE) ,
                                          x_accpt_disb_dt                     => NULL ,
                                          x_disb_accpt_amt                    => NULL ,
                                          x_accpt_db_cr_flag                  => NULL ,
                                          x_disb_ytd_amt                      => NULL ,
                                          x_pymt_prd_start_dt                 => NULL ,
                                          x_accpt_pymt_prd_start_dt           => NULL ,
                                          x_edit_code                         => NULL ,
                                          x_rfmb_id                           => NULL ,
                                          x_ed_use_flags                      => NULL
                                         );


              END IF;
              CLOSE c_rfmb_disb;
            END IF; -- only for phase-in award year

         END IF; -- Test Mode Flag Not Set

        END IF; -- RFMS Exists Flag

   l_last_disb_num := i;

   END LOOP; -- Main loop for all the Disbursements from the Pl/SQL table

   -- At this point all New Disbursments are adjusted.
   -- Check if the old Award Had Extra Disbursements in which case they need to be Cancelled

   IF (NVL(g_test_run,'N') <> 'Y') THEN

      -- Delete Additional Disbursement records

      FOR disb_cancel_rec IN c_disb_cancel(lc_stud_det.award_id,l_last_disb_num) LOOP

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage.debug','cancelling awd_disb for award_id:'||disb_cancel_rec.award_id||' disb_cancel_rec.disb_num:'||disb_cancel_rec.disb_num);
          END IF;

        -- cancel the disbursement
        igf_aw_awd_disb_pkg.update_row(
                                       x_rowid                      =>    disb_cancel_rec.row_id,
                                       x_award_id                   =>    disb_cancel_rec.award_id,
                                       x_disb_num                   =>    disb_cancel_rec.disb_num,
                                       x_tp_cal_type                =>    disb_cancel_rec.tp_cal_type,
                                       x_tp_sequence_number         =>    disb_cancel_rec.tp_sequence_number,
                                       x_disb_gross_amt             =>    disb_cancel_rec.disb_gross_amt,
                                       x_fee_1                      =>    disb_cancel_rec.fee_1,
                                       x_fee_2                      =>    disb_cancel_rec.fee_2,
                                       x_disb_net_amt               =>    disb_cancel_rec.disb_net_amt,
                                       x_disb_date                  =>    disb_cancel_rec.disb_date,
                                       x_trans_type                 =>    'C',
                                       x_elig_status                =>    disb_cancel_rec.elig_status,
                                       x_elig_status_date           =>    disb_cancel_rec.elig_status_date,
                                       x_affirm_flag                =>    disb_cancel_rec.affirm_flag,
                                       x_hold_rel_ind               =>    disb_cancel_rec.hold_rel_ind,
                                       x_manual_hold_ind            =>    disb_cancel_rec.manual_hold_ind,
                                       x_disb_status                =>    disb_cancel_rec.disb_status,
                                       x_disb_status_date           =>    disb_cancel_rec.disb_status_date,
                                       x_late_disb_ind              =>    disb_cancel_rec.late_disb_ind,
                                       x_fund_dist_mthd             =>    disb_cancel_rec.fund_dist_mthd,
                                       x_prev_reported_ind          =>    disb_cancel_rec.prev_reported_ind,
                                       x_fund_release_date          =>    disb_cancel_rec.fund_release_date,
                                       x_fund_status                =>    disb_cancel_rec.fund_status,
                                       x_fund_status_date           =>    disb_cancel_rec.fund_status_date,
                                       x_fee_paid_1                 =>    disb_cancel_rec.fee_paid_1,
                                       x_fee_paid_2                 =>    disb_cancel_rec.fee_paid_2,
                                       x_cheque_number              =>    disb_cancel_rec.cheque_number,
                                       x_ld_cal_type                =>    disb_cancel_rec.ld_cal_type,
                                       x_ld_sequence_number         =>    disb_cancel_rec.ld_sequence_number,
                                       x_disb_accepted_amt          =>    0,
                                       x_disb_paid_amt              =>    0,
                                       x_rvsn_id                    =>    disb_cancel_rec.rvsn_id,
                                       x_int_rebate_amt             =>    disb_cancel_rec.int_rebate_amt,
                                       x_force_disb                 =>    disb_cancel_rec.force_disb,
                                       x_min_credit_pts             =>    disb_cancel_rec.min_credit_pts,
                                       x_disb_exp_dt                =>    disb_cancel_rec.disb_exp_dt,
                                       x_verf_enfr_dt               =>    disb_cancel_rec.verf_enfr_dt,
                                       x_fee_class                  =>    disb_cancel_rec.fee_class,
                                       x_show_on_bill               =>    disb_cancel_rec.show_on_bill,
                                       x_mode                       =>    'R',
                                       x_attendance_type_code       =>    disb_cancel_rec.attendance_type_code,
                                       x_base_attendance_type_code  =>    disb_cancel_rec.base_attendance_type_code,
                                       x_payment_prd_st_date        =>    disb_cancel_rec.payment_prd_st_date,
                                       x_change_type_code           =>    disb_cancel_rec.change_type_code,
                                       x_fund_return_mthd_code      =>    disb_cancel_rec.fund_return_mthd_code,
                                       x_direct_to_borr_flag        =>    disb_cancel_rec.direct_to_borr_flag
                                      );

      END LOOP;

   END IF; -- Cancel the Extra Disbursement Records


   -- Check if the old RFMS Disbursement records had Extra Disbursements in which case they need to be Deleted

   IF (NVL(g_test_run,'N') <> 'Y') AND (lv_rfms_exits_flag) THEN

      -- Clear Additional RFMS Entries if any.

      FOR rfms_disb_rec IN c_rfmd_extra(lc_rfms.origination_id,l_last_disb_num) LOOP
          igf_gr_rfms_disb_pkg.delete_row(rfms_disb_rec.row_id);
      END LOOP;

   END IF; -- Delete of Extra RFMS Disbursement Records

   IF NVL(g_test_run,'N') <> 'Y' THEN
     IF NVL(l_pell_schedule_code,'*') <> NVL(lc_award.alt_pell_schedule,'*') THEN
       igf_aw_award_pkg.update_row(
                                   x_rowid              => lc_award.row_id,
                                   x_award_id           => lc_award.award_id,
                                   x_fund_id            => lc_award.fund_id,
                                   x_base_id            => lc_award.base_id,
                                   x_offered_amt        => lc_award.offered_amt,
                                   x_accepted_amt       => lc_award.accepted_amt,
                                   x_paid_amt           => lc_award.paid_amt,
                                   x_packaging_type     => lc_award.packaging_type,
                                   x_batch_id           => lc_award.batch_id,
                                   x_manual_update      => lc_award.manual_update,
                                   x_rules_override     => lc_award.rules_override,
                                   x_award_date         => lc_award.award_date,
                                   x_award_status       => lc_award.award_status,
                                   x_attribute_category => lc_award.attribute_category,
                                   x_attribute1         => lc_award.attribute1,
                                   x_attribute2         => lc_award.attribute2,
                                   x_attribute3         => lc_award.attribute3,
                                   x_attribute4         => lc_award.attribute4,
                                   x_attribute5         => lc_award.attribute5,
                                   x_attribute6         => lc_award.attribute6,
                                   x_attribute7         => lc_award.attribute7,
                                   x_attribute8         => lc_award.attribute8,
                                   x_attribute9         => lc_award.attribute9,
                                   x_attribute10        => lc_award.attribute10,
                                   x_attribute11        => lc_award.attribute11,
                                   x_attribute12        => lc_award.attribute12,
                                   x_attribute13        => lc_award.attribute13,
                                   x_attribute14        => lc_award.attribute14,
                                   x_attribute15        => lc_award.attribute15,
                                   x_attribute16        => lc_award.attribute16,
                                   x_attribute17        => lc_award.attribute17,
                                   x_attribute18        => lc_award.attribute18,
                                   x_attribute19        => lc_award.attribute19,
                                   x_attribute20        => lc_award.attribute20,
                                   x_rvsn_id            => lc_award.rvsn_id,
                                   x_alt_pell_schedule  => l_pell_schedule_code,--update the pell schedule
                                   x_mode               => 'R',
                                   x_award_number_txt   => lc_award.award_number_txt,
                                   x_legacy_record_flag => lc_award.legacy_record_flag,
                                   x_adplans_id         => lc_award.adplans_id,
                                   x_lock_award_flag    => lc_award.lock_award_flag,
                                   x_app_trans_num_txt  => lc_award.app_trans_num_txt,
                                   x_awd_proc_status_code  => lc_award.awd_proc_status_code,
                                   x_notification_status_code	=> lc_award.notification_status_code,
                                   x_notification_status_date	=> lc_award.notification_status_date,
                                   x_publish_in_ss_flag       => lc_award.publish_in_ss_flag
                                  );
     END IF;
   END IF;

   fnd_file.put_line(fnd_file.log, RPAD('-',210,'-'));


    --issue a commit
    COMMIT;


  fnd_message.set_name('IGF','IGF_AW_PROCESS_COMPLETE');
  fnd_file.put_line( fnd_file.log, fnd_message.get);
  fnd_file.new_line(fnd_file.log,2);

  EXCEPTION

    WHEN e_next_record THEN
      ROLLBACK to sv_student;
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log,1);

    WHEN others THEN
      ROLLBACK to sv_student;
      fnd_file.put_line(fnd_file.log,SQLERRM);
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.new_line(fnd_file.log,1);

END repackage;



PROCEDURE repackage_pell(
                         errbuf                OUT NOCOPY  VARCHAR2,
                         retcode               OUT NOCOPY  NUMBER,
                         p_award_year          IN          VARCHAR2,
                         p_base_id             IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_org_id              IN          igf_aw_award_all.org_id%TYPE,
                         p_persid_grp          IN          igs_pe_persid_group_all.group_id%TYPE,
                         p_test_run            IN          VARCHAR2,
                         p_cancel_invalid_awds IN          VARCHAR2
                        ) AS
-----------------------------------------------------------------------------------------------
--  Change History :
--  Who             When            What
--  (reverse chronological order - newest change first)
--  ridas        08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
--  veramach     02-Dec-2003     FA 131 COD Updates
--                               Adds p_persid_grp,p_test_run,p_cancel_invalid_awds as parameters
--  rasahoo      27-aug-2003     Removed the call to IGF_AP_OSS_PROCESS.GET_OSS_DETAILS
--                               as part of obsoletion of FA base record history
-----------------------------------------------------------------------------------------------
--  rasahoo      23-Apl-2003     Bug # 2860836
--                               locking problem created by fund manager is resolved
-----------------------------------------------------------------------------------------------
--  brajendr     24-Oct-2002     FA105 / FA108 Builds
--                               Modified the call PELL calc procedure to add one more parameter
-----------------------------------------------------------------------------------------------
--

   -- Get all base ids in a award year
   CURSOR c_all_base_id(
                        cp_seq_number     igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                        cp_cal_type       igf_ap_fa_base_rec_all.ci_cal_type%TYPE
                       ) IS
      SELECT awd.base_id
        FROM igf_aw_award_all awd,
             igf_aw_fund_mast_all fmast,
             igf_aw_fund_cat_all fcat
       WHERE fmast.ci_sequence_number = cp_seq_number
         AND fmast.ci_cal_type        = cp_cal_type
         AND awd.fund_id              = fmast.fund_id
         AND fmast.fund_code          = fcat.fund_code
         AND fcat.fed_fund_code       = 'PELL';

  l_ci_cal_type        igf_aw_fund_mast_all.ci_cal_type%TYPE;
  l_ci_sequence_number igf_aw_fund_mast_all.ci_sequence_number%TYPE;
  l_base_id            igf_ap_fa_base_rec_all.base_id%TYPE;

  TYPE baseidRefCur IS REF CURSOR;
  cur_base_id baseidRefCur;

  lv_status         VARCHAR2(1);
  l_list            VARCHAR2(32767);
  lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

BEGIN

  retcode := 0;
  errbuf  := NULL;
  --  Need to set the Org Id for this Responsibility
  igf_aw_gen.set_org_id(p_org_id);



  IF p_award_year IS NULL THEN
    fnd_message.set_name('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RETURN;
  END IF;

  --  Process only the given fund in the given Award Year.
  l_ci_cal_type := RTRIM(SUBSTR(p_award_year,1,10));

  l_ci_sequence_number := TO_NUMBER(LTRIM(RTRIM(SUBSTR(p_award_year,11))));

  l_base_id := p_base_id;

  g_test_run            := p_test_run;
  g_cancel_invalid_awds := p_cancel_invalid_awds;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage_pell.debug','l_ci_cal_type:'||l_ci_cal_type);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage_pell.debug','l_ci_sequence_number:'||l_ci_sequence_number);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage_pell.debug','l_base_id:'||l_base_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage_pell.debug','g_test_run:'||g_test_run);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage_pell.debug','g_cancel_invalid_awds:'||g_cancel_invalid_awds);
  END IF;

  log_parameters(l_ci_cal_type,l_ci_sequence_number,l_base_id,p_persid_grp,p_test_run,p_cancel_invalid_awds);

  IF p_base_id IS NOT NULL AND p_persid_grp IS NOT NULL THEN
    --Cannot pass both base_id and person_id group.
    fnd_message.set_name('IGF', 'IGF_AW_COA_PARAM_EX');
    fnd_file.put_line( fnd_file.log, fnd_message.get);
    RETURN;
  END IF;

  --
  -- Open the Student Details and check if the records exists else
  -- raise a message
  --
  IF p_persid_grp IS NOT NULL THEN
    --get all base_id in the group and call the main routine

    --get al person_id in the person _id group
    --Bug #5021084
    l_list := igf_ap_ss_pkg.get_pid(p_persid_grp,lv_status,lv_group_type);

    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      --open ref cursor for fetching the base_id of the person
      OPEN cur_base_id FOR ' SELECT base_id FROM igf_ap_fa_base_rec_all WHERE  ci_cal_type = :p_ci_cal_type AND  ci_sequence_number = :p_ci_sequence_number AND  person_id IN (' || l_list  || ') ' USING l_ci_cal_type, l_ci_sequence_number,p_persid_grp;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      --open ref cursor for fetching the base_id of the person
      OPEN cur_base_id FOR ' SELECT base_id FROM igf_ap_fa_base_rec_all WHERE  ci_cal_type = :p_ci_cal_type AND  ci_sequence_number = :p_ci_sequence_number AND  person_id IN (' || l_list  || ') ' USING l_ci_cal_type, l_ci_sequence_number;
    END IF;


    FETCH cur_base_id INTO l_base_id;
    IF cur_base_id%FOUND THEN
      WHILE cur_base_id%FOUND
      LOOP
        --call the main routine here
        repackage(l_base_id);

        FETCH cur_base_id INTO l_base_id;
      END LOOP;
    ELSE
      fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

  ELSIF p_base_id IS NOT NULL THEN
    --call the routine for the single base_id
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_repackage.repackage_pell.debug','calling repackage with base_id:'||p_base_id);
    END IF;
    repackage(p_base_id);

  ELSIF p_base_id IS NULL THEN
    --get all base_id in the award year and call the main routine for all base_id

    FOR lc_all_base_id IN c_all_base_id(l_ci_sequence_number,l_ci_cal_type) LOOP
      --call the main routine here
      repackage(lc_all_base_id.base_id);
    END LOOP;

  END IF;

EXCEPTION
  WHEN app_exception.record_lock_exception THEN
    ROLLBACK;
    retcode := 2;
    errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
    igs_ge_msg_stack.conc_exception_hndl;
  WHEN OTHERS THEN
    ROLLBACK ;
    retcode := 2;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_REPACKAGE.REPACKAGE_PELL '||SQLERRM);
    errbuf := fnd_message.get;
    igs_ge_msg_stack.conc_exception_hndl;

END repackage_pell;

END igf_gr_repackage;

/
