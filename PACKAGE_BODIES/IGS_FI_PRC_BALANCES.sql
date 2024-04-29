--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_BALANCES" AS
/* $Header: IGSFI57B.pls 120.4 2006/05/12 05:48:01 abshriva ship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 27052001
  --
  --Purpose: Package Body contains code for procedures/Functions defined in
  --         package specification . Also body includes Functions/Procedures
  --         private to it.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --abshriva    12-May-2006     Bug 5217319: Amount precision change calculate_balance,insert_or_update_balance
  --                            retro_update_balance,convert_holds_balances
  --sapanigr    05-May-2006     Bug 5178077: Modified procedure conv_balances to disable process in R12.
  --sapanigr    14-Feb_2006     Bug 5018036. Cursor c_credit changed in check_exclusion_rules for Repository Perf tuning
  --svuppala   14-JUL-2005      Enh 3392095 - impact of Tution Waivers build
  --                            Modified igs_fi_control_pkg.update_row by adding two new columns
  --                            post_waiver_gl_flag, waiver_notify_finaid_flag
  --uudayapr    23-DEC-2003     ENH#3167098 -Term Based Fee Calc build.
  --schodava    06-Oct-2003     Bug # 3123405 - Modified calculate_balance procedure.
  --jbegum      14-June-2003    Bug# 2998266 Obsoleted the column NEXT_INVOICE_NUMBER.
  --shtatiko    27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
  --                            and ar_int_org_id. For this, Modified finpl_upd_conv_prc_run_ind.
  --vvutukur    16-May-2003     Enh#2831572.Financial Accounting Build.Modified finpl_upd_conv_prc_run_ind.
  --pathipat    23-Apr-2003     Enh 2831569 - Commercial Receivables Interface
  --                            Modified call to igs_fi_control_pkg.update_row
  --                            Modified conv_balances - added validation for manage_accounts
  --smadathi    18-Feb-2002     Enh. Bug 2747329.Modified finpl_upd_conv_prc_run_ind procedure
  --shtatiko    15-JAN-2003     Bug# 2736389, Modified convert_holds_balances to handle validation failure
  --                            cases.
  --pathipat    07-Jan-2003     Bug: 2672837 - Modified convert_holds_balances
  --                            Removed func lookup_desc() as it is no longer used here.
  --vvutukur    11-Dec-2002     Enh#2584741.Modification done in calculate_balance,finpl_upd_conv_prc_run_ind
  --                            procedure.
  --smadathi    02-dec-2002     Bug 2690020. NOCOPY hint added
  --shtatiko    10-Oct-2002     Enh# 2562745 Obsoleted calc_balances concurrent executable.
  --pathipat    08-OCT-2002     Enh# 2562745  Added 2 new public procedures convert_holds_balances() and
  --                            conv_balances() for new concurrent program, Holds Conversion.
  --                            Added private procedure finpl_upd_conv_prc_run_ind().
  --vvutukur    07-Oct-2002    Enh#2562745.Renamed function calculate_balance_1 to public procedure
  --                           calculate_balance. Removed previously existing procedure
  --                           calculate_balance procedure from spec and body.Modified function
  --                           lookup_desc.
  --vvutukur    01-Oct-2002    Enh#2562745.Modified update_balances,retro_update_balance,
  --                           insert_or_update_balance,check_exclusion_rules,calculate_balance_1.
  -- smvk       17-Sep-2002    Removed the usage of subaccout_id in the entire package, As a part of Bug # 2564643.
  --smadathi    03-Jul-2002    Bug 2443082. Modified update_balances procedure. Added new private function
  --                           retro_update_balance.
  --agairola  11-Jun-2002      Bug No:2373963 Modified the code for the calculate_balance and calculate_balance_1
  --agairola    30-May-2002    Bug # 2364505, modified the code for the removal of the Standard Balance Rule Id
  --vvutukur    09-may-2002    Bugs#2329042,2309047,Modifications done in calculate_balance,calculate_balance_1,
  --                                       check_exclusion_rules.
  --smadathi    10-APR-2002     Bug 2289191. Function calculate_balance_1,procedure calculate_balance
  --                            procedure check_exclusion_rules Modified.
  --vvutukur    09-apr-2002     Modifications done in calculate_balance and calculate_balance_1 for
  --                            bug:2172457.
  --vvutukur    10-MAR-2002     Modified the code in calculate_balance_1 for bug:2172457.
  --schodava    28-FEB-2002     Bug #  2244532
  --                            Removed the function check_valid_party_subaccts
  --                            and its call.
  --schodava    27-FEB-2002     Enh # 2238362
  --                            Changes in Person Context Block of Student Finance Forms
  --                            Modified procedure calculate_balance, calculate_balance_1
  --Sarakshi     8-OCT-2001     Bug No:2030448 ,modified procedure calculate_balance and
  --                            calculate_balance_1
  --smadathi    07082001     Fixed Bug No. 1921761 .Modified procedure calculate_balance .
  --Nishikant   10DEC2001    The function check_exclusion_rules added for the
  --                         enhancement bug# 2124001
  -------------------------------------------------------------------

 g_ind_yes                CONSTANT VARCHAR2(1)  := 'Y';
 l_validation_exp         exception;

 -- Cursor for validating the person id
 CURSOR cur_person_number(cp_party_id  IN hz_parties.party_id%TYPE) IS
      SELECT party_number
      FROM    hz_parties
      WHERE  party_id = cp_party_id;

 /* Removed the global variable uses to store the subaccount Name, as a part of Bug # 2564643 */

