--------------------------------------------------------
--  DDL for Package Body IGF_GR_RFMS_DISB_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_RFMS_DISB_ORIG" AS
/* $Header: IGFGR03B.pls 120.4 2006/02/08 23:46:42 ridas ship $ */

------------------------------------------------------------------------
-- bvisvana   07-July-2005   Bug # 4008991 - IGF_GR_BATCH_DOES_NOT_EXIST replaced by IGF_SL_GR_BATCH_DOES_NO_EXIST
------------------------------------------------------------------------
--  ayedubat  20-OCT-2004    FA 149 COD-XML Standards build bug # 3416863
--                           Changed the logic as per the TD, FA149_TD_COD_XML_i1a.doc
------------------------------------------------------------------------
-- veramach   29-Jan-2004    Bug 3408092 Added 2004-2005 in g_ver_num checks
------------------------------------------------------------------------
-- ugummall   08-JAN-2004    Bug 3318202. Changed the order of parameters and removed p_org_id in main procedure.
------------------------------------------------------------------------
-- ugummall   06-NOV-2003    Bug 3102439. FA 126 Multiple FA Offices.
--                           1. Added two extra parameters to main and rfms_disb_orig procedures.
--                           2. Modified cursor cur_rfms_disb to include reporting and attending pell ids.
--                           3. Removed l_rep_pell_id and its references. Used p_reporting_pell, newly
--                              passed parameter, in igf_gr_gen.{get_pell_trailer, get_pell_header} procedures.
--                           4. New cursor cur_attending_pell to check attending pell is a child of reporting
--                              pell or not.
--                           5. In rfms_disb_orig prcodure processed only those records for which attending
--                              pell is a child of reporting pell id.
------------------------------------------------------------------------------
-- ugummall   03-NOV-2003    Bug 3102439. FA 126 - Multiple FA Offices.
--                           Added two extra parameters in call to igf_gr_gen.get_pell_header
------------------------------------------------------------------------------
-- cdcruz     16-Aug-2003    Bug BUG FA121-3085558
--                           Check added to check for Transaction Number
--                           Match against Payment ISIR.
------------------------------------------------------------------------
-- rasahoo    13-May-2003      Bug #2938258 If Disbursement Record is not part of this batch
--                             in the System then raise error.Cannot process Disbursement
--                             Record which status for acknowledgement processing is not "Sent".
-------------------------------------------------------------------------------
-- sjadhav    06-Feb-2003      FA116 Build Bug - 2758812
--                             added invalid_version expcetion
--                             modified for 03-04 compliance
--                             output file in UPPERCASE
------------------------------------------------------------------------------
-- sjadhav    Bug 2383690      added igf_gr_gen.send_orig_disb call
------------------------------------------------------------------------------
-- sjadhav    FEB13th,2002     BUG 2216956
--                             Removed flag and disbursement number parameters
--                             Added Award Year parameter to main_ack
------------------------------------------------------------------------------
-- sjadhav    18-jun-2001      Bug ID : 1823995
--                             1. Query for the main cursor 'cur_rfms_disb'
--                             modified to have NVL clause
--                             2. base_id is made null if the process is
--                             run for an award year
------------------------------------------------------------------------------
-- sjadhav    25-apr-2001      Bug No : 1750071
--                             Do not create Origination Record if any of
--                             the following field is null
--                             disb_ref_num,db_cr_flag,disb_amt
------------------------------------------------------------------------------
-- sjadhav    19-apr-2001      Bug ID : 1731177 Added main_ack to process
--                             rfms disb ack . this will get
--                             called from conc. mgr.
--                             Removed l_mode from main
------------------------------------------------------------------------------


  no_data_in_table      EXCEPTION;
  param_error           EXCEPTION;
  batch_not_created     EXCEPTION;
  invalid_version       EXCEPTION;
  next_record           EXCEPTION;

  l_cy_yr               VARCHAR2(10)    DEFAULT NULL; -- to hold cycle year
  l_msg_prn_1           BOOLEAN         DEFAULT TRUE;
  g_ver_num             VARCHAR2(30)    DEFAULT NULL; -- Flat File Version Number
  g_alt_code            VARCHAR2(80);
  g_header              VARCHAR2(1000);
  g_header_written      VARCHAR2(1)     DEFAULT 'N';
  g_trans_type          VARCHAR2(1);
  g_persid_grp          igs_pe_persid_group_all.group_id%TYPE;

-- Main Cursor to pick up RFMS Records
-- for preparing Origination File

-- FA 126. This cursor cur_rfms_disb is modified to include reporting and attending pell ids.
        CURSOR cur_rfms_disb(
                             l_base_id              igf_gr_rfms.base_id%TYPE,
                             l_ci_cal_type          igf_gr_rfms.ci_cal_type%TYPE,
                             l_ci_sequence_number   igf_gr_rfms.ci_sequence_number%TYPE,
                             cp_reporting_pell      igf_gr_rfms.rep_pell_id%TYPE,
                             cp_attending_pell      igf_gr_rfms.attending_campus_id%TYPE
                            ) IS
        SELECT rfmd.*,
               rfms.inst_cross_ref_cd,
               rfms.base_id,
               rfms.award_id,
               rfms.transaction_num,
               rfms.ci_cal_type,
               rfms.ci_sequence_number,
               rfms.rep_pell_id,
               rfms.attending_campus_id,
               rfms.pell_amount
          FROM igf_gr_rfms   rfms ,
               igf_gr_rfms_disb rfmd,
               igf_gr_pell_setup setup
         WHERE rfms.base_id             =  NVL(l_base_id,rfms.base_id)
           AND rfms.ci_cal_type         =  l_ci_cal_type
           AND rfms.ci_sequence_number  =  l_ci_sequence_number
           AND rfms.rep_pell_id         =  cp_reporting_pell
           AND rfms.attending_campus_id =  NVL(cp_attending_pell, rfms.attending_campus_id)
           AND rfmd.disb_ack_act_status =  'R'
           AND rfmd.origination_id      = rfms.origination_id
           AND rfmd.disb_ref_num IN (SELECT disb.disb_num
                                       FROM igf_aw_awd_disb_all disb
                                      WHERE disb.trans_type IN ('A')
                                        AND disb.award_id = rfms.award_id
                                        AND g_trans_type IN ('A','P')
                                     UNION ALL
                                     SELECT disb.disb_num
                                       FROM igf_aw_awd_disb_all disb
                                      WHERE disb.trans_type IN ('P')
                                        AND disb.award_id = rfms.award_id
                                        AND disb.disb_date <= DECODE(setup.funding_method,'J',TRUNC(SYSDATE) + 7,'A',TRUNC(SYSDATE) + 30)
                                        AND g_trans_type = 'P'
                                    )
           AND setup.rep_pell_id        = rfms.rep_pell_id
           AND setup.ci_cal_type        = rfms.ci_cal_type
           AND setup.ci_sequence_number = rfms.ci_sequence_number
           AND rfms.orig_action_code    IN ('A','D','C')
	       ORDER BY rfms.origination_id
       FOR UPDATE OF disb_ack_act_status NOWAIT;
       rec_rfms_disb cur_rfms_disb%ROWTYPE;

PROCEDURE  upd_rfms_disb(p_rec_disb_orig cur_rfms_disb%ROWTYPE,
                         p_rfmb_id  igf_gr_rfms_batch.rfmb_id%TYPE)  IS

