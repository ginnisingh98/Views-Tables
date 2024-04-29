--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_ORIG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_ORIG_ACK" AS
/* $Header: IGFSL04B.pls 120.5 2006/04/18 03:28:34 akomurav noship $ */
---------------------------------------------------------------------------------
-- akomurav     28-Feb-2006     Build FA161.
--                              TBH Impact change done in upd_lor_record() and
--                              upd_lor_loc_record()
-----------------------------------------------------------------------------------
--  museshad    20-Feb-2006     Bug 5045766 - SQL Repository Issue.
--                              In upd_lor_record(), modified cursor c_lar_cur
--                              for better performance.
-----------------------------------------------------------------------------------
-- mnade        28-Dec-2004     #4085937 The status from ACK file for PLUS loans is
--                                       now handled in different manner.

-- svuppala     4-Nov-2004      #3416936 FA 134 TBH impacts for newly added columns

--  veramach        29-Jan-2004     bug 3408092 added 2004-2005 in dl_version checks
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
--                             b) Also the DUNS_BORW_LENDER_ID
--                             DUNS_GUARNT_ID
--                             DUNS_LENDER_ID
--                             DUNS_RECIP_ID columns are osboleted from the
--                             igf_sl_lor_loc_all table.
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
---------------------------------------------------------------------------
--  sjadhav   28-Mar-2003      Bug 2863960 added code 'X' for orign records
---------------------------------------------------------------------------
--  sjadhav   18-Feb-2003      Bug 2758812 - FA 117 Build
--                             Added
--                             endorser_amount,mpn_status,
--                             mpn_id,mpn_type,mpn_indicator fields
--                             Changes as per TD
--                             Added dl_credit_ack
---------------------------------------------------------------------------
--  adhawan   19-feb-2002      Bug 2216956
--                             Modified the tbh call of igf_sl_lor table
--                             to include elec_mpn_ind ,
--                             borr_sign_ind,stud_sign_ind,
--                             borr_credit_auth_code
--                             Modified the tbh call of
--                             igf_sl_dl_resp table to include elec_mpn_ind
--                             Modified in dl_load_data procedure ,
--                             to add position reference for elec_mpn_ind
---------------------------------------------------------------------------
--  npalanis  11/jan/2002      The process Direct Loan  Origination
--                             Acknowledgment Process is modified to pick
--                             up disbursement records that are in planned
--                             state,
--                             insert records into IGF_DB_DISB_HOLDS
--                             table with hold 'EXTERNAL' and
--                             hold type 'SYSTEM' and also update
--                             manual_hold_ind flag in
--                             IGF_AW_AWD_DISB table to 'Y'.
--                             Enh Bug No-2154941.
---------------------------------------------------------------------------
--  ssawhney  2nd jan          TBH call of IGF_AW_AWD_DISB table changed
--                             in Stud Emp build
--                             En Bug No 2161847
---------------------------------------------------------------------------
--  mesriniv  13/07/2001       ENH BUG No:1806850
--                             ENH Description -Awards Build for NOV 2001
--                             Modified the call to
--                             igf_aw_awd_disb_pkg.update_row
---------------------------------------------------------------------------
--  rboddu    18/05/2001       ENH BUG NO:      1769051
--                             ENH DESCRIPTION: Loan Processing-Nov 2001
--                             Uploaded pnote_id field of
--                             IGF_SL_DL_LOR_RESP table into
--                             pnote_mpn_ind field
--                             of IGF_SL_LOR, IGF_SL_LOR_LOC tables.
--                             If School is configured to print,
--                             then the pnote_status field of IGF_SL_LOR
--                             is set to 'G' (Ready to Print)
---------------------------------------------------------------------------
--  Created By : venagara
--  Date Created On : 2000/11/22
--  Purpose :
--  Know limitations, enhancements or remarks
---------------------------------------------------------------------------


  g_lor_loc_rec       igf_sl_lor_loc%ROWTYPE;
  g_sl_dl_lor_resp    igf_sl_dl_lor_resp%ROWTYPE;
  g_entry_point       VARCHAR2(10)  DEFAULT 'NULL';
  file_not_loaded     EXCEPTION;
  yr_full_participant EXCEPTION;

--   FORWARD DECLARATION OF PRIVATE PROCEDURES
PROCEDURE upd_lor_record(p_loan_number  IN  igf_sl_loans.loan_number%TYPE,
                         p_process      IN  VARCHAR2,
                         p_rec_present  OUT NOCOPY VARCHAR2,
                         p_rec_updated  OUT NOCOPY VARCHAR2 );
PROCEDURE upd_lor_loc_record(p_loan_id   igf_sl_lor.loan_id%TYPE, p_process VARCHAR2);




-- Procedure to Load the Data from the Data File into the Interface tables.
-- Before loading, it does lot of checks to ensure it is the right file
-- and returns the dbth_id, for further processing.
PROCEDURE dl_load_data(p_dbth_id       OUT NOCOPY  igf_sl_dl_batch.dbth_id%TYPE,
                       p_dl_version    OUT NOCOPY igf_sl_dl_file_type.dl_version%TYPE,
                       p_dl_loan_catg  OUT NOCOPY igf_sl_dl_file_type.dl_loan_catg%TYPE)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

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

  CURSOR c_header IS
  SELECT RTRIM(SUBSTR(record_data, 23, 23))       batch_id,
         RTRIM(SUBSTR(record_data, 15,  8))       message_class,
         RTRIM(SUBSTR(record_data, 46, 16))       bth_creation_date,
         RTRIM(SUBSTR(record_data, 60,  2))       batch_rej_code,
         RTRIM(SUBSTR(record_data, 23,  2))       batch_type
  FROM igf_sl_load_file_t
  WHERE  lort_id = 1
  AND    record_data LIKE 'DL HEADER%'
  AND    file_type = 'DL_ORIG_ACK';

  CURSOR c_trailer IS
  SELECT lort_id                         last_lort_id,
         RTRIM(SUBSTR(record_data,15,7)) number_rec,
         RTRIM(SUBSTR(record_data,22,5)) accept_rec,
         RTRIM(SUBSTR(record_data,27,5)) reject_rec,
         RTRIM(SUBSTr(record_data,32,5)) pending_rec
  FROM igf_sl_load_file_t
  WHERE  lort_id = (SELECT MAX(lort_id) FROM igf_sl_load_file_t)
  AND    record_data LIKE 'DL TRAILER%'
  AND    file_type = 'DL_ORIG_ACK';

  -- Get the award year
  CURSOR c_get_awd_year( p_dl_version  igf_lookups_view.lookup_code%TYPE)
  IS
    SELECT ci_cal_type, ci_sequence_number
      FROM igf_sl_dl_setup
     WHERE dl_version = p_dl_version;

  awd_year_rec c_get_awd_year%ROWTYPE;

