--------------------------------------------------------
--  DDL for Package Body IGF_DB_CL_ROSTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_CL_ROSTER" AS
/* $Header: IGFDB04B.pls 120.5 2006/08/08 06:29:38 ridas noship $ */

-----------------------------------------------------------------------------------
--   Created By : sjadhav
--   Date Created On : 2000/12/18
--   Purpose :
--   Know limitations, enhancements or remarks
--   Change History
----------------------------------------------------------------------------------------
-- svuppala     27-OCT-04      FA 134 CommonLine4 Change Origination
--                             # 3416936 Modifications to disbursement roster process
 ----------------------------------------------------------------------------------------
--ayedubat     14-OCT-04      FA 149 COD-XML Standards build bug # 3416863
--                            Changed the TBH call of the package: IGF_AW_AWD_DISB_PKG
-----------------------------------------------------------------------------------
-- veramach    July 2004      FA 151 HR integration (bug # 3709292)
--                            Impact of obsoleting columns from igf_aw_awd_disb_pkg
-----------------------------------------------------------------------------------
--   Who          When            What
--   veramach     3-NOV-2003      FA 125 Multiple Distr Methods
--                                Changed the call of igf_aw_awd_disb_pkg.update_row to reflect the addition of attendance_type_code
-----------------------------------------------------------------------------------
--   sjadhav      26-Mar-2003     Bug 2863960
--                                Changed Disb Gross Amt to Disb Accepted Amt
--                                As net amount is based on accepted amount
--                                Cursor to read CL Setup Data modified to read
--                                records based on award year
--                                Corrected typos in messages and lookup codes
-----------------------------------------------------------------------------------
--   mesriniv     13-07-2001      W.r.to Awards Build,9 new columns have been added
--                                in IGF_AW_AWD_DISB_ALL table.The call to
--                                igf_aw_awd_disb_pkg.update_row has been modified
--                                to reflect the changes.
-----------------------------------------------------------------------------------
--   ssawhney     2nd Jan         Stud Emp build IGF_AW_AWD_DISB TBH call changed.
-----------------------------------------------------------------------------------

  FILE_NOT_LOADED     EXCEPTION;
  CLSETUP_NOT_FOUND   EXCEPTION;
  SKIP_THIS_RECORD    EXCEPTION;

  g_cl_version          igf_sl_cl_file_type.cl_version%TYPE;
  g_cl_file_type        igf_sl_cl_file_type.cl_file_type%TYPE;
  --These are description for various fields which will go in log file

  loan_number_desc           VARCHAR2(100);
  disb_num_desc              VARCHAR2(100);
  loc_disb_desc              VARCHAR2(100);
  ofa_disb_desc              VARCHAR2(100);
  disb_gross_amt_desc        VARCHAR2(100);
  fee_1_desc                 VARCHAR2(100);
  fee_2_desc                 VARCHAR2(100);
  disb_net_amt_desc          VARCHAR2(100);
  fee_paid_1_desc            VARCHAR2(100);
  fee_paid_2_desc            VARCHAR2(100);
  direct_to_borr_ind_desc    VARCHAR2(100);

  -- Above are description for various fields which will go in log file



-- Procedure to Load the Data from the Disbursement Roster File into the ,
-- and IGF_DB_CL_DISB_RESP  tables.
-- Before loading, it does lot of checks to ensure it is the right file


PROCEDURE cl_load_data(p_cbth_id OUT NOCOPY igf_sl_cl_batch_all.cbth_id%TYPE)
IS


/*************************************************************
  Created By : sjadhav
  Date Created On : 2000/12/18
  Purpose : To load data into Batch and Response table
  after validating for the correctness of the data

  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ridas           07-Aug-2006     Build FA163. Changes made to include the direct disbursement
                                  to borrower indicator and split of guarantee and origination fee paid.
  svuppala        27-Oct-2004     Added new fields as per FA 134
  (reverse chronological order - newest change first)
  ***************************************************************/

   l_batch_id                    igf_sl_cl_batch_all.batch_id%TYPE;
   l_file_creation_dt            igf_sl_cl_batch_all.file_creation_date%TYPE;
   l_file_trans_dt               igf_sl_cl_batch_all.file_trans_date%TYPE;
   l_file_ident_name             VARCHAR2(100);
   l_file_ident_code             igf_sl_cl_batch_all.file_ident_code%TYPE;
   l_source_id                   igf_sl_cl_batch_all.source_id%TYPE;
   l_recipient_id                igf_sl_cl_batch_all.recipient_id%TYPE;
   l_recip_non_ed_brc_id         igf_sl_cl_batch_all.recip_non_ed_brc_id%TYPE;
   l_source_non_ed_brc_id        igf_sl_cl_batch_all.source_non_ed_brc_id%TYPE;
   l_rowid                       ROWID;
   l_cbth_id                     igf_sl_cl_batch_all.cbth_id%TYPE;
   l_number_rec                  NUMBER;
   l_last_lort_id                NUMBER;
   l_tot_net_disb_amt            NUMBER;
   l_tot_net_eft_amt             NUMBER;
   l_tot_net_non_eft_amt         NUMBER;
   l_tot_reissue_amt             NUMBER;
   l_tot_cancel_amt              NUMBER;
   l_tot_deficit_amt             NUMBER;
   l_tot_net_cancel_amt          NUMBER;
   l_tot_net_out_cancel_amt      NUMBER;
   l_file_creation_time          DATE;
   l_source_name                 VARCHAR2(80);
   l_recipient_name              VARCHAR2(80);
   l_temp                        VARCHAR2(10);
   lv_header                     VARCHAR2(80);
   lv_source_id                  VARCHAR2(80);
   lv_source_name                VARCHAR2(80);
   lv_recipient_id               VARCHAR2(80);
   lv_recipient_name             VARCHAR2(80);
   lv_file_creation_date         VARCHAR2(80);
   lv_file_creation_time         VARCHAR2(80);
   lv_trailer                    VARCHAR2(80);
   lv_number_rec                 VARCHAR2(80);
   lv_tot_net_disb_amt           VARCHAR2(80);
   lv_tot_net_eft_amt            VARCHAR2(80);
   lv_tot_net_non_eft_amt        VARCHAR2(80);
   lv_tot_reissue_amt            VARCHAR2(80);
   lv_tot_cancel_amt             VARCHAR2(80);
   lv_tot_deficit_amt            VARCHAR2(80);
   lv_tot_net_cancel_amt         VARCHAR2(80);
   lv_tot_net_out_cancel_amt     VARCHAR2(80);
   l_actual_rec                  NUMBER DEFAULT 0;
   l_cdbr_id                     igf_db_cl_disb_resp_all.cdbr_id%TYPE;
   l_hold_rel_ind                VARCHAR2(30);
   l_pnote_code                  VARCHAR2(2);
   l_pnote_status_date           DATE;
   l_fee_paid_1                  NUMBER;
   l_netted_cancel_amt           NUMBER;
   l_outstd_cancel_amt           NUMBER;
   l_sch_non_ed_brc_id           VARCHAR2(30);
   l_record_type                 VARCHAR2(30);
   l_loan_number                 VARCHAR2(30);
   l_cl_seq_number               NUMBER;
   l_loan_per_start_date         DATE;
   l_loan_per_end_date           DATE;
   l_lender_id                   VARCHAR2(30);
   l_lend_non_ed_brc_id          VARCHAR2(30);
   l_tot_sched_disb              NUMBER;
   l_disb_num                    NUMBER;
   l_guarantor_id                VARCHAR2(30);
   l_guarantee_date              DATE;
   l_guarantee_amt               NUMBER;
   l_fund_release_date           DATE;
   l_gross_disb_amt              NUMBER;
   l_fee_1                       NUMBER;
   l_fee_2                       NUMBER;
   l_net_disb_amt                NUMBER;
   l_fund_dist_mthd              VARCHAR2(30);
   l_check_number                VARCHAR2(30);
   l_late_disb_ind               VARCHAR2(30);
   l_prev_reported_ind           VARCHAR2(30);
   l_net_cancel_amt              NUMBER;
   l_fee_paid_2                  NUMBER;
   lv_disb                       VARCHAR2(80);
   lv_record_type                VARCHAR2(80);
   lv_loan_sequence_number       VARCHAR2(80);
   lv_loan_number                VARCHAR2(80);
   lv_loan_period_end_date       VARCHAR2(80);
   lv_loan_period_start_date     VARCHAR2(80);
   lv_lender_id                  VARCHAR2(80);
   lv_lender_non_ed_branch_id    VARCHAR2(80);
   lv_total_schd_disb            VARCHAR2(80);
   lv_disbursement_number        VARCHAR2(80);
   lv_guarantor_id               VARCHAR2(80);
   lv_guarantee_date             VARCHAR2(80);
   lv_guarantee_amount           VARCHAR2(80);
   lv_fund_release_date          VARCHAR2(80);
   lv_gross_disbursement_amount  VARCHAR2(80);
   lv_guarantee_fees             VARCHAR2(80);
   lv_origination_fees_paid      VARCHAR2(80);
   lv_origination_fees           VARCHAR2(80);
   lv_guarantee_fees_paid        VARCHAR2(80);
   lv_net_disbursement_amount    VARCHAR2(80);
   lv_fees_paid                  VARCHAR2(80);
   lv_fund_distribution_method   VARCHAR2(80);
   lv_check_number               VARCHAR2(80);
   lv_late_disbursement          VARCHAR2(80);
   lv_previously_reported        VARCHAR2(80);
   lv_net_cancellation_amount    VARCHAR2(80);
   lv_netted_cancel_amount       VARCHAR2(80);
   lv_outstanding_can_amt        VARCHAR2(80);
   lv_esign_src_typ_cd           VARCHAR2(80);
   lv_direct_to_borr_ind_mng     VARCHAR2(80);
   l_direct_to_borr_ind          VARCHAR2(1);



   CURSOR c_header
   IS
      SELECT LTRIM(RTRIM(SUBSTR(record_data, 3, 12))) batch_id,
             TO_DATE(TRIM(SUBSTR(record_data, 15, 8)), 'YYYYMMDDHH24MISS') file_creation_dt,
             TO_DATE(TRIM(SUBSTR(record_data, 23, 6)), 'HH24MISS') file_creation_time,
             TO_DATE(TRIM(SUBSTR(record_data, 29, 8)), 'YYYYMMDDHH24MISS') file_trans_dt,
             LTRIM(RTRIM(SUBSTR(record_data, 43, 19))) file_ident_name,
             LTRIM(RTRIM(SUBSTR(record_data, 62, 5))) file_ident_code,
             LTRIM(RTRIM(SUBSTR(record_data, 67, 32))) source_name,
             LTRIM(RTRIM(SUBSTR(record_data, 99, 8))) source_id,
             LTRIM(RTRIM(SUBSTR(record_data, 109, 4))) source_non_ed_brc_id,
             LTRIM(RTRIM(SUBSTR(record_data, 114, 32))) recipient_name,
             LTRIM(RTRIM(SUBSTR(record_data, 146, 8))) recipient_id,
             LTRIM(RTRIM(SUBSTR(record_data, 156, 4))) recip_non_ed_brc_id
        FROM igf_sl_load_file_t
       WHERE lort_id = 1 AND record_data LIKE '@H%' AND file_type =
                                                                  'CL_ROSTER';

   CURSOR c_trailer
   IS
      SELECT lort_id last_lort_id,
             TO_NUMBER(TRIM(SUBSTR(record_data, 3, 6))) rec_count,
             TO_NUMBER(TRIM(SUBSTR(record_data, 9, 14)))/100 tot_net_disb_amt,
             TO_NUMBER(TRIM(SUBSTR(record_data, 23, 14)))/100 tot_net_eft_amt,
             TO_NUMBER(TRIM(SUBSTR(record_data, 37, 14)))/100 tot_net_non_eft_amt,
             TO_NUMBER(TRIM(SUBSTR(record_data, 51, 14)))/100 tot_reissue_amt,
             TO_NUMBER(TRIM(SUBSTR(record_data, 105, 14)))/100 tot_cancel_amt,
             TO_NUMBER(TRIM(SUBSTR(record_data, 119, 14)))/100 tot_deficit_amt,
             TO_NUMBER(TRIM(SUBSTR(record_data, 142, 14)))/100 tot_net_cancel_amt,
             TO_NUMBER(TRIM(SUBSTR(record_data, 156, 14)))/100 tot_net_out_cancel_amt
        FROM igf_sl_load_file_t
       WHERE lort_id = (SELECT MAX(lort_id)
                          FROM igf_sl_load_file_t)
             AND record_data LIKE '@T%' AND file_type = 'CL_ROSTER';

   CURSOR c_get_header_parameters
   IS
      SELECT meaning, lookup_code
        FROM igf_lookups_view
       WHERE lookup_type = 'IGF_SL_CL_ROSTER_LOGS';

   CURSOR c_get_trailer_parameters
   IS
      SELECT meaning, lookup_code
        FROM igf_lookups_view
       WHERE lookup_type = 'IGF_SL_CL_ROSTER_LOGS';


   CURSOR c_dbcl
   IS
      SELECT record_data
        FROM igf_sl_load_file_t
       WHERE lort_id BETWEEN 2 AND (l_last_lort_id - 1)
             AND file_type = 'CL_ROSTER';


   CURSOR cur_roster_logs
   IS
      SELECT meaning, lookup_code
        FROM igf_lookups_view
       WHERE lookup_type = 'IGF_SL_CL_ROSTER_LOGS';

   header_parameter_rec          c_get_header_parameters%ROWTYPE;
   trailer_parameter_rec         c_get_trailer_parameters%ROWTYPE;
   roster_logs_rec               cur_roster_logs%ROWTYPE;

  CURSOR  cur_lor_data  (cp_loan_number igf_sl_loans_all.loan_number%TYPE) IS
    SELECT  lor.ROWID row_id, lor.*
      FROM  IGF_SL_LOR_ALL lor,
            IGF_SL_LOANS_ALL loans
     WHERE  loans.loan_id = lor.loan_id
      AND   loans.loan_number = cp_loan_number;

  rec_lor_data  cur_lor_data%ROWTYPE;

  lv_esign_roster_data  igf_sl_lor_all.esign_src_typ_cd%TYPE;

BEGIN

--    Check for a proper header

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','cl_load_data Entry ');
      END IF;

      OPEN c_header;
      FETCH c_header INTO
            l_batch_id,
            l_file_creation_dt,
            l_file_creation_time,
            l_file_trans_dt,
            l_file_ident_name,
            l_file_ident_code,
            l_source_name,
            l_source_id,
            l_source_non_ed_brc_id,
            l_recipient_name,
            l_recipient_id,
            l_recip_non_ed_brc_id;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','cl_load_data Header fetch');
      END IF;
      IF c_header%NOTFOUND THEN
          CLOSE c_header;
          fnd_message.set_name('IGF','IGF_GE_FILE_NOT_COMPLETE');
          -- File uploaded is incomplete.
          igs_ge_msg_stack.add;
          RAISE FILE_NOT_LOADED;
      END IF;
      CLOSE c_header;

      -- Check for a valid Disbursement Roster File

      igf_sl_gen.get_cl_batch_details(
                      LTRIM(RTRIM(l_file_ident_code)),                      -- File_Ident_Code
                      LTRIM(RTRIM(l_file_ident_name)),                      -- File_Ident_Name
                      g_cl_version, g_cl_file_type);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','Got Batch g_cl_version,g_cl_file_type,l_file_ident_name ,l_file_ident_code '
                                                || g_cl_version ||' : ' || g_cl_file_type||' : ' || l_file_ident_name||' : ' || l_file_ident_code);
      END IF;

      IF  g_cl_file_type  = 'CL_DISB_ROSTER' THEN
          NULL;
      ELSE
          fnd_message.set_name('IGF','IGF_GE_INVALID_FILE');
          igs_ge_msg_stack.add;
          RAISE FILE_NOT_LOADED;
      END IF;

     -- File is a valid Disbursement Roster File. It should be processed.

      fnd_message.set_name('IGF','IGF_DB_CL_ROSTER_FILE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

     --Check whether file has been transmitted completely or not

      OPEN  c_trailer;
      FETCH c_trailer INTO  l_last_lort_id, l_number_rec, l_tot_net_disb_amt,
                            l_tot_net_eft_amt, l_tot_net_non_eft_amt,
                            l_tot_reissue_amt, l_tot_cancel_amt, l_tot_deficit_amt,
                            l_tot_net_cancel_amt, l_tot_net_out_cancel_amt;
      IF c_trailer%NOTFOUND THEN
          CLOSE c_trailer;
          fnd_message.set_name('IGF','IGF_GE_FILE_NOT_COMPLETE');
          -- File uploaded is incomplete.
          igs_ge_msg_stack.add;
          RAISE FILE_NOT_LOADED;
      END IF;
      CLOSE c_trailer;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug',' got trailer record ');
      END IF;


      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','before inserting batch record');
      END IF;

     l_rowid := NULL;

     IF g_cl_version  = 'RELEASE-5' THEN
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','before inserting batch record for Release-5');
       END IF;

      igf_sl_cl_batch_pkg.insert_row(
        x_rowid                     =>    l_rowid,
        x_cbth_id                   =>    l_cbth_id,
        x_batch_id                  =>    l_batch_id,
        x_file_creation_date        =>    l_file_creation_dt,
        x_file_trans_date           =>    l_file_trans_dt,
        x_file_ident_code           =>    l_file_ident_code,
        x_recipient_id              =>    l_recipient_id,
        x_recip_non_ed_brc_id       =>    l_recip_non_ed_brc_id,
        x_source_id                 =>    l_source_id,
        x_source_non_ed_brc_id      =>    l_source_non_ed_brc_id,
        x_send_resp                 =>    'D',
        x_mode                      =>    'R',
        x_record_count_num          =>    l_number_rec          ,
        x_total_net_disb_amt        =>    l_tot_net_disb_amt    ,
        x_total_net_eft_amt         =>    l_tot_net_eft_amt     ,
        x_total_net_non_eft_amt     =>    l_tot_net_non_eft_amt ,
        x_total_reissue_amt         =>    l_tot_reissue_amt     ,
        x_total_cancel_amt          =>    l_tot_cancel_amt      ,
        x_total_deficit_amt         =>    l_tot_deficit_amt     ,
        x_total_net_cancel_amt      =>    l_tot_net_cancel_amt  ,
        x_total_net_out_cancel_amt  =>    l_tot_net_out_cancel_amt
      );
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','After inserting batch record for Release-5');
       END IF;


    ELSIF g_cl_version  = 'RELEASE-4' THEN
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','before inserting batch record for Release-4');
       END IF;

     igf_sl_cl_batch_pkg.insert_row(
        x_rowid                     =>    l_rowid,
        x_cbth_id                   =>    l_cbth_id,
        x_batch_id                  =>    l_batch_id,
        x_file_creation_date        =>    l_file_creation_dt,
        x_file_trans_date           =>    l_file_trans_dt,
        x_file_ident_code           =>    l_file_ident_code,
        x_recipient_id              =>    l_recipient_id,
        x_recip_non_ed_brc_id       =>    l_recip_non_ed_brc_id,
        x_source_id                 =>    l_source_id,
        x_source_non_ed_brc_id      =>    l_source_non_ed_brc_id,
        x_send_resp                 =>    'D',
        x_mode                      =>    'R',
        x_record_count_num          =>    l_number_rec          ,
        x_total_net_disb_amt        =>    l_tot_net_disb_amt    ,
        x_total_net_eft_amt         =>    l_tot_net_eft_amt     ,
        x_total_net_non_eft_amt     =>    l_tot_net_non_eft_amt ,
        x_total_reissue_amt         =>    l_tot_reissue_amt     ,
        x_total_cancel_amt          =>    l_tot_cancel_amt      ,
        x_total_deficit_amt         =>    l_tot_deficit_amt     ,
        x_total_net_cancel_amt      =>    l_tot_net_cancel_amt  ,
        x_total_net_out_cancel_amt  =>    l_tot_net_out_cancel_amt
     );

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','after inserting batch record for Release-4');
       END IF;

    END IF;

     OPEN c_get_header_parameters;
     LOOP
          FETCH c_get_header_parameters INTO  header_parameter_rec;
          EXIT WHEN c_get_header_parameters%NOTFOUND;

          IF header_parameter_rec.lookup_code ='HEADER' THEN
            lv_header  := TRIM(header_parameter_rec.meaning);
          ELSIF header_parameter_rec.lookup_code ='SOURCE_ENTITY_ID_TXT' THEN
            lv_source_id  := TRIM(header_parameter_rec.meaning);
          ELSIF header_parameter_rec.lookup_code ='SOURCE_NAME' THEN
            lv_source_name      := TRIM(header_parameter_rec.meaning);
          ELSIF header_parameter_rec.lookup_code ='RECIPIENT_ID' THEN
            lv_recipient_id         := TRIM(header_parameter_rec.meaning);
          ELSIF header_parameter_rec.lookup_code ='RECIPIENT_NAME' THEN
            lv_recipient_name := TRIM(header_parameter_rec.meaning);
          ELSIF header_parameter_rec.lookup_code ='FILE_CREATION_DATE' THEN
            lv_file_creation_date   := TRIM(header_parameter_rec.meaning);
          ELSIF header_parameter_rec.lookup_code ='FILE_CREATION_TIME' THEN
            lv_file_creation_time  := TRIM(header_parameter_rec.meaning);
          END IF;

     END LOOP;
     CLOSE c_get_header_parameters;

     fnd_file.new_line(fnd_file.output,1);
     fnd_file.put_line(fnd_file.output, lv_header);
     fnd_file.new_line(fnd_file.output,1);
     fnd_file.put_line(fnd_file.output, RPAD(lv_source_id,30)       || ' : '|| RPAD(l_source_id,40) || RPAD(lv_source_name,30)      || ' : '|| l_source_name );
     fnd_file.put_line(fnd_file.output, RPAD(lv_recipient_id,30)    || ' : '|| RPAD(l_recipient_id,40) || RPAD(lv_recipient_name,30)    || ' : '|| l_recipient_name);
     fnd_file.put_line(fnd_file.output, RPAD(lv_file_creation_date,30)  || ' : '|| RPAD(l_file_creation_dt,40) || RPAD(lv_file_creation_time,30)  || ' : '|| l_file_creation_time);
     fnd_file.new_line(fnd_file.output,1);


     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','after print header');
     END IF;

     OPEN c_get_trailer_parameters;
     LOOP
          FETCH c_get_trailer_parameters INTO  trailer_parameter_rec;
          EXIT WHEN c_get_trailer_parameters%NOTFOUND;

          IF trailer_parameter_rec.lookup_code ='TRAILER' THEN
            lv_trailer  := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_DISBURSEMNT_RECORD_COUNT' THEN
            lv_number_rec  := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_NET_DISBURSEMENT_AMOUNT' THEN
            lv_tot_net_disb_amt     := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_NET_EFT_AMOUNT' THEN
            lv_tot_net_eft_amt        := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_NET_NON-EFT_AMOUNT' THEN
            lv_tot_net_non_eft_amt := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_REISSUE_AMOUNT' THEN
          lv_tot_reissue_amt     := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_CANCELLATION_AMOUNT' THEN
           lv_tot_cancel_amt   := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_DEFICIT_AMOUNT' THEN
            lv_tot_deficit_amt := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_NETED_CANCELATION_AMOUNT' THEN
            lv_tot_net_cancel_amt    := TRIM(trailer_parameter_rec.meaning);
          ELSIF trailer_parameter_rec.lookup_code ='TOTAL_NETED_OUTSTNDING_CAMOUNT' THEN
           lv_tot_net_out_cancel_amt  := TRIM(trailer_parameter_rec.meaning);
          END IF;

     END LOOP;
     CLOSE c_get_trailer_parameters;


     fnd_file.new_line(fnd_file.output,1);
     fnd_file.put_line(fnd_file.output, lv_trailer);
     fnd_file.new_line(fnd_file.output,1);
     fnd_file.put_line(fnd_file.output, RPAD(lv_number_rec,50)             || ' : '|| l_number_rec);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_net_disb_amt ,50)      || ' : '|| l_tot_net_disb_amt);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_net_eft_amt,50)        || ' : '|| l_tot_net_eft_amt);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_net_non_eft_amt,50)    || ' : '|| l_tot_net_non_eft_amt);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_reissue_amt,50)        || ' : '|| l_tot_reissue_amt);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_cancel_amt,50)         || ' : '|| l_tot_cancel_amt);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_deficit_amt,50)        || ' : '|| l_tot_deficit_amt);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_net_cancel_amt ,50)    || ' : '|| l_tot_net_cancel_amt);
     fnd_file.put_line(fnd_file.output, RPAD(lv_tot_net_out_cancel_amt,50) || ' : '|| l_tot_net_out_cancel_amt);
     fnd_file.new_line(fnd_file.output,1);



     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','after print trailer');
     END IF;
        --Insert records into IGF_DB_CL_DISB_RESP
       OPEN cur_roster_logs;
       LOOP
          FETCH cur_roster_logs INTO  roster_logs_rec;
          EXIT WHEN cur_roster_logs%NOTFOUND;

          IF roster_logs_rec.lookup_code ='DISBURSEMENT_ROSTER_@1_DETAIL' THEN
            lv_disb                         := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='RECORD_TYPE' THEN
            lv_record_type                     := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='LOAN_SEQUENCE_NUMBER' THEN
            lv_loan_sequence_number            := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='LOAN_NUMBER' THEN
            lv_loan_number                     := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='LOAN_PERIOD_END_DATE' THEN
            lv_loan_period_end_date            := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='LOAN_PERIOD_START_DATE' THEN
            lv_loan_period_start_date          := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='LENDER_ID' THEN
            lv_lender_id                       := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='LENDER_NON_ED_BRANCH_ID' THEN
            lv_lender_non_ed_branch_id         := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='TOTAL_SCHEDULED_DISBURSEMENT' THEN
            lv_total_schd_disb    := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='DISBURSEMENT_NUMBER' THEN
            lv_disbursement_number             := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='GUARANTOR_ID' THEN
             lv_guarantor_id                   := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='GUARANTEE_DATE' THEN
            lv_guarantee_date                  := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='GUARANTEE_AMOUNT' THEN
            lv_guarantee_amount                := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='FUND_RELEASE_DATE' THEN
            lv_fund_release_date               := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='GROSS_DISBURSEMENT_AMOUNT' THEN
            lv_gross_disbursement_amount       := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='GUARANTEE_FEES' THEN
            lv_guarantee_fees                  := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='ORIGINATION_FEES_PAID' THEN
            lv_origination_fees_paid           := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='ORIGINATION_FEES' THEN
            lv_origination_fees                := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='GUARANTEE_FEES_PAID' THEN
            lv_guarantee_fees_paid             := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='NET_DISBURSEMENT_AMOUNT' THEN
            lv_net_disbursement_amount         := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='FEES_PAID' THEN
             lv_fees_paid                      := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='FUND_DISTRIBUTION_METHOD' THEN
             lv_fund_distribution_method       := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='CHECK_NUMBER' THEN
             lv_check_number                   := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='LATE_DISBURSEMENT' THEN
             lv_late_disbursement              := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='PREVIOUSLY_REPORTED' THEN
             lv_previously_reported            := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='NET_CANCELLATION_AMOUNT' THEN
            lv_net_cancellation_amount         := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='NETTED_CANCEL_AMOUNT' THEN
             lv_netted_cancel_amount           := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='OUTSTANDING_CANCELATION_AMOUNT' THEN
            lv_outstanding_can_amt             := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='ESIGN_SRC_TYP_CD' THEN
            lv_esign_src_typ_cd                := TRIM(roster_logs_rec.meaning);
          ELSIF roster_logs_rec.lookup_code ='DIRECT_TO_BORR_IND' THEN
            lv_direct_to_borr_ind_mng          := TRIM(roster_logs_rec.meaning);
          END IF;
       END LOOP;
       CLOSE cur_roster_logs;

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','begin data processing ');
       END IF;

       fnd_file.new_line(fnd_file.output,1);
       fnd_file.put_line(fnd_file.output, lv_disb);

       FOR  db_rec IN c_dbcl
       LOOP

       BEGIN

          SAVEPOINT IGFDB04B_SP1_1;
          l_actual_rec    :=  l_actual_rec + 1;
          l_rowid         :=  NULL;


          l_record_type          := LTRIM(RTRIM(SUBSTR(db_rec.record_data,3,1)));
          l_loan_number          := LTRIM(RTRIM(SUBSTR(db_rec.record_data,4,17)));
          l_cl_seq_number        := LTRIM(RTRIM(SUBSTR(db_rec.record_data,21,2)));
          l_loan_per_start_date  := TO_DATE(TRIM(SUBSTR(db_rec.record_data,280,8)),'YYYYMMDD');
          l_loan_per_end_date    := TO_DATE(TRIM(SUBSTR(db_rec.record_data,288,8)),'YYYYMMDD');
          l_lender_id            := LTRIM(RTRIM(SUBSTR(db_rec.record_data,301,6)));
          l_lend_non_ed_brc_id   := LTRIM(RTRIM(SUBSTR(db_rec.record_data,307,4)));
          l_tot_sched_disb       := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,332,2)));
          l_disb_num             := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,342,1)));
          l_guarantor_id         := LTRIM(RTRIM(SUBSTR(db_rec.record_data,344,3)));
          l_guarantee_date       := TO_DATE(SUBSTR(db_rec.record_data,370,8),'YYYYMMDD'); --pssahni change fnd_date.string_to_date to TO_DATE
          l_guarantee_amt        := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,378,5)));
          l_fund_release_date    := TO_DATE(SUBSTR(db_rec.record_data,334,8),'YYYYMMDD');  --pssahni change fnd_date.string_to_date to TO_DATE
          l_gross_disb_amt       := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,383,7)))/100;       -- 9(005)V99
          l_fee_1                := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,390,7)))/100;
          l_fee_2                := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,397,7)))/100;
          l_net_disb_amt         := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,404,7)))/100;
          l_fund_dist_mthd       := LTRIM(RTRIM(SUBSTR(db_rec.record_data,411,1)));
          l_check_number         := LTRIM(RTRIM(SUBSTR(db_rec.record_data,412,15)));
          l_late_disb_ind        := LTRIM(RTRIM(SUBSTR(db_rec.record_data,427,1)));
          l_prev_reported_ind    := LTRIM(RTRIM(SUBSTR(db_rec.record_data,428,1)));
          l_net_cancel_amt       := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,466,7)))/100;

         IF g_cl_version  = 'RELEASE-5' THEN
               l_hold_rel_ind          :=  LTRIM(RTRIM(SUBSTR(db_rec.record_data,500,1)));
               l_pnote_code            :=  LTRIM(RTRIM(SUBSTR(db_rec.record_data,501,2)));
               l_pnote_status_date     :=  TO_DATE(SUBSTR(db_rec.record_data,503,14),'YYYYMMDDHH24MISS');  --pssahni change fnd_date.string_to_date to TO_DATE
               l_fee_paid_1            :=  TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,517,7)))/100;
               --Build FA163
	             l_fee_paid_2            :=  TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,444,7)))/100;
	             l_direct_to_borr_ind    :=  NVL(SUBSTR(db_rec.record_data,482,1),' ');
               l_netted_cancel_amt     :=  TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,524,7)))/100;
               l_outstd_cancel_amt     :=  TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,531,7)))/100;
               l_sch_non_ed_brc_id     :=  LTRIM(RTRIM(SUBSTR(db_rec.record_data,538,4)));
         ELSIF g_cl_version  = 'RELEASE-4' THEN
               l_pnote_code          := NULL;
               l_pnote_status_date   := NULL;
               l_fee_paid_1          := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,482,5)))/100;   --Build FA163
    	         l_fee_paid_2          := TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,487,5)))/100;
	             l_direct_to_borr_ind  := NVL(SUBSTR(db_rec.record_data,492,1),' ');
               l_netted_cancel_amt   := NULL;
               l_outstd_cancel_amt   := NULL;
               l_sch_non_ed_brc_id   := NULL;
         END IF;
         fnd_file.new_line(fnd_file.output,1);
         fnd_file.put_line(fnd_file.output, RPAD(lv_record_type,40)                       || ' : '|| l_record_type);
         fnd_file.put_line(fnd_file.output, RPAD(lv_loan_number,40)                       || ' : '|| RPAD(l_loan_number,40)         || RPAD(lv_loan_sequence_number,30)                 || ' : '|| l_cl_seq_number);
         fnd_file.put_line(fnd_file.output, RPAD(lv_loan_period_start_date,40)            || ' : '|| RPAD(l_loan_per_start_date,40) || RPAD(lv_loan_period_end_date,30)            || ' : '|| l_loan_per_end_date);
         fnd_file.put_line(fnd_file.output, RPAD(lv_lender_id,40)                         || ' : '|| RPAD(l_lender_id,40)           || RPAD(lv_lender_non_ed_branch_id,30)         || ' : '|| l_lend_non_ed_brc_id);
         fnd_file.put_line(fnd_file.output, RPAD(lv_total_schd_disb,40)                   || ' : '|| RPAD(l_tot_sched_disb,40)      || RPAD(lv_disbursement_number,30)                  || ' : '|| l_disb_num );
         fnd_file.put_line(fnd_file.output, RPAD(lv_guarantor_id,40)                      || ' : '|| RPAD(l_guarantor_id,40)        || RPAD(lv_guarantee_date,30)                  || ' : '|| l_guarantee_date );
         fnd_file.put_line(fnd_file.output, RPAD(lv_guarantee_amount ,40)                 || ' : '|| l_guarantee_amt);
         fnd_file.put_line(fnd_file.output, RPAD(lv_fund_release_date,40)                 || ' : '|| l_fund_release_date);
         fnd_file.put_line(fnd_file.output, RPAD(lv_gross_disbursement_amount,40)         || ' : '|| RPAD(l_gross_disb_amt,40)     || RPAD(lv_guarantee_fees,30)         || ' : '|| l_fee_2);
         fnd_file.put_line(fnd_file.output, RPAD(lv_origination_fees_paid,40)             || ' : '|| RPAD(l_fee_paid_1,40)         || RPAD(lv_origination_fees,30)                  || ' : '|| l_fee_1 );
         fnd_file.put_line(fnd_file.output, RPAD(lv_guarantee_fees_paid ,40)              || ' : '|| RPAD(NVL(l_fee_paid_2,0),40)  || RPAD( lv_net_disbursement_amount,30)                  || ' : '|| l_net_disb_amt );
         fnd_file.put_line(fnd_file.output, RPAD(lv_fund_distribution_method ,40)         || ' : '|| RPAD(l_fund_dist_mthd,40)     || RPAD(lv_check_number,30)                  || ' : '|| l_check_number);
         fnd_file.put_line(fnd_file.output, RPAD(lv_late_disbursement ,40)                || ' : '|| RPAD(l_late_disb_ind,40)      || RPAD(lv_previously_reported,30)                  || ' : '|| l_prev_reported_ind);
         fnd_file.put_line(fnd_file.output, RPAD(lv_net_cancellation_amount,40)           || ' : '|| RPAD(l_net_cancel_amt,40)     || RPAD(lv_netted_cancel_amount,30)                  || ' : '|| NVL(l_netted_cancel_amt,0)  );
         fnd_file.put_line(fnd_file.output, RPAD(lv_outstanding_can_amt,40)               || ' : '|| NVL(l_outstd_cancel_amt,0));
         fnd_file.put_line(fnd_file.output, RPAD(lv_esign_src_typ_cd,40)                  || ' : '|| LTRIM(RTRIM(SUBSTR(db_rec.record_data,473,9))));
         fnd_file.put_line(fnd_file.output, RPAD(lv_direct_to_borr_ind_mng,40)            || ' : '|| l_direct_to_borr_ind);
         fnd_file.new_line(fnd_file.output,1);
         igf_db_cl_disb_resp_pkg.insert_row (x_mode                 => 'R',
                                             x_rowid                => l_rowid,
                                             x_cdbr_id              => l_cdbr_id,
                                             x_cbth_id              => l_cbth_id,
                                             x_record_type          => l_record_type ,
                                             x_loan_number          => l_loan_number,
                                             x_cl_seq_number        => l_cl_seq_number,
                                             x_b_last_name          => LTRIM(RTRIM(SUBSTR(db_rec.record_data,23,35))),
                                             x_b_first_name         => LTRIM(RTRIM(SUBSTR(db_rec.record_data,58,12))),
                                             x_b_middle_name        => LTRIM(RTRIM(SUBSTR(db_rec.record_data,70,1))),
                                             x_b_ssn                => LTRIM(RTRIM(SUBSTR(db_rec.record_data,71,9))),
                                             x_b_addr_line_1        => LTRIM(RTRIM(SUBSTR(db_rec.record_data,80,30))),
                                             x_b_addr_line_2        => LTRIM(RTRIM(SUBSTR(db_rec.record_data,110,30))),
                                             x_b_city               => LTRIM(RTRIM(SUBSTR(db_rec.record_data,140,24))),
                                             x_b_state              => LTRIM(RTRIM(SUBSTR(db_rec.record_data,170,2))),
                                             x_b_zip                => LTRIM(RTRIM(SUBSTR(db_rec.record_data,172,5))),
                                             x_b_zip_suffix         => LTRIM(RTRIM(SUBSTR(db_rec.record_data,177,4))),
                                             x_b_addr_chg_date      => fnd_date.string_to_date(SUBSTR(db_rec.record_data,181,8),'YYYYMMDD'),
                                             x_eft_auth_code        => LTRIM(RTRIM(SUBSTR(db_rec.record_data,189,1))),
                                             x_s_last_name          => LTRIM(RTRIM(SUBSTR(db_rec.record_data,190,35))),
                                             x_s_first_name         => LTRIM(RTRIM(SUBSTR(db_rec.record_data,225,12))),
                                             x_s_middle_initial     => LTRIM(RTRIM(SUBSTR(db_rec.record_data,237,1))),
                                             x_s_ssn                => LTRIM(RTRIM(SUBSTR(db_rec.record_data,238,9))),
                                             x_school_id            => TO_NUMBER(TRIM(SUBSTR(db_rec.record_data,247,8))),
                                             x_school_use           => LTRIM(RTRIM(SUBSTR(db_rec.record_data,257,23))),
                                             x_loan_per_start_date  => l_loan_per_start_date,
                                             x_loan_per_end_date    => l_loan_per_end_date,
                                             x_cl_loan_type         => LTRIM(RTRIM(SUBSTR(db_rec.record_data,296,2))),
                                             x_alt_prog_type_code   => LTRIM(RTRIM(SUBSTR(db_rec.record_data,298,3))),
                                             x_lender_id            => l_lender_id,
                                             x_lend_non_ed_brc_id   => l_lend_non_ed_brc_id ,
                                             x_lender_use           => LTRIM(RTRIM(SUBSTR(db_rec.record_data,311,20))),
                                             x_borw_confirm_ind     => LTRIM(RTRIM(SUBSTR(db_rec.record_data,331,1))),
                                             x_tot_sched_disb       => l_tot_sched_disb,
                                             x_fund_release_date    => l_fund_release_date,
                                             x_disb_num             => l_disb_num,
                                             x_guarantor_id         => l_guarantor_id,
                                             x_guarantor_use        => LTRIM(RTRIM(SUBSTR(db_rec.record_data,347,23))),
                                             x_guarantee_date       => l_guarantee_date,
                                             x_guarantee_amt        => l_guarantee_amt,
                                             x_gross_disb_amt       => l_gross_disb_amt,
                                             x_fee_1                => l_fee_1,
                                             x_fee_2                => l_fee_2,
                                             x_net_disb_amt         => l_net_disb_amt ,
                                             x_fund_dist_mthd       => l_fund_dist_mthd,
                                             x_check_number         => l_check_number,
                                             x_late_disb_ind        => l_late_disb_ind,
                                             x_prev_reported_ind    => l_prev_reported_ind,
                                             x_err_code1            => LTRIM(RTRIM(SUBSTR(db_rec.record_data,429,3))),
                                             x_err_code2            => LTRIM(RTRIM(SUBSTR(db_rec.record_data,432,3))),
                                             x_err_code3            => LTRIM(RTRIM(SUBSTR(db_rec.record_data,435,3))),
                                             x_err_code4            => LTRIM(RTRIM(SUBSTR(db_rec.record_data,438,3))),
                                             x_err_code5            => LTRIM(RTRIM(SUBSTR(db_rec.record_data,441,3))),
                                             x_fee_paid_2           => l_fee_paid_2,
                                             x_lender_name          => LTRIM(RTRIM(SUBSTR(db_rec.record_data,451,15))),
                                             x_net_cancel_amt       => l_net_cancel_amt,
                                             x_duns_lender_id       => NULL,
                                             x_duns_guarnt_id       => NULL,
                                             x_hold_rel_ind         => l_hold_rel_ind,
                                             x_pnote_code           => l_pnote_code,
                                             x_pnote_status_date    => l_pnote_status_date,
                                             x_fee_paid_1           => l_fee_paid_1,
                                             x_netted_cancel_amt    => l_netted_cancel_amt,
                                             x_outstd_cancel_amt    => l_outstd_cancel_amt,
                                             x_sch_non_ed_brc_id    => l_sch_non_ed_brc_id,
                                             x_status               => 'N',
                                             x_esign_src_typ_cd     => LTRIM(RTRIM(SUBSTR(db_rec.record_data,473,9))),
                                             x_direct_to_borr_flag  => l_direct_to_borr_ind);

         -- FA 161 CL4 Updates build.
         lv_esign_roster_data := LTRIM(RTRIM(SUBSTR(db_rec.record_data, 473, 9)));
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','Esign src typ code in roster = '||lv_esign_roster_data);
         END IF;

         IF LENGTH(lv_esign_roster_data) > 0 THEN
           OPEN cur_lor_data(l_loan_number);
           FETCH cur_lor_data INTO rec_lor_data;
           IF cur_lor_data%NOTFOUND THEN
             CLOSE cur_lor_data;
             RAISE SKIP_THIS_RECORD;
           ELSE
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.cl_load_data.debug','Esign src typ code in system = '||NVL(rec_lor_data.esign_src_typ_cd,'*'));
              END IF;
             IF NVL(rec_lor_data.esign_src_typ_cd,'*') <> lv_esign_roster_data THEN
               igf_sl_lor_pkg.update_row (
                    X_Mode                              => 'R',
                    x_rowid                             => rec_lor_data.row_id,
                    x_origination_id                    => rec_lor_data.origination_id,
                    x_loan_id                           => rec_lor_data.loan_id,
                    x_sch_cert_date                     => rec_lor_data.sch_cert_date,
                    x_orig_status_flag                  => rec_lor_data.orig_status_flag,
                    x_orig_batch_id                     => rec_lor_data.orig_batch_id,
                    x_orig_batch_date                   => rec_lor_data.orig_batch_date,
                    x_chg_batch_id                      => rec_lor_data.chg_batch_id,
                    x_orig_ack_date                     => rec_lor_data.orig_ack_date,
                    x_credit_override                   => rec_lor_data.credit_override,
                    x_credit_decision_date              => rec_lor_data.credit_decision_date,
                    x_req_serial_loan_code              => rec_lor_data.req_serial_loan_code,
                    x_act_serial_loan_code              => rec_lor_data.act_serial_loan_code,
                    x_pnote_delivery_code               => rec_lor_data.pnote_delivery_code,
                    x_pnote_status                      => rec_lor_data.pnote_status,
                    x_pnote_status_date                 => rec_lor_data.pnote_status_date,
                    x_pnote_id                          => rec_lor_data.pnote_id,
                    x_pnote_print_ind                   => rec_lor_data.pnote_print_ind,
                    x_pnote_accept_amt                  => rec_lor_data.pnote_accept_amt,
                    x_pnote_accept_date                 => rec_lor_data.pnote_accept_date,
                    x_unsub_elig_for_heal               => rec_lor_data.unsub_elig_for_heal,
                    x_disclosure_print_ind              => rec_lor_data.disclosure_print_ind,
                    x_orig_fee_perct                    => rec_lor_data.orig_fee_perct,
                    x_borw_confirm_ind                  => rec_lor_data.borw_confirm_ind,
                    x_borw_interest_ind                 => rec_lor_data.borw_interest_ind,
                    x_borw_outstd_loan_code             => rec_lor_data.borw_outstd_loan_code,
                    x_unsub_elig_for_depnt              => rec_lor_data.unsub_elig_for_depnt,
                    x_guarantee_amt                     => rec_lor_data.guarantee_amt,
                    x_guarantee_date                    => rec_lor_data.guarantee_date,
                    x_guarnt_amt_redn_code              => rec_lor_data.guarnt_amt_redn_code,
                    x_guarnt_status_code                => rec_lor_data.guarnt_status_code,
                    x_guarnt_status_date                => rec_lor_data.guarnt_status_date,
                    x_lend_apprv_denied_code            => rec_lor_data.lend_apprv_denied_code, --NULL,
                    x_lend_apprv_denied_date            => rec_lor_data.lend_apprv_denied_date, --NULL,
                    x_lend_status_code                  => rec_lor_data.lend_status_code,
                    x_lend_status_date                  => rec_lor_data.lend_status_date,
                    x_guarnt_adj_ind                    => rec_lor_data.guarnt_adj_ind,
                    x_grade_level_code                  => rec_lor_data.grade_level_code,
                    x_enrollment_code                   => rec_lor_data.enrollment_code,
                    x_anticip_compl_date                => rec_lor_data.anticip_compl_date,
                    x_borw_lender_id                    => rec_lor_data.borw_lender_id, --NULL,
                    x_duns_borw_lender_id               => rec_lor_data.duns_borw_lender_id, --NULL,
                    x_guarantor_id                      => rec_lor_data.guarantor_id, --NULL,
                    x_duns_guarnt_id                    => rec_lor_data.duns_guarnt_id, --NULL,
                    x_prc_type_code                     => rec_lor_data.prc_type_code,
                    x_cl_seq_number                     => rec_lor_data.cl_seq_number,
                    x_last_resort_lender                => rec_lor_data.last_resort_lender,
                    x_lender_id                         => rec_lor_data.lender_id, --NULL,
                    x_duns_lender_id                    => rec_lor_data.duns_lender_id, --NULL,
                    x_lend_non_ed_brc_id                => rec_lor_data.lend_non_ed_brc_id, --NULL,
                    x_recipient_id                      => rec_lor_data.recipient_id, --NULL,
                    x_recipient_type                    => rec_lor_data.recipient_type, --NULL,
                    x_duns_recip_id                     => rec_lor_data.duns_recip_id, --NULL,
                    x_recip_non_ed_brc_id               => rec_lor_data.recip_non_ed_brc_id, --NULL,
                    x_rec_type_ind                      => rec_lor_data.rec_type_ind,
                    x_cl_loan_type                      => rec_lor_data.cl_loan_type,
                    x_cl_rec_status                     => rec_lor_data.cl_rec_status, --NULL,
                    x_cl_rec_status_last_update         => rec_lor_data.cl_rec_status_last_update, --NULL,
                    x_alt_prog_type_code                => rec_lor_data.alt_prog_type_code,
                    x_alt_appl_ver_code                 => rec_lor_data.alt_appl_ver_code,
                    x_mpn_confirm_code                  => rec_lor_data.mpn_confirm_code, --NULL,
                    x_resp_to_orig_code                 => rec_lor_data.resp_to_orig_code,
                    x_appl_loan_phase_code              => rec_lor_data.appl_loan_phase_code, --NULL,
                    x_appl_loan_phase_code_chg          => rec_lor_data.appl_loan_phase_code_chg, --NULL,
                    x_appl_send_error_codes             => rec_lor_data.appl_send_error_codes, --NULL,
                    x_tot_outstd_stafford               => rec_lor_data.tot_outstd_stafford,
                    x_tot_outstd_plus                   => rec_lor_data.tot_outstd_plus,
                    x_alt_borw_tot_debt                 => rec_lor_data.alt_borw_tot_debt,
                    x_act_interest_rate                 => rec_lor_data.act_interest_rate,
                    x_service_type_code                 => rec_lor_data.service_type_code,
                    x_rev_notice_of_guarnt              => rec_lor_data.rev_notice_of_guarnt,
                    x_sch_refund_amt                    => rec_lor_data.sch_refund_amt,
                    x_sch_refund_date                   => rec_lor_data.sch_refund_date,
                    x_uniq_layout_vend_code             => rec_lor_data.uniq_layout_vend_code,
                    x_uniq_layout_ident_code            => rec_lor_data.uniq_layout_ident_code,
                    x_p_person_id                       => rec_lor_data.p_person_id,
                    x_p_ssn_chg_date                    => rec_lor_data.p_ssn_chg_date, --NULL,
                    x_p_dob_chg_date                    => rec_lor_data.p_dob_chg_date, --NULL,
                    x_p_permt_addr_chg_date             => rec_lor_data.p_permt_addr_chg_date, --NULL,
                    x_p_default_status                  => rec_lor_data.p_default_status,
                    x_p_signature_code                  => rec_lor_data.p_signature_code,
                    x_p_signature_date                  => rec_lor_data.p_signature_date,
                    x_s_ssn_chg_date                    => rec_lor_data.s_ssn_chg_date, --NULL,
                    x_s_dob_chg_date                    => rec_lor_data.s_dob_chg_date, --NULL,
                    x_s_permt_addr_chg_date             => rec_lor_data.s_permt_addr_chg_date, --NULL,
                    x_s_local_addr_chg_date             => rec_lor_data.s_local_addr_chg_date, --NULL,
                    x_s_default_status                  => rec_lor_data.s_default_status,
                    x_s_signature_code                  => rec_lor_data.s_signature_code,
                    x_pnote_batch_id                    => rec_lor_data.pnote_batch_id,
                    x_pnote_ack_date                    => rec_lor_data.pnote_ack_date,
                    x_pnote_mpn_ind                     => rec_lor_data.pnote_mpn_ind ,
                    x_elec_mpn_ind                      => rec_lor_data.elec_mpn_ind         ,
                    x_borr_sign_ind                     => rec_lor_data.borr_sign_ind        ,
                    x_stud_sign_ind                     => rec_lor_data.stud_sign_ind        ,
                    x_borr_credit_auth_code             => rec_lor_data.borr_credit_auth_code ,
                    x_relationship_cd                   => rec_lor_data.relationship_cd,
                    x_interest_rebate_percent_num       => rec_lor_data.interest_rebate_percent_num,
                    x_cps_trans_num                     => rec_lor_data.cps_trans_num   ,
                    x_atd_entity_id_txt                 => rec_lor_data.atd_entity_id_txt,
                    x_rep_entity_id_txt                 => rec_lor_data.rep_entity_id_txt,
                    x_crdt_decision_status              => rec_lor_data.crdt_decision_status,
                    x_note_message                      => rec_lor_data.note_message        ,
                    x_book_loan_amt                     => rec_lor_data.book_loan_amt       ,
                    x_book_loan_amt_date                => rec_lor_data.book_loan_amt_date,
                    x_actual_record_type_code           => rec_lor_data.actual_record_type_code,
                    x_alt_approved_amt                  => rec_lor_data.alt_approved_amt,
                    x_deferment_request_code            => rec_lor_data.deferment_request_code,
                    x_eft_authorization_code            => rec_lor_data.eft_authorization_code,
                    x_external_loan_id_txt              => rec_lor_data.external_loan_id_txt,
                    x_flp_approved_amt                  => rec_lor_data.flp_approved_amt,
                    x_fls_approved_amt                  => rec_lor_data.fls_approved_amt,
                    x_flu_approved_amt                  => rec_lor_data.flu_approved_amt,
                    x_guarantor_use_txt                 => rec_lor_data.guarantor_use_txt,
                    x_lender_use_txt                    => rec_lor_data.lender_use_txt,
                    x_loan_app_form_code                => rec_lor_data.loan_app_form_code,
                    x_override_grade_level_code         => rec_lor_data.override_grade_level_code,
                    x_pymt_servicer_amt                 => rec_lor_data.pymt_servicer_amt,
                    x_pymt_servicer_date                => rec_lor_data.pymt_servicer_date,
                    x_reinstatement_amt                 => rec_lor_data.reinstatement_amt,
                    x_requested_loan_amt                => rec_lor_data.requested_loan_amt,
                    x_school_use_txt                    => rec_lor_data.school_use_txt,
                    x_b_alien_reg_num_txt               => rec_lor_data.b_alien_reg_num_txt,
                    x_esign_src_typ_cd                  => lv_esign_roster_data,
                    x_acad_begin_date                   => rec_lor_data.acad_begin_date,
                    x_acad_end_date                     => rec_lor_data.acad_end_date
               );
             END IF;
           END IF;
           CLOSE cur_lor_data;
         END IF;

       EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO IGFDB04B_SP1_1;
          fnd_message.set_name('IGF','IGF_SL_DB_ERROR_UPLOAD');
          fnd_file.put_line(fnd_file.log, fnd_message.get||' '||SQLERRM);
          fnd_message.set_name('IGF','IGF_SL_SKIPPING');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log, 1);
       END;

       END LOOP;
       IF l_actual_rec <> l_number_rec THEN
           fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
           igs_ge_msg_stack.add;
           RAISE FILE_NOT_LOADED;
       END IF;
       p_cbth_id := l_cbth_id;