------------------------------------------------------------------------------
--
--  Created By : sjadhav
--
--  Date Created On : 2001/01/03
--  Purpose :
-- This procedure updates the records which are sent to
-- external processor.
-- orig_ack_act_status is updated to 'S' for the record which is
-- sent to external processor.
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--
--  (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

BEGIN

     igf_gr_rfms_disb_pkg.update_row (
                         x_rowid                                    => p_rec_disb_orig.row_id,
                         x_rfmd_id                                  => p_rec_disb_orig.rfmd_id ,
                         x_origination_id                           => p_rec_disb_orig.origination_id,
                         x_disb_ref_num                             => p_rec_disb_orig.disb_ref_num,
                         x_disb_dt                                  => p_rec_disb_orig.disb_dt,
                         x_disb_amt                                 => p_rec_disb_orig.disb_amt,
                         x_db_cr_flag                               => p_rec_disb_orig.db_cr_flag,
                         x_disb_ack_act_status                      => 'S',                -- record processed
                         x_disb_status_dt                           => p_rec_disb_orig.disb_status_dt,
                         x_accpt_disb_dt                            => p_rec_disb_orig.accpt_disb_dt ,
                         x_disb_accpt_amt                           => p_rec_disb_orig.disb_accpt_amt,
                         x_accpt_db_cr_flag                         => p_rec_disb_orig.accpt_db_cr_flag,
                         x_disb_ytd_amt                             => p_rec_disb_orig.disb_ytd_amt,
                         x_pymt_prd_start_dt                        => p_rec_disb_orig.pymt_prd_start_dt,
                         x_accpt_pymt_prd_start_dt                  => p_rec_disb_orig.accpt_pymt_prd_start_dt,
                         x_edit_code                                => p_rec_disb_orig.edit_code ,
                         x_rfmb_id                                  => p_rfmb_id,
                         x_mode                                     => 'R',
                         x_ed_use_flags                             => p_rec_disb_orig.ed_use_flags);


EXCEPTION
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_RFMS_DISB_ORIG.UPD_RFMS_DISB');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END upd_rfms_disb;


PROCEDURE  prepare_data
          ( p_rfms_rec        IN  cur_rfms_disb%ROWTYPE,
            p_num_of_records  IN  OUT NOCOPY NUMBER,
            p_rfmb_id         IN  igf_gr_rfms_batch.rfmb_id%TYPE)
IS
------------------------------------------------------------------------------
--
--   Created By : sjadhav
--
--   Date Created On : 2001/01/03
--   Purpose :This procedure loads the record data into datafile
--   Know limitations, enhancements or remarks
--   Change History
--   Who             When            What
--   ugummall        06-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                                   1. Since Header needs to be written only when at least one data record to
--                                      be written is there, it is written just before writing first data record
--                                      into output file.
--
--   (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

   l_data           VARCHAR2(1000);
   -- This cursor gets l_inst_crref_id from igf_gr_pell_setup
   -- for a particualr origination


   BEGIN

   l_data        :=   NULL;
   --
   --
   -- Bug No : 1750071
   -- Do not create Origination Record if any of the following field is null
   -- disb_ref_num,db_cr_flag,disb_amt
   -- Write into the log file which records were not originated
   --
   --
   IF p_rfms_rec.disb_ref_num IS NULL OR
      p_rfms_rec.db_cr_flag   IS NULL OR
      p_rfms_rec.disb_amt     IS NULL THEN
      fnd_file.new_line(fnd_file.log,1);
      fnd_message.set_name('IGF','IGF_GR_ORIG_DATA_REQD');
      fnd_message.set_token('PER_NUM',igf_gr_gen.get_per_num(p_rfms_rec.base_id));
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','DISB_REF_NUM'),50) || ' : ' ||p_rfms_rec.disb_ref_num);
      fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','DB_CR_FLAG'),50) || ' : ' ||p_rfms_rec.db_cr_flag);
      fnd_file.put_line(fnd_file.log, RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','DISB_AMT'),50) || ' : ' ||p_rfms_rec.disb_amt);
      fnd_file.new_line(fnd_file.log,1);
   ELSE
        IF g_ver_num IN ('2002-2003','2003-2004','2004-2005') THEN
                 l_data     :=   RPAD(p_rfms_rec.origination_id,23)                                  ||
                                 RPAD(NVL(p_rfms_rec.inst_cross_ref_cd,' '),13)                      ||
                                 RPAD(' ',1)                                                         ||   -- Action Code
                                 LPAD(p_rfms_rec.disb_ref_num,2,'0')                                 ||
                                 RPAD(p_rfms_rec.db_cr_flag,1)                                       ||
                                 LPAD(TO_CHAR(ABS(100*NVL(p_rfms_rec.disb_amt,0))),7,'0')            ||
                                 RPAD(NVL(TO_CHAR(p_rfms_rec.disb_dt,'YYYYMMDD'),' '),8)             ||
                                 RPAD(NVL(TO_CHAR(p_rfms_rec.pymt_prd_start_dt,'YYYYMMDD'),' '),8)   ||
                                 RPAD(' ',37);                                                    -- Unused
             --
             -- The length of this record is 100
             -- update rfms_disb table for the records sent.
             --
             -- Bug 2383690
             -- If this is not first disbursement and
             -- If fed verf stat is W, do not send
             -- log message
             --

            IF NVL(p_rfms_rec.disb_ref_num,0) <>
               NVL(igf_gr_gen.get_min_pell_disb ( p_rfms_rec.origination_id ),0) THEN
                IF   igf_gr_gen.send_orig_disb( p_rfms_rec.origination_id) THEN

                     IF (g_header_written = 'N') THEN
                       fnd_file.put_line(fnd_file.output, UPPER(g_header));
                       g_header_written := 'Y';
                     END IF;

                     fnd_file.put_line(fnd_file.output,UPPER(l_data));
                     upd_rfms_disb(p_rfms_rec,p_rfmb_id);
                     p_num_of_records := p_num_of_records + 1;

                ELSE

                      fnd_message.set_name('IGF','IGF_GR_VERF_STAT_W');
                      fnd_message.set_token('ORIG_ID',igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID') ||
                                                           ' : ' || p_rfms_rec.origination_id        ||
                                                           ' , ' || igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','DISB_REF_NUM') ||
                                                           ' : ' || p_rfms_rec.disb_ref_num);

                      fnd_file.put_line(fnd_file.log,fnd_message.get);
               END IF;
            ELSE

                     IF (g_header_written = 'N') THEN
                       fnd_file.put_line(fnd_file.output, UPPER(g_header));
                       g_header_written := 'Y';
                     END IF;

                     fnd_file.put_line(fnd_file.output,UPPER(l_data));
                     upd_rfms_disb(p_rfms_rec,p_rfmb_id);
                     p_num_of_records := p_num_of_records + 1;

            END IF;


        ELSE
            RAISE igf_gr_gen.no_file_version;
        END IF;
    END IF;


    EXCEPTION

    WHEN igf_gr_gen.no_file_version THEN
      RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_RFMS_DISB_ORIG.PREPARE_DATA');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END prepare_data;

PROCEDURE   log_message
       (p_batch_id                 VARCHAR2,
        p_origination_id           igf_gr_rfms.origination_id%TYPE )  IS

------------------------------------------------------------------------------
--
--   Created By : sjadhav
--
--   Date Created On : 2001/01/03
--   Purpose :This overloaded procedure formats the messages
--   to be put into log file.
--   Know limitations, enhancements or remarks
--   Change History
--   Who             When            What
--
--   (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------
    l_msg_str_0     VARCHAR2(1000);
    l_msg_str_1     VARCHAR2(1000);
BEGIN

    l_msg_str_0  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BATCH_ID'),50) ||
                     RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID'),50);
    l_msg_str_1  :=  RPAD(p_batch_id,50) ||
                     RPAD(p_origination_id,50);

    fnd_file.put_line(fnd_file.log,'');
    fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,'         ');
    fnd_file.put_line(fnd_file.log,l_msg_str_0);
    fnd_file.put_line(fnd_file.log,RPAD('-',100,'-'));

    fnd_file.put_line(fnd_file.log,l_msg_str_1);


EXCEPTION
   WHEN others THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.LOG_MESSAGE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
END log_message;

PROCEDURE out_message( p_origination_id      igf_gr_rfms_disb.origination_id%TYPE,
                       p_disb_ref_num        igf_gr_rfms_disb.disb_ref_num%TYPE)
IS
------------------------------------------------------------------------------
--
--   Created By : sjadhav
--
--   Date Created On : 2001/01/03
--   Purpose :This overloaded procedure formats the messages
--   to be put into log file.
--   Know limitations, enhancements or remarks
--   Change History
--   Who             When            What
--
--   (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

    l_msg_str_0     VARCHAR2(1000);
    l_msg_str_1     VARCHAR2(1000);

BEGIN

     l_msg_str_0  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID'),50)       ||
                      RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','DISB_REF_NUM'),50);

     l_msg_str_1  :=  RPAD(p_origination_id,30)   ||
                      RPAD(p_disb_ref_num,30);

     IF l_msg_prn_1 = TRUE THEN
        fnd_message.set_name('IGF','IGF_GR_RECORDS_UPDATED');
        fnd_file.put_line(fnd_file.output,fnd_message.get);
        fnd_file.new_line(fnd_file.output,1);
        fnd_file.put_line(fnd_file.output,l_msg_str_0);
        fnd_file.put_line(fnd_file.output,RPAD('-',100,'-'));
        l_msg_prn_1 := FALSE;
     END IF;
     fnd_file.put_line(fnd_file.output,l_msg_str_1);


EXCEPTION
   WHEN others THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.LOG_MESSAGE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
END out_message;


PROCEDURE log_rej_message(p_origination_id      igf_gr_rfms_disb.origination_id%TYPE,
                          p_disb_ref_num        igf_gr_rfms_disb.disb_ref_num%TYPE,
                          p_edit_code           igf_gr_rfms_disb.edit_code%TYPE)
IS
------------------------------------------------------------------------------
--
--   Created By : sjadhav
--
--   Date Created On : 2001/01/03
--   Purpose :This overloaded procedure formats the messages
--   to be put into log file.
--   Know limitations, enhancements or remarks
--   Change History
--   Who             When            What
--
--   (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

    l_msg_str_0                 VARCHAR2(1000)  DEFAULT NULL;
    l_msg_str_1                 VARCHAR2(1000)  DEFAULT NULL;
    l_msg_str_2                 VARCHAR2(1000)  DEFAULT NULL;
    l_msg_str_3                 VARCHAR2(1000)  DEFAULT NULL;

    CURSOR cur_err_desc(l_err_cd igf_gr_rfms_error.edit_code%TYPE) IS
    SELECT
    igf_gr_rfms_error.message
    FROM igf_gr_rfms_error
    WHERE
    igf_gr_rfms_error.edit_code = l_err_cd;

    l_count             NUMBER  DEFAULT 1;
    l_error_code        igf_gr_rfms_error.edit_code%TYPE;
    l_msg_desc          VARCHAR2(4000)  DEFAULT NULL;

BEGIN

     IF NVL(TO_NUMBER(RTRIM(LTRIM(p_edit_code))),0) > 0 THEN
          fnd_file.new_line(fnd_file.log,1);
          fnd_message.set_name('IGF','IGF_GR_REC_CONTAIN_EDIT_CODES');
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          l_msg_str_0  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','ORIGINATION_ID'),50)       ||
                           RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','DISB_REF_NUM'),50);

          l_msg_str_1  :=  RPAD(p_origination_id,30)   ||
                           RPAD(p_disb_ref_num,30);


          l_msg_str_2  :=  RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','EDIT_CODE'),50);
          fnd_file.put_line(fnd_file.log,l_msg_str_0);
          fnd_file.put_line(fnd_file.log,RPAD('-',100,'-'));
          fnd_file.put_line(fnd_file.log,l_msg_str_1);
          fnd_file.put_line(fnd_file.log,' ');

          IF NVL(p_edit_code,'0') <> '0' THEN
            fnd_file.put_line(fnd_file.log,l_msg_str_2);
            fnd_file.put_line(fnd_file.log,RPAD('-',50,'-'));
          END IF;

          FOR l_cn IN 1 .. 25 LOOP

              l_error_code :=  NVL(SUBSTR(p_edit_code,l_count,3),'000');
              IF l_error_code <>'000' THEN

                    l_msg_str_3   :=    RPAD(l_error_code,5);
                    fnd_file.put_line(fnd_file.log,l_msg_str_3);

               END IF;
               l_count      :=  l_count + 3;
          END LOOP;
     END IF;


EXCEPTION

   WHEN others THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_GR_RFMS_ORIG.LOG_MESSAGE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END log_rej_message;


PROCEDURE rfms_disb_orig(
                         p_ci_cal_type          IN VARCHAR2,
                         p_ci_sequence_number   IN NUMBER,
                         p_base_id              IN VARCHAR2,
                         p_reporting_pell       IN VARCHAR2,
                         p_attending_pell       IN VARCHAR2
                        ) IS
------------------------------------------------------------------------------
--
--  Created By : sjadhav
--
--  Date Created On : 2001/01/03
--  Purpose : This procedure reads the data from igf_gr_rfms table
--  for the paricular award year and base id and loads the data
--  into a datafile after formatting
--
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--  ugummall        10-DEC-2003     Bug 3252832. FA 131 - COD Updates
--                                  Added check - Amount should not be less than sum of disbursement amounts.
--                                  Added cursor cur_disb_amt_tot
--  ugummall        06-NOV-2003     Bug 3102439. FA 126 Multiple FA Offices.
--                                  1. Added two extra parameters namely p_reporting_pell
--                                     and p_attending_pell to this procedure.
--                                  2. Added cursor cur_attending_pell. Added check for attending pell
--                                     is a child of reporting pell. If not skipped Context Student's records.
--                                  3. Parameters are shown in log file irrespective of wether cur_rfms
--                                     fetches the records or not. This is done for clarity.
--  ugummall        03-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                                  Added two extra parameters in call to igf_gr_gen.get_pell_header
--  rasahoo         16-Oct-2003     FA121-Bug# 3085558 cur_pymnt_isir_rec is initialised to null
--  cdcruz          16-Sep-03       FA121-Bug# 3085558 New Cursor added cur_pymnt_isir
--                                  That checks for the Transaction Number
--                                  On the Payment ISIR
--                                  Entire Looping Changed
--
--  (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

  -- l_header is removed, and new g_header is used.

  l_record              VARCHAR2(4000);
  l_trailer             VARCHAR2(1000);
  l_num_of_rec          NUMBER DEFAULT 0;
  l_amount_total        NUMBER DEFAULT 0;

  p_rfmb_id             igf_gr_rfms_batch.rfmb_id%TYPE;
  l_batch_id            VARCHAR2(60);
  l_running_orig_id     VARCHAR2(30);
  l_last_disb_rec       VARCHAR2(1);
  l_valid_rec           BOOLEAN;
  I  NUMBER;

	CURSOR cur_pymnt_isir(
                        l_base_id igf_gr_rfms.base_id%TYPE
                       )  IS
  SELECT isir.transaction_num
    FROM igf_ap_isir_matched isir
   WHERE isir.base_id = l_base_id
     AND isir.payment_isir = 'Y' ;
  cur_pymnt_isir_rec cur_pymnt_isir%rowtype;

  -- Cursor to check attending pell id is a child of reporting pell id
  CURSOR cur_attending_pell(
                            cp_ci_cal_type          igf_gr_report_pell.ci_cal_type%TYPE,
                            cp_ci_sequence_number   igf_gr_report_pell.ci_sequence_number%TYPE,
                            cp_reporting_pell       igf_gr_report_pell.reporting_pell_cd%TYPE,
                            cp_attending_pell       igf_gr_attend_pell.attending_pell_cd%TYPE
                           ) IS
  SELECT  'Y'
    FROM  igf_gr_report_pell rep,
          igf_gr_attend_pell att
   WHERE  rep.rcampus_id            =   att.rcampus_id
     AND  rep.ci_cal_type           =   cp_ci_cal_type
     AND  rep.ci_sequence_number    =   cp_ci_sequence_number
     AND  rep.reporting_pell_cd     =   cp_reporting_pell
     AND  att.attending_pell_cd     =   cp_attending_pell;
  l_attending_pell_exists      cur_attending_pell%ROWTYPE;

  -- To get sum of disbursement amounts.
  CURSOR cur_disb_amt_tot(cp_origination_id igf_gr_rfms_disb.origination_id%TYPE) IS
    SELECT SUM(disb_amt) disb_amt_tot
      FROM igf_gr_rfms_disb
     WHERE origination_id = cp_origination_id;
  rec_disb_amt_tot  cur_disb_amt_tot%ROWTYPE;

BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.rfms_disb_orig.debug','p_ci_cal_type:'||p_ci_cal_type);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.rfms_disb_orig.debug','p_ci_sequence_number:'||p_ci_sequence_number);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.rfms_disb_orig.debug','p_base_id:'||p_base_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.rfms_disb_orig.debug','p_reporting_pell:'||p_reporting_pell);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.rfms_disb_orig.debug','p_attending_pell:'||p_attending_pell);
  END IF;

  -- FA 126. Passed extra parameters p_reporting_pell and p_attending_pell to this cursor.
  OPEN     cur_rfms_disb(p_base_id,p_ci_cal_type,p_ci_sequence_number, p_reporting_pell, p_attending_pell);
  FETCH    cur_rfms_disb INTO rec_rfms_disb;

  -- If the table does not contain any data for this base_id or award_year
  -- message is logged into log file and relevent details are also shown
  IF cur_rfms_disb%NOTFOUND  THEN
    CLOSE cur_rfms_disb;
    IF (g_persid_grp IS NULL)THEN
      fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE no_data_in_table;
    ELSE
      RAISE next_record;
    END IF;
  END IF;

  -- since the table has data, prepare a header record
  g_header := igf_gr_gen.get_pell_header(g_ver_num,
                                         l_cy_yr,
                                         p_reporting_pell,
                                         '#D',
                                         p_rfmb_id,
                                         l_batch_id,
                                         p_ci_cal_type,
                                         p_ci_sequence_number);

  -- Header can not be written into output datafile unless and until we are sure that
  -- at least one data record will be created. Hence commenting out the following line.
  -- fnd_file.put_line(fnd_file.output,UPPER(l_header));
  -- Header(above line) will be written in prepare_data procedure just before first
  -- data record is written. by ugummall.

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BATCH_ID'),10)||' :'
                                                              ||'  '|| l_batch_id);
  fnd_file.new_line(fnd_file.log,1);

  l_amount_total := 0;
  l_num_of_rec   := 0;


  -- Initiallise the current Origination ID to -1
  l_running_orig_id := '-1';
  l_last_disb_rec   := 'N' ;

  LOOP
    IF (l_running_orig_id <> rec_rfms_disb.origination_id) THEN

      -- Student in Context has changed so do the Transaction Check as well Attending Pell child check.
      l_running_orig_id := rec_rfms_disb.origination_id ;
      l_valid_rec   :=  TRUE;

      fnd_message.set_name('IGF','IGF_GR_RFMS_ORG_ID');
      fnd_message.set_token('ORIG_ID',l_running_orig_id);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      -- Get The Payment ISIR Transaction Number
      cur_pymnt_isir_rec := NULL;
      OPEN cur_pymnt_isir(rec_rfms_disb.base_id);
      FETCH cur_pymnt_isir INTO cur_pymnt_isir_rec;
      CLOSE cur_pymnt_isir;

      -- If the Transaction Number being reported does not match do not Originate
      IF rec_rfms_disb.transaction_num <> NVL(cur_pymnt_isir_rec.transaction_num,-1) THEN
        l_valid_rec := FALSE;

        IF cur_pymnt_isir_rec.transaction_num IS NULL THEN
          fnd_message.set_name('IGF','IGF_AP_NO_PAYMENT_ISIR');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        ELSE
          fnd_message.set_name('IGF','IGF_GR_PYMNT_ISIR_MISMATCH');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;
      END IF;

      -- check if attending pell is a child of reporting pell id.
      l_attending_pell_exists := NULL;
      OPEN cur_attending_pell(rec_rfms_disb.ci_cal_type,
                              rec_rfms_disb.ci_sequence_number,
                              rec_rfms_disb.rep_pell_id,
                              rec_rfms_disb.attending_campus_id);
      FETCH cur_attending_pell INTO l_attending_pell_exists;

      -- If Attending pell child record does not exist?
      IF (cur_attending_pell%NOTFOUND) THEN
        l_valid_rec := FALSE;

        FND_MESSAGE.SET_NAME('IGF', 'IGF_GR_ATTEND_PELL_NOT_SETUP');
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
      END IF;
      CLOSE cur_attending_pell;

      -- Check if sum of disbursement amounts is less than origination record's amount.
      rec_disb_amt_tot := NULL;
      OPEN cur_disb_amt_tot(rec_rfms_disb.origination_id);
      FETCH cur_disb_amt_tot INTO rec_disb_amt_tot;
      CLOSE cur_disb_amt_tot;

      IF (rec_rfms_disb.pell_amount < rec_disb_amt_tot.disb_amt_tot) THEN
        l_valid_rec := FALSE;
        fnd_message.set_name('IGF','IGF_GR_PELL_DIFF_AMTS');
        FND_MESSAGE.SET_TOKEN('DISB_AMT', TO_CHAR(rec_disb_amt_tot.disb_amt_tot));
        FND_MESSAGE.SET_TOKEN('PELL_TOT', TO_CHAR(rec_rfms_disb.pell_amount));

        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;

      -- if Context student record is invalid for sending his disbersements
      -- due to transaction number mismatch or attending pell child does not exist.
      IF NOT l_valid_rec THEN
        -- Since context student record is not valid, skip all his records.
        LOOP
          FETCH cur_rfms_disb INTO rec_rfms_disb;
          IF (cur_rfms_disb%NOTFOUND) THEN
            l_last_disb_rec :=  'Y';
            EXIT;
          END IF;
          IF (l_running_orig_id <> rec_rfms_disb.origination_id) THEN
            -- New Student arrived.
            EXIT;
          END IF;
        END LOOP;     -- end of skipping context student's records.
      END IF;      -- end of context student record is invalid.
    END IF;     -- end of Student in Context has changed.

    IF l_last_disb_rec = 'Y' THEN
      EXIT ;
    END IF;

    IF (l_valid_rec) THEN
      l_amount_total := l_amount_total + NVL(rec_rfms_disb.disb_amt,0);  -- Check this
      prepare_data(rec_rfms_disb,l_num_of_rec,p_rfmb_id);
      FETCH cur_rfms_disb INTO rec_rfms_disb;
      EXIT WHEN cur_rfms_disb%NOTFOUND;
    END IF;
  END LOOP;

  CLOSE cur_rfms_disb;
  -- since the table has data, prepare a trailer record
  l_trailer := igf_gr_gen.get_pell_trailer(g_ver_num,
                                           l_cy_yr,
                                           p_reporting_pell,
                                           '#D',
                                           l_num_of_rec,
                                           l_amount_total,
                                           l_batch_id);

  fnd_file.new_line(fnd_file.log,1);
  fnd_message.set_name('IGF','IGF_GR_ORIG_REC_NUM');
  fnd_message.set_token('TOT_NUM',TO_CHAR(l_num_of_rec));
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  -- p_num_of_rec || ' records written into data file
  fnd_file.new_line(fnd_file.log,1);

  IF  l_num_of_rec > 0 THEN
    fnd_file.put_line(fnd_file.output,UPPER(l_trailer));
  ELSE
    RAISE batch_not_created;
  END IF;

EXCEPTION
  WHEN igf_gr_gen.no_file_version THEN
    RAISE;
  WHEN batch_not_created THEN
    RAISE;
  WHEN no_data_in_table THEN
    RAISE;
  WHEN next_record THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_GR_RFMS_DISB_ORIG.RFMS_DISB_ORIG');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END rfms_disb_orig;


PROCEDURE rfms_disb_ack  IS

------------------------------------------------------------------------------
--
--  Created By : sjadhav
--
--  Date Created On : 2001/01/03
--  Purpose : This procedure reads the data from datafile(RFMS Ack File )
--            and loads data into origination table after formatting
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
-- rasahoo         13-May-2003      Bug #2938258 If Disbursement Record is not part of this batch
--                                 in the System then raise error.Cannot process Disbursement
--                                 Record which status for acknowledgement processing is not "Sent".
--------------------------------------------------------------------------------------------
--
--  (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

    l_last_gldr_id     NUMBER;
    l_number_rec       NUMBER;
    l_count            NUMBER          DEFAULT  1;
    l_batch_id         VARCHAR2(100);
    l_rfms_process_dt  VARCHAR2(200);
    lp_count           NUMBER          DEFAULT  0;
    lf_count           NUMBER          DEFAULT  0;
    lv_message         fnd_new_messages.message_name%TYPE;
    SYSTEM_STATUS      VARCHAR2(20);
----Bug #2938258

    CURSOR cur_gr_rfmb_disb ( p_batch_id  igf_gr_rfms_batch.batch_id%TYPE)
       IS
       SELECT
       rfmb_id
       FROM
       igf_gr_rfms_batch
       WHERE batch_id = p_batch_id;

       cur_get_rfmb_disb  cur_gr_rfmb_disb%ROWTYPE;
       l_rfmb_id     igf_gr_rfms_batch.rfmb_id%TYPE;
--end -Bug #2938258
BEGIN

    igf_gr_gen.process_pell_ack (g_ver_num,
                                 'GR_RFMS_DISB_ORIG',
                                 l_number_rec,
                                 l_last_gldr_id,
                                 l_batch_id);

  ----Bug #2938258

  OPEN cur_gr_rfmb_disb(l_batch_id);
  FETCH cur_gr_rfmb_disb INTO cur_get_rfmb_disb;
  CLOSE cur_gr_rfmb_disb;
   l_rfmb_id := cur_get_rfmb_disb.rfmb_id;
  --end -Bug #2938258
   --
   --  Check the award year matches with the award year in PELL setup.
   --
   igf_gr_gen.match_file_version (g_ver_num, l_batch_id, lv_message);

   IF lv_message = 'IGF_GR_VRSN_MISMTCH' THEN
      fnd_message.set_name('IGF','IGF_GR_VRSN_MISMTCH');
      fnd_message.set_token('CYCL',SUBSTR(l_batch_id,3,4));
      fnd_message.set_token('BATCH',l_batch_id);
      fnd_message.set_token('VRSN',g_ver_num);
      fnd_message.set_token('AWD_YR',g_alt_code);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE invalid_version;
   END IF;

   IF l_number_rec > 0 THEN

       DECLARE

        l_actual_rec               NUMBER DEFAULT 0;
        l_origination_id           igf_gr_rfms.origination_id%TYPE;
        l_ci_cal_type              igf_gr_rfms.ci_cal_type%TYPE;
        l_ci_sequence_number       igf_gr_rfms.ci_sequence_number%TYPE;
        l_chk_flag                 BOOLEAN DEFAULT FALSE;

        CURSOR cur_award(l_origination_id   igf_gr_rfms.origination_id%TYPE) IS
        SELECT
        *
        FROM
        igf_gr_rfms
        WHERE
        origination_id = l_origination_id;

        rec_award  cur_award%ROWTYPE;

        CURSOR c_rfms_data IS
        SELECT record_data
        FROM
        igf_gr_load_file_t
        WHERE
        gldr_id BETWEEN 2 AND (l_last_gldr_id - 1)
        AND    file_type = 'GR_RFMS_DISB_ORIG';

        CURSOR cur_disb_orig(l_origination_id igf_gr_rfms_disb.origination_id%TYPE,
                             l_disb_ref_num   igf_gr_rfms_disb.disb_ref_num%TYPE)
        IS
        SELECT *
        FROM   igf_gr_rfms_disb
        WHERE
        origination_id   = l_origination_id AND
        disb_ref_num     = l_disb_ref_num
        FOR UPDATE OF edit_code NOWAIT;

        rec_disb_orig   cur_disb_orig%ROWTYPE;
        l_rfms          igf_gr_rfms_disb%ROWTYPE;
        l_disb_ref_num   igf_gr_rfms_disb.disb_ref_num%TYPE;

        BEGIN

               FOR rec_data  IN c_rfms_data LOOP

                BEGIN                              -- For Loop Inner Begin

                    l_actual_rec      :=  l_actual_rec + 1;


                    BEGIN
                    IF g_ver_num  IN ('2002-2003','2003-2004','2004-2005') THEN

                    l_rfms.origination_id            :=  LTRIM(RTRIM(SUBSTR(rec_data.record_data,1,23)));
                    l_disb_ref_num                   :=  NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,38,2)))),0);
                    l_rfms.disb_ack_act_status       :=  LTRIM(RTRIM(SUBSTR(rec_data.record_data,37,1)));
                    l_rfms.accpt_db_cr_flag          :=  LTRIM(RTRIM(SUBSTR(rec_data.record_data,40,1)));
                    l_rfms.disb_accpt_amt            :=  NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,41,7))))/100,0);  -- check
                    l_rfms.accpt_disb_dt             :=  fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(rec_data.record_data,48,8))),'YYYYMMDD');
                    l_rfms.disb_ytd_amt              :=  NVL(TO_NUMBER(RTRIM(LTRIM(SUBSTR(rec_data.record_data,101,7))))/100,0); -- check
                    l_rfms.accpt_pymt_prd_start_dt   :=  fnd_date.string_to_date(LTRIM(RTRIM(SUBSTR(rec_data.record_data,56,8))),'YYYYMMDD');
                    l_rfms.edit_code                 :=  LTRIM(RTRIM(SUBSTR(rec_data.record_data,108,75)));
                    l_rfms.ed_use_flags              :=  LTRIM(RTRIM(SUBSTR(rec_data.record_data,183,10)));

                    ELSE
                      RAISE igf_gr_gen.no_file_version;
                    END IF;


                    EXCEPTION
                        -- The exception caught here will be the data format exceptions
                        WHEN OTHERS THEN
                        lf_count := lf_count + 1;
                        fnd_file.put_line(fnd_file.log, ' ' );
                        fnd_message.set_name('IGF','IGF_GR_DISB_INVALID_RECORD');
                        fnd_message.set_token('ORIG_ID',l_rfms.origination_id);
                        -- Cannot Process Record for Origination ORIG_ID as it contains corrupt data
                        fnd_file.put_line(fnd_file.log,fnd_message.get);

                        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                        fnd_file.put_line(fnd_file.log,fnd_message.get);
                        fnd_file.put_line(fnd_file.log, ' ' );

                        RAISE igf_gr_gen.skip_this_record;

                    END;

                    OPEN cur_award(l_rfms.origination_id);
                    FETCH cur_award INTO  rec_award;

                    IF cur_award%NOTFOUND THEN
                      CLOSE cur_award;
                      log_message(l_batch_id,l_rfms.origination_id);
                      RAISE igf_gr_gen.skip_this_record;
                    END IF;

                    OPEN cur_disb_orig(l_rfms.origination_id,l_disb_ref_num);
                    FETCH cur_disb_orig INTO rec_disb_orig;

                    IF cur_disb_orig%NOTFOUND THEN
                       CLOSE cur_disb_orig;
                       fnd_file.put_line(fnd_file.log,' ');
                       fnd_message.set_name('IGF','IGF_GR_NO_RFMS_ORIG');
                       fnd_file.put_line(fnd_file.log,fnd_message.get);
                       --write to log file
                       log_message(l_batch_id,LTRIM(RTRIM(SUBSTR(rec_data.record_data,1,23))));
                       RAISE  igf_gr_gen.skip_this_record;
                    END IF;

