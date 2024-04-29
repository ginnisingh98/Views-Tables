--------------------------------------------------------
--  DDL for Package Body PAY_CA_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_BALANCE_PKG" AS
/* $Header: pycabals.pkb 115.24 2003/05/23 20:44:10 vpandya ship $ */
/*
 +======================================================================+
 |                Copyright (c) 1997 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name :  pay_ca_balance_pkg
 Package File Name :  pycabals.pkb
 Description : This package declares functions which are ....
                       call_ca_balance_get_value
                       get_current_balance

 Change List:
 ------------

 Name           Date       Version Bug     Text
 -------------- ---------- ------- ------- ------------------------------
 RThirlby      23-Oct-98   110.0           Initial Version
 RThirlby      17-Nov-98   110.1           Added p_jurisdiction_code
                                           and removed p_tax_unit.
 RThirlby      11-Apr-99   110.2           Set default to p_business_group
                                           to 0, so that will run if one
                                           is not set. Also set p_report_
                                           level to ASG for same reason.
                                           NB Need Header file aswell,
                                           pycabals.pkh v.110.2.
 MMUKHERJ      12-MAY-99   110.3           1) Called get_defined_balance from
                                           Canadian package which takes
                                           business_group_id as an additional
                                           parameter. 2)Changed the default
                                           value of the business_group_id
                                           parameter from 0 to NULL. To
                                           ensure that set_context does not
                                           fail, a local parameter of
                                           l_business_group_id has been used.
 JARTHURT      07-OCT-99   110.4           Remove 'upper' from balance_name
                                           due to changes in
                                           get_defined_balance function.
                                           Set SOURCE_ID context.
 JARTHURT      11-NOV-99   110.5           Return NULL if the
                                           get_defined_balance routine
                                           returns NULL
 JARTHURT      24-NOV-99   110.6           Calculate CURRENT balance
 jgoswami      06-DEC-1999 110.7           Overloading call_ca_balance_get_value,
                                           added parameter p_source_id.
                                           added l_report_unit in
                                           l_dimension_suffix
 JARTHURT      26-JAN-2000 110.8           Change hard-coding of balance
                                           dimension in get_current_balance.
 JARTHURT      28-JAN-2000 110.9           Correct building of dimension
                                           suffix string.
 RThirlby      11-FEB-2000 115.10          Changed all references to
                                           pay_us_balance_view_pkg to
                                           pay_ca_balance_view_pkg, except
                                           for calls to debug procedures.
                                           Added new procedure payments_bal-
                                           ance_required. (This is a copy
                                           from pay_us_taxbal_view_pkg).
 RThirlby      05-JUN-2000 115.11          Added turn_off_dimension function
                                           and turn_off_report_dimension
                                           procedure. To help SOE view
                                           performance.
 MMUKHERJ      25-JAN-01   115.12          dbdrv command added
 vpandya       03-May-02   115.15          Modified get_current_balance function
                                           Added cursor csr_check_sep_chk, check
                                           whether p_run_action_id is of sep
                                           check or not, if yes then pass it
                                           directly for calling get_value.
                                           Modified cursor csr_get_aa_ids,
                                           get all run aa id except sep chk.
 TCLEWIS       09-SEP-02   115.16          Re-wrote payments_balance_required
                                           to work with the umbrella process,
                                           though I'm not sure it will be used
                                           anymore.
                                           Added code in call_ca_balance_get_value
                                           to check for the ASG_PAYMENTS dimension
                                           suffix.  IF the Dimension Suffix is
                                           ASG_PAYMENTS call the core balance
                                           user_exit (Get_VALUE) function.
                                           Modified the code in
                                           call_ca_balance_get_value, it a view
                                           still attempts to fetch the current
                                           value, change the defined balance to
                                           <Element_name>_ASG_PAYMENTS and call
                                           the core balance user exit (get_value)
                                           instead of the get_current_value
                                           function.  (Which I don't believe works).
 TCLEWIS       29-OCT-02   115.17          modified the get_value function to check
                                           the get current code if l_jd_context =
                                           'NOT SET' he defined balance
                                           to <element_name>_ASG_PAYMENTS if
                                           l_jd_context <> 'NOT SET' then
                                           the defined balance to
                                           <element_name>_ASG_PAYMENTS_JD.

 TCLEWIS       11-NOV-02   115.18         modified get value function to
                                          check for null value of l_jd_context.
 tclewis       12-NOV-02   115.19         added calls to the pay_balance_pkg.
                                          set_context.
 tclewis       14-nov-2002 115.21         modified payments balance required
                                          to return true if pre-payments has
                                          been run.  It will no longer count
                                          runs.
 tclewis       03-mar-2003 115.22         modified the get value function to
                                          determine it the assignment_action_id
                                          passed to the procedure is a sep check
                                          or regular run.  IF sep check use
                                          the assignment action, if not then use
                                          master AA.
 vpandya       23-May-2003 115.24         Changed for Multi GRE functionality:
                                          Passing sub master asg act id to
                                          Assignment Payments for Standard Run
                                          and Tax Separate run and sepcheck asg
                                          act id for separate payment run. if
                                          TAX_GROUP is set then passing master
                                          asg act id to it. Setting context for
                                          Tax Group if TAX_GROUP is set.
 ========================================================================

*/
-- 'Current' balance dimension info for
-- prepayments related to many payroll runs
l_run_action_id NUMBER;
l_prepay_action_id NUMBER;