EXCEPTION
WHEN FILE_NOT_LOADED THEN
   RAISE;
WHEN CLSETUP_NOT_FOUND THEN
   RAISE;
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_DB_CL_ROSTER.CL_LOAD_DATA');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END cl_load_data;


-- ######### Main Procedure ################## --

PROCEDURE roster_ack(errbuf        OUT NOCOPY    VARCHAR2,
                     retcode       OUT NOCOPY    NUMBER,
                     p_update_disb IN VARCHAR2)
AS
  /*************************************************************
  Created By : sjadhav
  Date Created On : 2000/12/18

  Purpose :This is the procedeure called by con prog.
  This procedure updates igf_aw_awd_disb table based on
  certain conditions.
  This process will set the status of all the records
  processed as 'Processed' in the igf_db_cl_disb_resp
  table.

  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ridas           07-Aug-2006     Build FA163. Added condition to check the Direct_to_borr_ind difference between
                                  the roster information and the disbursement table information.
  tsailaja		    13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  veramach        3-NOV-2003      FA 125 Multiple Distr Methods
                                  Changed the call of igf_aw_awd_disb_pkg.update_row to reflect the addition of attendance_type_code
  ***************************************************************/

  l_cbth_id               igf_sl_cl_batch_all.cbth_id%TYPE;
  l_loan_number           igf_db_cl_disb_resp_all.loan_number%TYPE;
  l_disb_num              igf_aw_awd_disb_all.disb_num%TYPE;

  l_disb_gross_amt        igf_db_cl_disb_resp_all.gross_disb_amt%TYPE;
  l_fee_1                 igf_db_cl_disb_resp_all.fee_1%TYPE;
  l_fee_2                 igf_db_cl_disb_resp_all.fee_2%TYPE;
  l_net_disb_amt          igf_db_cl_disb_resp_all.net_disb_amt%TYPE;
  l_fee_paid_2            igf_db_cl_disb_resp_all.fee_paid_2%TYPE;
  l_fee_paid_1            igf_db_cl_disb_resp_all.fee_paid_1%TYPE;

  l_late_disb_ind         igf_db_cl_disb_resp_all.late_disb_ind%TYPE;
  l_fund_dist_mthd        igf_db_cl_disb_resp_all.fund_dist_mthd%TYPE;
  l_prev_reported_ind     igf_db_cl_disb_resp_all.prev_reported_ind%TYPE;
  l_fund_release_date     igf_db_cl_disb_resp_all.fund_release_date%TYPE;
  l_check_number          igf_db_cl_disb_resp_all.check_number%TYPE;
  l_rec_type              igf_db_cl_disb_resp_all.record_type%TYPE;
  lv_rec_status           igf_db_cl_disb_resp_all.status%TYPE;
  l_direct_to_borr_ind    igf_db_cl_disb_resp_all.direct_to_borr_flag%TYPE;

  CURSOR cur_db_resp(l_cbth_id igf_sl_cl_batch_all.cbth_id%TYPE) IS
    SELECT cdresp.* FROM igf_db_cl_disb_resp cdresp
    WHERE  cbth_id = l_cbth_id
    AND    status  = 'N'
    FOR UPDATE OF status NOWAIT;


   PROCEDURE log_start(p_loan_number      igf_sl_loans_all.loan_number%TYPE,
                       p_disb_num         igf_aw_awd_disb_all.disb_num%TYPE)
   AS
      l_msg_str_0   VARCHAR2(1000);
   BEGIN
          loan_number_desc   := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER');
          disb_num_desc      := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NUM');
          loc_disb_desc      := igf_aw_gen.lookup_desc('IGF_SL_GEN','LOC_DISB_DETAILS');
          ofa_disb_desc      := igf_aw_gen.lookup_desc('IGF_SL_GEN','OFA_DISB_DETAILS');
          fee_1_desc         := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_1');
          fee_2_desc         := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_2');
          disb_net_amt_desc  := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NET_AMT');
          fee_paid_1_desc    := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_PAID_1');
          fee_paid_2_desc    := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_PAID_2');
          disb_gross_amt_desc  := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_GROSS_AMT');
          direct_to_borr_ind_desc := igf_aw_gen.lookup_desc('IGF_SL_CL_ROSTER_LOGS','DIRECT_TO_BORR_IND');
          fnd_file.put_line(fnd_file.log, '');
          l_msg_str_0 := RPAD(loan_number_desc,30)||' : '|| p_loan_number ||'
