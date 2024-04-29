--------------------------------------------------------
--  DDL for Package Body PAY_US_PTO_CO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_PTO_CO_PKG" as
/* $Header: pyuspaco.pkb 120.1.12010000.2 2008/08/06 08:35:10 ubhat ship $ */

  --
  -- Package (private) constants.
  --
   LOGGING    CONSTANT pay_action_parameters.parameter_name%TYPE := 'LOGGING';
  MAX_ERRORS CONSTANT pay_action_parameters.parameter_name%TYPE := 'MAX_ERRORS_ALLOWED';
  NEWLINE    CONSTANT VARCHAR2(10) := fnd_global.newline;
  TAB        CONSTANT VARCHAR2(30) := fnd_global.tab;

  --
  -- Package variables.
  --
  g_debug          BOOLEAN := hr_utility.debug_enabled;
  g_conc_req_debug BOOLEAN;
  g_max_errors     NUMBER;
  g_plan_status    NUMBER;

PROCEDURE initialize_logging
    (p_action_parameter_group_id IN NUMBER)
IS

    --
    -- Gets an action parameter value.
    --
    CURSOR csr_get_action_param
        (p_parameter_name IN VARCHAR2) IS
    SELECT pap.parameter_value
    FROM   pay_action_parameters pap
    WHERE  pap.parameter_name = p_parameter_name;

    l_logging    pay_action_parameters.parameter_value%TYPE;
    l_max_errors pay_action_parameters.parameter_value%TYPE;
    l_string     VARCHAR2(500);

