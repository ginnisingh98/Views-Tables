--------------------------------------------------------
--  DDL for Package Body HR_USER_INIT_EARN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_USER_INIT_EARN" AS
/* $Header: pyusuiet.pkb 120.2 2005/09/23 00:04:53 saurgupt noship $ */
/*******************************************************************
  *                                                                *
  *  Copyright (C) 1993 Oracle Corporation.                        *
  *  All rights reserved.                                          *
  *                                                                *
  *  This material has been provided pursuant to an agreement      *
  *  containing restrictions on its use.  The material is also     *
  *  protected by copyright law.  No part of this material may     *
  *  be copied or distributed, transmitted or transcribed, in      *
  *  any form or by any means, electronic, mechanical, magnetic,   *
  *  manual, or otherwise, or disclosed to third parties without   *
  *  the express written permission of Oracle Corporation,         *
  *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
  *                                                                *
  ******************************************************************

    Name        : hr_pyusuiet
    Filename    : pyusuiet.pkb
    Change List
    -----------
    Date        Name            Vers    Bug No  Description
    ----        ----            ----    ------  -----------
    21-SEP-93   H.Parichabutr   1.0             First Created.
                                                Initial Procedures
    01-NOV-93   hparicha        1.1             Replaced calls to "benchmark"
                                                with calls to custom
                                                "pay_formula_results" for
                                                status proc and result rule
                                                building blocks.
    05-NOV-93   hparicha        1.2             Populates element type SCL.
    07-NOV-93   hparicha        1.3             Defaults input value for
                                                "Deduction Processing" inpval
                                                based on new radio group in
                                                PAYSUDEE.
                                                "Standard" processing rule
                                                now uses NULL asst status type.
    25-FEB-94   hparicha        40.18   G581    "Negative Earnings" fn'ality.
                                                General cleanup of code.
    17-MAR-94   hparicha        40.19   G604    Call "create_gross_up".
                                                'Date Earned' now on all earns.
    01-JUN-94   hparicha        40.20   G815    MIX Category param for new
                                                DDF segment.
    09-JUN-94   hparicha        40.21   G907    New implementation of Earnings
                                                without the use of UPDREE
                                                formula result rule type.
    07-JUL-94   hparicha                        "Date Earned" changed to
                                                "Earned Date".
    03-AUG-94   hparicha        40.5    G1188   Supplemental Earnings should
                                                automatically get 'Sep Check'
                                                and 'Dedn Proc' inpvals.
    22-AUG-94   hparicha        40.6    G1241   More defined balances req'd
                                                for view earnings screen.
                                                Update element type DDF with
                                                associated balances.
    21-SEP-94   hparicha        40.7    G1343   Feed "Earnings 401k" balance
                                                when Class/Cat = Earnings/Reg
                                                or Supp/Bonus-Comm.
    26-SEP-94   hparicha        40.8    G1201   Add "_GRE_YTD" defined bal for
                                                Primary bal - used in summary
                                                reports.
    22-NOV-94   hparicha        40.12   G1529   Fixes for decoupling decoupling
                                        G1601   "Deduction Processing" inpval
                                                from Separate Check processing.
    19-DEC-94   hparicha        40.13   G1564   New calculation of OT Base Rate
    18-JAN-95   hparicha        40.14   G1565   New associated balance for
                                                "Earnings Hours" needs to be
                                                created and associated when
                                                an earnings has an "Hours"
                                                input value.
                                                Also making change for when
                                                "Non-Payroll Payments" are
                                                generated - ie. dbitem names
                                                clash b/c defined balance
                                                with "Payments" dimension
                                                has same name as dbi created
                                                for element type (ELE_COUNT,
                                                ELE_PAY_VALUE, etc...)
    23-FEB-95   allee                           Changed "Earned Date" to
                                                "Date Earned"
    02-MAR-95   spanwar                         Added call to category feeder
                                                in insert bal feeds section.
    05-MAY-95   allee                           Added session date to
                                                category feeder call
    15-JUN-95   hparicha        40.21           Use "associated balance" ids
                                                for deletion of those balances.
                                                New params for do_deletions.
                                                Clean up select count(*)'s
                                                by using exceptions.
    21-JUN-95   hparicha        40.22           Comment out call to
                                                pay_db_pay_us_gross.
    29-JUN-95   hparicha        40.23           Defined balances are
                                                required for "_ASG_GRE_RUN/
                                                PTD/MONTH/QTD/YTD" - and
                                                also for PER and PER_GRE.
    17-OCT-95   hparicha        40.26   315814  Added call to bal type pkg
                                                to check for uniqueness of
                                                "Primary Associated Balance"
                                                name - ie. has same name as
                                                element type being generated.
09-JAN-96   hparicha        40.27   133133  Added defined balances for
                                            Primary associated bal of
                                            GRE_ITD and GRE_RUN.  Enables
                                            company-level reports on earnings.
16-FEB-96   hparicha        40.28           Added "PAYMENTS" defined bal to
                                            Hours associated balance.
01-APR-96   hparicha 40.29   348658  Added element type id to Indirect formula
                                     result rules... enabling Formula Results
                                     screen to display element name.
21-APR-1996 hparicha 40.30   337007  Added reducing input values on
                             340391  Special Features to feed
                                     regular hours worked and
                                     regsal/wages hours balances...
                                     Also added feeds reducing reg pay bals
                                     when p_reduce_regular = Yes.
                                     ie. reduce regular from paid absences.
                                     Added param for p_reduce_regular, new
                                     seggie on ele type ddf.  Create appropriate
                                     feeds... Also added to create feeds to Reg
                                     Hours Worked high level bal when class/cat
                                     = earn/reg. Also added feeds to high level
                                     "regpay" bals when earn/reg.
27-AUG-96    ramurthy    40.31  390388  Added the creation of the Jurisdiction
                                         input value to Non-Recurring Imputed
                                         Earnings elements.

6th Sep 1996 hparicha    40.32  385252. No longer allow input of
                         40.33          Separate Check or Deduction Processing
                                        input values for imputed earnings or
                                        earnings classifications...ie. only
                                        supplementals are allowed to enter
                                        these ivs.  Exceptions to this rule
                                        are below:
                                        384282. Attach supplemental earnings
                                        skip formula to imputed earning if it is
                                        a nonrecurring imputed.
                                        399471. Enhancement to allow Earnings
                                        categorized as Shift or Overtime to
                                        process in a tax only run...done by
                                        setting skip formula to Supplemental
                                        Earnings skip ff when this is the case.
                                        All three above bugs fixed in one go.

17th Dec 1996   hparicha 40.34  407348. Do not allow input of Separate Check or
                                Deduction Processing for nonrecurring imputeds.

22 Jul 1997 mreid    110.1      Removed Ctrl+M

28 Feb 1998 mlisieck 110.2      Changed do_deletions. Included missing
                                business_group_id condition.
                     110.3      Bug 633443.
26-APR-98   djeng    110.
09-JUN-99   dsaxby   115.3  873555  corrected the set up of
                                    the c_end_of_time constant to use
                                    hr_general.end_of_time.  Were getting
                                    ora-01847.
                                    Also, removed tabs from file, not
                                    supposed to use 'em!
03-NOV-1999 dscully         962590  Feeds to FLSA Hours and FLSA earnings
                                    were being accidently created for all
                                    Regular Earnings elements.  They are
                                    no only created if checked on the
                                    Earnings form.
14-FEB-2000 alogue   115.6          Utf8 Support.  Input value name lengthened
                                    to 80.
29-APR-2001 ekim     115.7          Added process_mode
14-MAY-2001 ssarma   115.8          Added Hours By Rate result rules
31-jul-2001 tclewis  115.9          Removed check for element classification of
                                    NON-PAYROLL Payments when creating the
                                    payments defined balance (bug 1835350).
25-SEP-2001 meshah   115.10 1952471 Added a new parameter p_prcess_mode to
                                    ins_uie_ele_type. All Special Input and
                                    Special Features elements are created with
                                    process mode of N and the actual elements
                                    have process mode of S.
19-OCT-2001 tclewis  115.12 944995  Added the following input values and
                                    associated formula result rules from the
                                    Main element (The hours x Rate formulas
                                    will be modified to return these values.
                                    RED_SAL_HOURS Reduce regular hours for reg
                                                  salary ele.
                                    RED_SAL_PAY Reduce regular pay for reg
                                                salary ele.
                                    RED_WAG_HOURS Reduce regular hours for
                                                  reg wage ele.
                                    RED_WAG_HOURS Reduce regular pay for
                                                  reg wage ele.
                            708373  Modified the formula result rules for he
                                    RED_REG_PAY return value from the
                                    RED_REG_PAY input value on the special
                                    features element to the special features
                                    PAY_VALUE input value.
                                    Also modified the cursor in the
                                    create_reduce_regpay_feeds procedure to not
                                    return balance that are fed via the
                                    element classification balance feeder
                                    processes.
21-DEC-2001 ahanda   115.15 1902232 Changed insert into ff_formulas_f
                                    to insert null for legislation_code.
22-JAN-2002 ahanda   115.16         Added call to create_defined_balance
                                    ID for 'Assignment Payments' dimension.

04-FEB-2002 rmonge   115.18        Bug 2074337. Shift input value element
                                   needs to be added when creating an
                                   Earning Element with a Shift Category.
17-May-2002 ekim     115.19        Added p_termination_rule
23-Jul-2002 ekim     115.20        Changed v_bg_name type to use
                                   per_business_groups.name%TYPE
                                   Re-numbered hr_utility.set_location
                                   number to avoid duplicates.
08-Oct-2002 ekim     115.21        Changed to use p_uom_code instead of
                                   p_uom in call to
                                   pay_db_pay_setup.create_input_value
10-Oct-2002 ekim     115.22        fixed GSCC warnings.
11-Nov-2002 ekim     115.23        for Input value of Rate Code, changed
                                   v_gen_dbi = 'N' for formula
                                   HOURS_X_RATE_NONRECUR_V2.
12-Nov-2002 ekim     115.24        Removed default value from do_insertions
                                   to fix GSCC warning.
18-Nov-2002 ekim     115.25        for Input value of Rate Code, changed
                                   v_gen_dbi = 'N' for formula
                                   HOURS_X_RATE_MULTIPLE_NONRECUR_V2.
14-JAN-2003 tclewis  115.26        Modifed processing of the special features
                                   element.  If P_REGUCE_REGULAR = 'Y'
                                   then we will create the SF element as
                                   an Earnings element, and not follow
                                   the base elements classification.
                                   Also reviewed for NOCOPY directive.  None
                                   required.
12-Mar-2003 ekim     115.27        for create_input_value for Warning,
                                   changed to use p_warn_or_error_code rather
                                   than p_warning_or_error.
01-APR-2003 ahanda   115.28        Added logic to save ASG_GRE_RUN as run level
                                   balances.
26-JUN-2003 ahanda   115.29        Changed call to create_balance_type procedure to
                                   pass the balance name as reporting name.
                                   Added code to populate 'Earnings' category for
                                   balances
08-JAN-2004 ardsouza 115.30        Performance tuning of few queries as required by
                                   bug 3349586.
08-JAN-2004 ardsouza 115.31        Non-mergable views eliminated in 2 queries.
18-MAR-2004 kvsankar 115.32        Changed call to create_balance_type
                                   procedure to pass the balance_category value
                                   depending upon the classification of the
                                   element instead of passing 'Earnings' for
                                   all types of elements (Earnings/Supplemental/
                                   Non-payroll Payments/Imputed Earnings)
                                   created. Elements created with Alien/Expat
                                   classification are not created using this package.
                                   Bug 3311781
20-MAY-2004 meshah   115.33        removed the logic not required for
                                   Non-Recurring elements. Like creation of
                                   additional and replacement defined balances.
03-FEB-2005 RMONGE   115.34        Bug 4134473.
                                   Modified package hr_user_init_earn to null out
                                   the default values of local variables
                                   v_lkp_type and v_dflt_value before calling
                                   'pay_db_pay_setup.create_input_value.
                                   This applies to the following Input Values
                                   Neg Earnings
                                   Reduce Reg Hours
                                   Reduce Reg Pay
                                   Reduce Sal Hours
                                   Reduce Sal Pay
                                   Reduce Wag Hours
                                   Reduce Wag Pay
09-JUN-2005 kvsankar 115.35        Bug 4420211
                                   Modified the procedure ins_uie_input_vals
                                   so that MANDATORY Flag is set to 'N'
                                   for the input value 'Deduction Processing'
                                   in case of 'Non-payroll Payments' Elements

*/
--
-- If any part of this package body fails, then rollback entire transaction.
-- Return to form and alert user of corrections required or to notify
-- Oracle HR staff in case of more serious error.

-- Pre-Insert validation procedures: called during insert procedures/functions.
-- Provided as part of API for the following:
--      1) Element creation;

--
------------------------------ do_insertions ---------------------------------
--
FUNCTION do_insertions (
                p_ele_name              in varchar2,
                p_ele_reporting_name    in varchar2,
                p_ele_description       in varchar2,
                p_ele_classification    in varchar2,
                p_ele_category          in varchar2,
                p_ele_ot_base           in varchar2,
                p_flsa_hours            in varchar2,
                p_ele_processing_type   in varchar2,
                p_ele_priority          in number,
                p_ele_standard_link     in varchar2,
                p_ele_calc_ff_id        in number,
                p_ele_calc_ff_name      in varchar2,
                p_sep_check_option      in varchar2,
                p_dedn_proc             in varchar2,
                p_mix_flag              in varchar2,
                p_reduce_regular        in varchar2,
                p_ele_eff_start_date    in date   ,
                p_ele_eff_end_date      in date  ,
                p_bg_id                 in number,
                p_termination_rule      in varchar2
                ) RETURN NUMBER IS
--
-- global constants
c_end_of_time  CONSTANT DATE := hr_general.end_of_time;

-- global vars
g_inpval_disp_seq       NUMBER := 0;    -- Display seq counter for input vals.
g_eff_start_date        DATE;
g_eff_end_date          DATE;

-- local vars
v_bg_name               per_business_groups.name%TYPE;
                        -- Get from bg short name passed in.
v_ele_type_id           NUMBER(9); -- Populated by insertion of element type.
v_process_mode          VARCHAR2(1); -- Set to S.
v_shadow_ele_type_id    NUMBER(9); -- Populated by insertion of element type.
v_shadow_ele_name       VARCHAR2(80); -- Name of shadow element type.
v_inputs_ele_type_id    NUMBER(9); -- Populated by insertion of element type.
v_inputs_ele_name       VARCHAR2(80); -- Name of shadow element type.
v_ele_repname           VARCHAR2(30);
v_primary_class_id      NUMBER(9);
v_class_lo_priority     NUMBER(9);
v_class_hi_priority     NUMBER(9);
v_bal_type_id           NUMBER(9);      -- Pop'd by insertion of balance type.
v_earn_bal_uom          VARCHAR2(30)    := 'M';
v_bal_dim               VARCHAR2(80);
v_neg_earn_bal_type_id  NUMBER(9);      -- Pop'd by insertion of balance type.
v_neg_earnbal_name      VARCHAR2(80);
v_hrs_bal_type_id       NUMBER(9);      -- Pop'd by insertion of balance type.
v_reghrs_bal_id         number(9);
v_regsal_bal_id         number(9);
v_regwage_bal_id        number(9);
v_hrs_bal_name          VARCHAR2(80);
v_hrs_bal_repname       VARCHAR2(30);
v_addl_amt_bal_type_id  NUMBER(9);      -- Pop'd by insertion of balance type.
v_addl_amt_bal_name     VARCHAR2(80);
v_repl_amt_bal_type_id  NUMBER(9);      -- Pop'd by insertion of balance type.
v_repl_amt_bal_name     VARCHAR2(80);
--v_bal_repname           VARCHAR2(30);
v_inpval_id             NUMBER(9); -- ID of inpval for chk and ins_3p inpvals.
v_payval_id             NUMBER(9); -- ID of payval for bal feed insert.
v_payval_formula_id     NUMBER(9);      -- ID of formula for payval validation.
v_payval_name           VARCHAR2(80);   -- Name of payval.
g_neg_earn_inpval_id    NUMBER(9);      -- ID of neg earn inpval for bal feed.
g_reduce_hrs_inpval_id  number(9);
g_reduce_pay_inpval_id  number(9);
g_reduce_sal_hrs_inpval_id  number(9);
g_reduce_sal_pay_inpval_id  number(9);
g_reduce_wag_hrs_inpval_id  number(9);
g_reduce_wag_pay_inpval_id  number(9);
g_shadow_info_payval_id  number(9);

g_addl_inpval_id        NUMBER(9);      -- ID of neg earn inpval for bal feed.
g_repl_inpval_id        NUMBER(9);      -- ID of neg earn inpval for bal feed.
gi_addl_inpval_id       NUMBER(9);      -- ID of neg earn inpval for bal feed.
gi_repl_inpval_id       NUMBER(9);      -- ID of neg earn inpval for bal feed.
v_nonpayroll_payval_id  NUMBER(9);
v_info_payval_id        NUMBER(9);
v_shadow_info_payval_id NUMBER(9);
v_inputs_info_payval_id NUMBER(9);
v_ot_base_baltype_id    NUMBER(9);
v_info_dflt_priority    NUMBER(9);
v_grossup_class_name    VARCHAR2(80);
v_skip_formula_id       NUMBER(9);
v_earn401k_bal_type_id  NUMBER(9);      -- Fed by Earn/Reg and Supp/BonComm
v_flsa_earnbal_id       NUMBER(9);
v_flsa_hrsbal_id        NUMBER(9);
v_hrs_inpval_id         NUMBER(9);

/* Hours By Rate Variables */
v_hbyr_ele_type_id      NUMBER(9);
v_hbyr_ele_inpval_id    NUMBER(9);
v_hbyr_rate_inpval_id   NUMBER(9);
v_hbyr_hours_inpval_id  NUMBER(9);
v_hbyr_mult_inpval_id   NUMBER(9);
--
l_ele_classification    varchar2(80);
-- Emp Balance form enhancement
l_bal_cat_classification varchar2(80);

