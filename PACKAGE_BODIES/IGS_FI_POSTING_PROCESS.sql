--------------------------------------------------------
--  DDL for Package Body IGS_FI_POSTING_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_POSTING_PROCESS" AS
/* $Header: IGSFI59B.pls 120.3 2006/05/12 00:08:02 abshriva noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGS_FI_POSTING_PROCESS                  |
 |                                                                       |
 | NOTES                                                                 |
 |     This is a batch process that collects all eligible transactions   |
 |     for posting purposes from charges lines, credit activities and    |
 |     application tables. The output is inserted into the               |
 |     IGS_FI_Posting_INT. IF Oracle AR is installed then the data gets  |
 |     transfered to the same.                                           |
 |                                                                       |
 | HISTORY                                                               |
 | Who             When            What                                  |
 | abshriva      12-May-2006       Enh#5217319 Precision Issue. Modified |
 |                                 transfer_credit_act_txns,             |
 |                                 transfer_appl_txns, transfer_chgs_txns|
 |                                 and transfer_ad_appl_fee_txns         |
 | abshriva       5-May-2006      Bug5178077 Modification  made in       |
 |                                posting_interface                      |
 | svuppala      30-MAY-2005       Enh 3442712 - Done the TBH            |
 |                                  modifications by adding new columns  |
 |                                  Unit_Type_Id, Unit_Level in          |
 |                                  igs_fi_invln_int_all                 |
 |                                                                       |
 | vvutukur       09-Oct-03        Bug#3160036. Modified procedure       |
 |                                 transfer_ad_appl_fee_txns.            |
 |  pathipat       14-Jun-2003     Enh 2831587 - CC Fund Transfer build  |
 |                                 Modified transfer_ad_appl_fee_txns()  |
 | pathipat        23-Apr-2003     Enh 2831569 - Commercial Receivables  |
 |                                 Stubbed transfer_posting.             |
 |                                 Removed proc get_customer_details.    |
 |                                 Modified posting_interface().         |
 | shtatiko         09-DEC-2002     Modified cursor in transfer_credit_act_txns|
 |                                 procedure. ( Bug# 2584741, Deposits)  |
 | SYKRISHN        05-NOV/2002     Change posting_interface procedure as |
 |                                 as per GL Interface TD.      2584986  |
 | vchappid       16-Jul-2002      Bug#2464172, procedure in body are    |
 |                                 made in sync with the Package Spec    |
 | agairola        04 May 2002     Added the function get_log_line       |
 |                                 Modified the log file for the Transfer|
 |                                 posting transactions to AR process    |
 |                                 Also removed the references for the   |
 |                                 g_err_party and added the global var  |
 |                                 g_party for the party id              |
 | agairola        21 Apr 2002     Changed the variable g_interface_attr |
 |                                 to data type igs_fi_control.interface |
 |                                 line attribute.Added bug no. to header|
 |                                 for bugs 2326595, 2309929, 2310806    |
 | agairola        17-APR 2002     Added a new function get_int_val.     |
 |                                 Modified the coding logic for the     |
 |                                 INTERFACE_LINE_ATTRIBUTE11. Modified  |
 |                                 the log file display of the Posting   |
 |                                 Process.                              |
 |                                 for bugs 2326595, 2309929, 2310806    |
 | agairola        12-Apr-2002     Made the width of the CCID displayed  |
 |                                 to 233. Incase of error displayed
 |                                 party id.Modified the get_customer_details
 |                                 procedure to return customer account
 |                                 number. Added the function get_party_num
 |                                 for bugs 2326595, 2309929, 2310806    |
 | agairola        11-Apr-2002     Used the comments for the description field
 |                                 while populating the data in the
 |                                 RA_INTERFACE_LINES_ALL table in case
 |                                 the description is null
 |                                 for bugs 2326595, 2309929, 2310806    |
 | agairola        10-Apr-2002     Modified the code for displaying the  |
 |                                 Accounting Flex fields. Removed the   |
 |                                 redundant code and added the procedure|
 |                                 s for updation of the log file.       |
 |                                 for bugs 2326595, 2309929, 2310806    |
 |
 | sarakshi        28-Feb-2002     bug:2238362,For message logging modified
 |                                 person_ref to party_ref lookup        |
 | jbegum          25 Feb 02       As part of Enh bug # 2238226          |
 |                                 Modified the local procedure          |
 |                                 get_customer_details to derive        |
 |                                 customer account details for the local|
 |                                 institution .                         |
 |                                 In the procedure transfer_posting     |
 |                                 added code to copy value of the field |
 |                                 orig_appl_fee_ref to comments field of|
 |                                 RA_INTERFACE_LINES_ALL when           |
 |                                 source_transaction_type is APPLFEE    |
 |                                 Also added column orig_appl_fee_ref to|
 |                                 the IGS_FI_POSTING_INT_PKG.insert_row,|
 |                                 IGS_FI_POSTING_INT_PKG.update_row     |
 | agairola        22-Feb-2002     Added the modifications related to    |
 |                                 Customer Account and also calling the |
 |                                 customer account creation procedure   |
 |
 | agairola        11-Apr-2002     Used the value of comments for description in case it is null
 | agairola        10-Apr-2002     Code fixes done as part of bug 2309929
 |                                 Added the procedures for  updating the log file
 |                                 Code fixes done as part of bug 2310806
 |                                 Added the brackets for the Batch Name in Cursor cur_postings
 |                                 Added the code for locking the records
 | jbegum          25 Feb 02        As part of Enh bug #2238226
 |                                 Modified the local procedure get_customer_details
 |                                 to derive customer account details for the local institution
 |                                 In the procedure transfer_posting added code to copy value of the field
 |                                 orig_appl_fee_ref to comments field of RA_INTERFACE_LINES_ALL when
 |                                 source_transaction_type is APPLFEE.Also added column orig_appl_fee_ref to
 |                                 the IGS_FI_POSTING_INT_PKG.insert_row ,IGS_FI_POSTING_INT_PKG.update_row
 |   jbegum          20 Feb 02     As part of Enh bug #2228910
                                   Removed the source_transaction_id column from the IGS_FI_INVLN_INT_PKG.update_row
     jbegum          16 Feb 02      As part of Enh bug #2222272
                                   Set org id of transactions created
                                   in the Receivables Invoice Interface tables
                                   to the org id value obtained from control table

  Sykrishn       18-FEB-2002       Changes as per build SFCR023 - 2227831
 *=======================================================================*/
  -- Declare all Global variables and global constants
  g_cash          CONSTANT VARCHAR2(20) := 'CASH';
  g_accrual       CONSTANT VARCHAR2(20) := 'ACCRUAL';
  g_credit        CONSTANT VARCHAR2(20) := 'CREDIT';
  g_charge        CONSTANT VARCHAR2(20) := 'CHARGE';
  g_application   CONSTANT VARCHAR2(20) := 'APPLICATION';
  g_todo          CONSTANT VARCHAR2(20) := 'TODO';
  g_transferred   CONSTANT VARCHAR2(20) := 'TRANSFERRED';
  g_error         CONSTANT VARCHAR2(20) := 'ERROR';


  -- jbegum           25 Feb 02      As part of enh bug #2238226 added the following global constant
  g_applfee       CONSTANT VARCHAR2(20) := 'APPLFEE';

-- Global variable for receivables installed flag setting
  g_rec_installed          igs_fi_control.rec_installed%TYPE;

  g_party                  hz_parties.party_id%TYPE;

  g_interface_attr         igs_fi_control.interface_line_attribute%TYPE;

