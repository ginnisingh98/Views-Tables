--------------------------------------------------------
--  DDL for Package Body PAY_SG_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_SOE" as
/* $Header: pysgsoe.pkb 120.2.12010000.2 2008/08/06 08:23:04 ubhat ship $ */
  ------------------------------------------------------------------------
  -- Selects the Salary for the Person.
  -- clone of hr_general.get_salary but fetch at a given date
  -- This cursor gets the screen_entry_value from pay_element_entry_values_f.
  -- This is the salary amount obtained when the pay basis isn't null.
  -- The pay basis and assignment_id are passed in by the view.
  -- A check is made on the effective date of pay_element_entry_values_f
  -- and pay_element_entries_f as they're datetracked.
  ------------------------------------------------------------------------
  function current_salary
    (p_pay_basis_id    in per_pay_bases.pay_basis_id%type,
     p_assignment_id   in pay_element_entries_f.assignment_id%type,
     p_effective_date  in date)
  return varchar2 is

    cursor salary
      (c_pay_basis_id    per_pay_bases.pay_basis_id%type,
       c_assignment_id   pay_element_entries_f.assignment_id%type,
       c_effective_date  date) is
    select pev.screen_entry_value
    from   per_pay_bases ppb,
           pay_element_entries_f pee,
           pay_element_entry_values_f pev
    where  pee.assignment_id    = c_assignment_id
    and    ppb.pay_basis_id     = c_pay_basis_id
    and    pee.element_entry_id = pev.element_entry_id
    and    ppb.input_value_id   = pev.input_value_id
    and    c_effective_date between pev.effective_start_date
                                and pev.effective_end_date
    and    c_effective_date between pee.effective_start_date
                                and pee.effective_end_date;

    v_salary  pay_element_entry_values_f.screen_entry_value%type := null;
  begin
    -- Only open the cursor if the parameter may retrieve anything
    -- In practice, p_assignment_id is always going to be non null;
    -- p_pay_basis_id may be null, though. If it is, don't bother trying
    -- to fetch a salary.
    -- If we do have a pay basis, try and get a salary. There may not be one,
    -- in which case no problem: just return null.

    if p_pay_basis_id is not null and p_assignment_id is not null then
      open salary (p_pay_basis_id,
                   p_assignment_id,
                   p_effective_date);
      fetch salary into v_salary;
      if salary%NOTFOUND then
         close salary;
         raise NO_DATA_FOUND;
      end if;
      close salary;
    end if;

    return v_salary;
  end current_salary;

  ------------------------------------------------------------------------
  -- Calls the core accrual function. As per_accrual_calc_functions may
  -- change to have extra (default) parameters, it is called here rather
  -- than in the form or report as the version of SQL in these will not
  -- process default parameters.
  -- Also handy as we only need to pass back the accrual value, not the
  -- other OUT parameters.
  ------------------------------------------------------------------------
  function net_accrual
    (p_assignment_id      in pay_assignment_actions.assignment_id%type,
     p_plan_id            in pay_accrual_plans.accrual_plan_id%type,
     p_payroll_id         in pay_payroll_actions.payroll_id%type,
     p_business_group_id  in pay_accrual_plans.business_group_id%type,
     p_effective_date     in per_time_periods.end_date%type)
  return number is
    v_start_date        date;
    v_end_date          date;
    v_accrual_end_date  date;
    v_accrual           number;
    v_net_entitlement   number;
  begin
    per_accrual_calc_functions.get_net_accrual
      (p_assignment_id     => p_assignment_id,      --  number  in
       p_plan_id           => p_plan_id,            --  number  in
       p_payroll_id        => p_payroll_id,         --  number  in
       p_business_group_id => p_business_group_id,  --  number  in
       p_calculation_date  => p_effective_date,     --  date    in
       p_start_date        => v_start_date,         --  date    out
       p_end_date          => v_end_date,           --  date    out
       p_accrual_end_date  => v_accrual_end_date,   --  date    out
       p_accrual           => v_accrual,            --  number  out
       p_net_entitlement   => v_net_entitlement);   --  number  out

    return v_net_entitlement;
  end net_accrual;
  ------------------------------------------------------------------------
  -- Sums the Balances for Current and YTD, according to the parameters.
  -- for the SOE window
  ------------------------------------------------------------------------
  /* Bug:2883606. This procedure is modified to retrieve balance values
     directly from pay_balance_pkg.get_value instead of retrieving it from
     the view pay_sg_soe_balances_v */

  procedure current_and_ytd_balances
    (p_prepaid_tag	     in varchar,
     p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_balance_name          in pay_balance_types.balance_name%type,
     p_person_id             in per_all_people_f.person_id%type,
     p_current_balance      out nocopy number,
     p_ytd_balance          out nocopy number)
  is
    v_balance_value  	number;
    v_asg_le_ytd	number;
    v_per_le_ytd	number;
    v_payments		number;
    v_asg_le_run	number;
    v_pp_asg_le_ytd     number;
    v_pp_asg_le_run     number;
    v_pp_per_le_ytd     number;
    v_pp_payments       number;
    v_pp_assignment_action_id pay_assignment_actions.assignment_action_id%type;
    v_cur_run_id  pay_assignment_actions.assignment_action_id%type;
    l_RUN_ASSIGNMENT_ACTION_ID  pay_assignment_actions.assignment_action_id%type;

    /* Bug 2824397 */

    v_assign_count      number := 1;
    v_date_earned       date;
    v_ass_act_id        pay_assignment_actions.assignment_action_id%type;
    v_asg_le_value      number;
    v_counter           number := 1;

    TYPE assign_tab is table of per_all_assignments_f.assignment_id%type
    index by BINARY_INTEGER;

    assignment_table assign_tab;

    /* Bug 2824397 */