BEGIN

    --
    -- Reset the package globals.
    --
    g_errbuf         := NULL;
    g_retcode        := SUCCESS;
    g_conc_req_debug := NULL;
    g_max_errors     := 0;

    --
    -- If the action parameter ID is passed in, the action param group
    -- is set.  Native dynamic PL/SQL is used to eliminate the
    -- the dependency on the pay package procedure.
    --
    IF p_action_parameter_group_id IS NOT NULL THEN

        l_string :=
            'BEGIN
                 pay_core_utils.set_pap_group_id(p_pap_group_id => ' ||
                     to_char(p_action_parameter_group_id) || ');
             END;';

        EXECUTE IMMEDIATE l_string;

    END IF;

    --
    -- Fetch the action parameter values.
    --
    OPEN  csr_get_action_param (LOGGING);
    FETCH csr_get_action_param INTO l_logging;
    CLOSE csr_get_action_param;

    --
    -- If logging is set to General, enable debugging.
    --
    IF instr(NVL(l_logging, 'N'), 'G') <> 0 THEN
        g_conc_req_debug := TRUE;
    END IF;

    IF g_conc_req_debug IS NULL THEN
        g_conc_req_debug := FALSE;
    END IF;

    --
    -- Set the max number of errors allowed.
    --
    OPEN  csr_get_action_param (MAX_ERRORS);
    FETCH csr_get_action_param INTO l_max_errors;
    CLOSE csr_get_action_param;

    g_max_errors := NVL(to_number(l_max_errors), 0);

END initialize_logging;

PROCEDURE write_log
    (p_text IN VARCHAR2
    ,p_type IN NUMBER)
IS

BEGIN

    --
    -- Output the PYUPIP.
    --
    IF g_debug THEN
        hr_utility.trace(p_text);
    END IF;

    --
    -- Exit immediately if processing a debug line and SRS debugging is disabled.
    --
    IF p_type = DEBUG AND NOT g_conc_req_debug THEN
        RETURN;
    END IF;

    --
    -- Write to the concurrent request log.
    --
    fnd_file.put_line(FND_FILE.log, p_text);

END write_log;

PROCEDURE carry_over (ERRBUF           OUT NOCOPY varchar2,
                      RETCODE          OUT NOCOPY number,
                      p_calculation_date          varchar2,
                      p_business_group_id         number,
                      p_plan_id                   number,
                      p_plan_category             varchar2,
                      p_mode                      varchar2,
                      p_accrual_term              varchar2,
                      p_action_parameter_group_id number)
IS

  CURSOR csr_accrual_plan (P_category varchar2,
                           P_date     date ) is
  select pap.accrual_plan_id              accrual_plan_id,
         pap.accrual_plan_name            accrual_plan_name,
	 pap.co_formula_id                co_formula_id,
         pap.accrual_plan_element_type_id accrual_plan_element_type_id,
         pap.co_input_value_id            co_input_value_id,
         pap.residual_input_value_id      residual_input_value_id,
	 pap.co_date_input_value_id       co_date_input_value_id,
	 pap.co_exp_date_input_value_id   co_exp_date_input_value_id,
         pap.residual_date_input_value_id residual_date_input_value_id,
         piv1.element_type_id             co_element_type_id,
         piv2.element_type_id             residual_element_type_id
  from   pay_accrual_plans     pap,
         pay_input_values_f    piv1,
         pay_input_values_f    piv2
  where (pap.accrual_plan_id = nvl(p_plan_id, -1) OR
         pap.accrual_category like p_category)
  and    pap.business_group_id       = p_business_group_id
  and    piv1.input_value_id         = pap.CO_INPUT_VALUE_ID
  and    P_date between piv1.effective_start_date and
                        piv1.effective_end_date
  and    piv2.input_value_id         = pap.RESIDUAL_INPUT_VALUE_ID
  and    P_date between piv2.effective_start_date and
                        piv2.effective_end_date;
  --
  -- Local variables
  --

  l_proc    varchar2(80) := 'pay_us_pto_co_pkg.carry_over';
  l_plan_category varchar2(30) := p_plan_category;
  l_count         number       := 0;
  l_message_count number       := 0;
  l_message       varchar2(256);
  l_session_date  date;
  l_calculation_date date;

-- Bug no 2932073 And 2878657
-- added local Variable to hold the ligislation code.

  l_legislation_code   hr_organization_information.org_information9%TYPE;

-- Cursor for selecting the Legislation code

  cursor c_legislation_code (p_bg_id number) is
  select hoi.org_information9
    from hr_all_organization_units org
       , hr_organization_information hoi
   where hoi.organization_id = org.business_group_id
     and hoi.org_information_context = 'Business Group Information'
     and org.business_group_id = p_bg_id;

  /*End 2878657 And 2932073*/


BEGIN

  initialize_logging
     (p_action_parameter_group_id => p_action_parameter_group_id);
  --
  -- Fix for bug 3434710 starts here.
  -- As this procedure is called from concurrent request, a row in fnd_session
  -- should be inserted sothat the fastformula databse item SQL's which are having joins
  -- to fnd_sessions would not fail.
  --
  dt_fndate.set_effective_date
  (p_effective_date         => trunc(sysdate)
  ,p_do_commit              => true
  ) ;
  --
  -- Fix for bug 3434710 ends here.
  --
  -- Pipe the parameters for ease of debugging.
  --
  write_log(' ', DEBUG);
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' ENTERING '||upper(l_proc), DEBUG);
  write_log(' --------------------------------'||
            '+--------------------------------', DEBUG);
  write_log('  p_calculation_date               '||
               p_calculation_date, DEBUG);
  write_log('  p_business_group_id              '||
               to_char(p_business_group_id), DEBUG);
  write_log('  p_plan_id                        '||
               to_char(p_plan_id), DEBUG);
  write_log('  p_plan_category                  '||
               p_plan_category, DEBUG);
  write_log('  p_mode                           '||
               p_mode, DEBUG);
  write_log('  p_accrual_term                   '||
               p_accrual_term, DEBUG);
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' ', DEBUG);

  per_accrual_message_pkg.clear_table;

  begin
    select effective_date into l_session_date
    from fnd_sessions
    where session_id = userenv('sessionid');
  exception
    when others then
      select sysdate into l_session_date
      from dual;
  end;

  write_log('l_session_date: '||to_char(l_session_date), DEBUG);

  l_calculation_date := trunc(fnd_date.canonical_to_date(p_calculation_date));

  write_log('l_calculation_date: '||to_char(l_calculation_date), DEBUG);
  --
  -- If no plan parameters are passed, process all plans.
  -- If a specific plan name is passed, ignore the
  -- accrual category parameter
  --

  IF p_plan_id is null and p_plan_category is null THEN
  --
    l_plan_category := '%%';
  --
  ELSIF p_plan_id is not null THEN
  --
    l_plan_category := null;
  --
  END IF;

  write_log('l_plan_category: '||l_plan_category, DEBUG);

-- Bug no 2932073 And 2878657
      -- Get the Legislation of the Business Group
    open c_legislation_code (p_business_group_id);
    fetch c_legislation_code into l_legislation_code;
    close c_legislation_code;

  write_log('l_legislation_code: '||l_legislation_code, DEBUG);
--End Bug no 2932073 And 2878657
  FOR l_accrual_plan IN csr_accrual_plan(l_plan_category, l_calculation_date) LOOP

    --
    -- Set this plan's flag to "successful" by default.  If an error occurs
    -- during assignment processing this global variable will be set
    -- to an error status as appropriate.
    --
    g_plan_status := SUCCESS;

    l_count := l_count + 1;

    write_log(NEWLINE);
    write_log('Processing Plan ' || l_accrual_plan.accrual_plan_name||
              ' (' || to_char(l_accrual_plan.accrual_plan_id) || ')...');

    --
    -- Loop for each Accrual Plan in the Carry Over process.
    --
    pay_us_pto_co_pkg.pto_carry_over_for_plan(
         p_plan_id                    => l_accrual_plan.accrual_plan_id,
         p_co_formula_id              => l_accrual_plan.co_formula_id,
         P_plan_ele_type_id           => l_accrual_plan.accrual_plan_element_type_id,
         P_co_ele_type_id             => l_accrual_plan.co_element_type_id,
         P_co_input_val_id            => l_accrual_plan.co_input_value_id,
         P_co_date_input_value_id     => l_accrual_plan.co_date_input_value_id,
         P_co_exp_date_input_value_id => l_accrual_plan.co_exp_date_input_value_id,
         P_res_ele_type_id            => l_accrual_plan.residual_element_type_id,
         P_res_input_val_id           => l_accrual_plan.residual_input_value_id,
         P_res_date_input_value_id    => l_accrual_plan.residual_date_input_value_id,
         p_business_group_id          => p_business_group_id,
         P_Calculation_date           => l_calculation_date,
         P_co_mode                    => p_mode,
         p_accrual_term               => p_accrual_term,
         p_session_date               => l_session_date,
	 p_legislation_code	      => l_legislation_code
         );
