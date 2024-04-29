--------------------------------------------------------
--  DDL for Package Body PAY_ZA_EMP201
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_EMP201" AS
/* $Header: pyzae201.pkb 120.0.12010000.4 2009/09/01 09:21:47 rbabla noship $ */
/* Copyright (c) Oracle Corporation 2005. All rights reserved. */
/*
   PRODUCT
      Oracle Payroll - ZA Localisation EMP201 Package

   NAME
      pay_za_emp201.pkb

   DESCRIPTION
      This is the ZA EMP201 package.  It contains
      functions and procedures used by EMP201 Report.

   MODIFICATION HISTORY
   Person    Date       Version         Bug     Comments
   --------- ---------- -----------    ------- --------------------------------
   P Arusia                                      Initial Version
   R Babla  10/06/2009  120.0           8512751  Updated Initial Version
   R Babla  26/06/2009  120.1           8512751  Removed GSCC Errors
   R Babla  26/06/2009 120.0.12010000.3 8512751  Modified the message in warning section.
                                                 Changed the archive_code to set l_cnt_paye_perm
                                                 as N if its seasonal worker with no remuneration
                                                 with EMP201 Status as Y
   R Babla  01/09/2009 120.0.12010000.3 8859207  1.Changes done in cursor csr_asg_details to include
                                                 space between name
                                                 2. Changes done in the parameters passed to cursor
						 csr_check_asg_termination

*/

g_package                  constant varchar2(30) := 'pay_za_emp201.';
g_archive_effective_date   date ;

-- -----------------------------------------------------------------------------
-- formatted_canonical
-- -----------------------------------------------------------------------------
-- This function converts varchar2 in decimal format
-- eg 0 is converted to 0.00
function formatted_canonical(
    canonical varchar2)
return varchar2 is
    decimal_char varchar2(1);
    dummy varchar2(20);
  begin
    hr_utility.set_location('Entered canonical_to_number',20);
    decimal_char := substr(ltrim(to_char(.3,'0D0')),2,1);
    hr_utility.set_location('Done with decimal_char',20);
    hr_utility.set_location('decimal_char:'||decimal_char,20);
    return rtrim(ltrim(to_char(translate(canonical, '.', decimal_char),'999999999999999990D99')));
  --return canonical;
end formatted_canonical;


-- -----------------------------------------------------------------------------
-- Get Parameters
-- -----------------------------------------------------------------------------
procedure get_parameters
(
   p_payroll_action_id in  number,
   p_token_name        in  varchar2,
   p_token_value       out nocopy varchar2
)  is

   cursor csr_parameter_info
   (
     p_pact_id number,
     p_token   char
   )  is
   select substr
       (
          legislative_parameters,
          instr
          (
             legislative_parameters,
             p_token
          )  + (length(p_token) + 1),
          instr
          (
             legislative_parameters,
             ' ',
             instr
             (
                legislative_parameters,
                p_token
             )
          )
          -
          (
             instr
             (
                legislative_parameters,
                p_token
             )  + length(p_token)
          )
       ),
       business_group_id
    from pay_payroll_actions
    where payroll_action_id = p_pact_id;

l_business_group_id            number;
l_proc                         varchar2(50) := g_package || 'get_parameters';

begin

   hr_utility.set_location('Entering ' || l_proc, 10);

   hr_utility.set_location('Step ' || l_proc, 20);
   hr_utility.set_location('p_token_name = ' || p_token_name, 20);

   open  csr_parameter_info
         (
            p_payroll_action_id,
            p_token_name
         );
   fetch csr_parameter_info into p_token_value, l_business_group_id;
   close csr_parameter_info;

   if p_token_name = 'BG_ID' then
      p_token_value := l_business_group_id;
   end if ;

   hr_utility.set_location('p_token_value = ' || p_token_value, 20);
   hr_utility.set_location('Leaving         ' || l_proc, 30);
--
exception
   when others then
   p_token_value := null;
--
end get_parameters;

function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2 is

start_ptr number;
end_ptr   number;
token_val pay_payroll_actions.legislative_parameters%type;
par_value pay_payroll_actions.legislative_parameters%type;

begin

   token_val := name || '=';

   start_ptr := instr(parameter_list, token_val) + length(token_val);
   end_ptr   := instr(parameter_list, ' ', start_ptr);

   /* if there is no spaces, then use the length of the string */
   if end_ptr = 0 then
     end_ptr := length(parameter_list) + 1;
   end if;

   /* Did we find the token */
   if instr(parameter_list, token_val) = 0 then
     par_value := NULL;
   else
     par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
   end if;

   return par_value;

end get_parameter;

--
--
--
-- -----------------------------------------------------------------------------
-- Range Cursor
-- -----------------------------------------------------------------------------
--

procedure range_cursor
(
     pactid in  number,
     sqlstr out nocopy varchar2
) is
    l_payroll_id number ;
    l_proc       varchar2(50) := g_package || 'range_cursor';

begin
   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Retrieve the Payroll_ID from legislative parameters from the payroll action
   get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'PAYROLL_ID',
      p_token_value       => l_payroll_id
   );

   -- Update the payroll_id column on the Payroll_Action record.
   update pay_payroll_actions
      set payroll_id = l_payroll_id
    where payroll_action_id = pactid;

   sqlstr :=
          'select distinct ass.person_id
           from per_assignments_f   ass,
                pay_payrolls_f      ppf,
                pay_payroll_actions ppa
           where ppa.payroll_action_id = :payroll_action_id
             and ass.business_group_id = ppa.business_group_id
             and ass.assignment_type   = ''E''
             and ppf.payroll_id        = ass.payroll_id
             and ppf.payroll_id        = ppa.payroll_id
           order by ass.person_id';

    hr_utility.set_location('Leaving ' || l_proc, 10);

    --hr_utility.trace_off;
    --
exception
     when others then
         sqlstr := null;
     --
end range_cursor;


--
--
-- -----------------------------------------------------------------------------
-- Archinit code
-- -----------------------------------------------------------------------------
--
-- Archive payroll level information here
procedure archinit
(
   p_payroll_action_id in number
) is

cursor csr_archive_effective_date(pactid number) is
   select effective_date
     from pay_payroll_actions
    where payroll_action_id = pactid;

CURSOR get_payroll_name (p_payroll_id number, l_effective_date date)IS
   select payroll_name
     from pay_all_payrolls_f
    where payroll_id = p_payroll_id
    and l_effective_date between effective_start_date and effective_end_date;

l_action_info_id number;
l_ovn            number;
l_payroll_id     number;
l_effective_date date;
l_payroll_name   varchar2(80);
l_calendar_month varchar2(30);
l_payroll_prd    varchar2(30);
l_proc       varchar2(50) := g_package || 'arch_init';

begin
   hr_utility.set_location('Entering ' || l_proc, 10);

   -- Get the effective date of the payroll action
   open csr_archive_effective_date(p_payroll_action_id); -- Payroll Action of the Archiver
      fetch csr_archive_effective_date
      into g_archive_effective_date;
   close csr_archive_effective_date;

   -- Retrieve the Payroll_ID from legislative parameters from the payroll action
   get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,   -- Payroll Action of the Archiver
      p_token_name        => 'PAYROLL_ID',
      p_token_value       => l_payroll_id
   );


   -- Retrieve the Calendar_Month from legislative parameters from the payroll action
   get_parameters
   (
      p_payroll_action_id => p_payroll_action_id,   -- Payroll Action of the Archiver
      p_token_name        => 'CALENDAR_MONTH',
      p_token_value       => l_calendar_month
   );

    l_effective_date := fnd_date.canonical_to_date(l_calendar_month);

    open get_payroll_name(l_payroll_id, l_effective_date);
    fetch get_payroll_name into l_payroll_name ;
    close get_payroll_name ;

    -- Convert calendar month to 'Mon YYYY' format, for eg 'Feb 2008'
    l_payroll_prd := to_char(to_date(l_calendar_month,'RRRR/MM/DD HH24:MI:SS'),'Mon YYYY');

    -- Archive 'ZA EMP201 PAYROLL DETAILS'
    pay_action_information_api.create_action_information
    (
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_payroll_action_id,
            p_action_context_type         => 'PA',
            p_object_version_number       => l_ovn,
            p_effective_date              => g_archive_effective_date,
            p_action_information_category => 'ZA EMP201 PAYROLL DETAILS',
            p_action_information1         => l_payroll_id,
            p_action_information2         => l_payroll_name,
            p_action_information3         => l_payroll_prd
     );