--    pay_balance_pkg.set_context('TAX_UNIT_ID');
--    pay_balance_pkg.set_context('JURISDICTION_CODE');

    /* Bug:2883606. Cursor to get the balance values from pay_balance_pkg.get_value */
    cursor balance_value
    (c_assignment_action_id  pay_assignment_actions.assignment_action_id%type,
     c_balance_name          pay_balance_types.balance_name%type,
     c_dimension_name        pay_balance_dimensions.dimension_name%type) is
       select nvl(pay_balance_pkg.get_value(pdb.defined_balance_id,c_assignment_action_id),0)
       from   pay_balance_dimensions pbd,
              pay_defined_balances pdb,
              pay_balance_types pbt
       where  pbt.balance_name         = c_balance_name
       and    pbd.dimension_name       = c_dimension_name
       and    pbt.balance_type_id      = pdb.balance_type_id
       and    pbd.balance_dimension_id = pdb.balance_dimension_id
       and    pbt.legislation_code     = 'SG';

    /* Bug:2883606. Cursor to get all the locked actions locked by prepayments */
     cursor run_ids
       (p_assignment_action_id pay_assignment_actions.assignment_action_id%type) is
      select LOCKED_ACTION_ID
      from   pay_action_interlocks
      where  LOCKING_ACTION_ID = p_assignment_action_id
      order by locked_action_id asc;

    /* Bug#2883606. Included check for costing(C) */
    /* Bug 6978015, added ORDER BY to get locking assignment_action_id */
    /*  whatever Costing runs after prepayment or before */
    cursor c_lock_id
      (c_assign_act_id pay_assignment_actions.assignment_action_id%type) is
    select pai.locking_action_id
    from pay_action_interlocks pai,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    where pai.locked_action_id = c_assign_act_id
    and   paa.assignment_action_id=pai.locking_action_id
    and   ppa.payroll_action_id=paa.payroll_action_id
    and ppa.action_type in ('P','U','C')
    order by decode(ppa.action_type,'C',0,1) desc;

    /* Bug #2824397 */
    /* Bug:2824397 Added extra parameter c_date_earned */
    cursor c_check_assignment
     (c_person_id  per_all_people_f.person_id%type,
      c_date_earned pay_payroll_actions.date_earned%type) is
            select distinct assignment_id
            from   per_all_assignments_f
            where  person_id = c_person_id
            and    effective_start_date <= c_date_earned
            and assignment_type = 'E';

    cursor c_date_earned
    (c_assignment_action_id  pay_assignment_actions.assignment_action_id%type) is
           select ppa.effective_date  /* Bug 4267365 */
           from   pay_payroll_actions ppa,
                  pay_assignment_actions pac
           where  pac.payroll_action_id = ppa.payroll_action_id
           and    pac.assignment_action_id = c_assignment_action_id;

     cursor c_max_assign_action
      (c_assignment_id per_all_assignments_f.assignment_id%type,
       c_date_earned pay_payroll_actions.date_earned%type ) is
           select max(pac.assignment_action_id)
           from   pay_assignment_actions pac,
                  per_all_assignments_f paa,
                  pay_payroll_actions ppa
           where paa.assignment_id =  c_assignment_id
           and   paa.assignment_type = 'E'
           and   paa.assignment_id =  pac.assignment_id
           and   pac.payroll_action_id = ppa.payroll_action_id
           and   ppa.action_type in ('R','Q','P','U')
           and   ppa.effective_date between to_date('01-01'||to_char(c_date_earned,'YYYY'),'DD-MM-YYYY')
                                 and c_date_earned;    /* Bug 4267365 */

    /* Bug #2824397 */

  begin

    /* Bug:2883606. If prepayments is done then sum up the balance values
       for all the actions that are locked by the prepayments.
       Else get the balance value for that single run */

    if p_prepaid_tag = 'Y' then
       open c_lock_id(p_assignment_action_id);
       fetch c_lock_id into v_pp_assignment_action_id;
       close c_lock_id;

       open run_ids(v_pp_assignment_action_id);
       loop
          fetch run_ids into v_cur_run_id;
          exit when run_ids%NOTFOUND;
          l_RUN_ASSIGNMENT_ACTION_ID := v_cur_run_id;

          open balance_value ( l_RUN_ASSIGNMENT_ACTION_ID ,p_balance_name,'_ASG_LE_RUN');
          fetch balance_value into v_asg_le_run;
           p_current_balance   := NVL(p_current_balance,0) + v_asg_le_run;
          close balance_value;
       end loop;
       close run_ids;

    else

       open balance_value ( p_assignment_action_id ,p_balance_name,'_ASG_LE_RUN');
       fetch balance_value into p_current_balance;
       close balance_value;

    end if;

    if instr(p_balance_name,'CPF') = 0 then
       open balance_value (p_assignment_action_id,
                           p_balance_name,
                           '_ASG_LE_YTD');
       fetch balance_value into p_ytd_balance;
       close balance_value;
    else

    /* Bug 2824397 */
      hr_utility.trace('Act_Act_Id' || to_char(p_assignment_action_id));
      hr_utility.trace('Person_Id' || to_char(p_person_id));
      hr_utility.trace('Date' ||to_char(v_date_earned));

     /* Get the Date Earned of the Assignment Action */
      open c_date_earned(p_assignment_action_id);
      fetch c_date_earned into v_date_earned;
      close c_date_earned;

      hr_utility.trace('Date' ||to_char(v_date_earned));

    /* Get all the assignments for the person_id and place the data into a PLSQL Table */

      open c_check_assignment(p_person_id,v_date_earned);
      loop
            fetch c_check_assignment  into assignment_table(v_assign_count);
            exit when c_check_assignment%NOTFOUND;
            v_assign_count := v_assign_count + 1;
      end loop;
      close c_check_assignment;

      hr_utility.trace('Count' || to_char(assignment_table.count));

      if assignment_table.count > 1 then
        for v_counter in 1..assignment_table.count
        loop

            /* Get the maximum assignment action within the financial year for every
               assignment fetched */

            v_asg_le_value := 0;
            open c_max_assign_action(assignment_table(v_counter),v_date_earned);
            fetch c_max_assign_action into v_ass_act_id;
            close c_max_assign_action;

            hr_utility.trace('Loop_Id' || to_char(v_ass_act_id));
            if (v_ass_act_id is not null) then
                 open balance_value (v_ass_act_id,
                                     p_balance_name,
                                     '_ASG_LE_YTD');
                 fetch balance_value into v_asg_le_value;
                 close balance_value;
            end if;

            hr_utility.trace('v_asg_le_value' || to_char(v_asg_le_value));

            /* Sum up the asg_le value to arrive at the per_le value */

            v_per_le_ytd := nvl(v_per_le_ytd,0) + nvl(v_asg_le_value,0);
            hr_utility.trace('v_per_le_ytd' || to_char(v_per_le_ytd));

        end loop;

        p_ytd_balance := nvl(v_per_le_ytd,0);

        hr_utility.trace('p_ytd_balance' || to_char(p_ytd_balance));

      else

        /* If the person has a single assignment_id then directly use asg_le_ytd value,
           since asg_le_ytd and per_le_ytd value */

        open balance_value (p_assignment_action_id,
                            p_balance_name,
                            '_ASG_LE_YTD');
        fetch balance_value into p_ytd_balance;
        close balance_value;

      end if;
    /* Bug 2824397 */

    end if;

  end current_and_ytd_balances;
  ------------------------------------------------------------------------
  -- Sums the Balances for Current and YTD, according to the parameters.
  -- for the Pay Advice report
  ------------------------------------------------------------------------
  /* Bug:2883606. This procedure is modified to retrieve balance values
     directly from pay_balance_pkg.get_value instead of retrieving it from
     the view pay_sg_soe_balances_v */

  procedure current_and_ytd_balances
      (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_balance_name          in pay_balance_types.balance_name%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_current_balance      out nocopy number,
       p_ytd_balance          out nocopy number)
  is
    v_balance_value     number;
    v_asg_le_ytd	number;
    v_per_le_ytd	number;
    v_payments		number;
    v_asg_le_run	number;
    v_pp_asg_le_ytd     number;
    v_pp_asg_le_run     number;
    v_pp_per_le_ytd     number;
    v_pp_payments       number;
    v_pp_assignment_action_id pay_assignment_actions.assignment_action_id%type;
    v_cur_run_id  pay_assignment_actions.assignment_action_id%type;
    l_RUN_ASSIGNMENT_ACTION_ID  pay_assignment_actions.assignment_action_id%type;

    /* Bug 2824397 */

    v_assign_count      number := 1;
    v_date_earned       date;
    v_ass_act_id        pay_assignment_actions.assignment_action_id%type;
    v_asg_le_value      number;
    v_counter           number := 1;

    TYPE assign_tab is table of per_all_assignments_f.assignment_id%type
    index by BINARY_INTEGER;

    assignment_table assign_tab;

    /* Bug 2824397 */
  --    pay_balance_pkg.set_context('TAX_UNIT_ID');
  --    pay_balance_pkg.set_context('JURISDICTION_CODE');

    /* Bug:2883606. Cursor to get the balance values from pay_balance_pkg.get_value */
    cursor balance_value
    (c_assignment_action_id  pay_assignment_actions.assignment_action_id%type,
     c_balance_name          pay_balance_types.balance_name%type,
     c_dimension_name        pay_balance_dimensions.dimension_name%type) is
       select nvl(pay_balance_pkg.get_value(pdb.defined_balance_id,c_assignment_action_id),0)
       from   pay_balance_dimensions pbd,
              pay_defined_balances pdb,
              pay_balance_types pbt
       where  pbt.balance_name         = c_balance_name
       and    pbd.dimension_name       = c_dimension_name
       and    pbt.balance_type_id      = pdb.balance_type_id
       and    pbd.balance_dimension_id = pdb.balance_dimension_id
    and    pbt.legislation_code     = 'SG';

    /* Bug:2883606. Cursor to get all the locked actions locked by prepayments  */
     cursor run_ids
       (p_assignment_action_id pay_assignment_actions.assignment_action_id%type) is
      select LOCKED_ACTION_ID
      from pay_action_interlocks
      where LOCKING_ACTION_ID = p_assignment_action_id
      order by locked_action_id asc;

    /* Bug#2883606. Included check for costing(C) */
    cursor c_lock_id
      (c_assign_act_id pay_assignment_actions.assignment_action_id%type) is
   select pai.locking_action_id
    from pay_action_interlocks pai,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    where pai.locked_action_id = c_assign_act_id
    and   paa.assignment_action_id=pai.locking_action_id
    and   ppa.payroll_action_id=paa.payroll_action_id
    and ppa.action_type in ('P','U','C');

    /* Bug #2824397 */
    /* Bug:2824397 Added extra parameter c_date_earned */
    cursor c_check_assignment
     (c_person_id  per_all_people_f.person_id%type,
      c_date_earned pay_payroll_actions.date_earned%type ) is
            select distinct assignment_id
            from   per_all_assignments_f
            where  person_id = c_person_id
            and    effective_start_date <= c_date_earned
            and assignment_type = 'E';

    cursor c_date_earned
    (c_assignment_action_id  pay_assignment_actions.assignment_action_id%type) is
           select ppa.effective_date   /* Bug 4267365 */
           from   pay_payroll_actions ppa,
                  pay_assignment_actions pac
           where  pac.payroll_action_id = ppa.payroll_action_id
           and    pac.assignment_action_id = c_assignment_action_id;

     cursor c_max_assign_action
      (c_assignment_id per_all_assignments_f.assignment_id%type,
       c_date_earned pay_payroll_actions.date_earned%type ) is
           select max(pac.assignment_action_id)
           from   pay_assignment_actions pac,
                  per_all_assignments_f paa,
                  pay_payroll_actions ppa
           where paa.assignment_id =  c_assignment_id
           and   paa.assignment_type = 'E'
           and   paa.assignment_id =  pac.assignment_id
           and   pac.payroll_action_id = ppa.payroll_action_id
           and   ppa.action_type in ('R','Q','P','U')
           and   ppa.effective_date between to_date('01-01'||to_char(c_date_earned,'YYYY'),'DD-MM-YYYY')
                                 and c_date_earned;   /* Bug 4267365 */

    /* Bug #2824397 */

    begin

      /* Get the prepayments assignment action id */
      open c_lock_id(p_assignment_action_id);
      fetch c_lock_id into v_pp_assignment_action_id;
      close c_lock_id;

      /* Bug:2883606. If the run is locked by the prepayments then
         get the balance values for all the runs that are locked by
         the prepayments and sum it up.
         Else get the balance value for the single run itself */

      if v_pp_assignment_action_id is not NULL then
         open run_ids(v_pp_assignment_action_id);
         loop
           fetch run_ids into v_cur_run_id;
           exit when run_ids%NOTFOUND;
           l_RUN_ASSIGNMENT_ACTION_ID := v_cur_run_id;

           open balance_value ( l_RUN_ASSIGNMENT_ACTION_ID ,p_balance_name,'_ASG_LE_RUN');
           fetch balance_value into v_asg_le_run;
           p_current_balance   := NVL(p_current_balance,0) + v_asg_le_run;
           close balance_value;
         end loop;
         close run_ids;

      else

         open balance_value ( p_assignment_action_id ,p_balance_name,'_ASG_LE_RUN');
         fetch balance_value into p_current_balance;
         close balance_value;

      end if;

      if instr(p_balance_name,'CPF') = 0 then
         open balance_value (p_assignment_action_id,
                             p_balance_name,
                             '_ASG_LE_YTD');
         fetch balance_value into p_ytd_balance;
         close balance_value;
      else
    /* Bug 2824397 */
    /* Get the Date Earned of the Assignment Action */

      open c_date_earned(p_assignment_action_id);
      fetch c_date_earned into v_date_earned;
      close c_date_earned;

      hr_utility.trace('Date' ||to_char(v_date_earned));
    /* Get all the assignments for the person_id and place the data into a PLSQL Table */

      open c_check_assignment(p_person_id,v_date_earned);
      loop
            fetch c_check_assignment  into assignment_table(v_assign_count);
            exit when c_check_assignment%NOTFOUND;
            v_assign_count := v_assign_count + 1;
      end loop;
      close c_check_assignment;



      if assignment_table.count > 1 then
        for v_counter in 1..assignment_table.count
        loop

            /* Get the maximum assignment action within the financial year for every
               assignment fetched */

            v_asg_le_value := 0;
            open c_max_assign_action(assignment_table(v_counter),v_date_earned);
            fetch c_max_assign_action into v_ass_act_id;
            close c_max_assign_action;

            if (v_ass_act_id is not null) then
                 open balance_value (v_ass_act_id,
                                     p_balance_name,
                                     '_ASG_LE_YTD');
                 fetch balance_value into v_asg_le_value;
                 close balance_value;
            end if;

            /* Sum up the asg_le value to arrive at the per_le value */

            v_per_le_ytd := nvl(v_per_le_ytd,0) + nvl(v_asg_le_value,0);

        end loop;

        p_ytd_balance := nvl(v_per_le_ytd,0);

      else

        /* If the person has a single assignment_id then directly use asg_le_ytd value,
           since asg_le_ytd and per_le_ytd value */

        open balance_value (p_assignment_action_id,
                            p_balance_name,
                            '_ASG_LE_YTD');
        fetch balance_value into p_ytd_balance;
        close balance_value;

      end if;
    /* Bug 2824397 */

     end if;

  end current_and_ytd_balances;
  ------------------------------------------------------------------------
  -- Procedure to merely pass all the balance results back in one hit,
  -- rather than 6 separate calls.
  -- for the SOE window
  ------------------------------------------------------------------------
  procedure balance_totals
    (p_prepaid_tag		      in varchar,
     p_assignment_action_id           in pay_assignment_actions.assignment_action_id%type,
     p_person_id                      in per_all_people_f.person_id%type,
     p_gross_pay_current              out nocopy number,
     p_statutory_deductions_current   out nocopy number,
     p_other_deductions_current       out nocopy number,
     p_net_pay_current                out nocopy number,
     p_non_payroll_current            out nocopy number,
     p_gross_pay_ytd                  out nocopy number,
     p_statutory_deductions_ytd       out nocopy number,
     p_other_deductions_ytd           out nocopy number,
     p_net_pay_ytd                    out nocopy number,
     p_non_payroll_ytd                out nocopy number,
     p_employee_cpf_current           out nocopy number,
     p_employer_cpf_current           out nocopy number,
     p_cpf_total_current              out nocopy number,
     p_employee_cpf_ytd               out nocopy number,
     p_employer_cpf_ytd               out nocopy number,
     p_cpf_total_ytd                  out nocopy number)
  is
    v_gross_pay_curr               number;
    v_involuntary_deductions_curr  number;
    v_voluntary_deductions_curr    number;
    v_statutory_deductions_curr    number;
    v_net_pay_curr                 number;
    v_non_payroll_curr             number;

    v_gross_pay_ytd                number;
    v_involuntary_deductions_ytd   number;
    v_voluntary_deductions_ytd     number;
    v_statutory_deductions_ytd     number;
    v_net_pay_ytd                  number;
    v_non_payroll_ytd              number;

    v_employee_cpf_curr_stat       number;
    v_employee_cpf_ytd_stat        number;
    v_employee_cpf_curr_vol        number;
    v_employee_cpf_ytd_vol         number;
    v_cpf_total_current            number;
    v_employer_cpf_curr_stat       number;
    v_employer_cpf_ytd_stat        number;
    v_employer_cpf_curr_vol        number;
    v_employer_cpf_ytd_vol         number;
    v_cpf_total_ytd                number;

    v_tax_id			   number;

  begin
    v_tax_id := get_tax_id(p_assignment_action_id);

    pay_balance_pkg.set_context('TAX_UNIT_ID',v_tax_id);
    -- Call procedure to get Current and YTD balances for Payment Summary Totals
    hr_utility.trace('JL pay_sg_soe, p_assignment_action_id:'||p_assignment_action_id);
    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
	    		      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Gross Pay',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_gross_pay_curr,
                              p_ytd_balance           => v_gross_pay_ytd);
 hr_utility.trace('JL v_gross_pay_curr:'||v_gross_pay_curr);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
	    		      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Statutory Deductions',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_statutory_deductions_curr,
                              p_ytd_balance           => v_statutory_deductions_ytd);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
	    		      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Involuntary Deductions',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_involuntary_deductions_curr,
                              p_ytd_balance           => v_involuntary_deductions_ytd);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
	    		      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Voluntary Deductions',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_voluntary_deductions_curr,
                              p_ytd_balance           => v_voluntary_deductions_ytd);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
	    		      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Net',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_net_pay_curr,
                              p_ytd_balance           => v_net_pay_ytd);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
	    		      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Non Payroll Payments',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_non_payroll_curr,
                              p_ytd_balance           => v_non_payroll_ytd);

    p_gross_pay_current            := v_gross_pay_curr;
    p_statutory_deductions_current := v_statutory_deductions_curr;
    p_other_deductions_current     := v_involuntary_deductions_curr +
                                      v_voluntary_deductions_curr;
    p_net_pay_current              := v_net_pay_curr;
    p_non_payroll_current          := v_non_payroll_curr;

    p_gross_pay_ytd                := v_gross_pay_ytd;
    p_other_deductions_ytd     	   := v_involuntary_deductions_ytd +
                                      v_voluntary_deductions_ytd;
    p_statutory_deductions_ytd     := v_statutory_deductions_ytd;
    p_net_pay_ytd                  := v_net_pay_ytd;
    p_non_payroll_ytd              := v_non_payroll_ytd;

    -- Call procedure to get Current and YTD balances for CPF Summary Totals
    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
    			      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'CPF Withheld',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_employee_cpf_curr_stat,
                              p_ytd_balance           => v_employee_cpf_ytd_stat);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
    			      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Voluntary CPF Withheld',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_employee_cpf_curr_vol,
                              p_ytd_balance           => v_employee_cpf_ytd_vol);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
    			      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'CPF Liability',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_employer_cpf_curr_stat,
                              p_ytd_balance           => v_employer_cpf_ytd_stat);

    current_and_ytd_balances (p_prepaid_tag	      => p_prepaid_tag,
    			      p_assignment_action_id  => p_assignment_action_id,
                              p_balance_name          => 'Voluntary CPF Liability',
                              p_person_id             => p_person_id,
                              p_current_balance       => v_employer_cpf_curr_vol,
                              p_ytd_balance           => v_employer_cpf_ytd_vol);


    p_employee_cpf_current := v_employee_cpf_curr_stat + v_employee_cpf_curr_vol;
    p_employer_cpf_current := v_employer_cpf_curr_stat + v_employer_cpf_curr_vol;
    p_cpf_total_current    := p_employee_cpf_current + p_employer_cpf_current;

    p_employee_cpf_ytd     := v_employee_cpf_ytd_stat + v_employee_cpf_ytd_vol;
    p_employer_cpf_ytd     := v_employer_cpf_ytd_stat + v_employer_cpf_ytd_vol;
    p_cpf_total_ytd        := p_employee_cpf_ytd + p_employer_cpf_ytd;
  end balance_totals;
  ------------------------------------------------------------------------
  -- Procedure to merely pass all the balance results back in one hit,
  -- rather than 6 separate calls.
  -- for the Pay Advice report
  ------------------------------------------------------------------------
    procedure balance_totals
      (p_assignment_action_id           in pay_assignment_actions.assignment_action_id%type,
       p_person_id                      in per_all_people_f.person_id%type,
       p_gross_pay_current              out nocopy number,
       p_statutory_deductions_current   out nocopy number,
       p_other_deductions_current       out nocopy number,
       p_net_pay_current                out nocopy number,
       p_non_payroll_current            out nocopy number,
       p_gross_pay_ytd                  out nocopy number,
       p_statutory_deductions_ytd       out nocopy number,
       p_other_deductions_ytd           out nocopy number,
       p_net_pay_ytd                    out nocopy number,
       p_non_payroll_ytd                out nocopy number,
       p_employee_cpf_current           out nocopy number,
       p_employer_cpf_current           out nocopy number,
       p_cpf_total_current              out nocopy number,
       p_employee_cpf_ytd               out nocopy number,
       p_employer_cpf_ytd               out nocopy number,
       p_cpf_total_ytd                  out nocopy number)
    is
      v_gross_pay_curr               number;
      v_involuntary_deductions_curr  number;
      v_voluntary_deductions_curr    number;
      v_statutory_deductions_curr    number;
      v_net_pay_curr                 number;
      v_non_payroll_curr             number;

      v_gross_pay_ytd                number;
      v_involuntary_deductions_ytd   number;
      v_voluntary_deductions_ytd     number;
      v_statutory_deductions_ytd     number;
      v_net_pay_ytd                  number;
      v_non_payroll_ytd              number;

      v_employee_cpf_curr_stat       number;
      v_employee_cpf_ytd_stat        number;
      v_employee_cpf_curr_vol        number;
      v_employee_cpf_ytd_vol         number;
      v_cpf_total_current            number;
      v_employer_cpf_curr_stat       number;
      v_employer_cpf_ytd_stat        number;
      v_employer_cpf_curr_vol        number;
      v_employer_cpf_ytd_vol         number;
      v_cpf_total_ytd                number;

      v_tax_id			   number;

    begin
      v_tax_id := get_tax_id(p_assignment_action_id);
      pay_balance_pkg.set_context('TAX_UNIT_ID',v_tax_id);
      -- Call procedure to get Current and YTD balances for Payment Summary Totals
      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Gross Pay',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_gross_pay_curr,
                                p_ytd_balance           => v_gross_pay_ytd);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Statutory Deductions',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_statutory_deductions_curr,
                                p_ytd_balance           => v_statutory_deductions_ytd);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Involuntary Deductions',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_involuntary_deductions_curr,
                                p_ytd_balance           => v_involuntary_deductions_ytd);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Voluntary Deductions',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_voluntary_deductions_curr,
                                p_ytd_balance           => v_voluntary_deductions_ytd);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Net',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_net_pay_curr,
                                p_ytd_balance           => v_net_pay_ytd);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Non Payroll Payments',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_non_payroll_curr,
                                p_ytd_balance           => v_non_payroll_ytd);

      p_gross_pay_current            := v_gross_pay_curr;
      p_statutory_deductions_current := v_statutory_deductions_curr;
      p_other_deductions_current     := v_involuntary_deductions_curr +
                                        v_voluntary_deductions_curr;
      p_net_pay_current              := v_net_pay_curr;
      p_non_payroll_current          := v_non_payroll_curr;

      p_gross_pay_ytd                := v_gross_pay_ytd;
      p_other_deductions_ytd     	   := v_involuntary_deductions_ytd +
                                        v_voluntary_deductions_ytd;
      p_statutory_deductions_ytd     := v_statutory_deductions_ytd;
      p_net_pay_ytd                  := v_net_pay_ytd;
      p_non_payroll_ytd              := v_non_payroll_ytd;

      -- Call procedure to get Current and YTD balances for CPF Summary Totals
      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'CPF Withheld',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_employee_cpf_curr_stat,
                                p_ytd_balance           => v_employee_cpf_ytd_stat);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Voluntary CPF Withheld',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_employee_cpf_curr_vol,
                                p_ytd_balance           => v_employee_cpf_ytd_vol);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'CPF Liability',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_employer_cpf_curr_stat,
                                p_ytd_balance           => v_employer_cpf_ytd_stat);

      current_and_ytd_balances (p_assignment_action_id  => p_assignment_action_id,
                                p_balance_name          => 'Voluntary CPF Liability',
                                p_person_id             => p_person_id,
                                p_current_balance       => v_employer_cpf_curr_vol,
                                p_ytd_balance           => v_employer_cpf_ytd_vol);


      p_employee_cpf_current := v_employee_cpf_curr_stat + v_employee_cpf_curr_vol;
      p_employer_cpf_current := v_employer_cpf_curr_stat + v_employer_cpf_curr_vol;
      p_cpf_total_current    := p_employee_cpf_current + p_employer_cpf_current;

      p_employee_cpf_ytd     := v_employee_cpf_ytd_stat + v_employee_cpf_ytd_vol;
      p_employer_cpf_ytd     := v_employer_cpf_ytd_stat + v_employer_cpf_ytd_vol;
      p_cpf_total_ytd        := p_employee_cpf_ytd + p_employer_cpf_ytd;
    end balance_totals;

  ------------------------------------------------------------------------
  -- get exchange rate for the payroll action effective_date
  -- to be used by pay_sg_asg_elements_v
  -- to convert the pay value from other currencies to BG currency
  ------------------------------------------------------------------------
  function get_exchange_rate
    (p_from_currency 		in gl_daily_rates.from_currency%type,
     p_to_currency 		in gl_daily_rates.to_currency%type,
     eff_date 			in gl_daily_rates.conversion_date%type,
     p_business_group_id 	in pay_user_columns.business_group_id%type )
  return number is
    CURSOR rate is     	SELECT gdr.conversion_rate
   	   		FROM   gl_daily_rates gdr, gl_daily_conversion_types gdct
   			WHERE  gdr.conversion_type = gdct.conversion_type
   			AND    gdr.from_currency = p_from_currency
          		AND    gdr.to_currency   = p_to_currency
          		AND    gdr.conversion_date = eff_date
          		AND    gdct.user_conversion_type = (
          						SELECT 	puci.value
							FROM 	pay_user_column_instances_f puci,
								pay_user_rows_f pur,
								pay_user_columns puc,
								pay_user_tables put
							WHERE   puci.user_row_id = pur.user_row_id
							AND     puci.user_column_id = puc.user_column_id
							AND     pur.user_table_id = put.user_table_id
							AND	puc.user_table_id = put.user_table_id
							AND     puci.business_group_id = p_business_group_id
							AND     pur.ROW_LOW_RANGE_OR_NAME = 'PAY'
							AND     put.user_table_name = 'EXCHANGE_RATE_TYPES'	);
    v_rate number;
  BEGIN
    IF p_from_currency <> p_to_currency THEN
       OPEN rate;
       FETCH rate INTO v_rate;
       IF rate%NOTFOUND THEN
         v_rate := null;
       END IF;
    END IF;
    return(v_rate);
    CLOSE rate;
  end get_exchange_rate;
  ------------------------------------------------------------------------
  -- get tax_unit_id for an assignment_action_id
  -- needed in setting the context id
  ------------------------------------------------------------------------
  function get_tax_id
    ( p_assignment_action_id 	number)
  return number is
    cursor tax is	SELECT 	tax_unit_id
    			FROM	pay_assignment_actions
      			WHERE   assignment_action_id = p_assignment_action_id;
    v_tax_id 	number;
  BEGIN
    open tax;
    fetch tax into v_tax_id;
    if tax%NOTFOUND then
       close tax;
       v_tax_id := null;
    end if;
    close tax;
    return(v_tax_id);
  END get_tax_id;
  ------------------------------------------------------------------------
  -- Selects the Home Address for the Person.
  ------------------------------------------------------------------------
  procedure get_home_address
    (p_person_id      in  per_addresses.person_id%type,
     p_address_line1  out nocopy per_addresses.address_line1%type,
     p_address_line2  out nocopy per_addresses.address_line2%type,
     p_address_line3  out nocopy per_addresses.address_line3%type,
     p_town_city      out nocopy per_addresses.town_or_city%type,
     p_postal_code    out nocopy per_addresses.postal_code%type,
     p_country_name   out nocopy fnd_territories_tl.territory_short_name%type) is

    cursor home_address
      (c_person_id  per_addresses.person_id%type) is
    select pad.address_line1,
           pad.address_line2,
           pad.address_line3,
           pad.town_or_city,
           pad.postal_code,
           ftt.territory_short_name
    from   per_addresses pad,
           fnd_territories_tl ftt
    where  pad.person_id      = c_person_id
    and    ftt.language       = userenv('LANG')
    and    ftt.territory_code = pad.country
    and    sysdate between nvl(pad.date_from, sysdate) and nvl(pad.date_to, sysdate);

  begin
    open home_address(p_person_id);
    fetch home_address into p_address_line1,
                            p_address_line2,
                            p_address_line3,
                            p_town_city,
                            p_postal_code,
                            p_country_name;
    close home_address;
  end get_home_address;
  ------------------------------------------------------------------------
  -- Selects the Work Address for the Person.
  ------------------------------------------------------------------------
  procedure get_work_address
    (p_location_id    in  hr_locations.location_id%type,
     p_address_line1  out nocopy hr_locations.address_line_1%type,
     p_address_line2  out nocopy hr_locations.address_line_2%type,
     p_address_line3  out nocopy hr_locations.address_line_3%type,
     p_town_city      out nocopy hr_locations.town_or_city%type,
     p_postal_code    out nocopy hr_locations.postal_code%type,
     p_country_name   out nocopy fnd_territories_tl.territory_short_name%type) is

    cursor c_get_work_address
      (c_location_id  hr_locations.location_id%type) is
    select hrl.address_line_1,
           hrl.address_line_2,
           hrl.address_line_3,
           hrl.town_or_city,
           hrl.postal_code,
           ftt.territory_short_name
    from   hr_locations hrl,
           fnd_territories_tl ftt
    where  hrl.location_id    = c_location_id
    and    ftt.language      (+) = userenv('LANG')
    and    ftt.territory_code (+) = hrl.country;

 begin
    open  c_get_work_address(p_location_id);
    fetch c_get_work_address into p_address_line1,
                                  p_address_line2,
                                  p_address_line3,
                                  p_town_city,
                                  p_postal_code,
                                  p_country_name;
    close c_get_work_address;
 end get_work_address;
 ------------------------------------------------------------------------
 -- Returns the Currency Code for the Business Group.
 ------------------------------------------------------------------------
 function business_currency_code
   (p_business_group_id  in hr_organization_units.business_group_id%type)
   return fnd_currencies.currency_code%type is

   v_currency_code  fnd_currencies.currency_code%type;

   cursor currency_code
     (c_business_group_id  hr_organization_units.business_group_id%type) is
     select fcu.currency_code
     from   hr_organization_information hoi,
            hr_organization_units hou,
            fnd_currencies fcu
     where  hou.business_group_id       = c_business_group_id
     and    hou.organization_id         = hoi.organization_id
     and    hoi.org_information_context = 'Business Group Information'
     and    fcu.issuing_territory_code  = hoi.org_information9;

   begin
     open currency_code (p_business_group_id);
     fetch currency_code into v_currency_code;
     close currency_code;
     return v_currency_code;
  end business_currency_code;

  ------------------------------------------------------------------------
  -- Bug#5633652 - Returns currency code based on the payment method attached
  --               to a payroll
  ------------------------------------------------------------------------
  function get_payroll_currency_code
   (p_payroll_id     in pay_payrolls_f.payroll_id%type,
    p_effective_date in pay_payroll_actions.effective_date%type)
  return fnd_currencies.currency_code%type is

   v_currency_code  fnd_currencies.currency_code%type;

   cursor csr_currency_code
     (c_payroll_id  pay_assignment_actions.assignment_action_id%type,
      c_effective_date in pay_payroll_actions.effective_date%type) is
   select popm.currency_code
   from   pay_payrolls_f            ppf,
          pay_org_payment_methods_f popm
   where  ppf.payroll_id = c_payroll_id
   and    popm.org_payment_method_id = ppf.default_payment_method_id
   and    c_effective_date between ppf.effective_start_date and ppf.effective_end_date
   and    c_effective_date between popm.effective_start_date and popm.effective_end_date;

   begin
     open csr_currency_code (p_payroll_id,p_effective_date);
     fetch csr_currency_code into v_currency_code;
     if csr_currency_code%NOTFOUND then
        v_currency_code := 'SGD';
     end if;
     close csr_currency_code;
     return v_currency_code;
  end get_payroll_currency_code;

  ------------------------------------------------------------------------
  -- Bug#5633652 - Returns currency code based on the payroll attached
  --               to an assignment
  ------------------------------------------------------------------------
  function get_assignment_currency_code
    (p_assignment_id  in per_all_assignments_f.assignment_id%type,
     p_effective_date in pay_payroll_actions.effective_date%type)
  return fnd_currencies.currency_code%type is

    v_currency_code  fnd_currencies.currency_code%type;
    v_payroll_id     pay_payrolls_f.payroll_id%type;

    cursor csr_get_payroll_id
      (c_assignment_id  pay_assignment_actions.assignment_action_id%type,
       c_effective_date in pay_payroll_actions.effective_date%type) is
    select payroll_id
    from   per_all_assignments_f
    where  assignment_id = c_assignment_id
    and    c_effective_date between effective_start_date and effective_end_date;

    begin
      open csr_get_payroll_id(p_assignment_id,p_effective_date);
      fetch csr_get_payroll_id into v_payroll_id;
      if csr_get_payroll_id%FOUND then
         v_currency_code := get_payroll_currency_code(v_payroll_id,p_effective_date);
      else
         v_currency_code := 'SGD';
      end if;
      close csr_get_payroll_id;
      return v_currency_code;
    end get_assignment_currency_code;

end pay_sg_soe;

/