/*added p_Legislation_code	      => l_legislation_code
for bug no 2932073 and 2878657  */
    --
    -- Write the status of processing this plan to the log.
    --
    IF g_plan_status = SUCCESS THEN
      write_log(l_accrual_plan.accrual_plan_name||' processed successfully.');
    ELSIF g_plan_status = WARNING THEN
      write_log(l_accrual_plan.accrual_plan_name||' processed with '||
                'one or more errors.');
    ELSIF g_plan_status = ERROR THEN
      write_log(l_accrual_plan.accrual_plan_name||' encountered too '||
                'many errors.  Processing was aborted.');
    END IF;

  END LOOP;

  write_log(l_proc||', 30', DEBUG);

  l_message_count := per_accrual_message_pkg.count_messages;
  for i in 1..l_message_count loop
  --
    l_message := per_accrual_message_pkg.get_message(i);
    write_log(l_message, DEBUG);
  --
  end loop;

  write_log(l_proc||', 35', DEBUG);

  --
  -- If no plans were found, error
  --
  if l_count = 0 then

    write_log(l_proc||', 40', DEBUG);
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','US_PTO_CARRY_OVER');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;

  end if;

  --
  -- Set the concurrent request completion status.
  --
  ERRBUF := g_errbuf;
  RETCODE:= g_retcode;
  write_log(NEWLINE);

  --
  -- Pipe the parameters for ease of debugging.
  --
  write_log(' ', DEBUG);
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' LEAVING '||upper(l_proc), DEBUG);
  write_log(' --------------------------------'||
            '+--------------------------------', DEBUG);
  write_log('  errbuf                           '||
               errbuf, DEBUG);
  write_log('  retcode                          '||
               to_char(retcode), DEBUG);
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' ', DEBUG);

END carry_over;
--
------------------------- pto_carry_over_for_plan ---------------------------
procedure pto_carry_over_for_plan
     (p_plan_id                    number,
      p_co_formula_id              number,
      P_plan_ele_type_id           number,
      P_co_ele_type_id             number,
      P_co_input_val_id            number,
      P_co_date_input_value_id     number,
      P_co_exp_date_input_value_id number,
      P_res_ele_type_id            number,
      P_res_input_val_id           number,
      P_res_date_input_value_id    number,
      P_business_group_id          number,
      P_Calculation_date           date,
      P_co_mode                    varchar2,
      p_accrual_term               varchar2,
      p_session_date               date,
      p_legislation_code           Varchar2
      ) is

  --
  -- The following cursor is designed to fetch all assignments enrolled onto
  -- the given accrual plan. Because we do not know at this stage what the
  -- effective co date will be (it may be calculated at a per assignment level),
  -- we simply retrieve all distinct assigments from enrollments effective as at the
  -- calculation date.  We only get future assignments if the accrual term is
  -- PTO_CURRENT because we may be carrying over ahead of the calculation date.
  --
  -- This cursor is tuned as part of performance bug fix 3420490.
  cursor csr_get_assignment is
  select distinct pee.assignment_id assignment_id, asg.assignment_number
   from  pay_element_entries_f pee,
         pay_element_links_f   pel,
         per_all_assignments_f asg
  where  pee.element_type_id = p_plan_ele_type_id
    and  pee.element_type_id = pel.element_type_id
    and  pee.element_link_id = pel.element_link_id
    and  pee.assignment_id   = asg.assignment_id
    and  asg.period_of_service_id is not null
    and  (p_accrual_term = 'PTO_CURRENT' or
         (p_accrual_term = 'PTO_PREVIOUS' and
          asg.effective_start_date < p_calculation_date));

  l_proc         varchar2(80) := 'pay_us_pto_co_pkg.pto_carry_over_for_plan';
  l_accrual_term varchar2(30);
  l_num_errors   number := 0;

