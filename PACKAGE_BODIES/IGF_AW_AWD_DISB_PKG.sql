--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWD_DISB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWD_DISB_PKG" AS
/* $Header: IGFWI24B.pls 120.5 2006/08/07 08:11:27 veramach ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_awd_disb_all%ROWTYPE;
  new_references igf_aw_awd_disb_all%ROWTYPE;
  g_v_called_from  VARCHAR2(30);

   PROCEDURE AfterRowInsertUpdateDelete1(
     p_inserting IN BOOLEAN ,
     p_updating  IN BOOLEAN ,
     p_deleting  IN BOOLEAN
    );

   PROCEDURE BeforeRowInsertUpdateDelete1(
     p_rowid     IN VARCHAR2,
     p_inserting IN BOOLEAN ,
     p_updating  IN BOOLEAN ,
     p_deleting  IN BOOLEAN
    );

  PROCEDURE after_dml (
    p_action  IN  VARCHAR2) AS
  /*--------------------------------------------------------------
  ||  Created By : AYEDUBAT
  ||  Created On : 15-OCT-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  museshad        05-Jan-2006     Bug 4930323. Fixed issue in DRI validation.
  ||                                  Did code clean up by introducing new flag variable
  ||                                  l_change_value.
  ||  ridas           10-Jan-2005     Bug #3701698. NVL is added in parameter new_references.disb_accepted_amt
  ||                                  in procedure igf_aw_db_chg_dtls_pkg.insert_row
  --------------------------------------------------------------*/

  CURSOR award_year_cal_cur (cp_award_id IGF_AW_AWD_DISB_ALL.award_id%TYPE) IS
    SELECT fmast.ci_cal_type,fmast.ci_sequence_number, awd.award_status
    FROM IGF_AW_AWARD_ALL awd,
         IGF_AW_FUND_MAST fmast
    WHERE awd.award_id = cp_award_id
      AND awd.fund_id = fmast.fund_id;
  award_year_cal_rec award_year_cal_cur%ROWTYPE;

  CURSOR upd_db_chg_dtls_cur( cp_award_id igf_aw_db_chg_dtls.award_id%TYPE,
                              cp_disb_num igf_aw_db_chg_dtls.disb_num%TYPE,
                              cp_disb_seq_num igf_aw_db_chg_dtls.disb_seq_num%TYPE) IS
    SELECT dbchgdtls.ROWID,dbchgdtls.*
    FROM igf_aw_db_chg_dtls dbchgdtls
    WHERE dbchgdtls.award_id = cp_award_id
      AND dbchgdtls.disb_num = cp_disb_num
      AND dbchgdtls.disb_seq_num = cp_disb_seq_num;
  upd_db_chg_dtls_rec upd_db_chg_dtls_cur%ROWTYPE;

  CURSOR max_disb_seq_num_cur(cp_award_id igf_aw_db_chg_dtls.award_id%TYPE,
                              cp_disb_num igf_aw_db_chg_dtls.disb_num%TYPE) IS
    SELECT max(dbchgdtls.disb_seq_num)+1
    FROM igf_aw_db_chg_dtls dbchgdtls
    WHERE dbchgdtls.award_id = cp_award_id
      AND dbchgdtls.disb_num = cp_disb_num;
  l_max_disb_seq_num igf_aw_db_chg_dtls.disb_seq_num%TYPE;

  CURSOR loans_cur (cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
    SELECT sl.ROWID, sl.*
    FROM IGF_SL_LOANS_ALL sl
    WHERE sl.award_id = cp_award_id;
  loans_rec loans_cur%ROWTYPE;

  CURSOR pell_cur (cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
    SELECT pell.*, pell.ROWID
    FROM igf_gr_rfms_all pell
    WHERE pell.award_id = cp_award_id;

    pell_rec pell_cur%ROWTYPE;

  CURSOR min_disb_date_cur(cp_award_id igf_aw_awd_disb_all.award_id%TYPE) IS
    SELECT min(disb_date)
    FROM igf_aw_awd_disb_all
    WHERE award_id = cp_award_id;

  CURSOR cur_latest_accepted_DateAmt  ( cp_award_id igf_aw_db_chg_dtls.award_id%TYPE,
                                        cp_disb_num igf_aw_db_chg_dtls.disb_num%TYPE,
                                        cp_disb_activity igf_aw_db_chg_dtls.disb_activity%TYPE) IS
    SELECT  chgdtls.*
      FROM  IGF_AW_DB_CHG_DTLS chgdtls
     WHERE  chgdtls.award_id = cp_award_id
      AND   chgdtls.disb_num = cp_disb_num
      AND   chgdtls.disb_status = 'A'
      AND   (chgdtls.disb_activity = 'P' OR chgdtls.disb_activity = cp_disb_activity)
    ORDER BY chgdtls.disb_seq_num DESC;
  latest_accepted_DateAmount_rec  cur_latest_accepted_DateAmt%ROWTYPE;

  CURSOR cur_latest_DateAmt_for_update  ( cp_award_id igf_aw_db_chg_dtls.award_id%TYPE,
                                          cp_disb_num igf_aw_db_chg_dtls.disb_num%TYPE,
                                          cp_disb_activity igf_aw_db_chg_dtls.disb_activity%TYPE) IS
    SELECT  chgdtls.ROWID, chgdtls.*
      FROM  IGF_AW_DB_CHG_DTLS chgdtls
     WHERE  chgdtls.award_id = cp_award_id
      AND   chgdtls.disb_num = cp_disb_num
      AND   chgdtls.disb_status <> 'A'
      AND   chgdtls.disb_activity = cp_disb_activity
    ORDER BY chgdtls.disb_seq_num DESC;
  latest_update_rec cur_latest_DateAmt_for_update%ROWTYPE;

  CURSOR cur_updated_award_amount (cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
  SELECT SUM(awddisb.DISB_NET_AMT) total_amt
       FROM IGF_AW_AWD_DISB_ALL awddisb
               WHERE awddisb.award_id = cp_award_id;
  updated_award_amount cur_updated_award_amount%ROWTYPE;

  l_row_id ROWID;
  l_message VARCHAR2(2000);
  l_cod_year_flag      BOOLEAN;
  l_dl_disb_change_status BOOLEAN;
  lv_first_disb_seq_accepted BOOLEAN;
  l_fund_code igf_aw_fund_cat.fed_fund_code%TYPE;
  l_loan_type VARCHAR2(10);
  l_min_disb_date DATE;
  l_disb_activity igf_aw_db_chg_dtls.disb_activity%TYPE;
  l_first_disb_flag igf_aw_db_chg_dtls.first_disb_flag%TYPE;
  l_change_value NUMBER := 0;

  BEGIN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement,
                      'igf.plsql.igf_aw_awd_disb_pkg.after_dml ',
                      'Processing award_id= ' ||new_references.award_id|| ', disb num= ' ||new_references.disb_num);
    END IF;

    l_rowid := NULL;
    IF (p_action = 'UPDATE') THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.after_dml ', 'action = update ' );
      END IF;
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete1
      (
        p_inserting => FALSE,
        p_updating  => TRUE ,
        p_deleting  => FALSE
      );
    ELSIF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After insert
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.after_dml ', 'action = insert ' );
      END IF;
      AfterRowInsertUpdateDelete1
      (
        p_inserting => TRUE,
        p_updating  => FALSE ,
        p_deleting  => FALSE
      );
    END IF;
    l_dl_disb_change_status := FALSE;
    l_first_disb_flag    := NULL;
    l_min_disb_date      := NULL;

    -- Get the Federal Fund Code
    l_fund_code := NULL;
    l_fund_code := igf_sl_gen.get_fed_fund_code(new_references.award_id, l_message);

    -- If fund Code is of Type, Direct Loans then Pass DL for COD-XML Processing
    -- If fund Code is of Type, Pell Grants then  Pass PELL for COD-XML Processing

    -- Get the Award Year Calendar Instance
    OPEN  award_year_cal_cur(new_references.award_id);
    FETCH award_year_cal_cur INTO award_year_cal_rec;
    CLOSE award_year_cal_cur;

    OPEN  loans_cur(new_references.award_id);
    FETCH loans_cur INTO loans_rec;
    CLOSE loans_cur;

    OPEN  pell_cur(new_references.award_id);
    FETCH pell_cur INTO pell_rec;
    CLOSE pell_cur;

    -- Check whether the awarding year is COD-XML processing year
    l_cod_year_flag := NULL;
    l_loan_type     := NULL;

    IF l_fund_code IN ('DLP','DLS','DLU') AND
       award_year_cal_rec.award_status <> 'SIMULATED' AND
       (NVL(loans_rec.loan_status,'*') <> 'S' OR NVL(loans_rec.loan_status,'S') <> 'S' ) THEN
       l_loan_type := 'DL';
       l_cod_year_flag := igf_sl_dl_validation.check_full_participant (award_year_cal_rec.ci_cal_type,award_year_cal_rec.ci_sequence_number,'DL');
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' DL is true ' );
       END IF;

    ELSIF l_fund_code = 'PELL' AND
          award_year_cal_rec.award_status <> 'SIMULATED' AND
          NVL(pell_rec.orig_action_code,'*') <> 'S'  AND
          (igf_sl_dl_validation.check_full_participant (award_year_cal_rec.ci_cal_type,award_year_cal_rec.ci_sequence_number,'PELL')) THEN
          l_loan_type := 'PELL';
          l_cod_year_flag := TRUE;

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' Pell is true ' );
       END IF;

       IF NVL(new_references.payment_prd_st_date,TO_DATE('4712/12/31','YYYY/MM/DD')) <> NVL(old_references.payment_prd_st_date,TO_DATE('4712/12/31','YYYY/MM/DD'))
        OR NVL(new_references.hold_rel_ind,'*') <> NVL(old_references.hold_rel_ind,'*')
        OR NVL(new_references.disb_accepted_amt,0) <> NVL(old_references.disb_accepted_amt,0)
        OR new_references.disb_date <> old_references.disb_date THEN
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' Before update in RFMS ' );
           END IF;
           IF pell_rec.rowid IS NOT NULL THEN

             --akomurav
             --The pell amount was not updated in the RFMS table when ever there is some change in the PELL amount
             --this fix will update the RFMS table with the pell amount (if it is updated due to deletion or updation of Disbursments
             OPEN cur_updated_award_amount(new_references.award_id);
             FETCH cur_updated_award_amount INTO updated_award_amount;
             CLOSE cur_updated_award_amount;

             igf_gr_rfms_pkg.update_row(
                                x_rowid                        => pell_rec.rowid,
                                x_origination_id               => pell_rec.origination_id,
                                x_ci_cal_type                  => pell_rec.ci_cal_type,
                                x_ci_sequence_number           => pell_rec.ci_sequence_number,
                                x_base_id                      => pell_rec.base_id,
                                x_award_id                     => pell_rec.award_id,
                                x_rfmb_id                      => pell_rec.rfmb_id,
                                x_sys_orig_ssn                 => pell_rec.sys_orig_ssn,
                                x_sys_orig_name_cd             => pell_rec.sys_orig_name_cd,
                                x_transaction_num              => pell_rec.transaction_num,
                                x_efc                          => pell_rec.efc,
                                x_ver_status_code              => pell_rec.ver_status_code,
                                x_secondary_efc                => pell_rec.secondary_efc,
                                x_secondary_efc_cd             => pell_rec.secondary_efc_cd,
                                x_pell_amount                  => updated_award_amount.total_amt,
                                x_pell_profile                 => pell_rec.pell_profile,
                                x_enrollment_status            => pell_rec.enrollment_status,
                                x_enrollment_dt                => pell_rec.enrollment_dt,
                                x_coa_amount                   => pell_rec.coa_amount,
                                x_academic_calendar            => pell_rec.academic_calendar,
                                x_payment_method               => pell_rec.payment_method,
                                x_total_pymt_prds              => pell_rec.total_pymt_prds,
                                x_incrcd_fed_pell_rcp_cd       => pell_rec.incrcd_fed_pell_rcp_cd,
                                x_attending_campus_id          => pell_rec.attending_campus_id,
                                x_est_disb_dt1                 => pell_rec.est_disb_dt1,
                                x_orig_action_code             => 'R', -- ready to send
                                x_orig_status_dt               => TRUNC(SYSDATE),
                                x_orig_ed_use_flags            => pell_rec.orig_ed_use_flags,
                                x_ft_pell_amount               => pell_rec.ft_pell_amount,
                                x_prev_accpt_efc               => pell_rec.prev_accpt_efc,
                                x_prev_accpt_tran_no           => pell_rec.prev_accpt_tran_no,
                                x_prev_accpt_sec_efc_cd        => pell_rec.prev_accpt_sec_efc_cd,
                                x_prev_accpt_coa               => pell_rec.prev_accpt_coa,
                                x_orig_reject_code             => pell_rec.orig_reject_code,
                                x_wk_inst_time_calc_pymt       => pell_rec.wk_inst_time_calc_pymt,
                                x_wk_int_time_prg_def_yr       => pell_rec.wk_int_time_prg_def_yr,
                                x_cr_clk_hrs_prds_sch_yr       => pell_rec.cr_clk_hrs_prds_sch_yr,
                                x_cr_clk_hrs_acad_yr           => pell_rec.cr_clk_hrs_acad_yr,
                                x_inst_cross_ref_cd            => pell_rec.inst_cross_ref_cd,
                                x_low_tution_fee               => pell_rec.low_tution_fee,
                                x_rec_source                   => pell_rec.rec_source,
                                x_pending_amount               => pell_rec.pending_amount,
                                x_mode                         => 'R',
                                x_birth_dt                     => pell_rec.birth_dt,
                                x_last_name                    => pell_rec.last_name,
                                x_first_name                   => pell_rec.first_name,
                                x_middle_name                  => pell_rec.middle_name,
                                x_current_ssn                  => pell_rec.current_ssn,
                                x_legacy_record_flag           => pell_rec.legacy_record_flag,
                                x_reporting_pell_cd            => pell_rec.reporting_pell_cd,
                                x_rep_entity_id_txt            => pell_rec.rep_entity_id_txt,
                                x_atd_entity_id_txt            => pell_rec.atd_entity_id_txt,
                                x_note_message                 => pell_rec.note_message,
                                x_full_resp_code               => pell_rec.full_resp_code,
                                x_document_id_txt              => pell_rec.document_id_txt);
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' updated rfms table ' );
             END IF;
           END IF;
      END IF; -- move rfms status
    END IF; -- loan type

    IF l_loan_type IN ('DL','PELL') THEN
      -- Get the Minimum Disbursement Date for the Award
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' Loan Type is  ' || l_loan_type );
      END IF;

      OPEN min_disb_date_cur (new_references.award_id);
      FETCH min_disb_date_cur INTO l_min_disb_date;
      CLOSE min_disb_date_cur;

      -- if the disbursement date is the minimun date then assign true else assign false;
      IF new_references.disb_date = l_min_disb_date THEN
        l_first_disb_flag := 'true';
      ELSE
        l_first_disb_flag := 'false';
      END IF;

      -- When a new Disbursement record is created, create a Disbursement change details record
      IF p_action = 'INSERT' THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' before insert of change rec 1 ' );
        END IF;

        -- Insert the new Disbursement change details record
        l_row_id := NULL;
        igf_aw_db_chg_dtls_pkg.insert_row(
          x_rowid                 => l_row_id,
          x_award_id              => new_references.award_id,
          x_disb_num              => new_references.disb_num,
          x_disb_seq_num          => 1,
          x_disb_accepted_amt     => NVL(new_references.disb_accepted_amt,0),
          x_orig_fee_amt          => new_references.fee_1,
          x_disb_net_amt          => new_references.disb_net_amt,
          x_disb_date             => new_references.disb_date,
          x_disb_activity         => 'P',
          x_disb_status           => 'G',
          x_disb_status_date      => TRUNC(SYSDATE),
          x_disb_rel_flag         => NVL(new_references.hold_rel_ind,'FALSE'),
          x_first_disb_flag       => l_first_disb_flag,
          x_interest_rebate_amt   => new_references.int_rebate_amt,
          x_disb_conf_flag        => new_references.affirm_flag,
          x_pymnt_prd_start_date  => new_references.payment_prd_st_date,
          x_note_message          => NULL,
          x_batch_id_txt          => NULL,
          x_ack_date              => NULL,
          x_booking_id_txt        => NULL,
          x_booking_date          => NULL,
          x_mode                  => 'R');
        IF l_loan_type = 'DL' THEN
          l_dl_disb_change_status := TRUE;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' after insert of change rec 1 ' );
        END IF;

      ELSIF (p_action = 'UPDATE') THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','p_action= ' ||p_action);
        END IF;

        OPEN upd_db_chg_dtls_cur( new_references.award_id, new_references.disb_num, 1);
        FETCH upd_db_chg_dtls_cur INTO upd_db_chg_dtls_rec;
        CLOSE upd_db_chg_dtls_cur;

        IF upd_db_chg_dtls_rec.disb_status = 'A' THEN
          lv_first_disb_seq_accepted := TRUE;
        ELSE
          lv_first_disb_seq_accepted := FALSE;
        END IF;

        -- museshad (Bug 4930323) - DRI Validation Code clean up
        /*
          l_change_value is a flag variable that can take one of the following values - 1,2,3.

          l_change_value = 0
              - No change in DRI/Disb amount/Disb date. Nothing needs to be done.

          l_change_value = 1
              - DRI is FALSE. Since DRI is FALSE, existing disb sequence needs to be updated, no question of insert.
              - Disb amount/Disb date has got changed (or) DRI has changed from FALSE to TRUE.

          l_change_value = 2
              - DRI is TRUE. Insert/Update of disb sequence.
              - Disb amount/Disb date has got changed.
                If Disb amount has changed, chk if there exists a disb sequence (in desc order of disb seq)
                of disb_activity type 'A' in not Accepted status. If it exists, update this disb seq,
                else insert new disb sequence with the new disb amount.
                Same logic holds good for Disb date change (disb_activity = 'Q')

          Note: Code clean up is done only for Full-Participant. The new code doesn't look for Phase-in
                participant assuming that Schools can't be in Phase-in Participant. For Phase-in participant
                l_change_value remains 0 and no change is done to the disb change records.
        */
        IF l_cod_year_flag THEN
          IF (NVL(new_references.hold_rel_ind, 'FALSE') = 'TRUE' AND NVL(old_references.hold_rel_ind, 'FALSE') = 'FALSE') THEN
            -- DRI changed from FALSE to TRUE. Update disb sequence
            l_change_value := 1;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','DRI has changed from FALSE to TRUE');
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','Marking l_change_value= ' ||l_change_value);
            END IF;
          ELSE
            IF (
                  (old_references.disb_accepted_amt <> new_references.disb_accepted_amt OR
                  NVL(old_references.fee_1,-1) <> NVL(new_references.fee_1,-1) OR
                  old_references.disb_net_amt <> new_references.disb_net_amt OR
                  NVL(old_references.hold_rel_ind, 'FALSE') <> NVL(new_references.hold_rel_ind, 'FALSE') OR
                  NVL(old_references.affirm_flag,' ') <> NVL(new_references.affirm_flag,' ') OR
                  NVL(old_references.payment_prd_st_date,TO_DATE('4712/12/31','YYYY/MM/DD')) <>
                  NVL(new_references.payment_prd_st_date,TO_DATE('4712/12/31','YYYY/MM/DD')))
                  OR
                  (old_references.disb_date <> new_references.disb_date)
               ) THEN
                -- Disb amt (or) Disb date changed

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','Disb amt (or) Disb date has changed');
                END IF;

                IF ( (NVL(new_references.hold_rel_ind, 'FALSE') = 'TRUE') AND (lv_first_disb_seq_accepted) ) THEN
                    l_change_value := 2;

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','Both DRI and lv_first_disb_seq_accepted are TRUE');
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','Marking l_change_value= ' ||l_change_value);
                    END IF;
                ELSE
                    l_change_value := 1;

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','DRI or lv_first_disb_seq_accepted is FALSE');
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','Marking l_change_value= ' ||l_change_value);
                    END IF;
                END IF;
            END IF;   -- <<Disb amt (or) Disb date changed>>
          END IF;     -- <<DRI changed from FALSE to TRUE>>
        END IF;       -- <<l_cod_year_flag>>

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','l_change_value= ' ||l_change_value);
        END IF;
        -- museshad (Bug 4930323)

        IF (l_change_value = 1) THEN

          -- Update IGF_AW_DB_CHG_DTLS record with disb_Seq_no = 1 with disb_status = G and other details from the record in igf_aw_awd_disb_all

          -- Update the record, IGF_AW_DB_CHG_DTLS
          igf_aw_db_chg_dtls_pkg.update_row (
            x_rowid                 => upd_db_chg_dtls_rec.ROWID,
            x_award_id              => upd_db_chg_dtls_rec.award_id,
            x_disb_num              => upd_db_chg_dtls_rec.disb_num,
            x_disb_seq_num          => upd_db_chg_dtls_rec.disb_seq_num,
            x_disb_accepted_amt     => new_references.disb_accepted_amt,
            x_orig_fee_amt          => new_references.fee_1,
            x_disb_net_amt          => new_references.disb_net_amt,
            x_disb_date             => new_references.disb_date,
            x_disb_activity         => upd_db_chg_dtls_rec.disb_activity,
            x_disb_status           => 'G',
            x_disb_status_date      => TRUNC(SYSDATE),
            x_disb_rel_flag         => NVL(new_references.hold_rel_ind, 'FALSE'),
            x_first_disb_flag       => l_first_disb_flag,
            x_interest_rebate_amt   => new_references.int_rebate_amt,
            x_disb_conf_flag        => new_references.affirm_flag,
            x_pymnt_prd_start_date  => new_references.payment_prd_st_date,
            x_note_message          => upd_db_chg_dtls_rec.note_message,
            x_batch_id_txt          => upd_db_chg_dtls_rec.batch_id_txt,
            x_ack_date              => upd_db_chg_dtls_rec.ack_date,
            x_booking_id_txt        => upd_db_chg_dtls_rec.booking_id_txt,
            x_booking_date          => upd_db_chg_dtls_rec.booking_date,
            x_mode                  => 'R'
          );
          IF l_loan_type = 'DL' THEN
            l_dl_disb_change_status := TRUE;
          END IF;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',' after update of change rec disb status chg true 1 ' );
          END IF;

        ELSIF (l_change_value = 2) THEN

          -- For Disbursement Gross Amount Change
          IF (old_references.disb_accepted_amt <> new_references.disb_accepted_amt OR
              NVL(old_references.fee_1,-1) <> NVL(new_references.fee_1,-1) OR
              old_references.disb_net_amt <> new_references.disb_net_amt OR
              NVL(old_references.hold_rel_ind, 'FALSE') <> NVL(new_references.hold_rel_ind, 'FALSE') OR
              NVL(old_references.affirm_flag,' ') <> NVL(new_references.affirm_flag,' ') OR
              NVL(old_references.payment_prd_st_date,TO_DATE('4712/12/31','YYYY/MM/DD')) <>
              NVL(new_references.payment_prd_st_date,TO_DATE('4712/12/31','YYYY/MM/DD'))) THEN

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','Disb amount change');
            END IF;

            -- Get latest AMOUNT record to be updated.
            OPEN cur_latest_DateAmt_for_update(new_references.award_id, new_references.disb_num, 'A');
            FETCH cur_latest_DateAmt_for_update INTO latest_update_rec;
            CLOSE cur_latest_DateAmt_for_update;

            -- Get latest Accepted DATE record.
            OPEN cur_latest_accepted_DateAmt(new_references.award_id, new_references.disb_num, 'Q');
            FETCH cur_latest_accepted_DateAmt INTO latest_accepted_DateAmount_rec;
            CLOSE cur_latest_accepted_DateAmt;

            IF latest_update_rec.award_id IS NOT NULL THEN

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,
                                'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',
                                'Updating disb sequence ' ||latest_update_rec.disb_seq_num|| ' with the new disb amount');
              END IF;

              -- Update the record
              igf_aw_db_chg_dtls_pkg.update_row (
                x_rowid                 => latest_update_rec.ROWID,
                x_award_id              => latest_update_rec.award_id,
                x_disb_num              => latest_update_rec.disb_num,
                x_disb_seq_num          => latest_update_rec.disb_seq_num,
                x_disb_accepted_amt     => new_references.disb_accepted_amt,
                x_orig_fee_amt          => new_references.fee_1,
                x_disb_net_amt          => new_references.disb_net_amt,
                x_disb_date             => latest_accepted_DateAmount_rec.disb_date,
                x_disb_activity         => 'A',
                x_disb_status           => 'G',
                x_disb_status_date      => TRUNC(SYSDATE),
                x_disb_rel_flag         => NVL(new_references.hold_rel_ind, 'FALSE'),
                x_first_disb_flag       => l_first_disb_flag,
                x_interest_rebate_amt   => new_references.int_rebate_amt,
                x_disb_conf_flag        => new_references.affirm_flag,
                x_pymnt_prd_start_date  => new_references.payment_prd_st_date,
                x_note_message          => latest_update_rec.note_message,
                x_batch_id_txt          => latest_update_rec.batch_id_txt,
                x_ack_date              => latest_update_rec.ack_date,
                x_booking_id_txt        => latest_update_rec.booking_id_txt,
                x_booking_date          => latest_update_rec.booking_date,
                x_mode                  => 'R'
              );
              IF l_loan_type = 'DL' THEN
                l_dl_disb_change_status := TRUE;
              END IF;
            ELSE
              -- Insert the new record
              OPEN max_disb_seq_num_cur (new_references.award_id, new_references.disb_num);
              FETCH max_disb_seq_num_cur INTO l_max_disb_seq_num;
              CLOSE max_disb_seq_num_cur;
              l_row_id := NULL;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,
                                'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',
                                'Inserting new disb sequence ' ||NVL(l_max_disb_seq_num,1)|| ' with the new disb amount');
              END IF;

              igf_aw_db_chg_dtls_pkg.insert_row(
                x_rowid                 => l_row_id,
                x_award_id              => new_references.award_id,
                x_disb_num              => new_references.disb_num,
                x_disb_seq_num          => NVL(l_max_disb_seq_num,1),
                x_disb_accepted_amt     => new_references.disb_accepted_amt,
                x_orig_fee_amt          => new_references.fee_1,
                x_disb_net_amt          => new_references.disb_net_amt,
                x_disb_date             => latest_accepted_DateAmount_rec.disb_date,
                x_disb_activity         => 'A',
                x_disb_status           => 'G',
                x_disb_status_date      => TRUNC(SYSDATE),
                x_disb_rel_flag         => NVL(new_references.hold_rel_ind, 'FALSE'),
                x_first_disb_flag       => l_first_disb_flag,
                x_interest_rebate_amt   => new_references.int_rebate_amt,
                x_disb_conf_flag        => new_references.affirm_flag,
                x_pymnt_prd_start_date  => new_references.payment_prd_st_date,
                x_note_message          => NULL,
                x_batch_id_txt          => NULL,
                x_ack_date              => NULL,
                x_booking_id_txt        => NULL,
                x_booking_date          => NULL,
                x_mode                  => 'R'
              );
              IF l_loan_type = 'DL' THEN
                l_dl_disb_change_status := TRUE;
              END IF;
            END IF; -- for either Update/Insert
          END IF; -- for Disbursement Amount Change

          -- For Disbursement Date Change
          IF (old_references.disb_date <> new_references.disb_date) THEN

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug','Disb date change');
            END IF;

            -- Get latest DATE record to be updated.
            OPEN cur_latest_DateAmt_for_update(new_references.award_id, new_references.disb_num, 'Q');
            FETCH cur_latest_DateAmt_for_update INTO latest_update_rec;
            CLOSE cur_latest_DateAmt_for_update;

            -- Get latest Accepted AMOUNT record.
            OPEN cur_latest_accepted_DateAmt(new_references.award_id, new_references.disb_num, 'A');
            FETCH cur_latest_accepted_DateAmt INTO latest_accepted_DateAmount_rec;
            CLOSE cur_latest_accepted_DateAmt;

            IF latest_update_rec.award_id IS NOT NULL THEN

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,
                                'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',
                                'Updating disb sequence ' ||latest_update_rec.disb_seq_num|| ' with the new disb date');
              END IF;

              -- Update the record
              igf_aw_db_chg_dtls_pkg.update_row (
                x_rowid                 => latest_update_rec.ROWID,
                x_award_id              => latest_update_rec.award_id,
                x_disb_num              => latest_update_rec.disb_num,
                x_disb_seq_num          => latest_update_rec.disb_seq_num,
                x_disb_accepted_amt     => latest_accepted_DateAmount_rec.disb_accepted_amt,
                x_orig_fee_amt          => latest_accepted_DateAmount_rec.orig_fee_amt,
                x_disb_net_amt          => latest_accepted_DateAmount_rec.disb_net_amt,
                x_disb_date             => new_references.disb_date,
                x_disb_activity         => 'Q',
                x_disb_status           => 'G',
                x_disb_status_date      => TRUNC(SYSDATE),
                x_disb_rel_flag         => NVL(new_references.hold_rel_ind, 'FALSE'),
                x_first_disb_flag       => l_first_disb_flag,
                x_interest_rebate_amt   => latest_accepted_DateAmount_rec.interest_rebate_amt,
                x_disb_conf_flag        => latest_accepted_DateAmount_rec.disb_conf_flag,
                x_pymnt_prd_start_date  => latest_accepted_DateAmount_rec.pymnt_prd_start_date,
                x_note_message          => latest_update_rec.note_message,
                x_batch_id_txt          => latest_update_rec.batch_id_txt,
                x_ack_date              => latest_update_rec.ack_date,
                x_booking_id_txt        => latest_update_rec.booking_id_txt,
                x_booking_date          => latest_update_rec.booking_date,
                x_mode                  => 'R'
              );
              IF l_loan_type = 'DL' THEN
                l_dl_disb_change_status := TRUE;
              END IF;
            ELSE
              -- Insert the new record
              OPEN max_disb_seq_num_cur (new_references.award_id, new_references.disb_num);
              FETCH max_disb_seq_num_cur INTO l_max_disb_seq_num;
              CLOSE max_disb_seq_num_cur;
              l_row_id := NULL;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,
                                'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug',
                                'Inserting new disb sequence ' ||NVL(l_max_disb_seq_num,1)|| ' with the new disb date');
              END IF;

              igf_aw_db_chg_dtls_pkg.insert_row(
                x_rowid                 => l_row_id,
                x_award_id              => new_references.award_id,
                x_disb_num              => new_references.disb_num,
                x_disb_seq_num          => NVL(l_max_disb_seq_num,1),
                x_disb_accepted_amt     => latest_accepted_DateAmount_rec.disb_accepted_amt,
                x_orig_fee_amt          => latest_accepted_DateAmount_rec.orig_fee_amt,
                x_disb_net_amt          => latest_accepted_DateAmount_rec.disb_net_amt,
                x_disb_date             => new_references.disb_date,
                x_disb_activity         => 'Q',
                x_disb_status           => 'G',
                x_disb_status_date      => TRUNC(SYSDATE),
                x_disb_rel_flag         => NVL(new_references.hold_rel_ind, 'FALSE'),
                x_first_disb_flag       => l_first_disb_flag,
                x_interest_rebate_amt   => latest_accepted_DateAmount_rec.interest_rebate_amt,
                x_disb_conf_flag        => latest_accepted_DateAmount_rec.disb_conf_flag,
                x_pymnt_prd_start_date  => latest_accepted_DateAmount_rec.pymnt_prd_start_date,
                x_note_message          => NULL,
                x_batch_id_txt          => NULL,
                x_ack_date              => NULL,
                x_booking_id_txt        => NULL,
                x_booking_date          => NULL,
                x_mode                  => 'R'
              );
              IF l_loan_type = 'DL' THEN
                l_dl_disb_change_status := TRUE;
              END IF;
            END IF; -- for either Update/Insert
          END IF; -- for Disbursement Date Change
        END IF; -- End of COD-XML year or not
      END IF; -- End of p_action

      -- If Change Details record inserted/updated with status "Ready to Send"
      -- then update loan change status or loan status. Bug #4390112
      IF l_dl_disb_change_status = TRUE THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.after_dml.debug', 'l_dl_disb_change_status = TRUE');
        END IF;

        -- Get loans record.
        OPEN  loans_cur(new_references.award_id);
        FETCH loans_cur INTO loans_rec;
        IF loans_cur%NOTFOUND THEN
          CLOSE loans_cur;
        ELSE

          -- Loan Status Codes and meanings.
          -- A -> Accepted
          -- G -> Ready to Send
          -- N -> Not Ready
          -- R -> Rejected

          IF loans_rec.loan_status = 'A' THEN
            loans_rec.loan_chg_status := 'G';
            loans_rec.loan_chg_status_date := TRUNC(SYSDATE);
          ELSIF loans_rec.loan_status IN ('N', 'R') THEN
            loans_rec.loan_status := 'G';
            loans_rec.loan_status_date := TRUNC(SYSDATE);
          END IF;
          igf_sl_loans_pkg.update_row(
              x_rowid                => loans_rec.rowid,
              x_loan_id              => loans_rec.loan_id,
              x_award_id             => loans_rec.award_id,
              x_seq_num              => loans_rec.seq_num,
              x_loan_number          => loans_rec.loan_number,
              x_loan_per_begin_date  => loans_rec.loan_per_begin_date,
              x_loan_per_end_date    => loans_rec.loan_per_end_date,
              x_loan_status          => loans_rec.loan_status,
              x_loan_status_date     => loans_rec.loan_status_date,
              x_loan_chg_status      => loans_rec.loan_chg_status,
              x_loan_chg_status_date => loans_rec.loan_chg_status_date,
              x_active               => loans_rec.active,
              x_active_date          => loans_rec.active_date,
              x_borw_detrm_code      => loans_rec.borw_detrm_code,
              x_mode                 => 'R',
              x_legacy_record_flag   => loans_rec.legacy_record_flag,
              x_external_loan_id_txt => loans_rec.external_loan_id_txt,
              x_called_from          => NULL
          );
          CLOSE loans_cur;
        END IF;
      END IF;
    END IF; -- only for DL and PELL

  END after_dml;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_tp_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_tp_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_fee_2                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_trans_type                        IN     VARCHAR2    DEFAULT NULL,
    x_elig_status                       IN     VARCHAR2    DEFAULT NULL,
    x_elig_status_date                  IN     DATE        DEFAULT NULL,
    x_affirm_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_manual_hold_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_disb_status                       IN     VARCHAR2    DEFAULT NULL,
    x_disb_status_date                  IN     DATE        DEFAULT NULL,
    x_late_disb_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_fund_dist_mthd                    IN     VARCHAR2    DEFAULT NULL,
    x_prev_reported_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_fund_release_date                 IN     DATE        DEFAULT NULL,
    x_fund_status                       IN     VARCHAR2    DEFAULT NULL,
    x_fund_status_date                  IN     DATE        DEFAULT NULL,
    x_fee_paid_1                        IN     NUMBER      DEFAULT NULL,
    x_fee_paid_2                        IN     NUMBER      DEFAULT NULL,
    x_cheque_number                     IN     VARCHAR2    DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_disb_accepted_amt                 IN     NUMBER      DEFAULT NULL,
    x_disb_paid_amt                     IN     NUMBER      DEFAULT NULL,
    x_rvsn_id                           IN     NUMBER      DEFAULT NULL,
    x_int_rebate_amt                    IN     NUMBER      DEFAULT NULL,
    x_force_disb                        IN     VARCHAR2    DEFAULT NULL,
    x_min_credit_pts                    IN     NUMBER      DEFAULT NULL,
    x_disb_exp_dt                       IN     DATE        DEFAULT NULL,
    x_verf_enfr_dt                      IN     DATE        DEFAULT NULL,
    x_fee_class                         IN     VARCHAR2    DEFAULT NULL,
    x_show_on_bill                      IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type_code              IN     VARCHAR2    DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE        DEFAULT NULL,
    x_change_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_mthd_code             IN     VARCHAR2    DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL


  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ||  bannamal        29-Sep-2004     FA 149 3416863 cod xml changes for pell and direct loan
  ||                                  addded a new column
  ||  veramach        3-NOV-2003      FA 125 Multiple Distr Methods
  ||                                  Added attendance_type_code to the signature
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_AWD_DISB_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.award_id                          := x_award_id;
    new_references.disb_num                          := x_disb_num;
    new_references.tp_cal_type                       := x_tp_cal_type;
    new_references.tp_sequence_number                := x_tp_sequence_number;
    new_references.disb_gross_amt                    := x_disb_gross_amt;
    new_references.fee_1                             := x_fee_1;
    new_references.fee_2                             := x_fee_2;
    new_references.disb_net_amt                      := x_disb_net_amt;
    new_references.disb_date                         := x_disb_date;
    new_references.trans_type                        := x_trans_type;
    new_references.elig_status                       := x_elig_status;
    new_references.elig_status_date                  := x_elig_status_date;
    new_references.affirm_flag                       := x_affirm_flag;
    new_references.hold_rel_ind                      := x_hold_rel_ind;
    new_references.manual_hold_ind                   := x_manual_hold_ind;
    new_references.disb_status                       := x_disb_status;
    new_references.disb_status_date                  := x_disb_status_date;
    new_references.late_disb_ind                     := x_late_disb_ind;
    new_references.fund_dist_mthd                    := x_fund_dist_mthd;
    new_references.prev_reported_ind                 := x_prev_reported_ind;
    new_references.fund_release_date                 := x_fund_release_date;
    new_references.fund_status                       := x_fund_status;
    new_references.fund_status_date                  := x_fund_status_date;
    new_references.fee_paid_1                        := x_fee_paid_1;
    new_references.fee_paid_2                        := x_fee_paid_2;
    new_references.cheque_number                     := x_cheque_number;
    new_references.ld_cal_type                       := x_ld_cal_type;
    new_references.ld_sequence_number                := x_ld_sequence_number;
    new_references.disb_accepted_amt                 := x_disb_accepted_amt;
    new_references.disb_paid_amt                     := x_disb_paid_amt;
    new_references.rvsn_id                           := x_rvsn_id;
    new_references.int_rebate_amt                    := x_int_rebate_amt;
    new_references.force_disb                        := x_force_disb;
    new_references.min_credit_pts                    := x_min_credit_pts;
    new_references.disb_exp_dt                       := x_disb_exp_dt;
    new_references.verf_enfr_dt                      := x_verf_enfr_dt;
    new_references.fee_class                         := x_fee_class;
    new_references.show_on_bill                      := x_show_on_bill;
    new_references.attendance_type_code              := x_attendance_type_code;
    new_references.base_attendance_type_code         := x_base_attendance_type_code;
    new_references.payment_prd_st_date               := x_payment_prd_st_date;
    new_references.change_type_code                  := x_change_type_code;
    new_references.fund_return_mthd_code             := x_fund_return_mthd_code;
    new_references.direct_to_borr_flag               := x_direct_to_borr_flag;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;