--
---------------------------- ins_uie_ele_type -------------------------------
--
FUNCTION ins_uie_ele_type (     p_ele_name              in varchar2,
                                p_ele_reporting_name    in varchar2,
                                p_ele_description       in varchar2,
                                p_ele_class             in varchar2,
                                p_ele_ot_base           in varchar2,
                                p_ele_processing_type   in varchar2,
                                p_ele_priority          in number,
                                p_ele_standard_link     in varchar2,
                                p_skip_formula_id       in number default NULL,
                                p_ind_only_flag         in varchar2,
                                p_ele_eff_start_date    in date,
                                p_bg_name               in varchar2,
                                p_process_mode          in varchar2 default 'S')

RETURN number IS
-- local vars
v_eletype_id            NUMBER(9);
v_pay_value_name        VARCHAR2(80);
v_mult_entries_allowed  VARCHAR2(1);

BEGIN
--
-- Unless this function actually has to do anything, we can make call
-- to pay_db_pay_setup from do_insertions.
--

    hr_utility.set_location('pyusuiet',1);
    IF p_ele_processing_type = 'N' THEN
      v_mult_entries_allowed := 'Y';
    ELSE
      v_mult_entries_allowed := 'N';
    END IF;
--
-- Process_mode by defalut is 'S' for US earnings as all earnings
-- has separate check input value.
--
--v_process_mode := 'S';
--
-- insert check for ele type existence here...return id if it does!
--

    hr_utility.set_location('pyusuiet',3);
    v_eletype_id := pay_db_pay_setup.create_element(
                        p_element_name          => p_ele_name,
                        p_description           => p_ele_description,
                        p_classification_name   => p_ele_class,
                        p_post_termination_rule => 'Final Close',
                        p_indirect_only_flag    => p_ind_only_flag,
                        p_reporting_name        => p_ele_reporting_name,
                        p_processing_type       => p_ele_processing_type,
                        p_mult_entries_allowed  => v_mult_entries_allowed,
                        p_formula_id            => p_skip_formula_id,
                        p_processing_priority   => p_ele_priority,
                        p_process_mode          => p_process_mode,
                        p_standard_link_flag    => p_ele_standard_link,
                        p_business_group_name   => p_bg_name,
                        p_effective_start_date  => p_ele_eff_start_date,
                        p_legislation_code      => NULL,
                        p_legislation_subgroup  => g_template_leg_subgroup);
                        --p_once_each_period_flag  => 'Y');
--
-- Now, make Pay Value non-enterable by setting MANDATORY_FLAG = 'X':
--
    v_pay_value_name := hr_input_values.get_pay_value_name(g_template_leg_code);
--
    UPDATE pay_input_values_f
    SET    mandatory_flag   = 'X'
    WHERE  element_type_id  = v_eletype_id
    AND    name             = v_pay_value_name;
--
    RETURN v_eletype_id;
--
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN v_eletype_id;
--
END ins_uie_ele_type;
--
------------------------- ins_formula -----------------------
--
FUNCTION ins_formula (  p_ff_ele_name           in varchar2,
                        p_ff_suffix             in varchar2,
                        p_ff_desc               in varchar2,
                        p_ff_bg_id              in number,
                        p_amt_rule              in varchar2 default NULL)
RETURN number IS

-- local vars
v_formula_id    number;         -- Return var
--
v_skeleton_formula_text         VARCHAR2(32000);
v_skeleton_formula_type_id      NUMBER(9);
v_ele_formula_text              VARCHAR2(32000);
v_ele_formula_name              VARCHAR2(80);
v_ele_formula_id                NUMBER(9);
v_ele_name                      VARCHAR2(80);
v_formula_name                  VARCHAR2(80);

BEGIN

     hr_utility.set_location('hr_user_init_earn.ins_formula',10);

-- Bug 3768726 - With this, the upper clause will be removed from the first condition in query.

     v_formula_name := UPPER(p_amt_rule);

-- Bug 3349586 - Condition for formula_id added to improve performance.
--
-- Bug 3768726 - Index FF_FORMULAS_F_UK2 is modified for bug 3768764. So ff.formula_id >= 0 is not needed.

     SELECT  FF.formula_text, FF.formula_type_id
       INTO  v_skeleton_formula_text, v_skeleton_formula_type_id
     FROM    ff_formulas_f   FF
     WHERE   FF.formula_name  = v_formula_name    --UPPER(FF.formula_name)  = UPPER(p_amt_rule)
         AND FF.business_group_id    IS NULL
         AND FF.legislation_code     = 'US'
         AND g_eff_start_date        BETWEEN FF.effective_start_date
                                            AND FF.effective_end_date;
--
-- Replace element name placeholders with current element name:

    hr_utility.set_location('hr_user_init_earn.ins_formula',15);
    v_ele_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');
--
    v_ele_formula_text := REPLACE( v_skeleton_formula_text,
                                   '<ELE_NAME>',
                                   v_ele_name);
--
    v_ele_formula_name := substr(v_ele_name,1,60) || UPPER(p_ff_suffix);
--
-- Insert the new formula into current business goup:
-- Get new id

    hr_utility.set_location('hr_user_init_earn.ins_formula',30);
    SELECT ff_formulas_s.nextval
      INTO v_formula_id
    FROM sys.dual;
--
    hr_utility.set_location('hr_user_init_earn.ins_formula',40);
    INSERT INTO ff_formulas_f (
        FORMULA_ID,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE,
        BUSINESS_GROUP_ID,
        LEGISLATION_CODE,
        FORMULA_TYPE_ID,
        FORMULA_NAME,
        DESCRIPTION,
        FORMULA_TEXT,
        STICKY_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATED_BY,
        CREATION_DATE)
    values (
        v_formula_id,
        g_eff_start_date,
        g_eff_end_date,
        p_bg_id,
        NULL,
        v_skeleton_formula_type_id,
        v_ele_formula_name,
        p_ff_desc,
        v_ele_formula_text,
        'N',
        NULL,
        NULL,
        NULL,
        -1,
        g_eff_start_date);
--
RETURN v_formula_id;
--
END ins_formula;
--
------------------------- ins_uie_formula_processing -----------------------
--
PROCEDURE ins_uie_formula_processing (
                                p_ele_id                in number,
                                p_ele_name              in varchar2,
                                p_ele_rept_name         in varchar2,
                                p_primary_class_id      in number,
                                p_ele_class_name        in varchar2,
                                p_grossup_class_name    in varchar2,
                                p_ele_cat               in varchar2,
                                p_include_in_ot         in varchar2,
                                p_flsa_hrs              in varchar2,
                                p_mix_enterable         in varchar2,
                                p_ele_proc_type         in varchar2,
                                p_ele_pri               in number,
                                p_calc_ff_id            in number,
                                p_calc_ff_name          in varchar2,
                                p_bg_id                 in number,
                                p_shadow_ele_id         in number,
                                p_inputs_ele_id         in number,
                                p_hrs_baltype_id        in number default NULL,
                                p_eff_start_date        in date default NULL,
                                p_eff_end_date          in date default NULL,
                                p_bg_name               in varchar2) IS
-- local constants

-- local vars
v_fname                 VARCHAR2(80);
v_ftype_id              NUMBER(9);
v_fdesc                 VARCHAR2(240);
v_ftext                 VARCHAR2(32767); -- Max length of varchar2
v_sticky_flag           VARCHAR2(1);
v_asst_status_type_id   NUMBER(9);
v_stat_proc_rule_id     NUMBER(9);
v_fres_rule_id          NUMBER(9);
v_proc_rule             VARCHAR2(1) := 'P'; -- Provide "Process" proc rule.
v_calc_rule_formula_id  NUMBER(9);
v_inpval_id             NUMBER(9);
v_inpval_name           VARCHAR2(80);
v_inpval_uom            VARCHAR2(80);
v_default_val           VARCHAR2(60);
v_ele_sev_level         VARCHAR2(1);
v_gen_dbi               VARCHAR2(1);
v_ele_info_cat          VARCHAR2(30);
v_ele_grossup_id        NUMBER(9);
v_mix_category          VARCHAR2(1);
--
BEGIN
-- In the case of earnings elements, the formulae are fully defined in advance
-- based on calculation rule only.  These pre-packaged formulae are seeded
-- as startup data - such that bg_id is NULL, in the appropriate legislation.
-- The formula_name will closely resemble the calc rule.
-- For deductions, formula is "pieced together" according to calc_rule
-- and other attributes. (Maybe, let's pre-defined them first.  Having them
-- pre-defined AND COMPILED makes things a bit easier.)

-- To copy a formula from seed data to the user's business group, we can
-- select the formula_text LONG field into a VARCHAR2; the LONG field
-- in the table can then accept the VARCHAR2 formula text as long as it-- does not exceed 32767 bytes.
--
-- First, update SCL
--        ( ) Element Information Category in ELEMENT_INFORMATION_CATEGORY
--        ( ) Category in segment 1;
--        ( ) Include in OT Base in segment 2.
-- Then make direct calls to CORE_API packaged procedures to:
-- 1) Insert status proc rule of 'PROCESS' for Asst status type 'ACTIVE_ASSIGN'
-- and appropriate formula according to calculation method
-- 2) Insert input values according to calculation method
--      - Also make call to ins_uie_input_vals for insertion of additional
--      input values based on class/category and others required of
--      ALL template earnings elements.
-- 3) Insert formula result rules as appropriate for formula (and other info?)
--
-- Populate SCL
--


      IF p_mix_enterable = 'Y' AND
         p_ele_proc_type = 'N' AND
         UPPER(p_calc_ff_name) IN ('HOURS_X_RATE_NONRECUR_V2',
                             'HOURS_X_RATE_MULTIPLE_NONRECUR_V2') THEN
        v_mix_category := 'T';
      ELSIF p_mix_enterable = 'Y' THEN
        v_mix_category := 'E';
      END IF;
--
-- NOTE: Shadow elements "...Special Features" do not require mix flag.
--
      IF UPPER(p_calc_ff_name) NOT IN ('GROSS_UP_RECUR_V2',
                                       'GROSS_UP_NONRECUR_V2') THEN
--
        IF UPPER(p_ele_class_name) = 'EARNINGS' THEN
          v_ele_info_cat := 'US_EARNINGS';
          hr_utility.set_location('pyusuiet',45);
          UPDATE      pay_element_types_f
          SET         element_information_category    = v_ele_info_cat,
                      element_information1            = p_ele_cat,
                      element_information8            = p_include_in_ot,
                      element_information11           = p_flsa_hrs,
                      element_information9            = v_mix_category,
                      element_information12           = p_hrs_baltype_id
          WHERE       element_type_id                 = p_ele_id
          AND         business_group_id               = p_bg_id;
      --
          hr_utility.set_location('pyusuiet',50);
          UPDATE      pay_element_types_f
          SET         element_information_category    = v_ele_info_cat,
                      element_information1            = p_ele_cat,
                      element_information8            = p_include_in_ot
          WHERE       element_type_id                 = p_shadow_ele_id
          AND         business_group_id               = p_bg_id;
--

          If p_ele_proc_type = 'R' then   /* Not required for NR Elements  */

             hr_utility.set_location('pyusuiet',55);
             UPDATE      pay_element_types_f
             SET         element_information_category    = v_ele_info_cat,
                         element_information1            = p_ele_cat,
                         element_information8            = p_include_in_ot
             WHERE       element_type_id                 = p_inputs_ele_id
             AND         business_group_id               = p_bg_id;

          end if;  /* Not required for NR Elements */

--
        ELSIF UPPER(p_ele_class_name) = 'SUPPLEMENTAL EARNINGS' THEN

            v_ele_info_cat := 'US_SUPPLEMENTAL EARNINGS';
            hr_utility.set_location('pyusuiet',60);
            UPDATE      pay_element_types_f
            SET         element_information_category    = v_ele_info_cat,
                        element_information1            = p_ele_cat,
                        element_information8            = p_include_in_ot,
                        element_information11           = p_flsa_hrs,
                        element_information9            = v_mix_category,
                        element_information12           = p_hrs_baltype_id
            WHERE       element_type_id                 = p_ele_id
            AND         business_group_id               = p_bg_id;
--
            hr_utility.set_location('pyusuiet',65);
            UPDATE      pay_element_types_f
            SET         element_information_category    = v_ele_info_cat,
                        element_information1            = p_ele_cat,
                        element_information8            = p_include_in_ot
            WHERE       element_type_id                 = p_shadow_ele_id
            AND         business_group_id               = p_bg_id;
--
          If p_ele_proc_type = 'R' then   /* Not required for NR Elements  */

            hr_utility.set_location('pyusuiet',70);
            UPDATE      pay_element_types_f
            SET         element_information_category    = v_ele_info_cat,
                        element_information1            = p_ele_cat,
                        element_information8            = p_include_in_ot
            WHERE       element_type_id                 = p_inputs_ele_id
            AND         business_group_id               = p_bg_id;

          end if; /* Not required for NR Elements  */
--
        ELSIF UPPER(p_ele_class_name) = 'IMPUTED EARNINGS' THEN

            v_ele_info_cat := 'US_IMPUTED EARNINGS';
            hr_utility.set_location('pyusuiet',75);
            UPDATE      pay_element_types_f
            SET         element_information_category    = v_ele_info_cat,
                        element_information1            = p_ele_cat,
                        element_information9            = v_mix_category,
                        element_information12           = p_hrs_baltype_id
            WHERE       element_type_id                 = p_ele_id
            AND         business_group_id               = p_bg_id;
--
            hr_utility.set_location('pyusuiet',80);
            UPDATE      pay_element_types_f
            SET         element_information_category    = v_ele_info_cat,
                        element_information1            = p_ele_cat
            WHERE       element_type_id                 = p_shadow_ele_id
            AND         business_group_id               = p_bg_id;
        --

           If p_ele_proc_type = 'R' then  /* Not required for NR Elements */

             hr_utility.set_location('pyusuiet',85);
             UPDATE      pay_element_types_f
             SET         element_information_category    = v_ele_info_cat,
                         element_information1            = p_ele_cat
             WHERE       element_type_id                 = p_inputs_ele_id
             AND         business_group_id               = p_bg_id;

          End if;  /* Not required for NR Elements  */

--
        ELSIF UPPER(p_ele_class_name) = 'NON-PAYROLL PAYMENTS' THEN

            v_ele_info_cat := 'US_NON-PAYROLL PAYMENTS';
            hr_utility.set_location('pyusuiet',90);
            UPDATE      pay_element_types_f
            SET         element_information_category    = v_ele_info_cat,
                        element_information1            = p_ele_cat,
                        element_information9            = v_mix_category
            WHERE       element_type_id                 = p_ele_id
            AND         business_group_id               = p_bg_id;
--
            hr_utility.set_location('pyusuiet',95);
            UPDATE      pay_element_types_f
            SET         element_information_category    = v_ele_info_cat,
                        element_information1            = p_ele_cat
            WHERE       element_type_id                 = p_shadow_ele_id
            AND         business_group_id               = p_bg_id;
        --
            If p_ele_proc_type = 'R' then  /* Not required for NR Elements */

              hr_utility.set_location('pyusuiet',100);
              UPDATE      pay_element_types_f
              SET         element_information_category    = v_ele_info_cat,
                          element_information1            = p_ele_cat
              WHERE       element_type_id                 = p_inputs_ele_id
              AND         business_group_id               = p_bg_id;

            end if;  /* Not required for NR Elements  */

--
        END IF;

--
      ELSE
         -- Ele is a grossup ele, Information classification, just set mix flag.
         hr_utility.set_location('pyusuiet',105);
         UPDATE        pay_element_types_f
         SET           element_information9            = v_mix_category
         WHERE         element_type_id                 = p_ele_id
         AND           business_group_id               = p_bg_id;
         --
      END IF;

--
-- "Standard" assignment status processing rule has assignment status type id
-- that is NULL!
--
-- v_asst_status_type_id := NULL;

IF UPPER(p_calc_ff_name) in (   'HOURS_X_RATE_RECUR_V2',
                              'HOURS_X_RATE_NONRECUR_V2') THEN
  -- Outermost IF
  --
  -- Copy/Insert formula;
  -- Insert status proc rule;
  -- Insert input vals;
  -- Gather Hours By Rate Element Details
  -- Insert formula result rules;
  --
  hr_utility.set_location('pyusuiet',110);
  v_calc_rule_formula_id := ins_formula  (
        p_ff_ele_name   => p_ele_name,
        p_ff_suffix     => '_HOURS_X_RATE',
        p_ff_desc       => 'Hours times Rate calculation for recurring earnings.',
        p_ff_bg_id      => p_bg_id,
        p_amt_rule      => UPPER(p_calc_ff_name));
  --
  hr_utility.set_location('pyusuiet',115);

  --
  -- check for existence...return id...
  --

  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
                p_business_group_id             => p_bg_id,
                p_legislation_code              => NULL,
                p_legislation_subgroup          => g_template_leg_subgroup,
                p_effective_start_date          => p_eff_start_date,
                p_effective_end_date            => c_end_of_time,
                p_element_type_id               => p_ele_id,
                p_assignment_status_type_id     => NULL,
                p_formula_id                    => v_calc_rule_formula_id,
                p_processing_rule               => v_proc_rule);

  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Creating "Hours Worked" input val.
    hr_utility.set_location('pyusuiet',120);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Hours';
    v_inpval_uom        := 'H_DECIMAL2'; --Hours in Decimal format (2 places)
    v_gen_dbi           := 'Y';

    -- check for input value existence before creating...return id if it exists...

    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',125);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',130);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting one "Hours" input value.
  -- Now insert "Rate".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
    hr_utility.set_location('pyusuiet',135);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Rate';
    v_inpval_uom        := 'N'; -- Check that this can go out to 5 dec.
    v_gen_dbi           := 'Y';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',140);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',145);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting one "Rate" input value.
  -- Now insert "Rate Code".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
    hr_utility.set_location('pyusuiet',150);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Rate Code';
    v_inpval_uom        := 'C';
    v_gen_dbi           := 'N';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',155);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',160);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting "Rate Code" input value.

  -- Now insert "Shift".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
    hr_utility.set_location('pyusuiet',165);

   -- Rmonge 01-FEB-2002
   -- Adding the following if condition to create Shift Input value.
   -- The Shift input values is only created if the p_ele_cat value
   -- is 'S'. S means Shift Category.

   hr_utility.trace('p_ele_cat is '||p_ele_cat);

   IF p_ele_cat = 'S' THEN

        g_inpval_disp_seq   := g_inpval_disp_seq + 1;
        v_inpval_name       := 'Shift';
        v_inpval_uom        := 'C';
        v_gen_dbi           := 'N';
        v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

        hr_utility.set_location('pyusuiet',170);
        hr_input_values.chk_input_value(
                         p_element_type_id               => p_ele_id,
                         p_legislation_code              => g_template_leg_code,
                         p_val_start_date             => p_eff_start_date,
                         p_val_end_date               => NULL,
                         p_insert_update_flag         => 'UPDATE',
                         p_input_value_id             => v_inpval_id,
                         p_rowid                      => NULL,
                         p_recurring_flag             => p_ele_proc_type,
                         p_mandatory_flag             => 'N',
                         p_hot_default_flag           => 'N',
                         p_standard_link_flag         => 'N',
                         p_classification_type        => 'N',
                         p_name                       => v_inpval_name,
                         p_uom                        => v_inpval_uom,
                         p_min_value                  => NULL,
                         p_max_value                  => NULL,
                         p_default_value              => NULL,
                         p_lookup_type                => NULL,
                         p_formula_id                 => NULL,
                         p_generate_db_items_flag     => v_gen_dbi,
                         p_warning_or_error           => NULL);

          hr_utility.set_location('pyusuiet',175);
          hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting "Shift" input value.

  -- FINISH ADDING  CODE FOR SHIFT   RMONGE  ---
