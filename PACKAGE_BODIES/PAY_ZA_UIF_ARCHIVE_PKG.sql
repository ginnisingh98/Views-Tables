--------------------------------------------------------
--  DDL for Package Body PAY_ZA_UIF_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_UIF_ARCHIVE_PKG" as
/* $Header: pyzauifa.pkb 120.2.12010000.2 2008/08/06 08:48:44 ubhat ship $ */
/*
 +======================================================================+
 | Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA|
 |                       All rights reserved.                           |
 +======================================================================+
 SQL Script File name : pyzauifa.pkb
 Description          : This sql script seeds the Package Body that
                        creates the UIF Archive code

 Change List:
 ------------

 Name           Date        Version  Bug     Text
 -------------- ----------- -------  ------  -----------------------------
 L.Kloppers     21-Apr-2002   115.0  2266156 Initial Version
 L.Kloppers     02-May-2002   115.1  2266156 Modified Employee Cursor
 L.Kloppers     06-May-2002   115.2  2266156 Replaced global variables with
                                            local procedure variables
                                            to allow for multi-threading
 L.Kloppers     06-May-2002   115.3  2266156 Replaced Nature of Person
                                            Lookup Meaning with Codes in
                                            action_creation procedure
 L.Kloppers     06-May-2002   115.4  2266156 Replaced global variables with
                                             local procedure variables
 L.Kloppers     08-May-2002   115.5  2266156 Modified to allow for multiple
                                             archives per UIF Month
 L.Kloppers     09-May-2002   115.6  2266156 Added range_cursor_mag for UIF File
 J.N. Louw      13-Jun-2002   115.7  2411444 ID_FLEX_STRUCTURE_CODE reference added
 J.N. Louw      17-Jun-2002   115.8  2420012 Id Flex select corrected
 Nirupa S       10-Dec-2002   115.10 2686708 Added NOCOPY
 Nageswara Rao  24-Jan-2003   115.11 2654703 Added new function
                                             get_uif_total_remu_sub_uif
 Nageswara Rao  13-Feb-2003   115.12 2798916 Changed query in Action Creation
                                             procedure
 Nageswara Rao  14-Feb-2003   115.13         Changes to query in Action Creation
                                             procedure to select all Employees
                                             in a payroll run
 Nageswara Rao  10-Apr-2003   115.15 2874102 changes to obsolete reason_non_contrib
                                             code '07'
                                     2863938 when first_name is null, archive 'XXX'
 Kaladhaur P    05-Oct-2004   115.16 3869426 Modified query in Action Creation to
                                             include future terminated employees
                                             to Electronic UIF File
 A. Mahanty     23-DEC-2004   115.18 4072410 An extra condition was added for an Employee
                                             having a non-contribution reason of 01 and with
                                             a value in the UIF Employee Contribution balance.
                                             No non-contribution reason must be written to the
                                             UIF File for such cases.
 A. Mahanty     14-FEB-2004   115.19 4134166 The Monthly UIFable Limit calculation was changed.
                                             Two cursors csr_pay_periods_per_year and
                                             csr_pay_periods_per_month were added.The cursor
                                             csr_uif_limit was modified.
                                     4140343 An additional condition was added to set to zero the
                                             balance values for an employee who has not been processed
                                             even once in a month.All eligible employees are included
                                             in the UIF File, even if they are not processed.
 Kaladhaur P    22-Apr-2005   115.20 4306265 Modified the cursor csr_employee_data in archive_data.
                                             Modified the parameter value passed to csr_employee_data
                                             inorder to fetch date effective data.
 Kaladhaur P    15-Sep-2005   115.20 4612798 R12 Performance Bug Fix. Tuned the query in the cursor
                                             csr_latest_asg_action.
 A. Mahanty     19-Dec-2005   115.22 4768622 R12 Performance Bug Fix. Modified the query in the
                                             procedure archive_data.
 P.Arusia       16-Jul-2008   115.23 7255839 If reason for UIF non-contribution is 007, then report
                                             it as 07
 ========================================================================
*/
sql_range          varchar2(4000);
prev_asg_id        number;

g_total_gross_tax_rem    number;
g_total_uif_contribution number;

/* changes as per2654703 */
g_total_remu_sub_uif     number;

g_total_no_emps          number;

g_archive_pact             number;
g_archive_effective_date   date;
g_package                  constant varchar2(30) := 'pay_za_uif_archive_pkg.';
g_canonical_end_date       date;
g_canonical_start_date     date;
g_business_group_id        number;

g_asg_set_id               number;
g_person_id                number;


/*--------------------------------------------------------------------------
  Name      : get_parameters
  Purpose   : This retrieves legislative parameters from the payroll action.
  Arguments :
--------------------------------------------------------------------------*/
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

l_business_group_id            varchar2(20);
l_token_value                  varchar2(50);

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
   fetch csr_parameter_info into l_token_value, l_business_group_id;
   close csr_parameter_info;

   if p_token_name = 'BG_ID' then

      p_token_value := l_business_group_id;

   else

      p_token_value := l_token_value;

   end if;

   hr_utility.set_location('l_token_value = ' || p_token_value, 20);
   hr_utility.set_location('Leaving         ' || l_proc, 30);
--
exception
   when others then
   p_token_value := null;
--
end get_parameters;


/*--------------------------------------------------------------------------
  Name      : get_balance_value
  Purpose   : This returns the Balance Value for a 'ZA' Balance
  Arguments : Assignment Action, Balance Name and Balance Dimension
  Notes     :
--------------------------------------------------------------------------*/
function get_balance_value
   (
   p_assignment_id in per_all_assignments_f.assignment_id%type,
   p_balance_name in pay_balance_types.balance_name%type,
   p_dimension in pay_balance_dimensions.dimension_name%type,
   p_effective_date in date
   )
return number is

   cursor csr_latest_asg_action is
   select paa.assignment_action_id
     from pay_assignment_actions paa
    where paa.assignment_id = p_assignment_id
      and paa.rowid =
        (
          select substr(
                         max(lpad(paa2.action_sequence, 15, 0) || paa2.rowid)
                         , -length(paa2.rowid)
                       )
            from pay_payroll_actions    ppa2
               , pay_assignment_actions paa2
           where paa2.assignment_id      = p_assignment_id
             and ppa2.payroll_action_id  = paa2.payroll_action_id
             and ppa2.action_type       in ('R', 'Q', 'I', 'B', 'V')
             and ppa2.effective_date    >= (add_months(p_effective_date, -1)+1) /*g_canonical_start_date*/
             and ppa2.effective_date    <= p_effective_date /*g_canonical_end_date*/
           group by length(paa2.rowid)
        );

   l_latest_asg_action  pay_assignment_actions.assignment_action_id%type;
   l_defined_bal_id     pay_defined_balances.defined_balance_id%type;
   l_balance_value      number;


   l_proc   varchar2(50) := g_package || 'get_balance';

