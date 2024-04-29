--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_FIN_LT_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_FIN_LT_CHG" AS
/* $Header: IGSFI69B.pls 120.3 2006/02/13 02:31:08 sapanigr noship $ */
  ------------------------------------------------------------------
  --Created by  :Sarakshi , Oracle IDC
  --Date created:05-Dec-2001
  --
  --Purpose: Package Body contains code for procedures/Functions defined in
  --         package specification . Also body includes Functions/Procedures
  --         private to it .
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sapanigr   13-Feb-2006     Bug 5018036. Modified cursor in procedure calc_fin_lt_charge for R12 repository perf tuning.
  --svuppala   04-AUG-2005     Enh 3392095 - Tution Waivers build
  --                           Impact of Charges API version Number change
  --                           Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  --pathipat   26-Apr-2004      Bug 3578249 - Modified calc_fin_lt_charge()
  --vvutukur   20-Jan-2004      Bug#3348787.Modified calc_fin_lt_charge.
  --vvutukur   20-Sep-2003      Enh#3045007.Payment Plans Build. Changes specific to Payment Plans TD.
  --vvutukur   30-Jul-2003      Bug#3069929.Modified calc_red_balance.
  --pathipat   24-Jun-2003      Bug: 3018104 - Impact of changes to person id group views
  --                            Replaced igs_pe_persid_group_v with igs_pe_persid_group in validate_persid_grp()
  --shtatiko   22-MAR-2003      Enh# 2831569, Modified calc_fin_lt_charge
  --vvutukur   12-Feb-2003      Bug#2731357.Modified calc_fin_lt_charge and lookup_desc.
  --shtatiko   10-JAN-2003      Bug# 2731350, modiifed calc_fin_lt_charge
  --pathipat   08-Jan-2003      Bug: 2690024 - modified calc_red_balance
  --shtatiko   17-DEC-2002      Enh# 2584741, introduced l_adb_bal1 for accommodating NOCOPY issue
  --vvutukur   17-DEC-2002      Enh# 2584741, Changed as per Deposits TD.
  --vvutukur   24-Nov-2002       Enh#2584986.Added p_d_gl_date parameter to calc_fin_lt_charge procedure.
  --                             Modifications done in procedures calculate_charge,call_charges_api.
  --shtatiko   08-OCT-2002      Bug# 2562745, Changed calc_fin_lt_charge, calculate_charge,
  --                            det_payable_balance and calc_red_balance.
  --                            Check corresponding procedures for exact changes.
  --shtatiko   23-SEP-2002      Bug# 2564643, Removed References to Sub Account Id in all places.
  --vchappid   03-Jun-2002      Bug# 2325427, Customized messages are shown to the user when there is no charge to
  --                            create.
  --SYKRISHN   30-APR-2002      Bug 2348883 - Function validate_ftci - Cursor cur_val
                               -- modified to compare with fee structure status (system ststus)
  --vchappid   19-Apr-2002      Bug#2313147, Date comparisions are done after eliminating time component,
  --                            implemented in all places where ever time component is not present
  --                            Billing Cutoff date comparision with the Charge Creation Date is Corrected
  --SYKRISHN    -5-APR-02       Enh Bug : 2293676 - Introduction of functionality of planned credits -
  --                            According to SFCR018 Build - Introduced the function get_planned_credits_ind
  --                            and associated code.
  --sarakshi    27-Feb-2002     bug:2238362, changed the view igs_pe_person_v to igs_fi_parties_v and used the
  --                            function igs_fi_gen_007.validate_person to validate person, removed validate
  --                            person_id local function.
  -------------------------------------------------------------------

  -- Global cursor, added NVL condition as part of Enh# 2562745.
  CURSOR cur_plan(cp_plan_name igs_fi_fin_lt_plan.plan_name%TYPE) IS
  SELECT *
  FROM   igs_fi_fin_lt_plan
  WHERE  plan_name= cp_plan_name
         AND NVL(closed_ind,'N')='N';


  --Declaration of a ref cursor type.
  TYPE cur_ref IS REF CURSOR;

--Added these valriables as part of Enh# 2562745. These are passed as OUT NOCOPY variables in call to
--finp_get_balance_rule.

  g_balance_rule_id igs_fi_balance_rules.balance_rule_id%TYPE;
  g_last_conversion_date igs_fi_balance_rules.last_conversion_date%TYPE;
  g_version_number igs_fi_balance_rules.version_number%TYPE;

  l_validation_exp exception;
  g_v_flat_amt     igs_fi_fin_lt_plan.accrual_type%TYPE := 'FLAT_AMOUNT';
  g_v_flat_rate    igs_fi_fin_lt_plan.accrual_type%TYPE := 'FLAT_RATE';
  g_v_cutoff_dt    igs_fi_fin_lt_plan.accrual_type%TYPE := 'AVG_DLY_BAL_CUTOFF_DT';
  g_v_due_dt       igs_fi_fin_lt_plan.accrual_type%TYPE := 'AVG_DLY_BAL_DUE_DT';
  g_v_finance      igs_fi_fin_lt_plan.plan_type%TYPE := 'INTEREST';
  g_v_late         igs_fi_fin_lt_plan.plan_type%TYPE := 'LATE';
  g_d_sysdate      DATE := TRUNC(SYSDATE);
  g_v_hor_line     VARCHAR2(100) := RPAD('-',77,'-');


-- Changes due to SFCR018
---Local package function to get the value of planned credits indicator
FUNCTION get_planned_credits_ind
RETURN VARCHAR2
 IS
 /***************************************************************
   Created By           :       SYkrishn
   Date Created By      :       APR/05/2002
   Purpose              :       Gets the value of planned credits indicator from IGS_FI_CONTROL_ALL.
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What

 ***************************************************************/

 l_v_planned_credits_ind igs_fi_control_all.planned_credits_ind%TYPE  :=  NULL;
 l_v_pln_cr_message      fnd_new_messages.message_name%TYPE  :=  NULL;

 BEGIN
--Call the genric function to get the value
 l_v_planned_credits_ind := igs_fi_gen_001.finp_get_planned_credits_ind(l_v_pln_cr_message);

 IF l_v_pln_cr_message IS NOT NULL THEN
 --Log error message and raise exception
     fnd_message.set_name('IGS',l_v_pln_cr_message);
     fnd_file.put_line(fnd_file.log,fnd_message.get());
     fnd_file.put_line(fnd_file.log,' ');
     RAISE l_validation_exp;
 END IF;

   RETURN l_v_planned_credits_ind;
 END get_planned_credits_ind;
-- Changes due to SFCR018

FUNCTION validate_persid_grp(p_persid_grp_id  IN    igs_pe_persid_group.group_id%TYPE)
  RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  Validates person Id Group

  Known limitations,enhancements,remarks:
  Change History
  Who        When           What
  vvutukur   25-Sep-2003    Enh#3045007.Payment Plans Build.modified cursor cur_val to validate
                            the dynamic person id group also.igs_pe_persid_group will have only
                            static person id groups.
  pathipat   24-Jun-2003    Bug: 3018104 - Impact of changes to person id group views
                            Replaced igs_pe_persid_group_v with igs_pe_persid_group
  vchappid   19-Apr-2002      Bug#2313147, Date comparisions are done after eliminating time component
********************************************************************************************** */

  CURSOR cur_val  IS
  SELECT  'X'
  FROM    igs_pe_persid_group_all
  WHERE   group_id = p_persid_grp_id
  AND     closed_ind = 'N'
  AND     TRUNC(create_dt) <= g_d_sysdate;
  l_temp  VARCHAR2(1);
BEGIN
  OPEN cur_val;
  FETCH cur_val INTO l_temp;
  IF cur_val%FOUND THEN
    CLOSE cur_val;
    RETURN TRUE;
  ELSE
    CLOSE cur_val;
    RETURN FALSE;
  END IF;
END validate_persid_grp;

FUNCTION validate_plan_name(p_plan_name IN     igs_fi_fin_lt_plan.plan_name%TYPE)
  RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  Validates Plan Name

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

  CURSOR cur_val IS
  SELECT  'X'
  FROM    igs_fi_fin_lt_plan
  WHERE   plan_name = p_plan_name
  AND     closed_ind = 'N';
  l_temp  VARCHAR2(1);
BEGIN
  OPEN cur_val;
  FETCH cur_val INTO l_temp;
  IF cur_val%FOUND THEN
    CLOSE cur_val;
    RETURN TRUE;
  ELSE
    CLOSE cur_val;
    RETURN FALSE;
  END IF;
END validate_plan_name;

FUNCTION validate_ftci(p_cur_plan cur_plan%ROWTYPE,
                       p_cal_type IN igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                       p_sequence_number IN  igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE)
  RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  Validates ftci

  Known limitations,enhancements,remarks:
  Change History
  Who       When            What
  SYkrishn  30/APR/2002     Modified the cursor cur_val to compare fee type ci status
                            with system status of Fee Structure status    Bug 2348883
  Sarakshi  15-Jan-2002     Modifies the cursor cur_val to remove subaccount_id check ,bug:2175865
********************************************************************************************** */
  CURSOR cur_val(cp_fee_type                igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                 cp_fee_cal_type            igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                 cp_fee_ci_sequence_number  igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE) IS
  SELECT  'X'
  FROM    igs_fi_f_typ_ca_inst_all fcc,
  -- bug 5018036:  Changed igs_fi_f_typ_ca_inst_lkp_v to igs_fi_f_typ_ca_inst_all
          igs_fi_fee_str_stat fss
  WHERE   fcc.fee_type = cp_fee_type
  AND     fcc.fee_cal_type = cp_fee_cal_type
  AND     fcc.fee_ci_sequence_number = cp_fee_ci_sequence_number
  AND     fcc.fee_type_ci_status = fss.fee_structure_status
  AND     fss.s_fee_structure_status = 'ACTIVE';
  l_temp  VARCHAR2(1);

BEGIN
  OPEN cur_val(p_cur_plan.fee_type,p_cal_type,p_sequence_number);
  FETCH cur_val INTO l_temp;
  IF cur_val%FOUND THEN
    CLOSE cur_val;
    RETURN TRUE;
  ELSE
    CLOSE cur_val;
    RETURN FALSE;
  END IF;

END validate_ftci;

