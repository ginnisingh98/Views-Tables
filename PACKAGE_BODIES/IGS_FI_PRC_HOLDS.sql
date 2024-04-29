--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_HOLDS" AS
/* $Header: IGSFI67B.pls 120.6 2006/05/15 23:01:32 sapanigr ship $ */

/***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              :   Having procedures related to batch application of holds on person/person group/all people
                            AND release of holds on person/person group/all people
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who        When          What
   sapanigr   03-May-2006   Enh#3924836 Precision Issue. Modified validate_holds.
   sapanigr   10-Oct-2005   Bug 3049184 - Modified proc finp_release_holds_main and function validate_holds to change log file
                            for Process Release of Finance Holds
   svuppala   17-AUG-2005   Bug 4557933 - Unable to remove holds that were put on with concurrent manager
                            Validate_holds : Passing values to AUTHORISING_PERSON_ID and AUTH_RESP_ID from SWS Holds API
                            while calling insert_row of IGS_PE_PERS_ENCUMB_PKG
   pmarada    26-jul-2004   Bug 3792800, Added code to bypass the holds apply validation in finp_apply_holds procedure
   pathipat   12-Aug-2003   Enh 3076768 - Automatic Release of Holds
                            Added procedure finp_auto_release_holds(), modified validate_holds() and all its call-outs
                            Modified validate_param - removed calls to igs_pe_gen_001.get_hold_auth.
   pathipat   23-Jun-2003   Bug: 3018104 - Impact of changes in person id group views
                            Replaced all occurrences of igs_pe_persid_group_v and igs_pe_prsid_grp_mem_v
                            with igs_pe_persid_group and igs_pe_prsid_grp_mem respectively
   pathipat   05-May-2003   Enh 2831569 - Commercial Receivables Build
                            Modified finp_apply_holds() and finp_release_holds_main() - Added check for manage_accounts
   vvutukur   05-Mar-2003   Bug#2824994.Modified procedure finp_apply_holds,function validate_holds(used in releasing holds),holds_balance.
   pathipat   25-Feb-2003   Enh:2747341 - Additional Security for Holds build
                            Modifications according to FI206_TD_SWS_Additional_Security_for_Holds_s1a.doc
                            Modified cursor c_person - selected from igs_pe_person_base_v instead of igs_pe_person
                            Changed declaration of local variable person_name appropriately.
   ssawhney   17-feb-2003   Bug : 2758856  : Added the parameter x_external_reference in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW

   SYKRISHn    03-JAN-2002              Bug 2684895 --Procedure finp_apply_holds  and finp_release_holds_main
                                        Logging Person Group Cd instead of person group id.
   SYKRISHN    31DEC2002                Bug 2676524 - Procedure finp_apply_holds
                                        Derived the person number for the parameter p_auth_person_id
                                        to display in the concurrent log file instead of the P_auth_person_id which
                                        was logged earlier.
   smadathi    20-dec-2002   Enh. Bug 2566615. Removed  the references of obsoleted table IGS_FI_HOLD_PLN_LNS and
                             incorporated changes suggested as per FICR102 TD. Removed lookup_desc function
   agairola     03-Dec-2002 Bug No: 2584741 As part of the Deposits Build, modified the cursor c_credit_amount to exclude
                            credits of Credit Class Enrolment Deposit and Other Deposit
   pathipat            04-OCT-2002      Enh Bug:2562745 --  Reassess Balances build
                                        1. Added check in finp_apply_holds() and in finp_release_holds_main() to check if
                                           holds conversion process is running before continuing with further processing
                                        2. Added check in validate_param() to check if active balance rule has been defined for the
                                           balance type of HOLDS.
                                        3. Also added in the same function, check if the process start date is not later than the
                                           last_conversion_date of the balance rule when the hold plan name is at 'Account' level.
                                        4. In validate_holds(), removed insertion of balance_amount into the igs_fi_person_holds
                                           table as the column is being obsoleted. Added cursor c_bal_amount to obtain holds balance
                                           from igs_fi_balances (in place of balance amount from igs_fi_person_holds)
                                        5. Added parameter balance_rule_id in calls to check_exclusion_rules()
                                        6. Removed igs_ge_date.igsdate(p_process_start_date) and replaced with just
                                           p_process_Start_date. similarly for process_end_date also.
   pkpatel             30-SEP-2002      Bug No: 2600842
                                        Added the parameter auth_resp_id in the call to the procedures of TBH igs_pe_pers_encumb_pkg
   vchappid            07-Jun-2002      Bug 2392486#, Calculation of the holds balance incase the Holds plan is at subaccount
                                        is corrected , Holds Balance should be added only when the balance record is found in
                                        the balances table
   SYkrishn            30/APR/2002      in function validate_param
                                        Changes in curor c_fee_type to compare ci ststu with system fee structure ststua
                                        Bug 2348883
   SYkrishn            03-APR-2002      Changes according to Build 2293676 - Planned Credits Functionality introduced.
   vvutukur            28-02-2002       Modified the cursor c_person by selecting from igs_pe_person
                                        instead of igs_fi_parties_v.for bug:2238362(reverting back the earlier fix).
   vvutukur            27-02-2002       Modified cursor c_person by selecting from igs_fi_parties_v
                                        instead of igs_pe_person for bug:2238362.
***************************************************************/

--Skip exception used to skip a record FROM the cursor based on the condition
skip EXCEPTION;

--cursor to SELECT person information for the passed person id in order to display in the log
CURSOR c_person(l_person_id  igs_pe_person.person_id%TYPE) IS
SELECT person_number,
       full_name
FROM   igs_pe_person_base_v
WHERE  person_id = l_person_id;

--cursor variable
l_person_rec    c_person%ROWTYPE;

-- package variables - OUT NOCOPY variables from finp_get_balance_rule()
l_balance_rule_id        igs_fi_balance_rules.balance_rule_id%TYPE;

-- Flag to indicate that a hold for a person has been skipped due to
-- some validation failure to continue with the next hold
-- g_b_hold_skipped = TRUE even if one hold for a person is skipped
g_b_hold_skipped   BOOLEAN := FALSE;

--added following 6 global variables as part of bug#2824994.
g_v_person_number CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','PERSON_NUMBER');
g_v_person_name   CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','PERSON_NAME');
g_v_hold_plan     CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','HOLD_PLAN');
g_n_holds_bal     CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','HOLDS_BALANCE');
g_n_overdue_bal   CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','HOLDS_OVERDUE_BALANCE');
g_v_hold_type     CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','HOLD_TYPE');
g_n_person_id     hz_parties.party_id%TYPE;
g_n_resp_id       fnd_responsibility.responsibility_id%TYPE;

-- Changes due to SFCR018
---Local package function to get the value of planned credits indicator

FUNCTION get_planned_credits_ind
RETURN VARCHAR2
 IS
 /***************************************************************
   Created By           :       SYkrishn
   Date Created By      :       APR/03/2002
   Purpose              :       Gets the value of planned credits indicator from IGS_FI_CONTROL_ALL.
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What

 ***************************************************************/

 l_v_planned_credits_ind igs_fi_control_all.planned_credits_ind%TYPE := NULL;
 l_v_pln_cr_message   fnd_new_messages.message_name%TYPE := NULL;

 BEGIN
--Call the genric function to get the value
 l_v_planned_credits_ind := igs_fi_gen_001.finp_get_planned_credits_ind(l_v_pln_cr_message);

 IF l_v_pln_cr_message IS NOT NULL THEN
 --Log error message and raise exception
     fnd_message.set_name('IGS',l_v_pln_cr_message);
     fnd_file.put_line(fnd_file.log,fnd_message.get());
     fnd_file.put_line(fnd_file.log,' ');
     app_exception.raise_exception;
 END IF;

   RETURN l_v_planned_credits_ind;

 END get_planned_credits_ind;
-- Changes due to SFCR018

--FUNCTION to calculate holds balance amount

FUNCTION holds_balance( p_person_id            IN     igs_pe_person_v.person_id%TYPE   ,
                        p_person_number        IN     igs_pe_person_v.person_number%TYPE   ,
                        p_hold_plan_name       IN     igs_fi_hold_plan.hold_plan_name%Type,
                        P_fee_cal_type         IN     igs_fi_inv_int.fee_cal_type%TYPE,
                        P_fee_ci_sequence_number IN  igs_fi_inv_int.fee_ci_sequence_number%TYPE,
                        p_process_end_date     IN     igs_fi_person_holds.process_end_dT%TYPE ,
                        p_process_start_date   IN     igs_fi_person_holds.process_start_dT%TYPE ,
                        P_test_run             IN     VARCHAR2 ,
                        P_hold_type            OUT NOCOPY    igs_fi_hold_plan.hold_type%Type,
                        P_hold_plan_level      OUT NOCOPY    igs_fi_hold_plan.hold_plan_level%TYPE,
                        P_holds_charges        OUT NOCOPY    igs_fi_inv_int.invoice_amount%TYPE,
                        P_holds_final_balance  OUT NOCOPY    igs_fi_credits.amount%TYPE,
                        p_offset_days          OUT NOCOPY    igs_fi_hold_plan.offset_days%TYPE,
                        p_n_student_plan_id    OUT NOCOPY    igs_fi_pp_std_attrs.student_plan_id%TYPE,
                        p_d_last_inst_due_date OUT NOCOPY    igs_fi_pp_instlmnts.due_date%TYPE)
RETURN BOOLEAN
IS
/***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              :      to calculate holds balance amount
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   shtatiko    17-OCT-2003   Bug# 3192641, Added code to consider charges which are waived when calculating holds_balance.
   smadathi    28-Aug-2003   Enh Bug 3045007. Added new parameters p_n_student_plan_id, p_d_last_inst_due_date. Modified p_offset_days
                             to OUT. Modified the cursor c_hold_plan.
   vvutukur    25-Mar-2003   Bug#2824994.Person Number,Person Name also logged if holds are would not be applied for a person.
   smadathi    20-dec-2002   Enh. Bug 2566615. Removed  the references of obsoleted table IGS_FI_HOLD_PLN_LNS and
                             incorporated changes suggested as per FICR102 TD
   agairola     03-Dec-2002 Bug No: 2584741 As part of the Deposits Build, modified the cursor c_credit_amount to exclude
                            credits of Credit Class Enrolment Deposit and Other Deposit
   sarakshi             23-sep-2002     Enh#2564643,removed teh reference of subaccount from this function as mentioned in the TD
   vchappid             07-Jun-2002     Bug 2392486#, Calculation of the holds balance incase the Holds plan is at subaccount
                                        is corrected , Balance should be added only when the balance record is found in the balances table
   SYkrishn             07-APR-2002     Introduced  planned credits functionality
                                        as per SFCR018 DLD- 2293676 - For sub account level hold plans if the
                                        include planned credits is setup then planned credits are also considered along with actual
                                        credits to derive the holds balance overdue.
 ***************************************************************/
--to SELECT hold_plan_level related information
CURSOR c_hold_plan IS
  SELECT        hold_plan_level,
                hold_type,
                threshold_amount,
                threshold_percent,
                fee_type,
                offset_days                    ,
                payment_plan_threshold_amt     ,
                payment_plan_threshold_pcent
  FROM    igs_fi_hold_plan
  WHERE   hold_plan_name = p_hold_plan_name;

--to SELECT holds_balance for the passed party_id  AND date range
CURSOR c_holds_balance IS
  SELECT holds_balance
  FROM  igs_fi_balances
  WHERE party_id = p_person_id
  AND   holds_balance IS NOT NULL
  AND   TRUNC(balance_date) <= TRUNC(p_process_start_date)
  ORDER BY balance_date desc;

--to SELECT credit_amount for the passed date range
CURSOR c_credit_amnt(l_payment_due_date DATE) IS
  SELECT crd.credit_id,
         crd.amount,
         crd.effective_date
  FROM igs_fi_credits crd,
       igs_fi_cr_types crt
  WHERE TRUNC(crd.effective_date)  between  (TRUNC(p_process_start_date) + 1) AND  TRUNC(l_payment_due_date)
  AND crd.status = 'CLEARED'
  AND crd.party_id = p_person_id
  AND crd.credit_type_id = crt.credit_type_id
  AND crt.credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT')
  ORDER BY crd.credit_id ;


--to SELECT invoice amount or invoice amount due based on the l_SELECT_facto value passed
CURSOR c_invoice_amnt(l_fee_type igs_fi_fee_type_all.fee_type%TYPE ) IS
  SELECT invoice_id,
         invoice_amount  amount,
         invoice_amount_due ,
         invoice_creation_date
  FROM   igs_fi_inv_int inv
  WHERE  fee_type               = l_fee_type
  AND    fee_cal_type           = p_fee_cal_type
  AND    fee_ci_sequence_number = p_fee_ci_sequence_number
  AND    TRUNC(invoice_creation_date) <= TRUNC(p_process_start_date)
  AND    person_id = p_person_id
  AND    NOT EXISTS (SELECT 'X'
                     FROM  igs_fi_inv_wav_det
                     WHERE invoice_id = inv.invoice_id
                     AND   balance_type = 'HOLDS'
                     AND  (
                          (
                           TRUNC(end_dt) IS NOT NULL AND
                           TRUNC(p_process_start_date) BETWEEN  TRUNC(start_dt) AND TRUNC(end_dt)
                          )
                          OR
                          (TRUNC(p_process_start_date) >= TRUNC(start_dt) AND  TRUNC(end_dt) is null)
                          )
                     );

  CURSOR c_igs_fi_pp_instlmnts ( cp_n_student_plan_id igs_fi_pp_std_attrs.student_plan_id%TYPE,
                                 cp_d_d_pay_det_date  DATE
                               ) IS
  SELECT SUM(installment_amt) installment_amt,
         SUM(due_amt)         due_amt,
         MAX(due_date)        due_date
  FROM   igs_fi_pp_instlmnts
  WHERE  student_plan_id = cp_n_student_plan_id
  AND    due_date        <= cp_d_d_pay_det_date;

  rec_c_igs_fi_pp_instlmnts c_igs_fi_pp_instlmnts%ROWTYPE;

  -- Cursor to calculate the total charge amount waived when a plan level is "Balance"
  -- Added as part of Bug# 3192641
  CURSOR c_waive_amount( cp_n_person_id NUMBER, cp_d_process_start_date DATE) IS
    SELECT NVL(SUM(chg.invoice_amount), 0)
    FROM igs_fi_inv_int_all chg,
         igs_fi_inv_wav_det wav
    WHERE person_id = cp_n_person_id
    AND chg.invoice_id = wav.invoice_id
    AND wav.balance_type = 'HOLDS'
    AND cp_d_process_start_date BETWEEN TRUNC(start_dt) AND NVL(TRUNC(end_dt), cp_d_process_start_date);
  l_n_waive_amount NUMBER;

--declaration of loacl variables
  l_hold_plan_rec       c_hold_plan%ROWTYPE ;
  l_holds_balance_rec   c_holds_balance%ROWTYPE;
  l_credit_amnt_rec     c_credit_amnt%ROWTYPE;
  l_invoice_amnt_rec    c_invoice_amnt%ROWTYPE;
  l_message_name        fnd_new_messages.message_name%TYPE := NULL;
  l_holds_balance       igs_fi_balances.holds_balance%TYPE :=0;
  l_payment_due_date    igs_fi_person_holds.process_start_dT%TYPE;
  l_credit_subac        igs_fi_credits.amount%TYPE :=0;
  l_tot_credits         igs_fi_credits.amount%TYPE :=0;
  l_charges             igs_fi_inv_int.invoice_amount%TYPE :=0;
  l_final_balance       igs_fi_credits.amount%TYPE :=0;
  l_ratio               igs_fi_hold_plan.threshold_percent%TYPE;

-- Changes due to SFCR018
 -- Call the local function to get the value of planned_credits_ind
  l_v_pln_cr_ind igs_fi_control_all.planned_credits_ind%TYPE := get_planned_credits_ind;
  l_v_pln_cr_message fnd_new_messages.message_name%TYPE :=NULL;
  l_n_planned_credit igs_fi_credits.amount%TYPE :=0;
-- Changes due to SFCR018

  l_n_threshold_amount  igs_fi_hold_plan.threshold_amount%TYPE    ;
  l_n_threshold_percent igs_fi_hold_plan.threshold_percent%TYPE   ;
  l_n_act_plan_id       igs_fi_pp_std_attrs.student_plan_id%TYPE  ;
  l_v_act_plan_name     igs_fi_pp_templates.payment_plan_name%TYPE;
  l_d_pay_det_date      DATE;