BEGIN

  --
  -- Pipe the parameters for ease of debugging.
  --
  write_log(' ', DEBUG);
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' ENTERING '||upper(l_proc), DEBUG);
  write_log(' for plan '||to_char(p_plan_id), DEBUG);
  write_log(' --------------------------------'||
            '+--------------------------------', DEBUG);
  write_log('  p_plan_id                        '||
               to_char(p_plan_id), DEBUG);
  write_log('  p_co_formula_id                  '||
               to_char(p_co_formula_id), DEBUG);
  write_log('  p_plan_ele_type_id               '||
               to_char(p_plan_ele_type_id), DEBUG);
  write_log('  p_co_ele_type_id                 '||
               to_char(p_co_ele_type_id), DEBUG);
  write_log('  p_co_input_val_id                '||
               to_char(p_co_input_val_id), DEBUG);
  write_log('  p_co_date_input_value_id         '||
               to_char(p_co_date_input_value_id), DEBUG);
  write_log('  p_co_exp_date_input_value_id     '||
               to_char(p_co_exp_date_input_value_id), DEBUG);
  write_log('  p_res_ele_type_id                '||
               to_char(p_res_ele_type_id), DEBUG);
  write_log('  p_res_input_val_id               '||
               to_char(p_res_input_val_id), DEBUG);
  write_log('  p_res_date_input_value_id        '||
               to_char(p_res_date_input_value_id), DEBUG);
  write_log('  p_business_group_id              '||
               to_char(p_business_group_id), DEBUG);
  write_log('  p_calculation_date               '||
               to_char(p_calculation_date), DEBUG);
  write_log('  p_co_mode                        '||
               p_co_mode, DEBUG);
  write_log('  p_accrual_term                   '||
               p_accrual_term, DEBUG);
  write_log('  p_session_date                   '||
               to_char(p_session_date), DEBUG);

/*start bug no 2932073 and  2878657 */
  write_log('  p_legislation_code               '||
               p_legislation_code, DEBUG);

/*start bug no 2932073 and 2878657 */
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' ', DEBUG);

  if p_accrual_term = 'PTO_CURRENT' then
    l_accrual_term := 'CURRENT';
  else
    l_accrual_term := 'PREVIOUS';
  end if;

  write_log('l_accrual_term: '||l_accrual_term, DEBUG);

  FOR l_asg IN csr_get_assignment LOOP

    BEGIN

      pay_us_pto_co_pkg.pto_carry_over_for_asg(
        p_plan_id                    => p_plan_id
       ,p_assignment_id              => l_asg.assignment_id
       ,p_co_formula_id              => p_co_formula_id
       ,p_plan_ele_type_id           => p_plan_ele_type_id
       ,p_co_ele_type_id             => p_co_ele_type_id
       ,p_co_input_val_id            => p_co_input_val_id
       ,p_co_date_input_value_id     => p_co_date_input_value_id
       ,p_co_exp_date_input_value_id => p_co_exp_date_input_value_id
       ,p_res_ele_type_id            => p_res_ele_type_id
       ,p_res_input_val_id           => p_res_input_val_id
       ,p_res_date_input_value_id    => p_res_date_input_value_id
       ,p_business_group_id          => p_business_group_id
       ,p_calculation_date           => p_calculation_date
       ,p_co_mode                    => p_co_mode
       ,p_accrual_term               => l_accrual_term
       ,p_session_date               => p_session_date
       ,p_legislation_code           => p_legislation_code
      );
/*added p_Legislation_code	      => l_legislation_code
for bug no 2932073 and 2878657  */


      write_log('    Processing Assignment '||l_asg.assignment_number||
                ' ('||to_char(l_asg.assignment_id)||')... successful.');

    EXCEPTION

      WHEN others THEN

        --
        -- Trap any errors that occur.  Initially raise these as a warning.
        --
        g_plan_status := WARNING;
        g_retcode     := WARNING;
        g_errbuf      := 'An error occurred during the processing of one or more '||
                         'assignments.';
        l_num_errors  := l_num_errors + 1;

        write_log('    Processing Assignment '||l_asg.assignment_number||
                  ' ('||to_char(l_asg.assignment_id)||')... failed.');
        write_log(SQLERRM);

        --
        -- If the max number of errors has been exceeded, raise the error and
        -- terminate processing of this plan.
        --
        IF l_num_errors > g_max_errors THEN

          g_plan_status := ERROR;
          g_retcode     := ERROR;
          g_errbuf      := 'The number of assignments that errored is greater '||
                           'than the maximum number of errors allowed.';

          RETURN;

        END IF;

      END;

  END LOOP;

  write_log('Leaving: '||l_proc||', 20', DEBUG);

END pto_carry_over_for_plan;

