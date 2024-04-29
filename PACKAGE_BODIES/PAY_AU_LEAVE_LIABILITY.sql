--------------------------------------------------------
--  DDL for Package Body PAY_AU_LEAVE_LIABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_LEAVE_LIABILITY" as
  --  $Header: pyaullal.pkb 120.0 2005/05/29 03:06:58 appldev noship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create AU HRMS leave liability package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+------------------------------------------
  --  01 Sep 2004 JLin      N/A       Fixed GSCC warning
  --  12 Aug 2004 JLin      3781867   Modified accraul_category getting
  --                                  from the pay_au_processes table
  --  04 Dec 2002 Ragovind  2689226   Added NOCOPY for the functions leave_net_accrual, leave_net_entitlement, range_code and added dbdrv
  --  25 JUL 2000 rayyadev  N/A       modified the query of cursor c_Accrual_plans
  -- 					in the archive_code procedure
  --  14 JUL 2000 rayyadev  N/A       Created
  --  06 oct 2000 rayyadev  N/A       Added the Leave_Net_Accrual Procedure.
  --  11 SEP 2001 vgsriniv  1938342   Added the c_formula Cursor.
  -----------------------------------------------------------------------------
  --  range_code procedure
  --
  --  public procedure required by the Payroll Archive Reporter (PAR) process
  -----------------------------------------------------------------------------

  procedure range_code
  (p_payroll_action_id  in     number
  ,p_sql                   out NOCOPY varchar2) is

    l_sql                           varchar2(4000) ;
    l_procedure_name                varchar2(61);

  begin
    l_procedure_name := 'pay_au_leave_liability.range_code' ;

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  set up a SQL statement that defines the set of people to process
    --  required by the PAR process

    l_sql := 'select distinct p.person_id '                                 ||
               'from per_people_f p '                                       ||
                   ',pay_payroll_actions pa '                               ||
                   ',per_assignments_f a '                                  ||
                   ',pay_element_entries_f ee '                             ||
                   ',pay_element_links_f el '                               ||
                   ',pay_accrual_plans ap '                                 ||
              'where pa.payroll_action_id = :payroll_action_id '            ||
                'and p.business_group_id = pa.business_group_id '           ||
                'and a.person_id = p.person_id '                            ||
                'and a.payroll_id is not null '                             ||
                'and ee.assignment_id = a.assignment_id '                   ||
                'and el.element_link_id = ee.element_link_id '              ||
                'and ap.accrual_plan_element_type_id = el.element_type_id ' ||
                'and ap.accrual_category In (select accrual_category '      ||
                                            'from   pay_au_processes '      ||
                                            'where  accrual_category is not null ' ||
                                            'and legislation_code = ''AU'') ' ||
                'and pa.effective_date between p.effective_start_date '     ||
                                          'and p.effective_end_date '       ||
                'and pa.effective_date between a.effective_start_date '     ||
                                          'and a.effective_end_date '       ||
                'and pa.effective_date between ee.effective_start_date '    ||
                                          'and ee.effective_end_date '      ||
                'and pa.effective_date between el.effective_start_date '    ||
                                          'and el.effective_end_date '      ||
             'order by '                                                    ||
                    'p.person_id ' ;

    p_sql := l_sql ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  end range_code ;

  -----------------------------------------------------------------------------
  -- assignment_action_code procedure
  --
  --  public procedure required by the Payroll Archive Reporter process
  -----------------------------------------------------------------------------

  procedure assignment_action_code
  (p_payroll_action_id  in     number
  ,p_start_person_id    in     number
  ,p_end_person_id      in     number
  ,p_chunk              in     number) is

    l_assignment_action_id          number ;
    l_procedure_name                varchar2(61) ;

    --  The PAR process can multi-thread this procedure so make
    --  sure that the cursor only deals with assignments in this
    --  thread.  The p_start_person_id and p_end_person_id parameters
    --  to the procedure identify the set of people in this thread.

    --  The cursor identifies assignments that are enrolled in
    --  accrual plans that have an accrual category of 'AUAL','AULSL'.

    cursor c_assignments (p_payroll_action_id number
                         ,p_start_person_id number
                         ,p_end_person_id number) is
      select distinct a.assignment_id
      from   pay_payroll_actions pa
      ,      per_assignments_f a
      ,      pay_element_entries_f ee
      ,      pay_element_links_f el
      ,      pay_accrual_plans ap
      where  pa.payroll_action_id = p_payroll_action_id
      and    a.business_group_id = pa.business_group_id
      and    a.person_id between p_start_person_id
                             and p_end_person_id
      and    a.payroll_id is not null
      and    ee.assignment_id = a.assignment_id
      and    el.element_link_id = ee.element_link_id
      and    ap.accrual_plan_element_type_id = el.element_type_id
      and    ap.accrual_category IN (select  accrual_category
                                     from    pay_au_processes
                                     where   legislation_code = 'AU'
                                     and     accrual_category is not null)
      and    pa.effective_date between a.effective_start_date
                                   and a.effective_end_date
      and    pa.effective_date between ee.effective_start_date
                                   and ee.effective_end_date
      and    pa.effective_date between el.effective_start_date
                                   and el.effective_end_date ;

    cursor c_assignment_action_id is
      select pay_assignment_actions_s.nextval
      from   dual ;

  begin

    l_procedure_name := 'pay_au_leave_liability.assignment_action_code' ;

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  loop through the qualifying assignments

    for r_assignment in c_assignments(p_payroll_action_id
                                     ,p_start_person_id
                                     ,p_end_person_id)
    loop

      --  get the next assignment action ID

      open c_assignment_action_id ;
      fetch c_assignment_action_id
        into l_assignment_action_id ;
      close c_assignment_action_id ;

      --  create the assignment action ID

      hr_nonrun_asact.insact(l_assignment_action_id
                            ,r_assignment.assignment_id
                            ,p_payroll_action_id
                            ,p_chunk
                            ,null) ;

    end loop ;  --  c_assignments

    hr_utility.trace('Out: ' || l_procedure_name) ;

  end assignment_action_code ;

  -----------------------------------------------------------------------------
  -- initialization_code procedure
  --
  --  public procedure required by the Payroll Archive Reporter process
  -----------------------------------------------------------------------------

  procedure initialization_code
  (p_payroll_action_id  in     number) is

    l_procedure_name                varchar2(61) ;

  begin

    l_procedure_name  := 'pay_au_leave_liability.initialization_code' ;

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  do nothing: no global contexts need to be set

    hr_utility.trace('Out: ' || l_procedure_name) ;

  end initialization_code ;

  -----------------------------------------------------------------------------
  -- archive_code procedure
  --
  --  public procedure required by the Payroll Archive Reporter process
  -----------------------------------------------------------------------------

  procedure archive_code
  (p_assignment_action_id  in     number
  ,p_effective_date        in     date) is

    l_procedure_name                varchar2(61) ;
    l_process_id                    pay_au_processes.process_id%type ;
    l_gcc_parameters_store          pay_au_generic_code_caller.t_variable_store_tab ;
    l_business_group_id             pay_payroll_actions.business_group_id%type ;
    l_assignment_id                 pay_assignment_actions.assignment_id%type ;
    l_payroll_action_id             pay_payroll_actions.payroll_action_id%type ;
    l_counter                       integer := 1 ;
    l_accrual_category		    varchar2(15); --temporary variable to check the accrual category.

    cursor c_process(p_short_name varchar2) is
      select p.process_id
      from   pay_au_processes p
      where  p.short_name = p_short_name
      and    p.legislation_code = 'AU' ;

    cursor c_action(p_assignment_action_id number) is
      select pa.business_group_id
      ,      pa.payroll_action_id
      ,      aa.assignment_id
      from   pay_assignment_actions aa
      ,      pay_payroll_actions pa
      where  aa.assignment_action_id = p_assignment_action_id
      and    pa.payroll_action_id = aa.payroll_action_id ;

    cursor c_accrual_plans(p_assignment_action_id number) is
      select ap.accrual_plan_id
      ,      ap.accrual_category
      ,      a.payroll_id
      from   pay_assignment_actions aa
      ,      pay_payroll_actions pa
      ,      per_assignments_f a
      ,      pay_element_entries_f ee
      ,      pay_element_links_f el
      ,      pay_accrual_plans ap
      where  aa.assignment_action_id = p_assignment_action_id
      and    pa.payroll_action_id = aa.payroll_action_id
      and    a.assignment_id = aa.assignment_id
      and    a.payroll_id is not null
      and    ee.assignment_id = a.assignment_id
      and    el.element_link_id = ee.element_link_id
      and    ap.accrual_plan_element_type_id = el.element_type_id
      and    ap.accrual_category in (select accrual_category
                                     from   pay_au_processes
                                     where  legislation_code = 'AU'
                                     and    accrual_category is not null)
      and    pa.effective_date between a.effective_start_date
                                   and a.effective_end_date
      and    pa.effective_date between ee.effective_start_date
                                   and ee.effective_end_date
      and    pa.effective_date between el.effective_start_date
                                   and el.effective_end_date ;

    cursor c_process_category(p_accrual_category varchar2) is
      select p.process_id
      from   pay_au_processes p
      where  p.accrual_category = p_accrual_category
      and    p.legislation_code = 'AU'
      and    p.accrual_category is not null;

  begin

    l_procedure_name := 'pay_au_leave_liability.archive_code' ;

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  find out the generic code caller process ID for
    --  AU leave liability
     hr_utility.trace('P_assignment_action_id' || P_assignment_action_id) ;

    hr_utility.trace('Accrual category ' || l_Accrual_category) ;



    --  the generic code caller requires parameters to be passed
    --  in using a PL/SQL table - set up the PL/SQL table with
    --  parameters

    open c_action(p_assignment_action_id) ;
    fetch c_action
      into l_business_group_id
      ,    l_payroll_action_id
      ,    l_assignment_id ;
    close c_action ;

    l_gcc_parameters_store(1).name := 'ASSIGNMENT_ID' ;
    l_gcc_parameters_store(1).data_type := 'NUMBER' ;
    l_gcc_parameters_store(1).value := to_char(l_assignment_id) ;

    l_gcc_parameters_store(2).name := 'PAYROLL_ACTION_ID' ;
    l_gcc_parameters_store(2).data_type := 'NUMBER' ;
    l_gcc_parameters_store(2).value := to_char(l_payroll_action_id) ;

    l_gcc_parameters_store(3).name := 'ORIGINAL_ENTRY_ID' ;
    l_gcc_parameters_store(3).data_type := 'NUMBER' ;
    l_gcc_parameters_store(3).value := '-1' ;

    --  find the annual leave plans the assignment is enrolled in
    --  (there will usually only be one).

    for r_accrual_plan in c_accrual_plans(p_assignment_action_id)
    loop
      open c_process_category(r_accrual_plan.accrual_category);
      fetch c_process_category into l_process_id;
      close c_process_category ;

      --  add the accrual plan ID to the PL/SQL table

      l_gcc_parameters_store(4).name := 'ACCRUAL_PLAN_ID' ;
      l_gcc_parameters_store(4).data_type := 'NUMBER' ;
      l_gcc_parameters_store(4).value := r_accrual_plan.accrual_plan_id ;

      --  add the payroll ID to the PL/SQL table

      l_gcc_parameters_store(5).name := 'PAYROLL_ID' ;
      l_gcc_parameters_store(5).data_type := 'NUMBER' ;
      l_gcc_parameters_store(5).value := r_accrual_plan.payroll_id ;

      --  set the hourly rate for testing purposes

      l_gcc_parameters_store(6).name := 'ORDINARY_PAY_HOURLY_RATE' ;
      l_gcc_parameters_store(6).data_type := 'NUMBER' ;
      l_gcc_parameters_store(6).value := '10' ;

      --  call the generic code caller.  It will execute the modules
      --  associated with the process and write the results as
      --  archive database items

      pay_au_generic_code_caller.execute_process
      (p_business_group_id            => l_business_group_id
      ,p_effective_date               => p_effective_date
      ,p_process_id                   => l_process_id
      ,p_assignment_action_id         => p_assignment_action_id
      ,p_input_store                  => l_gcc_parameters_store) ;

    end loop ;  --  c_accrual_plans

    hr_utility.trace('Out: ' || l_procedure_name) ;

  end archive_code ;

  -----------------------------------------------------------------------------
  --  hourly_rate procedure
  --
  --  procedure function that gets called as part of the AU Leave Liability
  --  process.  Note that this procedure can only be called from the
  --  generic code caller as it relies on data structures that have been
  --  set up by the generic code caller.
  -----------------------------------------------------------------------------

  procedure hourly_rate is

    l_hourly_rate_formula_const     constant ff_formulas_f.formula_name%type := 'AU_HOURLY_RATE_FORMULA' ;

    l_procedure_name                varchar2(61) ;
    l_hourly_rate                   number := null ;
    l_business_group_id             pay_au_modules.business_group_id%type ;
    l_legislation_code              pay_au_modules.legislation_code%type ;
    l_formula_name                  ff_formulas_f.formula_name%type ;

    e_bad_module                    exception ;
    e_bad_hourly_rate               exception ;