'||RPAD(disb_num_desc,30) ||' : '||TO_CHAR(p_disb_num);

          fnd_file.put_line(fnd_file.log,l_msg_str_0);

   END log_start;


BEGIN

    igf_aw_gen.set_org_id(NULL);
    retcode := 0;
   -- Load the data into the Batch and Response Table

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.roster_ack.debug','Calling Load Data');
    END IF;

   cl_load_data(l_cbth_id);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.roster_ack.debug','After Load Data, Batch ID ' || l_cbth_id);
    END IF;

   --  Select all the records from IGF_DB_CL_DISB_RESP table
   --  with status = 'N' for the batch id returned by load process.

   FOR cbth_rec IN cur_db_resp(l_cbth_id) LOOP     -- Main FOR LOOP

     l_loan_number         :=    cbth_rec.loan_number;
     l_disb_num            :=    cbth_rec.disb_num;
     l_disb_gross_amt      :=    cbth_rec.gross_disb_amt;
     l_fee_1               :=    cbth_rec.fee_1;
     l_fee_2               :=    cbth_rec.fee_2;
     l_net_disb_amt        :=    cbth_rec.net_disb_amt;
     l_fee_paid_2          :=    cbth_rec.fee_paid_2;
     l_fee_paid_1          :=    cbth_rec.fee_paid_1;
     l_late_disb_ind       :=    cbth_rec.late_disb_ind;
     l_fund_dist_mthd      :=    cbth_rec.fund_dist_mthd;
     l_prev_reported_ind   :=    cbth_rec.prev_reported_ind;
     l_fund_release_date   :=    cbth_rec.fund_release_date;
     l_check_number        :=    cbth_rec.check_number;
     l_rec_type            :=    cbth_rec.record_type;
     l_direct_to_borr_ind  :=    cbth_rec.direct_to_borr_flag;

     DECLARE

         l_fund_status               igf_aw_awd_disb_all.fund_status%TYPE;
         l_awd_disb_accep_amt        igf_aw_awd_disb_all.disb_accepted_amt%TYPE;
         l_awd_fee_1                 igf_aw_awd_disb_all.fee_1%TYPE;
         l_awd_fee_2                 igf_aw_awd_disb_all.fee_2%TYPE;
         l_awd_net_disb_amt          igf_aw_awd_disb_all.disb_net_amt%TYPE;
         l_awd_fee_paid_2            igf_aw_awd_disb_all.fee_paid_2%TYPE;
         l_awd_fee_paid_1            igf_aw_awd_disb_all.fee_paid_1%TYPE;
         l_award_id                  igf_aw_awd_disb_all.award_id%TYPE;
         l_auto_late_ind             igf_sl_cl_setup_all.auto_late_disb_ind%TYPE;
         l_awd_direct_to_borr_ind    igf_aw_awd_disb_all.direct_to_borr_flag%TYPE;

         l_msg_str1                  VARCHAR2(1000);
         l_msg_str2                  VARCHAR2(4000);
         l_msg_str3                  VARCHAR2(1000);

         CURSOR  cur_awdisb(l_loan_number igf_db_cl_disb_resp_all.loan_number%TYPE,
                            l_disb_num    igf_aw_awd_disb_all.disb_num%TYPE)
         IS
         SELECT
                 disb.*
         FROM    igf_aw_awd_disb disb,igf_sl_loans_all loans
         WHERE
                 NVL(loans.external_loan_id_txt, loans.loan_number)   =  l_loan_number   AND
                 disb.award_id      =  loans.award_id  AND
                 disb.disb_num      =  l_disb_num
         FOR UPDATE OF disb.fund_status NOWAIT;

         disb_rec  cur_awdisb%ROWTYPE;

         CURSOR c_clset (p_award_id igf_aw_award_all.award_id%TYPE)
         IS
         SELECT clset.auto_late_disb_ind
         FROM   igf_sl_cl_setup_all clset
         WHERE  (ci_cal_type,ci_sequence_number,relationship_cd )
                IN
                (
                  SELECT base.ci_cal_type,base.ci_sequence_number, lor.relationship_cd
                  FROM   igf_ap_fa_base_rec_all base, igf_aw_award_all awd,
                         igf_sl_loans_all loans,igf_sl_lor_all lor
                  WHERE  base.base_id  = awd.base_id
                    AND  awd.award_id  = loans.award_id
                    AND  loans.loan_id = lor.loan_id
                    AND  awd.award_id  = p_award_id
                );


     BEGIN

           lv_rec_status      := 'N';
           log_start(l_loan_number, l_disb_num);
           -- Condition 0 : If there are any errors returned in the File, then Display and skip
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.roster_ack.debug','Start processing disb response rec 1 l_loan_number,l_disb_num ' || l_loan_number||' : ' || l_disb_num);
           END IF;

           IF cbth_rec.err_code1 IS NOT NULL
           OR cbth_rec.err_code2 IS NOT NULL
           OR cbth_rec.err_code3 IS NOT NULL
           OR cbth_rec.err_code4 IS NOT NULL
           OR cbth_rec.err_code5 IS NOT NULL THEN

              IF cbth_rec.err_code1 IS NOT NULL THEN
                fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',cbth_rec.err_code1));
              END IF;
              IF cbth_rec.err_code2 IS NOT NULL THEN
                fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',cbth_rec.err_code2));
              END IF;
              IF cbth_rec.err_code3 IS NOT NULL THEN
                fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',cbth_rec.err_code3));
              END IF;
              IF cbth_rec.err_code4 IS NOT NULL THEN
                fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',cbth_rec.err_code4));
              END IF;
              IF cbth_rec.err_code5 IS NOT NULL THEN
                fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_SL_CL_ERROR',cbth_rec.err_code5));
              END IF;
           END IF;


           -- Condition 1 : Check if there is a Disb-rec for this Loan-Number and Disb-Num
           OPEN  cur_awdisb(l_loan_number,l_disb_num);
           FETCH cur_awdisb INTO disb_rec;
           IF cur_awdisb%NOTFOUND THEN
                CLOSE cur_awdisb;
                  fnd_message.set_name('IGF','IGF_SL_NO_AWD_DISB');
                -- No Records in Award-Disbursement Table.
                fnd_file.new_line(fnd_file.log,1);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                fnd_file.new_line(fnd_file.log,1);
                lv_rec_status   := 'F';
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.roster_ack.debug','skip flag TRUE ');
                END IF;
                lv_rec_status         := 'F';
                RAISE SKIP_THIS_RECORD;
           END IF;
           IF cur_awdisb%FOUND THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.roster_ack.debug','loan disb found ');
              END IF;
                OPEN  c_clset(disb_rec.award_id);
                FETCH c_clset INTO l_auto_late_ind;
                IF c_clset%NOTFOUND THEN
                     CLOSE c_clset;
                     fnd_message.set_name('IGF','IGF_SL_NO_CL_SETUP');
                     fnd_file.put_line(fnd_file.log,fnd_message.get);
                     -- No Records in CommonLine Setup Table.
                     igs_ge_msg_stack.add;
                     RAISE CLSETUP_NOT_FOUND;
                END IF;
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.roster_ack.debug','loan setup found, l_auto_late_ind ' || l_auto_late_ind);
                END IF;
                CLOSE c_clset;
           END IF;

           l_fund_status       :=  disb_rec.fund_status;
           l_awd_disb_accep_amt:=  disb_rec.disb_accepted_amt;
           l_awd_fee_1         :=  disb_rec.fee_1;
           l_awd_fee_2         :=  disb_rec.fee_2;
           l_awd_net_disb_amt  :=  disb_rec.disb_net_amt;
           l_awd_fee_paid_1    :=  disb_rec.fee_paid_1;
           l_awd_fee_paid_2    :=  disb_rec.fee_paid_2;
           l_award_id          :=  disb_rec.award_id;
           l_awd_direct_to_borr_ind :=  disb_rec.direct_to_borr_flag;

           -- Condition 2 : Check if the Disbursement was already FUNDED.
           IF l_fund_status = 'Y'  THEN
               -- If the fund status is already funded then skip this record
               -- No updates for igf_aw_awd_disb table
               IF l_rec_type = 'N' THEN
                   fnd_message.set_name('IGF','IGF_DB_ROST_ALFND_NOUPD');
                   fnd_file.put_line(fnd_file.log,fnd_message.get);
                   fnd_file.new_line(fnd_file.log,1);
                   RAISE SKIP_THIS_RECORD;
               ELSE
                   lv_rec_status     := 'A';
                   fnd_message.set_name('IGF','IGF_DB_UPD_ROST_FUND');
                   fnd_file.put_line(fnd_file.log,fnd_message.get);
                   fnd_file.new_line(fnd_file.log,1);
               END IF;
           END IF;

           -- Condition 3 : Check if the Amounts are Different.
           -- If the fund staus is not funded then
           -- 1.Compare the amounts in the Roster File Records
           --   with those of in igf_aw_awd_disb
           --   records for this particular disb_num

           IF      NVL(l_disb_gross_amt,0)<>  NVL(l_awd_disb_accep_amt,0) OR
                   NVL(l_fee_1,0)         <>  NVL(l_awd_fee_1,0)          OR
                   NVL(l_fee_2,0)         <>  NVL(l_awd_fee_2,0)          OR
                   NVL(l_net_disb_amt,0)  <>  NVL(l_awd_net_disb_amt,0)   OR
                   NVL(l_fee_paid_1,0)    <>  NVL(l_awd_fee_paid_1,0)     OR
                   NVL(l_fee_paid_2,0)    <>  NVL(l_awd_fee_paid_2,0)     OR
                   NVL(l_direct_to_borr_ind,'*')    <>  NVL(l_awd_direct_to_borr_ind,'*')
           THEN

              l_msg_str2 := LPAD(' ',40)                || RPAD(loc_disb_desc,40)                     ||RPAD(ofa_disb_desc,40)                         ||'