----Bug #2938258
                   IF  l_rfmb_id<>rec_disb_orig.rfmb_id THEN

                      fnd_message.set_name('IGF','IGF_GR_DISB_BATCH_MISMATCH');
                      fnd_message.set_token('BATCH_ID',l_batch_id);
                      fnd_message.set_token('DISB_ID',l_rfms.origination_id );
                      fnd_file.put_line(fnd_file.log,fnd_message.get);
                      fnd_file.new_line(fnd_file.log,1);
                      RAISE igf_gr_gen.skip_this_record;
                     END IF;

                     IF rec_disb_orig.disb_ack_act_status <> 'S' THEN


                       fnd_message.set_name('IGF','IGF_GR_DISB_NOT_IN_SENT');
                       fnd_message.set_token('DISB_ID',l_rfms.origination_id );
                       SYSTEM_STATUS := igf_aw_gen.lookup_desc('IGF_GR_ORIG_STATUS',rec_disb_orig.disb_ack_act_status);
                       fnd_message.set_token('SYS_STATUS',SYSTEM_STATUS );
                       fnd_file.put_line(fnd_file.log,fnd_message.get);
                       fnd_file.new_line(fnd_file.log,1);

                       RAISE igf_gr_gen.skip_this_record;
                      END IF;

--end -Bug #2938258

                    l_rfms.disb_ref_num              :=  rec_disb_orig.disb_ref_num;
                    l_rfms.rfmd_id                   :=  rec_disb_orig.rfmd_id;
                    l_rfms.rfmb_id                   :=  rec_disb_orig.rfmb_id;
                    l_rfms.disb_amt                  :=  rec_disb_orig.disb_amt;
                    l_rfms.disb_dt                   :=  rec_disb_orig.disb_dt;
                    l_rfms.db_cr_flag                :=  rec_disb_orig.db_cr_flag;
                    l_rfms.pymt_prd_start_dt         :=  rec_disb_orig.accpt_pymt_prd_start_dt;
                    l_rfms.disb_status_dt            :=  TRUNC(SYSDATE);

                    lp_count := lp_count + 1;
                    igf_gr_rfms_disb_pkg.update_row (
                                       x_rowid                                    => rec_disb_orig.row_id,
                                       x_rfmd_id                                  => l_rfms.rfmd_id ,
                                       x_origination_id                           => l_rfms.origination_id,
                                       x_disb_ref_num                             => l_rfms.disb_ref_num,
                                       x_disb_dt                                  => l_rfms.disb_dt,
                                       x_disb_amt                                 => l_rfms.disb_amt,
                                       x_db_cr_flag                               => l_rfms.db_cr_flag,
                                       x_disb_ack_act_status                      => l_rfms.disb_ack_act_status,
                                       x_disb_status_dt                           => l_rfms.disb_status_dt,
                                       x_accpt_disb_dt                            => l_rfms.accpt_disb_dt ,
                                       x_disb_accpt_amt                           => l_rfms.disb_accpt_amt,
                                       x_accpt_db_cr_flag                         => l_rfms.accpt_db_cr_flag,
                                       x_disb_ytd_amt                             => l_rfms.disb_ytd_amt,
                                       x_pymt_prd_start_dt                        => l_rfms.pymt_prd_start_dt,
                                       x_accpt_pymt_prd_start_dt                  => l_rfms.accpt_pymt_prd_start_dt,
                                       x_edit_code                                => l_rfms.edit_code,
                                       x_rfmb_id                                  => l_rfms.rfmb_id,
                                       x_mode                                     => 'R',
                                       x_ed_use_flags                             => l_rfms.ed_use_flags);

                --write to output file

                    out_message( l_rfms.origination_id,
                                 l_rfms.disb_ref_num);

                --write to log file
                    log_rej_message( l_rfms.origination_id,
                                     l_rfms.disb_ref_num,
                                     l_rfms.edit_code);

                    IF  l_rfms.disb_accpt_amt <> l_rfms.disb_amt THEN

                            igf_gr_gen.insert_sys_holds(rec_award.award_id,rec_disb_orig.disb_ref_num,'PELL');
                            fnd_message.set_name('IGF','IGF_GR_DIFF_PELL_DISB');
                            fnd_message.set_token('ORIG_ID',l_rfms.origination_id);
                            fnd_message.set_token('DISB_NUM',l_rfms.disb_ref_num);
                            fnd_file.put_line(fnd_file.log,fnd_message.get);

                            fnd_message.set_name('IGF','IGF_GR_REPORTED_AMT');
                            fnd_message.set_token('AMT', TO_CHAR(l_rfms.disb_amt));
                            fnd_file.put_line(fnd_file.log,fnd_message.get);

                            fnd_message.set_name('IGF','IGF_GR_RECEIVED_AMT');
                            fnd_message.set_token('AMT', TO_CHAR(l_rfms.disb_accpt_amt));
                            fnd_file.put_line(fnd_file.log,fnd_message.get);
                            fnd_file.new_line(fnd_file.log,1);

                    END IF;

                    CLOSE cur_award;
                    CLOSE cur_disb_orig;

                    EXCEPTION

                    WHEN igf_gr_gen.skip_this_record THEN
                      IF cur_award%ISOPEN THEN
                         CLOSE cur_award;
                      END IF;
                      IF cur_disb_orig%ISOPEN THEN
                         CLOSE cur_disb_orig;
                      END IF;

              END; -- For Loop Inner Begin-End

           END LOOP;

           IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              igs_ge_msg_stack.add;
              RAISE igf_gr_gen.file_not_loaded;
           END IF;

       END;                 -- Inner Begin

  fnd_file.new_line(fnd_file.log,2);

  fnd_message.set_name('IGF','IGF_GR_FILE_REC_CNT');
  fnd_message.set_token('CNT',l_number_rec);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  fnd_message.set_name('IGF','IGF_GR_FILE_REC_PAS');
  fnd_message.set_token('CNT',lp_count);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  fnd_message.set_name('IGF','IGF_GR_FILE_REC_FAL');
  fnd_message.set_token('CNT',lf_count);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

 END IF;   -- if l_num_rec --

