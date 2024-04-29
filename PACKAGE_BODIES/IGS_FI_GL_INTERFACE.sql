--------------------------------------------------------
--  DDL for Package Body IGS_FI_GL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GL_INTERFACE" AS
/* $Header: IGSFI76B.pls 120.8 2006/05/26 13:19:45 skharida ship $ */
/* **********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This package contains the procedures for processing the GL Interface
  Known limitations,enhancements,remarks:
  Change History
  Who         When         What
  abshriva    12-May-2006  Bug 5217319: Amount precision change in insert_gl_int
  sapanigr    05-May-2006  Bug 5178077: Modified procedure transfer to disable process in R12.
  bannamal    05-Jul-2005  Enh# 3392095, Tuition Waivers Build.
                           Modified functions get_crd_cat, get_inv_cat, get_app_cat, validate_parm
                           and procedures transfer_credit, transfer_app for this build.
  svuppala    30-MAY-2005  Enh 3442712 - Done the TBH modifications by adding
                           new columns Unit_Type_Id, Unit_Level in igs_fi_invln_int_all
  vvutukur    11-Dec-2003  Bug#3310756.Modified procedures transfer_credit,igs_ad_appl.
  shtatiko    18-NOV-2003  Enh# 3256915, modified get_crd_cat and get_app_cat
  vvutukur    09-Oct-2003  Bug#3160036. Modified procedure transfer_admapp.
  pathipat    14-Jun-2003  Enh 2831587 - Credit Card Fund Transfer build
                           Modified transfer_admapp() - modified call to igs_ad_app_req_pkg.update_row()
  shtatiko    22-APR-2003  Enh# 2831569, Modified validate_parm.
  agairola    27-Jan-2003  Bug 2711195: Modified the generate_log and transfer procedures
  agairola    02-Jan-2003  Bug 2714777,2727324: Modified the process for the following
                           1. In the validate_parm procedure, if the rec_installed is set to N
                           then after logging the parameters, the process exits.
                           2. In the validate_parm procedure, the message name changed if the
                           run journal import is set to Y and the start date is in a period that
                           is closed.
  vchappid    20-Dec-2002  Bug 2720702: In the procedure transfer_charge, for cursor cur_chg,
                           NVL is missing while checking for Error Account. When the Error Account
                           is set to NULL, it has to be treated as a valid transaction
                           i.e. error_account is treated as 'N'
  agairola    16-Dec-02    Bug 2584741: Added the code for the Deposits in get_crd_cat

********************************************************************************************** */

g_v_rec_inst              igs_fi_control.rec_installed%TYPE;
g_n_sob_id                igs_fi_control.set_of_books_id%TYPE;
g_v_currency_cd           igs_fi_control.currency_cd%TYPE;
g_v_accounting_method     igs_fi_control.accounting_method%TYPE;
g_v_new                   CONSTANT  VARCHAR2(10) := 'NEW';
g_v_actual                CONSTANT  VARCHAR2(3) := 'A';
g_v_je_source_name        CONSTANT  VARCHAR2(80) := 'Student System';
g_v_user_je_src_name      gl_je_sources.user_je_source_name%TYPE;
g_n_batch_id              NUMBER(38);
g_v_cash                  CONSTANT VARCHAR2(6) := 'CASH';
g_v_adm_cat               CONSTANT VARCHAR2(25) := 'Application Fee';
g_v_aid                   CONSTANT VARCHAR2(10) := 'Aid';
g_v_charges               CONSTANT VARCHAR2(10) := 'Charges';
g_v_credits               CONSTANT VARCHAR2(10) := 'Credits';
g_v_deposits              CONSTANT VARCHAR2(10) := 'Deposits';
g_v_refund_offst          CONSTANT VARCHAR2(20) := 'Refund Offset';
g_v_transferred           CONSTANT VARCHAR2(15) := 'TRANSFERRED';
g_b_rec_found             BOOLEAN := FALSE;

g_v_party_number          igs_lookup_values.meaning%TYPE;
g_v_invoice_number        igs_lookup_values.meaning%TYPE;
g_v_credit_number         igs_lookup_values.meaning%TYPE;
g_v_application           igs_lookup_values.meaning%TYPE;

--Added the constant variable for Tuition Waivers Build
g_v_waiver      CONSTANT  VARCHAR2(10) :=  'Waivers';
g_v_post_waiver_gl_flag   igs_fi_control.post_waiver_gl_flag%TYPE;

PROCEDURE initialize IS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure will initialize the package variables
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What

********************************************************************************************** */

  CURSOR cur_gl_je_src(cp_je_src_name           gl_je_sources.je_source_name%TYPE) IS
    SELECT user_je_source_name
    FROM   gl_je_sources
    WHERE  je_source_name = cp_je_src_name;
BEGIN
  g_v_invoice_number := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                    'CHARGE_NUMBER');
  g_v_credit_number := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                   'CREDIT_NUMBER');
  g_v_party_number := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                  'PARTY');
  g_v_application := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_SOURCE_TRANSACTION_TYPE',
                                                 'APPLFEE');
  g_v_accounting_method := NULL;
  g_v_currency_cd := NULL;
  g_v_rec_inst := NULL;
  g_n_sob_id := NULL;
  g_n_batch_id := NULL;

  OPEN cur_gl_je_src(g_v_je_source_name);
  FETCH cur_gl_je_src INTO g_v_user_je_src_name;
  CLOSE cur_gl_je_src;

END initialize;

 FUNCTION get_crd_cat (p_n_credit_id IN NUMBER) RETURN VARCHAR2 AS

  /******************************************************************
  Created By        : agairola
  Date Created By   : 22-NOV-2002
  Purpose           : Function to get the source category name for the passed credit id
  Known limitations,  - Hard Coded texts are returned as per TD requriements.
  enhancements,
  remarks            :
  Change History
  Who      When        What
  bannamal 05-Jul-05   Bug# 3392095, Tuition Waivers Build.
                       Added condition to check whether credit class is WAIVER
  shtatiko 18-NOV-03   Bug# 3256915, Added INSTALLMENT_PAYMENTS when checking the credit class.
  agairola 16-Dec-02   Bug: 2584741 added the code for Deposits functionality
   ******************************************************************/

  CURSOR cur_cred (cp_n_credit_id IN igs_fi_credits.credit_id%TYPE)  IS
  SELECT crtype.credit_class
  FROM igs_fi_credits_all crd,
       igs_fi_cr_types_all crtype
  WHERE crd.credit_type_id  = crtype.credit_type_id
  AND   crd.credit_id = cp_n_credit_id;

  CURSOR cur_tran_type (cp_n_credit_id IN igs_fi_credits.credit_id%TYPE)  IS
  SELECT inv.transaction_type
  FROM    igs_fi_inv_int_all inv,
          igs_fi_applications app
  WHERE inv.invoice_id = app.invoice_id
  AND  app.credit_id = cp_n_credit_id;

  l_v_credit_class igs_fi_cr_types_all.credit_class%TYPE;
  l_v_trans_type igs_fi_inv_int_all.transaction_type%TYPE;
  l_v_category VARCHAR2(20):= NULL;


 BEGIN

    IF (p_n_credit_id IS NULL) THEN
      RETURN null;
    END IF;

 -- Get the credit class of the credit record.
    OPEN cur_cred(p_n_credit_id);
    FETCH cur_cred INTO l_v_credit_class;
    CLOSE cur_cred;

    -- Added INSTALLMENT_PAYMENTS credit class as part of Bug# 3256915
    IF l_v_credit_class IN ('ONLINE PAYMENT','PMT','OTH', 'INSTALLMENT_PAYMENTS') THEN
        l_v_category := g_v_credits;

    ELSIF l_v_credit_class IN ('EXTFA','INTFA','SPNSP') THEN
        l_v_category := g_v_aid;

    ELSIF l_v_credit_class IN ('ENRDEPOSIT','OTHDEPOSIT') THEN
        l_v_category := g_v_deposits;

    ELSIF l_v_credit_class = 'CHGADJ'THEN
       OPEN cur_tran_type (p_n_credit_id);
       FETCH cur_tran_type INTO l_v_trans_type;
       CLOSE cur_tran_type;

       IF l_v_trans_type = 'REFUND' THEN
           l_v_category := g_v_refund_offst;
       ELSE
           l_v_category := g_v_charges;
       END IF;

    --Added this condition as part of Tuition Waivers Build
    ELSIF l_v_credit_class = 'WAIVER' THEN
      l_v_category := g_v_waiver;

    -- Added this ELSE condition so that if at all any credit class is missed, it will be imported as a credit instead of erroring out.
    -- Added this as part of Bug# 3256915
    ELSE
      l_v_category := g_v_credits;
    END IF;

  RETURN l_v_category;

 END get_crd_cat;