BEGIN

  --To fetch the header details associated with the hold plan name

  OPEN c_hold_plan ;
  FETCH c_hold_plan INTO l_hold_plan_rec;
    --Calculate the payment due date
    IF l_hold_plan_rec.offset_days IS NOT NULL THEN
      l_payment_due_date := p_process_end_date + NVL(l_hold_plan_rec.offset_days,0);
    ELSE
      l_payment_due_date := p_process_end_date ;
    END IF;

    p_hold_type           := l_hold_plan_rec.hold_type;
    p_hold_plan_level     := l_hold_plan_rec.hold_plan_level;
    p_offset_days         := l_hold_plan_rec.offset_days;
    l_n_threshold_amount  := l_hold_plan_rec.threshold_amount;
    l_n_threshold_percent := l_hold_plan_rec.threshold_percent;

    --Validate the  fetched Hold type for closed indicator

--1
         l_message_name := NULL;
         IF NOT igs_en_val_etde.enrp_val_et_closed(l_hold_plan_rec.hold_type,l_message_name)
            AND (l_message_name = 'IGS_EN_ENCUMB_TYPE_CLOSED') THEN
             fnd_message.set_name('IGS','IGS_EN_ENCUMB_TYPE_CLOSED');
             fnd_file.put_line(fnd_file.log,fnd_message.get());
             fnd_file.put_line(fnd_file.log,' ');
             CLOSE c_hold_plan;
             RETURN FALSE;
         END IF;
--1
--To find the level at which the hold plan is defined
--2
       IF l_hold_plan_rec.hold_plan_level = 'S' THEN

         -- check if the Person is on an Active Payment Plan.
         -- if the the Person is on an Active Payment Plan , hold application will be evaluated
         -- based on the payment plan installments.
         -- Invoke the Generic procedure
         igs_fi_gen_008.get_plan_details (p_n_person_id      => p_person_id,
                                          p_n_act_plan_id    => l_n_act_plan_id,
                                          p_v_act_plan_name  => l_v_act_plan_name
                                         );

         IF l_v_act_plan_name IS NOT NULL THEN

           l_d_pay_det_date := TRUNC(SYSDATE) - NVL(l_hold_plan_rec.offset_days,0);

           -- compute the sum of the installment amount and the due amount for the person

           OPEN  c_igs_fi_pp_instlmnts( cp_n_student_plan_id =>  l_n_act_plan_id ,
                                        cp_d_d_pay_det_date  =>  l_d_pay_det_date
                                      );
           FETCH c_igs_fi_pp_instlmnts INTO rec_c_igs_fi_pp_instlmnts;
           CLOSE c_igs_fi_pp_instlmnts;

           p_holds_charges        := NVL(rec_c_igs_fi_pp_instlmnts.installment_amt,0);
           p_holds_final_balance  := NVL(rec_c_igs_fi_pp_instlmnts.due_amt,0);
           p_n_student_plan_id    := l_n_act_plan_id;
           p_d_last_inst_due_date := rec_c_igs_fi_pp_instlmnts.due_date;

           -- if payment plan threshold amount is provided, assign the
           -- the c_hold_plan select value to the variable
           IF l_hold_plan_rec.payment_plan_threshold_amt IS NOT NULL THEN
             l_n_threshold_amount  := NVL(l_hold_plan_rec.payment_plan_threshold_amt,0);
             l_n_threshold_percent := NULL;
           END IF;

           -- if payment plan threshold percent is provided, assign the
           -- the c_hold_plan select value to the variable
           IF  l_hold_plan_rec.payment_plan_threshold_pcent IS NOT NULL THEN
             l_n_threshold_percent := NVL(l_hold_plan_rec.payment_plan_threshold_pcent,0);
             l_n_threshold_amount  := NULL;
           END IF;

         ELSIF l_v_act_plan_name IS NULL THEN

           --Open cursor to get the latest HOLDS balances as on the process start date
           OPEN c_holds_balance;
           FETCH c_holds_balance INTO l_holds_balance_rec;
           --Use a local variable to add up this latest outstanding holds balance(only the latest)
           -- Add to the Local Holds balance variable only when the balance record is found in the igs_fi_balances table for the party_id
           IF c_holds_balance%FOUND THEN
             l_holds_balance := NVL(l_holds_balance_rec.holds_balance,0)  +  NVL(l_holds_balance,0);
           END IF;
           CLOSE c_holds_balance;

           -- Added following logic as part of fix for Bug# 3192641
           -- Check if any charges are waived as of process_start_date.
           -- If yes, get the total amount waived.
           OPEN c_waive_amount(p_person_id, TRUNC(p_process_start_date));
           FETCH c_waive_amount INTO l_n_waive_amount;
           CLOSE c_waive_amount;

           -- Subtract waive amount from Holds Balance
           l_holds_balance := NVL(l_holds_balance, 0) - l_n_waive_amount;

           --Get the non- excluded payments/credits of person_id in context for the date range of p_process_start_date +1 to the payment_due_date.
           OPEN c_credit_amnt(l_payment_due_date);
           LOOP
             FETCH c_credit_amnt INTO l_credit_amnt_rec;
             --To be tested when completed as apart of alte fee finance charges
             EXIT WHEN c_credit_amnt%NOTFOUND;
             l_message_name := NULL ;
             --invoke the common funtion for exclusion rules .If this function returns 1 then do not include this amount for the charges.
             --5 TO MAKE IT NOT l_boolean
             IF   NOT igs_fi_prc_balances.check_exclusion_rules  (p_balance_type => 'HOLDS',
                                                                  p_source_type  => 'CREDIT',
                                                                  p_balance_date => TRUNC(l_credit_amnt_rec.effective_date),
                                                                  p_source_id    => l_credit_amnt_rec.credit_id  ,
                                                                  p_balance_rule_id => l_balance_rule_id,
                                                                  p_message_name => l_message_name)  THEN
               IF l_message_name IS NULL THEN
               --A local variable to sum up the non-excluded credits of the person
                 l_credit_subac :=  l_credit_subac + NVL(l_credit_amnt_rec.amount,0) ;
               ELSIF l_message_name IS NOT NULL THEN
               --Log the eror message in the log when message is returned with FALSE
                 IF  p_test_run = 'Y' THEN
                   fnd_message.set_name('IGS',l_message_name);
                   fnd_file.put_line(fnd_file.log,fnd_message.get());
                   fnd_file.put_line(fnd_file.log,' ');
                 END IF;
               END IF;
             END IF;
 --5
           END LOOP;
           CLOSE c_credit_amnt;
           --local variable at the end of this loop to sum up the total non-excluded credits defined for the hold plan
           l_tot_credits := l_tot_credits + l_credit_subac;
--4
           -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'
           IF l_v_pln_cr_ind = 'Y' THEN
           --Call the generic function to get the total planned credits for the params passed.
             l_n_planned_credit := igs_fi_gen_001.finp_get_total_planned_credits(
                                                                p_person_id => p_person_id,
                                                                p_start_date => NULL,
                                                                p_end_date => l_payment_due_date,
                                                                p_message_name => l_v_pln_cr_message);
             IF l_v_pln_cr_message IS NOT NULL THEN
               fnd_message.set_name('IGS',l_v_pln_cr_message);
               fnd_file.put_line(fnd_file.log,fnd_message.get());
               fnd_file.put_line(fnd_file.log,' ');
               RETURN FALSE;
             END IF;
             -- When no errors sum up the planned credits also with the actual credits
             l_tot_credits := l_tot_credits + NVL(l_n_planned_credit,0);
           END IF;
           -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'

           --If this amount is Zero i.e holds balance is zero then we need not proceed further
           IF l_holds_balance = 0 THEN
             IF  p_test_run = 'Y' THEN
               fnd_file.put_line(fnd_file.log,g_v_person_number ||' : '||p_person_number);
               fnd_file.put_line(fnd_file.log,g_v_person_name   ||' : '||l_person_rec.full_name);
               fnd_message.set_name('IGS','IGS_FI_NO_BALANCE');
               fnd_message.set_token('PERSON',p_person_number);
               fnd_message.set_token('PROCESS_START_DT',p_process_start_date);
               fnd_file.put_line(fnd_file.log,fnd_message.get());
             END IF;
             RETURN FALSE;
           END IF;
           l_final_balance := l_holds_balance -  l_tot_credits ;
--2
           P_holds_charges := l_holds_balance;
           P_holds_final_balance := l_final_balance;
         END IF; /* end of if l_v_act_plan_name condition */
       ELSIF l_hold_plan_rec.hold_plan_level  = 'F' THEN
                -- for a fee type hold plan level, fee type is mandatory
                -- if no fee type if found attached to fee type hold plan level
                -- an error  is raised
                IF l_hold_plan_rec.fee_type IS NULL THEN
                   fnd_message.set_name('IGS','IGS_FI_HLD_CRITERIA_NT_DEFIND');
                   fnd_file.put_line(fnd_file.log,fnd_message.get());
                   RETURN FALSE;
                END IF;

--Get the charges records for the person FROM the charges table IGS_FI_INV_INT as on the p_process_start_date by getting the fee types for the passed hold plan
                OPEN c_invoice_amnt(l_hold_plan_rec.fee_type);
                LOOP
                FETCH c_invoice_amnt INTO l_invoice_amnt_rec;

                EXIT WHEN c_invoice_amnt%NOTFOUND;
--invoke the common funtion for exclusion rules .If this function returns 1 then do not include this amount for the charges.
                  l_message_name := NULL;
               IF  NOT igs_fi_prc_balances.check_exclusion_rules(p_balance_type => 'HOLDS',
                                                                 p_source_type  => 'CHARGE',
                                                                 p_balance_date => TRUNC(l_invoice_amnt_rec.invoice_creation_date),
                                                                 p_source_id    => l_invoice_amnt_rec.Invoice_id ,
                                                                 p_balance_rule_id => l_balance_rule_id,
                                                                 p_message_name => l_message_name)  THEN

                      IF l_message_name IS NULL THEN
--A local variable to sum up the non-excluded charges of the person for the invoice id.
                                l_charges       :=  NVL(l_charges,0) + NVL(l_invoice_amnt_rec.amount,0) ;
                                l_final_balance :=  NVL(l_final_balance,0) + NVL(l_invoice_amnt_rec.invoice_amount_due,0) ;
                      ELSIF l_message_name IS NOT NULL THEN
--Log the eror message in the log when message is returned with FALSE
                          IF  p_test_run = 'Y' THEN
                             fnd_message.set_name('IGS',l_message_name);
                             fnd_file.put_line(fnd_file.log,fnd_message.get());
                             fnd_file.put_line(fnd_file.log,' ');
                          END IF;
                      END IF;
                END IF;
                END LOOP;
                CLOSE c_invoice_amnt;

           --If this amount is Zero i.e charges sum for all the fee types is zero then we need not proceed further
           IF NVL(l_charges,0) = 0 THEN
             IF  p_test_run = 'Y' THEN
               fnd_file.put_line(fnd_file.log,g_v_person_number ||' : '||p_person_number);
               fnd_file.put_line(fnd_file.log,g_v_person_name   ||' : '||l_person_rec.full_name);
               fnd_message.set_name('IGS','IGS_FI_NO_BALANCE');
               fnd_message.set_token('PERSON',p_person_number);
               fnd_message.set_token('PROCESS_START_DT',p_process_start_date);
               fnd_file.put_line(fnd_file.log,fnd_message.get());
             END IF;
               RETURN FALSE;
           END IF;
           -- the non-excluded invoice amount and invoice amount_due  has been assigned to OUT parameters
           P_holds_charges        := l_charges;
           P_holds_final_balance  := l_final_balance;
           p_n_student_plan_id    := NULL;
           p_d_last_inst_due_date := NULL;
       END IF;
 --2

--Common Steps values to determine whether holds are applicable or not for both the cases(fee type level AND Account level / student level)


--Check if threshold_amount is specified
--10
       IF l_n_threshold_amount IS NOT NULL THEN
--If the final balance  is greater THEN the threshold_amount defined then mark the paritcular person applicable for placing the particular hold type
--11

            IF  p_holds_final_balance > l_n_threshold_amount THEN

                 RETURN TRUE;
            ELSE
--11
                 RETURN FALSE;
            END IF;
--11
      ELSIF l_n_threshold_percent IS NOT NULL THEN
--10

           l_ratio := (p_holds_final_balance/ P_holds_charges) *100;

--If ratio is greater THEN the threshold_percent then mark the particular person applicable for placing the particular hold type
--12
           IF l_ratio > l_n_threshold_percent THEN
                 RETURN TRUE;
            ELSE
--12
                 RETURN FALSE;
--12
           END IF;
--10
      ELSIF (l_n_threshold_percent  IS  NULL AND l_n_threshold_amount  IS NULL) THEN
--If neither threshold_percent nor threshold_amount specified then DO NOT consider the person /hold plan to be placed under hold.

            RETURN FALSE;
       END IF;
--10
  CLOSE c_hold_plan;


  EXCEPTION
    WHEN OTHERS THEN
           ROLLBACK;
           RAISE;
END holds_balance;


--To validate holds to be applied

FUNCTION validate_holds(p_person_id           IN    igs_pe_person_v.person_id%TYPE   ,
                        p_person_number       IN     igs_pe_person_v.person_number%TYPE   ,
                        p_hold_start_date     IN    igs_fi_person_holds.hold_start_dt%type,
                        p_hold_type           IN    igs_fi_hold_plan.hold_type%TYPE,
                        p_hold_plan_name      IN    igs_fi_hold_plan.hold_plan_name%TYPE,
                        p_hold_plan_level     IN    igs_fi_hold_plan.hold_plan_level%TYPE,
                        p_process_start_dt    IN    igs_fi_person_holds.process_start_dT%TYPE ,
                        p_process_end_dt      IN    igs_fi_person_holds.process_end_dT%TYPE ,
                        p_offset_days         IN    NUMBER,
                        p_holds_charges       IN    igs_fi_inv_int.invoice_amount%TYPE,
                        p_holds_final_balance IN    igs_fi_credits.amount%TYPE,
                        p_fee_cal_type        IN    igs_fi_inv_int.fee_cal_type%TYPE,
                        p_fee_ci_sequence_number IN igs_fi_inv_int.fee_ci_sequence_number%TYPE,
                        p_test_run            IN    VARCHAR2,
                        p_n_student_plan_id    IN   igs_fi_pp_std_attrs.student_plan_id%TYPE,
                        p_d_last_inst_due_date IN   igs_fi_pp_instlmnts.due_date%TYPE
                        )
RETURN BOOLEAN
IS
/***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              :    To validate holds to be applied
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   sapanigr             04-May-2006     Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_person_holds
                                        are now rounded off to currency precision
   svuppala             17-AUG-2005     Bug 4557933 - Unable to remove holds that were put on with concurrent manager
                                        Passing global values to AUTHORISING_PERSON_ID and AUTH_RESP_ID from SWS Holds API
                                        while calling insert_row of IGS_PE_PERS_ENCUMB_PKG
   smadathi             28-Aug-2003     Enh Bug 3045007. Added 2 new IN parameter - p_n_student_plan_id and
                                        p_d_last_inst_due_date
   pathipat             12-Aug-2003     Enh 3076768 - Automatic Release of Holds
                                        Added param x_release_credit_id to TBH calls of igs_fi_person_holds
   pathipat             25-Feb-2003     Enh:2747341 - Additional Security for Holds build
                                        Removed parameter p_auth_person_id. Passed Null to authorising_person_id
                                        in the call to igs_pe_pers_encumb_pkg.insert_row
  ssawhney   17-feb-2003   Bug : 2758856  : Added the parameter x_external_reference in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW
  pathipat             04-OCT-2002     Enh Bug: 2562745 -- obsoleted column balance_amount from igs_fi_person_holds
                                        Removed column balance_amount from call to igs_fi_person_holds_pkg.insert_row()
   pkpatel              04-OCT-2002     Bug No: 2600842
                                        Added the parameter auth_resp_id in the call to TBH igs_pe_pers_encumb_pkg

 ***************************************************************/

--to check if reocrd exist in IGS_PE_PERS_ENCUMB for the passed start date
CURSOR c_hold_exist
IS
SELECT  *
FROM    igs_pe_pers_encumb
WHERE   person_id = p_person_id
AND     encumbrance_type = p_hold_type
AND     TRUNC(start_dt) = TRUNC(p_hold_start_date);

 --local varaibles declaration
l_hold_exist_rec  c_hold_exist%ROWTYPE;
l_message_name    fnd_new_messages.message_name%TYPE :=NULL;
l_message_string  fnd_new_messages.message_text%TYPE;
l_rowid           VARCHAR2(25) :=NULL;


