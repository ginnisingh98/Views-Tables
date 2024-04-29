--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_CHG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_CHG_ACK" AS
/* $Header: IGFSL06B.pls 120.2 2006/04/19 08:41:21 bvisvana noship $ */

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/29
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
-------------------------------------------------------------------------
--  museshad      20-Feb-2006     Bug 5045784 - SQL Repository Issue.
--                                In dl_chg_ack(), modified cursor cur_get_fed_fund
--                                for better performance.
-----------------------------------------------------------------------------------
--  veramach        29-Jan-2004     bug 3408092 added 2004-2005 in p_dl_version checks
-----------------------------------------------------------------------------------
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             The DUNS_BORW_LENDER_ID,
--                             DUNS_GUARNT_ID,
--                             DUNS_LENDER_ID,
--                             DUNS_RECIP_ID columns are osboleted from the
--                             igf_sl_lor_loc_all table.
---------------------------------------------------------------------------
  gmuralid   03-07-2003    Bug 2995944 - Legacy Part 3 - FFELP Import
                           Added legacy record flag as parameter to
                           igf_sl_loans_pkg

  vvutukur        21-Feb-2003     Enh#2758823.FA117 Build. Modified procedure dl_load_data.
  ***************************************************************/


g_lor_loc_rec       igf_sl_lor_loc%ROWTYPE;
g_dl_version        igf_lookups_view.lookup_code%TYPE;

FILE_NOT_LOADED           exception;
FILE_ALREADY_LOADED       exception;
NOT_PHASE_IN_PARTICIPANT  exception ;


/* FORWARD DECLARATION OF PRIVATE PROCEDURES */
PROCEDURE upd_dl_chg_resp(p_dbth_id       igf_sl_dl_batch.dbth_id%TYPE,
                          p_loan_number   igf_sl_loans.loan_number%TYPE,
                          p_status        igf_sl_dl_chg_resp.status%TYPE);

PROCEDURE upd_loan_record(p_loan_number       IN  igf_sl_loans.loan_number%TYPE,
                          p_loan_status       IN  igf_sl_loans_all.loan_status%TYPE,
                          p_loan_chg_status   IN  igf_sl_loans.loan_chg_status%TYPE,
                          p_rec_present       OUT NOCOPY VARCHAR2);

PROCEDURE upd_lor_loc_record(p_loan_id          igf_sl_lor.loan_id%TYPE,
                             p_loan_chg_status  igf_sl_loans.loan_chg_status%TYPE);




-- Procedure which loads the Data loaded by SQL*Loader into the
-- temp table, parses it as according to the DL File Spec and
-- loads it into the DL interface tables.

PROCEDURE dl_load_data(p_dbth_id OUT NOCOPY  igf_sl_dl_batch.dbth_id%TYPE)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Bug : 2255281 DL Version to checked for DL Programs
  Who             When            What
  vvutukur        21-Feb-2003     Enh#2758823.FA117 Build. Modified the if condition to include 03-04 removing 02-03.
                                  ie., Changed IF g_dl_version IN ('2001-2002','2002-2003') to IF g_dl_version IN ('2002-2003','2003-2004').
  mesriniv        19-mar-2002     Added version 2002-2003 for DL Version Check
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
  l_dl_file_type          igf_sl_dl_file_type.dl_file_type%TYPE;
  l_dl_loan_catg          igf_sl_dl_file_type.dl_loan_catg%TYPE;

  -- Cursor to parse and load the Header record.
  CURSOR c_header IS
  SELECT substr(record_data, 23, 23)       batch_id,
         substr(record_data, 15,  8)       message_class,
         substr(record_data, 46, 16)       bth_creation_date,
         substr(record_data, 60,  2)       batch_rej_code,
         substr(record_data, 23,  2)       batch_type
  FROM igf_sl_load_file_t
  WHERE  lort_id = 1
  AND    record_data like 'DL HEADER%'
  AND    file_type = 'DL_CHG_ACK';

  -- Cursor to parse and load the Trailer record.
  CURSOR c_trailer IS
  SELECT lort_id                  last_lort_id,
         substr(record_data,15,7) number_rec,
         substr(record_data,22,5) accept_rec,
         substr(record_data,27,5) reject_rec,
         substr(record_data,32,5) pending_rec
  FROM igf_sl_load_file_t
  WHERE  lort_id = (select max(lort_id) FROM igf_sl_load_file_t)
  AND    record_data like 'DL TRAILER%'
  AND    file_type = 'DL_CHG_ACK';

  -- Cursor to check the Batch Details, if the same Batch is loaded again.
  CURSOR c_dbth(l_batch_id            igf_sl_dl_batch.batch_id%TYPE,
                l_message_class       igf_sl_dl_batch.message_class%TYPE,
                l_bth_creation_date   VARCHAR2,
                l_batch_type          igf_sl_dl_batch.batch_type%TYPE)
  IS
  SELECT 'x' FROM igf_sl_dl_batch
  WHERE batch_id = l_batch_id
  AND   message_class = l_message_class
  AND   to_char(bth_creation_date,'YYYYMMDDHH24MISS') = l_bth_creation_date
  AND   batch_type  = l_batch_type;


  -- Get the details of award year
  CURSOR c_get_award_year(  p_dl_version igf_lookups_view.lookup_code%TYPE )
  IS
    SELECT ci_cal_type, ci_sequence_number
      FROM  igf_sl_dl_setup
     WHERE   dl_version = p_dl_version ;

   l_award_year  c_get_award_year%ROWTYPE;

