--------------------------------------------------------
--  DDL for Package Body PAY_MX_SOE_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_SOE_SS_PKG" as
/* $Header: paymxsoe.pkb 120.1 2005/08/22 11:47:41 vmehta noship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description: This package is used to show SS SOE for Mexico.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   11-AUG-2004  vpandya     115.0            Created.
   20-DEC-2004  vpandya     115.1            Changed view name and added suffix
                                             _V.
   06-Jan-2005  vpandya     115.2            Added following functions:
                                             - summary_balances
                                             - hourly_earnings
                                             - tax_balances
                                             - deductions
                                             - taxable_benefits
                                             - other_balances
  08-Feb-2005   vpandya     115.3  4145833   Added function setParameters
  08-Feb-2005   vpandya     115.4  4170915   Changes summary_balances using
                                             _PAYMENTS dimension for the
                                             prepayment.
  22-Aug-2005   vmehta      115.5            Changed currency code to MXN
                                             instead of MXP
*/
--

  lv_sql           long;
  lv_currency_code varchar2(240);
  g_debug          boolean;
  g_max_action     number;
  g_min_action     number;


  FUNCTION employee_earnings( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.employee_earnings ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select earn_bal_name COL01
             ,nvl(earn_reporting_name, earn_bal_name) COL02
             ,to_char(days_run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
             ,to_char(earn_run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL17
       from  PAY_MX_EMPLOYEE_EARNINGS_V
       where assignment_action_id :action_clause
       and   earn_run_val <> 0';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.employee_earnings ');

    return lv_sql;

  END employee_earnings;

  FUNCTION employee_taxes( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.employee_taxes ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select balance_name COL01
             ,nvl(reporting_name, balance_name) COL02
             ,to_char(run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
       from  PAY_MX_EMPLOYEE_TAXES_V
       where assignment_action_id :action_clause
       and   run_val <> 0';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.employee_taxes ');

    return lv_sql;

  END employee_taxes;

  FUNCTION tax_calc_details( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.tax_calc_details ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select balance_name COL01
             ,nvl(reporting_name, balance_name) COL02
             ,to_char(run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
       from  PAY_MX_TAX_CALC_DETAILS_V
       where assignment_action_id :action_clause
       and   run_val <> 0';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.tax_calc_details ');

    return lv_sql;

  END tax_calc_details;


  FUNCTION summary_balances( p_assignment_action_id in NUMBER )
    RETURN LONG IS

    CURSOR c_tax_unit(cp_assignment_action_id NUMBER) IS
      select tax_unit_id, payroll_action_id
      from   pay_assignment_actions
      where  assignment_action_id = cp_assignment_action_id;

    CURSOR c_action_type(cp_payroll_action_id NUMBER) IS
      select action_type
      from   pay_payroll_actions
      where  payroll_action_id = cp_payroll_action_id;

    ln_tax_unit_id  number;
    ln_pyrl_act_id  number;
    ln_cnt          number;
    ln_bal_value    number;

    lv_action_type  varchar2(10);

    lv_curr_dim varchar2(240);
    lv_ytd_dim  varchar2(240);

    summary     summary_bal;

  BEGIN
    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.mx_summary_balances ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);
    hr_utility.trace('lv_currency_code '||lv_currency_code);

    open  c_tax_unit(p_assignment_action_id);
    fetch c_tax_unit into ln_tax_unit_id,ln_pyrl_act_id;
    close c_tax_unit;

    open  c_action_type(ln_pyrl_act_id);
    fetch c_action_type into lv_action_type;
    close c_action_type;

    pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);

    IF lv_action_type in ('P', 'U') THEN
       lv_curr_dim := '_PAYMENTS';
    ELSE
       lv_curr_dim := '_ASG_GRE_RUN';
    END IF;

    lv_ytd_dim  := '_ASG_GRE_YTD';

    ln_cnt := 1;
    summary(ln_cnt).bal_name := 'Gross Earnings';
    summary(ln_cnt).reporting_name := 'Gross Pay';

    --ln_cnt := ln_cnt + 1;
    --summary(ln_cnt).bal_name := 'Pre Tax Deductions';
    --summary(ln_cnt).reporting_name := 'Pre-Tax Deductions';

    ln_cnt := ln_cnt + 1;
    summary(ln_cnt).bal_name := 'Tax Deductions';
    summary(ln_cnt).reporting_name := 'Tax Deductions';

    ln_cnt := ln_cnt + 1;
    summary(ln_cnt).bal_name := 'Deductions';
    summary(ln_cnt).reporting_name :=  'Other Deductions';

    ln_cnt := ln_cnt + 1;
    summary(ln_cnt).bal_name := 'Total Pay';
    summary(ln_cnt).reporting_name := 'Total Pay';

    pay_soe_util.clear;

    for i in summary.first..summary.last loop

        hr_utility.trace('i = '||i);
        hr_utility.trace('Balance = '||summary(i).bal_name);

        summary(i).curr_def_bal_id :=
                          pay_ac_utility.get_defined_balance_id
                                 (p_balance_name    => summary(i).bal_name
                                 ,p_dimension_name  => lv_curr_dim
                                 ,p_bus_grp_id      => NULL
                                 ,p_legislation_cd  => 'MX');

--      summary(i).ytd_def_bal_id :=
--                 get_defined_balance_id(summary(i).bal_name, lv_ytd_dim);

        ln_bal_value := pay_balance_pkg.get_value(summary(i).curr_def_bal_id
                                            ,p_assignment_action_id);
        summary(i).curr_val :=
           to_char(ln_bal_value
                   ,fnd_currency.get_format_mask(lv_currency_code,40));

--      summary(i).ytd_val :=
--                 pay_balance_pkg.get_value(summary(i).ytd_def_bal_id
--                                          ,p_assignment_action_id);
--
        --
         hr_utility.trace(' summary(i).curr_val '|| summary(i).curr_val);
        pay_soe_util.setValue('01' ,summary(i).bal_name ,TRUE, FALSE);
        pay_soe_util.setValue('02' ,summary(i).reporting_name ,FALSE, FALSE);
        pay_soe_util.setValue('16' ,summary(i).curr_val, FALSE, FALSE );
        pay_soe_util.setValue('17' ,summary(i).ytd_val, FALSE, TRUE );
        --
    end loop;

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.mx_summary_balances ');

    return pay_soe_util.genCursor;

  END summary_balances;

  FUNCTION hourly_earnings( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.hourly_earnings ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select earn_bal_name COL01
             ,nvl(earn_reporting_name, earn_bal_name) COL02
             ,to_char(hours_run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
             ,to_char(earn_run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL17
       from  PAY_MX_HOURLY_EARNINGS_V
       where assignment_action_id :action_clause
       and   earn_run_val <> 0';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.employee_earnings ');

    return lv_sql;

  END hourly_earnings;

  FUNCTION taxable_benefits( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.taxable_benefits ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select balance_name COL01
             ,nvl(reporting_name, balance_name) COL02
             ,to_char(run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
       from  PAY_MX_TAXABLE_BENEFITS_V
       where assignment_action_id :action_clause
       and   run_val <> 0';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.tax_calc_details ');

    return lv_sql;

  END taxable_benefits;

  FUNCTION tax_balances( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.tax_balances ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select balance_name COL01
             ,nvl(reporting_name, balance_name) COL02
             ,to_char(run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
       from  PAY_MX_TAX_BALANCES_V
       where assignment_action_id :action_clause
       and   run_val <> 0';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.tax_calc_details ');

    return lv_sql;

  END tax_balances;

  FUNCTION deductions( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.deductions ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select balance_name COL01
             ,nvl(reporting_name, balance_name) COL02
             ,to_char(run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
       from  PAY_MX_DEDUCTIONS_V
       where assignment_action_id :action_clause
       and   run_val <> 0';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.tax_calc_details ');

    return lv_sql;

  END deductions;

  FUNCTION other_balances( p_assignment_action_id in NUMBER )
    RETURN LONG IS
  BEGIN

    hr_utility.trace('Entering.. pay_mx_soe_ss_pkg.other_balances ');
    hr_utility.trace('p_assignment_action_id '||p_assignment_action_id);

    pay_soe_util.clear;

    lv_sql := 'select balance_name COL01
             ,nvl(reporting_name, balance_name) COL02
             ,to_char(run_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
             ,to_char(mtd_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL17
             ,to_char(ytd_val
                     ,fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL18
       from  PAY_MX_OTHER_BALANCES_V
       where assignment_action_id :action_clause';

    hr_utility.trace('Leaving.. pay_mx_soe_ss_pkg.tax_calc_details ');

    return lv_sql;

  END other_balances;

  --
  --
  /* ---------------------------------------------------------------------
     Function : SetParameters

     Text
  ------------------------------------------------------------------------ */
  FUNCTION setParameters(p_assignment_action_id in number)
  RETURN varchar2 is
  --
  cursor getParameters(c_assignment_action_id in number) is
  select pa.payroll_id
  --,      to_number(to_char(pa.effective_date,'J')) effective_date
  ,replace(substr(FND_DATE.DATE_TO_CANONICAL(pa.effective_date),1,10),'/','-') jsqldate       --YYYY-MM-DD
  ,'' || pa.effective_date || '' effective_date
  ,      aa.assignment_id
  ,      pa.business_group_id
  ,      aa.tax_unit_id
  ,''''  || bg.currency_code || '''' currency_code
  ,action_type
  ,fc.name currency_name
  from   pay_payroll_actions pa
  ,      pay_assignment_actions aa
  ,      per_business_groups bg
  ,      fnd_currencies_vl fc
  where  aa.assignment_action_id = p_assignment_action_id
  and    aa.payroll_action_id = pa.payroll_action_id
  and    pa.business_group_id = bg.business_group_id
  and    fc.currency_code = bg.currency_code
  and rownum = 1;

  cursor getActions is
  select assignment_action_id
  from pay_assignment_actions
  where level =
    (select max(level)
     from pay_assignment_actions
     connect by source_action_id =  prior assignment_action_id
     start with assignment_action_id = p_assignment_action_id)
  connect by source_action_id =  prior assignment_action_id
  start with assignment_action_id = p_assignment_action_id;

  l_action_type pay_payroll_actions.action_type%type;

  cursor lockedActions is
  select locked_action_id,
         action_sequence
  from pay_action_interlocks,
       pay_assignment_actions paa
  where locking_action_id = p_assignment_action_id
  and locked_action_id = assignment_action_id
  and exists ( select 1 from pay_run_types_f prt
                where prt.legislation_code = 'MX'
                and   prt.run_type_id = paa.run_type_id
                and   prt.run_method <> 'C' )
  order by action_sequence desc;

  --
  l_parameters varchar2(2000);
  l_action_count number;
  l_actions varchar2(2000);
  l_max_action number;
  l_min_action number;
  l_assignment_action_id number;
  --
  begin
  --
     if g_debug then
       hr_utility.set_location('Entering pay_soe_glb.setParameters', 10);
     end if;
     --
     -- Prepay change
     select action_type
     into l_action_type
     from  pay_payroll_actions pa
          ,pay_assignment_actions aa
     where  aa.assignment_action_id = p_assignment_action_id
     and    aa.payroll_action_id = pa.payroll_action_id;

     /* exception
           when no_data_found then
     */

     l_action_count := 0;
     l_max_action := 0;
     l_min_action := 0;

     if l_action_type in ('P','U') then
        for a in lockedActions loop
            l_action_count := l_action_count + 1;
            l_actions := l_actions || a.locked_action_id|| ',';
            if l_max_action = 0 then
               l_max_action := a.locked_action_id;
            end if;
            l_min_action := a.locked_action_id;
        end loop;
     else
        for a in getActions loop
            l_action_count := l_action_count + 1;
            l_actions := l_actions || a.assignment_action_id|| ',';
        end loop;
     end if;

     l_actions := substr(l_actions,1,length(l_actions)-1);
     --
     if l_action_type in ( 'P','U' ) then
        l_assignment_action_id := l_max_action; -- for Prepays, effective date is date of
     else                                       -- latest run action.
        l_assignment_action_id := p_assignment_action_id;
     end if;

     for p in getParameters(l_assignment_action_id) loop
         l_parameters := 'PAYROLL_ID:'        ||p.payroll_id        ||':'||
                         'JSQLDATE:'          ||p.jsqldate          ||':'||
                         'EFFECTIVE_DATE:'    ||p.effective_date    ||':'||
                         'ASSIGNMENT_ID:'     ||p.assignment_id     ||':'||
                         'BUSINESS_GROUP_ID:' ||p.business_group_id ||':'||
                         'TAX_UNIT_ID:'       ||p.tax_unit_id       ||':'||
                         'G_CURRENCY_CODE:'   ||p.currency_code     ||':'||
                         'PREPAY_MAX_ACTION:' ||l_max_action        ||':'||
                         'PREPAY_MIN_ACTION:' ||l_min_action        ||':'||
                         'CURRENCY_NAME:'     ||p.currency_name     ||':'||
                         'ASSIGNMENT_ACTION_ID:'||p_assignment_action_id||':';
         if g_debug then
            hr_utility.trace('p_payroll_id = ' || p.payroll_id);
            hr_utility.trace('jsqldate = ' || p.jsqldate);
            hr_utility.trace('effective_date = ' || p.effective_date);
            hr_utility.trace('assignment_id = ' || p.assignment_id);
            hr_utility.trace('business_group_id = ' || p.business_group_id);
            hr_utility.trace('tax_unit_id = ' || p.tax_unit_id);
            hr_utility.trace('g_currency_code = ' || g_currency_code);
            hr_utility.trace('action_clause = ' || l_actions);
         end if;
         g_currency_code := p.currency_code;
         l_action_type := p.action_type;
     end loop;
     --
     if l_action_count = 1 then
        l_parameters := l_parameters || 'ACTION_CLAUSE:' ||
                           ' = '||l_actions ||':';
     else
        l_parameters := l_parameters ||  'ACTION_CLAUSE:' ||
                           ' in ('||l_actions ||')' ||':';
     end if;
     --
     if g_debug then
       hr_utility.trace('l_parameters = ' || l_parameters);
       hr_utility.set_location('Leaving pay_soe_glb.setParameters', 20);
     end if;
     --
     return l_parameters;
  end;
  --
  /* ---------------------------------------------------------------------
  Function : SetParameters

  Text
  ------------------------------------------------------------------------ */
  FUNCTION setParameters(  p_person_id in number
                         , p_assignment_id in number
                         , p_effective_date date)
  RETURN VARCHAR2 is
  begin
    --
    if g_debug then
       hr_utility.set_location('Entering pay_soe_glb.setParameters', 10);
    end if;
    --
    -- NOTE:
    -- This overridden version of setParameters is not yet fully implemented
    -- at GLB level.
    --
    -- Localizations should provide their own version of setParameters to
    -- derive the desired assignment_action_id, and then call
    -- pay_soe_glb.setParameters with that assignment_action_id.
    --
    if g_debug then
       hr_utility.set_location('Leaving pay_soe_glb.setParameters', 20);
    end if;
    --
    RETURN null;
    --
  END;

BEGIN
--  hr_utility.trace_on(NULL, 'DEBUG');
  lv_currency_code := 'MXN';
END pay_mx_soe_ss_pkg;

/