BEGIN

--Validation to check if the person has the same hold type   already active
       OPEN c_hold_exist;
       FETCH c_hold_exist INTO l_hold_exist_rec;
       IF c_hold_exist%FOUND   THEN
             IF  p_test_run = 'Y' THEN
               fnd_message.set_name('IGS','IGS_FI_HOLD_NOT_VALID');
               fnd_file.put_line(fnd_file.log,fnd_message.get());
               fnd_file.put_line(fnd_file.log,' ');
             END IF;
             CLOSE c_hold_exist;
             RETURN FALSE;
       END IF;
       CLOSE c_hold_exist;
--  Validation to perform check to see if new hold type will cause level conflicts with existing hold types.
      l_message_name := NULL;
      IF NOT (igs_en_val_pen.enrp_val_prsn_encmb(p_person_id,p_hold_type,TRUNC(p_hold_start_date), Null,l_message_name))
                        AND
       (l_message_name IN ('IGS_EN_ENCUMB_TYPE_NOTAPPLIED','IGS_EN_ENCUMBTYPE_DIFF_LVLS','IGS_EN_ENCUMBTYPE_INV_COMBI','IGS_EN_ENCUMBTYPE_PRG_INVALID') )  THEN
           IF  p_test_run = 'Y' THEN
               fnd_message.set_name('IGS','IGS_EN_ENCUMBTYPE_DIFF_LVLS');
                     fnd_file.put_line(fnd_file.log,fnd_message.get());
               fnd_file.put_line(fnd_file.log,' ');
           END IF;
           RETURN FALSE;
      END IF;

      IF p_test_run ='N' THEN
      l_rowid  := NULL;

                     -- If test_tun value is 'N'
                     -- Insert into the person holds table for the person AND the hold type along with the hold start date.
                          igs_pe_pers_encumb_pkg.insert_row (
                                                              X_Mode                              => 'R',
                                                              X_RowId                             => l_rowid,
                                                              X_Person_Id                         => p_person_id,
                                                              X_Encumbrance_Type                  => p_hold_type,
                                                              X_CAL_TYPE                          => null,
                                                              X_SEQUENCE_NUMBER                   => null,
                                                              X_Start_Dt                          => p_hold_start_date,
                                                              X_Expiry_Dt                         => null,
                                                              X_Authorising_Person_Id             => g_n_person_id,
                                                              X_Comments                          => null,
                                                              X_Spo_Course_Cd                     => null,
                                                              X_Spo_Sequence_Number               => null,
                                                              x_auth_resp_id                      => g_n_resp_id,
                                                              x_external_reference                => null); -- should always be null when passed from internal system

--Check if the hold type has effects that require any active enrolments of the person to be discontinued by making a call to the below function
                     l_message_name := NULL;

                     IF NOT igs_en_val_pen.finp_val_encmb_eff (p_person_id,
                                                               p_hold_type,
                                                               TRUNC(SYSDATE),
                                                               NULL,
                                                               l_message_name)
                       AND l_message_name IN ('IGS_FI_ENCUMB_NOTAPPLIED_RVK',
                                              'IGS_FI_ENCUMB_NOTAPPLIED_EXC',
                                              'IGS_EN_PERS_ENRL_COURSE',
                                              'IGS_EN_CANT_APPLY_ENCUM_EFFEC',
                                              'IGS_EN_DISCON_STUD_ENRL',
                                              'IGS_EN_PERS_ENRL_EXCL_COURSE') THEN
                            fnd_message.set_name('IGS','IGS_FI_ACTIVE_ENRLLM_DISCONT');
                            fnd_message.set_token('HOLD_TYPE',p_hold_type);
                            fnd_message.set_token('PERSON',p_person_number);
                            fnd_file.put_line(fnd_file.log,fnd_message.get());
                            fnd_file.put_line(fnd_file.log,' ');

--TO rollback the previous insert
                       ROLLBACK;
                       RETURN FALSE;
                    END IF;
--To populate the default hold effects associated with the hold type placed.
                    l_message_name := NULL;
                    igs_en_gen_009.enrp_ins_dflt_effect (p_person_id,
                                                         p_hold_type,
                                                         TRUNC(p_hold_start_date),
                                                         null,
                                                         null,
                                                         l_message_name,
                                                         l_message_string);
                   IF l_message_name IS NOT NULL   THEN
                           fnd_message.set_name('IGS','IGS_FI_DEFAULT_HOLD_EFFECTS');
                           fnd_message.set_token('HOLD_TYPE',p_hold_type);
                           fnd_file.put_line(fnd_file.log,fnd_message.get());
                           fnd_file.put_line(fnd_file.log,' ');
--TO rollback the previous insert
                           ROLLBACK;
                           RETURN FALSE;
                   END IF;
IF  p_hold_plan_level  ='S' THEN
    l_rowid  := NULL;
--To insert the required data elements as shown below to the intermediate table IGS_FI_PERSON_HOLDS
--Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
                  igs_fi_person_holds_pkg.insert_row(
                                           x_Mode                              => 'R',
                                           x_RowId                             => l_rowid,
                                           x_person_id                         => p_person_id,
                                           x_hold_plan_name                    => p_hold_plan_name ,
                                           x_hold_type                         => p_hold_type ,
                                           x_hold_start_dt                     => p_hold_start_date,
                                           x_process_start_dt                  => p_process_start_dt,
                                           x_process_end_dt                    => p_process_end_dt,
                                           x_offset_days                       => p_offset_days,
                                           x_past_due_amount                   => igs_fi_gen_gl.get_formatted_amount(P_holds_final_balance),
                                           x_fee_cal_type                      => NULL,
                                           x_fee_ci_sequence_number            => NULL,
                                           x_fee_type_invoice_amount           => NULL,
                                           x_release_credit_id                 => NULL,
                                           x_student_plan_id                   => p_n_student_plan_id,
                                           x_last_instlmnt_due_date            => p_d_last_inst_due_date
                                           );


ELSIF p_hold_plan_level ='F' THEN
l_rowid  := NULL;
-- Call to igs_fi_gen_gl.get_formatted_amount formats amounts by rounding off to currency precision
                 igs_fi_person_holds_pkg.insert_row(
                                           x_Mode                              => 'R',
                                           x_Rowid                             => l_rowid,
                                           x_person_id                         => p_person_id,
                                           x_hold_plan_name                    => p_hold_plan_name ,
                                           x_hold_type                         => p_hold_type ,
                                           x_hold_start_dt                     => p_hold_start_date,
                                           x_process_start_dt                  => p_process_start_dt,
                                           x_process_end_dt                    => p_process_start_dt,
                                           x_offset_days                       => NULL,
                                           x_past_due_amount                   => igs_fi_gen_gl.get_formatted_amount(P_holds_final_balance),
                                           x_fee_cal_type                      => P_fee_cal_type ,
                                           x_fee_ci_sequence_number            => P_fee_ci_sequence_number ,
                                           x_fee_type_invoice_amount           => igs_fi_gen_gl.get_formatted_amount(p_holds_charges),
                                           x_release_credit_id                 => NULL,
                                           x_student_plan_id                   => p_n_student_plan_id,
                                           x_last_instlmnt_due_date            => p_d_last_inst_due_date
                                           );

END IF;
--TO commit the data for this person as from now the processing for next person will start.
COMMIT;
END IF;

--TO return TRUE back to the main procedure if all the validations get passed
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
           ROLLBACK;
           RAISE;
END validate_holds;

--Function to validate passed parameter values


FUNCTION validate_param(p_person_id          IN     igs_pe_person_v.person_id%TYPE   ,
                        p_person_id_group    IN     igs_pe_persid_group_v.group_id%TYPE   ,
                        P_process_start_date IN     igs_fi_person_holds.process_start_dT%TYPE ,
                        P_process_end_date   IN     igs_fi_person_holds.process_end_dT%TYPE ,
                        P_hold_plan_name     IN     igs_fi_hold_plan.hold_plan_name%Type,
                        P_fee_cal_type       IN     igs_fi_inv_int.fee_cal_type%TYPE,
                        P_fee_ci_sequence_number IN igs_fi_inv_int.fee_ci_sequence_number%TYPE
                       )
RETURN BOOLEAN
IS
/***************************************************************
   Created By           :       bayadav
   Date Created By      :       2001/04/25
   Purpose              : To validate the input parameters
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   smadathi             28-Aug-2003     Enh Bug 3045007. Removed the parameter P_OFFSET_DAYS.
   pathipat             12-Aug-2003     Enh 3076768 - Automatic Release of Holds
                                        Removed calls to igs_pe_gen_001.get_hold_auth -- Removed validation for staff member
   pathipat             23-Jun-2003     Bug: 3018104 - Impact of changes in person id group views
                                        Modified cursor c_person_group_id - replaced igs_pe_persid_group_v
                                        with igs_pe_persid_group
   pathipat             25-Feb-2003     Enh:2747341 - Additional Security for Holds build
                                        Removed parameter p_auth_person_id, added call to igs_pe_gen_001.get_hold_auth
   pathipat             04-OCT-2002     Enh Bug:2562745
                                        1. Added check to see if balance rule is defined for 'HOLDS', else
                                           stop further processing.
                                        2. Also, when the hold plan is determined at 'ACcount' level, then the
                                           process_start_dt cannot be before the last_conversion_date from igs_fi_balance_rules
                                        3. In check between process_start_date and process_end_date, it was made > in place of
                                           >= .
   sykrishn             30/APR/2002     c_fee_type cursor changed to compare with fee structure system status
                                        bug 2348883

 ***************************************************************/

-- to get the person group id related info
CURSOR c_person_group_id IS
 SELECT group_id
 FROM igs_pe_persid_group
 WHERE group_id   =  p_person_id_group
 AND   TRUNC(create_dt)  <= TRUNC(SYSDATE)
 AND   closed_ind = 'N';

--to get hold_plan_name related info
CURSOR c_hold_plan_name IS
  SELECT hold_plan_name,
         hold_plan_level,
         offset_days
  FROM igs_fi_hold_plan
  WHERE   hold_plan_name = p_hold_plan_name
  AND    closed_ind = 'N';

--to get fee related info based on the prameters value passed
CURSOR c_fee_type IS
  SELECT fcc.fee_cal_type
  FROM igs_fi_f_typ_ca_inst fcc,
        igs_fi_fee_str_stat fss
  WHERE fcc.fee_type_ci_status = fss.fee_structure_status
  AND    fss.s_fee_structure_status = 'ACTIVE'
  AND    fcc.fee_cal_type = p_fee_cal_type
  AND    fcc.fee_ci_sequence_number = p_fee_ci_sequence_number ;

 --declaration of local variables

 l_person_group_id_rec    c_person_group_id%ROWTYPE;
 l_hold_plan_name_rec     c_hold_plan_name%ROWTYPE;
 l_fee_type_rec           c_fee_type%ROWTYPE;

 l_last_conv_dt           igs_fi_balance_rules.last_conversion_date%TYPE;
 l_version_number         igs_fi_balance_rules.version_number%TYPE;

BEGIN
--Check for mandatory parameters
    IF  p_process_start_date IS NULL THEN
             fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
             fnd_message.set_token('PARAMETER','P_PROCESS_START_DATE');
             fnd_file.put_line(fnd_file.log,' ');
             RETURN FALSE;
    ELSIF  p_hold_plan_name  IS NULL THEN
             fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
             fnd_message.set_token('PARAMETER','P_HOLD_PLAN_NAME');
             fnd_file.put_line(fnd_file.log,' ');
             RETURN FALSE;
    END IF;

    igs_fi_gen_007.finp_get_balance_rule ( p_v_balance_type         => 'HOLDS',
                                          p_v_action                => 'ACTIVE',
                                          p_n_balance_rule_id       => l_balance_rule_id,
                                          p_d_last_conversion_date  => l_last_conv_dt,
                                          p_n_version_number        => l_version_number );

    IF l_version_number = 0 THEN
           -- Exit if balance rule is not defined
           fnd_message.set_name('IGS','IGS_FI_BR_CANNOT_APP_HLDS');
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           RETURN FALSE;
    END IF;

    IF (p_person_id IS  NOT NULL AND p_person_id_group IS NOT NULL) THEN
           -- Exit if the value of both the  parameters p_person_id AND p_person_id_group are not  NUll
           fnd_message.set_name('IGS','IGS_FI_NO_PERS_PGRP');
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           RETURN FALSE;
    ELSIF p_person_id IS NOT NULL AND p_person_id_group IS  NULL THEN
         -- Exit if the passed person_id is not valid
         OPEN c_person(p_person_id);
         FETCH c_person INTO l_person_rec;
         IF c_person%NOTFOUND  THEN
           fnd_message.set_name('IGS','IGS_FI_INVALID_PERSON_ID');
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           CLOSE c_person;
           RETURN FALSE;
         END IF;
          CLOSE c_person;
    ELSIF p_person_id IS NULL AND p_person_id_group IS NOT NULL THEN
         -- Exit if the passed person group id is not valid
         OPEN c_person_group_id;
         FETCH c_person_group_id INTO l_person_group_id_rec;
         IF c_person_group_id%NOTFOUND  THEN
             fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
             fnd_message.set_token('PARAMETER','P_PERSON_ID_GROUP');
             fnd_file.put_line(fnd_file.log,' ');
             CLOSE c_person_group_id;
             RETURN FALSE;
         END IF;
         CLOSE c_person_group_id;
    END IF;

    --To check for p_process_start_date validity
    IF    TRUNC(p_process_start_date) > TRUNC(SYSDATE) THEN
             fnd_message.set_name('IGS','IGS_FI_PR_ST_DT');
             fnd_file.put_line(fnd_file.log,fnd_message.get());
             fnd_file.put_line(fnd_file.log,' ');
             RETURN FALSE;

    -- If p_process_end_date is not NULL then (process_end_date +offset days) should not be greater THEN
    --sysdate
    ELSIF p_process_end_date IS NOT NULL THEN
      OPEN  c_hold_plan_name;
      FETCH c_hold_plan_name INTO l_hold_plan_name_rec;
      CLOSE c_hold_plan_name;
      IF    (TRUNC(p_process_end_date) + NVL(l_hold_plan_name_rec.offset_days,0))   > TRUNC(SYSDATE)   THEN
             fnd_message.set_name('IGS','IGS_FI_PR_EN_OFF_DT');
             fnd_file.put_line(fnd_file.log,fnd_message.get());
             fnd_file.put_line(fnd_file.log,' ');
             RETURN FALSE;
      END IF;

      --If p_process_end_date is not NULL then process_end_date  should not be less than process_start_date
      IF   TRUNC(p_process_start_date) >  TRUNC(p_process_end_date)  THEN
        fnd_message.set_name('IGS','IGS_FI_PR_EN_DT');
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(fnd_file.log,' ');
        RETURN FALSE;
      END IF;
    END IF;

     --To check for hold plan name validity
    OPEN  c_hold_plan_name;
    FETCH c_hold_plan_name INTO l_hold_plan_name_rec;
    IF c_hold_plan_name%NOTFOUND THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_HP');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.put_line(fnd_file.log,' ');
      CLOSE c_hold_plan_name;
      RETURN FALSE;
    END IF;
    CLOSE c_hold_plan_name;

     --To find the level at which the hold plan is defined
            --2
    IF l_hold_plan_name_rec.hold_plan_level = 'S' THEN
                 -- If hold plan is defined at Account level, then process_start_Date cannot be before the
                 -- last_conversion_date of the latest active balance rule for 'HOLDS' type
                 IF (TRUNC(p_process_start_date) < TRUNC(l_last_conv_dt)) THEN
                      fnd_message.set_name('IGS','IGS_FI_FINAPP_HLDS_DT');
                      fnd_message.set_token('DATE1',p_process_start_date);
                      fnd_message.set_token('DATE2',l_last_conv_dt);
                      fnd_file.put_line(fnd_file.log,fnd_message.get());
                      fnd_file.put_line(fnd_file.log,' ');
                      RETURN FALSE;
                 END IF;

                 --If the hold plan is defined at Account/student level then the parameter p_process_end_date is mandatory
                 IF p_process_end_date IS NULL THEN
                      fnd_message.set_name('IGS','IGS_FI_PROCESS_ENDDT_NULL');
                      fnd_file.put_line(fnd_file.log,fnd_message.get());
                      fnd_file.put_line(fnd_file.log,' ');
                      RETURN FALSE;
                 END IF;
   ELSIF l_hold_plan_name_rec.hold_plan_level  = 'F' THEN
                 --To check if the mandatory  parameters p_fee_cal_type  AND p_fee_ci_sequence_number are specified
                 --if the hold_plan_level SELECTed above is 'F'.
                 --6
                 IF p_fee_cal_type IS NULL AND  p_fee_ci_sequence_number IS NULL THEN
                      fnd_message.set_name('IGS','IGS_FI_FEE_PERIOD_NOT_NULL');
                      fnd_file.put_line(fnd_file.log,fnd_message.get());
                      fnd_file.put_line(fnd_file.log,' ');
                      RETURN FALSE;
                 --6
                 END IF;
   END IF;