PROCEDURE BeforeRowInsertUpdateDelete1(
  p_rowid     IN VARCHAR2,
  p_inserting IN BOOLEAN ,
  p_updating  IN BOOLEAN ,
  p_deleting  IN BOOLEAN
) AS
  /*-----------------------------------------------------------------
 ||  Created By : Sanil Madathil
 ||  Created On : 24-Nov-2004
 ||  Purpose :
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  (reverse chronological order - newest change first)
 --------------------------------------------------------------------*/
  CURSOR  c_aw_awd_disb (cp_rowid ROWID) IS
  SELECT  award_id
         ,disb_num
  FROM    igf_aw_awd_disb
  WHERE   row_id = cp_rowid;

  CURSOR  c_igf_sl_lorlar(cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
  SELECT  lar.loan_number
         ,lar.loan_status
         ,lor.prc_type_code
         ,lor.cl_rec_status
  FROM    igf_sl_lor_all lor
         ,igf_sl_loans_all lar
  WHERE  lor.loan_id  = lar.loan_id
  AND    lar.award_id = cp_n_award_id;

   rec_c_igf_sl_lorlar c_igf_sl_lorlar%ROWTYPE;

   CURSOR c_sl_clchsn_dtls (
     cp_v_loan_number igf_sl_loans_all.loan_number%TYPE,
     cp_new_disb_num  igf_aw_awd_disb_all.disb_num%TYPE
   ) IS
   SELECT chdt.ROWID row_id,chdt.*
   FROM   igf_sl_clchsn_dtls chdt
   WHERE  chdt.loan_number_txt = cp_v_loan_number
   AND    chdt.disbursement_number = cp_new_disb_num
   AND    chdt.status_code IN ('R','N','D')
   AND    chdt.change_field_code       = 'DISB_NUM'
   AND    chdt.change_code_txt         = 'D'
   AND    chdt.change_record_type_txt  = '09';

   rec_c_sl_clchsn_dtls c_sl_clchsn_dtls%ROWTYPE;

   l_v_fed_fund_code  igf_aw_fund_cat_all.fed_fund_code%TYPE;
   l_v_message_name   fnd_new_messages.message_name%TYPE;
   l_b_return_status  BOOLEAN;
   l_n_award_id       igf_aw_award_all.award_id%TYPE;
   l_n_disb_num       igf_aw_awd_disb_all.disb_num%TYPE;
   l_v_loan_number    igf_sl_loans_all.loan_number%TYPE;
   l_n_cl_version     igf_sl_cl_setup_all.cl_version%TYPE;
   l_c_cl_rec_status  igf_sl_lor_all.cl_rec_status%TYPE;
   l_v_prc_type_code  igf_sl_lor_all.prc_type_code%TYPE;
   l_v_loan_status    igf_sl_loans_all.loan_status%TYPE;
BEGIN
  IF p_deleting THEN
    OPEN  c_aw_awd_disb (cp_rowid => p_rowid);
    FETCH c_aw_awd_disb INTO l_n_award_id,l_n_disb_num;
    CLOSE c_aw_awd_disb ;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'Action = delete ' );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'inside BeforeRowInsertUpdateDelete1 ' );
    END IF;
    l_v_fed_fund_code := igf_sl_gen.get_fed_fund_code (p_n_award_id     => l_n_award_id,
                                                       p_v_message_name => l_v_message_name
                                                       );
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'l_v_fed_fund_code : '||l_v_fed_fund_code );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'g_v_called_from   : '||g_v_called_from );
    END IF;
    IF l_v_message_name IS NOT NULL THEN
      fnd_message.set_name ('IGS',l_v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    IF g_v_called_from NOT IN ('IGFSL27B','IGFAW038') THEN
      RETURN;
    END IF;
    IF l_v_fed_fund_code NOT IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
      RETURN;
    END IF;
    -- get the processing type code, loan record status, loan status and loan number for the input award id
    OPEN   c_igf_sl_lorlar (cp_n_award_id => l_n_award_id);
    FETCH  c_igf_sl_lorlar INTO rec_c_igf_sl_lorlar;
    CLOSE  c_igf_sl_lorlar;

    l_v_loan_number   := rec_c_igf_sl_lorlar.loan_number;
    l_v_loan_status   := rec_c_igf_sl_lorlar.loan_status;
    l_v_prc_type_code := rec_c_igf_sl_lorlar.prc_type_code;
    l_c_cl_rec_status := rec_c_igf_sl_lorlar.cl_rec_status;
    -- get the loan version for the input award id
    l_n_cl_version  := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);
    -- Change Record would be created only if
    -- The version = CommonLine Release 4 Version Loan,
    -- Loan Status = Accepted
    -- Loan Record Status is Guaranteed or Accepted
    -- Processing Type Code is GP or GO
    -- information is different from the latest guaranteed response for the loan
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'l_n_cl_version    : '||l_n_cl_version );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'l_v_loan_status   : '||l_v_loan_status );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'l_v_prc_type_code : '||l_v_prc_type_code );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'l_c_cl_rec_status : '||l_c_cl_rec_status );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', 'l_n_disb_num      : '||l_n_disb_num );
    END IF;
    IF (l_n_cl_version = 'RELEASE-4' AND
        l_v_loan_status = 'A' AND
        l_v_prc_type_code IN ('GO','GP') AND
        l_c_cl_rec_status IN ('B','G'))
    THEN
      OPEN c_sl_clchsn_dtls (
        cp_v_loan_number => l_v_loan_number,
        cp_new_disb_num  => l_n_disb_num
      );
      FETCH c_sl_clchsn_dtls INTO rec_c_sl_clchsn_dtls;
      IF c_sl_clchsn_dtls%FOUND THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', ' Change record to be deleted  ');
        END IF;
        igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  rec_c_sl_clchsn_dtls.row_id);
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.BeforeRowInsertUpdateDelete1 ', ' Change record deleted successfully ');
        END IF;
      END IF;
      CLOSE c_sl_clchsn_dtls;
    END IF;
  END IF;