begin

   hr_utility.set_location('Entering '|| l_proc,10);

   open csr_latest_asg_action;
   fetch csr_latest_asg_action into l_latest_asg_action;
   close csr_latest_asg_action;

   hr_utility.set_location(g_package||'get_balance',20);

   -- Set the Payroll Action ID context to the last Payroll Action
   -- that the assignment were processed in
   pay_balance_pkg.set_context
   (
      'PAYROLL_ACTION_ID',
      l_latest_asg_action
   );

   select def.defined_balance_id
     into l_defined_bal_id
     from pay_defined_balances def,
          pay_balance_types pbt,
          pay_balance_dimensions dim,
          pay_balance_types_tl pbt_tl
    where pbt_tl.balance_name = p_balance_name
      and pbt_tl.language = 'US'
      and pbt_tl.balance_type_id = pbt.balance_type_id
      and pbt.legislation_code = 'ZA'
      and dim.dimension_name = p_dimension
      and dim.legislation_code = 'ZA'
      and pbt.balance_type_id = def.balance_type_id
      and dim.balance_dimension_id = def.balance_dimension_id
      and def.legislation_code = 'ZA';


   hr_utility.set_location('Step ' || l_proc, 30);
   hr_utility.set_location('l_latest_asg_action = ' || l_latest_asg_action, 30);
   hr_utility.set_location('l_balance        = ' || p_balance_name, 30);
   hr_utility.set_location('l_dimension      = ' || p_dimension, 30);
   hr_utility.set_location('l_defined_bal_id = ' || l_defined_bal_id, 30);

   --Bug 4140343
   --If an active or suspended assignment is not processed in a particular month then
   --the balances values (dimension = _ASG_TAX_MTD ) are set to 0 and the employee is shown on the
   --reported on the UIF File
   if l_latest_asg_action is NOT NULL then

   l_balance_value := pay_balance_pkg.get_value
                      (
                         p_defined_balance_id   => l_defined_bal_id,
                         p_assignment_action_id => l_latest_asg_action
                      );

   hr_utility.set_location('l_balance_value = ' || l_balance_value, 40);

   else
   l_balance_value := 0;

   end if;

   return l_balance_value;

exception
   when others then
      hr_utility.set_location(l_proc,50);
      hr_utility.set_message(801,'Sql Err Code: '||to_char(sqlcode));
      hr_utility.raise_error;

end get_balance_value;


/*--------------------------------------------------------------------------
  Name      : range_cursor
  Purpose   : This returns the select statement that is used to created the
              range rows.
  Arguments :
  Notes     : The range cursor determines which people should be processed.
              The normal practice is to include everyone, and then limit
              the list during the assignment action creation.
--------------------------------------------------------------------------*/
procedure range_cursor
(
   pactid in  number,
   sqlstr out nocopy varchar2
)  is

-- Returns Creator Information for the specified UIF Month that has not been archived yet
cursor csr_creator_info is
   select hoi.org_information1,
          hoi.org_information2,
          hoi.org_information3,
          hoi.org_information4
     from hr_organization_information   hoi
        , hr_all_organization_units     org
    where hoi.org_information_context = 'ZA_UIF_CREATOR_INFO'
      and hoi.organization_id = org.organization_id
      and org.organization_id = g_business_group_id;
/*Commented out the following to allow re-archiving*/
/*
      and not exists
          (
           select null
             from pay_action_information pai
             , pay_payroll_actions ppa
            where pai.action_context_type = 'PA'
              and pai.action_information_category = 'ZA UIF CREATOR DETAILS'
              and pai.action_information1 = g_business_group_id
              and pai.action_information2 = to_char(g_canonical_end_date, 'YYYYMM')
           and ppa.payroll_action_id = pai.action_context_id
        )
*/

cursor csr_archive_effective_date(pactid number) is
   select effective_date
     from pay_payroll_actions
    where payroll_action_id = pactid;

l_payroll_id                   number;
l_start_date                   varchar2(30);
l_end_date                     varchar2(30);
l_bg_id                        number;
l_canonical_end_date           date;
l_canonical_start_date         date;

l_creator_uif_reference hr_organization_information.org_information1%type;
l_contact_person        hr_organization_information.org_information2%type;
l_contact_number        hr_organization_information.org_information3%type;
l_contact_email_address hr_organization_information.org_information4%type;

l_action_info_id number;
l_ovn            number;

l_proc       varchar2(50) := g_package || 'range_cursor';

begin

   --hr_utility.trace_on(null, 'UIF');

   hr_utility.set_location('Entering ' || l_proc, 10);
   hr_utility.trace('Entering ' || l_proc);

   g_archive_pact := pactid;   -- Payroll Action of the Archiver

   hr_utility.trace('g_archive_pact: ' || to_char(g_archive_pact));


   -- Get the effective date of the payroll action
   open csr_archive_effective_date(pactid); -- Payroll Action of the Archiver
      fetch csr_archive_effective_date
      into g_archive_effective_date;
   close csr_archive_effective_date;

   -- Retrieve the legislative parameters from the payroll action
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


   select get_parameter('START_DATE', legislative_parameters)
     into l_start_date
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('END_DATE', legislative_parameters)
     into l_end_date
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('BG_ID', legislative_parameters)
     into l_bg_id
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('ASG_SET_ID', legislative_parameters)
     into g_asg_set_id
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('PERSON_ID', legislative_parameters)
     into g_person_id
     from pay_payroll_actions
    where payroll_action_id = pactid;

   g_canonical_start_date := to_date(l_start_date,'yyyy/mm/dd');
   g_canonical_end_date   := to_date(l_end_date,'yyyy/mm/dd');

   g_business_group_id    := l_bg_id;

   hr_utility.set_location('Step ' || l_proc, 20);
   hr_utility.set_location('l_payroll_id = ' || l_payroll_id, 20);
   hr_utility.set_location('l_start_date = ' || l_start_date, 20);
   hr_utility.set_location('l_end_date   = ' || l_end_date,   20);
   hr_utility.set_location('g_business_group_id = ' || g_business_group_id,   20);
   hr_utility.set_location('g_asg_set_id = ' || g_asg_set_id,   20);
   hr_utility.set_location('g_person_id  = ' || g_person_id,   20);

   hr_utility.set_location('g_canonical_start_date = ' || g_canonical_start_date, 20);
   hr_utility.set_location('g_canonical_end_date   = ' || g_canonical_end_date, 20);


   -- Archive Creator Information that have not been archived yet for the specified UIF Month
   open csr_creator_info;
      fetch csr_creator_info
      into l_creator_uif_reference,
           l_contact_person,
           l_contact_number,
           l_contact_email_address;

      if csr_creator_info%notfound
      then

         hr_utility.set_location('ZA UIF CREATOR DETAILS does not exist', 21);

      else

         hr_utility.set_location('Calling arch_pay_action_level_data', 25);

         hr_utility.set_location('Archiving ZA UIF CREATOR DETAILS', 30);

         hr_utility.set_location('l_creator_uif_reference '||l_creator_uif_reference, 30);
         hr_utility.set_location('l_contact_person '||l_contact_person, 30);
         hr_utility.set_location('l_contact_number '||l_contact_number, 30);
         hr_utility.set_location('l_contact_email_address '||l_contact_email_address, 30);

         --Process UIF Ref. No.
         l_creator_uif_reference := process_uif_ref_no (l_creator_uif_reference);

         hr_utility.set_location('l_creator_uif_reference_processed '||l_creator_uif_reference, 30);

         -- Archive 'ZA UIF CREATOR DETAILS'
         pay_action_information_api.create_action_information
         (
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => pactid,
            p_action_context_type         => 'PA',
            p_object_version_number       => l_ovn,
            p_effective_date              => g_archive_effective_date,
            p_action_information_category => 'ZA UIF CREATOR DETAILS',
            p_action_information1         => g_business_group_id,
            p_action_information2         => to_char(g_canonical_end_date, 'YYYYMM'),
            p_action_information3         => l_payroll_id,
            p_action_information4         => l_creator_uif_reference /*Creator UIF Reference Number*/,
            p_action_information5         => l_contact_person /*Contact Person*/,
            p_action_information6         => l_contact_number /*Contact Number*/,
            p_action_information7         => l_contact_email_address /*Contact E-mail Address*/
         );

      end if;

   close csr_creator_info;


   sql_range :=
      'select distinct asg.person_id
         from per_assignments_f   asg,
              pay_payrolls_f      ppf,
              pay_payroll_actions ppa
        where ppa.payroll_action_id = :payroll_action_id
          and asg.business_group_id = ppa.business_group_id
          and asg.assignment_type   = ''E''
          and ppf.payroll_id        = asg.payroll_id
          and ppf.payroll_id        = ppa.payroll_id
        order by asg.person_id';

   sqlstr := sql_range;

   hr_utility.set_location('Leaving ' || l_proc, 10);

   --hr_utility.trace_off;
