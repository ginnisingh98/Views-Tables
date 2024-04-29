--------------------------------------------------------
--  DDL for Package Body IGF_DB_DL_DISB_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_DL_DISB_ORIG" AS
/* $Header: IGFDB02B.pls 120.1 2006/02/01 02:41:33 ridas noship $ */


  /*************************************************************
   Created By : prchandr
   Date Created On : 2000/12/13
   Purpose : Direct Loan Disbursement Origination Process
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
  (reverse chronological order - newest change first)
  ayedubat        20-OCT-2004     FA 149 COD-XML Standards build bug # 3416863
                                  Replaced the reference of igf_db_awd_disb_dtl with igf_aw_db_chg_dtls table
                                  Changed the logic as per the TD, FA149_TD_COD_XML_i1a.doc
  veramach        29-Jan-2004     bug 3408092 added 2004-2005 in p_dl_version checks
  ugummall        23-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  Modified the cursor cur_disb_dtl to include the clause which
                                  filter only the loans having the school id matched with parameter p_school_code.
  ugummall        17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  1. Added two new parameters to disb_originate process.
                                  2. Hence added one parameter to Trans_Rec internal procedure
                                     which is being called from disb_originate process.
  sjadhav         28-Mar-2003     Bug 2863960
                                  Added cursor cur_get_prev_date
                                  Added clause for reading date
                                  adjustment records into file

  vvutukur        21-Feb-2003     Enh#2758823.FA117 Build. Modified procedure Trans_Rec.
  ***************************************************************/

-- ## Forward Declaration of Trans_rec Procedure

lv_data_record    VARCHAR2(4000);   --  ##  Variable to store the concatenated value to be stored in file ##

PROCEDURE Trans_Rec( p_dl_version             igf_lookups_view.lookup_code%TYPE,
                     p_dl_batch_id            igf_sl_dl_batch.batch_id%TYPE,
                     p_Rec_count              IN OUT NOCOPY   NUMBER,
                     p_ci_cal_type            igf_sl_dl_setup.ci_cal_type%TYPE,
                     p_ci_sequence_number     igf_sl_dl_setup.ci_sequence_number%TYPE,
                     p_school_code          IN    VARCHAR2
                    );

PROCEDURE disb_originate(errbuf      OUT NOCOPY    VARCHAR2,
                         retcode      OUT NOCOPY     NUMBER,
                         p_award_year     VARCHAR2,
                         p_org_id     IN  NUMBER,
                         school_type   IN    VARCHAR2,
                         p_school_code IN    VARCHAR2
                        )