--To check for fee_cal_type  validity if specified
     IF  p_fee_cal_type IS NOT NULL  AND  p_fee_ci_sequence_number IS NOT NULL  THEN
        OPEN  c_fee_type;
        FETCH c_fee_type INTO l_fee_type_rec;
        IF c_fee_type%NOTFOUND THEN
             fnd_message.set_name('IGS','IGS_FI_FTCI_NOTFOUND');
             fnd_file.put_line(fnd_file.log,fnd_message.get());
             fnd_file.put_line(fnd_file.log,' ');
             CLOSE c_fee_type;
             RETURN FALSE;
        END IF;
        CLOSE c_fee_type;
    END IF;

   --IF all the validations get passed then RETURN TRUE BACK to the main procedure
   RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END validate_param;



PROCEDURE finp_apply_holds(errbuf               OUT NOCOPY    VARCHAR2,
                           retcode              OUT NOCOPY    NUMBER,
                           p_person_id          IN     igs_pe_person_v.person_id%TYPE         ,
                           p_person_id_group    IN     igs_pe_persid_group_v.group_id%TYPE    ,
                           P_process_start_date IN     VARCHAR2 ,
                           P_process_end_date   IN     VARCHAR2 ,
                           P_hold_plan_name     IN     igs_fi_hold_plan.hold_plan_name%Type,
                           P_fee_period         IN     VARCHAR2,
                           P_test_run           IN     VARCHAR2 )

 IS

 /***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              :   To carry out NOCOPY the functionality of application of holds for the person.
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   svuppala            17-AUG-2005      Bug 4557933 - Unable to remove holds that were put on with concurrent manager
                                        Validate_holds : getting global values for AUTHORISING_PERSON_ID and AUTH_RESP_ID from SWS Holds API
   pmarada              26-jul-2004     Bug 3792800, Added code to bypass the holds apply validation
   smadathi             28-Aug-2003     Enh Bug 3045007. Removed the parameter P_OFFSET_DAYS from
                                        procedure finp_apply_holds and all the references of P_OFFSET_DAYS
   pathipat             23-Jun-2003     Bug: 3018104 - Impact of changes in person id group views
                                        Modified cursor c_person_group - replaced igs_pe_prsid_grp_mem_v
                                        with igs_pe_prsid_grp_mem
   pathipat             05-May-2003     Enh 2831569 - Commercial Receivables Build
                                        Added check for manage_accounts - call to igs_fi_com_rec_interface.check_manage_acc()
   vvutukur             25-Mar-2003     Enh#2824994.Modified code such that log file output is not shown in horizontal tabular format, instead it
                                        it is shown in linear/logging format.Removed the code using l_person_ind as it is redundant since it is used
                                        earlier to print header in tabular format only once when the person is processed for the first time.
                                        Also used global variables to log the details.
   pathipat             25-Feb-2003     Enh:2747341 - Additional Security for Holds build
                                        Removed parameter p_auth_person_id and related code
                                        Removed p_auth_person_id in calls to functions validate_holds and validate_param
   SYKRISHn    03-JAN-2002              Bug 2684895 --Procedure finp_apply_holds
                                        Logging Person Group Cd instead of person group id.
                                        used igs_fi_gen_005.finp_get_prsid_grp_code
   SYKRISHN    31DEC2002                Bug 2676524 - Procedure finp_apply_holds
                                        Derived the person number for the parameter p_auth_person_id
                                        to display in the concurrent log file instead of the P_auth_person_id which
                                        was logged earlier.

   pathipat             04-OCT-2002     Enh Bug:2562745, added check that if the holds conversion process
                                        is running, then application of holds cannot take place.
 ***************************************************************/
--Cursor to SELECT dstinct persons FROM igs_pe_prsid_grp_mem_v if person group id is passsed
CURSOR c_person_group IS
  SELECT person_id
  FROM   igs_pe_prsid_grp_mem
  WHERE  (TRUNC(end_date) IS NULL OR TRUNC(end_date) >= TRUNC(SYSDATE))
  AND    group_id = p_person_id_group;
--Cursor to SELECT distinct persons FROM igs_fi_inv_int if person id AND person group id are passsed as NULL
CURSOR c_person_inv_int IS
  SELECT DISTINCT person_id
  FROM igs_fi_inv_int;

--Declare variables to store the values of cursors decalred above.
 l_person_group_rec        c_person_group%ROWTYPE;
 l_person_inv_int_rec      c_person_inv_int%ROWTYPE;
 l_fee_cal_type            igs_fi_inv_int.fee_cal_type%TYPE;
 l_fee_ci_sequence_number  igs_fi_inv_int.fee_ci_sequence_number%TYPE;
 l_person_number           igs_pe_person.person_number%TYPE :=NULL;
 l_person_name             igs_pe_person_base_v.full_name%TYPE :=NULL;
 l_message_name            fnd_new_messages.message_name%TYPE :=NULL;
 l_message_name_1          fnd_new_messages.message_name%TYPE :=NULL;
 l_hold_type               igs_fi_hold_plan.hold_type%TYPE;
 l_hold_plan_level         igs_fi_hold_plan.hold_plan_level%TYPE;
 l_hold_plan_name          igs_fi_hold_plan.hold_plan_name%TYPE;
 l_holds_charges           igs_fi_inv_int.invoice_amount%TYPE := 0;
 l_holds_final_balance     igs_fi_credits.amount%TYPE  := 0;
 l_count                   PLS_INTEGER := 0;
 l_msg_str_0               VARCHAR2(1000) :=NULL;
 l_msg_str_1               VARCHAR2(1000) :=NULL;
 l_process_start_date      igs_fi_person_holds.process_start_dT%TYPE;
 l_process_end_date        igs_fi_person_holds.process_end_dT%TYPE;

 l_process_run_ind         igs_fi_control_all.conv_process_run_ind%TYPE;

 l_v_manage_acc            igs_fi_control_all.manage_accounts%TYPE := NULL;
 l_v_message_name          fnd_new_messages.message_name%TYPE :=NULL;
 l_n_offset_days           igs_fi_hold_plan.offset_days%TYPE :=0;
 l_n_student_plan_id       igs_fi_pp_std_attrs.student_plan_id%TYPE;
 l_d_last_inst_due_date    igs_fi_pp_instlmnts.due_date%TYPE;
 l_n_fnd_user_id   fnd_user.user_id%TYPE;
 l_v_person_number  hz_parties.party_number%TYPE;
 l_v_person_name    hz_person_profiles.person_name%TYPE;
 l_v_msg_name  FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;