-- Global Variable for posting control id
  g_n_posting_control_id   igs_fi_posting_int_all.posting_control_id%TYPE;

  -- For printing total records processed at end of log file.
  g_n_rec_processed   NUMBER := 0;

  PROCEDURE derive_comments (
                       p_transaction_id     IN   igs_fi_posting_int_all.source_transaction_id%TYPE,
                       p_transaction_type   IN   igs_fi_posting_int_all.source_transaction_type%TYPE,
                       p_transaction_number OUT NOCOPY  VARCHAR2,
                       p_comments           OUT NOCOPY  ra_interface_lines_all.comments%TYPE
                         );

 FUNCTION lookup_desc( l_type in igs_lookup_values.lookup_type%TYPE , l_code in igs_lookup_values.lookup_code%TYPE  )RETURN VARCHAR2 IS
  /******************************************************************
  Created By        : sykrishn
  Date Created By   : 18-FEB-2002
  Purpose           : Local Function Returns the meaning for the given lookup code

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/

 CURSOR cur_desc( x_type igs_lookups_view.lookup_type%type,
                  x_code  igs_lookups_view.lookup_code%type )
 IS
 SELECT meaning
 FROM   igs_lookup_values
 WHERE lookup_code = x_code
 AND   lookup_type = x_type ;

 l_desc igs_lookup_values.meaning%type ;
 BEGIN
   IF l_code is null then
     return null ;
   ELSE
      open cur_desc(l_type,l_code);
      fetch cur_desc into l_desc ;
      close cur_desc ;
   END IF ;
   RETURN l_desc ;
 END lookup_desc;

 FUNCTION get_party_num(p_party_id    IN   NUMBER) RETURN VARCHAR2 AS
  /******************************************************************
  Created By        : agairola
  Date Created By   : 12-Apr-2002
  Purpose           : Local function for getting the party number

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/
   CURSOR cur_party(cp_party_id    NUMBER) IS
     SELECT party_number
     FROM   hz_parties
     WHERE  party_id = cp_party_id;

   l_party_num     hz_parties.party_number%TYPE;
 BEGIN
   IF p_party_id IS NULL THEN
     l_party_num := NULL;
   ELSE
     OPEN cur_party(p_party_id);
     FETCH cur_party INTO l_party_num;
     IF cur_party%NOTFOUND THEN
       l_party_num := NULL;
     END IF;
     CLOSE cur_party;
   END IF;

   RETURN l_party_num;
 END get_party_num;
 PROCEDURE update_log_norec(p_flag       IN BOOLEAN,
                            p_trx_type   IN VARCHAR2) AS
  /******************************************************************
  Created By        : agairola
  Date Created By   : 10-Apr-2002
  Purpose           : Local function for updating the log file incase
                      no records are found

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/
 BEGIN
   IF ((p_flag IS NULL) OR
       (p_trx_type IS NULL)) THEN
     RETURN;
   END IF;

   IF NOT p_flag THEN
     fnd_message.set_name('IGS',
                          'IGS_FI_NO_TRX_PROCESSED');
     fnd_message.set_token('TRX_TYPE',
                           lookup_desc('IGS_FI_SOURCE_TRANSACTION_TYPE',
                                       p_trx_type));
     fnd_file.put_line(fnd_file.log,
                       fnd_message.get);
   END IF;
 END update_log_norec;

 PROCEDURE update_log_file(p_txn_date         IN  igs_fi_posting_int.transaction_date%TYPE,
                           p_amount           IN  igs_fi_posting_int.amount%TYPE,
                           p_txn_id           IN  igs_fi_posting_int.source_transaction_id%TYPE,
                           p_dr_acc_code      IN  igs_fi_posting_int.dr_account_cd%TYPE,
                           p_cr_acc_code      IN  igs_fi_posting_int.cr_account_cd%TYPE,
                           p_src_txn_type     IN  igs_fi_posting_int.source_transaction_type%TYPE) AS

  /******************************************************************
  Created By        : agairola
  Date Created By   : 10-Apr-2002
  Purpose           : Local function for updating the log file with actual data

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
  SYKRISHN 01-NOV-2002  Modifications for Gl Interface Build
  agairola 17-Apr-2002 Modified the Log file display to be in Single Line instead of Tabular
                       for bugs 2326595, 2309929, 2310806
   ******************************************************************/

    l_v_txn_num             VARCHAR2(240);
    l_v_comments            ra_interface_lines_all.comments%TYPE;

    l_dr_account            igs_lookups_view.meaning%TYPE;
    l_cr_account            igs_lookups_view.meaning%TYPE;
  BEGIN

-- Log the Source Transaction Type in one single line
    fnd_file.put_line(fnd_file.log,'  '||lookup_desc('IGS_FI_LOCKBOX','SOURCE_TRAN_TYPE')||' : '||
                      lookup_desc('IGS_FI_SOURCE_TRANSACTION_TYPE',p_src_txn_type));

-- Call the procedure for deriving the comments tand the Transaction Number
-- This is a common procedure which is also used in the Transfer Posting process
    derive_comments(p_transaction_id     => p_txn_id,
                    p_transaction_type   => p_src_txn_type,
                    p_transaction_number => l_v_txn_num,
                    p_comments           => l_v_comments);

-- Log the Transaction Number
    fnd_file.put_line(fnd_file.log,
                      '  '||lookup_desc('IGS_FI_LOCKBOX','TRANSACTION_NUM')||' : '||l_v_txn_num);
    fnd_file.put_line(fnd_file.log,
                      '  '||lookup_desc('IGS_FI_LOCKBOX','TRANSACTION_DATE')||' : '||to_char(p_txn_date));
    fnd_file.put_line(fnd_file.log,
                      '  '||lookup_desc('IGS_FI_LOCKBOX','AMOUNT')||' : '||to_char(p_amount));


    l_dr_account := lookup_desc('IGS_FI_LOCKBOX','DR_ACCOUNT');
    l_cr_account := lookup_desc('IGS_FI_LOCKBOX','CR_ACCOUNT');

     fnd_file.put_line(fnd_file.log,
                        '  '||l_dr_account||' : '||p_dr_acc_code);
     fnd_file.put_line(fnd_file.log,
                        '  '||l_cr_account||' : '||p_cr_acc_code);