FUNCTION get_inv_cat (p_v_transaction_type IN VARCHAR2) RETURN VARCHAR2 AS

  /******************************************************************
  Created By        : agairola
  Date Created By   : 22-NOV-2002
  Purpose           : Function to get the source category name for the passed transaction type
  Known limitations,  - Hard Coded texts are returned as per TD requriements.
  enhancements,
  remarks            :
  Change History
  Who      When        What
  bannamal 5-Jul-05    Bug# 3392095, Tuition Waivers Build.
                       Added condition to check whether transaction type is WAIVER_ADJ
   ******************************************************************/

l_v_category VARCHAR2(20) := NULL;


 BEGIN

    IF (p_v_transaction_type IS NULL) THEN
      RETURN NULL;
    END IF;

   IF   p_v_transaction_type  = 'AID_ADJ' THEN
        l_v_category := g_v_aid;
   ELSIF p_v_transaction_type  = 'REFUND' THEN
        l_v_category := g_v_refund_offst;

   ELSIF p_v_transaction_type = 'WAIVER_ADJ' THEN
     l_v_category := g_v_waiver;

   ELSE
        l_v_category := g_v_charges;
   END IF;
   RETURN l_v_category;


 END get_inv_cat;


FUNCTION get_app_cat (p_n_invoice_id IN NUMBER,
                      p_n_credit_id IN NUMBER) RETURN VARCHAR2 AS

  /******************************************************************
  Created By        : agairola
  Date Created By   : 22-NOV-2002
  Purpose           : Function to get the source category name for the passed invoice/credit id for applications
  Known limitations,  - Hard Coded texts are returned as per TD requriements.
  enhancements,
  remarks            :
  Change History
  Who      When        What
  bannamal 05-Jul-05   Bug# 3392095, Tuition Waivers Build.
                       Added condition to check whether credit class is WAIVER
  shtatiko 18-NOV-03   Bug# 3256915, Added INSTALLMENT_PAYMENTS when checking the credit class.
   ******************************************************************/


  CURSOR cur_cred (cp_n_credit_id IN igs_fi_credits.credit_id%TYPE)  IS
  SELECT crtype.credit_class
  FROM igs_fi_credits_all crd,
       igs_fi_cr_types_all crtype
  WHERE crd.credit_type_id  = crtype.credit_type_id
  AND   crd.credit_id = cp_n_credit_id;


  CURSOR cur_tran_type (cp_n_invoice_id IN igs_fi_inv_int_all.invoice_id%TYPE)  IS
  SELECT inv.transaction_type
  FROM   igs_fi_inv_int_all inv
  WHERE  inv.invoice_id = cp_n_invoice_id;

  l_v_category VARCHAR2(20) := NULL;
  l_v_trans_type igs_fi_inv_int_all.transaction_type%TYPE;
  l_v_credit_class igs_fi_cr_types_all.credit_class%TYPE;

 BEGIN

    IF (p_n_invoice_id IS NULL)  OR (p_n_credit_id IS NULL) THEN
      RETURN null;
    END IF;

 -- Get the credit class of the credit record.
    OPEN cur_cred(p_n_credit_id);
    FETCH cur_cred INTO l_v_credit_class;
    CLOSE cur_cred;

    -- Added INSTALLMENT_PAYMENTS credit class as part of Bug# 3256915
    IF l_v_credit_class IN ('ONLINE PAYMENT','PMT', 'INSTALLMENT_PAYMENTS') THEN
        l_v_category := g_v_credits;

    ELSIF l_v_credit_class IN ('EXTFA','INTFA','SPNSP') THEN
        l_v_category := g_v_aid;

    ELSIF l_v_credit_class = 'CHGADJ'THEN
    -- Fetch the transaction type of the invoice record.
       OPEN cur_tran_type (p_n_invoice_id);
       FETCH cur_tran_type INTO l_v_trans_type;
       CLOSE cur_tran_type;

       IF l_v_trans_type = 'REFUND' THEN
           l_v_category := g_v_refund_offst;
       ELSE
           l_v_category := g_v_charges;
       END IF;

    --Added the condition as part of Tuition Waivers Build
    ELSIF l_v_credit_class = 'WAIVER' THEN
      l_v_category := g_v_waiver;

    -- Added this ELSE condition so that if at all any credit class is missed, it will be imported as a credit instead of erroring out.
    -- Added this as part of Bug# 3256915
    ELSE
      l_v_category := g_v_credits;
    END IF;

  RETURN l_v_category;


END get_app_cat;

FUNCTION get_batch_id  RETURN NUMBER AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This function will return the unique batch identifier
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What

********************************************************************************************** */
  l_n_batch_id       igs_fi_invln_int.posting_control_id%TYPE;

  CURSOR cur_batch IS
    SELECT IGS_FI_POSTING_CONTROL_S.NEXTVAL
    FROM dual;
BEGIN
  OPEN cur_batch;
  FETCH cur_batch INTO l_n_batch_id;
  CLOSE cur_batch;

  RETURN l_n_batch_id;
END get_batch_id;

FUNCTION get_log_details(p_v_lookup_code    igs_lookup_values.lookup_code%TYPE,
                         p_v_value          VARCHAR2) RETURN VARCHAR2 AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This function will get the log information
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What

********************************************************************************************** */
  l_v_log_line            VARCHAR2(2000);
BEGIN
  l_v_log_line := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',p_v_lookup_code)||' : '||p_v_value;

  RETURN l_v_log_line;
END get_log_details;

FUNCTION get_party_number(p_n_party_id   hz_parties.party_id%TYPE) RETURN VARCHAR2 AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This function will retrieve the party number for the party id passed as input
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What

********************************************************************************************** */
  CURSOR cur_hzp(cp_party_id    hz_parties.party_id%TYPE) IS
    SELECT party_number
    FROM   hz_parties hzp
    WHERE  party_id = cp_party_id;

  l_v_person_number   hz_parties.party_number%TYPE;
BEGIN
  IF p_n_party_id IS NULL THEN
    l_v_person_number := NULL;
  ELSE
    OPEN cur_hzp(p_n_party_id);
    FETCH cur_hzp INTO l_v_person_number;
    CLOSE cur_hzp;
  END IF;

  RETURN l_v_person_number;
END get_party_number;

