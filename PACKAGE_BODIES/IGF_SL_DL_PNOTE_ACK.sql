--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_PNOTE_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_PNOTE_ACK" AS
/* $Header: IGFSL15B.pls 120.1 2006/04/18 03:50:11 akomurav noship $ */
--
---------------------------------------------------------------------------------
--
--  Created By : prchandr
--  Date Created On : 2000/05/09
--  Purpose : Package for Promissory Note Acknowledgement Process
--  Know limitations, enhancements or remarks
--  Change History
--
--------------------------------------------------------------------------------------
--    Who         When            What
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--  akomurav    17-Apr-2006       Build FA161 and 162.
--                                TBH Impact change done in igf_sl_lor_pkg.update_row().
----------------------------------------------------------------------------------------

-- svuppala     4-Nov-2004      #3416936 FA 134 TBH impacts for newly added columns
---------------------------------------------------------------------------------------

--  ayedubat        20-OCT-2004   FA 149 COD-XML Standards build bug # 3416863
--                                Changed the logic as per the TD, FA149_TD_COD_XML_i1a.doc
-----------------------------------------------------------------------------------
--  veramach        29-Jan-2004     bug 3408092 added 2004-2005 in p_dl_version checks
-----------------------------------------------------------------------------------
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             a) Impact of adding the relationship_cd
--                             in igf_sl_lor_all table and obsoleting
--                             BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                             GUARANTOR_ID, DUNS_GUARNT_ID,
--                             LENDER_ID, DUNS_LENDER_ID
--                             LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                             RECIPIENT_TYPE,DUNS_RECIP_ID
--                             RECIP_NON_ED_BRC_ID columns.
-----------------------------------------------------------------------------------------------------------------------------
--  veramach   23-SEP-2003     Bug 3104228: Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                                          cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                                          p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                                          chg_batch_id,appl_send_error_codes from igf_sl_lor
--                                          Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                                          cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                                          p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                                          chg_batch_id from igf_sl_lor_loc
------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--   sjadhav      27-Mar-2003     Bug 2863960
--                                Changed Disb Gross Amt to Disb Accepted Amt
--                                to insert into igf_sl_awd_disb table
---------------------------------------------------------------------------------
--    smvk        25-Feb-2003     Bug # 2758823.  DL-03-04 updates Build.
---------------------------------------------------------------------------------
--    masehgal    17-Feb-2002     # 2216956   FACR007
--                                Added Elec_mpn_ind,
--                                Borrow_sign_ind in
--                                igf_sl_lor_pkg.update_row
--                                and
--                                igf_sl_cl_resp_r1
---------------------------------------------------------------------------------
--    npalanis    11/jan/2002     The process Common Line Origination
--                                Process( procedure place_holds_disb )
--                                is modified to pick up disbursement
--                                records that are in planned state,
--                                insert records into IGF_DB_DISB_HOLDS
--                                table with hold 'EXTERNAL' and
--                                hold type 'SYSTEM' and also
--                                update manual_hold_ind flag in
--                                IGF_AW_AWD_DISB table to 'Y'.
--                                enh bug no-2154941.
---------------------------------------------------------------------------------
--    ssawhney    2nd jan         TBH call of IGF_AW_AWD_DISB table
--                                changed in Stud Emp build
--                                en bug no 2161847
---------------------------------------------------------------------------------
--    mesriniv    13/07/2001      Modified the call to
--                                igf_aw_awd_disb_pkg.update_row
--                                since 9 columns were added to the
--                                table igf_aw_awd_disb_all.
---------------------------------------------------------------------------------
--

g_lor_loc_rec       igf_sl_lor_loc%ROWTYPE;
FILE_NOT_LOADED     EXCEPTION;
p_disb_title        VARCHAR2(1000);
p_disb_under_line   VARCHAR2(1000);

g_log_title         VARCHAR2(1000);
g_log_start_flag    BOOLEAN;

PROCEDURE update_resp_edit(p_dlpnr_id igf_sl_dl_pnote_resp_all.dlpnr_id%TYPE,
                           p_status igf_sl_dl_pnote_resp_all.status%TYPE);

PROCEDURE compare_disbursements(p_loan_number igf_sl_loans_all.loan_number%TYPE ,
                                loaded_1rec   igf_sl_dl_pnote_resp%ROWTYPE);


PROCEDURE log_message(p_loan_number igf_sl_loans_all.loan_number%TYPE) IS
BEGIN

  IF g_log_start_flag = FALSE THEN
    fnd_file.put_line(fnd_file.log, '');
    fnd_file.put_line(fnd_file.log, '');
    fnd_file.put_line(fnd_file.log, RPAD('-',80,'-'));

    IF g_log_title IS NULL THEN
       g_log_title := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER')||'   : ';
    END IF;

    fnd_file.put_line(fnd_file.log, g_log_title||p_loan_number);
    g_log_start_flag := TRUE;
  END IF;

END log_message;


-- Procedure to Load the Data from the Data File into the Interface tables.
-- Before loading, it does lot of checks to ensure it is the right file
-- and returns the dbth_id, for further processing.

PROCEDURE dl_load_data(p_dbth_id       OUT NOCOPY  igf_sl_dl_batch.dbth_id%TYPE,
                       p_dl_version    OUT NOCOPY igf_sl_dl_file_type.dl_version%TYPE,
                       p_dl_loan_catg  OUT NOCOPY igf_sl_dl_file_type.dl_loan_catg%TYPE)