BEGIN

  -- Assuming that Header and Trailer record format does not change
  -- since the header record contains Message Class Info, which
  -- indicates the version of the File.


  /*********** Validate the File and Load it ***************/

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


  -- Check whether the File is valid/Not. (ie whether any wrong file is loaded)
  igf_sl_gen.get_dl_batch_details(l_rec_message_class, l_rec_batch_type,
                  g_dl_version, l_dl_file_type, l_dl_loan_catg);
  IF     g_dl_version    = 'INVALID-FILE'
      OR l_dl_file_type  = 'INVALID-FILE'
      OR l_dl_file_type <> 'DL_CHG_ACK' THEN
        fnd_message.set_name('IGF','IGF_GE_INVALID_FILE');
        -- Message : This is not a valid file
        igs_ge_msg_stack.add;
        RAISE FILE_NOT_LOADED;
  END IF;

  -- pssahni 07-Feb-2005
  -- Check if this is a phase-in participant
    OPEN c_get_award_year(g_dl_version);
    FETCH c_get_award_year INTO l_award_year;
    IF c_get_award_year%FOUND THEN
      IF (igf_sl_dl_validation.check_full_participant (l_award_year.ci_cal_type, l_award_year.ci_sequence_number,'DL'))  THEN
        RAISE NOT_PHASE_IN_PARTICIPANT;
      END IF;
    END IF;
    CLOSE c_get_award_year;


  -- This is an Direct Loan Change Acknowledgment File
  fnd_message.set_name('IGF','IGF_SL_DL_CHG_ACK_FILE');
  fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
  fnd_file.put_line(fnd_file.log,' ');


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


  -- Check if the entire batch was rejected for any reason or not
  IF LTRIM(RTRIM(l_rec_batch_rej_code)) IS NOT NULL  THEN
      fnd_message.set_name('IGF','IGF_GE_BATCH_REJECTED');
      fnd_message.set_token('BATCH', l_rec_batch_id);
      fnd_message.set_token('REASON', igf_aw_gen.lookup_desc('IGF_SL_DL_BATCH_REJ',l_rec_batch_rej_code));
      -- Message : Batch #BATCH was rejected. Reason : #REASON.
      igs_ge_msg_stack.add;
      RAISE FILE_NOT_LOADED;
  END IF;

  -- Check if the File already Loaded earlier or not
  OPEN c_dbth(l_rec_batch_id, l_rec_message_class, l_rec_bth_creation_date, l_rec_batch_type);
  FETCH c_dbth INTO l_temp;
  IF c_dbth%NOTFOUND THEN
      CLOSE c_dbth;
  ELSE
      CLOSE c_dbth;
      RAISE FILE_ALREADY_LOADED;
  END IF;

  l_rowid := NULL;
  -- Insert the Batch Details into the igf_sl_dl_batch table.
  igf_sl_dl_batch_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => l_rowid,
      X_dbth_id                           => l_dbth_id,
      X_batch_id                          => l_rec_batch_id,
      X_message_class                     => l_rec_message_class,
      X_bth_creation_date                 => to_date(l_rec_bth_creation_date,'YYYYMMDDHH24MISS'),
      X_batch_rej_code                    => l_rec_batch_rej_code,
      X_end_date                          => NULL,
      X_batch_type                        => l_rec_batch_type,
      X_send_resp                         => 'R',
      X_status                            => 'N'
  );


  /***************  Load Transaction records ***************/


  DECLARE
     l_actual_rec      NUMBER DEFAULT 0;
     l_lor_resp_num    NUMBER;
     CURSOR c_trans IS
     SELECT record_data FROM igf_sl_load_file_t
     WHERE  lort_id between 2 AND (l_last_lort_id-1)
     AND    file_type = 'DL_CHG_ACK';
  BEGIN

    --Added extra check for 2002-2003 as per Enh Bug 2255281
    IF g_dl_version IN ('2002-2003','2003-2004','2004-2005') THEN

          FOR orec IN c_trans LOOP
             l_actual_rec := l_actual_rec + 1;
             FOR l_incr in 1..10 LOOP

                IF RTRIM(substr(orec.record_data, 24+(56*(l_incr-1)), 4)) IS NOT NULL THEN
                   l_rowid := NULL;
                   igf_sl_dl_chg_resp_pkg.insert_row (
                     x_mode                     => 'R',
                     x_rowid                    => l_rowid,
                     X_resp_num                 => l_lor_resp_num,
                     X_dbth_id                  => l_dbth_id,
                     X_batch_id                 => RTRIM(substr(orec.record_data, 590,23) ),
                     X_loan_number              => RTRIM(substr(orec.record_data,   1,21) ),
                     X_chg_code                 => RTRIM(substr(orec.record_data, 24+(56*(l_incr-1)), 4) ),
                     X_reject_code              => RTRIM(substr(orec.record_data, 78+(56*(l_incr-1)), 2) ),
                     X_new_value                => RTRIM(substr(orec.record_data, 28+(56*(l_incr-1)), 50) ),
                     X_loan_ident_err_code      => RTRIM(substr(orec.record_data, 22,2)),
                     X_status                   => 'N'
                   );
                END IF;
             END LOOP;
          END LOOP;
          IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              -- Message : The Actual Number of records does not match with the one mentioned in the trailer
              igs_ge_msg_stack.add;
              RAISE FILE_NOT_LOADED;
          END IF;

  END IF;    -- End of condition for VERSION.

 END;

 p_dbth_id    := l_dbth_id;