--
exception
   when others then
   sqlstr := null;
--
end range_cursor;


/*--------------------------------------------------------------------------
  Name      : range_cursor_mag
  Purpose   : This returns the select statement that is used to created the
              range rows for the UIF File.
  Arguments :
  Notes     : The range cursor determines which people should be processed.
              The normal practice is to include everyone, and then limit
              the list during the assignment action creation.
--------------------------------------------------------------------------*/
procedure range_cursor_mag
(
   pactid in  number,
   sqlstr out nocopy varchar2
)  is

sql_range    varchar2(4000);

l_proc       varchar2(50) := g_package || 'range_cursor_mag';

begin

   --hr_utility.trace_on(null, 'UIF');

   hr_utility.set_location('Entering ' || l_proc, 10);

   sql_range :=
      'select distinct asg.person_id
         from per_assignments_f   asg,
              pay_payrolls_f      ppf,
              pay_payroll_actions ppa
        where ppa.payroll_action_id = :payroll_action_id
          and asg.business_group_id = ppa.business_group_id
          and asg.assignment_type   = ''E''
          and ppf.payroll_id        = asg.payroll_id
          and ppf.payroll_id        = ppa.payroll_id
        order by asg.person_id';

   sqlstr := sql_range;

   hr_utility.set_location('Leaving ' || l_proc, 10);

   --hr_utility.trace_off;
--
exception
   when others then
   sqlstr := null;
--
end range_cursor_mag;


/*--------------------------------------------------------------------------
  Name      : action_creation
  Purpose   : This creates the assignment actions for a specific chunk.
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
procedure action_creation
(
   pactid    in number,
   stperson  in number,
   endperson in number,
   chunk     in number
) is

-- This cursor returns all Assignments that are active during,
-- or that ends in this UIF Month (not before). It excludes Independent
-- Contractors and specific Nature of Person assignments.
-- Note: There is no outer join to per_assignment_extra_info, as it is
--       mandatory that an Assignment must have a Legal Entity, which
--       must be entered on per_assignment_extra_info

/* Changes Bug 2798916 - Commenting existing query and rewriting the query */

  /* cursor csr_get_asg (p_pactid number
                    , p_stperson number
                    , p_endperson number
                    , p_canonical_start_date date
                    , p_canonical_end_date date) is
     select asg.person_id                person_id,
            asg.assignment_id            assignment_id
       from per_assignments_f            asg,
            per_assignments_f            asg3,
            --pay_payrolls_f               ppf, -- Bug 2608190
            pay_payroll_actions          ppa_arch,
            per_assignment_extra_info    paei,
            per_periods_of_service       pds -- Bug 2654703
      where asg.business_group_id = ppa_arch.business_group_id
        and asg.period_of_service_id = pds.period_of_service_id  -- Bug 2608190
        and asg3.period_of_service_id = pds.period_of_service_id -- Bug 2608190
        and asg.person_id between p_stperson and p_endperson
        and paei.assignment_id = asg.assignment_id
        and paei.aei_information_category = 'ZA_SPECIFIC_INFO'
        -- Not an Independent Contractor
        and nvl(paei.aei_information6, 'N') = 'N'
        -- Nature of Person not in the following ZA_PER_NATURES Lookup Values
        and paei.aei_information4 not in ('04', '05', '06', '07', '08', '09')
        and ppa_arch.payroll_action_id = p_pactid
        --and ppf.payroll_id = ppa_arch.payroll_id -- Bug 2608190
        --and asg.payroll_id = ppf.payroll_id      -- Bug 2608190
        and ppa_arch.payroll_id = asg.payroll_id   -- Bug 2608190
        --and ppa_arch.effective_date between ppf.effective_start_date -- Bug 2608190
        --                                and ppf.effective_end_date   -- Bug 2608190
        -- Get the Assignment End Date
        and asg.effective_end_date =
                (
                 select max(asg2.effective_end_date)
                   from per_assignments_f asg2
                      , per_assignment_status_types sta
                  where asg2.assignment_id = asg.assignment_id
                    and asg2.assignment_status_type_id = sta.assignment_status_type_id
                    and sta.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
                )
         -- Check that Assignment ends after UIF Month Start Date
        and ( asg.effective_end_date >= p_canonical_start_date
              or pds.final_process_date >= p_canonical_start_date ) -- Bug 2608190
         -- Get the Assignment Start Date
        and asg3.assignment_id = asg.assignment_id
        and asg3.effective_start_date =
                (
                 select min(asg4.effective_start_date)
                   from per_assignments_f asg4
                      , per_assignment_status_types sta
                  where asg4.assignment_id = asg3.assignment_id
                    and asg4.assignment_status_type_id = sta.assignment_status_type_id
                    and sta.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
                )
         -- Check that Assignment starts before UIF Month End Date
        and asg3.effective_start_date <= p_canonical_end_date
      order by 2
        for update of asg.assignment_id;
    */

    /* Changes Bug 2798916 - New query
       This Query will not take the records which falls after last standard process
       and before final process date and having UIF contributions zero
    */