AS
  /*************************************************************
  Created By : prchandr
  Date Created On : 2001/05/09
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk           18-Feb-2003      Bug # 2758823. Coded for '2003-2004' structure.

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_temp                  VARCHAR2(30);
  l_last_lort_id          NUMBER;
  l_number_rec            NUMBER;
  l_accept_rec            NUMBER;
  l_reject_rec            NUMBER;
  l_pending_rec           NUMBER;

  -- The fields have not been defined as tablename.field%TYPE on
  -- purpose to feedback a proper message to the user
  l_rec_batch_id          VARCHAR2(100);
  l_rec_message_class     VARCHAR2(100);
  l_rec_bth_creation_date VARCHAR2(100);
  l_rec_batch_rej_code    VARCHAR2(100);
  l_rec_batch_type        VARCHAR2(100);

  l_rowid                 VARCHAR2(25);
  l_dbth_id               igf_sl_dl_batch.dbth_id%TYPE;
  l_dl_version            igf_lookups_view.lookup_code%TYPE;
  l_dl_file_type          igf_sl_dl_file_type.dl_file_type%TYPE;
  l_dl_loan_catg          igf_sl_dl_file_type.dl_loan_catg%TYPE;

  -- ## Cursor for Fetching Header records

  CURSOR c_header IS
  SELECT RTRIM(SUBSTR(record_data, 23, 23))       batch_id,
         RTRIM(SUBSTR(record_data, 15,  8))       message_class,
         RTRIM(SUBSTR(record_data, 46, 16))       bth_creation_date,
         RTRIM(SUBSTR(record_data, 60,  2))       batch_rej_code,
         RTRIM(SUBSTR(record_data, 23,  2))       batch_type
  FROM igf_sl_load_file_t
  WHERE  lort_id = 1
  AND    record_data LIKE 'DL HEADER%'
  AND    file_type = 'DL_PNOTE_ACK';

  -- ## Cursor for Fetching Trailer Records

  CURSOR c_trailer IS
  SELECT lort_id                         last_lort_id,
         RTRIM(SUBSTR(record_data,15,7)) number_rec,
         RTRIM(SUBSTR(record_data,22,5)) accept_rec,
         RTRIM(SUBSTR(record_data,27,5)) reject_rec,
         RTRIM(SUBSTr(record_data,32,5)) pending_rec
  FROM igf_sl_load_file_t
  WHERE  lort_id = (SELECT MAX(lort_id) FROM igf_sl_load_file_t)
  AND    record_data LIKE 'DL TRAILER%'
  AND    file_type = 'DL_PNOTE_ACK';

  CURSOR award_year_cur ( cp_dl_version IGF_SL_DL_SETUP.dl_version%TYPE) IS
   SELECT ci_cal_type, ci_sequence_number
   FROM igf_sl_dl_setup
   WHERE dl_version = cp_dl_version;
  award_year_rec award_year_cur%ROWTYPE;
  l_cod_year_flag   BOOLEAN;

BEGIN

  -- Assuming that Header and Trailer record format does not change
  -- since the header record contains Message Class Info, which
  -- indicates the version of the File.

  /***************  Check File Uploaded ********************/

  -- Get the Header details
  OPEN c_header;
  FETCH c_header INTO l_rec_batch_id,
                      l_rec_message_class,
                      l_rec_bth_creation_date,
                      l_rec_batch_rej_code,
                      l_rec_batch_type;
  IF c_header%NOTFOUND THEN
      CLOSE c_header;
      fnd_message.set_name('IGF','IGF_GE_FILE_NOT_COMPLETE');
      -- Message : Response File uploaded is not complete.
      igs_ge_msg_stack.add;
      RAISE FILE_NOT_LOADED;
  END IF;
  CLOSE c_header;

  -- Check whether the File is valid/Not. (ie whether any wrong file is used)
  -- File can be Origination Response For Stafford/PLUS OR a Credit Response.
  -- Also, Check if the file is an OUTPUT File.


  igf_sl_gen.get_dl_batch_details(l_rec_message_class, l_rec_batch_type,
                    l_dl_version, l_dl_file_type, l_dl_loan_catg);

  IF  l_dl_file_type  = 'DL_PNOTE_ACK'
  AND l_dl_loan_catg in ('DL_STAFFORD','DL_PLUS','DL_STAFFORD_PLUS') THEN
     NULL;
  ELSE
      fnd_message.set_name('IGF','IGF_GE_INVALID_FILE');
      -- Message : This is not a valid file
      igs_ge_msg_stack.add;
      RAISE FILE_NOT_LOADED;
  END IF;

  IF l_dl_loan_catg in ('DL_STAFFORD','DL_PLUS','DL_STAFFORD_PLUS') THEN
      -- This is an Direct Loan Promissory Note Acknowledgment File
      fnd_message.set_name('IGF','IGF_SL_DL_ORIG_PNOTE_FILE');
      fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET);

  END IF;

  -- Get the System Award Year from l_dl_version
  OPEN award_year_cur (l_dl_version);
  FETCH award_year_cur INTO award_year_rec;
  CLOSE award_year_cur;

  -- Check wether the awarding year is COD-XML processing Year or not
  l_cod_year_flag  := NULL;
  l_cod_year_flag := igf_sl_dl_validation.check_full_participant (award_year_rec.ci_cal_type,award_year_rec.ci_sequence_number,'DL');

  -- If the award year is FULL_PARTICIPANT then raise the error message
  --  and stop processing else continue the process
  IF l_cod_year_flag THEN

   fnd_message.set_name('IGF','IGF_SL_COD_NO_PNOTE_ACK');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   RETURN;

  END IF;

  -- Check whether the File was Fully transferred.
  -- Get the record details in the File.
  OPEN c_trailer;
  FETCH c_trailer into l_last_lort_id, l_number_rec, l_accept_rec,
                       l_reject_rec,   l_pending_rec;
  IF c_trailer%NOTFOUND THEN
      CLOSE c_trailer;
      fnd_message.set_name('IGF','IGF_GE_FILE_NOT_COMPLETE');
      igs_ge_msg_stack.add;
      RAISE FILE_NOT_LOADED;
  END IF;
  CLOSE c_trailer;



  IF l_rec_batch_rej_code IS NOT NULL  THEN
      fnd_message.set_name('IGF','IGF_GE_BATCH_REJECTED');
      fnd_message.set_token('BATCH', l_rec_batch_id);
      fnd_message.set_token('REASON', igf_aw_gen.lookup_desc('IGF_SL_DL_BATCH_REJ',l_rec_batch_rej_code));
      igs_ge_msg_stack.add;

      -- Message : Batch #BATCH was rejected. Reason : #REASON.
      RAISE FILE_NOT_LOADED;
  END IF;


  l_rowid := NULL;
  igf_sl_dl_batch_pkg.insert_row (
      x_mode                 => 'R',
      x_rowid                => l_rowid,
      X_dbth_id              => l_dbth_id,
      X_batch_id             => l_rec_batch_id,
      X_message_class        => l_rec_message_class,
      X_bth_creation_date    => TO_DATE(l_rec_bth_creation_date,'YYYYMMDDHH24MISS'),
      X_batch_rej_code       => l_rec_batch_rej_code,
      X_end_date             => NULL,
      X_batch_type           => l_rec_batch_type,
      X_send_resp            => 'R',
      X_status               => 'Y'
  );




  /***************  Load Transactions ********************/

  DECLARE

     l_actual_rec      NUMBER DEFAULT 0;
     l_lor_resp_num    NUMBER;
     lv_rowid          VARCHAR2(100);
     lc_rowid           VARCHAR2(100);
     l_dlpnr_id        igf_sl_dl_pnote_resp.dlpnr_id%TYPE;
     l_dlpdr_id        igf_sl_dl_pdet_resp.dlpdr_id%TYPE;
     l_c_elec_mpn_ind  igf_sl_dl_pnote_resp.ELEC_MPN_IND%TYPE := NULL;

     CURSOR c_trans
     IS
     SELECT record_data
     FROM   igf_sl_load_file_t
     WHERE  lort_id between 2 AND (l_last_lort_id-1)
     AND    file_type = 'DL_PNOTE_ACK';

  BEGIN
    IF l_dl_version = '2002-2003' THEN


       -- File is Origination Response File For Stafford/PLUS.
       IF l_dl_loan_catg in ('DL_STAFFORD','DL_PLUS','DL_STAFFORD_PLUS') THEN

       FOR orec IN c_trans LOOP
             l_actual_rec := l_actual_rec + 1;
             l_rowid := NULL;
             l_c_elec_mpn_ind := SUBSTR(orec.record_data,190,1);
             IF l_c_elec_mpn_ind  IS NULL THEN
                l_c_elec_mpn_ind := 'P';
             ELSE
                l_c_elec_mpn_ind := SUBSTR(orec.record_data,190,1);
             END IF;
              igf_sl_dl_pnote_resp_pkg.insert_row (
                                x_rowid                => lv_rowid,
                                x_dlpnr_id             => l_dlpnr_id,
                                x_dbth_id              => l_dbth_id,
                                x_pnote_ack_date       => TO_DATE(RTRIM(SUBSTR(orec.record_data, 1,8)),'YYYYMMDD'),
                                x_pnote_batch_id       => RTRIM(SUBSTR(orec.record_data, 9,23)),
                                x_loan_number          => RTRIM(SUBSTR(orec.record_data, 32,21)),
                                x_pnote_status         => RTRIM(SUBSTR(orec.record_data, 53,1)),
                                x_pnote_rej_codes      => RTRIM(SUBSTR(orec.record_data, 54,10)),
                                x_mpn_ind              => RTRIM(SUBSTR(orec.record_data, 164,21)),
                                x_pnote_accept_amt     => LTRIM(RTRIM(SUBSTR(orec.record_data, 185,5))),
                                x_elec_mpn_ind         => l_c_elec_mpn_ind,
                                x_status               => 'N',
                                x_mode                 => 'R'
                  );


            -- ## For each Loan there will be Many Disbursement Records
            -- ## Insert that record in IGF_SL_DL_PDET_RESP table

             FOR i IN 0..19 LOOP
               IF RTRIM(SUBSTR(orec.record_data, 64 + (i * 5),5)) IS NOT NULL THEN

                 igf_sl_dl_pdet_resp_pkg.insert_row (
                                    x_mode            => 'R',
                                    x_rowid           => lc_rowid,
                                    x_dlpnr_id        => l_dlpnr_id,
                                    x_dlpdr_id        => i + 1,
                                    x_disb_gross_amt  => TO_NUMBER(RTRIM(SUBSTR(orec.record_data, 64 + (i * 5),5))));
               END IF;

             END LOOP;

       END LOOP;

      END IF;
    ELSIF l_dl_version IN ('2003-2004','2004-2005') THEN
       -- File is Origination Response File For Stafford/PLUS.
       IF l_dl_loan_catg in ('DL_STAFFORD','DL_PLUS','DL_STAFFORD_PLUS') THEN

       FOR orec IN c_trans LOOP
             l_actual_rec := l_actual_rec + 1;
             l_rowid := NULL;
             l_c_elec_mpn_ind := SUBSTR(orec.record_data,190,1);

             IF l_c_elec_mpn_ind  IS NULL THEN
                l_c_elec_mpn_ind := 'P';
             ELSE
                l_c_elec_mpn_ind := SUBSTR(orec.record_data,190,1);
             END IF;
              igf_sl_dl_pnote_resp_pkg.insert_row (
                                x_rowid               => lv_rowid,
                                x_dlpnr_id            => l_dlpnr_id,
                                x_dbth_id             => l_dbth_id,
                                x_pnote_ack_date      => TO_DATE(RTRIM(SUBSTR(orec.record_data, 1,8)),'YYYYMMDD'),
                                x_pnote_batch_id      => RTRIM(SUBSTR(orec.record_data, 9,23)),
                                x_loan_number         => RTRIM(SUBSTR(orec.record_data, 32,21)),
                                x_pnote_status        => RTRIM(SUBSTR(orec.record_data, 53,1)),
                                x_pnote_rej_codes     => RTRIM(SUBSTR(orec.record_data, 54,10)),
                                x_mpn_ind             => RTRIM(SUBSTR(orec.record_data, 164,21)),
                                x_pnote_accept_amt    => NULL,
                                x_elec_mpn_ind        => l_c_elec_mpn_ind,
                                x_status              => 'N',
                                x_mode                => 'R'
                  );

       END LOOP;

      END IF;

    END IF;    -- End of condition for VERSION.

    IF l_actual_rec <> l_number_rec THEN
       fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
       -- Message : The Actual Number of records does not match with the one mentioned in the trailer
       igs_ge_msg_stack.add;
       RAISE FILE_NOT_LOADED;
    END IF;

 END;

 p_dbth_id       := l_dbth_id;
 p_dl_version    := l_dl_version;
 p_dl_loan_catg  := l_dl_loan_catg;


