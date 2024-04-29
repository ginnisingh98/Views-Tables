--------------------------------------------------------
--  DDL for Package Body PAY_GB_HIST_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_HIST_ARCH_PKG" AS
/* $Header: pygbpupg.pkb 120.0.12010000.2 2009/03/13 15:36:07 krreddy noship $ */

/**------------------------------------------------------------
** Name      : get_parameters
** Purpose   : This procedure returns the value of the given parameter name.
**----------------------------------------------------------**/

procedure get_parameters(p_payroll_action_id in  number,
                         p_token_name        in  varchar2,
                         p_token_value       out NOCOPY varchar2) is

    cursor csr_parameter_info(p_pact_id number,
                              p_token   char) is
              select pay_core_utils.get_parameter(p_token,legislative_parameters)
                from pay_payroll_actions
               where payroll_action_id = p_pact_id;

l_token_value                     varchar2(50) := null;

begin

  hr_utility.trace('Entering get_parameters');

  hr_utility.set_location('p_token_name: ' || p_token_name,10);

  open csr_parameter_info(p_payroll_action_id,
                          p_token_name);
  fetch csr_parameter_info into l_token_value;
  close csr_parameter_info;

  p_token_value := l_token_value;

  hr_utility.set_location('l_token_value: ' || l_token_value,20);

  hr_utility.trace('Leaving get_parameters');
exception
  when OTHERS
  then
    hr_utility.set_location('Exception occured in get_parameters: '||SQLERRM,30);
    raise;
end get_parameters;

/**------------------------------------------------------------
** Name      : range_cursor
** Purpose   : This procedure returns an SQL statement to select all the
**             people that may be eligible for payslip reports.
**             The archiver uses this cursor to split the people into chunks
**             for parallel processing.
**----------------------------------------------------------**/
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

l_payroll_id                      number := null;

begin

  hr_utility.trace('Entering range_cursor');

  pay_gb_hist_arch_pkg.get_parameters (
    p_payroll_action_id => pactid
  , p_token_name        => 'PAYROLL_NAME'
  , p_token_value       => l_payroll_id);

  hr_utility.set_location('l_payroll_id = ' || l_payroll_id,20);

    if l_payroll_id is null then
     --
     -- Use full cursor not restricting by payroll
     --
       hr_utility.trace('Range Cursor Not using Payroll Restriction');
       sqlstr := 'SELECT DISTINCT person_id
                 FROM   per_people_f ppf,
                        pay_payroll_actions ppa
                 WHERE  ppa.payroll_action_id = :payroll_action_id
                 AND    ppa.business_group_id +0= ppf.business_group_id
                 ORDER BY ppf.person_id';
    else
     --
     -- The Payroll ID was used as parameter, so restrict by this
     --
       hr_utility.trace('Range Cursor using Payroll Restriction');
       sqlstr := 'SELECT DISTINCT ppf.person_id
                  FROM   per_all_people_f ppf,
                         pay_payroll_actions ppa,
                         per_all_assignments_f paaf
                  WHERE  ppa.payroll_action_id = :payroll_action_id
                  AND    ppf.business_group_id +0 = ppa.business_group_id
                  AND    paaf.person_id = ppf.person_id
                  AND    paaf.payroll_id = '|| to_char(l_payroll_id)||
                 ' ORDER BY ppf.person_id';
  end if;

  hr_utility.trace('Leaving range_cursor');
exception
  when OTHERS
  then
    sqlstr := 'select 1 '||
              '/* ERROR - Employer Details Fetch failed with: '||
              sqlerrm(sqlcode)||' */ '||
              'from dual where to_char(:payroll_action_id) = dummy';

    hr_utility.set_location('Exception occured in range_cursor: '||SQLERRM,30);
    raise;
end range_cursor;