BEGIN

  --TO set the org id
  igs_ge_gen_003.set_org_id(null);
  retcode:= 0;
  --initialise the global variables
  g_n_resp_id       := NULL;
  g_n_person_id     := NULL;
   -- Initializing the hold validation global parameter to N, This global variable defined in IGSNI18S.pls
   -- with default value Y, If the value is Y then TBH validates the holds for person. But as per bug
   -- we have to bypass the apply holds validation, hence we are initializing to N. pmarada, bug 3792800
   igs_pe_gen_001.g_hold_validation := 'N';

  IF p_fee_period IS NOT NULL THEN
    l_fee_cal_type := RTRIM(SUBSTR(p_fee_period, 102, 10));
    l_fee_ci_sequence_number := TO_NUMBER(LTRIM(SUBSTR(p_fee_period, 113,8)));
  END IF;

  --To get the value of passed date parameters in canonical format
  IF p_process_start_date IS NOT NULL THEN
    l_process_start_date  := TRUNC(igs_ge_date.igsdate(p_process_start_date));
  END IF;

  IF p_process_end_date  IS NOT NULL THEN
    l_process_end_date  := TRUNC(igs_ge_date.igsdate(p_process_end_date));
  END IF;

  --To get the passed person id if not NULL corresponding person number
  IF p_person_id IS NOT NULL THEN
    OPEN c_person(p_person_id);
    FETCH c_person INTO l_person_rec;
    l_person_number := l_person_rec.person_number;
    l_person_name := l_person_rec.full_name;
    CLOSE c_person;
  END IF;

  --TO print the passed parameter values at the starting of log
  fnd_message.set_name('IGS','IGS_FI_APPLY_HOLD_PARAM');
  fnd_message.set_token('PERSON_NUMBER', l_person_number);
  fnd_message.set_token('PERSON_GROUP',igs_fi_gen_005.finp_get_prsid_grp_code(p_person_id_group));
  fnd_message.set_token('PROCESS_START_DATE',p_process_start_date);
  fnd_message.set_token('PROCESS_END_DATE',p_process_end_date);
  fnd_message.set_token('HOLD_PLAN_NAME',p_hold_plan_name);
  fnd_message.set_token('FEE_PERIOD',p_fee_period);
  fnd_message.set_token('TEST_RUN',p_test_run);
  fnd_file.put_line(fnd_file.log,fnd_message.get());
  fnd_file.put_line(fnd_file.log,' ');

  -- Obtain the value of manage_accounts in the System Options form
  -- If it is null or 'OTHER', then this process is not available, so error out.
  igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                               p_v_message_name => l_v_message_name
                                             );
  IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.new_line(fnd_file.log);
    retcode := 2;  -- error out
    RETURN;
  END IF;

  -- If the holds conversion process is running (conv_process_run_ind of the control_all table
  -- will be 1 if the process is running), then error out. Else continue.
  igs_fi_gen_007.finp_get_conv_prc_run_ind( p_n_conv_process_run_ind  => l_process_run_ind,
                                            p_v_message_name          => l_message_name_1) ;

  IF l_message_name_1 IS NOT NULL THEN
    fnd_message.set_name('IGS',l_message_name_1);
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.new_line(fnd_file.log);
    retcode := 2;  -- error out
    RETURN;
  END IF;

  IF l_process_run_ind = 1 THEN
    -- Stop further processing as the holds conversion process is running
    fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    fnd_file.put_line(fnd_file.log,' ');
    retcode := 2;  -- error out
    RETURN;
  END IF;

  --function to validate the input parameters .In this if any of the validation fails appropriate errors are logged
  --proceessing does not take palce further.
  --1
  IF NOT  validate_param(p_person_id          ,
                         p_person_id_group    ,
                         l_process_start_date ,
                         l_process_end_date   ,
                         p_hold_plan_name     ,
                         l_fee_cal_type       ,
                         l_fee_ci_sequence_number
                         )  THEN
    retcode := 2;
    RETURN;
   --1
  ELSE
      l_n_fnd_user_id   := FND_GLOBAL.USER_ID;
      g_n_resp_id       := FND_GLOBAL.RESP_ID;
      --derive the attributes - Authorising_Person_Id
      igs_pe_gen_001.get_hold_auth(l_n_fnd_user_id,
                                   g_n_person_id,
                                   l_v_person_number,
                                   l_v_person_name,
                                   l_v_msg_name);

     IF l_v_msg_name IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('IGS',l_v_msg_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get());
          fnd_file.put_line(fnd_file.log,' ');
          retcode := 2;
          RETURN;
     END IF;

    --To check only for 1 condition as for 0 the further execution has not to be done AND error message has been logged earlier in validate_param
    --2
    IF  p_person_id IS NOT NULL THEN
      --3

      IF NOT holds_balance ( p_person_id ,
                             l_person_number,
                             p_hold_plan_name ,
                             l_fee_cal_type ,
                             l_fee_ci_sequence_number ,
                             l_process_end_date ,
                             l_process_start_date ,
                             p_test_run,
                             l_hold_type ,
                             l_hold_plan_level,
                             l_holds_charges ,
                             l_holds_final_balance,
                             l_n_offset_days,
                             l_n_student_plan_id,
                             l_d_last_inst_due_date
                             ) THEN
        fnd_message.set_name('IGS','IGS_FI_HOLD_NOT_APPLY');
        fnd_message.set_token('PERSON',l_person_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(fnd_file.log,' ');
        RETURN;
      ELSE

        --Call a private function for validating the values to apply holds for the person,toinsert data into holds table AND to print
        --the output.
        IF NOT  validate_holds( p_person_id,
                                l_person_number,
                                TRUNC(SYSDATE),
                                l_hold_type,
                                p_hold_plan_name,
                                l_hold_plan_level,
                                l_process_start_date,
                                l_process_end_date,
                                l_n_offset_days,
                                l_holds_charges,
                                l_holds_final_balance,
                                l_fee_cal_type ,
                                l_fee_ci_sequence_number ,
                                p_test_run,
                                l_n_student_plan_id,
                                l_d_last_inst_due_date
                                ) THEN
          fnd_message.set_name('IGS','IGS_FI_HOLD_NOT_APPLY');
          fnd_message.set_token('PERSON', l_person_number);
          fnd_file.put_line(fnd_file.log,fnd_message.get());
          fnd_file.put_line(fnd_file.log,' ');
          RETURN;
        ELSE

          --count of persons on whom holds is applied
          l_count  := l_count +1;
          --To print the log file for both the cases of test_run parameter value
          IF p_test_run = 'Y' AND l_count = 1 THEN
            fnd_message.set_name('IGS','IGS_FI_HOLDS_APPLY');
            fnd_file.put_line(fnd_file.log,fnd_message.get());
            fnd_file.put_line(fnd_file.log,' ');
          ELSIF p_test_run = 'N' AND l_count = 1 THEN
            fnd_message.set_name('IGS','IGS_FI_HLDS_HV_APP');
            fnd_file.put_line(fnd_file.log,fnd_message.get());
            fnd_file.put_line(fnd_file.log,' ');
          END IF;

          fnd_file.put_line(fnd_file.log,g_v_person_number ||' : '||l_person_number);
          fnd_file.put_line(fnd_file.log,g_v_person_name   ||' : '||l_person_name);
          fnd_file.put_line(fnd_file.log,g_n_holds_bal     ||' : '||TO_CHAR(l_holds_charges));
          fnd_file.put_line(fnd_file.log,g_n_overdue_bal   ||' : '||TO_CHAR(l_holds_final_balance));
          fnd_file.put_line(fnd_file.log,g_v_hold_type     ||' : '||l_hold_type);
          fnd_file.put_line(fnd_file.log,' ');
        END IF;
           --3
      END IF;
      --2
    ELSIF p_person_id_group IS NOT NULL THEN
      OPEN c_person_group;
      LOOP
      FETCH c_person_group INTO l_person_group_rec;
      EXIT WHEN c_person_group%NOTFOUND;
      BEGIN
        OPEN c_person(l_person_group_rec.person_id);
        FETCH c_person INTO l_person_rec;
        CLOSE c_person;
        --4
        IF NOT holds_balance (l_person_group_rec.person_id ,
                              l_person_rec.person_number ,
                              p_hold_plan_name ,
                              l_fee_cal_type ,
                              l_fee_ci_sequence_number ,
                              l_process_end_date ,
                              l_process_start_date ,
                              p_test_run,
                              l_hold_type ,
                              l_hold_plan_level,
                              l_holds_charges ,
                              l_holds_final_balance,
                              l_n_offset_days ,
                              l_n_student_plan_id,
                              l_d_last_inst_due_date
                              )  THEN
          RAISE skip;
        --4
        ELSE
          IF NOT validate_holds(l_person_group_rec.person_id ,
                                l_person_rec.person_number,
                                TRUNC(SYSDATE),
                                l_hold_type ,
                                p_hold_plan_name,
                                l_hold_plan_level ,
                                l_process_start_date,
                                l_process_end_date ,
                                l_n_offset_days        ,
                                l_holds_charges ,
                                l_holds_final_balance,
                                l_fee_cal_type ,
                                l_fee_ci_sequence_number ,
                                p_test_run,
                                l_n_student_plan_id,
                                l_d_last_inst_due_date
                                ) THEN
            RAISE skip;
          ELSE
            --count of persons on whom holds is applied
            l_count  := l_count +1;

            --To print the log file for both the cases of test_run parameter value
            IF p_test_run = 'Y' AND l_count = 1 THEN
              fnd_message.set_name('IGS','IGS_FI_HOLDS_APPLY');
              fnd_file.put_line(fnd_file.log,fnd_message.get());
              fnd_file.put_line(fnd_file.log,' ');
            ELSIF p_test_run = 'N' AND l_count = 1 THEN
              fnd_message.set_name('IGS','IGS_FI_HLDS_HV_APP');
              fnd_file.put_line(fnd_file.log,fnd_message.get());
              fnd_file.put_line(fnd_file.log,' ');
            END IF;

            fnd_file.put_line(fnd_file.log,g_v_person_number ||' : '||l_person_rec.person_number);
            fnd_file.put_line(fnd_file.log,g_v_person_name   ||' : '||l_person_rec.full_name);
            fnd_file.put_line(fnd_file.log,g_n_holds_bal     ||' : '||TO_CHAR(l_holds_charges));
            fnd_file.put_line(fnd_file.log,g_n_overdue_bal   ||' : '||TO_CHAR(l_holds_final_balance));
            fnd_file.put_line(fnd_file.log,g_v_hold_type     ||' : '||l_hold_type);
            fnd_file.put_line(fnd_file.log,' ');
          END IF;
        --4
        END IF;

        EXCEPTION
          WHEN skip THEN
            IF c_person%ISOPEN THEN
              CLOSE c_person;
            END IF;

            fnd_message.set_name('IGS','IGS_FI_HOLD_NOT_APPLY');
            fnd_message.set_token('PERSON',l_person_rec.person_number);
            fnd_file.put_line(fnd_file.log,fnd_message.get());
            fnd_file.put_line(fnd_file.log,' ');
          WHEN OTHERS THEN
            ROLLBACK;
            fnd_file.put_line(fnd_file.log,sqlerrm);
            fnd_file.put_line(fnd_file.log,' ');
      END;
      END LOOP;
      CLOSE c_person_group;
    --2
    ELSE
      --Both person_id AND person_group_code are NULL
      OPEN  c_person_inv_int ;
      LOOP
        FETCH c_person_inv_int INTO l_person_inv_int_rec;
        EXIT WHEN c_person_inv_int%NOTFOUND;
        BEGIN
          OPEN c_person(l_person_inv_int_rec.person_id);
          FETCH c_person INTO l_person_rec;
          CLOSE c_person;
          --5
          IF NOT holds_balance (l_person_inv_int_rec.person_id ,
                                l_person_rec.person_number,
                                p_hold_plan_name ,
                                l_fee_cal_type ,
                                l_fee_ci_sequence_number ,
                                l_process_end_date ,
                                l_process_start_date ,
                                p_test_run,
                                l_hold_type ,
                                l_hold_plan_level,
                                l_holds_charges ,
                                l_holds_final_balance,
                                l_n_offset_days,
                                l_n_student_plan_id,
                                l_d_last_inst_due_date
                                ) THEN
            RAISE skip;
          --5
          ELSE
            IF NOT  validate_holds(l_person_inv_int_rec.person_id ,
                                   l_person_rec.person_number,
                                   TRUNC(SYSDATE),
                                   l_hold_type ,
                                   p_hold_plan_name,
                                   l_hold_plan_level ,
                                   l_process_start_date,
                                   l_process_end_date ,
                                   l_n_offset_days,
                                   l_holds_charges ,
                                   l_holds_final_balance,
                                   l_fee_cal_type ,
                                   l_fee_ci_sequence_number ,
                                   p_test_run,
                                   l_n_student_plan_id,
                                   l_d_last_inst_due_date
                                   ) THEN
              RAISE skip;
            ELSE
              --count of persons on whom holds is applied
              l_count  := l_count +1;

              --To print the log file for both the cases of test_run parameter value
              IF p_test_run = 'Y' AND l_count = 1 THEN
                fnd_message.set_name('IGS','IGS_FI_HOLDS_APPLY');
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                fnd_file.put_line(fnd_file.log,' ');
              ELSIF p_test_run = 'N' AND l_count = 1 THEN
                fnd_message.set_name('IGS','IGS_FI_HLDS_HV_APP');
                fnd_file.put_line(fnd_file.log,fnd_message.get());
                fnd_file.put_line(fnd_file.log,' ');
              END IF;

              fnd_file.put_line(fnd_file.log,g_v_person_number ||' : '||l_person_rec.person_number);
              fnd_file.put_line(fnd_file.log,g_v_person_name   ||' : '||l_person_rec.full_name);
              fnd_file.put_line(fnd_file.log,g_n_holds_bal     ||' : '||TO_CHAR(l_holds_charges));
              fnd_file.put_line(fnd_file.log,g_n_overdue_bal   ||' : '||TO_CHAR(l_holds_final_balance));
              fnd_file.put_line(fnd_file.log,g_v_hold_type     ||' : '||l_hold_type);
              fnd_file.put_line(fnd_file.log,' ');
            END IF;
          --5
          END IF;

          EXCEPTION
            WHEN skip THEN
              fnd_message.set_name('IGS','IGS_FI_HOLD_NOT_APPLY');
              fnd_message.set_token('PERSON',l_person_rec.person_number);
              fnd_file.put_line(fnd_file.log,fnd_message.get());
              fnd_file.put_line(fnd_file.log,' ');

              IF c_person%ISOPEN THEN
                CLOSE c_person;
              END IF;
            WHEN OTHERS THEN
              ROLLBACK;
              fnd_file.put_line(fnd_file.log,sqlerrm);
              fnd_file.put_line(fnd_file.log,' ');
        END;
        END LOOP;
        CLOSE c_person_inv_int;
      --2
      END IF;
    --1
    END  IF;

    --to display the count of persons on whom holds is applied
    IF p_test_run = 'N' THEN
      fnd_file.put_line(fnd_file.log,' ');
      fnd_message.set_name('IGS','IGS_FI_TOTAL_HOLDS_APPLY');
      fnd_message.set_token('COUNT',l_count);
      fnd_file.put_line(fnd_file.log,fnd_message.get());
    END IF;


    -- It is possible to do a test run which does not change
    -- data but performs all the assessment processing.
    IF (p_test_run = 'N') THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
    -- Hold validation is global variable, For bypassing the hold validation we initialized to N
    -- at the starting of the process, after completes the process re-initializing back default value Y.
       igs_pe_gen_001.g_hold_validation := 'Y';

    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode := 2;
      errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||SUBSTR(sqlerrm,1,40);
      igs_ge_msg_stack.add;
      igs_ge_msg_stack.conc_exception_hndl;
  END finp_apply_holds;


FUNCTION validate_param(p_person_id          IN    igs_pe_person_v.person_id%TYPE,
                        p_person_id_group    IN    igs_pe_persid_group_v.group_id%TYPE,
                        P_hold_plan_name     IN    igs_fi_hold_plan.hold_plan_name%Type,
                        P_message_name       OUT NOCOPY   fnd_new_messages.message_name%TYPE)
RETURN BOOLEAN
IS
/***************************************************************
   Created By           :       bayadav
   Date Created By      :       2001/04/25
   Purpose              : To validate the input parameters
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who        When            What
   pathipat   12-Aug-2003     Enh 3076768 - Automatic Release of Holds
                              Removed calls to igs_pe_gen_001.get_hold_auth
   pathipat   23-Jun-2003     Bug: 3018104 - Impact of changes in person id group views
                              Modified cursor c_person_group_id - replaced igs_pe_persid_group_v
                              with igs_pe_persid_group
   pathipat   25-Feb-2003     Enh:2747341 - - Additional Security for Holds build
                              Added validation for hold authorizer
 ***************************************************************/
CURSOR c_person_group_id
 IS
 SELECT  group_id
 FROM igs_pe_persid_group
 WHERE group_id   =  p_person_id_group
 AND   TRUNC(create_dt)  <= TRUNC(SYSDATE)
 AND   closed_ind = 'N';

CURSOR c_hold_plan_name
IS
  SELECT hold_plan_name
  FROM igs_fi_hold_plan
  WHERE   hold_plan_name = p_hold_plan_name;

 l_person_group_id_rec    c_person_group_id%ROWTYPE;
 l_hold_plan_name_rec     c_hold_plan_name%ROWTYPE;

BEGIN

  IF (p_person_id IS  NOT NULL AND p_person_id_group IS NOT NULL) THEN

  -- Exit if the value of both the  parameters p_person_id and p_person_id_group are not  NULL
           fnd_message.set_name('IGS','IGS_FI_NO_PERS_PGRP');
           p_message_name := 'IGS_FI_NO_PERS_PGRP';
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           RETURN FALSE;
   ELSIF ( p_person_id IS NOT NULL AND p_person_id_group IS  NULL) THEN

-- Exit if the passed person_id is not valid

         OPEN c_person(p_person_id);
         FETCH c_person INTO l_person_rec;
         IF c_person%NOTFOUND  THEN
           fnd_message.set_name('IGS','IGS_FI_INVALID_PERSON_ID');
           p_message_name := 'IGS_FI_INVALID_PERSON_ID';
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           CLOSE c_person;
           RETURN FALSE;
          END IF;
          CLOSE c_person;
   ELSIF (p_person_id IS NULL AND p_person_id_group IS NOT NULL) THEN

-- Exit if the passed person group id is not valid
         OPEN c_person_group_id;
         FETCH c_person_group_id INTO l_person_group_id_rec;
         IF c_person_group_id%NOTFOUND  THEN
           fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
           fnd_message.set_token('PARAMETER','P_PERSON_ID_GROUP');
           p_message_name := 'IGS_GE_INVALID_VALUE';
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           CLOSE c_person_group_id;
            RETURN FALSE;
         END IF;
         CLOSE c_person_group_id;
   END IF;
--To check for hold plan name validity
  IF  p_hold_plan_name IS NOT NULL  THEN
     OPEN c_hold_plan_name;
     FETCH c_hold_plan_name INTO l_hold_plan_name_rec;
     IF c_hold_plan_name%NOTFOUND THEN
             fnd_message.set_name('IGS','IGS_FI_INVALID_HP');
             p_message_name :=  'IGS_FI_INVALID_HP';
             fnd_file.put_line(fnd_file.log,fnd_message.get());
             fnd_file.put_line(fnd_file.log,' ');
             CLOSE c_hold_plan_name;
             RETURN FALSE;
     END IF;
     CLOSE c_hold_plan_name;
  END IF;

--IF all the validations get passed then return TRUE BACK to the main procedure
         p_message_name := NULL;
         RETURN TRUE;

EXCEPTION

    WHEN OTHERS THEN
     p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
     ROLLBACK;
     RAISE;
END validate_param;



FUNCTION   validate_holds( p_person_id          IN          igs_pe_person.person_id%TYPE,
                           P_hold_plan_name     IN          igs_fi_hold_plan.hold_plan_name%TYPE,
                           P_test_run           IN          VARCHAR2 ,
                           P_release            OUT NOCOPY  PLS_INTEGER,
                           P_message_name       OUT NOCOPY  fnd_new_messages.message_name%TYPE,
                           p_release_credit_id  IN          igs_fi_person_holds.release_credit_id%TYPE  := NULL,
                           p_hold_plan_level    IN          igs_fi_hold_plan.hold_plan_level%TYPE  := NULL
                         ) RETURN BOOLEAN IS
 /***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              :   To find out the hold types to be relaesed for the passed person id
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who          When            What
   sapanigr   10-Oct-2005   Bug 3049184. New message in log file added for case when Holds have not been released as balance amount is greater than the threshold amount
   shtatiko   17-OCT-2003   Bug# 3192641, Added code to consider charges that are waived when calculating Holds Balance.
   smadathi   28-Aug-2003   Enh Bug 3045007.
   pathipat   12-Aug-2003   Enh 3076768 - Auto Release of Holds. Modification as per TD
                            Added two IN params - p_release_credit_id and p_hold_plan_level
                            Modified cursor c_hold_type - added join with igs_fi_hold_plan, removed trunc for start and end dates
                            Removed cursor c_hold_plan, modified TBH calls to igs_fi_person_holds
   vvutukur   05-Mar-2003   Enh#2824994.Modified code such that log file output is not shown in horizontal tabular format, instead it
                            it is shown in linear/logging format.Also used global variables to log the details instead of calling generic function
                            everytime to get the lookup meaning.
   pathipat   26-Feb-2003   Enh:2747341 - Additional Security for Holds
                            Replaced call to igs_pe_pers_encumb_pkg.update_row with call to igs_pe_gen_001.release_hold
   ssawhney   17-feb-2003   Bug : 2758856  : Added the parameter x_external_reference in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW

   smadathi    20-dec-2002   Enh. Bug 2566615. Removed  the references of obsoleted table IGS_FI_HOLD_PLN_LNS and
                             incorporated changes suggested as per FICR102 TD
   agairola     03-Dec-2002 Bug No: 2584741 As part of the Deposits Build, modified the cursor c_credit_amount to exclude
                            credits of Credit Class Enrolment Deposit and Other Deposit
   pathipat     04-OCT-2002     Enh Bug: 2562745  -- Removed selection of balance_amount from cursor c_hold_type
                                Added cursor c_bal_amount to obtain holds balance amount from igs_fi_balances
                                Changed type of p_release and l_release_ind to PLS_INTEGER instead of NUMBER
   pkpatel      04-OCT-2002     Bug No: 2600842
                                Added the parameter auth_resp_id in the call to TBH igs_pe_pers_encumb_pkg
   sarakshi     23-sep-2002     Enh#2564643,removed the reference of subaccount from this function as mentioned in the TD
   sykrishn     07-APR-2002     Introduced planned credits functionality as per SFCR018 DLD
                                2293676 - Planned Credits are also considered for release of holds along with
                                the actual credits . (suba account level holds plan)
 ***************************************************************/

CURSOR c_hold_type IS
    SELECT  a.person_id                person_id,
            a.encumbrance_type         encumbrance_type,
            a.start_dt                 start_dt,
            c.rowid                    row_id,
            a.comments                 comments,
            a.expiry_dt                expiry_dt,
            a.authorising_person_id    authorising_person_id,
            a.spo_course_cd            spo_course_cd,
            a.spo_sequence_number      spo_sequence_number,
            a.cal_type                 cal_type,
            a.sequence_number          sequence_number  ,
            c.hold_plan_name           hold_plan_name,
            c.process_start_dt         process_start_dt ,
            c.fee_type_invoice_amount  fee_type_invoice_amount,
            c.fee_ci_sequence_number   fee_ci_sequence_number,
            c.fee_cal_type             fee_cal_type,
            c.hold_type                hold_type,
            a.auth_resp_id             auth_resp_id,
            a.external_reference       external_reference,
            c.hold_start_dt            hold_start_dt,
            c.process_end_dt           process_end_dt,
            c.offset_days              offset_days,
            c.past_due_amount          past_due_amount,
            hplan.hold_plan_level      hold_plan_level,
            hplan.threshold_amount     threshold_amount,
            hplan.threshold_percent    threshold_percent,
            hplan.payment_plan_threshold_amt    payment_plan_threshold_amt  ,
            hplan.payment_plan_threshold_pcent  payment_plan_threshold_pcent,
            c.student_plan_id          student_plan_id,
            c.last_instlmnt_due_date   last_instlmnt_due_date
    FROM    igs_pe_pers_encumb   a,
            igs_fi_person_holds  c,
            igs_fi_hold_plan     hplan
    WHERE   (a.person_id = p_person_id OR p_person_id IS NULL)
    AND     a.start_dt <= TRUNC(SYSDATE)
    AND     (a.expiry_dt IS NULL OR TRUNC(SYSDATE) < a.expiry_dt )
    AND     c.hold_plan_name   = hplan.hold_plan_name
    AND     c.person_id = a.person_id
    AND     c.hold_start_dt =  a.start_dt
    AND     c.hold_type = a.encumbrance_type
    AND     (c.hold_plan_name = p_hold_plan_name  OR p_hold_plan_name is null)
    AND     (hplan.hold_plan_level = p_hold_plan_level OR p_hold_plan_level IS NULL);

CURSOR c_credit_amount(l_process_start_date igs_fi_person_holds.process_start_dt%TYPE ) IS
  SELECT crd.credit_id,
         crd.amount,
         crd.effective_date
  FROM   igs_fi_credits crd,
         igs_fi_cr_types crt
  WHERE TRUNC(crd.effective_date)  between
        (TRUNC(l_process_start_date) + 1 )and  TRUNC(SYSDATE)
  AND crd.status = 'CLEARED'
  AND crd.party_id = p_person_id
  AND crd.credit_type_id = crt.credit_type_id
  AND crt.credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT')
  ORDER BY crd.credit_id;

CURSOR  c_igs_fi_hold_plan(cp_c_hold_plan_name  igs_fi_hold_plan.hold_plan_name%TYPE) IS
SELECT  fee_type
FROM    igs_fi_hold_plan fhpl
WHERE   fhpl.hold_plan_name = cp_c_hold_plan_name;

l_c_fee_type  igs_fi_fee_type_all.fee_type%TYPE;

CURSOR c_total_balance(l_fee_cal_type           igs_fi_person_holds.fee_cal_type%TYPE,
                       l_fee_ci_sequence_number igs_fi_person_holds.fee_ci_sequence_number%TYPE,
                       l_process_start_dt       igs_fi_person_holds.process_start_dt%TYPE,
                       cp_c_fee_type            igs_fi_fee_type_all.fee_type%TYPE
                       )   IS
  SELECT invoice_id,
         invoice_amount_due,
         invoice_creation_date,
         fee_type
  FROM   igs_fi_inv_int inv
  WHERE  fee_type     = cp_c_fee_type
  AND    fee_cal_type = l_fee_cal_type
  AND    fee_ci_sequence_number = l_fee_ci_sequence_number
  AND    TRUNC(invoice_creation_date) <= TRUNC(l_process_start_dt)
  AND    person_id = p_person_id
  AND    NVL(invoice_amount_due,0) > 0
  AND    NOT EXISTS (  SELECT 'X'
                       FROM igs_fi_inv_wav_det
                       WHERE invoice_id = inv.invoice_id
                       AND balance_type = 'HOLDS'
                       AND ( (TRUNC(end_dt) IS NOT NULL AND TRUNC(SYSDATE) BETWEEN  TRUNC(start_dt) AND TRUNC(end_dt))
                                     OR
                             (TRUNC(SYSDATE) >= TRUNC(start_dt) AND  TRUNC(end_dt) IS NULL)
                           )
                    );

-- Get the balance amount from igs_fi_balances instead of from igs_fi_person_holds
-- where the column balance_amount is getting obsoleted.
CURSOR c_bal_amount (cp_person_id         igs_pe_pers_encumb.person_id%TYPE,
                     cp_process_start_dt  igs_fi_person_holds.process_start_dt%TYPE)  IS
  SELECT holds_balance
  FROM   igs_fi_balances
  WHERE  party_id = cp_person_id
  AND    holds_balance IS NOT NULL
  AND    TRUNC(balance_date) <= TRUNC(cp_process_start_dt)
  ORDER BY balance_date DESC;

  CURSOR c_igs_fi_pp_instlmnts ( cp_n_student_plan_id igs_fi_pp_std_attrs.student_plan_id%TYPE,
                                 cp_d_inst_due_date   igs_fi_pp_instlmnts.due_date%TYPE
                               ) IS
  SELECT SUM(installment_amt) installment_amt,
         SUM(due_amt)         due_amt
  FROM   igs_fi_pp_instlmnts
  WHERE  student_plan_id = cp_n_student_plan_id
  AND    due_date        <= cp_d_inst_due_date;

  rec_c_igs_fi_pp_instlmnts c_igs_fi_pp_instlmnts%ROWTYPE;

  -- Cursor to get the total amount of waived charges
  -- Added as part of Bug# 3192641
  CURSOR c_waive_amount( cp_n_person_id NUMBER, cp_d_process_start_date DATE) IS
    SELECT NVL(SUM(chg.invoice_amount), 0)
    FROM igs_fi_inv_int_all chg,
         igs_fi_inv_wav_det wav
    WHERE person_id = cp_n_person_id
    AND chg.invoice_id = wav.invoice_id
    AND wav.balance_type = 'HOLDS'
    AND cp_d_process_start_date BETWEEN TRUNC(start_dt) AND NVL(TRUNC(end_dt), cp_d_process_start_date);
  l_n_waive_amount NUMBER;


 l_hold_type_rec        c_hold_type%ROWTYPE;
 l_credit_amount_rec    c_credit_amount%ROWTYPE;
 l_total_balance_rec    c_total_balance%ROWTYPE;
 l_hold_plan_name       igs_fi_hold_plan.hold_plan_name%TYPE;
 l_message_name         fnd_new_messages.message_name%TYPE := NULL;
 l_tot_amnt_all_subact  igs_fi_credits.amount%TYPE := 0;
 l_non_ex_amnt_each_sc  igs_fi_credits.amount%TYPE := 0;
 l_total_charges        igs_fi_balances.holds_balance%TYPE := 0.0;
 l_final_balance_amnt   igs_fi_balances.holds_balance%TYPE := 0.0;
 l_release_hold         VARCHAR2(2)  :='Y';
 l_msg_str_0            VARCHAR2(1000) :=NULL;
 l_msg_str_1            VARCHAR2(1000) :=NULL;
 l_release_ind          PLS_INTEGER := 0;
 l_srl_no               NUMBER := 0;
 l_tot_hold_type_rec    NUMBER := 0;
 l_count                PLS_INTEGER := 0;

 l_hold_bal_amt         igs_fi_balances.holds_balance%TYPE := 0.0;

 -- Changes due to SFCR018
  l_v_pln_cr_ind igs_fi_control_all.planned_credits_ind%TYPE := get_planned_credits_ind;
  l_v_pln_cr_message fnd_new_messages.message_name%TYPE :=NULL;
  l_n_planned_credit igs_fi_credits.amount%TYPE;
-- Changes due to SFCR018

  l_c_message_name      fnd_new_messages.message_name%TYPE := NULL;
  l_n_threshold_amount  igs_fi_hold_plan.threshold_amount%TYPE    ;
  l_n_threshold_percent igs_fi_hold_plan.threshold_percent%TYPE   ;
--Boolean variable added for Bug 3049184
  l_b_ret_amt_grt_msg_flag BOOLEAN ;
BEGIN
 l_b_ret_amt_grt_msg_flag := FALSE;
 p_message_name := NULL;
 p_release := 0;

        --to check get the active (open ended) hold types which are of hold category 'ADMIN'
        OPEN c_hold_type;
        LOOP
          FETCH c_hold_type INTO l_hold_type_rec;
        --1
          IF   c_hold_type%NOTFOUND AND c_hold_type%ROWCOUNT = 0 THEN
            IF p_test_run = 'Y' THEN
              fnd_message.set_name('IGS','IGS_FI_NO_ACT_HOLDS');
              fnd_file.put_line(fnd_file.log,fnd_message.get());
            END IF;
            p_message_name := 'IGS_FI_NO_ACT_HOLDS';
            CLOSE c_hold_type;
            RETURN FALSE;
          ELSE
        --1
            BEGIN
              EXIT WHEN c_hold_type%NOTFOUND;
              --to find out if the particular hold type was applied by the student finance holds apply process.
              --2
              IF p_hold_plan_name IS NULL THEN
              --to set the hold_name parameter value if it is passed as NULL
                l_hold_plan_name :=  l_hold_type_rec.hold_plan_name;
              --2
              ELSE
                l_hold_plan_name :=  p_hold_plan_name;
              END IF;
              --Get the corresponding threshold amount, threshold percent, level for the particular hold plan
--3
              -- Assign the default threshold_amount and  threshold_percent to variables
              l_n_threshold_amount  := l_hold_type_rec.threshold_amount;
              l_n_threshold_percent := l_hold_type_rec.threshold_percent;

              IF l_hold_type_rec.hold_plan_level = 'S' THEN
                --Processing logic if hold_level = 'S'
                -- balance_amount is obtained from igs_fi_balances, not person_holds
                IF l_hold_type_rec.student_plan_id IS NOT NULL THEN

                  -- if payment plan threshold amount is provided, assign the
                  -- the c_hold_type select value to the variable
                  IF l_hold_type_rec.payment_plan_threshold_amt IS NOT NULL THEN
                    l_n_threshold_amount  := l_hold_type_rec.payment_plan_threshold_amt;
                    l_n_threshold_percent := NULL;
                  END IF;
                  -- if payment plan threshold percent is provided, assign the
                  -- the c_hold_type select value to the variable
                  IF  l_hold_type_rec.payment_plan_threshold_pcent IS NOT NULL THEN
                    l_n_threshold_percent := l_hold_type_rec.payment_plan_threshold_pcent;
                    l_n_threshold_amount  := NULL;
                  END IF;
                  OPEN  c_igs_fi_pp_instlmnts(l_hold_type_rec.student_plan_id,
                                              l_hold_type_rec.last_instlmnt_due_date
                                              );
                  FETCH c_igs_fi_pp_instlmnts INTO rec_c_igs_fi_pp_instlmnts;
                  CLOSE c_igs_fi_pp_instlmnts;
                  l_total_charges       := rec_c_igs_fi_pp_instlmnts.installment_amt;
                  l_final_balance_amnt  := rec_c_igs_fi_pp_instlmnts.due_amt;
                ELSE

                  OPEN c_bal_amount(l_hold_type_rec.person_id, l_hold_type_rec.process_start_dt);
                  FETCH c_bal_amount INTO l_hold_bal_amt;
                  l_total_charges  := NVL(l_hold_bal_amt,0.0);
                  CLOSE c_bal_amount;
                  -- Get the total waived amount.
                  OPEN c_waive_amount( p_person_id, TRUNC(l_hold_type_rec.process_start_dt));
                  FETCH c_waive_amount INTO l_n_waive_amount;
                  CLOSE c_waive_amount;

                  l_total_charges := l_total_charges - l_n_waive_amount;

                  --loop across the table IGS_FI_CREDITS to get the amount for the person_id with the effective_date between the date range
                  OPEN c_credit_amount(l_hold_type_rec.process_start_dt);
                  LOOP
                    FETCH c_credit_amount INTO l_credit_amount_rec;
                    EXIT WHEN c_credit_amount%NOTFOUND;

                    --  Each of the above credit record is checked for exclusion rules by calling the common function for exclusion
                    --  Use a local variable to sum up the non-excluded credits of the person
--5
                    l_message_name := NULL;
                    IF NOT igs_fi_prc_balances.check_exclusion_rules (p_balance_type    => 'HOLDS',
                                                                      P_source_type     => 'CREDIT',
                                                                      P_balance_date    => TRUNC(l_credit_amount_rec.effective_date),
                                                                      P_source_id       => l_credit_amount_rec.credit_id,
                                                                      p_balance_rule_id => l_balance_rule_id,
                                                                      p_message_name    => l_message_name)   THEN
                      IF l_message_name IS NULL THEN
                        --A local variable to sum up the non-excluded credits  of the person for the credit id.
                        l_non_ex_amnt_each_sc:= l_non_ex_amnt_each_sc + NVL(l_credit_amount_rec.amount,0);
                      ELSIF l_message_name IS NOT NULL THEN
                        --Log the eror message in the log when message is returned with FALSE
                        IF  p_test_run = 'Y' THEN
                          fnd_message.set_name('IGS',l_message_name);
                          fnd_file.put_line(fnd_file.log,fnd_message.get());
                          fnd_file.put_line(fnd_file.log,' ');
                        END IF;
                      END IF;
                    END IF;
--5
                  END LOOP;
                  CLOSE c_credit_amount;
--4
                  --another local variable at the end of this loop across the IGS_FI_CREDITS to sum up the total non-excluded credits defined for the hold plan.
                  l_tot_amnt_all_subact  :=   l_tot_amnt_all_subact  + l_non_ex_amnt_each_sc;

                  -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'
                  IF l_v_pln_cr_ind = 'Y' THEN
                    --Call the generic function to get the total planned credits for the params passed.
                    l_n_planned_credit := igs_fi_gen_001.finp_get_total_planned_credits(
                                                                p_person_id => p_person_id,
                                                                p_start_date => NULL,
                                                                p_end_date => SYSDATE,
                                                                p_message_name  => l_v_pln_cr_message);
                    IF l_v_pln_cr_message IS NOT NULL THEN
                      -- Log messages in the log file only if invoked from concurrent process
                      -- Messages should not be logged if called for Automatic release of holds
                      IF p_release_credit_id IS NULL THEN
                        fnd_message.set_name('IGS',l_v_pln_cr_message);
                        fnd_file.put_line(fnd_file.log,fnd_message.get());
                        fnd_file.put_line(fnd_file.log,' ');
                      END IF;
                      RAISE skip;
                    END IF;
                    -- When no errors sum up the planned credits also with the actual credits
                    l_tot_amnt_all_subact := l_tot_amnt_all_subact + NVL(l_n_planned_credit,0);
                  END IF;
                  -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'


                  --to calculate the final balance that will be used for validating whether the particular hold type placed on the person can be released or not
                  l_final_balance_amnt  :=  l_total_charges - l_tot_amnt_all_subact ;
--3
                END IF;
              ELSIF l_hold_type_rec.hold_plan_level = 'F' THEN

                   OPEN   c_igs_fi_hold_plan(l_hold_plan_name);
                   FETCH  c_igs_fi_hold_plan INTO l_c_fee_type;
                   CLOSE  c_igs_fi_hold_plan;
--fetched fee_type_invoice_amount that stores the value of charges as on the process_start_date when the Holds application process ran and placed a hold on the student.
                           l_total_charges := l_hold_type_rec.fee_type_invoice_amount ;
--get the outstanding balance for the particular student for the fee types defined in the hold plan in the fee period from the intermediate table IGS_FI_PERSON_HOLDS
                            OPEN c_total_balance(l_hold_type_rec.fee_cal_type ,
                                                 l_hold_type_rec.fee_ci_sequence_number,
                                                 l_hold_type_rec.process_start_dt,
                                                 l_c_fee_type
                                                 );
                            LOOP
                            FETCH c_total_balance INTO l_total_balance_rec;
                            EXIT when c_total_balance%NOTFOUND ;
--6
                                      l_message_name := NULL;
                                      IF NOT igs_fi_prc_balances.check_exclusion_rules ( p_balance_type    => 'HOLDS',
                                                                                         P_source_type     => 'CHARGE',
                                                                                         P_balance_date    => TRUNC(l_total_balance_rec.invoice_creation_date),
                                                                                         P_source_id       => l_total_balance_rec.invoice_id ,
                                                                                         p_balance_rule_id => l_balance_rule_id,
                                                                                         P_message_name    => l_message_name) THEN

                                      IF l_message_name IS NULL THEN
--A local variable to sum up the non-excluded charges of the person for the invoiceid.
                                          l_final_balance_amnt  :=  NVL(l_final_balance_amnt,0) + NVL(l_total_balance_rec.invoice_amount_due,0);
                                      ELSIF l_message_name IS NOT NULL THEN
--Log the eror message in the log when message is returned with FALSE
                                         IF  p_test_run = 'Y' THEN
                                             fnd_message.set_name('IGS',l_message_name);
                                             fnd_file.put_line(fnd_file.log,fnd_message.get());
                                             fnd_file.put_line(fnd_file.log,' ');
                                         END IF;
                                      END IF;

                                  END IF;
--6
                            END LOOP;
                            CLOSE c_total_balance;
--3
                 END IF;
-- logic to see if the particular hold type can be released for the person.
--When threshold_amount is specified
                      IF  l_n_threshold_amount IS NOT NULL THEN
--7
                         IF l_final_balance_amnt   <=  l_n_threshold_amount  THEN
-- If the threshold amount is less THEN equal to the threshold_percent then mark the particular hold_type as releasable for that person.
                            l_release_hold := 'Y';
                         ELSE
                            l_release_hold := 'N';
                            --Code added for Bug 3049184
                            l_b_ret_amt_grt_msg_flag  := TRUE;
                            END IF;
--7
                      ELSIF l_n_threshold_percent IS NOT NULL THEN
--When threshold percent is specified
--8
                        IF ((l_final_balance_amnt /l_total_charges)*100)  <=  l_n_threshold_percent THEN
-- If this ratio R is less THEN equal to the threshold_percent then mark the particular hold_type as releasable for that person.
                            l_release_hold := 'Y';
                        ELSE
                            l_release_hold := 'N';
                            --Code added for Bug 3049184
                            l_b_ret_amt_grt_msg_flag  := TRUE;
                            END IF;
--8
                      END IF;
--9
                  IF  l_release_hold = 'Y' AND p_test_run = 'Y' THEN
                                 l_release_ind := NVL(l_release_ind,0) + 1;
                                 -- Assigning of l_release_ind to out parameter p_release
                                 -- was added as part of FICR102 Build.
                                 p_release     := l_release_ind ;
                                 IF l_release_ind = 1 THEN
                                           fnd_message.set_name('IGS','IGS_FI_HOLDS_RLS');
                                           fnd_file.put_line(fnd_file.log,fnd_message.get());
                                           fnd_file.put_line(fnd_file.log,' ');
                                 END IF;
                               OPEN c_person(p_person_id);
                               FETCH c_person  INTO l_person_rec;
--To print indvidual person logs repeated for each record
                               fnd_file.put_line(fnd_file.log,g_v_person_number ||' : '||l_person_rec.person_number);
                               fnd_file.put_line(fnd_file.log,g_v_person_name   ||' : '||l_person_rec.full_name);
                               fnd_file.put_line(fnd_file.log,g_v_hold_plan     ||' : '||l_hold_type_rec.hold_plan_name);
                               fnd_file.put_line(fnd_file.log,g_n_holds_bal     ||' : '||TO_CHAR(l_total_charges));
                               fnd_file.put_line(fnd_file.log,g_n_overdue_bal   ||' : '||TO_CHAR(l_final_balance_amnt));
                               fnd_file.put_line(fnd_file.log,g_v_hold_type     ||' : '||l_hold_type_rec.hold_type);
                               fnd_file.put_line(fnd_file.log,' ');
                               CLOSE c_person;

                  ELSIF  l_release_hold = 'Y' AND p_test_run = 'N' THEN

--Validate expiry date is not less THEN current date
--10
                     l_message_name := NULL ;
                     IF NOT igs_en_val_pce.enrp_val_encmb_dt (TRUNC(SYSDATE),l_message_name) THEN
--If this function returns false then log error,skip this record and move to next hold type
                        -- Log messages in the log file only if invoked from concurrent process
                        -- Messages should not be logged if called for Automatic release of holds
                        IF p_release_credit_id IS NULL THEN
                           fnd_message.set_name('IGS','IGS_EN_DT_NOT_LT_CURR_DT');
                           fnd_file.put_line(fnd_file.log,fnd_message.get());
                           fnd_file.put_line(fnd_file.log,' ');
                        END IF;

--To set the message for the form
                         p_message_name := 'IGS_FI_HOLD_NOT_RELSD';
                         RAISE skip;
                     END IF;
--10
--Validate expiry date is greater THEN start date.
--11
                       l_message_name := NULL ;
                       IF NOT IGS_EN_VAL_PCE.enrp_val_strt_exp_dt (TRUNC(l_hold_type_rec.start_dt),TRUNC(SYSDATE),l_message_name)  THEN
--If this function returns false then log error,skip this record and move to next hold type
                           -- Log messages in the log file only if invoked from concurrent process
                           -- Messages should not be logged if called for Automatic release of holds
                           IF p_release_credit_id IS NULL THEN
                              fnd_message.set_name('IGS','IGS_EN_EXPDT_GE_STDT');
                              fnd_file.put_line(fnd_file.log,fnd_message.get());
                              fnd_file.put_line(fnd_file.log,' ');
                           END IF;

--To set the message for the form
                           p_message_name := 'IGS_FI_HOLD_NOT_RELSD';
                           RAISE skip;
                       END IF;
--11

                       -- Call procedure to validate if person logged in as user has authority to release the hold
                       -- Part of Auto Release of Holds build - Passed null to resp_id and fnd_user_id, 'X' to override_resp
                       -- Validation for Staff should not happen for releasing holds
                       BEGIN
                           igs_pe_gen_001.release_hold( p_resp_id           => NULL,
                                                        p_fnd_user_id       => NULL,
                                                        p_person_id         => l_hold_type_rec.person_id,
                                                        p_encumbrance_type  => l_hold_type_rec.encumbrance_type,
                                                        p_start_dt          => l_hold_type_rec.start_dt,
                                                        p_expiry_dt         => TRUNC(SYSDATE),
                                                        p_override_resp     => 'X',
                                                        p_message_name      => l_c_message_name
                                                      );
                           -- The above procedure does not return any message_name but the OUT parameter is
                           -- still specified. So the following piece of code is present in case the out parameter
                           -- is used in future, does not hold any purpose as of now.
                           IF l_c_message_name IS NOT NULL THEN
                              -- Log messages in the log file only if invoked from concurrent process
                              -- Messages should not be logged if called for Automatic release of holds
                              IF p_release_credit_id IS NULL THEN
                                 fnd_message.set_name('IGS',l_c_message_name);
                                 fnd_file.put_line(fnd_file.log,fnd_message.get());
                                 fnd_file.put_line(fnd_file.log,' ');
                              END IF;
                              app_exception.raise_exception;
                           END IF;

                           -- Update the value of Release Credit Id in the Holds table if releasing of hold was successful
                           -- Added as part of Automatic Release of Holds build
                           -- The Credit Id which caused the hold to be released will be the release_credit_id
                           igs_fi_person_holds_pkg.update_row ( x_rowid                   => l_hold_type_rec.row_id,
                                                                x_person_id               => l_hold_type_rec.person_id,
                                                                x_hold_plan_name          => l_hold_type_rec.hold_plan_name,
                                                                x_hold_type               => l_hold_type_rec.hold_type,
                                                                x_hold_start_dt           => l_hold_type_rec.hold_start_dt,
                                                                x_process_start_dt        => l_hold_type_rec.process_start_dt,
                                                                x_process_end_dt          => l_hold_type_rec.process_end_dt,
                                                                x_offset_days             => l_hold_type_rec.offset_days,
                                                                x_past_due_amount         => l_hold_type_rec.past_due_amount,
                                                                x_fee_cal_type            => l_hold_type_rec.fee_cal_type,
                                                                x_fee_ci_sequence_number  => l_hold_type_rec.fee_ci_sequence_number,
                                                                x_fee_type_invoice_amount => l_hold_type_rec.fee_type_invoice_amount,
                                                                x_mode                    => 'R',
                                                                x_release_credit_id       => p_release_credit_id ,
                                                                x_student_plan_id         => l_hold_type_rec.student_plan_id,
                                                                x_last_instlmnt_due_date  => l_hold_type_rec.last_instlmnt_due_date
                                                              );


                       EXCEPTION
                         -- The procedure called above always raises an exception when some validation fails.
                         -- We continue with the next hold for the person in case an exception occurs.
                         WHEN OTHERS THEN
                           -- Even if one hold is skipped, the process should end with a Warning status
                           -- g_b_hold_skipped is made TRUE if a hold is skipped, and process continues for next hold
                           g_b_hold_skipped := TRUE;

                           -- Log messages in the log file only if invoked from concurrent process
                           -- Messages should not be logged if called for Automatic release of holds
                           IF p_release_credit_id IS NULL THEN
                              fnd_file.put_line(fnd_file.log,fnd_message.get());
                              fnd_file.put_line(fnd_file.log,' ');
                           END IF;
                           RAISE skip;
                       END;

                          l_release_ind := l_release_ind + 1;
                          p_release := l_release_ind ;
                           IF l_release_ind = 1 THEN
                               -- Log messages in the log file only if invoked from concurrent process
                               -- Messages should not be logged if called for Automatic release of holds
                               IF p_release_credit_id IS NULL THEN
                                  fnd_message.set_name('IGS','IGS_FI_HLDS_HV_RLS');
                                  fnd_file.put_line(fnd_file.log,fnd_message.get());
                                  fnd_file.put_line(fnd_file.log,' ');
                               END IF;
                           END IF;
                           OPEN c_person(p_person_id);
                           FETCH c_person  INTO l_person_rec;

                           -- Log messages in the log file only if invoked from concurrent process
                           -- Messages should not be logged if called for Automatic release of holds
                           IF p_release_credit_id IS NULL THEN
                             --To print indvidual person logs repeated for each record
                             fnd_file.put_line(fnd_file.log,g_v_person_number ||' : '||l_person_rec.person_number);
                             fnd_file.put_line(fnd_file.log,g_v_person_name   ||' : '||l_person_rec.full_name);
                             fnd_file.put_line(fnd_file.log,g_v_hold_plan     ||' : '||l_hold_type_rec.hold_plan_name);
                             fnd_file.put_line(fnd_file.log,g_n_holds_bal     ||' : '||TO_CHAR(l_total_charges));
                             fnd_file.put_line(fnd_file.log,g_n_overdue_bal   ||' : '||TO_CHAR(l_final_balance_amnt));
                             fnd_file.put_line(fnd_file.log,g_v_hold_type     ||' : '||l_hold_type_rec.hold_type);
                             fnd_file.put_line(fnd_file.log,' ');
                           END IF;
                     CLOSE c_person;

                 END IF;
--9
 EXCEPTION
       WHEN skip THEN
          Null;
       WHEN OTHERS THEN
         ROLLBACK;
          p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
         RAISE;
     END;
  END IF;
--1
END LOOP;
CLOSE c_hold_type;

--Code added for Bug 3049184
IF l_b_ret_amt_grt_msg_flag=TRUE AND p_test_run='Y' THEN
     fnd_message.set_name('IGS','IGS_FI_BAL_AMT_GT_THRS_AMT');
     fnd_file.put_line(fnd_file.log,fnd_message.get());
END IF;

RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
 p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
RAISE;
END validate_holds;


PROCEDURE finp_release_holds_main(p_person_id          IN     igs_pe_person.person_id%TYPE           ,
                                  p_person_id_group    IN     igs_pe_persid_group_v.group_id%TYPE    ,
                                  P_hold_plan_name     IN     Igs_fi_hold_plan.hold_plan_name%TYPE   ,
                                  P_test_run           IN     VARCHAR2 ,
                                  P_message_name       OUT NOCOPY    fnd_new_messages.message_name%TYPE)
 IS
 /***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              :   To will carry out the  release of holds applied on a person / all persons /
                  group of students by student finance
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   sapanigr             10-Oct-2005     Bug 3049184 - Modified log file layout.
   pathipat             18-Aug-2003     Enh 3076768 - Automatic Release of Holds
                                        Modified cursor c_person_hold to remove DISTINCT clause
   pathipat             23-Jun-2003     Bug: 3018104 - Impact of changes in person id group views
                                        Modified cursor c_person_group - replaced igs_pe_prsid_grp_mem_v
                                        with igs_pe_prsid_grp_mem
   pathipat             05-May-2003     Enh 2831569 - Commercial Receivables Build
                                        Added check for manage_accounts - call to igs_fi_com_rec_interface.check_manage_acc()
   pathipat             26-Feb-2003     Enh 2747341 - Additional Security for Holds
                                        Added code to keep count of total number of records fetched apart from
                                        count of records processed (code involving l_n_total_count)
   SYKRISHn    03-JAN-2002              Bug 2684895 --Procedure finp_apply_holds
                                        Logging Person Group Cd instead of person group id.
                                        used igs_fi_gen_005.finp_get_prsid_grp_code
   pathipat             04-OCT-2002     Enh Bug: 2562745, added check that if the holds conversion process is running
                                        then the holds release process cannot happen simultaneously.
 ***************************************************************/

 --As this procedure is being called from forms and as concurrent process also So
 --while calling this procedure from forms proper exception handeling in PLL is neccessary .For concurrent process
 --exception handeling has been done in wrapper procedure.

 CURSOR c_person_group IS
    SELECT  person_id
                FROM   igs_pe_prsid_grp_mem
                WHERE (TRUNC(end_date) IS NULL OR TRUNC(end_date) >= TRUNC(SYSDATE))
                AND group_id = p_person_id_group;

 CURSOR c_person_hold IS
    SELECT person_id, person_number
    FROM  igs_pe_person_base_v per
    WHERE EXISTS ( SELECT '1'
                   FROM igs_fi_person_holds hold
                   WHERE hold.person_id = per.person_id);

 l_person_group_rec       c_person_group%ROWTYPE;
 l_person_hold_rec        c_person_hold%ROWTYPE;
 l_person_number          igs_pe_person.person_number%TYPE :=NULL;
 l_start_date             igs_pe_pers_encumb.start_dt%TYPE;
 l_passed_hold_type       igs_fi_person_holds.hold_type%TYPE ;
 l_hold_plan_name         igs_fi_hold_plan.hold_plan_name%TYPE :=NULL;
 l_message_name           fnd_new_messages.message_name%TYPE :=NULL;
 l_message_name_1         fnd_new_messages.message_name%TYPE :=NULL;
 l_release_hold           VARCHAR2(10) :='Y';
 l_release                NUMBER :=0;
 l_msg_str_0              VARCHAR2(1000);
 l_msg_str_1              VARCHAR2(1000);
 l_count                  PLS_INTEGER :=0;

 l_process_run_ind        igs_fi_control_all.conv_process_run_ind%TYPE;
 l_last_conv_dt           igs_fi_balance_rules.last_conversion_date%TYPE;
 l_version_number         igs_fi_balance_rules.version_number%TYPE;

 l_n_total_count          PLS_INTEGER := 0;

 l_v_manage_acc      igs_fi_control_all.manage_accounts%TYPE  := NULL;
 l_v_message_name    fnd_new_messages.message_name%TYPE       := NULL;
 l_v_line_sepr            VARCHAR2(1000) := '+-----------------------------------------------------------------------+';

BEGIN
      p_message_name := NULL;
      l_hold_plan_name := p_hold_plan_name;
      --To get the passed person id if not NULL corresponding person number
      IF p_person_id IS NOT NULL THEN
                    OPEN c_person(p_person_id);
                    FETCH c_person INTO l_person_rec;
                      l_person_number := l_person_rec.person_number;
                    CLOSE c_person;
      END IF;

      --TO display passed parameter values in the log
      fnd_message.set_name('IGS','IGS_FI_RELEASE_HOLD_PARAM');

      fnd_message.set_token('PERSON_NUMBER',l_person_number);
      fnd_message.set_token('PERSON_GROUP_ID',igs_fi_gen_005.finp_get_prsid_grp_code(p_person_id_group));
      fnd_message.set_token('HOLD_PLAN_NAME',p_hold_plan_name);
      fnd_message.set_token('TEST_RUN',p_test_run);

      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.put_line(fnd_file.log,' ');

      -- Obtain the value of manage_accounts in the System Options form
      -- If it is null or 'OTHER', then this process is not available, so error out.
      igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                   p_v_message_name => l_v_message_name
                                                );
      IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
          fnd_message.set_name('IGS',l_v_message_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get());
          fnd_file.new_line(fnd_file.log);
          p_message_name := l_v_message_name;
          RETURN;
      END IF;

      -- if the holds conversion process is running (conv_process_run_ind of the control_all table
      -- will be 1 if the process is running), then error out. Else continue.
      igs_fi_gen_007.finp_get_conv_prc_run_ind( p_n_conv_process_run_ind  => l_process_run_ind,
                                                p_v_message_name          => l_message_name_1) ;

      IF l_message_name_1 IS NOT NULL THEN
           fnd_message.set_name('IGS',l_message_name_1);
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           -- pass message name to calling proc
           p_message_name := l_message_name_1;
           RETURN;
      END IF;

      IF l_process_run_ind = 1 THEN
           -- Stop further processing as the conversion process is running
           fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(fnd_file.log,' ');
           -- pass message name to calling proc
           p_message_name := 'IGS_FI_REASS_BAL_PRC_RUN';
           RETURN;
      END IF;

      igs_fi_gen_007.finp_get_balance_rule ( p_v_balance_type          => 'HOLDS',
                                       p_v_action                => 'ACTIVE',
                                       p_n_balance_rule_id       => l_balance_rule_id,
                                       p_d_last_conversion_date  => l_last_conv_dt,
                                       p_n_version_number        => l_version_number);

      --function to validate the input parameters .In this if any of the validation fails appropriate errors are logged
      --proceessing does not take palce further.
      --To check only for TRUE condition as for FALSE the further execution has not to be done and error message has been logged earlier in validate_param
       --1
       l_message_name := NULL ;
       IF  validate_param( p_person_id,
                           p_person_id_group,
                           p_hold_plan_name,
                           l_message_name) THEN
               --2
               IF p_person_id IS NOT NULL THEN
                    l_message_name := NULL;
                    --Code added for Bug 3049184
                    fnd_file.put_line(fnd_file.log,l_v_line_sepr);
                    fnd_message.set_name('IGS','IGS_FI_END_DATE');
                    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','PERSON_NUMBER')||': '|| l_person_number);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);

                    --Function to check whether holds has to be released
                    IF NOT validate_holds(p_person_id,
                                          l_hold_plan_name,
                                          P_test_run,
                                          l_release,
                                          l_message_name,
                                          NULL,
                                          NULL)  THEN
                         --TO display the message in form
                         IF l_release = 0 AND l_message_name IS NULL THEN
                              p_message_name := 'IGS_FI_HOLD_NOT_RELSD';
                         ELSE
                              p_message_name := l_message_name;
                         END IF;
                         fnd_message.set_name('IGS','IGS_FI_HLD_PERSON_NOT_RELSD');
                         fnd_message.set_token('PERSON',l_person_number);
                         fnd_file.put_line(fnd_file.log,fnd_message.get());
                         RETURN;
                    ELSE
                         --This is to display the correct message back to the form
                         IF l_release > 0   AND l_message_name IS NOT NULL THEN
                              p_message_name := l_message_name;
                         ELSIF l_release > 0 AND  l_message_name IS NULL THEN
                              p_message_name := 'IGS_FI_HOLD_RELSD';
                         ELSIF l_release = 0 AND l_message_name IS NULL THEN
                              p_message_name := 'IGS_FI_HOLD_NOT_RELSD';
                         END IF;
                         --To set the indicator to count the number of persons on whom hold has been released
                         IF l_release > 0 THEN
                              l_count := l_count +1;
                         ELSIF l_release = 0 THEN
                               IF p_test_run = 'Y' THEN
                                     fnd_message.set_name('IGS','IGS_FI_HLD_PERSON_NOT_RELSD');
                                     fnd_message.set_token('PERSON',l_person_number);
                                     fnd_file.put_line(fnd_file.log,fnd_message.get());
                               END IF;
                         END IF;
                         --Code added for Bug 3049184
                         fnd_file.put_line(fnd_file.log,l_v_line_sepr);
                    END IF;
               --2
               ELSIF p_person_id_group  IS NOT NULL THEN
                    fnd_file.put_line(fnd_file.log,l_v_line_sepr);
                    OPEN c_person_group;
                    LOOP
                        FETCH c_person_group INTO l_person_group_rec;
                        -- To count the total records fetched
                        l_n_total_count := c_person_group%ROWCOUNT;
                        BEGIN
                                  EXIT WHEN c_person_group%NOTFOUND;
                                  --Call a private function for validating the values to apply holds for the person,
                                  --to insert data into holds table and to print the output.
                                  OPEN c_person(l_person_group_rec.person_id);
                                  FETCH c_person INTO l_person_rec;
                                  l_person_number := l_person_rec.person_number;
                                  CLOSE c_person;
                                  --Code added for Bug 3049184
                                  fnd_message.set_name('IGS','IGS_FI_END_DATE');
                                  fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','PERSON_NUMBER')||': '|| l_person_number);
                                  fnd_file.put_line(fnd_file.log,fnd_message.get);

                                  IF NOT validate_holds(l_person_group_rec.person_id,
                                                        l_hold_plan_name,
                                                        P_test_run,
                                                        l_release,
                                                        l_message_name,
                                                        NULL,
                                                        NULL)  THEN
                                         IF p_test_run = 'Y' THEN
                                                fnd_message.set_name('IGS','IGS_FI_HLD_PERSON_NOT_RELSD');
                                                fnd_message.set_token('PERSON',l_person_number);
                                                fnd_file.put_line(fnd_file.log,fnd_message.get());
                                         END IF;
                                         RAISE skip;
                                   ELSE
                                         IF l_release > 0 THEN
                                               l_count := l_count +1;
                                         ELSIF l_release = 0 THEN
                                               IF p_test_run = 'Y' THEN
                                                      fnd_message.set_name('IGS','IGS_FI_HLD_PERSON_NOT_RELSD');
                                                      fnd_message.set_token('PERSON',l_person_number);
                                                      fnd_file.put_line(fnd_file.log,fnd_message.get());
                                               END IF;
                                         END IF;
                                  END IF;   --4
                          EXCEPTION
                             WHEN skip THEN
                                NULL;
                             WHEN OTHERS THEN
                               p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
                               RAISE;
                          END;
                          --Code added for Bug 3049184
                          fnd_file.put_line(fnd_file.log,l_v_line_sepr);
                    END LOOP;
                    CLOSE c_person_group;
               --2
               ELSE
                    --Both person_id and person_group_code are NULL
                    fnd_file.put_line(fnd_file.log,l_v_line_sepr);
                    OPEN  c_person_hold ;
                    LOOP
                        FETCH c_person_hold INTO l_person_hold_rec;
                        -- To count the total records fetched
                        l_n_total_count := c_person_hold%ROWCOUNT;
                        BEGIN
                                 EXIT WHEN c_person_hold%NOTFOUND;
                                 fnd_message.set_name('IGS','IGS_FI_END_DATE');
                                 fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_HOLDS','PERSON_NUMBER')||': '|| l_person_hold_rec.person_number);
                                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                                 IF NOT  validate_holds(l_person_hold_rec.person_id,
                                                        l_hold_plan_name,
                                                        p_test_run,
                                                        l_release,
                                                        l_message_name,
                                                        NULL,
                                                        NULL)  THEN
                                         IF p_test_run = 'Y' THEN
                                                fnd_message.set_name('IGS','IGS_FI_HLD_PERSON_NOT_RELSD');
                                                fnd_message.set_token('PERSON',l_person_hold_rec.person_number);
                                                fnd_file.put_line(fnd_file.log,fnd_message.get());
                                         END IF;
                                         RAISE skip;
                                  ELSE
                                         IF l_release > 0 THEN
                                               l_count := l_count +1;
                                         ELSIF l_release = 0 THEN
                                               IF p_test_run = 'Y' THEN
                                                   fnd_message.set_name('IGS','IGS_FI_HLD_PERSON_NOT_RELSD');
                                                   fnd_message.set_token('PERSON',l_person_hold_rec.person_number);
                                                   fnd_file.put_line(fnd_file.log,fnd_message.get());
                                               END  IF;
                                         END IF;
                                 END IF; --4
                        EXCEPTION
                            WHEN skip THEN
                               NULL;
                            WHEN OTHERS THEN
                              p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
                              RAISE;
                        END;
                        fnd_file.put_line(fnd_file.log,l_v_line_sepr);
                    END LOOP;
                    CLOSE  c_person_hold;
               --2
               END IF;
       --1
       ELSE
            -- If validate_param fails, return to calling proc with error message.
            p_message_name := l_message_name;
            RETURN;
       END IF;


       --to display the count of persons on whom holds is released
       IF p_test_run = 'N'  THEN
              --TO display the message for no active holds if due to some invalid hold plan name or person group passed,
              --the further execution of process does not take place for any person
              IF l_count =0 AND l_message_name = 'IGS_FI_NO_ACT_HOLDS' THEN
                    fnd_message.set_name('IGS','IGS_FI_NO_ACT_HOLDS');
                    fnd_file.put_line(fnd_file.log,fnd_message.get());
              END IF;
              fnd_file.put_line(fnd_file.log,' ');

              -- If holds have not been released for some students, log message
              -- indicating that the release of holds failed for certain students.
              IF (l_n_total_count > l_count) OR (g_b_hold_skipped = TRUE) THEN
                 p_message_name := 'IGS_FI_FEW_HOLDS_REL_ERR';
                 fnd_message.set_name('IGS','IGS_FI_FEW_HOLDS_REL_ERR');
                 -- If only one person was processed, the above message need not be
                 -- shown in the log file.
                 IF l_n_total_count > 1 THEN
                    fnd_file.put_line(fnd_file.log,fnd_message.get());
                    fnd_file.put_line(fnd_file.log,' ');
                 END IF;
              END IF;

              fnd_message.set_name('IGS','IGS_FI_TOTAL_HOLDS_RELEASE');
              fnd_message.set_token('COUNT',l_count);
              fnd_file.put_line(fnd_file.log,fnd_message.get());
       END IF;

        --To commit the data based on the test run parameter value passed to it
        IF (p_test_run = 'N') THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;