EXCEPTION
WHEN app_exception.record_lock_exception THEN
   RAISE;
WHEN FILE_NOT_LOADED THEN
   RAISE;
WHEN OTHERS THEN
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_PNOTE_ACK.DL_LOAD_DATA');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END dl_load_data;

/* MAIN PROCEDURE */
PROCEDURE process_ack(errbuf   OUT NOCOPY   VARCHAR2,
                      retcode  OUT NOCOPY   NUMBER,
                      P_org_id IN           NUMBER)
AS
  /*************************************************************
  Created By : prchandr
  Date Created On : 2001/05/09
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ------------------------------------------------------------------------------
  bkkumar    06-oct-2003        Bug 3104228 FA 122 Loans Enhancements
                                Impact of adding the relationship_cd
                                in igf_sl_lor_all table and obsoleting
                                BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
                                GUARANTOR_ID, DUNS_GUARNT_ID,
                                LENDER_ID, DUNS_LENDER_ID
                                LEND_NON_ED_BRC_ID, RECIPIENT_ID
                                RECIPIENT_TYPE,DUNS_RECIP_ID
                                RECIP_NON_ED_BRC_ID columns.
  ------------------------------------------------------------------------------
  smvk            18-Feb-2003     Bug # 2758823. Coded for '2003-2004' structure.
  masehgal        19-Feb-2002     # 2216956   FACR007
                                  Added Stud_sign_ind , Borr_sign_ind
  (reverse chronological order - newest change first)
  ***************************************************************/

  l_dbth_id               igf_sl_dl_batch.dbth_id%TYPE;
  l_batch_type            igf_sl_dl_batch.batch_type%TYPE;
  l_rec_present           VARCHAR2(10);
  l_rec_updated           VARCHAR2(10);
  l_stat                  VARCHAR2(30);

  l_dl_version            igf_sl_dl_file_type.dl_version%TYPE;
  l_dl_loan_catg          igf_sl_dl_file_type.dl_loan_catg%TYPE;

  -- ## Cursor to get the batch Records

  CURSOR cur_batch IS
  SELECT igf_sl_dl_batch.* FROM igf_sl_dl_batch
  WHERE dbth_id = l_dbth_id;

  -- ## Cursor to Fetch the Unprocessed Records from Promissory Note
  -- ## Table

  CURSOR cur_pnote_resp(l_dbth_id igf_sl_dl_batch.dbth_id%TYPE) IS
  SELECT igf_sl_dl_pnote_resp.* FROM igf_sl_dl_pnote_resp
  WHERE dbth_id = l_dbth_id
  AND   status  = 'N';


  -- To Check whether the Loan Exists in Financial Aid i.e exists in

  CURSOR cur_loans(p_loan_number igf_sl_dl_pnote_resp_all.loan_number%TYPE) IS
  SELECT fed_fund_code, count(*) countcol
  FROM igf_sl_loans_v loans
  WHERE loan_number=p_loan_number
  GROUP BY fed_fund_code;

  -- TO get loan_id from the particular loan_number

  CURSOR cur_loanid(p_loan_number igf_sl_loans_all.loan_number%TYPE) IS
  SELECT loan_id FROM
  igf_sl_loans
  WHERE trim(loan_number)=trim(p_loan_number);

  -- To get the next sequence number
  CURSOR c_seq_num IS
  SELECT igf_sl_wf_process_s.NEXTVAL
    FROM DUAL;


  l_cur_loans   cur_loans%ROWTYPE;
  lcur_loanid   cur_loanid%ROWTYPE;
  l_seq_no      NUMBER;
  -- ## User Defined Exceptions

  invalid_loan  EXCEPTION;
  Rec_no_update EXCEPTION;
  no_loan_id    EXCEPTION;

