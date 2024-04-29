--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_CHG_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_CHG_ORIG" AS
/* $Header: IGFSL05B.pls 120.1 2006/04/19 08:40:35 bvisvana noship $ */

--
---------------------------------------------------------------------------------------
--
-- Procedure chg_originate :
--
-- User inputs are
-- Award year (required) : Consists of Cal_type and sequence_number concatenated
-- LOAN_CATEGORY         : Valid values are DL_STAFFORD/DL_PLUS.
--
---------------------------------------------------------------------------------------
-- Change History:
---------------------------------------------------------------------------------------
-- Who          When            What
-----------------------------------------------------------------------------------
-- veramach     04-May-2004     bug 3603289
--                              Modified cursor cur_student_licence to select
--                              dependency_status from ISIR. other details are
--                              derived from igf_sl_gen.get_person_details.
-----------------------------------------------------------------------------------
-- veramach        29-Jan-2004     bug 3408092 added 2004-2005 in p_dl_version checks
-----------------------------------------------------------------------------------
-- ugummall   23-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
--                             Modified the cursor c_lor to include the clause which filter only
--                             the loans having the school id matched with parameter p_school_code.
---------------------------------------------------------------------------------------
-- ugummall    17-OCT-2003      Bug 3102439. FA 126 Multiple FA Offices.
--                              1. Added two new parameters to chg_originate process.
--                              2. Passed the parameter p_school_code to DLHeader_cur
--                                 as extra parameter
--                              3. Processed only those students whose associated org unit
--                                 has an alternate identifier of Direct Loan School Code and it
--                                 is matching with the supplied p_school_code parameter.
---------------------------------------------------------------------------------------
-- sjadhav     14-Oct-2003      Bug 3104228 Removed ref to obsolete columns
---------------------------------------------------------------------------------------
-- bkkumar     07-oct-2003      Bug 3104228 FA 122 Loan Enhancemtns
--                              a) Changed the cursor c_lor
--                                 containing igf_sl_lor_dtls_v with simple
--                                 joins and got the details of student and parent
--                                 from igf_sl_gen.get_person_details.
--                                 Added the debugging log messages.
--                              b) The DUNS_BORW_LENDER_ID,
--                                 DUNS_GUARNT_ID,
--                                 DUNS_LENDER_ID,
--                                 DUNS_RECIP_ID columns are osboleted from the
--                                 igf_sl_lor_loc_all table.
---------------------------------------------------------------------------------------
-- sjadhav      26-Mar-2003     Bug 2863960
--                              lcur_award.disb_gross_amt replaced with
--                              lcur_award.disb_accepted_amt as accepted amount is the
--                              gross amount
---------------------------------------------------------------------------------------
-- vvutukur     21-Feb-2003     Enh#2758823.FA117 Build. Modified procedure Trans_Rec.
---------------------------------------------------------------------------------------
--
-- ## Forward Declaration of Trans_rec Procedure

PROCEDURE Trans_Rec( p_dl_version           igf_lookups_view.lookup_code%TYPE,
                     p_dl_dbth_id           igf_sl_dl_batch.dbth_id%TYPE,
                     p_dl_batch_id          igf_sl_dl_batch.batch_id%TYPE,
                     p_tot_rec_count        IN OUT NOCOPY NUMBER);

PROCEDURE chg_originate(errbuf  OUT NOCOPY    VARCHAR2,
                       retcode OUT NOCOPY     NUMBER,
                       p_award_year    VARCHAR2,
                       p_dl_loan_catg  igf_lookups_view.lookup_code%TYPE,
                       p_org_id IN     NUMBER,
                       school_type    IN    VARCHAR2,
                       p_school_code  IN    VARCHAR2
                       )