'||
                            LPAD('-',120,'-')           ||'
'||
                            LPAD(disb_gross_amt_desc,30)|| LPAD(NVL(TO_CHAR(l_disb_gross_amt),' '),30)||LPAD(NVL(TO_CHAR(l_awd_disb_accep_amt),' '),30)||'
'||
                            LPAD(fee_1_desc,30)         || LPAD(NVL(TO_CHAR(l_fee_1),' '),30)         ||LPAD(NVL(TO_CHAR(l_awd_fee_1),' '),30)         ||'
'||
                            LPAD(fee_2_desc,30)         || LPAD(NVL(TO_CHAR(l_fee_2),' '),30)         ||LPAD(NVL(TO_CHAR(l_awd_fee_2),' '),30)         ||'
'||
                            LPAD(disb_net_amt_desc,30)  || LPAD(NVL(TO_CHAR(l_net_disb_amt),' '),30)  ||LPAD(NVL(TO_CHAR(l_awd_net_disb_amt),' '),30)  ||'
'||
                            LPAD(fee_paid_1_desc,30)    || LPAD(NVL(TO_CHAR(l_fee_paid_1),' '),30)    ||LPAD(NVL(TO_CHAR(l_awd_fee_paid_1),' '),30)    ||'
'||
                            LPAD(fee_paid_2_desc,30)    || LPAD(NVL(TO_CHAR(l_fee_paid_2),' '),30)    ||LPAD(NVL(TO_CHAR(l_awd_fee_paid_2),' '),30)    ||'