-- 'Current' balance dimension info for
-- prepayments related to many payroll runs
g_run_action_id NUMBER;
g_prepay_action_id NUMBER;
------------------------------------------------------------------------
-- GET_CURRENT_BALANCE calculates the CURRENT balance given a run
-- assignment action id. From this it calculates the pre-payment and
-- then it finds all the runs included in this pre-payment.
-------------------------------------------------------------------------
FUNCTION get_current_balance (p_defined_balance_id NUMBER
                             ,p_run_action_id      NUMBER)
RETURN NUMBER IS
--
CURSOR csr_get_aa_ids (p_prepay_aa_id NUMBER) IS
  SELECT pai.locked_action_id
  FROM   pay_payroll_actions    ppa,
         pay_assignment_actions paa,
         pay_action_interlocks  pai
  WHERE  pai.locking_action_id = p_prepay_aa_id
  AND    paa.assignment_action_id = pai.locked_action_id
  AND    ppa.payroll_action_id = paa.payroll_action_id
  AND    ppa.action_type IN ('R', 'Q')
  and    not exists ( select 1 from pay_run_types_f prt
                       where   prt.legislation_code = 'CA'
                         and   prt.run_method = 'S'
                         and   prt.run_type_id  = paa.run_type_id );

CURSOR csr_get_prepay_id (p_run_id NUMBER) IS
  SELECT pai.locking_action_id
  FROM   pay_payroll_actions    ppa,
         pay_assignment_actions paa,
         pay_action_interlocks  pai
  WHERE  pai.locked_action_id = p_run_id
  AND    paa.assignment_action_id = pai.locking_action_id
  AND    ppa.payroll_action_id = paa.payroll_action_id
  AND    ppa.action_type IN ('P', 'U');

CURSOR csr_check_sep_chk (p_run_aa_id NUMBER) IS
  SELECT 1
  FROM   pay_assignment_actions    paa
     ,   pay_run_types_f prt
  WHERE  paa.assignment_action_id = p_run_aa_id
    and  prt.legislation_code = 'CA'
    and  prt.run_method = 'S'
    and  prt.run_type_id  = paa.run_type_id;

l_defined_balance_id   NUMBER;
l_bal_value            NUMBER := 0;
l_prepay_action_id     NUMBER;
l_check_sep_chk_aa     NUMBER := 0;

BEGIN

  OPEN csr_check_sep_chk (p_run_action_id);
  FETCH csr_check_sep_chk INTO l_check_sep_chk_aa;
  CLOSE csr_check_sep_chk;

  IF l_check_sep_chk_aa = 1 THEN

      l_bal_value := l_bal_value + pay_ca_balance_view_pkg.get_value
                                      (p_run_action_id
                                      ,p_defined_balance_id);

  ELSE
    pay_us_balance_view_pkg.debug_msg('  p_def_bal: '||l_defined_balance_id);
    OPEN csr_get_prepay_id (p_run_action_id);
    FETCH csr_get_prepay_id INTO l_prepay_action_id;
    CLOSE csr_get_prepay_id;

    FOR v_runs IN csr_get_aa_ids(l_prepay_action_id) LOOP

      l_bal_value := l_bal_value + pay_ca_balance_view_pkg.get_value
                                      (v_runs.locked_action_id,
                                       p_defined_balance_id);

    END LOOP;
  END IF;

  RETURN l_bal_value;