l_formula_id number;
     cursor c_formula (p_formula_name varchar2
                     ,p_business_group_id number
                     ,p_legislation_code varchar2) is
      select f.formula_id
      from   ff_formulas_f f
      where  f.formula_name = p_formula_name
      and    ((f.business_group_id is null
      and      f.legislation_code is null)
      or      (f.business_group_id = p_business_group_id)
      or      (f.legislation_code = p_legislation_code)) ;
    procedure execute_formula(p_formula_name varchar2) is

      l_procedure_name                varchar2(61) ;
      l_module_id                     pay_au_modules.module_id%type ;

      cursor c_module(p_formula_name        varchar2
                     ,p_business_group_id   number
                     ,p_legislation_code    varchar2) is
        select m.module_id
        from   pay_au_modules m
        where  m.formula_name = p_formula_name
        and    m.enabled_flag = 'Y'
        and    ((m.business_group_id is null
        and      m.legislation_code is null)
        or      (m.business_group_id = p_business_group_id)
        or      (m.legislation_code = p_legislation_code)) ;

    begin

      l_procedure_name    := 'execute_formula' ;

      hr_utility.trace('  In: ' || l_procedure_name) ;

      --  get the module ID for the formula

      open c_module(p_formula_name
                   ,l_business_group_id
                   ,l_legislation_code) ;
      fetch c_module
        into l_module_id ;
      if c_module%notfound
      then
        close c_module ;
        raise e_bad_module ;
      end if ;
      close c_module ;

      --  execute the formula using the generic code caller execute
      --  formula procedure

      pay_au_generic_code_caller.execute_formula
      (l_module_id
      ,p_formula_name) ;

      hr_utility.trace('  Out: ' || l_procedure_name) ;