BEGIN

retcode := 0;
-- ## Set the Org ID
igf_aw_gen.set_org_id(p_org_id);


-- Load the Data into the Batch and Response Tables
dl_load_data(l_dbth_id, l_dl_version, l_dl_loan_catg);

IF l_dl_loan_catg IN ('DL_PLUS','DL_STAFFORD','DL_STAFFORD_PLUS') THEN


FOR dbth_rec IN cur_batch LOOP -- ## Outer Loop for selecting from Batch Table


  FOR resp_rec IN cur_pnote_resp(l_dbth_id) LOOP -- ## Selects records from PNOTE_ERSP table
     BEGIN

       g_log_start_flag   := FALSE;
       l_rec_present := 'N';
       l_rec_updated := 'N';

          OPEN  cur_loans(resp_rec.loan_number);
          FETCH cur_loans INTO l_cur_loans;

          -- Check if the Loan is in Financial Aid else skip the record
          -- and raise a exception

          IF l_cur_loans.countcol  = 0 THEN
               log_message(resp_rec.loan_number);
               update_resp_edit(resp_rec.dlpnr_id,'I');  -- ## Set the status as Invalid Loan
               CLOSE cur_loans;
               RAISE invalid_loan;
          END IF;
          CLOSE cur_loans;

          -- ## Check for Reject Codes IF EXISTS then
          -- ## skip the record and PUt the message in LOG File
          --  ## with the reject Descriptions
          IF resp_rec.pnote_rej_codes IS NOT NULL THEN

                log_message(resp_rec.loan_number);
                fnd_message.set_name('IGF','IGF_SL_DL_REJ_EXISTS');
                fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET);
                resp_rec.pnote_rej_codes := translate(resp_rec.pnote_rej_codes,'0',' ');
                DECLARE
                  CURSOR c_rej IS
                  SELECT lookup_code, meaning FROM igf_lookups_view
                  WHERE  lookup_type = 'IGF_SL_PNOTE_REJ_CODES'
                  AND    lookup_code IN (LTRIM(RTRIM(SUBSTR(resp_rec.pnote_rej_codes, 1,2))),
                                         LTRIM(RTRIM(SUBSTR(resp_rec.pnote_rej_codes, 3,2))),
                                         LTRIM(RTRIM(SUBSTR(resp_rec.pnote_rej_codes, 5,2))),
                                         LTRIM(RTRIM(SUBSTR(resp_rec.pnote_rej_codes, 7,2))),
                                         LTRIM(RTRIM(SUBSTR(resp_rec.pnote_rej_codes, 9,2))));
                BEGIN
                  igf_sl_edit.delete_edit(resp_rec.loan_number, 'P');
                  FOR rrec IN c_rej LOOP
                      fnd_file.put_line(fnd_file.log, '   '||RPAD(rrec.lookup_code,3)||' - '||rrec.meaning);
                      igf_sl_edit.insert_edit(resp_rec.loan_number, 'P', 'IGF_SL_PNOTE_REJ_CODES',
                                              rrec.lookup_code, '', '');
                  END LOOP;
                END;
          END IF;

          -- ## Check if PNOTE is Rejected then Skip the Record
          -- ## and call for the Work Flow Process.

          IF resp_rec.pnote_status='R' THEN

             OPEN cur_loanid(resp_rec.loan_number);

             FETCH cur_loanid INTO lcur_loanid;
             log_message(resp_rec.loan_number);
             fnd_message.set_name('IGF','IGF_SL_DL_PNOTE_REJECTED');
             fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET);

             IF cur_loanid%NOTFOUND THEN
                CLOSE cur_loanid;
                log_message(resp_rec.loan_number);
                update_resp_edit(resp_rec.dlpnr_id,'I');
                RAISE invalid_loan;
             END IF;

             OPEN c_seq_num;
             FETCH c_seq_num INTO l_seq_no;
             CLOSE c_seq_num;

             wf_engine.CreateProcess
                     (itemtype => 'DLPNA',
                      itemkey => l_seq_no,
                      process => 'WF_DLPNOTE_REJ');


             wf_engine.SetItemAttrNumber('DLPNA',
                       l_seq_no,
                       'VDBTHID',
                       l_dbth_id);

             wf_engine.SetItemAttrNumber
                        ('DLPNA',
                         l_seq_no,
                         'VLOANID',
                          lcur_loanid.loan_id);

             wf_engine.StartProcess
                      (itemtype => 'DLPNA',
                       itemkey =>l_seq_no );

          END IF;


          DECLARE
               CURSOR c_tbh_cur IS
               SELECT igf_sl_lor.* FROM igf_sl_lor
               WHERE loan_id = (SELECT loan_id FROM igf_sl_loans lar
                                WHERE  loan_number = resp_rec.loan_number)
                                FOR UPDATE NOWAIT ;
          BEGIN

            FOR tbh_rec IN c_tbh_cur LOOP
                 -- ## Check if Promissory Note is Accepted and Ack Date is NOT NULL
                 -- ## then Print the message and skip the record and raise a
                 -- ## User Defined exception
                IF tbh_rec.pnote_status='A' AND tbh_rec.pnote_ack_date IS NOT NULL THEN
                     log_message(resp_rec.loan_number);
                     fnd_message.set_name('IGF','IGF_SL_DL_AlREADY_ACCEPTED');
                     fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET);
                     update_resp_edit(resp_rec.dlpnr_id,'U');
                     RAISE Rec_no_update;
                ELSE

                    -- ## If all the conditions are satisfied then
                    -- ## check if PNOTE_ACK_DATE in PNOTE TABLE is greater than
                    -- ## that in LOR table then update the LOR table with
                    -- ## PNOTE related details in  LOR table

                                  tbh_rec.pnote_status          := resp_rec.pnote_status;
                                  tbh_rec.pnote_status_date     := TRUNC(sysdate);
                                  tbh_rec.pnote_batch_id        := resp_rec.pnote_batch_id;
                                  tbh_rec.pnote_ack_date        := resp_rec.pnote_ack_date;
                                  tbh_rec.pnote_id              := resp_rec.mpn_ind;
                                  tbh_rec.pnote_accept_amt      := resp_rec.pnote_accept_amt;
                                  tbh_rec.pnote_accept_date     := TRUNC(sysdate);
                                  tbh_rec.elec_mpn_ind          := resp_rec.elec_mpn_ind;

                       igf_sl_lor_pkg.update_row (
                                      X_Mode                              => 'R',
                                      x_rowid                             => tbh_rec.row_id,
                                      x_origination_id                    => tbh_rec.origination_id,
                                      x_loan_id                           => tbh_rec.loan_id,
                                      x_sch_cert_date                     => tbh_rec.sch_cert_date,
                                      x_orig_status_flag                  => tbh_rec.orig_status_flag,
                                      x_orig_batch_id                     => tbh_rec.orig_batch_id,
                                      x_orig_batch_date                   => tbh_rec.orig_batch_date,
                                      x_chg_batch_id                      => NULL,
                                      x_orig_ack_date                     => tbh_rec.orig_ack_date,
                                      x_credit_override                   => tbh_rec.credit_override,
                                      x_credit_decision_date              => tbh_rec.credit_decision_date,
                                      x_req_serial_loan_code              => tbh_rec.req_serial_loan_code,
                                      x_act_serial_loan_code              => tbh_rec.act_serial_loan_code,
                                      x_pnote_delivery_code               => tbh_rec.pnote_delivery_code,
                                      x_pnote_status                      => tbh_rec.pnote_status,
                                      x_pnote_status_date                 => tbh_rec.pnote_status_date,
                                      x_pnote_id                          => tbh_rec.pnote_id,
                                      x_pnote_batch_id                    => tbh_rec.pnote_batch_id,
                                      x_pnote_ack_date                    => tbh_rec.pnote_ack_date,
                                      x_pnote_mpn_ind                     => tbh_rec.pnote_mpn_ind,
                                      x_pnote_print_ind                   => tbh_rec.pnote_print_ind,
                                      x_pnote_accept_amt                  => tbh_rec.pnote_accept_amt,
                                      x_pnote_accept_date                 => tbh_rec.pnote_accept_date,
                                      x_unsub_elig_for_heal               => tbh_rec.unsub_elig_for_heal,
                                      x_disclosure_print_ind              => tbh_rec.disclosure_print_ind,
                                      x_orig_fee_perct                    => tbh_rec.orig_fee_perct,
                                      x_borw_confirm_ind                  => tbh_rec.borw_confirm_ind,
                                      x_borw_interest_ind                 => tbh_rec.borw_interest_ind,
                                      x_borw_outstd_loan_code             => tbh_rec.borw_outstd_loan_code,
                                      x_unsub_elig_for_depnt              => tbh_rec.unsub_elig_for_depnt,
                                      x_guarantee_amt                     => tbh_rec.guarantee_amt,
                                      x_guarantee_date                    => tbh_rec.guarantee_date,
                                      x_guarnt_amt_redn_code              => tbh_rec.guarnt_amt_redn_code,
                                      x_guarnt_status_code                => tbh_rec.guarnt_status_code,
                                      x_guarnt_status_date                => tbh_rec.guarnt_status_date,
                                      x_lend_apprv_denied_code            => NULL,
                                      x_lend_apprv_denied_date            => NULL,
                                      x_lend_status_code                  => tbh_rec.lend_status_code,
                                      x_lend_status_date                  => tbh_rec.lend_status_date,
                                      x_guarnt_adj_ind                    => tbh_rec.guarnt_adj_ind,
                                      x_grade_level_code                  => tbh_rec.grade_level_code,
                                      x_enrollment_code                   => tbh_rec.enrollment_code,
                                      x_anticip_compl_date                => tbh_rec.anticip_compl_date,
                                      x_borw_lender_id                    => NULL,
                                      x_duns_borw_lender_id               => NULL,
                                      x_guarantor_id                      => NULL,
                                      x_duns_guarnt_id                    => NULL,
                                      x_prc_type_code                     => tbh_rec.prc_type_code,
                                      x_cl_seq_number                     => tbh_rec.cl_seq_number,
                                      x_last_resort_lender                => tbh_rec.last_resort_lender,
                                      x_lender_id                         => NULL,
                                      x_duns_lender_id                    => NULL,
                                      x_lend_non_ed_brc_id                => NULL,
                                      x_recipient_id                      => NULL,
                                      x_recipient_type                    => NULL,
                                      x_duns_recip_id                     => NULL,
                                      x_recip_non_ed_brc_id               => NULL,
                                      x_rec_type_ind                      => tbh_rec.rec_type_ind,
                                      x_cl_loan_type                      => tbh_rec.cl_loan_type,
                                      x_cl_rec_status                     => NULL,
                                      x_cl_rec_status_last_update         => NULL,
                                      x_alt_prog_type_code                => tbh_rec.alt_prog_type_code,
                                      x_alt_appl_ver_code                 => tbh_rec.alt_appl_ver_code,
                                      x_mpn_confirm_code                  => NULL,
                                      x_resp_to_orig_code                 => tbh_rec.resp_to_orig_code,
                                      x_appl_loan_phase_code              => NULL,
                                      x_appl_loan_phase_code_chg          => NULL,
                                      x_appl_send_error_codes             => NULL,
                                      x_tot_outstd_stafford               => tbh_rec.tot_outstd_stafford,
                                      x_tot_outstd_plus                   => tbh_rec.tot_outstd_plus,
                                      x_alt_borw_tot_debt                 => tbh_rec.alt_borw_tot_debt,
                                      x_act_interest_rate                 => tbh_rec.act_interest_rate,
                                      x_service_type_code                 => tbh_rec.service_type_code,
                                      x_rev_notice_of_guarnt              => tbh_rec.rev_notice_of_guarnt,
                                      x_sch_refund_amt                    => tbh_rec.sch_refund_amt,
                                      x_sch_refund_date                   => tbh_rec.sch_refund_date,
                                      x_uniq_layout_vend_code             => tbh_rec.uniq_layout_vend_code,
                                      x_uniq_layout_ident_code            => tbh_rec.uniq_layout_ident_code,
                                      x_p_person_id                       => tbh_rec.p_person_id,
                                      x_p_ssn_chg_date                    => NULL,
                                      x_p_dob_chg_date                    => NULL,
                                      x_p_permt_addr_chg_date             => tbh_rec.p_permt_addr_chg_date,
                                      x_p_default_status                  => tbh_rec.p_default_status,
                                      x_p_signature_code                  => tbh_rec.p_signature_code,
                                      x_p_signature_date                  => tbh_rec.p_signature_date,
                                      x_s_ssn_chg_date                    => NULL,
                                      x_s_dob_chg_date                    => NULL,
                                      x_s_permt_addr_chg_date             => tbh_rec.s_permt_addr_chg_date,
                                      x_s_local_addr_chg_date             => NULL,
                                      x_s_default_status                  => tbh_rec.s_default_status,
                                      x_s_signature_code                  => tbh_rec.s_signature_code,
                                      x_elec_mpn_ind                      => tbh_rec.elec_mpn_ind,
                                      x_borr_sign_ind                     => tbh_rec.borr_sign_ind,
                                      x_stud_sign_ind                     => tbh_rec.stud_sign_ind,
                                      x_borr_credit_auth_code             => tbh_rec.borr_credit_auth_code,
                                      x_relationship_cd                   => tbh_rec.relationship_cd,
                                      x_interest_rebate_percent_num       => tbh_rec.interest_rebate_percent_num,
                                      x_cps_trans_num                     => tbh_rec.cps_trans_num,
                                      x_atd_entity_id_txt                 => tbh_rec.atd_entity_id_txt,
                                      x_rep_entity_id_txt                 => tbh_rec.rep_entity_id_txt,
                                      x_crdt_decision_status              => tbh_rec.crdt_decision_status,
                                      x_note_message                      => tbh_rec.note_message,
                                      x_book_loan_amt                     => tbh_rec.book_loan_amt,
                                      x_book_loan_amt_date                => tbh_rec.book_loan_amt_date,
                                      x_pymt_servicer_amt                 => tbh_rec.pymt_servicer_amt,
                                      x_pymt_servicer_date                => tbh_rec.pymt_servicer_date,
                                      x_requested_loan_amt                => tbh_rec.requested_loan_amt,
                                      x_eft_authorization_code            => tbh_rec.eft_authorization_code,
                                      x_external_loan_id_txt              => tbh_rec.external_loan_id_txt,
                                      x_deferment_request_code            => tbh_rec.deferment_request_code ,
                                      x_actual_record_type_code           => tbh_rec.actual_record_type_code,
                                      x_reinstatement_amt                 => tbh_rec.reinstatement_amt,
                                      x_school_use_txt                    => tbh_rec.school_use_txt,
                                      x_lender_use_txt                    => tbh_rec.lender_use_txt,
                                      x_guarantor_use_txt                 => tbh_rec.guarantor_use_txt,
                                      x_fls_approved_amt                  => tbh_rec.fls_approved_amt,
                                      x_flu_approved_amt                  => tbh_rec.flu_approved_amt,
                                      x_flp_approved_amt                  => tbh_rec.flp_approved_amt,
                                      x_alt_approved_amt                  => tbh_rec.alt_approved_amt,
                                      x_loan_app_form_code                => tbh_rec.loan_app_form_code,
                                      x_override_grade_level_code         => tbh_rec.override_grade_level_code,
				      x_b_alien_reg_num_txt               => tbh_rec.b_alien_reg_num_txt,
                                      x_esign_src_typ_cd                  => tbh_rec.esign_src_typ_cd,
                                      x_acad_begin_date                   => tbh_rec.acad_begin_date,
                                      x_acad_end_date                     => tbh_rec.acad_end_date
				   );

                    -- ## Incase of PLUS loans then addtional Validations need to be
                    -- ## done. Compare the Disbursements for uniqueness in PDET_RESP
                    --  ## table and award Disb Table.
                    IF  igf_sl_gen.chk_dl_plus(l_cur_loans.fed_fund_code) = 'TRUE'  AND
                        l_dl_version = '2002-2003' THEN

                          DECLARE
                             CURSOR cur_award(p_loan_number igf_sl_dl_pnote_resp_all.loan_number%TYPE) IS
                                    SELECT NVL(loan_amt_offered,loan_amt_accepted) loan_amt FROM
                                    igf_sl_loans_v WHERE
                                    loan_number = TRIM(p_loan_number);

                             lcur_award cur_award%ROWTYPE;
                           BEGIN

                              OPEN cur_award(resp_rec.loan_number);
                              FETCH cur_award INTO lcur_award;
                              EXIT WHEN cur_award%NOTFOUND;
                              IF resp_rec.pnote_accept_amt <> lcur_award.loan_amt THEN
                                   log_message(resp_rec.loan_number);
                                   fnd_file.put_line(fnd_file.log,
                                           RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','PNOTE_ACCEPT_AMT'),40,' ')||' : '||
                                                TO_CHAR(resp_rec.pnote_accept_amt));
                                   fnd_file.put_line(fnd_file.log,
                                           RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_AMT_ACCEPTED'),40,' ')||' : '||
                                                TO_CHAR(lcur_award.loan_amt));
                              END IF;
                            END;
                    END IF;
                    IF l_dl_version = '2002-2003' THEN
                           compare_disbursements(resp_rec.loan_number,resp_rec);
                    END IF;
                END IF;

                update_resp_edit(resp_rec.dlpnr_id,'Y');

            END LOOP;

          END;



       EXCEPTION
       WHEN invalid_loan THEN
               fnd_message.set_name('IGF','IGF_SL_DL_INVALID_LOAN');
               fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET);
       WHEN Rec_no_update THEN
               NULL;
       WHEN no_loan_id THEN
               NULL;
       END;

   END LOOP;

  END LOOP;

 END IF;   -- Condition for Loan Category Checking

 fnd_file.put_line(fnd_file.log, '');

 COMMIT;