end archinit;


--
--
-- -----------------------------------------------------------------------------
-- Assignment Action Creation
-- -----------------------------------------------------------------------------
--
procedure action_creation
(
    pactid    in number,
    stperson  in number,
    endperson in number,
    chunk     in number
) is

   -- pick up all assignments within this person range,
   -- belonging to this payroll and business group
   -- (as per the last person/assignment record before this month end )
   -- which are
   -- a) not terminated (or)
   -- b) terminated but
   --         i) termination starts after this month end (or)
   --        ii) termination happened within this month
   --       iii) action_termination_date was before month start
   --            but final_process_date is still left

   cursor csr_get_asg (p_pactid number
                    , p_stperson number
                    , p_endperson number
                    , p_canonical_start_date date
                    , p_canonical_end_date date) is
         select ppf.person_id
              , paa.assignment_id
           from per_all_people_f ppf
              , per_all_assignments_f paa
              , pay_payroll_actions ppa
              , per_periods_of_service pps
         where ppf.person_id between p_stperson and p_endperson
           and paa.person_id = ppf.person_id
           and paa.business_group_id = ppa.business_group_id
           and ppa.payroll_action_id = p_pactid
           and paa.payroll_id = ppa.payroll_id
           and paa.period_of_service_id = pps.period_of_service_id
           -- last person record before this month end
               and ppf.effective_start_date = ( select max(effective_start_date)
                                                from   per_all_people_f ppf1
                                                where  ppf1.person_id = ppf.person_id
                                                and    ppf1.effective_start_date <= p_canonical_end_date
                                                )
           -- last assignment record before this month end
               and paa.effective_start_date = ( select max(paa1.effective_start_date)
                                                from   per_all_assignments_f paa1 where paa1.assignment_id = paa.assignment_id
                                                and    paa1.effective_start_date <= p_canonical_end_date
                                                )
           and
               (
            pps.actual_termination_date is null -- employee is not terminated
            or                                  -- (or)
                (
                        pps.actual_termination_date is not null -- employee is terminated but
                    and
                    (
                    pps.actual_termination_date > p_canonical_end_date  -- 1) termination is after this month end (or)
                    or
                                pps.actual_termination_date between p_canonical_start_date and p_canonical_end_date -- 2) termination is within this month (or)
                                or
                        (
                                        pps.actual_termination_date < p_canonical_start_date   -- 3) termination happened before month start (but) final_process_date is after month start
                                and nvl(pps.final_process_date,to_date('31-12-4712','DD-MM-YYYY')) >= p_canonical_start_date
                        )

                          )
                 )
               )
        order by 2
 for update of paa.assignment_id;

 l_calendar_month varchar(30);
 l_month_start date ;
 l_month_end date ;
 l_asg_set_id number;
 v_incl_sw    hr_assignment_set_amendments.include_or_exclude%type;
 asg_include boolean;
 prev_asg_id number := 0 ;
 lockingactid number;

 l_proc       varchar2(50) := g_package || 'action_creation';
begin
   -- Retrieve the Calendar Month from legislative parameters from the payroll action
   get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'CALENDAR_MONTH',
      p_token_value       => l_calendar_month
   );

   l_month_start := add_months(fnd_date.canonical_to_date(l_calendar_month), -1)+1;
   l_month_end := fnd_date.canonical_to_date(l_calendar_month) ;

   -- Retrieve the Calendar Month from legislative parameters from the payroll action
   get_parameters
   (
      p_payroll_action_id => pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'ASG_SET_ID',
      p_token_value       => l_asg_set_id
   );

   hr_utility.set_location('pactid '||to_char(pactid), 10);
   hr_utility.set_location('l_asg_set_id '||to_char(l_asg_set_id), 10);
   hr_utility.set_location('stperson '||to_char(stperson), 10);
   hr_utility.set_location('endperson '||to_char(endperson), 10);
   hr_utility.set_location('l_month_start '||to_char(l_month_start, 'dd/mm/yyyy'), 10);
   hr_utility.set_location('l_month_end '||to_char(l_month_end, 'dd/mm/yyyy'), 10);

   if l_asg_set_id is not null then
       -- find out if assignments in assignment-set are set to Include or Exclude.
       begin
         select distinct include_or_exclude
           into v_incl_sw
           from hr_assignment_set_amendments
          where assignment_set_id = l_asg_set_id;
       exception
         when no_data_found  then
              -- default to Include, should not go here though.
              v_incl_sw := 'I';
       end;
   end if;

   hr_utility.set_location('Before csr_get_asg', 20);

   for asgrec in csr_get_asg ( pactid, stperson, endperson, l_month_start, l_month_end)
   loop
     hr_utility.set_location('ASS_ID: ' || to_char(asgrec.assignment_id), 30);
     asg_include := TRUE;

      -- Remove duplicate assignments
      if prev_asg_id <> asgrec.assignment_id then
         prev_asg_id := asgrec.assignment_id;
         if l_asg_set_id is not null then
            declare
               inc_flag varchar2(5);
            begin
               select include_or_exclude
                 into inc_flag
                 from hr_assignment_set_amendments
                where assignment_set_id = l_asg_set_id
                  and assignment_id = asgrec.assignment_id;

               if inc_flag = 'E' then
                  asg_include := FALSE;
               end if;
            exception
               -- goes through this exception, for each assignment in the payroll
               -- but not in the relevant assignment_set.
               when no_data_found then
                    if  v_incl_sw = 'I' then
                        asg_include := FALSE;
                    else
                        asg_include := TRUE;
                    end if;
            end ;
         end if; -- end of l_asg_set_id is not null

         if asg_include = TRUE then
            select pay_assignment_actions_s.nextval
              into lockingactid
              from dual;

            -- Insert assignment into pay_assignment_actions
            hr_nonrun_asact.insact
            (
               lockingactid,
               asgrec.assignment_id,
               pactid,
               chunk,
               null
            );
         end if; --end of if asg_include = TRUE
      end if; -- end of ( if not duplicate assignment )
   end loop ;

   hr_utility.set_location('Leaving ' || l_proc, 30);

   --hr_utility.trace_off;

end action_creation;

--
-- -----------------------------------------------------------------------------
-- Archive Data
-- -----------------------------------------------------------------------------
--