EXCEPTION

WHEN invalid_version THEN
     RAISE;
WHEN igf_gr_gen.no_file_version THEN
     RAISE;
WHEN igf_gr_gen.corrupt_data_file THEN
     RAISE;
WHEN no_data_in_table THEN
     RAISE;
WHEN igf_gr_gen.batch_not_in_system  THEN
      -- Bug # 4008991
     fnd_message.set_name('IGF','IGF_SL_GR_BATCH_DOES_NO_EXIST');
     fnd_message.set_token('BATCH_ID',l_batch_id);
     RAISE;
WHEN igf_gr_gen.file_not_loaded THEN
     RAISE;
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_GR_RFMS_DISB_ORIG.RFMS_DISB_ACK');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END rfms_disb_ack;


PROCEDURE main(
               errbuf               OUT     NOCOPY  VARCHAR2,
               retcode              OUT     NOCOPY  NUMBER,
               award_year           IN              VARCHAR2,
               p_reporting_pell     IN              VARCHAR2,
               p_attending_pell     IN              VARCHAR2,
               p_trans_type         IN              VARCHAR2,
               base_id              IN              igf_gr_rfms_all.base_id%TYPE,
               p_dummy              IN              VARCHAR2,
               p_pers_id_grp        IN              NUMBER
              )