END BeforeRowInsertUpdateDelete1;

PROCEDURE AfterRowInsertUpdateDelete1(
   p_inserting IN BOOLEAN ,
   p_updating  IN BOOLEAN ,
   p_deleting  IN BOOLEAN
   ) AS
  /*-----------------------------------------------------------------
 ||  Created By : Sanil Madathil
 ||  Created On : 13-Oct-2004
 ||  Purpose :
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  (reverse chronological order - newest change first)
 --------------------------------------------------------------------*/
  CURSOR  c_igf_sl_lorlar(cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
  SELECT  lar.loan_number
         ,lar.loan_status
         ,lor.prc_type_code
         ,lor.cl_rec_status
  FROM    igf_sl_lor_all lor
         ,igf_sl_loans_all lar
  WHERE  lor.loan_id  = lar.loan_id
  AND    lar.award_id = cp_n_award_id;

  rec_c_igf_sl_lorlar c_igf_sl_lorlar%ROWTYPE;

  l_v_fed_fund_code  igf_aw_fund_cat_all.fed_fund_code%TYPE;
  l_v_message_name   fnd_new_messages.message_name%TYPE;
  l_b_return_status  BOOLEAN;
  l_n_clchgsnd_id    igf_sl_clchsn_dtls.clchgsnd_id%TYPE;
  l_v_rowid          ROWID;
  l_n_award_id       igf_aw_award_all.award_id%TYPE;
  l_v_loan_number    igf_sl_loans_all.loan_number%TYPE;
  l_n_cl_version     igf_sl_cl_setup_all.cl_version%TYPE;
  l_c_cl_rec_status  igf_sl_lor_all.cl_rec_status%TYPE;
  l_v_prc_type_code  igf_sl_lor_all.prc_type_code%TYPE;
  l_v_loan_status    igf_sl_loans_all.loan_status%TYPE;

  CURSOR c_sl_clchsn_dtls (
    cp_v_loan_number igf_sl_loans_all.loan_number%TYPE,
    cp_new_disb_num  igf_aw_awd_disb_all.disb_num%TYPE
  ) IS
  SELECT chdt.ROWID row_id,chdt.*
  FROM   igf_sl_clchsn_dtls chdt
  WHERE  chdt.loan_number_txt = cp_v_loan_number
  AND    chdt.disbursement_number = cp_new_disb_num
  AND    chdt.status_code IN ('R','N','D')
  AND    chdt.change_field_code       = 'DISB_NUM'
  AND    chdt.change_code_txt         = 'D'
  AND    chdt.change_record_type_txt  = '09';

  rec_c_sl_clchsn_dtls c_sl_clchsn_dtls%ROWTYPE;

  l_d_message_tokens        igf_sl_cl_chg_prc.token_tab%TYPE;

BEGIN
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'inside AfterRowInsertUpdateDelete1 ' );
  END IF;
  l_v_fed_fund_code := igf_sl_gen.get_fed_fund_code (p_n_award_id     => new_references.award_id,
                                                     p_v_message_name => l_v_message_name
                                                     );
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' fund code   = '||l_v_fed_fund_code );
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' called from = '||g_v_called_from );
  END IF;
  IF l_v_message_name IS NOT NULL THEN
    fnd_message.set_name ('IGS',l_v_message_name);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END IF;
  IF g_v_called_from NOT IN ('IGFSL27B','IGFAW038','IGFAW016') THEN
    RETURN;
  END IF;
  IF l_v_fed_fund_code NOT IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
    RETURN;
  END IF;
  IF p_updating THEN
    IF ((new_references.disb_date <> old_references.disb_date) OR
        (new_references.disb_accepted_amT <> old_references.disb_accepted_amt) OR
        (NVL(new_references.hold_rel_ind, 'FALSE') <> NVL(old_references.hold_rel_ind, 'FALSE')) OR
        (NVL(new_references.change_type_code, '*') <> NVL(old_references.change_type_code, '*'))
       ) THEN
       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'invoking igf_sl_cl_create_chg.create_disb_chg_rec. ' );
       END IF;
      -- invoke the procedure to create loan cancellation change record in igf_sl_clchsn_dtls table
      igf_sl_cl_create_chg.create_disb_chg_rec(
        p_new_disb_rec    => new_references,
        p_old_disb_rec    => old_references,
        p_b_return_status => l_b_return_status,
        p_v_message_name  => l_v_message_name
      );
      -- if the above call out returns false and error message is returned,
      -- add the message to the error stack and error message test should be displayed
      -- in the calling form
      IF (NOT (l_b_return_status) AND l_v_message_name IS NOT NULL )THEN
      -- substring of the out bound parameter l_v_message_name is carried
      -- out since it can expect either IGS OR IGF message
        fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
        igf_sl_cl_chg_prc.parse_tokens(
          p_t_message_tokens => igf_sl_cl_chg_prc.g_message_tokens);