AS
  /*************************************************************
   Created By : prchandr
  Date Created On : 2000/12/13
  Purpose : Main Procedure for the Direct Loan change process
  Know limitations, enhancements or remarks
  Change History:
  Who             When            What
  bvisvana       10-Apr-2006      Build FA 161.
                                  TBH Impact change in igf_sl_lor_loc_pkg.update_row()
  Bug No:2332668 Desc:LOAN ORIGINATION PROCESS NOT RUNNING SUCCESSFULLY.
  Who             When            What
  mesriniv        23-APR-2002     Added code to display the Parameters Passed

  Bug :- 2255281
  Desc:- DL Version Change
  Who             When            What
  mesriniv        20-MAR-2002     Added Code to SKIP LOAN when an error occurs

  Who             When            What
  agairola        19-Mar-2002     Modifed the update row call of the IGF_SL_LOANS_PKG to include
                                  Borrower determination as part of Refunds DLD - 2144600


  (reverse chronological order - newest change first)
  ***************************************************************/

   lv_cal_type       igs_ca_inst.cal_type%TYPE;               -- ##  Used for the award year ##
   lv_cal_seq_num    igs_ca_inst.sequence_number%TYPE;        -- ##  Both cal_seq_num and cal_type forms the award year ##
   lv_dl_version     igf_lookups_view.lookup_code%TYPE;          -- ##  Variable for the storing the version number ##
   lv_batch_id       igf_sl_dl_batch.batch_id%TYPE;              -- ##  Variable to have the batch ID ##
   lv_dbth_id        igf_sl_dl_batch.dbth_id%TYPE;
   lv_mesg_class     igf_sl_dl_batch.message_class%TYPE;
   lv_begin_date     igf_sl_lor_loc.acad_yr_begin_date %TYPE;    -- ##  Variable to have the academic begin date ##
   lv_end_date       igf_sl_lor_loc.acad_yr_end_date%TYPE;       -- ##  Variable to have the academic end date ##

  --Bug No:2332668
   l_i               NUMBER(1);
   l_alternate_code  igs_ca_inst.alternate_code%TYPE;
   l_display        VARCHAR2(1) := 'N';

   TYPE l_parameters IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
   l_para_rec l_parameters;

   SKIP_LOAN         EXCEPTION;
   yr_full_participant  EXCEPTION;

   lv_data_record    VARCHAR2(4000);   --  ##  Variable to store the concatenated value to be stored in file ##
   lv_orig_award_id  igf_aw_award.award_id%TYPE;
   p_tot_rec_count   NUMBER := 0;      --  ##  Variable to store the number of records to be placed in Trailer Record ##
   lc_chg_flag       VARCHAR2(1);      --  ##  Flag to Indicate if any changes are there between Oldvalues and New values ##
   lc_disb_chg_flag  VARCHAR2(1);      --  ##  Flag to Indicate if any changes are there between Oldvalues and New ones in Disbursement tables##
   lc_header_flag    VARCHAR2(1) := 'N';  --  ##  Flag to indicate if any changes had happened in loans or disbursement so as to set the header record ##
   l_rowid           ROWID;
   lv_loan_number    igf_sl_dl_chg_send.loan_number%TYPE;

   -- ## REF Cursor Record Types.

   Header_Rec        igf_sl_dl_record.DLHeaderType;
   Trailer_Rec       igf_sl_dl_record.DLTrailerType;

   lv_bool           BOOLEAN;
   l_disb            BOOLEAN := TRUE;  -- ## Variable for disbursement calculations
   l_disb_loc        BOOLEAN := FALSE; -- ## Variable for disbursement calculations

   l_driver_license_number     igf_ap_isir_matched.driver_license_number%TYPE;
   l_driver_license_state      igf_ap_isir_matched.driver_license_state%TYPE;
   l_citizenship_status        igf_ap_isir_matched.citizenship_status%TYPE;
   l_alien_reg_number          igf_ap_isir_matched.alien_reg_number%TYPE;
   l_dependency_status         igf_ap_isir_matched.dependency_status%TYPE;
   l_fed_fund_1 igf_aw_fund_cat.fed_fund_code%TYPE;
   l_fed_fund_2 igf_aw_fund_cat.fed_fund_code%TYPE;
    student_dtl_cur igf_sl_gen.person_dtl_cur;
    parent_dtl_cur  igf_sl_gen.person_dtl_cur;
    student_dtl_rec  igf_sl_gen.person_dtl_rec;
    parent_dtl_rec   igf_sl_gen.person_dtl_rec;


   -- ## Cursor to Retrieve the active direct loan records with change status as Send from the igf_sl_lor table
   -- ## for the particular award Year
  -- FA 122 Loans Enhancemnts changed the cursor to remove the obsolete view igf_sl_lor_dtls_v
   CURSOR c_lor(
                p_cal_type         igs_ca_inst.cal_type%TYPE,
                p_seq_num          igs_ca_inst.sequence_number%TYPE,
                p_fed_fund_1       igf_aw_fund_cat.fed_fund_code%TYPE,
                p_fed_fund_2       igf_aw_fund_cat.fed_fund_code%TYPE,
                p_loan_status      igf_sl_loans.loan_status%TYPE,
                p_loan_chg_status  igf_sl_loans.loan_chg_status%TYPE,
                p_active           igf_sl_loans.active%TYPE
                ) IS
    SELECT
    loans.row_id,
    loans.loan_id,
    loans.loan_number,
    loans.award_id,
    awd.accepted_amt loan_amt_accepted,
    loans.loan_per_begin_date,
    loans.loan_per_end_date,
    lor.orig_fee_perct,
    lor.pnote_print_ind,
    lor.s_default_status,
    lor.p_default_status,
    lor.p_person_id,
    lor.grade_level_code,
    lor.unsub_elig_for_heal,
    lor.disclosure_print_ind,
    lor.unsub_elig_for_depnt,
    lor.pnote_batch_id,
    lor.pnote_ack_date,
    lor.pnote_mpn_ind,
    fabase.base_id,
    fabase.person_id student_id,
    awd.accepted_amt
    FROM
    igf_sl_loans       loans,
    igf_sl_lor         lor,
    igf_aw_award       awd,
    igf_aw_fund_mast   fmast,
    igf_aw_fund_cat    fcat,
    igf_ap_fa_base_rec fabase
    WHERE
    fabase.ci_cal_type        = p_cal_type      AND
    fabase.ci_sequence_number = p_seq_num       AND
    fabase.base_id            = awd.base_id     AND
    awd.fund_id               = fmast.fund_id   AND
    fmast.fund_code           = fcat.fund_code  AND
    (fcat.fed_fund_code       = p_fed_fund_1    OR  fcat.fed_fund_code =  p_fed_fund_2) AND
    loans.award_id            = awd.award_id    AND
    loans.loan_id             = lor.loan_id     AND
    loans.loan_status         = p_loan_status      AND
    loans.loan_chg_status     = p_loan_chg_status  AND
    loans.active              = p_active           AND
    substr(loans.loan_number, 13, 6) = p_school_code;

   -- masehgal  # 2593215    define variables to be used in the call to get_acad_cal_dtls
   l_loan_number    igf_sl_loans.loan_number%TYPE := NULL ;
   lv_acad_cal_type igs_ca_inst.cal_type%TYPE := NULL ;
   lv_acad_seq_num  igs_ca_inst.sequence_number%TYPE := NULL ;
   lv_message       VARCHAR2(100) := NULL ;

   -- ## Cursor to Retrieve the Originated record to compare with the igf_sl_lor table to see if any
   -- ## change records exist.

   CURSOR c_lor_loc(p_loan_id igf_sl_lor_loc.loan_id%TYPE) IS
   SELECT igf_sl_lor_loc.*
   FROM igf_sl_lor_loc
   WHERE loan_id  = p_loan_id;

   -- ## Cursor to retrieve the license number,license state,citizenship status,alien reg number and
   -- ## dependency status of the Student to be compared with that in IGF_SL_LOR_LOC to see if
   -- ## any changes exists.

   CURSOR cur_isir_depend_status(l_base_id  igf_ap_fa_base_rec.base_id%TYPE)
       IS
       SELECT isir.dependency_status
       FROM   igf_ap_fa_base_rec fabase,igf_ap_isir_matched isir
       WHERE  isir.isir_id   = fabase.payment_isir_id
       AND    fabase.base_id = l_base_id;

    -- ## Cursor to Retrieve the disburesment records

    CURSOR cur_award(p_award_id igf_aw_award.award_id%TYPE) IS
         SELECT disb.* FROM igf_aw_awd_disb disb
         WHERE disb.award_id = p_award_id
         ORDER BY disb.disb_num;


    -- ## Cursor to Retrieve the Originated disbursement records for the particular award ID
    -- ## to compare with the disbursement table to know if any change exists

    CURSOR cur_disb_loc(p_award_id igf_aw_award.award_id%TYPE) IS
           SELECT disb.row_id row_id, disb.disb_num, disb.disb_gross_amt, disb.disb_date
           FROM igf_sl_awd_disb_loc disb
           WHERE award_id = p_award_id
           ORDER BY disb.disb_num FOR UPDATE OF disb.disb_gross_amt NOWAIT;

    lcur_award        cur_award%ROWTYPE;
    lcur_disb_loc     cur_disb_loc%ROWTYPE;
    lc_lor_loc        c_lor_loc%ROWTYPE;

    --Cursor to fetch the Meaning for displaying parameters passed
    --Used UNION ALL here since individual select clauses
    --have the same cost
    --Bug 2332668

     CURSOR cur_get_parameters IS
     SELECT meaning FROM igf_lookups_view
     WHERE  lookup_type='IGF_SL_DL_LOAN_CATG' AND lookup_code=p_dl_loan_catg AND enabled_flag = 'Y'

     UNION ALL

     SELECT  meaning FROM igf_lookups_view
     WHERE  lookup_type='IGF_GE_PARAMETERS' AND lookup_code IN ('AWARD_YEAR','LOAN_CATG','PARAMETER_PASS') AND enabled_flag = 'Y';

    -- Get the details of school meaning from lookups to print in the log file
    CURSOR c_get_sch_code IS
      SELECT meaning
        FROM igs_lookups_view
       WHERE lookup_type = 'OR_SYSTEM_ID_TYPE'
         AND lookup_code = 'DL_SCH_CD'
         AND enabled_flag = 'Y';
    c_get_sch_code_rec c_get_sch_code%ROWTYPE;

     --Cursor to get the alternate code for the calendar instance
     --Bug 2332668
     CURSOR cur_alternate_code IS
     SELECT ca.alternate_code FROM igs_ca_inst ca
     WHERE  ca.cal_type =lv_cal_type
     AND    ca.sequence_number = lv_cal_seq_num;

    -- Private Definition of the Procedure comp_lor_loc

    PROCEDURE  comp_lor_loc
                          ( p_field_lor      IN     VARCHAR2,
                            p_field_lor_loc  IN     VARCHAR2,
                            p_field_name     IN     VARCHAR2,
                            p_chg_flg        IN OUT NOCOPY VARCHAR2
                            )
    AS
    /*************************************************************
      Created By : prchandr
      Date Created On : 2000/12/07
      Purpose : Procedure to compare the values in igf_sl_lor_loc and igf_sl_lor_dtls_v also for disbursements
      Know limitations, enhancements or remarks
      Change History:
      Bug 2438434.Incorrect Format in Output File.
      Who             When            What
      masehgal        # 2593215       removed begin/end dates fetching functions
                                      used procedure get_acad_cal_dtls instead
      mesriniv        1-jul-2002      Made UPPERCASE for Name,Address Fields,and LPAD with 0 for Amount Fields
      Who             When            What

      (reverse chronological order - newest change first)
      ***************************************************************/

    -- ## Cursor to get the changed code values
    CURSOR c_chg_code IS
           SELECT chg_code FROM igf_sl_dl_chg_fld
                 WHERE fld_name =p_field_name
                 AND   loan_catg= p_dl_loan_catg
                 AND   dl_version =lv_dl_version;

     lc_chg_code   c_chg_code%ROWTYPE;
     l_rowid       ROWID;
     l_chg_num     igf_sl_dl_chg_send.chg_num%TYPE;

    BEGIN
    -- ## Comparing the old field value with new field value, if any difference
    -- ## exists a record is inserted in igf_sl_dl_chg_send table with the status as
    -- ## Ready to send.

        IF   (p_field_lor IS NULL AND p_field_lor_loc IS NULL)
        OR   (p_field_lor = p_field_lor_loc) THEN
              NULL;
        ELSE

            OPEN c_chg_code;
            FETCH c_chg_code INTO lc_chg_code;
            IF c_chg_code%NOTFOUND THEN
                 CLOSE c_chg_code;
                 fnd_message.set_name('IGF','IGF_SL_NO_CHG_CODE');
                 fnd_message.set_token('FLD_NAME',  igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS', p_field_name));
                 fnd_message.set_token('LOAN_CATG', igf_aw_gen.lookup_desc('IGF_SL_DL_LOAN_CATG',p_dl_loan_catg));
                 fnd_message.set_token('DL_VERSION',igf_aw_gen.lookup_desc('IGF_SL_DL_VERSION',  lv_dl_version ));
                 igs_ge_msg_stack.add;
                 app_exception.raise_exception;
            END IF;

             -- Directly setting to Send, as the Trans_rec() procedure picks up only the
             -- picks up record belonging to this dbth_id

             igf_sl_dl_chg_send_pkg.insert_row (
                           x_mode                              => 'R',
                           x_rowid                             => l_rowid,
                           X_chg_num                           => l_chg_num,
                           X_dbth_id                           => lv_dbth_id,
                           X_loan_number                       => lv_loan_number,
                           X_chg_code                          => lc_chg_code.chg_code,
                           X_new_value                         => p_field_lor,
                           X_status                            => 'S'
                                                    );
                 p_chg_flg  := 'Y';    -- ## Set the chg flag as Y to indicate changes exists between 2 tables
              CLOSE c_chg_code;    -- ## Close the Cursor

        END IF;

       EXCEPTION
       WHEN OTHERS THEN
           IF c_chg_code%ISOPEN THEN
                CLOSE c_chg_code;
           END IF;
           fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
           fnd_message.set_token('NAME','IGF_SL_DL_CHG_ORIG.COMP_LOR_LOC');
           fnd_file.put_line(fnd_file.log,SQLERRM);
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
    END comp_lor_loc;

-- main
BEGIN

  retcode := 0;
  igf_aw_gen.set_org_id(p_org_id);

  lv_cal_type    := rtrim(substr(p_award_year,1,10));
  lv_cal_seq_num := rtrim(substr(p_award_year,11));

    --Get the alternate code
  OPEN cur_alternate_code;
  FETCH cur_alternate_code INTO l_alternate_code;
  IF cur_alternate_code%NOTFOUND THEN
     CLOSE cur_alternate_code;
     fnd_message.set_name('IGF','IGF_SL_NO_CALENDAR');
     IGS_GE_MSG_STACK.ADD;
     fnd_file.put_line(fnd_file.log,fnd_message.get);

     app_exception.raise_exception;
   END IF;
     CLOSE cur_alternate_code;

  --Write the details of Parameters Passed into LOG File.
  --Bug 2332668
    l_i:=0;
    OPEN cur_get_parameters;
     LOOP
      l_i:=l_i+1;
     FETCH cur_get_parameters INTO l_para_rec(l_i);
     EXIT WHEN cur_get_parameters%NOTFOUND;
     END LOOP;
     CLOSE cur_get_parameters;

    OPEN c_get_sch_code; FETCH c_get_sch_code INTO c_get_sch_code_rec; CLOSE c_get_sch_code;

        --Show the parameters passed
        --Bug No:2332668
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(4),50,' '));
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(2),50,' ')||':'||RPAD(' ',4,' ')||l_alternate_code);
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(3),50,' ')||':'||RPAD(' ',4,' ')||l_para_rec(1));
        fnd_file.put_line(fnd_file.log,RPAD(c_get_sch_code_rec.meaning,50,' ')||':'||RPAD(' ',4,' ')||p_school_code);

   IF  (igf_sl_dl_validation.check_full_participant (lv_cal_type, lv_cal_seq_num,'DL') ) THEN
     -- Log an error message
      fnd_message.set_name('IGF','IGF_SL_COD_NO_CHG_ORIG');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
        raise yr_full_participant;
    END IF;

  --Get the Direct Loan File Spec Version Bug :-2490289 DL Header and Trailer Formatting Error.
  --Handled the NO_DATA_FOUND exception if the DL Setup record is not available
  BEGIN
  lv_dl_version := igf_sl_gen.get_dl_version(lv_cal_type, lv_cal_seq_num);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   fnd_message.set_name('IGF','IGF_SL_NO_DL_SETUP');
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
     Since the Batch-Type and File-Specifications are same for STAFFORD
     and PLUS, we are passing Loan_catg='DL' and File-Type='DL_CHG_SEND'
     to DLHeader_Cur(). (Maintaining only 1 record in igf_sl_dl_file_type Seed table)
  *************************************************************************/

  igf_sl_dl_record.DLHeader_cur(lv_dl_version, 'DL',
                                lv_cal_type, lv_cal_seq_num, 'DL_CHG_SEND', p_school_code,
                                lv_dbth_id, lv_batch_id, lv_mesg_class, Header_Rec);
  FETCH Header_Rec into lv_data_record;

  IF Header_Rec%NOTFOUND THEN
     fnd_message.set_name ('IGF', 'IGF_GE_HDR_CREATE_ERROR');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
  END IF;

  -- FA 122 Loan Enhancements derive the paramters to be passed to the c_lor cursor
  IF p_dl_loan_catg = 'DL_STAFFORD' THEN
    l_fed_fund_1 := 'DLS';
    l_fed_fund_2 := 'DLU';
  ELSIF p_dl_loan_catg = 'DL_PLUS' THEN
    l_fed_fund_1 := 'DLP';
    l_fed_fund_2 := 'DLP';
  END IF;

  -- ## Comparisons of Old records and the new records in c_lor cursor and igf_sl_lor_loc
  -- ## Outer Loop get the various Loan ID for the Particular award year whereas the inner loop
  -- ## gets the originated records for the particular loan ID and passes it to a procedure
  -- ## called comp_lor_loc to check if any changes are there between 2 tables. If changes exists
  -- ## returns a flag with status as Y

  FOR lc_lor IN c_lor(lv_cal_type,lv_cal_seq_num,l_fed_fund_1,l_fed_fund_2,'A','G','Y')
  LOOP
              BEGIN
                -- FA 122 Loan Enhancements Use the igf_sl_gen.get_person_details for getting the student as
                 -- well as parent details.
                 igf_sl_gen.get_person_details(lc_lor.student_id,student_dtl_cur);
                 FETCH student_dtl_cur INTO student_dtl_rec;
                 igf_sl_gen.get_person_details(lc_lor.p_person_id,parent_dtl_cur);
                 FETCH parent_dtl_cur INTO parent_dtl_rec;

                 CLOSE student_dtl_cur;
                 CLOSE parent_dtl_cur;

                --Added Code to SKIP this LOAN instead of Raising an Exception
                --So that next correct record can be processed.
                --Raising Exception Code is being removed
                OPEN c_lor_loc(lc_lor.loan_id);
                FETCH c_lor_loc INTO lc_lor_loc;
                IF c_lor_loc%NOTFOUND THEN
                       CLOSE c_lor_loc;
                       fnd_message.set_name('IGF','IGF_SL_NO_LOR_LOC_REC');
                       fnd_message.set_token('LOAN_NUMBER',lc_lor.loan_number);
                       fnd_file.put_line(fnd_file.log,' ');
                       fnd_file.put_line(fnd_file.log,fnd_message.get);

                       RAISE SKIP_LOAN;
                END IF;

                --Added Code to SKIP this LOAN instead of Raising an Exception
                --So that next correct record can be processed.
                --Raising Exception Code is being removed
               OPEN cur_isir_depend_status(lc_lor.base_id);
               FETCH cur_isir_depend_status INTO l_dependency_status;
               IF cur_isir_depend_status%NOTFOUND THEN
                       CLOSE cur_isir_depend_status;
                       fnd_message.set_name('IGF','IGF_GE_REC_NO_DATA_FOUND');
                       fnd_message.set_token('P_RECORD',' Payment ISIR');
                       fnd_file.put_line(fnd_file.log,' ');
                       fnd_file.put_line(fnd_file.log,fnd_message.get);
                       RAISE SKIP_LOAN;
               END IF;

              --Code added for bug 3603289 start
              l_driver_license_number := student_dtl_rec.p_license_num;
              l_driver_license_state  := student_dtl_rec.p_license_state;
              l_citizenship_status    := student_dtl_rec.p_citizenship_status;
              l_alien_reg_number      := student_dtl_rec.p_alien_reg_num;
              --Code added for bug 3603289 end

            -- PUT THE DEBUGGING LOG MESSAGES

              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_chg_orig.chg_originate.debug','loan_number passed to igf_sl_dl_record.get_acad_cal_dtls:'|| lc_lor.loan_number);
              END IF;
               l_loan_number := lc_lor.loan_number ;
               -- To get the academic begin and end dates.
               -- masehgal   # 2593215   removed begin/end dates fetching functions
               --                        used procedure get_acad_cal_dtls instead
               igf_sl_dl_record.get_acad_cal_dtls ( l_loan_number,
                                                    lv_acad_cal_type,
                                                    lv_acad_seq_num,
                                                    lv_begin_date,
                                                    lv_end_date,
                                                    lv_message ) ;


              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_chg_orig.chg_originate.debug','lv_message got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_message);
              END IF;
              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_chg_orig.chg_originate.debug','lv_acad_begin_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_begin_date);
              END IF;
              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_chg_orig.chg_originate.debug','lv_acad_end_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_end_date);
              END IF;
                    -- ## The If conditions checks if it is Plus records and else the Stafford records

                    lc_chg_flag      := 'N';
                    lc_disb_chg_flag := 'N';
                    lv_loan_number   := lc_lor.loan_number;

                    IF p_dl_loan_catg = 'DL_PLUS' THEN


                       comp_lor_loc(SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(student_dtl_rec.p_ssn),1,9),
                                    SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(lc_lor_loc.s_ssn),1,9),'S_SSN', lc_chg_flag);
                       comp_lor_loc(UPPER(student_dtl_rec.p_first_name),UPPER(lc_lor_loc.s_first_name),'S_FIRST_NAME' ,lc_chg_flag);


                       comp_lor_loc(UPPER(student_dtl_rec.p_last_name),UPPER(lc_lor_loc.s_last_name),'S_LAST_NAME',lc_chg_flag);
                       comp_lor_loc(UPPER(student_dtl_rec.p_middle_name),UPPER(lc_lor_loc.s_middle_name),'S_MIDDLE_NAME',lc_chg_flag);
                       comp_lor_loc(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),TO_CHAR(lc_lor_loc.s_date_of_birth,'YYYYMMDD'),
                                     'S_DATE_OF_BIRTH',lc_chg_flag);
                       comp_lor_loc(lc_lor.s_default_status,lc_lor_loc.s_default_status,'S_DEFAULT_STATUS',lc_chg_flag);
                       comp_lor_loc(SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(parent_dtl_rec.p_ssn),1,9),
                                    SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(lc_lor_loc.p_ssn),1,9),'P_SSN',lc_chg_flag);
                       comp_lor_loc(UPPER(parent_dtl_rec.p_first_name),UPPER(lc_lor_loc.p_first_name),'P_FIRST_NAME',lc_chg_flag);
                       comp_lor_loc(UPPER(parent_dtl_rec.p_last_name),UPPER(lc_lor_loc.p_last_name),'P_LAST_NAME',lc_chg_flag);
                       comp_lor_loc(UPPER(parent_dtl_rec.p_middle_name),UPPER(lc_lor_loc.p_middle_name),'P_MIDDLE_NAME',lc_chg_flag);
                       comp_lor_loc( RPAD(NVL(UPPER(parent_dtl_rec.p_permt_addr1)    ||' '||UPPER(parent_dtl_rec.p_permt_addr2),' '),35),
                                     RPAD(NVL(UPPER(lc_lor_loc.p_permt_addr1)||' '||UPPER(lc_lor_loc.p_permt_addr2),' '),35),
                                     'P_PERMT_ADDR1',lc_chg_flag);
                       comp_lor_loc(UPPER(parent_dtl_rec.p_permt_city),UPPER(lc_lor_loc.p_permt_city),'P_PERMT_CITY',lc_chg_flag);
                       comp_lor_loc(UPPER(parent_dtl_rec.p_permt_state),UPPER(lc_lor_loc.p_permt_state),'P_PERMT_STATE',lc_chg_flag);
                       comp_lor_loc(parent_dtl_rec.p_permt_zip,lc_lor_loc.p_permt_zip,'P_PERMT_ZIP',lc_chg_flag);
                       comp_lor_loc(UPPER(parent_dtl_rec.p_license_state),UPPER(lc_lor_loc.p_license_state),'P_LICENSE_STATE',lc_chg_flag);
                       comp_lor_loc(UPPER(parent_dtl_rec.p_license_num),UPPER(lc_lor_loc.p_license_num),'P_LICENSE_NUM',lc_chg_flag);
                       comp_lor_loc(parent_dtl_rec.p_citizenship_status,lc_lor_loc.p_citizenship_status,'P_CITIZENSHIP_STATUS',lc_chg_flag);
                       comp_lor_loc(parent_dtl_rec.p_alien_reg_num,lc_lor_loc.p_alien_reg_num,'P_ALIEN_REG_NUM',lc_chg_flag);
                       comp_lor_loc(lc_lor.p_default_status,lc_lor_loc.p_default_status,'P_DEFAULT_STATUS',lc_chg_flag);
                       comp_lor_loc(lc_lor.grade_level_code,lc_lor_loc.grade_level_code,'GRADE_LEVEL_CODE',lc_chg_flag);
                       comp_lor_loc(LPAD(TO_CHAR(lc_lor.loan_amt_accepted),5,0),LPAD(TO_CHAR(lc_lor_loc.loan_amt_accepted),5,0),'LOAN_AMT_ACCEPTED',lc_chg_flag);
                       comp_lor_loc(TO_CHAR(lc_lor.loan_per_begin_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.loan_per_begin_date,'YYYYMMDD'),
                                      'LOAN_PER_BEGIN_DATE',lc_chg_flag);
                       comp_lor_loc(TO_CHAR(lc_lor.loan_per_end_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.loan_per_end_date,'YYYYMMDD'),
                                      'LOAN_PER_END_DATE',lc_chg_flag);
                       comp_lor_loc(lc_lor.pnote_print_ind,lc_lor_loc.pnote_print_ind,'PNOTE_PRINT_IND',lc_chg_flag);
                       comp_lor_loc(lc_lor.unsub_elig_for_heal,lc_lor_loc.unsub_elig_for_heal,'UNSUB_ELIG_FOR_HEAL',lc_chg_flag);
                       comp_lor_loc(lc_lor.disclosure_print_ind,lc_lor_loc.disclosure_print_ind,'DISCLOSURE_PRINT_IND',lc_chg_flag);
                       comp_lor_loc(LPAD(NVL(LTRIM(TO_CHAR(lc_lor.orig_fee_perct*1000,'00000')),'0'),5),LPAD(NVL(LTRIM(TO_CHAR(lc_lor_loc.orig_fee_perct*1000,'00000')),'0'),5),'ORIG_FEE_PERCT',lc_chg_flag);
                       comp_lor_loc(lc_lor.unsub_elig_for_depnt,lc_lor_loc.unsub_elig_for_depnt,'UNSUB_ELIG_FOR_DEPNT',lc_chg_flag);
                       comp_lor_loc(student_dtl_rec.p_email_addr,lc_lor_loc.s_email_addr,'S_EMAIL_ADDR',lc_chg_flag);
                       comp_lor_loc(TO_CHAR(lv_begin_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.acad_yr_begin_date,'YYYYMMDD'),
                                        'ACAD_YR_BEGIN_DATE',lc_chg_flag);
                       comp_lor_loc(TO_CHAR(lv_end_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.acad_yr_end_date,'YYYYMMDD'),
                                        'ACAD_YR_END_DATE',lc_chg_flag);

                       comp_lor_loc(l_citizenship_status,lc_lor_loc.s_citizenship_status,'S_CITIZENSHIP_STATUS',lc_chg_flag);
                       comp_lor_loc(l_alien_reg_number,lc_lor_loc.s_alien_reg_num,'S_ALIEN_REG_NUM',lc_chg_flag);
                       comp_lor_loc(l_dependency_status,lc_lor_loc.s_depncy_status,'S_DEPNCY_STATUS',lc_chg_flag);

                   ELSIF   p_dl_loan_catg = 'DL_STAFFORD' THEN

                        comp_lor_loc(SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(student_dtl_rec.p_ssn),1,9),
                                     SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(lc_lor_loc.s_ssn),1,9),
                                    'S_SSN', lc_chg_flag);
                        comp_lor_loc(UPPER(student_dtl_rec.p_first_name),UPPER(lc_lor_loc.s_first_name),'S_FIRST_NAME',lc_chg_flag);
                        comp_lor_loc(UPPER(student_dtl_rec.p_last_name),UPPER(lc_lor_loc.s_last_name),'S_LAST_NAME',lc_chg_flag);
                        comp_lor_loc(UPPER(student_dtl_rec.p_middle_name),UPPER(lc_lor_loc.s_middle_name),'S_MIDDLE_NAME',lc_chg_flag);
                        comp_lor_loc( RPAD(NVL(UPPER(student_dtl_rec.p_permt_addr1)    ||' '||UPPER(student_dtl_rec.p_permt_addr2),' '),35),
                                      RPAD(NVL(UPPER(lc_lor_loc.s_permt_addr1)||' '||UPPER(lc_lor_loc.s_permt_addr2),' '),35),
                                      'S_PERMT_ADDR1',lc_chg_flag);
                        comp_lor_loc(UPPER(student_dtl_rec.p_permt_city),UPPER(lc_lor_loc.s_permt_city),'S_PERMT_CITY',lc_chg_flag);
                        comp_lor_loc(UPPER(student_dtl_rec.p_permt_state),UPPER(lc_lor_loc.s_permt_state),'S_PERMT_STATE',lc_chg_flag);
                        comp_lor_loc(student_dtl_rec.p_permt_zip,lc_lor_loc.s_permt_zip,'S_PERMT_ZIP',lc_chg_flag);

                        comp_lor_loc(lc_lor.s_default_status,lc_lor_loc.s_default_status,'S_DEFAULT_STATUS',lc_chg_flag);
                        comp_lor_loc(lc_lor.grade_level_code,lc_lor_loc.grade_level_code,'GRADE_LEVEL_CODE',lc_chg_flag);
                        comp_lor_loc(LPAD(TO_CHAR(NVL(lc_lor.loan_amt_accepted,0)),5,0),LPAD(TO_CHAR(lc_lor_loc.loan_amt_accepted),5,0),'LOAN_AMT_ACCEPTED',lc_chg_flag);
                        comp_lor_loc(TO_CHAR(lc_lor.loan_per_begin_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.loan_per_begin_date,'YYYYMMDD'),
                                       'LOAN_PER_BEGIN_DATE',lc_chg_flag);
                        comp_lor_loc(TO_CHAR(lc_lor.loan_per_end_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.loan_per_end_date,'YYYYMMDD'),
                                       'LOAN_PER_END_DATE',lc_chg_flag);
                        comp_lor_loc(lc_lor.pnote_print_ind,lc_lor_loc.pnote_print_ind,'PNOTE_PRINT_IND',lc_chg_flag);
                        comp_lor_loc( RPAD(NVL(UPPER(student_dtl_rec.p_local_addr1)    ||' '||UPPER(student_dtl_rec.p_local_addr2),' '),35),
                                      RPAD(NVL(UPPER(lc_lor_loc.s_local_addr1)||' '||UPPER(lc_lor_loc.s_local_addr2),' '),35),
                                      'S_LOCAL_ADDR1',lc_chg_flag);
                        comp_lor_loc(UPPER(student_dtl_rec.p_local_city),UPPER(lc_lor_loc.s_local_city),'S_LOCAL_CITY',lc_chg_flag);
                        comp_lor_loc(UPPER(student_dtl_rec.p_local_state),UPPER(lc_lor_loc.s_local_state),'S_LOCAL_STATE',lc_chg_flag);
                        comp_lor_loc(student_dtl_rec.p_local_zip,lc_lor_loc.s_local_zip,'S_LOCAL_ZIP',lc_chg_flag);
                        comp_lor_loc(lc_lor.unsub_elig_for_heal,lc_lor_loc.unsub_elig_for_heal,'UNSUB_ELIG_FOR_HEAL',lc_chg_flag);
                        comp_lor_loc(lc_lor.disclosure_print_ind,lc_lor_loc.disclosure_print_ind,'DISCLOSURE_PRINT_IND',lc_chg_flag);
                        comp_lor_loc(LPAD(NVL(LTRIM(TO_CHAR(lc_lor.orig_fee_perct*1000,'00000')),'0'),5),
                                     LPAD(NVL(LTRIM(TO_CHAR(lc_lor_loc.orig_fee_perct*1000,'00000')),'0'),5),'ORIG_FEE_PERCT', lc_chg_flag);
                        comp_lor_loc(lc_lor.unsub_elig_for_depnt,lc_lor_loc.unsub_elig_for_depnt,'UNSUB_ELIG_FOR_DEPNT',lc_chg_flag);
                        comp_lor_loc(student_dtl_rec.p_email_addr,lc_lor_loc.s_email_addr,'S_EMAIL_ADDR',lc_chg_flag);
                        comp_lor_loc(TO_CHAR(lv_begin_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.acad_yr_begin_date,'YYYYMMDD'),
                                      'ACAD_YR_BEGIN_DATE',lc_chg_flag);
                        comp_lor_loc(TO_CHAR(lv_end_date,'YYYYMMDD'),TO_CHAR(lc_lor_loc.acad_yr_end_date,'YYYYMMDD'),
                                      'ACAD_YR_END_DATE',lc_chg_flag);

                        comp_lor_loc(UPPER(l_driver_license_state),UPPER(lc_lor_loc.s_license_state),'S_LICENSE_STATE',lc_chg_flag);
                        comp_lor_loc(UPPER(l_driver_license_number),UPPER(lc_lor_loc.s_license_num),'S_LICENSE_NUM',lc_chg_flag);
                        comp_lor_loc(l_dependency_status,lc_lor_loc.s_depncy_status,'S_DEPNCY_STATUS',lc_chg_flag);
                        comp_lor_loc(l_citizenship_status,lc_lor_loc.s_citizenship_status,'S_CITIZENSHIP_STATUS',lc_chg_flag);
                        comp_lor_loc(l_alien_reg_number,lc_lor_loc.s_alien_reg_num,'S_ALIEN_REG_NUM',lc_chg_flag);

                    END IF;

                    -- ## This loop is to calculate the disbursement based records. initially it is set to NULL and
                    -- ## the record is fetced from the igf_aw_awd_disb and origination table. The condition is made
                    -- ## in such a way that even if a Disbursement is Deleted, we still need to send Disb-gross-amt
                    -- ## as ZERO and disb-date as blank we need to overwrite these values at the LOC also.
                    -- ## So, 3 scenarios possible are
                    -- ##      - No. of Disbursement in IGF_AW_AWD_DISB = No. of Disb in IGF_SL_AWD_DISB_LOC
                    -- ##        and Disb-gross-amt and disb-date may be same or different.
                    -- ##      - A New disbursment is added in IGF_AW_AWD_DISB
                    -- ##      - A disbursement is deleted in IGF_AW_AWD_DISB.


                     l_disb     := TRUE;
                     l_disb_loc := TRUE;
                     OPEN cur_award(lc_lor.award_id);
                     OPEN cur_disb_loc(lc_lor.award_id);
                     LOOP
                                    lcur_disb_loc.disb_num           := NULL;
                                    lcur_disb_loc.disb_date          := NULL;
                                    lcur_disb_loc.disb_gross_amt     := NULL;
                                    lcur_award.disb_num              := NULL;
                                    lcur_award.disb_date             := NULL;
                                    lcur_award.disb_accepted_amt     := NULL;

                                    FETCH cur_award INTO lcur_award;
                                    IF cur_award%NOTFOUND THEN
                                        l_disb := FALSE;
                                    END IF;

                                    FETCH cur_disb_loc INTO lcur_disb_loc;
                                    IF cur_disb_loc%NOTFOUND THEN
                                        l_disb_loc := FALSE;
                                    END IF;

                                    IF l_disb_loc = FALSE AND l_disb = FALSE THEN
                                         EXIT;
                                    END IF;

                                    comp_lor_loc( LPAD(TO_CHAR(NVL(lcur_award.disb_accepted_amt,0)),5,0), LPAD(TO_CHAR(NVL(lcur_disb_loc.disb_gross_amt,0)),5,0),
                                       'DISB_GROSS_AMT'||'_'||NVL(lcur_disb_loc.disb_num,lcur_award.disb_num), lc_disb_chg_flag);
                                    comp_lor_loc(TO_CHAR(lcur_award.disb_date,'YYYYMMDD'),TO_CHAR(lcur_disb_loc.disb_date,'YYYYMMDD'),
                                       'DISB_DATE'||'_'||NVL(lcur_disb_loc.disb_num,lcur_award.disb_num), lc_disb_chg_flag);

                      END LOOP;
                      CLOSE cur_award;
                      CLOSE cur_disb_loc;


                       IF lc_chg_flag ='Y' or lc_disb_chg_flag='Y' THEN
                           lc_header_flag := 'Y';
                       END IF;

                   -- ## The lc_chg_flag is the out NOCOPY parameter from the comp_lor_loc procedure, even if one changed column
                   -- ## exists then the flag is set to Y and depending on that the igf_sl_lor_loc table is updated with
                   -- ## the new value(changed value). In case of disbursement records if any changes exists then the
                   -- ## igf_sl_awd_disb_loc table is deleted for the particular award Id and the new value from the
                   -- ## igf_aw_awd_disb is inserted into this table.

                    IF lc_chg_flag ='Y' THEN

                       -- Update the igf_sl_lor_loc table with the New Values(Changes values)
                       igf_sl_lor_loc_pkg.update_row (
                                                 X_Mode                              => 'R',
                                                 x_rowid                             => lc_lor_loc.row_id,
                                                 x_loan_id                           => lc_lor_loc.loan_id,
                                                 x_origination_id                    => lc_lor_loc.origination_id,
                                                 x_loan_number                       => lc_lor_loc.loan_number,
                                                 x_loan_type                         => lc_lor_loc.loan_type,
                                                 x_loan_amt_offered                  => lc_lor_loc.loan_amt_offered,
                                                 x_loan_amt_accepted                 => lc_lor.loan_amt_accepted,
                                                 x_loan_per_begin_date               => lc_lor.loan_per_begin_date,
                                                 x_loan_per_end_date                 => lc_lor.loan_per_end_date,
                                                 X_acad_yr_begin_date                => lc_lor_loc.acad_yr_begin_date,
                                                 X_acad_yr_end_date                  => lc_lor_loc.acad_yr_end_date,
                                                 x_loan_status                       => lc_lor_loc.loan_status,
                                                 x_loan_status_date                  => lc_lor_loc.loan_status_date,
                                                 x_loan_chg_status                   => lc_lor_loc.loan_chg_status,
                                                 x_loan_chg_status_date              => lc_lor_loc.loan_chg_status_date,
                                                 x_req_serial_loan_code              => lc_lor_loc.req_serial_loan_code,
                                                 x_act_serial_loan_code              => lc_lor_loc.act_serial_loan_code,
                                                 x_active                            => lc_lor_loc.active,
                                                 x_active_date                       => lc_lor_loc.active_date,
                                                 x_sch_cert_date                     => lc_lor_loc.sch_cert_date,
                                                 x_orig_status_flag                  => lc_lor_loc.orig_status_flag,
                                                 x_orig_batch_id                     => lc_lor_loc.orig_batch_id,
                                                 x_orig_batch_date                   => lc_lor_loc.orig_batch_date,
                                                 x_chg_batch_id                      => NULL,
                                                 x_orig_ack_date                     => lc_lor_loc.orig_ack_date,
                                                 x_credit_override                   => lc_lor_loc.credit_override,
                                                 x_credit_decision_date              => lc_lor_loc.credit_decision_date,
                                                 x_pnote_delivery_code               => lc_lor_loc.pnote_delivery_code,
                                                 x_pnote_status                      => lc_lor_loc.pnote_status,
                                                 x_pnote_status_date                 => lc_lor_loc.pnote_status_date,
                                                 x_pnote_id                          => lc_lor_loc.pnote_id,
                                                 x_pnote_print_ind                   => lc_lor.pnote_print_ind,
                                                 x_pnote_accept_amt                  => lc_lor_loc.pnote_accept_amt,
                                                 x_pnote_accept_date                 => lc_lor_loc.pnote_accept_date,
                                                 x_p_signature_code                  => lc_lor_loc.p_signature_code,
                                                 x_p_signature_date                  => lc_lor_loc.p_signature_date,
                                                 x_s_signature_code                  => lc_lor_loc.s_signature_code,
                                                 x_unsub_elig_for_heal               => lc_lor.unsub_elig_for_heal,
                                                 x_disclosure_print_ind              => lc_lor.disclosure_print_ind,
                                                 x_orig_fee_perct                    => lc_lor.orig_fee_perct,
                                                 x_borw_confirm_ind                  => lc_lor_loc.borw_confirm_ind,
                                                 x_borw_interest_ind                 => lc_lor_loc.borw_interest_ind,
                                                 x_unsub_elig_for_depnt              => lc_lor.unsub_elig_for_depnt,
                                                 x_guarantee_amt                     => lc_lor_loc.guarantee_amt,
                                                 x_guarantee_date                    => lc_lor_loc.guarantee_date,
                                                 x_guarnt_adj_ind                    => lc_lor_loc.guarnt_adj_ind,
                                                 x_guarnt_amt_redn_code              => lc_lor_loc.guarnt_amt_redn_code,
                                                 x_guarnt_status_code                => lc_lor_loc.guarnt_status_code,
                                                 x_guarnt_status_date                => lc_lor_loc.guarnt_status_date,
                                                 x_lend_apprv_denied_code            => NULL,
                                                 x_lend_apprv_denied_date            => NULL,
                                                 x_lend_status_code                  => lc_lor_loc.lend_status_code,
                                                 x_lend_status_date                  => lc_lor_loc.lend_status_date,
                                                 x_grade_level_code                  => lc_lor.grade_level_code,
                                                 x_enrollment_code                   => lc_lor_loc.enrollment_code,
                                                 x_anticip_compl_date                => lc_lor_loc.anticip_compl_date,
                                                 x_borw_lender_id                    => lc_lor_loc.borw_lender_id,
                                                 x_duns_borw_lender_id               => NULL,
                                                 x_guarantor_id                      => lc_lor_loc.guarantor_id,
                                                 x_duns_guarnt_id                    => NULL,
                                                 x_prc_type_code                     => lc_lor_loc.prc_type_code,
                                                 x_rec_type_ind                      => lc_lor_loc.rec_type_ind,
                                                 x_cl_loan_type                      => lc_lor_loc.cl_loan_type,
                                                 x_cl_seq_number                     => lc_lor_loc.cl_seq_number,
                                                 x_last_resort_lender                => lc_lor_loc.last_resort_lender,
                                                 x_lender_id                         => lc_lor_loc.lender_id,
                                                 x_duns_lender_id                    => NULL,
                                                 x_lend_non_ed_brc_id                => lc_lor_loc.lend_non_ed_brc_id,
                                                 x_recipient_id                      => lc_lor_loc.recipient_id,
                                                 x_recipient_type                    => lc_lor_loc.recipient_type,
                                                 x_duns_recip_id                     => NULL,
                                                 x_recip_non_ed_brc_id               => lc_lor_loc.recip_non_ed_brc_id,
                                                 x_cl_rec_status                     => NULL,
                                                 x_cl_rec_status_last_update         => NULL,
                                                 x_alt_prog_type_code                => lc_lor_loc.alt_prog_type_code,
                                                 x_alt_appl_ver_code                 => lc_lor_loc.alt_appl_ver_code,
                                                 x_borw_outstd_loan_code             => lc_lor_loc.borw_outstd_loan_code,
                                                 x_mpn_confirm_code                  => NULL,
                                                 x_resp_to_orig_code                 => lc_lor_loc.resp_to_orig_code,
                                                 x_appl_loan_phase_code              => NULL,
                                                 x_appl_loan_phase_code_chg          => NULL,
                                                 x_tot_outstd_stafford               => lc_lor_loc.tot_outstd_stafford,
                                                 x_tot_outstd_plus                   => lc_lor_loc.tot_outstd_plus,
                                                 x_alt_borw_tot_debt                 => lc_lor_loc.alt_borw_tot_debt,
                                                 x_act_interest_rate                 => lc_lor_loc.act_interest_rate,
                                                 x_service_type_code                 => lc_lor_loc.service_type_code,
                                                 x_rev_notice_of_guarnt              => lc_lor_loc.rev_notice_of_guarnt,
                                                 x_sch_refund_amt                    => lc_lor_loc.sch_refund_amt,
                                                 x_sch_refund_date                   => lc_lor_loc.sch_refund_date,
                                                 x_uniq_layout_vend_code             => lc_lor_loc.uniq_layout_vend_code,
                                                 x_uniq_layout_ident_code            => lc_lor_loc.uniq_layout_ident_code,
                                                 x_p_person_id                       => lc_lor_loc.p_person_id,
                                                 x_p_ssn                             => parent_dtl_rec.p_ssn,
                                                 x_p_ssn_chg_date                    => NULL,
                                                 x_p_last_name                       => parent_dtl_rec.p_last_name,
                                                 x_p_first_name                      => parent_dtl_rec.p_first_name,
                                                 x_p_middle_name                     => parent_dtl_rec.p_middle_name,
                                                 x_p_permt_addr1                     => parent_dtl_rec.p_permt_addr1,
                                                 x_p_permt_addr2                     => parent_dtl_rec.p_permt_addr2,
                                                 x_p_permt_city                      => parent_dtl_rec.p_permt_city,
                                                 x_p_permt_state                     => parent_dtl_rec.p_permt_state,
                                                 x_p_permt_zip                       => parent_dtl_rec.p_permt_zip,
                                                 x_p_permt_addr_chg_date             => NULL,
                                                 x_p_permt_phone                     => lc_lor_loc.p_permt_phone,
                                                 x_p_email_addr                      => parent_dtl_rec.p_email_addr,
                                                 x_p_date_of_birth                   => parent_dtl_rec.p_date_of_birth,
                                                 x_p_dob_chg_date                    => NULL,
                                                 x_p_license_num                     => parent_dtl_rec.p_license_num,
                                                 x_p_license_state                   => parent_dtl_rec.p_license_state,
                                                 x_p_citizenship_status              => parent_dtl_rec.p_citizenship_status,
                                                 x_p_alien_reg_num                   => parent_dtl_rec.p_alien_reg_num,
                                                 x_p_default_status                  => lc_lor.p_default_status,
                                                 x_p_foreign_postal_code             => NULL,
                                                 x_p_state_of_legal_res              => parent_dtl_rec.p_state_of_legal_res,
                                                 x_p_legal_res_date                  => parent_dtl_rec.p_legal_res_date,
                                                 x_s_ssn                             => student_dtl_rec.p_ssn,
                                                 x_s_ssn_chg_date                    => NULL,
                                                 x_s_last_name                       => student_dtl_rec.p_last_name,
                                                 x_s_first_name                      => student_dtl_rec.p_first_name,
                                                 x_s_middle_name                     => student_dtl_rec.p_middle_name,
                                                 x_s_permt_addr1                     => student_dtl_rec.p_permt_addr1,
                                                 x_s_permt_addr2                     => student_dtl_rec.p_permt_addr2,
                                                 x_s_permt_city                      => student_dtl_rec.p_permt_city,
                                                 x_s_permt_state                     => student_dtl_rec.p_permt_state,
                                                 x_s_permt_zip                       => student_dtl_rec.p_permt_zip,
                                                 x_s_permt_addr_chg_date             => NULL,
                                                 x_s_permt_phone                     => lc_lor_loc.s_permt_phone,
                                                 x_s_local_addr1                     => student_dtl_rec.p_local_addr1,
                                                 x_s_local_addr2                     => student_dtl_rec.p_local_addr2,
                                                 x_s_local_city                      => student_dtl_rec.p_local_city,
                                                 x_s_local_state                     => student_dtl_rec.p_local_state,
                                                 x_s_local_zip                       => student_dtl_rec.p_local_zip,
                                                 x_s_local_addr_chg_date             => NULL,
                                                 x_s_email_addr                      => student_dtl_rec.p_email_addr,
                                                 x_s_date_of_birth                   => student_dtl_rec.p_date_of_birth,
                                                 x_s_dob_chg_date                    => NULL,
                                                 x_s_license_num                     => l_driver_license_number,
                                                 x_s_license_state                   => l_driver_license_state,
                                                 x_s_depncy_status                   => l_dependency_status,
                                                 x_s_default_status                  => lc_lor.s_default_status,
                                                 x_s_citizenship_status              => l_citizenship_status,
                                                 x_s_alien_reg_num                   => l_alien_reg_number,
                                                 x_s_foreign_postal_code             => NULL,
                                                 x_pnote_batch_id                    => lc_lor.pnote_batch_id,
                                                 x_pnote_ack_date                    => lc_lor.pnote_ack_date,
                                                 x_pnote_mpn_ind                     => lc_lor.pnote_mpn_ind ,
                                                 x_award_id                          => lc_lor_loc.award_id,
                                                 x_base_id                           => lc_lor_loc.base_id,
                                                 x_document_id_txt                   => lc_lor_loc.document_id_txt,
                                                 x_loan_key_num                      => lc_lor_loc.loan_key_num,
                                                 x_interest_rebate_percent_num       => lc_lor_loc.interest_rebate_percent_num,
                                                 x_fin_award_year                    => lc_lor_loc.fin_award_year,
                                                 x_cps_trans_num                     => lc_lor_loc.cps_trans_num,
                                                 x_atd_entity_id_txt                 => lc_lor_loc.atd_entity_id_txt,
                                                 x_rep_entity_id_txt                 => lc_lor_loc.rep_entity_id_txt,
                                                 x_source_entity_id_txt              => lc_lor_loc.source_entity_id_txt,
                                                 x_pymt_servicer_amt                 => lc_lor_loc.pymt_servicer_amt,
                                                 x_pymt_servicer_date                => lc_lor_loc.pymt_servicer_date,
                                                 x_book_loan_amt                     => lc_lor_loc.book_loan_amt,
                                                 x_book_loan_amt_date                => lc_lor_loc.book_loan_amt_date,
                                                 x_s_chg_birth_date                  => lc_lor_loc.s_chg_birth_date,
                                                 x_s_chg_ssn                         => lc_lor_loc.s_chg_ssn,
                                                 x_s_chg_last_name                   => lc_lor_loc.s_chg_last_name,
                                                 x_b_chg_birth_date                  => lc_lor_loc.b_chg_birth_date,
                                                 x_b_chg_ssn                         => lc_lor_loc.b_chg_ssn,
                                                 x_b_chg_last_name                   => lc_lor_loc.b_chg_last_name,
                                                 x_note_message                      => lc_lor_loc.note_message,
                                                 x_full_resp_code                    => lc_lor_loc.full_resp_code,
                                                 x_s_permt_county                    => lc_lor_loc.s_permt_county,
                                                 x_b_permt_county                    => lc_lor_loc.b_permt_county,
                                                 x_s_permt_country                   => lc_lor_loc.s_permt_country,
                                                 x_b_permt_country                   => lc_lor_loc.b_permt_country,
                                                 x_crdt_decision_status              => lc_lor_loc.crdt_decision_status,
                                                 x_external_loan_id_txt              => lc_lor_loc.external_loan_id_txt,
                                                 x_deferment_request_code            => lc_lor_loc.deferment_request_code,
                                                 x_eft_authorization_code            => lc_lor_loc.eft_authorization_code,
                                                 x_requested_loan_amt                => lc_lor_loc.requested_loan_amt,
                                                 x_actual_record_type_code           => lc_lor_loc.actual_record_type_code,
                                                 x_reinstatement_amt                 => lc_lor_loc.reinstatement_amt,
                                                 x_lender_use_txt                    => lc_lor_loc.lender_use_txt,
                                                 x_guarantor_use_txt                 => lc_lor_loc.guarantor_use_txt,
                                                 x_fls_approved_amt                  => lc_lor_loc.fls_approved_amt,
                                                 x_flu_approved_amt                  => lc_lor_loc.flu_approved_amt,
                                                 x_flp_approved_amt                  => lc_lor_loc.flp_approved_amt,
                                                 x_alt_approved_amt                  => lc_lor_loc.alt_approved_amt,
                                                 x_loan_app_form_code                => lc_lor_loc.loan_app_form_code,
                                                 x_alt_borrower_ind_flag             => lc_lor_loc.alt_borrower_ind_flag,
                                                 x_school_id_txt                     => lc_lor_loc.school_id_txt,
                                                 x_cost_of_attendance_amt            => lc_lor_loc.cost_of_attendance_amt,
                                                 x_established_fin_aid_amount        => lc_lor_loc.established_fin_aid_amount,
                                                 x_student_electronic_sign_flag      => lc_lor_loc.student_electronic_sign_flag,
                                                 x_mpn_type_flag                     => lc_lor_loc.mpn_type_flag,
                                                 x_school_use_txt                    => lc_lor_loc.school_use_txt,
                                                 x_expect_family_contribute_amt      => lc_lor_loc.expect_family_contribute_amt,
                                                 x_borower_electronic_sign_flag      => lc_lor_loc.borower_electronic_sign_flag,
                                                 x_borower_credit_authoriz_flag      => lc_lor_loc.borower_credit_authoriz_flag ,
                                                 x_esign_src_typ_cd                  => lc_lor_loc.esign_src_typ_cd
                                                 );


                    END IF;

                     -- ## If any comparison difference exists for disbursement records
                     -- ##  then delete the particular award id consisting of old records and
                     -- ##  insert new records of from lor loc

                     IF lc_disb_chg_flag ='Y' THEN

                                  FOR lcur_disb_loc IN cur_disb_loc(lc_lor.award_id)
                                  LOOP

                                   -- ## Delete the records from the LOC table.

                                    igf_sl_awd_disb_loc_pkg.delete_row (lcur_disb_loc.row_id);

                                   END LOOP;

                                       -- ## Insert the new record from igf_aw_awd record to igf_aw_awd_disb_loc table

                                   FOR lcur_award IN cur_award(lc_lor.award_id)
                                   LOOP
                                       igf_sl_awd_disb_loc_pkg.insert_row (
                                                        x_mode                              => 'R',
                                                        x_rowid                             => l_rowid,
                                                        X_award_id                          => lcur_award.award_id,
                                                        X_disb_num                          => lcur_award.disb_num,
                                                        X_disb_gross_amt                    => lcur_award.disb_accepted_amt,
                                                        X_fee_1                             => lcur_award.fee_1,
                                                        X_fee_2                             => lcur_award.fee_1,
                                                        X_disb_net_amt                      => lcur_award.disb_net_amt,
                                                        X_disb_date                         => lcur_award.disb_date,
                                                        X_hold_rel_ind                      => lcur_award.hold_rel_ind,
                                                        X_fee_paid_1                        => lcur_award.fee_paid_1,
                                                        X_fee_paid_2                        => lcur_award.fee_paid_2
                                                        );

                                  END LOOP;
                      END IF;

                      -- ## Update LOAN_STATUS, LOAN_STATUS_DATE to SENT, Current Date In IGF_SL_LOANS TABLE

                      IF lc_chg_flag='Y' or lc_disb_chg_flag='Y' THEN
                               DECLARE
                                  lv_row_id  VARCHAR2(25);
                                  CURSOR c_tbh_cur IS
                                         SELECT igf_sl_loans.* FROM igf_sl_loans
                                         WHERE loan_id =lc_lor.loan_id;
                               BEGIN

                                    FOR tbh_rec in c_tbh_cur LOOP

                                    -- ## Update the Loan Change Status as Sent and Loan Change status date as the current date
                                    -- Modified the update row call of the IGF_SL_LOANS_PKG package to include Borrower
                                    -- determination as part of Refunds DLD - 2144600
                                       igf_sl_loans_pkg.update_row (
                                               x_Mode                              => 'R',
                                               x_rowid                             => tbh_rec.row_id,
                                               x_loan_id                           => lc_lor.loan_id,
                                               x_award_id                          => tbh_rec.award_id,
                                               x_seq_num                           => tbh_rec.seq_num,
                                               x_loan_number                       => tbh_rec.loan_number,
                                               x_loan_per_begin_date               => tbh_rec.loan_per_begin_date,
                                               x_loan_per_end_date                 => tbh_rec.loan_per_end_date,
                                               x_loan_status                       => tbh_rec.loan_status,
                                               x_loan_status_date                  => tbh_rec.loan_status_date,
                                               x_loan_chg_status                   => 'S',     -- ## Change the loan change status as send
                                               x_loan_chg_status_date              => TRUNC(SYSDATE), -- ## Change the loan change date as sysdate
                                               x_active                            => tbh_rec.active,
                                               x_active_date                       => tbh_rec.active_date,
                                               x_borw_detrm_code                   => tbh_rec.borw_detrm_code,
                                               x_external_loan_id_txt              => tbh_rec.external_loan_id_txt

                                               );


                                      IF l_display <> 'Y' THEN
                                       --Display mesg in LOG File that Change Records have been originated and an Output file has been created.
                                         fnd_message.set_name('IGF','IGF_SL_LOAN_CHG_ORIG');
                                         fnd_message.set_token('LOAN_CATEG',l_para_rec(1));
                                         fnd_message.set_token('FILE_VERSION',lv_dl_version);
                                         fnd_file.put_line(fnd_file.log,fnd_message.get);
                                         l_display :='Y';
                                      END IF;


                                    END LOOP;
                              END;
                      END IF;

                   CLOSE cur_isir_depend_status;
                   CLOSE c_lor_loc;

                   EXCEPTION
                      WHEN SKIP_LOAN THEN
                          NULL;
                   END;