AS

------------------------------------------------------------------------------
--
--  Created By : sjadhav
--
--  Date Created On : 2001/01/03
--
--  Purpose :This is the procedeure called by con prog.
--  This procedure updates igf_aw_awd_disb table based on
--  certain conditions.
--  This process will set the status of all the records
--  processed as 'Processed' in the igf_db_cl_disb_resp
--  table.
--
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--  ridas           08-FEB-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
--  tsailaja		    13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
--  ugummall        08-JAN-2004     Bug 3318202. Changed the order of parameters and removed p_org_id
--  ugummall        06-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                                  1. Added two parameters to this procedure namely
--                                     p_reporting_pell and p_attending_pell
--                                  2. base_id and p_attending_pell are mutually exclusive. Added this check.
--
--  brajendr        02-Sep-2002     Bug # 2483249
--                                  Modifed the messages as per the message standards

-- bug 2216956
-- sjadhav, FEB13th,2002
--
-- Removed flag and disbursement number parameters
-- Added Award Year parameter to main_ack
--
--
--  Bug ID : 1731177
--  Who           When           What
--  sjadhav       19-apr-2001    Added main_ack to process
--                               rfms disb ack . this will get
--                               called from conc. mgr.
--                               Removed l_mode from main
--
--(reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

  l_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE;
  l_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE;
  ln_base_id            NUMBER;
  lv_status VARCHAR2(1);
  l_list    VARCHAR2(32767);
  TYPE base_idRefCur IS REF CURSOR;
  c_base_id base_idRefCur;

  l_msg_str_1           VARCHAR2(1000);
  l_msg_str_2           VARCHAR2(1000);
  l_msg_str_3           VARCHAR2(1000);
  l_msg_str_4           VARCHAR2(1000);
  l_msg_str_5           VARCHAR2(1000);
  l_msg_str_6           VARCHAR2(1000);
  -- Get person id group name
  CURSOR c_pers_id_grp_name(
                            cp_persid_grp igs_pe_persid_group_all.group_id%TYPE
                           ) IS
    SELECT group_cd group_name
      FROM igs_pe_persid_group_all
     WHERE group_id = cp_persid_grp;
  l_pers_id_grp_name c_pers_id_grp_name%ROWTYPE;

  l_error           NUMBER;
  l_record          NUMBER;
  l_cod_year_flag   BOOLEAN;
  lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

BEGIN
  igf_aw_gen.set_org_id(NULL);
  retcode := 0;

  ln_base_id           := base_id;
  l_ci_cal_type        := LTRIM(RTRIM(SUBSTR(award_year,1,10)));
  l_ci_sequence_number := TO_NUMBER(SUBSTR(award_year,11));
  g_trans_type         := p_trans_type;
  g_persid_grp         := p_pers_id_grp;

  -- Check wether the awarding year is COD-XML processing Year or not
  l_cod_year_flag  := NULL;
  l_cod_year_flag := igf_sl_dl_validation.check_full_participant (l_ci_cal_type,l_ci_sequence_number,'PELL');

  -- This process is allowed to run only for PHASE_IN_PARTICIPANT
  -- If the award year is FULL_PARTICIPANT then raise the error message
  --  and stop processing else continue the process
  IF l_cod_year_flag THEN

   fnd_message.set_name('IGF','IGF_GR_COD_NO_DISB');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   RETURN;

  END IF;

  -- FA 126. base_id and attending pell are mutually exclusive.
  IF (base_id IS NOT NULL AND p_attending_pell IS NOT NULL) OR (p_pers_id_grp IS NOT NULL AND p_attending_pell IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME('IGF', 'IGF_GR_PORIG_INCOMPAT');
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
    RETURN;
  END IF;

  IF l_ci_cal_type IS  NULL OR l_ci_sequence_number IS NULL  THEN
    RAISE param_error;
  END IF;

  IF ln_base_id IS NOT NULL AND p_pers_id_grp IS NOT NULL THEN
    RAISE param_error;
  END IF;
  --
  -- Get the Flat File Version and then Proceed
  --
  g_ver_num  := igf_aw_gen.get_ver_num(l_ci_cal_type,l_ci_sequence_number,'P');

  --
  -- Get the Cycle Year
  --
  l_cy_yr    :=  igf_gr_gen.get_cycle_year(l_ci_cal_type,l_ci_sequence_number);

  IF g_ver_num ='NULL' THEN
    RAISE igf_gr_gen.no_file_version;
  END IF;

  -- show parameter 1 - award year
	l_msg_str_1        :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','AWARD_YEAR'),20) || RPAD(igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number),20);
  fnd_file.put_line(fnd_file.log,l_msg_str_1);

  -- show parameter 2 - report pell id
  l_msg_str_3        :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'REPORT_PELL'),20) || p_reporting_pell;
  fnd_file.put_line(fnd_file.log,l_msg_str_3);

  -- show parameter 3 - attend pell id
  IF (p_attending_pell IS NOT NULL) THEN
    l_msg_str_4      :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS', 'ATTEND_PELL'),20) || p_attending_pell;
  	fnd_file.put_line(fnd_file.log,l_msg_str_4);
  END IF;

  -- show trans_type parameter
  l_msg_str_6        := RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS', 'TRANS_TYPE'),20) || igf_aw_gen.lookup_desc('IGF_GR_TRANS_TYPE',p_trans_type);
  fnd_file.put_line(fnd_file.log,l_msg_str_6);

  -- show parameter 4 - base id
  IF (base_id IS NOT NULL) THEN
    l_msg_str_2        :=   RPAD(igf_aw_gen.lookup_desc('IGF_GR_LOOKUPS','BASE_ID'),20) || RPAD(igf_gr_gen.get_per_num(base_id),20);
  	fnd_file.put_line(fnd_file.log,l_msg_str_2);
  END IF;

  -- show parameter 5 - person id group
  IF p_pers_id_grp IS NOT NULL THEN
    OPEN c_pers_id_grp_name(p_pers_id_grp);
    FETCH c_pers_id_grp_name INTO l_pers_id_grp_name;
    CLOSE c_pers_id_grp_name;
    l_msg_str_5       :=   RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'),20) || l_pers_id_grp_name.group_name;
    fnd_file.put_line(fnd_file.log,l_msg_str_5);
  END IF;
  fnd_file.new_line(fnd_file.log,1);

  /*
    Main logic starts here.
  */
  IF ln_base_id IS NOT NULL THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.main.debug','(A)calling rfms_disb_orig with base_id:'||ln_base_id);
    END IF;
    --call the main processing routine
    rfms_disb_orig(l_ci_cal_type,l_ci_sequence_number,ln_base_id, p_reporting_pell, p_attending_pell);

  ELSIF p_attending_pell IS NOT NULL THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.main.debug','(B)calling rfms_disb_orig with attedning pell:'||p_attending_pell);
    END IF;
    --call the main processing routine
    rfms_disb_orig(l_ci_cal_type,l_ci_sequence_number,ln_base_id, p_reporting_pell, p_attending_pell);

  ELSIF p_pers_id_grp IS NOT NULL THEN
    --Bug #5021084
    l_list := igf_ap_ss_pkg.get_pid(p_pers_id_grp,lv_status,lv_group_type);

    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      OPEN c_base_id FOR ' SELECT base_id FROM igf_ap_fa_base_rec_all WHERE  ci_cal_type = :p_ci_cal_type AND  ci_sequence_number = :p_ci_sequence_number AND  person_id IN (' || l_list  || ') ' USING l_ci_cal_type,l_ci_sequence_number,p_pers_id_grp;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      OPEN c_base_id FOR ' SELECT base_id FROM igf_ap_fa_base_rec_all WHERE  ci_cal_type = :p_ci_cal_type AND  ci_sequence_number = :p_ci_sequence_number AND  person_id IN (' || l_list  || ') ' USING l_ci_cal_type,l_ci_sequence_number;
    END IF;

    FETCH c_base_id INTO ln_base_id;

    IF c_base_id%FOUND THEN

      WHILE c_base_id%FOUND LOOP
        BEGIN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_gr_rfms_disb_orig.main.debug','(C)calling rfms_disb_orig with base_id:'||ln_base_id);
          END IF;

          l_record := NVL(l_record,0) + 1;
          --call the main processing routine
          rfms_disb_orig(l_ci_cal_type,l_ci_sequence_number,ln_base_id, p_reporting_pell, p_attending_pell);
        EXCEPTION
          WHEN next_record THEN
            l_error := NVL(l_error,0) + 1;
        END;
        FETCH c_base_id INTO ln_base_id;
      END LOOP;
      CLOSE c_base_id;
      IF l_error = l_record THEN
        RAISE no_data_in_table;
      END IF;
    ELSE
      fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;
  ELSE
    RAISE param_error;
  END IF;

  COMMIT;