END get_current_balance;

------------------------------------------------------------------------
-- CALL_CA_BALANCE_GET_VALUE is the wrapper function for calls to
-- get_value. It is used for ASG and PER level balances. Group Level balance
-- wrapper in pycatxbv.pkb.
-------------------------------------------------------------------------
FUNCTION call_ca_balance_get_value (p_balance_name      VARCHAR2
                           ,p_time_period               VARCHAR2
                           ,p_assignment_action_id      NUMBER
                           ,p_assignment_id             NUMBER
                           ,p_virtual_date              DATE
                           ,p_report_level              VARCHAR2
                           ,p_gre_id                    NUMBER
                           ,p_business_group_id         NUMBER
                           ,p_jurisdiction_code         VARCHAR2 )
RETURN number IS
--
BEGIN
--

return call_ca_balance_get_value( p_balance_name
                           ,p_time_period
                           ,p_assignment_action_id
                           ,p_assignment_id
                           ,p_virtual_date
                           ,p_report_level
                           ,p_gre_id
                           ,p_business_group_id
                           ,p_jurisdiction_code
                           ,NULL);
--
END call_ca_balance_get_value;
--------------------------------------------------------------------
-- Overloaded Version of call_ca_balance_get_value
-- for parameter p_source_id
-- CALL_CA_BALANCE_GET_VALUE is the wrapper function for calls to
-- get_value. It is used for ASG and PER level balances. Group Level balances
-- are in package pycatxbv.pkb.
-------------------------------------------------------------------------
FUNCTION call_ca_balance_get_value (p_balance_name      VARCHAR2
                           ,p_time_period               VARCHAR2
                           ,p_assignment_action_id      NUMBER
                           ,p_assignment_id             NUMBER
                           ,p_virtual_date              DATE
                           ,p_report_level              VARCHAR2
                           ,p_gre_id                    NUMBER
                           ,p_business_group_id         NUMBER
                           ,p_jurisdiction_code         VARCHAR2
                           ,p_source_id                 NUMBER    )
RETURN number IS
--

CURSOR C_GET_MASTER_AAID (cp_prepay_action_id in number,
                          cp_assignment_id    in number) is
     select max(paa.assignment_action_id)
     from   pay_assignment_actions paa,  -- assignment_action for master payroll run
            pay_action_interlocks pai
     where  pai.locking_action_id = cp_prepay_action_id
     and    pai.locked_action_id = paa.assignment_action_id
     and    paa.assignment_id    = cp_assignment_id
     and    paa.source_action_id is null -- master assignment_action
     group by assignment_id;