/**------------------------------------------------------------
** Name      : action_creation
** Purpose   : This procedure fetches archived assignment_action_id's
**             from archive table and creates a new temp assignment_action_id
**             for each of them. This new temp id along with the archived id
**             will be inserted into pay_temp_object_actions.
**----------------------------------------------------------**/
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  cursor get_assignment_id (cp_payroll_id number,
                            cp_bg_id number,
                            cp_start_date varchar2,
                            cp_end_date varchar2 ) is

  select distinct paa.assignment_action_id,
                  paaf.assignment_id,
                  ppa.effective_date
   from per_all_assignments_f paaf,
        pay_payroll_actions ppa,
        pay_assignment_actions paa,
        pay_action_interlocks lck,
        pay_payroll_actions ppa1,
        pay_assignment_actions paa1
  where paa.SOURCE_ACTION_ID is null
    and paaf.person_id between stperson
			                        and endperson
    and ppa.report_type = 'UKPS'
    and ppa.action_type ='X'
    and paa.assignment_id = paaf.assignment_id
    and paaf.business_group_id = cp_bg_id
    and ppa.payroll_action_id = paa.payroll_action_id
    and ppa.start_date between fnd_date.canonical_to_date(cp_start_date)
                           and fnd_date.canonical_to_date(cp_end_date)
    and ppa.report_qualifier = 'GB'
    and ppa.report_category = 'ARCHIVE'
    and ppa.business_group_id = paaf.business_group_id
    and paa.action_status = 'C'
    and lck.locking_action_id = paa.assignment_action_id
    and lck.locked_action_id = paa1.assignment_action_id
    and ppa1.payroll_action_id = paa1.payroll_action_id
    and ppa1.action_status = 'C'
    and ppa1.payroll_id = nvl(cp_payroll_id,ppa1.payroll_id)
    and ppa1.business_group_id = ppa.business_group_id
    and ppa1.action_type IN ('U','P')
    and not exists (
                    select 1
                      from pay_action_information pai
                     where pai.action_context_id = paa.assignment_action_id
                   	   and pai.action_context_type = 'AAP'
                   	   and pai.assignment_id = paa.assignment_id
                       and pai.action_information_category = 'GB ELEMENT PAYSLIP INFO')
    ;

    l_start_date varchar2(30);
	l_end_date varchar2(30);
    l_payroll_id number := null;
    l_bg_id number := null;
	lockingactid  varchar2(100);
	begin
   hr_utility.trace('Entering action_creation' );

   get_parameters(pactid,'PAYROLL_NAME',l_payroll_id);
   get_parameters(pactid,'P_START_DATE',l_start_date);
   get_parameters(pactid,'P_END_DATE',l_end_date);

    select business_group_id
    into l_bg_id
    from pay_payroll_actions
    where payroll_action_id = pactid;

   hr_utility.set_location('l_payroll_id :' ||l_payroll_id ,10);
   hr_utility.set_location('l_start_date :' ||l_start_date ,10);
   hr_utility.set_location('l_end_date :' ||l_end_date ,10);
   hr_utility.set_location('l_bg_id :' ||l_bg_id ,10);
   hr_utility.set_location('stperson :' ||stperson ,10);
   hr_utility.set_location('endperson :' ||endperson ,10);

   for asgrec in get_assignment_id(l_payroll_id,l_bg_id,l_start_date,l_end_date)
   loop
   	  select pay_assignment_actions_s.nextval
           into   lockingactid
           from   dual;

            hr_nonrun_asact.insact
               (
                  lockingactid => lockingactid,
                  assignid     => asgrec.assignment_id,
                  pactid       => pactid,
                  chunk        => chunk,
                  object_type  => 'ASG',
                  object_id    => asgrec.assignment_action_id
                );
  end loop;
   hr_utility.trace('Leaving action_creation' );
exception
  when OTHERS
  then
    hr_utility.set_location('Exception occured in action_creation: '||SQLERRM,30);
    raise;
end action_creation;

procedure archinit(p_payroll_action_id in number) is
begin
hr_utility.trace('Entering archinit');
   null;
hr_utility.trace('Leaving archinit');
end archinit;

/**------------------------------------------------------------
** Name      : archive_historic_data
** Purpose   : This procedure gets the archived assignment_action_id from
**             pay_temp_object_actions and passes it to the
**             get_pay_deduct_element_info procedure to archive payments and
**             deductions data.
**----------------------------------------------------------**/

procedure archive_historic_data (p_assactid       in number,
                                 p_effective_date in date) IS

    cursor get_archive_asg_id is
	select ptoa.object_id assignment_action_id
	  from pay_temp_object_actions ptoa
	 where object_action_id = p_assactid;

    l_assignment_action_id pay_assignment_actions.assignment_Action_id%type;
begin

	hr_utility.trace('Entering archive_historic_data');
	hr_utility.set_location('Current assignment_action_id - p_assactid: '
                            || p_assactid, 10);

    --getting the archived assignment_action_id

	   open get_archive_asg_id;
            fetch get_archive_asg_id into l_assignment_action_id;
       close get_archive_asg_id;

	hr_utility.set_location('Archived assignment_action_id - l_assignment_action_id: '
                            || l_assignment_action_id, 20);

    --Calling archive procedure to archive payments and deductions details for
        --this assignment_action_id
    PAY_GB_PAYSLIP_ARCHIVE.get_pay_deduct_element_info(l_assignment_action_id);

	hr_utility.trace('Leaving archive_historic_data');
exception
  when OTHERS
  then
    hr_utility.set_location('Exception occured in archive_historic_data: '||SQLERRM,30);
    raise;
end archive_historic_data;

END pay_gb_hist_arch_pkg;

/