PROCEDURE insert_gl_int(p_d_gl_date       DATE,
                        p_user_cat_name   VARCHAR2,
                        p_dr_ccid         NUMBER,
                        p_cr_ccid         NUMBER,
                        p_amount          NUMBER,
                        p_ref23           NUMBER,
                        p_ref30           VARCHAR2,
                        p_desc            VARCHAR2) AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure will create the records in the GL Interface table
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What
 abshriva   12-May-2006  Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
********************************************************************************************** */
  l_n_dr_ccid            gl_interface.code_combination_id%TYPE;
  l_n_cr_ccid            gl_interface.code_combination_id%TYPE;
  l_n_amnt               gl_interface.entered_dr%TYPE;
  l_n_user_id            gl_interface.created_by%TYPE;
  l_v_user_je_cat        gl_interface.user_je_category_name%TYPE;

  CURSOR cur_je_cat(cp_je_cat        gl_je_categories.je_category_name%TYPE) IS
    SELECT user_je_category_name
    FROM   gl_je_categories
    WHERE  je_category_name = cp_je_cat;

BEGIN
  l_n_dr_ccid := p_dr_ccid;
  l_n_cr_ccid := p_cr_ccid;
  l_n_amnt := p_amount;

  l_n_user_id := fnd_global.user_id;

  OPEN cur_je_cat(p_user_cat_name);
  FETCH cur_je_cat INTO l_v_user_je_cat;
  CLOSE cur_je_cat;

  l_n_amnt :=igs_fi_gen_gl.get_formatted_amount(l_n_amnt);

-- If the amount is negative, then swap the accounts and the amount is made positive
  IF l_n_amnt < 0 THEN
    l_n_dr_ccid := p_cr_ccid;
    l_n_cr_ccid := p_dr_ccid;
    l_n_amnt := ABS(l_n_amnt);
  END IF;

-- Create a transaction in the GL Interface for the debit account
  INSERT INTO gl_interface(status,
                           set_of_books_id,
                           accounting_date,
                           currency_code,
                           date_created,
                           created_by,
                           actual_flag,
                           user_je_category_name,
                           user_je_source_name,
                           code_combination_id,
                           entered_dr,
                           entered_cr,
                           accounted_dr,
                           accounted_cr,
                           reference1,
                           reference10,
                           reference23,
                           reference30,
                           group_id)
                   VALUES (g_v_new,
                           g_n_sob_id,
                           p_d_gl_date,
                           g_v_currency_cd,
                           sysdate,
                           l_n_user_id,
                           g_v_actual,
                           l_v_user_je_cat,
                           g_v_user_je_src_name,
                           l_n_dr_ccid,
                           l_n_amnt,
                           NULL,
                           l_n_amnt,
                           NULL,
                           to_char(g_n_batch_id),
                           p_desc,
                           p_ref23,
                           p_ref30,
                           g_n_batch_id);

-- Create a transaction in the GL Interface for the credit account
  INSERT INTO gl_interface(status,
                           set_of_books_id,
                           accounting_date,
                           currency_code,
                           date_created,
                           created_by,
                           actual_flag,
                           user_je_category_name,
                           user_je_source_name,
                           code_combination_id,
                           entered_dr,
                           entered_cr,
                           accounted_dr,
                           accounted_cr,
                           reference1,
                           reference10,
                           reference23,
                           reference30,
                           group_id)
                   VALUES (g_v_new,
                           g_n_sob_id,
                           p_d_gl_date,
                           g_v_currency_cd,
                           sysdate,
                           l_n_user_id,
                           g_v_actual,
                           l_v_user_je_cat,
                           g_v_user_je_src_name,
                           l_n_cr_ccid,
                           NULL,
                           l_n_amnt,
                           NULL,
                           l_n_amnt,
                           to_char(g_n_batch_id),
                           p_desc,
                           p_ref23,
                           p_ref30,
                           g_n_batch_id);
END insert_gl_int;

PROCEDURE transfer_credit(p_d_gl_date_start     DATE,
                          p_d_gl_date_end       DATE,
                          p_d_gl_date_posted    DATE) AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure will transfer the credit transactions to the GL Interface
  Known limitations,enhancements,remarks:
  Change History
  Who         When        What
 bannamal    05-Jul-2005  Bug# 3392095, Tuition Waivers Build.
                          Added code to skip the waiver credit record if the post_waiver_gl_flag is set to 'N'.
 vvutukur    11-Dec-2003  Bug#3310756.Modified cursor cur_crd to exclude the deposit credit
                          activity txns that does not have accounting information and having 'TRANSFERRED' Status.
********************************************************************************************** */

-- Cursor for selecting the credit transactions from the credit activities table
  CURSOR cur_crd(cp_gl_date_start     DATE,
                 cp_gl_date_end       DATE) IS
    SELECT cra.rowid,cra.*,
           crd.credit_number credit_number,
           crd.party_id party_id
    FROM   igs_fi_cr_activities cra,
           igs_fi_credits crd
    WHERE  cra.gl_date IS NOT NULL
    AND    ((cra.POSTING_ID IS NULL) AND (cra.POSTING_CONTROL_ID IS NULL))
    AND    TRUNC(cra.gl_date) >= TRUNC(cp_gl_date_start)
    AND    TRUNC(cra.gl_date) <= TRUNC(cp_gl_date_end)
    AND    cra.credit_id = crd.credit_id
    AND    cra.dr_gl_ccid IS NOT NULL
    AND    cra.cr_gl_ccid IS NOT NULL
    AND    cra.status <> g_v_transferred;

  l_b_exception_flag   BOOLEAN;
  l_v_crd_cat          gl_je_categories.je_category_name%TYPE;
  l_v_crd_desc         gl_interface.reference10%TYPE;
  l_b_waiver_flag      BOOLEAN;

BEGIN

-- Select all the credit transactions which have the GL Date between the
-- the Gl Date start and GL date end passed as input to the procedure.
  FOR crdrec IN cur_crd(p_d_gl_date_start,
                         p_d_gl_date_end)  LOOP
    l_b_exception_flag := FALSE;
    l_v_crd_cat := NULL;

-- Fetch the journal category for the credit transaction
    l_v_crd_cat := get_crd_cat(crdrec.credit_id);

    l_b_waiver_flag := TRUE;

    IF (l_v_crd_cat = g_v_waiver) THEN
      IF (g_v_accounting_method = g_v_cash) THEN
        IF (g_v_post_waiver_gl_flag = 'N' ) THEN
          l_b_waiver_flag := FALSE;
        END IF;
      END IF;
    END IF;

    IF (l_b_waiver_flag = TRUE) THEN

      -- Prepare the description for the credit transaction
      l_v_crd_desc := g_v_credit_number;
      l_v_crd_desc := l_v_crd_desc||' :'||crdrec.credit_number;
      l_v_crd_desc := l_v_crd_desc||' ;'||g_v_party_number||' :';
      l_v_crd_desc := l_v_crd_desc||get_party_number(crdrec.party_id);
      l_v_crd_desc := SUBSTR(l_v_crd_desc,1,240);

      -- Create the transactions in the GL Interface table
      BEGIN
        insert_gl_int(p_d_gl_date     => crdrec.gl_date,
                      p_user_cat_name => l_v_crd_cat,
                      p_dr_ccid       => crdrec.dr_gl_ccid,
                      p_cr_ccid       => crdrec.cr_gl_ccid,
                      p_amount        => crdrec.amount,
                      p_ref23         => crdrec.credit_activity_id,
                      p_ref30         => 'IGS_FI_CR_ACTIVITIES',
                      p_desc          => l_v_crd_desc);
      EXCEPTION
        WHEN OTHERS THEN
          l_b_exception_flag := TRUE;
          fnd_file.put_line(fnd_file.log,
                            sqlerrm);
      END;

      -- Update the Credit Activity record with the batch identifier generated the posted date.
      IF NOT l_b_exception_flag THEN
        igs_fi_cr_activities_pkg.update_row(x_rowid                   => crdrec.rowid,
                                            x_credit_activity_id      => crdrec.credit_activity_id,
                                            x_credit_id               => crdrec.credit_id,
                                            x_status                  => crdrec.status,
                                            x_transaction_date        => crdrec.transaction_date,
                                            x_amount                  => crdrec.amount,
                                            x_dr_account_cd           => crdrec.dr_account_cd,
                                            x_cr_account_cd           => crdrec.cr_account_cd,
                                            x_dr_gl_ccid              => crdrec.dr_gl_ccid,
                                            x_cr_gl_ccid              => crdrec.cr_gl_ccid,
                                            x_bill_id                 => crdrec.bill_id,
                                            x_bill_number             => crdrec.bill_number,
                                            x_bill_date               => crdrec.bill_date,
                                            x_posting_id              => crdrec.posting_id,
                                            x_posting_control_id      => g_n_batch_id,
                                            x_gl_date                 => crdrec.gl_date,
                                            x_gl_posted_date          => p_d_gl_date_posted);
      END IF;
      COMMIT;
    END IF;
  END LOOP;