PROCEDURE log_person(p_person_id igs_pe_person_v.person_id%TYPE ) IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  Logging person number and name

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */
  CURSOR cur_person IS
  SELECT person_number,full_name
  --bug:2238362, changed the view igs_pe_person_v to igs_fi_parties_v
  FROM   igs_fi_parties_v
  WHERE  person_id= p_person_id;
  l_cur_person cur_person%ROWTYPE;

BEGIN
  OPEN cur_person;
  FETCH cur_person INTO l_cur_person;
  CLOSE cur_person;

  fnd_file.put_line(fnd_file.log,g_v_hor_line);
  fnd_message.set_name('IGS','IGS_FI_PROC_PERSON');
  fnd_message.set_token('NUMBER',l_cur_person.person_number);
  fnd_message.set_token('NAME',l_cur_person.full_name) ;
  fnd_file.put_line(fnd_file.log,fnd_message.get);
END log_person;

PROCEDURE log_amount(p_amount igs_fi_balances.standard_balance%TYPE, p_msg_name  VARCHAR2 ) IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To log the amount calculated

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

BEGIN
  fnd_message.set_name('IGS',p_msg_name);
  fnd_message.set_token('AMOUNT',TO_CHAR(p_amount));
  fnd_file.put_line(fnd_file.log,fnd_message.get);
END log_amount;

FUNCTION lookup_desc( p_type IN VARCHAR2 ,
                      p_code IN VARCHAR2 )
RETURN VARCHAR2 IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To fetch the meaning of a corresponding lookup code of a lookup type

  Known limitations,enhancements,remarks:
  Change History
  Who      When         What
vvutukur  27-Feb-2003  Enh#2731357.Removed cursor which fetches the meaning of the lookup code and its usage.
                       Instead, used generic function which returns the same.
********************************************************************************************** */

BEGIN

  IF p_code IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN igs_fi_gen_gl.get_lkp_meaning(p_v_lookup_type => p_type,
                                         p_v_lookup_code => p_code);
  END IF ;

END lookup_desc;

PROCEDURE log_messages ( p_msg_name  VARCHAR2 ,
                         p_msg_val   VARCHAR2
                       ) IS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To log the parameter and other important information obtained from plans table

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */
BEGIN
  fnd_message.set_name('IGS','IGS_FI_CAL_BALANCES_LOG');
  fnd_message.set_token('PARAMETER_NAME',p_msg_name);
  fnd_message.set_token('PARAMETER_VAL' ,p_msg_val) ;
  fnd_file.put_line(fnd_file.log,fnd_message.get);
END log_messages ;



PROCEDURE log_plan_info(p_cur_plan cur_plan%ROWTYPE, p_batch_cutoff_dt DATE,p_batch_due_date DATE,
                        p_cal_type igs_fi_f_typ_ca_inst_lkp_v.fee_cal_type%TYPE ,
                        p_sequence_number igs_fi_f_typ_ca_inst_lkp_v.fee_ci_sequence_number%TYPE,
                        p_batch_due_dt    DATE )
  AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To log the parameter and other important information obtained from plans table

  Known limitations,enhancements,remarks:
  Change History
  Who       When       What
  vvutukur   20-Sep-2003      Enh#3045007.Payment Plans Build. Changes specific to Payment Plans TD.
  vchappid  03-Jun-02  Bug 2325427, Added all the plan details in the Log file
********************************************************************************************** */

BEGIN

  fnd_file.put_line(fnd_file.log,' ');
  log_messages(lookup_desc('IGS_FI_LOCKBOX','PLAN_TYPE'),lookup_desc('IGS_FI_PLAN_TYPE',p_cur_plan.plan_type));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','BALANCE_TYPE'),
               lookup_desc('IGS_FI_BALANCE_TYPE',p_cur_plan.balance_type));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','ACCRUAL_TYPE'),
               lookup_desc('IGS_FI_ACCRUAL_TYPE',p_cur_plan.accrual_type));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','FEE_TYPE'),p_cur_plan.fee_type);

  fnd_message.set_name('IGS','IGS_FI_OFFSET_DAYS');
  fnd_message.set_token('DAYS',p_cur_plan.offset_days);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.put_line(fnd_file.log,'');

  fnd_message.set_name('IGS','IGS_FI_CHARGE_RATE');
  fnd_message.set_token('RATE',p_cur_plan.chg_rate);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.put_line(fnd_file.log,'');

  fnd_message.set_name('IGS','IGS_FI_FLAT_AMOUNT');
  fnd_message.set_token('AMT',p_cur_plan.flat_amount);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.put_line(fnd_file.log,'');

  fnd_message.set_name('IGS','IGS_FI_MIN_BAL_AMOUNT');
  fnd_message.set_token('BAL_AMT',p_cur_plan.min_balance_amount);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.put_line(fnd_file.log,'');

  fnd_message.set_name('IGS','IGS_FI_MIN_CHG_AMOUNT');
  fnd_message.set_token('CHG_AMT',p_cur_plan.min_charge_amount);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.put_line(fnd_file.log,'');

  fnd_message.set_name('IGS','IGS_FI_MAX_CHG_AMOUNT');
  fnd_message.set_token('CHG_AMT',p_cur_plan.max_charge_amount);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.put_line(fnd_file.log,'');

  fnd_message.set_name('IGS','IGS_FI_MIN_AMT_NO_CHG');
  fnd_message.set_token('CHG_AMT',p_cur_plan.min_charge_amount_no_charge);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

  fnd_file.put_line(fnd_file.log,' ');
END log_plan_info;

PROCEDURE calc_red_balance (
        p_person_id     IN      igs_pe_person.person_id%TYPE,
        p_bal_start_dt  IN      DATE,
        p_bal_end_dt    IN      DATE,
        p_bal_type      IN      igs_fi_balance_rules.balance_name%TYPE,
        p_open_bal      IN      NUMBER,
        p_red_bal       OUT NOCOPY      NUMBER) IS
-------------------------------------------------------------------------------
--  Created By : Nishikant, Oracle IDC.
--  Date Created On : 11-DEC-2001
--  Purpose: The Procedure takes the period of time and balance at the start of
--           the period for a person as input. Then it processes all credits in
--           the given period and applies them to the opening balance to
--           calculate the Reduced Balance.
--  Change History
--  Who             When            What
--  vvutukur       30-Jul-2003     Bug#3069929.Modified cursor c_credits.
--  pathipat       08-Jan-2003     Bug: 2690024 - Removed exception section to prevent masking
--                                 Called check_Exclusion_rules and finp_get_total_planned_credits
--                                 in begin-end blocks to handle exceptions
--  shtatiko       08-OCT-2002     Removed cursor c_bal_type and its references in code. Enh# 2562745.
--                                 Added balance_rule_id parameter to check_exclusion_rules.
--  shtatiko       23-SEP-2002     Removal of subaccount_id from the parameter list and usage of the--                                 same in the code.
--  SYKRISHN        5/apr/2002     Changes due to SFCr018 - 2293676 -- Include planned credits
--  if the indicator is set as Y while deriving the reduced balance p_red_bal
--  (reverse chronological order - newest change first)
-------------------------------------------------------------------------------
CURSOR c_credits IS
       SELECT  credit_id, amount, effective_date
       FROM    igs_fi_credits cdt,
               igs_fi_cr_types cty
       WHERE   TRUNC(effective_date)
         BETWEEN TRUNC(p_bal_start_dt) AND TRUNC(p_bal_end_dt)
         AND party_id = p_person_id
         AND status = 'CLEARED'
         AND cty.credit_type_id = cdt.credit_type_id
         AND cty.credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT');

-- An issue was found with the above cursor during the build of SFCR018 - the format mask for date was wrongly used
-- as DDMMYYYY - It was changed to YYYYMMDD
l_credit_amount      NUMBER  :=  0;
l_person_id          VARCHAR2(1);
l_bal_type           VARCHAR2(1);
l_credits            c_credits%ROWTYPE;
l_message_name       fnd_new_messages.message_name%TYPE;
l_return_stat        BOOLEAN;

-- Changes due to SFCR018
 -- Call the local function to get the value of planned_credits_ind
  l_v_pln_cr_ind igs_fi_control_all.planned_credits_ind%TYPE := get_planned_credits_ind;
  l_v_pln_cr_message fnd_new_messages.message_name%TYPE  :=  NULL;
  l_n_planned_credit igs_fi_credits.amount%TYPE  :=  0;
-- Changes due to SFCR018

l_b_success_flag     BOOLEAN;  -- For bug 2690024

BEGIN

  -- The below parameters are mandatory so they cannot be NULL
  IF  (p_person_id   IS NULL OR
      p_bal_start_dt IS NULL OR
      p_bal_end_dt   IS NULL OR
      p_bal_type     IS NULL OR
      p_open_bal     IS NULL  )  THEN
          fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
  END IF;

  -- The Person_id passed as parameter to the procedure is validated
  IF igs_fi_gen_007.validate_person(p_person_id) = 'N' THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END IF;

  -- The parameter Balance Start Date should less than Balance End Date
  IF p_bal_start_dt > p_bal_end_dt THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END IF;

  -- Select all Credits from the credits table for the person where the Effective
  -- Date of the Credits falls in the input Period, which means between Balance
  -- Start Date and Balance End Date.
  FOR l_credits IN c_credits
  LOOP

     l_message_name := NULL;
     l_return_stat := FALSE;

  -- Calling Check Exclusion Rules procedure to check whether the credit found is
  -- excluded or not.
     BEGIN
          --Added balance rule id parameter to check_exclusion_rules as part of Enh#2562745.
          l_return_stat := igs_fi_prc_balances.check_exclusion_rules (
                                                p_balance_type => p_bal_type,
                                                p_balance_date => l_credits.effective_date,
                                                p_source_type => 'CREDIT',
                                                p_source_id => l_credits.credit_id,
                                                p_message_name => l_message_name,
                                                p_balance_rule_id => g_balance_rule_id );

     -- The exception part is written here to handle if any exception raised in
     -- the check Exclusion Rules procedure due to the above call.
     EXCEPTION
          WHEN OTHERS THEN
             -- (pathipat) for bug 2690024 - removed NULL (masking of exception),
             -- instead set flag to TRUE
             l_return_stat := TRUE;
     END;

     -- If the Return value from the above call is False then the Credit is not
     -- excluded. Then it sums up the credit amount found for the credit with
     -- the previously found credit amounts, if any found earlier.

     -- (pathipat) for bug 2690024 - brought the following code out of the begin-end
     -- section.
     IF NOT l_return_stat AND l_message_name IS NULL THEN
        l_credit_amount := l_credit_amount + l_credits.amount;
     END IF;

  END LOOP;

  -- Here the Reduced Balance is calculated by substracting the whole Credit Amount
  -- from the Opening Balance. If no Credit Amount found then Opening Balance will
  -- be the Reduced Balance.
  p_red_bal := p_open_bal - l_credit_amount;

  -- (pathipat) bug 2690024 - Called finp_get_total_planned_credits within a begin-end block
  -- to handle exception without masking it.
  l_b_success_flag := TRUE;

  BEGIN
  -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'
           IF l_v_pln_cr_ind = 'Y' THEN
           --Call the generic function to get the total planned credits for the params passed.
               l_n_planned_credit := igs_fi_gen_001.finp_get_total_planned_credits(
                                                                p_person_id => p_person_id,
                                                                p_start_date => p_bal_start_dt,
                                                                p_end_date => p_bal_end_dt,
                                                                p_message_name => l_v_pln_cr_message);
               IF l_v_pln_cr_message IS NOT NULL THEN
                  l_b_success_flag := FALSE;
               ELSE
                  l_b_success_flag := TRUE;
               END IF;
           END IF;

  EXCEPTION
    WHEN OTHERS THEN
       l_b_success_flag := FALSE;

  END;

  IF l_b_success_flag = FALSE THEN
     fnd_message.set_name('IGS',l_v_pln_cr_message);
     fnd_file.put_line(fnd_file.log,fnd_message.get());
     fnd_file.put_line(FND_FILE.LOG,' ');
  ELSE
     -- When no errors reduce the balance with the sum of planned credits.
     p_red_bal := p_red_bal - NVL(l_n_planned_credit,0);
  END IF;
  -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'