BEGIN

  -- Assuming that Header and Trailer record format does not change
  -- since the header record contains Message Class Info, which
  -- indicates the version of the File.

  -- Check File Uploaded

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
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      -- Message : Response File uploaded is not complete.
      RAISE file_not_loaded;
  END IF;
  CLOSE c_header;


  -- Check whether the File is valid/Not. (ie whether any wrong file is used)
  -- File can be Origination Response For Stafford/PLUS OR a Credit Response.
  -- Also, Check if the file is an OUTPUT File.
  --
  igf_sl_gen.get_dl_batch_details(l_rec_message_class,
                                  l_rec_batch_type,
                                  l_dl_version,
                                  l_dl_file_type,
                                  l_dl_loan_catg);

  -- determine the system awd year and run the process only for phase in participant
  OPEN c_get_awd_year(l_dl_version);
  FETCH c_get_awd_year INTO awd_year_rec;
  CLOSE c_get_awd_year;

  IF igf_sl_dl_validation.check_full_participant (awd_year_rec.ci_cal_type, awd_year_rec.ci_sequence_number,'DL')  THEN

    IF g_entry_point = 'CREDIT' THEN
      fnd_message.set_name('IGF','IGF_SL_COD_NO_CRDT_ACK');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      raise yr_full_participant;

    ELSE
      fnd_message.set_name('IGF','IGF_SL_COD_NO_ACK');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      raise yr_full_participant;
    END IF;

  END IF;

  --
  -- if dl orig process is run with credit files
  -- then do not process
  -- here g_entry_point will be 'NULL'
  --

  IF  l_dl_file_type  =  'DL_ORIG_ACK'
  AND l_dl_loan_catg  IN ('DL_STAFFORD','DL_PLUS')
  AND g_entry_point   =  'NULL' THEN
      NULL;
  ELSIF g_entry_point <> 'CREDIT' THEN
      fnd_message.set_name('IGF','IGF_GE_INVALID_FILE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      -- Message : This is not a valid file
      RAISE file_not_loaded;
  END IF;

  --
  -- if credit process is run with dl orig files
  -- then do not process
  -- here g_entry_point will be 'CREDIT'
  --

  IF  l_dl_file_type  = 'DL_ORIG_ACK'
  AND l_dl_loan_catg  = 'DL_PLUS_CREDIT'
  AND g_entry_point   = 'CREDIT'   THEN
     NULL;
  ELSIF g_entry_point <> 'NULL' THEN
      fnd_message.set_name('IGF','IGF_GE_INVALID_FILE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      -- Message : This is not a valid file
      RAISE file_not_loaded;
  END IF;

  IF l_dl_loan_catg in ('DL_STAFFORD','DL_PLUS') THEN
      -- This is an Direct Loan Origination Acknowledgment File
      fnd_message.set_name('IGF','IGF_SL_DL_ORIG_ACK_FILE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

  ELSIF l_dl_loan_catg = 'DL_PLUS_CREDIT' THEN
      -- This is an Direct Loan Credit Response File
      fnd_message.set_name('IGF','IGF_SL_DL_CREDIT_ACK_FILE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

  END IF;


  -- Check whether the File was Fully transferred.
  -- Get the record details in the File.
  OPEN c_trailer;
  FETCH c_trailer into l_last_lort_id, l_number_rec, l_accept_rec,
                       l_reject_rec,   l_pending_rec;
  IF c_trailer%NOTFOUND THEN
      CLOSE c_trailer;
      fnd_message.set_name('IGF','IGF_GE_FILE_NOT_COMPLETE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE file_not_loaded;
  END IF;
  CLOSE c_trailer;


  IF l_rec_batch_rej_code IS NOT NULL  THEN
      fnd_message.set_name('IGF','IGF_GE_BATCH_REJECTED');
      fnd_message.set_token('BATCH', l_rec_batch_id);
      fnd_message.set_token('REASON', igf_aw_gen.lookup_desc('IGF_SL_DL_BATCH_REJ',l_rec_batch_rej_code));
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE file_not_loaded;
  END IF;


  l_rowid := NULL;
  igf_sl_dl_batch_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => l_rowid,
      x_dbth_id                           => l_dbth_id,
      x_batch_id                          => l_rec_batch_id,
      x_message_class                     => l_rec_message_class,
      x_bth_creation_date                 => TO_DATE(l_rec_bth_creation_date,'YYYYMMDDHH24MISS'),
      x_batch_rej_code                    => l_rec_batch_rej_code,
      x_end_date                          => NULL,
      x_batch_type                        => l_rec_batch_type,
      x_send_resp                         => 'R',
      x_status                            => 'N'
  );


  /***************  Load Transactions ********************/
  DECLARE
     l_actual_rec      NUMBER DEFAULT 0;
     l_lor_resp_num    NUMBER;
     CURSOR c_trans IS
     SELECT record_data FROM igf_sl_load_file_t
     WHERE  lort_id between 2 AND (l_last_lort_id-1)
     AND    file_type = 'DL_ORIG_ACK';

  BEGIN

    IF l_dl_version = '2002-2003' THEN

       -- File is Origination Response File For Stafford/PLUS.
       IF l_dl_loan_catg in ('DL_STAFFORD','DL_PLUS') THEN
          FOR orec IN c_trans LOOP
             l_actual_rec := l_actual_rec + 1;
             l_rowid := NULL;
             igf_sl_dl_lor_resp_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => l_rowid,
              x_lor_resp_num                      => l_lor_resp_num,
              x_dbth_id                           => l_dbth_id,
              x_orig_batch_id                     => RTRIM(SUBSTR(orec.record_data, 9,23)),
              x_loan_number                       => RTRIM(SUBSTR(orec.record_data,32,21)),
              x_orig_ack_date                     => TO_DATE(SUBSTR(orec.record_data,1,8),'YYYYMMDD'),
              x_orig_status_flag                  => RTRIM(SUBSTR(orec.record_data,53,1)),
              x_orig_reject_reasons               => RTRIM(SUBSTR(orec.record_data,54,10)),
              x_pnote_status                      => RTRIM(SUBSTR(orec.record_data,64,1)),
              x_pnote_id                          => RTRIM(SUBSTR(orec.record_data,90,1)),
              x_pnote_accept_amt                  => NULL,
              x_loan_amount_accepted              => LTRIM(RTRIM(SUBSTR(orec.record_data,91,5))),
              x_status                            => 'N',
              x_elec_mpn_ind                      => NVL(RTRIM(SUBSTR(orec.record_data,65,1)),'P') --added for 2216956
             );
          END LOOP;
          IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              -- Message : The Actual Number of records does not match with the one mentioned in the trailer
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              RAISE file_not_loaded;
          END IF;
       END IF;

       -- File is Credit Response File For PLUS.
       IF l_dl_loan_catg = 'DL_PLUS_CREDIT' THEN
          FOR orec IN c_trans LOOP
             l_actual_rec := l_actual_rec + 1;
             l_rowid := NULL;
             igf_sl_dl_lor_crresp_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => l_rowid,
              X_lor_resp_num                      => l_lor_resp_num,
              X_dbth_id                           => l_dbth_id,
              X_loan_number                       => RTRIM(SUBSTR(orec.record_data,9,21)),
              X_credit_override                   => RTRIM(SUBSTR(orec.record_data,30,1)),
              X_credit_decision_date              => TO_DATE(SUBSTR(orec.record_data,1,8),'YYYYMMDD'),
              X_status                            => 'N'
             );
          END LOOP;
          IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              RAISE file_not_loaded;
          END IF;
       END IF;

  END IF;    -- End of condition for VERSION.



  IF l_dl_version IN ('2003-2004','2004-2005') THEN

       -- File is Origination Response File For Stafford/PLUS.
       IF l_dl_loan_catg in ('DL_STAFFORD','DL_PLUS') THEN
          FOR orec IN c_trans LOOP
             l_actual_rec := l_actual_rec + 1;
             l_rowid := NULL;
             igf_sl_dl_lor_resp_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => l_rowid,
              x_lor_resp_num                      => l_lor_resp_num,
              x_dbth_id                           => l_dbth_id,
              x_orig_batch_id                     => RTRIM(SUBSTR(orec.record_data, 9,23)),
              x_loan_number                       => RTRIM(SUBSTR(orec.record_data,32,21)),
              x_orig_ack_date                     => TO_DATE(SUBSTR(orec.record_data,1,8),'YYYYMMDD'),
              x_orig_status_flag                  => RTRIM(SUBSTR(orec.record_data,53,1)),
              x_orig_reject_reasons               => RTRIM(SUBSTR(orec.record_data,54,10)),
              x_pnote_status                      => RTRIM(SUBSTR(orec.record_data,64,1)),
              x_pnote_id                          => RTRIM(SUBSTR(orec.record_data,90,1)),
              x_pnote_accept_amt                  => NULL,
              x_loan_amount_accepted              => NULL,
              x_status                            => 'N',
              x_elec_mpn_ind                      => NVL(RTRIM(SUBSTR(orec.record_data,65,1)),'P') --added for 2216956
             );
          END LOOP;
          IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              -- Message : The Actual Number of records does not match with the one mentioned in the trailer
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              RAISE file_not_loaded;
          END IF;
       END IF;

       -- File is Credit Response File For PLUS.
       IF l_dl_loan_catg = 'DL_PLUS_CREDIT' THEN
          FOR orec IN c_trans LOOP
             l_actual_rec := l_actual_rec + 1;
             l_rowid := NULL;
             igf_sl_dl_lor_crresp_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => l_rowid,
              x_lor_resp_num                      => l_lor_resp_num,
              x_dbth_id                           => l_dbth_id,
              x_loan_number                       => LTRIM(RTRIM(SUBSTR(orec.record_data,9,21))),
              x_credit_override                   => LTRIM(RTRIM(SUBSTR(orec.record_data,30,1))),
              x_credit_decision_date              => TO_DATE(substr(orec.record_data,1,8),'YYYYMMDD'),
              x_status                            => 'N',
              x_endorser_amount                   => NVL(TO_NUMBER(LTRIM(RTRIM(SUBSTR(orec.record_data,31,5)))),0),
              x_mpn_status                        => LTRIM(RTRIM(SUBSTR(orec.record_data,36,1))),
              x_mpn_id                            => LTRIM(RTRIM(SUBSTR(orec.record_data,37,21))),
              x_mpn_type                          => LTRIM(RTRIM(SUBSTR(orec.record_data,58,1))),
              x_mpn_indicator                     => LTRIM(RTRIM(SUBSTR(orec.record_data,59,1)))
             );
          END LOOP;
          IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              RAISE file_not_loaded;
          END IF;
       END IF;

  END IF;    -- End of condition for VERSION.

 END;

 p_dbth_id       := l_dbth_id;
 p_dl_version    := l_dl_version;
 p_dl_loan_catg  := l_dl_loan_catg;