EXCEPTION
   WHEN OTHERS THEN
      p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
      RAISE;
END finp_release_holds_main;


PROCEDURE  finp_release_holds(  errbuf                     OUT NOCOPY    VARCHAR2,
                                retcode                    OUT NOCOPY           NUMBER,
                                p_person_id          IN     igs_pe_person.person_id%TYPE       ,
                                p_person_id_group    IN     igs_pe_persid_group_v.group_id%TYPE ,
                                p_hold_plan_name     IN     Igs_fi_hold_plan.hold_plan_name%Type,
                                p_test_run           IN     VARCHAR2)

 IS
 /***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              :   A wrapper procedure around the main process of release of holds from concurrent manager.
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   pathipat             05-May-2003     Enh 2831569 - Commercial Receivables Build
                                        Added check for messages IGS_FI_MANAGE_ACC_NULL and IGS_FI_MANAGE_ACC_OTH
   pathipat             26-Feb-2003     Enh 2747341 - Additional Security for Holds
                                        Added code related to messages IGS_PE_HOLD_AUTH_CR, IGS_GE_NOT_STAFF_MEMBER
                                        and IGS_FI_FEW_HOLDS_REL_ERR
 ***************************************************************/
l_message_name  fnd_new_messages.message_name%TYPE :=NULL;
l_error NUMBER :=0;