END calc_red_balance;

PROCEDURE  call_charges_api(p_cur_plan        IN cur_plan%ROWTYPE,
                            p_person_id       IN igs_pe_person_v.person_id%TYPE,
                            p_charge_amount   IN igs_fi_balances.standard_balance%TYPE,
                            p_chg_crtn_dt     IN DATE,
                            p_cal_type        IN igs_fi_f_typ_ca_inst_v.fee_cal_type%TYPE,
                            p_sequence_number IN igs_fi_f_typ_ca_inst_v.fee_ci_sequence_number%TYPE,
                            p_d_gl_date       IN igs_fi_credits_all.gl_date%TYPE,
                            p_n_std_plan_id   IN igs_fi_pp_std_attrs.student_plan_id%TYPE,
                            p_d_inst_due_date IN igs_fi_pp_instlmnts.due_date%TYPE,
                            p_b_chrg_flag     OUT NOCOPY BOOLEAN
                            )AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To create charges.

  Known limitations,enhancements,remarks:
  Change History
  Who         When         What
  svuppala    04-AUG-2005  Enh 3392095 - Tution Waivers build
                           Impact of Charges API version Number change
                           Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  vvutukur    20-Sep-2003  Enh#3045007.Payment Plans Build. Changes specific to Payment Plans TD.
  vvutukur    24-Nov-2002  Enh#2584986.Added p_d_gl_date parameter and passed the same to the call to charges api.
                           Removed references to igs_fi_cur as the same has been obsoleted and captured the local
                           currency from System Options Form to be passed to charges api.
  vchappid    19-APR-2002  Bug#2313147, Amount in the invoice lines table was passed as NULL, Corrected to
                           Charge Amount that is calculated
********************************************************************************************** */


  l_chg_rec             igs_fi_charges_api_pvt.Header_Rec_Type;
  l_chg_line_tbl        igs_fi_charges_api_pvt.Line_Tbl_Type;
  l_line_tbl            igs_fi_charges_api_pvt.Line_Id_Tbl_Type;
  l_invoice_id          igs_fi_inv_int.Invoice_Id%TYPE;
  l_ret_status          VARCHAR2(1);
  l_msg_count           NUMBER(5);
  l_msg_data            VARCHAR2(2000);
  l_var                 NUMBER(5) := 0;
  l_count               NUMBER(5);
  l_msg                 VARCHAR2(2000);

  CURSOR cur_desc(cp_fee_type  igs_fi_fee_type.fee_type%TYPE)  IS
  SELECT description
  FROM   igs_fi_fee_type
  WHERE  fee_type = cp_fee_type;

  l_cur_desc        igs_fi_inv_int.invoice_desc%TYPE;

  l_v_currency      igs_fi_control_all.currency_cd%TYPE;
  l_v_curr_desc     fnd_currencies_tl.name%TYPE;
  l_v_message_name  fnd_new_messages.message_name%TYPE;
  l_v_tran_type     igs_lookup_values.meaning%TYPE := lookup_desc('TRANSACTION_TYPE',p_cur_plan.plan_type);
  l_v_pmt_plan      igs_lookup_values.meaning%TYPE := lookup_desc('IGS_FI_LOCKBOX','PAYMENT_PLAN');
  l_v_instl_due     igs_lookup_values.meaning%TYPE := lookup_desc('IGS_FI_LOCKBOX','INSTALLMENT_DUE');

  l_n_waiver_amount NUMBER;
BEGIN

  p_b_chrg_flag := TRUE;

  IF p_n_std_plan_id IS NULL THEN
    --fetching the fee type description
    OPEN cur_desc(p_cur_plan.fee_type);
    FETCH cur_desc INTO l_cur_desc;
    CLOSE cur_desc;
  ELSE
    IF p_cur_plan.plan_type = g_v_finance THEN
      l_cur_desc := l_v_tran_type||' '||l_v_pmt_plan;
    ELSIF p_cur_plan.plan_type = g_v_late THEN
      l_cur_desc := l_v_tran_type||' '||l_v_instl_due||' '||TO_CHAR(p_d_inst_due_date,'Month DD, YYYY');
    END IF;
  END IF;

  --Capture the default currency that is set up in System Options Form.
  igs_fi_gen_gl.finp_get_cur( p_v_currency_cd   => l_v_currency,
                              p_v_curr_desc     => l_v_curr_desc,
                              p_v_message_name  => l_v_message_name
                             );
  IF l_v_message_name IS NOT NULL THEN
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_msg_pub.add;
    p_b_chrg_flag := FALSE;
    RAISE fnd_api.g_exc_error;
  END IF;

  l_chg_rec.p_person_id                := p_person_id;
  l_chg_rec.p_fee_type                 := p_cur_plan.fee_type;
  l_chg_rec.p_fee_cat                  := NULL;
  l_chg_rec.p_fee_cal_type             := p_cal_type;
  l_chg_rec.p_fee_ci_sequence_number   := p_sequence_number;
  l_chg_rec.p_course_cd                := NULL;
  l_chg_rec.p_attendance_type          := NULL;
  l_chg_rec.p_attendance_mode          := NULL;
  l_chg_rec.p_invoice_amount           := p_charge_amount;
  l_chg_rec.p_invoice_creation_date    := p_chg_crtn_dt;
  l_chg_rec.p_invoice_desc             := l_cur_desc;
  l_chg_rec.p_transaction_type         := p_cur_plan.plan_type;
  l_chg_rec.p_currency_cd              := l_v_currency;
  l_chg_rec.p_exchange_rate            := 1;
  l_chg_rec.p_effective_date           := p_chg_crtn_dt;
  l_chg_rec.p_waiver_flag              := NULL;
  l_chg_rec.p_waiver_reason            := NULL;
  l_chg_rec.p_source_transaction_id    := NULL;


  l_chg_line_tbl(1).p_s_chg_method_type         := NULL;
  l_chg_line_tbl(1).p_description               := l_cur_desc;
  l_chg_line_tbl(1).p_chg_elements              := NULL;
  l_chg_line_tbl(1).p_amount                    := p_charge_amount;
  l_chg_line_tbl(1).p_unit_attempt_status       := NULL;
  l_chg_line_tbl(1).p_eftsu                     := NULL;
  l_chg_line_tbl(1).p_credit_points             := NULL;
  l_chg_line_tbl(1).p_org_unit_cd               := NULL;
  l_chg_line_tbl(1).p_attribute_category        := NULL;
  l_chg_line_tbl(1).p_attribute1                := NULL;
  l_chg_line_tbl(1).p_attribute2                := NULL;
  l_chg_line_tbl(1).p_attribute3                := NULL;
  l_chg_line_tbl(1).p_attribute4                := NULL;
  l_chg_line_tbl(1).p_attribute5                := NULL;
  l_chg_line_tbl(1).p_attribute6                := NULL;
  l_chg_line_tbl(1).p_attribute7                := NULL;
  l_chg_line_tbl(1).p_attribute8                := NULL;
  l_chg_line_tbl(1).p_attribute9                := NULL;
  l_chg_line_tbl(1).p_attribute10               := NULL;
  l_chg_line_tbl(1).p_attribute11               := NULL;
  l_chg_line_tbl(1).p_attribute12               := NULL;
  l_chg_line_tbl(1).p_attribute13               := NULL;
  l_chg_line_tbl(1).p_attribute14               := NULL;
  l_chg_line_tbl(1).p_attribute15               := NULL;
  l_chg_line_tbl(1).p_attribute16               := NULL;
  l_chg_line_tbl(1).p_attribute17               := NULL;
  l_chg_line_tbl(1).p_attribute18               := NULL;
  l_chg_line_tbl(1).p_attribute19               := NULL;
  l_chg_line_tbl(1).p_attribute20               := NULL;
  l_chg_line_tbl(1).p_location_cd               := NULL;
  l_chg_line_tbl(1).p_uoo_id                    := NULL;
  l_chg_line_tbl(1).p_d_gl_date                 := p_d_gl_date;


  igs_fi_charges_api_pvt.Create_Charge(p_api_version      => 2.0,
                                       p_init_msg_list    => 'T',
                                       p_commit           => 'F',
                                       p_validation_level => NULL,
                                       p_header_rec       => l_chg_rec,
                                       p_line_tbl         => l_chg_line_tbl,
                                       x_invoice_id       => l_invoice_id,
                                       x_line_id_tbl      => l_line_tbl,
                                       x_return_status    => l_ret_status,
                                       x_msg_count        => l_msg_count,
                                       x_msg_data         => l_msg_data,
                                       x_waiver_amount    => l_n_waiver_amount);

  IF l_ret_status <> 'S' THEN
    IF l_msg_count = 1 THEN
      fnd_message.set_encoded(l_msg_data);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    ELSE
      FOR l_count IN 1 .. l_msg_count LOOP
        l_msg := fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T');
        fnd_message.set_encoded(l_msg);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END LOOP;
    END IF;
    p_b_chrg_flag := FALSE;
  END IF;