procedure archive_data
(
      p_assactid       in number,
      p_archive_effective_date in date
) is

   -- Retrieve the employee details
   cursor csr_asg_details (l_eff_date date)is
       select p.employee_number
             ,p.title ||' '|| p.first_name ||' '|| p.last_name emp_name
             ,a.assignment_id
             ,a.period_of_service_id
             ,a.assignment_number
       from per_all_people_f p
          , per_all_assignments_f a
          , pay_assignment_actions paa
       where paa.assignment_action_id = p_assactid
         and a.assignment_id = paa.assignment_id
         and p.person_id = a.person_id
         and l_eff_date between p.effective_start_date and p.effective_end_date
         and l_eff_date between a.effective_start_date and a.effective_end_date ;

    -- EMP201 Status logic -
    -- a) If EMP201_Status is provided (aei_information12), use it
    -- b) else, if Employment Equity Status is provided (aei_information11), use it
    -- c) else, use the Employment Equity Status defaulting logic
    --          (per_za_employment_equity_pkg.get_ee_employment_type_name),
    --          which says that employee has to work for a continuous period of
    --          3 months in order to be seen as permanent

   cursor csr_asg_specific_info_dtls (p_assignment_id number
                                    , p_effective_date date
                                    , p_period_of_service_id number) is
       select hr_general.decode_lookup('ZA_PER_NATURES',aei.aei_information4) nature,
              nvl(aei.aei_information6,'N') independent_contractor,
              nvl(aei.aei_information10,'N') labour_broker,
              decode(aei.aei_information12,
                       'P','Permanent',
                       'N','Non-Permanent',
                       nvl(decode(aei.aei_information11,
                              'P','Permanent',
                              'N','Non-Permanent'),
                              per_za_employment_equity_pkg.get_ee_employment_type_name(p_effective_date
                                                                                 , p_period_of_service_id))) EMP201_status
       from per_assignment_extra_info aei
       where aei.assignment_id = p_assignment_id
         and aei.information_type = 'ZA_SPECIFIC_INFO' ;

   --Retrieve the employee's UIF Information
   cursor csr_asg_uif_info_dtls (p_assignment_id number) is
       select aei.aei_information1 reason_for_non_contrib
       from per_assignment_extra_info aei
       where aei.assignment_id = p_assignment_id
         and aei.information_type = 'ZA_UIF_INFO' ;

    -- select the payroll_action_id of the last payroll run
    -- whose pay_advice_date falls in the calendar month
    cursor csr_payroll_action (p_assignment_id number,
                               l_effective_date date) is
       select ppa.payroll_action_id
            , ppa.payroll_id
       from   pay_assignment_actions     paa,
            pay_payroll_actions        ppa,
            per_time_periods ptp
       where  paa.assignment_id = p_assignment_id
       and  paa.payroll_action_id = ppa.payroll_action_id
       and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
       and  paa.action_status ='C'
       and  ptp.payroll_id = ppa.payroll_id
       and  ppa.date_earned between ptp.start_date and ptp.end_date
       and  ptp.pay_advice_date between trunc(l_effective_date,'Month') and l_effective_date
       and  paa.action_sequence = (select max(paa1.action_sequence)
                                   from pay_assignment_actions     paa1,
                                        pay_payroll_actions        ppa1,
                                        per_time_periods ptp1
                                   where  paa1.assignment_id = p_assignment_id
                                     and  paa1.payroll_action_id = ppa1.payroll_action_id
                                     and  ppa1.action_type IN ('R', 'Q', 'V', 'B', 'I')
                                     and  paa1.action_status ='C'
                                     and  ptp1.payroll_id = ppa1.payroll_id
                                     and  ppa1.date_earned between ptp1.start_date and ptp1.end_date
                                     and  ptp1.pay_advice_date between trunc(l_effective_date,'Month') and l_effective_date
                                 ) ;

    --Check whether the employee is SDL Exempt or Non-Exempt
    --If the SDL is set to Exempt at assignment extra information, then the employee is exempt
    --else its considered the one set at organisation level
    cursor get_sdl_exemption (p_assignment_id number
                            , p_effective_date date) is
       select decode(hoi.org_information1,'Exempt','E',nvl(aei.aei_information9,'N')) "Exemption"
       from per_all_assignments_f ass
          , hr_organization_information hoi
          , per_assignment_extra_info   aei
       where ass.assignment_id = p_assignment_id
         and p_effective_date between ass.effective_start_date and ass.effective_end_date
         and ass.organization_id = hoi.organization_id
         and hoi.org_information_context = 'ZA_NQF_SETA_INFO'
         and aei.assignment_id = ass.assignment_id
         and aei.information_type = 'ZA_SPECIFIC_INFO' ;

    --Used in UIF Calculation to retrieve the period limit
    --Its same query used for route ZA_PAY_MONTH_PERIOD_NUMBER
    cursor csr_za_pay_mnth_prd_num (p_payroll_action_id number
                                  , p_payroll_id number) is
      select count(ptp.end_date)
        from per_time_periods ptp
        where ptp.pay_advice_date =
                (select tperiod.pay_advice_date
                   from per_time_periods tperiod,
                        pay_payroll_actions paction
                   where paction.payroll_action_id = p_payroll_action_id
                     and tperiod.time_period_id = paction.time_period_id
                 )
          and ptp.end_date <=
               (select tperiod.end_date
                  from per_time_periods tperiod,
                       pay_payroll_actions paction
                  where paction.payroll_action_id = p_payroll_action_id
                    and tperiod.time_period_id = paction.time_period_id
               )
         and ptp.payroll_id = p_payroll_id;

    --Used in UIF Calculation to retrieve the period limit
    --Its same query used for route ZA_PAY_PERIODS_PER_YEAR
    cursor csr_pay_prd_per_yr (p_payroll_action_id number
                             , p_payroll_id number) is
       select count(ptp.end_date)
         from  per_time_periods PTP
         where ptp.prd_information1 =
                (select tperiod.prd_information1
                   from per_time_periods tperiod,
                        pay_payroll_actions paction
                  where paction.payroll_action_id  = p_payroll_action_id
                    and tperiod.time_period_id = paction.time_period_id)
               and ptp.payroll_id = p_payroll_id;

    --Retrieve the value of the global
    cursor csr_global_value (p_global_name VARCHAR2
                           , p_effective_date date) is
        select global_value
        from   ff_globals_f
        where  global_name = p_global_name
          and    p_effective_date between effective_start_date
                                  and effective_end_date
          and legislation_code = 'ZA';


    --Retrive the Tax Status from Run results
    cursor csr_tax_status (p_payroll_action_id number ) is
       select prrv.result_value
       from pay_payroll_actions ppa
          , pay_assignment_actions paa
          , pay_element_types_f pet
          , pay_input_values_f  piv
          , pay_run_results     prr
          , pay_run_result_values  prrv
      where ppa.payroll_action_id = p_payroll_action_id
        and paa.payroll_action_id = ppa.payroll_action_id
        and pet.element_name = 'ZA_Tax'
        and piv.element_type_id = pet.element_type_id
        and piv.name = 'Tax Status'
        and prr.element_type_id = pet.element_type_id
        and prr.assignment_action_id = paa.assignment_action_id
        and prrv.run_result_id  = prr.run_result_id
        and prrv.input_value_id = piv.input_value_id
        and ppa.effective_date between pet.effective_start_date and pet.effective_end_date
        and ppa.effective_date between piv.effective_start_date and piv.effective_end_date ;

    --Retrieve the Tax Status from element entry
    cursor csr_tax_status_from_ele_entry (p_assignment_id number
                                        , p_effective_date date) is
       select peev.screen_entry_value
       from    pay_element_entry_values_f peev
             , pay_element_entries_f peef
             , pay_element_types_f   pet
             , pay_input_values_f    piv
       where
             pet.legislation_code = 'ZA'
         and pet.element_name = 'ZA_Tax'
         and piv.element_type_id = pet.element_type_id
         and piv.name = 'Tax Status'
         and peef.assignment_id = p_assignment_id
         and peef.element_type_id = pet.element_type_id
         and peev.element_entry_id = peef.element_entry_id
         and peev.input_value_id = piv.input_value_id
         and p_effective_date between pet.effective_start_date and pet.effective_end_date
         and p_effective_date between piv.effective_start_date and piv.effective_end_date
         and p_effective_date between peef.effective_start_date and peef.effective_end_date
         and p_effective_date between peev.effective_start_date and peev.effective_end_date ;

    --Returns Y is assignment is terminated, else N
    cursor csr_check_asg_termination (p_assignment_id number
                                    , p_effective_date date) is
       select decode (past.PER_SYSTEM_STATUS, 'TERM_ASSIGN','Y','N') asg_terminated
       from per_all_assignments_f paa,
            per_assignment_status_types past
       where paa.assignment_id = p_assignment_id
         and paa.assignment_status_type_id = past.assignment_status_type_id
         and p_effective_date between paa.effective_start_date and paa.effective_end_date ;


   l_pactid_archive number ;
   l_calendar_month varchar2(30);
   l_month_end date ;
   l_effective_date date ;
   l_asg_end_date date :=null;
   l_last_run_payroll_action_id number ;
   l_payroll_id number ;

   l_proc           varchar2(50) := g_package || 'archive_data';
   l_employee_number varchar2(30);
   l_assignment_no   varchar2(30);
   l_emp_name        varchar2(350);
   l_assignment_id   number ;
   l_period_of_service_id number ;
   l_nature_of_person varchar2(1);
   l_independent_contractor varchar2(1);
   l_labour_broker varchar2(1);
   l_EMP201_status varchar2 (20);
   l_reason_for_uif_non_contrib varchar2(3);

    l_tax_dim_mtd number;
    l_paye_remuneration number;
    l_paye_rem_dim_mtd  number;
    l_tax number;
    l_sdl_exemption varchar2(1);
    l_net_taxable_inc_dim_mtd number ;
    l_skills_levy_dim_mtd number ;
    l_leviable_amt number;
    l_sdl_amt number ;
    l_temp_emp_hours_dim_mtd number;
    l_temp_emp_hours number;
    l_za_pay_mnth_prd_num number ;
    l_pay_prd_per_yr number ;
    l_uif_ee_dim_mtd number ;
    l_uif_er_dim_mtd number ;
    l_uifable_income_dim_mtd number ;
    l_uif_ee_contr number;
    l_uif_er_contr number;
    l_uif_amt number ;
    l_uif_remuneration number ;
    l_UIF_Annual_Limit number ;
    l_UIF_period_limit number ;

    l_tax_status varchar2(2);
    l_gross_remun number ;
    l_gross_remun_dim_mtd number;
    l_seasonal_not_paid_flag boolean := false ;
    l_cnt_paye_perm varchar2(1) ;
    l_cnt_paye_non_perm varchar2(1);

    l_asg_terminated varchar2(1);
    l_site_dim_ytd number;
    l_paye_dim_ytd number ;
    l_tax_dim_ytd  number;
    l_tax_ytd number;
    l_site number ;
    l_paye number;
    l_raise_warning varchar2(1) ;

    l_action_info_id number ;
    l_ovn number ;
