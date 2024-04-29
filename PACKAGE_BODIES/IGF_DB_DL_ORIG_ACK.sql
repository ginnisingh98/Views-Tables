--------------------------------------------------------
--  DDL for Package Body IGF_DB_DL_ORIG_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_DL_ORIG_ACK" AS
/* $Header: IGFDB03B.pls 120.2 2006/02/01 02:39:50 ridas ship $ */

  /*************************************************************
  Created By : prchandr
  Date Created On : 2000/12/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  bvisvana        19-Jul-2005     Bug 4101317 - added new exception INVALID_PHASE_IN_PARTICIPANT
  ayedubat        20-OCT-2004     FA 149 COD-XML Standards build bug # 3416863
                                  Replaced the reference of igf_db_awd_disb_dtl with igf_aw_db_chg_dtls table
                                  Changed the logic as per the TD, FA149_TD_COD_XML_i1a.doc
    veramach        29-Jan-2004     bug 3408092 added 2004-2005 in l_dl_version checks
  sjadhav         31-Mar-2003     Bug 2863960
                                  added desc for disb data displayed
                                  in the log file

  vvutukur        21-Feb-2003     Enh#2758823.FA117 Build.
                                  Modified procedure disb_load_data.

  ***************************************************************/



FILE_NOT_LOADED     EXCEPTION;
SKIP_THIS_RECORD    EXCEPTION;
INVALID_PHASE_IN_PARTICIPANT  EXCEPTION;

-- Procedure to Load the Data from the Data File into the Interface tables.
-- Before loading, it does lot of checks to ensure it is the right file
-- and returns the dbth_id, for further processing.
PROCEDURE disb_load_data(p_dbth_id       OUT NOCOPY  igf_sl_dl_batch.dbth_id%TYPE,
                         p_batch_id      OUT NOCOPY  igf_sl_dl_batch.batch_id%TYPE,
                         p_dl_version    OUT NOCOPY  igf_sl_dl_file_type.dl_version%TYPE,
                         p_dl_file_type  OUT NOCOPY  igf_sl_dl_file_type.dl_loan_catg%TYPE)