-- Put a new line

    fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    fnd_file.new_line(fnd_file.log);
  END update_log_file;

 PROCEDURE transfer_credit_act_txns(
                                 p_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_posted_date   IN  igs_fi_posting_int_all.accounting_date%TYPE
                                 ) AS
    /*
    ||  Created By : brajendr
    ||  Created On : 24-Apr-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  abshriva        12-May-2006     Enh#5217319 Precision Issue. Amount values being inserted into igs_fi_posting_int
    ||                                  is now rounded off to currency precision
    ||  shtatiko        09-Dec-2002     Modified to cursor to include conditions for dr_account_cd and cr_account_cd.
    ||                                  ( BUG# 2584741 )
    ||  Sykrishn        01-NOV/2002     Gl Interface TD modifications...
    ||                                  The below history is nt valid as the local procedure is revamped completely (including the proc name)
    ||  agairola        21 Apr 2002     Initialised the lrec_posting_int
    ||                                  for bugs 2326595, 2309929, 2310806
    ||  agairola        10-Apr-2002     Added the code for the printing of message in case of
    ||                                  no records being found and also for the common procedure
    ||                                  for logging messages for bugs 2326595, 2309929, 2310806
    ||  jbegum          25 Feb 02       As part of Enh bug # 2238226
    ||                                  Added column orig_appl_fee_ref to the
    ||                                  IGS_FI_POSTING_INT_PKG.insert_row
    ||  (reverse chronological order - newest change first)
    */

    -- Get all the credit activity records, where GL_DATE lies b/w the passed date ranges that are yet to be posted.

    -- Cursor is modified to include the check of credit and debit account codes
    -- by shtatiko as part of Enh Bug# 2584741.
    CURSOR cur_credit_activities(cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS

      SELECT crac.rowid row_id, crac.*
      FROM   igs_fi_cr_activities crac
      WHERE  crac.gl_date IS NOT NULL
      AND    TRUNC(crac.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
      AND    crac.posting_id IS NULL
      AND    crac.posting_control_id IS NULL
      AND    crac.dr_account_cd IS NOT NULL
      AND    crac.cr_account_cd IS NOT NULL
      ORDER BY gl_date
      FOR UPDATE OF gl_posted_date NOWAIT;


    -- Get the Currency Code from the Credit table with the given credit id.
    CURSOR cur_credit (cp_credit_id igs_fi_cr_activities.credit_id%TYPE ) IS
      SELECT currency_cd
      FROM   igs_fi_credits
      WHERE  credit_id = cp_credit_id;

    l_b_exception_flag   BOOLEAN := FALSE;

    l_v_currency_cd    igs_fi_credits.currency_cd%TYPE;
    l_v_cr_account_cd  igs_fi_cr_activities.cr_account_cd%TYPE;
    l_v_dr_account_cd  igs_fi_cr_activities.dr_account_cd%TYPE;
    l_n_amount         igs_fi_cr_activities.amount%TYPE;

    l_v_posting_rowid  ROWID;
    l_n_posting_id     igs_fi_posting_int.posting_id%TYPE;

  BEGIN

    FOR cr_act_rec IN cur_credit_activities( p_d_gl_date_start, p_d_gl_date_end) LOOP
           -- Looping through each of these records selected , check if the CR_ACT_REC.AMOUNT fetched is negative.
           --If negative, then make the AMOUNT positive (Eg. -50 to 50) and swap the values of debit and credit account codes.
           --(Value of DR_ACCOUNT_CD  to Value of CR_ACCOUNT_CD).

           IF cr_act_rec.amount < 0 THEN
                --Make amount +ve
                l_n_amount := ((-1) * cr_act_rec.amount);
                -- Swapping
                l_v_cr_account_cd := cr_act_rec.dr_account_cd;
                l_v_dr_account_cd := cr_act_rec.cr_account_cd;
           ELSE
                l_n_amount :=  cr_act_rec.amount;
                l_v_cr_account_cd := cr_act_rec.cr_account_cd;
                l_v_dr_account_cd := cr_act_rec.dr_account_cd;
           END IF;

       -- get the currency code from the credits table for credit_id
        OPEN cur_credit (cr_act_rec.credit_id);
        FETCH cur_credit INTO l_v_currency_cd;
        CLOSE  cur_credit;

        -- Insert into the posting int table wiht the selected transaction

      l_v_posting_rowid := NULL;
      l_n_posting_id := NULL;

      BEGIN
      -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
        igs_fi_posting_int_pkg.insert_row (
                                        x_rowid                        => l_v_posting_rowid,
                                        x_posting_control_id           => g_n_posting_control_id,
                                        x_posting_id                   => l_n_posting_id,
                                        x_batch_name                   => NULL,
                                        x_accounting_date              => cr_act_rec.gl_date,
                                        x_transaction_date             => cr_act_rec.transaction_date,
                                        x_currency_cd                  => l_v_currency_cd,
                                        x_dr_account_cd                => l_v_dr_account_cd,
                                        x_cr_account_cd                => l_v_cr_account_cd,
                                        x_dr_gl_code_ccid              => NULL,
                                        x_cr_gl_code_ccid              => NULL,
                                        x_amount                       => igs_fi_gen_gl.get_formatted_amount(l_n_amount),
                                        x_source_transaction_id        => cr_act_rec.credit_activity_id,
                                        x_source_transaction_type      => g_credit,
                                        x_status                       => g_todo,
                                        x_orig_appl_fee_ref            => NULL,
                                        x_mode                         => 'R'
                                        );
      EXCEPTION
        WHEN OTHERS THEN
        l_b_exception_flag := TRUE;
      END;


        -- Update the  credit activities table - posting_control_id and the log file

           IF NOT l_b_exception_flag THEN

                   update_log_file
                       (p_txn_date       => cr_act_rec.transaction_date,
                        p_amount         => l_n_amount,
                        p_txn_id         => cr_act_rec.credit_activity_id,
                        p_dr_acc_code    => l_v_dr_account_cd,
                        p_cr_acc_code    => l_v_cr_account_cd,
                        p_src_txn_type   => g_credit);

                  BEGIN
                    igs_fi_cr_activities_pkg.update_row(
                                          x_rowid                   => cr_act_rec.row_id,
                                          x_credit_activity_id      => cr_act_rec.credit_activity_id,
                                          x_credit_id               => cr_act_rec.credit_id,
                                          x_status                  => cr_act_rec.status,
                                          x_transaction_date        => cr_act_rec.transaction_date,
                                          x_amount                  => cr_act_rec.amount,
                                          x_dr_account_cd           => cr_act_rec.dr_account_cd,
                                          x_cr_account_cd           => cr_act_rec.cr_account_cd,
                                          x_dr_gl_ccid              => cr_act_rec.dr_gl_ccid,
                                          x_cr_gl_ccid              => cr_act_rec.cr_gl_ccid,
                                          x_bill_id                 => cr_act_rec.bill_id,
                                          x_bill_number             => cr_act_rec.bill_number,
                                          x_bill_date               => cr_act_rec.bill_date,
                                          x_posting_id              => l_n_posting_id,
                                          x_posting_control_id      => g_n_posting_control_id,
                                          x_gl_date                 => cr_act_rec.gl_date,
                                          x_gl_posted_date          => p_d_gl_posted_date,
                                          x_mode                    => 'R'
                                        );
                  END;
                 -- Total Records Processed Counter.....
                  g_n_rec_processed := g_n_rec_processed + 1;
           END IF;

        -- Reseting flag if exception has occured for previous_record.
         l_b_exception_flag := FALSE;

    END LOOP;

  EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXP');
        --Unhandled Exception Raised in Procedure NAME
        fnd_message.set_token('NAME','IGS_FI_POSTING_INTERFACE.TRANSFER_CREDIT_ACT_TXNS');
        fnd_file.put_line( fnd_file.log, fnd_message.get() || sqlerrm);
        app_exception.raise_exception;
  END transfer_credit_act_txns;


 PROCEDURE transfer_appl_txns(
                                 p_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_posted_date   IN  igs_fi_posting_int_all.accounting_date%TYPE
                                 ) AS
    /*
    ||  Created By : brajendr
    ||  Created On : 24-Apr-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  abshriva        12-May-2006     Enh#5217319 Precision Issue. Amount values being inserted into igs_fi_posting_int
    ||                                  is now rounded off to currency precision
    ||  Sykrishn        01-NOV/2002     Gl Interface TD modifications...
    ||                                  The below history is nt valid as the local procedure is revamped completely
    ||  agairola        21 Apr 2002     Initialised the lrec_posting_int
    ||                                  for bugs 2326595, 2309929, 2310806
    ||  agairola        10-Apr-2002     Added the code for the printing of message in case of
    ||                                  no records being found and also for the common procedure
    ||                                  for logging messages for bugs 2326595, 2309929, 2310806
    ||  jbegum          25 Feb 02       As part of Enh bug # 2238226
    ||                                  Added column orig_appl_fee_ref to the
    ||                                  IGS_FI_POSTING_INT_PKG.insert_row
    ||  (reverse chronological order - newest change first)
    */

    -- Get all the credit activity records, where GL_DATE lies b/w the passedg date ranges that have not been posted.

    CURSOR cur_appl             (cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS

      SELECT appl.rowid row_id, appl.*
      FROM   igs_fi_applications appl
      WHERE  appl.gl_date IS NOT NULL
      AND    TRUNC(appl.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
      AND    appl.posting_id IS NULL
      AND    appl.posting_control_id IS NULL
      ORDER BY gl_date
      FOR UPDATE OF gl_posted_date NOWAIT;


    -- Get the details like Effective date and Currency Code from the Credit table with the given credit id.
    CURSOR cur_credit (cp_credit_id igs_fi_applications.credit_id%TYPE ) IS
      SELECT currency_cd
      FROM   igs_fi_credits
      WHERE   credit_id = cp_credit_id;


    l_b_exception_flag   BOOLEAN := FALSE;

    l_v_cr_account_cd  igs_fi_applications.cr_account_cd%TYPE;
    l_v_dr_account_cd  igs_fi_applications.dr_account_cd%TYPE;
    l_n_amount         igs_fi_applications.amount_applied%TYPE;
    l_v_posting_rowid  ROWID;
    l_n_posting_id     igs_fi_posting_int.posting_id%TYPE;
    l_v_currency_cd    igs_fi_credits.currency_cd%TYPE;

  BEGIN


    FOR app_rec IN cur_appl( p_d_gl_date_start, p_d_gl_date_end) LOOP
           -- Looping through each of these records selected , check if the AMOUNT_APPLIED fetched is negative.
           --If negative, then make the AMOUNT positive (Eg. -50 to 50) and swap the values of debit and credit account codes.
           --(Value of DR_ACCOUNT_CD  to Value of CR_ACCOUNT_CD).

           IF app_rec.amount_applied < 0 THEN
                l_n_amount := ((-1) * app_rec.amount_applied);
                -- Swapping
                l_v_cr_account_cd := app_rec.dr_account_cd;
                l_v_dr_account_cd := app_rec.cr_account_cd;
           ELSE
                l_n_amount :=  app_rec.amount_applied;
                l_v_cr_account_cd := app_rec.cr_account_cd;
                l_v_dr_account_cd := app_rec.dr_account_cd;
           END IF;

       -- get the currency code from the credits table
        OPEN cur_credit (app_rec.credit_id);
        FETCH cur_credit INTO l_v_currency_cd;
        CLOSE  cur_credit;

        -- Insert into the posting int table wiht the selected transaction
      l_v_posting_rowid := NULL;
      l_n_posting_id := NULL;
      BEGIN
      -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
        igs_fi_posting_int_pkg.insert_row (
                                        x_rowid                        => l_v_posting_rowid,
                                        x_posting_control_id           => g_n_posting_control_id,
                                        x_posting_id                   => l_n_posting_id,
                                        x_batch_name                   => NULL,
                                        x_accounting_date              => app_rec.gl_date,
                                        x_transaction_date             => app_rec.apply_date,
                                        x_currency_cd                  => l_v_currency_cd,
                                        x_dr_account_cd                => l_v_dr_account_cd,
                                        x_cr_account_cd                => l_v_cr_account_cd,
                                        x_dr_gl_code_ccid              => NULL,
                                        x_cr_gl_code_ccid              => NULL,
                                        x_amount                       => igs_fi_gen_gl.get_formatted_amount(l_n_amount),
                                        x_source_transaction_id        => app_rec.application_id,
                                        x_source_transaction_type      => g_application,
                                        x_status                       => g_todo,
                                        x_orig_appl_fee_ref            => NULL,
                                        x_mode                         => 'R'
                                        );
      EXCEPTION
        WHEN OTHERS THEN
        l_b_exception_flag := TRUE;
      END;


        -- Update the  Applications table - posting_control_id and the log file

           IF NOT l_b_exception_flag THEN

                   update_log_file
                       (p_txn_date       => app_rec.apply_date,
                        p_amount         => l_n_amount,
                        p_txn_id         => app_rec.application_id,
                        p_dr_acc_code    => l_v_dr_account_cd,
                        p_cr_acc_code    => l_v_cr_account_cd,
                        p_src_txn_type   => g_application);

                  BEGIN
                    igs_fi_applications_pkg.update_row(
                                      x_rowid                          => app_rec.row_id,
                                      x_application_id                 => app_rec.application_id,
                                      x_application_type               => app_rec.application_type,
                                      x_invoice_id                     => app_rec.invoice_id,
                                      x_credit_id                      => app_rec.credit_id,
                                      x_credit_activity_id             => app_rec.credit_activity_id,
                                      x_amount_applied                 => app_rec.amount_applied,
                                      x_apply_date                     => app_rec.apply_date,
                                      x_link_application_id            => app_rec.link_application_id,
                                      x_dr_account_cd                  => app_rec.dr_account_cd,
                                      x_cr_account_cd                  => app_rec.cr_account_cd,
                                      x_dr_gl_code_ccid                => app_rec.dr_gl_code_ccid,
                                      x_cr_gl_code_ccid                => app_rec.cr_gl_code_ccid,
                                      x_applied_invoice_lines_id       => app_rec.applied_invoice_lines_id,
                                      x_appl_hierarchy_id              => app_rec.appl_hierarchy_id,
                                      x_posting_id                     => l_n_posting_id,
                                      x_posting_control_id             => g_n_posting_control_id,
                                      x_gl_date                        => app_rec.gl_date,
                                      x_gl_posted_date                 => p_d_gl_posted_date,
                                      x_mode                           => 'R'
                                      );
                  END;
                   -- Total Records Processed Counter.....
                  g_n_rec_processed := g_n_rec_processed + 1;
           END IF;

        -- Reseting flag if exception has occured for previous_record.
         l_b_exception_flag := FALSE;
    END LOOP;

  EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXP');
        --Unhandled Exception Raised in Procedure NAME
        fnd_message.set_token('NAME','IGS_FI_POSTING_INTERFACE.TRANSFER_APPL_TXNS');
        fnd_file.put_line( fnd_file.log, fnd_message.get() || sqlerrm);
        app_exception.raise_exception;

  END transfer_appl_txns;


 PROCEDURE transfer_chgs_txns(
                                 p_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_posted_date   IN  igs_fi_posting_int_all.accounting_date%TYPE
                                 ) AS
    /*
    ||  Created By : brajendr
    ||  Created On : 24-Apr-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  abshriva        12-May-2006     Enh#5217319 Precision Issue. Amount values being inserted into igs_fi_posting_int
    ||                                  and igs_fi_invln_int is now rounded off to currency precision
    ||  svuppala      30-MAY-2005       Enh 3442712 - Done the TBH modifications by adding
    ||                                  new columns Unit_Type_Id, Unit_Level in igs_fi_invln_int_all
    ||  Sykrishn        01-NOV/2002     Gl Interface TD modifications...
    ||                                  The below history is nt valid as the local procedure is revamped completely
    ||  agairola        21 Apr 2002     Initialised the lrec_posting_int
    ||                                  for bugs 2326595, 2309929, 2310806
    ||  agairola        10-Apr-2002     Added the code for the printing of message in case of
    ||                                  no records being found and also for the common procedure
    ||                                  for logging messages for bugs 2326595, 2309929, 2310806
    ||  jbegum          25 Feb 02       As part of Enh bug # 2238226
    ||                                  Added column orig_appl_fee_ref to the
    ||                                  IGS_FI_POSTING_INT_PKG.insert_row
    ||  (reverse chronological order - newest change first)
    */

    -- Get all the invoice lines records, where GL_DATE lies b/w the passedg date ranges that have not been posted.

    CURSOR cur_inv      (cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                         cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS
      SELECT invln.rowid row_id, inv.invoice_creation_date, inv.currency_cd, invln.*
      FROM igs_fi_invln_int_all invln,
           igs_fi_inv_int_all inv
      WHERE  invln.gl_date IS NOT NULL
      AND    TRUNC(invln.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
      AND    invln.posting_id IS NULL
      AND    invln.posting_control_id IS NULL
      AND    inv.invoice_id = invln.invoice_id
      AND    NVL(invln.error_account,'N') = 'N'
      ORDER BY gl_date
      FOR UPDATE OF gl_posted_date NOWAIT;



    l_b_exception_flag   BOOLEAN := FALSE;

    l_v_cr_account_cd  igs_fi_invln_int_all.rev_account_cd%TYPE;
    l_v_dr_account_cd  igs_fi_invln_int_all.rec_account_cd%TYPE;
    l_n_amount         igs_fi_invln_int_all.amount%TYPE;
    l_v_posting_rowid  ROWID;
    l_n_posting_id     igs_fi_posting_int.posting_id%TYPE;

  BEGIN


    FOR inv_rec IN cur_inv( p_d_gl_date_start, p_d_gl_date_end) LOOP
           -- Looping through each of these records selected , check if the AMOUNT fetched is negative.
           --If negative, then make the AMOUNT positive (Eg. -50 to 50) and swap the values of debit and credit account codes.
           --(Value of REC_ACCOUNT_CD  to Value of REV_ACCOUNT_CD).

           -- NOTE: According to the present functionality this case would never occur. Code kept for future cases if any

           IF inv_rec.amount < 0 THEN
                l_n_amount := ((-1) * inv_rec.amount);
                -- Swapping
                l_v_cr_account_cd := inv_rec.rec_account_cd;
                l_v_dr_account_cd := inv_rec.rev_account_cd;
           ELSE
                l_n_amount :=  inv_rec.amount;
                l_v_cr_account_cd := inv_rec.rev_account_cd;
                l_v_dr_account_cd := inv_rec.rec_account_cd;
           END IF;
        -- Insert into the posting int table , the selected transaction
              l_v_posting_rowid := NULL;
              l_n_posting_id := NULL;
      BEGIN
      -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
        igs_fi_posting_int_pkg.insert_row (
                                        x_rowid                        => l_v_posting_rowid,
                                        x_posting_control_id           => g_n_posting_control_id,
                                        x_posting_id                   => l_n_posting_id,
                                        x_batch_name                   => NULL,
                                        x_accounting_date              => inv_rec.gl_date,
                                        x_transaction_date             => inv_rec.invoice_creation_date,
                                        x_currency_cd                  => inv_rec.currency_cd,
                                        x_dr_account_cd                => l_v_dr_account_cd,
                                        x_cr_account_cd                => l_v_cr_account_cd,
                                        x_dr_gl_code_ccid              => NULL,
                                        x_cr_gl_code_ccid              => NULL,
                                        x_amount                       => igs_fi_gen_gl.get_formatted_amount(l_n_amount),
                                        x_source_transaction_id        => inv_rec.invoice_lines_id,
                                        x_source_transaction_type      => g_charge,
                                        x_status                       => g_todo,
                                        x_orig_appl_fee_ref            => NULL,
                                        x_mode                         => 'R'
                                        );
      EXCEPTION
        WHEN OTHERS THEN
        l_b_exception_flag := TRUE;
      END;

        -- Update the  Invoice Lines Table table - posting_control_id and also the log file

           IF NOT l_b_exception_flag THEN

                   update_log_file
                       (p_txn_date       => inv_rec.invoice_creation_date,
                        p_amount         => l_n_amount,
                        p_txn_id         => inv_rec.invoice_lines_id,
                        p_dr_acc_code    => l_v_dr_account_cd,
                        p_cr_acc_code    => l_v_cr_account_cd,
                        p_src_txn_type   => g_charge);

                  BEGIN
                  -- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
                         igs_fi_invln_int_pkg.update_row(
                                  x_rowid                         => inv_rec.row_id,
                                  x_invoice_lines_id              => inv_rec.invoice_lines_id,
                                  x_invoice_id                    => inv_rec.invoice_id,
                                  x_line_number                   => inv_rec.line_number,
                                  x_s_chg_method_type             => inv_rec.s_chg_method_type,
                                  x_description                   => inv_rec.description,
                                  x_chg_elements                  => inv_rec.chg_elements,
                                  x_amount                        => igs_fi_gen_gl.get_formatted_amount(inv_rec.amount),
                                  x_unit_attempt_status           => inv_rec.unit_attempt_status,
                                  x_eftsu                         => inv_rec.eftsu,
                                  x_credit_points                 => inv_rec.credit_points,
                                  x_attribute_category            => inv_rec.attribute_category,
                                  x_attribute1                    => inv_rec.attribute1,
                                  x_attribute2                    => inv_rec.attribute2,
                                  x_attribute3                    => inv_rec.attribute3,
                                  x_attribute4                    => inv_rec.attribute4,
                                  x_attribute5                    => inv_rec.attribute5,
                                  x_attribute6                    => inv_rec.attribute6,
                                  x_attribute7                    => inv_rec.attribute7,
                                  x_attribute8                    => inv_rec.attribute8,
                                  x_attribute9                    => inv_rec.attribute9,
                                  x_attribute10                   => inv_rec.attribute10,
                                  x_rec_account_cd                => inv_rec.rec_account_cd,
                                  x_rev_account_cd                => inv_rec.rev_account_cd,
                                  x_rec_gl_ccid                   => inv_rec.rec_gl_ccid,
                                  x_rev_gl_ccid                   => inv_rec.rev_gl_ccid,
                                  x_org_unit_cd                   => inv_rec.org_unit_cd,
                                  x_posting_id                    => l_n_posting_id,
                                  x_attribute11                   => inv_rec.attribute11,
                                  x_attribute12                   => inv_rec.attribute12,
                                  x_attribute13                   => inv_rec.attribute13,
                                  x_attribute14                   => inv_rec.attribute14,
                                  x_attribute15                   => inv_rec.attribute15,
                                  x_attribute16                   => inv_rec.attribute16,
                                  x_attribute17                   => inv_rec.attribute17,
                                  x_attribute18                   => inv_rec.attribute18,
                                  x_attribute19                   => inv_rec.attribute19,
                                  x_attribute20                   => inv_rec.attribute20,
                                  x_error_account                 => inv_rec.error_account,
                                  x_error_string                  => inv_rec.error_string,
                                  x_location_cd                   => inv_rec.location_cd,
                                  x_uoo_id                        => inv_rec.uoo_id,
                                  x_posting_control_id            => g_n_posting_control_id,
                                  x_gl_date                       => inv_rec.gl_date,
                                  x_gl_posted_date                => p_d_gl_posted_date,
                                  x_mode                          => 'R',
                                  x_unit_type_id                  => inv_rec.unit_type_id,
                                  x_unit_level                    => inv_rec.unit_level
                                );
                  END;

                   -- Total Records Processed Counter.....
                  g_n_rec_processed := g_n_rec_processed + 1;
             END IF;

        -- Reseting flag if exception has occured for previous_record.
         l_b_exception_flag := FALSE;

    END LOOP;

  EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXP');
        --Unhandled Exception Raised in Procedure NAME
        fnd_message.set_token('NAME','IGS_FI_POSTING_INTERFACE.TRANSFER_CHGS_TXNS');
        fnd_file.put_line( fnd_file.log, fnd_message.get() || sqlerrm);
        app_exception.raise_exception;
  END transfer_chgs_txns;

   PROCEDURE transfer_ad_appl_fee_txns(
                                 p_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE,
                                 p_d_gl_posted_date   IN  igs_fi_posting_int_all.accounting_date%TYPE
                                 ) AS
    /*
    ||  Created By : SYKRISHN
    ||  Created On : 01-NOV/2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  abshriva        12-May-2006     Enh#5217319 Precision Issue. Amount values being inserted into igs_fi_posting_int
    ||                                  is now rounded off to currency precision
    ||  vvutukur        09-Oct-2003     Bug#3160036.Replaced call to igs_ad_app_req.update_row with
    ||                                  call to igs_ad_gen_015.update_igs_ad_app_req.
    ||  pathipat        14-Jun-2003     Enh 2831587 Credit Card Fund Transfer build
    ||                                  Modified call to igs_ad_app_req_pkg.update_row()
    ||  Sykrishn        01-NOV/2002     Created this procedure - as part of Gl Interface TD modifications (NEW)
    ||  (reverse chronological order - newest change first)
    */

    -- Get all the non-posted admission application fee  records, where GL_DATE lies b/w the passedg date ranges that have not been posted.
    -- Only posting control id needs to be checked in this case



    CURSOR cur_adm_fee  (cp_d_gl_date_start    IN  igs_fi_posting_int_all.accounting_date%TYPE,
                         cp_d_gl_date_end      IN  igs_fi_posting_int_all.accounting_date%TYPE ) IS
      SELECT adm.rowid row_id,adm.*
      FROM igs_ad_app_req adm
      WHERE  adm.gl_date IS NOT NULL
      AND    TRUNC(adm.gl_date) BETWEEN TRUNC(cp_d_gl_date_start) AND TRUNC(cp_d_gl_date_end)
      AND    adm.posting_control_id IS NULL
      ORDER BY gl_date
      FOR UPDATE OF gl_posted_date NOWAIT;


     -- Cursor to get admission application id
     CURSOR cur_app_id  (cp_person_id IN igs_fi_parties_v.person_id%TYPE,
                         cp_admission_appl_number IN  igs_ad_app_req.admission_appl_number%TYPE) IS
       SELECT application_id
       FROM  igs_ad_appl
       WHERE person_id = cp_person_id
       AND   admission_appl_number = cp_admission_appl_number;

    l_b_exception_flag   BOOLEAN := FALSE;
    l_v_posting_rowid  ROWID;
    l_n_posting_id     igs_fi_posting_int.posting_id%TYPE;
    l_v_currency_cd    igs_fi_control_all.currency_cd%TYPE := igs_fi_gen_gl.finp_ss_get_cur;
    l_v_orig_appl_fee_ref  igs_fi_posting_int_all.orig_appl_fee_ref%TYPE;
    l_n_application_id  igs_ad_appl.application_id%TYPE;

  BEGIN


    FOR ad_app_rec IN cur_adm_fee( p_d_gl_date_start, p_d_gl_date_end) LOOP

        -- Derive the _orig_appl_fee_ref as Admission Application ID : <Admission Application ID>; Party Number : <Party Number >

      OPEN  cur_app_id (cp_person_id => ad_app_rec.person_id,
                        cp_admission_appl_number => ad_app_rec.admission_appl_number);
      FETCH cur_app_id  INTO   l_n_application_id;
      CLOSE cur_app_id;

      l_v_orig_appl_fee_ref := lookup_desc('IGS_FI_SOURCE_TRANSACTION_TYPE',g_applfee)||' : '|| TO_CHAR(l_n_application_id)||' ; '||lookup_desc('IGS_FI_LOCKBOX','PARTY')||' : '||get_party_num(p_party_id => ad_app_rec.person_id);

        -- Insert into the posting int table , the selected transaction
      l_v_posting_rowid := NULL;
      l_n_posting_id := NULL;
      BEGIN
      -- Call to igs_fi_gen_gl.get_formatted_amount formats fee_amount by rounding off to currency precision
        igs_fi_posting_int_pkg.insert_row (
                                        x_rowid                        => l_v_posting_rowid,
                                        x_posting_control_id           => g_n_posting_control_id,
                                        x_posting_id                   => l_n_posting_id,
                                        x_batch_name                   => NULL,
                                        x_accounting_date              => ad_app_rec.gl_date,
                                        x_transaction_date             => ad_app_rec.fee_date,
                                        x_currency_cd                  => l_v_currency_cd,
                                        x_dr_account_cd                => ad_app_rec.cash_account_cd,
                                        x_cr_account_cd                => ad_app_rec.rev_account_cd,
                                        x_dr_gl_code_ccid              => NULL,
                                        x_cr_gl_code_ccid              => NULL,
                                        x_amount                       => igs_fi_gen_gl.get_formatted_amount(ad_app_rec.fee_amount),
                                        x_source_transaction_id        => NULL,
                                        x_source_transaction_type      => g_applfee,
                                        x_status                       => g_todo,
                                        x_orig_appl_fee_ref            => l_v_orig_appl_fee_ref,
                                        x_mode                         => 'R'
                                        );
      EXCEPTION
        WHEN OTHERS THEN
        l_b_exception_flag := TRUE;
      END;

        -- Update the  igs_ad_app_req table - posting_control_id and also the log file

           IF NOT l_b_exception_flag THEN

                   update_log_file
                       (p_txn_date       => ad_app_rec.fee_date,
                        p_amount         => ad_app_rec.fee_amount,
                        p_txn_id         => l_n_application_id,
                        p_dr_acc_code    => ad_app_rec.cash_account_cd,
                        p_cr_acc_code    => ad_app_rec.rev_account_cd,
                        p_src_txn_type   => g_applfee);

                  BEGIN

                    igs_ad_gen_015.update_igs_ad_app_req(
                          p_rowid                         => ad_app_rec.row_id,
                          p_app_req_id                    => ad_app_rec.app_req_id,
                          p_person_id                     => ad_app_rec.person_id,
                          p_admission_appl_number         => ad_app_rec.admission_appl_number,
                          p_applicant_fee_type            => ad_app_rec.applicant_fee_type,
                          p_applicant_fee_status          => ad_app_rec.applicant_fee_status,
                          p_fee_date                      => ad_app_rec.fee_date,
                          p_fee_payment_method            => ad_app_rec.fee_payment_method,
                          p_fee_amount                    => ad_app_rec.fee_amount,
                          p_reference_num                 => ad_app_rec.reference_num,
                          p_credit_card_code              => ad_app_rec.credit_card_code,
                          p_credit_card_holder_name       => ad_app_rec.credit_card_holder_name,
                          p_credit_card_number            => ad_app_rec.credit_card_number,
                          p_credit_card_expiration_date   => ad_app_rec.credit_card_expiration_date,
                          p_rev_gl_ccid                   => ad_app_rec.rev_gl_ccid,
                          p_cash_gl_ccid                  => ad_app_rec.cash_gl_ccid,
                          p_rev_account_cd                => ad_app_rec.rev_account_cd,
                          p_cash_account_cd               => ad_app_rec.cash_account_cd,
                          p_posting_control_id            => g_n_posting_control_id,
                          p_gl_date                       => ad_app_rec.gl_date,
                          p_gl_posted_date                => p_d_gl_posted_date,
                          p_credit_card_tangible_cd       => ad_app_rec.credit_card_tangible_cd,
                          p_credit_card_payee_cd          => ad_app_rec.credit_card_payee_cd,
                          p_credit_card_status_code       => ad_app_rec.credit_card_status_code,
                          p_mode                          => 'R'
                          );

                  END;
                   -- Total Records Processed Counter.....
                  g_n_rec_processed := g_n_rec_processed + 1;
           END IF;

        -- Reseting flag if exception has occured for previous_record.
         l_b_exception_flag := FALSE;

    END LOOP;

  EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXP');
        --Unhandled Exception Raised in Procedure NAME
        fnd_message.set_token('NAME','IGS_FI_POSTING_INTERFACE.TRANSFER_AD_APPL_FEE_TXNS');
        fnd_file.put_line( fnd_file.log, fnd_message.get() || sqlerrm);
        app_exception.raise_exception;
  END transfer_ad_appl_fee_txns;


  PROCEDURE derive_comments (
                       p_transaction_id     IN   igs_fi_posting_int_all.source_transaction_id%TYPE,
                       p_transaction_type   IN   igs_fi_posting_int_all.source_transaction_type%TYPE,
                       p_transaction_number OUT NOCOPY  VARCHAR2,
                       p_comments           OUT NOCOPY  ra_interface_lines_all.comments%TYPE
                         ) AS
        /*
        ||  Created By : sykrishn
        ||  Created On : 18-FEB-2002
        ||  Purpose : To Derive the comments for insert
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  agairola        21 Apr 2002     Added the new out NOCOPY parameter transaction number for the
        ||                                  transaction number derivation for bugs 2326595, 2309929,
        ||                                  2310806
        ||  sykrishn        18-FEB-2002     As per build of SFCR023 - 2227831
        ||
        ||  (reverse chronological order - newest change first)
        */

--Cursor to fetch the invoice number for the passed invoice_id
 CURSOR cur_charge (cp_transaction_id    IN   igs_fi_posting_int_all.source_transaction_id%TYPE) IS
  SELECT inv.invoice_number
  FROM igs_fi_inv_int inv, igs_fi_invln_int invln
  WHERE invln.invoice_lines_id = cp_transaction_id
  AND   inv.invoice_id = invln.invoice_id;

--Cursor to fetch the credit number for the passed credit_id
 CURSOR cur_credit(cp_transaction_id    IN   igs_fi_posting_int_all.source_transaction_id%TYPE) IS
  SELECT crd.credit_number
  FROM   igs_fi_credits crd,
         igs_fi_cr_activities cra
  WHERE  cra.credit_activity_id = cp_transaction_id
  AND    crd.credit_id = cra.credit_id;

--Cursor to fetch the credit id and invoice id for the passed application id
 CURSOR cur_appl(cp_transaction_id    IN   igs_fi_posting_int_all.source_transaction_id%TYPE)  IS
  SELECT crd.credit_number,
         inv.invoice_number
  FROM   igs_fi_applications app,
         igs_fi_credits crd,
         igs_fi_inv_int inv
  WHERE  application_id  = cp_transaction_id
  AND    app.credit_id = crd.credit_id
  AND    app.invoice_id = inv.invoice_id;

 l_v_comments ra_interface_lines_all.comments%TYPE := NULL;
 l_v_invoice_number igs_fi_inv_int.invoice_number%TYPE;
 l_v_credit_number  igs_fi_credits.credit_number%TYPE;

 BEGIN
 -- Setup the comments with the passes transaction types meaning and colon :
 l_v_comments := lookup_desc('IGS_FI_SOURCE_TRANSACTION_TYPE',p_transaction_type)||':';

  IF p_transaction_type = g_charge THEN
    OPEN  cur_charge (p_transaction_id);
    FETCH cur_charge INTO l_v_invoice_number;
    CLOSE cur_charge;
    l_v_comments  := l_v_comments || l_v_invoice_number;
    p_transaction_number     := l_v_invoice_number;
    --A sample comments will look like 'Charge: Charge Number1
  ELSIF p_transaction_type = g_credit THEN
    OPEN  cur_credit (p_transaction_id);
    FETCH cur_credit INTO l_v_credit_number;
    CLOSE cur_credit;
    l_v_comments  := l_v_comments || l_v_credit_number;
    p_transaction_number     := l_v_credit_number;
    --A sample comments will look like 'Credit: Credit Number1'

  ELSIF p_transaction_type = g_applfee THEN
    p_transaction_number     := TO_CHAR(p_transaction_id);
  -- Application ID would be the Transaction Number when APPLFEE

  ELSIF p_transaction_type = g_application THEN
    OPEN cur_appl(p_transaction_id);
    FETCH cur_appl INTO l_v_credit_number,
                        l_v_invoice_number;
    CLOSE cur_appl;

    p_transaction_number := l_v_credit_number||'-'||l_v_invoice_number;
       -- The comments variable is setup  a sample will look like
       -- Application:Credit <credit number>-Charge <Charge Number>
       l_v_comments  := l_v_comments||lookup_desc('IGS_FI_SOURCE_TRANSACTION_TYPE',g_credit)||' '||l_v_credit_number||'-'||
                        lookup_desc('IGS_FI_SOURCE_TRANSACTION_TYPE',g_charge)||' '|| l_v_invoice_number;

  END IF;
   -- Since the comments column in the table ra_interface_lines is only 240 - We need to substring it to 240.
  p_comments :=   substr(l_v_comments,1,240);
  END derive_comments;

  FUNCTION get_log_line(p_lookup_code             igs_lookups_view.lookup_code%TYPE,
                        p_value                   VARCHAR2) RETURN VARCHAR2 AS
  /******************************************************************
  Created By        : agairola
  Date Created By   : 04-May-2002
  Purpose           : Local function for comparing and getting the value for log file

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/

    l_data     VARCHAR2(2000);

  BEGIN
    l_data := lookup_desc('IGS_FI_LOCKBOX',
                          p_lookup_code)||' : '||p_value;
    RETURN l_data;
  END get_log_line;

  FUNCTION get_int_val(p_column_name              VARCHAR2,
                       p_column_value             VARCHAR2) RETURN VARCHAR2 AS
  /******************************************************************
  Created By        : agairola
  Date Created By   : 17-Apr-2002
  Purpose           : Local function for comparing and getting the value for the
                      Interface Line Attribute

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
   ******************************************************************/

    l_ret_val     VARCHAR2(20);
  BEGIN
    l_ret_val := NULL;

-- If the value passed for the column name matches with the global variable
-- for the Interface Line Attribute, then return the value passed as p_column_value
    IF g_interface_attr = p_column_name THEN
      l_ret_val := p_column_value;
    END IF;

    RETURN l_ret_val;
  END get_int_val;


  PROCEDURE transfer_posting(
                             ERRBUF               OUT NOCOPY  VARCHAR2,
                             RETCODE              OUT NOCOPY  NUMBER,
                             p_batch_name         IN  igs_fi_posting_int_all.batch_name%TYPE,
                             p_posting_date_low   IN  VARCHAR2,
                             p_posting_date_high  IN  VARCHAR2,
                             p_org_id             IN  igs_fi_posting_int_all.org_id%TYPE
                             ) AS
        /*
        ||  Created By : brajendr
        ||  Created On : 24-Apr-2001
        ||  Purpose :
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  pathipat        23-Apr-2003     Enh 2831569 - Commercial Receivables
        ||                                  Process has been obsoleted, removed code.
        ||  agairola        04-May-2002     Modified the log file format from Tabular to
        ||                                  multiline
        ||  agairola        17-Apr-2002     Modified the code for the INTERFACE_LINE_ATTRIBUTE
        ||                                  for bugs 2326595, 2309929, 2310806
        ||  agairola        12-Apr-2002     Displaying party number in case of erros while creating customer account
        ||                                  for bugs 2326595, 2309929, 2310806
        ||  agairola        11-Apr-2002     Added the code in case the description is NULL, it is equated to
        ||                                  the comments. Also, removed the commit statement from inside the
        ||                                  cur_postings as cur_postings has a FOR UPDATE NOWAIT clause
        ||                                  for bugs 2326595, 2309929, 2310806
        ||  agairola        10_Apr-2002     Modified the cursor cur_postings to include brackets for
        ||                                  Batch name. Also, added the FOR UPDATE NOWAIT, exception and
        ||                                  appropriate exception handling for the locking. Removed the
        ||                                  commit from inside the begin end block for inserting records
        ||                                  in the RA_INTERFACE_LINES_ALL table.
        ||                                  for bugs 2326595, 2309929, 2310806
        ||  jbegum          25 Feb 02       As part of Enh bug #2238226
        ||                                  Added code to copy value of the field orig_appl_fee_ref to
        ||                                  comments field of RA_INTERFACE_LINES_ALL when
        ||                                  source_transaction_type is APPLFEE
        ||                                  Added column orig_appl_fee_ref to the
        ||                                  IGS_FI_POSTING_INT_PKG.update_row
        ||  sykrishn        19 Feb 02       As part of Enh bug #2227831
        ||                                  Changes related to get_customer_details
        ||  jbegum          16 Feb 02       As part of Enh bug #2222272
        ||                                  Set org id of transactions created
        ||                                  in the Receivables Invoice Interface tables
        ||                                  to the org id value obtained from control table
        ||  (reverse chronological order - newest change first)
        */

  BEGIN

      -- This process has been obsoleted as part of Commercial Receivables TD
      fnd_message.set_name('IGS', 'IGS_GE_OBSOLETE_JOB');
      fnd_file.put_line( fnd_file.log, fnd_message.get());
      retcode := 0;

  EXCEPTION
    WHEN OTHERS THEN
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||SQLERRM;
       igs_ge_msg_stack.conc_exception_hndl;

  END transfer_posting;


  PROCEDURE posting_interface(
                               errbuf               OUT NOCOPY  VARCHAR2,
                               retcode              OUT NOCOPY  NUMBER,
                               p_posting_date_low   IN   VARCHAR2,
                               p_posting_date_high  IN   VARCHAR2,
                               p_accounting_date    IN   VARCHAR2) AS
    /*
    ||  Created By : brajendr
    ||  Created On : 24-Apr-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  abshriva        5-May-2006      Bug 5178077: Introduced igs_ge_gen_003.set_org_id
    ||  pathipat        23-Apr-2003     Enh 2831569 - Commercial Receivables build
    ||                                  Added check for manage_Accounts. Replaced app_exception.raise_exception
    ||                                  with raise l_user_exception to avoid 'Unhandled exp' in log file
    ||  Sykrishn        01/NOV/02       Build Bug 2584986 - GL interface Build Modifications....  (Revamp)
                                        Refer TD for Modifications
    ||  agairola        17-Apr-2002     Modified the Log file display
    ||                                  for bugs 2326595, 2309929, 2310806
    ||  schodava        8-OCT-2001      Enh # 2030448 (SFCR002)
    */


    l_d_gl_date_start         igs_fI_applications.gl_date%TYPE;
    l_d_gl_date_end           igs_fI_applications.gl_date%TYPE;
    l_d_gl_posted_date        igs_fI_applications.gl_date%TYPE;
    l_org_id                  VARCHAR2(15);
    CURSOR cur_gen_control_id IS
    SELECT igs_fi_posting_control_s.nextval
    FROM dual;

    l_v_manage_acc      igs_fi_control_all.manage_accounts%TYPE  := NULL;
    l_v_message_name    fnd_new_messages.message_name%TYPE       := NULL;
    l_user_exception    EXCEPTION;

  BEGIN
    BEGIN
       l_org_id := NULL;
       igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         retcode:=2;
         RETURN;
    END;
    retcode:= 0;

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                               );
    IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
       fnd_message.set_name('IGS',l_v_message_name);
       fnd_file.put_line(fnd_file.log,fnd_message.get());
       fnd_file.put_line(fnd_file.log,' ');
       RAISE l_user_exception;
    END IF;

   -- Get the value of of financials Insalled value defined in System Options form.
       IF igs_fi_gen_005.finp_get_receivables_inst = 'Y' THEN
          --This process is not valid.  This process is only valid when using Oracle Financials "NO"
            fnd_message.set_name('IGS', 'IGS_FI_INVALID_PROCESS');
            fnd_message.set_token('YES_NO', lookup_desc('YES_NO','N'));
            fnd_file.put_line(fnd_file.log, fnd_message.get());
            RAISE l_user_exception;
        END IF;

    -- Convert the varchar2 parameter dates to DATE Datatype if not null else raise insufficient parameter error.

    IF p_posting_date_low IS NOT NULL THEN
       l_d_gl_date_start  := igs_ge_date.igsdate(p_posting_date_low);
    ELSE
       fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
       fnd_file.put_line(fnd_file.log, fnd_message.get());
       RAISE l_user_exception;
    END IF;

    IF p_posting_date_high IS NOT NULL THEN
       l_d_gl_date_end  := igs_ge_date.igsdate(p_posting_date_high);
    ELSE
       fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
       fnd_file.put_line(fnd_file.log, fnd_message.get());
       RAISE l_user_exception;
    END IF;

    IF p_accounting_date IS NOT NULL THEN
       l_d_gl_posted_date  := igs_ge_date.igsdate(p_accounting_date);
    ELSE
       fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
       fnd_file.put_line(fnd_file.log, fnd_message.get());
       RAISE l_user_exception;
    END IF;


    -- Validate if the GL date End is lesser than GL Date start
    -- The GL Date End should not be earlier than the GL Date Start  'START_DATE'

    IF TRUNC(l_d_gl_date_start) > TRUNC(l_d_gl_date_end) THEN
      fnd_message.set_name('IGS','IGS_FI_VAL_GL_END_DATE');
      fnd_message.set_token('START_DATE',l_d_gl_date_start);
      fnd_file.put_line( fnd_file.log, fnd_message.get());
      RAISE l_user_exception;
    END IF;

      -- Generate the batch posting control - id only once per process run ()..
        OPEN  cur_gen_control_id;
        FETCH cur_gen_control_id INTO g_n_posting_control_id;
        CLOSE cur_gen_control_id;

     fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
     fnd_file.put_line(fnd_file.log, get_log_line('SYS_DATE',TO_CHAR(SYSDATE)));
     fnd_file.put_line(fnd_file.log, get_log_line('GL_DT_START',TO_CHAR(l_d_gl_date_start)));
     fnd_file.put_line(fnd_file.log, get_log_line('GL_DT_END',TO_CHAR(l_d_gl_date_end)));
     fnd_file.put_line(fnd_file.log, get_log_line('GL_POSTED_DT',TO_CHAR(l_d_gl_posted_date)));
     fnd_file.put_line(fnd_file.log, get_log_line('POSTING_CTRL_ID',TO_CHAR(g_n_posting_control_id)));
     fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');


    -- Log the heading for the log file  "Summary of Transactions posted to Posting Interface"
      fnd_file.new_line(fnd_file.log);
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
      fnd_message.set_name('IGS','IGS_FI_POST_SUM_TRANS');
      fnd_file.put_line( fnd_file.log, fnd_message.get());
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');

    -- For both the cases, i.e. when Accounting Method is 'CASH' or 'ACCRUAL' the Credit Activities Transactions, Applications Transactions and Admission Application fees transactions need to be posted.
    -- For this invoke the local procedures TRANSFER_CREDIT_ACT_TXNS, TRANSFER_APPL_TXNS and TRANSFER_AD_APPL_FEE_TXNS.
    -- Hence no derivation and checking of accounting method required at this stage.


        transfer_credit_act_txns( p_d_gl_date_start => l_d_gl_date_start,
                                  p_d_gl_date_end      => l_d_gl_date_end,
                                  p_d_gl_posted_date   =>  l_d_gl_posted_date);

        COMMIT;



        transfer_appl_txns      ( p_d_gl_date_start => l_d_gl_date_start,
                                  p_d_gl_date_end      => l_d_gl_date_end,
                                  p_d_gl_posted_date   =>  l_d_gl_posted_date);


        COMMIT;


        transfer_ad_appl_fee_txns( p_d_gl_date_start => l_d_gl_date_start,
                                  p_d_gl_date_end      => l_d_gl_date_end,
                                  p_d_gl_posted_date   =>  l_d_gl_posted_date);

        COMMIT;

   -- Only when Accounting Method is ACCRUAL, apart from posting the Credit Activities Transactions, Applications Transactions and Admission Application Fees Transactions,
   -- also the Charges Transactions need to be posted. - For this invoke the local procedure TRANSFER_CHGS_TXNS.

     -- Get the value of the accounting method defined in System Options form.
     IF igs_fi_gen_005.finp_get_acct_meth = g_accrual THEN

        transfer_chgs_txns       ( p_d_gl_date_start => l_d_gl_date_start,
                                   p_d_gl_date_end      => l_d_gl_date_end,
                                   p_d_gl_posted_date   =>  l_d_gl_posted_date);
        COMMIT;
     END IF;

      fnd_file.new_line(fnd_file.log);
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
      fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
      fnd_file.put_line(fnd_file.log, fnd_message.get()||TO_CHAR(g_n_rec_processed));

  EXCEPTION
     WHEN l_user_exception THEN
        ROLLBACK;
        retcode := 2;
     WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||sqlerrm;
       igs_ge_msg_stack.conc_exception_hndl;
  END posting_interface;


 END igs_fi_posting_process;

/