BEGIN
--To set the org id
  igs_ge_gen_003.set_org_id(NULL);
  retcode := 0;
  l_message_name := NULL;


 --Invoke the Main Process Release of hol
               finp_release_holds_main (p_person_id,
                                        p_person_id_group,
                                        P_hold_plan_name,
                                        P_test_run,
                                        l_message_name
                                        );
                IF l_message_name in ('IGS_FI_NO_PERS_PGRP',
                                      'IGS_FI_INVALID_PERSON_ID',
                                      'IGS_GE_INVALID_VALUE',
                                      'IGS_FI_INVALID_HP',
                                      'IGS_FI_SYSTEM_OPT_SETUP',
                                      'IGS_FI_REASS_BAL_PRC_RUN',
                                      'IGS_PE_HOLD_AUTH_CR',
                                      'IGS_GE_NOT_STAFF_MEMBER',
                                      'IGS_FI_MANAGE_ACC_NULL',
                                      'IGS_FI_MANAGE_ACC_OTH')     THEN
                     ROLLBACK;
                     retcode :=2;
                     RETURN;
                END IF;

                -- If release of holds failed for certain students, then end the process
                -- with a warning.
                IF l_message_name = 'IGS_FI_FEW_HOLDS_REL_ERR' THEN
                   retcode := 1;
                   RETURN;
                END IF;