AS
  /*************************************************************
  Created By : Prajeesh Chandran .K
  Date Created On : 2000/12/20
  Purpose :Procedure to load the datas in igf_db_dl_resp from igf_load_file_T
  Know limitations, enhancements or remarks
  Change History
  Bug :2255281
  Desc:DL VERSION TO BE CHECKED FOR DL CHANGE ORIG AND DISB ORIGINATION LOAN PROGRAMS.
  Who             When            What
  vvutukur        21-Feb-2003     Enh#2758823.FA117 Build. Modified the if condition to include 03-04 removing 02-03.
                                  ie., Changed IF l_dl_version IN ('2001-2002','2002-2003') to IF l_dl_version IN ('2002-2003','2003-2004').
                                  In the call to igf_db_dl_disb_resp_pkg.insert_row passed NULL to x_sch_code_status,x_loan_num_status,
                                  x_disb_num_status,x_trans_date_status,x_trans_date_status.
  mesriniv        19-MAR-2002     Added Version 2002-2003 check
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
  x_ddrp_id               igf_db_dl_disb_resp.ddrp_id%TYPE;
  -- ## Cursor for formulating the header

  CURSOR c_header
  IS
  SELECT RTRIM(SUBSTR(record_data, 23, 23))       batch_id,
         RTRIM(SUBSTR(record_data, 15,  8))       message_class,
         RTRIM(SUBSTR(record_data, 46, 16))       bth_creation_date,
         RTRIM(SUBSTR(record_data, 60,  2))       batch_rej_code,
         RTRIM(SUBSTR(record_data, 23,  2))       batch_type
  FROM   igf_sl_load_file_t
  WHERE  lort_id = 1
  AND    record_data LIKE 'DL HEADER%'
  AND    file_type = 'DL_DISB';


  -- ## Cursor for formulating the trailer

  CURSOR c_trailer
  IS
  SELECT lort_id                         last_lort_id,
         RTRIM(SUBSTR(record_data,15,7)) number_rec,
         RTRIM(SUBSTR(record_data,22,5)) accept_rec,
         RTRIM(SUBSTR(record_data,27,5)) reject_rec,
         RTRIM(SUBSTr(record_data,32,5)) pending_rec
  FROM   igf_sl_load_file_t
  WHERE  lort_id = (SELECT MAX(lort_id) FROM igf_sl_load_file_t)
  AND    record_data LIKE 'DL TRAILER%'
  AND    file_type = 'DL_DISB';

BEGIN

  -- Assuming that Header and Trailer record format does not change
  -- since the header record contains Message Class Info, which
  -- indicates the version of the File.

  -- *************  Check File Uploaded ********************

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


  IF  l_dl_file_type  IN ('DL_DISB_ACK','DL_DISB_BOOK')
      AND l_dl_loan_catg = 'DL' THEN
           NULL;
  ELSE
      fnd_message.set_name('IGF','IGF_GE_INVALID_FILE');
      -- Message : This is not a valid file
      igs_ge_msg_stack.add;
      RAISE FILE_NOT_LOADED;
  END IF;

  IF l_dl_file_type ='DL_DISB_ACK' THEN
      -- This is an Direct Loan Disbursment Acknowledgment File
      fnd_message.set_name('IGF','IGF_DB_DL_ACK_FILE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
  ELSIF l_dl_file_type='DL_DISB_BOOK'  THEN
      fnd_message.set_name('IGF','IGF_DB_DL_BOOK_FILE');
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
      igs_ge_msg_stack.add;
      RAISE FILE_NOT_LOADED;
  END IF;
  CLOSE c_trailer;


  IF l_rec_batch_rej_code IS NOT NULL  THEN
      fnd_message.set_name('IGF','IGF_GE_BATCH_REJECTED');
      fnd_message.set_token('BATCH', l_rec_batch_id);
      fnd_message.set_token('REASON', igf_aw_gen.lookup_desc('IGF_SL_DL_BATCH_REJ',l_rec_batch_rej_code));
      igs_ge_msg_stack.add;
      RAISE FILE_NOT_LOADED;
      -- Message : Batch #BATCH was rejected. Reason : #REASON.

  END IF;


  l_rowid := NULL;
  igf_sl_dl_batch_pkg.insert_row (
      x_mode                 => 'R',
      x_rowid                => l_rowid,
      x_dbth_id              => l_dbth_id,
      x_batch_id             => l_rec_batch_id,
      x_message_class        => l_rec_message_class,
      x_bth_creation_date    => TO_DATE(l_rec_bth_creation_date,'YYYYMMDDHH24MISS'),
      x_batch_rej_code       => l_rec_batch_rej_code,
      x_end_date             => NULL,
      x_batch_type           => l_rec_batch_type,
      x_send_resp            => 'R',
      x_status               => 'Y'
  );


  -- *************  Disbursement Transactions ********************

  DECLARE
     l_actual_rec      NUMBER DEFAULT 0;
     l_lor_resp_num    NUMBER;
     x_ddrp_Id         NUMBER;
     l_rowid           ROWID;
     CURSOR cur_disb
     IS
     SELECT record_data
     FROM   igf_sl_load_file_t
     WHERE  lort_id between 2 AND (l_last_lort_id-1)
     AND    file_type = 'DL_DISB';
  BEGIN
  --Added Version 2002-2003 as per Bug 2255281 DL VERSION TO BE CHECKED FOR DL CHANGE ORIG AND DISB ORIGINATION LOAN PROGRAMS.


    IF l_dl_version IN ('2002-2003','2003-2004','2004-2005') THEN

       -- File is Origination Response File For Stafford/PLUS.
       IF l_dl_file_type IN ('DL_DISB_ACK','DL_DISB_BOOK') THEN
          FOR lcur_disb IN cur_disb LOOP
             l_actual_rec := l_actual_rec + 1;

              igf_db_dl_disb_resp_pkg.insert_row (
                           x_mode                   => 'R',
                           x_rowid                  => l_rowid,
                           x_ddrp_id                => x_ddrp_id,
                           x_dbth_id                => l_dbth_id,
                           x_loan_number            => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,1,21))),
                           x_disb_num               => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,22,2)))),
                           x_disb_activity          => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,24,1))),
                           x_transaction_date       => TO_DATE(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,25,8))),'YYYYMMDD'),
                           x_disb_seq_num           => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,33,2)))),
                           x_disb_gross_amt         => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,35,5)))),
                           x_fee_1                  => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,40,5)))),
                           x_disb_net_amt           => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,45,5)))),
                           x_int_rebate_amt         => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,50,5)))),
                           x_user_ident             => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,56,8))),
                           x_disb_batch_id          => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,64,23))),
                           x_school_id              => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,87,6))),
                           x_sch_code_status        => NULL,
                           x_loan_num_status        => NULL,
                           x_disb_num_status        => NULL,
                           x_disb_activity_status   => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,96,10))),
                           x_trans_date_status      => NULL,
                           x_disb_seq_num_status    => NULL,
                           x_loc_disb_gross_amt     => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,108,5)))),
                           x_loc_fee_1              => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,113,5)))),
                           x_loc_disb_net_amt       => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,118,5)))),
                           x_servicer_refund_amt    => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,123,6)))),
                           x_loc_int_rebate_amt     => TO_NUMBER(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,130,5)))),
                           x_loc_net_booked_loan    => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,139,5))),
                           x_ack_date               => TO_DATE(LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,144,8))),'YYYYMMDD'),
                           x_affirm_flag            => LTRIM(RTRIM(SUBSTR(lcur_disb.record_data,152,1))),
                           x_status                 => 'N'
                           );

          END LOOP;
          IF l_actual_rec <> l_number_rec THEN
              fnd_message.set_name('IGF','IGF_GE_RECORD_NUM_NOT_MATCH');
              -- Message : The Actual Number of records does not match with the one mentioned in the trailer
              igs_ge_msg_stack.add;
              RAISE FILE_NOT_LOADED;
          END IF;
       END IF;
     END IF;

 END;

 p_dbth_id       := l_dbth_id;
 p_dl_version    := l_dl_version;
 p_dl_file_type  := l_dl_file_type;
 p_batch_id      := l_rec_batch_id;

EXCEPTION
WHEN app_exception.record_lock_exception THEN
   RAISE;
WHEN FILE_NOT_LOADED THEN
   RAISE;
WHEN OTHERS THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_DB_DL_ORIG_ACK.DISB_LOAD_DATA');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END disb_load_data;


--
-- main procedure
--

PROCEDURE disb_ack(errbuf    OUT   NOCOPY    VARCHAR2,
                   retcode   OUT   NOCOPY    NUMBER,
                   p_org_id  IN    NUMBER )
AS
  /*************************************************************
  Created By : Prajeesh Chandran .K
  Date Created On : 2000/12/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  bvisvana    19-Jul-2005      Bug 4101317 - RAISE INVALID_PHASE_IN_PARTICIPANT in case on award year not a phase in participant
  vvutukur    26-Feb-2003      Enh#2758823.FA117 Build. Replaced message IGS_GE_FILE_NOT_LOADED with IGF_GE_FILE_NOT_LOADED as the former one
                               is not a correct one.Removed validations regarding loan_num_status,disb_num_status,disb_seq_num_status,sch_code_status.
                               Removed if condition IF lcur_awdisb.booking_batch_id IS NOT NULL THEN.
  ridas       31-Jan-2006      Bug #4951401. Added procedure igf_aw_gen.set_org_id()
  ***************************************************************/

  l_dbth_id                   igf_sl_dl_batch.dbth_id%TYPE;  -- ## Variable for the batch ID
  l_batch_type                igf_sl_dl_batch.batch_type%TYPE;
  l_stat                      VARCHAR2(30);
  l_batch_id                  igf_sl_dl_batch.batch_id%TYPE;

  l_dl_version                igf_sl_dl_file_type.dl_version%TYPE;
  l_dl_file_type              igf_sl_dl_file_type.dl_file_type%TYPE;
  l_disb_status               igf_aw_db_chg_dtls.disb_status%TYPE;
  l_disb_status_date          igf_aw_db_chg_dtls.disb_status_date%TYPE;
  l_disb_ack_date             igf_db_dl_disb_resp.ack_date%TYPE DEFAULT NULL;

  l_mesg_str1                 VARCHAR2(4000);                -- ## String to put in the log file
  l_mesg_str2                 VARCHAR2(4000);                -- ## String to put in the log file
  l_mesg_str3                 VARCHAR2(4000);                -- ## String to put in the log file

  l_loan_number_desc          igf_lookups_view.meaning%TYPE;
  l_disb_num_desc             igf_lookups_view.meaning%TYPE;
  l_disb_seq_num_desc         igf_lookups_view.meaning%TYPE;
  l_disb_gross_amt_desc       igf_lookups_view.meaning%TYPE;
  l_disb_net_amt_desc         igf_lookups_view.meaning%TYPE;
  l_int_rebate_amt_desc       igf_lookups_view.meaning%TYPE;
  l_fee_1_desc                igf_lookups_view.meaning%TYPE;
  l_sch_code_status_desc      igf_lookups_view.meaning%TYPE;
  l_loan_num_status_desc      igf_lookups_view.meaning%TYPE;
  l_disb_num_status_desc      igf_lookups_view.meaning%TYPE;
  l_disb_seq_num_status_desc  igf_lookups_view.meaning%TYPE;
  l_disb_date_desc            igf_lookups_view.meaning%TYPE;

  -- ## Cursor to get the Disbursement Details to Process the acknowlegement Process

  CURSOR cur_db_resp(l_dbth_id igf_sl_dl_batch.dbth_id%TYPE)
    IS
    SELECT *
    FROM   igf_db_dl_disb_resp
    WHERE  dbth_id = l_dbth_id
    AND    status  = 'N';

  -- ## Cursor to Get the award disbursements for the particular loannumber,award id ,disbursement Number  and disbursement sequence number

   CURSOR  cur_awdisb(l_loan_number  igf_db_cl_disb_resp.loan_number%TYPE,
                      l_disb_num     igf_aw_db_chg_dtls.disb_num%TYPE,
                      l_disb_seq_num igf_aw_db_chg_dtls.disb_seq_num%TYPE)
       IS
       SELECT adcd.*
       FROM   igf_aw_db_chg_dtls adcd,
              igf_sl_loans sl
       WHERE
         sl.loan_number     =  l_loan_number  AND
         adcd.award_id      =  sl.award_id    AND
         adcd.disb_num      =  l_disb_num     AND
         adcd.disb_seq_num  =  l_disb_seq_num;

   lcur_awdisb            cur_awdisb%ROWTYPE;

   l_log_start_flag       BOOLEAN;

   CURSOR award_year_cur ( cp_dl_version IGF_SL_DL_SETUP.dl_version%TYPE) IS
     SELECT ci_cal_type, ci_sequence_number
     FROM igf_sl_dl_setup
     WHERE dl_version = cp_dl_version;
   award_year_rec award_year_cur%ROWTYPE;
   l_cod_year_flag   BOOLEAN;

   -- Used to print the disbursement details in the log file
   TYPE disb_dtl_rec IS  RECORD
     (
      p_disb_num     NUMBER(15),
      p_disb_seq_num NUMBER(15),
      p_disb_date    DATE,
      p_disb_amount  NUMBER(10,3),
      p_rec_type     VARCHAR2(1)
     );

   TYPE disb_dtl_tab IS TABLE OF disb_dtl_rec INDEX BY BINARY_INTEGER;
   l_disb_dtl_tab disb_dtl_tab;
   l_disb_count NUMBER(15);


   -- ## Local Procedure to print the Loan Number, Disb Number and Disb Seq Num in the LOG File

   PROCEDURE log_start(p_loan_number  igf_db_dl_disb_resp.loan_number%TYPE,
                       p_disb_num     igf_db_dl_disb_resp.disb_num%TYPE,
                       p_disb_seq_num igf_db_dl_disb_resp.disb_seq_num%TYPE
                       )
   AS
   BEGIN

       IF l_log_start_flag = FALSE THEN

            fnd_file.put_line(fnd_file.log,RPAD(l_loan_number_desc ,50)||' : '||p_loan_number);
            fnd_file.put_line(fnd_file.log,RPAD(l_disb_num_desc    ,50)||' : '||TO_CHAR(p_disb_num)  );
            fnd_file.put_line(fnd_file.log,RPAD(l_disb_seq_num_desc,50)||' : '||TO_CHAR(p_disb_seq_num));

            l_log_start_flag := TRUE;
        END IF;

    END;