begin
 --  hr_utility.trace_on(null, 'ZA_EMP201');

   hr_utility.set_location('Entering ' || l_proc, 10);

   --get the Archive Effective Date
   select ppa.payroll_action_id
     into l_pactid_archive
     from pay_payroll_actions    ppa,
          pay_assignment_actions paa
     where paa.payroll_action_id = ppa.payroll_action_id
       and paa.assignment_action_id = p_assactid;

   -- Retrieve the Calendar Month from legislative parameters from the payroll action
   get_parameters
   (
      p_payroll_action_id => l_pactid_archive,   -- Payroll Action of the Archiver
      p_token_name        => 'CALENDAR_MONTH',
      p_token_value       => l_calendar_month
   );

   l_month_end := fnd_date.canonical_to_date(l_calendar_month) ;

   l_effective_date := l_month_end ;

   -- Retrieve the employee details
   open csr_asg_details (l_effective_date);
   fetch csr_asg_details into l_employee_number
                              , l_emp_name
                              , l_assignment_id
                              , l_period_of_service_id
                              , l_assignment_no;
   if csr_asg_details%NOTFOUND then
        hr_utility.set_location('csr_asg_details not found',10);
        select max(effective_end_date)
        into l_asg_end_date
        from per_all_assignments_f paf,
             pay_assignment_actions paa
        where effective_end_date <= l_month_end
        and paa.assignment_id = paf.assignment_id
        and paa.assignment_action_id = p_assactid;

  --      hr_utility.set_location('l_asg_end_date: '||to_char('l_asg_end_date','dd-mon-yyyy'),10);
        hr_utility.set_location('Found csr_asg_details',10);

        close csr_asg_details ;

        open csr_asg_details (l_asg_end_date);
        fetch csr_asg_details into l_employee_number
                                 , l_emp_name
                                 , l_assignment_id
                                 , l_period_of_service_id
                                 , l_assignment_no;
   end if ;
   close csr_asg_details ;

   hr_utility.set_location(l_proc, 20);

    --Retrieve the ZA_SPECIFIC_INFO details
   open csr_asg_specific_info_dtls (l_assignment_id, nvl(l_asg_end_date,l_effective_date), l_period_of_service_id);
   fetch csr_asg_specific_info_dtls into l_nature_of_person
                                       , l_independent_contractor
                                       , l_labour_broker
                                       , l_EMP201_status ;
   if csr_asg_specific_info_dtls%NOTFOUND then
       hr_utility.set_location(l_proc, 30);
       l_nature_of_person := 'A' ;
       l_independent_contractor := 'N' ;
       l_labour_broker := 'N';
       l_EMP201_status := per_za_employment_equity_pkg.get_ee_employment_type_name(l_effective_date, l_period_of_service_id);
   end if ;
   close csr_asg_specific_info_dtls ;

   hr_utility.set_location(l_proc, 40);

   --Retrieve the UIF details
   open csr_asg_uif_info_dtls(l_assignment_id) ;
   fetch csr_asg_uif_info_dtls into l_reason_for_uif_non_contrib ;
   close csr_asg_uif_info_dtls ;

   hr_utility.set_location(l_proc, 50);

   --Retrieve the last payroll run for this employee in the current Month (Month for which archival is run)
   open csr_payroll_action (l_assignment_id, l_effective_date);
   fetch csr_payroll_action into l_last_run_payroll_action_id
                               , l_payroll_id ;
   if csr_payroll_action%NOTFOUND then
       hr_utility.trace('Payroll Not Run this month');
       hr_utility.set_location(l_proc, 60);
       l_last_run_payroll_action_id := null ;
   end if ;
   close csr_payroll_action ;

   hr_utility.set_location(l_proc, 70);

   hr_utility.trace('Assignment_id : '||l_assignment_id);
   hr_utility.trace('l_nature_of_person : '||l_nature_of_person);
   hr_utility.trace('l_independent_contractor : '||l_independent_contractor);
   hr_utility.trace('l_labour_broker : '||l_labour_broker);
   hr_utility.trace('l_EMP201_status : '||l_EMP201_status);
   hr_utility.trace('l_reason_for_non_contrib : '||l_reason_for_uif_non_contrib);
   hr_utility.trace('l_last_run_payroll_action_id : '||l_last_run_payroll_action_id);
   hr_utility.trace('l_payroll_id : '||l_payroll_id);


   -- Get PAYE Data
   l_tax_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('Tax', '_ASG_TAX_MTD');
   l_tax := nvl(pay_balance_pkg.get_value(l_tax_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

   -- Get PAYE Remuneration
   l_paye_rem_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('Net PAYE Taxable Income', '_ASG_TAX_MTD');
   l_paye_remuneration := nvl(pay_balance_pkg.get_value(l_paye_rem_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

   hr_utility.set_location(l_proc, 80);

   -- Get SDL Data
   open get_sdl_exemption (l_assignment_id, nvl(l_asg_end_date,l_effective_date));
   fetch get_sdl_exemption into l_sdl_exemption ;
   close get_sdl_exemption ;

   -- exclude Exempt employees
   if l_sdl_exemption = 'N' then

       hr_utility.set_location(l_proc, 90);

       l_net_taxable_inc_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('Net Taxable Income', '_ASG_TAX_MTD');
       l_skills_levy_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('Skills Levy', '_ASG_TAX_MTD');

       l_leviable_amt := nvl(pay_balance_pkg.get_value(l_net_taxable_inc_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);
       l_sdl_amt := nvl(pay_balance_pkg.get_value(l_skills_levy_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

       if l_leviable_amt < 0 then
          l_leviable_amt := 0 ;
       end if ;
   else
       hr_utility.set_location(l_proc, 100);
       l_leviable_amt := 0 ;
       l_sdl_amt := 0 ;
   end if ;

   -- Get UIF Data

   -- Remuneration for employee's with a UIF reason for Non-Contribution must be excluded as must
   -- Remuneration of Independent Contractors and any non-natural persons (Nature of Person = D, E, F, G, H or K).

   l_temp_emp_hours_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('ZA_TEMPORARY_EMPLOYEE_HOURS', '_ASG_TAX_MTD');
   l_temp_emp_hours := nvl(pay_balance_pkg.get_value(l_temp_emp_hours_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

   if l_last_run_payroll_action_id is null then -- No payroll run for this calendar month
       hr_utility.set_location(l_proc, 110);
       l_uif_amt := 0 ;
       l_uif_remuneration := 0 ;
   elsif (l_nature_of_person in ('D','E','F','G','H','K') or
       l_independent_contractor = 'Y' or
       l_reason_for_uif_non_contrib in ('02','03','04','05','06','08','007') or
       ( l_reason_for_uif_non_contrib= '01'
         and
         l_temp_emp_hours < 24.0
         )
       ) then
       hr_utility.set_location(l_proc, 120);
       l_uif_amt := 0 ;
       l_uif_remuneration := 0 ;
   else
        hr_utility.set_location(l_proc, 130);
        -- get UIF amount and Remuneration
        l_uif_ee_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('UIF Employee Contribution', '_ASG_TAX_MTD');
        l_uif_er_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('UIF Employer Contribution', '_ASG_TAX_MTD');
        l_uifable_income_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('Total UIFable Income', '_ASG_TAX_MTD');

        l_uif_ee_contr := nvl(pay_balance_pkg.get_value(l_uif_ee_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);
        l_uif_er_contr := nvl(pay_balance_pkg.get_value(l_uif_er_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);
        l_uif_amt := l_uif_ee_contr+ l_uif_er_contr ;

        l_uif_remuneration := nvl(pay_balance_pkg.get_value(l_uifable_income_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

        -- Each person's UIF Remuneration must be limited to the monthly UIF maximum
        -- calculate periodic UIF limit

        open csr_za_pay_mnth_prd_num(l_last_run_payroll_action_id, l_payroll_id);
        fetch csr_za_pay_mnth_prd_num into l_za_pay_mnth_prd_num ;
        close csr_za_pay_mnth_prd_num ;

        open csr_pay_prd_per_yr(l_last_run_payroll_action_id, l_payroll_id);
        fetch csr_pay_prd_per_yr into l_pay_prd_per_yr ;
        close csr_pay_prd_per_yr ;

        open csr_global_value( 'ZA_UIF_ANN_LIM', l_effective_date);
        fetch csr_global_value into l_UIF_Annual_Limit ;
        close csr_global_value ;

        l_UIF_period_limit := round(l_za_pay_mnth_prd_num * l_UIF_Annual_Limit / l_pay_prd_per_yr ,2) ;

        -- if UIF Remuneration > period_limit, then truncate it to period_limit
        if l_uif_remuneration > l_UIF_period_limit then
           hr_utility.set_location(l_proc, 140);
           l_uif_remuneration := l_UIF_period_limit ;
        end if ;
   end if ;

   hr_utility.set_location(l_proc, 150);

   -- whether to count the employee in Permanent or Non-Permanent or None
        if  (l_nature_of_person not in ('D','E','F','G','H','K') and
             l_independent_contractor <> 'Y' and
             l_labour_broker <> 'Y') then

             hr_utility.set_location(l_proc, 160);

             -- get tax_status from run results
             if l_last_run_payroll_action_id is not null then
                hr_utility.set_location(l_proc, 170);
                open csr_tax_status(l_last_run_payroll_action_id);
                fetch csr_tax_status into l_tax_status ;
                close csr_tax_status ;
             else
                -- get tax status from element entry screen values
                hr_utility.set_location(l_proc, 180);
                -- tax status effective as on month_end_date / assignment_end_date
                open csr_tax_status_from_ele_entry  (l_assignment_id,nvl(l_asg_end_date,l_effective_date)) ;
                fetch csr_tax_status_from_ele_entry into l_tax_status ;
                if csr_tax_status_from_ele_entry%NOTFOUND then
                    hr_utility.set_location(l_proc, 190);
                    -- if tax status not specified, assume to be non-seasonal worker
                    l_tax_status := 'A' ;
                end if ;
                close csr_tax_status_from_ele_entry;
             end if ;

             hr_utility.trace('tax_status :'||l_tax_status);

             l_gross_remun_dim_mtd := pay_za_payroll_action_pkg.defined_balance_id('Gross Remuneration', '_ASG_CAL_MTD');
             l_gross_remun := nvl(pay_balance_pkg.get_value(l_gross_remun_dim_mtd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0) ;

             if l_tax_status = 'G' and l_gross_remun = 0 then
                    -- Seasonal worker and no remuneration in this month
                    -- Hence don't count this employee
                   hr_utility.set_location(l_proc, 200);
                   l_seasonal_not_paid_flag := true ;
             end if ;

             -- Do not count if employee is a seasonal worker
             -- and has not been paid any remuneration this month
             if l_seasonal_not_paid_flag = false then
                hr_utility.set_location(l_proc, 210);
                if l_EMP201_status = 'Permanent' then
                   hr_utility.set_location(l_proc, 220);
                   l_cnt_paye_perm := 'Y' ;
                else
                   hr_utility.set_location(l_proc, 230);
                   if l_gross_remun > 0 then
                       hr_utility.set_location(l_proc, 240);
                       -- Count non-permanent employees only if
                       -- remuneration was paid / accrued to them during
                       -- the relevant month
                       l_cnt_paye_non_perm := 'Y';
                   end if ;
                end if ;
             -- If seasonal worker with no remuneration and EMP201 status as 'Permanent', then dont count in permanent
             elsif (l_seasonal_not_paid_flag and l_EMP201_status = 'Permanent' ) then
                l_cnt_paye_perm := 'N' ;
             end if ;
        end if ;

    hr_utility.set_location(l_proc, 220);

    -------WARNING PAGE ------------------------------

    -- Check each employee processed to see if they are terminated or not.
    -- If they are terminated they must have a value in SITE and/or PAYE.
    -- If this is not the case then a Warning Page must be printed at the end
    -- of the report.
    -- For summary format of the report option, print only count of
    -- defaulting assignments.

    -- check if assignment is terminated
    open csr_check_asg_termination(l_assignment_id, l_effective_date);
    fetch csr_check_asg_termination into l_asg_terminated ;
        if csr_check_asg_termination%NOTFOUND then
           hr_utility.set_location(l_proc, 245);
           l_asg_terminated := 'Y' ;
        end if ;
    close csr_check_asg_termination ;

    if l_asg_terminated = 'Y' then -- assignment is terminated
       hr_utility.set_location(l_proc, 250);
       l_tax_dim_ytd := pay_za_payroll_action_pkg.defined_balance_id('Tax', '_ASG_TAX_YTD');
       l_tax_ytd := nvl(pay_balance_pkg.get_value(l_tax_dim_ytd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

       l_site_dim_ytd := pay_za_payroll_action_pkg.defined_balance_id('SITE', '_ASG_TAX_YTD');
       l_site := nvl(pay_balance_pkg.get_value(l_site_dim_ytd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

       l_paye_dim_ytd := pay_za_payroll_action_pkg.defined_balance_id('PAYE', '_ASG_TAX_YTD');
       l_paye := nvl(pay_balance_pkg.get_value(l_paye_dim_ytd, l_assignment_id,nvl(l_asg_end_date,l_effective_date)),0);

       if l_tax_ytd <> 0 and l_site = 0 and l_paye = 0 then -- SITE/PAYE split not calculated
          hr_utility.set_location(l_proc, 255);
          l_raise_warning := 'Y' ;
       end if ; -- end of SITE/PAYE split not calculated for the assignment
    end if ; -- end of Assignment Terminated

    hr_utility.set_location(l_proc, 260);

      hr_utility.set_location('p_action_context_id           => '|| to_char(p_assactid), 60);
      hr_utility.set_location('p_action_context_type         => '|| 'AAP', 60);
      hr_utility.set_location('p_assignment_id               => '|| l_assignment_id, 60);
      hr_utility.set_location('p_effective_date              => '|| to_char(l_effective_date, 'dd/mm/yyyy'), 60);
      hr_utility.set_location('p_action_information_category => '|| 'ZA EMP201 ASSIGNMENT DATA', 60);
      hr_utility.set_location('p_action_information1         => '|| l_assignment_id, 60);
      hr_utility.set_location('p_action_information2         => '|| to_char(l_effective_date, 'YYYYMM'), 60);
      hr_utility.set_location('p_action_information3         => '|| l_employee_number, 60);
      hr_utility.set_location('p_action_information4         => '|| l_emp_name, 60);
      hr_utility.set_location('p_action_information5         => '|| l_paye_remuneration, 60);
      hr_utility.set_location('p_action_information6         => '|| l_tax, 60);
      hr_utility.set_location('p_action_information7         => '|| l_leviable_amt, 60);
      hr_utility.set_location('p_action_information8         => '|| l_sdl_amt, 60);
      hr_utility.set_location('p_action_information9         => '|| l_uif_remuneration, 60);
      hr_utility.set_location('p_action_information10        => '|| l_uif_amt, 60);
      hr_utility.set_location('p_action_information11        => '|| l_EMP201_status, 60);
      hr_utility.set_location('p_action_information12        => '|| l_cnt_paye_perm, 60);
      hr_utility.set_location('p_action_information13        => '|| l_cnt_paye_non_perm, 60);
      hr_utility.set_location('p_action_information14        => '|| l_raise_warning, 60);
      hr_utility.set_location('p_action_information15        => '|| l_asg_terminated, 60);
      hr_utility.set_location('p_action_information16        => '|| l_assignment_no, 60);
      hr_utility.set_location('p_action_information17        => '|| l_pactid_archive, 60);



      -- Archive the ZA EMP201 ASSIGNMENT DETAILS
      pay_action_information_api.create_action_information
      (
         p_action_information_id       => l_action_info_id,
         p_action_context_id           => p_assactid, -- Assignment Action of the Archiver
         p_action_context_type         => 'AAP',
         p_object_version_number       => l_ovn,
         p_assignment_id               => l_assignment_id,
         p_effective_date              => p_archive_effective_date,
         p_source_id                   => null,
         p_source_text                 => null,
         p_action_information_category => 'ZA EMP201 ASSIGNMENT DETAILS',
         p_action_information1         => l_assignment_id,
         p_action_information2         => to_char(l_effective_date, 'YYYYMM'),
         p_action_information3         => l_employee_number,
         p_action_information4         => l_emp_name,
         p_action_information5         => fnd_number.number_to_canonical(l_paye_remuneration),
         p_action_information6         => fnd_number.number_to_canonical(l_tax),
         p_action_information7         => fnd_number.number_to_canonical(l_leviable_amt),
         p_action_information8         => fnd_number.number_to_canonical(l_sdl_amt),
         p_action_information9         => fnd_number.number_to_canonical(l_uif_remuneration),
         p_action_information10        => fnd_number.number_to_canonical(l_uif_amt),
         p_action_information11        => l_EMP201_status,
         p_action_information12        => l_cnt_paye_perm,
         p_action_information13        => l_cnt_paye_non_perm,
         p_action_information14        => l_raise_warning,
         p_action_information15        => l_asg_terminated,
         p_action_information16        => l_assignment_no,
         p_action_information17        => l_pactid_archive
      );

   hr_utility.set_location('Leaving ' || l_proc, 270);
    --hr_utility.trace_off ;
end archive_data;


/*--------------------------------------------------------------------------
  Name      : get_parameters
  Purpose   : This retrieves legislative parameters from the payroll action.
  Arguments :
--------------------------------------------------------------------------*/

 --
 -- -----------------------------------------------------------------------------
 -- Get the correct characterset for XML generation
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_IANA_charset RETURN VARCHAR2 IS
   CURSOR csr_get_iana_charset IS
     SELECT tag
       FROM fnd_lookup_values
      WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
        AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
        AND language = 'US';
 --
  lv_iana_charset fnd_lookup_values.tag%type;
 BEGIN
   OPEN csr_get_iana_charset;
     FETCH csr_get_iana_charset INTO lv_iana_charset;
   CLOSE csr_get_iana_charset;
   RETURN (lv_iana_charset);
 END get_IANA_charset;

 --
 --
 -- -----------------------------------------------------------------------------
 -- Takes XML element from a table and puts them into a CLOB.
 -- -----------------------------------------------------------------------------
 --

  PROCEDURE write_to_clob (p_clob OUT NOCOPY CLOB) IS

  --  l_xml_element_template0 VARCHAR2(20) := '<TAG>VALUE</TAG>';
  --  l_xml_element_template1 VARCHAR2(30) := '<TAG><![CDATA[VALUE]]></TAG>';
  --  l_xml_element_template2 VARCHAR2(10) := '<TAG>';
  --  l_xml_element_template3 VARCHAR2(10) := '</TAG>';
  l_str1                  VARCHAR2(80) ;
  l_str2                  VARCHAR2(20) := '</EOY> </ROOT>';
  l_xml_element           VARCHAR2(800);
  l_clob                  CLOB;
  --
 BEGIN

  l_str1 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?>' ;

  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);
  dbms_lob.open(l_clob, DBMS_LOB.LOB_READWRITE);
  --
  dbms_lob.writeappend(l_clob, LENGTH(l_str1), l_str1);
  --
  IF g_xml_element_table.COUNT > 0 THEN
  --
   FOR table_counter IN g_xml_element_table.FIRST .. g_xml_element_table.LAST LOOP
   --
      IF g_xml_element_table(table_counter).tagvalue = '_START_' THEN
         l_xml_element := '<' || g_xml_element_table(table_counter).tagname || '>';
      ELSIF g_xml_element_table(table_counter).tagvalue = '_END_' THEN
         l_xml_element := '</' || g_xml_element_table(table_counter).tagname || '>';
      ELSIF g_xml_element_table(table_counter).tagvalue = '_COMMENT_' THEN
         l_xml_element := '<!-- ' || g_xml_element_table(table_counter).tagname || ' -->';
      ELSE
         l_xml_element := '<' || g_xml_element_table(table_counter).tagname ||
                      '><![CDATA[' || g_xml_element_table(table_counter).tagvalue ||
                     ']]></' || g_xml_element_table(table_counter).tagname || '>';
      END IF;
      --
      dbms_lob.writeappend(l_clob, LENGTH(l_xml_element), l_xml_element);
   --
   END LOOP;
  --
  END IF;

  p_clob := l_clob;
  --
  EXCEPTION
   WHEN OTHERS THEN
     --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
      hr_utility.set_location(sqlerrm(sqlcode),110);
 --
 END write_to_clob;

 --
 --
 -- -----------------------------------------------------------------------------
 -- Main procedure to be called to generate XML file for EMP201 report
 -- -----------------------------------------------------------------------------
 --

 PROCEDURE get_emp201_xml
    (business_group_id  number
    ,calendar_month   varchar2
    ,calendar_month_hidden   varchar2
    ,EMP201_FILE_PREPROCESS   varchar2
    ,p_detail_flag   varchar2
    ,p_template_name     IN VARCHAR2
    ,p_xml               OUT NOCOPY CLOB) AS


    cursor csr_get_emp201_payroll_data(p_archive_pact number) is
        select action_information1 l_payroll_id
             , action_information2 l_payroll_name
             , action_information3 l_payroll_prd
        from   pay_action_information
        where  action_context_id = p_archive_pact
          and  action_context_type = 'PA'
          and  action_information_category = 'ZA EMP201 PAYROLL DETAILS' ;

    cursor csr_get_emp201_asg_data(p_archive_pact number) is
        select action_information1     assignment_id,
               action_information2     l_effective_date,
               action_information3     employee_number,
               action_information4     emp_name,
               formatted_canonical(action_information5)    paye_remuneration,
               formatted_canonical(action_information6)    tax,
               formatted_canonical(action_information7)    leviable_amt,
               formatted_canonical(action_information8)    sdl_amt,
               formatted_canonical(action_information9)    uif_remuneration,
               formatted_canonical(action_information10)   uif_amt,
               action_information11    EMP201_status,
               action_information12    cnt_paye_perm,
               action_information13    cnt_paye_non_perm,
               action_information14    raise_warning,
               action_information15    asg_terminated,
               action_information16    assignment_no
        from pay_action_information pai
           , pay_assignment_actions paa
        where paa.payroll_action_id = p_archive_pact
          and pai.action_context_id = paa.assignment_action_id
          and pai.action_context_type = 'AAP'
          and pai.action_information_category = 'ZA EMP201 ASSIGNMENT DETAILS'
          order by employee_number,emp_name;


    type emp is record (
        employee_number varchar2(30),
        asg_no varchar2(30),
        emp_name varchar2(350)
    ) ;

    type defaulting_emp_tab is TABLE of emp index by binary_integer ;

    defaulting_emp_rec defaulting_emp_tab ;

    defaulting_asg_count number := 0 ;

    l_clob                  CLOB;
    l_str1 varchar2(200);
    l_archive_pact number ;
    l_proc_name constant varchar2(200) := g_package || 'get_emp201_xml' ;

    l_payroll_id number ;
    l_payroll_name varchar2(80) ;
    l_payroll_prd varchar2(30) ;

    l_first_asgn_rec boolean := true ;

    l_emp_rec_printed boolean := false ;

    l_tot_paye_rem number := 0 ;
    l_tot_paye number := 0 ;
    l_tot_leviable_amt number := 0 ;
    l_tot_sdl_amt number := 0;
    l_tot_uif_rem number := 0;
    l_tot_uif_amt number := 0 ;

    l_cnt_paye_perm number := 0 ;
    l_cnt_paye_non_perm number := 0;
    l_cnt_sdl number := 0 ;
    l_cnt_uif number := 0 ;
    l_control_tot number := 0 ;

    l_xml_element_count number := 0 ;
 BEGIN
  -- hr_utility.trace_on(null,'ZAEMP201');
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  g_xml_element_table.DELETE;
  ---
  -- Start XML
  ---
  g_xml_element_table(l_xml_element_count).tagname  := 'EMP201';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  l_xml_element_count := l_xml_element_count + 1;


  ---
  -- Payroll Data
  ---
  l_archive_pact := substr(EMP201_FILE_PREPROCESS,instr(EMP201_FILE_PREPROCESS,'=')+1);

  open csr_get_emp201_payroll_data(l_archive_pact) ;
  fetch csr_get_emp201_payroll_data into l_payroll_id
                                       , l_payroll_name
                                       , l_payroll_prd ;

  close csr_get_emp201_payroll_data ;

  hr_utility.set_location(l_proc_name, 20);

  g_xml_element_table(l_xml_element_count).tagname  := 'Payroll Information';
  g_xml_element_table(l_xml_element_count).tagvalue := '_COMMENT_';
  l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'PAYROLL_NAME';
    g_xml_element_table(l_xml_element_count).tagvalue := l_payroll_name;
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'PAYROLL_PRD';
    g_xml_element_table(l_xml_element_count).tagvalue := l_payroll_prd;
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'DETAIL_FLAG';
    g_xml_element_table(l_xml_element_count).tagvalue := p_detail_flag;
    l_xml_element_count := l_xml_element_count + 1;

    hr_utility.set_location(l_proc_name, 30);
    ---
    -- Employees Data
    ---

  for ass in csr_get_emp201_asg_data (l_archive_pact)
  loop
        hr_utility.trace('Assignment_id : '||ass.assignment_id);

        /* 1. Dont display employee records if the employee is terminated and has not earned any
              late payment, and hence dont count them in permanent/non-permanent.
           2. In case of non-permanent employees with no remuneration, dont display in the report
              and hence dont count them in permanent/non-permanent. */
        if (((ass.cnt_paye_non_perm is null and ass.cnt_paye_perm is null) OR ass.asg_terminated='Y')
          AND (ass.paye_remuneration = 0 and ass.tax = 0 and ass.leviable_amt = 0 and ass.sdl_amt = 0
                and ass.uif_remuneration = 0 and ass.uif_amt = 0 ))
        then
           null;
        else
        if p_detail_flag = 'Y' then
            hr_utility.set_location(l_proc_name, 100);
            if l_first_asgn_rec then
                -- Add <ALL_EMP> start tag before the first assignment
                g_xml_element_table(l_xml_element_count).tagname  := 'Employees Information';
                g_xml_element_table(l_xml_element_count).tagvalue := '_COMMENT_';
                l_xml_element_count := l_xml_element_count + 1;

                g_xml_element_table(l_xml_element_count).tagname  := 'ALL_EMP';
                g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
                l_xml_element_count := l_xml_element_count + 1;

                l_first_asgn_rec := false;
                l_emp_rec_printed := true ;
            end if ;

            hr_utility.set_location(l_proc_name, 110);

            -- Employees Data will come here
            hr_utility.set_location(l_proc_name, 130);
            g_xml_element_table(l_xml_element_count).tagname  := 'EMP';
            g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'EMP_NO';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.employee_number;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'EMP_NAME';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.emp_name;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'PAYE_REMUNERATION';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.paye_remuneration;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'PAYE';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.tax;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'LEVIABLE_AMT';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.leviable_amt;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'SDL_AMT';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.sdl_amt;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'UIF_REMUNERATION';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.uif_remuneration;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'UIF_AMT';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.uif_amt;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'CATEGORY';
            g_xml_element_table(l_xml_element_count).tagvalue := ass.EMP201_status;
            l_xml_element_count := l_xml_element_count + 1;

            g_xml_element_table(l_xml_element_count).tagname  := 'EMP';
            g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
            l_xml_element_count := l_xml_element_count + 1;
        end if ; -- End of p_detail_flag = 'Y'

        l_tot_paye_rem := l_tot_paye_rem + ass.paye_remuneration ;
        l_tot_paye := l_tot_paye + ass.tax ;
        l_tot_leviable_amt := l_tot_leviable_amt + ass.leviable_amt ;
        l_tot_sdl_amt := l_tot_sdl_amt + ass.sdl_amt ;
        l_tot_uif_rem := l_tot_uif_rem + ass.uif_remuneration ;
        l_tot_uif_amt := l_tot_uif_amt + ass.uif_amt ;

        hr_utility.set_location(l_proc_name, 140);
        if ass.cnt_paye_perm = 'Y' then
            l_cnt_paye_perm := l_cnt_paye_perm + 1 ;
        end if ;

        if ass.cnt_paye_non_perm = 'Y' then
            l_cnt_paye_non_perm := l_cnt_paye_non_perm + 1 ;
        end if ;

        if fnd_number.canonical_to_number(ass.sdl_amt) > 0 then
           l_cnt_sdl := l_cnt_sdl + 1 ;
        end if ;

        if fnd_number.canonical_to_number(ass.uif_amt) > 0 then
           l_cnt_uif := l_cnt_uif + 1 ;
        end if ;

        end if ; -- end of rem and amt <>0 */

        hr_utility.set_location(l_proc_name, 150);
        if ass.raise_warning = 'Y' then
            defaulting_asg_count := defaulting_asg_count + 1;
            defaulting_emp_rec(defaulting_asg_count).employee_number := ass.employee_number ;
            defaulting_emp_rec(defaulting_asg_count).asg_no   := ass.assignment_no;
            defaulting_emp_rec(defaulting_asg_count).emp_name := ass.emp_name ;
            hr_utility.set_location(l_proc_name, 160);
        end if ;

  end loop ;

    if l_emp_rec_printed = true then
         -- if <ALL_EMP> tag was printed, then close it now ( after all employees
         -- data has been printed
         g_xml_element_table(l_xml_element_count).tagname  := 'ALL_EMP';
         g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
         l_xml_element_count := l_xml_element_count + 1;
         hr_utility.set_location(l_proc_name, 170);
    end if;

    l_control_tot := l_tot_paye + l_tot_sdl_amt + l_tot_uif_amt ;

    ---
    -- Print totals
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Totals';
    g_xml_element_table(l_xml_element_count).tagvalue := '_COMMENT_';
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'TOT_PAYE_REM';
    g_xml_element_table(l_xml_element_count).tagvalue := formatted_canonical(l_tot_paye_rem);
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'TOT_PAYE';
    g_xml_element_table(l_xml_element_count).tagvalue := formatted_canonical(l_tot_paye);
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'TOT_LEVIABLE_AMT';
    g_xml_element_table(l_xml_element_count).tagvalue := formatted_canonical(l_tot_leviable_amt);
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'TOT_SDL_AMT';
    g_xml_element_table(l_xml_element_count).tagvalue := formatted_canonical(l_tot_sdl_amt);
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'TOT_UIF_REM';
    g_xml_element_table(l_xml_element_count).tagvalue := formatted_canonical(l_tot_uif_rem);
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'TOT_UIF_AMT';
    g_xml_element_table(l_xml_element_count).tagvalue := formatted_canonical(l_tot_uif_amt);
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'CONTROL_TOTAL';
    g_xml_element_table(l_xml_element_count).tagvalue := formatted_canonical(l_control_tot);
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'Employee Counts';
    g_xml_element_table(l_xml_element_count).tagvalue := '_COMMENT_';
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'CNT_PAYE_PERM';
    g_xml_element_table(l_xml_element_count).tagvalue := l_cnt_paye_perm;
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'CNT_PAYE_NON_PERM';
    g_xml_element_table(l_xml_element_count).tagvalue := l_cnt_paye_non_perm;
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'CNT_SDL';
    g_xml_element_table(l_xml_element_count).tagvalue := l_cnt_sdl;
    l_xml_element_count := l_xml_element_count + 1;

    g_xml_element_table(l_xml_element_count).tagname  := 'CNT_UIF';
    g_xml_element_table(l_xml_element_count).tagvalue := l_cnt_uif;
    l_xml_element_count := l_xml_element_count + 1;

    hr_utility.set_location(l_proc_name, 180);

    -------WARNING PAGE ------------------------------
    if defaulting_asg_count > 0 then
         hr_utility.set_location(l_proc_name, 190);
         g_xml_element_table(l_xml_element_count).tagname  := 'Warning Page';
         g_xml_element_table(l_xml_element_count).tagvalue := '_COMMENT_';
         l_xml_element_count := l_xml_element_count + 1;

         g_xml_element_table(l_xml_element_count).tagname  := 'PG_BRK';
         g_xml_element_table(l_xml_element_count).tagvalue := 'Y';
         l_xml_element_count := l_xml_element_count + 1;

         g_xml_element_table(l_xml_element_count).tagname  := 'WARN';
         g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
         l_xml_element_count := l_xml_element_count + 1;

         g_xml_element_table(l_xml_element_count).tagname  := 'HEADER_LINE';
         g_xml_element_table(l_xml_element_count).tagvalue := 'The following Employees do not ' ||
                     'have a SITE / PAYE split. Please process a final payroll run, a tax override or ' ||
                     'a tax balance adjustment for these employees to ensure correct Tax Year End reporting:';
         l_xml_element_count := l_xml_element_count + 1;
    end if ;

    hr_utility.set_location(l_proc_name, 200);
    for i in 1 .. defaulting_emp_rec.count
    loop
          g_xml_element_table(l_xml_element_count).tagname  := 'WARN_EMP';
          g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
          l_xml_element_count := l_xml_element_count + 1;

          g_xml_element_table(l_xml_element_count).tagname  := 'EMP_NUM';
          g_xml_element_table(l_xml_element_count).tagvalue := defaulting_emp_rec(i).employee_number;
          l_xml_element_count := l_xml_element_count + 1;

          g_xml_element_table(l_xml_element_count).tagname  := 'ASG_NUM';
          g_xml_element_table(l_xml_element_count).tagvalue := defaulting_emp_rec(i).asg_no;
          l_xml_element_count := l_xml_element_count + 1;

          g_xml_element_table(l_xml_element_count).tagname  := 'EMP_NAME';
          g_xml_element_table(l_xml_element_count).tagvalue := defaulting_emp_rec(i).emp_name ;
          l_xml_element_count := l_xml_element_count + 1;

          g_xml_element_table(l_xml_element_count).tagname  := 'WARN_EMP';
          g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
          l_xml_element_count := l_xml_element_count + 1;
    end loop ;
    hr_utility.set_location(l_proc_name,220);

    if defaulting_asg_count > 0 then
        g_xml_element_table(l_xml_element_count).tagname  := 'WARN';
        g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
        l_xml_element_count := l_xml_element_count + 1;
    end if ;

    ---
    -- End XML
    ---
    g_xml_element_table(l_xml_element_count).tagname  := 'EMP201';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    write_to_clob(p_xml);
    --
    hr_utility.set_location(l_proc_name, 999);
    hr_utility.set_location('Leaving ' || l_proc_name, 1000);

 END get_emp201_xml ;

END PAY_ZA_EMP201 ;

/