'||
                            LPAD(direct_to_borr_ind_desc,30)    || LPAD(NVL(l_direct_to_borr_ind,' '),30)    ||LPAD(NVL(l_awd_direct_to_borr_ind,' '),30);

              fnd_message.set_name('IGF','IGF_DB_INFO_DIFFER');
              --Amounts are different in file and table for this record
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              fnd_file.put_line(fnd_file.log,l_msg_str2);
              fnd_file.new_line(fnd_file.log,1);
             IF p_update_disb = 'N' THEN
                lv_rec_status      := 'D';
                fnd_message.set_name('IGF','IGF_DB_ROST_DIFF_NOUPD');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                fnd_file.new_line(fnd_file.log,1);
                RAISE SKIP_THIS_RECORD;
             ELSIF p_update_disb = 'Y' THEN
                 lv_rec_status     := 'U';
                 fnd_message.set_name('IGF','IGF_DB_ROST_DIFF_YSUPD');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                 fnd_file.new_line(fnd_file.log,1);
                 disb_rec.fee_1                := l_fee_1;
                 disb_rec.fee_2                := l_fee_2;
                 disb_rec.disb_net_amt         := l_net_disb_amt;
                 disb_rec.disb_accepted_amt    := l_disb_gross_amt;
                 disb_rec.fee_paid_1           := l_fee_paid_1;
                 disb_rec.fee_paid_2           := l_fee_paid_2;
                 disb_rec.direct_to_borr_flag  := l_direct_to_borr_ind;
             END IF;
          END IF;
          -- Condition 4 : Check if it is a Late Disbursement and Whether it should be auto Loaded ?
          -- If the fund staus is not funded then
          -- 2.a. If Auto Fund Late Disb is NO and
          --      Late Disb Ind Code is Y then
          --      show on Edit Report
          IF l_auto_late_ind = 'N' AND
             l_late_disb_ind = 'Y' THEN

                l_msg_str1 := RPAD(' '       ,40)         ||RPAD(loc_disb_desc,40)                     ||'