g_prepay_action_id	NUMBER;
l_defined_balance_id	NUMBER;
l_business_group_id	NUMBER;
l_report_level		VARCHAR2(4);
l_tax_group		VARCHAR2(30);
l_gre			VARCHAR2(30);
l_dimension_suffix	VARCHAR2(30);
l_jd_code		VARCHAR2(10);
l_balance_value		NUMBER;
l_jd_context            VARCHAR2(10);
l_report_unit		VARCHAR2(30);
l_time_period           VARCHAR2(80);
l_gre_tg_or_rpt_unit    VARCHAR2(80);
l_current_bal_flag      BOOLEAN := FALSE;
l_sep_check         VARCHAR2(1) := 'N';
l_assignment_action_id  NUMBER;
l_pre_pay_aaid          NUMBER;
l_assignment_id         number;
l_tax_group_id          number;
--
BEGIN
  pay_us_balance_view_pkg.debug_msg( '=======================================');
  pay_us_balance_view_pkg.debug_msg('call_ca_balance_get_value entry:');
  pay_us_balance_view_pkg.debug_msg('  p_balance_name:    ' || p_balance_name);
  pay_us_balance_view_pkg.debug_msg('  p_time_period:     ' || p_time_period);
  pay_us_balance_view_pkg.debug_msg('  p_assignment_action_id: ' ||
                                               TO_CHAR(p_assignment_action_id));
  pay_us_balance_view_pkg.debug_msg('  p_assignment_id:   ' ||
                                               TO_CHAR(p_assignment_id));
  pay_us_balance_view_pkg.debug_msg('  p_virtual_date:    ' ||
                                               TO_CHAR(p_virtual_date));
  pay_us_balance_view_pkg.debug_msg('  p_report_level:    ' || p_report_level);
  pay_us_balance_view_pkg.debug_msg('  p_gre_id:          ' ||
                                               TO_CHAR(p_gre_id));
  pay_us_balance_view_pkg.debug_msg('  p_business_group_id: ' ||
                                               TO_CHAR(p_business_group_id));
  pay_us_balance_view_pkg.debug_msg('  p_jurisdiction_code: ' ||
                                                      p_jurisdiction_code);
  pay_us_balance_view_pkg.debug_msg('  p_source_id:       ' ||
                                               TO_CHAR(p_source_id));

  --
  --Set contexts
  --
  pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',
                                      p_gre_id);
  pay_balance_pkg.set_context('TAX_UNIT_ID', p_gre_id);

  IF p_jurisdiction_code IS NULL THEN
    l_jd_context := nvl(pay_ca_balance_view_pkg.get_session_var
                            ('JURISDICTION_CODE'), 'Not_Set');
  ELSE
    l_jd_context := p_jurisdiction_code;
  END IF;

  IF p_business_group_id is NULL then
    l_business_group_id := 0;
  ELSE
    l_business_group_id := p_business_group_id;
  END IF;

  IF l_jd_context = 'Not_Set'  THEN
    l_jd_code := '';
    l_jd_context := NULL;
  ELSE
    IF p_source_id IS NULL THEN
      l_jd_code := 'JD_';
    ELSE
      --
      -- Balances with a Reporting Unit level dimension can not be at the
      -- jurisdiction level aswell.
      --
      l_jd_code := '';
    END IF;
  END IF;
  --
  -- derive the dimension_suffix
  -- set session var REPORT_LEVEL to default of ASG if not already set.
  --
  IF p_report_level IS NULL THEN
    pay_ca_balance_view_pkg.set_session_var('REPORT_LEVEL','ASG');

    l_report_level :=
             pay_ca_balance_view_pkg.get_session_var('REPORT_LEVEL')||'_';
  ELSE
    l_report_level := p_report_level||'_';
  END IF;

  IF p_source_id IS NULL THEN
    IF pay_ca_balance_view_pkg.get_session_var('TAX_GROUP') = 'Y' then
      l_gre_tg_or_rpt_unit := 'TG_';

      begin
        select pac.context_value
          into l_tax_group
          from pay_action_contexts pac
              ,ff_contexts fc
         where pac.assignment_action_id = p_assignment_action_id
         and   fc.context_name = 'TAX_GROUP'
         and   pac.context_id  = fc.context_id;

         if l_tax_group <> 'No Tax Group' then
            l_tax_group_id := l_tax_group;
            pay_ca_balance_view_pkg.set_context('TAX_GROUP',l_tax_group_id);
            pay_balance_pkg.set_context('TAX_GROUP',l_tax_group_id);
         end if;

       exception
       when others then
            null;
      end;

    ELSE
      l_gre_tg_or_rpt_unit := 'GRE_';
    END IF;
  ELSE
    l_gre_tg_or_rpt_unit := 'RPT_UNIT_';
  END IF;

  pay_ca_balance_view_pkg.set_context('JURISDICTION_CODE',l_jd_context);
  pay_ca_balance_view_pkg.set_context('ASSIGNMENT_ACTION_ID'
                                      ,p_assignment_action_id);
  pay_ca_balance_view_pkg.set_context('BUSINESS_GROUP_ID',l_business_group_id);
  pay_ca_balance_view_pkg.set_context('DATE_EARNED',p_virtual_date);
  pay_ca_balance_view_pkg.set_context('SOURCE_ID',p_source_id);

  pay_balance_pkg.set_context('JURISDICTION_CODE',l_jd_context);
  pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID'
                                      ,p_assignment_action_id);
  pay_balance_pkg.set_context('BUSINESS_GROUP_ID',l_business_group_id);
  pay_balance_pkg.set_context('DATE_EARNED',p_virtual_date);
  pay_balance_pkg.set_context('SOURCE_ID',p_source_id);

  l_time_period := p_time_period;
  pay_us_balance_view_pkg.debug_msg('  l_time_period:     ' || l_time_period);

  IF p_time_period = 'CURRENT' THEN
    l_gre_tg_or_rpt_unit := 'GRE_';
    l_time_period := 'RUN';
    l_current_bal_flag := TRUE;
  END IF;

  --
  -- Build the dimension suffix string
  --
  l_dimension_suffix := l_report_level||l_jd_code||l_gre_tg_or_rpt_unit||l_time_period;
  --
  -- Determine which dimensions should be returned.
  -- turn_off_dimension is TRUE then don't get the balance.
  --
  IF turn_off_dimension(p_time_period)
  --
    THEN RETURN NULL;
    --
  ELSE -- turn_off_dimension is FALSE so get the balance.
  --
  -- Get the defined balance
  --
  pay_us_balance_view_pkg.debug_msg('  p_balance_name: ' || p_balance_name);
  pay_us_balance_view_pkg.debug_msg
                          ('  p_dimension_suffix: ' || l_dimension_suffix);
  l_defined_balance_id := pay_ca_group_level_bal_pkg.get_defined_balance
                              (p_balance_name      => p_balance_name
                              ,p_dimension         => l_dimension_suffix
                              ,p_business_group_id => p_business_group_id);

  --
  -- The 'CURRENT' Dimension is for the current payment method amount.
  -- This is needed for checks, deposit advice, and the payroll register.
  --
  IF l_current_bal_flag = TRUE AND
    payments_balance_required(p_assignment_action_id)
    THEN

      l_assignment_action_id := p_assignment_action_id;

      BEGIN

        SELECT DECODE(prt.shortname,'SEP_PAY','Y','N'),
               paa.assignment_id
        INTO   l_sep_check,
               l_assignment_id
        FROM   pay_assignment_actions paa
              ,pay_run_types_f        prt
        WHERE  paa.assignment_action_id = p_assignment_action_id
        AND    prt.run_type_id          = paa.run_type_id
        AND    prt.legislation_code     = 'CA';

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_sep_check := 'N';
      END;

      IF l_sep_check <> 'Y' THEN

         IF pay_ca_balance_view_pkg.get_session_var('TAX_GROUP') = 'Y' then
            select paa_master.source_action_id
            into   l_assignment_action_id
            from   pay_assignment_actions paa_master
                  ,pay_assignment_actions paa_sm
            where  paa_sm.assignment_action_id = p_assignment_action_id
            and    paa_master.assignment_action_id = paa_sm.source_action_id;
         ELSE
            select paa.source_action_id
            into   l_assignment_action_id
            from   pay_assignment_actions paa
            where  paa.assignment_action_id = p_assignment_action_id;
         END IF;

         IF nvl(l_jd_context,'Not_Set') = 'Not_Set'  THEN
            l_defined_balance_id :=
                               pay_ca_group_level_bal_pkg.get_defined_balance
                                   (p_balance_name      => p_balance_name
                                   ,p_dimension         => 'ASG_PAYMENTS'
                                   ,p_business_group_id => p_business_group_id);
         ELSE
            l_defined_balance_id :=
                               pay_ca_group_level_bal_pkg.get_defined_balance
                                   (p_balance_name      => p_balance_name
                                   ,p_dimension         => 'ASG_PAYMENTS_JD'
                                   ,p_business_group_id => p_business_group_id);
         END IF;

      END IF;

      RETURN pay_balance_pkg.get_value
                                 (l_defined_balance_id
                                 ,l_assignment_action_id);

  END IF;

  IF p_time_period =  'ASG_PAYMENTS' THEN

     l_defined_balance_id := pay_ca_group_level_bal_pkg.get_defined_balance
                            (p_balance_name      => p_balance_name
                            ,p_dimension         => 'ASG_PAYMENTS'
                            ,p_business_group_id => p_business_group_id);

      RETURN pay_balance_pkg.get_value
                (l_defined_balance_id
                ,p_assignment_action_id);

  END IF;

  IF p_time_period =  'ASG_PAYMENTS_JD' THEN

     l_defined_balance_id := pay_ca_group_level_bal_pkg.get_defined_balance
                            (p_balance_name      => p_balance_name
                            ,p_dimension         => 'ASG_PAYMENTS_JD'
                            ,p_business_group_id => p_business_group_id);

      RETURN pay_balance_pkg.get_value
                (l_defined_balance_id
                ,p_assignment_action_id);

  END IF;

  IF l_defined_balance_id IS NULL THEN
    pay_us_balance_view_pkg.debug_msg('The Defined Balance does not exist');
    RETURN NULL;
  ELSE

    RETURN pay_ca_balance_view_pkg.get_value
                                 (p_assignment_action_id
                                 ,l_defined_balance_id);

  END IF;
  --
  END IF; -- Determine which dimensions to return using turn_off_dimension
  --