END call_charges_api;


PROCEDURE log_dtls_create_charge(p_cur_plan          IN cur_plan%ROWTYPE,
                                 p_n_person_id       IN PLS_INTEGER,
                                 p_n_std_plan_id     IN PLS_INTEGER,
                                 p_b_grt_min_bal_amt IN BOOLEAN,
                                 p_n_charge_amount   IN NUMBER,
                                 p_d_chg_crtn_dt     IN DATE,
                                 p_v_cal_type        IN VARCHAR2,
                                 p_n_sequence_number IN PLS_INTEGER,
                                 p_d_gl_date         IN DATE,
                                 p_d_inst_due_date   IN DATE,
                                 p_v_test_flag       IN VARCHAR2,
                                 p_b_chrg_flag       OUT NOCOPY BOOLEAN
                                 ) AS
/***********************************************************************************************

  Created By     :  vvutukur, Oracle India
  Date Created By:  17-Sep-2003
  Purpose        :  To log the amount calculated and amount to be charged. Also
                    this procedure calls another local procedure to create the charge.
                    This procedure is being created as part of the modifications for
                    Payment Plans Build.(Enh#3045007).

  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
************************************************************************************************/

  CURSOR cur_bill(cp_n_person_id igs_fi_parties_v.person_id%TYPE) IS
    SELECT cut_off_date
    FROM   igs_fi_bill
    WHERE  person_id = cp_n_person_id
    ORDER BY bill_date DESC;

  l_cur_bill              cur_bill%ROWTYPE;
  l_n_min_chg_amt_no_chg  igs_fi_fin_lt_plan.payment_plan_minchgamt_nochg%TYPE;
  l_n_min_chrg_amt        igs_fi_fin_lt_plan.payment_plan_min_charge_amt%TYPE;
  l_n_max_chrg_amt        igs_fi_fin_lt_plan.payment_plan_max_charge_amt%TYPE;
  l_v_accrual_type        igs_fi_fin_lt_plan.accrual_type%TYPE;
  l_n_charge_amount       NUMBER := 0;
  l_b_chrg_flag           BOOLEAN := TRUE;

BEGIN

  l_v_accrual_type       := p_cur_plan.accrual_type;
  l_n_min_chg_amt_no_chg := p_cur_plan.min_charge_amount_no_charge;
  l_n_min_chrg_amt       := p_cur_plan.min_charge_amount;
  l_n_max_chrg_amt       := p_cur_plan.max_charge_amount;

  IF (p_n_std_plan_id IS NOT NULL AND p_cur_plan.payment_plan_accrl_type_code IS NOT NULL) THEN
    l_v_accrual_type       := NVL(p_cur_plan.payment_plan_accrl_type_code,l_v_accrual_type);
    l_n_max_chrg_amt       := NVL(p_cur_plan.payment_plan_max_charge_amt,l_n_max_chrg_amt);
    l_n_min_chrg_amt       := NVL(p_cur_plan.payment_plan_min_charge_amt,l_n_min_chrg_amt);
    l_n_min_chg_amt_no_chg := NVL(p_cur_plan.payment_plan_minchgamt_nochg,l_n_min_chg_amt_no_chg);
  END IF;

  l_n_charge_amount := NVL(p_n_charge_amount,0);

  --Logging the calculated amount
  log_amount(l_n_charge_amount,'IGS_FI_CALC_AMNT');

  p_b_chrg_flag := TRUE;

  IF (l_n_charge_amount <= 0 AND p_b_grt_min_bal_amt) THEN
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_NO_CHG_APP'));
    p_b_chrg_flag := FALSE;
    RETURN;
  END IF;

  --Incase the flag p_b_grt_min_bal_amt is FALSE, no need to proceed for creating a charge.
  IF p_cur_plan.plan_type = g_v_late AND p_b_grt_min_bal_amt = FALSE THEN
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_NO_CHG_APP_MIN_BAL'));
    p_b_chrg_flag := FALSE;
    RETURN;
  END IF;

  --Validate the charge amount against Min Charge Amount, Max Charge Amount, Min Charge Amount No charge Amount
  --only when the plan type is not late and accrual type is not Flat Amount.
  --Because only in that particular case only, these three fields will not have values.
  IF (NOT((p_cur_plan.plan_type = g_v_late) AND (l_v_accrual_type = g_v_flat_amt))) THEN
    IF l_n_charge_amount < NVL(l_n_min_chg_amt_no_chg,l_n_charge_amount) THEN
      fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_NO_CHG_APP_MIN_CHG'));
      p_b_chrg_flag := FALSE;
      RETURN;
    END IF;

    --If the charge amount is less than min charge amount, then amount to be charged = min charge amount.
    IF l_n_charge_amount < NVL(l_n_min_chrg_amt,l_n_charge_amount) THEN
      l_n_charge_amount := l_n_min_chrg_amt;
    END IF;

    --If the charge amount is greater than max charge amount, then amount to be charged = max charge amount.
    IF l_n_charge_amount > NVL(l_n_max_chrg_amt,l_n_charge_amount) THEN
      l_n_charge_amount := l_n_max_chrg_amt;
    END IF;
  END IF;

  --Logging the amount to be charged
  log_amount(l_n_charge_amount,'IGS_FI_CHG_AMNT');

  --If the student is not on an active payment, then only the following validation
  --related with charge creation date and latest bill generated cutoff date should happen.
  IF p_n_std_plan_id IS NULL THEN
    --validate input charge creation date with ths latest bill generated cutoff date
    OPEN cur_bill(p_n_person_id);
    FETCH cur_bill INTO l_cur_bill;
    IF cur_bill%FOUND THEN
      IF p_d_chg_crtn_dt < l_cur_bill.cut_off_date THEN
        fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_CHG_BILL'));
        p_b_chrg_flag := FALSE;
        CLOSE cur_bill;
        RETURN;
      END IF;
    END IF;
    CLOSE cur_bill;
  END IF;

  --If it is not a test run then creating charges, i.e p_test_flag='N'
  IF p_v_test_flag = 'N' THEN
    call_charges_api(p_cur_plan        => p_cur_plan,
                     p_person_id       => p_n_person_id,
                     p_charge_amount   => l_n_charge_amount,
                     p_chg_crtn_dt     => p_d_chg_crtn_dt,
                     p_cal_type        => p_v_cal_type,
                     p_sequence_number => p_n_sequence_number,
                     p_d_gl_date       => p_d_gl_date,
                     p_n_std_plan_id   => p_n_std_plan_id,
                     p_d_inst_due_date => p_d_inst_due_date,
                     p_b_chrg_flag     => l_b_chrg_flag
                    );
    --If charges api returns any error and the charge is not created,l_b_chrg_flag will be FALSE.
    --otherwise, l_b_chrg_flag will be TRUE.
    p_b_chrg_flag := l_b_chrg_flag;
  END IF;
END log_dtls_create_charge;

FUNCTION get_pp_cul_dly_bal(p_d_bal_start_dt   IN DATE,
                            p_n_open_bal       IN NUMBER,
                            p_n_std_plan_id    IN PLS_INTEGER) RETURN NUMBER AS
/***********************************************************************************************

  Created By     :  vvutukur, Oracle India.
  Date Created By:  18-Sep-2003
  Purpose        :  To calculate the cumulative daily balance.

  Known limitations,enhancements,remarks:
  Change History
  Who            When           What
********************************************************************************************** */
  CURSOR cur_get_inst_dtls(cp_n_std_plan_id NUMBER,
                           cp_d_bal_start_dt DATE
                           ) IS
    SELECT due_amt, due_date, (g_d_sysdate -(TRUNC(due_date)-1)) num_days
    FROM   igs_fi_pp_instlmnts
    WHERE  student_plan_id = cp_n_std_plan_id
    AND    TRUNC(due_date) BETWEEN TRUNC(cp_d_bal_start_dt) AND g_d_sysdate
    AND    due_amt > 0
    ORDER BY due_date;

  l_cur_get_inst_dtls  cur_get_inst_dtls%ROWTYPE;
  l_n_cul_bal          NUMBER;

BEGIN

  l_n_cul_bal := p_n_open_bal * ((g_d_sysdate - p_d_bal_start_dt) + 1);

  OPEN cur_get_inst_dtls(p_n_std_plan_id,p_d_bal_start_dt);
  LOOP
    FETCH cur_get_inst_dtls INTO l_cur_get_inst_dtls;
    EXIT WHEN cur_get_inst_dtls%NOTFOUND;
      l_n_cul_bal := l_n_cul_bal + NVL(l_cur_get_inst_dtls.due_amt,0) * NVL(l_cur_get_inst_dtls.num_days,0);
  END LOOP;
  CLOSE cur_get_inst_dtls;
  RETURN l_n_cul_bal;

END get_pp_cul_dly_bal;


FUNCTION det_payable_balance(p_person_id        IN    igs_fi_balances.party_id%TYPE,
                             p_cur_plan         IN    cur_plan%ROWTYPE,
                             p_batch_cutoff_dt  IN    DATE)
  RETURN NUMBER AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  Obtain the payable balance for a person .

  Known limitations,enhancements,remarks:
  Change History
  Who            When           What
  shtatiko       08-OCT-2002    Changed cur_get_bal so that it includes only information related to
                                FEE balance type.
********************************************************************************************** */
  CURSOR cur_get_bal IS
  SELECT fee_balance amount
  FROM    igs_fi_balances
  WHERE   party_id = p_person_id
  AND     balance_date <= p_batch_cutoff_dt
  AND     fee_balance IS NOT NULL
  ORDER BY balance_date DESC;

  l_cur_get_bal  cur_get_bal%ROWTYPE;

BEGIN
  OPEN cur_get_bal;
  FETCH cur_get_bal INTO l_cur_get_bal;
  IF cur_get_bal%NOTFOUND THEN
    CLOSE cur_get_bal;
    RETURN 0;
  ELSE
    CLOSE cur_get_bal;
    RETURN NVL(l_cur_get_bal.amount,0);
  END IF;
END det_payable_balance;