/*
   -- ADDING INPUT VALUE 'Date Earned' for the Shift Element.
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Date Earned';
    v_inpval_uom        := 'Date (DD-MON-YYYY)';
    v_gen_dbi           := 'N';

    hr_utility.set_location('pyusuiet',180);
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',185);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',190);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);


  -- (HERE) Done inserting "Date Earned" input value.
   */

  END IF; -- p_ele_cat

  -- Now insert "Rate Table".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Now insert appropriate formula_result_rules for "HRS X RATE"
  -- REMEMBER: Testing using 'HEP_TEST_01' formula.

    -- Gather Hours By Rate Element Details
    hr_utility.trace('Get Hours By Rate Element Id');
    hr_utility.set_location('pyusuiet',195);
    select element_type_id
      into v_hbyr_ele_type_id
      from pay_element_types_f
     where element_name = 'Hours by Rate'
       and legislation_code = g_template_leg_code
       and sysdate between effective_start_date
                       and effective_end_date;

    hr_utility.trace('Get Hours By Rate Element Inpval Id');
    hr_utility.set_location('pyusuiet',200);
    select input_value_id
      into v_hbyr_ele_inpval_id
      from pay_input_values_f
     where element_type_id = v_hbyr_ele_type_id
       and name            = 'Element Type Id'
       and sysdate between effective_start_date
                       and effective_end_date;

    hr_utility.trace('Get Hours By Rate Rate Inpval Id');
    hr_utility.set_location('pyusuiet',205);
    select input_value_id
      into v_hbyr_rate_inpval_id
      from pay_input_values_f
     where element_type_id = v_hbyr_ele_type_id
       and name            = 'Rate'
       and sysdate between effective_start_date
                       and effective_end_date;

    hr_utility.trace('Get Hours By Rate Hours Inpval Id');
    hr_utility.set_location('pyusuiet',210);
    select input_value_id
      into v_hbyr_hours_inpval_id
      from pay_input_values_f
     where element_type_id = v_hbyr_ele_type_id
       and name            = 'Hours'
       and sysdate between effective_start_date
                       and effective_end_date;


    hr_utility.set_location('pyusuiet',215);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => NULL,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'TEMPLATE_EARNING',
        p_result_rule_type              => 'D',
        p_severity_level                => NULL);
  --
    hr_utility.set_location('pyusuiet',220);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => NULL,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'MESG',
        p_result_rule_type              => 'M',
        p_severity_level                => 'W');
  --
      hr_utility.set_location('pyusuiet',225);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => v_hbyr_ele_inpval_id,
        p_result_name                   => 'ELEMENT_TYPE_ID_PASSED',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => v_hbyr_ele_type_id);

      hr_utility.set_location('pyusuiet',230);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => v_hbyr_rate_inpval_id,
        p_result_name                   => 'RATE_PASSED',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => v_hbyr_ele_type_id);

      hr_utility.set_location('pyusuiet',235);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => v_hbyr_hours_inpval_id,
        p_result_name                   => 'HOURS_PASSED',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => v_hbyr_ele_type_id);

    IF p_ele_proc_type = 'R' THEN
    --
      hr_utility.set_location('pyusuiet',240);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
        p_result_name                   => 'STOP_ENTRY',
        p_result_rule_type              => 'S',
        p_severity_level                => NULL,
        p_element_type_id               => p_ele_id);
    --
    END IF;
--
ELSIF UPPER(p_calc_ff_name) IN ('HOURS_X_RATE_MULTIPLE_RECUR_V2',
                                'HOURS_X_RATE_MULTIPLE_NONRECUR_V2') THEN
--
  hr_utility.set_location('pyusuiet',245);
  v_calc_rule_formula_id := ins_formula  (
        p_ff_ele_name   => p_ele_name,
        p_ff_suffix     => '_HOURS_X_RATE_MULT',
        p_ff_desc       => 'Hours * Rate * Multiple calculation for recurring earnings.',
        p_ff_bg_id      => p_bg_id,
        p_amt_rule      => UPPER(p_calc_ff_name));
  --
  hr_utility.set_location('pyusuiet',250);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
                p_business_group_id             => p_bg_id,
                p_legislation_code              => NULL,
                p_legislation_subgroup          => g_template_leg_subgroup,
                p_effective_start_date          => p_eff_start_date,
                p_effective_end_date            => c_end_of_time,
                p_element_type_id               => p_ele_id,
                p_assignment_status_type_id     => NULL,
                p_formula_id                    => v_calc_rule_formula_id,
                p_processing_rule               => v_proc_rule);

  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Creating "Hours Worked" input val.
    hr_utility.set_location('pyusuiet',255);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Hours';
    v_inpval_uom        := 'H_DECIMAL2'; --Hours in Decimal format (2 places)
    v_gen_dbi           := 'Y';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',260);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',265);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting one "Hours" input value.
  -- Now insert "Multiple".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
    hr_utility.set_location('pyusuiet',270);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Multiple';
    v_inpval_uom        := 'N'; -- Check that this can go out to 5 dec.
    v_gen_dbi           := 'Y';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',275);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',280);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting one "Multiple" input value.
  -- Now insert "Rate".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
    hr_utility.set_location('pyusuiet',285);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Rate';
    v_inpval_uom        := 'N'; -- Check that this can go out to 5 dec.
    v_gen_dbi           := 'Y';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',290);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',295);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting one "Rate" input value.
  -- Now insert "Rate Code".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
    hr_utility.set_location('pyusuiet',300);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Rate Code';
    v_inpval_uom        := 'C';
    v_gen_dbi           := 'N';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',305);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',310);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting "Rate Code" input value.
  -- Now insert "Rate Table".
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Now insert appropriate formula_result_rules for "HRS X RATE X MULTIPLE"
  -- REMEMBER: Testing using 'HEP_TEST_01' formula.

    hr_utility.set_location('pyusuiet',315);

    --
    -- check for existence ... return id of result rule if it already exists.
    --
     -- Gather Hours By Rate Element Details
  hr_utility.trace('Get Hours By Rate Element Id');
  hr_utility.set_location('pyusuiet',320);
    select element_type_id
      into v_hbyr_ele_type_id
      from pay_element_types_f
     where element_name = 'Hours by Rate'
       and legislation_code = g_template_leg_code
       and sysdate between effective_start_date
                       and effective_end_date;

  hr_utility.trace('Get Hours By Rate Element Inpval Id');
  hr_utility.set_location('pyusuiet',325);
    select input_value_id
      into v_hbyr_ele_inpval_id
      from pay_input_values_f
     where element_type_id = v_hbyr_ele_type_id
       and name            = 'Element Type Id'
       and sysdate between effective_start_date
                       and effective_end_date;

  hr_utility.trace('Get Hours By Rate Rate Inpval Id');
  hr_utility.set_location('pyusuiet',330);
    select input_value_id
      into v_hbyr_rate_inpval_id
      from pay_input_values_f
     where element_type_id = v_hbyr_ele_type_id
       and name            = 'Rate'
       and sysdate between effective_start_date
                       and effective_end_date;

  hr_utility.trace('Get Hours By Rate Hours Inpval Id');
  hr_utility.set_location('pyusuiet',335);
    select input_value_id
      into v_hbyr_hours_inpval_id
      from pay_input_values_f
     where element_type_id = v_hbyr_ele_type_id
       and name            = 'Hours'
       and sysdate between effective_start_date
                       and effective_end_date;

  hr_utility.trace('Get Hours By Rate Multiple Inpval Id');
  hr_utility.set_location('pyusuiet',340);
    select input_value_id
      into v_hbyr_mult_inpval_id
      from pay_input_values_f
     where element_type_id = v_hbyr_ele_type_id
       and name            = 'Multiple'
       and sysdate between effective_start_date
                       and effective_end_date;


    hr_utility.set_location('pyusuiet',345);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => NULL,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'TEMPLATE_EARNING',
        p_result_rule_type              => 'D',
        p_severity_level                => NULL);
  --
    hr_utility.set_location('pyusuiet',350);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => NULL,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'MESG',
        p_result_rule_type              => 'M',
        p_severity_level                => 'W');
  --
     hr_utility.set_location('pyusuiet',355);
     v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => v_hbyr_ele_inpval_id,
        p_result_name                   => 'ELEMENT_TYPE_ID_PASSED',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => v_hbyr_ele_type_id);

      hr_utility.set_location('pyusuiet',360);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => v_hbyr_rate_inpval_id,
        p_result_name                   => 'RATE_PASSED',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => v_hbyr_ele_type_id);

      hr_utility.set_location('pyusuiet',365);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => v_hbyr_hours_inpval_id,
        p_result_name                   => 'HOURS_PASSED',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => v_hbyr_ele_type_id);

       hr_utility.set_location('pyusuiet',370);
       v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => v_hbyr_mult_inpval_id,
        p_result_name                   => 'MULTIPLE_PASSED',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => v_hbyr_ele_type_id);

    IF p_ele_proc_type = 'R' THEN
    --
      hr_utility.set_location('pyusuiet',375);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
        p_result_name                   => 'STOP_ENTRY',
        p_result_rule_type              => 'S',
        p_severity_level                => NULL,
        p_element_type_id               => p_ele_id);
    --
    END IF;
  -- NOTE: Decide on "Rate Code" and "Rate Table" fnality!!!
--
ELSIF UPPER(p_calc_ff_name) IN ('PERCENTAGE_OF_REG_EARNINGS_RECUR_V2',
                                'PERCENTAGE_OF_REG_EARNINGS_NONRECUR_V2') THEN
--
  hr_utility.set_location('pyusuiet',380);
  v_calc_rule_formula_id := ins_formula  (
        p_ff_ele_name   => p_ele_name,
        p_ff_suffix     => '_PCT_EARN',
        p_ff_desc       => 'Percentage of regular earnings calculation for recurring earnings.',
        p_ff_bg_id      => p_bg_id,
        p_amt_rule      => UPPER(p_calc_ff_name));
--
  hr_utility.set_location('pyusuiet',385);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
                p_business_group_id             => p_bg_id,
                p_legislation_code              => NULL,
                p_legislation_subgroup          => g_template_leg_subgroup,
                p_effective_start_date          => p_eff_start_date,
                p_effective_end_date            => c_end_of_time,
                p_element_type_id               => p_ele_id,
                p_assignment_status_type_id     => NULL,
                p_formula_id                    => v_calc_rule_formula_id,
                p_processing_rule               => v_proc_rule);

  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Creating "Percentage" input val.
    hr_utility.set_location('pyusuiet',390);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Percentage';
    v_inpval_uom        := 'N';
    v_gen_dbi           := 'Y';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',395);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',400);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting one "Percentage" input value.
  -- Now insert appropriate formula_result_rules for "PERCENT SALARY"
  -- REMEMBER: Testing using 'HEP_TEST_01' formula.

    hr_utility.set_location('pyusuiet',405);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'TEMPLATE_EARNING',
        p_result_rule_type              => 'D',
        p_severity_level                => NULL);
  --
    hr_utility.set_location('pyusuiet',410);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => NULL,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'MESG',
        p_result_rule_type              => 'M',
        p_severity_level                => 'W');
  --
    IF p_ele_proc_type = 'R' THEN
    --
      hr_utility.set_location('pyusuiet',415);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
        p_result_name                   => 'STOP_ENTRY',
        p_result_rule_type              => 'S',
        p_severity_level                => NULL,
        p_element_type_id               => p_ele_id);
    --
    END IF;
--

ELSIF UPPER(p_calc_ff_name) IN ('FLAT_AMOUNT_RECUR_V2',
                                'FLAT_AMOUNT_NONRECUR_V2') THEN
--
  hr_utility.set_location('pyusuiet',420);
  v_calc_rule_formula_id := ins_formula  (
        p_ff_ele_name   => p_ele_name,
        p_ff_suffix     => '_FLAT_AMOUNT',
        p_ff_desc       => 'Flat Amount calculation for recurring earnings.',
        p_ff_bg_id      => p_bg_id,
        p_amt_rule      => UPPER(p_calc_ff_name));
--
  hr_utility.set_location('pyusuiet',425);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
                p_business_group_id             => p_bg_id,
                p_legislation_code              => NULL,
                p_legislation_subgroup          => g_template_leg_subgroup,
                p_effective_start_date          => p_eff_start_date,
                p_effective_end_date            => c_end_of_time,
                p_element_type_id               => p_ele_id,
                p_assignment_status_type_id     => NULL,
                p_formula_id                    => v_calc_rule_formula_id,
                p_processing_rule               => v_proc_rule);
  --
  -- Creating "Amount" input val.
    hr_utility.set_location('pyusuiet',430);
    g_inpval_disp_seq   := g_inpval_disp_seq + 1;
    v_inpval_name       := 'Amount';
    v_inpval_uom        := 'M';
    v_gen_dbi           := 'Y';
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

    hr_utility.set_location('pyusuiet',435);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start_date,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

    hr_utility.set_location('pyusuiet',440);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start_date,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  --
  -- (HERE) Done inserting one "Amount" input value.
  --
  -- Now insert appropriate formula_result_rules for "FLAT AMOUNT"
  --
    hr_utility.set_location('pyusuiet',445);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => NULL,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'FLAT_AMOUNT',
        p_result_rule_type              => 'D',
        p_severity_level                => NULL);
  --
    hr_utility.set_location('pyusuiet',450);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => NULL,
  --
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
  --
        p_result_name                   => 'MESG',
        p_result_rule_type              => 'M',
        p_severity_level                => 'W');
  --
    IF p_ele_proc_type = 'R' THEN
    --
      hr_utility.set_location('pyusuiet',455);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start_date,
        p_effective_end_date            => p_eff_end_date,
        p_status_processing_rule_id     => v_stat_proc_rule_id,
        p_input_value_id                => NULL,
        p_result_name                   => 'STOP_ENTRY',
        p_result_rule_type              => 'S',
        p_severity_level                => NULL,
        p_element_type_id               => p_ele_id);
    --
    END IF;
--

ELSE

    -- Could not find this calc method formula(?) should never happen!
    -- No input vals or formula results required for calculation of
    -- this earning.
    hr_utility.set_location('pyusuiet',460);
    v_calc_rule_formula_id := '';
    v_stat_proc_rule_id :=
    pay_formula_results.ins_stat_proc_rule (
                p_business_group_id             => p_bg_id,
                p_legislation_code              => NULL,
                p_legislation_subgroup          => g_template_leg_subgroup,
                p_effective_start_date          => p_eff_start_date,
                p_effective_end_date            => c_end_of_time,
                p_element_type_id               => p_ele_id,
                p_assignment_status_type_id     => NULL,
                p_formula_id                    => v_calc_rule_formula_id,
                p_processing_rule               => v_proc_rule);

END IF; -- Outermost IF

END ins_uie_formula_processing;

---------------------------- ins_uie_input_vals ------------------------------
PROCEDURE ins_uie_input_vals (
                p_ele_type_id           in number,
                p_ele_name              in varchar2,
                p_shadow_ele_type_id    in number,
                p_shadow_ele_name       in varchar2,
                p_inputs_ele_type_id    in number,
                p_inputs_ele_name       in varchar2,
                p_eff_start             in date,
                p_eff_end               in date,
                p_primary_class_id      in number,
                p_ele_class             in varchar2,
                p_ele_cat               in varchar2,
                p_ele_proc_type         in varchar2,
                p_sep_chk_opt           in varchar2,
                p_dedn_proc_opt in varchar2 DEFAULT 'A',
                p_bg_id                 in number,
                p_bg_name               in varchar2,
                p_calc_ff_name          in varchar2) IS

-- local vars
v_inpval_name           VARCHAR2(30);
v_inpval_uom            VARCHAR2(80);
v_gen_dbi               VARCHAR2(1);
v_dflt_value            VARCHAR2(60);
v_lkp_type              VARCHAR2(30);
v_mand_flag             VARCHAR2(1);
v_val_formula_id                NUMBER(9);
v_fres_rule_id          NUMBER(9);
v_status_proc_id        NUMBER(9);
v_resrule_id            NUMBER(9);
v_pv_name               varchar2(80);
v_regsal_pv_id          number(9);
v_regwage_pv_id number(9);
v_regsal_ele_id         number(9);
v_regwage_ele_id        number(9);