EXCEPTION
    WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
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

END process_ack;

PROCEDURE update_resp_edit(p_dlpnr_id igf_sl_dl_pnote_resp_all.dlpnr_id%TYPE,p_status igf_sl_dl_pnote_resp_all.status%TYPE) IS

    CURSOR c_tbh_cur IS
                          SELECT resp.* FROM igf_sl_dl_pnote_resp resp
                          WHERE dlpnr_id = p_dlpnr_id
                          FOR UPDATE NOWAIT;

    /*************************************************************
    Created By : prchandr
    Date Created On : 2001/05/09
    Purpose : Procedure to  Update the PNOTE_RESP table
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    masehgal        19-Feb-2002     # 2216956   FACR007
                                    Added Elec_mpn_ind
    (reverse chronological order - newest change first)
    ***************************************************************/
BEGIN

    FOR tbh_cur IN c_tbh_cur LOOP

      igf_sl_dl_pnote_resp_pkg.update_row (
      x_mode                              => 'R',
      x_rowid                             => tbh_cur.row_id,
      x_dlpnr_id                          => tbh_cur.dlpnr_id,
      x_dbth_id                           => tbh_cur.dbth_id,
      x_pnote_ack_date                    => tbh_cur.pnote_ack_date,
      x_pnote_batch_id                    => tbh_cur.pnote_batch_id,
      x_loan_number                       => tbh_cur.loan_number,
      x_pnote_status                      => tbh_cur.pnote_status,
      x_pnote_rej_codes                   => tbh_cur.pnote_rej_codes,
      x_mpn_ind                           => tbh_cur.mpn_ind,
      x_pnote_accept_amt                  => tbh_cur.pnote_accept_amt,
      x_elec_mpn_ind                      => tbh_cur.elec_mpn_ind,
      x_status                            => p_status
    );

   END LOOP;