PROCEDURE calculate_late_fee_charge(p_overdue_bal           IN igs_fi_balances.standard_balance%TYPE,
                                    p_cur_plan              IN cur_plan%ROWTYPE,
                                    p_n_person_id           IN PLS_INTEGER,
                                    p_n_std_plan_id         IN PLS_INTEGER,
                                    p_d_chg_crtn_dt         IN DATE,
                                    p_v_fee_cal_type        IN VARCHAR2,
                                    p_n_fee_sequence_number IN PLS_INTEGER,
                                    p_d_gl_date             IN DATE,
                                    p_v_test_flag           IN VARCHAR2
                                   ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To obtain the amount for a late fee.

  Known limitations,enhancements,remarks:
  Change History
  Who        When         What
  vvutukur   17-Sep-2003  Enh#3045007.Payment Plans Build. Changes specific to Payment Plans TD.
  vchappid   04-Jun-2002  Bug# 2325427, for logging different messages when the overdue balance
                          is greater than minimum balance amount
********************************************************************************************** */

  CURSOR cur_get_instal_details(cp_n_person_id NUMBER,
                                cp_n_std_plan_id NUMBER,
                                cp_v_penalty_flag VARCHAR2,
                                cp_d_due_date DATE) IS
    SELECT pp.rowid,pp.*
    FROM   igs_fi_pp_instlmnts pp
    WHERE  pp.student_plan_id = cp_n_std_plan_id
    AND    TRUNC(pp.due_date) <= cp_d_due_date
    AND    pp.due_amt > 0
    AND    NVL(pp.penalty_flag,'N') = cp_v_penalty_flag;

  l_b_grt_min_bal_amt  BOOLEAN;
  l_n_charge_amount    NUMBER := 0;
  l_d_effective_dt     DATE;
  l_n_chg_rate         igs_fi_fin_lt_plan.payment_plan_chg_rate%TYPE;
  l_b_chrg_flag        BOOLEAN;
  l_b_inst_exists      BOOLEAN := FALSE;

BEGIN

  IF p_n_std_plan_id IS NULL THEN --if the person is NOT on an active payment plan..

    IF p_overdue_bal >= NVL(p_cur_plan.min_balance_amount,0) THEN
      l_b_grt_min_bal_amt := TRUE;
      IF p_cur_plan.accrual_type = g_v_flat_amt  THEN
        l_n_charge_amount := NVL(p_cur_plan.flat_amount,0);
      ELSIF p_cur_plan.accrual_type = g_v_flat_rate THEN
        l_n_charge_amount := ROUND((NVL(p_cur_plan.chg_rate,0) * p_overdue_bal)/100,2);
      END IF;
    ELSE
      -- overdue balance is less than the minimum balance amount
      l_b_grt_min_bal_amt := FALSE;
    END IF;

    --invoke the local procedure for generating the log and creating charge.
    log_dtls_create_charge(p_cur_plan          => p_cur_plan,
                           p_n_person_id       => p_n_person_id,
                           p_n_std_plan_id     => NULL,
                           p_b_grt_min_bal_amt => l_b_grt_min_bal_amt,
                           p_n_charge_amount   => l_n_charge_amount,
                           p_d_chg_crtn_dt     => p_d_chg_crtn_dt,
                           p_v_cal_type        => p_v_fee_cal_type,
                           p_n_sequence_number => p_n_fee_sequence_number,
                           p_d_gl_date         => p_d_gl_date,
                           p_d_inst_due_date   => NULL,
                           p_v_test_flag       => p_v_test_flag,
                           p_b_chrg_flag       => l_b_chrg_flag
                           );

  ELSE --if the person is on an active payment plan.

    --Get the effective date to get the installment details.
    IF p_cur_plan.offset_days IS NOT NULL THEN
      l_d_effective_dt := g_d_sysdate - p_cur_plan.offset_days;
    ELSE
      l_d_effective_dt := g_d_sysdate;
    END IF;

    --Check if the balance as on the determination date is greater than zero,
    --otherwise log error message.
    IF NVL(igs_fi_gen_008.get_plan_balance(p_n_std_plan_id,l_d_effective_dt),0) <= 0 THEN
      fnd_message.set_name('IGS','IGS_FI_NO_CHG_APP_DUE_DT');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RETURN;
    END IF;

    --Get the charge rate.If the payment plan charge rate is not defined at, get the default charge rate.
    l_n_chg_rate := NVL(NVL(p_cur_plan.payment_plan_chg_rate,p_cur_plan.chg_rate),0);

    l_b_inst_exists := FALSE;

    --for each installment due a charge needs to be created
    FOR rec_cur_get_inst_details IN cur_get_instal_details(p_n_person_id,p_n_std_plan_id,'N',l_d_effective_dt) LOOP

      l_b_inst_exists := TRUE;

      --If the installment due amount is greater than the minimum balance amount, then..
      IF (rec_cur_get_inst_details.due_amt > NVL(NVL(p_cur_plan.payment_plan_min_balance_amt,p_cur_plan.min_balance_amount),0))  THEN

        l_b_grt_min_bal_amt := TRUE;

        --Get the charge amount depending on the accrual type(If not defined at Payment Plan, get from Default).
        IF (NVL(p_cur_plan.payment_plan_accrl_type_code,p_cur_plan.accrual_type))= g_v_flat_amt THEN
          l_n_charge_amount := NVL(NVL(p_cur_plan.payment_plan_flat_amt,p_cur_plan.flat_amount),0);
        ELSIF (NVL(p_cur_plan.payment_plan_accrl_type_code, p_cur_plan.accrual_type)) = g_v_flat_rate THEN
          l_n_charge_amount := ROUND((l_n_chg_rate * rec_cur_get_inst_details.due_amt)/100,2);
        END IF;
      ELSE
        l_b_grt_min_bal_amt := FALSE;
      END IF;

      l_b_chrg_flag := FALSE;

      --invoke the local procedure for generating the log and creating charge.
      log_dtls_create_charge(  p_cur_plan          => p_cur_plan,
                               p_n_person_id       => p_n_person_id,
                               p_n_std_plan_id     => p_n_std_plan_id,
                               p_b_grt_min_bal_amt => l_b_grt_min_bal_amt,
                               p_n_charge_amount   => l_n_charge_amount,
                               p_d_chg_crtn_dt     => p_d_chg_crtn_dt,
                               p_v_cal_type        => p_v_fee_cal_type,
                               p_n_sequence_number => p_n_fee_sequence_number,
                               p_d_gl_date         => p_d_gl_date,
                               p_d_inst_due_date   => rec_cur_get_inst_details.due_date,
                               p_v_test_flag       => p_v_test_flag,
                               p_b_chrg_flag       => l_b_chrg_flag
                             );
      --Once the log is generated and charge is created, if the process is invoked with test run parameter as 'No',
      --then the penalty flag of the installment record should be updated to 'Y'.
      IF p_v_test_flag = 'N' AND l_b_chrg_flag THEN
      BEGIN
        igs_fi_pp_instlmnts_pkg.update_row(
                                       x_rowid                  => rec_cur_get_inst_details.rowid,
                                       x_installment_id         => rec_cur_get_inst_details.installment_id,
                                       x_student_plan_id        => rec_cur_get_inst_details.student_plan_id,
                                       x_installment_line_num   => rec_cur_get_inst_details.installment_line_num,
                                       x_due_day                => rec_cur_get_inst_details.due_day,
                                       x_due_month_code         => rec_cur_get_inst_details.due_month_code,
                                       x_due_year               => rec_cur_get_inst_details.due_year,
                                       x_due_date               => rec_cur_get_inst_details.due_date,
                                       x_installment_amt        => rec_cur_get_inst_details.installment_amt,
                                       x_due_amt                => rec_cur_get_inst_details.due_amt,
                                       x_penalty_flag           => 'Y',
                                       x_mode                   => 'R'
                                      );
      EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,SQLERRM);
      END;
      END IF;
    END LOOP;

    --If there are no installments considered for Late charge Calculation, log message.
    IF NOT l_b_inst_exists THEN
      fnd_message.set_name('IGS','IGS_FI_PP_LT_NO_RECS');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;
  END IF;

END calculate_late_fee_charge;