EXCEPTION
WHEN app_exception.record_lock_exception THEN
   RAISE;
WHEN file_not_loaded THEN
   RAISE;
WHEN yr_full_participant THEN
   NULL;
WHEN OTHERS THEN
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_ORIG_ACK.DL_LOAD_DATA');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END dl_load_data;




/* MAIN PROCEDURE */
PROCEDURE dl_orig_ack(errbuf    OUT NOCOPY  VARCHAR2,
                      retcode   OUT NOCOPY  NUMBER,
                      P_org_id  IN  NUMBER )
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  npalanis       11/jan/2002      This procedure is  modified to pick up disbursement records that
                                  are in planned state,insert records into IGF_DB_DISB_HOLDS table
                                  with hold 'EXTERNAL' and hold type 'SYSTEM' and also update
                                  manual_hold_ind flag in  IGF_AW_AWD_DISB table to 'Y'.
                                  enh bug no-2154941.

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_dbth_id               igf_sl_dl_batch.dbth_id%TYPE;
  l_batch_type            igf_sl_dl_batch.batch_type%TYPE;
  l_rec_present           VARCHAR2(10);
  l_rec_updated           VARCHAR2(10);
  l_stat                  VARCHAR2(30);

  l_dl_version            igf_sl_dl_file_type.dl_version%TYPE;
  l_dl_loan_catg          igf_sl_dl_file_type.dl_loan_catg%TYPE;

  CURSOR cur_batch
  IS
  SELECT igf_sl_dl_batch.*
  FROM   igf_sl_dl_batch
  WHERE  dbth_id = l_dbth_id
  AND    status  = 'N';

  CURSOR cur_lor_resp(l_dbth_id igf_sl_dl_batch.dbth_id%TYPE)
  IS
  SELECT igf_sl_dl_lor_resp.*
  FROM   igf_sl_dl_lor_resp
  WHERE  dbth_id = l_dbth_id
  AND    status  = 'N';

  CURSOR cur_lor_crresp(l_dbth_id igf_sl_dl_batch.dbth_id%TYPE)
  IS
  SELECT igf_sl_dl_lor_crresp.*
  FROM   igf_sl_dl_lor_crresp
  WHERE  dbth_id = l_dbth_id
  AND    status  = 'N';

BEGIN

  retcode := 0;

  igf_aw_gen.set_org_id(p_org_id);

  --
  --  Load the Data into the Batch and Response Tables
  --
  dl_load_data(l_dbth_id, l_dl_version, l_dl_loan_catg);

  FOR dbth_rec IN cur_batch LOOP

    IF l_dl_loan_catg IN ('DL_STAFFORD','DL_PLUS') THEN
       -- These are Direct Loan Origination Response records.

       FOR resp_rec IN cur_lor_resp(l_dbth_id) LOOP
          l_rec_present := 'N';
          l_rec_updated := 'N';

          -- Use this to update igf_sl_lor_loc table, with old values.
          g_lor_loc_rec.orig_status_flag   := resp_rec.orig_status_flag;
          g_lor_loc_rec.orig_ack_date      := resp_rec.orig_ack_date;
          g_lor_loc_rec.pnote_status       := resp_rec.pnote_status;

          IF    resp_rec.pnote_status = 'Q' THEN
                g_lor_loc_rec.pnote_status       := 'R';
          ELSIF resp_rec.pnote_status = 'P' THEN
                g_lor_loc_rec.pnote_status       := 'F';
          END IF;

          g_lor_loc_rec.pnote_status_date  := resp_rec.orig_ack_date;
          g_lor_loc_rec.pnote_mpn_ind      := resp_rec.pnote_id;
          g_sl_dl_lor_resp.elec_mpn_ind    := resp_rec.elec_mpn_ind;

          -- Update the IGF_SL_LOR record.