cursor csr_get_asg (p_pactid number
                    , p_stperson number
                    , p_endperson number
                    , p_canonical_start_date date
                    , p_canonical_end_date date) is
	select ppf.person_id
	      ,paa.assignment_id
	  from per_all_people_f             ppf
	      ,per_all_assignments_f        paa
	      ,per_assignment_extra_info    paei
	      ,pay_payroll_actions          ppa_arch
	      ,per_periods_of_service       pps
	 where paa.business_group_id = ppa_arch.business_group_id
	   and paa.person_id = ppf.person_id
	   and ppf.person_id between p_stperson and p_endperson /* to select all Employees in a payroll run */
	   and paa.period_of_service_id = pps.period_of_service_id
	   and paei.assignment_id = paa.assignment_id
	   and ppa_arch.payroll_id = paa.payroll_id
	   and ppa_arch.payroll_action_id = p_pactid
	   and paei.aei_information_category = 'ZA_SPECIFIC_INFO'
	   /* Not an Independent Contractor */
	    and nvl(paei.aei_information6, 'N') = 'N'
	   /* Nature of Person not in the following ZA_PER_NATURES Lookup Values */
	   and paei.aei_information4 not in ('04', '05', '06', '07', '08', '09')
	   and ppf.effective_start_date = (	select max(effective_start_date)
						from   per_all_people_f ppf1
						where  ppf1.person_id = ppf.person_id
						and    ppf1.effective_start_date <= p_canonical_end_date
						and    ppf1.effective_end_date >= '01-MAR-' || to_number(to_char(p_canonical_end_date ,'YYYY') - 1))
	   and paa.effective_start_date = (	select max(paa1.effective_start_date)
						from   per_all_assignments_f paa1 where paa1.assignment_id = paa.assignment_id
						and    paa1.effective_start_date <= p_canonical_end_date
						and    paa1.effective_end_date >= '01-MAR-' || to_number(to_char(p_canonical_end_date ,'YYYY') - 1))
	   and
	    (
		(
		   pps.actual_termination_date is not null
		   and
		    (
			(
			    pps.actual_termination_date between '01-MAR-' || to_number(to_char(p_canonical_end_date ,'YYYY') - 1) and p_canonical_end_date
			    and
			     (
				pps.actual_termination_date between p_canonical_start_date and p_canonical_end_date
				or
				 (
					pps.actual_termination_date < p_canonical_start_date
			     		and nvl(pps.final_process_date,to_date('31-12-4712','DD-MM-YYYY')) >= p_canonical_start_date
					and pay_za_uif_archive_pkg.get_balance_value(paa.assignment_id,'Total UIFable Income','_ASG_TAX_MTD',p_canonical_end_date) <> 0
			   	 )
		      	     )
			)
			or pps.actual_termination_date > p_canonical_end_date  /* New Condition for Bug 3869426 */
		     )
		)
		or pps.actual_termination_date is null
	      )
	order by 2
 for update of paa.assignment_id;


l_payroll_id                   number;
l_consolidation_set            number;
l_assignment_set_id            number;

leg_param    pay_payroll_actions.legislative_parameters%type;
asg_include  boolean;
lockingactid number;
v_incl_sw    hr_assignment_set_amendments.include_or_exclude%type;

l_proc       varchar2(50) := g_package || 'action_creation';

l_start_date                   varchar2(30);
l_end_date                     varchar2(30);
l_bg_id                        number;
l_asg_set_id                   number;
l_person_id                    number;
l_canonical_end_date           date;
l_canonical_start_date         date;

l_persid number;
l_asgid  number;

begin

   --hr_utility.trace_on(null, 'UIF');

   hr_utility.set_location('Entering ' || l_proc, 10);

   select get_parameter('START_DATE', legislative_parameters)
     into l_start_date
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('END_DATE', legislative_parameters)
     into l_end_date
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('BG_ID', legislative_parameters)
     into l_bg_id
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('ASG_SET_ID', legislative_parameters)
     into l_asg_set_id
     from pay_payroll_actions
    where payroll_action_id = pactid;

   select get_parameter('PERSON_ID', legislative_parameters)
     into l_person_id
     from pay_payroll_actions
    where payroll_action_id = pactid;

   l_canonical_start_date := to_date(l_start_date,'yyyy/mm/dd');
   l_canonical_end_date   := to_date(l_end_date,'yyyy/mm/dd');

   hr_utility.set_location('pactid '||to_char(pactid), 10);
   hr_utility.set_location('l_person_id '||to_char(l_person_id), 10);
   hr_utility.set_location('l_asg_set_id '||to_char(l_asg_set_id), 10);
   hr_utility.set_location('stperson '||to_char(stperson), 10);
   hr_utility.set_location('endperson '||to_char(endperson), 10);
   hr_utility.set_location('l_canonical_start_date '||to_char(l_canonical_start_date, 'dd/mm/yyyy'), 10);
   hr_utility.set_location('l_canonical_end_date '||to_char(l_canonical_end_date, 'dd/mm/yyyy'), 10);

   if l_asg_set_id is not null then
       -- need to find out if assignments in assignment-set are set to Include or Exclude.
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

   for asgrec in csr_get_asg (pactid, stperson, endperson, l_canonical_start_date, l_canonical_end_date) loop

     hr_utility.set_location('ASG: ' || to_char(asgrec.assignment_id), 30);

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

         end if;

         if l_person_id is not null then

            if l_person_id <> asgrec.person_id then
               asg_include := FALSE;
            end if;

         end if;

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

         end if;

      end if;

   end loop;

   hr_utility.set_location('Leaving ' || l_proc, 30);

   --hr_utility.trace_off;

end action_creation;


/*--------------------------------------------------------------------------
  Name      : archinit
  Purpose   : This procedure can be used to perform an initialisation
              section
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
procedure archinit
(
   p_payroll_action_id in number
)  is

l_proc                         varchar2(50) := g_package || 'archinit';


begin

   null;

end archinit;


/*--------------------------------------------------------------------------
  Name      : archive_data
  Purpose   : Archive data by calling
              pay_action_information_api.create_action_information
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
procedure archive_data
(
   p_assactid       in number,
   p_effective_date in date
) is

-- Employee Data:
l_id_number          per_people_f.national_identifier%type;
l_other_number       per_people_f.per_information2%type;
l_employee_number    per_people_f.employee_number%type;
l_last_name          per_people_f.last_name%type;
l_first_names        varchar2(600);
l_date_of_birth      per_people_f.date_of_birth%type;
l_date_employed_from per_periods_of_service.date_start%type;
l_date_employed_to   per_periods_of_service.actual_termination_date%type;
l_leaving_reason     per_periods_of_service.leaving_reason%type;

   cursor csr_employee_data (p_person_id number, p_eff_date date) is
   select per.national_identifier ID_Number,
          nvl(per.per_information2, per.per_information3) Other_Number,
          per.employee_number,
          per.last_name,
          names(per.first_name||', '||per.middle_names) First_Names,
          per.date_of_birth,
          pos.date_start Date_Employed_From,
          pos.actual_termination_date Date_Employed_To,
          pos.leaving_reason
     from per_people_f per,
          per_periods_of_service pos
    where per.person_id = p_person_id
        -- Bug 4306265: and per.effective_end_date between per.effective_start_date and p_eff_date  -- Modified the condition for Bug : 3869426
      and p_eff_date between per.effective_start_date and per.effective_end_date -- Bug 4306265: re-enabled /* Old Condition Before Bug : 3869426 */
      and per.per_information_category = 'ZA'
      and pos.person_id(+) = per.person_id
      and nvl(pos.actual_termination_date(+), per.effective_end_date) = per.effective_end_date;

l_leaving_reason_meaning fnd_lookup_values.meaning%type;

   cursor csr_leaving_reason_meaning (p_leaving_reason varchar2) is
         select flv.meaning
           from fnd_lookup_types flt,
                fnd_lookup_values flv
          where flt.lookup_type = 'LEAV_REAS'
            and flt.lookup_type = flv.lookup_type
            and flv.language = 'US'
            and flv.lookup_code = p_leaving_reason
         and flv.enabled_flag = 'Y';


--Assignment Start Date
l_asg_start          per_assignments_f.effective_start_date%type;

  cursor csr_asg_start (p_asg_id number) is
  select min(asg2.effective_start_date)
    from per_assignments_f asg2
       , per_assignment_status_types sta
   where asg2.assignment_id = p_asg_id
     and asg2.assignment_status_type_id = sta.assignment_status_type_id
     and sta.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN', 'TERM_ASSIGN'); -- Added 'TERM_ASSIGN' for bug 3869426