exception
    when e_bad_module
    then
      hr_utility.set_message(801, 'HR_AU_INVALID_MODULE') ;
      hr_utility.set_message_token('MODULE_NAME',p_formula_name);
      hr_utility.raise_error ;
    end execute_formula ;

  begin

    l_procedure_name      := 'pay_au_leave_liability.hourly_rate' ;

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  get the BUSINESS_GROUP_ID from the PL/SQL table of
    --  variables maintained by the generic code caller

    pay_au_generic_code_caller.retrieve_variable
    ('BUSINESS_GROUP_ID'
    ,'NUMBER'
    ,l_business_group_id) ;

    --  get the LEGISLATION_CODE from the PL/SQL table of
    --  variables maintained by the generic code caller

    pay_au_generic_code_caller.retrieve_variable
    ('LEGISLATION_CODE'
    ,'TEXT'
    ,l_legislation_code) ;

    --  Execute the hourly rate formula.
    --  (the hourly rate formula will be written by the implementation
    --  team.  We will ship the module definition in pay_au_modules
    --  and define the specification of the formula).



open
c_formula(l_hourly_rate_formula_const,l_business_group_id,l_legislation_code);

fetch c_formula into l_formula_id ;
if c_formula%notfound then
   close c_formula;
  raise e_bad_hourly_rate;