-- MN 27-Dec-2004 15:33 - Following matrix will be used to update the loan status based on responses for PLUS loans.
          --           B = Rejected Origination
          --           C = Accepted Origination/Credit Check Accepted (PLUS only)
          --           D = Accepted Origination/Credit Check Denied (PLUS only)
          --           X = Accepted Origination/Credit Check Pending (PLUS only)
          --           Based on the orig_status_flag only the crdt_decision_status will be changed.
          IF l_dl_loan_catg = 'DL_PLUS' THEN
              IF resp_rec.orig_status_flag = 'B' THEN
                g_lor_loc_rec.crdt_decision_status := NULL;
              ELSIF resp_rec.orig_status_flag = 'C' THEN
                g_lor_loc_rec.crdt_decision_status := 'A';
              ELSIF resp_rec.orig_status_flag = 'D' THEN
                g_lor_loc_rec.crdt_decision_status := 'D';
              ELSIF resp_rec.orig_status_flag = 'X' THEN
                g_lor_loc_rec.crdt_decision_status := 'P';
              END IF;
          END IF;

          upd_lor_record(resp_rec.loan_number, 'ORIG_ACK', l_rec_present, l_rec_updated);

          IF l_rec_present = 'N' THEN
              fnd_message.set_name('IGF','IGF_SL_NO_LOAN_NUMBER');
              fnd_message.set_token('LOAN_NUMBER',resp_rec.loan_number);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              -- Message : Loan ID #LOAN_NUMBER does not exist in the Financial Aid System
          ELSE
             -- If the Loan Number is a Valid Loan-number

             IF l_rec_updated = 'N' THEN
                fnd_message.set_name('IGF','IGF_SL_OLD_ORIG_ACK_DATE');
                fnd_message.set_token('LOAN_NUMBER',resp_rec.loan_number);
                fnd_file.put_line(fnd_file.log, fnd_message.get);
                -- Message : Acknowledgment for Loan ID #LOAN_NUMBER not loaded, due to old acknowledgement date
             ELSE
                -- Show any Origination Reject Codes in the Log File, if any.
                DECLARE
                  CURSOR c_rej IS
                  SELECT lookup_code, meaning FROM igf_lookups_view
                  WHERE  lookup_type = 'IGF_SL_DL_ORIG_REJ_CODES'
                  AND    lookup_code IN (SUBSTR(resp_rec.orig_reject_reasons, 1,2),
                                         SUBSTR(resp_rec.orig_reject_reasons, 3,2),
                                         SUBSTR(resp_rec.orig_reject_reasons, 5,2),
                                         SUBSTR(resp_rec.orig_reject_reasons, 7,2),
                                         SUBSTR(resp_rec.orig_reject_reasons, 9,2));
                BEGIN
                  igf_sl_edit.delete_edit(resp_rec.loan_number, 'R');
                  FOR rrec IN c_rej LOOP
                      fnd_file.put_line(fnd_file.log, '   '||rrec.meaning);
                      igf_sl_edit.insert_edit(resp_rec.loan_number, 'R', 'IGF_SL_DL_ORIG_REJ_CODES',
                                              rrec.lookup_code, '', '');
                  END LOOP;
                END;
             END IF;  -- End of condition for "l_rec_updated = 'N' "
          END IF;  -- End of condition for "l_rec_present = 'N' "


          IF l_rec_present = 'N' THEN
            l_stat := 'I';               -- Invalid Loan Number. So, Not Loaded.
          ELSE
            IF l_rec_updated = 'N' THEN
              l_stat := 'O';             -- Old Acknowledgment Data. Not Loaded.
            ELSIF l_rec_updated = 'Y' THEN
              l_stat := 'Y';             -- Loan Acknowledgment Data uploaded.
            END IF;
          END IF;

          -- Update the Response File's transaction record with the Processing Status
          igf_sl_dl_lor_resp_pkg.update_row (
           x_mode                              => 'R',
           x_rowid                             => resp_rec.row_id,
           x_lor_resp_num                      => resp_rec.lor_resp_num,
           x_dbth_id                           => resp_rec.dbth_id,
           x_orig_batch_id                     => resp_rec.orig_batch_id,
           x_loan_number                       => resp_rec.loan_number,
           x_orig_ack_date                     => resp_rec.orig_ack_date,
           x_orig_status_flag                  => resp_rec.orig_status_flag,
           x_orig_reject_reasons               => resp_rec.orig_reject_reasons,
           x_pnote_status                      => resp_rec.pnote_status,
           x_pnote_id                          => resp_rec.pnote_id,
           x_pnote_accept_amt                  => resp_rec.pnote_accept_amt,
           x_loan_amount_accepted              => resp_rec.loan_amount_accepted,
           x_status                            => l_stat,
           x_elec_mpn_ind                      => resp_rec.elec_mpn_ind
          );


       END LOOP;  -- End of igf_sl_dl_lor_resp table LOOP.


    ELSIF l_dl_loan_catg = 'DL_PLUS_CREDIT' THEN

       --
       -- These are Direct Loan Credit Response records.
       --

       FOR crresp_rec IN cur_lor_crresp(l_dbth_id) LOOP

          l_rec_present := 'N';
          l_rec_updated := 'N';

          -- Use this to update igf_sl_lor_loc table, with old values.
          g_lor_loc_rec.credit_override      := crresp_rec.credit_override;
          g_lor_loc_rec.credit_decision_date := crresp_rec.credit_decision_date;
          g_lor_loc_rec.pnote_status         := crresp_rec.mpn_status;
          g_lor_loc_rec.pnote_status_date    := crresp_rec.credit_decision_date;

          IF crresp_rec.mpn_status = 'R' THEN
               g_lor_loc_rec.pnote_status := 'F';
          END IF;

          g_lor_loc_rec.pnote_id             := crresp_rec.mpn_id;
          g_lor_loc_rec.pnote_mpn_ind        := crresp_rec.mpn_indicator;
          g_sl_dl_lor_resp.elec_mpn_ind      := crresp_rec.mpn_type;
          g_lor_loc_rec.pnote_accept_amt     := crresp_rec.endorser_amount;


          -- Update the IGF_SL_LOR record.
          upd_lor_record(crresp_rec.loan_number, 'CREDIT_ACK', l_rec_present, l_rec_updated);

          IF l_rec_present = 'N' THEN
              fnd_message.set_name('IGF','IGF_SL_NO_LOAN_NUMBER');
              fnd_message.set_token('LOAN_NUMBER',crresp_rec.loan_number);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              -- Message : Loan ID #LOAN_NUMBER does not exist in the Financial Aid System
          ELSE
             -- If the Loan Number is a Valid Loan-number
             IF l_rec_updated = 'N' THEN
                fnd_message.set_name('IGF','IGF_SL_OLD_CREDT_ACK_DATE');
                fnd_message.set_token('LOAN_NUMBER',crresp_rec.loan_number);
                fnd_file.put_line(fnd_file.log, fnd_message.get);
                -- Message : Acknowledgment for Loan ID #LOAN_NUMBER not loaded, due to old credit acknowledgement date
             END IF;  -- End of condition for "l_rec_updated = 'N' "
          END IF;  -- End of condition for "l_rec_present = 'N' "


          IF l_rec_present = 'N' THEN
            l_stat := 'I';               -- Invalid Loan Number. So, Not Loaded.
          ELSE
            IF l_rec_updated = 'N' THEN
              l_stat := 'O';             -- Old Acknowledgment Data. Not Loaded.
            ELSIF l_rec_updated = 'Y' THEN
              l_stat := 'Y';             -- Loan Acknowledgment Data uploaded.
            END IF;
          END IF;

          -- Update the Credit Response File's transaction record with the Processing Status
         igf_sl_dl_lor_crresp_pkg.update_row (
           x_mode                              => 'R',
           x_rowid                             => crresp_rec.row_id,
           x_lor_resp_num                      => crresp_rec.lor_resp_num,
           x_dbth_id                           => crresp_rec.dbth_id,
           x_loan_number                       => crresp_rec.loan_number,
           x_credit_override                   => crresp_rec.credit_override,
           x_credit_decision_date              => crresp_rec.credit_decision_date,
           x_status                            => l_stat
         );


       END LOOP;  -- End of igf_sl_dl_lor_crresp table LOOP.

    END IF;  -- End of Condition for l_dl_loan_catg

    -- Update the DL_BATCH record as Successfully Uploaded.
    igf_sl_dl_batch_pkg.update_row (
      x_mode                              => 'R',
      x_rowid                             => dbth_rec.row_id,
      x_dbth_id                           => dbth_rec.dbth_id,
      x_batch_id                          => dbth_rec.batch_id,
      x_message_class                     => dbth_rec.message_class,
      x_bth_creation_date                 => dbth_rec.bth_creation_date,
      x_batch_rej_code                    => dbth_rec.batch_rej_code,
      x_end_date                          => dbth_rec.end_date,
      x_batch_type                        => dbth_rec.batch_type,
      x_send_resp                         => dbth_rec.send_resp,
      x_status                            => 'Y'
    );


  END LOOP;  -- End of Batch ID "FOR LOOP"

  COMMIT;

