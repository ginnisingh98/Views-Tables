--------------------------------------------------------
--  DDL for Package Body IGS_FI_BILL_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BILL_EXTRACT" AS
/* $Header: IGSFI61B.pls 120.16 2006/06/27 14:15:06 skharida ship $ */
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --skharida    26-Jun-2006     Bug#5208136 - Modified bill_the_person procedure , removed the usage of obsoleted columns of the table IGS_FI_INV_INT_ALL
  --sapanigr    19-Jun-2006     Bug 5134985 - Modified bill_the_person procedure. Date of first bill for student changed from null.
  --abshriva    8-Jun-2006      Bug 5178298 Invalid Value Message in Log File: Modified the messages
  --abshriva    12-May-2006     Bug#5217319:- Amount precision change in bill_the_person,create_payplan_bills
  --sapanigr    24-Feb-2006     Bug#5018036 - Removed  cursor cur_person_number in bill_the_person procedure and replaced it by function call.
  --sapanigr    15-Feb-2006     Bug#5018036 - Modified cursors in create_payplan_bills and bill_the_person.  (R12 SQL Repository tuning)
  --sapanigr    12-Feb-2006     Bug#5018036 - Modified  cursor cur_person_number in bill_the_person procedure. (R12 SQL Repository tuning)
  --sapanigr    23-Nov-2005     Bug#4744481 - Modified bill_the_person procedure.
  --sapanigr    26-Oct-2005     Bug#4686200 - Modified the bill_the_person procedure.
  --svuppala    04-Oct-2005     Bug# 3813498 Add Fee Class Description To Report To Sponsor From Billing Extract Process
  --                            In PROCEDURE bill_the_person, added new cursor cur_fee_type and added fee_class_meaning
  --                            incase of Sponsor system fee type.
  --uudayapr    28-Jun-2005     Bug 2767636 Modified the bill_the_person procedure.
  --svuppala    11-Mar-2005     Bug 4240402 Timezone impact; truncating the time part in calling place of the table handlers
  --                            IGS_FI_INV_INT_PKG, IGS_FI_CR_ACTIVITIES_PKG, IGS_FI_BILL_PKG.
  --                            Modified the sysdate entries as Trunc(Sysdate).
  --pathipat    21-Jul-2004     Bug 3778782 - Modified procedure billing_extract() and bill_the_person()
  --pathipat    06-May-2004     Bug# 3578249 - Modified procedure billing_extract()
  --vvutukur    23-Jan-2004     Bug#3348787.Modified procedure billing_extract.
  --vvutukur    07-dec-2003     Bug#3146325.Modified bill_the_person and create_payplan_bills.
  --gmaheswa    12-Nov-2003     Bug 3227107, Address Changes. modified cursor cur_remit_addr as to select only active address records.
  --smvk        10-Sep-2003     Bug 3045007, Modified the cursor c_clo_dis_pp_dtls in the procedure create_payplan_bills.
  --smvk        05-Sep-2003     Enh#3045007. Created local procedure create_payplan_bills and its call in billing_extract
  --schodava    25-Aug-2003     Bug #3021943 - Cut off Date parameter issue.
  --shtatiko    21-AUG-2003     Bug# 3106262, modified bill_the_person.
  --vvutukur    18-ul-2003      Enh#3038511.FICR106 Build. Modified procedure bill_the_person.
  --pathipat    23-Jun-2003     Bug: 3018104 - Impact of igs_pe_persid_group change
  --                            Modified cur_person_id_group
  --pathipat    23-Apr-2003     Enh 2831569 - Commercial Receivables build - Modified billing_extract()
  --                            Added validation for manage_account - call to chk_manage_account()
  --shtatiko    12-DEC-2002     Enh Bug#, 2584741 (Deposits), Modified bill_the_person to include Deposit records in report.
  --jbegum      24-Sep-02       Bug#2564643 Removed the parameter p_n_subaccount_id
  --                            from the list parameters passed in call of procedure
  --                            billing_extract.
  --                            Obsoleted the local function get_include_in_bill.
  --                            Modified procedure bill_the_person.
  --                            Removed cursor cur_sub_account_id and validation related to it.
  --vchappid    13-Jun-2002     Bug#2411529, Incorrectly used message name has been modified
  --vchappid    06-Jun-2002     Bug# 2349394, incase the fund code is sponsor then credit type description is passed else the
  --                            bill description from the fund master is passed
  --smadathi    31-May-2002     Bug 2349394. Procedure bill_the_person modified.
  --vchappid    15-May-2002     Bug# 2345299, Message IGS_FI_PRS_OR_PRSIDGRP is replaced with IGS_PRS_PRSIDGRP_NULL as the
  --                            message is not as per the text in the DLD
  --vchappid    07-May-2002     Bug# 2347657, In the cases where the bill is getting generated for the first time, Start Date
  --                            of the bill is hard coded to '01-01-1200'. Removed the hard coded date in this case and in such
  --                            cases Start Date of the Bill would be Null, and the Bill would be Generated till the cut off
  --                            date provided to the process
  --vchappid    29-Apr-2002     Bug# 2347609, Changed the cursor 'cur_remitt_addr' which is having additional where clause
  --                            removed clause 'person_id = p_n_person_id'
  --                            Bug# 2337820, removed the correspondance flag reference in the cursors 'cur_bill_to_addr',
  --                            'cur_remit_addr'
  --                            Bug 2345299, removed the fnd_file.put_line call since it was not writing into the log file of
  --                            the report, instead added to the igs_ge_msg.stack to add into the stack and in the report
  --                            fnd_message.get is used to unwound the stack
  --sarakshi    3-Apr-2002      added code according to sfcr018,bug:2293676, 'vchappid' incorporated review comments
  --sarakshi    27-Feb-2002     bug:2238362, changed the view igs_pe_person_v to igs_fi_parties_v and used the
  --                            function igs_fi_gen_007.validate_person to validate person
  --jbegum     20-Feb-02       As part Enh bug#2228910
  --                           Removed source_transaction_id column from call to
  --                           IGS_FI_INV_INT_PKG.update_row
  --                           Removed the source_transaction_id from Cursor CUR_CHARGE_TRANS_UPD
  --jbegum      09-Feb-02       As part of Enh bug # 2201081
  --                            Added the local function get_include_in_bill
  --maseghal    17-Jan-2002     ENH # 2170429
  --                            Obsoletion of SPONSOR_CD from Cursor CUR_CHARGE_TRANS_UPD  and
  --                                                          UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler
  --smadathi    08-Oct-2001     Balance_flag references Removed from bill_the_person Procedure.
  --                            This is as per enhancement bug no. 2030448

  -------------------------------------------------------------------
  --
  --  Procedure billing_extract generates the Bill Number and consolidates
  --  the related Billing information into the extract tables.
  --  o  The input parameters to this process identify the Person
  --     for which the Billing needs to be done.
  --  o  It also identifies the period, in terms of Cut Off date, for which
  --     the Billing is to be carried out. All Outstanding Charges and any new
  --     Credits against the Person, since the last Bill was generated,
  --     are picked for creating the new Bill.
  --  o  The user specifies the Due Date, Remittance Address and the Bill To
  --     Address as billing information. A Bill Number is generated by the
  --     process and stored as reference information against the Transaction
  --     records (Charges and Credits) which have been identified to be
  --     included in the Bill.
  --  o  If any of the business rules fail then the reason is recorded as a message.
  --     The Process Logs a message and exits by returning a Status (P_C_STATUS) of
  --     'FALSE' to the calling Program.
  --
  e_resource_busy      EXCEPTION;
  PRAGMA               EXCEPTION_INIT(e_resource_busy,-0054);

  l_b_txn_exist        BOOLEAN := FALSE;

  -- Procedure to create payment plan related billing records. forward declaration
  PROCEDURE create_payplan_bills (p_n_bill_id IN NUMBER, p_n_person_id IN NUMBER, p_d_cut_off_date IN DATE);

  PROCEDURE billing_extract
  (
    p_n_prsid_grp_id               IN     NUMBER,
    p_n_person_id                  IN     NUMBER,
    p_c_test_mode                  IN     VARCHAR2,
    p_d_cutoff_dt                  IN     DATE,
    p_d_due_dt                     IN     DATE,
    p_n_remit_prty_site_id         IN     NUMBER,
    p_c_site_usg_type_cd_1         IN     VARCHAR2,
    p_c_site_usg_type_cd_2         IN     VARCHAR2,
    p_c_site_usg_type_cd_3         IN     VARCHAR2,
    p_c_org_id                     IN     VARCHAR2,
    p_c_status                     OUT NOCOPY    VARCHAR2
  ) AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --abshriva    8-Jun-2006      Bug 5178298 Invalid Value Message in Log File: Added cursor cur_usr_profl_name,
  --                            Modified cursor cur_remit_addr
  --sapanigr    15-Feb-2006     Bug# 5018036 Cursor cur_remit_addr now uses igs_or_inst_org_base_v, hz_party_sites and
  --                            igs_pe_hz_pty_sites igsps instead of igs_or_institution_v orv, igs_pe_addr_v pav
  --svuppala    04-Oct-2005     Bug# 3813498 Add Fee Class Description To Report To Sponsor From Billing Extract Process
  --                            In PROCEDURE bill_the_person, added new cursor cur_fee_type and added fee_class_meaning
  --                            incase of Sponsor system fee type.
  --pathipat    21-Jul-2004     Bug 3778782 - Modified the way bill_the_person is invoked
  --pathipat    06-May-2004     Bug# 3578249 - Modified cursor cur_bill_to_addr_usage
  --vvutukur    20-Jan-2004     Bug#3348787.Modified cursor cur_bill_to_addr_usage.
  --schodava    25-Aug-2003     Bug #3021943 - Cut off Date parameter issue.
  --                            Modified cursor CUR_PERSON_IDS
  --pathipat    23-Jun-2003     Bug: 3018104 - Impact of igs_pe_persid_group change
  --                            Modified cur_person_id_group - replaced igs_pe_persid_group_v
  --                            with igs_pe_persid_group
  --gmaheswa    12-Nov-2003     Bug: 3227107 - Modified cur_remit_addr cursor to check active status of the records.
  ------------------------------------------------------------------
    --
    --  Parameter Explanation :
    --
    --  p_n_prsid_grp_id               -> The Person ID Group, the member of which are to be Billed.
    --  p_n_person_id                  -> The Person ID who has to be Billed.
    --  p_c_test_mode                  -> Whether the Billing Process is run in test mode or not. Default - Yes.
    --  p_d_cutoff_dt                  -> The Cut Off date for Billing.
    --  p_d_due_dt                     -> The Date by which any pending charges identified in this Bill are due.
    --  p_n_remit_prty_site_id         -> The Remittance Address for the Bill. The Party Site ID is recorded here.
    --  p_c_site_usg_type_cd_1         -> The Bill is to be sent to the Physical Addresses of the Billed Person having
    --                                    this address usage. The Lookup Code corresponding to the Usage is recorded here.
    --  p_c_site_usg_type_cd_2         -> The Bill is to be sent to the Physical Addresses of the Billed Person having
    --                                    this address usage. The Lookup Code corresponding to the Usage is recorded here.
    --  p_c_site_usg_type_cd_3         -> The Bill is to be sent to the Physical Addresses of the Billed Person having
    --                                    this address usage. The Lookup Code corresponding to the Usage is recorded here.
    --  p_c_org_id                     -> Context Organisation ID.
    --  p_c_status                     -> The Status with which the Package completes the processing.
    --                                    Valid return values are 'TRUE' or 'FALSE'.
    --
    --
    --  Cursor to find if the Person ID Group is valid.
    --
    CURSOR cur_person_id_group (
             cp_n_prsid_grp_id              IN NUMBER
           ) IS
      SELECT   'Y' found_person_id_group
      FROM     igs_pe_persid_group
      WHERE    group_id = cp_n_prsid_grp_id
      AND      closed_ind = 'N'
      AND      TRUNC(creation_date) <= TRUNC(SYSDATE);

    --  Bug#2564643 Removed cursor cur_sub_account_id

    --
    --  Cursor to find if the Remittance Address is valid and if the Remit Address specified has an active Usage setting same as
    --  the Usage which has been set in the Profile 'IGS: Remit To Address Usage'.
    --  Added as part of the Bug 5178298
    --
    CURSOR cur_remit_addr (
             cp_n_remit_prty_site_id        IN NUMBER,
             cp_d_due_dt                    IN DATE,
             cp_profile_value               IN VARCHAR2
           ) IS
      SELECT  'Y' found_remit_addr
      FROM    igs_or_inst_org_base_v oi,
              hz_party_sites ps,
              igs_pe_hz_pty_sites igsps,
              igs_pe_partysiteuse_v ppv
      WHERE   ps.party_site_id = cp_n_remit_prty_site_id
      AND      ps.party_site_id = ppv.party_site_id
      AND     oi.oi_local_institution_ind = 'Y'
      AND     oi.party_id = ps.party_id
      AND     ps.party_site_id = igsps.party_site_id (+)
      AND     oi.inst_org_ind = 'I'
      AND     ppv.site_use_type = cp_profile_value
      AND     ppv.active = 'A'
      AND     (ps.status = 'A'
      AND     ((TRUNC(igsps.start_date) <= TRUNC(SYSDATE) AND TRUNC(igsps.start_date) <= TRUNC(cp_d_due_dt)) OR igsps.start_date IS NULL)
      AND     ((TRUNC(igsps.end_date) >= TRUNC(SYSDATE) AND TRUNC(igsps.end_date) >= TRUNC(cp_d_due_dt))  OR igsps.end_date IS NULL));

    --  Cursor to find if any of the Bill To Address Usage 1, 2, 3 is valid.
    --
    CURSOR cur_bill_to_addr_usage (
             cp_c_site_usg_type_cd          IN VARCHAR2
           ) IS
      SELECT   'Y' found_bill_to_addr_usage
      FROM   fnd_lookup_values
      WHERE  lookup_type = 'PARTY_SITE_USE_CODE'
      AND    lookup_code = cp_c_site_usg_type_cd
      AND    view_application_id = 222
      AND    security_group_id  = 0
      AND    language  = USERENV('LANG')
      AND    enabled_flag = 'Y'
      AND    TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE)) AND NVL(end_date_active,TRUNC(SYSDATE));

    --
    --  Cursor to find the Person IDs that are part of the Person ID Group.
    --
    CURSOR cur_person_ids (
             cp_n_prsid_grp_id              IN NUMBER
           ) IS
      SELECT   person_id
      FROM     igs_pe_prsid_grp_mem
      WHERE    group_id = cp_n_prsid_grp_id
      AND      NVL(start_date,SYSDATE) <= SYSDATE
      AND      NVL(end_date,SYSDATE) >= SYSDATE;

     -- Cursor to find User Profile option name
     -- Added as part of the Bug 3804379
     --
     CURSOR cur_usr_profl_name IS
      SELECT user_profile_option_name
      FROM fnd_profile_options_vl
      WHERE (profile_option_name LIKE 'IGS_REMIT_TO_ADD_USG');
    --
    rec_cur_person_id_group cur_person_id_group%ROWTYPE;
    rec_cur_remit_addr cur_remit_addr%ROWTYPE;
    rec_cur_bill_to_addr_usage cur_bill_to_addr_usage%ROWTYPE;
    --

    l_v_manage_acc      igs_fi_control_all.manage_accounts%TYPE  := NULL;
    l_v_message_name    fnd_new_messages.message_name%TYPE       := NULL;
    l_v_usr_profl_name   fnd_profile_options_vl.user_profile_option_name%TYPE := NULL;
    l_v_bill_usg_lkp_type fnd_lookup_values.lookup_type%TYPE := 'PARTY_SITE_USE_CODE';
    l_n_use_num NUMBER;


    PROCEDURE bill_the_person (
      p_n_person_id                  IN NUMBER
    ) IS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --skharida    26-Jun-2006     Bug# 5208136 - Removed the usage of obsoleted columns of the table IGS_FI_INV_INT_ALL
  --sapanigr    19-Jun-2006     Bug 5134985 - First bill for a student modified to show start date as earlier of first charge or credit date.
  --                            Earlier this field was being left null.
  --abshriva    8-Jun-2006     Bug 5178298 Invalid Value Message in Log File: Added proper messages
  --
  --abshriva    12-May-2006     Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
  --sapanigr    24-Feb-2006     Bug#5018036 - Cursor cur_person_number removed and replaced by call to function igs_fi_gen_008.get_party_number.
  --sapanigr    15-Feb-2006     Bug#5018036 - Cursor cur_bill_to_addr was a union of three select stmts. This is
  --                            changed to one select statement by using IN function to reduce share memory usage.
  --sapanigr    12-Feb-2006     Bug#5018036 - Cursor cur_person_number now queries hz_parties instead of igs_fi_parties_v. (R12 SQL Repository tuning)
  --sapanigr    23-Nov-2005     Bug#4744481 - Cursor cur_bill_to_addr modifed to check for active address usage.
  --sapanigr    26-Oct-2005     Bug#4686200 - Modified the Cursor cur_bill_to_addr to check for active address.
  --svuppala    04-Oct-2005     Bug# 3813498 Add Fee Class Description To Report To Sponsor From Billing Extract Process
  --                            Added new cursor cur_fee_type and added fee_class_meaning
  --                            incase of Sponsor system fee type.
  --agairola    29-Aug-2005     Tuition Waiver Build: Modified changes as per TD
  --uudayapr    01-Aug-2005     Bug#2767636  Modified the Cursor cur_bill_to_addr to add the Start and End Date
  --pmarada     26-May-2005     Enh#3020586- added tax year code column as per 1098-t reporting build
  --pathipat    21-Jul-2004     Bug 3778782 - Raised exception instead of RETURN if Bill To address usage is not defined for a person.
  --                            Removed addition to stack for Bill To address validation failure and Planned Credits validation failure.
  --vvutukur     07-dec-2003    Bug#3146325.Removed cursor cur_transactions_found and its usage. Added logic to
  --                            rollback the bill txns if no records found for processing.This is done using
  --                            boolean variable.
  --shtatiko     21-AUG-2003    Bug# 3106262, Added reversal_gl_date column to igs_fi_inv_int_pkg.update_row call
  --                            and added gl_date, gl_posted_date and posting_control_id columns to igs_fi_cr_activities_pkg calls
  --vvutukur    18-ul-2003      Enh#3038511.FICR106 Build. Modified cursor cur_planned_crd to to exclude the
  --                            planned credits for which the Award Year status is not OPEN.
  --shtatiko    12-DEC-2002     Enh Bug# 2584741, Added c_bill_deposits and modified code so that report will include
  --                            Deposit records in report.
  --jbegum      24-Sep-02       Bug#2564643
  --                            Modified procedure bill_the_person as follows:
  --                               Removed call to local function get_include_in_bill.
  --                               Removed the local variable l_psa_exist.
  --                               Removed cursor cur_sub_accts , which finds the Sub Account details for a given Sub Account.
  --                               Modified the following cursors by removing parameter subaccount_id to cursor
  --                               and usage of column subaccount_id in where clause.Also modified code related
  --                               to management of all these cursors accordingly.
  --                                 cur_start_date,cur_charge_trans,cur_charge_trans_upd,cur_credit_trans,
  --                                 cur_opening_balance,cur_charges_total,cur_credits_total,cur_transactions_found,
  --                                 and cur_planned_crd.
  --                               Removed code assigning value to token SUB_ACCOUNT_NAME.
  --                               Removed the parameter p_subaccount_id in call to igs_fi_gen_001.finp_get_total_planned_credits
  --                               Removed the parameter subaccount_id from relevant TBH calls.
  --vchappid    13-Jun-2002     Bug#2411529, Incorrectly used message name has been modified
  --vchappid    06-Jun-2002     Bug# 2349394, incase the fund code is sponsor then credit type description is passed else the
  --                            bill description from the fund master is passed
  --smadathi    31-May-2002     Bug 2349394. Cursor cur_planned_crd modified to select the column bill_desc from
  --                            igf_aw_fund_mast MO view. Also the insert row call to IGS_FI_BILL_PLN_CRD_PKG modified
  --                            to add new column bill_desc.
  --vchappid    29-Apr-2002     Bug# 2347609, Changed the cursor 'cur_remitt_addr' which is having additional where clause
  --                            removed clause 'person_id = p_n_person_id'
  --                            Bug# 2337820, removed the correspondance flag reference in the cursors 'cur_bill_to_addr',
  --                            'cur_remit_addr'
  --                            Bug 2345299, removed the fnd_file.put_line call since it was not writing into the log file of
  --                            the report, instead added to the igs_ge_msg.stack to add into the stack and in the report
  --                            fnd_message.get is used to unwound the stack
  --sarakshi    3-Apr-2002      added code according to sfcr018,bug:2293676
  --jbegum      9-Feb-02        In the following cursors the join with the IGS_FI_PARTY_SUBACTS table
  --                            was removed as part of Enh bug # 2201081
  --                            CUR_CHARGE_TRANS , CUR_CHARGE_TRANS_UPD ,CUR_CHARGES_TOTAL,CUR_TRANSACTIONS_FOUND
  --sarakshi    21-jan-2002     removed fee_cal_type,fee_ci_sequence_number from the where clause of cursor
  --                            cur_charge_trans,cur_charges_total,cur_transactions_found and
  --                            cur_charge_trans_upd, bug:2175865
  --smadathi    08-Oct-2001     Balance_flag references Removed from  igs_fi_inv_int_pkg.update_row call and
  --                            cur_charge_trans_upd cursor and optional_fee_flag added. This is as per enhancement bug no. 2030448
  -------------------------------------------------------------------

      --  Bug#2564643 Removed cursor cur_sub_accts

      --  Bug#2564643 Modified cursor defination of cur_start_date
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.
      --
      --  Cursor to find the Start Date for the current Billing.
      --
      CURSOR cur_start_date (
               cp_n_person_id                  IN NUMBER
             ) IS
        SELECT   (MAX (cut_off_date) + 1) start_date
        FROM     igs_fi_bill
        WHERE    person_id = cp_n_person_id;

      --  Bug#2564643 Modified cursor defination of cur_charge_trans
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.
      --
      --  Cursor to find the Charge Transactions made by the Person.
      --  The Charge transactions are identified on the basis of the Transaction Date.
      --  The Effective Date is not to be considered for this purpose.
      --
      CURSOR cur_charge_trans (
               cp_n_person_id                 IN NUMBER,
               cp_d_start_date                IN DATE,
               cp_d_cutoff_dt                 IN DATE
             ) IS
        SELECT   inv.invoice_id invoice_id,
                 inv.invoice_number invoice_number,
                 inv.fee_type fee_type,
                 inv.invoice_creation_date invoice_creation_date,
                 inv.invoice_desc invoice_desc,
                 NVL (inv.invoice_amount, 0) invoice_amount
        FROM     igs_fi_inv_int inv
        WHERE    inv.person_id = cp_n_person_id
        AND      (cp_d_start_date IS NULL OR (TRUNC(inv.invoice_creation_date) >= TRUNC(cp_d_start_date)))
        AND      TRUNC(inv.invoice_creation_date) <= TRUNC(cp_d_cutoff_dt)
        AND      inv.bill_date IS NULL
        FOR UPDATE NOWAIT;

      --  Bug#2564643 Modified cursor defination of cur_charge_trans_upd
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.
      --
      --  Cursor to find the Charge Transactions made by the Person .
      --  The Charge transactions are identified on the basis of the Transaction Date.
      --  The Effective Date is not to be considered for this purpose.
      --  **
      --  ** This cursor is meant for updation of the values in igs_fi_inv_int table **
      --  ** Balance_flag reference is removed from cur_charge_trans_upd
      --

      --Change History
      --Who           When            What
      --skharida      26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns from the cursor
      --jbegum        20 Feb 02       Enh bug#2228910
      --                              Removed the source_transaction_id from Cursor CUR_CHARGE_TRANS_UPD
      --masehgal      17-Jan-2002     ENH # 2170429
      --                              Obsoletion of SPONSOR_CD from Cursor CUR_CHARGE_TRANS_UPD

      CURSOR cur_charge_trans_upd (
               cp_n_person_id                 IN NUMBER,
               cp_d_start_date                IN DATE,
               cp_d_cutoff_dt                 IN DATE
             ) IS
        SELECT   inv.row_id row_id,
                 inv.invoice_id invoice_id,
                 inv.person_id person_id,
                 inv.fee_type fee_type,
                 inv.fee_cat fee_cat,
                 inv.fee_cal_type fee_cal_type,
                 inv.fee_ci_sequence_number fee_ci_sequence_number,
                 inv.course_cd course_cd,
                 inv.attendance_mode attendance_mode,
                 inv.attendance_type attendance_type,
                 inv.invoice_amount_due invoice_amount_due,
                 inv.invoice_creation_date invoice_creation_date,
                 inv.invoice_desc invoice_desc,
                 inv.transaction_type transaction_type,
                 inv.currency_cd currency_cd,
                 inv.exchange_rate exchange_rate,
                 inv.status status,
                 inv.attribute_category attribute_category,
                 inv.attribute1 attribute1,
                 inv.attribute2 attribute2,
                 inv.attribute3 attribute3,
                 inv.attribute4 attribute4,
                 inv.attribute5 attribute5,
                 inv.attribute6 attribute6,
                 inv.attribute7 attribute7,
                 inv.attribute8 attribute8,
                 inv.attribute9 attribute9,
                 inv.attribute10 attribute10,
                 inv.org_id org_id,
                 inv.invoice_amount invoice_amount,
                 inv.bill_id bill_id,
                 inv.bill_number bill_number,
                 inv.bill_date bill_date,
                 inv.waiver_flag waiver_flag,
                 inv.waiver_reason waiver_reason,
                 inv.effective_date effective_date,
                 inv.invoice_number invoice_number,
                 inv.bill_payment_due_date bill_payment_due_date,
                 inv.last_update_date last_update_date,
                 inv.last_updated_by last_updated_by,
                 inv.creation_date creation_date,
                 inv.created_by created_by,
                 inv.last_update_login last_update_login,
                 inv.request_id request_id,
                 inv.program_application_id program_application_id,
                 inv.program_id program_id,
                 inv.program_update_date program_update_date,
                 inv.optional_fee_flag optional_fee_flag,
                 inv.reversal_gl_date reversal_gl_date,
                 inv.tax_year_code tax_year_code,
		 inv.waiver_name
        FROM     igs_fi_inv_int inv
        WHERE    inv.person_id = cp_n_person_id
        AND      (cp_d_start_date IS NULL OR (TRUNC(inv.invoice_creation_date) >= TRUNC(cp_d_start_date)))
        AND      TRUNC(inv.invoice_creation_date) <= TRUNC(cp_d_cutoff_dt)
        AND      inv.bill_date IS NULL;

      --  Bug#2564643 Modified cursor defination of cur_credit_trans
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.
      --
      --  Cursor to find the Credit Transactions (Cleared Credit and Reversed Credit) made by the Person.
      --  The Credit transactions are identified on the basis of the Effective Date.
      --  The Transaction Date is not to be considered for this purpose.
      --
      CURSOR cur_credit_trans (
               cp_n_person_id                 IN NUMBER,
               cp_d_start_date                IN DATE,
               cp_d_cutoff_dt                 IN DATE
             ) IS
        SELECT   credit_activity_id,
                 credit_number,
                 effective_date,
                 credit_type,
                 description,
                 (-amount) amount  -- Negate the amount since this is a Credit Transaction.
        FROM     igs_fi_crdt_trnsctns
        WHERE    person_id = cp_n_person_id
        AND      (cp_d_start_date IS NULL OR (TRUNC(effective_date) >= TRUNC(cp_d_start_date)))
        AND      TRUNC(effective_date) <= TRUNC(cp_d_cutoff_dt)
        AND      credit_activity_id IN (SELECT   credit_activity_id
                                            FROM     igs_fi_cr_activities
                                            WHERE    bill_date IS NULL)
        FOR UPDATE OF credit_activity_id NOWAIT;

      --
      --  Cursor to find the Bill To Address from the Party Site IDs.
      --

      CURSOR cur_bill_to_addr (
               cp_c_site_usg_type_cd_1        IN VARCHAR2,
               cp_c_site_usg_type_cd_2        IN VARCHAR2,
               cp_c_site_usg_type_cd_3        IN VARCHAR2
             ) IS
         SELECT   pav.addr_line_1,
                  pav.addr_line_2,
                  pav.addr_line_3,
                  pav.addr_line_4,
                  pav.city,
                  pav.state,
                  pav.province,
                  pav.county,
                  pav.country,
                  pav.postal_code,
                  pav.delivery_point_code
         FROM     igs_pe_addr_v pav,
                  igs_pe_partysiteuse_v ppv
         WHERE    pav.person_id = p_n_person_id
         AND      pav.party_site_id = ppv.party_site_id
         AND      ppv.site_use_type IN (cp_c_site_usg_type_cd_1,cp_c_site_usg_type_cd_2,cp_c_site_usg_type_cd_3)
         AND      TRUNC(SYSDATE) BETWEEN TRUNC(NVL(pav.start_dt,SYSDATE))
         AND      TRUNC(NVL(pav.end_dt,SYSDATE))
         AND      pav.status = 'A'
         AND      ppv.active = 'A';

      --
      --  Cursor to find the Remittance Address from the Remittance Party Site ID.
      --
      CURSOR cur_remitt_addr (
               cp_n_remit_prty_site_id        IN NUMBER
             ) IS
        SELECT   addr_line_1,
                 addr_line_2,
                 addr_line_3,
                 addr_line_4,
                 city,
                 state,
                 province,
                 county,
                 country,
                 postal_code,
                 delivery_point_code
        FROM     igs_pe_addr_v
        WHERE    party_site_id = cp_n_remit_prty_site_id;

      --  Bug#2564643 Modified cursor defination of cur_opening_balance
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.
      --
      --  Cursor to find the Opening Balance from the Closing Balance of the Previous Bill.
      --
      CURSOR cur_opening_balance (
               cp_n_person_id                 IN NUMBER,
               cp_d_start_dt                  IN DATE
             ) IS
        SELECT   NVL (closing_balance, 0) closing_balance
        FROM     igs_fi_bill
        WHERE    person_id = cp_n_person_id
        AND      TRUNC(cut_off_date) = TRUNC(cp_d_start_dt - 1);

      --  Bug#2564643 Modified cursor defination of cur_charges_total
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.
      --
      --  Cursor to find the Charge Amount made by the Person .
      --  The Charge transactions are identified on the basis of the Transaction Date.
      --  The Effective Date is not to be considered for this purpose.
      --
      CURSOR cur_charges_total (
               cp_n_person_id                 IN NUMBER,
               cp_d_start_date                IN DATE,
               cp_d_cutoff_dt                 IN DATE
             ) IS
        SELECT   NVL (SUM (inv.invoice_amount), 0) total_charge_amount
        FROM     igs_fi_inv_int inv
        WHERE    inv.person_id = cp_n_person_id
        AND      (cp_d_start_date IS NULL OR (TRUNC(inv.invoice_creation_date) >= TRUNC(cp_d_start_date)))
        AND      TRUNC(inv.invoice_creation_date) <= TRUNC(cp_d_cutoff_dt)
        AND      inv.bill_date IS NULL;

      --  Bug#2564643 Modified cursor defination of cur_credits_total
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.
      --
      --  Cursor to find the Credit Amount (Cleared Credit and Reversed Credit) made by the Person .
      --  The Credit transactions are identified on the basis of the Effective Date.
      --  The Transaction Date is not to be considered for this purpose.
      --
      CURSOR cur_credits_total (
               cp_n_person_id                 IN NUMBER,
               cp_d_start_date                IN DATE,
               cp_d_cutoff_dt                 IN DATE
             ) IS
        SELECT   NVL (SUM (amount), 0) total_credit_amount
        FROM     igs_fi_crdt_trnsctns
        WHERE    person_id = cp_n_person_id
        AND      (cp_d_start_date IS NULL OR (TRUNC(effective_date) >= TRUNC(cp_d_start_date)))
        AND      TRUNC(effective_date) <= TRUNC(cp_d_cutoff_dt)
        AND      credit_activity_id IN (SELECT   credit_activity_id
                                            FROM     igs_fi_cr_activities
                                            WHERE    bill_date IS NULL);

      --
      --  Cursor to find the Credit History records for a Person.
      --
      CURSOR cur_credit_hist (
               cp_n_credit_act_id             IN NUMBER
             ) IS
        SELECT   ca.rowid,
                 ca.*
        FROM     igs_fi_cr_activities ca
        WHERE    credit_activity_id = cp_n_credit_act_id;
      --
      l_d_start_date DATE;
      l_d_min_inv_dt DATE;
      l_d_min_crd_dt DATE;
      l_n_opening_balance NUMBER;
      l_n_closing_balance NUMBER;
      l_n_bill_id_seq NUMBER;
      l_r_bill_row_id VARCHAR2(25);
      l_r_bill_trans_row_id VARCHAR2(25);
      l_r_bill_addr_row_id VARCHAR2(25);
      l_n_transaction_id NUMBER;
      l_n_bill_addr_id NUMBER;
      l_person_number hz_parties.party_number%TYPE;
      rec_cur_charges_total cur_charges_total%ROWTYPE;
      rec_cur_credits_total cur_credits_total%ROWTYPE;
      rec_cur_bill_to_addr cur_bill_to_addr%ROWTYPE;
      rec_cur_remitt_addr cur_remitt_addr%ROWTYPE;
      rec_cur_credit_hist cur_credit_hist%ROWTYPE;

      --
      --  Bug#2564643 Modified cursor defination of cur_planned_crd
      --  Removed the parameter subaccount_id to cursor and usage of column
      --  subaccount_id in where clause.

      CURSOR cur_planned_crd(cp_person_id     igf_ap_fa_base_rec.person_id%TYPE,
                             cp_cutoff_dt     igf_aw_awd_disb.disb_date%TYPE) IS
      SELECT
        disb.award_id,
        disb.disb_num,
        disb.disb_date,
        fmast.fund_id,
        disb.ld_cal_type,
        disb.ld_sequence_number,
        disb.disb_net_amt,
        fmast.bill_desc,
        cr.description,
        fcat.fed_fund_code
      FROM
        igf_aw_awd_disb disb,
        igf_aw_award   awd,
        igf_aw_fund_mast fmast,
        igf_aw_fund_cat fcat,
        igf_ap_fa_base_rec base,
        igs_fi_cr_types cr,
        igf_ap_batch_aw_map bm
      WHERE  disb.award_id          = awd.award_id
      AND    awd.fund_id            = fmast.fund_id
      AND    awd.base_id            = base.base_id
      AND    fmast.credit_type_id   = cr.credit_type_id (+)
      AND    fmast.fund_code        = fcat.fund_code
      AND    fmast.ci_cal_type      = bm.ci_cal_type
      AND    fmast.ci_sequence_number = bm.ci_sequence_number
      AND    awd.award_status       ='ACCEPTED'
      AND    disb.trans_type        = 'P'
      AND    disb.show_on_bill      = 'Y'
      AND    base.person_id         = cp_person_id
      AND    TRUNC(disb.disb_date) <= TRUNC(cp_cutoff_dt)
      AND    bm.award_year_status_code = 'O';

      -- The following cursor has been added as a part of Deposits Build (Bug# 2584741)
      -- This cursor will fetch records which are to be included in report. These are
      -- inserted into igs_fi_bill_dpsts_table from where report will pick up data.
      CURSOR c_bill_deposits (cp_n_person_id igs_pe_person_v.person_id%TYPE,
                              cp_c_rec_installed IN VARCHAR2,
                              cp_d_start_date IN DATE,
                              cp_d_cutoff_dt IN DATE) IS
      SELECT
        cra.credit_activity_id
      FROM
        igs_fi_cr_activities cra,
        igs_fi_credits cr,
        igs_fi_cr_types crt
      WHERE
        cra.status = 'CLEARED'
        AND cr.party_id = cp_n_person_id
        AND cra.credit_id = cr.credit_id
        AND cr.credit_type_id = crt.credit_type_id
        AND crt.credit_class IN ('ENRDEPOSIT', 'OTHDEPOSIT')
        AND (cp_d_start_date IS NULL
             OR (TRUNC(cr.effective_date) >= TRUNC(cp_d_start_date) ))
        AND TRUNC(cr.effective_date) <= TRUNC(cp_d_cutoff_dt)
        AND cra.bill_id IS NULL
        AND (
             (cp_c_rec_installed = 'Y'
              AND cra.dr_gl_ccid IS NOT NULL
              AND cra.cr_gl_ccid IS NOT NULL
             )
             OR
             (cp_c_rec_installed = 'N'
              AND cra.dr_account_cd IS NOT NULL
              AND cra.cr_account_cd IS NOT NULL
             )
            )
        FOR UPDATE OF credit_activity_id NOWAIT;
      rec_bill_deposits c_bill_deposits%ROWTYPE;
      l_c_bill_deposits_row_id VARCHAR2(25);

      l_planned_credits  igs_fi_bill_pln_crd.pln_credit_amount%TYPE;
      l_to_pay_amount    igs_fi_bill.to_pay_amount%TYPE;
      l_message_name     fnd_new_messages.message_name%TYPE:=NULL;
      l_pln_crd_setup    igs_fi_control_all.planned_credits_ind%TYPE;
      l_pln_crd_rowid    VARCHAR2(25);
      l_fee_cal_type     igs_fi_bill_pln_crd.fee_cal_type%TYPE;
      l_fee_ci_seq_num   igs_fi_bill_pln_crd.fee_ci_sequence_number%TYPE;
      l_flag             BOOLEAN := TRUE;
      l_bill_desc        igs_fi_bill_pln_crd.bill_desc%TYPE;
      l_c_rec_installed  igs_fi_control.rec_installed%TYPE;

      -- Bug #3813498 To get system fee type and fee class associated with the fee_type
      CURSOR cur_fee_type(cp_fee_type igs_fi_fee_type.fee_type%TYPE) IS
      SELECT s_fee_type, fee_class
      FROM   igs_fi_fee_type ft
      WHERE  fee_type = cp_fee_type;

      l_v_s_fee_type         igs_fi_fee_type.s_fee_type%TYPE;
      l_v_fee_class         igs_fi_fee_type.fee_class%TYPE;
      l_v_fee_class_meaning  igs_lookup_values.meaning%TYPE;

      CURSOR cur_min_inv_dt IS
      SELECT MIN(invoice_creation_date)
      FROM igs_fi_inv_int_all
      WHERE person_id = p_n_person_id;

      CURSOR cur_min_crd_dt IS
      SELECT MIN(effective_date)
      FROM igs_fi_credits_all
      WHERE party_id = p_n_person_id;

    BEGIN

      --Set the flag l_b_txn_exist to FALSE for each person being processed.
      --This flag checks whether atleast one transaction is liable for billing or not.
      l_b_txn_exist := FALSE;

      --
      --  6. Identify the Bill To Address.
      --  Check if the Person has got Bill To Address Usage Types.
      --
      OPEN cur_bill_to_addr (
             p_c_site_usg_type_cd_1,
             p_c_site_usg_type_cd_2,
             p_c_site_usg_type_cd_3
             );
      FETCH cur_bill_to_addr INTO rec_cur_bill_to_addr;
      IF (cur_bill_to_addr%NOTFOUND) THEN
        CLOSE cur_bill_to_addr;
        fnd_message.set_name ('IGS', 'IGS_FI_NO_BILL_TO_ADDR');
        app_exception.raise_exception;  -- Raise exception.  (pathipat)
      END IF;
      CLOSE cur_bill_to_addr;

      --added as a part of bug:2293676
      --Fetching the value of planned credits ind from igs_fi_control,
      --if the out parameter returns any value then return
      l_pln_crd_setup:=igs_fi_gen_001.finp_get_planned_credits_ind(l_message_name);
      IF l_message_name IS NOT NULL THEN
        fnd_message.set_name('IGS',l_message_name);
        -- Raise the exception, message is added to stack in the invoking place in billing_extract()
        app_exception.raise_exception;
      END IF;

        --
        --  4. Identify the Start Date for the Billing Period.
        --     o  The Start date is the next day of the Cut Off Date of the most recent Bill
        --        that was generated for the identified Person .
        --     o  If this is the first Bill being generated for the Person
        --        then there would no start date.
        --     o  All the transaction till the Cut Off Date would be taken for Billing.
        --

        -- Bug#2564643 Removed call to local function get_include_in_bill.
        -- Also removed the IF condition which executed the following code in the
        -- procedure bill_the_person if the function get_include_in_bill returned
        -- 1 else the message IGS_FI_NOT_BLLBL is logged .


          OPEN cur_start_date (
                 p_n_person_id
               );
          FETCH cur_start_date INTO l_d_start_date;
          IF (cur_start_date%NOTFOUND) THEN
            CLOSE cur_start_date;
            l_d_start_date := NULL;
          ELSE
            CLOSE cur_start_date;
            IF (l_d_start_date > p_d_cutoff_dt) THEN
              fnd_message.set_name ('IGS', 'IGS_FI_CUTOFF_LSTDT');
              -- Bug#2564643 Removed code assigning value to token SUB_ACCOUNT_NAME .
              -- Bug#5018036 cur_person_number replaced by call to igs_fi_gen_008.get_party_number
              l_person_number := igs_fi_gen_008.get_party_number(p_n_person_id);
              fnd_message.set_token ('PERSON_NUMBER', l_person_number);
              igs_ge_msg_stack.add;
            END IF;
          END IF;
          --
          --  Compute the following steps only if the Start Date is less than or equal to Cut Off Date
          --
          IF (NVL (l_d_start_date, p_d_cutoff_dt) <= p_d_cutoff_dt) THEN

            --Create a savepoint for bill transactions.
            SAVEPOINT s_bill_txn;

            --
            --  8. Generate the Bill Number / Closing Balance.
            --
            IF (l_d_start_date IS NULL) THEN
              l_n_opening_balance := 0;

             -- If start date is null then assign it the earlier of first charge or credit date.
             OPEN cur_min_inv_dt;
             FETCH cur_min_inv_dt INTO l_d_min_inv_dt;
             CLOSE cur_min_inv_dt;

             OPEN cur_min_crd_dt;
             FETCH cur_min_crd_dt INTO l_d_min_crd_dt;
             CLOSE cur_min_crd_dt;

             IF (nvl(l_d_min_inv_dt,SYSDATE)<nvl(l_d_min_crd_dt,SYSDATE)) THEN
               l_d_start_date := l_d_min_inv_dt;
             ELSE
               l_d_start_date := l_d_min_crd_dt;
             END IF;

            ELSE
              OPEN cur_opening_balance (
                     p_n_person_id,
                     l_d_start_date
                   );
              FETCH cur_opening_balance INTO l_n_opening_balance;
              IF (l_n_opening_balance IS NULL) THEN
                l_n_opening_balance := 0;
              END IF;
              CLOSE cur_opening_balance;
            END IF;
            --
            --  Get the total charge amount.
            --
            OPEN cur_charges_total (
                 p_n_person_id,
                 l_d_start_date,
                 p_d_cutoff_dt
               );
            FETCH cur_charges_total INTO rec_cur_charges_total;
            CLOSE cur_charges_total;
            --
            --  Get the total credit amount.
            --
            OPEN cur_credits_total (
                 p_n_person_id,
                 l_d_start_date,
                 p_d_cutoff_dt
               );
            FETCH cur_credits_total INTO rec_cur_credits_total;
            CLOSE cur_credits_total;

            -- Bug#2564643 Removed the parameter p_subaccount_id in call to
            -- igs_fi_gen_001.finp_get_total_planned_credits

            --Added as a part of bug:2293676,to get the sum of the planned credits
            l_message_name:=NULL;
            IF l_pln_crd_setup =  'Y' THEN
              l_planned_credits:=igs_fi_gen_001.finp_get_total_planned_credits(
                               p_person_id     => p_n_person_id,
                               p_start_date    => NULL,
                               p_end_date      => p_d_cutoff_dt,
                               p_message_name  => l_message_name);
              IF l_message_name IS NOT NULL THEN
                FND_MESSAGE.SET_NAME('IGS',l_message_name);
                igs_ge_msg_stack.add;
                l_flag :=FALSE;
              END IF;
            END IF;

            --Skip the following code if above function returns some messages
            IF l_flag THEN
              l_n_closing_balance := l_n_opening_balance +
                                     NVL (rec_cur_charges_total.total_charge_amount, 0) -
                                     NVL (rec_cur_credits_total.total_credit_amount, 0);
              --
              --  5. Identify the Transactions (Credit - Amount paid by the person/Charge - Amount laid on the person) to be Billed.
              --     o  All the Transactions from the Start Date (l_d_start_date) until the Cut Off Date (p_d_cutoff_dt)
              --        are identified for Billing. The transactions both on the Start Date and the Cut Off Date
              --        are also included in the Bill being generated.
              --
              --added as a part of bug:2293676
              IF l_pln_crd_setup =  'Y' THEN
                l_to_pay_amount:= NVL(l_n_closing_balance,0) - NVL(l_planned_credits,0);
              ELSE
                l_to_pay_amount:=NULL;
              END IF;

              -- Bug#2564643 Removed the subaccount_id from call to igs_fi_bill_pkg.insert_row
              --  9. Insert the data in the Billing Tables.
              --
              --  Insert the Bill Information.
              --  --  Modified bill_date entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact

              l_r_bill_row_id := NULL;
              igs_fi_bill_pkg.insert_row (
                x_rowid                        => l_r_bill_row_id,
                x_bill_id                      => l_n_bill_id_seq,
                x_bill_number                  => NULL,
                x_bill_date                    => TRUNC(SYSDATE),
                x_due_date                     => p_d_due_dt,
                x_person_id                    => p_n_person_id,
                x_bill_from_date               => l_d_start_date,
                x_opening_balance              => igs_fi_gen_gl.get_formatted_amount(l_n_opening_balance),
                x_cut_off_date                 => p_d_cutoff_dt,
                x_closing_balance              => igs_fi_gen_gl.get_formatted_amount(l_n_closing_balance),
                x_to_pay_amount                => igs_fi_gen_gl.get_formatted_amount(l_to_pay_amount), --added as a part of bug:2293676
                x_printed_flag                 => 'N',
                x_print_date                   => NULL,
                x_mode                         => 'R'
              );

              --
              --  Insert the Charge transactions information in the Bill Transactions table.
              --

              FOR rec_cur_charge_trans IN cur_charge_trans (
                                          p_n_person_id,
                                          l_d_start_date,
                                          p_d_cutoff_dt
                                          )
              LOOP

                --Set the flag to TRUE if charge transactions are found for processing.
		l_b_txn_exist := TRUE;

                l_r_bill_trans_row_id := NULL;
                l_n_transaction_id := NULL;


                --- Bug #3813498
                -- Getting system fee type and fee class associated with the fee_type
                OPEN cur_fee_type(rec_cur_charge_trans.fee_type);
                FETCH cur_fee_type INTO l_v_s_fee_type,l_v_fee_class;
                CLOSE cur_fee_type;

                --Check the system fee type is either sponsor
                IF l_v_s_fee_type = 'SPONSOR' THEN
                   -- check if it has Fee_Class defined
                   IF l_v_fee_class IS NOT NULL THEN
                      --Get the fee class meaning
                      l_v_fee_class_meaning := igs_fi_gen_gl.get_lkp_meaning(p_v_lookup_type => 'FEE_CLASS',
                                                                             p_v_lookup_code => l_v_fee_class);

                      --Append the fee class meaning to the invoice_desc
                      rec_cur_charge_trans.invoice_desc := rec_cur_charge_trans.invoice_desc || ' : ' || l_v_fee_class_meaning;

                   END IF;
                END IF;

                igs_fi_bill_trnsctns_pkg.insert_row (
                  x_rowid                        => l_r_bill_trans_row_id,
                  x_transaction_id               => l_n_transaction_id,
                  x_bill_id                      => l_n_bill_id_seq,
                  x_transaction_type             => 'D',
                  x_invoice_creditact_id         => rec_cur_charge_trans.invoice_id,
                  x_transaction_date             => rec_cur_charge_trans.invoice_creation_date,
                  x_transaction_number           => rec_cur_charge_trans.invoice_number,
                  x_fee_credit_type              => rec_cur_charge_trans.fee_type,
                  x_transaction_description      => rec_cur_charge_trans.invoice_desc,
                  x_transaction_amount           => igs_fi_gen_gl.get_formatted_amount(rec_cur_charge_trans.invoice_amount),
                  x_mode                         => 'R'
                );
              END LOOP;

              --
              --  Insert the Credit transactions information in the Bill Transactions table.
              --

              FOR rec_cur_credit_trans IN cur_credit_trans (
                                          p_n_person_id,
                                          l_d_start_date,
                                          p_d_cutoff_dt
                                          )
              LOOP

                --Set the flag to TRUE if credit transactions are found for processing.
		l_b_txn_exist := TRUE;

                l_r_bill_trans_row_id := NULL;
                l_n_transaction_id := NULL;
                igs_fi_bill_trnsctns_pkg.insert_row (
                  x_rowid                        => l_r_bill_trans_row_id,
                  x_transaction_id               => l_n_transaction_id,
                  x_bill_id                      => l_n_bill_id_seq,
                  x_transaction_type             => 'C',
                  x_invoice_creditact_id         => rec_cur_credit_trans.credit_activity_id,
                  x_transaction_date             => rec_cur_credit_trans.effective_date,
                  x_transaction_number           => rec_cur_credit_trans.credit_number,
                  x_fee_credit_type              => rec_cur_credit_trans.credit_type,
                  x_transaction_description      => rec_cur_credit_trans.description,
                  x_transaction_amount           => igs_fi_gen_gl.get_formatted_amount(rec_cur_credit_trans.amount),
                  x_mode                         => 'R'
                );
              END LOOP;

              --Added as a part of bug:2293676
              --Fetching all the planned credits and inserting into igs_fi_bill_pln_crd table
              IF l_pln_crd_setup =  'Y' THEN

                FOR l_cur_planned_crd IN cur_planned_crd(p_n_person_id,p_d_cutoff_dt) LOOP

                  --Set the flag to TRUE if planned credit transactions are found for processing.
		  l_b_txn_exist := TRUE;

                  l_pln_crd_rowid:=NULL;
                  l_message_name:=NULL;
                  IF igs_fi_gen_001.finp_get_lfci_reln(l_cur_planned_crd.ld_cal_type,
                                                       l_cur_planned_crd.ld_sequence_number,
                                                       'LOAD',
                                                       l_fee_cal_type,
                                                       l_fee_ci_seq_num,
                                                       l_message_name) = FALSE THEN
                    l_fee_cal_type:=NULL;
                    l_fee_ci_seq_num:=NULL;
                  END IF;

                  -- incase the fund code is sponsor then credit type description is passed else the
                  -- bill description from the fund master is passed
                  IF (l_cur_planned_crd.fed_fund_code = 'SPNSR') THEN
                    l_bill_desc := l_cur_planned_crd.description;
                  ELSE
                    l_bill_desc := l_cur_planned_crd.bill_desc;
                  END IF;

                  l_pln_crd_rowid := NULL;
                  igs_fi_bill_pln_crd_pkg.insert_row(
                    x_rowid                   => l_pln_crd_rowid,
                    x_bill_id                 => l_n_bill_id_seq,
                    x_award_id                => l_cur_planned_crd.award_id,
                    x_disb_num                => l_cur_planned_crd.disb_num,
                    x_pln_credit_date         => l_cur_planned_crd.disb_date,
                    x_fund_id                 => l_cur_planned_crd.fund_id,
                    x_fee_cal_type            => l_fee_cal_type,
                    x_fee_ci_sequence_number  => l_fee_ci_seq_num,
                    x_pln_credit_amount       => igs_fi_gen_gl.get_formatted_amount(l_cur_planned_crd.disb_net_amt),
                    x_mode                    => 'R',
                    x_bill_desc               => l_bill_desc
                    );
                 END LOOP;
              END IF;


              --
              --  7. Identify the Remittance Address.
              --  Insert the Remittance Address in the Bill Address Table.
              --
              OPEN cur_remitt_addr (p_n_remit_prty_site_id);
              FETCH cur_remitt_addr INTO rec_cur_remitt_addr;
              IF (cur_remitt_addr%FOUND) THEN
                l_r_bill_addr_row_id := NULL;
                l_n_bill_addr_id := NULL;
                igs_fi_bill_addr_pkg.insert_row (
                  x_rowid                        => l_r_bill_addr_row_id,
                  x_bill_addr_id                 => l_n_bill_addr_id,
                  x_bill_id                      => l_n_bill_id_seq,
                  x_addr_type                    => 'R',
                  x_addr_line_1                  => rec_cur_remitt_addr.addr_line_1,
                  x_addr_line_2                  => rec_cur_remitt_addr.addr_line_2,
                  x_addr_line_3                  => rec_cur_remitt_addr.addr_line_3,
                  x_addr_line_4                  => rec_cur_remitt_addr.addr_line_4,
                  x_city                         => rec_cur_remitt_addr.city,
                  x_state                        => rec_cur_remitt_addr.state,
                  x_province                     => rec_cur_remitt_addr.province,
                  x_county                       => rec_cur_remitt_addr.county,
                  x_country                      => rec_cur_remitt_addr.country,
                  x_postal_code                  => rec_cur_remitt_addr.postal_code,
                  x_delivery_point_code          => rec_cur_remitt_addr.delivery_point_code,
                  x_mode                         => 'R'
                );
              END IF;
              CLOSE cur_remitt_addr;
              --
              --  Insert the Bill To Address in the Bill Address Table.
              --
              FOR rec_cur_bill_to_addr1 IN cur_bill_to_addr (
                                           p_c_site_usg_type_cd_1,
                                           p_c_site_usg_type_cd_2,
                                           p_c_site_usg_type_cd_3
                                         )
              LOOP
                EXIT WHEN cur_bill_to_addr%ROWCOUNT > 3;
                l_r_bill_addr_row_id := NULL;
                l_n_bill_addr_id := NULL;
                igs_fi_bill_addr_pkg.insert_row (
                  x_rowid                        => l_r_bill_addr_row_id,
                  x_bill_addr_id                 => l_n_bill_addr_id,
                  x_bill_id                      => l_n_bill_id_seq,
                  x_addr_type                    => 'B',
                  x_addr_line_1                  => rec_cur_bill_to_addr1.addr_line_1,
                  x_addr_line_2                  => rec_cur_bill_to_addr1.addr_line_2,
                  x_addr_line_3                  => rec_cur_bill_to_addr1.addr_line_3,
                  x_addr_line_4                  => rec_cur_bill_to_addr1.addr_line_4,
                  x_city                         => rec_cur_bill_to_addr1.city,
                  x_state                        => rec_cur_bill_to_addr1.state,
                  x_province                     => rec_cur_bill_to_addr1.province,
                  x_county                       => rec_cur_bill_to_addr1.county,
                  x_country                      => rec_cur_bill_to_addr1.country,
                  x_postal_code                  => rec_cur_bill_to_addr1.postal_code,
                  x_delivery_point_code          => rec_cur_bill_to_addr1.delivery_point_code,
                  x_mode                         => 'R'
                );
              END LOOP;

              -- As per Deposits build, Bill should also include the deposit records.
              -- Fllowing code will identify and insert deposit records into Bill Deposits Table
              l_c_rec_installed := igs_fi_gen_005.finp_get_receivables_inst;

              FOR rec_bill_deposits IN c_bill_deposits ( p_n_person_id, l_c_rec_installed, l_d_start_date, p_d_cutoff_dt )
              LOOP

                --Set the flag to TRUE if deposit transactions are found for processing.
		l_b_txn_exist := TRUE;

                l_c_bill_deposits_row_id := NULL;
                igs_fi_bill_dpsts_pkg.insert_row (
                  x_rowid                        => l_c_bill_deposits_row_id,
                  x_bill_id                      => l_n_bill_id_seq,
                  x_credit_activity_id           => rec_bill_deposits.credit_activity_id,
                  x_mode                         => 'R'
                );
              END LOOP;

              -- As per Payment Plan build, to create billing payment plan records, call to the local procedure create_payplan_bills is made
              create_payplan_bills (p_n_bill_id => l_n_bill_id_seq, p_n_person_id => p_n_person_id, p_d_cut_off_date => p_d_cutoff_dt);

              --
              --  10. Update the Charges/Credits table and Commit all data if the process is NOT running in Test Mode.
              --

              --If there are no charges, no credits, no planned credits, no deposits, no payment plan records
              --found for processing..
              IF NOT l_b_txn_exist THEN
                --rollback all the bill transactions.
                ROLLBACK TO s_bill_txn;
              END IF;

              IF (p_c_test_mode = 'N') THEN
                FOR rec_cur_charge_trans IN cur_charge_trans_upd (
                                              p_n_person_id,
                                              l_d_start_date,
                                              p_d_cutoff_dt
                                            )
                LOOP

                  --Change History
                  --Who          When           What
                  --skharida     26-Jun-2006    Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
                  --shtatiko     21-AUG-2003    Bug@ 3106262, Added reversal_gl_date column to igs_fi_inv_int_pkg.update_row
                  --jbegum       24-Sep-02      Enh Bug#2564643
                  --                            Removed the subaccount_id parameter from call to igs_fi_inv_int_pkg.update_row
                  --jbegum       20 feb 02      Enh bug # 2228910
                  --                            Removed the source_transaction_id column from igs_fi_inv_int_pkg.update_row
                  --masehgal     17-Jan-2002    ENH # 2170429
                  --                            Obsoletion of SPONSOR_CD from UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler
                  --svuppala     21-Mar-2005    Modified bill_date entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact

                  igs_fi_inv_int_pkg.update_row (
                    x_rowid                                 => rec_cur_charge_trans.row_id,
                    x_invoice_id                            => rec_cur_charge_trans.invoice_id,
                    x_person_id                             => rec_cur_charge_trans.person_id,
                    x_fee_type                              => rec_cur_charge_trans.fee_type,
                    x_fee_cat                               => rec_cur_charge_trans.fee_cat,
                    x_fee_cal_type                          => rec_cur_charge_trans.fee_cal_type,
                    x_fee_ci_sequence_number                => rec_cur_charge_trans.fee_ci_sequence_number,
                    x_course_cd                             => rec_cur_charge_trans.course_cd,
                    x_attendance_mode                       => rec_cur_charge_trans.attendance_mode,
                    x_attendance_type                       => rec_cur_charge_trans.attendance_type,
                    x_invoice_amount_due                    => rec_cur_charge_trans.invoice_amount_due,
                    x_invoice_creation_date                 => rec_cur_charge_trans.invoice_creation_date,
                    x_invoice_desc                          => rec_cur_charge_trans.invoice_desc,
                    x_transaction_type                      => rec_cur_charge_trans.transaction_type,
                    x_currency_cd                           => rec_cur_charge_trans.currency_cd,
                    x_status                                => rec_cur_charge_trans.status,
                    x_attribute_category                    => rec_cur_charge_trans.attribute_category,
                    x_attribute1                            => rec_cur_charge_trans.attribute1,
                    x_attribute2                            => rec_cur_charge_trans.attribute2,
                    x_attribute3                            => rec_cur_charge_trans.attribute3,
                    x_attribute4                            => rec_cur_charge_trans.attribute4,
                    x_attribute5                            => rec_cur_charge_trans.attribute5,
                    x_attribute6                            => rec_cur_charge_trans.attribute6,
                    x_attribute7                            => rec_cur_charge_trans.attribute7,
                    x_attribute8                            => rec_cur_charge_trans.attribute8,
                    x_attribute9                            => rec_cur_charge_trans.attribute9,
                    x_attribute10                           => rec_cur_charge_trans.attribute10,
                    x_invoice_amount                        => rec_cur_charge_trans.invoice_amount,
                    x_bill_id                               => l_n_bill_id_seq,
                    x_bill_number                           => TO_CHAR (l_n_bill_id_seq),
                    x_bill_date                             => TRUNC(SYSDATE),
                    x_waiver_flag                           => rec_cur_charge_trans.waiver_flag,
                    x_waiver_reason                         => rec_cur_charge_trans.waiver_reason,
                    x_effective_date                        => rec_cur_charge_trans.effective_date,
                    x_invoice_number                        => rec_cur_charge_trans.invoice_number,
                    x_exchange_rate                         => rec_cur_charge_trans.exchange_rate,
                    x_bill_payment_due_date                 => p_d_due_dt,
                    x_optional_fee_flag                     => rec_cur_charge_trans.optional_fee_flag,
                    x_mode                                  => 'R',
                    x_reversal_gl_date                      => rec_cur_charge_trans.reversal_gl_date,
                    x_tax_year_code                         => rec_cur_charge_trans.tax_year_code,
		    x_waiver_name                           => rec_cur_charge_trans.waiver_name
                  );
                END LOOP;

                FOR rec_cur_credit_trans IN cur_credit_trans (
                                          p_n_person_id,
                                          l_d_start_date,
                                          p_d_cutoff_dt
                                            )
                LOOP
                  OPEN cur_credit_hist (rec_cur_credit_trans.credit_activity_id);
                  FETCH cur_credit_hist INTO rec_cur_credit_hist;
                  IF (cur_credit_hist%FOUND) THEN
                    igs_fi_cr_activities_pkg.update_row (
                      x_rowid                        => rec_cur_credit_hist.rowid,
                      x_credit_activity_id           => rec_cur_credit_hist.credit_activity_id,
                      x_credit_id                    => rec_cur_credit_hist.credit_id,
                      x_status                       => rec_cur_credit_hist.status,
                      x_transaction_date             => rec_cur_credit_hist.transaction_date,
                      x_amount                       => rec_cur_credit_hist.amount,
                      x_dr_account_cd                => rec_cur_credit_hist.dr_account_cd,
                      x_cr_account_cd                => rec_cur_credit_hist.cr_account_cd,
                      x_dr_gl_ccid                   => rec_cur_credit_hist.dr_gl_ccid,
                      x_cr_gl_ccid                   => rec_cur_credit_hist.cr_gl_ccid,
                      x_bill_id                      => l_n_bill_id_seq,
                      x_bill_number                  => TO_CHAR (l_n_bill_id_seq),
                      x_bill_date                    => TRUNC(SYSDATE),
                      x_posting_id                   => rec_cur_credit_hist.posting_id,
                      x_mode                         => 'R',
                      x_gl_date                      => rec_cur_credit_hist.gl_date,
                      x_gl_posted_date               => rec_cur_credit_hist.gl_posted_date,
                      x_posting_control_id           => rec_cur_credit_hist.posting_control_id
                    );
                  END IF;
                  CLOSE cur_credit_hist;
                END LOOP;

                -- Update the bill details for deposit records in credit activities table.
                FOR rec_bill_deposits IN c_bill_deposits ( p_n_person_id, l_c_rec_installed, l_d_start_date, p_d_cutoff_dt )
                LOOP
                  -- Get the other credit activity details from cur_credit_hist cursor.
                  -- Modified bill_date entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
                  OPEN cur_credit_hist (rec_bill_deposits.credit_activity_id);
                  FETCH cur_credit_hist INTO rec_cur_credit_hist;
                  IF (cur_credit_hist%FOUND) THEN
                    igs_fi_cr_activities_pkg.update_row (
                      x_rowid                        => rec_cur_credit_hist.rowid,
                      x_credit_activity_id           => rec_cur_credit_hist.credit_activity_id,
                      x_credit_id                    => rec_cur_credit_hist.credit_id,
                      x_status                       => rec_cur_credit_hist.status,
                      x_transaction_date             => rec_cur_credit_hist.transaction_date,
                      x_amount                       => rec_cur_credit_hist.amount,
                      x_dr_account_cd                => rec_cur_credit_hist.dr_account_cd,
                      x_cr_account_cd                => rec_cur_credit_hist.cr_account_cd,
                      x_dr_gl_ccid                   => rec_cur_credit_hist.dr_gl_ccid,
                      x_cr_gl_ccid                   => rec_cur_credit_hist.cr_gl_ccid,
                      x_bill_id                      => l_n_bill_id_seq,
                      x_bill_number                  => TO_CHAR (l_n_bill_id_seq),
                      x_bill_date                    => TRUNC(SYSDATE),
                      x_posting_id                   => rec_cur_credit_hist.posting_id,
                      x_mode                         => 'R',
                      x_gl_date                      => rec_cur_credit_hist.gl_date,
                      x_gl_posted_date               => rec_cur_credit_hist.gl_posted_date,
                      x_posting_control_id           => rec_cur_credit_hist.posting_control_id
                    );
                  END IF;
                  CLOSE cur_credit_hist;
                END LOOP;

                COMMIT;
              END IF;--Test Mode ='N'
            END IF;--l_flag
          END IF; -- NVL (l_d_start_date, p_d_cutoff_dt) <= p_d_cutoff_dt

      RETURN;
      --
    END bill_the_person;
    --
  BEGIN
    --
    --  Set the Organization ID Context.
    --

    igs_ge_gen_003.set_org_id (p_c_org_id);

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                               );
    IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
       fnd_message.set_name('IGS',l_v_message_name);
       igs_ge_msg_stack.add;
       p_c_status := 'FALSE';
       RETURN;
    END IF;

    --
    --  1. Validate the Input Parameters.
    --
    --  At least one of the Parameters : Person ID Group Code or Person ID should be specified.
    --  But both the parameters cannot be specified at the same time.
    --
    IF ((p_n_prsid_grp_id IS NULL) AND (p_n_person_id IS NULL)) THEN
      --
      --  Return FALSE if both the parameters are NULL.
      --
      fnd_message.set_name ('IGS', 'IGS_FI_PRS_PRSIDGRP_NULL');
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    END IF;
    --
    IF ((p_n_prsid_grp_id IS NOT NULL) AND (p_n_person_id IS NOT NULL)) THEN
      --
      --  Return FALSE if both the parameters are NOT NULL.
      --
      fnd_message.set_name ('IGS', 'IGS_FI_PRS_OR_PRSIDGRP');
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    END IF;
    IF (p_n_prsid_grp_id IS NOT NULL) THEN
      --
      --  Check if the Person ID Group Code is valid and not Closed.
      --  Bug 5178298 - changed the message to IGS_FI_INVALID_PARAMETER
      OPEN cur_person_id_group (p_n_prsid_grp_id);
      FETCH cur_person_id_group INTO rec_cur_person_id_group;
      IF (cur_person_id_group%NOTFOUND) THEN
        CLOSE cur_person_id_group;
        fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP'));
        igs_ge_msg_stack.add;
        p_c_status := 'FALSE';
        RETURN;
      ELSE
        CLOSE cur_person_id_group;
      END IF;
    END IF;
    IF (p_n_person_id IS NOT NULL) THEN
      --
      --  Check if the Person ID is valid.
      --  Bug 5178298 - changed the message to IGS_FI_INVALID_PARAMETER
      IF igs_fi_gen_007.validate_person(p_n_person_id) = 'N' THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PARTY'));
        igs_ge_msg_stack.add;
        p_c_status := 'FALSE';
        RETURN;
      END IF;
    END IF;

    --  Bug#2564643 Removed validation to check if the Sub Account ID is valid.
    --  This was being done thru cursor cur_sub_account_id

    --
    --  Check if the value of the parameter Test Mode is valid.
    --  Bug 5178298 - changed the message to IGS_FI_INVALID_PARAMETER
    IF ((p_c_test_mode NOT IN ('Y', 'N')) OR (p_c_test_mode IS NULL)) THEN
      fnd_message.set_name('IGS', 'IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'TEST_MODE'));
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    END IF;
    --
    --  Check if the Cut Off Date is valid.
    --
    IF ((p_d_cutoff_dt >= TRUNC(SYSDATE)) OR (p_d_cutoff_dt IS NULL)) THEN
      fnd_message.set_name ('IGS', 'IGS_FI_CUTOFF_DT');
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    END IF;
    --
    --  Check if the Due Date is valid.
    --
    IF ((p_d_due_dt < TRUNC(SYSDATE)) OR (p_d_due_dt IS NULL)) THEN
      fnd_message.set_name ('IGS', 'IGS_RE_DUE_DT_CANT_BE_PAST_DT');
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    END IF;
    --
    --  Check if the Remittance Address for the bill is valid  and the Remittance Address Usage for the bill is valid.
    --  Bug 5178298 - Modified the cursor and the messages
    --
    IF (p_n_remit_prty_site_id IS NULL) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    ELSE
      OPEN cur_usr_profl_name;
      FETCH cur_usr_profl_name INTO l_v_usr_profl_name;
      IF (cur_usr_profl_name%NOTFOUND) THEN
        CLOSE cur_usr_profl_name;
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        p_c_status := 'FALSE';
        RETURN;
      ELSE
        CLOSE cur_usr_profl_name;
      OPEN cur_remit_addr (
             p_n_remit_prty_site_id,
             p_d_due_dt,
             FND_PROFILE.VALUE('IGS_REMIT_TO_ADD_USG')
           );
      FETCH cur_remit_addr INTO rec_cur_remit_addr;
      IF (cur_remit_addr%NOTFOUND) THEN
        CLOSE cur_remit_addr;
        fnd_message.set_name ('IGS', 'IGS_FI_BILL_REMIT_ADDR_INVALID');
        fnd_message.set_token('REMIT_ADD_USG',l_v_usr_profl_name);
        igs_ge_msg_stack.add;
        p_c_status := 'FALSE';
        RETURN;
      ELSE
        CLOSE cur_remit_addr;
      END IF; -- End of cur_remit_addr%NOTFOUND
    END IF; -- End of cur_usr_profl_name%NOTFOUND
  END IF; -- End of p_n_remit_prty_site_id

    --  Check if the Bill to Address 1 is NOT NULL, and
    --  Bug 5178298 - Modified the message

    IF (p_c_site_usg_type_cd_1 IS NULL) THEN
      fnd_message.set_name('IGS', 'IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'BILL_ADDR_USG_1'));
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    END IF;
    --  Bill To Address Usage 2 is not equal to Bill To Address Usage 1,
    --  Bill To Address Usage 3 is not equal to Bill To Address Usage 1,
    --  Bill To Address Usage 3 is not equal to Bill To Address Usage 2.
    --
    IF ((p_c_site_usg_type_cd_1 = p_c_site_usg_type_cd_2) OR
        (p_c_site_usg_type_cd_1 = p_c_site_usg_type_cd_3) OR
        (p_c_site_usg_type_cd_2 = p_c_site_usg_type_cd_3)) THEN
      fnd_message.set_name ('IGS', 'IGS_FI_BILL_TO_ADDR_USGS');
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    END IF;
    --
    --  Check if the Bill to Address Usage 1 is valid.
    --  Bug 5178298 - Modified the message
    OPEN cur_bill_to_addr_usage (p_c_site_usg_type_cd_1);
    FETCH cur_bill_to_addr_usage INTO rec_cur_bill_to_addr_usage;
    IF (cur_bill_to_addr_usage%NOTFOUND) THEN
      CLOSE cur_bill_to_addr_usage;
      l_n_use_num := 1;
      fnd_message.set_name ('IGS', 'IGS_FI_BILL_TO_ADDUSG');
      fnd_message.set_token ('USG_NUM', l_n_use_num);
      fnd_message.set_token ('ADDR_UGS_VAL', p_c_site_usg_type_cd_1);
      fnd_message.set_token ('BILL_USG_LKP_TYPE', l_v_bill_usg_lkp_type);
      igs_ge_msg_stack.add;
      p_c_status := 'FALSE';
      RETURN;
    ELSE
      CLOSE cur_bill_to_addr_usage;
    END IF;
    IF (p_c_site_usg_type_cd_2 IS NOT NULL) THEN
      --
      --  Check if the Bill to Address Usage 2 is valid.
      --  Bug 5178298 - Modified the message
      OPEN cur_bill_to_addr_usage (p_c_site_usg_type_cd_2);
      FETCH cur_bill_to_addr_usage INTO rec_cur_bill_to_addr_usage;
      IF (cur_bill_to_addr_usage%NOTFOUND) THEN
        CLOSE cur_bill_to_addr_usage;
        l_n_use_num := 2;
        fnd_message.set_name ('IGS', 'IGS_FI_BILL_TO_ADDUSG');
        fnd_message.set_token ('USG_NUM', l_n_use_num);
        fnd_message.set_token ('ADDR_UGS_VAL', p_c_site_usg_type_cd_2);
        fnd_message.set_token ('BILL_USG_LKP_TYPE', l_v_bill_usg_lkp_type);
        igs_ge_msg_stack.add;
        p_c_status := 'FALSE';
        RETURN;
      ELSE
        CLOSE cur_bill_to_addr_usage;
      END IF;
    END IF;
    IF (p_c_site_usg_type_cd_3 IS NOT NULL) THEN
      --
      --  Check if the Bill to Address Usage 3 is valid.
      --  Bug 5178298 - Modified the message
      OPEN cur_bill_to_addr_usage (p_c_site_usg_type_cd_3);
      FETCH cur_bill_to_addr_usage INTO rec_cur_bill_to_addr_usage;
      IF (cur_bill_to_addr_usage%NOTFOUND) THEN
        CLOSE cur_bill_to_addr_usage;
        l_n_use_num := 3;
        fnd_message.set_name ('IGS', 'IGS_FI_BILL_TO_ADDUSG');
        fnd_message.set_token ('USG_NUM', l_n_use_num);
        fnd_message.set_token ('ADDR_UGS_VAL', p_c_site_usg_type_cd_3);
        fnd_message.set_token ('BILL_USG_LKP_TYPE', l_v_bill_usg_lkp_type);
        igs_ge_msg_stack.add;
        p_c_status := 'FALSE';
        RETURN;
      ELSE
        CLOSE cur_bill_to_addr_usage;
      END IF;
    END IF;
    --
    --  2. Identify the Person to be Billed.
    --
    IF (p_n_person_id IS NOT NULL) THEN
      BEGIN
          bill_the_person (p_n_person_id);
      EXCEPTION
          WHEN OTHERS THEN
                 p_c_status := 'WARN';

                 -- Note:  In case of a handled exception with a functional message, SQLERRM would hold the message
                 --        that has been set previously.
                 --        In case of unhandled exception, SQLERRM would hold the ORA error that occured. The same
                 --        would be raised here.

                 -- Log SQLERRM in case of any exception
                 fnd_message.set_name('IGS','IGS_FI_ERR_TXT');
                 fnd_message.set_token('TEXT',SQLERRM);
                 igs_ge_msg_stack.add;

                 -- Log Person Number in the log file.
                 fnd_message.set_name('IGS','IGS_FI_PERSON_NUM');
                 fnd_message.set_token('PERSON_NUM',igs_fi_gen_008.get_party_number(p_n_person_id));
                 igs_ge_msg_stack.add;
      END;
    ELSE
      FOR rec_cur_person_ids IN cur_person_ids (p_n_prsid_grp_id) LOOP
          -- Following procedure bill_the_person invoked in a begin-end block so that
          -- if process errors for one person, it can skip and move to the next person.
          BEGIN
               bill_the_person (rec_cur_person_ids.person_id );
          EXCEPTION
              WHEN OTHERS THEN
                 -- If any exception happens, log the person details and skip.
                 p_c_status := 'WARN';

                 -- Note:  In case of a handled exception with a functional message, SQLERRM would hold the message
                 --        that has been set previously.
                 --        In case of unhandled exception, SQLERRM would hold the ORA error that occured. The same
                 --        would be raised here.

                 -- Log SQLERRM in case of any unhandled exception
                 fnd_message.set_name('IGS','IGS_FI_ERR_TXT');
                 fnd_message.set_token('TEXT',SQLERRM);
                 igs_ge_msg_stack.add;

                 -- Log Person Number in the log file.
                 fnd_message.set_name('IGS','IGS_FI_PERSON_NUM');
                 fnd_message.set_token('PERSON_NUM',igs_fi_gen_008.get_party_number(rec_cur_person_ids.person_id));
                 igs_ge_msg_stack.add;
          END;
      END LOOP;
    END IF;
    --
    --  Return TRUE to the calling program saying that everything went fine.
    --
    -- Set the status to True only if it is not WARN already. This is to maintain the status as
    -- 'WARN' if all persons in a person id group had validation failures, which would have set
    -- the status to WARN.
    IF (p_c_status <> 'WARN') THEN
       p_c_status := 'TRUE';
    END IF;

    RETURN;
    --
  EXCEPTION
    WHEN e_resource_busy THEN
     p_c_status:='FALSE';
     fnd_message.set_name ('IGS', 'IGS_GE_RECORD_LOCKED');
     igs_ge_msg_stack.add;
     RAISE;
    WHEN OTHERS THEN
       ROLLBACK;
       p_c_status := 'FALSE';
       RAISE;
  END billing_extract;

  PROCEDURE create_payplan_bills (p_n_bill_id IN NUMBER, p_n_person_id IN NUMBER, p_d_cut_off_date IN DATE) AS

  /**********************************************************
  Created By : smvk

  Date Created By : 03-Sep-03

  Purpose : For creating paypment plan and installment billing record for a student

  Know limitations, enhancements or remarks

  Change History

  Who           When            What
  abshriva      12-May-2006     Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
  vvutukur      07-dec-2003     Bug#3146325.Used boolean variable l_b_pmtplns_exist to check if any payment plan
                                records are avaiable for processing the bill.
  smvk          10-Sep-2003     Bug 3045007, Modified the cursor c_clo_dis_pp_dtls to select
                                records of plan_end_date less than or equal to cutoff date.
  ***************************************************************/

    -- cursor to select the payment plan contract signed by student and payment plan status is ACTIVE.
    cursor c_act_pp_dtls (cp_n_person_id IN igs_fi_pp_std_attrs.person_id%TYPE) IS
      SELECT *
      FROM   igs_fi_pp_std_attrs
      WHERE  person_id = cp_n_person_id
      AND    plan_status_code = 'ACTIVE';

    --cursor to select the payment plan contract signed by student and payment plan status is CLOSED and DISQUALIFIED.
    cursor c_clo_dis_pp_dtls (cp_n_person_id IN igs_fi_pp_std_attrs.person_id%TYPE,
                              cp_d_cutoff_date IN igs_fi_pp_std_attrs.plan_end_date%TYPE) IS
      SELECT *
      FROM   igs_fi_pp_std_attrs
      WHERE  person_id = cp_n_person_id
      AND    plan_status_code IN ('CLOSED','DISQUALIFIED')
      AND    TRUNC(plan_end_date) <= TRUNC(cp_d_cutoff_date);

    --cursor to select the payment plan installment for the given payment plan identifier
    cursor c_pp_instlmnts ( cp_n_student_plan_id IN igs_fi_pp_instlmnts.student_plan_id%TYPE) IS
      SELECT *
      FROM   igs_fi_pp_instlmnts
      WHERE  student_plan_id = cp_n_student_plan_id;

    l_c_rowid            ROWID;                     -- to hold rowid while using insert_row tbh call.
    rec_act_pp_dtls      c_act_pp_dtls%ROWTYPE;     -- row type Active cursor variable
    rec_clo_dis_pp_dtls  c_clo_dis_pp_dtls%ROWTYPE; -- row type Closed / Disqualified cursor variable
    rec_pp_instlmnts     c_pp_instlmnts%ROWTYPE;    -- row type payment plan installments cursor variable

  BEGIN
    OPEN c_act_pp_dtls(p_n_person_id);
    FETCH c_act_pp_dtls INTO rec_act_pp_dtls;

    IF c_act_pp_dtls%FOUND THEN
      CLOSE c_act_pp_dtls;

      --Set the flag to TRUE if payment plan records are found for processing.
      l_b_txn_exist := TRUE;

      -- create billing payment plan records for active payment plan record
      l_c_rowid := NULL;
      igs_fi_bill_p_plans_pkg.insert_row (
                                               X_ROWID                 => l_c_rowid,
                                               X_STUDENT_PLAN_ID       => rec_act_pp_dtls.student_plan_id,
                                               X_BILL_ID               => p_n_bill_id,
                                               X_PLAN_START_DATE       => rec_act_pp_dtls.plan_start_date,
                                               X_PLAN_END_DATE         => rec_act_pp_dtls.plan_end_date,
                                               X_MODE                  => 'R'
      );

      -- create billing installments record for active payment plan record
      FOR rec_pp_instlmnts IN c_pp_instlmnts(rec_act_pp_dtls.student_plan_id) LOOP
        l_c_rowid := NULL;
        igs_fi_bill_instls_pkg.insert_row(
                                               X_ROWID                 => l_c_rowid,
                                               X_STUDENT_PLAN_ID       => rec_pp_instlmnts.student_plan_id,
                                               X_BILL_ID               => p_n_bill_id,
                                               X_INSTALLMENT_ID        => rec_pp_instlmnts.installment_id,
                                               X_INSTALLMENT_LINE_NUM  => rec_pp_instlmnts.installment_line_num,
                                               X_INSTALLMENT_DUE_DATE  => rec_pp_instlmnts.due_date,
                                               X_INSTALLMENT_AMT       => igs_fi_gen_gl.get_formatted_amount(rec_pp_instlmnts.installment_amt),
                                               X_DUE_AMT               => igs_fi_gen_gl.get_formatted_amount(rec_pp_instlmnts.due_amt),
                                               X_MODE                  => 'R'
        );
      END LOOP; -- end of payment plan installment loop

    ELSE
      CLOSE c_act_pp_dtls;

      -- create billing payment plan records for each closed and disqualified payment plan records
      FOR rec_clo_dis_pp_dtls IN c_clo_dis_pp_dtls(p_n_person_id, p_d_cut_off_date) LOOP

        --Set the flag to TRUE if payment plan records are found for processing.
	l_b_txn_exist := TRUE;

        l_c_rowid := NULL;
        igs_fi_bill_p_plans_pkg.insert_row (
                                                 X_ROWID                 => l_c_rowid,
                                                 X_STUDENT_PLAN_ID       => rec_clo_dis_pp_dtls.student_plan_id,
                                                 X_BILL_ID               => p_n_bill_id,
                                                 X_PLAN_START_DATE       => rec_clo_dis_pp_dtls.plan_start_date,
                                                 X_PLAN_END_DATE         => rec_clo_dis_pp_dtls.plan_end_date,
                                                 X_MODE                  => 'R'
        );

        -- create billing installments record for closed and disqualified payment plan record
        FOR rec_pp_instlmnts IN c_pp_instlmnts(rec_clo_dis_pp_dtls.student_plan_id) LOOP
          l_c_rowid := NULL;
          igs_fi_bill_instls_pkg.insert_row(
                                                 X_ROWID                 => l_c_rowid,
                                                 X_STUDENT_PLAN_ID       => rec_pp_instlmnts.student_plan_id,
                                                 X_BILL_ID               => p_n_bill_id,
                                                 X_INSTALLMENT_ID        => rec_pp_instlmnts.installment_id,
                                                 X_INSTALLMENT_LINE_NUM  => rec_pp_instlmnts.installment_line_num,
                                                 X_INSTALLMENT_DUE_DATE  => rec_pp_instlmnts.due_date,
                                                 X_INSTALLMENT_AMT       => igs_fi_gen_gl.get_formatted_amount(rec_pp_instlmnts.installment_amt),
                                                 X_DUE_AMT               => igs_fi_gen_gl.get_formatted_amount(rec_pp_instlmnts.due_amt),
                                                 X_MODE                  => 'R'
          );

        END LOOP; -- end of payment plan installment loop
      END LOOP; -- end of payment plan loop

    END IF;

  END create_payplan_bills;

END igs_fi_bill_extract;

/