EXCEPTION
WHEN FILE_NOT_LOADED THEN
   RAISE;
WHEN FILE_ALREADY_LOADED THEN
   RAISE;
WHEN NOT_PHASE_IN_PARTICIPANT THEN
    RAISE;
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_chg_ack.dl_load_data'||sqlerrm);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END dl_load_data;




/* MAIN PROCEDURE */
PROCEDURE dl_chg_ack(errbuf  OUT NOCOPY    VARCHAR2,
                     retcode OUT NOCOPY    NUMBER,
                     p_org_id IN    NUMBER )
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/29
  Purpose :
  Know limitations, enhancements or remarks
  Change History:
  Bug:-  2383350 Loan Cancellation
  Who             When            What
  museshad       20-Feb-2006      Bug 5045784 - SQL Repository Issue.
                                  Modified cursor cur_get_fed_fund for better
                                  performance.

  mesriniv       28-may-2002      Code added to handle Cancelling a Loan

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_dbth_id               igf_sl_dl_batch.dbth_id%TYPE;
  l_batch_type            igf_sl_dl_batch.batch_type%TYPE;
  l_rec_present           VARCHAR2(10);
  l_stat                  VARCHAR2(30);
  l_loan_chg_status       igf_lookups_view.lookup_code%TYPE;
  l_sub_col_heading       VARCHAR2(1000) DEFAULT NULL;

  CURSOR cur_batch IS
  SELECT igf_sl_dl_batch.* FROM igf_sl_dl_batch
  WHERE dbth_id = l_dbth_id
  AND   status  = 'N';

  -- Get the Count of Records which have Reject Codes, for each change SENT
  -- OR      Count of Records which have Errors for the ENTIRE Line SENT
  CURSOR cur_chg_resp(l_dbth_id igf_sl_dl_batch.dbth_id%TYPE) IS
  SELECT loan_number,
         NVL(SUM(DECODE(loan_ident_err_code,NULL,0,1)),0)  loan_err_count,
         NVL(SUM(DECODE(reject_code,NULL,1,0)),0)          accept_count,
         NVL(SUM(DECODE(reject_code,NULL,0,1)),0)          reject_count
  FROM igf_sl_dl_chg_resp
  WHERE dbth_id = l_dbth_id
  AND   status  = 'N'
  GROUP BY loan_number;

  -- Get the fed fund code for the loan number
  CURSOR cur_get_fed_fund(p_loan_number igf_sl_loans_all.loan_number%TYPE) IS
    SELECT  fcat.fed_fund_code
    FROM    igf_sl_loans_all loan,
            igf_aw_award_all awd,
            igf_aw_fund_mast_all fmast,
            igf_aw_fund_cat_all fcat
    WHERE
            loan.award_id     =   awd.award_id    AND
            awd.fund_id       =   fmast.fund_id   AND
            fcat.fund_code    =   fmast.fund_code AND
            loan.loan_number  =   p_loan_number;

  --Added code as part of Bug :- 2383350 Loan Cancellation
  --Check if the received file has  the change code as LOAN_AMT_ACCEPTED
  --for the particular Loan Number
  CURSOR cur_get_loan_accp_amt(p_loan_number igf_sl_loans_all.loan_number%TYPE,
                               p_dbth_id     igf_sl_dl_batch.dbth_id%TYPE,
                               p_loan_catg   igf_sl_dl_chg_fld.loan_catg%TYPE
                               ) IS
  SELECT resp.new_value
  FROM   igf_sl_dl_chg_resp resp,igf_sl_dl_chg_fld chgfld
  WHERE  loan_number          =p_loan_number
  AND    dbth_id              =p_dbth_id
  AND    status               ='N'
  AND    resp.chg_code        = chgfld.chg_code
  AND    chgfld.dl_version    = g_dl_version
  AND    chgfld.fld_name      ='LOAN_AMT_ACCEPTED'
  AND    chgfld.loan_catg     =p_loan_catg;


  l_loan_accp_amt  igf_aw_award_all.accepted_amt%TYPE;
  l_loan_status    igf_sl_loans_all.loan_status%TYPE;
  l_loan_catg      igf_sl_dl_chg_fld.loan_catg%TYPE;
  l_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE;