PROCEDURE calculate_finance_charge( p_cur_plan              IN  cur_plan%ROWTYPE,
                                    p_payable_bal           IN  igs_fi_balances.standard_balance%TYPE,
                                    p_overdue_bal           IN  igs_fi_balances.standard_balance%TYPE,
                                    p_batch_cutoff_dt       IN  DATE,
                                    p_batch_due_dt          IN  DATE,
                                    p_person_id             IN  igs_pe_person_v.person_id%TYPE,
                                    p_n_std_plan_id         IN  PLS_INTEGER,
                                    p_d_chg_crtn_dt         IN  DATE,
                                    p_v_fee_cal_type        IN  VARCHAR2,
                                    p_n_fee_sequence_number IN  PLS_INTEGER,
                                    p_d_gl_date             IN  DATE,
                                    p_v_test_flag           IN  VARCHAR2
                                  ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To obtain the amount for finance charge.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
  vvutukur   20-Sep-2003      Enh#3045007.Payment Plans Build. Changes specific to Payment Plans TD.
  shtatiko   17-DEC-2002      Enh# 2584741, Introduced l_adb_bal1
  vchappid   19-Apr-2002      Bug#2313147, Date comparisions are done after eliminating time component
********************************************************************************************** */
l_overdue_bal      igs_fi_balances.standard_balance%TYPE;
l_adb_start_dt     DATE;
l_adb_bal          igs_fi_balances.standard_balance%TYPE;
l_adb_total_bal    igs_fi_balances.standard_balance%TYPE := 0;
l_adb_track_dt     DATE;
l_adb_bal1         igs_fi_balances.standard_balance%TYPE := 0;

l_n_charge_amount  NUMBER := 0;
l_n_charge_rate    NUMBER := 0;
l_d_start_dt       DATE;
l_d_eff_date       DATE;

l_b_chrg_flag      BOOLEAN;

BEGIN

  l_n_charge_rate := NVL(p_cur_plan.chg_rate,0);

  --if the person is NOT on an Active Payment Plan..
  IF p_n_std_plan_id IS NULL THEN
    --calculate ADB bal and ADB start date depending upon accrual type
    IF p_cur_plan.accrual_type = g_v_cutoff_dt THEN
      l_adb_bal := p_payable_bal;
      l_adb_start_dt := p_batch_cutoff_dt + 1;
    ELSIF p_cur_plan.accrual_type = g_v_due_dt THEN
      IF p_cur_plan.offset_days > 0 THEN
        calc_red_balance(p_person_id    => p_person_id,
                         p_bal_start_dt => p_batch_cutoff_dt + 1,
                         p_bal_end_dt   => p_batch_due_dt,
                         p_bal_type     => p_cur_plan.balance_type,
                         p_open_bal     => p_payable_bal,
                         p_red_bal      => l_overdue_bal
                         );
        l_adb_bal := l_overdue_bal;
      ELSE
        l_adb_bal := p_overdue_bal;
      END IF;
      l_adb_start_dt := p_batch_due_dt + 1;
    END IF;

    l_adb_total_bal := 0;
    l_adb_track_dt  := l_adb_start_dt;

    WHILE l_adb_track_dt <= g_d_sysdate LOOP
      -- Introduced dummy variable l_adb_bal1 to hold the output of the procedure.
      -- If l_adb_bal is also passed as OUT variable, then it will be made NULL.
      -- This has been done as part of Enh# 2584741, Deposits by shtatiko.
      calc_red_balance(p_person_id    => p_person_id,
                       p_bal_start_dt => l_adb_track_dt,
                       p_bal_end_dt   => l_adb_track_dt,
                       p_bal_type     => p_cur_plan.balance_type,
                       p_open_bal     => l_adb_bal,
                       p_red_bal      => l_adb_bal1
                       );
      l_adb_bal := l_adb_bal1;
      EXIT WHEN l_adb_bal <= 0;
      l_adb_total_bal := l_adb_total_bal + l_adb_bal;
      l_adb_track_dt := l_adb_track_dt + 1;
    END LOOP;

  ELSE  --if the person is on an Active Payment Plan..

    --Check if offset days is provided, if provided then..
    IF p_cur_plan.offset_days IS NOT NULL THEN
      --Deduct offset days from the system date and assign the date to the local variable.
      l_d_eff_date := g_d_sysdate - p_cur_plan.offset_days;
    ELSE
      --if offset days is not provided, then assign system date to the local variable.
      l_d_eff_date := g_d_sysdate;
    END IF;

    --If the outstanding balance as on the above calculated start date is less than or equal to 0,
    --then log the error message and return from this procedure.
    IF NVL(igs_fi_gen_008.get_plan_balance(p_n_std_plan_id,l_d_eff_date),0) <= 0 THEN
      fnd_message.set_name('IGS','IGS_FI_NO_CHG_APP_DUE_DT');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RETURN;
    END IF;

    IF (NVL(p_cur_plan.payment_plan_accrl_type_code,p_cur_plan.accrual_type) = g_v_cutoff_dt) THEN
      l_d_start_dt := p_batch_cutoff_dt +1;
    ELSIF (NVL(p_cur_plan.payment_plan_accrl_type_code,p_cur_plan.accrual_type) = g_v_due_dt) THEN
      l_d_start_dt := p_batch_due_dt+1;
    END IF;

    l_adb_total_bal := get_pp_cul_dly_bal(p_d_bal_start_dt => l_d_start_dt,
                                          p_n_open_bal     => p_payable_bal,
                                          p_n_std_plan_id  => p_n_std_plan_id
                                          );

    IF p_cur_plan.payment_plan_chg_rate IS NOT NULL THEN
      l_n_charge_rate := p_cur_plan.payment_plan_chg_rate;
    END IF;
  END IF;

  l_n_charge_amount := ROUND((l_n_charge_rate * l_adb_total_bal)/100,2);

  --invoke the local procedure for creating a charge and generating the log.
  log_dtls_create_charge(p_cur_plan          => p_cur_plan,
                         p_n_person_id       => p_person_id,
                         p_n_std_plan_id     => p_n_std_plan_id,
                         p_b_grt_min_bal_amt => TRUE,
                         p_n_charge_amount   => l_n_charge_amount,
                         p_d_chg_crtn_dt     => p_d_chg_crtn_dt,
                         p_v_cal_type        => p_v_fee_cal_type,
                         p_n_sequence_number => p_n_fee_sequence_number,
                         p_d_gl_date         => p_d_gl_date,
                         p_d_inst_due_date   => NULL,
                         p_v_test_flag       => p_v_test_flag,
                         p_b_chrg_flag       => l_b_chrg_flag
                         );

END calculate_finance_charge;


PROCEDURE calculate_charge(
                   p_person_id        IN    igs_pe_person_v.person_id%TYPE ,
                   p_batch_cutoff_dt  IN    DATE,
                   p_batch_due_dt     IN    DATE,
                   p_chg_crtn_dt      IN    DATE ,
                   p_test_flag        IN    VARCHAR2,
                   p_cur_plan         IN    cur_plan%ROWTYPE,
                   p_cal_type         IN    igs_fi_f_typ_ca_inst_v.fee_cal_type%TYPE,
                   p_sequence_number  IN    igs_fi_f_typ_ca_inst_v.fee_ci_sequence_number%TYPE,
                   p_d_gl_date        IN    igs_fi_credits_all.gl_date%TYPE,
                   p_n_std_plan_id    IN    PLS_INTEGER
                  ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  To calculate the charge for a particular person

  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  vvutukur  20-Sep-2003  Enh#3045007.Payment Plans Build. Changes specific to Payment Plans TD.
  vvutukur  24-Nov-2002  Enh#2584986.Added p_d_gl_date parameter and passed the same to the call to call_charges_api.
  shtatiko  08-Oct-2002  Bug# 2562745, Added call to calculate_balance
  vchappid  03-Jun-2002  Bug# 2325427, Customized messages are shown to the user when there is no charge to create
  vchappid   19-Apr-2002 Bug#2313147 Billing Cutoff date comparision with the Charge Creation Date is Corrected
SYKRISHN    05-APR-2002 - SFCR018 Build - Planned Credits- 2293676 - to include planned credits also while deriving payable balance.!
********************************************************************************************** */

l_offset_date   DATE;
l_payable_bal   igs_fi_balances.standard_balance%TYPE;
l_overdue_bal   igs_fi_balances.standard_balance%TYPE;

l_flg_cont  BOOLEAN := TRUE;

l_grt_min_bal_amt BOOLEAN := TRUE;

-- Changes due to SFCR018
 -- Call the local function to get the value of planned_credits_ind
  l_v_pln_cr_ind igs_fi_control_all.planned_credits_ind%TYPE := get_planned_credits_ind;
  l_v_pln_cr_message fnd_new_messages.message_name%TYPE  :=  NULL;
  l_n_planned_credit igs_fi_credits.amount%TYPE  :=  0;
--changes due to Enh#2562745.
  l_message_name fnd_new_messages.message_name%TYPE;
  l_balance_amount igs_fi_balances.standard_balance%TYPE; --This variable ignored in the following call.
  l_d_eff_date     DATE;
  l_d_inst_due_date DATE;

BEGIN
  --if the person is NOT on an Active Payment Plan..
  IF p_n_std_plan_id IS NULL THEN
    --call calculate_balance procedure. This call is added as part of Enh#2562745.
    igs_fi_prc_balances.calculate_balance ( p_person_id => p_person_id,
                                            p_balance_type => 'FEE',
                                            p_balance_date => p_batch_cutoff_dt,
                                            p_action => 'ASONBALDATE',
                                            p_balance_rule_id => g_balance_rule_id,
                                            p_balance_amount => l_balance_amount,
                                            p_message_name => l_message_name );
    --If any message is returned, log that and error out.
    IF l_message_name IS NOT NULL THEN
      fnd_file.new_line(fnd_file.log);
      fnd_message.set_name('IGS',l_message_name);
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      RAISE l_validation_exp;
    END IF;

    --Get the payable balance
    l_payable_bal:= det_payable_balance(p_person_id ,p_cur_plan, p_batch_cutoff_dt );

    -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'
    IF l_v_pln_cr_ind = 'Y' THEN
      --Call the generic function to get the total planned credits for the params passed.
      l_n_planned_credit := igs_fi_gen_001.finp_get_total_planned_credits(
                                                                  p_person_id => p_person_id,
                                                                  p_start_date => NULL,
                                                                  p_end_date => p_batch_cutoff_dt,
                                                                  p_message_name => l_v_pln_cr_message);
      IF l_v_pln_cr_message IS NOT NULL THEN
        fnd_message.set_name('IGS',l_v_pln_cr_message);
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(fnd_file.log,' ');
      ELSE
        -- When no errors reduce the payable balance with the sum of planned credits.
        l_payable_bal := l_payable_bal - NVL(l_n_planned_credit,0);
      END IF;
    END IF;
    -- Changes due to SFCR018 - To include planned credits also when the indicator is set as 'Y'

    -- Balance as on the Batch Cutoff Date is less than or equal to Zero
    IF l_payable_bal <= 0 THEN
      fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_NO_CHG_APP_BT_CUT_OFF'));
      RETURN;
    END IF;

    --Determining the overdue balance as on the offset date
    l_offset_date := p_batch_due_dt + NVL(p_cur_plan.offset_days,0);
    calc_red_balance(p_person_id    => p_person_id,
                     p_bal_start_dt => p_batch_cutoff_dt + 1,
                     p_bal_end_dt   => l_offset_date,
                     p_bal_type     => p_cur_plan.balance_type,
                     p_open_bal     => l_payable_bal,
                     p_red_bal      => l_overdue_bal
                     );
    -- Overdue Balance as of the offset date is less than or equal to zero
    IF l_overdue_bal <= 0 THEN
      fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_NO_CHG_APP_DUE_DT'));
      RETURN;
    END IF;

  ELSE  --if the person is on an Active Payment Plan..

    --Log the message that the Student is on an Active Payment Plan.
    fnd_message.set_name('IGS','IGS_FI_PP_PRSN_ON_PP');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.new_line(fnd_file.log);

    --If the plan type is 'Finance' then..
    IF p_cur_plan.plan_type = g_v_finance THEN

      --If the payment plan accrual type is Average Daily Balance Cutoff Date..
      IF NVL(p_cur_plan.payment_plan_accrl_type_code,p_cur_plan.accrual_type) = g_v_cutoff_dt THEN
        --Assign batch cutoff date to the the local variable.
        l_d_eff_date := p_batch_cutoff_dt;
      --If the payment plan accrual type is Average Daily Balance Cutoff Date..
      ELSIF NVL(p_cur_plan.payment_plan_accrl_type_code,p_cur_plan.accrual_type) = g_v_due_dt THEN
        --Assign batch due date to the the local variable.
        l_d_eff_date := p_batch_due_dt;
      END IF;

      --Get the Installment Balance passing the local variable l_d_eff_date value to p_d_effective_date parameter.
      --and student active plan id.
      l_payable_bal := igs_fi_gen_008.get_plan_balance(p_n_act_plan_id    => p_n_std_plan_id,
                                                       p_d_effective_date => l_d_eff_date
                                                       );
      IF l_payable_bal <= 0 THEN
        --Log different messages in the log file depending on accrual type.
        IF NVL(p_cur_plan.payment_plan_accrl_type_code,p_cur_plan.accrual_type) = g_v_cutoff_dt THEN
          fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_NO_CHG_APP_BT_CUT_OFF'));
          RETURN;
        ELSIF NVL(p_cur_plan.payment_plan_accrl_type_code,p_cur_plan.accrual_type) = g_v_due_dt THEN
          fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_PP_INST_NO_AMT_DUE'));
          RETURN;
        END IF;
      END IF;

      --If the Student is on an Active Payment Plan, assign the Installment Balance calculated as above,
      --to overdue balance.
      l_overdue_bal := l_payable_bal;
    END IF;
  END IF;

  --Proceed with the processing
  IF p_cur_plan.plan_type = g_v_late THEN
    --Call the below procedure to calculate late fee charge(s).
    calculate_late_fee_charge(p_overdue_bal           => l_overdue_bal,
                              p_cur_plan              => p_cur_plan,
                              p_n_person_id           => p_person_id,
                              p_n_std_plan_id         => p_n_std_plan_id,
                              p_d_chg_crtn_dt         => p_chg_crtn_dt,
                              p_v_fee_cal_type        => p_cal_type,
                              p_n_fee_sequence_number => p_sequence_number,
                              p_d_gl_date             => p_d_gl_date,
                              p_v_test_flag           => p_test_flag
                              );
  ELSIF p_cur_plan.plan_type = g_v_finance THEN
    --Call the below procedure to calculate finance charge.
    calculate_finance_charge( p_cur_plan              => p_cur_plan,
                              p_payable_bal           => l_payable_bal,
                              p_overdue_bal           => l_overdue_bal,
                              p_batch_cutoff_dt       => p_batch_cutoff_dt,
                              p_batch_due_dt          => p_batch_due_dt,
                              p_person_id             => p_person_id,
                              p_n_std_plan_id         => p_n_std_plan_id,
                              p_d_chg_crtn_dt         => p_chg_crtn_dt,
                              p_v_fee_cal_type        => p_cal_type,
                              p_n_fee_sequence_number => p_sequence_number,
                              p_d_gl_date             => p_d_gl_date,
                              p_v_test_flag           => p_test_flag
                            );
  END IF;

END calculate_charge;


PROCEDURE calc_fin_lt_charge(
                   errbuf             OUT NOCOPY   VARCHAR2,
                   retcode            OUT NOCOPY   NUMBER,
                   p_person_id        IN    igs_pe_person.person_id%TYPE,
                   p_pers_id_grp_id   IN    igs_pe_persid_group.group_id%TYPE,
                   p_plan_name        IN    igs_fi_fin_lt_plan.plan_name%TYPE ,
                   p_batch_cutoff_dt  IN    VARCHAR2,
                   p_batch_due_dt     IN    VARCHAR2,
                   p_fee_period       IN    VARCHAR2,
                   p_chg_crtn_dt      IN    VARCHAR2,
                   p_test_flag        IN    VARCHAR2,
                   p_d_gl_date        IN    VARCHAR2
                 ) AS
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  05-Dec-2001
  Purpose        :  The main current program procedure, which validates all parameters and computes
                    charges one person after another

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
  sapanigr   13-Feb-2006      Bug 5018036 - Modified cur_fee to reference base table igs_fi_f_typ_ca_inst_all and igs_ca_inst ci.
                              It was earlier using igs_fi_f_typ_ca_inst_lkp_v.
  pmarada    01-sep-04        bug 3687308 - Enforcing user to pass either person id or personid group
  pathipat   26-Apr-2004      Bug 3578249 - Modified cursor cur_yes_no - Replaced fnd_lookup_values
                              with igs_lookup_values, changed lookup_type to YES_NO from SYS_YES_NO
                              Changed code related to p_test_flag to check for Y and N instead of 1 and 2 respectively.
  vvutukur   20-Jan-2004      Bug#3348787.Modified cursor cur_yes_no.
  vvutukur   17-Sep-2003      Enh#3045007.Payment Plans Build. Changes specific to Payment Plans TD.
  shtatiko   22-APR-2003      Enh# 2831569, Added check for Manage Accounts System Option.
  vvutukur   12-Feb-2003      Bug#2731357.As p_chg_crtn_dt parameter is made mandatory,displayed error message
                              if it is null.
  shtatiko   10-JAN-2003      Bug# 2731350, used user defined exception instead of using generic exception
                              (app_exception.raise_exception)
  vvutukur   24-Nov-2002      Enh#2584986.Added p_d_gl_date parameter to calc_fin_lt_charge procedure and
                              corresponding validations.Modified the calls to procedure calculate_charge to include
                              p_d_gl_date parameter also.
  shtatiko   08-OCT-2002      Bug#2562745, check for Holds Balance Process running is added.
  vchappid   19-Apr-2002      Bug#2313147, Date comparisions are done after eliminating time component
********************************************************************************************** */

  --Ref cursor variable.
  l_cur_ref cur_ref;

  l_v_person_number igs_fi_parties_v.person_number%TYPE := NULL;

  CURSOR cur_fee(cp_fee_type  igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                 cp_fee_cal_type igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                 cp_fee_ci_sequence_number igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE) IS
  SELECT ci.start_dt start_dt,ci.end_dt end_dt
  FROM   igs_fi_f_typ_ca_inst_all ftci, igs_ca_inst ci
  WHERE  ftci.fee_type=cp_fee_type
  AND    ftci.fee_cal_type=cp_fee_cal_type
  AND    ftci.fee_ci_sequence_number=cp_fee_ci_sequence_number
  AND    ci.cal_type = ftci.fee_cal_type
  AND    ci.sequence_number = ftci.fee_ci_sequence_number;
  l_cur_fee         cur_fee%ROWTYPE;

  CURSOR cur_yes_no IS
  SELECT meaning
  FROM   igs_lookup_values
  WHERE  lookup_type = 'YES_NO'
  AND    lookup_code = p_test_flag;

  l_cur_yes_no      cur_yes_no%ROWTYPE;

  l_cur_plan        cur_plan%ROWTYPE;
  l_offset_date     DATE;
  l_batch_cutoff_dt DATE;
  l_batch_due_dt    DATE;
  l_chg_crtn_dt     DATE;
  l_cal_type        igs_fi_f_typ_ca_inst_lkp_v.fee_cal_type%TYPE;
  l_sequence_number igs_fi_f_typ_ca_inst_lkp_v.fee_ci_sequence_number%TYPE;
  l_record_count NUMBER :=0;
--Added the following as part of Enh# 2562745.
  l_conv_process_run_ind igs_fi_control.conv_process_run_ind%TYPE;
  l_message_name fnd_new_messages.message_name%TYPE;

  l_v_closing_status       gl_period_statuses.closing_status%TYPE;
  l_d_gl_date    igs_fi_credits_all.gl_date%TYPE;
  l_v_message_name         fnd_new_messages.message_name%TYPE;
  l_v_manage_accounts     igs_fi_control.manage_accounts%TYPE;

  l_n_person_id           igs_fi_parties_v.person_id%TYPE;
  l_v_sql                 VARCHAR2(32767);
  l_v_status              VARCHAR2(1);
  l_n_act_plan_id         igs_fi_pp_std_attrs.student_plan_id%TYPE;
  l_v_act_plan_name       igs_fi_pp_std_attrs.payment_plan_name%TYPE;

BEGIN

--Create a Savepoint for Rollback.
  SAVEPOINT s_calc_fin_lt_charge;

  IGS_GE_GEN_003.set_org_id(NULL) ;           --  sets the orgid
  retcode := 0 ;                              -- initialises the out NOCOPY parameter to 0

  -- Check the value of Manage Accounts System Option value.
  -- If its NULL or OTHER then this process should error out by logging message.
  igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                p_v_message_name => l_v_message_name );
  IF l_v_manage_accounts IS NULL OR l_v_manage_accounts = 'OTHER' THEN
    fnd_message.set_name ( 'IGS', l_v_message_name );
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
    RAISE l_validation_exp;
  END IF;

--Check whether Holds Balance Conversion Process is running or not. If yes, Error out.

  igs_fi_gen_007.finp_get_conv_prc_run_ind ( p_n_conv_process_run_ind => l_conv_process_run_ind,
                                             p_v_message_name => l_message_name );
  IF ((l_conv_process_run_ind IS NOT NULL) AND (l_conv_process_run_ind = 1)) THEN
    fnd_file.new_line(fnd_file.log);
    fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    RAISE l_validation_exp;
  ELSIF ((l_message_name IS NOT NULL) AND (l_conv_process_run_ind IS NULL)) THEN
    fnd_file.new_line(fnd_file.log);
    fnd_message.set_name('IGS',l_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get());
    RAISE l_validation_exp;
  END IF;

--Logging the parameters
  IF p_person_id IS NOT NULL THEN
    l_v_person_number := igs_fi_gen_008.get_party_number(p_n_party_id => p_person_id);
  END IF;

  OPEN cur_yes_no ;
  FETCH  cur_yes_no INTO l_cur_yes_no;
  CLOSE cur_yes_no;

  --Getting the plan information in the record l_cur_plan
  OPEN cur_plan(p_plan_name);
  FETCH cur_plan INTO l_cur_plan;
  CLOSE cur_plan;

  --Getting cal type and  sequence number
  l_cal_type :=RTRIM(SUBSTR(p_fee_period ,1,10));
  l_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_fee_period,12)));

  --Converting the date parameter
  l_batch_cutoff_dt := igs_ge_date.igsdate(p_batch_cutoff_dt);
  l_batch_due_dt    := igs_ge_date.igsdate(p_batch_due_dt);

  --Conversion of p_d_gl_date from VARCHAR2 data type to DATE data type.
  l_d_gl_date  := igs_ge_date.igsdate(p_d_gl_date);

  --Conversion of p_chg_crtn_dt from VARCHAR2 datatype to DATE data type.
  l_chg_crtn_dt  := igs_ge_date.igsdate(p_chg_crtn_dt);

  OPEN cur_fee(l_cur_plan.fee_type,l_cal_type,l_sequence_number);
  FETCH cur_fee INTO l_cur_fee;
  CLOSE cur_fee;

  fnd_message.set_name('IGS','IGS_FI_ANC_LOG_PARM');
  fnd_file.put_line(fnd_file.log,fnd_message.get||':');
  fnd_file.new_line(fnd_file.log);

  log_messages(lookup_desc('IGS_FI_LOCKBOX','PARTY'),l_v_person_number);
  log_messages(lookup_desc('IGS_FI_LOCKBOX','PERSON_GROUP'),TO_CHAR(p_pers_id_grp_id));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','PLAN_NAME'),p_plan_name);
  log_messages(lookup_desc('IGS_FI_LOCKBOX','BATCH_CUTOFF_DT'),TO_CHAR(l_batch_cutoff_dt,'DD-MM-YYYY'));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','BATCH_DUE_DT'),TO_CHAR(l_batch_due_dt,'DD-MM-YYYY'));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','FEE_PERIOD'),
               TO_CHAR(l_cur_fee.start_dt,'DD-MM-YYYY')||'  '||TO_CHAR(l_cur_fee.end_dt,'DD-MM-YYYY'));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','CHG_CREATION_DT'),TO_CHAR(l_chg_crtn_dt,'DD-MM-YYYY'));
  log_messages(lookup_desc('IGS_FI_LOCKBOX','TEST_MODE'),l_cur_yes_no.meaning);
  log_messages(lookup_desc('IGS_FI_LOCKBOX','GL_DATE'),l_d_gl_date);

  fnd_file.put_line(fnd_file.log,g_v_hor_line);