--      END IF;
  END LOOP;


    -- ## If there are any changes then create a header record

    IF lc_header_flag= 'Y' THEN

          -- Write the Header Record into the Output file.
          fnd_file.put_line(FND_FILE.OUTPUT, lv_data_record);

           --Formulating the Transaction Record

         BEGIN

            --Calls a Procedure to create a Transaction record in the File.

            Trans_Rec(lv_dl_version,lv_dbth_id,lv_batch_id,p_tot_rec_count);

         END;


         -- Initialise the Data Record field
       lv_data_record := NULL;

       -- Write the Trailer Record
       igf_sl_dl_record.DLTrailer_cur(lv_dl_version, p_tot_rec_count, Trailer_Rec);
       FETCH Trailer_Rec into lv_data_record;
       IF Trailer_Rec%NOTFOUND THEN
          fnd_message.set_name ('IGF', 'IGF_GE_TRL_CREATE_ERROR');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
       END IF;

       -- Write the Trailer Record into the Output file.
       fnd_file.put_line(FND_FILE.OUTPUT, lv_data_record);

   ELSE
      -- We need to do a rollback as we would have inserted into IGF_SL_DL_BATCH
      -- table while calling igf_sl_dl_record.DLHeader_cur.
      ROLLBACK;
   END IF;

   --Display a message if No Loan Change Origination
   --Bug No:2332668
   IF l_display='N' THEN
       fnd_file.put_line(fnd_file.log,' ');
       fnd_file.put_line(fnd_file.log,' ');
       fnd_message.set_name('IGF','IGF_SL_NO_LOAN_CHG_ORIG');
       fnd_file.put_line(fnd_file.log,fnd_message.get);

   END IF;


COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL;
    WHEN yr_full_participant THEN
    NULL;

    WHEN OTHERS THEN
       ROLLBACK;
       IF c_lor_loc%ISOPEN THEN
          CLOSE c_lor_loc;
       END IF;
       IF cur_isir_depend_status%ISOPEN THEN
          CLOSE cur_isir_depend_status;
       END IF;
       IF cur_award%ISOPEN THEN
          CLOSE cur_award;
       END IF;
       IF cur_disb_loc%ISOPEN THEN
          CLOSE cur_disb_loc;
       END IF;
       retcode := 2;
       errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       fnd_file.put_line(fnd_file.log,SQLERRM);
       igs_ge_msg_stack.conc_exception_hndl;
 END chg_originate;




PROCEDURE Trans_Rec( p_dl_version           igf_lookups_view.lookup_code%TYPE,
                     p_dl_dbth_id           igf_sl_dl_batch.dbth_id%TYPE,
                     p_dl_batch_id          igf_sl_dl_batch.batch_id%TYPE,
                     p_tot_rec_count        IN OUT NOCOPY NUMBER)
AS
  /*************************************************************
  Created By : prchandr
  Date Created On : 2000/11/13
  Purpose : To create the Transaction Record
  Know limitations, enhancements or remarks
  Change History
  Bug:-2255281
  Desc:-DL Version Change
  Who             When            What
  vvutukur        21-Feb-2003     Enh#2758823.FA117 Build. Modified the if condition to include 03-04 removing 02-03.
                                  ie., Changed IF p_dl_version IN ('2001-2002','2002-2003') to IF p_dl_version IN ('2002-2003','2003-2004').
  mesriniv        13-MAR-2002     Added DL Version 2002-2003
  (reverse chronological order - newest change first)
  ***************************************************************/


  l_Trans_Rec        VARCHAR2(4000)  := NULL;
  l_prev_loan_number igf_sl_dl_chg_send.loan_number%TYPE;
  l_line_rec_count   NUMBER := 0;
  l_tot_rec_count    NUMBER := 0;

  l_chg_rec_hdr_len  NUMBER := 0;
  l_chg_rec_len      NUMBER := 0;
  l_chg_code_len     NUMBER := 0;
  l_chg_val_len      NUMBER := 0;
  l_chg_err_len      NUMBER := 0;

  -- ## Cursor to retrieve the changed records for the particular loan_number and batch Id

  CURSOR cur_chg_rec  IS
         SELECT * from igf_sl_dl_chg_send
         WHERE dbth_id     = p_dl_dbth_id
         ORDER BY loan_number, chg_num;

  lcur_chg_rec  cur_chg_rec%ROWTYPE;