END call_ca_balance_get_value;
-----------------------------------------------------------------------------
-- FUNCTION Payments_Balance_Required
--  This function caches information related to an assignment action
--  for a payroll run related to a pre-payment composed of multiple
--  runs.  This is to support the 'CURRENT' balance value displayed
--  on checkwriter and related reports(PAYRPCHK, PAYRPPST, PAYRPREG)
--
--  Returns:
--  TRUE if multiple runs exists and sets global prepayment id
--  FALSE if a single run exists and clears global prepayment id
--------------------------------------------------------------------------
FUNCTION payments_balance_required(p_assignment_action_id NUMBER)
RETURN boolean IS
--
CURSOR c_count_runs(p_asgact_id NUMBER) IS
SELECT pai.locking_action_id, count(pai2.locked_action_id)
FROM   pay_action_interlocks pai,
       pay_action_interlocks pai2,
       pay_assignment_actions paa,
       pay_payroll_actions    ppa
WHERE  pai.locked_action_id = p_asgact_id
AND    pai.locking_action_id = pai2.locking_action_id
AND    pai.locking_action_id = paa.assignment_action_id
AND    paa.payroll_action_id = ppa.payroll_action_id
AND    ppa.action_type in ('P', 'U')
GROUP BY pai.locking_action_id;