EXCEPTION
    WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       igs_ge_msg_stack.conc_exception_hndl;
    WHEN file_not_loaded THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       igs_ge_msg_stack.conc_exception_hndl;
    WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       fnd_file.put_line(fnd_file.log,SQLERRM);
       igs_ge_msg_stack.conc_exception_hndl;
END dl_orig_ack;



PROCEDURE upd_lor_record(p_loan_number  IN  igf_sl_loans.loan_number%TYPE,
                         p_process      IN  VARCHAR2,
                         p_rec_present  OUT NOCOPY VARCHAR2,
                         p_rec_updated  OUT NOCOPY VARCHAR2 )
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
--------------------------------------------------------------------------------------------
--  museshad      20-Feb-2006     Bug 5045766 - SQL Repository Issue.
--                                Modified cursor c_lar_cur for better performance.
---------------------------------------------------------------------------------------------
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             a) Impact of adding the relationship_cd
--                             in igf_sl_lor_all table and obsoleting
--                             BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                             GUARANTOR_ID, DUNS_GUARNT_ID,
--                             LENDER_ID, DUNS_LENDER_ID
--                             LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                             RECIPIENT_TYPE,DUNS_RECIP_ID
--                             RECIP_NON_ED_BRC_ID columns.
---------------------------------------------------------------------------------------------
  veramach   23-SEP-2003     Bug 3104228:
                                        1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
                                        2. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id from igf_sl_lor_loc

  agairola       15-MAR-2002      Modified the Update Row call of the IGF_SL_LOANS_PKG
                                  added as part of the Refunds DLD - 2144600
  rboddu         18/05/2001       uploaded pnote_id field of IGF_SL_DL_LOR_RESP table into
                                  pnote_mpn_ind field of IGF_SL_LOR table.
                                  If School is configured to print then the pnote_status
                                  field of IGF_SL_LOR is set to 'G' (Ready to Print)

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_row_id         VARCHAR2(25);
  l_print_opt      igf_sl_dl_setup.pnote_print_ind%TYPE;

  CURSOR c_tbh_cur IS
  SELECT igf_sl_lor.* FROM igf_sl_lor
  WHERE loan_id = (SELECT loan_id FROM igf_sl_loans lar
                   WHERE  loan_number = p_loan_number)
  FOR UPDATE OF igf_sl_lor.sch_cert_date NOWAIT;

  CURSOR c_lar_cur(c_loan_id  igf_sl_loans.loan_id%TYPE)
  IS
    SELECT  loan.rowid row_id,
            loan.*,
            fcat.fed_fund_code
    FROM    igf_sl_loans_all loan,
            igf_aw_award_all awd,
            igf_aw_fund_mast_all fmast,
            igf_aw_fund_cat_all fcat
    WHERE
            loan.award_id = awd.award_id AND
            awd.fund_id = fmast.fund_id AND
            fcat.fund_code = fmast.fund_code AND
            loan.loan_id = c_loan_id;

  lar_rec   c_lar_cur%ROWTYPE;

  CURSOR c_print_cur
  IS
  SELECT
  pnote_print_ind
  FROM
  igf_sl_dl_setup
  WHERE (ci_cal_type,ci_sequence_number) = ( SELECT fmast.ci_cal_type,
                                                    fmast.ci_sequence_number
                                             FROM   igf_sl_loans loans,
                                                    igf_aw_award awd,
                                                    igf_aw_fund_mast fmast
                                             WHERE  loans.loan_number = p_loan_number
                                               AND  loans.award_id    = awd.award_id
                                               AND  awd.fund_id       = fmast.fund_id
                                             );

