--------------------------------------------------------
--  DDL for Package Body PAY_NZ_QES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_QES_PKG" as
/* $Header: pynzqes.pkb 120.0 2005/05/29 02:12:27 appldev noship $ */
  ------------------------------------------------------------------------
  g_ordinary_time_hours_id   pay_defined_balances.defined_balance_id%type;
  g_ordinary_time_payout_id  pay_defined_balances.defined_balance_id%type;
  ------------------------------------------------------------------------
  -- Counts the number of people per group.
  ------------------------------------------------------------------------
  function count_employees
    (p_organization_id  in hr_organization_units.organization_id%type,
     p_payroll_id       in pay_all_payrolls_f.payroll_id%type,
     p_time_period_id   in per_time_periods.time_period_id%type,
     p_location_id      in per_all_assignments_f.location_id%type,
     p_emp_cat_code     in per_all_people_f.per_information7%type,
     p_work_time_code   in per_all_people_f.per_information8%type,
     p_sex              in per_all_people_f.sex%type,
     p_survey_date       in date)
  return number is

    v_emp_count  number(20) := 0;

    cursor emp_count
      (c_organization_id  hr_organization_units.organization_id%type,
       c_payroll_id       pay_all_payrolls_f.payroll_id%type,
       c_time_period_id   per_time_periods.time_period_id%type,
       c_location_id      per_all_assignments_f.location_id%type,
       c_emp_cat_code     per_all_people_f.per_information7%type,
       c_work_time_code   per_all_people_f.per_information8%type,
       c_sex              per_all_people_f.sex%type,
       c_survey_date      date)
       is
    select count(*)
    from   hr_soft_coding_keyflex hsck,
           pay_payrolls_f pay, /*Bug 2920728*/
           per_time_periods ptp,
           per_people_f pap, /*Bug 2920728*/
           per_assignments_f paa /*Bug 2920728*/
    where  hsck.soft_coding_keyflex_id    = paa.soft_coding_keyflex_id
    and    hsck.segment1                  = to_char(c_organization_id)
    and    pay.payroll_id                 = c_payroll_id
    and    ptp.time_period_id             = c_time_period_id
    and    paa.location_id                = c_location_id
    and    pap.per_information7           = c_emp_cat_code
    and    pap.per_information8           = c_work_time_code
    and    pap.sex                        = c_sex
    and    ptp.regular_payment_date between paa.effective_start_date
                                        and paa.effective_end_date
    and    pap.effective_start_date <= c_survey_date
    and    pap.effective_end_date   >= c_survey_date
    and    pap.current_employee_flag      ='Y'
    and    pay.payroll_id                 = ptp.payroll_id
    and    pap.person_id                  = paa.person_id
    and    pay.payroll_id                 = paa.payroll_id;

  begin
    open emp_count (p_organization_id,
                    p_payroll_id,
                    p_time_period_id,
                    p_location_id,
                    p_emp_cat_code,
                    p_work_time_code,
                    p_sex,
                    p_survey_date  );
    fetch emp_count into v_emp_count;
    close emp_count;

    return v_emp_count;
  end count_employees;
  ------------------------------------------------------------------------
  -- Bug 1921492, will use Ordinary hours to calculate the hours worked
  -- for employee to see if the employee is part time employee or full
  -- time employee
  ------------------------------------------------------------------------
  function count_employees_using_balance
    (p_organization_id  in hr_organization_units.organization_id%type,
     p_payroll_id       in pay_all_payrolls_f.payroll_id%type,
     p_time_period_id   in per_time_periods.time_period_id%type,
     p_location_id      in per_all_assignments_f.location_id%type,
     p_emp_cat_code     in per_all_people_f.per_information7%type,
     p_work_time_code   in per_all_people_f.per_information8%type,
     p_sex              in per_all_people_f.sex%type,
     p_week_hours       in per_all_assignments_f.normal_hours%type,
     p_week_frequency   in per_all_assignments_f.frequency%type,
     p_survey_date      in date)
  return number is

     v_defined_balance_id     pay_defined_balances.defined_balance_id%type;
     v_emp_count         number(20)   := 0;
     v_emp_balance       number(20,5) := 0;
     v_total_balance     number(20,5) := 0;
     v_full_time_count   number(20)   := 0;
     v_part_time_count   number(20)   := 0;
     v_standard_hours    number(20)   := 0;

     cursor emp_balance
       (c_organization_id     hr_organization_units.organization_id%type,
        c_payroll_id          pay_all_payrolls_f.payroll_id%type,
        c_time_period_id      per_time_periods.time_period_id%type,
        c_location_id         per_all_assignments_f.location_id%type,
        c_defined_balance_id  pay_defined_balances.defined_balance_id%type,
        c_sex                 per_all_people_f.sex%type,
        c_survey_date         date) is

     select paa.assignment_id,
            ptp.regular_payment_date,
            pay.period_type  payroll_frequency,
            hr_nzbal.calc_all_balances(ptp.regular_payment_date,
                                       paa.assignment_id,
                                       c_defined_balance_id) balance
     from   hr_soft_coding_keyflex hsck,
            pay_payrolls_f pay, /*Bug 2929728*/
            per_time_periods ptp,
            per_people_f pap, /*Bug 2920728*/
            per_assignments_f paa /*Bug 2920728*/
     where  hsck.soft_coding_keyflex_id    = paa.soft_coding_keyflex_id
     and    hsck.segment1                  = to_char(c_organization_id)
     and    pay.payroll_id                 = c_payroll_id
     and    ptp.time_period_id             = c_time_period_id
     and    paa.location_id                = c_location_id
     and    pap.sex                        = c_sex
     and    ptp.regular_payment_date between paa.effective_start_date
                                         and paa.effective_end_date
     and    pap.effective_start_date<=c_survey_date
     and    pap.effective_end_date  >=c_survey_date
     and    pap.current_employee_flag='Y'
     and    pay.payroll_id                 = ptp.payroll_id
     and    pap.person_id                  = paa.person_id
     and    pay.payroll_id                 = paa.payroll_id
     and    pap.per_information7           = 'E';

   begin

     -- Determine the balance ID for OT hours .

     v_defined_balance_id := id_for_defined_balance('Statistics NZ Ordinary Time Hours','_ASG_PTD');

     for balance_rec in emp_balance (p_organization_id,
                                     p_payroll_id,
                                     p_time_period_id,
                                     p_location_id,
                                     v_defined_balance_id,
                                     p_sex,
                                     p_survey_date) loop

       if balance_rec.balance = 0 then

           -- Determine the Balance Id for OT Hours and check if the same
           -- as Balance Id passed in

           -- If it is then check if the OT Payout is 0 as well. If it is,
           -- that's okay, but if not, then the Assignment is for a salaried
           -- Employee, therefore determine the hours worked.
           if ordinary_time_payout (balance_rec.regular_payment_date,
                                    balance_rec.assignment_id) <> 0 then
              v_emp_balance := hours_worked (balance_rec.assignment_id,
                                             balance_rec.payroll_frequency);
           else

              -- Not OT Hours Balance OR OT Payout Balance = 0 as well.
              v_emp_balance := balance_rec.balance;
           end if;

       else
           v_emp_balance := balance_rec.balance;
       end if;

       v_standard_hours := convert_hours(p_week_hours,
                                         balance_rec.payroll_frequency,
                                         p_week_frequency);

       if v_emp_balance > v_standard_hours then
           v_full_time_count := v_full_time_count + 1;
       elsif v_emp_balance <> 0 then
           v_part_time_count := v_part_time_count + 1;
       end if;


     end loop;

     if p_work_time_code = 'F' then
         return v_full_time_count;
     elsif p_work_time_code = 'P' then
         return v_part_time_count;
     end if;

  end count_employees_using_balance;
  ------------------------------------------------------------------------
  -- Sums the Balance amount per group by each individual Assignment.
  -- This is done so that if the Balance for Ordinary Time Hours is 0,
  -- then a check can be performed to determine if the Balance for
  -- Ordinary Time Payout is 0. If it is, then the Hours for the
  -- Assignment are calculated, according to its Frequency and the
  -- Payroll Frequency.
  ------------------------------------------------------------------------
  function sum_balances
    (p_organization_id     in hr_organization_units.organization_id%type,
     p_payroll_id          in pay_all_payrolls_f.payroll_id%type,
     p_time_period_id      in per_time_periods.time_period_id%type,
     p_location_id         in per_all_assignments_f.location_id%type,
     p_defined_balance_id  in pay_defined_balances.defined_balance_id%type,
     p_sex                 in per_all_people_f.sex%type,
     p_survey_date          in date)
  return number is

    v_emp_balance    number(20,5) := 0;
    v_total_balance  number(20,5) := 0;

    cursor emp_balance
      (c_organization_id     hr_organization_units.organization_id%type,
       c_payroll_id          pay_all_payrolls_f.payroll_id%type,
       c_time_period_id      per_time_periods.time_period_id%type,
       c_location_id         per_all_assignments_f.location_id%type,
       c_defined_balance_id  pay_defined_balances.defined_balance_id%type,
       c_sex                 per_all_people_f.sex%type,
       c_survey_date         date) is

    select paa.assignment_id,
           ptp.regular_payment_date,
           pay.period_type  payroll_frequency,
           hr_nzbal.calc_all_balances(ptp.regular_payment_date,
                                      paa.assignment_id,
                                      c_defined_balance_id) balance
    from   hr_soft_coding_keyflex hsck,
           pay_payrolls_f pay, /*Bug 2920728*/
           per_time_periods ptp,
           per_people_f pap, /*Bug 2920728*/
           per_assignments_f paa /*Bug 2920728*/
    where  hsck.soft_coding_keyflex_id    = paa.soft_coding_keyflex_id
    and    hsck.segment1                  = to_char(c_organization_id)
    and    pay.payroll_id                 = c_payroll_id
    and    ptp.time_period_id             = c_time_period_id
    and    paa.location_id                = c_location_id
    and    pap.sex                        = c_sex
    and    ptp.regular_payment_date between paa.effective_start_date
                                        and paa.effective_end_date
    and    pap.effective_start_date<=c_survey_date
    and    pap.effective_end_date  >=c_survey_date
    and    pap.current_employee_flag='Y'
    and    pay.payroll_id                 = ptp.payroll_id
    and    pap.person_id                  = paa.person_id
    and    pay.payroll_id                 = paa.payroll_id
    and    pap.per_information7           = 'E';

  begin
    for balance_rec in emp_balance (p_organization_id,
                                    p_payroll_id,
                                    p_time_period_id,
                                    p_location_id,
                                    p_defined_balance_id,
                                    p_sex,
                                    p_survey_date) loop

      if balance_rec.balance = 0 then

         -- Determine the Balance Id for OT Hours and check if the same
         -- as Balance Id passed in
         if g_ordinary_time_hours_id is null then
           g_ordinary_time_hours_id :=
                   id_for_defined_balance('Statistics NZ Ordinary Time Hours','_ASG_PTD');
         end if;

         -- If it is then check if the OT Payout is 0 as well. If it is,
         -- that's okay, but if not, then the Assignment is for a salaried
         -- Employee, therefore determine the hours worked.
         if p_defined_balance_id = g_ordinary_time_hours_id and
            ordinary_time_payout (balance_rec.regular_payment_date,
                                  balance_rec.assignment_id) <> 0 then
           v_emp_balance := hours_worked (balance_rec.assignment_id,
                                          balance_rec.payroll_frequency);
         else

           -- Not OT Hours Balance OR OT Payout Balance = 0 as well.
           v_emp_balance := balance_rec.balance;
         end if;

      else
        v_emp_balance := balance_rec.balance;
      end if;

      v_total_balance := v_total_balance + v_emp_balance;
    end loop;

    return v_total_balance;
  end sum_balances;
  ------------------------------------------------------------------------
  -- Returns the Defined Balance Id for the Balance Name and Database Item
  -- Suffix passed in.
  ------------------------------------------------------------------------
  function id_for_defined_balance
    (p_balance_name       in pay_balance_types.balance_name%type,
     p_balance_dimension  in pay_balance_dimensions.database_item_suffix%type)
  return pay_balance_types.balance_type_id%type is

    v_balance_id  pay_balance_types.balance_type_id%type;

    cursor balance_id
      (c_balance_name       pay_balance_types.balance_name%type,
       c_balance_dimension  pay_balance_dimensions.database_item_suffix%type) is
    select pdb.defined_balance_id
    from   pay_balance_dimensions pbd,
           pay_defined_balances pdb,
           pay_balance_types pbt
    where  pbt.balance_type_id      = pdb.balance_type_id
    and    pbd.balance_dimension_id = pdb.balance_dimension_id
    and    pbt.balance_name         = c_balance_name
    and    pbd.database_item_suffix = c_balance_dimension;

  begin
    open balance_id (p_balance_name, p_balance_dimension);
    fetch balance_id into v_balance_id;
    close balance_id;

    return v_balance_id;
  end id_for_defined_balance;
  ------------------------------------------------------------------------
  -- Returns the Balance for the Ordinary Time Payout for the Effective
  -- Date and Assignment.
  ------------------------------------------------------------------------
  function ordinary_time_payout
    (p_regular_payment_date  in per_time_periods.regular_payment_date%type,
     p_assignment_id         in per_all_assignments_f.assignment_id%type)
  return number is

    v_payout  number(20,5) := 0;

  begin
    if g_ordinary_time_payout_id is null then
      g_ordinary_time_payout_id :=
              id_for_defined_balance('Statistics NZ Ordinary Time Payout','_ASG_PTD');
    end if;

    v_payout := hr_nzbal.calc_all_balances(p_regular_payment_date,
                                           p_assignment_id,
                                           g_ordinary_time_payout_id);
    return v_payout;
  end ordinary_time_payout;
  ------------------------------------------------------------------------
  -- Returns the Hours for an Assignment. If the Assignment Frequency is
  -- not equal to W (Week), then return 0. If the Assignment Frequency is
  -- equal to W, but differs from the Payroll Frequency, then call
  -- convert_hours.
  ------------------------------------------------------------------------
  function hours_worked
    (p_assignment_id      in per_all_assignments_f.assignment_id%type,
     p_payroll_frequency  in pay_all_payrolls_f.period_type%type)
  return number is

    v_hours_worked  number(20,5) := 0;

    cursor standard_conditions
      (c_assignment_id  per_all_assignments_f.assignment_id%type) is

    select paa.normal_hours,
           paa.frequency frequency_code, -- to pass to convert_hours
           hl.meaning   frequency -- to compare to payroll_frequency
    from   hr_lookups hl,
           per_assignments_f paa /*Bug 2920728*/
    where  hl.application_id  = 800
    and    paa.assignment_id  = c_assignment_id
    and    paa.frequency      = hl.lookup_code
    and    hl.lookup_type     = 'FREQUENCY';

    v_standard_conditions_rec  standard_conditions%rowtype;
  begin
    open standard_conditions (p_assignment_id);
    fetch standard_conditions into v_standard_conditions_rec;
    close standard_conditions;

    if v_standard_conditions_rec.frequency_code <> 'W' then
      v_hours_worked := 0;
    else
      if v_standard_conditions_rec.frequency = p_payroll_frequency then
        v_hours_worked := v_standard_conditions_rec.normal_hours;
      else
        v_hours_worked := convert_hours (v_standard_conditions_rec.normal_hours,
                                         p_payroll_frequency,
                                         v_standard_conditions_rec.frequency_code);
      end if;
    end if;

    return v_hours_worked;
  end hours_worked;
  ------------------------------------------------------------------------
  -- Converts the Assignment Hours so that it is of the same Frequency as
  -- the Payroll Frequency. This function assumes there are 52 weeks per
  -- year.
  ------------------------------------------------------------------------
  function convert_hours
    (p_assignment_hours     in per_all_assignments_f.normal_hours%type,
     p_payroll_frequency    in pay_all_payrolls_f.period_type%type,
     p_assignment_frequency in per_all_assignments_f.frequency%type)
  return number is

    v_converted_hours   number(20,5) := 0;
    v_number_per_year   per_time_period_types.number_per_fiscal_year%type := 52;
    v_periods_per_year  per_time_period_types.number_per_fiscal_year%type := 1;

  begin
    v_periods_per_year := no_periods_per_year (p_payroll_frequency);
    v_converted_hours  := p_assignment_hours /
                          v_periods_per_year *
                          v_number_per_year;

    return v_converted_hours;
  end convert_hours;
  ------------------------------------------------------------------------
  -- To determine which figures to use for conversion, the Payroll Period
  -- Types needs to be queried to determine the number of Periods per
  -- fiscal year.
  ------------------------------------------------------------------------
  function no_periods_per_year
    (p_period_type  in per_time_period_types.period_type%type)
  return number is

    v_number_per_year  per_time_period_types.number_per_fiscal_year%type := 0;

    cursor no_of_periods
      (c_period_type  per_time_period_types.period_type%type) is

    select number_per_fiscal_year
    from   per_time_period_types
    where  period_type = c_period_type;

  begin
    open no_of_periods (p_period_type);
    fetch no_of_periods into v_number_per_year;
    close no_of_periods;

    return v_number_per_year;
  end no_periods_per_year;
  ------------------------------------------------------------------------
end pay_nz_qes_pkg;

/