BEGIN
-- More input values may be necessary, so make direct calls to CORE_API
-- packaged procedures to:
-- 1) Insert input values according to Class and Category
--    (Done in ins_uie_formula_processing)
-- 2) Insert input values required for ALL user-initiated earnings elements
--    (ie. batch entry fields, override fields)

-- Add input values (in order) "Jurisdiction", "Deduction Processing"
-- ,"Tax Separately", and "Separate Check",

-- (*) Display sequence must be checked before inserting input values according
-- to Class/Cat(2) and again before inserting generic inputs(3).  However, the
-- insert input value API may handle this by automatically determining display
-- sequence. BUT IT DOES NOT LOOK THAT WAY (23 Sep 93).
-- The PAY_VALUE and first input value both have a display sequence = 1.
-- So if the max(display_seq) = 1, then you don't know if it means the
-- the PAY_VALUE or the first INPUT_VALUE (ie. pay val name can be changed).
-- So I'll keep a global variable count of current input val disp seq num.

  -- Add input values w/display seq = g_inpval_disp_seq + 1, and so on.
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Creating "Jurisdiction" input val

    hr_utility.set_location('pyusuiet',465);
    SELECT      formula_id
    INTO                v_val_formula_id
    FROM        ff_formulas_f
    WHERE       business_group_id       IS NULL
    AND         legislation_code        = 'US'
    AND         formula_name            = 'JURISDICTION_VALIDATION';
    --
    hr_utility.set_location('pyusuiet',86);
    g_inpval_disp_seq := g_inpval_disp_seq + 1;
    v_inpval_name := 'Jurisdiction';
    v_inpval_uom := 'C';
    v_gen_dbi   := 'N';
    v_lkp_type := NULL;
    --
    hr_utility.set_location('pyusuiet',470);
    v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warn_or_error_code    => 'E',
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => v_val_formula_id,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);
    --
    hr_utility.set_location('pyusuiet',480);
    hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_type_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start,
                           p_val_end_date               => NULL,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => v_val_formula_id,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => 'Error');
    --
    hr_utility.set_location('pyusuiet',485);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => 'Error',
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting "Jurisdiction" input value.

  -- Check classification, if supplemental, then create "Tax Separately"
    IF UPPER(p_ele_class) = 'SUPPLEMENTAL EARNINGS' THEN
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Creating "Tax Separately" inpval
      hr_utility.set_location('pyusuiet',490);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name := 'Tax Separately';
      v_inpval_uom := 'C';
      v_gen_dbi := 'N';
      v_lkp_type := 'YES_NO';
      v_dflt_value := 'N';
      --
      v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_default_value         => v_dflt_value,
                                p_lookup_type           => v_lkp_type,
                                p_business_group_name   => p_bg_name);

      hr_utility.set_location('pyusuiet',495);
      hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_type_id,
                        p_legislation_code              => g_template_leg_code,
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => NULL,
                        p_insert_update_flag            => 'UPDATE',
                        p_input_value_id                => v_inpval_id,
                        p_rowid                         => NULL,
                        p_recurring_flag                => p_ele_proc_type,
                        p_mandatory_flag                => 'N',
                        p_hot_default_flag              => 'N',
                        p_standard_link_flag            => 'N',
                        p_classification_type           => 'N',
                        p_name                          => v_inpval_name,
                        p_uom                           => v_inpval_uom,
                        p_min_value                     => NULL,
                        p_max_value                     => NULL,
                        p_default_value                 => v_dflt_value,
                        p_lookup_type                   => v_lkp_type,
                        p_formula_id                    => NULL,
                        p_generate_db_items_flag        => v_gen_dbi,
                        p_warning_or_error              => NULL);

      hr_utility.set_location('pyusuiet',500);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => NULL,
                        p_element_type_id               => p_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => v_dflt_value,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting "Tax Separately" input value.
    END IF; -- Supplemental class check.
  --
  -- Check sep_check_option value, create "Deduction Processing" and
  -- "Separate Check" or not.
  -- G1188 (03-Aug-94): Also create these input values if ele classification
  -- is 'Supplemental Earnings'.
  --
  -- Creating "Deduction Processing" inpval
      hr_utility.set_location('pyusuiet',505);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name := 'Deduction Processing';
      v_inpval_uom := 'C';
      v_gen_dbi := 'N';
      v_lkp_type := 'US_DEDUCTION_PROCESSING';
      v_val_formula_id := NULL;
      v_dflt_value := UPPER(p_dedn_proc_opt);

--
-- 385252 : Imputeds and Earnings can never be processed via sep check or deduction processing.
-- Therefore we do not allow entry of these inputs...with the exceptions of:
-- 384282: Nonrecurring Imputeds can process in tax only or sepcheck runs;
-- 399471: Earnings can process in supp, tax only, or sepcheck runs when category
-- is other than 'REG' or 'ENWH' - ie. for overtime, shift, and future categories.
-- 407348 : Nonrecurring Imputeds cannot enter these inputs, but still process
-- in supplemental run by virtue of skip formula set by 384282.
-- 4420211 : 'Non-Payroll Payments' elements should have the mandatory flag
-- set to 'N' for the input value 'Deduction Processing'
--
      IF (UPPER(p_ele_class) = 'EARNINGS')
        OR
         (UPPER(p_ele_class) = 'IMPUTED EARNINGS')
      THEN
        v_mand_flag := 'X';
      ELSIF (UPPER(p_ele_class) = 'NON-PAYROLL PAYMENTS') THEN
        v_mand_flag := 'N';
      ELSE
        v_mand_flag := 'Y';
      END IF;

      hr_utility.set_location('pyusuiet',510);
      v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => v_mand_flag,
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => v_val_formula_id,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',515);
      hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_type_id,
                        p_legislation_code              => g_template_leg_code,
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => p_eff_end,
                        p_insert_update_flag            => 'UPDATE',
                        p_input_value_id                => v_inpval_id,
                        p_rowid                         => NULL,
                        p_recurring_flag                => p_ele_proc_type,
                        p_mandatory_flag                => v_mand_flag,
                        p_hot_default_flag              => 'N',
                        p_standard_link_flag            => 'N',
                        p_classification_type           => 'N',
                        p_name                          => v_inpval_name,
                        p_uom                           => v_inpval_uom,
                        p_min_value                     => NULL,
                        p_max_value                     => NULL,
                        p_default_value                 => v_dflt_value,
                        p_lookup_type                   => v_lkp_type,
                        p_formula_id                    => NULL,
                        p_generate_db_items_flag        => v_gen_dbi,
                        p_warning_or_error              => NULL);

      hr_utility.set_location('pyusuiet',520);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => p_eff_end,
                        p_element_type_id               => p_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => v_dflt_value,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
  -- (HERE) Done inserting "Deduction Processing" input value.
  --
  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  -- Creating "Separate Check" inpval
      hr_utility.set_location('pyusuiet',525);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name := 'Separate Check';
      v_inpval_uom := 'C';
      v_gen_dbi := 'N';
      v_lkp_type := 'YES_NO';
      v_dflt_value := substr(p_sep_chk_opt,1,1);
      --
--
-- 385252 : Imputeds and Earnings can never be processed via sep check or deduction processing.
-- Therefore we do not allow entry of these inputs...with the exceptions of:
-- 384282: Nonrecurring Imputeds can process in tax only or sepcheck runs;
-- 399471: Earnings can process in supp, tax only, or sepcheck runs when category
-- is other than 'REG' or 'ENWH' - ie. for overtime, shift, and future categories.
-- 407348 : Nonrecurring Imputeds cannot enter these inputs, but still process
-- in supplemental run by virtue of skip formula set by 384282.
--
      IF (UPPER(p_ele_class) = 'EARNINGS')
        OR
         (UPPER(p_ele_class) = 'IMPUTED EARNINGS')

      THEN

        v_mand_flag := 'X';

      ELSE

        v_mand_flag := 'Y';

      END IF;

      hr_utility.set_location('pyusuiet',530);
      v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => v_mand_flag,
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => v_val_formula_id,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',535);
      hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_type_id,
                        p_legislation_code              => g_template_leg_code,
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => p_eff_end,
                        p_insert_update_flag            => 'UPDATE',
                        p_input_value_id                => v_inpval_id,
                        p_rowid                         => NULL,
                        p_recurring_flag                => p_ele_proc_type,
                        p_mandatory_flag                => v_mand_flag,
                        p_hot_default_flag              => 'N',
                        p_standard_link_flag            => 'N',
                        p_classification_type           => 'N',
                        p_name                          => v_inpval_name,
                        p_uom                           => v_inpval_uom,
                        p_min_value                     => NULL,
                        p_max_value                     => NULL,
                        p_default_value                 => v_dflt_value,
                        p_lookup_type                   => v_lkp_type,
                        p_formula_id                    => NULL,
                        p_generate_db_items_flag        => v_gen_dbi,
                        p_warning_or_error              => NULL);

      hr_utility.set_location('pyusuiet',540);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => p_eff_end,
                        p_element_type_id               => p_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => v_dflt_value,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);

  -- (HERE) Done inserting "Separate Check" input value.

--
  --
  -- Creating "Date Earned" inpval
  --
/*

hr_utility.trace('I am going to create the Date Earned');
  hr_utility.set_location('pyusuiet',545);
  g_inpval_disp_seq := g_inpval_disp_seq + 1;
  v_inpval_name := 'Date Earned';
  v_inpval_uom := 'Date (DD-MON-YYYY)';
  v_gen_dbi     := 'N';

  hr_utility.trace('The input value name is '|| v_inpval_name );
  hr_utility.set_location('pyusuiet',550);
  v_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name);

  hr_utility.set_location('pyusuiet',555);
  hr_input_values.chk_input_value(
                        p_element_type_id               => p_ele_type_id,
                        p_legislation_code              => g_template_leg_code,
                           p_val_start_date             => p_eff_start,
                           p_val_end_date               => p_eff_end,
                           p_insert_update_flag         => 'UPDATE',
                           p_input_value_id             => v_inpval_id,
                           p_rowid                      => NULL,
                           p_recurring_flag             => p_ele_proc_type,
                           p_mandatory_flag             => 'N',
                           p_hot_default_flag           => 'N',
                           p_standard_link_flag         => 'N',
                           p_classification_type        => 'N',
                           p_name                       => v_inpval_name,
                           p_uom                        => v_inpval_uom,
                           p_min_value                  => NULL,
                           p_max_value                  => NULL,
                           p_default_value              => NULL,
                           p_lookup_type                => NULL,
                           p_formula_id                 => NULL,
                           p_generate_db_items_flag     => v_gen_dbi,
                           p_warning_or_error           => NULL);

  hr_utility.set_location('pyusuiet',560);
  hr_input_values.ins_3p_input_values(
                        p_val_start_date                => p_eff_start,
                        p_val_end_date                  => p_eff_end,
                        p_element_type_id               => p_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id                => v_inpval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => v_inpval_name,
                        p_db_items_flag                 => v_gen_dbi,
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
 */
  --
  -- (HERE) Done inserting "Date Earned" input value.
  --
  -- Create inpvals on "<ELE_NAME> Special Inputs" (Repl/Addl Amts)
  --
  -- Create input values on "<ELE_NAME> Special Inputs" element (shadow):
  -- "Replacement Amt", "Addl Amt", "Neg Earnings"
  -- Creating "Replace Amt" inpval

If p_ele_proc_type = 'R' then    /* Not required for NR Elements  */

      hr_utility.set_location('pyusuiet',565);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name := 'Replace Amt';
      v_inpval_uom := 'M';
      v_gen_dbi := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      gi_repl_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_inputs_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => NULL,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',570);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_inputs_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => gi_repl_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',575);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_inputs_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => gi_repl_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Replacement Amount" input value.
  --
  -- Creating "Addl Amt" inpval
  --
      hr_utility.set_location('pyusuiet',580);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name := 'Addl Amt';
      v_inpval_uom := 'M';
      v_gen_dbi := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      gi_addl_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_inputs_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => NULL,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',585);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_inputs_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => gi_addl_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',590);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_inputs_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => gi_addl_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);

End If;   /* Not required for NR Elements  */

  --
  -- (HERE) Done inserting "Addl Amt" input value.
  --
  -- Create input values on "<ELE_NAME> Special Features" element (shadow):
  -- "Replacement Amt", "Addl Amt", "Neg Earnings", and "Reduce Regular Hours"
  -- Creating "Replacement Amt" inpval

/* SInce we are removing the Additional Amount and Replacement Amount there will be
   no Formula Result Rules.

   I think we should not create these input values too.   */

/* Not required for NR Elements */

   g_inpval_disp_seq := 0;

If p_ele_proc_type = 'R' then    /* Not required for NR Elements  */

      hr_utility.set_location('pyusuiet',595);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name := 'Replacement Amt';
      v_inpval_uom := 'M';
      v_gen_dbi := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_repl_inpval_id := pay_db_pay_setup.create_input_value (
                        p_element_name  => p_shadow_ele_name,
                        p_name                  => v_inpval_name,
                        p_uom_code              => v_inpval_uom,
                        p_mandatory_flag        => 'N',
                        p_generate_db_item_flag => v_gen_dbi,
                        p_default_value                 => v_dflt_value,
                        p_min_value                     => NULL,
                        p_max_value                     => NULL,
                        p_warning_or_error              => NULL,
                        p_lookup_type           => v_lkp_type,
                        p_formula_id            => NULL,
                        p_hot_default_flag              => 'N',
                        p_display_sequence      => g_inpval_disp_seq,
                        p_business_group_name   => p_bg_name,
                        p_effective_start_date  => p_eff_start,
                        p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',600);
      hr_input_values.chk_input_value(
                p_element_type_id       => p_shadow_ele_type_id,
                p_legislation_code      => g_template_leg_code,
                p_val_start_date        => p_eff_start,
                p_val_end_date          => p_eff_end,
                p_insert_update_flag    => 'UPDATE',
                p_input_value_id        => g_repl_inpval_id,
                p_rowid                 => NULL,
                p_recurring_flag        => 'N',
                p_mandatory_flag        => 'N',
                p_hot_default_flag      => 'N',
                p_standard_link_flag    => 'N',
                p_classification_type   => 'N',
                p_name                  => v_inpval_name,
                p_uom                   => v_inpval_uom,
                p_min_value             => NULL,
                p_max_value             => NULL,
                p_default_value         => NULL,
                p_lookup_type           => NULL,
                p_formula_id            => NULL,
                p_generate_db_items_flag => v_gen_dbi,
                p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',605);
      hr_input_values.ins_3p_input_values(
                p_val_start_date        => p_eff_start,
                p_val_end_date          => p_eff_end,
                p_element_type_id       => p_shadow_ele_type_id,
                p_primary_classification_id     => p_primary_class_id,
                p_input_value_id        => g_repl_inpval_id,
                p_default_value         => NULL,
                p_max_value             => NULL,
                p_min_value             => NULL,
                p_warning_or_error_flag => NULL,
                p_input_value_name      => v_inpval_name,
                p_db_items_flag         => v_gen_dbi,
                p_costable_type         => NULL,
                p_hot_default_flag      => 'N',
                p_business_group_id     => p_bg_id,
                p_legislation_code      => NULL,
                p_startup_mode          => NULL);
 --
  -- (HERE) Done inserting "Replacement Amount" input value.
  --
  -- Creating "Addl Amt" inpval
  --
      hr_utility.set_location('pyusuiet',610);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name := 'Additional Amt';
      v_inpval_uom := 'M';
      v_gen_dbi := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_addl_inpval_id := pay_db_pay_setup.create_input_value (
                        p_element_name  => p_shadow_ele_name,
                        p_name                  => v_inpval_name,
                        p_uom_code              => v_inpval_uom,
                        p_mandatory_flag        => 'N',
                        p_generate_db_item_flag => v_gen_dbi,
                        p_default_value         => v_dflt_value,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_warning_or_error      => NULL,
                        p_lookup_type           => v_lkp_type,
                        p_formula_id            => NULL,
                        p_hot_default_flag      => 'N',
                        p_display_sequence      => g_inpval_disp_seq,
                        p_business_group_name   => p_bg_name,
                        p_effective_start_date  => p_eff_start,
                        p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',615);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_addl_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',620);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_addl_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);

End if;  /* Not required for NR Elements */

  --
  -- (HERE) Done inserting "Addl Amt" input value.
  --
  -- Now insert "Neg Earnings".
  --
    hr_utility.set_location('pyusuiet',625);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name     := 'Neg Earnings';
      v_inpval_uom      := 'M';
      v_gen_dbi         := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_neg_earn_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_shadow_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => NULL,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);

    hr_utility.set_location('pyusuiet',630);
    hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_neg_earn_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',635);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_neg_earn_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Neg Earnings" input value.
  --

  -- Now insert "Reduce Reg Hours".
  --
    hr_utility.set_location('pyusuiet',640);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name     := 'Reduce Reg Hours';
      v_inpval_uom      := 'H_DECIMAL2'; --Hours in Decimal format (2 places)
      v_gen_dbi         := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_reduce_hrs_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_shadow_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => NULL,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);


      hr_utility.set_location('pyusuiet',645);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_reduce_hrs_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',650);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_reduce_hrs_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Reduce Reg Hours" input value.

  -- Now insert "Reduce Reg Pay".
  --
    hr_utility.set_location('pyusuiet',655);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name     := 'Reduce Reg Pay';
      v_inpval_uom      := 'M';
      v_gen_dbi         := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_reduce_pay_inpval_id := pay_db_pay_setup.create_input_value (
                        p_element_name  => p_shadow_ele_name,
                        p_name                  => v_inpval_name,
                        p_uom_code              => v_inpval_uom,
                        p_mandatory_flag        => 'N',
                        p_generate_db_item_flag => v_gen_dbi,
                        p_default_value         => v_dflt_value,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_warning_or_error      => NULL,
                        p_lookup_type           => v_lkp_type,
                        p_formula_id            => NULL,
                        p_hot_default_flag      => 'N',
                        p_display_sequence      => g_inpval_disp_seq,
                        p_business_group_name   => p_bg_name,
                        p_effective_start_date  => p_eff_start,
                        p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',660);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_reduce_pay_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',665);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_reduce_pay_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Reduce Reg Pay" input value.

  -- Now insert "Reduce Sal Hours".
  --
    hr_utility.set_location('pyusuiet',670);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name     := 'Reduce Sal Hours';
      v_inpval_uom      := 'H_DECIMAL2'; --Hours in Decimal format (2 places)
      v_gen_dbi         := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_reduce_sal_hrs_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_shadow_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => NULL,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',675);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_reduce_sal_hrs_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',680);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_reduce_sal_hrs_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Reduce Sal Hours" input value.

  -- Now insert "Reduce Sal Pay".
  --
    hr_utility.set_location('pyusuiet',685);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name     := 'Reduce Sal Pay';
      v_inpval_uom      := 'M';
      v_gen_dbi         := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_reduce_sal_pay_inpval_id := pay_db_pay_setup.create_input_value (
                        p_element_name  => p_shadow_ele_name,
                        p_name                  => v_inpval_name,
                        p_uom_code              => v_inpval_uom,
                        p_mandatory_flag        => 'N',
                        p_generate_db_item_flag => v_gen_dbi,
                        p_default_value         => v_dflt_value,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_warning_or_error      => NULL,
                        p_lookup_type           => v_lkp_type,
                        p_formula_id            => NULL,
                        p_hot_default_flag      => 'N',
                        p_display_sequence      => g_inpval_disp_seq,
                        p_business_group_name   => p_bg_name,
                        p_effective_start_date  => p_eff_start,
                        p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',690);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_reduce_sal_pay_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',695);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_reduce_sal_pay_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Reduce Sal Pay" input value.

  -- Now insert "Reduce Wag Hours".
  --
    hr_utility.set_location('pyusuiet',700);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name     := 'Reduce Wag Hours';
      v_inpval_uom      := 'H_DECIMAL2'; --Hours in Decimal format (2 places)
      v_gen_dbi         := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_reduce_wag_hrs_inpval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_shadow_ele_name,
                                p_name                  => v_inpval_name,
                                p_uom_code              => v_inpval_uom,
                                p_mandatory_flag        => 'N',
                                p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => NULL,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => g_inpval_disp_seq,
                                p_business_group_name   => p_bg_name,
                                p_effective_start_date  => p_eff_start,
                                p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',705);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_reduce_wag_hrs_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',710);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_reduce_wag_hrs_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Reduce Wag Hours" input value.

  -- Now insert "Reduce Wag Pay".
  --
    hr_utility.set_location('pyusuiet',715);
      g_inpval_disp_seq := g_inpval_disp_seq + 1;
      v_inpval_name     := 'Reduce Wag Pay';
      v_inpval_uom      := 'M';
      v_gen_dbi         := 'N';
      v_lkp_type        := NULL;
      v_dflt_value      := NULL;
      g_reduce_wag_pay_inpval_id := pay_db_pay_setup.create_input_value (
                        p_element_name  => p_shadow_ele_name,
                        p_name                  => v_inpval_name,
                        p_uom_code              => v_inpval_uom,
                        p_mandatory_flag        => 'N',
                        p_generate_db_item_flag => v_gen_dbi,
                        p_default_value         => v_dflt_value,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_warning_or_error      => NULL,
                        p_lookup_type           => v_lkp_type,
                        p_formula_id            => NULL,
                        p_hot_default_flag      => 'N',
                        p_display_sequence      => g_inpval_disp_seq,
                        p_business_group_name   => p_bg_name,
                        p_effective_start_date  => p_eff_start,
                        p_effective_end_date    => p_eff_end);

      hr_utility.set_location('pyusuiet',720);
      hr_input_values.chk_input_value(
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => g_reduce_wag_pay_inpval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'N',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => v_inpval_name,
                        p_uom                   => v_inpval_uom,
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => v_gen_dbi,
                        p_warning_or_error      => NULL);

      hr_utility.set_location('pyusuiet',725);
      hr_input_values.ins_3p_input_values(
                        p_val_start_date        => p_eff_start,
                        p_val_end_date          => p_eff_end,
                        p_element_type_id       => p_shadow_ele_type_id,
                        p_primary_classification_id     => p_primary_class_id,
                        p_input_value_id        => g_reduce_wag_pay_inpval_id,
                        p_default_value         => NULL,
                        p_max_value             => NULL,
                        p_min_value             => NULL,
                        p_warning_or_error_flag => NULL,
                        p_input_value_name      => v_inpval_name,
                        p_db_items_flag         => v_gen_dbi,
                        p_costable_type         => NULL,
                        p_hot_default_flag      => 'N',
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_startup_mode          => NULL);
  --
  -- (HERE) Done inserting "Reduce Wag Pay" input value.

    hr_utility.set_location('pyusuiet',730);
    SELECT      status_processing_rule_id
    INTO                v_status_proc_id
    FROM        pay_status_processing_rules_f
    WHERE       assignment_status_type_id IS NULL
    AND         element_type_id = p_ele_type_id;
  --