AS
  /*************************************************************
   Created By : prchandr
  Date Created On : 2000/12/13
  Purpose : Main Procedure for the Direct Loan disbursement process
  Know limitations, enhancements or remarks
  Who             When            What
  ugummall        23-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  Modified the cursor cur_disb_dtl to include the clause which
                                  filter only the loans having the school id matched with parameter p_school_code.
  ugummall        17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  1. Added two new parameters
                                  2. p_school_code parameter is passed as extra parameter to
                                     procedures igf_sl_dl_record.DLHeader_cur and Trans_Rec.
                                  3. Logic is changed so that header and trailer are written to the
                                     output file only when at least one record is processed.
  Bug :2383350 Loan Cancellation
  Who             When            What
  mesriniv      4-jun-2002      Removed SF_STATUS <> 'E' check in the two cursors
                                cur_disb_dtl
  Bug:2255281
  Desc:DL VERSION TO BE CHECKED FOR DL CHANGE ORIG AND DISB ORIGINATION LOAN PROGRAMS
  Who             When            What
  mesriniv        22-mar-2002     Modified cur_disb_dtl to pick up
                                  Disbursements for future and also posted to Student A/C

  (reverse chronological order - newest change first)
  ***************************************************************/

   l_cod_year_flag   BOOLEAN;
   lv_cal_type       igs_ca_inst.cal_type%TYPE;                  -- ##  Used for the award year ##
   lv_cal_seq_num    igs_ca_inst.sequence_number%TYPE;           -- ##  Both cal_seq_num and cal_type forms the award year ##
   lv_dl_version     igf_lookups_view.lookup_code%TYPE;          -- ##  Variable for the storing the version number ##
   lv_batch_id       igf_sl_dl_batch.batch_id%TYPE;              -- ##  Variable to have the batch ID ##
   lv_dbth_id        igf_sl_dl_batch.dbth_id%TYPE;
   lv_mesg_class     igf_sl_dl_batch.message_class%TYPE;

    -- ## REF Cursor Record Types.

   Header_Rec        igf_sl_dl_record.DLHeaderType;
   Trailer_Rec       igf_sl_dl_record.DLTrailerType;

   lv_dl_loan_catg   igf_lookups_view.lookup_code%TYPE;
   p_rec_count       NUMBER := 0;

   no_disb_data      EXCEPTION;  -- ## User Define Exception to check if any records to Originate.

   -- ## Cursor to check If any records is there to originate. If no records exists
   -- ## then header file should not be created and a suitable user definede exception
   -- ## is fired else the file is created.

   --SF Status is changed to P( Posted into Student A/C)
   --Removed the check for Invoice Number being not null
   --If a positive adjustment is done Invoice Number is NULL and credit id will be upadted by the
   --student finance integration process.
   --If a negative adjustment is done  Invoice Number is NOT NULL and
   --Credit ID will be null
   --So we consider only SF Status as P

   CURSOR cur_disb_dtl(lv_ci_cal_type igs_ca_inst.cal_type%TYPE,
                       lv_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
        SELECT  '1'
        FROM igf_aw_db_chg_dtls adtlv,
             igf_aw_award awd,
             igf_sl_loans lar,
             igf_ap_fa_base_rec fabase
        WHERE   -- ## Pick up all records with SF Status 1)"to be Posted" and Pick up Disbursements with Future dates and within 7 Future days,
                --    "Posted" to Student Account.
              adtlv.disb_date-TRUNC(SYSDATE) <=7
        AND   adtlv.disb_status         = 'G'           -- ## With Disbursement Status as Ready to Send
        AND   adtlv.award_id            = awd.award_id
        AND   adtlv.award_id            = lar.award_id
        AND   awd.base_id               = fabase.base_id
        AND   fabase.ci_cal_type        = lv_ci_cal_type
        AND   fabase.ci_sequence_number = lv_ci_sequence_number
        AND   substr(lar.loan_number, 13, 6) = p_school_code;

   --Cursor to fetch the minimum disbursement number for an award.

     lcur_disb_dtl       cur_disb_dtl%ROWTYPE;
     l_year              VARCHAR2(80);
     l_para              VARCHAR2(80);
     l_alternate_code    igs_ca_inst.alternate_code%TYPE;

   -- Get the details of school meaning from lookups to print in the log file
   CURSOR c_get_sch_code IS
     SELECT meaning
       FROM igs_lookups_view
      WHERE lookup_type = 'OR_SYSTEM_ID_TYPE'
        AND lookup_code = 'DL_SCH_CD'
        AND enabled_flag = 'Y';
    c_get_sch_code_rec c_get_sch_code%ROWTYPE;

   BEGIN
     igf_aw_gen.set_org_id(p_org_id);

     retcode := 0;
     l_year := igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
     l_para := igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS');

     lv_cal_type    := rtrim(substr(p_award_year,1,10));
     lv_cal_seq_num := rtrim(substr(p_award_year,11));

     -- Check wether the awarding year is COD-XML processing Year or not
     l_cod_year_flag  := NULL;
     l_cod_year_flag := igf_sl_dl_validation.check_full_participant (lv_cal_type, lv_cal_seq_num,'DL');

     -- If the award year is FULL_PARTICIPANT then raise the error message and stop processing
     -- else continue the process
     IF l_cod_year_flag THEN

       fnd_message.set_name('IGF','IGF_SL_COD_NO_DISB_ORIG');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       RETURN;

     END IF;

     l_alternate_code:=igf_gr_gen.get_alt_code(lv_cal_type,lv_cal_seq_num);

     OPEN c_get_sch_code; FETCH c_get_sch_code INTO c_get_sch_code_rec; CLOSE c_get_sch_code;

     --Show the parameters Passed
     fnd_file.put_line(fnd_file.log,RPAD(l_para,50,' '));
     fnd_file.put_line(fnd_file.log,RPAD(l_year,50,' ')||':'||RPAD(' ',4,' ')||l_alternate_code);
     fnd_file.put_line(fnd_file.log,RPAD(c_get_sch_code_rec.meaning,50,' ')||':'||RPAD(' ',4,' ')||p_school_code);
     fnd_file.put_line(fnd_file.log,' ');

     -- Get the Direct Loan File Spec Version
     BEGIN
       lv_dl_version := igf_sl_gen.get_dl_version(lv_cal_type, lv_cal_seq_num);
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       fnd_message.set_name('IGF','IGF_DB_DL_VERSION_FALSE');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       RAISE NO_DATA_FOUND;
     END;

     -- Initialise the Data Record field
     lv_data_record := NULL;

     /************************************************************************
             Using REF CURSORS.
             Header Record specifications, for each Direct Loan Version
             is specified in the igf_sl_dl_record.DLHeader_cur procedure.
             By calling this procedure, the following are done
               1. Computes Batch ID
               2. Inserts the Batch ID details in igf_sl_dl_batch
               3. For the specified version, Opens a REF CURSOR, having
                  header file Specs.
      *************************************************************************/

     OPEN cur_disb_dtl(lv_cal_type,lv_cal_seq_num);
     FETCH cur_disb_dtl INTO lcur_disb_dtl;

     IF cur_disb_dtl%NOTFOUND THEN
       --Obseleted message IGF_NO_DL_DISB_DATA_ORIG as it does not comply standards.
       --Added a new message.
       fnd_message.set_name('IGF','IGF_DB_DLDISB_NOTORIG');
       fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
       CLOSE cur_disb_dtl;
       RAISE no_disb_data;
     END IF;

     lv_dl_loan_catg := 'DL';
     igf_sl_dl_record.DLHeader_cur(lv_dl_version,
                                  lv_dl_loan_catg,
                                  lv_cal_type,
                                  lv_cal_seq_num,
                                  'DL_DISB_SEND',
                                  p_school_code,
                                  lv_dbth_id,
                                  lv_batch_id,
                                  lv_mesg_class,
                                  Header_Rec);

     FETCH Header_Rec into lv_data_record;

     IF Header_Rec%NOTFOUND THEN
       fnd_message.set_name ('IGF', 'IGF_GE_HDR_CREATE_ERROR');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;

     -- Write the Header Record into the Output file.
     -- fnd_file.put_line(FND_FILE.OUTPUT, lv_data_record);
     -- The above line(code) commented here and is being used in the trans_rec procedure
     -- as the header record is created if there exists a valid transaction
     -- record to process

     --Formulating the Transaction Record
     --Calls a Procedure to create a Transaction record in the File.
      Trans_Rec(lv_dl_version,
                lv_batch_id,
                p_Rec_count,
                lv_cal_type,
                lv_cal_seq_num,
                p_school_code);


     -- Initialise the Data Record field
     lv_data_record := NULL;

     -- process the trailer record only if atleast one transaction record has been processed
     IF(p_Rec_count > 0)THEN
     -- Write the Trailer Record
       igf_sl_dl_record.DLTrailer_cur(lv_dl_version, p_Rec_count,Trailer_Rec);
       FETCH Trailer_Rec into lv_data_record;
       IF Trailer_Rec%NOTFOUND THEN
         fnd_message.set_name ('IGF', 'IGF_GE_TRL_CREATE_ERROR');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
       END IF;
       -- Write the Trailer Record into the Output file
       fnd_file.put_line(FND_FILE.OUTPUT, lv_data_record);

       --Display message that DL Disb Records are originated.See output File.
       fnd_file.put_line(fnd_file.log,' ');
       fnd_message.set_name('IGF','IGF_DB_DL_DISB_ORIG');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
     ELSE
       FND_MESSAGE.SET_NAME('IGF','IGF_AP_TOTAL_RECS');
       FND_MESSAGE.SET_TOKEN('COUNT', p_Rec_count);
       FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
     END IF;
     COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN no_disb_data THEN
    ROLLBACK;
    retcode := 0;
    errbuf  := NULL;
  WHEN app_exception.record_lock_exception THEN
    ROLLBACK;
    retcode := 2;
    errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END disb_originate;

PROCEDURE trans_rec( p_dl_version           igf_lookups_view.lookup_code%TYPE,
                     p_dl_batch_id          igf_sl_dl_batch.batch_id%TYPE,
                     p_rec_count            IN OUT NOCOPY NUMBER,
                     p_ci_cal_type          igf_sl_dl_setup.ci_cal_type%TYPE,
                     p_ci_sequence_number   igf_sl_dl_setup.ci_sequence_number%TYPE,
                     p_school_code        IN    VARCHAR2 )
AS
  /*************************************************************
  Created By : prchandr
  Date Created On : 2000/12/19
  Purpose : To create the Transaction Record
  Know limitations, enhancements or remarks
  Change History:
  Bug 2438434.Incorrect Format in Output File.
  Who             When            What
  ugummall        23-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  Modified the cursor cur_disb_dtl to include the clause which
                                  filter only the loans having the school id matched with parameter p_school_code.
  ugummall        17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  1. Logic is changed so that it processes for only those students whose associated
                                     Org Unit has an alternate identifier for Direct Loan School Code matching with
                                     the supplied parameter p_school_code(instead of school_id picked from igf_sl_dl_setup table)
                                  2. school_id is removed from the cursor cur_school and its references are replaced with the
                                     supplied parameter p_school_code.
  vvutukur        25-Feb-2003     Enh#2758823.FA117 Build. Modified the if condition to include 03-04 removing 02-03.
                                  ie., Changed IF p_dl_version IN ('2001-2002','2002-2003') to IF p_dl_version IN ('2002-2003','2003-2004').
                                  Also added new cursor cur_min_disb_num used the min. disb.num of the award to log details
                                  in column number 129 in the output file. In when others section exception section, NOTFOUND is changed to ISOPEN
                                  to close a cursor is still open.
  mesriniv        1-jul-2002      LPAD with 0 for Amount Fields
  Bug:2255281
  Desc:DL VERSION TO BE CHECKED FOR DL CHANGE ORIG AND DISB ORIGINATION LOAN PROGRAMS
  Who             When            What
  mesriniv        22-mar-2002     Added Check for 2002-2003
                                  Modified cur_disb_dtl to pick up
                                  Disbursements for future and also posted to Student A/C

  (reverse chronological order - newest change first)
  ***************************************************************/


 l_Trans_Rec               VARCHAR2(4000)  := NULL; -- ## Variable to store the Disbursement Detail Record
 l_Rec_count               NUMBER          := 0;    -- ## Variable to store the Record Count
 l_orig_fee_perct_stafford igf_sl_dl_setup.orig_fee_perct_stafford%TYPE;
 l_orig_fee_perct_plus     igf_sl_dl_setup.orig_fee_perct_plus%TYPE;
 l_int_rebate_amt          igf_aw_awd_disb.fee_1%TYPE;     -- This field's data type is similar to Fees.

-- ## Cursor to Retrieve the disbursements being credited to the Students Account

 CURSOR cur_disb_dtl IS
        SELECT  adtlv.*, fabase.base_id, lar.loan_number
        FROM igf_aw_db_chg_dtls adtlv,
             igf_aw_award awd,
             igf_sl_loans lar,
             igf_ap_fa_base_rec fabase
        WHERE
             adtlv.disb_date-TRUNC(SYSDATE) <=7
        AND   adtlv.disb_status         = 'G'           -- ## With Disbursement Status as Ready to Send
        AND   adtlv.award_id            = awd.award_id
        AND   adtlv.award_id            = lar.award_id
        AND   awd.base_id               = fabase.base_id
        AND   fabase.ci_cal_type        = p_ci_cal_type
        AND   fabase.ci_sequence_number = p_ci_sequence_number
        AND   substr(lar.loan_number, 13, 6) = p_school_code
        ORDER BY adtlv.disb_num, adtlv.disb_seq_num;

 -- ## Cursor to Retrieve the School ID for a Particular Award Year.
 -- ## by ugummall. school_id is removed as it is being obsoleted w.r.t. FA 126.
 -- ## Supplied parameter p_school_id is used instead of school_id.
 CURSOR cur_school IS
        SELECT orig_fee_perct_stafford, orig_fee_perct_plus FROM igf_sl_dl_setup
        WHERE  ci_cal_type         = p_ci_cal_type
        AND    ci_sequence_number  = p_ci_sequence_number;

 -- Cursor to get the Fed Fund code for the specified award.
 CURSOR cur_fund_details(p_award_id igf_aw_award_all.award_id%TYPE) IS
        SELECT awd.fund_id, fcat.fed_fund_code
        FROM   igf_aw_fund_mast fmast,
               igf_aw_fund_cat  fcat,
               igf_aw_award awd
        WHERE awd.award_id    = p_award_id
        AND   awd.fund_id     = fmast.fund_id
        AND   fmast.fund_code = fcat.fund_code;

 CURSOR cur_min_disb_num (cp_award_id igf_aw_award_all.award_id%TYPE) IS
   SELECT MIN(disb_num)
   FROM   igf_aw_awd_disb
   WHERE  award_id = cp_award_id;


   CURSOR cur_get_prev_date (cp_award_id      igf_aw_db_chg_dtls.award_id%TYPE,
                             cp_disb_num      igf_aw_db_chg_dtls.disb_num%TYPE,
                             cp_disb_seq_num  igf_aw_db_chg_dtls.disb_seq_num%TYPE)
   IS
   SELECT disb_date
   FROM   igf_aw_db_chg_dtls
   WHERE  award_id     = cp_award_id
     AND  disb_num     = cp_disb_num
     AND  disb_seq_num = cp_disb_seq_num;

   ld_date             igf_aw_db_chg_dtls.disb_date%TYPE;
   l_min_disb_num      igf_aw_db_chg_dtls.disb_num%TYPE;

   lcur_disb_dtl       cur_disb_dtl%ROWTYPE; -- ## Cursor Type for the Disb Cursor
   lcur_fund_dtl       cur_fund_details%ROWTYPE;
   lcur_fund_dtl_temp  cur_fund_details%ROWTYPE;


BEGIN
  -- ## Loop to Get the School ID
  OPEN cur_school;
  FETCH cur_school INTO l_orig_fee_perct_stafford, l_orig_fee_perct_plus;
  IF cur_school%NOTFOUND THEN
    CLOSE cur_school;
    fnd_message.set_name ('IGF', 'IGF_SL_NO_DL_SETUP');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE cur_school;

  OPEN cur_disb_dtl; -- ## Open the Cursor
  -- ## Check for the DL Version and according to fetch the
  -- ## Disbursements detail records and Store it in a variable
  -- ## to be put in a file

  IF p_dl_version  IN ('2002-2003','2003-2004','2004-2005') THEN
    LOOP
      FETCH cur_disb_dtl INTO lcur_disb_dtl;
      EXIT WHEN cur_disb_dtl%NOTFOUND;

          -- Calculate the Interest Rebate Amt, for this set of disbursement figures
          lcur_fund_dtl := lcur_fund_dtl_temp;
          l_int_rebate_amt := 0;

          OPEN cur_fund_details(lcur_disb_dtl.award_id);
          FETCH cur_fund_details INTO lcur_fund_dtl;
          CLOSE cur_fund_details;

          --Interest Rebate = Net Disb Amt - (Gross Disb- Loan Fee)
          --Loan Fee Amount = orig fee perct (PLUS or STAFFORD) * Gross Disb
          --Using this Formula the Interest Rebate Amount was being calculated.
          --Since this interest rebate amount is available in the IGF_AW_AWD_DISB
          --we can make use of the same instead of re-calculating here.
          --Hence removing code which calculated the value and using same from IGF_AW_AWD_DISB.

          l_int_rebate_amt := lcur_disb_dtl.interest_rebate_amt;

          l_Trans_Rec  :=  RPAD(NVL(lcur_disb_dtl.loan_number,' '),21) ||
                           LPAD(NVL(TO_CHAR(lcur_disb_dtl.disb_num),'0'),2,'0') ||
                           NVL(lcur_disb_dtl.disb_activity,' ');

          -- ## Check if disb activity is Actual Disbursement(D) or
          -- ## Adjusted Disbursement(A) then send the SF Status Date
          -- If Adjusted Disbursement Date (Q) then send the new disbursement date

          --Made a specific check for 'D' and 'A' as per FACR007

          IF lcur_disb_dtl.disb_activity IN ('D','A') THEN
            l_Trans_Rec :=   l_Trans_Rec
                            || RPAD( NVL( TO_CHAR(lcur_disb_dtl.disb_status_date,'YYYYMMDD'), ' '),8);

          ELSIF lcur_disb_dtl.disb_activity ='Q' THEN
            l_Trans_Rec :=   l_Trans_Rec
                             || RPAD( NVL( TO_CHAR(lcur_disb_dtl.disb_date,'YYYYMMDD'), ' '),8);
          ELSE
            l_Trans_Rec := l_Trans_Rec || RPAD(' ',8);
          END IF;

          -- ## Add the disbursement Sequence Number
          l_Trans_Rec := l_Trans_Rec || LPAD(NVL(TO_CHAR(lcur_disb_dtl.disb_seq_num),'0'),2,'0');

          -- ## Check if the disb activity is Ajusted Disbursement(A) then
          -- ## Add the gross amt else sent blank

          --LPAD  with 0 for amount fields as per Bug 2438434
          IF lcur_disb_dtl.disb_activity IN ('D','A') THEN
            l_Trans_Rec := l_Trans_Rec || LPAD(NVL(TO_CHAR(lcur_disb_dtl.orig_fee_amt)    ,'0'),5,'0')
                                         || LPAD(NVL(TO_CHAR(lcur_disb_dtl.orig_fee_amt)  ,'0'),5,'0')
                                         || LPAD(NVL(TO_CHAR(lcur_disb_dtl.disb_net_amt)  ,'0'),5,'0')
                                         || LPAD(NVL(TO_CHAR(l_int_rebate_amt)            ,'0'),5,'0');

          ELSE
            l_Trans_Rec := l_Trans_rec||LPAD(' ',5)
                                        ||LPAD(' ',5)
                                        ||LPAD(' ',5)
                                        ||RPAD(' ',5);
          END IF;

          -- ## Add 9 spaces including Filler ,and batch ID
          l_Trans_Rec := l_Trans_Rec || RPAD(' ',9)
                                      || RPAD(NVL(p_dl_batch_id,' '),23);


          l_Trans_Rec := l_Trans_Rec ||RPAD(NVL(p_school_code,' '),6)
                                         ||RPAD(' ',1)
                                         ||RPAD(' ',1)
                                         ||RPAD(' ',1) -- Totally 3 Filler
                                         ||RPAD(' ',10)
                                         ||RPAD(' ',1)
                                         ||RPAD(' ',1)
                                         ||LPAD(' ',5)
                                         ||LPAD(' ',5)
                                         ||LPAD(' ',5)
                                         ||LPAD(' ',6);


          -- ##  Check if disbursement Number is 1 and it is the first actual disbursement then
          -- ##  Send F (first disbursement required)

          OPEN cur_min_disb_num(lcur_disb_dtl.award_id);
          FETCH cur_min_disb_num INTO l_min_disb_num;
          CLOSE cur_min_disb_num;

          IF (lcur_disb_dtl.disb_num = l_min_disb_num AND l_min_disb_num > 1 AND lcur_disb_dtl.disb_seq_num = 1) THEN
             l_Trans_Rec := l_Trans_Rec ||'F';
          ELSE
             l_Trans_Rec := l_Trans_Rec || RPAD(' ',1);
          END IF;

          l_Trans_Rec := l_Trans_Rec || LPAD(' ',5)
                                        || LPAD(' ',4)
                                        || LPAD(' ',5);

          -- ## Check if the disb activity is Ajusted Disbursement Date(Q) then
          -- ## Add the gross adjusted amt

          IF lcur_disb_dtl.disb_activity = 'Q' THEN

          --
          -- here we should put the previous adjustment date
          --
             OPEN  cur_get_prev_date(lcur_disb_dtl.award_id,
                                     lcur_disb_dtl.disb_num,
                                     lcur_disb_dtl.disb_seq_num - 1);
             FETCH cur_get_prev_date INTO ld_date;
             CLOSE cur_get_prev_date;

             l_Trans_Rec :=    l_Trans_Rec
                            || LPAD( NVL( TO_CHAR(ld_date,'YYYYMMDD'),' '),8);
          ELSE
             l_Trans_Rec := l_Trans_Rec || LPAD(' ',8);
          END IF;

          -- ## Check if the disb activity is Ajusted Disbursement(A) then
          -- ## Add the Affirm Flag else sent blank

          IF lcur_disb_dtl.disb_activity IN ('D','A') THEN
             l_Trans_Rec := l_Trans_Rec || RPAD(NVL(lcur_disb_dtl.disb_conf_flag,' '),1);
          ELSE
             l_Trans_Rec := l_Trans_Rec || RPAD(' ',1);
          END IF;

          l_Rec_count := l_Rec_count + 1;  -- ## Increment the Record Count
          -- ## Write the header to file only first time
          IF (l_Rec_count = 1) THEN
            fnd_file.put_line(FND_FILE.OUTPUT, lv_data_record);
          END IF;
          fnd_file.put_line(FND_FILE.OUTPUT, l_Trans_Rec); -- ## Write the Transaction Record to file

          -- ## Update the igf_aw_db_chg_dtls table with the disb_status as sent
          -- ## , disb_status_date as sysdate and disb_batch_id as current batch id
          -- ## for each award ID,disbnum and disb_seq_num.

          DECLARE

            CURSOR c_tbh_cur IS
              SELECT igf_aw_db_chg_dtls.*,igf_aw_db_chg_dtls.ROWID
                FROM igf_aw_db_chg_dtls
               WHERE award_id     = lcur_disb_dtl.award_Id
                 AND disb_num     = lcur_disb_dtl.disb_num
                 AND disb_seq_num = lcur_disb_dtl.disb_seq_num
                 FOR UPDATE OF award_Id NOWAIT;
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
                x_disb_status           => 'S',
                x_disb_status_date      => TRUNC(SYSDATE),
                x_disb_rel_flag         => tbh_rec.disb_rel_flag,
                x_first_disb_flag       => tbh_rec.first_disb_flag,
                x_interest_rebate_amt   => tbh_rec.interest_rebate_amt,
                x_disb_conf_flag        => tbh_rec.disb_conf_flag,
                x_pymnt_prd_start_date  => tbh_rec.pymnt_prd_start_date,
                x_note_message          => tbh_rec.note_message,
                x_batch_id_txt          => p_dl_batch_Id,
                x_ack_date              => tbh_rec.ack_date,
                x_booking_id_txt        => tbh_rec.booking_id_txt,
                x_booking_date          => tbh_rec.booking_date,
                x_mode                  => 'R');

            END LOOP;
          END;
    END LOOP;  -- ## OUter End Loop
    p_Rec_count := l_Rec_count;
    CLOSE cur_disb_dtl; -- ## Close The cursor.
  END IF;   --end of version check

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
WHEN app_exception.record_lock_exception THEN
   IF cur_disb_dtl%ISOPEN THEN
     CLOSE cur_disb_dtl;
   END IF;
   IF cur_school%ISOPEN THEN
     CLOSE cur_school;
   END IF;
   RAISE;

WHEN OTHERS THEN
   IF cur_disb_dtl%ISOPEN THEN
     CLOSE cur_disb_dtl;
   END IF;
   IF cur_school%ISOPEN THEN
     CLOSE cur_school;
   END IF;
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_DB_DL_DISB_ORIG.TRANS_REC');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END trans_rec;
END igf_db_dl_disb_orig;

/