END transfer_credit;

PROCEDURE transfer_charge(p_d_gl_date_start     DATE,
                          p_d_gl_date_end       DATE,
                          p_d_gl_date_posted    DATE) AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure will transfer the charge transactions to the GL Interface
  Known limitations,enhancements,remarks:
  Change History
  Who         When             What
  svuppala    30-MAY-2005      Enh 3442712 - Done the TBH modifications by adding
                               new columns Unit_Type_Id, Unit_Level in igs_fi_invln_int_all

  vchappid    20-Dec-2002  Bug 2720702: In the procedure transfer_charge, for cursor cur_chg,
                           NVL is missing while checking for Error Account. When the Error Account
                           is set to NULL, it has to be treated as a valid transaction
                           i.e. error_account is treated as 'N'
********************************************************************************************** */
  l_b_exception_flag        BOOLEAN;
  l_v_inv_cat               gl_je_categories.je_category_name%TYPE;
  l_v_inv_desc              gl_interface.reference10%TYPE;

-- Cursor for selecting the Charge transactions from the Invoice Lines table
  CURSOR cur_chg(cp_gl_date_start     igs_fi_invln_int.gl_date%TYPE,
                 cp_gl_date_end       igs_fi_invln_int.gl_date%TYPE) IS
    SELECT ln.*,
           inv.invoice_number,
           inv.transaction_type,
           inv.person_id
    FROM   igs_fi_invln_int ln,
           igs_fi_inv_int inv
    WHERE  ln.invoice_id = inv.invoice_id
    AND    ln.gl_date IS NOT NULL
    AND    TRUNC(ln.gl_date) >= TRUNC(cp_gl_date_start)
    AND    TRUNC(ln.gl_date) <= TRUNC(cp_gl_date_end)
    AND    NVL(ln.error_account,'N') = 'N'
    AND    ((ln.posting_id IS NULL) AND (ln.posting_control_id IS NULL));

BEGIN

-- If the accounting method is CASH, then the charge transactions are not transferred
  IF g_v_accounting_method = g_v_cash THEN
    RETURN;
  END IF;

-- Loop across all the charge transactions selected by the cursor cur_chg
  FOR chgrec IN cur_chg(p_d_gl_date_start,
                        p_d_gl_date_end) LOOP
    l_b_exception_flag := FALSE;

    l_v_inv_cat := NULL;
-- Derive the category for the charge transaction
    l_v_inv_cat := get_inv_cat(chgrec.transaction_type);

-- Derive the description
    l_v_inv_desc := g_v_invoice_number;
    l_v_inv_desc := l_v_inv_desc||' :'||chgrec.invoice_number||' ;';
    l_v_inv_desc := l_v_inv_desc||g_v_party_number;
    l_v_inv_desc := l_v_inv_desc||' :'||get_party_number(chgrec.person_id);

    l_v_inv_desc := SUBSTR(l_v_inv_desc,1,240);

-- Create transactions in the GL Interface
    SAVEPOINT SP_INV1;
    BEGIN
      insert_gl_int(p_d_gl_date     => chgrec.gl_date,
                    p_user_cat_name => l_v_inv_cat,
                    p_dr_ccid       => chgrec.rec_gl_ccid,
                    p_cr_ccid       => chgrec.rev_gl_ccid,
                    p_amount        => chgrec.amount,
                    p_ref23         => chgrec.invoice_lines_id,
                    p_ref30         => 'IGS_FI_INVLN_INT',
                    p_desc          => l_v_inv_desc);
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO SP_INV1;
        l_b_exception_flag := TRUE;
        fnd_file.put_line(fnd_file.log,
                          sqlerrm);
    END;

    IF NOT l_b_exception_flag THEN
      igs_fi_invln_int_pkg.update_row(x_rowid               => chgrec.row_id,
                                      x_invoice_id          => chgrec.invoice_id,
                                      x_line_number         => chgrec.line_number,
                                      x_invoice_lines_id    => chgrec.invoice_lines_id,
                                      x_attribute2          => chgrec.attribute2,
                                      x_chg_elements        => chgrec.chg_elements,
                                      x_amount              => chgrec.amount,
                                      x_unit_attempt_status => chgrec.unit_attempt_status,
                                      x_eftsu               => chgrec.eftsu,
                                      x_credit_points       => chgrec.credit_points,
                                      x_attribute_category  => chgrec.attribute_category,
                                      x_attribute1          => chgrec.attribute1,
                                      x_s_chg_method_type   => chgrec.s_chg_method_type,
                                      x_description         => chgrec.description,
                                      x_attribute3          => chgrec.attribute3,
                                      x_attribute4          => chgrec.attribute4,
                                      x_attribute5          => chgrec.attribute5,
                                      x_attribute6          => chgrec.attribute6,
                                      x_attribute7          => chgrec.attribute7,
                                      x_attribute8          => chgrec.attribute8,
                                      x_attribute9          => chgrec.attribute9,
                                      x_attribute10         => chgrec.attribute10,
                                      x_rec_account_cd      => chgrec.rec_account_cd,
                                      x_rev_account_cd      => chgrec.rev_account_cd,
                                      x_rec_gl_ccid         => chgrec.rec_gl_ccid,
                                      x_rev_gl_ccid         => chgrec.rev_gl_ccid,
                                      x_org_unit_cd         => chgrec.org_unit_cd,
                                      x_posting_id          => chgrec.posting_id,
                                      x_attribute11         => chgrec.attribute11,
                                      x_attribute12         => chgrec.attribute12,
                                      x_attribute13         => chgrec.attribute13,
                                      x_attribute14         => chgrec.attribute14,
                                      x_attribute15         => chgrec.attribute15,
                                      x_attribute16         => chgrec.attribute16,
                                      x_attribute17         => chgrec.attribute17,
                                      x_attribute18         => chgrec.attribute18,
                                      x_attribute19         => chgrec.attribute19,
                                      x_attribute20         => chgrec.attribute20,
                                      x_error_string        => chgrec.error_string,
                                      x_error_account       => chgrec.error_account,
                                      x_location_cd         => chgrec.location_cd,
                                      x_uoo_id              => chgrec.uoo_id,
                                      x_gl_date             => chgrec.gl_date,
                                      x_posting_control_id  => g_n_batch_id,
                                      x_gl_posted_date      => p_d_gl_date_posted,
                                      x_unit_type_id        => chgrec.unit_type_id,
                                      x_unit_level          => chgrec.unit_level);
        END IF;
        COMMIT;
  END LOOP;