EXCEPTION
  WHEN igf_gr_gen.no_file_version THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGF','IGF_GR_VERSION_NOTFOUND');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN batch_not_created THEN
    ROLLBACK;
  WHEN param_error THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGF','IGF_AW_PARAM_ERR');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN no_data_in_table THEN
    ROLLBACK;
    errbuf := fnd_message.get_string('IGF','IGF_AP_NO_DATA_FOUND');
    fnd_file.put_line(fnd_file.log,errbuf);
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || SQLERRM;
    igs_ge_msg_stack.conc_exception_hndl;
 END main;


PROCEDURE main_ack( errbuf      OUT NOCOPY   VARCHAR2,
                    retcode     OUT NOCOPY   NUMBER,
                    p_awd_yr    IN           VARCHAR2,
                    p_org_id    IN           NUMBER)
AS

------------------------------------------------------------------------------
--  This process is called from concurrent manager. This process
--  will invoke rfms disbursements acknowledgement.
--  Who           When           What
--
-- bug 2216956
-- sjadhav, FEB13th,2002
--
-- Removed flag and disbursement number parameters
-- Added Award Year parameter to main_ack
--
--  sjadhav       19-apr-2001    Added main_ack to process
--                               rfms disb ack . this will get
--                               called from conc. mgr.
--                               Removed l_mode from main
--
--  (reverse chronological order - newest change first)
--
------------------------------------------------------------------------------

   l_ci_cal_type         igf_gr_rfms.ci_cal_type%TYPE;
   l_ci_sequence_number  igf_gr_rfms.ci_sequence_number%TYPE;