If p_ele_proc_type = 'R' then    /* Not required for NR Elements  */

    hr_utility.set_location('pyusuiet',735);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_repl_inpval_id,
        p_result_name                   => 'CLEAR_REPL_AMT',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id);
    --
    hr_utility.set_location('pyusuiet',740);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_addl_inpval_id,
        p_result_name                   => 'CLEAR_ADDL_AMT',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id );
      --

End if; /* Not required for NR Elements */


    hr_utility.set_location('pyusuiet',745);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_reduce_hrs_inpval_id,
        p_result_name                   => 'REDUCE_REG_HOURS',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id );
      --

/* get the input value id for the Pay Value input value for the shadow  element. */

    hr_utility.set_location('pyusuiet',750);
    select pivf.input_value_id
    into g_shadow_info_payval_id
    from pay_input_values_f pivf
    where pivf.element_type_id = p_shadow_ele_type_id
    and  pivf.name = 'Pay Value';

    hr_utility.set_location('pyusuiet',755);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_shadow_info_payval_id,
        p_result_name                   => 'REDUCE_REG_PAY',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id );
      --

      --
    hr_utility.set_location('pyusuiet',760);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_reduce_sal_hrs_inpval_id,
        p_result_name                   => 'REDUCE_SAL_HOURS',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id );
      --
    hr_utility.set_location('pyusuiet',765);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_reduce_sal_pay_inpval_id,
        p_result_name                   => 'REDUCE_SAL_PAY',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id );
      --

      --
    hr_utility.set_location('pyusuiet',770);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_reduce_wag_hrs_inpval_id,
        p_result_name                   => 'REDUCE_WAG_HOURS',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id );
      --

    hr_utility.set_location('pyusuiet',775);
    v_resrule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_reduce_wag_pay_inpval_id,
        p_result_name                   => 'REDUCE_WAG_PAY',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id );
      --

    IF UPPER(p_ele_proc_type) = 'R' THEN
      --
      hr_utility.set_location('pyusuiet',780);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
        p_business_group_id             => p_bg_id,
        p_legislation_code              => NULL,
        p_legislation_subgroup          => g_template_leg_subgroup,
        p_effective_start_date          => p_eff_start,
        p_effective_end_date            => p_eff_end,
        p_status_processing_rule_id     => v_status_proc_id,
        p_input_value_id                => g_neg_earn_inpval_id,
        p_result_name                   => 'NEG_EARN',
        p_result_rule_type              => 'I',
        p_severity_level                => NULL,
        p_element_type_id               => p_shadow_ele_type_id);
    --
    END IF;
    --
--
-- Done!
--
END ins_uie_input_vals;
--

PROCEDURE create_reduce_regpay_feeds (p_eff_start_date in date) IS

-- Note : If cat feeder does this for earn/regs, then we do NOT want to create
-- feeds from reducing regulars to regsal and regwage associated primary bals...
-- Ie. create feeds where baltype id <> ele info 10 on regsal/wages.
-- Modify the get bal cursor...

l_bal_id        number(9);
l_pv_id         number(9);
l_pv_name       varchar2(80);

already_exists  number;

-- bug 962590 modified cursor to exclude 'FLSA Hours' and 'FLSA Earnings'
-- bugs 944994 and 708373 Now excluding elements that are feed via the
-- 'classification balance feeder' as the change in bug 708373 now assigns a value
-- to the special features "Element" pay value (the pay value input value
-- is automatically taken care of in the "classification balance feeder"

CURSOR  get_reg_feeds (p_iv_id in number) IS
SELECT  f.balance_type_id
FROM            pay_balance_feeds_f f,
		pay_balance_types bt
WHERE           f.input_value_id = p_iv_id
AND             p_eff_start_date between f.effective_start_date
                                                      and f.effective_end_date
AND 		bt.balance_name not in ('FLSA Earnings','FLSA Hours')
AND		bt.balance_type_id = f.balance_type_id
and     bt.balance_type_id not in
        (select bc.balance_type_id
         from   pay_balance_classifications bc,
                pay_element_classifications ec
         where ec.legislation_code = 'US'
         and   ec.classification_name = 'Earnings'
         and   bc.classification_id = ec.classification_id);

BEGIN

    l_pv_name := hr_input_values.get_pay_value_name(g_template_leg_code);

    select i.input_value_id
    into   l_pv_id
    from   pay_element_types_f e,
         pay_input_values_f i
    where  e.element_name = 'Regular Salary'
    and    p_eff_start_date between e.effective_start_date
                                and e.effective_end_date
    and    e.business_group_id is null
    and    e.legislation_code = 'US'
    and    i.element_type_id = e.element_type_id
    and i.name = l_pv_name
    and    p_eff_start_date between i.effective_start_date
                                and i.effective_end_date
    and    i.business_group_id is null
    and    i.legislation_code = 'US';


open get_reg_feeds (l_pv_id);

loop

  fetch get_reg_feeds into l_bal_id;
  exit when get_reg_feeds%notfound;

  select COUNT(0)
  into   already_exists
  from   pay_balance_feeds_f
  where  input_value_id = g_reduce_pay_inpval_id
  and    balance_type_id = l_bal_id;

  IF already_exists = 0 THEN

    hr_balances.ins_balance_feed(
                p_option                      => 'INS_MANUAL_FEED',
                p_input_value_id              => g_reduce_sal_pay_inpval_id,
                p_element_type_id             => NULL,
                p_primary_classification_id   => NULL,
                p_sub_classification_id       => NULL,
                p_sub_classification_rule_id  => NULL,
                p_balance_type_id             => l_bal_id,
                p_scale                       => '-1',
                p_session_date                => g_eff_start_date,
                p_business_group              => p_bg_id,
                p_legislation_code            => NULL,
                p_mode                        => 'USER');

  END IF;

end loop;

close get_reg_feeds;


    select i.input_value_id
    into   l_pv_id
    from   pay_element_types_f e,
           pay_input_values_f i
    where  e.element_name = 'Regular Wages'
    and    p_eff_start_date between e.effective_start_date
                                and e.effective_end_date
    and    e.business_group_id is null
    and    e.legislation_code = 'US'
    and    i.element_type_id = e.element_type_id
    and    i.name = l_pv_name
    and    p_eff_start_date between i.effective_start_date
                                and i.effective_end_date
    and    i.business_group_id is null
    and    i.legislation_code = 'US';


open get_reg_feeds (l_pv_id);

loop

  fetch get_reg_feeds into l_bal_id;
  exit when get_reg_feeds%notfound;

  select COUNT(0)
  into   already_exists
  from   pay_balance_feeds_f
  where  input_value_id = g_reduce_pay_inpval_id
  and    balance_type_id = l_bal_id;

  IF already_exists = 0 THEN

    hr_balances.ins_balance_feed(
                p_option                       => 'INS_MANUAL_FEED',
                p_input_value_id               => g_reduce_wag_pay_inpval_id,
                p_element_type_id              => NULL,
                p_primary_classification_id    => NULL,
                p_sub_classification_id        => NULL,
                p_sub_classification_rule_id   => NULL,
                p_balance_type_id              => l_bal_id,
                p_scale                        => '-1',
                p_session_date                 => g_eff_start_date,
                p_business_group               => p_bg_id,
                p_legislation_code             => NULL,
                p_mode                         => 'USER');

  END IF;

end loop;

close get_reg_feeds;

END create_reduce_regpay_feeds;


PROCEDURE create_regearn_feeds (        p_iv_id              in number,
                                        p_eff_start_date     in date,
					p_business_group_id  in number) IS

-- Note : If cat feeder does this for earn/regs, then we do NOT want to create
-- feeds from reducing regulars to regsal and regwage associated primary bals...
-- Ie. create feeds where baltype id <> ele info 10 on regsal/wages.
-- Modify the get bal cursor...

l_bal_id        number(9);
l_pv_id         number(9);
l_pv_name       varchar2(80);

already_exists  number;

-- bug 962590 added FLSA Hours and FLSA Earnings check to cursor
CURSOR  get_reg_feeds (p_iv_id in number, p_business_group_id in number) IS
SELECT  f.balance_type_id
FROM            pay_balance_feeds_f f,
                pay_balance_types bt
WHERE           f.input_value_id = p_iv_id
AND             p_eff_start_date between f.effective_start_date
                                                      and f.effective_end_date
AND             (  (bt.business_group_id is NULL and bt.legislation_code = 'US')
                 OR (bt.business_group_id = p_business_group_id and bt.legislation_code is NULL) )
AND             bt.balance_type_id = f.balance_type_id
AND             bt.balance_name not in ('Regular Salary', 'Regular Wages','FLSA Hours','FLSA Earnings');

BEGIN

    l_pv_name := hr_input_values.get_pay_value_name(g_template_leg_code);

    select i.input_value_id
    into   l_pv_id
    from   pay_element_types_f e,
         pay_input_values_f i
    where  e.element_name = 'Regular Salary'
    and    p_eff_start_date between e.effective_start_date
                                and e.effective_end_date
    and    e.business_group_id is null
    and    e.legislation_code = 'US'
    and    i.element_type_id = e.element_type_id
    and i.name = l_pv_name
    and    p_eff_start_date between i.effective_start_date
                                and i.effective_end_date
    and    i.business_group_id is null
    and    i.legislation_code = 'US';


open get_reg_feeds (l_pv_id,p_business_group_id);

loop

  fetch get_reg_feeds into l_bal_id;
  exit when get_reg_feeds%notfound;

  select COUNT(0)
  into   already_exists
  from   pay_balance_feeds_f
  where  input_value_id =  p_iv_id
  and    balance_type_id = l_bal_id;

  IF already_exists = 0 THEN

    hr_balances.ins_balance_feed(
                p_option                      => 'INS_MANUAL_FEED',
                p_input_value_id              => p_iv_id,
                p_element_type_id             => NULL,
                p_primary_classification_id   => NULL,
                p_sub_classification_id       => NULL,
                p_sub_classification_rule_id  => NULL,
                p_balance_type_id             => l_bal_id,
                p_scale                       => '1',
                p_session_date                => g_eff_start_date,
                p_business_group              => p_bg_id,
                p_legislation_code            => NULL,
                p_mode                        => 'USER');

  END IF;

end loop;

close get_reg_feeds;


    select i.input_value_id
    into   l_pv_id
    from   pay_element_types_f e,
           pay_input_values_f i
    where  e.element_name = 'Regular Wages'
    and    p_eff_start_date between e.effective_start_date
                                and e.effective_end_date
    and    e.business_group_id is null
    and    e.legislation_code = 'US'
    and    i.element_type_id = e.element_type_id
    and    i.name = l_pv_name
    and    p_eff_start_date between i.effective_start_date
                                and i.effective_end_date
    and    i.business_group_id is null
    and    i.legislation_code = 'US';


open get_reg_feeds (l_pv_id,p_business_group_id);

loop

  fetch get_reg_feeds into l_bal_id;
  exit when get_reg_feeds%notfound;

  select COUNT(0)
  into   already_exists
  from   pay_balance_feeds_f
  where  input_value_id = p_iv_id
  and    balance_type_id = l_bal_id;

  IF already_exists = 0 THEN

    hr_balances.ins_balance_feed(
                p_option                     => 'INS_MANUAL_FEED',
                p_input_value_id             => p_iv_id,
                p_element_type_id            => NULL,
                p_primary_classification_id  => NULL,
                p_sub_classification_id      => NULL,
                p_sub_classification_rule_id => NULL,
                p_balance_type_id            => l_bal_id,
                p_scale                      => '1',
                p_session_date               => g_eff_start_date,
                p_business_group             => p_bg_id,
                p_legislation_code           => NULL,
                p_mode                       => 'USER');

  END IF;

end loop;

close get_reg_feeds;

END create_regearn_feeds;

-------------------------------- do_insertions Main --------------------------
--
-- Main Procedure

BEGIN

--
-- Set session date

hr_utility.set_location('pyusuiet',785);
pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
g_eff_start_date        := NVL(p_ele_eff_start_date, sysdate);
g_eff_end_date          := NVL(p_ele_eff_end_date, c_end_of_time);

-- Set globals: v_bg_name
hr_utility.set_location('pyusuiet',790);
select  name
into    v_bg_name
from    per_business_groups
where   business_group_id = p_bg_id;
--
--------------------- Create Balances Types and Defined Balances --------------
--
-- Could make direct call to API for each balance req'd.
-- Let's do that since only "primary" balances are ever req'd for ui earnings.
-- Create bal type, then Defined_Balances for PTD, MTD, and YTD dimensions.
-- Let currency code default to leg currency.
-- ins_uie_balance (e_name, bal_uom);

hr_utility.set_location('pyusuiet',795);
-- Check element name, ie. primary balance name, is unique to
-- balances within this BG.

pay_balance_types_pkg.chk_balance_type(
                        p_row_id                => NULL,
                        p_business_group_id     => p_bg_id,
                        p_legislation_code      => NULL,
                        p_balance_name          => p_ele_name,
                        p_reporting_name        => p_ele_name,
                        p_assignment_remuneration_flag => 'N');

hr_utility.set_location('pyusuiet',800);
-- Check element name, ie. primary balance name, is unique to
-- balances provided as startup data.

pay_balance_types_pkg.chk_balance_type(
                        p_row_id                => NULL,
                        p_business_group_id     => NULL,
                        p_legislation_code      => 'US',
                        p_balance_name          => p_ele_name,
                        p_reporting_name        => p_ele_name,
                        p_assignment_remuneration_flag => 'N');

--
-- check for existence of balance type before creating...return bal type id if already exists...
--

--
-- Emp Balance form enhancement. Bug 3311781
-- Used 'l_bal_cat_classification' for passing the value of p_balance_category
-- in the call to 'pay_db_pay_setup.create_balance_type' for creating balances

if upper(p_ele_classification) = 'EARNINGS' then
   l_bal_cat_classification := 'Earnings';
elsif upper(p_ele_classification) = 'IMPUTED EARNINGS' then
      l_bal_cat_classification := 'Imputed Earnings';
   elsif upper(p_ele_classification) = 'NON-PAYROLL PAYMENTS' then
         l_bal_cat_classification := 'Non-payroll Payments';
      else
         l_bal_cat_classification := 'Supplemental Earnings';
end if;

hr_utility.set_location('pyusuiet',805);
v_bal_type_id := pay_db_pay_setup.create_balance_type(
        p_balance_name          => p_ele_name,
        p_uom                   => null,
        p_uom_code              => 'M',
        p_reporting_name        => p_ele_name,
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL,
        p_legislation_subgroup  => NULL,
        p_balance_category      => l_bal_cat_classification, --Bug 3311781
        p_bc_leg_code           => 'US',
        p_effective_date        => g_eff_start_date);
--
IF p_ele_processing_type = 'R' THEN
  v_neg_earnbal_name := SUBSTR(p_ele_name, 1, 65)||' Neg Earnings';
  --v_bal_repname      := SUBSTR(p_ele_reporting_name, 1, 15)||' Neg Earnings';

  hr_utility.set_location('pyusuiet',810);
  v_neg_earn_bal_type_id := pay_db_pay_setup.create_balance_type(
        p_balance_name          => v_neg_earnbal_name,
        p_uom                   => null,
        p_uom_code              => 'M',
        p_reporting_name        => v_neg_earnbal_name,
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL,
        p_legislation_subgroup  => NULL,
        p_balance_category      => l_bal_cat_classification, -- Bug 3311781
        p_bc_leg_code           => 'US',
        p_effective_date        => g_eff_start_date);
END IF;
--
-- NOTE: For primary balances, the feeds should not be altered - only one
-- value should ever feed the primary balance (ie. the element's payvalue).
--
-- 09 Jun 94: Balances are required for Additional and Replacement Amounts
--
IF p_ele_processing_type = 'R' THEN  /* Not required for NR Elements Change */
   v_addl_amt_bal_name := SUBSTR(p_ele_name, 1, 67)||' Additional';
   --v_bal_repname      := SUBSTR(p_ele_reporting_name, 1, 17)||' Additional';

   hr_utility.set_location('pyusuiet',815);
   v_addl_amt_bal_type_id := pay_db_pay_setup.create_balance_type(
        p_balance_name          => v_addl_amt_bal_name,
        p_uom                   => null,
        p_uom_code              => 'M',
        p_reporting_name        => v_addl_amt_bal_name,
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL,
        p_legislation_subgroup  => NULL,
        p_balance_category      => l_bal_cat_classification, -- Bug 3311781
        p_bc_leg_code           => 'US',
        p_effective_date        => g_eff_start_date);
--
   v_repl_amt_bal_name := SUBSTR(p_ele_name, 1, 67)||' Replacement';
   --v_bal_repname      := SUBSTR(p_ele_reporting_name, 1, 17)||' Replacement';

   hr_utility.set_location('pyusuiet',820);
   v_repl_amt_bal_type_id := pay_db_pay_setup.create_balance_type(
        p_balance_name          => v_repl_amt_bal_name,
        p_uom                   => null,
        p_uom_code              => 'M',
        p_reporting_name        => v_repl_amt_bal_name,
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL,
        p_legislation_subgroup  => NULL,
        p_balance_category      => l_bal_cat_classification, -- Bug 3311781
        p_bc_leg_code           => 'US',
        p_effective_date        => g_eff_start_date);

end if;  /* Not required for NR Elements Change */
--
-- Defined Balances (ie. balance type associated with a dimension)
--
hr_utility.set_location('pyusuiet',825);

--
-- check for existence of defined balance before creating...return defbal id if already exists...
--

   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Year to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',830);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Period to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',835);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Quarter to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',840);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Run',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL,
        p_save_run_bal          => 'Y');