BEGIN

    igf_aw_gen.set_org_id(p_org_id);

  -- Load the Data into the Batch and Response Tables
  dl_load_data(l_dbth_id);

  FOR dbth_rec IN cur_batch LOOP


       -- These are Direct Loan Change Response records.

       FOR resp_rec IN cur_chg_resp(l_dbth_id) LOOP
          l_rec_present := 'N';

          IF ((resp_rec.reject_count > 0) OR (resp_rec.loan_err_count > 0)) THEN
              l_loan_chg_status := 'R';         -- REJECTED (Code for LOAN_CHG_STATUS)
          ELSE
              l_loan_chg_status := 'A';         -- ACCEPTED (Code for LOAN_CHG_STATUS)

             --Get the fed fund code for the loan
             OPEN cur_get_fed_fund(resp_rec.loan_number);
             FETCH cur_get_fed_fund INTO l_fed_fund_code;
             CLOSE cur_get_fed_fund;

             IF l_fed_fund_code ='DLP' THEN
                l_loan_catg :='DL_PLUS';
             ELSE
                l_loan_catg :='DL_STAFFORD';
             END IF;

             --Fetch the Response data for the particular loan number
             --for which the CHANGE CODE Field Name is LOAN_ACCEPTED_AMT
             --The field name and corr Change Code are present in IGF_SL_DL_CHG_FLD
             --for the current loan category and also the file format version
             --Seeded Data should be available

             OPEN cur_get_loan_accp_amt(resp_rec.loan_number,l_dbth_id,l_loan_catg);
             FETCH cur_get_loan_accp_amt INTO l_loan_accp_amt;

             --This ensures that seeded data is present and also the
             --Loan Accepted Amt is received from LOC
             IF cur_get_loan_accp_amt%FOUND THEN

               IF  NVL(l_loan_accp_amt,0) = 0 THEN
                  l_loan_status :='C';
              END IF;

             END IF;
             CLOSE cur_get_loan_accp_amt;

         END IF;


          -- Update the IGF_SL_LOANS record with the Loan Change Status
          upd_loan_record(resp_rec.loan_number,l_loan_status,l_loan_chg_status, l_rec_present);

          -- If the Loan# being uploaded is not a Valid Loan#
          IF l_rec_present = 'N' THEN
              fnd_message.set_name('IGF','IGF_SL_NO_LOAN_NUMBER');
              fnd_message.set_token('LOAN_NUMBER',resp_rec.loan_number);
              fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
              -- Message : Loan ID #LOAN_NUMBER does not exist in the Financial Aid System

              -- Update the Loan Change Response Record as NOT UPLOADED, Since it is INVALID
              upd_dl_chg_resp(l_dbth_id, resp_rec.loan_number, 'I');

          ELSE
             -- If the Loan Number is a Valid Loan-number

             -- If the Loan Changes were Rejected, Then
             -- Update the Loan Change Status of the Loan Application record
             -- and also display and insert the reject codes.
             IF l_loan_chg_status = 'R' THEN

                -- Show "Changes for Loan ID #LOAN_NUMBER were #LOAN_CHG_STATUS" on the Log File.
                fnd_message.set_name('IGF','IGF_SL_LOAN_CHG_STATUS');
                fnd_message.set_token('LOAN_NUMBER',resp_rec.loan_number);
                fnd_message.set_token('LOAN_STATUS',
                                       igf_aw_gen.lookup_desc('IGF_SL_REC_STATUS',l_loan_chg_status));
                fnd_file.put_line(FND_FILE.LOG, fnd_message.get);


                /************* Show Reject Details on the LOG File ***************/
                DECLARE

                  -- Loan Error for the ENTIRE line are retrieved here.
                  CURSOR cur_loan_err_resp(l_dbth_id     igf_sl_dl_batch.dbth_id%TYPE,
                                           l_loan_number igf_sl_loans.loan_number%TYPE) IS
                  SELECT DISTINCT rchg.loan_ident_err_code
                  FROM   igf_sl_dl_chg_resp rchg
                  WHERE   rchg.dbth_id     = l_dbth_id
                  AND     rchg.loan_number = l_loan_number
                  AND     rchg.loan_ident_err_code IS NOT NULL
                  AND     rchg.status      = 'N';

                  -- Reject Codes for Individual Field Changes are retrieved here.
                  CURSOR cur_chg_rej_resp(l_dbth_id     igf_sl_dl_batch.dbth_id%TYPE,
                                          l_loan_number igf_sl_loans.loan_number%TYPE) IS
                  SELECT fld_name, cchgv.description fld_desc, rchg.reject_code, rchg.new_value
                  FROM igf_sl_dl_chg_resp rchg,
                       igf_sl_dl_chg_fld_v cchgv
                  WHERE   rchg.dbth_id     = l_dbth_id
                  AND     rchg.loan_number = l_loan_number
                  AND     rchg.reject_code IS NOT NULL
                  AND     rchg.status      = 'N'
                  AND     rchg.chg_code    = cchgv.chg_code
                  AND     cchgv.dl_version = g_dl_version;

                BEGIN

                  -- Delete the Edit Records from the table, with "Errors occurred during Change Resp"
                  igf_sl_edit.delete_edit(resp_rec.loan_number, 'H');

                  -- If Reject codes are present for each LINE, then show those.
                  IF resp_rec.loan_err_count > 0 THEN

                       FOR lrec IN cur_loan_err_resp(l_dbth_id, resp_rec.loan_number) LOOP

                           -- Display on the LOG File.
                           fnd_file.put_line(FND_FILE.LOG,
                                  igf_aw_gen.lookup_desc('IGF_SL_DL_CHG_REJ_CODES', lrec.loan_ident_err_code));

                           -- Insert Loan Error Code details into the edit_report table.
                           igf_sl_edit.insert_edit(resp_rec.loan_number,
                                                   'H',                      -- EDITS from Change Response
                                                   'IGF_SL_DL_CHG_REJ_CODES',
                                                   lrec.loan_ident_err_code,
                                                   NULL,
                                                   NULL);
                       END LOOP;

                  END IF;  -- END of condition "resp_rec.reject_count > 0 "

                  -- If Reject codes are present for each field, then show those.
                  IF resp_rec.reject_count > 0 THEN

                       -- Show a Sub-heading on the Log File, to show the reject descriptions.
                       IF l_sub_col_heading IS NULL THEN
                           l_sub_col_heading := RPAD(igf_aw_gen.lookup_desc('IGF_SL_GEN','FIELDS'),50)
                                              ||'  '
                                              ||RPAD(igf_aw_gen.lookup_desc('IGF_SL_GEN','VALUES'),50)
                                              ||'  '
                                              ||igf_aw_gen.lookup_desc('IGF_SL_GEN','REJ_REASON');
                       END IF;
                       fnd_file.put_line(FND_FILE.LOG, l_sub_col_heading);
                       fnd_file.put_line(FND_FILE.LOG, RPAD('-',50,'-')||'  '||RPAD('-',50,'-')||'  '
                                                     ||RPAD('-',100,'-') );

                       FOR rrec IN cur_chg_rej_resp(l_dbth_id, resp_rec.loan_number) LOOP

                           -- Display on the LOG File.
                           fnd_file.put_line(FND_FILE.LOG, RPAD(rrec.fld_desc,50) ||'  '
                                   ||RPAD(rrec.new_value,50)||'  '
                                   ||igf_aw_gen.lookup_desc('IGF_SL_DL_CHG_REJ_CODES',rrec.reject_code));

                           -- Insert Reject details into the edit_report table.
                           igf_sl_edit.insert_edit(resp_rec.loan_number,
                                                   'H',                   -- EDITS from Change Response
                                                   'IGF_SL_DL_CHG_REJ_CODES',
                                                   rrec.reject_code,
                                                   rrec.fld_name,
                                                   rrec.new_value);
                       END LOOP;

                  END IF;  -- END of condition "resp_rec.reject_count > 0 "

                END;

             END IF;  -- End of condition for "l_loan_chg_status = 'R' "

             -- Update the Loan Change Response Record as UPLOADED, as the Loan ID exists
             upd_dl_chg_resp(l_dbth_id, resp_rec.loan_number, 'Y');

          END IF;  -- End of condition for "l_rec_present = 'N' "


          -- This is done to get a seperator of 2 Lines between each Loan rejected.
          IF l_loan_chg_status <> 'A' THEN
            fnd_file.put_line(FND_FILE.LOG,'');
            fnd_file.put_line(FND_FILE.LOG,'');
          END IF;

       END LOOP;  -- End of igf_sl_dl_chg_resp table LOOP.


    -- Update the DL_BATCH record as Successfully Uploaded.
    igf_sl_dl_batch_pkg.update_row (
      X_Mode                              => 'R',
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
    WHEN FILE_NOT_LOADED THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
    WHEN FILE_ALREADY_LOADED THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGF','IGF_GE_BATCH_ALEARDY_LOADED');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

    WHEN NOT_PHASE_IN_PARTICIPANT THEN
        ROLLBACK;
        fnd_message.set_name('IGF','IGF_SL_COD_NO_CHG_ACK');
        fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
        fnd_file.put_line(fnd_file.log,' ');

    WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END dl_chg_ack;




PROCEDURE upd_dl_chg_resp(p_dbth_id       igf_sl_dl_batch.dbth_id%TYPE,
                          p_loan_number   igf_sl_loans.loan_number%TYPE,
                          p_status        igf_sl_dl_chg_resp.status%TYPE)
IS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    lv_row_id  VARCHAR2(25);
    CURSOR c_tbh_cur IS
    SELECT igf_sl_dl_chg_resp.* FROM igf_sl_dl_chg_resp
    WHERE  dbth_id = p_dbth_id
    AND    loan_number = p_loan_number;
BEGIN

  FOR tbh_rec in c_tbh_cur LOOP

    tbh_rec.status := p_status;

    igf_sl_dl_chg_resp_pkg.update_row (
      X_Mode                              => 'R',
      x_rowid                             => tbh_rec.row_id,
      x_resp_num                          => tbh_rec.resp_num,
      x_dbth_id                           => tbh_rec.dbth_id,
      x_batch_id                          => tbh_rec.batch_id,
      x_loan_number                       => tbh_rec.loan_number,
      x_chg_code                          => tbh_rec.chg_code,
      x_reject_code                       => tbh_rec.reject_code,
      x_new_value                         => tbh_rec.new_value,
      x_loan_ident_err_code               => tbh_rec.loan_ident_err_code,
      x_status                            => tbh_rec.status
    );
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_chg_ack.upd_dl_chg_resp');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END upd_dl_chg_resp;



-- Update the IGF_SL_LOANS record, for the Loan-Number, for the New Change Status
-- If the Loan_number is not present in OFA, then return p_rec_present as 'N'
PROCEDURE upd_loan_record(p_loan_number       IN igf_sl_loans.loan_number%TYPE,
                          p_loan_status       IN igf_sl_loans_all.loan_status%TYPE,
                          p_loan_chg_status   IN igf_sl_loans.loan_chg_status%TYPE,
                          p_rec_present       OUT NOCOPY VARCHAR2)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  agairola       15-Mar-2002      Modified the Update Row call
                                  of the IGF_SL_LOANS_PKG to include the
                                  Borrower Determination as part of Refunds DLD 2144600
  (reverse chronological order - newest change first)
  ***************************************************************/

  l_row_id  VARCHAR2(25);
  CURSOR c_tbh_cur IS
  SELECT igf_sl_loans.* FROM igf_sl_loans
  WHERE loan_number = p_loan_number
  FOR UPDATE OF loan_id NOWAIT;

BEGIN
   p_rec_present := 'N';

   FOR tbh_rec in c_tbh_cur LOOP

       -- If the Loan-Number is a Valid Loan-Number
       p_rec_present := 'Y';

       tbh_rec.loan_chg_status      := p_loan_chg_status;
       tbh_rec.loan_chg_status_date := TRUNC(SYSDATE);

       --Message in the Log File which specifies that a Loan is Cancelled and Update Loan Status and Date
       IF p_loan_status ='C' THEN
          tbh_rec.loan_status:=p_loan_status;
          tbh_rec.loan_status_date := TRUNC(SYSDATE);
          fnd_file.put_line(fnd_file.log,' ');
          fnd_message.set_name('IGF','IGF_SL_LOAN_CANCELLED');
          fnd_message.set_token('LOAN_NO',tbh_rec.loan_number);
          --Loan Number tbh_rec.loan_number has been cancelled.
          fnd_file.put_line(fnd_file.log,fnd_message.get);
       END IF;



-- Modified the Update Row call for the Borrower Determination
-- as part of the Refunds DLD 2144600
       igf_sl_loans_pkg.update_row (
          X_Mode                              => 'R',
          x_rowid                             => tbh_rec.row_id,
          x_loan_id                           => tbh_rec.loan_id,
          x_award_id                          => tbh_rec.award_id,
          x_seq_num                           => tbh_rec.seq_num,
          x_loan_number                       => tbh_rec.loan_number,
          x_loan_per_begin_date               => tbh_rec.loan_per_begin_date,
          x_loan_per_end_date                 => tbh_rec.loan_per_end_date,
          x_loan_status                       => tbh_rec.loan_status,
          x_loan_status_date                  => tbh_rec.loan_status_date,
          x_loan_chg_status                   => tbh_rec.loan_chg_status,
          x_loan_chg_status_date              => tbh_rec.loan_chg_status_date,
          x_active                            => tbh_rec.active,
          x_active_date                       => tbh_rec.active_date,
          x_borw_detrm_code                   => tbh_rec.borw_detrm_code,
          x_legacy_record_flag                => NULL,
          x_external_loan_id_txt              => tbh_rec.external_loan_id_txt

       );

       -- Update the LOR LOC record, to reflect the incoming information.
       upd_lor_loc_record(tbh_rec.loan_id, p_loan_chg_status);

   END LOOP;

EXCEPTION
WHEN others THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_chg_ack.upd_loan_record');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END upd_loan_record;



-- Update the IGF_SL_LOR_LOC record for the New Loan Change Status, for the passed Loan-Number
PROCEDURE upd_lor_loc_record(p_loan_id          igf_sl_lor.loan_id%TYPE,
                             p_loan_chg_status  igf_sl_loans.loan_chg_status%TYPE)
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/22
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
-------------------------------------------------------------------------
--  bvisvana   10-Apr-2006     Build FA 161. TBH Impact change
--                             in igf_sl_lor_loc_pkg.update_row()
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             The DUNS_BORW_LENDER_ID,
--                             DUNS_GUARNT_ID,
--                             DUNS_LENDER_ID,
--                             DUNS_RECIP_ID columns are osboleted from the
--                             igf_sl_lor_loc_all table.
---------------------------------------------------------------------------
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_tbh_cur IS
    SELECT igf_sl_lor_loc.* FROM igf_sl_lor_loc
    WHERE loan_id = p_loan_id;
BEGIN

  FOR tbh_rec in c_tbh_cur LOOP

    tbh_rec.loan_chg_status      := p_loan_chg_status;
    tbh_rec.loan_chg_status_date := TRUNC(SYSDATE);

    igf_sl_lor_loc_pkg.update_row (
      X_Mode                              => 'R',
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
      x_chg_batch_id                      => tbh_rec.chg_batch_id,
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
      x_lend_apprv_denied_code            => tbh_rec.lend_apprv_denied_code,
      x_lend_apprv_denied_date            => tbh_rec.lend_apprv_denied_date,
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
      x_cl_rec_status                     => tbh_rec.cl_rec_status,
      x_cl_rec_status_last_update         => tbh_rec.cl_rec_status_last_update,
      x_alt_prog_type_code                => tbh_rec.alt_prog_type_code,
      x_alt_appl_ver_code                 => tbh_rec.alt_appl_ver_code,
      x_borw_outstd_loan_code             => tbh_rec.borw_outstd_loan_code,
      x_mpn_confirm_code                  => tbh_rec.mpn_confirm_code,
      x_resp_to_orig_code                 => tbh_rec.resp_to_orig_code,
      x_appl_loan_phase_code              => tbh_rec.appl_loan_phase_code,
      x_appl_loan_phase_code_chg          => tbh_rec.appl_loan_phase_code_chg,
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
      x_p_ssn_chg_date                    => tbh_rec.p_ssn_chg_date,
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
      x_p_dob_chg_date                    => tbh_rec.p_dob_chg_date,
      x_p_license_num                     => tbh_rec.p_license_num,
      x_p_license_state                   => tbh_rec.p_license_state,
      x_p_citizenship_status              => tbh_rec.p_citizenship_status,
      x_p_alien_reg_num                   => tbh_rec.p_alien_reg_num,
      x_p_default_status                  => tbh_rec.p_default_status,
      x_p_foreign_postal_code             => tbh_rec.p_foreign_postal_code,
      x_p_state_of_legal_res              => tbh_rec.p_state_of_legal_res,
      x_p_legal_res_date                  => tbh_rec.p_legal_res_date,
      x_s_ssn                             => tbh_rec.s_ssn,
      x_s_ssn_chg_date                    => tbh_rec.s_ssn_chg_date,
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
      x_s_local_addr_chg_date             => tbh_rec.s_local_addr_chg_date,
      x_s_email_addr                      => tbh_rec.s_email_addr,
      x_s_date_of_birth                   => tbh_rec.s_date_of_birth,
      x_s_dob_chg_date                    => tbh_rec.s_dob_chg_date,
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
      x_borower_credit_authoriz_flag      => tbh_rec.borower_credit_authoriz_flag ,
      x_esign_src_typ_cd                  => tbh_rec.esign_src_typ_cd

    );

  END LOOP;

EXCEPTION
WHEN others THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_chg_ack.upd_lor_loc_record');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END upd_lor_loc_record;


END igf_sl_dl_chg_ack;

/