END transfer_charge;

PROCEDURE transfer_app(p_d_gl_date_start     DATE,
                       p_d_gl_date_end       DATE,
                       p_d_gl_date_posted    DATE) AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure will transfer the application transactions to the GL Interface
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What
  bannamal    05-Jul-05  Bug# 3392095, Tuition Waivers Build.
                         Added code to skip the waiver application record if the post_waiver_gl_flag is set to 'N'.
********************************************************************************************** */
  l_v_app_cat            gl_je_categories.je_category_name%TYPE;
  l_v_app_desc           gl_interface.reference10%TYPE;
  l_b_exception_flag     BOOLEAN;
  l_b_waiver_flag        BOOLEAN;

-- Cursor for selecting the unposted application records
  CURSOR cur_app(cp_gl_date_start igs_fi_applications.gl_date%TYPE,
                 cp_gl_date_end   igs_fi_applications.gl_date%TYPE) IS
    SELECT app.*,app.rowid row_id,
           inv.invoice_number,
           crd.credit_number,
           inv.person_id
    FROM   igs_fi_applications app,
           igs_fi_credits crd,
           igs_fi_inv_int inv
    WHERE  crd.credit_id = app.credit_id
    AND    inv.invoice_id = app.invoice_id
    AND    app.gl_date IS NOT NULL
    AND    TRUNC(app.gl_date) >= TRUNC(cp_gl_date_start)
    AND    TRUNC(app.gl_date) <= TRUNC(cp_gl_date_end)
    AND    ((app.posting_id IS NULL) AND (app.posting_control_id IS NULL));
BEGIN

-- Loop across all the application records fetched by the cur_app
  FOR apprec IN cur_app(p_d_gl_date_start,
                        p_d_gl_date_end) LOOP
    l_v_app_desc := null;
    l_b_exception_flag := FALSE;
    l_v_app_cat := NULL;

-- Get the category name for the application transaction
    l_v_app_cat := get_app_cat(p_n_invoice_id  => apprec.invoice_id,
                               p_n_credit_id   => apprec.credit_id);
    l_b_waiver_flag := TRUE;

    IF (l_v_app_cat = g_v_waiver) THEN
      IF (g_v_accounting_method = g_v_cash) THEN
        IF (g_v_post_waiver_gl_flag = 'N') THEN
          l_b_waiver_flag := FALSE;
        END IF;
      END IF;
    END IF;

    IF (l_b_waiver_flag = TRUE) THEN
      -- Form the description for the application record
      l_v_app_desc := SUBSTR(g_v_invoice_number||' :'||
                      apprec.invoice_number||' ;'||
                      g_v_credit_number||' :'||
                      apprec.credit_number||' ;'||
                      g_v_party_number||' :'||
                      get_party_number(apprec.person_id),
                      1,240);

      -- Create the transactions in the GL interface table
      SAVEPOINT SP_APP1;
      BEGIN

        insert_gl_int(p_d_gl_date     => apprec.gl_date,
                      p_user_cat_name => l_v_app_cat,
                      p_dr_ccid       => apprec.dr_gl_code_ccid,
                      p_cr_ccid       => apprec.cr_gl_code_ccid,
                      p_amount        => apprec.amount_applied,
                      p_ref23         => apprec.application_id,
                      p_ref30         => 'IGS_FI_APPLICATIONS',
                      p_desc          => l_v_app_desc);

      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK TO SP_APP1;
           l_b_exception_flag := TRUE;
           fnd_file.put_line(fnd_file.log,
                             sqlerrm);
      END;

      -- If there is no error in creation of the transaction in the GL Interface table,
      -- then update the application record with the posting control id and the gl posted date
      IF NOT l_b_exception_flag THEN
        igs_fi_applications_pkg.update_row(x_rowid                          => apprec.row_id,
                                           x_application_id                 => apprec.application_id,
                                           x_application_type               => apprec.application_type,
                                           x_invoice_id                     => apprec.invoice_id,
                                           x_credit_id                      => apprec.credit_id,
                                           x_credit_activity_id             => apprec.credit_activity_id,
                                           x_amount_applied                 => apprec.amount_applied,
                                           x_apply_date                     => apprec.apply_date,
                                           x_link_application_id            => apprec.link_application_id,
                                           x_dr_account_cd                  => apprec.dr_account_cd,
                                           x_cr_account_cd                  => apprec.cr_account_cd,
                                           x_dr_gl_code_ccid                => apprec.dr_gl_code_ccid,
                                           x_cr_gl_code_ccid                => apprec.cr_gl_code_ccid,
                                           x_applied_invoice_lines_id       => apprec.applied_invoice_lines_id,
                                           x_appl_hierarchy_id              => apprec.appl_hierarchy_id,
                                           x_posting_id                     => apprec.posting_id,
                                           x_gl_date                        => apprec.gl_date,
                                           x_gl_posted_date                 => p_d_gl_date_posted,
                                           x_posting_control_id             => g_n_batch_id);
      END IF;
      COMMIT;
    END IF;
  END LOOP;
END transfer_app;

PROCEDURE transfer_admapp(p_d_gl_date_start     DATE,
                          p_d_gl_date_end       DATE,
                          p_d_gl_date_posted    DATE) AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure will transfer the admission application
                    transactions to the GL Interface
  Known limitations,enhancements,remarks:
  Change History
  Who         When           What
  vvutukur    15-Dec-2003    Bug#3310756.Modified cursor cur_adm to check for cash_gl_ccid is not null also.
  vvutukur    09-Oct-2003    Bug#3160036.Replaced the call to igs_ad_app_req.update_row with
                             the call to igs_ad_gen_015.update_igs_ad_app_req.
  pathipat    14-Jun-2003    Enh 2831587 - Credit Card Fund Transfer build
                             Modified call to igs_ad_app_req_pkg.update_row - added 3 new parameters
********************************************************************************************** */
  l_b_exception_flag        BOOLEAN;
  l_v_adm_cat               gl_je_categories.je_category_name%TYPE;
  l_v_adm_desc              gl_interface.reference10%TYPE;

-- Cursor for selecting the records from the admission application table
  CURSOR cur_adm(cp_gl_date_start    DATE,
                 cp_gl_date_end      DATE) IS
    SELECT fee.*, fee.rowid row_id, appl.application_id
    FROM   igs_ad_app_req fee,
           igs_ad_appl     appl
    WHERE  appl.person_id = fee.person_id
    AND    appl.admission_appl_number = fee.admission_appl_number
    AND    fee.gl_date IS NOT NULL
    AND    fee.posting_control_id IS NULL
    AND    fee.gl_posted_date IS NULL
    AND    fee.rev_gl_ccid IS NOT NULL
    AND    fee.cash_gl_ccid IS NOT NULL
    AND    TRUNC(fee.gl_date) >= TRUNC(cp_gl_date_start)
    AND    TRUNC(fee.gl_date) <= TRUNC(cp_gl_date_end);

BEGIN

-- Loop across all the records fetched by the cursor cur_adm
  FOR admrec IN cur_adm(p_d_gl_date_start,
                        p_d_gl_date_end) LOOP
    l_b_exception_flag := FALSE;