else
close c_formula;
end if;




    execute_formula(l_hourly_rate_formula_const) ;

    --  get the HOURLY_RATE_FORMULA from the PL/SQL table of
    --  variables maintained by the generic code caller.  This
    --  variable should have been set up as an output from the
    --  hourly rate formula.

    pay_au_generic_code_caller.retrieve_variable
    ('HOURLY_RATE_FORMULA_NAME'
    ,'TEXT'
    ,l_formula_name) ;

    execute_formula(l_formula_name) ;

    --  the formula should have set up the ORDINARY_PAY_HOURLY_RATE
    --  variable in the generic code caller's PL/SQL table.  Get
    --  rate to make sure that it has been set up.

    pay_au_generic_code_caller.retrieve_variable
    ('ORDINARY_PAY_HOURLY_RATE'
    ,'NUMBER'
    ,l_hourly_rate) ;

    if l_hourly_rate is null
    then
      raise e_bad_hourly_rate ;
    end if ;

    hr_utility.trace('Out: ' || l_procedure_name) ;

  exception
    when e_bad_hourly_rate
    then
      hr_utility.set_message(801, 'HR_AU_BAD_HOURLY_RATE') ;
      hr_utility.raise_error ;

  end hourly_rate ;

  procedure leave_net_entitlement
     (p_assignment_id      in number
     ,p_payroll_id         in number
     ,p_business_group_id  in number
     ,p_plan_id            in number
     ,p_calculation_date   in date
     ,p_start_date         out NOCOPY date
     ,p_end_date	   out NOCOPY date
     ,p_net_entitlement    out NOCOPY number) is
    l_get_accrual_value	  number;
    l_net_accrual         number;
    l_next_period_end     date;
    l_procedure_name                varchar2(61) ;

  begin

    l_procedure_name   := 'pay_au_leave_liability.annual_leave_net_entitlement' ;

    hr_utility.trace('In: ' || l_procedure_name) ;
    l_get_accrual_value := hr_au_holidays.get_accrual_entitlement(p_assignment_id
     ,p_payroll_id
     ,p_business_group_id
     ,p_plan_id
     ,p_calculation_date
     ,l_net_accrual
     ,p_net_entitlement
     ,p_start_date
     ,p_end_date
     ,l_next_period_end
     );
    hr_utility.trace('out: ' || l_procedure_name) ;