-- In following validations removed call to generic, app_exception.raise_exception
-- and added user defined exception, l_validation_exp. As we are not putting message onto
-- stack, used fnd_file.put_line to log messages. This has been done by shtatiko as part
-- of Bug# 2731350
--Validating if all the mandatory parameter are passed
  IF ((p_plan_name IS NULL) OR (p_batch_cutoff_dt IS NULL) OR (p_batch_due_dt IS NULL)
                                   OR (p_fee_period IS NULL) OR (p_test_flag IS NULL) OR (p_chg_crtn_dt IS NULL) ) THEN
    fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
    fnd_file.put_line ( fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;


--Validating person Id and person id group cannot be present at a same time
  IF p_person_id IS NOT NULL AND p_pers_id_grp_id IS NOT NULL THEN
    fnd_message.set_name('IGS','IGS_FI_PRS_OR_PRSIDGRP');
    fnd_file.put_line ( fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;

-- Either person Id or person id group should be passed as a parameter
  IF p_person_id IS NULL AND p_pers_id_grp_id IS NULL THEN
    fnd_message.set_name('IGS','IGS_FI_PRS_PRSIDGRP_NULL');
    fnd_file.put_line ( fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;

--Validating person id group
  IF p_pers_id_grp_id IS NOT NULL THEN
    IF NOT validate_persid_grp(p_pers_id_grp_id) THEN
      fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      fnd_file.put_line ( fnd_file.log, fnd_message.get );
      RAISE l_validation_exp;
    END IF;
  END IF;

--Validating person id
  IF p_person_id IS NOT NULL THEN
    IF igs_fi_gen_007.validate_person(p_person_id)= 'N' THEN
      fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      fnd_file.put_line ( fnd_file.log, fnd_message.get );
      RAISE l_validation_exp;
    END IF;
  END IF;

--Validating Plan Name
  IF NOT validate_plan_name(p_plan_name) THEN
    fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
    fnd_file.put_line ( fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;

--Validating cut off date with due date
  IF l_batch_cutoff_dt >= l_batch_due_dt THEN
    fnd_message.set_name('IGS','IGS_FI_CTDT_DUEDT');
    fnd_file.put_line ( fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;

--Validating charge creation date with cut off date
  IF l_batch_cutoff_dt >= l_chg_crtn_dt THEN
    fnd_message.set_name('IGS','IGS_FI_CTDT_CHG_DT');
    fnd_file.put_line ( fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;


--Validating FTCI
  IF NOT validate_ftci(l_cur_plan,l_cal_type,l_sequence_number) THEN
    fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
    fnd_file.put_line ( fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;

  --GL date parameter is mandatory, hence if passed as null, error out NOCOPY of the concurrent job.
  IF p_d_gl_date IS NULL THEN
    fnd_message.set_name('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
    fnd_file.put_line(fnd_file.log, fnd_message.get );
    RAISE l_validation_exp;
  END IF;

  --Validate the GL Date.
  igs_fi_gen_gl.get_period_status_for_date(p_d_date            => l_d_gl_date,
                                           p_v_closing_status  => l_v_closing_status,
                                           p_v_message_name    => l_v_message_name
                                           );
  IF l_v_message_name IS NOT NULL THEN
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_validation_exp;
  END IF;

  --Error out NOCOPY the concurrent process if the GL Date is not a valid one.
  IF l_v_closing_status IN ('C','N','W') THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_GL_DATE');
    fnd_message.set_token('GL_DATE',l_d_gl_date);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE l_validation_exp;
  END IF;

  --Logging the plan information
  log_plan_info(l_cur_plan,l_batch_cutoff_dt,l_batch_due_dt,l_cal_type,l_sequence_number,l_batch_due_dt);

  --Validating offset date >= sysdate
  l_offset_date := l_batch_due_dt + NVL(l_cur_plan.offset_days,0);
  IF l_offset_date  >= g_d_sysdate THEN
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_DUDT_OFFST'));
  ELSE
    --Find the latest balance rule id for the balance type FEE.Return values last_conversion_date and
    --version number are ignored by passing null.

    --Added this call to finp_get_balance_rule as part of Bug#2562745. g_balance_rule_id is used
    --in calculate_charge. This is done here because this should be called only once irrespopective of
    --number of persons.

    igs_fi_gen_007.finp_get_balance_rule ( p_v_balance_type => 'FEE',
                                           p_v_action => 'MAX',
                                           p_n_balance_rule_id => g_balance_rule_id,
                                           p_d_last_conversion_date => g_last_conversion_date,
                                           p_n_version_number => g_version_number );

    --Proceed with the processing
    --when person id is provided
    IF p_person_id IS NOT NULL THEN
      log_person(p_person_id);
      l_record_count := l_record_count + 1;

      --Get the Student's Active Payment Plan Details.
      igs_fi_gen_008.get_plan_details(p_n_person_id     => p_person_id,
                                      p_n_act_plan_id   => l_n_act_plan_id,
                                      p_v_act_plan_name => l_v_act_plan_name
                                      );

      --Call the local procedure which does the processing for creation of Finanace/Late Charge.
      calculate_charge( p_person_id        => p_person_id,
                        p_batch_cutoff_dt  => l_batch_cutoff_dt,
                        p_batch_due_dt     => l_batch_due_dt,
                        p_chg_crtn_dt      => l_chg_crtn_dt,
                        p_test_flag        => p_test_flag,
                        p_cur_plan         => l_cur_plan,
                        p_cal_type         => l_cal_type,
                        p_sequence_number  => l_sequence_number,
                        p_d_gl_date        => l_d_gl_date,
                        p_n_std_plan_id    => l_n_act_plan_id
                       );

    --when person group id is provided
    ELSIF p_pers_id_grp_id IS NOT NULL THEN
      --For the Person Group passed as input to the process, identify all the Persons that are members of this group
      --using generic function.
      l_v_sql := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_groupid => p_pers_id_grp_id,
                                                                 p_status  => l_v_status
                                                                 );
      --If the sql returned is invalid.. then,
      IF l_v_status <> 'S' THEN
        --Log the error message and stop processing.
        fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.put_line(fnd_file.log,l_v_sql);
        retcode := 2;
        RETURN;
      END IF;

      --Execute the sql statement using ref cursor.
      OPEN l_cur_ref FOR l_v_sql;
      LOOP
        --Capture the person id into a local variable l_n_person_id.
        FETCH l_cur_ref INTO l_n_person_id;
        EXIT WHEN l_cur_ref%NOTFOUND;
        log_person(l_n_person_id);
        l_record_count := l_record_count + 1;

        l_n_act_plan_id := NULL;
        l_v_act_plan_name := NULL;

        --Get the Student's Active Payment Plan Details.
        igs_fi_gen_008.get_plan_details(p_n_person_id     => l_n_person_id,
                                        p_n_act_plan_id   => l_n_act_plan_id,
                                        p_v_act_plan_name => l_v_act_plan_name
                                        );

        --Call the local procedure which does the processing for creation of Finanace/Late Charge.
        calculate_charge( p_person_id        => l_n_person_id,
                          p_batch_cutoff_dt  => l_batch_cutoff_dt,
                          p_batch_due_dt     => l_batch_due_dt,
                          p_chg_crtn_dt      => l_chg_crtn_dt,
                          p_test_flag        => p_test_flag,
                          p_cur_plan         => l_cur_plan,
                          p_cal_type         => l_cal_type,
                          p_sequence_number  => l_sequence_number,
                          p_d_gl_date        => l_d_gl_date,
                          p_n_std_plan_id    => l_n_act_plan_id
                         );
      END LOOP;
      CLOSE l_cur_ref;
    END IF;   -- End if for personid or personid group not null
  END IF;

-- Rollback to the savepoint created if process is in test run mode.
  IF ( p_test_flag = 'Y' ) THEN -- i.e., If its in TEST mode.
    ROLLBACK TO s_calc_fin_lt_charge;
  END IF;

  fnd_file.put_line(fnd_file.log,g_v_hor_line);
  fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_GE_TOTAL_REC_PROCESSED')||TO_CHAR(l_record_count));
  fnd_file.put_line(fnd_file.log,g_v_hor_line);
  fnd_file.new_line(fnd_file.log);


  EXCEPTION
    WHEN l_validation_exp THEN
      retcode := 2;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
      igs_ge_msg_stack.conc_exception_hndl;
END calc_fin_lt_charge;

END igs_fi_prc_fin_lt_chg;

/