-- Get the je category name
    l_v_adm_cat := g_v_adm_cat;

    l_v_adm_desc := SUBSTR(g_v_application||' :'||
                      admrec.app_req_id||' ;'||
                      g_v_party_number||' :'||
                      get_party_number(admrec.person_id),1,240);

-- Create transactions in the GL Interface table
    SAVEPOINT SP_ADAPP1;
    BEGIN
      insert_gl_int(p_d_gl_date     => admrec.gl_date,
                    p_user_cat_name => l_v_adm_cat,
                    p_dr_ccid       => admrec.cash_gl_ccid,
                    p_cr_ccid       => admrec.rev_gl_ccid,
                    p_amount        => admrec.fee_amount,
                    p_ref23         => admrec.app_req_id,
                    p_ref30         => 'IGS_AD_APP_REQ',
                    p_desc          => l_v_adm_desc);
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO SP_ADAPP1;
        l_b_exception_flag := TRUE;
        fnd_file.put_line(fnd_file.log,
                          sqlerrm);
    END;

-- If there is no error in creating transaction in the GL Interface table,
-- then update the admission application record by the value of the Posting control id
-- and the GL Posted Date
    IF NOT l_b_exception_flag THEN
      igs_ad_gen_015.update_igs_ad_app_req(
          p_rowid                         => admrec.row_id,
          p_app_req_id                    => admrec.app_req_id,
          p_person_id                     => admrec.person_id,
          p_admission_appl_number         => admrec.admission_appl_number,
          p_applicant_fee_type            => admrec.applicant_fee_type,
          p_applicant_fee_status          => admrec.applicant_fee_status,
          p_fee_date                      => admrec.fee_date,
          p_fee_payment_method            => admrec.fee_payment_method,
          p_fee_amount                    => admrec.fee_amount,
          p_reference_num                 => admrec.reference_num,
          p_credit_card_code              => admrec.credit_card_code,
          p_credit_card_holder_name       => admrec.credit_card_holder_name,
          p_credit_card_number            => admrec.credit_card_number,
          p_credit_card_expiration_date   => admrec.credit_card_expiration_date,
          p_rev_gl_ccid                   => admrec.rev_gl_ccid,
          p_cash_gl_ccid                  => admrec.cash_gl_ccid,
          p_rev_account_cd                => admrec.rev_account_cd,
          p_cash_account_cd               => admrec.cash_account_cd,
          p_posting_control_id            => g_n_batch_id,
          p_gl_date                       => admrec.gl_date,
          p_gl_posted_date                => p_d_gl_date_posted,
          p_credit_card_tangible_cd       => admrec.credit_card_tangible_cd,
          p_credit_card_payee_cd          => admrec.credit_card_payee_cd,
          p_credit_card_status_code       => admrec.credit_card_status_code,
          p_mode                          => 'R'
          );
    END IF;
    COMMIT;
  END LOOP;
END transfer_admapp;

FUNCTION validate_parm(p_d_gl_date_start     DATE,
                       p_d_gl_date_end       DATE,
                       p_v_post_detail       VARCHAR2,
                       p_d_gl_date_posted    DATE,
                       p_v_jrnl_import       VARCHAR2) RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This function will validate the input parameters
  Known limitations,enhancements,remarks:
  Change History
  Who         When         What
  bannamal    05-Jul-2005  Bug# 3392095, Tuition Waivers Build.
                           Modified the cursor cur_ctrl.Added post_waiver_gl_flag in the select clause.
  shtatiko    22-APR-2003  Enh# 2831569, Added check for Manage Accounts System Option.
  agairola    02-Jan-2003  Bug 2714777,2727324: Modified the process for the following
                           1. In the validate_parm procedure, if the rec_installed is set to N
                           then after logging the parameters, the process exits.
                           2. In the validate_parm procedure, the message name changed if the
                           run journal import is set to Y and the start date is in a period that
                           is closed.
********************************************************************************************** */
  l_b_val_parm            BOOLEAN;
  l_v_period_name         gl_period_statuses.period_name%TYPE;
  l_d_end_date            DATE;
  l_v_sob_name            gl_sets_of_books.name%TYPE;
  l_log_line              VARCHAR2(2000);
  l_v_message_name        fnd_new_messages.message_name%TYPE;
  l_v_manage_accounts     igs_fi_control.manage_accounts%TYPE;

-- Cursor for selecting the information from the System Options
  CURSOR cur_ctrl IS
    SELECT rec_installed,
           currency_cd,
           set_of_books_id,
           accounting_method,
           post_waiver_gl_flag
    FROM   igs_fi_control;

  CURSOR cur_sob(cp_sob_id     gl_sets_of_books.set_of_books_id%TYPE) IS
    SELECT name
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = cp_sob_id;

-- Cursor for selecting the records from gl period statuses table
  CURSOR cur_glp(cp_app_id            NUMBER,
                 cp_gl_date_start     DATE,
                 cp_sob_id            igs_fi_control.set_of_books_id%TYPE) IS
    SELECT period_name, end_date
        FROM   gl_period_statuses a
        WHERE  TRUNC(start_date) <= TRUNC(cp_gl_date_start)
        AND    TRUNC(end_date) >= TRUNC(cp_gl_date_start)
        AND    CLOSING_STATUS = 'O'
        AND    APPLICATION_ID = cp_app_id
        AND    adjustment_period_flag = 'N'
        AND    set_of_books_id = cp_sob_id;

BEGIN
  l_b_val_parm := TRUE;

-- Select the currency, set of books and accounting method information from the
-- system options
  -- If any error occurs store the message name in l_v_message_name.
  -- Logging of the same is done after logging parameters
  OPEN cur_ctrl;
  FETCH cur_ctrl INTO g_v_rec_inst,
                      g_v_currency_cd,
                      g_n_sob_id,
                      g_v_accounting_method,
                      g_v_post_waiver_gl_flag;
  IF cur_ctrl%NOTFOUND THEN
    l_v_message_name := 'IGS_FI_SYSTEM_OPT_SETUP';
    l_b_val_parm := FALSE;
  ELSE

-- If the receivables installed is set to No, then this process should not be run
    IF g_v_rec_inst = 'N' THEN
      l_v_message_name := 'IGS_FI_INVALID_PROCESS';
      l_b_val_parm := FALSE;
    END IF;
  END IF;
  CLOSE cur_ctrl;

-- Get the batch identifier
  g_n_batch_id := get_batch_id;

  OPEN cur_sob(g_n_sob_id);
  FETCH cur_sob INTO l_v_sob_name;
  CLOSE cur_sob;