--     exception
--     when others then
    end leave_net_entitlement;

    procedure leave_net_accrual
     (p_assignment_id        IN    NUMBER
    ,p_payroll_id           IN    NUMBER
    ,p_business_group_id    IN    NUMBER
    ,p_plan_id              IN    NUMBER
    ,p_calculation_date     IN    DATE
    ,p_net_accrual          OUT  NOCOPY  NUMBER
    ,p_net_entitlement      OUT  NOCOPY  NUMBER
    ,p_calc_start_date      OUT  NOCOPY  DATE
    ,p_last_accrual         OUT  NOCOPY  DATE
    ,p_next_period_end      OUT  NOCOPY  DATE) is
    l_procedure_name                varchar2(61) ;
l_get_accrual_value number ;
  begin

    l_procedure_name          := 'pay_au_leave_liability.leave_net_accrual' ;

    hr_utility.trace('In: ' || l_procedure_name) ;
    l_get_accrual_value :=
     hr_au_holidays.get_accrual_entitlement
    (p_assignment_id
    ,p_payroll_id
    ,p_business_group_id
    ,p_plan_id
    ,p_calculation_date
    ,p_net_accrual
    ,p_net_entitlement
    ,p_calc_start_date
    ,p_last_accrual
    ,p_next_period_end      )   ;

    hr_utility.trace('out: ' || l_procedure_name) ;
 exception
     when others then
     hr_utility.trace('exception: ' || l_procedure_name) ;
    end leave_net_accrual;

   /*---------------------------------------------------------------------
              Name    : get_weekdays_in_period
              Purpose : To get the number of weekdays in a date range
              Returns : Number of Weekdays if successful, NULL otherwise
    ---------------------------------------------------------------------*/

FUNCTION get_weekdays_in_period
    (p_start_date          IN DATE
    ,p_end_date            IN DATE)
RETURN NUMBER IS
    l_proc      VARCHAR2(72);

    l_day_count NUMBER := 0;
    l_day       DATE;
  BEGIN
    l_proc      := 'get_weekdays_in_period';

    hr_utility.trace('In: '||l_proc);
    hr_utility.trace('  p_start_date: ' || to_char(p_start_date,'dd Mon yyyy')) ;
    hr_utility.trace('  p_end_date: ' || to_char(p_end_date,'dd Mon yyyy')) ;


    IF (p_start_date > p_end_date)
    THEN
        hr_utility.trace('Crash Out: '||l_proc);
        hr_utility.set_message(801,'HR_AU_INVALID_DATE_RANGE');
        hr_utility.raise_error;
    END IF;

    hr_utility.set_location(l_proc,5);
    l_day := p_start_date;
    WHILE (l_day <= p_end_date)
    LOOP
        IF (TO_CHAR(l_day,'DY') IN ('MON','TUE','WED','THU','FRI'))
        THEN
            l_day_count := l_day_count + 1;
        END IF;
        l_day := l_day + 1;
    END LOOP;
    hr_utility.trace('  return: ' || to_char(l_day_count)) ;
    hr_utility.trace('Out: '||l_proc);
    RETURN l_day_count;

  END get_weekdays_in_period;





end pay_au_leave_liability ;

/