hr_utility.set_location('pyusuiet',845);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Month',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',850);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment-Level Current Run',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',855);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment Period to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',860);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment Month',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',865);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment Quarter to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',870);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment Year to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',875);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person Run',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',880);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person Quarter to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',885);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person Year to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',890);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person Month',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',895);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person within Government Reporting Entity Run',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',900);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person within Government Reporting Entity Quarter to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',910);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person within Government Reporting Entity Year to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',915);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Person within Government Reporting Entity Month',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

hr_utility.set_location('pyusuiet',920);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Government Reporting Entity Year to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

/* *** WWBug 133133 start *** */
/* Adding defined balances for GRE_RUN and GRE_ITD for primary balance */
hr_utility.set_location('pyusuiet',925);
pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Government Reporting Entity Run',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

IF p_ele_processing_type = 'R' THEN /* Not required for NR Elements  */

   hr_utility.set_location('pyusuiet',930);
   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Government Reporting Entity Inception to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

end if;

/* *** WWBug 133133 finish *** */

/* bug 1835350 begin
IF UPPER(p_ele_classification) <> 'NON-PAYROLL PAYMENTS' THEN
  bug 1835350 end */

  hr_utility.set_location('pyusuiet',935);
  pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Payments',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

  hr_utility.set_location('pyusuiet',940);
  pay_db_pay_setup.create_defined_balance (
        p_balance_name          => p_ele_name,
        p_balance_dimension     => 'Assignment Payments',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

/* bug 1835350 begin
END IF;
  bug 1835350 end */

hr_utility.trace('I before p_ele_processing_type ');
hr_utility.trace('p_ele_processing_type is '||p_ele_processing_type);

IF p_ele_processing_type = 'R' THEN
  hr_utility.set_location('pyusuiet',945);
  pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_neg_earnbal_name,
        p_balance_dimension   => 'Assignment within Government Reporting Entity Inception to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);
--
END IF;
--
IF p_ele_processing_type = 'R' THEN /* Not required for NR Elements */
   hr_utility.set_location('pyusuiet',950);
   pay_db_pay_setup.create_defined_balance (
       p_balance_name          => v_addl_amt_bal_name,
       p_balance_dimension   => 'Assignment within Government Reporting Entity Inception to Date',
       p_business_group_name   => v_bg_name,
       p_legislation_code      => NULL);

   hr_utility.set_location('pyusuiet',955);
   pay_db_pay_setup.create_defined_balance (
      p_balance_name          => v_repl_amt_bal_name,
      p_balance_dimension   => 'Assignment within Government Reporting Entity Inception to Date',
      p_business_group_name   => v_bg_name,
      p_legislation_code      => NULL);

END IF; /* Not required for NR Elements */

IF UPPER(p_ele_calc_ff_name) in (
                                'HOURS_X_RATE_RECUR_V2',
                                'HOURS_X_RATE_NONRECUR_V2',
                                'HOURS_X_RATE_MULTIPLE_RECUR_V2',
                                'HOURS_X_RATE_MULTIPLE_NONRECUR_V2') THEN


hr_utility.trace('I am inside the UPPER IN...HOURS X....');
hr_utility.trace('p_ele_calc_ff_name  is '||p_ele_calc_ff_name);

  -- Create "Hours" associated balance for this earning; _ASG_RUN dim.
  v_hrs_bal_name        := SUBSTR(p_ele_name, 1, 73)||' Hours';
  --v_hrs_bal_repname  := SUBSTR(p_ele_reporting_name, 1, 23)||' Hours';

  hr_utility.set_location('pyusuiet',960);
  v_hrs_bal_type_id := pay_db_pay_setup.create_balance_type(
        p_balance_name          => v_hrs_bal_name,
        p_uom                   => null,
        p_uom_code              => 'H_DECIMAL2',
        p_reporting_name        => v_hrs_bal_name,
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL,
        p_legislation_subgroup  => NULL,
        p_balance_category      => l_bal_cat_classification, -- Bug 3311781
        p_bc_leg_code           => 'US',
        p_effective_date        => g_eff_start_date);

  hr_utility.set_location('pyusuiet',965);
  pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Assignment-Level Current Run',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

  hr_utility.set_location('pyusuiet',970);
  pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Run',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL,
        p_save_run_bal          => 'Y');

-- 16th Feb 1996 Fix - added Payments defined bal to Hours assoc bal.
   hr_utility.set_location('pyusuiet',975);
   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Payments',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

   hr_utility.set_location('pyusuiet',980);
   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Assignment Quarter to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

   hr_utility.set_location('pyusuiet',985);
   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Assignment Year to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

   hr_utility.set_location('pyusuiet',990);
   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Quarter to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Assignment within Government Reporting Entity Year to Date',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);

   hr_utility.set_location('pyusuiet',995);
   pay_db_pay_setup.create_defined_balance (
        p_balance_name          => v_hrs_bal_name,
        p_balance_dimension     => 'Assignment Payments',
        p_business_group_name   => v_bg_name,
        p_legislation_code      => NULL);
END IF;

-- Determine which earnings skip rule needed:
-- Get skip rule formula id and pass it to create_element.

IF UPPER(p_ele_classification) IN ('EARNINGS', 'IMPUTED EARNINGS') THEN
  hr_utility.set_location('pyusuiet',1000);

hr_utility.trace('Element Classification is '|| p_ele_classification);
--
--Bug 3349586 - Condition for formula_id added to remove use of non-mergable view
--
  SELECT        FF.formula_id
  INTO          v_skip_formula_id
  FROM          ff_formulas_f FF
  WHERE         FF.formula_name         = 'REGULAR_EARNINGS'
  AND           FF.formula_id           >= 0
  AND           FF.business_group_id    IS NULL
  AND           legislation_code        = g_template_leg_code
  AND           p_ele_eff_start_date    BETWEEN FF.effective_start_date
                                            AND FF.effective_end_date;
--
ELSIF UPPER(p_ele_classification) = 'SUPPLEMENTAL EARNINGS' THEN
  hr_utility.set_location('pyusuiet',1005);
--
--Bug 3349586 - Condition for formula_id added to remove use of non-mergable view
--
  SELECT        FF.formula_id
  INTO          v_skip_formula_id
  FROM          ff_formulas_f FF
  WHERE         FF.formula_name         = 'SUPPLEMENTAL_EARNINGS'
  AND           FF.formula_id           >= 0
  AND           FF.business_group_id    IS NULL
  AND           legislation_code        = g_template_leg_code
  AND           p_ele_eff_start_date    BETWEEN FF.effective_start_date
                                            AND FF.effective_end_date;
--
END IF;
--
-- 385252 : If imputed earning is nonrecurring, attach SUPPLEMENTAL_EARNINGS skip formula.
--
IF UPPER(p_ele_classification) = 'IMPUTED EARNINGS' AND
    p_ele_processing_type = 'N' THEN

  hr_utility.set_location('pyusuiet',1010);
--
--Bug 3349586 - Condition for formula_id added to remove use of non-mergable view
--
  SELECT        FF.formula_id
  INTO          v_skip_formula_id
  FROM          ff_formulas_f FF
  WHERE         FF.formula_name         = 'SUPPLEMENTAL_EARNINGS'
  AND           FF.formula_id           >= 0
  AND           FF.business_group_id    IS NULL
  AND           legislation_code        = g_template_leg_code
  AND           p_ele_eff_start_date    BETWEEN FF.effective_start_date
                                            AND FF.effective_end_date;

END IF;



-- Check for Gross Up element here.  If it is, call create_element
-- with 'Information' classification.
--
IF UPPER(p_ele_calc_ff_name) NOT IN (   'GROSS_UP_RECUR_V2',
                                        'GROSS_UP_NONRECUR_V2')
   OR
   p_ele_calc_ff_name IS NULL THEN
 hr_utility.trace('This is inside p_ele_calc_ff_name not in gross_up...');

  hr_utility.set_location('pyusuiet',1015);
  v_ele_type_id :=  ins_uie_ele_type (  p_ele_name,
                                        p_ele_reporting_name,
                                        p_ele_description,
                                        p_ele_classification,
                                        p_ele_ot_base,
                                        p_ele_processing_type,
                                        p_ele_priority,
                                        p_ele_standard_link,
                                        v_skip_formula_id,
                                        'N',
                                        g_eff_start_date,
                                        v_bg_name,
                                        'S'); -- process mode is S for the actual elements

-- Need to find PRIMARY_CLASSIFICATION_ID of element type.
  hr_utility.set_location('pyusuiet',1020);
  select distinct(classification_id)
  into   v_primary_class_id
  from   pay_element_types_f
  where  element_type_id = v_ele_type_id;
--
  hr_utility.set_location('pyusuiet',1025);
  SELECT default_low_priority,
         default_high_priority
  INTO   v_class_lo_priority,
         v_class_hi_priority
  FROM   pay_element_classifications
  WHERE  classification_id = v_primary_class_id
  AND    nvl(business_group_id, p_bg_id) = p_bg_id;
--
  IF p_reduce_regular = 'Y' THEN
     l_ele_classification := 'Earnings';
  ELSE
     l_ele_classification := p_ele_classification;
  END IF;
--
  hr_utility.set_location('pyusuiet',1030);
  v_shadow_ele_name := SUBSTR(p_ele_name, 1, 61)||' Special Features';
  v_ele_repname := SUBSTR(p_ele_reporting_name, 1, 27)||' SF';
  v_shadow_ele_type_id :=  ins_uie_ele_type (
                                              v_shadow_ele_name,
                                              v_ele_repname,
                                              p_ele_description,
                                              l_ele_classification,
                                              p_ele_ot_base,
                                              'N',
                                              v_class_hi_priority,
                                              'N',
                                              NULL,
                                              'Y',
                                              g_eff_start_date,
                                              v_bg_name,
                                              'N'); -- process mode for Special Features should be 'N'
--

If p_ele_processing_type = 'R' then    /* Not required for NR Elements */
  hr_utility.set_location('pyusuiet',1031);
  v_inputs_ele_name := SUBSTR(p_ele_name, 1, 61)||' Special Inputs';
  v_ele_repname := SUBSTR(p_ele_reporting_name, 1, 27)||' SI';
  v_inputs_ele_type_id :=  ins_uie_ele_type (
                                              v_inputs_ele_name,
                                              v_ele_repname,
                                              p_ele_description,
                                              p_ele_classification,
                                              p_ele_ot_base,
                                              'N',
                                              v_class_lo_priority,
                                              'N',
                                              NULL,
                                              'N',
                                              g_eff_start_date,
                                              v_bg_name,
                                              'N'); -- process mode for Special Features should be 'N'

end if;  /* Not required for NR Elements */
--
ELSE -- GrossUp element being created, need to create this one as "Info".
  hr_utility.set_location('pyusuiet',1032);
  SELECT        classification_id,
                default_priority,
                default_low_priority,
                default_high_priority
  INTO          v_primary_class_id,
                v_info_dflt_priority,
                v_class_lo_priority,
                v_class_hi_priority
  FROM          pay_element_classifications
  WHERE         classification_name = 'Information'
  AND           nvl(business_group_id, p_bg_id) = p_bg_id;
  --
  hr_utility.set_location('pyusuiet',1033);
  v_ele_type_id :=  ins_uie_ele_type (  p_ele_name,
                                        p_ele_reporting_name,
                                        p_ele_description,
                                        'Information',
                                        p_ele_ot_base,
                                        p_ele_processing_type,
                                        v_info_dflt_priority,
                                        p_ele_standard_link,
                                        v_skip_formula_id,
                                        'N',
                                        g_eff_start_date,
                                        v_bg_name,
                                        'S' ); -- process mode
--
-- Set classification for future reference, call create_vertex_grossup w/this.
--
  v_grossup_class_name := p_ele_classification;
--
  hr_utility.set_location('pyusuiet',1034);
  v_info_payval_id := pay_db_pay_setup.create_input_value (
                                p_element_name          => p_ele_name,
                                p_name                  => 'Pay Value',
                                p_uom_code              => 'M',
                                p_mandatory_flag        => 'X',
                                p_generate_db_item_flag => 'Y',
                                p_default_value         => NULL,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => NULL,
                                p_formula_id            => NULL,
                                p_hot_default_flag      => 'N',
                                p_display_sequence      => 1,
                                p_business_group_name   => v_bg_name,
                                p_effective_start_date  => g_eff_start_date,
                                p_effective_end_date    => g_eff_end_date);
--
    hr_utility.set_location('pyusuiet',1035);
    hr_input_values.chk_input_value(
                        p_element_type_id               => v_ele_type_id,
                        p_legislation_code              => g_template_leg_code,
                        p_val_start_date                => g_eff_start_date,
                        p_val_end_date                  => g_eff_end_date,
                        p_insert_update_flag            => 'UPDATE',
                        p_input_value_id                => v_info_payval_id,
                        p_rowid                         => NULL,
                        p_recurring_flag                => p_ele_processing_type,
                        p_mandatory_flag                => 'N',
                        p_hot_default_flag              => 'X',
                        p_standard_link_flag            => 'N',
                        p_classification_type           => 'N',
                        p_name                          => 'Pay Value',
                        p_uom                           => 'M',
                        p_min_value                     => NULL,
                        p_max_value                     => NULL,
                        p_default_value                 => NULL,
                        p_lookup_type                   => NULL,
                        p_formula_id                    => NULL,
                        p_generate_db_items_flag        => 'Y',
                        p_warning_or_error              => NULL);