'||
                              LPAD(disb_gross_amt_desc,30)||LPAD(NVL(TO_CHAR(l_disb_gross_amt),' '),30)||'
'||
                              LPAD(fee_1_desc,30)         ||LPAD(NVL(TO_CHAR(l_fee_1),' '),30)         ||'
'||
                              LPAD(fee_2_desc,30)         ||LPAD(NVL(TO_CHAR(l_fee_2),' '),30)         ||'
'||
                              LPAD(disb_net_amt_desc,30)  ||LPAD(NVL(TO_CHAR(l_net_disb_amt),' '),30)  ||'
'||
                              LPAD(fee_paid_1_desc,30)    ||LPAD(NVL(TO_CHAR(l_fee_paid_1),' '),30)    ||'
'||
                              LPAD(fee_paid_2_desc,30)    ||LPAD(NVL(TO_CHAR(l_fee_paid_2),' '),30)    ||'
'||
                              LPAD(direct_to_borr_ind_desc,30)    ||LPAD(NVL(l_direct_to_borr_ind,' '),30);

                fnd_message.set_name('IGF','IGF_SL_LATE_DISB');
                -- Late disbursement set for this record.
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                fnd_file.put_line(fnd_file.log,l_msg_str1);
                lv_rec_status     := 'L';
                RAISE SKIP_THIS_RECORD;
          END IF;


          -- 2.b.Update igf_aw_awd_disb
          --      set the fund status = FUNDED
          IF lv_rec_status  = 'N' THEN
              lv_rec_status  := 'U';
              fnd_message.set_name('IGF','IGF_DB_UPD_ROST_FUND');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              fnd_file.new_line(fnd_file.log,1);
          END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_cl_roster.roster_ack.debug',
                          'Updating aw disb , award_id, disb_num, RESP_status ' || disb_rec.award_id || ' : ' || disb_rec.disb_num || ' : ' || lv_rec_status);
          END IF;

          igf_aw_awd_disb_pkg.update_row(
                     x_mode                 => 'R',
                     x_rowid                => disb_rec.row_id,
                     x_award_id             => disb_rec.award_id,
                     x_disb_num             => disb_rec.disb_num,
                     x_tp_cal_type          => disb_rec.tp_cal_type,
                     x_tp_sequence_number   => disb_rec.tp_sequence_number,
                     x_disb_gross_amt       => disb_rec.disb_gross_amt,
                     x_fee_1                => disb_rec.fee_1,
                     x_fee_2                => disb_rec.fee_2,
                     x_disb_net_amt         => disb_rec.disb_net_amt,
                     x_disb_date            => disb_rec.disb_date,
                     x_trans_type           => disb_rec.trans_type,
                     x_elig_status          => disb_rec.elig_status,
                     x_elig_status_date     => disb_rec.elig_status_date,
                     x_affirm_flag          => disb_rec.affirm_flag,
                     x_hold_rel_ind         => disb_rec.hold_rel_ind,
                     x_manual_hold_ind      => disb_rec.manual_hold_ind,
                     x_disb_status          => disb_rec.disb_status,
                     x_disb_status_date     => disb_rec.disb_status_date,
                     x_late_disb_ind        => NVL(l_late_disb_ind, disb_rec.late_disb_ind),
                     x_fund_dist_mthd       => NVL(l_fund_dist_mthd, disb_rec.fund_dist_mthd),
                     x_prev_reported_ind    => NVL(l_prev_reported_ind, disb_rec.prev_reported_ind),
                     x_fund_release_date    => NVL(l_fund_release_date,disb_rec.fund_release_date),
                     x_fund_status          => 'Y',
                     x_fund_status_date     => TRUNC(SYSDATE),
                     x_fee_paid_1           => disb_rec.fee_paid_1,
                     x_fee_paid_2           => disb_rec.fee_paid_2,
                     x_cheque_number        => NVL(l_check_number,disb_rec.cheque_number),
                     x_ld_cal_type          => disb_rec.ld_cal_type,
                     x_ld_sequence_number   => disb_rec.ld_sequence_number,
                     x_disb_accepted_amt    => disb_rec.disb_accepted_amt,
                     x_disb_paid_amt        => disb_rec.disb_paid_amt,
                     x_rvsn_id              => disb_rec.rvsn_id,
                     x_int_rebate_amt       => disb_rec.int_rebate_amt,
                     x_force_disb           => disb_rec.force_disb,
                     x_min_credit_pts       => disb_rec.min_credit_pts,
                     x_disb_exp_dt          => disb_rec.disb_exp_dt,
                     x_verf_enfr_dt         => disb_rec.verf_enfr_dt,
                     x_fee_class            => disb_rec.fee_class,
                     x_show_on_bill         => disb_rec.show_on_bill,
                     x_attendance_type_code      => disb_rec.attendance_type_code,
                     x_base_attendance_type_code => disb_rec.base_attendance_type_code,
                     x_payment_prd_st_date       => disb_rec.payment_prd_st_date,
                     x_change_type_code          => disb_rec.change_type_code,
                     x_fund_return_mthd_code     => disb_rec.fund_return_mthd_code,
                     x_direct_to_borr_flag       => disb_rec.direct_to_borr_flag
                     );

              IF cur_awdisb%ISOPEN THEN
                CLOSE cur_awdisb;
              END IF;

     EXCEPTION

     WHEN SKIP_THIS_RECORD THEN
              IF cur_awdisb%ISOPEN THEN
                CLOSE cur_awdisb;
              END IF;
     END;

     -- set the status of igf_db_cl_disb_resp record_processed = 'Y'
     -- update all the records which are processed

     igf_db_cl_disb_resp_pkg.update_row(
            x_mode                              => 'R',
            x_rowid                             => cbth_rec.row_id,
            x_cdbr_id                           => cbth_rec.cdbr_id,
            x_cbth_id                           => cbth_rec.cbth_id,
            x_record_type                       => cbth_rec.record_type,
            x_loan_number                       => cbth_rec.loan_number,
            x_cl_seq_number                     => cbth_rec.cl_seq_number,
            x_b_last_name                       => cbth_rec.b_last_name,
            x_b_first_name                      => cbth_rec.b_first_name,
            x_b_middle_name                     => cbth_rec.b_middle_name,
            x_b_ssn                             => cbth_rec.b_ssn,
            x_b_addr_line_1                     => cbth_rec.b_addr_line_1,
            x_b_addr_line_2                     => cbth_rec.b_addr_line_2,
            x_b_city                            => cbth_rec.b_city,
            x_b_state                           => cbth_rec.b_state,
            x_b_zip                             => cbth_rec.b_zip,
            x_b_zip_suffix                      => cbth_rec.b_zip_suffix,
            x_b_addr_chg_date                   => cbth_rec.b_addr_chg_date,
            x_eft_auth_code                     => cbth_rec.eft_auth_code,
            x_s_last_name                       => cbth_rec.s_last_name,
            x_s_first_name                      => cbth_rec.s_first_name,
            x_s_middle_initial                  => cbth_rec.s_middle_initial,
            x_s_ssn                             => cbth_rec.s_ssn,
            x_school_id                         => cbth_rec.school_id,
            x_school_use                        => cbth_rec.school_use,
            x_loan_per_start_date               => cbth_rec.loan_per_start_date,
            x_loan_per_end_date                 => cbth_rec.loan_per_end_date,
            x_cl_loan_type                      => cbth_rec.cl_loan_type,
            x_alt_prog_type_code                => cbth_rec.alt_prog_type_code,
            x_lender_id                         => cbth_rec.lender_id,
            x_lend_non_ed_brc_id                => cbth_rec.lend_non_ed_brc_id,
            x_lender_use                        => cbth_rec.lender_use,
            x_borw_confirm_ind                  => cbth_rec.borw_confirm_ind,
            x_tot_sched_disb                    => cbth_rec.tot_sched_disb,
            x_fund_release_date                 => cbth_rec.fund_release_date,
            x_disb_num                          => cbth_rec.disb_num,
            x_guarantor_id                      => cbth_rec.guarantor_id,
            x_guarantor_use                     => cbth_rec.guarantor_use,
            x_guarantee_date                    => cbth_rec.guarantee_date,
            x_guarantee_amt                     => cbth_rec.guarantee_amt,
            x_gross_disb_amt                    => cbth_rec.gross_disb_amt,
            x_fee_1                             => cbth_rec.fee_1,
            x_fee_2                             => cbth_rec.fee_2,
            x_net_disb_amt                      => cbth_rec.net_disb_amt,
            x_fund_dist_mthd                    => cbth_rec.fund_dist_mthd,
            x_check_number                      => cbth_rec.check_number,
            x_late_disb_ind                     => cbth_rec.late_disb_ind,
            x_prev_reported_ind                 => cbth_rec.prev_reported_ind,
            x_err_code1                         => cbth_rec.err_code1,
            x_err_code2                         => cbth_rec.err_code2,
            x_err_code3                         => cbth_rec.err_code3,
            x_err_code4                         => cbth_rec.err_code4,
            x_err_code5                         => cbth_rec.err_code5,
            x_fee_paid_2                        => cbth_rec.fee_paid_2,
            x_lender_name                       => cbth_rec.lender_name,
            x_net_cancel_amt                    => cbth_rec.net_cancel_amt,
            x_duns_lender_id                    => cbth_rec.duns_lender_id,
            x_duns_guarnt_id                    => cbth_rec.duns_guarnt_id,
            x_hold_rel_ind                      => cbth_rec.hold_rel_ind,
            x_pnote_code                        => cbth_rec.pnote_code,
            x_pnote_status_date                 => cbth_rec.pnote_status_date,
            x_fee_paid_1                        => cbth_rec.fee_paid_1,
            x_netted_cancel_amt                 => cbth_rec.netted_cancel_amt,
            x_outstd_cancel_amt                 => cbth_rec.outstd_cancel_amt,
            x_sch_non_ed_brc_id                 => cbth_rec.sch_non_ed_brc_id,
            x_status                            => lv_rec_status,
            x_esign_src_typ_cd                  => cbth_rec.esign_src_typ_cd,
            x_direct_to_borr_flag               => cbth_rec.direct_to_borr_flag
         );

   END LOOP;

   COMMIT;

  EXCEPTION

     WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       igs_ge_msg_stack.conc_exception_hndl;

     WHEN CLSETUP_NOT_FOUND THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_SL_NO_CL_SETUP');
       igs_ge_msg_stack.conc_exception_hndl;

     WHEN FILE_NOT_LOADED THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       igs_ge_msg_stack.conc_exception_hndl;

     WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       fnd_file.put_line(fnd_file.log,SQLERRM);
       igs_ge_msg_stack.conc_exception_hndl;

END roster_ack;

END igf_db_cl_roster;

/