BEGIN
   p_rec_present := 'N';
   p_rec_updated := 'N';

   FOR tbh_rec in c_tbh_cur LOOP

       -- If the Loan-Number is a Valid Loan-Number
       p_rec_present := 'Y';


       IF p_process = 'ORIG_ACK'
       AND (     tbh_rec.orig_ack_date IS NULL
            OR   tbh_rec.orig_ack_date < g_lor_loc_rec.orig_ack_date )  THEN

           -- If the Loan origination acknowledgment record has to be loaded.
           p_rec_updated := 'Y';

           tbh_rec.orig_status_flag    := g_lor_loc_rec.orig_status_flag;
           tbh_rec.orig_ack_date       := g_lor_loc_rec.orig_ack_date;
           tbh_rec.pnote_status        := g_lor_loc_rec.pnote_status;
           tbh_rec.pnote_status_date   := g_lor_loc_rec.pnote_status_date;
           tbh_rec.pnote_mpn_ind       := g_lor_loc_rec.pnote_mpn_ind;
           tbh_rec.elec_mpn_ind        := g_sl_dl_lor_resp.elec_mpn_ind;  --added for 2216956
           tbh_rec.crdt_decision_status:= g_lor_loc_rec.crdt_decision_status; --added for FA149

       ELSIF p_process = 'CREDIT_ACK'
       AND (     tbh_rec.credit_decision_date IS NULL
            OR   tbh_rec.credit_decision_date < g_lor_loc_rec.credit_decision_date )  THEN

           -- If the Loan credit acknowledgment record has to be loaded.
           p_rec_updated := 'Y';

           tbh_rec.credit_override      := g_lor_loc_rec.credit_override;
           tbh_rec.credit_decision_date := g_lor_loc_rec.credit_decision_date;
           tbh_rec.pnote_status         := g_lor_loc_rec.pnote_status;
           tbh_rec.pnote_status_date    := g_lor_loc_rec.pnote_status_date;
           tbh_rec.pnote_mpn_ind        := g_lor_loc_rec.pnote_mpn_ind;
           tbh_rec.elec_mpn_ind         := g_sl_dl_lor_resp.elec_mpn_ind;  --added for 2216956
           tbh_rec.pnote_id             := g_lor_loc_rec.pnote_id;
           tbh_rec.pnote_accept_amt     := g_lor_loc_rec.pnote_accept_amt;

       END IF;


       -- If the Loan has to updated with the information from the File
       IF p_rec_updated = 'Y' THEN

           -- Delete all previous reject records, for Response process.
                 igf_sl_edit.delete_edit(p_loan_number, 'R');
                 igf_sl_lor_pkg.update_row (
                                      x_mode                              => 'R',
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
                                      x_atd_entity_id_txt                 => tbh_rec.atd_entity_id_txt ,
                                      x_rep_entity_id_txt                 => tbh_rec.rep_entity_id_txt,
                                      x_crdt_decision_status              => tbh_rec.crdt_decision_status,
                                      x_note_message                      => tbh_rec.note_message,
                                      x_book_loan_amt                     => tbh_rec.book_loan_amt ,
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


           -- Update the Loan Status Based on the LOR's Origination Status
           OPEN c_lar_cur(tbh_rec.loan_id);
           FETCH c_lar_cur INTO lar_rec;
           IF c_lar_cur%NOTFOUND  THEN
               CLOSE c_lar_cur;
               RAISE NO_DATA_FOUND;
           END IF;
           DECLARE
                 l_update_loan    VARCHAR2(30) DEFAULT 'N';
                 l_loan_status_dt igf_sl_loans.loan_status_date%TYPE;
                 l_loan_status    igf_sl_loans.loan_status%TYPE;
           BEGIN

                 -- Set the Loan Status and Loan Status Date to existing values
                 g_lor_loc_rec.loan_status       := lar_rec.loan_status;
                 g_lor_loc_rec.loan_status_date  := lar_rec.loan_status_date;

                 IF igf_sl_gen.chk_dl_stafford(lar_rec.fed_fund_code) = 'TRUE' THEN
                     IF tbh_rec.orig_status_flag = 'A' THEN    -- Orgination Accepted
                         l_loan_status    := 'A';              -- Loan is Accepted
                         l_loan_status_dt := TRUNC(SYSDATE);
                         l_update_loan    := 'Y';
                     ELSIF tbh_rec.orig_status_flag = 'B' THEN -- Origination Rejected
                         l_loan_status    := 'R';              -- Loan is Rejected
                         l_loan_status_dt := TRUNC(SYSDATE);
                         l_update_loan    := 'Y';
                     END IF;
                 ELSIF igf_sl_gen.chk_dl_plus(lar_rec.fed_fund_code) = 'TRUE' THEN
                     IF tbh_rec.orig_status_flag IN ('X','C') THEN    -- Origination Accepted, Credit Accepted
                         l_loan_status    := 'A';                     -- Loan is Accepted
                     ELSIF tbh_rec.orig_status_flag IN ('B','D') THEN -- Orig Rejected OR Orig Accept,Credit Denied
                         l_loan_status    := 'R';                     -- Loan is Rejected
                     END IF;
                     l_loan_status_dt := TRUNC(SYSDATE);
                     l_update_loan    := 'Y';
                 END IF;

                 IF l_update_loan = 'Y' THEN
                    fnd_message.set_name('IGF','IGF_SL_LOAN_STATUS');
                    fnd_message.set_token('LOAN_NUMBER',p_loan_number);
                    fnd_message.set_token('LOAN_STATUS',igf_aw_gen.lookup_desc('IGF_SL_REC_STATUS',l_loan_status));
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    -- Message : Loan ID #LOAN_NUMBER has been #LOAN_STATUS

                    -- Set the Loan Status and Loan Status Date to New Values
                    g_lor_loc_rec.loan_status       := l_loan_status;
                    g_lor_loc_rec.loan_status_date  := l_loan_status_dt;

-- Modified the Update Row call to include the Borrower Determination
-- added as part of Refunds DLD - 2144600
                    igf_sl_loans_pkg.update_row (
                     x_mode                              => 'R',
                     x_rowid                             => lar_rec.row_id,
                     x_loan_id                           => lar_rec.loan_id,
                     x_award_id                          => lar_rec.award_id,
                     x_seq_num                           => lar_rec.seq_num,
                     x_loan_number                       => lar_rec.loan_number,
                     x_loan_per_begin_date               => lar_rec.loan_per_begin_date,
                     x_loan_per_end_date                 => lar_rec.loan_per_end_date,
                     x_loan_status                       => l_loan_status,
                     x_loan_status_date                  => l_loan_status_dt,
                     x_loan_chg_status                   => lar_rec.loan_chg_status,
                     x_loan_chg_status_date              => lar_rec.loan_chg_status_date,
                     x_active                            => lar_rec.active,
                     x_active_date                       => lar_rec.active_date,
                     x_borw_detrm_code                   => lar_rec.borw_detrm_code,
                     x_external_loan_id_txt              => lar_rec.external_loan_id_txt

                     );
                 END IF;
           END;

           CLOSE c_lar_cur;

           -- Update the LOR LOC record, to reflect the incoming information.
           upd_lor_loc_record(tbh_rec.loan_id, p_process);

       END IF;
   END LOOP;

EXCEPTION

WHEN app_exception.record_lock_exception THEN
   RAISE;
WHEN others THEN
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_ORIG_ACK.UPD_LOR_RECORD');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END upd_lor_record;



PROCEDURE upd_lor_loc_record(p_loan_id   igf_sl_lor.loan_id%TYPE, p_process VARCHAR2)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
-----------------------------------------------------------------------------------------------------------
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             The DUNS_BORW_LENDER_ID,
--                             DUNS_GUARNT_ID,
--                             DUNS_LENDER_ID,
--                             DUNS_RECIP_ID columns are osboleted from the
--                             igf_sl_lor_loc_all table.
-----------------------------------------------------------------------------------------------------------
  veramach   23-SEP-2003     Bug 3104228:
                                        1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
                                        2. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id from igf_sl_lor_loc
 rboddu          18/05/2001       uploaded pnote_id field of IGF_SL_DL_LOR_RESP table into
                                  pnote_mpn_ind field of IGF_SL_LOR_LOC table.

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c_tbh_cur
    IS
    SELECT
    igf_sl_lor_loc.*
    FROM
    igf_sl_lor_loc
    WHERE loan_id = p_loan_id
    FOR UPDATE OF igf_sl_lor_loc.loan_status NOWAIT;

BEGIN

  FOR tbh_rec in c_tbh_cur LOOP

     IF p_process = 'ORIG_ACK' THEN
         tbh_rec.orig_status_flag    := g_lor_loc_rec.orig_status_flag;
         tbh_rec.orig_ack_date       := g_lor_loc_rec.orig_ack_date;
         tbh_rec.pnote_status        := g_lor_loc_rec.pnote_status;
         tbh_rec.pnote_status_date   := g_lor_loc_rec.pnote_status_date;
         tbh_rec.pnote_mpn_ind       := g_lor_loc_rec.pnote_mpn_ind;

     ELSIF p_process = 'CREDIT_ACK' THEN
         tbh_rec.credit_override      := g_lor_loc_rec.credit_override;
         tbh_rec.credit_decision_date := g_lor_loc_rec.credit_decision_date;
         tbh_rec.pnote_status         := g_lor_loc_rec.pnote_status;
         tbh_rec.pnote_status_date    := g_lor_loc_rec.pnote_status_date;
         tbh_rec.pnote_mpn_ind        := g_lor_loc_rec.pnote_mpn_ind;
     END IF;

     tbh_rec.loan_status      := g_lor_loc_rec.loan_status;
     tbh_rec.loan_status_date := g_lor_loc_rec.loan_status_date;

    igf_sl_lor_loc_pkg.update_row (
      x_mode                              => 'R',
      x_rowid                             => tbh_rec.row_id,
      x_loan_id                           => tbh_rec.loan_id,
      x_origination_id                    => tbh_rec.origination_id,
      x_loan_number                       => tbh_rec.loan_number,
      x_loan_type                         => tbh_rec.loan_type,
      x_loan_amt_offered                  => tbh_rec.loan_amt_offered,
      x_loan_amt_accepted                 => tbh_rec.loan_amt_accepted,
      x_loan_per_begin_date               => tbh_rec.loan_per_begin_date,
      x_loan_per_end_date                 => tbh_rec.loan_per_end_date,
      x_acad_yr_begin_date                => tbh_rec.acad_yr_begin_date,
      x_acad_yr_end_date                  => tbh_rec.acad_yr_end_date,
      x_loan_status                       => tbh_rec.loan_status,
      x_loan_status_date                  => tbh_rec.loan_status_date,
      x_loan_chg_status                   => tbh_rec.loan_chg_status,
      x_loan_chg_status_date              => tbh_rec.loan_chg_status_date,
      x_req_serial_loan_code              => tbh_rec.req_serial_loan_code,
      x_act_serial_loan_code              => tbh_rec.act_serial_loan_code,
      x_active                            => tbh_rec.active,
      x_active_date                       => tbh_rec.active_date,
      x_sch_cert_date                     => tbh_rec.sch_cert_date,
      x_orig_status_flag                  => tbh_rec.orig_status_flag,
      x_orig_batch_id                     => tbh_rec.orig_batch_id,
      x_orig_batch_date                   => tbh_rec.orig_batch_date,
      x_chg_batch_id                      => NULL,
      x_orig_ack_date                     => tbh_rec.orig_ack_date,
      x_credit_override                   => tbh_rec.credit_override,
      x_credit_decision_date              => tbh_rec.credit_decision_date,
      x_pnote_delivery_code               => tbh_rec.pnote_delivery_code,
      x_pnote_status                      => tbh_rec.pnote_status,
      x_pnote_status_date                 => tbh_rec.pnote_status_date,
      x_pnote_id                          => tbh_rec.pnote_id,
      x_pnote_print_ind                   => tbh_rec.pnote_print_ind,
      x_pnote_accept_amt                  => tbh_rec.pnote_accept_amt,
      x_pnote_accept_date                 => tbh_rec.pnote_accept_date,
      x_p_signature_code                  => tbh_rec.p_signature_code,
      x_p_signature_date                  => tbh_rec.p_signature_date,
      x_s_signature_code                  => tbh_rec.s_signature_code,
      x_unsub_elig_for_heal               => tbh_rec.unsub_elig_for_heal,
      x_disclosure_print_ind              => tbh_rec.disclosure_print_ind,
      x_orig_fee_perct                    => tbh_rec.orig_fee_perct,
      x_borw_confirm_ind                  => tbh_rec.borw_confirm_ind,
      x_borw_interest_ind                 => tbh_rec.borw_interest_ind,
      x_unsub_elig_for_depnt              => tbh_rec.unsub_elig_for_depnt,
      x_guarantee_amt                     => tbh_rec.guarantee_amt,
      x_guarantee_date                    => tbh_rec.guarantee_date,
      x_guarnt_adj_ind                    => tbh_rec.guarnt_adj_ind,
      x_guarnt_amt_redn_code              => tbh_rec.guarnt_amt_redn_code,
      x_guarnt_status_code                => tbh_rec.guarnt_status_code,
      x_guarnt_status_date                => tbh_rec.guarnt_status_date,
      x_lend_apprv_denied_code            => NULL,
      x_lend_apprv_denied_date            => NULL,
      x_lend_status_code                  => tbh_rec.lend_status_code,
      x_lend_status_date                  => tbh_rec.lend_status_date,
      x_grade_level_code                  => tbh_rec.grade_level_code,
      x_enrollment_code                   => tbh_rec.enrollment_code,
      x_anticip_compl_date                => tbh_rec.anticip_compl_date,
      x_borw_lender_id                    => tbh_rec.borw_lender_id,
      x_duns_borw_lender_id               => NULL,
      x_guarantor_id                      => tbh_rec.guarantor_id,
      x_duns_guarnt_id                    => NULL,
      x_prc_type_code                     => tbh_rec.prc_type_code,
      x_rec_type_ind                      => tbh_rec.rec_type_ind,
      x_cl_loan_type                      => tbh_rec.cl_loan_type,
      x_cl_seq_number                     => tbh_rec.cl_seq_number,
      x_last_resort_lender                => tbh_rec.last_resort_lender,
      x_lender_id                         => tbh_rec.lender_id,
      x_duns_lender_id                    => NULL,
      x_lend_non_ed_brc_id                => tbh_rec.lend_non_ed_brc_id,
      x_recipient_id                      => tbh_rec.recipient_id,
      x_recipient_type                    => tbh_rec.recipient_type,
      x_duns_recip_id                     => NULL,
      x_recip_non_ed_brc_id               => tbh_rec.recip_non_ed_brc_id,
      x_cl_rec_status                     => NULL,
      x_cl_rec_status_last_update         => NULL,
      x_alt_prog_type_code                => tbh_rec.alt_prog_type_code,
      x_alt_appl_ver_code                 => tbh_rec.alt_appl_ver_code,
      x_borw_outstd_loan_code             => tbh_rec.borw_outstd_loan_code,
      x_mpn_confirm_code                  => NULL,
      x_resp_to_orig_code                 => tbh_rec.resp_to_orig_code,
      x_appl_loan_phase_code              => NULL,
      x_appl_loan_phase_code_chg          => NULL,
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
      x_p_ssn                             => tbh_rec.p_ssn,
      x_p_ssn_chg_date                    => NULL,
      x_p_last_name                       => tbh_rec.p_last_name,
      x_p_first_name                      => tbh_rec.p_first_name,
      x_p_middle_name                     => tbh_rec.p_middle_name,
      x_p_permt_addr1                     => tbh_rec.p_permt_addr1,
      x_p_permt_addr2                     => tbh_rec.p_permt_addr2,
      x_p_permt_city                      => tbh_rec.p_permt_city,
      x_p_permt_state                     => tbh_rec.p_permt_state,
      x_p_permt_zip                       => tbh_rec.p_permt_zip,
      x_p_permt_addr_chg_date             => tbh_rec.p_permt_addr_chg_date,
      x_p_permt_phone                     => tbh_rec.p_permt_phone,
      x_p_email_addr                      => tbh_rec.p_email_addr,
      x_p_date_of_birth                   => tbh_rec.p_date_of_birth,
      x_p_dob_chg_date                    => NULL,
      x_p_license_num                     => tbh_rec.p_license_num,
      x_p_license_state                   => tbh_rec.p_license_state,
      x_p_citizenship_status              => tbh_rec.p_citizenship_status,
      x_p_alien_reg_num                   => tbh_rec.p_alien_reg_num,
      x_p_default_status                  => tbh_rec.p_default_status,
      x_p_foreign_postal_code             => tbh_rec.p_foreign_postal_code,
      x_p_state_of_legal_res              => tbh_rec.p_state_of_legal_res,
      x_p_legal_res_date                  => tbh_rec.p_legal_res_date,
      x_s_ssn                             => tbh_rec.s_ssn,
      x_s_ssn_chg_date                    => NULL,
      x_s_last_name                       => tbh_rec.s_last_name,
      x_s_first_name                      => tbh_rec.s_first_name,
      x_s_middle_name                     => tbh_rec.s_middle_name,
      x_s_permt_addr1                     => tbh_rec.s_permt_addr1,
      x_s_permt_addr2                     => tbh_rec.s_permt_addr2,
      x_s_permt_city                      => tbh_rec.s_permt_city,
      x_s_permt_state                     => tbh_rec.s_permt_state,
      x_s_permt_zip                       => tbh_rec.s_permt_zip,
      x_s_permt_addr_chg_date             => tbh_rec.s_permt_addr_chg_date,
      x_s_permt_phone                     => tbh_rec.s_permt_phone,
      x_s_local_addr1                     => tbh_rec.s_local_addr1,
      x_s_local_addr2                     => tbh_rec.s_local_addr2,
      x_s_local_city                      => tbh_rec.s_local_city,
      x_s_local_state                     => tbh_rec.s_local_state,
      x_s_local_zip                       => tbh_rec.s_local_zip,
      x_s_local_addr_chg_date             => NULL,
      x_s_email_addr                      => tbh_rec.s_email_addr,
      x_s_date_of_birth                   => tbh_rec.s_date_of_birth,
      x_s_dob_chg_date                    => NULL,
      x_s_license_num                     => tbh_rec.s_license_num,
      x_s_license_state                   => tbh_rec.s_license_state,
      x_s_depncy_status                   => tbh_rec.s_depncy_status,
      x_s_default_status                  => tbh_rec.s_default_status,
      x_s_citizenship_status              => tbh_rec.s_citizenship_status,
      x_s_alien_reg_num                   => tbh_rec.s_alien_reg_num,
      x_s_foreign_postal_code             => tbh_rec.s_foreign_postal_code,
      x_pnote_batch_id                    => tbh_rec.pnote_batch_id,
      x_pnote_ack_date                    => tbh_rec.pnote_ack_date,
      x_pnote_mpn_ind                     => tbh_rec.pnote_mpn_ind,
      x_award_id                          => tbh_rec.award_id,
      x_base_id                           => tbh_rec.base_id,
      x_document_id_txt                   => tbh_rec.document_id_txt,
      x_loan_key_num                      => tbh_rec.loan_key_num,
      x_interest_rebate_percent_num       => tbh_rec.interest_rebate_percent_num,
      x_fin_award_year                    => tbh_rec.fin_award_year,
      x_cps_trans_num                     => tbh_rec.cps_trans_num,
      x_atd_entity_id_txt                 => tbh_rec.atd_entity_id_txt,
      x_rep_entity_id_txt                 => tbh_rec.rep_entity_id_txt,
      x_source_entity_id_txt              => tbh_rec.source_entity_id_txt,
      x_pymt_servicer_amt                 => tbh_rec.pymt_servicer_amt,
      x_pymt_servicer_date                => tbh_rec.pymt_servicer_date,
      x_book_loan_amt                     => tbh_rec.book_loan_amt,
      x_book_loan_amt_date                => tbh_rec.book_loan_amt_date,
      x_s_chg_birth_date                  => tbh_rec.s_chg_birth_date,
      x_s_chg_ssn                         => tbh_rec.s_chg_ssn,
      x_s_chg_last_name                   => tbh_rec.s_chg_last_name,
      x_b_chg_birth_date                  => tbh_rec.b_chg_birth_date,
      x_b_chg_ssn                         => tbh_rec.b_chg_ssn,
      x_b_chg_last_name                   => tbh_rec.b_chg_last_name,
      x_note_message                      => tbh_rec.note_message,
      x_full_resp_code                    => tbh_rec.full_resp_code,
      x_s_permt_county                    => tbh_rec.s_permt_county,
      x_b_permt_county                    => tbh_rec.b_permt_county,
      x_s_permt_country                   => tbh_rec.s_permt_country,
      x_b_permt_country                   => tbh_rec.b_permt_country,
      x_crdt_decision_status              => tbh_rec.crdt_decision_status,
      x_external_loan_id_txt              => tbh_rec.external_loan_id_txt,
      x_deferment_request_code            => tbh_rec.deferment_request_code,
      x_eft_authorization_code            => tbh_rec.eft_authorization_code,
      x_requested_loan_amt                => tbh_rec.requested_loan_amt,
      x_actual_record_type_code           => tbh_rec.actual_record_type_code,
      x_reinstatement_amt                 => tbh_rec.reinstatement_amt,
      x_lender_use_txt                    => tbh_rec.lender_use_txt,
      x_guarantor_use_txt                 => tbh_rec.guarantor_use_txt,
      x_fls_approved_amt                  => tbh_rec.fls_approved_amt,
      x_flu_approved_amt                  => tbh_rec.flu_approved_amt,
      x_flp_approved_amt                  => tbh_rec.flp_approved_amt,
      x_alt_approved_amt                  => tbh_rec.alt_approved_amt,
      x_loan_app_form_code                => tbh_rec.loan_app_form_code,
      x_alt_borrower_ind_flag             => tbh_rec.alt_borrower_ind_flag,
      x_school_id_txt                     => tbh_rec.school_id_txt,
      x_cost_of_attendance_amt            => tbh_rec.cost_of_attendance_amt,
      x_established_fin_aid_amount        => tbh_rec.established_fin_aid_amount,
      x_student_electronic_sign_flag      => tbh_rec.student_electronic_sign_flag,
      x_mpn_type_flag                     => tbh_rec.mpn_type_flag,
      x_school_use_txt                    => tbh_rec.school_use_txt,
      x_expect_family_contribute_amt      => tbh_rec.expect_family_contribute_amt,
      x_borower_electronic_sign_flag      => tbh_rec.borower_electronic_sign_flag,
      x_borower_credit_authoriz_flag      => tbh_rec.borower_credit_authoriz_flag,
      x_esign_src_typ_cd                  => tbh_rec.esign_src_typ_cd

    );

  END LOOP;

EXCEPTION
WHEN app_exception.record_lock_exception THEN
   RAISE;
WHEN others THEN
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_ORIG_ACK.UPD_LOR_LOC_RECORD');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;

END upd_lor_loc_record;


PROCEDURE dl_credit_ack(errbuf    OUT  NOCOPY  VARCHAR2,
                        retcode   OUT  NOCOPY  NUMBER)
IS
---------------------------------------------------------------------------
--  sjadhav   18-Feb-2003      Bug 2758812 - FA 117 Build
--                             This procedure is the entry point for
--                             concurrent manager for DL PLUS Credit ack
--                             processing
---------------------------------------------------------------------------

BEGIN
    g_entry_point := 'CREDIT';
    dl_orig_ack(errbuf,retcode,NULL);

EXCEPTION

    WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       igs_ge_msg_stack.conc_exception_hndl;
    WHEN file_not_loaded THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       igs_ge_msg_stack.conc_exception_hndl;
    WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       fnd_file.put_line(fnd_file.log,SQLERRM);
       igs_ge_msg_stack.conc_exception_hndl;

END dl_credit_ack;


END igf_sl_dl_orig_ack;

/