/*
        FOR token_counter IN igf_sl_cl_chg_prc.g_message_tokens.FIRST..igf_sl_cl_chg_prc.g_message_tokens.LAST LOOP
           fnd_message.set_token(igf_sl_cl_chg_prc.g_message_tokens(token_counter).token_name, igf_sl_cl_chg_prc.g_message_tokens(token_counter).token_value);
        END LOOP;
*/
        igs_ge_msg_stack.add;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'Call to igf_sl_cl_create_chg.create_disb_chg_rec returned error '|| l_v_message_name);
        END IF;
        app_exception.raise_exception;
      END IF;
    END IF;
    l_n_award_id := new_references.award_id;
    -- get the processing type code, loan record status, loan status and loan number for the input award id
    OPEN   c_igf_sl_lorlar (cp_n_award_id => l_n_award_id);
    FETCH  c_igf_sl_lorlar INTO rec_c_igf_sl_lorlar;
    CLOSE  c_igf_sl_lorlar;

    l_v_loan_number   := rec_c_igf_sl_lorlar.loan_number;
    l_v_loan_status   := rec_c_igf_sl_lorlar.loan_status;
    l_v_prc_type_code := rec_c_igf_sl_lorlar.prc_type_code;
    l_c_cl_rec_status := rec_c_igf_sl_lorlar.cl_rec_status;
    -- get the loan version for the input award id
    l_n_cl_version  := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);
    -- Change Record would be created only if
    -- The version = CommonLine Release 4 Version Loan,
    -- Loan Status = Accepted
    -- Loan Record Status is Guaranteed or Accepted
    -- Processing Type Code is GP or GO
    -- information is different from the latest guaranteed response for the loan
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'l_n_cl_version    : '||l_n_cl_version );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'l_v_loan_status   : '||l_v_loan_status );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'l_v_prc_type_code : '||l_v_prc_type_code );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'l_c_cl_rec_status : '||l_c_cl_rec_status );
    END IF;
    IF (l_n_cl_version = 'RELEASE-4' AND
        l_v_loan_status = 'A' AND
        l_v_prc_type_code IN ('GO','GP') AND
        l_c_cl_rec_status IN ('B','G')) THEN
      OPEN c_sl_clchsn_dtls (
        cp_v_loan_number => l_v_loan_number,
        cp_new_disb_num  => new_references.disb_num
      );
      FETCH c_sl_clchsn_dtls INTO rec_c_sl_clchsn_dtls;
      IF c_sl_clchsn_dtls%FOUND THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'invoking igf_sl_clchsn_dtls_pkg.update_row to update @9 record of change_code_txt = D ');
        END IF;
        igf_sl_clchsn_dtls_pkg.update_row (
          x_rowid                      => rec_c_sl_clchsn_dtls.row_id,
          x_clchgsnd_id                => rec_c_sl_clchsn_dtls.clchgsnd_id                ,
          x_award_id                   => rec_c_sl_clchsn_dtls.award_id                   ,
          x_loan_number_txt            => rec_c_sl_clchsn_dtls.loan_number_txt            ,
          x_cl_version_code            => rec_c_sl_clchsn_dtls.cl_version_code            ,
          x_change_field_code          => rec_c_sl_clchsn_dtls.change_field_code          ,
          x_change_record_type_txt     => rec_c_sl_clchsn_dtls.change_record_type_txt     ,
          x_change_code_txt            => rec_c_sl_clchsn_dtls.change_code_txt            ,
          x_status_code                => 'R'                                             ,
          x_status_date                => rec_c_sl_clchsn_dtls.status_date                ,
          x_response_status_code       => rec_c_sl_clchsn_dtls.response_status_code       ,
          x_old_value_txt              => rec_c_sl_clchsn_dtls.old_value_txt              ,
          x_new_value_txt              => new_references.hold_rel_ind                     ,
          x_old_date                   => rec_c_sl_clchsn_dtls.old_date                   ,
          x_new_date                   => new_references.disb_date                        ,
          x_old_amt                    => rec_c_sl_clchsn_dtls.old_amt                    ,
          x_new_amt                    => new_references.disb_accepted_amt                ,
          x_disbursement_number        => rec_c_sl_clchsn_dtls.disbursement_number        ,
          x_disbursement_date          => rec_c_sl_clchsn_dtls.disbursement_date          ,
          x_change_issue_code          => rec_c_sl_clchsn_dtls.change_issue_code          ,
          x_disbursement_cancel_date   => rec_c_sl_clchsn_dtls.disbursement_cancel_date   ,
          x_disbursement_cancel_amt    => rec_c_sl_clchsn_dtls.disbursement_cancel_amt    ,
          x_disbursement_revised_amt   => rec_c_sl_clchsn_dtls.disbursement_revised_amt   ,
          x_disbursement_revised_date  => rec_c_sl_clchsn_dtls.disbursement_revised_date  ,
          x_disbursement_reissue_code  => rec_c_sl_clchsn_dtls.disbursement_reissue_code  ,
          x_disbursement_reinst_code   => rec_c_sl_clchsn_dtls.disbursement_reinst_code   ,
          x_disbursement_return_amt    => rec_c_sl_clchsn_dtls.disbursement_return_amt    ,
          x_disbursement_return_date   => rec_c_sl_clchsn_dtls.disbursement_return_date   ,
          x_disbursement_return_code   => rec_c_sl_clchsn_dtls.disbursement_return_code   ,
          x_post_with_disb_return_amt  => rec_c_sl_clchsn_dtls.post_with_disb_return_amt  ,
          x_post_with_disb_return_date => rec_c_sl_clchsn_dtls.post_with_disb_return_date ,
          x_post_with_disb_return_code => rec_c_sl_clchsn_dtls.post_with_disb_return_code ,
          x_prev_with_disb_return_amt  => rec_c_sl_clchsn_dtls.prev_with_disb_return_amt  ,
          x_prev_with_disb_return_date => rec_c_sl_clchsn_dtls.prev_with_disb_return_date ,
          x_school_use_txt             => rec_c_sl_clchsn_dtls.school_use_txt             ,
          x_lender_use_txt             => rec_c_sl_clchsn_dtls.lender_use_txt             ,
          x_guarantor_use_txt          => rec_c_sl_clchsn_dtls.guarantor_use_txt          ,
          x_validation_edit_txt        => NULL                                                ,
          x_send_record_txt            => rec_c_sl_clchsn_dtls.send_record_txt
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' validating the Change record for Change send id: '  ||rec_c_sl_clchsn_dtls.clchgsnd_id);
        END IF;
        igf_sl_cl_chg_prc.validate_chg (
          p_n_clchgsnd_id    => rec_c_sl_clchsn_dtls.clchgsnd_id,
          p_b_return_status  => l_b_return_status,
          p_v_message_name   => l_v_message_name,
          p_t_message_tokens => l_d_message_tokens
        );
        IF NOT(l_b_return_status) THEN
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' validation of the Change record failed for Change send id: '  ||rec_c_sl_clchsn_dtls.clchgsnd_id);
          END IF;
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
          igf_sl_cl_chg_prc.parse_tokens(
            p_t_message_tokens => l_d_message_tokens);