--
--
-- Commenting out this call to 3rd party inserts.  Don't think it's needed.
/*
    hr_utility.set_location('pyusuiet',1036);
    hr_input_values.ins_3p_input_values(
                        p_val_start_date                => g_eff_start_date,
                        p_val_end_date                  => g_eff_end_date,
                        p_element_type_id               => v_eletype_id,
                        p_primary_classification_id     => v_primary_class_id,
                        p_input_value_id        => v_nonpayroll_payval_id,
                        p_default_value                 => NULL,
                        p_max_value                     => NULL,
                        p_min_value                     => NULL,
                        p_warning_or_error_flag         => NULL,
                        p_input_value_name              => 'Pay Value',
                        p_db_items_flag                 => 'Y',
                        p_costable_type                 => NULL,
                        p_hot_default_flag              => 'N',
                        p_business_group_id             => p_bg_id,
                        p_legislation_code              => NULL,
                        p_startup_mode                  => NULL);
*/
--
-- Done inserting "Pay Value" for 'Information' element
--
--
-- Creating shadow element for gross up ele
--
  hr_utility.set_location('pyusuiet',1037);
  v_shadow_ele_name := SUBSTR(p_ele_name, 1, 61)||' Special Features';
  v_ele_repname := SUBSTR(p_ele_reporting_name, 1, 27)||' SF';
  v_shadow_ele_type_id :=  ins_uie_ele_type (
                                              v_shadow_ele_name,
                                              v_ele_repname,
                                              p_ele_description,
                                              'Information',
                                              p_ele_ot_base,
                                              'N',
                                              v_class_hi_priority,
                                              'N',
                                              NULL,
                                              'Y',
                                              g_eff_start_date,
                                              v_bg_name,
                                              'N' ); -- process mode

  hr_utility.set_location('pyusuiet',1038);

  v_shadow_info_payval_id := pay_db_pay_setup.create_input_value (
        p_element_name          => v_shadow_ele_name,
        p_name                  => 'Pay Value',
        p_uom_code              => 'M',
        p_mandatory_flag        => 'X',
        p_generate_db_item_flag => 'Y',
        p_default_value         => NULL,
        p_min_value             => NULL,
        p_max_value             => NULL,
        p_warning_or_error      => NULL,
        p_lookup_type           => NULL,
        p_formula_id            => NULL,
        p_hot_default_flag      => 'N',
        p_display_sequence      => 1,
        p_business_group_name   => v_bg_name,
        p_effective_start_date  => g_eff_start_date,
        p_effective_end_date    => g_eff_end_date);

    hr_utility.set_location('pyusuiet',1039);
    hr_input_values.chk_input_value(
                        p_element_type_id       => v_shadow_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => g_eff_start_date,
                        p_val_end_date          => g_eff_end_date,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => v_shadow_info_payval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'X',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => 'Pay Value',
                        p_uom                   => 'M',
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => 'Y',
                        p_warning_or_error      => NULL);
--
-- Creating Special Inputs for Grossup
--

If p_ele_processing_type = 'R' then    /* Not required for NR Elements */

  hr_utility.set_location('pyusuiet',1040);
  v_inputs_ele_name := SUBSTR(p_ele_name, 1, 61)||' Special Inputs';
  v_ele_repname := SUBSTR(p_ele_reporting_name, 1, 27)||' SI';
  v_inputs_ele_type_id :=  ins_uie_ele_type (
                                              v_inputs_ele_name,
                                              v_ele_repname,
                                              p_ele_description,
                                              'Information',
                                              p_ele_ot_base,
                                              'N',
                                              v_class_lo_priority,
                                              'N',
                                              NULL,
                                              'N',
                                              g_eff_start_date,
                                              v_bg_name,
                                              'N' ); -- process mode

  hr_utility.set_location('pyusuiet',1045);
  v_inputs_info_payval_id := pay_db_pay_setup.create_input_value (
        p_element_name          => v_inputs_ele_name,
        p_name                  => 'Pay Value',
        p_uom_code              => 'M',
        p_mandatory_flag        => 'X',
        p_generate_db_item_flag => 'Y',
        p_default_value         => NULL,
        p_min_value             => NULL,
        p_max_value             => NULL,
        p_warning_or_error      => NULL,
        p_lookup_type           => NULL,
        p_formula_id            => NULL,
        p_hot_default_flag      => 'N',
        p_display_sequence      => 1,
        p_business_group_name   => v_bg_name,
        p_effective_start_date  => g_eff_start_date,
        p_effective_end_date    => g_eff_end_date);

    hr_utility.set_location('pyusuiet',1050);
    hr_input_values.chk_input_value(
                        p_element_type_id       => v_inputs_ele_type_id,
                        p_legislation_code      => g_template_leg_code,
                        p_val_start_date        => g_eff_start_date,
                        p_val_end_date          => g_eff_end_date,
                        p_insert_update_flag    => 'UPDATE',
                        p_input_value_id        => v_inputs_info_payval_id,
                        p_rowid                 => NULL,
                        p_recurring_flag        => 'N',
                        p_mandatory_flag        => 'X',
                        p_hot_default_flag      => 'N',
                        p_standard_link_flag    => 'N',
                        p_classification_type   => 'N',
                        p_name                  => 'Pay Value',
                        p_uom                   => 'M',
                        p_min_value             => NULL,
                        p_max_value             => NULL,
                        p_default_value         => NULL,
                        p_lookup_type           => NULL,
                        p_formula_id            => NULL,
                        p_generate_db_items_flag => 'Y',
                        p_warning_or_error      => NULL);

END IF; /* Not required for NR Elements */
END IF;

-------------------------- Insert Formula Processing records -------------

ins_uie_formula_processing (    v_ele_type_id,
                                p_ele_name,
                                p_ele_reporting_name,
                                v_primary_class_id,
                                p_ele_classification,
                                v_grossup_class_name,
                                p_ele_category,
                                p_ele_ot_base,
                                p_flsa_hours,
                                p_mix_flag,
                                p_ele_processing_type,
                                p_ele_priority,
                                p_ele_calc_ff_id,
                                p_ele_calc_ff_name,
                                p_bg_id,
                                v_shadow_ele_type_id,
                                v_inputs_ele_type_id,
                                v_hrs_bal_type_id,
                                g_eff_start_date,
                                NULL,
                                v_bg_name);
--
------------------- Insert Status Processing Rule ---------------------
--
-- Done during ins_uie_formula_processing.
-- Is lock ladder integrity maintained?  Does it matter in this case?

--
-------------------------Insert Input Values --------------------------
--
-- Make insertion of all basic earnings input vals (ie. req'd for all
-- earnings elements, not based on calc rule; instead on Class).
hr_utility.set_location('pyusuiet',1055);

ins_uie_input_vals (    v_ele_type_id,
                        p_ele_name,
                        v_shadow_ele_type_id,
                        v_shadow_ele_name,
                        v_inputs_ele_type_id,
                        v_inputs_ele_name,
                        g_eff_start_date,
                        g_eff_end_date,
                        v_primary_class_id,
                        p_ele_classification,
                        p_ele_category,
                        p_ele_processing_type,
                        p_sep_check_option,
                        p_dedn_proc,
                        p_bg_id,
                        v_bg_name,
                        p_ele_calc_ff_name);
--
--------------------Insert Formula Result Rules -----------------------
--
-- Done during ins_uie_formula_processing.
-- Is lock ladder integrity maintained?  Does it matter in this case?

--
------------------------ Insert Balance Feeds -------------------------
--
-- First, call the "category feeder" API which creates manual pay value feeds
-- to pre-existing balances depending on the element classn/category.
--
pay_us_ctgy_feeds_pkg.create_category_feeds(
                                p_element_type_id =>  v_ele_type_id,
                                p_date            =>  g_eff_start_date);
--
-- These are manual feeds for "primary" balance for earnings element.
-- For manual feeds, only baltype id, inpval id, and scale are req'd.
--
-- Also, update element type DDF with associated balances for this
-- earning.  Current associated balances for Regular/Supplemental/Imputed
-- Earnings:  "Primary Balance" - hold in ELEMENT_INFORMATION10
-- Update Termination Rule for the base element.
UPDATE pay_element_types_f
SET    element_information10 = v_bal_type_id,
       post_termination_rule = p_termination_rule
WHERE  element_type_id = v_ele_type_id
AND    business_group_id = p_bg_id;

-- So we need inpval_id of pay value for this element:
hr_utility.set_location('pyusuiet',1060);
v_payval_name := hr_input_values.get_pay_value_name(g_template_leg_code);

hr_utility.set_location('pyusuiet',1065);
select  iv.input_value_id
into    v_payval_id
from    pay_input_values_f iv
where   iv.element_type_id = v_ele_type_id
and     iv.business_group_id = p_bg_id
and     iv.name = v_payval_name;
--
-- While we have Pay Value's ID, update Formula ID on payval record s.t.
-- validation is performed by "PAYVALUE_VALIDATION" formula!
-- 08 June 94: Don't need to anymore, payvalue's mandatory flag is set to
-- 'X' (ie. Never enterable) after creation of element type.
--
/*
hr_utility.set_location('pyusuiet',1066);
SELECT  formula_id
INTO    v_payval_formula_id
FROM    ff_formulas_f
WHERE   business_group_id       IS NULL
AND     legislation_code        = 'US'
AND     formula_name            = 'PAYVALUE_VALIDATION';

hr_utility.set_location('pyusuiet',1067);
UPDATE  pay_input_values_f
SET     formula_id              = v_payval_formula_id,
        warning_or_error        = 'E'
WHERE   input_value_id          = v_payval_id;
*/
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
--
hr_utility.set_location('pyusuiet',1068);

--
-- check for existence of balance feed before creating...return bal feed id if already exists...
--

hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => v_payval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');
--
--
-- ISSUE: G581 - "Negative Earnings"
-- Now select balance type id of "[<ELE_NAME>] Neg Earnings" balance and
-- create feed from <ELE_NAME> Negative Earnings input value to bal.
-- Issue over whether we create individual Neg Earnings balances for each
-- earning or just use a single Neg Earnings balance to hold ANY negative
-- earnings that occur - to be processed by Regular Salary, Regular Wages,
-- and Time Entry Wages.
--
IF p_ele_processing_type = 'R' THEN

hr_utility.set_location('pyusuiet',1070);
/*
  select        iv.input_value_id
  into          v_negearn_inpval_id
  from          pay_input_values_f      iv
  where         iv.element_type_id      = v_shadow_ele_type_id
  and           iv.name                 = 'Neg Earnings';
*/
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
  hr_utility.set_location('pyusuiet',1075);
  hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => g_neg_earn_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_neg_earn_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

--
END IF;
--
hr_utility.set_location('pyusuiet',1080);

If p_ele_processing_type = 'R' then    /* Not required for NR Elements */

/*
  select        iv.input_value_id
  into          v_addl_inpval_id
  from          pay_input_values_f      iv
  where         iv.element_type_id      = v_shadow_ele_type_id
  and           iv.name                 = 'Addl Amt';
*/
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.


  hr_utility.set_location('pyusuiet',1084);
  hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => g_addl_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_addl_amt_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

  hr_utility.set_location('pyusuiet',1085);
  hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => gi_addl_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_addl_amt_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

hr_utility.set_location('pyusuiet',1086);
/*
  select        iv.input_value_id
  into          g_repl_inpval_id
  from          pay_input_values_f      iv
  where         iv.element_type_id      = v_shadow_ele_type_id
  and           iv.name                 = 'Replacement Amt';
*/
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
  hr_utility.set_location('pyusuiet',1090);
  hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => g_repl_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_repl_amt_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

  hr_utility.set_location('pyusuiet',1095);
  hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => gi_repl_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_repl_amt_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

End if; /* Not required for NR Elements */
--
-- G1343: Insert feeds to "Earnings 401k" balance if earning is of Class/Cat
--        Earnings/Regular or Supplemental/Bonuses-Commissions.
--
  IF (UPPER(p_ele_classification) = 'EARNINGS'
      AND
      UPPER(p_ele_category) = 'REG'
     )
    OR
     (UPPER(p_ele_classification) = 'SUPPLEMENTAL EARNINGS'
      AND
      UPPER(p_ele_category) = 'B'
     ) THEN

    hr_utility.set_location('pyusuiet',1100);
    SELECT balance_type_id
    INTO   v_earn401k_bal_type_id
    FROM   pay_balance_types
    WHERE  balance_name = 'Earnings 401k'
    AND    business_group_id IS NULL
    AND    legislation_code = 'US';

    hr_utility.set_location('pyusuiet',1105);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => v_payval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_earn401k_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

  END IF;

-- G1564: Insert feeds to 'FLSA Earnings' and 'FLSA Hours' as per p_ele_ot_base
--        and p_flsa_hours.

  IF p_ele_ot_base = 'Y' THEN

    hr_utility.set_location('pyusuiet',1110);

    begin

    SELECT balance_type_id
    INTO   v_flsa_earnbal_id
    FROM   pay_balance_types
    WHERE  balance_name = 'FLSA Earnings'
    AND    business_group_id IS NULL
    AND    legislation_code = 'US';

    hr_utility.set_location('pyusuiet',1115);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => v_payval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_flsa_earnbal_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

    exception

      when NO_DATA_FOUND then

        hr_utility.set_location('Could not find FLSA_Earnings balance.',1120);

      when TOO_MANY_ROWS then

        hr_utility.set_location('Too many STU FLSA_Earnings balances.',1125);

    end;

  END IF;

  IF p_flsa_hours = 'Y' THEN

    hr_utility.set_location('pyusuiet',1130);

    begin


    SELECT balance_type_id
    INTO   v_flsa_hrsbal_id
    FROM   pay_balance_types
    WHERE  balance_name = 'FLSA Hours'
    AND    business_group_id IS NULL
    AND    legislation_code = 'US';

    hr_utility.set_location('pyusuiet',1135);
    SELECT input_value_id
    INTO   v_hrs_inpval_id
    FROM   pay_input_values_f
    WHERE  element_type_id = v_ele_type_id
    AND    business_group_id = p_bg_id
    AND    name = 'Hours';

    hr_utility.set_location('pyusuiet',1140);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => v_hrs_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_flsa_hrsbal_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

    exception

      when NO_DATA_FOUND then

        hr_utility.set_location('Could not find FLSA_Hours bal or Hours inpval.',1145);

      when TOO_MANY_ROWS then

        hr_utility.set_location('Too many STU FLSA_Hours bals or Hours inpvals.',1150);

    end;

  END IF;

  IF UPPER(p_ele_calc_ff_name) in (
                                'HOURS_X_RATE_RECUR_V2',
                                'HOURS_X_RATE_NONRECUR_V2',
                                'HOURS_X_RATE_MULTIPLE_RECUR_V2',
                                'HOURS_X_RATE_MULTIPLE_NONRECUR_V2') THEN

  -- Insert feed from "Hours" inpval to hours bal for this ele.

--    begin

    hr_utility.set_location('pyusuiet',1155);
    SELECT input_value_id
    INTO   v_hrs_inpval_id
    FROM   pay_input_values_f
    WHERE  element_type_id = v_ele_type_id
    AND    business_group_id = p_bg_id
    AND    name = 'Hours';

    hr_utility.set_location('pyusuiet',1160);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => v_hrs_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_hrs_bal_type_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

/*
 exception

      when NO_DATA_FOUND then

        hr_utility.set_location('Could not find Hours inpval.',1170);

      when TOO_MANY_ROWS then

        hr_utility.set_location('Too many Hours inpvals.',1171);

    end;
*/

    IF (UPPER(p_ele_classification) = 'EARNINGS'
         AND
         UPPER(p_ele_category) = 'REG'
         ) THEN

-- begin

-- Bug 3349586 - removed 'upper' to improve performance.
--
    select balance_type_id
    into    v_reghrs_bal_id
    from   pay_balance_types
    where balance_name = 'Regular Hours Worked'
    and business_group_id is null
    and legislation_code = 'US';

    hr_utility.set_location('pyusuiet',1175);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => v_hrs_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_reghrs_bal_id,
                p_scale                         => '1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

    -- Create feeds to all high level bals fed by RegSal and Wages pay vals...except for primary assoc bals.
    -- Do we need this or is cat feeder doing it? ie. for earn/regs...?
    create_regearn_feeds (  p_iv_id             => v_payval_id,
                        p_eff_start_date        => g_eff_start_date,
		        p_business_group_id     => p_bg_id);

/*
exception

      when NO_DATA_FOUND then

        hr_utility.set_location('Could not find Reg Hours Worked bal.',1180);

      when TOO_MANY_ROWS then

        hr_utility.set_location('Too many Reg Hours Worked bals.',1185);

    end;
*/

  END IF;

  -- 344018 : Add feed to reduce Regular Hours Worked balance if p_reduce_regular = Yes;
  -- also need to reduce Regular Salary Hours and Regular Wages Hours balances.
  -- And, set element_information13 appropriately - Reduce Regular flag.

  if p_reduce_regular = 'Y' then

--  begin

-- Bug 3349586 - removed 'upper' to improve performance.
--
    select balance_type_id
    into    v_reghrs_bal_id
    from   pay_balance_types
    where balance_name = 'Regular Hours Worked'
    and business_group_id is null
    and legislation_code = 'US';
/*
select balance_type_id
    into    v_reghrs_bal_id
    from   pay_balance_types
    where upper(balance_name ) = 'REGULAR HOURS WORKED'
    and business_group_id is null
    and legislation_code = 'US';
*/
    hr_utility.set_location('pyusuiet',1190);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => g_reduce_hrs_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_reghrs_bal_id,
                p_scale                         => '-1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

/*
    exception
      when NO_DATA_FOUND then
        hr_utility.set_location('Could not find Regular Hours Worked bal.',1195);
      when TOO_MANY_ROWS then
        hr_utility.set_location('Too many Regular Hours Worked bals.',1200);
    end;
*/

--    begin

