--------------------------------------------------------
--  DDL for Package Body IGS_FI_TRAN_LOCKBOX_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_TRAN_LOCKBOX_TXNS" AS
/* $Header: IGSFI55B.pls 115.24 2003/05/28 08:52:46 shtatiko ship $ */

/***************************************************************
   Created By		:	bayadav
   Date Created By	:	2001/04/25
   Purpose		:       To upload data from 'AR_CASH_RECEIPTS' AR Cash Receipts
                                table into 'IGS_FI_CRD_INT_ALL' credit interface table
   Known Limitations,Enhancements or Remarks:
   Change History	:
   Who		When	        What
   shtatiko     28-MAY-2003   Enh# 2831582, This process has been obsoleted and removed all the local procedures as they are no longer be used
   SYKRISHN     05/MAR/2003   Bug Fix 2727192 ~ Validation for Transaction Dates parameter introduced
   vvutukur     17-Jan-2003   Bug#2743483.Modifications done in procedure transfer_lockbox.
   vvutukur     21-Nov-2002   Enh#2584986.Added new parameter p_d_gl_date parameter to the procedure transfer_lockbox.
                              Also modified get_cur_desc.Removed local function lookup_desc and its call in get_log_line.
   pathipat     24-SEP-2002   Enh Bug# 2564643: subaccount_id column made obsolete in IGS_FI_CRD_INT and IGS_FI_SA_LOCKBOXES
                              In TRANSFER_LOCKBOX() proc, removed local variables for subaccount_id and removed it in INSERT_ROW().
			      Removed cursor c_subaccount_id and its usage thereafter.
			      Removed all DEFAULT NULL in proc transfer_lockbox()

   vchappid     13-Jun-2002   Bug#2411529, Incorrectly used message name has been modified

   agairola     27-May-2002   For the bugs 2383820,2336344, created private function get_pers_grp_code
                              for fetching the Person id Group code to be displayed. Also
                              modified the log file parameter logging.

   vvutukur     24-May-2002   For bugs.2383820,2336344,created private functions get_log_line,get_cur_desc,
                              get_cust_acct_num,get_pers_num and called them in transfer_lockbox main procedure
			      to show log in multiline.Shown customer account number also in the log.Modified cursor
			      c_ar_cash_rec, used BETWEEN instead of handling cp_txn_date_low,cp_txn_date_high values
			      individually for checking with receipt date(for the improvement of code).

   agairola     24-May-2002    For bug 2383846, while inserting record in the Credits Interface table
                               passing NULL to Attribute_Category in transfer_lockbox procedure

   vvutukur     17-May-2002      bug#2372093.Modified transfer_lockbox procedure to add validation for p_lockbox_num.

   sarakshi     28-Feb-2002      bug:2238362,replaced PERSON to PARTY_ID in logging a message in log file

   sykrishn     19-FEB-02        Changes as part of SFCR023 - 2227831 - Changes to transfer_lockbox procedure
 		                 Removed Cursor c_ar_cash_rec_all_att as it not used anywhere

   jbegum       15 Feb 02        As part of Enh bug #2222272
                                 Selecting the  org_id from the control table prior to importing the lockbox
                                 transactions from Accounts Receivable to Student Finance

 ***************************************************************/

PROCEDURE   transfer_lockbox(  ERRBUF   	  OUT NOCOPY 		VARCHAR2,
                               RETCODE		  OUT NOCOPY		NUMBER,
                               p_person_id        IN            igs_pe_person_v.person_id%TYPE         ,
                               p_person_id_group  IN            igs_pe_persid_group_v.group_id%TYPE    ,
                               p_lockbox_num      IN            ar_lockboxes.lockbox_number%TYPE,
                               p_txn_date_low     IN            VARCHAR2   ,
                               p_txn_date_high    IN            VARCHAR2   ,
                               p_org_id           IN            NUMBER,
			       p_d_gl_date        IN            VARCHAR2
			     )AS
/***************************************************************
   Created By		:	bayadav
   Date Created By	:	2001/04/25
   Purpose		:       To upload data from 'AR_CASH_RECEIPTS' AR Cash Receipts
                                table into 'IGS_FI_CRD_INT_ALL' credit interface table
   Known Limitations,Enhancements or Remarks:
   Change History	:
   Who		When		What
   shtatiko     28-MAY-2003    Enh# 2831582, This process has been obsoleted.
   sykrishn    5-mar-03        Bug 2727192 - Added Transaction Dates validation
   vvutukur     17-Jna-2003    Bug#2743483.Added code for the process to error out if Oracle Financials is not Installed, since this process
                               is valid only when Oracle Financials is Installed.
   vvutukur     21-Nov-2002    Enh#2584986.Added new parameter p_d_gl_date and corresponding validations.
   pathipat     24-SEP-2002    Enh Bug# 2564643: subaccount_id column made obsolete in IGS_FI_CRD_INT and IGS_FI_SA_LOCKBOXES
                               Removed local variables for subaccount_id and removed it in INSERT_ROW().
			       Removed cursor c_subaccount_id and its usage thereafter.
			       Removed all 'DEFAULT NULL' (DEFAULT present only in spec)

   vchappid     13-Jun-2002    Bug#2411529, Incorrectly used message name has been modified
   agairola     27-May-2002    For the bugs 2383820,2336344, modified the log file parameter logging.
   vvutukur     24-May-2002    For bugs 2383820,2336344.modified code to show log file output in multiline.
                               Modified such that parameters are logged first and then show log file in multiline
			       format. Modified l_indicator logic such that it shows all records that are transferred
			       to credits interface table.Called function get_cust_acct_num to show cutomer account name.
   agairola     24-May-2002    For bug 2383846, while inserting record in the Credits Interface table
                               passing NULL to Attribute_Category
   vvutukur     17-May-2002    Added cursor cur_lockbox validation if p_lockbox_num is not null.
                               thrown message IGS_FI_CAPI_INVALID_LOCKBOX if p_lockbox_num parameter
                               is invalid.bug#2372093.
   sykrishn     19-FEB-2002    As part of Enh 2227831
                               Made p_lockbox_num mandatory Param
                               Removed code which executes when p_lockbox_num is NULL (no longer required)

   jbegum       15 Feb 02      As part of Enh bug #2222272
                               Selecting the  org_id from the control table prior to importing the lockbox
                               transactions from Accounts Receivable to Student Finance.
		               Also modified the CURSOR c_control_lockbox_attr

 ***************************************************************/

BEGIN

 /*
  * Enh# 2831582, Lockbox design introduces a new Lockbox functionality
  * detached from Oracle Receivables (AR) Module.
  * Due to this change, the existing processes related to transfer lockbox transactions to AR is obsolesced.
  */
  fnd_message.set_name('IGS', 'IGS_GE_OBSOLETE_JOB');
  fnd_file.put_line( fnd_file.LOG, fnd_message.get());
  retcode := 0;

END transfer_lockbox;
END igs_fi_tran_lockbox_txns;

/