END update_resp_edit;

PROCEDURE compare_disbursements(p_loan_number igf_sl_loans_all.loan_number%TYPE ,
                                loaded_1rec   igf_sl_dl_pnote_resp%ROWTYPE)
AS
   /***************************************************************
   Created By           :       prchandr
   Date Created By      :       2000/12/07
   Purpose              :       To Compare the Disbursement Amounts specified in the
                                 FILE WITH THAT in the IGF_AW_AWD_DISB table
   Known Limitations,Enhancements or Remarks
   Change History       :
   Who                  When            What
   ***************************************************************/

    l_old_count         NUMBER;
    l_new_count         NUMBER;
    l_award_id          igf_aw_awd_disb.award_id%TYPE;
    l_disb_num          igf_aw_awd_disb.disb_num%TYPE;
    l_disb_gross_amt    igf_aw_awd_disb.disb_gross_amt%TYPE;


      --Count the No.of Disbursements for the award id in Awards Disbursements Table
      CURSOR cur_count_old_disb
        IS
        SELECT award_id,  NVL(COUNT(disb_num),0) FROM igf_aw_awd_disb
        WHERE award_id = (SELECT award_id FROM igf_sl_loans
                          WHERE loan_number = p_loan_number)
        GROUP BY award_id;

      --Count the No.of Disbursements for the award id in Response8 Disbursements Table
      CURSOR cur_count_new_disb
        IS
        SELECT NVL(COUNT(resp.dlpdr_id),0) FROM igf_sl_dl_pdet_resp resp
        WHERE dlpnr_id                = loaded_1rec.dlpnr_id;

      -- Check if the Disb-Num and Disb_gross_amts are same between the File and
      -- currently in our system.
      CURSOR cur_disb_same_data IS
        SELECT disb_num, disb_gross_amt FROM
        ((
         SELECT disb_num, NVL(disb_accepted_amt,0) disb_gross_amt FROM igf_aw_awd_disb adisb
          WHERE award_id = l_award_id
          MINUS
          SELECT dlpdr_id, disb_gross_amt FROM igf_sl_dl_pdet_resp resp
          WHERE dlpnr_id = loaded_1rec.dlpnr_id
         )
         UNION
         (SELECT dlpdr_id, disb_gross_amt FROM igf_sl_dl_pdet_resp resp
          WHERE dlpnr_id = loaded_1rec.dlpnr_id
          MINUS
          SELECT disb_num, NVL(disb_accepted_amt,0) disb_gross_amt FROM igf_aw_awd_disb adisb
          WHERE award_id = l_award_id
         )
        );

      --select the NewDisbursements for the award id in Response8 Disbursements Table
      CURSOR cur_new_disbursements
        IS
        SELECT * FROM igf_sl_dl_pdet_resp resp
        WHERE dlpnr_id         = loaded_1rec.dlpnr_id
        ORDER By dlpnr_id;

      --Select the old Disbursements for the award id in Awards Disbursements Table
      CURSOR cur_old_disbursements
      IS
      SELECT * FROM  igf_aw_awd_disb
      WHERE award_id = l_award_id
      ORDER BY disb_num;


    --To update the Resp
     --Records with Y as Record Status


    PROCEDURE show_disb_details
    AS


     -- Show all Disb details   (From OFA)
     --    Disb-Num    Disb-Gross
     -- Show all Disb detail    (From File)
     --    Disb-Num    Disb-Gross

    BEGIN

        IF p_disb_title IS  NULL THEN
            p_disb_title :=  LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NUM'),30)
                            ||LPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_GROSS_AMT'),30);


           p_disb_under_line := RPAD('-',30,'-')
                              ||RPAD('-',30,'-');
        END IF;

        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_GEN','OFA_DISB_DETAILS'));
        fnd_file.put_line(fnd_file.log,p_disb_title);
        fnd_file.put_line(fnd_file.log,p_disb_under_line);
        --To show the Disbursement Details in OFA

        FOR OFA_disb IN cur_old_disbursements
        LOOP
             fnd_file.put_line(fnd_file.log,
                                 LPAD(TO_CHAR(OFA_disb.disb_num),30)
                                 ||LPAD(TO_CHAR(OFA_disb.disb_accepted_amt),30));
        END LOOP;

        --To show the Disbursement details in File
        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_GEN','LOC_DISB_DETAILS'));
        fnd_file.put_line(fnd_file.log,p_disb_title);
        fnd_file.put_line(fnd_file.log,p_disb_under_line);

        FOR LOC_disb IN cur_new_disbursements
        LOOP
           fnd_file.put_line(fnd_file.log,
                               LPAD(TO_CHAR(LOC_disb.dlpdr_id),30)
                               ||LPAD(TO_CHAR(LOC_disb.disb_gross_amt),30));

        END LOOP;

    END show_disb_details;


    PROCEDURE place_disb_holds(p_award_id   igf_aw_awd_disb.award_id%TYPE)
    AS
        CURSOR c_tbh_cur IS
        SELECT adisb.* FROM igf_aw_awd_disb adisb
        WHERE award_id = p_award_id and
        trans_type = 'P';

        CURSOR cur_disb_hold_exists(cp_award_id  igf_db_disb_holds.award_id%TYPE,
                                    cp_disb_num  igf_db_disb_holds.disb_num%TYPE,
                                    cp_hold      igf_db_disb_holds.hold%TYPE )
        IS
        SELECT COUNT(row_id)
        FROM   igf_db_disb_holds
        WHERE  award_id = cp_award_id
        AND    disb_num = cp_disb_num
        AND    hold     = cp_hold
        AND    release_flag ='N';

        l_rowid        VARCHAR2(30);
        l_hold_id      igf_db_disb_holds.hold_id%TYPE;
        l_rec_count    NUMBER;

    BEGIN

        FOR tbh_rec in c_tbh_cur LOOP

          l_rowid   := NULL;
          l_hold_id := NULL;
           OPEN cur_disb_hold_exists(tbh_rec.award_id,tbh_rec.disb_num,'DL_PROM');
          FETCH cur_disb_hold_exists into l_rec_count;
           IF NOT ( nvl(l_rec_count,0) > 0) THEN

          igf_db_disb_holds_pkg.insert_row (
            x_mode                              => 'R',
            x_rowid                             => l_rowid,
            x_hold_id                           => l_hold_id,
            x_award_id                          => tbh_rec.award_id,
            x_disb_num                          => tbh_rec.disb_num,
            x_hold                              => 'DL_PROM',
            x_hold_type                         => 'SYSTEM',
            x_hold_date                         => TRUNC(sysdate),
            x_release_flag                      => 'N',
            x_release_reason                    =>  NULL,
            x_release_date                      =>  NULL
           );
            END IF;
           Close cur_disb_hold_exists;

        END LOOP;
    END place_disb_holds;


