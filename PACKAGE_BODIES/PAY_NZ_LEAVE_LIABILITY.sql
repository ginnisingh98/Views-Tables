--------------------------------------------------------
--  DDL for Package Body PAY_NZ_LEAVE_LIABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_LEAVE_LIABILITY" as
  --  $Header: pynzllal.pkb 115.6 2002/12/03 05:20:43 srrajago ship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create NZ HRMS leave liability package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+------------------------------------------
  --  28 Feb 2000 JTurner            Renamed objects to use country identifier
  --                                 of "AU" instead of "NZ"
  --  29 NOV 1999 JTURNER  N/A       Created
  --  29 sep 2000 rayyadev           bug no 1420851
  --  30 JUL 2001 rbsinha  1422001   Added function retrieve_variable
  --  28 AUG 2002 vgsriniv 2514562   Added code to initialise context parameter
  --                                 to a default value.Also added dbdrv command
  --  03 DEC 2002 srrajago 2689221   Included 'nocopy' option for the 'out'
  --                                 parameters of all the procedures.
  -----------------------------------------------------------------------------
  --  range_code procedure
  --
  --  public procedure required by the Payroll Archive Reporter (PAR) process
  -----------------------------------------------------------------------------

  procedure range_code
  (p_payroll_action_id  in     number
  ,p_sql                out nocopy varchar2) is

    l_sql                           varchar2(4000) ;
    l_procedure_name                varchar2(61) := 'pay_nz_leave_liability.range_code' ;

  begin
--    hr_utility.trace_on(null,'ll_archive') ;
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
                'and ap.accrual_category = ''NZAL'' '                       ||
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
    l_procedure_name                varchar2(61) := 'pay_nz_leave_liability.assignment_action_code' ;

    --  The PAR process can multi-thread this procedure so make
    --  sure that the cursor only deals with assignments in this
    --  thread.  The p_start_person_id and p_end_person_id parameters
    --  to the procedure identify the set of people in this thread.

    --  The cursor identifies assignments that are enrolled in
    --  accrual plans that have an accrual category of 'NZAL'.

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
      and    ap.accrual_category = 'NZAL'
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

    l_procedure_name                varchar2(61) := 'pay_nz_leave_liability.initialization_code' ;

  begin

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

    l_procedure_name                varchar2(61) := 'pay_nz_leave_liability.archive_code' ;
    l_process_id                    pay_au_processes.process_id%type ;
    l_gcc_parameters_store          pay_au_generic_code_caller.t_variable_store_tab ;
    l_business_group_id             pay_payroll_actions.business_group_id%type ;
    l_assignment_id                 pay_assignment_actions.assignment_id%type ;
    l_payroll_action_id             pay_payroll_actions.payroll_action_id%type ;
    l_counter                       integer := 1 ;

    cursor c_process(p_short_name varchar2) is
      select p.process_id
      from   pay_au_processes p
      where  p.short_name = p_short_name
      and    p.legislation_code = 'NZ' ;

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
      and    ap.accrual_category = 'NZAL'
      and    pa.effective_date between a.effective_start_date
                                   and a.effective_end_date
      and    pa.effective_date between ee.effective_start_date
                                   and ee.effective_end_date
      and    pa.effective_date between el.effective_start_date
                                   and el.effective_end_date ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;

    --  find out the generic code caller process ID for
    --  NZ leave liability

    open c_process('PYNZLLAL') ;
    fetch c_process
      into l_process_id ;
    close c_process ;

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

     /* Bug 2514562 Initialised context parameter element entry id to a
        default value -1  */
      l_gcc_parameters_store(7).name := 'ELEMENT_ENTRY_ID' ;
      l_gcc_parameters_store(7).data_type := 'NUMBER' ;
      l_gcc_parameters_store(7).value := '-1' ;


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
  --  procedure function that gets called as part of the NZ Leave Liability
  --  process.  Note that this procedure can only be called from the
  --  generic code caller as it relies on data structures that have been
  --  set up by the generic code caller.
  -----------------------------------------------------------------------------

  procedure hourly_rate is

    l_hourly_rate_formula_const     constant ff_formulas_f.formula_name%type := 'HOURLY_RATE_FORMULA' ;

    l_procedure_name                varchar2(61) := 'pay_nz_leave_liability.hourly_rate' ;
    l_hourly_rate                   number := null ;
    l_business_group_id             pay_au_modules.business_group_id%type ;
    l_legislation_code              pay_au_modules.legislation_code%type ;
    l_formula_name                  ff_formulas_f.formula_name%type ;

    e_bad_module                    exception ;
    e_bad_hourly_rate               exception ;

    procedure execute_formula(p_formula_name varchar2) is

      l_procedure_name                varchar2(61) := 'execute_formula' ;
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

    end execute_formula ;

  begin

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
    when e_bad_module
    then
      hr_utility.set_message(801, 'HR_NZ_INVALID_MODULE') ;
      hr_utility.raise_error ;
    when e_bad_hourly_rate
    then
      hr_utility.set_message(801, 'HR_NZ_BAD_HOURLY_RATE') ;
      hr_utility.raise_error ;

  end hourly_rate ;


   procedure leave_net_accrual
     (p_assignment_id        IN    NUMBER
    ,p_payroll_id           IN    NUMBER
    ,p_business_group_id    IN    NUMBER
    ,p_plan_id              IN    NUMBER
    ,p_calculation_date     IN    DATE
    ,p_net_accrual          OUT NOCOPY NUMBER
    ,p_net_entitlement      OUT NOCOPY NUMBER
    ,p_calc_start_date      OUT NOCOPY DATE
    ,p_last_accrual         OUT NOCOPY DATE
    ,p_next_period_end      OUT NOCOPY DATE) is
    l_procedure_name                varchar2(61) := 'pay_nz_leave_liability.leave_net_accrual' ;
l_get_accrual_value number ;
  begin

    hr_utility.trace('In: ' || l_procedure_name) ;
    l_get_accrual_value :=
     hr_nz_holidays.get_accrual_entitlement
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


function retrieve_variable(P_NAME IN VARCHAR2,
                           P_DATA_TYPE IN VARCHAR2) return varchar2 is

l_value varchar2(200);

begin

  pay_au_generic_code_caller.retrieve_variable(P_NAME,P_DATA_TYPE,l_value);

  return l_value ;

end retrieve_variable;


end pay_nz_leave_liability ;

/