-- Forward declaration of function retro_update_balance
FUNCTION retro_update_balance
(
               p_n_party_id       IN   igs_fi_balances.party_id%TYPE       ,
             /* Removed th parameter p_n_subaccount_id, as a part of Bug # 2564643 */
               p_c_balance_type   IN   igs_lookups_view.lookup_code%TYPE   ,
               p_d_balance_date   IN   igs_fi_balances.balance_date%TYPE   ,
               p_n_amount         IN   igs_fi_inv_int.invoice_amount%TYPE  ,
               p_c_message        OUT  NOCOPY fnd_new_messages.message_name%TYPE
)
RETURN BOOLEAN;


  -- Bug # 2244532
  -- Removed the FUNCTION check_valid_party_subaccts
  -- as it is deemed obsolete (as per Enh # 2201081)


  PROCEDURE calculate_balance(
                           p_person_id            IN  igs_pe_person_v.person_id%TYPE,
                           p_balance_type         IN  igs_lookup_values.lookup_code%TYPE,
                           p_balance_date         IN  igs_fi_balances.balance_date%TYPE,
                           p_action               IN  VARCHAR2,
                           p_balance_rule_id      IN  igs_fi_balance_rules.balance_rule_id%TYPE,
                           p_balance_amount       OUT NOCOPY igs_fi_balances.standard_balance%TYPE,
                           p_message_name         OUT NOCOPY fnd_new_messages.message_name%TYPE
                           ) AS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 27052001
  --Purpose:This public procedure was earlier a local function calculate_balance_1.
  --        As part of Reassess Balances Build(Enh#2562745), this is made public procedure by adding
  --        4 new parameters hence added to the package spec also.This procedure is called from
  --        Holds Conversion Process, a newly created concurrent program as part of the Reassess
  --        Balances Build, and existing Finance and Late Charges Process also for Holds and Fee Balance
  --        calculation.
  --        This procedure returns the balance amount conditionally on whether the requirement is
  --        "As on a particular balance date" or "For a Particular Balance Date" through the OUT
  --        parameter p_balance_amount.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --abshriva  12-May-2006    Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
  --shtatiko  17-OCT-2003    Bug# 3192641, Modified cursor cur_chrgs_for_balance so that waived charges are considered
  --                         only when the balance type is FEE. For Holds, waived charges are considered in Process that apply/release holds.
  --schodava  06-Oct-2003    Bug # 3123405 - Modified cursors cur_chrgs_for_balance and cur_crds_for_balance.
  --                         Also modified logic, to use the invoice_amount and credit amount, instead of
  --                         invoice_amount_due and unapplied_amount respectively.
  --vvutukur  10-DEC-2002    Enh# 2584741 - Modified cursor cur_crds_for_balance - added join with igs_fi_cr_types
  --                         to exclude deposit records while obtaining records for balances calculation
  --vvutukur  04-Oct-2002    Enh#2562745.Removed references to balance types 'Installment','Other'
  --                         as the same have become obsolete.Renamed this local function calculate_balance_1
  --                         to a public procedure calculate_balance.Modified charges and credits cursors
  --                         to fetch the balance depending upon this procedure's newly added input
  --                         parameter p_action, also added check to pickup records with invoice_amount_due
  --                         or unapplied_amount > 0 only.
  --smvk      17-Sep-2002       Removed the input parameter p_subaccount_id and
  --                            its is usage in this function, as a part of Bug # 2564643.
  --agairola  11-Jun-2002       Bug No:2373963 The following modifications were done
  --                            1. In the WHERE clause of the Cursor for charges added the condition for the
  --                            invoice_creation_date to be less than sysdate
  --                            2. The Balances were getting created/updated only if there were any charges
  --                            or credit records found. Incase of no charges or credits, the balances were
  --                            not getting updated/created. Modified the code to update or create the balance
  --                            even if no charge or credits were found
  --agairola    30-May-2002     Bug # 2364505, modified the code for the removal of the Standard Balance Rule Id
  --vvutukur    09-may-2002     Bugs#2329042,2309047. Modified c_fi_inv_int_all,c_fi_credits_all cursors
  --                            and removed cursor c_igs_fi_bal_rules. Put a call to check_exclusion_rules
  --                            and removed redundant code for assigning cursor fetched values into local variables.
  --smadathi    10-APR-2002     Bug 2289191. References to enabled_flag column removed from cursor
  --                            c_fi_inv_int_all, c_fi_credits_all select list.
  --vvutukur    09-APR-2002     Removed unnecessary condition check for balance_rule_id in where clause of
  --                            c_fi_inv_int_all,c_fi_credits_all cursors.Moved manipulation of cursors
  --                            cur_person_number,cur_subaccount_name out of for loop in calculate_balance_1
  --                            for the improvement of code.for bug#2293676.
  --vvutukur    10-MAR-2002     Removed code which throws error message if no balance rules exist.
  --                            Modified the cursors c_fi_inv_int_all,c_fi_credits_all to select rows even if
  --                            there are no balance rules defined.Shown numbers instead of IDs in case of
  --                            Party,Credit,Invoice and name for Subaccount in the LOG. bug:2172457.
  --schodava    28-FEB-2002     Enh # 2238362
  --                            Modified the logging of messages
  --                            Changed references to 'Person' to 'Party'
  --Nishikant   18DEC2001       The cursor c_fi_inv_int_all modified to exclude the waived charges in the balance Rule.
  --                            Enh Bug#2124001.
  --sarakshi    8-oct-2001   1. removed the parameter accounting method from the call as well as the definition.
  --                            of this function and removed the logic of calculating balance based on accounting method
  --                         2. removed from the cursors selecting records based on the balance_flag condition from
  --                            charges and credits table.
  --                         3. Now balance amount = sum of invoice amount due(from charges table)
  --                                               - sum of unapplied amount(credits table).
  --                         4. We insert a record in the balance table if for a combination of party_id,subaccount_id
  --                            and balance_date no records exists there , else we update the  balance amount depending
  --                            upon the balance type.
  -------------------------------------------------------------------
  l_as_on_baldate        CONSTANT VARCHAR2(20) := 'ASONBALDATE';
  l_for_baldate          CONSTANT VARCHAR2(20) := 'FORBALDATE';

  -- cursor reads from the charges tables
  CURSOR cur_chrgs_for_balance IS
  SELECT inv.*
  FROM   igs_fi_inv_int inv
  WHERE  person_id     = p_person_id      /*for person id passed as parameter*/
  AND    ((p_action    = l_for_baldate   AND TRUNC(inv.invoice_creation_date) = TRUNC(p_balance_date))
          OR (p_action = l_as_on_baldate AND TRUNC(inv.invoice_creation_date) <= TRUNC(NVL(p_balance_date,sysdate)))
         )
  AND NOT EXISTS ( SELECT '1'
                   FROM   igs_fi_inv_wav_det fiw
                   WHERE  fiw.invoice_id   = inv.invoice_id
                   AND    fiw.balance_type = p_balance_type
                   AND    p_balance_type = 'FEE'
                   AND    ((fiw.end_dt IS NOT NULL AND p_balance_date BETWEEN fiw.start_dt AND fiw.end_dt)
                            OR  (fiw.end_dt IS NULL AND p_balance_date >= fiw.start_dt)
                           )
                  );

-- cursor reads from credits table
CURSOR cur_crds_for_balance IS
SELECT cra.*
FROM   igs_fi_credits crd,
       igs_fi_cr_activities cra,
       igs_fi_cr_types cty
WHERE  party_id           = p_person_id
AND    crd.credit_id      = cra.credit_id
AND    cty.credit_type_id = crd.credit_type_id
AND    cty.credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT')
AND    ((p_action   = l_as_on_baldate AND TRUNC(crd.effective_date) <= TRUNC(NVL(p_balance_date,SYSDATE)))
       OR (p_action = l_for_baldate   AND TRUNC(crd.effective_date) =  TRUNC(p_balance_date))
       );

-- Added by sarakshi, as a part of SFCR010
CURSOR cur_rec_exists IS
SELECT ifb.rowid, ifb.*
FROM igs_fi_balances ifb
WHERE party_id          = p_person_id
AND TRUNC(balance_date) = TRUNC(p_balance_date);

l_cur_rec_exists       cur_rec_exists%ROWTYPE;
l_invoice_amount       igs_fi_balances.standard_balance%TYPE := 0.0;
l_credit_amount        igs_fi_credits_all.amount%TYPE := 0.0;
l_balance              igs_fi_balances.standard_balance%TYPE := 0.0;
l_rowid                igs_fi_inv_int_v.row_id%TYPE;
l_balance_id           igs_fi_balances.balance_id%TYPE;
l_bal_standard         igs_fi_balances.standard_balance%TYPE := 0.0;
l_bal_fee              igs_fi_balances.standard_balance%TYPE := 0.0;
l_bal_hold             igs_fi_balances.standard_balance%TYPE := 0.0;
l_bal_rule_fee         igs_fi_balance_rules.balance_rule_id%TYPE := NULL;
l_bal_rule_hold        igs_fi_balance_rules.balance_rule_id%TYPE := NULL;
l_message              fnd_new_messages.message_name%TYPE := NULL;
l_return_status        BOOLEAN := FALSE;

BEGIN
  p_message_name := NULL;
  l_invoice_amount := 0.0;    -- Initialise the total invoice amount to 0.0

  --loop thru all charge records.
  FOR l_cur_chrgs_for_baldate IN cur_chrgs_for_balance
  LOOP
    l_message:= NULL;
    l_return_status := FALSE;

    --Check exclusion rules only if balance_rule_id is not null.
    IF p_balance_rule_id IS NOT NULL THEN
      --check for exclusion rules for charge record.
      l_return_status := igs_fi_prc_balances.check_exclusion_rules(
                                              p_balance_type    => p_balance_type,
                                              p_balance_date    => p_balance_date,
                                              p_source_type     => 'CHARGE',
                                              p_source_id       => l_cur_chrgs_for_baldate.invoice_id,
                                              p_balance_rule_id => p_balance_rule_id,
                                              p_message_name    => l_message);
    END IF;

    --if charge is not excluded only, calculate the sum of invoice amount due.
    IF l_message IS NULL AND l_return_status = FALSE THEN
      l_invoice_amount   :=  NVL(l_invoice_amount ,0.0) + NVL(l_cur_chrgs_for_baldate.invoice_amount ,0.0) ; /* accumulates invoice amount */
    END IF;
  END LOOP ;

  l_credit_amount := 0.0; --Initialise total credit amount to 0.

  --Loop thru all credit records.
  FOR l_cur_crds_for_balance IN cur_crds_for_balance
  LOOP
    l_message  := NULL;
    l_return_status := FALSE;

    --Check exclusion rules only if balance_rule_id is not null.
    IF p_balance_rule_id IS NOT NULL THEN
      --check for exclusion rules for credit record.
      l_return_status := igs_fi_prc_balances.check_exclusion_rules(
                                              p_balance_type    => p_balance_type,
                                              p_balance_date    => p_balance_date,
                                              p_source_type     => 'CREDIT',
                                              p_source_id       => l_cur_crds_for_balance.credit_id,
                                              p_balance_rule_id => p_balance_rule_id,
                                              p_message_name    => l_message);
    END IF;

    --if credit is not excluded, calculate sum of credit amount
    IF l_message IS NULL AND l_return_status = FALSE THEN
      l_credit_amount := NVL(l_credit_amount,0.0) + NVL(l_cur_crds_for_balance.amount,0.0) ; /* accumulates unapplied amount */
    END IF;
  END LOOP;

  -- Added by sarakshi , as a part of SFCR010
  --get the balance amount by subtracting total unapplied amount from the total invoice due.
  l_balance := NVL(l_invoice_amount,0.0) - NVL(l_credit_amount,0.0);

  --assign the amount to the corresponding balance.
  IF p_balance_type = 'STANDARD' THEN
    l_bal_standard := l_balance ;
    l_bal_fee      := NULL;
    l_bal_hold     := NULL;
    l_bal_rule_fee := NULL;
    l_bal_rule_hold:= NULL;
  ELSIF p_balance_type = 'FEE' THEN
    l_bal_standard := NULL;
    l_bal_fee      := l_balance;
    l_bal_hold     := NULL;
    l_bal_rule_fee := p_balance_rule_id;
    l_bal_rule_hold:= NULL;
  ELSIF p_balance_type = 'HOLDS' THEN
    l_bal_standard    := NULL;
    l_bal_fee         :=  NULL;
    l_bal_hold        :=  l_balance;
    l_bal_rule_fee    :=  NULL;
    l_bal_rule_hold   :=  p_balance_rule_id;
  END IF;

--Added by sarakshi , as a part of SFCR010
--insertion/updation of record in igs_fi_balances table will happen only if p_action is 'ASONBALDATE'.
  IF p_action = l_as_on_baldate THEN
    OPEN cur_rec_exists ;
    FETCH cur_rec_exists INTO l_cur_rec_exists;
    IF cur_rec_exists%FOUND THEN
      CLOSE cur_rec_exists;
      IF p_balance_type = 'STANDARD' THEN
        l_cur_rec_exists.standard_balance := l_balance;
      ELSIF p_balance_type = 'FEE' THEN
        l_cur_rec_exists.fee_balance := l_balance;
        l_cur_rec_exists.fee_balance_rule_id := p_balance_rule_id;
      ELSIF p_balance_type = 'HOLDS' THEN
        l_cur_rec_exists.holds_balance := l_balance;
        l_cur_rec_exists.holds_balance_rule_id := p_balance_rule_id;
      END IF;

      l_balance_id:= l_cur_rec_exists.balance_id;

      --update the row in igs_fi_balances table if already a record exists with a combination of party,
      --balance type and balance date.
      -- Removed the parameter subaccount_id, as a part of Bug # 2564643
      igs_fi_balances_pkg.update_row(
                            X_ROWID                  => l_cur_rec_exists.rowid,
                            X_BALANCE_ID             => l_cur_rec_exists.balance_id,
                            X_PARTY_ID               => l_cur_rec_exists.party_id,
                            X_STANDARD_BALANCE       => l_cur_rec_exists.standard_balance,
                            X_FEE_BALANCE            => l_cur_rec_exists.fee_balance,
                            X_HOLDS_BALANCE          => l_cur_rec_exists.holds_balance,
                            X_BALANCE_DATE           => l_cur_rec_exists.balance_date,
                            X_FEE_BALANCE_RULE_ID    => l_cur_rec_exists.fee_balance_rule_id,
                            X_HOLDS_BALANCE_RULE_ID  => l_cur_rec_exists.holds_balance_rule_id,
                            X_MODE                   => 'R'
                            );
    ELSE  --if no record exists in igs_fi_balances...
      l_balance_id:=null;
      CLOSE cur_rec_exists;
      --Insert a row in igs_fi_balances table.
      -- Removed the parameter subaccount_id, as a part of Bug # 2564643

      l_bal_standard  := igs_fi_gen_gl.get_formatted_amount(l_bal_standard);
      l_bal_fee       := igs_fi_gen_gl.get_formatted_amount(l_bal_fee);
      l_bal_hold      := igs_fi_gen_gl.get_formatted_amount(l_bal_hold);

      igs_fi_balances_pkg.insert_row
                          ( X_ROWID                  => l_rowid,
                            X_BALANCE_ID             => l_balance_id,
                            X_PARTY_ID               => p_person_id,
                            X_STANDARD_BALANCE       => l_bal_standard,
                            X_FEE_BALANCE            => l_bal_fee,
                            X_HOLDS_BALANCE          => l_bal_hold,
                            X_BALANCE_DATE           => p_balance_date,
                            X_FEE_BALANCE_RULE_ID    => l_bal_rule_fee,
                            X_HOLDS_BALANCE_RULE_ID  => l_bal_rule_hold,
                            X_MODE                   => 'R'
                          );
    END IF;
  END IF;

  p_balance_amount := l_balance;
  EXCEPTION
    WHEN OTHERS THEN
      p_balance_amount := 0.0;
      p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';

END calculate_balance;  --procedure ends here.


PROCEDURE calc_balances (   errbuf           OUT NOCOPY VARCHAR2                    ,
                            retcode          OUT NOCOPY NUMBER                       ,
                            p_person_id      IN  igs_pe_person_v.person_id%TYPE       ,
                            p_person_id_grp  IN  igs_pe_persid_group_v.group_id%TYPE  ,
                            p_bal_type       IN  igs_lookups_view.lookup_code%TYPE    ,
                            p_bal_date       IN  VARCHAR2                             ,
                            p_org_id         IN  NUMBER
                          ) IS

------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 02062001
  --
  --Purpose: This Procedure calls Calculate balance Procedure .
  --         This procedure is registered with Concurrent Manager.
  --         The concurrent manager initiates this procedure .
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --shtatiko    10-Oct-2002     Obsoleted this concurrent executable as part of
  --                            Enh# 2562745.
  --smvk        17-Sep-2002     Removed the input parameter p_subaccount_id and its usage
  --                            in this functin as a part of Bug # 2564643
-------------------------------------------------------------------
    l_bal_date    igs_fi_balances.balance_date%TYPE ;

BEGIN

-- This concurrent job is made obsolete as part of Enh#2562745. If user tried to
-- run the program then an error message should be written to the Log file that
-- the Concurrent Program is obsolete and this should not be run
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
  retcode := 0;

EXCEPTION
  WHEN OTHERS THEN
        RETCODE:=2;
        ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END calc_balances ;  /* procedure ends here */

  /**************The below procedure added as part of SFCR  10 **************/
PROCEDURE update_balances (   p_party_id       IN   igs_fi_balances.party_id%TYPE       ,
                                p_balance_type   IN   igs_lookups_view.lookup_code%TYPE    ,
                                p_balance_date   IN   igs_fi_balances.balance_date%TYPE    ,
                                p_amount         IN   igs_fi_inv_int.invoice_amount%TYPE ,
                                p_source         IN   VARCHAR2 ,
                                p_source_id      IN   NUMBER ,
                                p_message_name   OUT  NOCOPY fnd_new_messages.message_name%TYPE
                              ) IS

  ------------------------------------------------------------------
  --Created by  : Syam Krishnan, Oracle IDC
  --Date created: 03/10/2001
  --
  --Purpose:  For Updation of real time balances
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --vvutukur 01-Oct-2002  Enh#2562745.Removed cursor c_igs_fi_bal_rules and its usage in this procedure.
  --                      Instead added call to generic procedure igs_fi_gen_007.finp_get_balance_rule.
  --                      Modified local function insert_or_update_balance.
  --smvk        17-Sep-2002    Removed the input parameter p_subaccount_id and
  --                           its usage from this function as a part of Bug # 2564643.
  --smadathi    03-Jul-2002    Bug 2443082. Modified insert_or_update_balance function. Incorporated invokation of
  --                           retro_update_balance function for retroactive updation of balances
  --agairola    30-May-2002    Bug # 2364505, modified the code for the removal of the Standard Balance Rule Id
  --Nishikant   18DEC2001       A new parameter p_source_id added to the procedure and
  --                            three parameters p_source_date, p_fee_type, p_credit_type_id removed
  --                            from the procedure. The code written to check the credit or charge
  --                            transaction is excluded or not  based upon exclusion rules is
  --                            removed by the call to the check exclusion rules function.
  --                            Enhancement bug#2124001.
  -------------------------------------------------------------------

     l_v_message fnd_new_messages.message_name%TYPE;
     l_v_insert_upd_message fnd_new_messages.message_name%TYPE;
     l_func_ret_status BOOLEAN := TRUE;
     l_return_status BOOLEAN;

     --following local variables are declared as part of enh#2562745.
     l_action_active CONSTANT VARCHAR2(10):= 'ACTIVE';
     l_action_max    CONSTANT VARCHAR2(10):= 'MAX';
     l_hold_bal_type CONSTANT igs_lookup_values.lookup_code%TYPE := 'HOLDS';
     l_fee_bal_type  CONSTANT igs_lookup_values.lookup_code%TYPE := 'FEE';
     l_std_bal_type  CONSTANT igs_lookup_values.lookup_code%TYPE := 'STANDARD';

     l_balance_rule_id       igs_fi_balance_rules.balance_rule_id%TYPE := NULL;
     l_last_conversion_date  DATE := NULL;
     l_version_number        igs_fi_balance_rules.version_number%TYPE := NULL;

 --removed cursor c_igs_fi_bal_rules.bug#2562745.

 /**  Local function for Validation of parameters **/
  FUNCTION validate_params (p_message OUT NOCOPY fnd_new_messages.message_name%TYPE ) RETURN BOOLEAN IS

  ------------------------------------------------------------------
  --Created by  : Syam Krishnan, Oracle IDC
  --Date created: 03/10/2001
  --
  --Purpose: Local Function for Validation of parameters
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk       17-Sep-2002      Removed the validation for the parameter p_subaccount_id
  --                            as a part of Bug # 2564643.
  -------------------------------------------------------------------
  BEGIN

    IF (  p_party_id IS NULL OR p_balance_type IS NULL
          OR p_balance_date IS NULL OR p_source IS NULL OR p_amount IS NULL
          OR p_source_id IS NULL  )  THEN
        p_message :=  'IGS_FI_PARAMETER_NULL';
        RETURN FALSE;
    END IF;
    RETURN TRUE;
  END validate_params;

 /**  Local function for Validation of parameters **/

/* Local Function for Updation or insert into balances table */

  FUNCTION insert_or_update_balance (p_balance_rule_id IN igs_fi_balance_rules.balance_rule_id%TYPE,
                                     p_message OUT NOCOPY fnd_new_messages.message_name%TYPE ) RETURN BOOLEAN IS

  ------------------------------------------------------------------
  --Created by  : Syam Krishnan, Oracle IDC
  --Date created: 03/10/2001
  --
  --Purpose: Local Function for Updation or insert into balances table
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --abshriva  12-May-2006    Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
  --vvutukur    01-Oct-2002    Enh#2562745.Removed cursors c_inst_balance,c_other_balance and their
  --                           usage in the code.Also removed references to balance types INSTALLMENT,
  --                           OTHER as these have been obsolete.Modified tbh calls(igs_fi_balances_pkg)accordingly.
  --smvk        17-Sep-2002    Removed the references of the parameter p_subaccount_id from this function, as a part of Bug # 2564643
  --smadathi    03-Jul-2002    Bug 2443082. Modified cursor c_std_balance, c_fee_balance, c_holds_balance,c_inst_balance,
  --                           c_other_balance select statements.
  --agairola    30-May-2002    Bug # 2364505, modified the code for the removal of the Standard Balance Rule Id
  --Nishikant   18DEC2001       Code added to check for the parameter p_balance_type
  --                            is valid or not. Enh bug#2124001
  -------------------------------------------------------------------

/* Cursors to select the previously existing balance and rule id n table irresspective of the balance type..will select only for a particular balance type - see where clause */

     -- Cursor selects all the standard balances for person , subaccount combination
     -- which are created before the balance date parameter in the descending order of balance date

     CURSOR   c_std_balance IS
     SELECT   standard_balance
     FROM     igs_fi_balances
     WHERE    party_id = p_party_id
     /* Removed the parameter p_subaccount_id from the where clause, as a part of Bug # 2564643 */
     AND      standard_balance IS NOT NULL
     AND      TO_CHAR(balance_date,'YYYYMMDD')  <= TO_CHAR(p_balance_date,'YYYYMMDD')
     ORDER by balance_date desc;


     CURSOR   c_fee_balance IS
     SELECT   fee_balance
     FROM     igs_fi_balances
     WHERE    party_id = p_party_id
     /* Removed the parameter p_subaccount_id from the where clause, as a part of Bug # 2564643 */
     AND      fee_balance IS NOT NULL
     AND      TO_CHAR(balance_date,'YYYYMMDD')  <= TO_CHAR(p_balance_date,'YYYYMMDD')
     ORDER by balance_date desc;


     CURSOR   c_holds_balance IS
     SELECT   holds_balance
     FROM     igs_fi_balances
     WHERE    party_id = p_party_id
     /* Removed the parameter p_subaccount_id from the where clause, as a part of Bug # 2564643 */
     AND      holds_balance IS NOT NULL
     AND      TO_CHAR(balance_date,'YYYYMMDD')  <= TO_CHAR(p_balance_date,'YYYYMMDD')
     ORDER by balance_date desc;


/* Cursor used for updation into the table igs_fi_balances for the party_id, subaccount_id  and balance_date  */
     CURSOR c_upd_balance IS
     SELECT bal.rowid, bal.*
     FROM   igs_fi_balances bal
     WHERE  party_id = p_party_id
     /* Removed the parameter p_subaccount_id from the where clause, as a part of Bug # 2564643 */
     AND    TO_CHAR(balance_date,'YYYYMMDD')  = TO_CHAR(p_balance_date,'YYYYMMDD');


   l_b_insert BOOLEAN := FALSE;
   rec_upd_balance c_upd_balance%ROWTYPE;

   l_rowid               rowid;
   l_balance_id          igs_fi_balances.balance_id%TYPE := NULL;
   l_bal_standard        igs_fi_balances.standard_balance%TYPE := NULL;
   l_bal_fee             igs_fi_balances.standard_balance%TYPE := NULL;
   l_bal_hold            igs_fi_balances.standard_balance%TYPE := NULL;
   l_bal_rule_fee        igs_fi_balance_rules.balance_rule_id%TYPE := NULL ;
   l_bal_rule_hold       igs_fi_balance_rules.balance_rule_id%TYPE := NULL ;

   l_n_table_standard_balance igs_fi_balances.standard_balance%TYPE := NUll;
   l_n_table_fee_balance igs_fi_balances.fee_balance%TYPE := NULL;
   l_n_table_holds_balance igs_fi_balances.holds_balance%TYPE := NUll;



  BEGIN

/* Fetch the existin  table balances */
                OPEN c_std_balance;
                FETCH c_std_balance INTO      l_n_table_standard_balance;
                CLOSE c_std_balance;

                OPEN c_fee_balance;
                FETCH c_fee_balance INTO        l_n_table_fee_balance;
                CLOSE c_fee_balance;

                OPEN c_holds_balance;
                FETCH c_holds_balance INTO    l_n_table_holds_balance;
                CLOSE c_holds_balance;


/** Based on The balance type the new balance p_amount is added to the existing balance as below used  for update_row and insert_row**/
      IF p_balance_type = 'STANDARD'        THEN
              l_n_table_standard_balance := NVL(l_n_table_standard_balance,0) + NVL(p_amount,0);
      ELSIF p_balance_type = 'FEE'          THEN
              l_n_table_fee_balance :=  NVL(l_n_table_fee_balance,0) + NVL(p_amount,0);
      ELSIF p_balance_type = 'HOLDS'        THEN
              l_n_table_holds_balance :=  NVL(l_n_table_holds_balance,0) + NVL(p_amount,0);
      END IF;

/* Open cursor for updation */
        OPEN  c_upd_balance;
        FETCH c_upd_balance INTO rec_upd_balance;
         IF c_upd_balance%FOUND THEN
                CLOSE c_upd_balance;
                l_b_insert  := FALSE; /* When record found then No insert required */
         ELSE
                CLOSE c_upd_balance;
                l_b_insert  := TRUE; /* No revord found Insert required */
         END IF;

              IF l_b_insert  THEN
/* When insert required then the corresping colummns balance amount  + origibal table balance (will be 0 if nothing was present) and rule id is populated depending on the balance type - We prefer to keep the other fields null */

                      IF p_balance_type = 'STANDARD'        THEN
                         l_bal_standard        :=  NVL(l_n_table_standard_balance,0)   ;
                         l_bal_fee             :=  NULL       ;
                         l_bal_hold            :=  NULL       ;
                         l_bal_rule_fee        :=  NULL       ;
                         l_bal_rule_hold       :=  NULL       ;
                      ELSIF p_balance_type = 'FEE'          THEN
                         l_bal_standard        :=  NULL       ;
                         l_bal_fee             :=  NVL(l_n_table_fee_balance,0)   ;
                         l_bal_hold            :=  NULL       ;
                         l_bal_rule_fee        :=  p_balance_rule_id ;
                         l_bal_rule_hold       :=  NULL       ;
                      ELSIF p_balance_type = 'HOLDS'        THEN
                         l_bal_standard        :=  NULL       ;
                         l_bal_fee             :=  NULL       ;
                         l_bal_hold            :=  NVL(l_n_table_holds_balance,0)   ;
                         l_bal_rule_fee        :=  NULL       ;
                         l_bal_rule_hold       :=  p_balance_rule_id ;
                      ELSE
                         p_message   :=  'IGS_GE_INVALID_VALUE';
                         RETURN FALSE;
                      END IF;

/* Start of insert into the IGS_FI_BALANCES */
                BEGIN
                l_bal_standard  := igs_fi_gen_gl.get_formatted_amount(l_bal_standard);
                l_bal_fee       := igs_fi_gen_gl.get_formatted_amount(l_bal_fee);
                l_bal_hold      := igs_fi_gen_gl.get_formatted_amount(l_bal_hold);


                igs_fi_balances_pkg.insert_row ( X_ROWID                           =>       l_rowid              ,
                                                 X_BALANCE_ID                      =>       l_balance_id         ,
                                                 X_PARTY_ID                        =>       p_party_id          ,
                                               /* Removed the subaccount from this procedure call, as a part of Bug # 2564643 */
                                                 X_STANDARD_BALANCE                =>       l_bal_standard       ,
                                                 X_FEE_BALANCE                     =>       l_bal_fee            ,
                                                 X_HOLDS_BALANCE                   =>       l_bal_hold           ,
                                                 X_BALANCE_DATE                    =>       p_balance_date        ,
                                                 X_FEE_BALANCE_RULE_ID             =>       l_bal_rule_fee       ,
                                                 X_HOLDS_BALANCE_RULE_ID           =>       l_bal_rule_hold      ,
                                                 X_MODE                            =>       'R'
                                                );
                EXCEPTION
                        WHEN OTHERS THEN
                                p_message := 'IGS_GE_UNHANDLED_EXCEPTION';
                                RETURN FALSE;
                END;

      ELSIF  NOT l_b_insert THEN
        /* For update we update only the corresponding balance amoounts abd leave others same */

                      IF p_balance_type = 'STANDARD'        THEN
                           BEGIN
                           l_n_table_standard_balance :=igs_fi_gen_gl.get_formatted_amount(l_n_table_standard_balance);
                              igs_fi_balances_pkg.update_row
                              (
                                         X_ROWID                           =>       rec_upd_balance.rowid              ,
                                         X_BALANCE_ID                      =>       rec_upd_balance.balance_id         ,
                                         X_PARTY_ID                        =>       rec_upd_balance.party_id           ,
                                        /* Removed the subaccount from this procedure call, as a part of Bug # 2564643 */
                                         X_STANDARD_BALANCE                =>       l_n_table_standard_balance    ,
                                         X_FEE_BALANCE                     =>       rec_upd_balance.fee_balance,
                                         X_HOLDS_BALANCE                   =>       rec_upd_balance.holds_balance       ,
                                         X_BALANCE_DATE                    =>       rec_upd_balance.balance_date       ,
                                         X_FEE_BALANCE_RULE_ID             =>       rec_upd_balance.fee_balance_rule_id       ,
                                         X_HOLDS_BALANCE_RULE_ID           =>       rec_upd_balance.holds_balance_rule_id       ,
                                         X_MODE                            =>       'R'
                              )  ;

                           EXCEPTION
                             WHEN OTHERS THEN
                               p_message := 'IGS_GE_UNHANDLED_EXCEPTION';
                               RETURN FALSE;
                           END;

                      ELSIF p_balance_type = 'FEE'          THEN
                              BEGIN
                                l_n_table_fee_balance :=igs_fi_gen_gl.get_formatted_amount(l_n_table_fee_balance);
                                igs_fi_balances_pkg.update_row
                                                     ( X_ROWID                   =>       rec_upd_balance.rowid              ,
                                         X_BALANCE_ID                      =>       rec_upd_balance.balance_id         ,
                                         X_PARTY_ID                        =>       rec_upd_balance.party_id           ,
                                        /* Removed the subaccount from this procedure call, as a part of Bug # 2564643 */
                                         X_STANDARD_BALANCE                =>       rec_upd_balance.standard_balance    ,
                                         X_FEE_BALANCE                     =>       l_n_table_fee_balance,
                                         X_HOLDS_BALANCE                   =>       rec_upd_balance.holds_balance       ,
                                         X_BALANCE_DATE                    =>       rec_upd_balance.balance_date       ,
                                         X_FEE_BALANCE_RULE_ID             =>       p_balance_rule_id       ,
                                         X_HOLDS_BALANCE_RULE_ID           =>       rec_upd_balance.holds_balance_rule_id       ,
                                         X_MODE                            =>       'R'
                                      )  ;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                         p_message := 'IGS_GE_UNHANDLED_EXCEPTION';
                                        RETURN FALSE;
                              END;

                      ELSIF p_balance_type = 'HOLDS'        THEN
                              BEGIN
                                l_n_table_holds_balance :=igs_fi_gen_gl.get_formatted_amount(l_n_table_holds_balance);
                                igs_fi_balances_pkg.update_row
                                                            ( X_ROWID                   =>       rec_upd_balance.rowid              ,
                                         X_BALANCE_ID                      =>       rec_upd_balance.balance_id         ,
                                         X_PARTY_ID                        =>       rec_upd_balance.party_id           ,
                                        /* Removed the subaccount from this procedure call, as a part of Bug # 2564643 */
                                         X_STANDARD_BALANCE                =>       rec_upd_balance.standard_balance    ,
                                         X_FEE_BALANCE                     =>       rec_upd_balance.fee_balance,
                                         X_HOLDS_BALANCE                   =>       l_n_table_holds_balance       ,
                                         X_BALANCE_DATE                    =>       rec_upd_balance.balance_date       ,
                                         X_FEE_BALANCE_RULE_ID             =>       rec_upd_balance.fee_balance_rule_id       ,
                                         X_HOLDS_BALANCE_RULE_ID           =>          p_balance_rule_id       ,
                                         X_MODE                            =>       'R'
                                      )  ;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                         p_message := 'IGS_GE_UNHANDLED_EXCEPTION';
                                        RETURN FALSE;
                             END;
                      ELSE
                         p_message  :=  'IGS_GE_INVALID_VALUE';
                         RETURN FALSE;
                      END IF;

      END IF;

 /* If everything is OK then return TRUE */
    RETURN TRUE;
  END insert_or_update_balance;


  BEGIN  /* Main procedure update_balances */
    --Validation of all parameters.
    IF NOT validate_params(l_v_message) THEN
    --If any of the validation fails then return message and get out of procedure.
      p_message_name := l_v_message;
      RETURN;
    END IF;

    IF p_amount <> 0 THEN
    -- The entire update balance process happens only if the passed parameter p_amount is not equal
    -- to 0 since there is no use updating a 0 balance.

      --For Standard balance,there is no need to derive the balance_rule_id and hence no exclusion
      --rules can be checked.
      IF p_balance_type <> l_std_bal_type THEN
        --Fetch balance_rule_id of active Holds balance_type.
        IF p_balance_type = l_hold_bal_type THEN
          igs_fi_gen_007.finp_get_balance_rule(p_v_balance_type    => p_balance_type,
                                               p_v_action          => l_action_active,
                                               p_n_balance_rule_id => l_balance_rule_id,
                                               p_d_last_conversion_date => l_last_conversion_date,
                                               p_n_version_number  => l_version_number
                                               );
          --If no balance rule exists for Holds Balance Type.
          IF l_version_number = 0 THEN
            --Error out of the procedure.
            p_message_name := 'IGS_FI_CANNOT_CRT_TXN';
            RETURN;
          END IF;
        --Fetch balance rule id of latest Fee balance_type.
        ELSIF p_balance_type = l_fee_bal_type THEN
          igs_fi_gen_007.finp_get_balance_rule(p_v_balance_type    => p_balance_type,
                                               p_v_action          => l_action_max,
                                               p_n_balance_rule_id => l_balance_rule_id,
                                               p_d_last_conversion_date => l_last_conversion_date,
                                               p_n_version_number  => l_version_number
                                               );
        END IF;
        -- following code added to call the check exclusion rules function, Enh Bug#2124001
        IF p_source = 'CHARGE' THEN
          l_return_status := igs_fi_prc_balances.check_exclusion_rules
                                                    (p_balance_type,
                                                     p_balance_date,
                                                     'CHARGE',
                                                     p_source_id,
                                                     l_balance_rule_id,
                                                     l_v_message);
          IF l_v_message IS NOT NULL THEN
            p_message_name := l_v_message;
            RETURN;
          END IF;
        ELSIF p_source = 'CREDIT' THEN
          l_return_status := igs_fi_prc_balances.check_exclusion_rules(
                                                     p_balance_type,
                                                     p_balance_date,
                                                     'CREDIT',
                                                     p_source_id,
                                                     l_balance_rule_id,
                                                     l_v_message);
          IF l_v_message IS NOT NULL THEN
            p_message_name := l_v_message;
            RETURN;
          END IF;
        ELSE
          p_message_name := 'IGS_GE_INVALID_VALUE';
          RETURN;
        END IF;
      END IF;

      --initialises the variable l_func_ret_status
      l_func_ret_status := TRUE;
      /* Step 9 to insert or update into the balances table  */
      IF NOT insert_or_update_balance(l_balance_rule_id,
                                      l_v_insert_upd_message ) THEN
      -- sets the function return status to false
        l_func_ret_status := FALSE;
        p_message_name  := l_v_insert_upd_message;
      END IF;
      -- invokes retro_update_balance function for retroactive updation of balances
      -- if insert_or_update_balanc has been successfully executed.
      -- retro_update_balance function will be invoked for retroactive updation of
      -- all the records whose balance date is greater than the
      -- parameter balance date

      IF (l_func_ret_status) THEN
        l_return_status := retro_update_balance
                           (
                            p_n_party_id       => p_party_id,
                            /* Removed the subaccount from this procedure call, as a part of Bug # 2564643 */
                            p_c_balance_type   => p_balance_type,
                            p_d_balance_date   => p_balance_date,
                            p_n_amount         => p_amount,
                            p_c_message        => l_v_message
                            );
        IF NOT(l_return_status) THEN
          p_message_name := l_v_message;
        END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_message_name  :='IGS_GE_UNHANDLED_EXCEPTION';
  END update_balances ;
/* procedure ends here */
/***************The procedure update balances added as part of SFCR  10 ***************/



/*** The below check_exclusion_rules function added for the enhancement bug#2124001. ***/

FUNCTION check_exclusion_rules (
        p_balance_type    IN      igs_fi_balance_rules.balance_name%TYPE ,
        p_balance_date    IN      igs_fi_balance_rules.effective_start_date%TYPE,
        p_source_type     IN      VARCHAR2 ,
        p_source_id       IN      NUMBER   ,
        p_balance_rule_id IN      igs_fi_balance_rules.balance_rule_id%TYPE,
        p_message_name   OUT  NOCOPY   VARCHAR2 )
RETURN BOOLEAN  AS
-------------------------------------------------------------------------------
--  Created By : Nishikant
--  Date Created On : 06-12-2001
--  Purpose:  It checks for all the Charges and Credits transactions based upon
--            the exclusion rules set up for a particular balance type before
--            arriving at the final balances.
--  Change History
--  Who             When            What
-- sapanigr    14-Feb_2006    Bug 5018036. Cursor c_credit now uses igs_fi_credits_all instead of igs_fi_credits
-- vvutukur    04-Oct-2002    Enh#2562745.Added a new mandatory parametre p_balance_rule_id.Removed
--                            cursor c_balance and its usage in the code.Modified cursor c_bal_type
--                            as 'INSTALLMENT','OTHER' balance types have been obsoleted.
-- smvk        17-Sep-2002    Removed the references to subaccount_id, as a part of Bug # 2564643
-- vvutukur     01-may-2002    Bug 2329042. Modified to return FALSE for Standard Balance Type as there
--                            there will be no exclusion rules defined for Standard Bal. type.
-- smadathi     10-APR-2002    Bug 2289191. References to enabled_flag column removed from cursor
--                            c_subacct_excl, c_ftype_excl, c_ctyp_excl select list.
--  (reverse chronological order - newest change first)
-------------------------------------------------------------------------------
l_fee_type              igs_fi_inv_int_v.fee_type%TYPE;
l_credit_type_id        igs_fi_credits_v.credit_type_id%TYPE;
l_balance_rule_id       igs_fi_balance_rules.balance_rule_id%TYPE := p_balance_rule_id;
l_std_bal               igs_lookup_values.lookup_code%TYPE := 'STANDARD';
l_sysdate               DATE := TRUNC(SYSDATE);
l_lkp_type              igs_lookup_values.lookup_type%TYPE := 'IGS_FI_BALANCE_TYPE';

CURSOR c_bal_type(cp_balance_type igs_fi_balance_rules.balance_name%TYPE) IS
       SELECT 'X'
       FROM   igs_lookup_values
       WHERE  lookup_type = l_lkp_type
              AND lookup_code = cp_balance_type
              AND lookup_code NOT IN ('INSTALLMENT','OTHER')
              AND enabled_flag = 'Y'
              AND l_sysdate BETWEEN NVL(TRUNC(start_date_active),l_sysdate) AND
                                    NVL(TRUNC(end_date_active),l_sysdate);

--removed cursor c_balance.

CURSOR c_charge(cp_source_id igs_fi_inv_int.invoice_id%TYPE) IS
        SELECT fee_type, invoice_creation_date
        FROM   igs_fi_inv_int_v
        WHERE  invoice_id = cp_source_id;

CURSOR c_credit(cp_source_id igs_fi_credits_all.credit_id%TYPE)IS
        SELECT credit_type_id,  effective_date
        FROM   igs_fi_credits_all
        WHERE  credit_id = cp_source_id;

/* Removed the cursor c_subacct_excl, as a part of Bug # 2564643 */

CURSOR c_ftype_excl(cp_fee_type          igs_fi_fee_type.fee_type%TYPE,
                    cp_balance_rule_id   igs_fi_balance_rules.balance_rule_id%TYPE
                   )IS
        SELECT 'X'
        FROM   IGS_FI_BAL_EX_F_TYPS_V
        WHERE  fee_type = cp_fee_type
        AND    balance_rule_id = cp_balance_rule_id;

CURSOR c_ctyp_excl(cp_credit_type_id   igs_fi_cr_types.credit_type_id%TYPE,
                   cp_balance_rule_id  igs_fi_balance_rules.balance_rule_id%TYPE
                  )IS
        SELECT 'X'
        FROM   IGS_FI_BAL_EX_C_TYPS_V
        WHERE  credit_type_id  =  cp_credit_type_id
        AND    balance_rule_id =  cp_balance_rule_id;

l_charge                c_charge%ROWTYPE;
l_credit                c_credit%ROWTYPE;
l_temp                  VARCHAR2(1);

BEGIN

-- The below parameters are required so they cannot be NULL
  IF  (p_balance_type    IS NULL OR
       p_balance_date    IS NULL OR
       p_source_type     IS NULL OR
       p_source_id       IS NULL OR
       p_balance_rule_id IS NULL
      )THEN
      p_message_name := 'IGS_GE_INVALID_VALUE';
      RETURN FALSE;
  END IF;

  IF p_balance_type = l_std_bal THEN
    p_message_name := NULL;
    RETURN FALSE;
  END IF;

-- The parameter Balance Type should be either of the Lookup Codes enabled
-- for the Lookup Type 'IGS_FI_BALANCE_TYPE'.
  OPEN c_bal_type(cp_balance_type   => p_balance_type);
  FETCH c_bal_type INTO l_temp;
  IF c_bal_type%NOTFOUND THEN
    p_message_name := 'IGS_GE_INVALID_VALUE';
    CLOSE c_bal_type;
    RETURN FALSE;
  END IF;
  CLOSE c_bal_type;

-- The parameter Source Type should be either CHARGE or CREDIT
  IF p_source_type NOT IN ('CHARGE','CREDIT') THEN
    p_message_name := 'IGS_GE_INVALID_VALUE';
    RETURN FALSE;
  END IF;

  IF p_source_type = 'CHARGE' THEN
    -- If Source Type is CHARGE then it retrieves the Fee Type, Invoice Creation Date by
    -- matching the invoice_id with the parameter p_source_id.
    OPEN c_charge(cp_source_id  => p_source_id);
    FETCH c_charge INTO l_charge;
    IF   c_charge%FOUND THEN
    -- Storing the Fee Type found from the above cursor to the local variable.
      l_fee_type := l_charge.fee_type;
    END IF;
    CLOSE c_charge;

    -- Here it checks the Fee Type found above is excluded or not.  If excluded it returns
    -- TRUE and the mentioned message.
    OPEN c_ftype_excl(cp_fee_type        =>  l_fee_type,
                      cp_balance_rule_id =>  p_balance_rule_id
                      );
    FETCH c_ftype_excl INTO l_temp;
    IF c_ftype_excl%FOUND THEN
      CLOSE c_ftype_excl;
      p_message_name := 'IGS_FI_FTYP_EXCLDED';
      RETURN TRUE;
    END IF;
    CLOSE c_ftype_excl;
  ELSE

    -- If Source Type is CREDIT then it retrieves the Credit Type ID, Effective Date
    -- by matching the credit_id with the parameter p_source_id. Then it checks whether
    -- the Credit Effective Date for the Credit Type ID is in between the Transaction Low Date
    -- and the Transaction High Date of the Balance Name. If it found the it returns TRUE and
    -- the mentioned message.
    OPEN c_credit(cp_source_id  => p_source_id);
    FETCH c_credit INTO l_credit;
    IF c_credit%FOUND THEN
    -- Storing the Credit Type found from the above cursor into the local variable.
      l_credit_type_id := l_credit.credit_type_id;
    END IF;
    CLOSE c_credit;

    -- Here it checks the Credit Type found above is excluded or not.  If excluded it
    -- returns TRUE and the mentioned message.
    OPEN c_ctyp_excl(cp_credit_type_id    => l_credit_type_id,
                     cp_balance_rule_id   => p_balance_rule_id
                     );
    FETCH c_ctyp_excl INTO l_temp;
    IF c_ctyp_excl%FOUND THEN
      CLOSE c_ctyp_excl;
      p_message_name := 'IGS_FI_CTYP_EXCLDED';
      RETURN TRUE;
    END IF;
    CLOSE c_ctyp_excl;
  END IF;

/* removed the validation of subaccount_id from exclusion, as a part of Bug # 2564643 */

  -- If nowhere found Excluded the it returns FALSE.
  p_message_name := NULL;
  RETURN FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_charge%ISOPEN THEN
        CLOSE c_charge;
      END IF;
      IF c_credit%ISOPEN THEN
        CLOSE c_credit;
      END IF;
      IF c_ftype_excl%ISOPEN THEN
       CLOSE c_ftype_excl;
      END IF;
      IF c_ctyp_excl%ISOPEN THEN
        CLOSE c_ctyp_excl;
      END IF;
      p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
      RETURN FALSE;
END check_exclusion_rules;


FUNCTION retro_update_balance
(
               p_n_party_id       IN   igs_fi_balances.party_id%TYPE       ,
              /* Removed the parameter p_subaccount_id as a part of Bug # 2564643 */
               p_c_balance_type   IN   igs_lookups_view.lookup_code%TYPE   ,
               p_d_balance_date   IN   igs_fi_balances.balance_date%TYPE   ,
               p_n_amount         IN   igs_fi_inv_int.invoice_amount%TYPE  ,
               p_c_message        OUT  NOCOPY fnd_new_messages.message_name%TYPE
)
RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 02 Jul 2002
--
--Purpose: This private Function is invoked from update_balances procedure
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--abshriva  12-May-2006    Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
--vvutukur    01-Oct-2002     Enh#2562745.Removed references to balance types INSTALLMENT,OTHER from
--                            tbh calls(igs_fi_balances_pkg) as the same are obsolete.
--smvk        17-Sep-2002     Removed the input parameter p_n_subaccount_id and its usage
--                            in this function. As a part of Bug # 2564643
------------------------------------------------------------------
   --Cursor used for retroactive updation of the table igs_fi_balances for the
   --party_id, subaccount_id  and balance_date

   CURSOR   c_igs_fi_balances IS
   SELECT   bal.rowid, bal.*
   FROM     igs_fi_balances bal
   WHERE    party_id      = p_n_party_id
   AND      TO_CHAR(balance_date,'YYYYMMDD')  > TO_CHAR(p_d_balance_date,'YYYYMMDD')
   ORDER BY balance_date ;

   rec_c_igs_fi_balances c_igs_fi_balances%ROWTYPE;

BEGIN
   -- for retroactive updation all the records whose balance date is greater than the
   -- parameter balance date will be fetched and updated with the amount
   FOR rec_c_igs_fi_balances IN c_igs_fi_balances
   LOOP
     IF p_c_balance_type = 'STANDARD'
     THEN
       BEGIN
         igs_fi_balances_pkg.update_row
         (
           X_ROWID                           =>       rec_c_igs_fi_balances.rowid              ,
           X_BALANCE_ID                      =>       rec_c_igs_fi_balances.balance_id         ,
           X_PARTY_ID                        =>       rec_c_igs_fi_balances.party_id           ,
          /* Removed subaccount_id from this procedure call, as a part of Bug # 2564643 */
           X_STANDARD_BALANCE                =>       igs_fi_gen_gl.get_formatted_amount(NVL(rec_c_igs_fi_balances.standard_balance,0) + NVL(p_n_amount,0))    ,
           X_FEE_BALANCE                     =>       rec_c_igs_fi_balances.fee_balance         ,
           X_HOLDS_BALANCE                   =>       rec_c_igs_fi_balances.holds_balance       ,
           X_BALANCE_DATE                    =>       rec_c_igs_fi_balances.balance_date        ,
           X_FEE_BALANCE_RULE_ID             =>       rec_c_igs_fi_balances.fee_balance_rule_id   ,
           X_HOLDS_BALANCE_RULE_ID           =>       rec_c_igs_fi_balances.holds_balance_rule_id ,
           X_MODE                            =>       'R'
                              )  ;
       EXCEPTION
         WHEN OTHERS THEN
            -- log the error message returned by the tbh
           p_c_message := FND_MESSAGE.GET;
           RETURN FALSE;
       END;
     ELSIF p_c_balance_type = 'FEE'
     THEN
       BEGIN
         igs_fi_balances_pkg.update_row
         (
           X_ROWID                           =>       rec_c_igs_fi_balances.rowid              ,
           X_BALANCE_ID                      =>       rec_c_igs_fi_balances.balance_id         ,
           X_PARTY_ID                        =>       rec_c_igs_fi_balances.party_id           ,
          /* Removed subaccount_id from this procedure call, as a part of Bug # 2564643 */
           X_STANDARD_BALANCE                =>       rec_c_igs_fi_balances.standard_balance   ,
           X_FEE_BALANCE                     =>       igs_fi_gen_gl.get_formatted_amount(NVL(rec_c_igs_fi_balances.fee_balance,0) + NVL(p_n_amount,0) )       ,
           X_HOLDS_BALANCE                   =>       rec_c_igs_fi_balances.holds_balance       ,
           X_BALANCE_DATE                    =>       rec_c_igs_fi_balances.balance_date        ,
           X_FEE_BALANCE_RULE_ID             =>       rec_c_igs_fi_balances.fee_balance_rule_id   ,
           X_HOLDS_BALANCE_RULE_ID           =>       rec_c_igs_fi_balances.holds_balance_rule_id ,
           X_MODE                            =>       'R'
                              )  ;
       EXCEPTION
         WHEN OTHERS THEN
            -- log the error message returned by the tbh
           p_c_message := FND_MESSAGE.GET;
           RETURN FALSE;
       END;
     ELSIF p_c_balance_type = 'HOLDS'
     THEN
       BEGIN
         igs_fi_balances_pkg.update_row
         (
           X_ROWID                           =>       rec_c_igs_fi_balances.rowid              ,
           X_BALANCE_ID                      =>       rec_c_igs_fi_balances.balance_id         ,
           X_PARTY_ID                        =>       rec_c_igs_fi_balances.party_id           ,
          /* Removed subaccount_id from this procedure call, as a part of Bug # 2564643 */
           X_STANDARD_BALANCE                =>       rec_c_igs_fi_balances.standard_balance   ,
           X_FEE_BALANCE                     =>       rec_c_igs_fi_balances.fee_balance        ,
           X_HOLDS_BALANCE                   =>       igs_fi_gen_gl.get_formatted_amount( NVL(rec_c_igs_fi_balances.holds_balance,0) + NVL(p_n_amount,0) )       ,
           X_BALANCE_DATE                    =>       rec_c_igs_fi_balances.balance_date        ,
           X_FEE_BALANCE_RULE_ID             =>       rec_c_igs_fi_balances.fee_balance_rule_id   ,
           X_HOLDS_BALANCE_RULE_ID           =>       rec_c_igs_fi_balances.holds_balance_rule_id ,
           X_MODE                            =>       'R'
                              )  ;
       EXCEPTION
         WHEN OTHERS THEN
            -- log the error message returned by the tbh
           p_c_message := FND_MESSAGE.GET;
           RETURN FALSE;
       END;
     END IF;
   END LOOP;
   RETURN TRUE;
END retro_update_balance;


/****** Following 3 procedures finpl_upd_conv_prc_run_ind(), convert_holds_balances() and conv_balances() added
        as part of Reassess Balances Build FI102, Bug 2562745  ******/


PROCEDURE finpl_upd_conv_prc_run_ind ( p_n_value  IN  NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
------------------------------------------------------------------
--Created by  : Priya Athipatla, Oracle IDC
--Date created: 08-OCT-2002
--
--Purpose: Private procedure to update value of conv_process_run_ind
--         in the igs_fi_control_all table to 0 or 1 when the holds process is
--         not-running/running anymore.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--svuppala    14-JUL-2005     Enh 3392095 - impact of Tution Waivers build
--                            Modified igs_fi_control_pkg.update_row by adding two new columns
--                            post_waiver_gl_flag, waiver_notify_finaid_flag
--pmarada    19-Nov-2004      Bug 4017841, Removed the obsoleted res_dt_alias column reference from igs_fi_control table update row
--uudayapr    23-dec-2003     ENH3167098 Modified igs_fi_control_pkg.update_row by changing the Column Name PRG_CHG_DT_ALAIS
--                                        to RES_DT_ALAIS
--jbegum      14-june-2003    Bug#2998266 Removed the column next_invoice_number from call to igs_fi_control_pkg.update_row
--shtatiko    27-MAY-2003     Enh# 2831582, Removed columns lockbox_context, lockbox_number_attribute and ar_int_org_id from
--                            call igs_fi_control_pkg.update_row.
--vvutukur    16-May-2003     Enh#2831572.financial Accounting Build. Modified TBH call to add parameter acct_conv_flag.
--pathipat    14-Apr-2003     Enh 2831569 - Commercial Receivables Interface
--                            Modified call to igs_fi_control_pkg.update_row
--smadathi   18-Feb-2002      Enh. Bug 2747329.Modified the TBH call to IGS_FI_CONTROL to Add new columns
--                            rfnd_destination, ap_org_id, dflt_supplier_site_name
--vvutukur  11-Dec-2002   Enh#2584741.Added currency_cd parameter to the tbh call of igs_fi_control_pkg.update_row.
------------------------------------------------------------------

CURSOR c_get_data IS
  SELECT fc.rowid, fc.*
  FROM igs_fi_control_all fc;

l_rec_get_data    c_get_data%ROWTYPE;

BEGIN

  OPEN c_get_data;
  FETCH c_get_data INTO l_rec_get_data;
  IF c_get_data%FOUND THEN
    igs_fi_control_pkg.update_row (
         x_rowid                     => l_rec_get_data.rowid,
         x_rec_installed             => l_rec_get_data.rec_installed,
         x_mode                      => 'R',
         x_accounting_method         => l_rec_get_data.accounting_method,
         x_set_of_books_id           => l_rec_get_data.set_of_books_id,
         x_refund_dr_gl_ccid         => l_rec_get_data.refund_dr_gl_ccid,
         x_refund_cr_gl_ccid         => l_rec_get_data.refund_cr_gl_ccid,
         x_refund_dr_account_cd      => l_rec_get_data.refund_dr_account_cd,
         x_refund_cr_account_cd      => l_rec_get_data.refund_cr_account_cd,
         x_refund_dt_alias           => l_rec_get_data.refund_dt_alias,
         x_fee_calc_mthd_code        => l_rec_get_data.fee_calc_mthd_code,
         x_planned_credits_ind       => l_rec_get_data.planned_credits_ind,
         x_rec_gl_ccid               => l_rec_get_data.rec_gl_ccid,
         x_cash_gl_ccid              => l_rec_get_data.cash_gl_ccid,
         x_unapp_gl_ccid             => l_rec_get_data.unapp_gl_ccid,
         x_rec_account_cd            => l_rec_get_data.rec_account_cd,
         x_rev_account_cd            => l_rec_get_data.rev_account_cd,
         x_cash_account_cd           => l_rec_get_data.cash_account_cd,
         x_unapp_account_cd          => l_rec_get_data.unapp_account_cd,
         x_conv_process_run_ind      => p_n_value,
         x_currency_cd               => l_rec_get_data.currency_cd,
         x_rfnd_destination          => l_rec_get_data.rfnd_destination,
         x_ap_org_id                 => l_rec_get_data.ap_org_id,
         x_dflt_supplier_site_name   => l_rec_get_data.dflt_supplier_site_name,
         x_manage_accounts           => l_rec_get_data.manage_accounts,
         x_acct_conv_flag            => l_rec_get_data.acct_conv_flag,
         x_post_waiver_gl_flag       => l_rec_get_data.post_waiver_gl_flag,
         x_waiver_notify_finaid_flag => l_rec_get_data.waiver_notify_finaid_flag
    );
    COMMIT;
    CLOSE c_get_data;
  ELSE
    fnd_message.set_name('IGS','IGS_FI_SYSTEM_OPT_SETUP');
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(FND_FILE.LOG,' ');
    app_exception.raise_exception;
  END IF;

END finpl_upd_conv_prc_run_ind;


PROCEDURE convert_holds_balances( p_conv_st_date IN igs_fi_balance_rules.last_conversion_date%TYPE ) AS
------------------------------------------------------------------
--Created by  : Priya Athipatla, Oracle IDC
--Date created: 08-OCT-2002
--
--Purpose: Public procedure invoked by conv_balances --> holds conversion concurrent program
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--abshriva    12-May-2006     Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
--shtatiko    15-JAN-2003     Bug# 2736389, Introduced l_validation_exp to handle validation failure
--                            cases separately. Because in these cases if we raise exception using
--                            app_exception.raise_exception then message "Process raised unhandled
--                            exception" is logged along with validation failure error message.
--pathipat    07-Jan-2003     Bug: 2672837 - Log file format modified to be multiline instead
--                            of in tabular format. Used generic function to obtain the lookup
--                            description instead of local func lookup_Desc
------------------------------------------------------------------

-- to obtain the process start date for conversion
CURSOR c_get_process_dt IS
  SELECT a.process_start_dt
  FROM igs_fi_person_holds a,
       igs_pe_pers_encumb b,
       igs_fi_hold_plan c
  WHERE a.hold_plan_name = c.hold_plan_name
  AND c.hold_plan_level  = 'S'
  AND a.person_id        = b.person_id
  AND a.hold_start_dt    = b.start_dt
  AND a.hold_type        = b.encumbrance_type
  AND (b.expiry_dt IS NULL OR TRUNC(b.expiry_dt) >= TRUNC(SYSDATE))
  ORDER BY 1 ;

-- to obtain all the records in the balances table for conversion
CURSOR c_get_balances IS
  SELECT fb.rowid, fb.*
  FROM igs_fi_balances fb
  WHERE TRUNC(balance_date) >= TRUNC(p_conv_st_date)
  ORDER BY party_id, balance_date ;

-- to obtain the rowid for the record that is to be updated after the conversion process is successful
CURSOR c_rule_update(cp_balance_rule_id IN igs_fi_balance_rules.balance_rule_id%TYPE) IS
  SELECT rowid
  FROM igs_fi_balance_rules
  WHERE balance_rule_id = cp_balance_rule_id;

l_rec_get_balances       c_get_balances%ROWTYPE;
l_process_start_dt       igs_fi_person_holds.process_start_dt%TYPE;
l_conv_process_run_ind   igs_fi_control_all.conv_process_run_ind%TYPE;
l_balance_rule_id        igs_fi_balance_rules.balance_rule_id%TYPE;
l_version_number         igs_fi_balance_rules.version_number%TYPE;
l_last_conv_dt           igs_fi_balance_rules.last_conversion_date%TYPE;
l_balance_amt            igs_fi_balances.holds_balance%TYPE := 0;
l_balance_sum            igs_fi_balances.holds_balance%TYPE := 0;
l_party_id               igs_fi_balances.party_id%TYPE  := NULL;
l_message_name           fnd_new_messages.message_name%TYPE  := NULL;
l_message_name_1         fnd_new_messages.message_name%TYPE  := NULL;
l_msg_str_0              VARCHAR2(1000) := NULL;
l_msg_str_1              VARCHAR2(1000) := NULL;
l_rowid                  VARCHAR2(25);
l_person_number          hz_parties.party_number%TYPE;
l_user_exception         EXCEPTION;
l_exception              BOOLEAN;

BEGIN

  -- if conversion start date is not given, then error out
  IF p_conv_st_date IS NULL THEN
    fnd_message.set_name('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(FND_FILE.LOG,' ');
    RAISE l_validation_exp;
  END IF;

  -- conversion start date should not be greater than sysdate
  IF TRUNC(p_conv_st_date) > TRUNC(SYSDATE) THEN
    fnd_message.set_name('IGS','IGS_FI_CONV_GT_SYSDT');
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(FND_FILE.LOG,' ');
    RAISE l_validation_exp;
  END IF;

  -- Check if the holds conversion process is not already running
  IGS_FI_GEN_007.finp_get_conv_prc_run_ind( p_n_conv_process_run_ind  => l_conv_process_run_ind,
                                            p_v_message_name          => l_message_name_1) ;

  IF l_message_name_1 IS NOT NULL THEN
    fnd_message.set_name('IGS',l_message_name_1);
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(FND_FILE.LOG,' ');
    RAISE l_validation_exp;
  END IF;

  -- indicator = 1 if the process is already running
  IF l_conv_process_run_ind = 1 THEN
    fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(FND_FILE.LOG,' ');
    RAISE l_validation_exp;
  -- if indicator <> 1, then make it 1 to show that the process will be run now
  ELSIF l_conv_process_run_ind = 0 THEN
    finpl_upd_conv_prc_run_ind(1);
  END IF;

  -- Get the balance_rule_id, last_conversion_date and the version number
  IGS_FI_GEN_007.finp_get_balance_rule(p_v_balance_type         => 'HOLDS',
                                       p_v_action               => 'MAX',
                                       p_n_balance_rule_id      => l_balance_rule_id,
                                       p_d_last_conversion_date => l_last_conv_dt,
                                       p_n_version_number       => l_version_number);
  -- 1
  IF l_version_number = 0 THEN
    -- means no balance rule has been defined, so error out
    fnd_message.set_name('IGS','IGS_FI_NO_BAL_CONV');
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(FND_FILE.LOG,' ');

    finpl_upd_conv_prc_run_ind(0);   -- to update the run indicator back to 0 before erroring out
    RAISE l_validation_exp;
  -- 1
  END IF;

  -- 2
  IF ( (l_last_conv_dt IS NOT NULL) AND (TRUNC(p_conv_st_date) > TRUNC(l_last_conv_dt)) ) THEN

          fnd_message.set_name('IGS','IGS_FI_PD_LE_INP_DT');
          fnd_message.set_token('DATE1',l_last_conv_dt);
          fnd_message.set_token('DATE2',p_conv_st_date);
          fnd_file.put_line(fnd_file.log,fnd_message.get());
          fnd_file.put_line(FND_FILE.LOG,' ');

          -- update the run indicator back to 0 before erroring out
          finpl_upd_conv_prc_run_ind(0);
          RAISE l_validation_exp;
  -- 2
  END IF;

  OPEN c_get_process_dt;
  FETCH c_get_process_dt INTO l_process_start_dt;  -- l_process_start_dt now holds the earliest process start date
  CLOSE c_get_process_dt;
  -- 3
  IF ( (l_process_start_dt IS NOT NULL) AND (TRUNC(l_process_start_dt) < TRUNC(p_conv_st_date)) ) THEN
     -- Check if earliest process start date is earlier than p_conv_st_date
     fnd_message.set_name('IGS','IGS_FI_EPSD_LE_PRC_DT');
     fnd_message.set_token('DATE1',p_conv_st_date);
     fnd_message.set_token('DATE2',l_process_start_dt);
     fnd_file.put_line(fnd_file.log,fnd_message.get());
     fnd_file.put_line(FND_FILE.LOG,' ');

     -- update the run indicator back to 0 before erroring out
     finpl_upd_conv_prc_run_ind(0);
     RAISE l_validation_exp;
  -- 3
  END IF;

  SAVEPOINT A;

  FOR l_rec_get_balances IN c_get_balances
  LOOP
    BEGIN

       -- 4     For same party id, get the cumulative balance amount. First party id, calculate balances with action as
       --       ASONBALDATE.  For consecutive same party id records, calculate based on FORBALDATE.

       IF NVL(l_party_id,-99) <> l_rec_get_balances.party_id THEN
          -- if l_party_id is null, then initialize the first record of that party id to l_party_id
          l_party_id := l_rec_get_balances.party_id;
          l_balance_sum := 0;   -- cumulative sum is set to zero
          l_balance_amt := 0;
          l_exception := FALSE;

          SAVEPOINT B;

          IGS_FI_PRC_BALANCES.calculate_balance( p_person_id        => l_rec_get_balances.party_id,
                                                       p_balance_type     => 'HOLDS',
                                                       p_balance_date     => l_rec_get_balances.balance_date,
                                                       p_action           => 'ASONBALDATE',
                                                       p_balance_rule_id  => l_balance_rule_id,
                                                       p_balance_amount   => l_balance_amt,        -- OUT parameter
                                                       p_message_name     => l_message_name        -- OUT parameter
                                                      );
          IF l_message_name IS NOT NULL THEN
             RAISE l_user_exception;
          END IF;

          l_balance_sum := NVL(l_balance_amt,0) + NVL(l_balance_sum,0);
          l_balance_amt := 0;

          -- Update the log file
          -- (pathipat) Log file format changed from tabular format to multiline format
          -- Used generic function to get the description, and not the local func lookup_Desc
          -- Bug: 2672837
          OPEN cur_person_number(l_rec_get_balances.party_id);
          FETCH cur_person_number INTO l_person_number;

          fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'PERSON')
                                );
          fnd_message.set_token('PARM_CODE', l_person_number);
          fnd_file.put_line(fnd_file.log, fnd_message.get);

          fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'BALANCE_DATE')
                                );
          fnd_message.set_token('PARM_CODE', l_rec_get_balances.balance_date);
          fnd_file.put_line(fnd_file.log,  fnd_message.get);

          fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'BALANCE_RULE_VERSION')
                                );
          fnd_message.set_token('PARM_CODE', l_version_number);
          fnd_file.put_line(fnd_file.log,  fnd_message.get);

          fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'BALANCE_AMOUNT')
                                );
          fnd_message.set_token('PARM_CODE',igs_fi_gen_gl.get_formatted_amount(l_balance_sum));
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_file.new_line(fnd_file.log);

          CLOSE cur_person_number;

       -- 4
       ELSIF NVL(l_party_id,-99) = l_rec_get_balances.party_id AND NOT (l_exception) THEN  --4

          IGS_FI_PRC_BALANCES.calculate_balance( p_person_id        => l_rec_get_balances.party_id,
                                                          p_balance_type     => 'HOLDS',
                                                          p_balance_date     => l_rec_get_balances.balance_date,
                                                          p_action           => 'FORBALDATE',
                                                          p_balance_rule_id  => l_balance_rule_id,
                                                          p_balance_amount   => l_balance_amt,
                                                          p_message_name     => l_message_name
                                                         );
          IF l_message_name IS NOT NULL THEN
              RAISE l_user_exception;
          END IF;

          l_balance_sum := NVL(l_balance_amt,0) + NVL(l_balance_sum,0);   -- cumulative balance amount for each party id
          l_balance_amt := 0;

          l_balance_sum := igs_fi_gen_gl.get_formatted_amount(l_balance_sum);
          -- Update the cumulative balance amount in the fi_balances table under holds_balances
          -- and the balance_rule_id under holds_balance_rule_id
          IGS_FI_BALANCES_PKG.update_row ( x_rowid                  => l_rec_get_balances.rowid,
                                                       x_balance_id             => l_rec_get_balances.balance_id,
                                                       x_party_id               => l_rec_get_balances.party_id,
                                                       x_standard_balance       => l_rec_get_balances.standard_balance,
                                                       x_fee_balance            => l_rec_get_balances.fee_balance,
                                                       x_holds_balance          => l_balance_sum,
                                                       x_balance_date           => l_rec_get_balances.balance_date,
                                                       x_fee_balance_rule_id    => l_rec_get_balances.fee_balance_rule_id,
                                                       x_holds_balance_rule_id  => l_balance_rule_id,
                                                       x_mode                   => 'R'
                                                     );

          -- Update the log file
          -- (pathipat) Log file format changed from tabular format to multiline format
          -- Used generic function to get the description, and not the local func lookup_Desc
          -- Bug: 2672837
          fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'PERSON')
                                );
          fnd_message.set_token('PARM_CODE', l_person_number);
          fnd_file.put_line(fnd_file.log, fnd_message.get);

          fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'BALANCE_DATE')
                                );
          fnd_message.set_token('PARM_CODE', l_rec_get_balances.balance_date);
          fnd_file.put_line(fnd_file.log,  fnd_message.get);

          fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'BALANCE_RULE_VERSION')
                                );
          fnd_message.set_token('PARM_CODE', l_version_number);
          fnd_file.put_line(fnd_file.log,  fnd_message.get);

          fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
          fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                            p_v_lookup_code => 'BALANCE_AMOUNT')
                                );
          fnd_message.set_token('PARM_CODE',igs_fi_gen_gl.get_formatted_amount(l_balance_sum));
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_file.new_line(fnd_file.log);

       -- 4
       END IF;

    EXCEPTION
       WHEN l_user_exception THEN
          l_exception := TRUE;
       finpl_upd_conv_prc_run_ind(0);
       ROLLBACK TO SAVEPOINT B;
    END;
  END LOOP;


  BEGIN
    -- update the rules table with the version number and rule_id and set the last_conversion_date
    -- to be p_conv_st_date if the holds calculation process above completed without any errors
    OPEN c_rule_update(l_balance_rule_id);
    FETCH c_rule_update INTO l_rowid;
    CLOSE c_rule_update;
    IGS_FI_BALANCE_RULES_PKG.update_row ( x_rowid                 => l_rowid,
                                                x_balance_rule_id       => l_balance_rule_id,
                                                x_balance_name          => 'HOLDS',
                                                x_version_number        => l_version_number,
                                                x_last_conversion_date  => p_conv_st_date,
                                                x_mode                  => 'R'
                                              );

  EXCEPTION
    WHEN OTHERS THEN
      finpl_upd_conv_prc_run_ind(0);
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.put_line(FND_FILE.LOG,' ');
      ROLLBACK TO SAVEPOINT A;
  END;