/*
          FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
             fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
          END LOOP;
*/
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send ');
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' Change send id: '  ||rec_c_sl_clchsn_dtls.clchgsnd_id);
          END IF;
          igf_sl_clchsn_dtls_pkg.update_row (
            x_rowid                      => rec_c_sl_clchsn_dtls.row_id,
            x_clchgsnd_id                => rec_c_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'N'                                             ,
            x_status_date                => rec_c_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => new_references.hold_rel_ind                     ,
            x_old_date                   => rec_c_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => new_references.disb_date                        ,
            x_old_amt                    => rec_c_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => new_references.disb_accepted_amt                ,
            x_disbursement_number        => rec_c_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => fnd_message.get                                 ,
            x_send_record_txt            => rec_c_sl_clchsn_dtls.send_record_txt
          );
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' updated the status to Not Ready to Send for Change send id: '  ||rec_c_sl_clchsn_dtls.clchgsnd_id);
          END IF;
        END IF;
      END IF;
      CLOSE c_sl_clchsn_dtls;
    END IF;
  ELSIF p_inserting THEN
    l_n_award_id := new_references.award_id;
    -- get the processing type code, loan record status, loan status and loan number for the input award id
    OPEN   c_igf_sl_lorlar (cp_n_award_id => l_n_award_id);
    FETCH  c_igf_sl_lorlar INTO rec_c_igf_sl_lorlar;
    CLOSE  c_igf_sl_lorlar;
    l_v_loan_number   := rec_c_igf_sl_lorlar.loan_number;
    l_v_loan_status   := rec_c_igf_sl_lorlar.loan_status;
    l_v_prc_type_code := rec_c_igf_sl_lorlar.prc_type_code;
    l_c_cl_rec_status := rec_c_igf_sl_lorlar.cl_rec_status;
    -- get the loan version for the input award id
    l_n_cl_version  := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);
    -- Change Record would be created only if
    -- The version = CommonLine Release 4 Version Loan,
    -- Loan Status = Accepted
    -- Loan Record Status is Guaranteed or Accepted
    -- Processing Type Code is GP or GO
    -- information is different from the latest guaranteed response for the loan
    IF (l_n_cl_version = 'RELEASE-4' AND
        l_v_loan_status = 'A' AND
        l_v_prc_type_code IN ('GO','GP') AND
        l_c_cl_rec_status IN ('B','G')) THEN
      l_v_rowid       := NULL;
      l_n_clchgsnd_id := NULL;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'invoking igf_sl_clchsn_dtls_pkg.insert_row to insert @9 record of change_code_txt = D ');
      END IF;
      igf_sl_clchsn_dtls_pkg.insert_row (
        x_rowid                      => l_v_rowid                ,
        x_clchgsnd_id                => l_n_clchgsnd_id          ,
        x_award_id                   => l_n_award_id             ,
        x_loan_number_txt            => l_v_loan_number          ,
        x_cl_version_code            => l_n_cl_version           ,
        x_change_field_code          => 'DISB_NUM'               ,
        x_change_record_type_txt     => '09'                     ,
        x_change_code_txt            => 'D'                      ,
        x_status_code                => 'R'                      ,
        x_status_date                => TRUNC(SYSDATE)           ,
        x_response_status_code       => NULL                     ,
        x_old_value_txt              => new_references.hold_rel_ind     ,
        x_new_value_txt              => new_references.hold_rel_ind     ,
        x_old_date                   => new_references.disb_date        ,
        x_new_date                   => new_references.disb_date        ,
        x_old_amt                    => 0,
        x_new_amt                    => new_references.disb_accepted_amt,
        x_disbursement_number        => new_references.disb_num  ,
        x_disbursement_date          => new_references.disb_date ,
        x_change_issue_code          => 'PRE_DISB'               ,
        x_disbursement_cancel_date   => NULL                     ,
        x_disbursement_cancel_amt    => NULL                     ,
        x_disbursement_revised_amt   => NULL                     ,
        x_disbursement_revised_date  => NULL                     ,
        x_disbursement_reissue_code  => NULL                     ,
        x_disbursement_reinst_code   => 'N'                      ,
        x_disbursement_return_amt    => NULL                     ,
        x_disbursement_return_date   => NULL                     ,
        x_disbursement_return_code   => NULL                     ,
        x_post_with_disb_return_amt  => NULL                     ,
        x_post_with_disb_return_date => NULL                     ,
        x_post_with_disb_return_code => NULL                     ,
        x_prev_with_disb_return_amt  => NULL                     ,
        x_prev_with_disb_return_date => NULL                     ,
        x_school_use_txt             => NULL                     ,
        x_lender_use_txt             => NULL                     ,
        x_guarantor_use_txt          => NULL                     ,
        x_validation_edit_txt        => NULL                     ,
        x_send_record_txt            => NULL
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', 'Inserted @9 record of change_code_txt = D ');
      END IF;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id);
        END IF;
        igf_sl_cl_chg_prc.validate_chg (
          p_n_clchgsnd_id    => l_n_clchgsnd_id,
          p_b_return_status  => l_b_return_status,
          p_v_message_name   => l_v_message_name,
          p_t_message_tokens => l_d_message_tokens
        );
      IF NOT(l_b_return_status) THEN
        fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
        igf_sl_cl_chg_prc.parse_tokens(
          p_t_message_tokens => l_d_message_tokens);