BEGIN

  --Fetch the Old and New No.of Records

  OPEN cur_count_old_disb;
  FETCH cur_count_old_disb INTO l_award_id, l_old_count;
  IF l_old_count=0 THEN
     CLOSE cur_count_old_disb;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE cur_count_old_disb;


  OPEN cur_count_new_disb;
  FETCH cur_count_new_disb INTO l_new_count;
  IF l_new_count=0 THEN
     CLOSE cur_count_new_disb;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE cur_count_new_disb;

  IF l_old_count <> l_new_count THEN

        log_message(p_loan_number);
        -- Show all details like Old(From OFA) and New Disbursement Amounts(From File)
        show_disb_details;

        -- Place Process Holds on All the Disbursement records.
        place_disb_holds(l_award_id);

  ELSE

      OPEN cur_disb_same_data;
      FETCH cur_disb_same_data into l_disb_num, l_disb_gross_amt;
      IF cur_disb_same_data%NOTFOUND THEN

       -- Indicates that disbursement data (Number of Disbursements and
       -- disb-gross-amts and loan_requested_amt ) are currently same,
       -- what was sent to the external processor.

         NULL;
      ELSE

        log_message(p_loan_number);
        show_disb_details;

        -- Place Process Holds on All the Disbursement records.
        place_disb_holds(l_award_id);

       END IF;
     CLOSE cur_disb_same_data;

  END IF;

EXCEPTION
 WHEN app_exception.record_lock_exception THEN
    RAISE;
 WHEN OTHERS THEN
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_DL_PNOTE_ACK.COMPARE_DISBURSEMENTS');
     fnd_file.put_line(fnd_file.log,SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END compare_disbursements;

END igf_sl_dl_pnote_ack;

/