finpl_upd_conv_prc_run_ind(0);

EXCEPTION

  WHEN OTHERS THEN
     IF c_get_process_dt%ISOPEN THEN
        CLOSE c_get_process_dt;
     END IF;
     IF c_get_balances%ISOPEN THEN
        CLOSE c_get_balances;
     END IF;
     IF c_rule_update%ISOPEN THEN
        CLOSE c_rule_update;
     END IF;
     IF cur_person_number%ISOPEN THEN
        CLOSE cur_person_number;
     END IF;
     ROLLBACK;
     finpl_upd_conv_prc_run_ind(0) ;
     RAISE;

END convert_holds_balances;



PROCEDURE conv_balances ( errbuf          OUT  NOCOPY  VARCHAR2,
                          retcode         OUT  NOCOPY  NUMBER,
                          p_conv_st_date  IN   VARCHAR2) AS
------------------------------------------------------------------
--Created by  : Priya Athipatla, Oracle IDC
--Date created: 08-OCT-2002
--
--Purpose: Wrapper procedure for convert_holds_balances(), registered
--         as a concurrent manager job executable.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--sapanigr    05-May-2006     Bug 5178077: Added call to igs_ge_gen_003.set_org_id. to disable process in R12
--pathipat    23-Apr-2003     Enh 2831569 - Commercial Receivables build - Added call to
--                            igs_fi_com_rec_interface.chk_manage_account()
------------------------------------------------------------------

l_v_manage_acc           igs_fi_control_all.manage_accounts%TYPE := NULL;
l_v_message_name         fnd_new_messages.message_name%TYPE := NULL;
l_org_id                 VARCHAR2(15);

BEGIN

  BEGIN
       l_org_id := NULL;
       igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         RETCODE:=2;
         RETURN;
  END;

  -- Obtain the value of manage_accounts in the System Options form
  -- If it is null or 'OTHER', then this process is not available, so error out.
  igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                               p_v_message_name => l_v_message_name
                                             );
  IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(FND_FILE.LOG,' ');
    RAISE l_validation_exp;
  END IF;

    -- call the main holds conversion procedure
    convert_holds_balances(TRUNC(igs_ge_date.igsdate(p_conv_st_date)));

EXCEPTION
  WHEN l_validation_exp THEN
    ROLLBACK;
    retcode := 2;
  WHEN OTHERS THEN
     ROLLBACK;
     retcode := 2;
     errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ': ' || SQLERRM;
     igs_ge_msg_stack.add;
     IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END conv_balances;

END IGS_FI_PRC_BALANCES;

/