-- Bug 3349586 - removed 'upper' to improve performance.
--
    select balance_type_id
    into    v_reghrs_bal_id
    from   pay_balance_types
    where balance_name = 'Regular Salary Hours'
    and business_group_id is null
    and legislation_code = 'US';

    hr_utility.set_location('pyusuiet',1205);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => g_reduce_sal_hrs_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_reghrs_bal_id,
                p_scale                         => '-1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

  /*
  exception
      when NO_DATA_FOUND then
        hr_utility.set_location('Could not find Regular Salary Hours bal.',170);
      when TOO_MANY_ROWS then
        hr_utility.set_location('Too many Regular Salary Hours bals.',170);
    end;
*/

--    begin

-- Bug 3349586 - removed 'upper' to improve performance.
--
    select balance_type_id
    into    v_reghrs_bal_id
    from   pay_balance_types
    where balance_name = 'Regular Wages Hours'
    and business_group_id is null
    and legislation_code = 'US';

    hr_utility.set_location('pyusuiet',1210);
    hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => g_reduce_wag_hrs_inpval_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => v_reghrs_bal_id,
                p_scale                         => '-1',
                p_session_date                  => g_eff_start_date,
                p_business_group                => p_bg_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');

/*
    exception
      when NO_DATA_FOUND then
        hr_utility.set_location('Could not find Regular Wages Hours bal.',170);
      when TOO_MANY_ROWS then
        hr_utility.set_location('Too many Regular Wages Hours bals.',170);
    end;
*/

     -- Create feeds to all bals fed by RegSal and Wages pay values.
    create_reduce_regpay_feeds (p_eff_start_date        => g_eff_start_date);

    update pay_element_types_f
    set element_information13 = 'Y'
    where element_type_id = v_ele_type_id;

  end if;

END IF;

------------------------ Conclude Do Insertions Main ----------------------

RETURN v_ele_type_id;

END do_insertions;
--
--
-------------------------------- Locking procedures ----------------------
--
PROCEDURE lock_template_rows (
                p_ele_type_id           in number,
                p_ele_eff_start_date    in date,
                p_ele_eff_end_date      in date,
                p_ele_name              in varchar2,
                p_ele_reporting_name    in varchar2,
                p_ele_description       in varchar2,
                p_ele_classification    in varchar2,
                p_ele_category          in varchar2,
                p_ele_ot_base           in varchar2,
                p_ele_processing_type   in varchar2,
                p_ele_priority          in number,
                p_ele_standard_link     in varchar2,
                p_ele_calculation_rule  in varchar2) IS

CURSOR chk_for_lock IS
        SELECT  *
        FROM    pay_all_earnings_types_v
        WHERE   element_type_id = p_ele_type_id
        FOR UPDATE OF element_type_id NOWAIT;

recinfo chk_for_lock%ROWTYPE;

BEGIN
  hr_utility.set_location('pyusuiet',1220);
  OPEN chk_for_lock;
  FETCH chk_for_lock INTO recinfo;
  CLOSE chk_for_lock;

-- Note: Not checking eff dates.

  hr_utility.set_location('pyusuiet',1225);
  IF ( ( (recinfo.element_type_id = p_ele_type_id)
       OR (recinfo.element_type_id IS NULL AND p_ele_type_id IS NULL))
--     AND ( (recinfo.effective_start_date = fnd_date.canonical_to_date(p_ele_eff_start_date))
--       OR (recinfo.effective_start_date IS NULL
--              AND p_ele_eff_start_date IS NULL))
--     AND ( (recinfo.effective_end_date = fnd_date.canonical_to_date(p_ele_eff_end_date))
--       OR (recinfo.effective_end_date IS NULL
--              AND p_ele_eff_end_date IS NULL))
     AND ( (recinfo.element_name = p_ele_name)
       OR (recinfo.element_name IS NULL AND p_ele_name IS NULL))
     AND ( (recinfo.reporting_name = p_ele_reporting_name)
       OR (recinfo.reporting_name IS NULL AND p_ele_reporting_name IS NULL))
     AND ( (recinfo.description = p_ele_description)
       OR (recinfo.description IS NULL AND p_ele_description IS NULL))
     AND ( (recinfo.classification_name = p_ele_classification)
       OR (recinfo.classification_name IS NULL
                AND p_ele_classification IS NULL))
     AND ( (recinfo.category = p_ele_category)
       OR (recinfo.category IS NULL AND p_ele_category IS NULL))
     AND ( (recinfo.include_in_ot_base = p_ele_ot_base)
       OR (recinfo.include_in_ot_base IS NULL AND p_ele_ot_base IS NULL))
     AND ( (recinfo.processing_type = p_ele_processing_type)
       OR (recinfo.processing_type IS NULL AND p_ele_processing_type IS NULL))
     AND ( (recinfo.processing_priority = p_ele_priority)
       OR (recinfo.processing_priority IS NULL AND p_ele_priority IS NULL))
     AND ( (recinfo.standard_link_flag = p_ele_standard_link)
       OR (recinfo.standard_link_flag IS NULL
                AND p_ele_standard_link IS NULL)))
THEN
  hr_utility.set_location('pyusuiet',1230);
  RETURN;
ELSE
  hr_utility.set_location('pyusuiet',151);
  hr_utility.set_message(801,'HR_51026_HR_LOCKED_OBJ');
  hr_utility.raise_error;

  --  FND_MESSAGE.SET_NAME('FND',
        --      'FORM_RECORD_CHANGED_BY_ANOTHER_USER');
  --  APP_EXCEPTION.RAISE_EXCEPTION;

END IF;

END lock_template_rows;
--
--
------------------------- Deletion procedures -----------------------------
--
PROCEDURE do_deletions (p_business_group_id     in number,
                        p_ele_type_id           in number,
                        p_ele_name              in varchar2,
                        p_ele_priority          in number,
                        p_ele_info_10           in varchar2,
                        p_ele_info_12           in varchar2,
                        p_del_sess_date         in date,
                        p_del_val_start_date    in date,
                        p_del_val_end_date      in date) IS
-- local constants
c_end_of_time  CONSTANT DATE := hr_general.end_of_time;

-- local vars
v_del_mode      VARCHAR2(80)    := 'ZAP';       -- Completely remove template.
v_startup_mode  VARCHAR2(80)    := 'USER';
v_del_sess_date DATE            := NULL;
v_del_val_start DATE            := NULL;
v_del_val_end   DATE            := NULL;
v_ff_id         NUMBER(9);
v_ff_count      NUMBER(3);
v_shadow_eletype_id             NUMBER(9);
v_shadow_ele_priority           NUMBER(9);
v_inputs_eletype_id             NUMBER(9);
v_inputs_ele_priority           NUMBER(9);
v_bal_type_id   NUMBER(9);
v_negearn_bal_type_id   NUMBER(9);
v_negearn_bal_name      VARCHAR2(80);
v_addl_bal_type_id      NUMBER(9);
v_addl_bal_name VARCHAR2(80);
v_repl_bal_type_id      NUMBER(9);
v_repl_bal_name VARCHAR2(80);
v_inpval_id     NUMBER(9);
v_spr_id        NUMBER(9);
v_baltype_count NUMBER(3);

CURSOR  get_inpvals IS
SELECT  input_value_id
FROM    pay_input_values_f
WHERE   element_type_id = p_ele_type_id;

CURSOR  get_formulae IS
SELECT  formula_id
FROM    pay_status_processing_rules_f
WHERE   element_type_id = p_ele_type_id;
--
BEGIN
-- Populate vars.
v_del_val_end           := nvl(p_del_val_end_date, c_end_of_time);
v_del_val_start         := nvl(p_del_val_start_date, sysdate);
v_del_sess_date         := nvl(p_del_sess_date, sysdate);
--
-- Get formula_ids to delete from various tables:
-- FF_FORMULAS_F
-- FF_FDI_USAGES_F
-- FF_COMPILED_INFO_F
--
OPEN get_formulae;
LOOP
  FETCH get_formulae INTO v_ff_id;
  EXIT WHEN get_formulae%NOTFOUND;
  hr_utility.set_location('pyusuidt',1235);

  DELETE FROM   ff_formulas_f
  WHERE         formula_id = v_ff_id;

  begin

    DELETE FROM ff_fdi_usages_f
    WHERE       formula_id = v_ff_id;

  exception when NO_DATA_FOUND then
    null;
  end;

  begin

    DELETE FROM ff_compiled_info_f
    WHERE       formula_id = v_ff_id;

  exception when NO_DATA_FOUND then
    null;
  end;

END LOOP;
CLOSE get_formulae;

hr_utility.set_location('pyusuiet',1240);

begin

SELECT  status_processing_rule_id
INTO    v_spr_id
FROM    pay_status_processing_rules_f
WHERE   element_type_id = p_ele_type_id;

  hr_utility.set_location('pyusuiet',1245);
  hr_elements.del_status_processing_rules(
                        p_element_type_id       => p_ele_type_id,
                        p_delete_mode           => v_del_mode,
                        p_val_session_date      => v_del_sess_date,
                        p_val_start_date        => v_del_val_start,
                        p_val_end_date          => v_del_val_end,
                        p_startup_mode          => v_startup_mode);

exception when no_data_found then
  null;
          when too_many_rows then
  null;
end;

OPEN get_inpvals;
LOOP
  FETCH get_inpvals INTO v_inpval_id;
  EXIT WHEN get_inpvals%NOTFOUND;
  hr_utility.set_location('pyusuiet',1250);
  DELETE FROM   pay_formula_result_rules_f
  WHERE         input_value_id = v_inpval_id;
END LOOP;
CLOSE get_inpvals;
--
-- Get shadow ele info
--
begin
SELECT  element_type_id,
        processing_priority
INTO    v_shadow_eletype_id,
        v_shadow_ele_priority
FROM    pay_element_types_f
WHERE   element_name = SUBSTR(p_ele_name || ' Special Features', 1, 80)
AND     business_group_id       = p_business_group_id;

exception when NO_DATA_FOUND then
  null;
end;

--
-- Get special inputs ele info
--
begin
SELECT  element_type_id,
        processing_priority
INTO    v_inputs_eletype_id,
        v_inputs_ele_priority
FROM    pay_element_types_f
WHERE   element_name = SUBSTR(p_ele_name || ' Special Inputs', 1, 80)
AND     business_group_id       = p_business_group_id;

exception when NO_DATA_FOUND then
  null;
end;

hr_utility.set_location('pyusuiet',1255);
hr_elements.chk_del_element_type (
                        p_mode                  => v_del_mode,
                        p_element_type_id       => p_ele_type_id,
                        p_processing_priority   => p_ele_priority,
                        p_session_date          => v_del_sess_date,
                        p_val_start_date        => v_del_val_start,
                        p_val_end_date          => v_del_val_end);

hr_utility.set_location('pyusuiet',1256);
hr_elements.del_3p_element_type (
                        p_element_type_id       => p_ele_type_id,
                        p_delete_mode           => v_del_mode,
                        p_val_session_date      => v_del_sess_date,
                        p_val_start_date        => v_del_val_start,
                        p_val_end_date          => v_del_val_end,
                        p_startup_mode          => v_startup_mode);

-- Delete element type record:
hr_utility.set_location('pyusuiet',1257);
delete from PAY_ELEMENT_TYPES_F
where   element_type_id = p_ele_type_id;

--
-- DELETE ASSOCIATED BALANCES AND OTHER BALANCES CREATED FOR THIS DEDN.
-- Balance type ids of associated balances for this element are passed in
-- via the p_ele_info_xx params.  Other balances (not "associated" bals) are
-- "<ELE-NAME> Replacement" and "<ELE-NAME> Additional".

  -- Primary Balance
  IF p_ele_info_10 IS NOT NULL THEN

    hr_utility.set_location('pyusuiet',1260);
    hr_balances.del_balance_type_cascade (
        p_balance_type_id       => fnd_number.canonical_to_number(p_ele_info_10),
        p_legislation_code      => g_template_leg_code,
        p_mode                  => v_del_mode);

    hr_utility.set_location('pyusuiet',1261);
    delete from PAY_BALANCE_TYPES
    where  balance_type_id = fnd_number.canonical_to_number(p_ele_info_10);

  END IF;

  -- Hours Balance
  IF p_ele_info_12 IS NOT NULL THEN

    hr_utility.set_location('pyusuiet', 1262);
    hr_balances.del_balance_type_cascade (
        p_balance_type_id       => fnd_number.canonical_to_number(p_ele_info_12),
        p_legislation_code      => g_template_leg_code,
        p_mode                  => v_del_mode);

    hr_utility.set_location('pyusuiet', 1263);
    DELETE FROM pay_balance_types
    WHERE balance_type_id = fnd_number.canonical_to_number(p_ele_info_12);

 END IF;

v_negearn_bal_name := p_ele_name || ' Neg Earnings';
v_negearn_bal_name := SUBSTR(v_negearn_bal_name, 1, 80);
hr_utility.set_location('pyusuiet',162);

 begin

  hr_utility.set_location('pyusuiet',1264);
  --
  -- 633443, added missing bussiness_group_id condition.mlisieck 28/02/98.
  --
  -- Bug 3349586 - removed 'upper' to improve performance.
  --
  select        balance_type_id
  into          v_negearn_bal_type_id
  from          pay_balance_types
  where         balance_name = v_negearn_bal_name and
                business_group_id + 0 = p_business_group_id ;

  hr_utility.set_location('pyusuiet',164);
  hr_balances.del_balance_type_cascade (
        p_balance_type_id       => v_negearn_bal_type_id,
        p_legislation_code      => g_template_leg_code,
        p_mode                  => v_del_mode);

  hr_utility.set_location('pyusuiet',1265);
  delete from PAY_BALANCE_TYPES
  where  balance_type_id = v_negearn_bal_type_id;

 exception when NO_DATA_FOUND then
   null;
 end;

v_addl_bal_name := p_ele_name || ' Additional';
v_addl_bal_name := SUBSTR(v_addl_bal_name, 1, 80);
hr_utility.set_location('pyusuiet',1266);

 begin
  --
  -- 633443, added missing bussiness_group_id condition.mlisieck 28/02/98.
  --
  -- Bug 3349586 - removed 'upper' to improve performance.
  --

  hr_utility.set_location('pyusuiet',1267);
  select        balance_type_id
  into          v_addl_bal_type_id
  from          pay_balance_types
  where         balance_name = v_addl_bal_name and
                business_group_id + 0 = p_business_group_id ;

  hr_utility.set_location('pyusuiet',1268);
  hr_balances.del_balance_type_cascade (
        p_balance_type_id       => v_addl_bal_type_id,
        p_legislation_code      => g_template_leg_code,
        p_mode                  => v_del_mode);

  hr_utility.set_location('pyusuiet',1268);
  delete from PAY_BALANCE_TYPES
  where  balance_type_id = v_addl_bal_type_id;

 exception when NO_DATA_FOUND then
   null;
 end;

v_repl_bal_name := p_ele_name || ' Replacement';
v_repl_bal_name := SUBSTR(v_repl_bal_name, 1, 80);
hr_utility.set_location('pyusuiet',1269);

 begin

  --
  -- 633443, added missing bussiness_group_id condition.mlisieck 28/02/98.
  --
  -- Bug 3349586 - removed 'upper' to improve performance.
  --

  hr_utility.set_location('pyusuiet',1270);
  select        balance_type_id
  into          v_repl_bal_type_id
  from          pay_balance_types
  where         balance_name = v_repl_bal_name and
                business_group_id + 0 = p_business_group_id ;

  hr_utility.set_location('pyusuiet',1275);
  hr_balances.del_balance_type_cascade (
        p_balance_type_id       => v_repl_bal_type_id,
        p_legislation_code      => g_template_leg_code,
        p_mode                  => v_del_mode);

  hr_utility.set_location('pyusuiet',1280);
  delete from PAY_BALANCE_TYPES
  where  balance_type_id = v_repl_bal_type_id;

 exception when NO_DATA_FOUND then
   null;
 end;

--
-- Delete Shadow element...
--
hr_utility.set_location('pyusuiet',1285);
hr_elements.chk_del_element_type (
                        p_mode                  => v_del_mode,
                        p_element_type_id       => v_shadow_eletype_id,
                        p_processing_priority   => v_shadow_ele_priority,
                        p_session_date          => v_del_sess_date,
                        p_val_start_date        => v_del_val_start,
                        p_val_end_date          => v_del_val_end);

hr_utility.set_location('pyusuiet',1290);
hr_elements.del_3p_element_type (
                        p_element_type_id       => v_shadow_eletype_id,
                        p_delete_mode           => v_del_mode,
                        p_val_session_date      => v_del_sess_date,
                        p_val_start_date        => v_del_val_start,
                        p_val_end_date          => v_del_val_end,
                        p_startup_mode          => v_startup_mode);

hr_utility.set_location('pyusuiet',1295);
delete from PAY_ELEMENT_TYPES_F
where   element_type_id = v_shadow_eletype_id;

--
-- Delete Special Inputs element...
--
hr_utility.set_location('pyusuiet',1300);
hr_elements.chk_del_element_type (
                        p_mode                  => v_del_mode,
                        p_element_type_id       => v_inputs_eletype_id,
                        p_processing_priority   => v_inputs_ele_priority,
                        p_session_date          => v_del_sess_date,
                        p_val_start_date        => v_del_val_start,
                        p_val_end_date          => v_del_val_end);

hr_utility.set_location('pyusuiet',1305);
hr_elements.del_3p_element_type (
                        p_element_type_id       => v_inputs_eletype_id,
                        p_delete_mode           => v_del_mode,
                        p_val_session_date      => v_del_sess_date,
                        p_val_start_date        => v_del_val_start,
                        p_val_end_date          => v_del_val_end,
                        p_startup_mode          => v_startup_mode);

hr_utility.set_location('pyusuiet',1310);
delete from PAY_ELEMENT_TYPES_F
where   element_type_id = v_inputs_eletype_id;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
  -- Processing falls through to here from one of 2 places:
  -- location 35 or 40, deleting from element/balance type tables resp.
  -- Highly suspicious if it falls through while trying to delete
  -- element type (35).
  -- If there was no balance type to delete (ie. w/same name as element type
  -- just deleted), then fine.

END do_deletions; -- Del recs according to lockladder.
--
--
END hr_user_init_earn;

/