EXCEPTION
WHEN OTHERS THEN
     ROLLBACK;
     retcode := 2;
     errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||SUBSTR(sqlerrm,1,40);
     igs_ge_msg_stack.add;
     igs_ge_msg_stack.conc_exception_hndl;
END finp_release_holds;


PROCEDURE finp_auto_release_holds ( p_person_id              IN NUMBER,
                                    p_hold_plan_level        IN VARCHAR2,
                                    p_release_credit_id      IN NUMBER,
                                    p_run_application        IN VARCHAR2,
                                    p_message_name           OUT NOCOPY VARCHAR2
                                   ) IS
 /***************************************************************
   Created By           :   Priya Athipatla
   Date Created By      :   12-Aug-2003
   Purpose              :   Wrapper procedure invoked to release holds
   automatically when a credit is created. Invoked from Credits API or
   from SS pages. Not invoked from concurrent process.
   Created as part of Automatic Release of Holds build Enh 3076768
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
 ***************************************************************/

  -- Cursor to check if the student has any active Balance level
  -- or Fee Type level.
  CURSOR cur_active_holds(cp_person_id         igs_fi_person_holds.person_id%TYPE,
                          cp_hold_plan_level   igs_fi_hold_plan.hold_plan_level%TYPE) IS
    SELECT  'X'
    FROM    igs_pe_pers_encumb   pe_encmb,
            igs_fi_person_holds  fi_holds,
            igs_fi_hold_plan     hplan
    WHERE  pe_encmb.person_id      = p_person_id
    AND    pe_encmb.start_dt       <= TRUNC(SYSDATE)
    AND    (pe_encmb.expiry_dt IS NULL OR TRUNC(SYSDATE) < pe_encmb.expiry_dt)
    AND    fi_holds.person_id      = pe_encmb.person_id
    AND    fi_holds.hold_start_dt  = pe_encmb.start_dt
    AND    fi_holds.hold_type      = pe_encmb.encumbrance_type
    AND    fi_holds.hold_plan_name = hplan.hold_plan_name
    AND    hplan.hold_plan_level   = p_hold_plan_level
    AND    ROWNUM < 2;

  CURSOR cur_credit_number(cp_release_credit_id    igs_fi_person_holds.release_credit_id%TYPE) IS
    SELECT credit_number
    FROM igs_fi_credits_all
    WHERE credit_id = cp_release_credit_id;

    l_rec_active_holds   cur_active_holds%ROWTYPE;
    l_v_credit_number    igs_fi_credits_all.credit_number%TYPE          := NULL;
    l_d_last_conv_dt     igs_fi_balance_rules.last_conversion_date%TYPE := NULL;
    l_n_version_number   igs_fi_balance_rules.version_number%TYPE       := NULL;
    l_n_release          PLS_INTEGER := 0;
    l_v_message_name     fnd_new_messages.message_name%TYPE := NULL;

BEGIN

   OPEN cur_active_holds(p_person_id, p_hold_plan_level);
   FETCH cur_active_holds INTO l_rec_active_holds;
   IF cur_active_holds%NOTFOUND THEN
      CLOSE cur_active_holds;
      RETURN;
   END IF;
   CLOSE cur_active_holds;

   -- Obtain the latest active balance rule
   igs_fi_gen_007.finp_get_balance_rule ( p_v_balance_type          => 'HOLDS',
                                          p_v_action                => 'ACTIVE',
                                          p_n_balance_rule_id       => l_balance_rule_id, -- Package level OUT variable
                                          p_d_last_conversion_date  => l_d_last_conv_dt,
                                          p_n_version_number        => l_n_version_number);

   -- Hold Plan Level = Fee Type
   IF (p_hold_plan_level = 'F') THEN
       BEGIN   -- Block to call Mass Application and Release holds
          SAVEPOINT before_transaction;

          IF (p_run_application = 'Y') THEN
               -- Invoke Mass Application process
               OPEN cur_credit_number(p_release_credit_id);
               FETCH cur_credit_number INTO l_v_credit_number;
               CLOSE cur_credit_number;

               igs_fi_prc_appl.mass_apply( p_person_id          => p_person_id,
                                           p_person_id_grp      => NULL,
                                           p_credit_number      => l_v_credit_number,
                                           p_credit_type_id     => NULL,
                                           p_credit_date_low    => NULL,
                                           p_credit_date_high   => NULL,
                                           p_d_gl_date          => TRUNC(SYSDATE)
                                         );
          END IF;  -- End of check for run_application

          -- Validate the holds, release if applicable
          -- Also updates release_credit_id column if holds were released
          IF NOT validate_holds( p_person_id         => p_person_id,
                                 p_hold_plan_name    => NULL,
                                 p_test_run          => 'N',
                                 p_release           => l_n_release,
                                 p_message_name      => l_v_message_name,
                                 p_release_credit_id => p_release_credit_id,
                                 p_hold_plan_level   => p_hold_plan_level) THEN
                ROLLBACK TO before_transaction;
                -- Set the message name to the out variable of validate_holds
                p_message_name := l_v_message_name;
                RETURN;
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
               ROLLBACK TO before_transaction;
               -- Set the message name to a generic error message
               p_message_name := 'IGS_FI_NO_AUTO_HOLD_REL';
               RETURN;
       END;  -- End of Block to call Mass Application and release holds

   -- Hold Plan Level = Balance
   ELSIF (p_hold_plan_level = 'S') THEN
      -- Block to validate and release holds
      BEGIN
           SAVEPOINT before_release;

           -- Validate the holds, release if applicable
           -- Also updates release_credit_id column if holds were released
           IF NOT validate_holds( p_person_id         => p_person_id,
                                  p_hold_plan_name    => NULL,
                                  p_test_run          => 'N',
                                  p_release           => l_n_release,        -- OUT parameter
                                  p_message_name      => l_v_message_name,    -- OUT parameter
                                  p_release_credit_id => p_release_credit_id,
                                  p_hold_plan_level   => p_hold_plan_level) THEN
               ROLLBACK TO before_release;
               -- Set the message name to the out variable of validate_holds
               p_message_name := l_v_message_name;
               RETURN;
           END IF;
      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK TO before_release;
            -- Set the message name to a generic error message
            p_message_name := 'IGS_FI_NO_AUTO_HOLD_REL';
            RETURN;
      END; -- End of block to validate and release holds

   END IF; -- End of check for hold_plan_level

END finp_auto_release_holds;

END  igs_fi_prc_holds;

/