--Assignment UIF Data:
l_empl_status        per_assignment_extra_info.aei_information2%type;
l_reason_non_contrib per_assignment_extra_info.aei_information1%type;

   cursor csr_asg_uif_data (p_asg_id number) is
   select paei.aei_information2 Empl_Status,
          paei.aei_information1 Reason_Non_Contrib
     from per_assignment_extra_info paei
    where paei.assignment_id = p_asg_id
      and paei.aei_information_category = 'ZA_UIF_INFO';


--Employment Status Code:
   cursor csr_empl_status (p_empl_stat_value varchar2) is
   select flv.lookup_code
     from fnd_lookup_types flt,
          fnd_lookup_values flv
    where flt.lookup_type = 'ZA_UIF_TERMINATION_CATEGORIES'
      and flt.lookup_type = flv.lookup_type
      and flv.language = 'US'
      and flv.meaning = p_empl_stat_value
      and flv.enabled_flag = 'Y';


--Assignment Legal Entity Data:
l_legal_entity       per_assignment_extra_info.aei_information7%type;

   cursor csr_asg_leg_ent_data (p_asg_id number) is
   select paei.aei_information7 Legal_Entity
     from per_assignment_extra_info paei
    where paei.assignment_id = p_asg_id
      and paei.aei_information_category = 'ZA_SPECIFIC_INFO';


--Legal Entity Organization Data:
l_employer_uif_ref_no   hr_organization_information.org_information6%type;

/* Changes as per Bug2654703 */
l_employer_email_address  hr_organization_information.org_information10%type;

l_employer_paye_number  hr_organization_information.org_information3%type;

   -- call with l_legal_entity from Assignment UIF Data cursor
   cursor csr_leg_entity_data (p_org_id number) is
   select hoi.org_information6 Employer_UIF_Ref_No,
          /* Changes as per Bug2654703 */
          hoi.org_information10 Employer_email_Address,

          hoi.org_information3 Employer_PAYE_Number
     from hr_organization_information hoi,
          hr_all_organization_units org
    where org.organization_id = p_org_id
      and org.organization_id = hoi.organization_id
      and hoi.org_information_context = 'ZA_LEGAL_ENTITY';


--Bank Data:
l_bank_branch_code      pay_external_accounts.segment1%type;
l_bank_account_number   pay_external_accounts.segment3%type;
l_bank_account_type     pay_external_accounts.segment2%type;

   cursor csr_bank_data (p_asg_id number, p_eff_date date) is
   select pea.segment1  seg1,
          pea.segment3  seg3,
          pea.segment2  seg2
     from pay_personal_payment_methods_f pppm,
          pay_external_accounts          pea,
          pay_org_payment_methods_f      porg,
          pay_legislation_rules          plr
    where pppm.assignment_id      = p_asg_id
      and pea.external_account_id = pppm.external_account_id
      and pea.id_flex_num         = plr.rule_mode
      and plr.LEGISLATION_CODE    = 'ZA'
      and plr.rule_type           = 'E'
      and pea.territory_code      = 'ZA'
      and pppm.priority =
                  ( select min(pppm2.priority)
                      from pay_personal_payment_methods_f pppm2,
                           pay_external_accounts          pea2,
                           pay_org_payment_methods_f      porg2,
                           pay_legislation_rules          plr2
                     where pppm2.assignment_id      = pppm.assignment_id
                       and pea2.external_account_id = pppm2.external_account_id
                       and pea2.id_flex_num         = plr2.rule_mode
                       and plr2.LEGISLATION_CODE    = 'ZA'
                       and plr2.rule_type           = 'E'
                       and pea2.territory_code      = 'ZA'
                       and p_eff_date between pppm2.effective_start_date
                                          and pppm2.effective_end_date
                       and pppm2.org_payment_method_id = porg2.org_payment_method_id
                        /* Exclude 3rd Party Payment Methods*/
                       and porg2.defined_balance_id is not null
                       and p_eff_date between porg2.effective_start_date
                                          and porg2.effective_end_date
                  )
      and p_eff_date between pppm.effective_start_date
                         and pppm.effective_end_date
      and pppm.org_payment_method_id = porg.org_payment_method_id
       /* Exclude 3rd Party Payment Methods*/
      and porg.defined_balance_id is not null
      and p_eff_date between porg.effective_start_date
                         and porg.effective_end_date;


  -- Added for Bug 4134166
   l_pay_periods_per_year        number :=0;
   cursor csr_pay_periods_per_year(p_eff_date date, p_payroll_id number) is
   select count(ptp.end_date)
    from per_time_periods ptp
    where ptp.payroll_id = p_payroll_id
      and ptp.end_date >= '01-MAR-'||to_char(p_eff_date,'YYYY')
      and ptp.end_date  < '01-MAR-'||to_number(to_char(p_eff_date,'YYYY')+1);

  --Added for Bug 4134166
   l_pay_periods_per_month       number :=0;
   cursor csr_pay_periods_per_month(p_eff_date date, p_payroll_id number)is
   select count(ptp.end_date)
     from per_time_periods ptp
     where ptp.payroll_id = p_payroll_id
       and to_char(ptp.end_date,'MMYYYY')= to_char(p_eff_date, 'MMYYYY');

  --UIF Limit
   l_uif_limit              number := 0;
   cursor csr_uif_limit (p_eff_date date) is
   select round((to_number(ffg.global_value)*l_pay_periods_per_month/l_pay_periods_per_year),2) --Bug 4134166
   --select (to_number(ffg.global_value)/12)
    from ff_globals_f ffg
    where ffg.global_name = 'ZA_UIF_ANN_LIM'
      and ffg.legislation_code = 'ZA'
      and p_eff_date between ffg.effective_start_date and ffg.effective_end_date;


   l_asgid      pay_assignment_actions.assignment_id%type;

   l_person_id  per_assignments_f.person_id%type;

   l_empl_stat_value varchar2(200);

   l_action_info_id number;
   l_ovn            number;

   l_assignment_action_id number;

   l_dimension      pay_balance_dimensions.dimension_name%type:= '_ASG_TAX_MTD';
   l_balance_name   pay_balance_types_tl.balance_name%type;

   l_temp_gt_bal                 number := 0;
   l_gross_taxable_remuneration  number := 0;
   l_gross_uif_remuneration      number := 0;
   l_temp_uc_bal                 number := 0;
   l_uif_contribution            number := 0;

   l_archive_effective_date      date;
   l_business_group_id           number;

   l_asg_eff_end_date                date;

   l_proc           varchar2(50) := g_package || 'archive_data';
   l_pactid                      number:=0;  --Bug 4134166
   l_payroll_id                  number:=0;  --Bug 4134166