-- Log the values for the parameters to the process
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_message.set_name('IGS',
                       'IGS_FI_ANC_LOG_PARM');
  fnd_file.put_line(fnd_file.log,
                    fnd_message.get);

  fnd_file.new_line(fnd_file.log);
  fnd_file.put_line(fnd_file.log,
                    get_log_details('SET_OF_BOOKS',l_v_sob_name));
  fnd_file.put_line(fnd_file.log,
                    get_log_details('SYS_DATE', sysdate));
  fnd_file.put_line(fnd_file.log,
                    get_log_details('GL_DT_START',p_d_gl_date_start));
  fnd_file.put_line(fnd_file.log,
                    get_log_details('GL_DT_END',p_d_gl_date_end));
  fnd_file.put_line(fnd_file.log,
                    get_log_details('POSTING_DETAIL',
                                    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_POSTING_DETAIL',
                                                                   p_v_post_detail)));
  fnd_file.put_line(fnd_file.log,
                    get_log_details('GL_POSTED_DT',p_d_gl_date_posted));
  fnd_file.put_line(fnd_file.log,
                    get_log_details('RUN_JNL_IMP',
                                    igs_fi_gen_gl.get_lkp_meaning('YES_NO',
                                                                   p_v_jrnl_import)));
  fnd_file.put_line(fnd_file.log,
                    get_log_details('POSTING_CTRL_ID',g_n_batch_id));

  fnd_file.new_line(fnd_file.log);

  -- Added the code here to exit from this procedure if the Receivables is not installed
  -- If validations of igs_fi_control fails then log the corresponding message and return.
  IF NOT l_b_val_parm THEN
    fnd_message.set_name ( 'IGS', l_v_message_name );
    IF l_v_message_name = 'IGS_FI_INVALID_PROCESS' THEN
      fnd_message.set_token('YES_NO', igs_fi_gen_gl.get_lkp_meaning('YES_NO', 'Y'));
    END IF;
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
    RETURN l_b_val_parm;
  END IF;

  -- Check the value of Manage Accounts System Option value.
  -- If its NULL or OTHER then this process should error out by logging message.
  l_v_message_name := NULL;
  igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                p_v_message_name => l_v_message_name );
  IF l_v_manage_accounts IS NULL OR l_v_manage_accounts = 'OTHER' THEN
    fnd_message.set_name ( 'IGS', l_v_message_name );
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
    RETURN FALSE;
  END IF;

-- If any of the parameters is NULL, then log the error in the log file
  IF ((p_d_gl_date_start IS NULL) OR
      (p_d_gl_date_end IS NULL) OR
      (p_v_post_detail IS NULL) OR
      (p_d_gl_date_posted IS NULL) OR
      (p_v_jrnl_import IS NULL)) THEN
     fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
     fnd_file.put_line(fnd_file.log,
                       fnd_message.get);
    l_b_val_parm := FALSE;
  END IF;

-- If the GL Date start is greater than the gl date end, then log error message
  IF p_d_gl_date_start IS NOT NULL AND p_d_gl_date_end IS NOT NULL THEN
    IF TRUNC(p_d_gl_date_start) > TRUNC(p_d_gl_date_end) THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_VAL_GL_END_DATE');
      fnd_message.set_token('START_DATE',
                            TRUNC(p_d_gl_date_start));
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      l_b_val_parm := FALSE;
    END IF;

-- If the GL Date Start and the GL Date end are not within the same Open accounting period,
-- then log the error message
    OPEN cur_glp(8405,
                 p_d_gl_date_start,
                 g_n_sob_id);
    FETCH cur_glp INTO l_v_period_name, l_d_end_date;
    IF cur_glp%NOTFOUND THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_NO_OPEN_PERIOD');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      l_b_val_parm := FALSE;
    END IF;
    CLOSE cur_glp;

    IF TRUNC(l_d_end_date) < TRUNC(p_d_gl_date_end) THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_VAL_GL_START_END_DATE');
      fnd_message.set_token('GL_START_DATE',
                            p_d_gl_date_start);
      fnd_message.set_token('PERIOD',
                            l_v_period_name);

      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      l_b_val_parm := FALSE;
    END IF;

    l_v_period_name := NULL;
    l_d_end_date := NULL;

-- If the Import Journal process is to be run, then validate if the GL Date Start and GL Date End
-- are within the same open period for the GL Application (Application Id = 101)
    IF p_v_jrnl_import = 'Y' THEN
      OPEN cur_glp(101,
                   p_d_gl_date_start,
                   g_n_sob_id);
      FETCH cur_glp INTO l_v_period_name, l_d_end_date;
      IF cur_glp%NOTFOUND THEN
        fnd_message.set_name('IGS',
                             'IGS_FI_GL_NO_OPEN_PERIOD');
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
        l_b_val_parm := FALSE;
      END IF;
      CLOSE cur_glp;
    END IF;

    IF TRUNC(l_d_end_date) < TRUNC(p_d_gl_date_end) THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_NO_OPEN_PERIOD_GL');
      l_log_line := fnd_message.get;
      fnd_message.set_name('IGS',
                           'IGS_FI_VAL_GL_START_END_DATE');
      fnd_message.set_token('GL_START_DATE',
                            p_d_gl_date_start);
      fnd_message.set_token('PERIOD',
                            l_v_period_name);
      l_log_line := l_log_line||fnd_message.get;
      fnd_file.put_line(fnd_file.log,
                        l_log_line);
      l_b_val_parm := FALSE;
    END IF;
  END IF;


-- Validate if the parameter for Posting Detail is a valid lookup
  IF p_v_post_detail IS NOT NULL THEN
    IF NOT igs_lookups_view_pkg.get_pk_for_validation('IGS_FI_POSTING_DETAIL',
                                                       p_v_post_detail) THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_INV_POSTING_DETAIL');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      l_b_val_parm := FALSE;
    END IF;
  END IF;
-- Validate if the Journal Import parameter is a valid Lookup

  IF p_v_jrnl_import IS NOT NULL THEN
    IF NOT igs_lookups_view_pkg.get_pk_for_validation('YES_NO',
                                                       p_v_jrnl_import) THEN
      fnd_message.set_name('IGS',
                         'IGS_FI_INV_JNL_IMPORT');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      l_b_val_parm := FALSE;
    END IF;
  END IF;

  RETURN l_b_val_parm;

END validate_parm;

FUNCTION run_jrnl_imp(p_d_gl_date_start DATE,
                      p_d_gl_date_end   DATE,
                      p_v_post_detail   VARCHAR2) RETURN NUMBER AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This function will submit the Import Journal Process
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What

********************************************************************************************** */

  l_n_unique_id         NUMBER(38);
  l_n_req_id            NUMBER(38);
  l_v_post_detail       VARCHAR2(1);
BEGIN

-- If the Posting Detail parameter is DETAIL then pass N to GL Interface
-- Else Y for Create Summary Journal parameter
  IF p_v_post_detail = 'DETAIL' THEN
    l_v_post_detail := 'N';
  ELSE
    l_v_post_detail := 'Y';
  END IF;

-- Get the unique run id using the get_unique_run_id procedure
--  l_n_unique_id := gl_interface_control_pkg.get_unique_run_id;

-- Create a record in the GL_INTERFACE_CONTROL_PKG
/*  gl_interface_control_pkg.insert_row(xset_of_books_id      => g_n_sob_id,
                                      xinterface_run_id     => l_n_unique_id,
                                      xje_source_name       => g_v_je_source_name,
                                      xgroup_id             => g_n_batch_id,
                                      xpacket_id            => NULL); */

-- Run the Journal Import Process
  l_n_req_id := fnd_request.submit_request('SQLGL',
                                           'GLLEZL',
                                           '',
                                           '',
                                           FALSE,
                                           to_char(l_n_unique_id),
                                           to_char(g_n_sob_id),
                                           'N',
                                           to_char(TRUNC(p_d_gl_date_start),'YYYY/MM/DD'),
                                           to_char(TRUNC(p_d_gl_date_end),'YYYY/MM/DD'),
                                           l_v_post_detail,
                                           'N',
                                           CHR(0),
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '',
                                           '', '', '', '', '', '', '', '', '', '','');
  RETURN l_n_req_id;
END run_jrnl_imp;

PROCEDURE generate_log AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure will generate the log file
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What
  agairola    27-Jan-2003 Bug 2711195: Modified the code to display No Data Found in the log file
********************************************************************************************** */
  l_v_line_txt       VARCHAR2(80);
  l_n_cntr           PLS_INTEGER;
  l_n_dr_amnt        gl_interface.entered_dr%TYPE;
  l_n_cr_amnt        gl_interface.entered_cr%TYPE;