------------------------- pto_carry_over_for_asg ---------------------------
procedure pto_carry_over_for_asg
    ( p_plan_id                    number,
      p_assignment_id              number,
      p_co_formula_id              number,
      p_plan_ele_type_id           number,
      p_co_ele_type_id             number,
      p_co_input_val_id            number,
      p_co_date_input_value_id     number,
      p_co_exp_date_input_value_id number,
      p_res_ele_type_id            number,
      p_res_input_val_id           number,
      p_res_date_input_value_id    number,
      p_business_group_id          number,
      p_calculation_date           date,
      p_co_mode                    varchar2,
      p_accrual_term               varchar2,
      p_session_date               date,
      p_legislation_code	   varchar2
      ) is

  --
  -- Cursor to check whether an assignment has already been
  -- processed for the current accrual term.
  --
  cursor csr_check_ee_exist (p_ele_link_id         number,
                             p_effective_date      date,
                             p_date_input_value_id number) is
  select pee.element_entry_id
  from   pay_element_entries_f      pee,
         pay_element_entry_values_f pev
  where  pee.assignment_id               = p_assignment_id
  and    pee.element_link_id             = p_ele_link_id
  and    pee.element_entry_id            = pev.element_entry_id
  and    pev.input_value_id              = p_date_input_value_id
  and    p_effective_date between pee.effective_start_date
                          and pee.effective_end_date;

  --
  -- Cursor to fetch payroll details for a given asg
  --
  cursor c_payroll_period
           (p_payroll_id  number,
            p_effective_date date) is
  select ptp.start_date,
         ptp.end_date
  from   per_time_periods ptp
  where  ptp.payroll_id = p_payroll_id
  and    p_effective_date between ptp.start_date
  and    ptp.end_date;


  --
  -- Cursor to get the first effective start date of the assignment
  -- so that assignments starting mid payroll period can be
  -- evaluated.
  --
  cursor c_get_asg_start_date is
  select min(asg.effective_start_date)
  from   per_all_assignments_f asg
  where  asg.assignment_id = p_assignment_id
  and    asg.period_of_service_id is not null;

  --
  -- Cursor to get the last effective end date of the assignment
  -- so that terminated assignments can be evaluated.
  --
  cursor c_get_asg_end_date is
  select max(asg.effective_end_date)
  from   per_all_assignments_f asg
  where  asg.assignment_id = p_assignment_id
  and    asg.period_of_service_id is not null;

  --
  -- Gets the payroll_id of the assignment at the effective date.
  -- If there is no payroll on the assignment at the effective
  -- date, check for terminated assigments. If the accrual term is
  -- 'CURRENT', we also need to consider future assignments.
  --
  cursor c_payroll_id (p_effective_date date) is
  select asg.payroll_id
  from   per_all_assignments_f asg
  where  asg.assignment_id = p_assignment_id
  and    asg.period_of_service_id is not null
  and    asg.payroll_id is not null
  and  ((p_effective_date between
         asg.effective_start_date and asg.effective_end_date)
   or   (asg.effective_end_date < p_effective_date
         and asg.effective_end_date =
                (select max(asg2.effective_end_date)
                 from   per_all_assignments_f asg2
                 where  asg2.assignment_id = asg.assignment_id
                 and    asg2.period_of_service_id is not null
                 and    asg2.payroll_id is not null))
   or   (p_accrual_term = 'CURRENT'
         and asg.effective_start_date > p_effective_date
         and asg.effective_start_date =
                (select min(asg3.effective_start_date)
                 from   per_all_assignments_f asg3
                 where  asg3.assignment_id = asg.assignment_id
                 and    asg3.period_of_service_id is not null
                 and    asg3.payroll_id is not null)));

  --
  -- Local Variables
  --
  l_proc  varchar2(80) := 'pay_us_pto_co_pkg.pto_carry_over_for_asg';
  l_co_link_id         number := null;
  l_res_link_id        number := null;
  l_max_carryover      number;
  l_effective_date     date;
  l_expiry_date        date;
  l_carryover          number;
  l_residual           number;
  l_total_accrual      number;
  l_net_entitlement    number;
  l_payroll_id         number;
  l_co_ele_entry_id    number := 0;
  l_res_ele_entry_id   number := 0;
  l_dummy1             date;
  l_dummy2             date;
  l_dummy3             date;
  l_start_date         date;
  l_end_date           date;
  l_min_asg_start_date date;
  l_max_asg_end_date   date;
  l_new_ee_id          number;
  l_temp_payroll_id    number;
  l_enrolled           boolean := true;



  -- Declare tables for input value ids and Screen Entry Values

  inp_value_id_tbl hr_entry.number_table;
  scr_valuetbl     hr_entry.varchar2_table;