BEGIN

   retcode := 0;
   igf_aw_gen.set_org_id(p_org_id);
   l_ci_cal_type            :=   LTRIM(RTRIM(SUBSTR(p_awd_yr,1,10)));
   l_ci_sequence_number     :=   TO_NUMBER(SUBSTR(p_awd_yr,11));

   IF l_ci_cal_type IS  NULL OR l_ci_sequence_number IS NULL  THEN
            RAISE param_error;
   END IF;

   -- Check wether the awarding year is COD-XML processing Year or not
   -- This process is allowed to run only for PHASE_IN_PARTICIPANT
   -- If the award year is FULL_PARTICIPANT then raise the error message
   --  and stop processing else continue the process
   IF igf_sl_dl_validation.check_full_participant (l_ci_cal_type,l_ci_sequence_number,'PELL') THEN

     fnd_message.set_name('IGF','IGF_GR_COD_NO_DISB_ACK');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     RETURN;

   END IF;

--
-- Get the Flat File Version and then Proceed
--

   g_ver_num  := igf_aw_gen.get_ver_num(l_ci_cal_type,l_ci_sequence_number,'P');
   g_alt_code := igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number);
   l_cy_yr    :=  igf_gr_gen.get_cycle_year(l_ci_cal_type,l_ci_sequence_number);

   IF g_ver_num ='NULL' THEN
      RAISE igf_gr_gen.no_file_version;
   ELSE
      rfms_disb_ack;
   END IF;

   COMMIT;

EXCEPTION

    WHEN invalid_version THEN
       ROLLBACK;
       retcode := 2;

    WHEN igf_gr_gen.no_file_version THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GR_VERSION_NOTFOUND');
       fnd_file.put_line(fnd_file.log,errbuf);

    WHEN batch_not_created THEN
       ROLLBACK;

    WHEN param_error THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_AW_PARAM_ERR');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.corrupt_data_file THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GR_CORRUPT_DATA_FILE');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.batch_not_in_system  THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get; -- Bug # 4008991
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN igf_gr_gen.file_not_loaded THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN no_data_in_table THEN
       ROLLBACK;
       errbuf := fnd_message.get_string('IGF','IGF_AP_NO_DATA_FOUND');
       fnd_file.put_line(fnd_file.log,errbuf);

     WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || SQLERRM;
       igs_ge_msg_stack.conc_exception_hndl;

END main_ack;

END igf_gr_rfms_disb_orig;

/