-- Cursor for getting the debit and credit amount group by the user_je_category name
  CURSOR cur_glint(cp_batch_id      NUMBER,
                   cp_source_name   VARCHAR2,
                   cp_sob_id        NUMBER) IS
    SELECT user_je_category_name,
           SUM(decode(entered_dr,NULL,0,entered_dr)) dr_amnt,
           SUM(decode(entered_cr,NULL,0,entered_cr)) cr_amnt
    FROM   gl_interface
    WHERE  group_id = cp_batch_id
    AND    set_of_books_id = cp_sob_id
    AND    user_je_source_name = cp_source_name
    GROUP BY user_je_category_name
    ORDER BY user_je_category_name;
BEGIN
  l_v_line_txt := NULL;
  g_b_rec_found := FALSE;

  FOR l_n_cntr IN 1..80 LOOP
    l_v_line_txt := l_v_line_txt||'-';
  END LOOP;

  fnd_file.new_line(fnd_file.log);

  fnd_message.set_name('IGS',
                       'IGS_FI_SUM_GL_TRX');
  fnd_file.put_line(fnd_file.log,
                    fnd_message.get);
  fnd_file.put_line(fnd_file.log,
                    l_v_line_txt);

-- Loop across the GL Interface table
  FOR glrec IN cur_glint(g_n_batch_id,
                         g_v_user_je_src_name,
                         g_n_sob_id) LOOP
    l_n_dr_amnt := NVL(l_n_dr_amnt,0) + NVL(glrec.dr_amnt,0);
    l_n_cr_amnt := NVL(l_n_cr_amnt,0) + NVL(glrec.cr_amnt,0);

-- Log the debit and the credit amount category wise
    fnd_file.put_line(fnd_file.log,
                      get_log_details('CATEGORY',glrec.user_je_category_name));
    fnd_file.put_line(fnd_file.log,
                      get_log_details('ENT_DEBITS',glrec.dr_amnt));
    fnd_file.put_line(fnd_file.log,
                      get_log_details('ENT_CREDITS',glrec.cr_amnt));
    fnd_file.new_line(fnd_file.log);

-- Set the value of the global variable g_b_rec_found to TRUE
    g_b_rec_found := TRUE;
  END LOOP;

  fnd_file.new_line(fnd_file.log);

-- Log the total entered debits and credits. If no data has been
-- created in the GL_INTERFACE table,then log the message NO
-- DATA FOUND
  IF g_b_rec_found THEN
    fnd_file.put_line(fnd_file.log,
                      l_v_line_txt);
    fnd_file.put_line(fnd_file.log,
                      get_log_details('TOT_ENT_DEBITS',l_n_dr_amnt));
    fnd_file.put_line(fnd_file.log,
                      get_log_details('TOT_ENT_CREDITS',l_n_cr_amnt));
  ELSE
    fnd_message.set_name('IGS',
                         'IGS_GE_NO_DATA_FOUND');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;
END generate_log;

PROCEDURE transfer(errbuf                    OUT NOCOPY VARCHAR2,
                   retcode                   OUT NOCOPY NUMBER,
                   p_d_gl_date_start         VARCHAR2,
                   p_d_gl_date_end           VARCHAR2,
                   p_v_post_detail           VARCHAR2,
                   p_d_gl_date_posted        VARCHAR2,
                   p_v_jrnl_import           VARCHAR2) AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  1-Nov-2002
  Purpose        :  This procedure is the main concurrent program procedure
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What
  sapanigr    05-May-2006 Bug 5178077: Added call to igs_ge_gen_003.set_org_id. to disable process in R12
  agairola    27-Jan-2003 Bug 2711195: Modified the code to run the Journal Import only
                          when the records have been created in the GL_INTERFACE table
********************************************************************************************** */
  l_d_gl_date_start          DATE;
  l_d_gl_date_end            DATE;
  l_d_gl_date_posted         DATE;
  l_n_req_id                 NUMBER(38);
  l_b_val_parm               BOOLEAN;
  l_org_id                   VARCHAR2(15);

BEGIN

  retcode := 0;
  initialize;

  BEGIN
       l_org_id := NULL;
       igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         RETCODE:=2;
         RETURN;
  END;

-- Convert the Date parameters
  l_d_gl_date_start := igs_ge_date.igsdate(p_d_gl_date_start);
  l_d_gl_date_end   := igs_ge_date.igsdate(p_d_gl_date_end);
  l_d_gl_date_posted := igs_ge_date.igsdate(p_d_gl_date_posted);

-- Validate the parameters. If the validate_parm returns false, then raise error
  l_b_val_parm :=  validate_parm(p_d_gl_date_start   => l_d_gl_date_start,
                                 p_d_gl_date_end     => l_d_gl_date_end,
                                 p_v_post_detail     => p_v_post_detail,
                                 p_d_gl_date_posted  => l_d_gl_date_posted,
                                 p_v_jrnl_import     => p_v_jrnl_import);

-- Transfer the Charge records
  IF NOT l_b_val_parm THEN
    retcode := 2;
    RETURN;
  END IF;

  transfer_charge(p_d_gl_date_start   => l_d_gl_date_start,
                  p_d_gl_date_end     => l_d_gl_date_end,
                  p_d_gl_date_posted  => l_d_gl_date_posted);

-- Transfer the Credit Transactions
  transfer_credit(p_d_gl_date_start   => l_d_gl_date_start,
                  p_d_gl_date_end     => l_d_gl_date_end,
                  p_d_gl_date_posted  => l_d_gl_date_posted);

-- Transfer the application records
  transfer_app(p_d_gl_date_start   => l_d_gl_date_start,
               p_d_gl_date_end     => l_d_gl_date_end,
               p_d_gl_date_posted  => l_d_gl_date_posted);

-- Transfer the admission application transactions
  transfer_admapp(p_d_gl_date_start   => l_d_gl_date_start,
                  p_d_gl_date_end     => l_d_gl_date_end,
                  p_d_gl_date_posted  => l_d_gl_date_posted);

-- Generate the log
  generate_log;

-- If the records have been inserted in the GL_INTERFACE, then
-- then the Journal Import Process should be run.
  IF g_b_rec_found THEN
-- If the Journal Import parameter is Yes, then
    IF p_v_jrnl_import = 'Y' THEN

-- Run the Journal Import process
      l_n_req_id := run_jrnl_imp(l_d_gl_date_start,
                                 l_d_gl_date_end,
                                 p_v_post_detail);

-- If the request id is null or 0, i.e. the request is not submitted, then
-- log message indicating to the user to run the Import Journal Process manually
      IF ((l_n_req_id IS NULL) OR (l_n_req_id = 0))THEN
        fnd_message.set_name('IGS',
                             'IGS_FI_UNABLE_TO_SUB_GL_IMP');
      ELSE

-- Else log the request identifier
        fnd_file.put_line(fnd_file.log,
                          get_log_details('REQ_ID',l_n_req_id));
      END IF;
    ELSE

-- Else if the run journal import parameter is No, then log a message to indicate that
-- the user should manually run the Journal Import process
      fnd_message.set_name('IGS',
                         'IGS_FI_RUN_IMP_JNL');
      fnd_file.put_line(fnd_file.log,
      fnd_message.get);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     retcode := 2;
     fnd_message.set_name('IGS',
                          'IGS_GE_UNHANDLED_EXCEPTION');
     errbuf := fnd_message.get;
     fnd_file.put_line(fnd_file.log,
                       sqlerrm);
     igs_ge_msg_stack.conc_exception_hndl;
END transfer;

END igs_fi_gl_interface;

/