BEGIN

  --
  -- Pipe the parameters for ease of debugging.
  --
  write_log(' ', DEBUG);
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' ENTERING '||upper(l_proc), DEBUG);
  write_log(' for assignment '||to_char(p_assignment_id), DEBUG);
  write_log(' --------------------------------'||
            '+--------------------------------', DEBUG);
  write_log('  p_plan_id                        '||
               to_char(p_plan_id), DEBUG);
  write_log('  p_assignment_id                  '||
               to_char(p_assignment_id), DEBUG);
  write_log('  p_co_formula_id                  '||
               to_char(p_co_formula_id), DEBUG);
  write_log('  p_plan_ele_type_id               '||
               to_char(p_plan_ele_type_id), DEBUG);
  write_log('  p_co_ele_type_id                 '||
               to_char(p_co_ele_type_id), DEBUG);
  write_log('  p_co_input_val_id                '||
               to_char(p_co_input_val_id), DEBUG);
  write_log('  p_co_date_input_value_id         '||
               to_char(p_co_date_input_value_id), DEBUG);
  write_log('  p_co_exp_date_input_value_id     '||
               to_char(p_co_exp_date_input_value_id), DEBUG);
  write_log('  p_res_ele_type_id                '||
               to_char(p_res_ele_type_id), DEBUG);
  write_log('  p_res_input_val_id               '||
               to_char(p_res_input_val_id), DEBUG);
  write_log('  p_res_date_input_value_id        '||
               to_char(p_res_date_input_value_id), DEBUG);
  write_log('  p_business_group_id              '||
               to_char(p_business_group_id), DEBUG);
  write_log('  p_calculation_date               '||
               to_char(p_calculation_date), DEBUG);
  write_log('  p_co_mode                        '||
               p_co_mode, DEBUG);
  write_log('  p_accrual_term                   '||
               p_accrual_term, DEBUG);
  write_log('  p_session_date                   '||
               to_char(p_session_date), DEBUG);

/*start bug no 2932073 and  2878657 */
  write_log('  p_legislation_code               '||
               p_legislation_code, DEBUG);

/*start bug no 2932073 and 2878657 */
  write_log(' --------------------------------'||
            '---------------------------------', DEBUG);
  write_log(' ', DEBUG);

  --
  -- Get the persons payroll_id.
  --
  open c_payroll_id(p_effective_date => p_calculation_date);
  fetch c_payroll_id into l_payroll_id;
  close c_payroll_id;

  write_log('1st l_payroll_id: '||to_char(l_payroll_id), DEBUG);

  --
  -- We retrieve the max co and effective date here, so that
  -- the exact effective date can be used immediately, rather
  -- than the calculation date entered by the user
  --
  per_accrual_calc_functions.get_carry_over_values (
     p_assignment_id     => p_assignment_id,
     p_co_formula_id     => p_co_formula_id,
     p_accrual_plan_id   => p_plan_id,
     p_business_group_id => p_business_group_id,
     p_payroll_id        => l_payroll_id,
     p_calculation_date  => p_calculation_date,
     p_session_date      => p_session_date,
     p_accrual_term      => p_accrual_term,
     p_max_carry_over    => l_max_carryover,
     p_effective_date    => l_effective_date,
     p_expiry_date       => l_expiry_date
    );

  write_log('p_max_carry_over: '||to_char(l_max_carryover), DEBUG);
  write_log('p_effective_date: '||to_char(l_effective_date), DEBUG);
  write_log('p_expiry_date: '||to_char(l_expiry_date), DEBUG);

  if l_max_carryover is not null then
    --
    --
    -- Get the persons payroll_id, effective at the time of
    -- carry over.
    --
    write_log(l_proc||', 30', DEBUG);
    open  c_payroll_id(p_effective_date => l_effective_date);
    fetch c_payroll_id into l_temp_payroll_id;
    close c_payroll_id;

    l_payroll_id := nvl(l_temp_payroll_id, l_payroll_id);

    write_log('2nd l_payroll_id: '||to_char(l_payroll_id), DEBUG);

    --
    -- Get the links for the co and residual elements
    --
    write_log(l_proc||', 35', DEBUG);

    l_co_link_id := hr_entry_api.get_link(
                       p_assignment_id   => p_assignment_id,
                       p_element_type_id => p_co_ele_type_id,
                       p_session_date    => l_effective_date + 1);

    write_log('l_co_link_id: '||to_char(l_co_link_id), DEBUG);

    l_res_link_id := hr_entry_api.get_link(
                       p_assignment_id   => p_assignment_id,
                       p_element_type_id => p_res_ele_type_id,
                       p_session_date    => l_effective_date + 1);

    write_log('l_res_link_id: '||to_char(l_res_link_id), DEBUG);

    l_enrolled := per_accrual_calc_functions.check_assignment_enrollment(
                      p_assignment_id => p_assignment_id,
                      p_accrual_plan_element_type_id => p_plan_ele_type_id,
                      p_calculation_date => l_effective_date + 1);

      if l_enrolled then
        write_log('l_enrolled: TRUE', DEBUG);
      else
        write_log('l_enrolled: FALSE', DEBUG);
      end if;

  end if;

  --
  -- Only proceed with this asg if links exist for both elements.
  --

  write_log(l_proc||', 55', DEBUG);

  IF l_co_link_id  is not null AND
     l_res_link_id is not null AND
     l_enrolled AND
     l_max_carryover is not null THEN

   write_log(l_proc||', 60', DEBUG);

    per_accrual_calc_functions.Get_Net_Accrual (
      P_Assignment_ID          => p_assignment_id
     ,P_Plan_ID                => p_plan_id
     ,P_Payroll_ID             => l_payroll_id
     ,P_Business_Group_ID      => p_business_group_id
     ,P_Assignment_Action_Id   => -1
     ,P_Accrual_Start_Date     => null
     ,P_Accrual_Latest_Balance => null
     ,P_Calculation_Date       => l_effective_date
     ,P_Start_Date             => l_dummy1
     ,P_End_Date               => l_dummy2
     ,P_Accrual_End_Date       => l_dummy3
     ,P_Accrual                => l_total_accrual
     ,P_Net_Entitlement        => l_net_entitlement
    );

    write_log('l_total_accrual: '||to_char(l_total_accrual), DEBUG);
    write_log('l_net_entitlement: '||to_char(l_net_entitlement), DEBUG);

 /*Added for 2878657 And 2932073 */



    if p_legislation_code = 'ZA' then

	      write_log(l_proc||', 65', DEBUG);
	      PER_ZA_PTO_ACCRUAL_PERIOD.ZA_PTO_CARRYOVER_RESI_VALUE (
				   p_assignment_id       =>	p_assignment_id
				  ,p_plan_id		 =>	p_plan_id
				  ,l_payroll_id		 =>	l_payroll_id
				  ,p_business_group_id   =>	p_business_group_id
				  ,l_effective_date	 =>	l_effective_date
				  ,l_total_accrual	 =>	l_total_accrual
				  ,l_net_entitlement	 =>	l_net_entitlement
				  ,l_max_carryover	 =>	l_max_carryover
				  ,l_residual		 =>	l_residual
				  ,l_carryover		 => 	l_carryover
									);

    Else
	    if l_net_entitlement <= l_max_carryover then
	    --
	      write_log(l_proc||', 70', DEBUG);
	      l_carryover := round(l_net_entitlement, 3);
	      l_residual  := 0;
	    --
	    else
	    --
	      write_log(l_proc||', 75', DEBUG);
	      l_carryover := round(l_max_carryover, 3);
	      l_residual  := round((l_net_entitlement - l_max_carryover), 3);
	      --
	    end if;
   End if;