begin

   --hr_utility.trace_on(null, 'UIF');

   hr_utility.set_location('Entering ' || l_proc, 10);

   --get the Archive Effective Date
   select ppa.effective_date,
          ppa.payroll_action_id
     into l_archive_effective_date,
          l_pactid                   --Bug 4134166
     from pay_payroll_actions    ppa,
          pay_assignment_actions paa
     where paa.payroll_action_id = ppa.payroll_action_id
       and paa.assignment_action_id = p_assactid;


   --get the assignment_id from the assignment_action_id
   select paa.assignment_id
     into l_asgid
     from pay_assignment_actions paa
    where paa.assignment_action_id = p_assactid;

   --get the person_id, Business Group and the
   --assignment's effective end date from the assignment_id
   select asg.person_id
        , business_group_id
        , asg.effective_end_date
     into l_person_id
        , l_business_group_id
        , l_asg_eff_end_date
     from per_assignments_f asg
    where asg.assignment_id = l_asgid
      and asg.effective_end_date =
                (
                 select max(asg2.effective_end_date)
                   from per_assignments_f asg2
                      , per_assignment_status_types sta
                  where asg2.assignment_id = l_asgid   --Bug 4768622
                    and asg2.assignment_status_type_id = sta.assignment_status_type_id
                    and sta.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN') -- Bug 4306265: Removed 'TERM_ASSIGN') -- Added 'TERM_ASSIGN' for bug 3869426
                );


   -- Employee Data:
   -- Strat: Bug 4306265
   if l_asg_eff_end_date > p_effective_date then
        l_asg_eff_end_date := p_effective_date;
   end if;
   -- End: Bug 4306265

   open csr_employee_data (l_person_id, l_asg_eff_end_date);

      fetch csr_employee_data
       into l_id_number,
            l_other_number,
            l_employee_number,
            l_last_name,
            l_first_names,
            l_date_of_birth,
            l_date_employed_from,
            l_date_employed_to,
            l_leaving_reason;

   close csr_employee_data;

   -- When first_name is null, replace with 'XXX'
   -- Bug 2863938
   if l_first_names is null then

      l_first_names := 'XXX';

   end if;

   --Assignment Start Date
   open csr_asg_start (l_asgid);

      fetch csr_asg_start
       into l_asg_start;

   close csr_asg_start;


   --If l_date_employed_from IS NULL then set it to the l_asg_start
   --as it is Mandatory for the UIF File
   if l_date_employed_from is null then

      l_date_employed_from := l_asg_start;

   end if;


   --Assignment UIF Data:
   open csr_asg_uif_data (l_asgid);

      fetch csr_asg_uif_data
       into l_empl_status,
            l_reason_non_contrib;

   close csr_asg_uif_data;


   --IF l_date_employed_to IS NOT NULL then get the value for l_empl_status from
   --the ZA_TERMINATION_CATEGORIES User Table, column UIF Employment Status,
   --by using the mapping for LEAV_REAS (from per_periods_of_service.leaving_reason)
   if (l_date_employed_to is not null and l_date_employed_to <> to_date('31/12/4712', 'DD/MM/YYYY'))
   then

         --Get the Lookup Meaning for the LEAV_REAS Lookup Code in l_leaving_reason
      open csr_leaving_reason_meaning (l_leaving_reason);

           fetch csr_leaving_reason_meaning
            into l_leaving_reason_meaning;

      close csr_leaving_reason_meaning;

     if l_leaving_reason_meaning is not null
     then

          --Get the mapped Legislative UIF Employment Status value
            l_empl_stat_value := per_za_utility_pkg.get_table_value (
                                                        p_table_name        => 'ZA_TERMINATION_CATEGORIES'
                                                      , p_col_name          => 'UIF Employment Status'
                                                      , p_row_value         => l_leaving_reason_meaning
                                                      , p_effective_date    => p_effective_date
                                          , p_business_group_id => l_business_group_id
                                                     );

          --Set the l_empl_status code for each Legislative UIF Employment Status Meaning
          if l_empl_stat_value is not null then

            open csr_empl_status (l_empl_stat_value);

                 fetch csr_empl_status
                  into l_empl_status;

            close csr_empl_status;

          else

                        l_empl_status := '06';

          end if;

      else
         /* default Employment Status to 06 Resigned - should not happen though, as
            there should always be a Leaving Reason if Person is Terminated */
         l_empl_status := '06';

      end if;

   end if;

   -- IF l_date_employed_to is greater than the end of the next UIF month then it,
   -- and the Employment Status, must not be displayed in the file
   if (l_date_employed_to is not null and l_date_employed_to > add_months(l_archive_effective_date, 1))
   then

      l_date_employed_to := null;
      l_empl_status := '';

   end if;


   --Legal Entity
   open csr_asg_leg_ent_data (l_asgid);

      fetch csr_asg_leg_ent_data
       into l_legal_entity;

   close csr_asg_leg_ent_data;


   --Legal Entity Organization Data:
   --call with l_legal_entity from Assignment UIF Data cursor
   open csr_leg_entity_data (l_legal_entity);

      fetch csr_leg_entity_data
       into l_employer_uif_ref_no
          , l_employer_email_address /* Bug 2654703 */
          , l_employer_paye_number;

   close csr_leg_entity_data;


   --Process UIF Ref No
   l_employer_uif_ref_no := process_uif_ref_no (l_employer_uif_ref_no);


   --Bank Data:
   open csr_bank_data (l_asgid, p_effective_date);

      fetch csr_bank_data
       into l_bank_branch_code
          , l_bank_account_number
          , l_bank_account_type;

   close csr_bank_data;


   --Balance Values


   --Gross Taxable Remuneration

      l_balance_name := 'Total NRFIable Income';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Total RFIable Income';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Total NRFIable Annual Income';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Total RFIable Annual Income';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Retirement or Retrenchment Gratuities';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Resignation Pension and RAF Lump Sums';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Retirement Pension and RAF Lump Sums';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Resignation Provident Lump Sums';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Retirement Provident Lump Sums';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Special Remuneration';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;
      l_balance_name := 'Other Lump Sums';
      l_temp_gt_bal  := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_gross_taxable_remuneration := l_gross_taxable_remuneration + l_temp_gt_bal;


   --Gross UIF Remuneration Package

      l_balance_name := 'Total UIFable Income';
      l_gross_uif_remuneration := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);

   --If Total UIFable Income greater than Monthly UIF Limit,
   --then the limit must be printed instead

   --Added for Bug 4134166
   get_parameters
   (
      p_payroll_action_id => l_pactid,   -- Payroll Action of the Archiver
      p_token_name        => 'PAYROLL_ID',
      p_token_value       => l_payroll_id
   );

   hr_utility.set_location('l_payroll_id    => '|| l_payroll_id, 100);
   hr_utility.set_location('l_pactid    => '|| l_pactid, 100);

   --Added for Bug 4134166
   open csr_pay_periods_per_year(p_effective_date,l_payroll_id);
	fetch csr_pay_periods_per_year
	 into l_pay_periods_per_year;

   close csr_pay_periods_per_year;

    --Added for Bug 4134166
    open csr_pay_periods_per_month(p_effective_date,l_payroll_id);

	fetch csr_pay_periods_per_month
	 into l_pay_periods_per_month;

    close csr_pay_periods_per_month;

    hr_utility.set_location('l_pay_periods_per_year    => '|| to_char(l_pay_periods_per_year), 100);
    hr_utility.set_location('l_pay_periods_per_month   => '|| to_char(l_pay_periods_per_month), 100);

    open csr_uif_limit (p_effective_date);

        fetch csr_uif_limit
         into l_uif_limit;

     close csr_uif_limit;


    if l_gross_uif_remuneration > l_uif_limit then

      l_gross_uif_remuneration := l_uif_limit;

    end if;


   --UIF Employee Contribution = UIF Employee Contribution + UIF Employer Contribution

      l_balance_name := 'UIF Employee Contribution';
      l_temp_uc_bal := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_uif_contribution := l_uif_contribution + l_temp_uc_bal;

      l_balance_name := 'UIF Employer Contribution';
      l_temp_uc_bal := get_balance_value(l_asgid, l_balance_name, l_dimension, p_effective_date);
      l_uif_contribution := l_uif_contribution + l_temp_uc_bal;


      --If UIF contribution (8320) is zero, check Person, Assignment,
      --Assignment Extra Information Flexfield for a value in Reason for Non-contribution
      --field. If this field has no value print 06 (no income this period)
      if l_uif_contribution <= 0 then

         if l_reason_non_contrib is null then

            l_reason_non_contrib := '06';

         end if;
     else
         --Bug 4072410
         --If an employee has a value in the UIF Employee Contribution balance
         --AND has a non-contribution reason of 01, then no non-contribution
         --reason must be written to the UIF File.
           if l_reason_non_contrib = '01' then
              l_reason_non_contrib := NULL;
         end if;
      end if;

      -- Changes as per Enhancement Bug 2874102
      -- As reason_non_contrib code '07' is obsoleted after 01-04-2003, if the code
      --    is there for employee, should not be archived.

      if (   l_reason_non_contrib = '07'
             and p_effective_date >= to_date('01-04-2003','dd-mm-yyyy')
         ) then
         l_reason_non_contrib := NULL;
      end if;

      -- Changes as per Bug 7255839
      -- the code 007 (Employees who receive Old Age Pension from the State)
      -- should actually be reported as code '07'
      -- We could not use '07' in the lookup, as it contained the end-date
      -- value for Seasonal Worker. Hence converting '007' to '07' here.
      if (   l_reason_non_contrib = '007') then
         l_reason_non_contrib := '07';
      end if;


   hr_utility.set_location('Archiving ZA UIF EMPLOYEE DETAILS', 50);

   -- Only archive record if the Assignment's Legal Entity and the latter's
   -- Employer UIF Ref No exist
   if (l_employer_uif_ref_no is not null and l_legal_entity is not null) then

      hr_utility.set_location('p_action_context_id           => '|| to_char(p_assactid), 60);
      hr_utility.set_location('p_action_context_type         => '|| 'AAP', 60);
      hr_utility.set_location('p_assignment_id               => '|| to_char(l_asgid), 60);
      hr_utility.set_location('p_effective_date              => '|| to_char(l_archive_effective_date, 'dd/mm/yyyy'), 60);
      hr_utility.set_location('p_action_information_category => '|| 'ZA UIF EMPLOYEE DETAILS', 60);
      hr_utility.set_location('p_action_information1         => '|| to_char(l_asgid), 60);
      hr_utility.set_location('p_action_information2         => '|| to_char(l_archive_effective_date, 'YYYYMM'), 60);
      hr_utility.set_location('p_action_information3         => '|| l_legal_entity, 60);
      hr_utility.set_location('p_action_information4         => '|| l_employer_uif_ref_no, 60);
      hr_utility.set_location('p_action_information5         => '|| l_employer_paye_number, 60);
      hr_utility.set_location('p_action_information6         => '|| l_id_number, 60);
      hr_utility.set_location('p_action_information7         => '|| l_other_number, 60);
      hr_utility.set_location('p_action_information8         => '|| l_employee_number, 60);
      hr_utility.set_location('p_action_information9         => '|| l_last_name, 60);
      hr_utility.set_location('p_action_information10        => '|| l_first_names, 60);
      hr_utility.set_location('p_action_information11        => '|| to_char(l_date_of_birth, 'YYYYMMDD'), 60);
      hr_utility.set_location('p_action_information12        => '|| to_char(l_date_employed_from, 'YYYYMMDD'), 60);
      hr_utility.set_location('p_action_information13        => '|| to_char(l_date_employed_to, 'YYYYMMDD'), 60);
      hr_utility.set_location('p_action_information14        => '|| l_empl_status, 60);
      hr_utility.set_location('p_action_information15        => '|| l_reason_non_contrib, 60);
      hr_utility.set_location('p_action_information16        => '|| l_gross_taxable_remuneration, 60);
      hr_utility.set_location('p_action_information17        => '|| l_gross_uif_remuneration, 60);
      hr_utility.set_location('p_action_information18        => '|| l_uif_contribution, 60);
      hr_utility.set_location('p_action_information19        => '|| l_bank_branch_code, 60);
      hr_utility.set_location('p_action_information20        => '|| l_bank_account_number, 60);
      hr_utility.set_location('p_action_information21        => '|| l_bank_account_type, 60);
      hr_utility.set_location('p_action_information22        => '|| l_employer_email_address, 50); /* Bug 2654703 */


      -- Archive the ZA UIF EMPLOYEE DETAILS
      pay_action_information_api.create_action_information
      (
         p_action_information_id       => l_action_info_id,
         p_action_context_id           => p_assactid, -- Assignment Action of the Archiver
         p_action_context_type         => 'AAP',
         p_object_version_number       => l_ovn,
         p_assignment_id               => l_asgid,
         p_effective_date              => l_archive_effective_date,
         p_source_id                   => null,
         p_source_text                 => null,
         p_action_information_category => 'ZA UIF EMPLOYEE DETAILS',
         p_action_information1         => l_asgid,
         p_action_information2         => to_char(l_archive_effective_date, 'YYYYMM'),
         p_action_information3         => l_legal_entity,
         p_action_information4         => l_employer_uif_ref_no,
         p_action_information5         => l_employer_paye_number,
         p_action_information6         => l_id_number,
         p_action_information7         => l_other_number,
         p_action_information8         => l_employee_number,
         p_action_information9         => l_last_name,
         p_action_information10        => l_first_names,
         p_action_information11        => to_char(l_date_of_birth, 'YYYYMMDD'),
         p_action_information12        => to_char(l_date_employed_from, 'YYYYMMDD'),
         p_action_information13        => to_char(l_date_employed_to, 'YYYYMMDD'),
         p_action_information14        => l_empl_status,
         p_action_information15        => l_reason_non_contrib,
         p_action_information16        => l_gross_taxable_remuneration,
         p_action_information17        => l_gross_uif_remuneration,
         p_action_information18        => l_uif_contribution,
         p_action_information19        => l_bank_branch_code,
         p_action_information20        => l_bank_account_number,
         p_action_information21        => l_bank_account_type,
         p_action_information22        => l_employer_email_address /* Bug 2654703 */
      );

   end if;

   hr_utility.set_location('Leaving ' || l_proc, 60);

   --hr_utility.trace_off;