l_count_runs NUMBER;

BEGIN

IF l_run_action_id = p_assignment_action_id
   AND l_prepay_action_id IS NOT NULL THEN
   -- Have processed this assignment
   -- and it does have multiple RUNS
   RETURN TRUE;
ELSIF  l_run_action_id = p_assignment_action_id
   AND l_prepay_action_id IS NULL THEN
   -- Have processed this assignment
   -- and it does not have multiple RUNS
   RETURN FALSE;
ELSE
   l_run_action_id := p_assignment_action_id;  -- set Run action id
   OPEN c_count_runs(p_assignment_action_id);
   FETCH c_count_runs INTO l_prepay_action_id, l_count_runs;
   CLOSE c_count_runs;
   IF l_count_runs > 1 THEN
       -- Set asg_act_ids if multple runs
       l_run_action_id := p_assignment_action_id;
       RETURN TRUE;
   ELSE
       -- Clear asg_act_ids if they do not
       l_prepay_action_id := NULL;
       RETURN FALSE;
   END IF;
END IF;





END payments_balance_required;
-----------------------------------------------------------------------------
-- FUNCTION turn_off_dimension
-----------------------------------------------------------------------------
FUNCTION turn_off_dimension (p_dimension varchar2)
RETURN BOOLEAN IS
--
BEGIN
--
IF nvl(pay_ca_balance_view_pkg.get_session_var(p_dimension),'ON') = 'OFF' THEN
--
  RETURN TRUE;
  --
ELSE
  RETURN FALSE;
  --
END IF;
--
END turn_off_dimension;
-----------------------------------------------------------------------------
-- PROCEDURE turn_off_report_dimension
-----------------------------------------------------------------------------
PROCEDURE turn_off_report_dimension (p_report_name varchar2)
is
--
BEGIN
--
/*
IF p_report_name = 'SOE'
--
  THEN pay_ca_balance_view_pkg.set_session_var(PTD','OFF');
       pay_ca_balance_view_pkg.set_session_var('MONTH','OFF');
       pay_ca_balance_view_pkg.set_session_var('QTD','OFF');
       pay_ca_balance_view_pkg.set_session_var('YTD','ON');
-- Need to check if need both CURRENT and RUN
       pay_ca_balance_view_pkg.set_session_var('CURRENT','ON');
       pay_ca_balance_view_pkg.set_session_var('RUN','ON');
       --
END IF;
*/
null;
END turn_off_report_dimension;
-----------------------------------------------------------------------------
END pay_ca_balance_pkg;

/