/*
        FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
           fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
        END LOOP;
*/
        igs_ge_msg_stack.add;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.AfterRowInsertUpdateDelete1 ', ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id);
        END IF;
        app_exception.raise_exception;
      END IF;
    END IF;
  END IF;
 END AfterRowInsertUpdateDelete1;


  PROCEDURE check_constraints (
    column_name    IN     VARCHAR2    DEFAULT NULL,
    column_value   IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'TRANS_TYPE') THEN
      new_references.trans_type := column_value;
    ELSIF (UPPER(column_name) = 'ELIG_STATUS') THEN
      new_references.elig_status := column_value;
    ELSIF (UPPER(column_name) = 'AFFIRM_FLAG') THEN
      new_references.affirm_flag := column_value;
    ELSIF (UPPER(column_name) = 'HOLD_REL_IND') THEN
      new_references.hold_rel_ind := column_value;
    ELSIF (UPPER(column_name) = 'MANUAL_HOLD_IND') THEN
      new_references.manual_hold_ind := column_value;
    ELSIF (UPPER(column_name) = 'LATE_DISB_IND') THEN
      new_references.late_disb_ind := column_value;
    ELSIF (UPPER(column_name) = 'FUND_DIST_MTHD') THEN
      new_references.fund_dist_mthd := column_value;
    ELSIF (UPPER(column_name) = 'PREV_REPORTED_IND') THEN
      new_references.prev_reported_ind := column_value;
    ELSIF (UPPER(column_name) = 'FUND_STATUS') THEN
      new_references.fund_status := column_value;
    ELSIF (UPPER(column_name) = 'DIRECT_TO_BORR_FLAG') THEN
      new_references.direct_to_borr_flag := column_value;
    END IF;

    IF (UPPER(column_name) = 'TRANS_TYPE' OR column_name IS NULL) THEN
      IF igf_aw_gen.lookup_desc('IGF_DB_TRANS_TYPE',new_references.trans_type) IS NULL THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.trans_type || ' for TRANS_TYPE is invalid ');
        END IF;
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'ELIG_STATUS' OR column_name IS NULL) THEN
      IF new_references.elig_status IS NOT NULL THEN
           IF igf_aw_gen.lookup_desc('IGF_DB_ELIG_STATUS',new_references.elig_status) IS NULL THEN

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.elig_status || ' for ELIG_STAUS is invalid');
             END IF;
             fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
           END IF;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'AFFIRM_FLAG' OR column_name IS NULL) THEN
      IF new_references.affirm_flag IS NOT NULL THEN
           IF igf_aw_gen.lookup_desc('IGF_AP_YES_NO',new_references.affirm_flag) IS NULL THEN
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.affirm_flag || ' for AFFIRM_FLAG is invalid ');
             END IF;
             fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
           END IF;
      END IF;
    END IF;

    --
    -- Bug 2983181
    --
    IF (UPPER(column_name) = 'HOLD_REL_IND' OR column_name IS NULL) THEN
      IF new_references.hold_rel_ind IS NOT NULL THEN
           IF igf_aw_gen.lookup_desc('IGF_SL_CL_HOLD_REL_IND_TF',new_references.hold_rel_ind) IS NULL THEN
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.hold_rel_ind || ' for HOLD_REL_IND is invalid ');
             END IF;
             fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
           END IF;
       END IF;
    END IF;

    IF (UPPER(column_name) = 'FUND_DIST_MTHD' OR column_name IS NULL) THEN
      IF new_references.fund_dist_mthd IS NOT NULL THEN
           IF igf_aw_gen.lookup_desc('IGF_SL_CL_DB_FUND_DISB_METH',new_references.fund_dist_mthd) IS NULL THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.fund_dist_mthd || ' for FUND_DIST_MTHD is invalid ');
              END IF;
              fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
           END IF;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'PREV_REPORTED_IND' OR column_name IS NULL) THEN
      IF new_references.prev_reported_ind IS NOT NULL THEN
           IF igf_aw_gen.lookup_desc('IGF_AP_YES_NO',new_references.prev_reported_ind) IS NULL THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.prev_reported_ind || ' for PREV_REPORTED_IND is invalid ');
              END IF;
              fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
           END IF;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'FUND_STATUS' OR column_name IS NULL) THEN
      IF new_references.fund_status IS NOT NULL THEN
           IF igf_aw_gen.lookup_desc('IGF_SL_CL_DB_FUND_STATUS',new_references.fund_status) IS NULL THEN
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.fund_status || ' for FUND_STATUS is invalid ');
             END IF;
             fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
           END IF;
      END IF;
    END IF;

    -- Added a value of 'Y' w.r to Disbursement and Sponsership Build
    -- Bug 2154941.
    -- This is required as IGF_DB_DISB_HOLDS_PKG calls this Table Handler
    -- for Update Row.
    IF (UPPER(column_name) = 'MANUAL_HOLD_IND' OR column_name IS NULL) THEN
      IF NOT (new_references.manual_hold_ind IN ('N','Y'))  THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.manual_hold_ind || ' for MANUAL_HOLD_IND is invalid ');
         END IF;
         fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'LATE_DISB_IND' OR column_name IS NULL) THEN
      IF NOT (new_references.late_disb_ind IN ('Y', 'N'))  THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.late_disb_ind || ' for LATE_DISB_IND is invalid ');
        END IF;
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'DIRECT_TO_BORR_FLAG' OR column_name IS NULL) THEN
      IF NOT (new_references.direct_to_borr_flag IN ('Y', 'N'))  THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_awd_disb_pkg.check_constraints.debug','TBH: Check Constraints Fail: Value ' || new_references.direct_to_borr_flag || ' for DIRECT_TO_BORR_FLAG is invalid ');
        END IF;
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.award_id = new_references.award_id)) OR
        ((new_references.award_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_award_pkg.get_pk_for_validation (
                new_references.award_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

     IF (((old_references.rvsn_id = new_references.rvsn_id)) OR
        ((new_references.rvsn_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_rvsn_rsn_pkg.get_pk_for_validation (
                new_references.rvsn_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.tp_cal_type = new_references.tp_cal_type) AND
         (old_references.tp_sequence_number = new_references.tp_sequence_number)) OR
        ((new_references.tp_cal_type IS NULL) OR
         (new_references.tp_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.tp_cal_type,
                new_references.tp_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.ld_cal_type = new_references.ld_cal_type) AND
         (old_references.ld_sequence_number = new_references.ld_sequence_number)) OR
        ((new_references.ld_cal_type IS NULL) OR
         (new_references.ld_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.ld_cal_type,
                new_references.ld_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


  END check_parent_existance;

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Bug Id : 2154941
  ||  Disbursement and Sponsership Build Jul 2002 (CCR004)
  ||  Who             When            What
  ||  vchappid       10-Apr-2002      Enh# 2293676, New Child Table(IGS_FI_BILL_PLN_CRD) added
  ||  mesriniv       08-JAN-2002       To check for child Hold Records
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_db_disb_holds_pkg.get_fk_igf_aw_awd_disb(
       old_references.award_id,
       old_references.disb_num
       );

    igf_db_awd_disb_dtl_pkg.get_fk_igf_aw_awd_disb(
       old_references.award_id,
       old_references.disb_num );

    igs_fi_bill_pln_crd_pkg.get_fk_igf_aw_awd_disb (
       old_references.award_id,
       old_references.disb_num );

    igf_aw_db_chg_dtls_pkg.get_fk_igf_aw_awd_disb(
       old_references.award_id,
       old_references.disb_num);

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_disb_all
      WHERE    award_id = x_award_id
      AND      disb_num = x_disb_num
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_disb_all
      WHERE   ((award_id = x_award_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_ADISB_AWD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_award;

  PROCEDURE get_fk_igf_aw_awd_rvsn_rsn (
    x_rvsn_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_disb_all
      WHERE   ((rvsn_id = x_rvsn_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_ADISB_RVSN_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_rvsn_rsn;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_disb_all
      WHERE   ((tp_cal_type = x_cal_type) AND
               (tp_sequence_number = x_sequence_number))
      OR      ((ld_cal_type = x_cal_type) AND
               (ld_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_ADISB_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

  PROCEDURE get_fk_igs_lookups_view (
    x_fee_class                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_disb_all
      WHERE    fee_class = x_fee_class;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_ADISB_LKUP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_lookups_view;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_tp_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_tp_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_fee_2                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_trans_type                        IN     VARCHAR2    DEFAULT NULL,
    x_elig_status                       IN     VARCHAR2    DEFAULT NULL,
    x_elig_status_date                  IN     DATE        DEFAULT NULL,
    x_affirm_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_manual_hold_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_disb_status                       IN     VARCHAR2    DEFAULT NULL,
    x_disb_status_date                  IN     DATE        DEFAULT NULL,
    x_late_disb_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_fund_dist_mthd                    IN     VARCHAR2    DEFAULT NULL,
    x_prev_reported_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_fund_release_date                 IN     DATE        DEFAULT NULL,
    x_fund_status                       IN     VARCHAR2    DEFAULT NULL,
    x_fund_status_date                  IN     DATE        DEFAULT NULL,
    x_fee_paid_1                        IN     NUMBER      DEFAULT NULL,
    x_fee_paid_2                        IN     NUMBER      DEFAULT NULL,
    x_cheque_number                     IN     VARCHAR2    DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_disb_accepted_amt                 IN     NUMBER      DEFAULT NULL,
    x_disb_paid_amt                     IN     NUMBER      DEFAULT NULL,
    x_rvsn_id                           IN     NUMBER      DEFAULT NULL,
    x_int_rebate_amt                    IN     NUMBER      DEFAULT NULL,
    x_force_disb                        IN     VARCHAR2    DEFAULT NULL,
    x_min_credit_pts                    IN     NUMBER      DEFAULT NULL,
    x_disb_exp_dt                       IN     DATE        DEFAULT NULL,
    x_verf_enfr_dt                      IN     DATE        DEFAULT NULL,
    x_fee_class                         IN     VARCHAR2    DEFAULT NULL,
    x_show_on_bill                      IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type_code              IN     VARCHAR2    DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE        DEFAULT NULL,
    x_change_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_mthd_code             IN     VARCHAR2    DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bannamal        29-Sep-2004     FA 149 3416863 cod xml changes for pell and direct loan
  ||                                  addded a new column
  ||  veramach        3-NOV-2003      FA 125 Multiple Distr Methods
  ||                                  Added attendance_type_code to the signature
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_award_id,
      x_disb_num,
      x_tp_cal_type,
      x_tp_sequence_number,
      x_disb_gross_amt,
      x_fee_1,
      x_fee_2,
      x_disb_net_amt,
      x_disb_date,
      x_trans_type,
      x_elig_status,
      x_elig_status_date,
      x_affirm_flag,
      x_hold_rel_ind,
      x_manual_hold_ind,
      x_disb_status,
      x_disb_status_date,
      x_late_disb_ind,
      x_fund_dist_mthd,
      x_prev_reported_ind,
      x_fund_release_date,
      x_fund_status,
      x_fund_status_date,
      x_fee_paid_1,
      x_fee_paid_2,
      x_cheque_number,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_disb_accepted_amt,
      x_disb_paid_amt,
      x_rvsn_id,
      x_int_rebate_amt,
      x_force_disb,
      x_min_credit_pts,
      x_disb_exp_dt,
      x_verf_enfr_dt,
      x_fee_class,
      x_show_on_bill,
      x_attendance_type_code,
      x_base_attendance_type_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_payment_prd_st_date,
      x_change_type_code,
      x_fund_return_mthd_code,
      x_direct_to_borr_flag

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.award_id,
             new_references.disb_num
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.award_id,
             new_references.disb_num
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
          check_constraints;
    --
    -- This Check has been added as part of the Disbursement and Sponsership Build Jul 2202
    -- Holds Check ,its a child to Award Disbursement
    -- FACR004
    --
    ELSIF p_action IN ('DELETE','VALIDATE_DELETE') THEN
         check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_base_attendance_type_code         IN     VARCHAR2,
    x_payment_prd_st_date               IN     DATE,
    x_change_type_code                  IN     VARCHAR2,
    x_fund_return_mthd_code             IN     VARCHAR2,
    x_called_from                       IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bannamal        29-Sep-2004     FA 149 3416863 cod xml changes for pell and direct loan
  ||                                  addded a new column
  ||  veramach        3-NOV-2003      FA 125 Multiple Distr Methods
  ||                                  Added attendance_type_code to the signature
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_awd_disb_all
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id              igf_aw_awd_disb_all.org_id%TYPE;

  BEGIN
    l_org_id := igf_aw_gen.get_org_id;

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_tp_cal_type                       => x_tp_cal_type,
      x_tp_sequence_number                => x_tp_sequence_number,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_date                         => x_disb_date,
      x_trans_type                        => x_trans_type,
      x_elig_status                       => x_elig_status,
      x_elig_status_date                  => x_elig_status_date,
      x_affirm_flag                       => x_affirm_flag,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_manual_hold_ind                   => x_manual_hold_ind,
      x_disb_status                       => x_disb_status,
      x_disb_status_date                  => x_disb_status_date,
      x_late_disb_ind                     => x_late_disb_ind,
      x_fund_dist_mthd                    => x_fund_dist_mthd,
      x_prev_reported_ind                 => x_prev_reported_ind,
      x_fund_release_date                 => x_fund_release_date,
      x_fund_status                       => NVL(x_fund_status,'N'),
      x_fund_status_date                  => x_fund_status_date,
      x_fee_paid_1                        => x_fee_paid_1,
      x_fee_paid_2                        => x_fee_paid_2,
      x_cheque_number                     => x_cheque_number,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_disb_accepted_amt                 => x_disb_accepted_amt,
      x_disb_paid_amt                     => x_disb_paid_amt,
      x_rvsn_id                           => x_rvsn_id,
      x_int_rebate_amt                    => x_int_rebate_amt,
      x_force_disb                        => x_force_disb,
      x_min_credit_pts                    => x_min_credit_pts,
      x_disb_exp_dt                       => x_disb_exp_dt,
      x_verf_enfr_dt                      => x_verf_enfr_dt,
      x_fee_class                         => x_fee_class,
      x_show_on_bill                      => x_show_on_bill,
      x_attendance_type_code              => x_attendance_type_code,
      x_base_attendance_type_code         => x_base_attendance_type_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_payment_prd_st_date               => x_payment_prd_st_date,
      x_change_type_code                  => x_change_type_code,
      x_fund_return_mthd_code             => x_fund_return_mthd_code,
      x_direct_to_borr_flag               => x_direct_to_borr_flag
    );


    INSERT INTO igf_aw_awd_disb_all(
      award_id,
      disb_num,
      tp_cal_type,
      tp_sequence_number,
      disb_gross_amt,
      fee_1,
      fee_2,
      disb_net_amt,
      disb_date,
      trans_type,
      elig_status,
      elig_status_date,
      affirm_flag,
      hold_rel_ind,
      manual_hold_ind,
      disb_status,
      disb_status_date,
      late_disb_ind,
      fund_dist_mthd,
      prev_reported_ind,
      fund_release_date,
      fund_status,
      fund_status_date,
      fee_paid_1,
      fee_paid_2,
      cheque_number,
      ld_cal_type,
      ld_sequence_number,
      disb_accepted_amt,
      disb_paid_amt,
      rvsn_id,
      int_rebate_amt,
      force_disb,
      min_credit_pts,
      disb_exp_dt,
      verf_enfr_dt,
      fee_class,
      show_on_bill,
      attendance_type_code,
      base_attendance_type_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id,
      payment_prd_st_date,
      change_type_code,
      fund_return_mthd_code,
      direct_to_borr_flag

    ) VALUES (
      new_references.award_id,
      new_references.disb_num,
      new_references.tp_cal_type,
      new_references.tp_sequence_number,
      new_references.disb_gross_amt,
      new_references.fee_1,
      new_references.fee_2,
      new_references.disb_net_amt,
      new_references.disb_date,
      new_references.trans_type,
      new_references.elig_status,
      new_references.elig_status_date,
      new_references.affirm_flag,
      NVL(new_references.hold_rel_ind, 'FALSE'),
      new_references.manual_hold_ind,
      new_references.disb_status,
      new_references.disb_status_date,
      new_references.late_disb_ind,
      new_references.fund_dist_mthd,
      new_references.prev_reported_ind,
      new_references.fund_release_date,
      NVL(new_references.fund_status,'N'),
      new_references.fund_status_date,
      new_references.fee_paid_1,
      new_references.fee_paid_2,
      new_references.cheque_number,
      new_references.ld_cal_type,
      new_references.ld_sequence_number,
      new_references.disb_accepted_amt,
      new_references.disb_paid_amt,
      new_references.rvsn_id,
      new_references.int_rebate_amt,
      new_references.force_disb,
      new_references.min_credit_pts,
      new_references.disb_exp_dt,
      new_references.verf_enfr_dt,
      new_references.fee_class,
      new_references.show_on_bill,
      new_references.attendance_type_code,
      new_references.base_attendance_type_code,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id,
      new_references.payment_prd_st_date,
      new_references.change_type_code,
      new_references.fund_return_mthd_code,
      new_references.direct_to_borr_flag
    );


    g_v_called_from := x_called_from;
    --
    -- To Reflect summation of Disbursement Amounts into Award Table
    -- Action INSERT
    --
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.insert_row ', ' g_v_called_from '||g_v_called_from);
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.insert_row ', 'before invoking igf_aw_gen.update_award  ' );
    END IF;
    igf_aw_gen.update_award (
      new_references.award_id,
      new_references.disb_num,
      new_references.disb_net_amt,
      new_references.disb_date,
      'I',
      g_v_called_from
    );
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.insert_row ', 'after invoking igf_aw_gen.update_award  ' );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.insert_row ', 'before invoking after_dml for p_action = INSERT ' );
    END IF;
    after_dml(p_action  => 'INSERT');

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    g_v_called_from := NULL;
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2  DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2  DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE,
    x_change_type_code                  IN     VARCHAR2,
    x_fund_return_mthd_code             IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2  DEFAULT NULL

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bannamal        29-Sep-2004     FA 149 3416863 cod xml changes for pell and direct loan
  ||                                  addded a new column
  ||  veramach        3-NOV-2003      FA 125 Multiple Distr Methods
  ||                                  Added attendance_type_code to the signature
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        tp_cal_type,
        tp_sequence_number,
        disb_gross_amt,
        fee_1,
        fee_2,
        disb_net_amt,
        disb_date,
        trans_type,
        elig_status,
        elig_status_date,
        affirm_flag,
        hold_rel_ind,
        manual_hold_ind,
        disb_status,
        disb_status_date,
        late_disb_ind,
        fund_dist_mthd,
        prev_reported_ind,
        fund_release_date,
        fund_status,
        fund_status_date,
        fee_paid_1,
        fee_paid_2,
        cheque_number,
        ld_cal_type,
        ld_sequence_number,
        disb_accepted_amt,
        disb_paid_amt,
        rvsn_id,
        int_rebate_amt,
        force_disb,
        min_credit_pts,
        disb_exp_dt,
        verf_enfr_dt,
        fee_class,
        show_on_bill,
        attendance_type_code,
        base_attendance_type_code,
        payment_prd_st_date,
        change_type_code,
        fund_return_mthd_code,
        direct_to_borr_flag

      FROM  igf_aw_awd_disb_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.ld_cal_type = x_ld_cal_type)
        AND (tlinfo.ld_sequence_number = x_ld_sequence_number)
        AND (tlinfo.disb_gross_amt = x_disb_gross_amt)
        AND ((tlinfo.fee_1 = x_fee_1) OR ((tlinfo.fee_1 IS NULL) AND (X_fee_1 IS NULL)))
        AND ((tlinfo.fee_2 = x_fee_2) OR ((tlinfo.fee_2 IS NULL) AND (X_fee_2 IS NULL)))
        AND (tlinfo.disb_net_amt = x_disb_net_amt)
        AND (tlinfo.disb_date = x_disb_date)
        AND (tlinfo.trans_type = x_trans_type)
        AND ((tlinfo.elig_status = x_elig_status) OR ((tlinfo.elig_status IS NULL) AND (X_elig_status IS NULL)))
        AND ((tlinfo.elig_status_date = x_elig_status_date) OR ((tlinfo.elig_status_date IS NULL) AND (X_elig_status_date IS NULL)))
        AND ((tlinfo.affirm_flag = x_affirm_flag) OR ((tlinfo.affirm_flag IS NULL) AND (X_affirm_flag IS NULL)))
        AND ((tlinfo.hold_rel_ind = x_hold_rel_ind) OR ((tlinfo.hold_rel_ind IS NULL) AND (X_hold_rel_ind IS NULL)))
        AND ((tlinfo.manual_hold_ind = x_manual_hold_ind) OR ((tlinfo.manual_hold_ind IS NULL) AND (X_manual_hold_ind IS NULL)))
        AND ((tlinfo.disb_status = x_disb_status) OR ((tlinfo.disb_status IS NULL) AND (X_disb_status IS NULL)))
        AND ((tlinfo.disb_status_date = x_disb_status_date) OR ((tlinfo.disb_status_date IS NULL) AND (X_disb_status_date IS NULL)))
        AND ((tlinfo.late_disb_ind = x_late_disb_ind) OR ((tlinfo.late_disb_ind IS NULL) AND (X_late_disb_ind IS NULL)))
        AND ((tlinfo.fund_dist_mthd = x_fund_dist_mthd) OR ((tlinfo.fund_dist_mthd IS NULL) AND (X_fund_dist_mthd IS NULL)))
        AND ((tlinfo.prev_reported_ind = x_prev_reported_ind) OR ((tlinfo.prev_reported_ind IS NULL) AND (X_prev_reported_ind IS NULL)))
        AND ((tlinfo.fund_release_date = x_fund_release_date) OR ((tlinfo.fund_release_date IS NULL) AND (X_fund_release_date IS NULL)))
        AND ((tlinfo.fund_status = x_fund_status) OR ((tlinfo.fund_status IS NULL) AND (X_fund_status IS NULL)))
        AND ((tlinfo.fund_status_date = x_fund_status_date) OR ((tlinfo.fund_status_date IS NULL) AND (X_fund_status_date IS NULL)))
        AND ((tlinfo.fee_paid_1 = x_fee_paid_1) OR ((tlinfo.fee_paid_1 IS NULL) AND (X_fee_paid_1 IS NULL)))
        AND ((tlinfo.fee_paid_2 = x_fee_paid_2) OR ((tlinfo.fee_paid_2 IS NULL) AND (X_fee_paid_2 IS NULL)))
        AND ((tlinfo.cheque_number = x_cheque_number) OR ((tlinfo.cheque_number IS NULL) AND (X_cheque_number IS NULL)))
        AND ((tlinfo.tp_cal_type = x_tp_cal_type) OR ((tlinfo.tp_cal_type IS NULL) AND (X_tp_cal_type IS NULL)))
        AND ((tlinfo.tp_sequence_number = x_tp_sequence_number) OR ((tlinfo.tp_sequence_number IS NULL) AND (X_tp_sequence_number IS NULL)))
        AND ((tlinfo.disb_accepted_amt = x_disb_accepted_amt) OR ((tlinfo.disb_accepted_amt IS NULL) AND (X_disb_accepted_amt IS NULL)))
        AND ((tlinfo.disb_paid_amt = x_disb_paid_amt) OR ((tlinfo.disb_paid_amt IS NULL) AND (X_disb_paid_amt IS NULL)))
        AND ((tlinfo.rvsn_id = x_rvsn_id) OR ((tlinfo.rvsn_id IS NULL) AND (X_rvsn_id IS NULL)))
        AND ((tlinfo.int_rebate_amt = x_int_rebate_amt) OR ((tlinfo.int_rebate_amt IS NULL) AND (x_int_rebate_amt IS NULL)))
     AND ((tlinfo.force_disb = x_force_disb) OR ((tlinfo.force_disb IS NULL) AND (x_force_disb IS NULL)))
     AND ((tlinfo.min_credit_pts = x_min_credit_pts) OR ((tlinfo.min_credit_pts IS NULL) AND (x_min_credit_pts IS NULL)))
     AND ((tlinfo.disb_exp_dt = x_disb_exp_dt) OR ((tlinfo.disb_exp_dt IS NULL) AND (x_disb_exp_dt IS NULL)))
     AND ((tlinfo.verf_enfr_dt = x_verf_enfr_dt) OR ((tlinfo.verf_enfr_dt IS NULL) AND (x_verf_enfr_dt IS NULL)))
     AND ((tlinfo.fee_class = x_fee_class) OR ((tlinfo.fee_class IS NULL) AND (x_fee_class IS NULL)))
     AND ((tlinfo.show_on_bill = x_show_on_bill) OR ((tlinfo.show_on_bill IS NULL) AND (x_show_on_bill IS NULL)))
     AND ((tlinfo.attendance_type_code = x_attendance_type_code) OR ((tlinfo.attendance_type_code IS NULL) AND (x_attendance_type_code IS NULL)))
     AND ((tlinfo.base_attendance_type_code = x_base_attendance_type_code) OR ((tlinfo.base_attendance_type_code IS NULL) AND (x_base_attendance_type_code IS NULL)))
     AND ((tlinfo.payment_prd_st_date = x_payment_prd_st_date) OR ((tlinfo.payment_prd_st_date IS NULL) AND (x_payment_prd_st_date IS NULL)))
     AND ((tlinfo.change_type_code = x_change_type_code) OR ((tlinfo.change_type_code IS NULL) AND (x_change_type_code IS NULL)))
     AND ((tlinfo.fund_return_mthd_code = x_fund_return_mthd_code) OR ((tlinfo.fund_return_mthd_code IS NULL) AND (x_fund_return_mthd_code IS NULL)))
     AND ((tlinfo.direct_to_borr_flag = x_direct_to_borr_flag) OR ((tlinfo.direct_to_borr_flag IS NULL) AND (x_direct_to_borr_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_base_attendance_type_code         IN     VARCHAR2,
    x_payment_prd_st_date               IN     DATE,
    x_change_type_code                  IN     VARCHAR2,
    x_fund_return_mthd_code             IN     VARCHAR2,
    x_called_from                       IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2

    ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bannamal        29-Sep-2004     FA 149 3416863 cod xml changes for pell and direct loan
  ||                                  addded a new column
  ||  veramach        3-NOV-2003      FA 125 Multiple Distr Methods
  ||                                  Added attendance_type_code to the signature
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_tp_cal_type                       => x_tp_cal_type,
      x_tp_sequence_number                => x_tp_sequence_number,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_disb_net_amt                      => x_disb_net_amt,
      x_disb_date                         => x_disb_date,
      x_trans_type                        => x_trans_type,
      x_elig_status                       => x_elig_status,
      x_elig_status_date                  => x_elig_status_date,
      x_affirm_flag                       => x_affirm_flag,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_manual_hold_ind                   => x_manual_hold_ind,
      x_disb_status                       => x_disb_status,
      x_disb_status_date                  => x_disb_status_date,
      x_late_disb_ind                     => x_late_disb_ind,
      x_fund_dist_mthd                    => x_fund_dist_mthd,
      x_prev_reported_ind                 => x_prev_reported_ind,
      x_fund_release_date                 => x_fund_release_date,
      x_fund_status                       => x_fund_status,
      x_fund_status_date                  => x_fund_status_date,
      x_fee_paid_1                        => x_fee_paid_1,
      x_fee_paid_2                        => x_fee_paid_2,
      x_cheque_number                     => x_cheque_number,
      x_ld_cal_type                       => x_ld_cal_type,
      x_ld_sequence_number                => x_ld_sequence_number,
      x_disb_accepted_amt                 => x_disb_accepted_amt,
      x_disb_paid_amt                     => x_disb_paid_amt,
      x_rvsn_id                           => x_rvsn_id,
      x_int_rebate_amt                    => x_int_rebate_amt,
      x_force_disb                        => x_force_disb,
      x_min_credit_pts                    => x_min_credit_pts,
      x_disb_exp_dt                       => x_disb_exp_dt,
      x_verf_enfr_dt                      => x_verf_enfr_dt,
      x_fee_class                         => x_fee_class,
      x_show_on_bill                      => x_show_on_bill,
      x_attendance_type_code              => x_attendance_type_code,
      x_base_attendance_type_code         => x_base_attendance_type_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_payment_prd_st_date               => x_payment_prd_st_date,
      x_change_type_code                  => x_change_type_code,
      x_fund_return_mthd_code             => x_fund_return_mthd_code,
      x_direct_to_borr_flag               => x_direct_to_borr_flag

    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    --
    -- To Crate Adjustments
    --

    igf_aw_gen.update_disb( old_references,new_references );

    UPDATE igf_aw_awd_disb_all
      SET
        tp_cal_type                       = new_references.tp_cal_type,
        tp_sequence_number                = new_references.tp_sequence_number,
        disb_gross_amt                    = new_references.disb_gross_amt,
        fee_1                             = new_references.fee_1,
        fee_2                             = new_references.fee_2,
        disb_net_amt                      = new_references.disb_net_amt,
        disb_date                         = new_references.disb_date,
        trans_type                        = new_references.trans_type,
        elig_status                       = new_references.elig_status,
        elig_status_date                  = new_references.elig_status_date,
        affirm_flag                       = new_references.affirm_flag,
        hold_rel_ind                      = NVL(new_references.hold_rel_ind, 'FALSE'),
        manual_hold_ind                   = new_references.manual_hold_ind,
        disb_status                       = new_references.disb_status,
        disb_status_date                  = new_references.disb_status_date,
        late_disb_ind                     = new_references.late_disb_ind,
        fund_dist_mthd                    = new_references.fund_dist_mthd,
        prev_reported_ind                 = new_references.prev_reported_ind,
        fund_release_date                 = new_references.fund_release_date,
        fund_status                       = new_references.fund_status,
        fund_status_date                  = new_references.fund_status_date,
        fee_paid_1                        = new_references.fee_paid_1,
        fee_paid_2                        = new_references.fee_paid_2,
        cheque_number                     = new_references.cheque_number,
        ld_cal_type                       = new_references.ld_cal_type,
        ld_sequence_number                = new_references.ld_sequence_number,
        disb_accepted_amt                 = new_references.disb_accepted_amt,
        disb_paid_amt                     = new_references.disb_paid_amt,
        rvsn_id                           = new_references.rvsn_id,
        int_rebate_amt                    = new_references.int_rebate_amt,
        force_disb                        = new_references.force_disb,
        min_credit_pts                    = new_references.min_credit_pts,
        disb_exp_dt                       = new_references.disb_exp_dt,
        verf_enfr_dt                      = new_references.verf_enfr_dt,
        fee_class                         = new_references.fee_class,
        show_on_bill                      = new_references.show_on_bill,
        attendance_type_code              = new_references.attendance_type_code,
        base_attendance_type_code         = new_references.base_attendance_type_code,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        payment_prd_st_date               = new_references.payment_prd_st_date,
        change_type_code                  = new_references.change_type_code,
        fund_return_mthd_code             = new_references.fund_return_mthd_code,
        direct_to_borr_flag               = new_references.direct_to_borr_flag

      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    --
    -- To Reflect summation of Disbursement Amounts into Award Table
    -- Action UPDATE
    --
    g_v_called_from := x_called_from;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.update_row ', ' g_v_called_from '||g_v_called_from);
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.update_row ', 'before invoking after_dml ' );
    END IF;
    after_dml(p_action => 'UPDATE');
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.update_row ', 'after invoking after_dml ' );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.update_row ', 'before invoking igf_aw_gen.update_award ' );
    END IF;
    igf_aw_gen.update_award (new_references.award_id,
                             new_references.disb_num,
                             new_references.disb_net_amt,
                             new_references.disb_date,
                             'U',
                             g_v_called_from
                             );
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.update_row ', 'after invoking igf_aw_gen.update_award ' );
    END IF;
    g_v_called_from := NULL;
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_base_attendance_type_code         IN     VARCHAR2,
    x_payment_prd_st_date               IN     DATE,
    x_change_type_code                  IN     VARCHAR2,
    x_fund_return_mthd_code             IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2

  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  bannamal        29-Sep-2004     FA 149 3416863 cod xml changes for pell and direct loan
  ||                                  addded a new column
  ||  veramach        3-NOV-2003      FA 125 Multiple Distr Methods
  ||                                  Added attendance_type_code to the signature
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_awd_disb_all
      WHERE    award_id                          = x_award_id
      AND      disb_num                          = x_disb_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_award_id,
        x_disb_num,
        x_tp_cal_type,
        x_tp_sequence_number,
        x_disb_gross_amt,
        x_fee_1,
        x_fee_2,
        x_disb_net_amt,
        x_disb_date,
        x_trans_type,
        x_elig_status,
        x_elig_status_date,
        x_affirm_flag,
        x_hold_rel_ind,
        x_manual_hold_ind,
        x_disb_status,
        x_disb_status_date,
        x_late_disb_ind,
        x_fund_dist_mthd,
        x_prev_reported_ind,
        x_fund_release_date,
        x_fund_status,
        x_fund_status_date,
        x_fee_paid_1,
        x_fee_paid_2,
        x_cheque_number,
        x_ld_cal_type,
        x_ld_sequence_number,
        x_disb_accepted_amt,
        x_disb_paid_amt,
        x_rvsn_id,
        x_int_rebate_amt,
        x_force_disb,
        x_min_credit_pts,
        x_disb_exp_dt,
        x_verf_enfr_dt,
        x_fee_class,
        x_show_on_bill,
        x_mode,
        x_attendance_type_code,
        x_base_attendance_type_code,
        x_payment_prd_st_date,
        x_change_type_code,
        x_fund_return_mthd_code,
        x_direct_to_borr_flag

      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_award_id,
      x_disb_num,
      x_tp_cal_type,
      x_tp_sequence_number,
      x_disb_gross_amt,
      x_fee_1,
      x_fee_2,
      x_disb_net_amt,
      x_disb_date,
      x_trans_type,
      x_elig_status,
      x_elig_status_date,
      x_affirm_flag,
      x_hold_rel_ind,
      x_manual_hold_ind,
      x_disb_status,
      x_disb_status_date,
      x_late_disb_ind,
      x_fund_dist_mthd,
      x_prev_reported_ind,
      x_fund_release_date,
      x_fund_status,
      x_fund_status_date,
      x_fee_paid_1,
      x_fee_paid_2,
      x_cheque_number,
      x_ld_cal_type,
      x_ld_sequence_number,
      x_disb_accepted_amt,
      x_disb_paid_amt,
      x_rvsn_id,
      x_int_rebate_amt,
      x_force_disb,
      x_min_credit_pts,
      x_disb_exp_dt,
      x_verf_enfr_dt,
      x_fee_class,
      x_show_on_bill,
      x_mode,
      x_attendance_type_code,
      x_base_attendance_type_code,
      x_payment_prd_st_date,
      x_change_type_code,
      x_fund_return_mthd_code,
      x_direct_to_borr_flag

    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
    x_called_from  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : adhawan
  ||  Created On : 16-NOV-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  --
  -- Bug 2255279
  -- sjadhav
  -- Apr02,2002
  -- Reflect The Amoutns into Awards Table once a disbursement
  -- is deleted
  --

  CURSOR cur_get_award ( p_row_id ROWID)
  IS
  SELECT
  award_id
  FROM
  igf_aw_awd_disb
  WHERE
  row_id = p_row_id;

  get_award_rec  cur_get_award%ROWTYPE;

  BEGIN

  OPEN  cur_get_award(x_rowid);
  FETCH cur_get_award INTO get_award_rec;
  CLOSE cur_get_award;

    g_v_called_from := x_called_from;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.delete_row ', ' g_v_called_from '||g_v_called_from);
    END IF;
    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.delete_row ', ' before invoking BeforeRowInsertUpdateDelete1 ');
    END IF;
    BeforeRowInsertUpdateDelete1(
      p_rowid     => x_rowid,
      p_inserting => FALSE,
      p_updating  => FALSE ,
      p_deleting  => TRUE
    );
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.delete_row ', ' after invoking BeforeRowInsertUpdateDelete1 ');
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.delete_row ', ' deleting the record from igf_aw_awd_disb_all table for rowid '||x_rowid);
    END IF;
    DELETE FROM igf_aw_awd_disb_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    --
    -- To Reflect summation of Disbursement Amounts into Award Table
    -- Action DELETE
    --
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_awd_disb_pkg.delete_row ', ' before invoking igf_aw_gen.update_award ');
    END IF;
    igf_aw_gen.update_award (get_award_rec.award_id,
                             0,
                             0,
                             TRUNC(SYSDATE),
                             'D',
                             g_v_called_from
                             );
    g_v_called_from := NULL;
  END delete_row;

END igf_aw_awd_disb_pkg;

/