end archive_data;


/*--------------------------------------------------------------------------
  Name      : process_uif_ref_no
  Purpose   : Process UIF Ref No
  Arguments : p_employer_uif_ref_no
  Notes     : Should be zero filled to fit the field size A9. Slash should be
              left out if included in the number. e.g. 123456/8 should be
              sent as 001234568, e.g. of UIF Ref. No. 062441/0 or U120721099
--------------------------------------------------------------------------*/
function process_uif_ref_no
(
   p_employer_uif_ref_no in varchar2
)  return varchar2 is

l_length              number;
l_employer_uif_ref_no varchar2(11);
l_temp_no             varchar2(11) := '';

begin

      hr_utility.set_location('Entering process_uif_ref_no', 10);

      l_employer_uif_ref_no := p_employer_uif_ref_no;

      hr_utility.set_location('l_employer_uif_ref_no = '|| l_employer_uif_ref_no, 20);

     if l_employer_uif_ref_no is not null then

     l_employer_uif_ref_no := ltrim(rtrim(l_employer_uif_ref_no));

        hr_utility.set_location('l_employer_uif_ref_no = '|| l_employer_uif_ref_no, 25);

     l_length := to_number(length(l_employer_uif_ref_no));

        hr_utility.set_location('length_l_employer_uif_ref_no = '|| to_char(l_length), 30);

      for i in 1 .. l_length

         loop

            if substr(l_employer_uif_ref_no, i, 1)
            in ('0','1','2','3','4','5','6','7','8','9')
            then

               l_temp_no := l_temp_no || substr(l_employer_uif_ref_no, i, 1);

             hr_utility.set_location('l_temp_no = '|| l_temp_no, 35);

            end if;

         end loop;

     end if;

      l_employer_uif_ref_no := ltrim(rtrim(l_temp_no));

         hr_utility.set_location('l_employer_uif_ref_no_PROCESSED= '|| l_employer_uif_ref_no, 40);

      l_length := to_number(length(l_employer_uif_ref_no));

      if l_length > 9 then

        l_employer_uif_ref_no := substr(l_employer_uif_ref_no, -9);

      end if;

      l_employer_uif_ref_no := lpad(l_employer_uif_ref_no, 9, '0');

         hr_utility.set_location('l_employer_uif_ref_no_PROCESSED_zero_padded= '|| l_employer_uif_ref_no, 50);

   return l_employer_uif_ref_no;