BEGIN

  igf_aw_gen.set_org_id(p_org_id);

  -- Load the Data into the Batch and Response Tables
  disb_load_data(l_dbth_id, l_batch_id,l_dl_version, l_dl_file_type);

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
    fnd_message.set_name('IGF','IGF_SL_COD_NO_DISB_ACK');
    igs_ge_msg_stack.add;
    RAISE INVALID_PHASE_IN_PARTICIPANT;
  END IF;

  -- ## Getting the Loopkup Descriptions.

  l_loan_number_desc     := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER');
  l_disb_num_desc        := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NUM');
  l_disb_seq_num_desc    := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_SEQ_NUM');
  l_disb_gross_amt_desc  := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_GROSS_AMT');
  l_fee_1_desc           := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','FEE_1');
  l_disb_net_amt_desc    := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_NET_AMT');
  l_int_rebate_amt_desc  := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','INT_REBATE_AMT');
  l_disb_date_desc       := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','DISB_DATE');

  FOR lcur_db_resp IN cur_db_resp(l_dbth_id)
  LOOP  -- ## Open the Disb LOOP

     BEGIN

     l_mesg_str1      := NULL;
     l_mesg_str2      := NULL;
     l_mesg_str3      := NULL;
     l_disb_ack_date  := NULL;
     l_log_start_flag := FALSE;

     -- If the disbursement sequence number is between 60 and 100 then
     -- Store the values in a temparary PL/SQL table to print at the end
     IF (lcur_db_resp.disb_seq_num > 60 AND lcur_db_resp.disb_seq_num < 100) THEN

       l_disb_dtl_tab(1).p_disb_num     := lcur_db_resp.disb_num;
       l_disb_dtl_tab(1).p_disb_seq_num := lcur_db_resp.disb_seq_num;
       l_disb_dtl_tab(1).p_disb_date    := lcur_db_resp.transaction_date;
       l_disb_dtl_tab(1).p_disb_amount  := lcur_db_resp.disb_gross_amt;

       -- If disb_seq_num > 60 and < 91 then print under COD generated disbursements received section
       IF (lcur_db_resp.disb_seq_num > 60 AND lcur_db_resp.disb_seq_num < 91) THEN
         l_disb_dtl_tab(1).p_rec_type  := 'C';
       -- If disb_Seq_num > 90 and < 100 then print under Payment to Servicing Response Received section
       ELSIF (lcur_db_resp.disb_seq_num  > 90 AND lcur_db_resp.disb_seq_num < 100) THEN
         l_disb_dtl_tab(1).p_rec_type  := 'P';
       END IF;

     END IF;

     OPEN cur_awdisb(lcur_db_resp.loan_number,lcur_db_resp.disb_num,lcur_db_resp.disb_seq_num); -- ## Open the award Disb Loop
     FETCH cur_awdisb INTO lcur_awdisb;
     IF cur_awdisb%NOTFOUND THEN
          CLOSE cur_awdisb;          -- Bug 4101482 Cursor not closed
          fnd_message.set_name('IGF','IGF_DB_NO_AWARD_DTL');
          fnd_message.set_token('AWARD',lcur_db_resp.loan_number);
          fnd_message.set_token('DNUM',lcur_db_resp.disb_num);
          fnd_message.set_token('DSEQNUM',lcur_db_resp.disb_seq_num);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE SKIP_THIS_RECORD;

     END IF;

   -- ## Check if file type is Acknolwedgement

     IF l_dl_file_type = 'DL_DISB_ACK' THEN


        -- ## Check If already acknowledged
        IF lcur_awdisb.ack_date IS NULL THEN


           IF lcur_db_resp.disb_activity_status IS NOT NULL THEN

               log_start(lcur_db_resp.loan_number, lcur_db_resp.disb_num, lcur_db_resp.disb_seq_num);

               fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_DB_DL_REJ_CODES',
                                               LTRIM(RTRIM(SUBSTR(lcur_db_resp.disb_activity_status,1,2)))
                                               )
                                );
               fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_DB_DL_REJ_CODES',
                                               LTRIM(RTRIM(SUBSTR(lcur_db_resp.disb_activity_status,3,2)))
                                               )
                                );
               fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_DB_DL_REJ_CODES',
                                               LTRIM(RTRIM(SUBSTR(lcur_db_resp.disb_activity_status,5,2)))
                                               )
                                );
               fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_DB_DL_REJ_CODES',
                                               LTRIM(RTRIM(SUBSTR(lcur_db_resp.disb_activity_status,7,2)))
                                               )
                                );
           END IF;


           IF        lcur_db_resp.disb_activity_status IS NULL THEN
                     l_disb_status      := 'A';
                     l_disb_status_date := TRUNC(SYSDATE);
                     l_disb_ack_date    := lcur_db_resp.ack_date;
           ELSE
                     l_disb_status      := 'R';
                     l_disb_status_date := TRUNC(SYSDATE);
           END IF;


          -- ## Update the igf_aw_db_chg_dtls table with the disb status as Rejected
          -- ## and disb status date as current data

           IF     lcur_db_resp.loc_disb_gross_amt  IS NOT NULL
               OR lcur_db_resp.loc_fee_1           IS NOT NULL
               OR lcur_db_resp.loc_disb_net_amt    IS NOT NULL THEN

              --
              -- ## Compare If there is any difference exists between amt and fee fields
              -- ## in the tables like igf_aw_db_chg_dtls and igf_db_dl_disb_resp.If any
              -- ## difference exists then log it in the file.
              -- ## Below, NVL(,lcur_awdisb.field) is given so that, if the field in flat file
              -- ## is NULL, then it means that it matches with the values sent by the school.
              --

              IF NVL(lcur_db_resp.loc_disb_gross_amt,lcur_awdisb.disb_accepted_amt)  <> NVL(lcur_awdisb.disb_accepted_amt,0)
              OR NVL(lcur_db_resp.loc_fee_1,lcur_awdisb.orig_fee_amt)                    <> NVL(lcur_awdisb.orig_fee_amt,0)
              OR NVL(lcur_db_resp.loc_disb_net_amt,lcur_awdisb.disb_net_amt)      <> NVL(lcur_awdisb.disb_net_amt,0)  THEN


                 l_mesg_str1 := RPAD(' ',35);
                 l_mesg_str2 := RPAD(igf_aw_gen.lookup_desc('IGF_SL_GEN','LOC_DISB_DETAILS'),35);
                 l_mesg_str3 := RPAD(igf_aw_gen.lookup_desc('IGF_SL_GEN','OFA_DISB_DETAILS'),35);

                 l_mesg_str1 := l_mesg_str1 || LPAD(l_disb_gross_amt_desc,50);
                 l_mesg_str2 := l_mesg_str2 || LPAD(NVL(lcur_db_resp.loc_disb_gross_amt,''),50);
                 l_mesg_str3 := l_mesg_str3 || LPAD(lcur_awdisb.disb_accepted_amt,50);

                 l_mesg_str1 := l_mesg_str1 || LPAD(l_fee_1_desc,50);
                 l_mesg_str2 := l_mesg_str2 || LPAD(NVL(lcur_db_resp.loc_fee_1,''),50);
                 l_mesg_str3 := l_mesg_str3 || LPAD(lcur_awdisb.orig_fee_amt,50);

                 l_mesg_str1 := l_mesg_str1 || LPAD(l_disb_net_amt_desc,50);
                 l_mesg_str2 := l_mesg_str2 || LPAD(NVL(lcur_db_resp.loc_disb_net_amt,''),50);
                 l_mesg_str3 := l_mesg_str3 || LPAD(lcur_awdisb.disb_net_amt,50);

                 fnd_file.new_line(fnd_file.log,1);
                 fnd_file.put_line(fnd_file.log,l_mesg_str1);
                 fnd_file.put_line(fnd_file.log,l_mesg_str2);
                 fnd_file.put_line(fnd_file.log,l_mesg_str3);

              END IF;

           END IF;

            DECLARE

                 CURSOR c_tbh_cur IS
                 SELECT adcd.*,adcd.ROWID
                 FROM igf_aw_db_chg_dtls adcd
                 WHERE adcd.award_id     = lcur_awdisb.award_id
                   AND adcd.disb_num     = lcur_db_resp.disb_num
                   AND adcd.disb_seq_num = lcur_db_resp.disb_seq_num
                 FOR UPDATE OF adcd.award_id NOWAIT;

            BEGIN
                  FOR tbh_rec in c_tbh_cur LOOP

                    igf_aw_db_chg_dtls_pkg.update_row (
                      x_rowid                 => tbh_rec.ROWID,
                      x_award_id              => tbh_rec.award_id,
                      x_disb_num              => tbh_rec.disb_num,
                      x_disb_seq_num          => tbh_rec.disb_seq_num,
                      x_disb_accepted_amt     => tbh_rec.disb_accepted_amt,
                      x_orig_fee_amt          => tbh_rec.orig_fee_amt,
                      x_disb_net_amt          => tbh_rec.disb_net_amt,
                      x_disb_date             => tbh_rec.disb_date,
                      x_disb_activity         => tbh_rec.disb_activity,
                      x_disb_status           => l_disb_status,
                      x_disb_status_date      => l_disb_status_date,
                      x_disb_rel_flag         => tbh_rec.disb_rel_flag,
                      x_first_disb_flag       => tbh_rec.first_disb_flag,
                      x_interest_rebate_amt   => tbh_rec.interest_rebate_amt,
                      x_disb_conf_flag        => tbh_rec.disb_conf_flag,
                      x_pymnt_prd_start_date  => tbh_rec.pymnt_prd_start_date,
                      x_note_message          => tbh_rec.note_message,
                      x_batch_id_txt          => tbh_rec.batch_id_txt,
                      x_ack_date              => l_disb_ack_date,
                      x_booking_id_txt        => tbh_rec.booking_id_txt,
                      x_booking_date          => tbh_rec.booking_date,
                      x_mode                  => 'R');

                     END LOOP;
                END;
        END IF;


     -- ## If the file type is Booking then pick up the data from the igf_aw_db_chg_dtls
     -- ## and update the igf_aw_db_chg_dtls with the disb status as booked, booking batch id
     -- ## with the current batch ID and disb status date as current date

     ELSIF l_dl_file_type = 'DL_DISB_BOOK' THEN
       DECLARE

         CURSOR c_tbh_cur IS
         SELECT adcd.*, adcd.ROWID
         FROM igf_aw_db_chg_dtls adcd
         WHERE adcd.award_id     = lcur_awdisb.award_id
           AND adcd.disb_num     = lcur_db_resp.disb_num
           AND adcd.disb_seq_num = lcur_db_resp.disb_seq_num
         FOR UPDATE OF adcd.award_id NOWAIT;

         BEGIN

           FOR tbh_recss in c_tbh_cur LOOP

              igf_aw_db_chg_dtls_pkg.update_row (
                x_rowid                 => tbh_recss.ROWID,
                x_award_id              => tbh_recss.award_id,
                x_disb_num              => tbh_recss.disb_num,
                x_disb_seq_num          => tbh_recss.disb_seq_num,
                x_disb_accepted_amt     => tbh_recss.disb_accepted_amt,
                x_orig_fee_amt          => tbh_recss.orig_fee_amt,
                x_disb_net_amt          => tbh_recss.disb_net_amt,
                x_disb_date             => tbh_recss.disb_date,
                x_disb_activity         => tbh_recss.disb_activity,
                x_disb_status           => 'B',
                x_disb_status_date      => TRUNC(SYSDATE),
                x_disb_rel_flag         => tbh_recss.disb_rel_flag,
                x_first_disb_flag       => tbh_recss.first_disb_flag,
                x_interest_rebate_amt   => tbh_recss.interest_rebate_amt,
                x_disb_conf_flag        => tbh_recss.disb_conf_flag,
                x_pymnt_prd_start_date  => tbh_recss.pymnt_prd_start_date,
                x_note_message          => tbh_recss.note_message,
                x_batch_id_txt          => tbh_recss.batch_id_txt,
                x_ack_date              => l_disb_ack_date,
                x_booking_id_txt        => l_batch_id,
                x_booking_date          => lcur_db_resp.transaction_date,
                x_mode                  => 'R');

           END LOOP;
         END;
     END IF;


     -- ## Update the igf_db_dl_disb_resp table with the status as Y(Processed);


          igf_db_dl_disb_resp_pkg.update_row (
              x_mode                 => 'R',
              x_rowid                => lcur_db_resp.row_id,
              x_ddrp_id              => lcur_db_resp.ddrp_id,
              x_dbth_id              => lcur_db_resp.dbth_id,
              x_loan_number          => lcur_db_resp.loan_number,
              x_disb_num             => lcur_db_resp.disb_num,
              x_disb_activity        => lcur_db_resp.disb_activity,
              x_transaction_date     => lcur_db_resp.transaction_date,
              x_disb_seq_num         => lcur_db_resp.disb_seq_num,
              x_disb_gross_amt       => lcur_db_resp.disb_gross_amt,
              x_fee_1                => lcur_db_resp.fee_1,
              x_disb_net_amt         => lcur_db_resp.disb_net_amt,
              x_int_rebate_amt       => lcur_db_resp.int_rebate_amt,
              x_user_ident           => lcur_db_resp.user_ident,
              x_disb_batch_id        => lcur_db_resp.disb_batch_id,
              x_school_id            => lcur_db_resp.school_id,
              x_sch_code_status      => lcur_db_resp.sch_code_status,
              x_loan_num_status      => lcur_db_resp.loan_num_status,
              x_disb_num_status      => lcur_db_resp.disb_num_status,
              x_disb_activity_status => lcur_db_resp.disb_activity_status,
              x_trans_date_status    => lcur_db_resp.trans_date_status,
              x_disb_seq_num_status  => lcur_db_resp.disb_seq_num_status,
              x_loc_disb_gross_amt   => lcur_db_resp.loc_disb_gross_amt,
              x_loc_fee_1            => lcur_db_resp.loc_fee_1,
              x_loc_disb_net_amt     => lcur_db_resp.loc_disb_net_amt,
              x_servicer_refund_amt  => lcur_db_resp.servicer_refund_amt,
              x_loc_int_rebate_amt   => lcur_db_resp.loc_int_rebate_amt,
              x_loc_net_booked_loan  => lcur_db_resp.loc_net_booked_loan,
              x_ack_date             => lcur_db_resp.ack_date,
              x_affirm_flag          => lcur_db_resp.affirm_flag,
              x_status               =>'Y' );
    CLOSE cur_awdisb;

   EXCEPTION
   WHEN SKIP_THIS_RECORD THEN
        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);
   END;

   END LOOP; -- ## End Loop of Disb Loop

   COMMIT;

   -- Print the disbursment details of 'COD generated disbursements received' in the log file
   fnd_message.set_name('IGF','IGF_SL_DL_DB_COD_DISB');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   FOR l_disb_count IN 1 .. l_disb_dtl_tab.COUNT LOOP

     IF l_disb_dtl_tab(l_disb_count).p_rec_type = 'C' THEN
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_num_desc      ,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_num));
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_seq_num_desc  ,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_seq_num));
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_date_desc     ,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_date));
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_gross_amt_desc,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_amount));
     END IF;

   END LOOP;

   -- Print the disbursment details of 'Payment to Servicing Response Received' in the log file
   fnd_message.set_name('IGF','IGF_SL_DL_DB_PYMN_SRVC');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   FOR l_disb_count IN 1 .. l_disb_dtl_tab.COUNT LOOP

     IF l_disb_dtl_tab(l_disb_count).p_rec_type = 'P' THEN
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_num_desc      ,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_num));
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_seq_num_desc  ,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_seq_num));
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_date_desc     ,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_date));
       fnd_file.put_line(fnd_file.log,RPAD(l_disb_gross_amt_desc,50)||' : '||TO_CHAR(l_disb_dtl_tab(l_disb_count).p_disb_amount));
     END IF;

   END LOOP;

 EXCEPTION

    WHEN app_exception.record_lock_exception THEN

       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       igs_ge_msg_stack.conc_exception_hndl;

    WHEN FILE_NOT_LOADED THEN

       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_FILE_NOT_LOADED');
       igs_ge_msg_stack.conc_exception_hndl;

    WHEN INVALID_PHASE_IN_PARTICIPANT THEN

       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_SL_COD_NO_DISB_ACK');
       igs_ge_msg_stack.conc_exception_hndl;

    WHEN OTHERS THEN

       IF cur_awdisb%ISOPEN THEN
          CLOSE cur_awdisb;
       END IF;
       ROLLBACK;

       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       fnd_file.put_line(fnd_file.log,SQLERRM);
       igs_ge_msg_stack.conc_exception_hndl;

END disb_ack;

END igf_db_dl_orig_ack;

/