BEGIN

   l_tot_rec_count := 0;
   l_line_rec_count := 0;
   l_prev_loan_number := 'XXX';
   l_trans_rec := NULL;

   IF p_dl_version  IN  ('2002-2003','2003-2004','2004-2005') THEN
      l_chg_code_len :=  4;
      l_chg_val_len  :=  50;
      l_chg_err_len  :=  2;
      l_chg_rec_hdr_len := 23;
      l_chg_rec_len := l_chg_rec_hdr_len + (4 + 50 + 2) * 10 + 6;
   END IF;

   OPEN cur_chg_rec;

   LOOP
      FETCH cur_chg_rec INTO lcur_chg_rec;
      IF cur_chg_rec%NOTFOUND THEN
         IF l_trans_rec IS NOT NULL THEN
              fnd_file.put_line(FND_FILE.OUTPUT, RPAD(l_Trans_Rec, l_chg_rec_len)||RPAD(p_dl_batch_id,'25'));
              l_tot_rec_count := l_tot_rec_count + 1;
         END IF;
         EXIT;
      END IF;

      IF l_prev_loan_number <> lcur_chg_rec.loan_number THEN
         l_prev_loan_number := lcur_chg_rec.loan_number;
         l_line_rec_count := 0;
         IF l_trans_rec IS NOT NULL THEN
              fnd_file.put_line(FND_FILE.OUTPUT, RPAD(l_Trans_Rec, l_chg_rec_len)||RPAD(p_dl_batch_id,'25'));
              l_tot_rec_count := l_tot_rec_count + 1;
              l_trans_rec     := RPAD(lcur_chg_rec.loan_number,21)||'  ';
         ELSE
              l_trans_rec     := RPAD(lcur_chg_rec.loan_number,21)||'  ';
         END IF;

      ELSE   -- If Loan-Number is Same
         IF l_line_rec_count = 10 THEN
            l_line_rec_count := 0;
            fnd_file.put_line(FND_FILE.OUTPUT, RPAD(l_Trans_Rec, l_chg_rec_len)||RPAD(p_dl_batch_id,'25'));
            l_tot_rec_count := l_tot_rec_count + 1;
            l_trans_rec     := RPAD(lcur_chg_rec.loan_number,21)||'  ';
         END IF;
      END IF;

      l_Trans_Rec := l_Trans_Rec ||RPAD(NVL(lcur_chg_rec.chg_code,' '), l_chg_code_len)
                                 ||RPAD(NVL(lcur_chg_rec.new_value ,' '), l_chg_val_len)
                                 ||RPAD(' ', l_chg_err_len);

      l_line_rec_count := l_line_rec_count + 1;
   END LOOP;

   CLOSE cur_chg_rec;

   p_tot_rec_count := l_tot_rec_count;

EXCEPTION
WHEN OTHERS THEN
   IF cur_chg_rec%ISOPEN THEN
        CLOSE cur_chg_rec;
   END IF;
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_DL_CHG_ORIG.TRANS_REC');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END Trans_Rec;

END igf_sl_dl_chg_orig;

/