/* End of the 2932073 and  2878657 */
/* The below code was there before adding the abov code for the 2932073 */
   /*

   	    if l_net_entitlement <= l_max_carryover then
	    --
	      write_log(l_proc||', 70', DEBUG);
	      l_carryover := round(l_net_entitlement, 3);
	      l_residual  := 0;
	    --
	    else
	    --
	      write_log(l_proc||', 75', DEBUG);
	      l_carryover := round(l_max_carryover, 3);
	      l_residual  := round((l_net_entitlement - l_max_carryover), 3);
	      --
	    end if;

    */

    write_log('l_carryover: '||to_char(l_carryover), DEBUG);
    write_log('l_residual: '||to_char(l_residual), DEBUG);

    --
    -- We must get the payroll period start and end dates for
    -- the period in which the element entry will be made,
    -- as these are the effective start and end dates for all
    -- non-recurring element entries.
    --
    open  c_payroll_period(l_payroll_id,
                           l_effective_date + 1);
    fetch c_payroll_period into l_start_date,
                                l_end_date;
    close c_payroll_period;

    write_log('l_start_date: '||to_char(l_start_date), DEBUG);
    write_log('l_end_date: '||to_char(l_end_date), DEBUG);

    --
    -- Get the earliest assignment start date.
    --
    open  c_get_asg_start_date;
    fetch c_get_asg_start_date into l_min_asg_start_date;
    close c_get_asg_start_date;

    --
    -- Get the latest assignment end date.
    --
    open  c_get_asg_end_date;
    fetch c_get_asg_end_date into l_max_asg_end_date;
    close c_get_asg_end_date;

    write_log('l_min_asg_start_date: '||to_char(l_min_asg_start_date), DEBUG);
    write_log('l_max_asg_end_date: '||to_char(l_max_asg_end_date), DEBUG);

    If l_min_asg_start_date <= l_start_date
    and l_max_asg_end_date >= l_start_date then

    -- Modified the if condition for the bug 6969078
    -- Create the carryover element if the assignment
    -- is valid for atleast one day in the pay period
    -- rather than being valid for the whole pay period
    -- and l_max_asg_end_date >= l_end_date then
      --
      -- Proceed with the element entries.
      --
      -- Check whether a carry over element entry already exists
      -- for the given accrual plan, accrual term and assignment
      --
      write_log(l_proc||', 95', DEBUG);

      open  csr_check_ee_exist (l_co_link_id,
                                l_effective_date + 1,
                                p_co_date_input_value_id);

      fetch csr_check_ee_exist into l_co_ele_entry_id;

      write_log('l_co_ele_entry_id: '||to_char(l_co_ele_entry_id), DEBUG);

      if csr_check_ee_exist%NOTFOUND and l_carryover <> 0 then
        --
        -- Insert entry for Carried Over element
        --
        write_log(l_proc||', 100', DEBUG);

        inp_value_id_tbl(1) := p_co_date_input_value_id;
        scr_valuetbl(1)     := fnd_date.date_to_displaydate(l_effective_date + 1);

        inp_value_id_tbl(2) := p_co_input_val_id;
        scr_valuetbl(2)     := to_char(l_carryover);  -- Bug 4752106

        inp_value_id_tbl(3) := p_co_exp_date_input_value_id;
        scr_valuetbl(3)     := fnd_date.date_to_displaydate(l_expiry_date);

        write_log(l_proc||', 105', DEBUG);

        hr_entry_api.insert_element_entry(
           p_effective_start_date     => l_start_date,
           p_effective_end_date       => l_end_date,
           p_element_entry_id         => l_new_ee_id,
           p_assignment_id            => p_assignment_id,
           p_element_link_id          => l_co_link_id,
           p_creator_type             => 'F',
           p_entry_type               => 'E',
           p_num_entry_values         => 3,
           p_input_value_id_tbl       => inp_value_id_tbl,
           p_entry_value_tbl          => scr_valuetbl);

        write_log(l_proc||', 110', DEBUG);

      elsif csr_check_ee_exist%FOUND and p_co_mode = 'Y' THEN

        --
        -- Update element entry for CO element, using
        -- date track CORRECTION mode
        --
        write_log(l_proc||', 115', DEBUG);

        inp_value_id_tbl(1) := p_co_input_val_id;
        scr_valuetbl(1)     := to_char(l_carryover); -- Bug 4752106

        inp_value_id_tbl(2) := p_co_date_input_value_id;
        scr_valuetbl(2)     := fnd_date.date_to_displaydate(l_effective_date + 1);

        inp_value_id_tbl(3) := p_co_exp_date_input_value_id;
        scr_valuetbl(3)     := fnd_date.date_to_displaydate(l_expiry_date);

        hr_entry_api.update_element_entry(
           p_dt_update_mode           => 'CORRECTION',
           p_session_date             => l_start_date,
           p_element_entry_id         => l_co_ele_entry_id,
           p_num_entry_values         => 3,
           p_input_value_id_tbl       => inp_value_id_tbl,
           p_entry_value_tbl          => scr_valuetbl);

        write_log(l_proc||', 120', DEBUG);

      end if;

      close csr_check_ee_exist;

      write_log(l_proc||', 120', DEBUG);

      --
      -- Check whether a residual element entry already exists
      -- for the given accrual plan, accrual term and assignment
      --
      open  csr_check_ee_exist (l_res_link_id,
                                l_effective_date + 1,
                                p_res_date_input_value_id);

      fetch csr_check_ee_exist INTO l_res_ele_entry_id;

      write_log('l_res_ele_entry_id: '||to_char(l_res_ele_entry_id), DEBUG);

      IF csr_check_ee_exist%NOTFOUND and l_residual <> 0 then
        --
        -- Insert entry for Residual element
        --
        write_log(l_proc||', 130', DEBUG);

        inp_value_id_tbl(1) := p_res_input_val_id;
        scr_valuetbl(1)     := to_char(l_residual); -- Bug 4752106

        inp_value_id_tbl(2) := p_res_date_input_value_id;
        scr_valuetbl(2)     := fnd_date.date_to_displaydate(l_effective_date + 1);

        hr_entry_api.insert_element_entry(
            p_effective_start_date     => l_start_date,
            p_effective_end_date       => l_end_date,
            p_element_entry_id         => l_new_ee_id,
            p_assignment_id            => p_assignment_id,
            p_element_link_id          => l_res_link_id,
            p_creator_type             => 'F',
            p_entry_type               => 'E',
            p_num_entry_values         => 2,
            p_input_value_id_tbl       => inp_value_id_tbl,
            p_entry_value_tbl          => scr_valuetbl);

        write_log(l_proc||', 135', DEBUG);

      elsif csr_check_ee_exist%FOUND AND p_co_mode = 'Y' THEN
        --
        -- Update Element entry for Residual element, using
        -- date track CORRECTION mode.
        --
        write_log(l_proc||', 140', DEBUG);

        inp_value_id_tbl(1) := p_res_input_val_id;
        scr_valuetbl(1)     := to_char(l_residual); -- Bug 4752106

        inp_value_id_tbl(2) := P_res_date_input_value_id;
        scr_valuetbl(2)     := fnd_date.date_to_displaydate(l_effective_date + 1);

        hr_entry_api.update_element_entry(
             p_dt_update_mode           => 'CORRECTION',
             p_session_date             => l_start_date,
             p_element_entry_id         => l_res_ele_entry_id,
             p_num_entry_values         => 2,
             p_input_value_id_tbl       => inp_value_id_tbl,
             p_entry_value_tbl          => scr_valuetbl);

        write_log(l_proc||', 145', DEBUG);

      end if;

      close csr_check_ee_exist;

    end if;

  end if;

  write_log('Leaving: '||l_proc||', 150', DEBUG);

end pto_carry_over_for_asg;

END pay_us_pto_co_pkg;

/
