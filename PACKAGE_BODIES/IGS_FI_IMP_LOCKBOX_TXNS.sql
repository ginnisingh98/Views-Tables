--------------------------------------------------------
--  DDL for Package Body IGS_FI_IMP_LOCKBOX_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_IMP_LOCKBOX_TXNS" AS
/* $Header: IGSFI58B.pls 115.30 2003/05/28 08:56:01 shtatiko ship $ */

  /******************************************************************
  Created By         :Sanjeeb Rakshit
  Date Created By    :25-APR-2001
  Purpose            :This package implements one procedure which insert rows to credits table
                      from interface table if everything is fine else updates the interface table
                      and writes appropriate message in the log file.
  remarks            :
  Change History
  Who        When           What
  shtatiko   28-MAY-2003    Enh# 2831582, Obsoleted this process.
  schodava   09-Apr-2003    Enh#2831554. Modification as a part of the Internal Credits API Build
  vvutukur   20-Jan-2003    Bug#2727223.Modification done in procedure import_lockbox.
  vvutukur   17-Jna-2003    Bug#2743483.Modifications done in procedure import_lockbox.
  vchappid   31-Dec-2002    Bug# 2707089, For import_lockbox interface processes, fnd_stats.gather_table_stats
                            has to be invoked for gathering the statistics.
  shtatiko   09-dec-2002    Enh# 2584741, Modified import_lockbox.
  vvutukur   21-Nov-2002    Enh#2584986.Modifications done in import_lockbox.Modified functions get_log_line,
                            get_cur_desc.
  pathipat   24-SEP-2002    Enh Bug: 2564643:
                            1. Removed references to subaccount_id as the column is being obsoleted (in cursors cur_fei
                                 and cur_subaccount and in log)
                            2. Obsoleted function get_sac_name() as its used only for validating subaccount_id
                            3. Removed paramter p_subaccount_id from call to igs_fi_Credits_api_pub.create_credit()
                            4. Removed reference to subaccount_id from call to igs_fi_crd_int_pkg.update_row()
                            5. Changed message from IGS_FI_SBAC_NOT_FOR_EFF_DT to IGS_FI_CAPI_CR_TYPE_INVALID (for log)

  smadathi   24-Jun-2002     Bug 2404720. Modified the import_lockbox procedure.
  agairola   09-May-2002    Modified the import_lockbox process for the bug fix 2357948
  agairola   24-APR-2002    The following modifications were done as part of Bug fix 2336504
                          1.  Modified the Cursor cur_fei to remove the parameters for Credit Instrument
                              and credit type and also removed them from the Where clause
                          2.  Added the parameter logging
                          3.  The log file was modified to display the data in different lines
                          4.  In the call to credits API, the values of the input
                              parameters Credit Instrument and Credit type were passed.
                          5.  code for validation of the subaccount was optimised.
                          6.  Functions get_pers_num, get_cr_type,get_sac_name, get_log_line and
                              get_cur_desc were introduced for modularisation of code.
                          7.  Modified the concurrent program specification to remove Credit Class parameter
  sarakshi   28-Feb-2002   modified message logging of person to party_id, bug:2238362
  sykrishn   04-FEB-2002   call to credits api modified to include new params as part of SFCR020 build
                             Bug 2191470
                         Related changes w-r-t-o credit_source - removing the parameter and passing the same as null to credits API

  sarakshi 31-Jan-2002   In the call to the credit's API adding a new parameter p_invoice_id as a part of
                        SFCR003 , bug:2195715.
   ******************************************************************/

 PROCEDURE import_lockbox(  errbuf  OUT NOCOPY  VARCHAR2,
                            retcode OUT NOCOPY  NUMBER,
                            p_receipt_lockbox_number igs_fi_crd_int_all.receipt_lockbox_number%TYPE ,
                            p_credit_instrument      igs_fi_crd_int_all.credit_instrument%TYPE ,
                            p_credit_type_id         igs_fi_crd_int_all.credit_type_id%TYPE ,
                            p_org_id                 NUMBER
                          ) AS

  /******************************************************************
  Created By         :Sanjeeb Rakshit
  Date Created By    :25-APR-2001
  Purpose            :This procedure looks at the credit interface table.
                      If the transaction is defined as a valid transaction ,
                      this gets imported in the credit table in student finance
                      .Once data is successfully imported to credit table ,it would
                      be deleted from the interface table.Insertion of data to
                      credits table the credits table is taken care by the credits API.
  remarks            :
  Change History
  Who         When         What
  shtatiko   28-MAY-2003   Enh# 2831582, This process has been obsoleted.
  schodava   09-Apr-2003   Enh#2831554. Modified the call to Public Credits API to Private Credits API.
  vvutukur   20-Jan-2003   Bug#2727223.Logged Status also in the log file as Error, when the currency in the Credits Interface Table does not
                           match with the currency set up in the System Options Form.
  vvutukur   17-Jan-2003   Bug#2743483.Added code for the process to error out if Oracle Financials is not Installed, since this process
                           is valid only when Oracle Financials is Installed.
  vchappid   31-Dec-2002   Bug# 2707089, For import_lockbox interface processes, fnd_stats.gather_table_stats
                           has to be invoked for gathering the statistics.
  shtatiko   09-DEC-2002   Enh# 2584741, Modified cur_subaccount cursor and modified call to
                           igs_fi_credits_api_pub.create_credit.
  vvutukur   21-Nov-2002   Enh#2584986.Modified the calls to igs_fi_credits_api_pub.create_credit,
                           igs_fi_crd_int_pkg.update_row to include p_d_gl_date.Passed p_exchange_rate as 1 in the
                           call to credits api as only local currency that is setup in System Options Form only
                           will be passed to credits api from this call.
  pathipat   24-SEP-2002    Enh Bug: 2564643:
                            1. Removed references to subaccount_id as the column is being obsoleted (in cursors cur_fei
                                 and cur_subaccount and in log)
                            2. Removed paramter p_subaccount_id from call to igs_fi_Credits_api_pub.create_credit()
                            3. Removed reference to subaccount_id from call to igs_fi_crd_int_pkg.update_row()
                            4. Removed DEFAULT NULL for p_receipt_lockbox_number igs_fi_crd_int_all.receipt_lockbox_number%TYPE
                               to prevent gscc warning (as it is already present in spec).

  smadathi   24-Jun-2002  Bug 2404720.The cursor  cur_subaccount select is modified to fetch description
                        column along with the other columns. The call to igs_fi_credits_api_pub.create_credit
                        was modified to pass this description value to the formal parameter p_description
  agairola   09-May-2002  The following modifications were done as part of bug fix 2357948
                        1. Modified the cursor cur_fei to include the Sub Account and the
                           effective start date and end date.
                        2. Modified the cursor cur_subaccount to fetch the Effective Start
                           date and end date.
                        3. Modified the code to fetch the SubAccount for the credit type before
                           the cursor to select the data from the Credits Interface table
                        4. Removed the code inside the cur_fei loop for subaccount validations as this
                           is being done before the cursor cur_fei is opened.
                        5. Modified the code to remove the extra UPDATE_ROW call for updating the status
                           to error for the table IGS_FI_CRD_INT
  agairola 24-APR-2002  The following modifications were done as part of Bug fix 2336504
                        1.  Modified the Cursor cur_fei to remove the parameters for Credit Instrument
                        and credit type and also removed them from the Where clause
                        2.  Added the parameter logging
                        3.  The log file was modified to display the data in different lines
                        4.  In the call to credits API, the values of the input
                            parameters Credit Instrument and Credit type were passed.
                        5.  code for validation of the subaccount was optimised.
  sarakshi 31-Jan-2002  In the call to the credit's API adding a new parameter p_invoice_id as a part of
                        SFCR003 , bug:2195715.
  ******************************************************************/

BEGIN

 /*
  * Enh# 2831582, Lockbox design introduces a new Lockbox functionality
  * detached from Oracle Receivables (AR) Module.
  * Due to this change, the existing processes related to import lockbox transactions from AR is obsolesced.
  */
  fnd_message.set_name('IGS', 'IGS_GE_OBSOLETE_JOB');
  fnd_file.put_line( fnd_file.LOG, fnd_message.get());
  retcode := 0;

END import_lockbox;

 -- end of package body
END igs_fi_imp_lockbox_txns;

/