end process_uif_ref_no;


/*--------------------------------------------------------------------------
  Name      : get_parameter
  Purpose   : Returns a legislative parameter
  Arguments :
  Notes     : The legislative parameter field must be of the form:
              PARAMETER_NAME=PARAMETER_VALUE. No spaces is allowed in either
              the PARAMETER_NAME or the PARAMETER_VALUE.
--------------------------------------------------------------------------*/
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



function names(name varchar2) return varchar2 is

l_pos    number;
l_pos2   number;
l_name   varchar2(255);
l_answer varchar2(255);

begin

   -- Remove any unnecessary spaces
   l_name := ltrim(rtrim(name));

   -- Get the first name
   l_pos := instr(l_name, ',', 1, 1);
   l_answer := rtrim(substr(l_name, 1, l_pos - 1));

   -- Append the second name
   l_pos2 := instr(l_name, ',', l_pos + 1, 1);
   if l_pos2 = 0 then

      -- Concatenate the rest of the string
      l_answer := l_answer || ' ' || ltrim(rtrim( substr(l_name, l_pos + 1) ));

   else

      -- Concatenate the name up to the comma
      l_answer := l_answer || ' ' || ltrim(rtrim( substr(l_name, l_pos + 1, l_pos2 - l_pos - 1) ));

   end if;

   l_answer := ltrim(rtrim(l_answer));

   return l_answer;

end names;

function clean(name varchar2) return varchar2 is

l_invalid varchar2(255) := '&`''';
l_answer  varchar2(255);
l_pos     number;
l_count   number;

begin

   l_answer := name;

   if l_answer = '&&&,&&&' then

      return '&&&';

   else

      -- Loop through the invalid characters
      for l_count in 1..length(l_invalid) loop

         l_pos := instr(l_answer, substr(l_invalid, l_count, 1), 1, 1);
         while l_pos <> 0 loop

            -- Replace the invalid character with a space
            l_answer := substr(l_answer, 1, l_pos - 1) || ' ' || substr(l_answer, l_pos + 1);
            l_pos := instr(l_answer, substr(l_invalid, l_count, 1), 1, 1);

         end loop;

      end loop;

      return l_answer;

   end if;

end;

function get_uif_employer_count return number is
begin

   return g_total_no_emps;

end;

function get_uif_total_gross_tax_rem return number is
begin

   return g_total_gross_tax_rem;

end;

/* Bug 2654703 */
function get_uif_total_remu_sub_uif return number is
begin

   return g_total_remu_sub_uif;

end;

function get_uif_total_uif_contrib return number is
begin

   return g_total_uif_contribution;

end;


function set_size
(
   p_code  in varchar2,
   p_type  in varchar2,
   p_value in varchar2
)  return varchar2 is

l_text  varchar2(256);
l_code  varchar2(256);
l_value varchar2(256);

begin

   --hr_utility.trace_on(null, 'UIF');

   l_code := p_code;

   -- Remove any spaces
   l_value := rtrim(ltrim(p_value));

   --Initialize globals
   if p_code = '0000' then

         g_total_gross_tax_rem := 0;
         g_total_uif_contribution := 0;

         /* Changes as per Bug 2654703 */
         g_total_remu_sub_uif := 0;

         g_total_no_emps := 0;

   end if;


   -- Check whether the Employer amounts and Count totals should be incremented
   if to_number(l_code) = 8300 then

      g_total_gross_tax_rem := g_total_gross_tax_rem + to_number(l_value);

     g_total_no_emps := g_total_no_emps + 1;

   /* Changes as per Bug 2654703 */
   elsif to_number(l_code) = 8310 then
     g_total_remu_sub_uif := g_total_remu_sub_uif + to_number(l_value);

   elsif to_number(l_code) = 8320 then

     g_total_uif_contribution := g_total_uif_contribution + to_number(l_value);

   end if;


   -- Check whether the Employer (Legal Entity) counts should be reset
   if l_code = '8130' then /*Employer Total Gross Taxable Remuneration*/

     l_value := to_char(g_total_gross_tax_rem);

        g_total_gross_tax_rem := 0;

   /* Changes as per Bug 2654703 */
   elsif l_code = '8135' then /* Employer Total remuneration subject to UIF */
     l_value := to_char(g_total_remu_sub_uif);
     g_total_remu_sub_uif := 0;

   elsif l_code = '8140' then /*Employer Total Contribution*/

     l_value := to_char(g_total_uif_contribution);

     g_total_uif_contribution := 0;

   elsif l_code = '8150' then /*Employer Total Number of Employee Records*/

     l_value :=  to_char(g_total_no_emps);

     g_total_no_emps := 0;

   end if;


   --Process field:

   -- Check for empty fields
   if (l_value = '&&&') then

      -- The field should be left out completely
     l_text := '';

   -- Check for a record terminator field
   elsif (l_value = '@@@') then

      l_text := fnd_global.local_chr(13) || fnd_global.local_chr(10);

   -- A value field was provided
   else

      -- Check for the start of a record
      if p_code in ('8000','8001','8002') then /* Bug 2654703 */
         l_text := p_code;
      else
         l_text := ',' || p_code;
      end if;

      -- Append the value
      if p_type = 'N' then

        --first take off decimal .00 if it exists
       if mod(to_number(l_value), trunc(to_number(l_value))) = 0 then

          l_value := to_char(to_number(l_value));

       end if;

         l_text := l_text || ',' || l_value;
      else
         -- Add quotes if it is a character field
         l_text := l_text || ',"' || l_value || '"';
      end if;

   end if;


   hr_utility.trace('DO(' || l_code || ',' || l_value || ',' || l_text || ')');
   --hr_utility.trace_off;
   return l_text;

end;

function za_power
(
   p_number in number,
   p_power  in number
)  return number is

begin

   return power(p_number, p_power);

end;

function za_to_char
(
   p_number in number,
   p_format in varchar2
)  return varchar2 is

begin

   -- Check whether the Format parameter was defaulted
   if p_format = '&&&' then

      return to_char(p_number);

   else

      return ltrim(to_char(p_number, p_format));

   end if;

end;


begin

   prev_asg_id := 0;
   --g_size := 0;

end pay_za_uif_archive_pkg;

/
