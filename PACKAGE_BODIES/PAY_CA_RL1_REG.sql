--------------------------------------------------------
--  DDL for Package Body PAY_CA_RL1_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_RL1_REG" as
/* $Header: pycarrrg.pkb 120.3.12010000.2 2009/02/24 07:04:43 sneelapa ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed to run
                RL1 Register Multi-Threaded Report
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   06-JAN-2000  mmukherj    110.0  Created
   25-JAN-2000  MMukherjee  110.1   Changed the legislative_parameter name
                                    from QUEBEC_BUSINESS_NO to QC_ID_NO
   04-FEB-2000  MMukherjee  110.2   Modified sort code
   04-FEB-2000  MMukherjee  115.1   Modified sort code to include
                                    terminated employees

   21-SEP-2000  VPANDYA     115.2   Modified cursor all_asg commented
                                    primaryflag condition
   02-NOV-2000  VPANDYA     115.3   Modified cursor c_first_tax_unit_id
                                    and c_all_asg declaring with parameters.
                                    Modified condition from = NULL to is NULL
                                    for l_rl1reg_pre_org_id
   08-DEC-2000  VPANDYA     115.4   Added to_char in subquery of c_all_asg
                                    cursor.
   27-DEC-2001  VPANDYA     115.5   Added function get_rl1_message
                                    and dbdrv lines.
   28-DEC-2001  VPANDYA     115.6   Modified sort_action cursor replace
                                    to_date('31-DEC'..with add_months
   28-DEC-2001  VPANDYA     115.7   Modified function get_rl1_message
                                    removed 'DD-MON-YYYY' from
                                    to_date( p_emp_dob,..)
   08-Jan-2002  VPANDYA     115.8   Modified function get_rl1_message
                                    in which added one more input
                                    parameter p_hire_dt and returning
                                    message with hire date.
   09-MAY-2002  SSattineni  115.9   Fixed the bug#2135545 by
                                    modifying action_creation
                                    procedure.
   16-AUG-2002  mmukherj    115.10  Added get_user_entity_id procedure.
                                    added these two lines in action_creation
                                    procedure.
  l_uid_caeoy_tax_year      := get_user_entity_id('CAEOY_TAXATION_YEAR');
  l_uid_caeoy_rl1_quebec_bn := get_user_entity_id('CAEOY_RL1_QUEBEC_BN');
  and used these two variables in c_all_pres cursor. This makes this cursor
  more performant. The query inside this cursor had been recognised as a
  query with high cost in 11.5.8.

   16-AUG-2002  vpandya     115.11  Changed c_all_pres for perfoemance 11.5.8,
                                    getting Quebec Busi.number from
                                    pay_payroll_actions table instead of
                                    archiver table.
                                    Changed c_all_asg_in_asgset for 11.5.8 perf.
                                    added table hr_all_organization_units table
                                    to avoid cartesian join.
                                    Changed function get_rl1_message, added
                                    input parameter p_termination_dt to print it
                                    in the message if it is not null.Bug2192914
   06-NOV-2002  vpandya     115.12  Added function get_primary_address,
                                    Changed action_creation procedure to create
                                    one assignment action for a person if the
                                    person has more than one assignments(multi).
   06-NOV-2002  vpandya     115.13  Added country in  get_primary_address
   07-NOV-2002  vpandya     115.14  Print country code only in the address
                                    instead of Country name(Ref. by LT).
   08-Nov-2002  vpandya     115.15  Added address_line_6 which returns
                                    Country Name where as line 5 returns
                                    Country Code.
   22-Oct-2002 vpandya      115.16  Bug 2681250: changed cursor csr_address
                                    of get_primary_address. If country is CA
                                    take data from region_1 to get province
                                    code and if it is US take data from
                                    region_2 to get state code.
   02-DEC-2002  vpandya     115.17  Added nocopy with out parameter
                                    as per GSCC.
   04-DEC-2002  vpandya     115.18  Changed get_parimary_address function,
                                    returns region_1 for province if country is
                                    null
   04-SEP-2003  vpandya     115.19  Changed cursors c_all_asg and
                                    c_all_asg_in_asgset to check tax unit id of
                                    RL1 with segment1(T4/RL1) and segment11
                                    (T4A/RL1) -- Multi GRE Changes.
                                    Bug 2633035: stamping organization id of
                                    PRE in to tax unit id of asg act.
                                    Changed sort_action cursor to use sort
                                    options.
   18-Sep-2003  vpandya     115.20  Fix gscc date conversion error by replacing
                                    to_date with fnd_date.canonical_to_date in
                                    function get_rl1_message.
   25-Sep-2003  vpandya     115.21  Change sort action cursor and also changed
                                    in c_all_asg c_all_asg_set cursor in
                                    action creation. Bug 2633035.
   04-Nov-2003 ssouresr     115.22  Using pre_organization_id instead of Quebec
                                    Business Number. Also updating the serial
                                    number on pay_assignment_actions to province
                                    archived assignment action and payroll action id
   11-Feb-2004 ssouresr     115.23  Sort_action query was modified to eliminate dups
   16-Feb-2004 ssouresr     115.24  Taken out join to hr_locations from assignment
                                    cursors and from sort_action
   03-Mar-2004 ssouresr     115.26  Data is archived against the primary assignment_id
                                    however non primary assignments were being
                                    compared to the archived assignment_id in the
                                    cursor c_archived_person_info. This mismatch
                                    resulted in archived employees not being reported.
   02-Apr-2004 ssattini     115.27  11510 Changes to fix bug#3356512.
                                    Modified cursor c_all_asg_in_asgset and
                                    c_all_asg in action_creation procedure.
   17-Apr-2004 ssouresr     115.28  Created new cursor c_single_asg to allow a
                                    single assignment to be displayed Bug #3274365
   03-Sep-2004 ssattini     115.29  Added get_label function to fix
                                    bug#3810959.
   22-NOV-2004 ssouresr     115.30  Replaced tables with views for security group
   25-FEB-2005 ssmukher     115.31  Added TRUNC function to the date parameter
                                    p_effective_date in the csr_address cursor
                                    of the function get_primary_address to fix
                                    #Bug 4205724
   15-JUN-2005 ssouresr     115.32  Replaced views with tables in sort_action
                                    as this was causing Assertion failure
   13-JUL-2005 saurgupt     115.33  Modified function get_primary_address. Cursor csr_address
                                    is modified to add country_code in address_line4 to
                                    fix #Bug 4131616.
   10-FEB-2006 ssouresr     115.34  Removed references to hr_soft_coding_keyflex

   24-FEB-2009 sneelapa     115.35  Bug 7572889, Modified the CURSORS
                                    c_all_asg, c_single_asg and c_all_asg_in_asgset
                                    to fetch the data from "pay_payroll_actions"
                                    and "pay_assignment_actions" tables.
*/
/*
----------------------------------- range_cursor -----------------------------
*/

function get_user_entity_id(p_user_name varchar2) return number is

begin

declare

  cursor cur_user_entity_id is
  select user_entity_id
  from   ff_database_items
  where  user_name = p_user_name;

  l_user_entity_id	ff_database_items.user_entity_id%TYPE;

begin

  open  cur_user_entity_id;

  fetch cur_user_entity_id
  into  l_user_entity_id;

  close cur_user_entity_id;

  return l_user_entity_id;

end;
end;

procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
  l_payroll_id number;
  leg_param    pay_payroll_actions.legislative_parameters%type;

begin
   --hr_utility.trace_on('Y','RL1');
	hr_utility.trace('begining of range_cursor 1 ');
   select legislative_parameters
     into leg_param
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;


/* pay reg code */

   sqlstr := 'select distinct to_number(fai3.value)
                from    ff_archive_items fai1,
                        ff_archive_items fai2,
                        ff_database_items fdi1,
                        ff_database_items fdi2,
                        ff_archive_items fai3,
                        ff_database_items fdi3,
			pay_payroll_actions     ppa,
                        pay_assignment_actions  paa
              where  ppa.payroll_action_id    = :payroll_action_id
                 and    fai1.user_entity_id = fdi1.user_entity_id
                 and    fdi1.user_name      = ''CAEOY_TAXATION_YEAR''
                 and    fai1.value =
                 	nvl(pay_ca_rl1_reg.get_parameter(''TAX_YEAR'',
                                                         ppa.legislative_parameters),fai1.value)
                 and    fai2.user_entity_id = fdi2.user_entity_id
                 and    fdi2.user_name      = ''CAEOY_RL1_PRE_ORG_ID''
                 and    fai2.value           =
                  nvl(pay_ca_rl1_reg.get_parameter(''PRE_ORGANIZATION_ID'',
                                                   ppa.legislative_parameters),
                                                   fai2.value)
                 and    fai1.context1        = fai2.context1
                 and    paa.payroll_action_id= fai2.context1
                 and    paa.assignment_action_id=fai3.context1
                 and    fai3.user_entity_id = fdi3.user_entity_id
                 and    fdi3.user_name = ''CAEOY_PERSON_ID''
                 and    fai3.value  = nvl(pay_ca_rl1_reg.get_parameter(''PER_ID'',
                                          ppa.legislative_parameters),fai3.value)
		 order by to_number(fai3.value)';

	hr_utility.trace('End of range_cursor 2 ');
end range_cursor;
/*
-------------------------------- action_creation ----------------------------------
*/

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

      lockingactid  number;
      lockedactid   number;
      l_asg_id      number;
      l_primary_asg number;
      l_asg_set_id  number;
      l_tax_unit_id number;
      l_year        varchar2(4);
      l_bus_group_id number;
      l_year_start  date;
      l_year_end    date;
      l_pre_organization_id varchar2(17);
      l_rl1reg_pre_org_id varchar2(17);
      l_effective_date date;
      l_report_type varchar2(80);
      l_legislative_parameters varchar2(240);
      l_person_id      number;
      l_prev_person_id      number;
      l_prev_pre_organization_id varchar2(17);

      l_pre_org_id number; -- Organization Id of PRE (Prov Reporting Est)
      lv_serial_number varchar2(30);
      ln_arch_asgact_id number;
      ln_arch_pact_id number;
      lv_per_id       varchar2(30);

/* For performance: getting all pre organization ids   from
   legislative parameter of pay_payroll_actions for RL1 archiver
   for the given year within same business group.
*/
   cursor c_all_pres is
   select pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
          ppa.legislative_parameters )
    from pay_payroll_actions ppa
   where ppa.report_type       = 'RL1'
   and   ppa.report_qualifier  = 'CAEOYRL1'
   and   ppa.report_category   = 'CAEOYRL1'
   and   ppa.effective_date    = l_year_end
   and   ppa.start_date        = l_year_start
   and   ppa.business_group_id = l_bus_group_id
   and   ppa.action_status     = 'C';

   cursor c_archived_person_info (cp_person_id in number,
                                  cp_assignment_id in number,
                                  cp_pre_org_id in varchar2) is
   select paa.assignment_action_id,
          ppa.payroll_action_id
   from pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.report_type       = 'RL1'
   and   ppa.report_qualifier  = 'CAEOYRL1'
   and   ppa.report_category   = 'CAEOYRL1'
   and   ppa.effective_date    = l_year_end
   and   ppa.start_date        = l_year_start
   and   ppa.business_group_id = l_bus_group_id
   and   ppa.action_status     = 'C'
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   paa.serial_number     = to_char(cp_person_id)
   and   pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
          ppa.legislative_parameters) = cp_pre_org_id
   and   paa.assignment_id     = cp_assignment_id;

   cursor c_first_tax_unit_id (p_pre_org_id varchar2) is
   select distinct organization_id
   from hr_organization_information hoi
   where hoi.org_information_context = 'Canada Employer Identification'
   and  hoi.org_information2         = p_pre_org_id;

   /* 11510 Change to fix bug#3356512, modified cursor c_all_asg */
   cursor c_all_asg(l_business_group_id number
                  , l_year_start date
                  , l_year_end date ) is
    select distinct to_number(paa.serial_number),
                       paa.assignment_id assignment_id
    from pay_payroll_actions ppa,
        pay_assignment_actions paa
    where ppa.report_type       = 'RL1'
    and   ppa.report_qualifier  = 'CAEOYRL1'
    and   ppa.report_category   = 'CAEOYRL1'
    and   ppa.effective_date    = l_year_end
    and   ppa.start_date        = l_year_start
    and   ppa.business_group_id = l_business_group_id
    and   ppa.action_status     = 'C'
    and   ppa.payroll_action_id = paa.payroll_action_id
    and   to_number(paa.serial_number) between stperson and endperson
    order by 1, 2;

/*  commented by sneelapa, for bug 7572889
    select distinct paf.person_id,
                    paf.assignment_id  assignment_id
    from per_people_f ppf,
         per_assignments_f paf
    where ppf.person_id between stperson and endperson
    and   ppf.effective_start_date  <= l_year_end
    and   ppf.effective_end_date    >= l_year_start
    and   paf.person_id = ppf.person_id
    and   paf.effective_start_date  <= l_year_end
    and   paf.effective_end_date    >= l_year_start
    and   paf.assignment_type = 'E'
    and   paf.business_group_id + 0 = l_business_group_id
    order by 1,2;
*/
    cursor c_single_asg (l_business_group_id number
                        ,l_year_start date
                        ,l_year_end   date
                        ,l_per_id     varchar2) is
    select distinct to_number(paa.serial_number),
                    paa.assignment_id assignment_id
    from pay_payroll_actions ppa,
        pay_assignment_actions paa
    where ppa.report_type       = 'RL1'
    and   ppa.report_qualifier  = 'CAEOYRL1'
    and   ppa.report_category   = 'CAEOYRL1'
    and   ppa.effective_date    = l_year_end
    and   ppa.start_date        = l_year_start
    and   ppa.business_group_id = l_business_group_id
    and   ppa.action_status     = 'C'
    and   ppa.payroll_action_id = paa.payroll_action_id
    and   to_number(paa.serial_number) between stperson and endperson
    and   paa.serial_number = l_per_id;

/*  commented by sneelapa, for bug 7572889
    select distinct paf.person_id,
                    paf.assignment_id  assignment_id
    from per_people_f ppf,
         per_assignments_f paf
    where ppf.person_id between stperson and endperson
    and   ppf.effective_start_date  <= l_year_end
    and   ppf.effective_end_date    >= l_year_start
    and   paf.person_id = ppf.person_id
    and   ppf.person_id = to_number(l_per_id)
    and   paf.effective_start_date  <= l_year_end
    and   paf.effective_end_date    >= l_year_start
    and   paf.assignment_type = 'E'
    and   paf.business_group_id + 0 = l_business_group_id
    order by 1,2;
*/

/* Added this new cursor to fix bug#2135545 and this
   will be used only if Assignment Set is passed for RL1 reports */
   /* 11510 change modified c_all_asg_in_asgset cursor to fix bug#3356512*/
    cursor c_all_asg_in_asgset(l_business_group_id number
                             ,l_year_start date
                             ,l_year_end date ) is
   select distinct to_number(paa.serial_number),
                   paa.assignment_id assignment_id
   from pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.report_type       = 'RL1'
   and   ppa.report_qualifier  = 'CAEOYRL1'
   and   ppa.report_category   = 'CAEOYRL1'
   and   ppa.effective_date    = l_year_end
   and   ppa.start_date        = l_year_start
   and   ppa.business_group_id = l_business_group_id
   and   ppa.action_status     = 'C'
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   to_number(paa.serial_number) between stperson and endperson
   and exists (select 1
               from hr_assignment_set_amendments hasa,
                    per_assignments_f paf
               where hasa.assignment_set_id         = l_asg_set_id
               and   upper(hasa.include_or_exclude) = 'I'
               and   hasa.assignment_id             = paf.assignment_id
               and   paf.person_id = to_number(paa.serial_number))
   order by 1,2;

/*  commented by sneelapa, for bug 7572889
    select distinct paf.person_id,
                    paf.assignment_id  assignment_id
    from per_people_f ppf,
	 per_assignments_f paf
    where ppf.person_id between stperson and endperson
    and   ppf.effective_start_date  <= l_year_end
    and   ppf.effective_end_date    >= l_year_start
    and   paf.person_id = ppf.person_id
    and   paf.effective_start_date  <= l_year_end
    and   paf.effective_end_date    >= l_year_start
    and   paf.assignment_type = 'E'
    and   paf.business_group_id +0 = l_business_group_id
    and   exists ( select 1 /* Selected Assignment Set */
/*                   from   hr_assignment_set_amendments hasa
                   where  hasa.assignment_set_id   = l_asg_set_id
                   and    hasa.assignment_id         = paf.assignment_id
                   and    upper(hasa.include_or_exclude) = 'I')
    order by 1,2;
*/
    cursor c_get_asg_id (p_person_id number) is
    select assignment_id
    from per_assignments_f paf
    where person_id = p_person_id
    and   primary_flag = 'Y'
    and   assignment_type = 'E'
    and   paf.effective_start_date  <= l_year_end
    and   paf.effective_end_date    >= l_year_start
    order by assignment_id desc;

   begin
     hr_utility.set_location('procpyr',1);
     hr_utility.trace('begining of action creation 1'||to_char(pactid));

     /* get report type and effective date */

     select effective_date,
            report_type,
            business_group_id,
            legislative_parameters
     into   l_effective_date,
            l_report_type,
            l_bus_group_id,
            l_legislative_parameters
     from pay_payroll_actions
     where payroll_action_id = pactid;

     hr_utility.trace('begining of action creation 2 '||
                       to_char(l_bus_group_id));

     hr_utility.trace('legislative parameters is '||l_legislative_parameters);

   l_year       := pay_ca_rl1_reg.get_parameter('TAX_YEAR',l_legislative_parameters);
   l_year_start := trunc(to_date(l_year,'YYYY'), 'Y');
   l_year_end   := add_months(trunc(to_date(l_year,'YYYY'), 'Y'),12) - 1;
   l_asg_set_id := pay_ca_rl1_reg.get_parameter('ASG_SET_ID',l_legislative_parameters);
   lv_per_id    := pay_ca_rl1_reg.get_parameter('PER_ID',l_legislative_parameters);

   hr_utility.trace('begin action creation '||l_year||to_char(l_year_start)||to_char(l_year_end));

   l_rl1reg_pre_org_id := pay_ca_rl1_reg.get_parameter('PRE_ORGANIZATION_ID',
                                                       l_legislative_parameters);

    hr_utility.trace('begining of action creation 4 *'||
                                      l_rl1reg_pre_org_id||'*');

    if  l_rl1reg_pre_org_id is NULL then
        open c_all_pres;
        hr_utility.trace('else condition after open c_all_pres '||
                         'c_all_asg cursor 6 ');
    else
      l_pre_organization_id := l_rl1reg_pre_org_id;
      hr_utility.trace('begining of if condition 5 '||l_pre_organization_id);
    end if;

      if l_rl1reg_pre_org_id is NULL then
          loop
              fetch c_all_pres into l_pre_organization_id;
		hr_utility.trace('Begining of else loop for c_all_pres 7 '||
                                  l_pre_organization_id);
              exit when c_all_pres%notfound;
               open c_first_tax_unit_id(l_pre_organization_id);
               fetch c_first_tax_unit_id into l_tax_unit_id;

            if c_first_tax_unit_id%FOUND then
                 close c_first_tax_unit_id;

                 l_pre_org_id := to_number(l_pre_organization_id);

               /* Added this validation to fix bug#2135545 */

                 if l_asg_set_id is not null then
                    open c_all_asg_in_asgset(l_bus_group_id,
                                             l_year_start , l_year_end);
                 elsif lv_per_id is not null then
                    open c_single_asg(l_bus_group_id, l_year_start,
                                      l_year_end, lv_per_id);
                 else
                    open c_all_asg(l_bus_group_id,
                                   l_year_start, l_year_end);
                 end if;

                 loop
                    /* Added this validation to fix bug#2135545 */

                    if l_asg_set_id is not null then
                       fetch c_all_asg_in_asgset into l_person_id, l_asg_id;
                       exit when c_all_asg_in_asgset%notfound;
                    elsif lv_per_id is not null then
                       fetch c_single_asg into l_person_id, l_asg_id;
                       exit when c_single_asg%notfound;
                    else
                       fetch c_all_asg into l_person_id, l_asg_id;
                       exit when c_all_asg%notfound;
                    end if;

	          hr_utility.trace('Begining of loop for c_all_asg 8 '||
                                     to_char(l_asg_id));

                 if ( l_person_id   = l_prev_person_id   and
                      l_pre_organization_id = l_prev_pre_organization_id) then

                   hr_utility.trace('Not creating assignment action');

                 else
                     /* Get the primary assignment as the primary
                        assignment is the assignment_id that is
                        always archived.  Must check against this
                        assignment when checking for archived person */

                    open c_get_asg_id(l_person_id);
                    fetch c_get_asg_id into l_primary_asg;

                    if c_get_asg_id%NOTFOUND then
                       close c_get_asg_id;
                       hr_utility.raise_error;
                    else
                       close c_get_asg_id;
                    end if;

                    open c_archived_person_info (l_person_id,
                                                 l_primary_asg,
                                                 l_pre_organization_id);
                    fetch c_archived_person_info
                    into ln_arch_asgact_id,
                         ln_arch_pact_id;
                    if c_archived_person_info%notfound then
                       hr_utility.trace('No Archived Person Found');
                    else
                       select pay_assignment_actions_s.nextval
                       into   lockingactid
                       from   dual;

                       hr_nonrun_asact.insact(lockingactid,
                       --                       l_asg_id, -- commented by sneelapa, for bug 7572889
                                              l_primary_asg,
                                              pactid,
                                              chunk,
                                              l_pre_org_id);

		        hr_utility.trace('in if loop after calling '||
                          'hr_nonrun_asact.insact pkg 9 '||to_char(l_asg_id));

                 /* Added this to implement RL1 Register and RL1 Amendment Register
                    using the same report file */
                        lv_serial_number := 'QC' ||lpad(to_char(ln_arch_asgact_id),14,0)||
                                         lpad(to_char(ln_arch_pact_id),14,0);

                        hr_utility.trace('lv_serial_number :' ||lv_serial_number);

                        update pay_assignment_actions paa
                        set paa.serial_number = lv_serial_number
                        where paa.assignment_action_id = lockingactid;

                        l_prev_person_id   := l_person_id;
                        l_prev_pre_organization_id := l_pre_organization_id;

                    end if;
                    close c_archived_person_info;

                 end if;

               end loop;

                  /* Added this validation to fix bug#2135545 */
                  if l_asg_set_id is not null then
                     close c_all_asg_in_asgset;
                  elsif lv_per_id is not null then
                     close c_single_asg;
                  else
	             close c_all_asg;
                  end if;

            else

                hr_utility.trace('No GRE for this PRE Organization id');
                hr_utility.raise_error;

            end if;
          end loop;
         close c_all_pres;
      else
             open c_first_tax_unit_id(l_pre_organization_id);
             fetch c_first_tax_unit_id into l_tax_unit_id;

             if c_first_tax_unit_id%FOUND then
                 close c_first_tax_unit_id;

               l_pre_org_id := to_number(l_pre_organization_id);

               /* Added this validation to fix bug#2135545 */
               if l_asg_set_id is not null then
                  open c_all_asg_in_asgset(l_bus_group_id,
                                           l_year_start, l_year_end);
               elsif lv_per_id is not null then
                  open c_single_asg(l_bus_group_id, l_year_start,
                                    l_year_end, lv_per_id);
               else
                  open c_all_asg(l_bus_group_id,
                                 l_year_start, l_year_end);
               end if;

              loop

               /* Added this validation to fix bug#2135545 */
                if l_asg_set_id is not null then
                   fetch c_all_asg_in_asgset into l_person_id, l_asg_id;
                   exit when c_all_asg_in_asgset%notfound;
                elsif lv_per_id is not null then
                   fetch c_single_asg into l_person_id, l_asg_id;
                   exit when c_single_asg%notfound;
                else
                   fetch c_all_asg into l_person_id, l_asg_id;
                   exit when c_all_asg%notfound;
                end if;

		hr_utility.trace('Begining of if part loop for c_all_asg 10 '||
                                  to_char(l_asg_id));


                 if ( l_person_id   = l_prev_person_id   and
                      l_pre_organization_id = l_prev_pre_organization_id) then

                   hr_utility.trace('Not creating assignment action');

                 else

                     /* Get the primary assignment as the primary
                        assignment is the assignment_id that is
                        always archived.  Must check against this
                        assignment when checking for archived person */

                    open c_get_asg_id(l_person_id);
                    fetch c_get_asg_id into l_primary_asg;

                    if c_get_asg_id%NOTFOUND then
                       close c_get_asg_id;
                       hr_utility.raise_error;
                    else
                       close c_get_asg_id;
                    end if;

                    open c_archived_person_info (l_person_id,
                                                 l_primary_asg,
                                                 l_pre_organization_id);
                    fetch c_archived_person_info
                    into ln_arch_asgact_id,
                         ln_arch_pact_id;
                    if c_archived_person_info%notfound then
                       hr_utility.trace('No Archived Person Found');
                    else
                         select pay_assignment_actions_s.nextval
                         into   lockingactid
                         from   dual;

                         hr_nonrun_asact.insact(lockingactid,
                       --                       l_asg_id, -- commented by sneelapa, for bug 7572889
                                                l_primary_asg,
                                                pactid,
                                                chunk,
                                                l_pre_org_id);
     	          	 hr_utility.trace('in if loop after calling '||
                            'hr_nonrun_asact.insact pkg 11 '||to_char(lockingactid));

                  /* Added this to implement RL1 Register and RL1 Amendment Register
                    using the same report file */
                         lv_serial_number := 'QC' ||lpad(to_char(ln_arch_asgact_id),14,0)||
                                          lpad(to_char(ln_arch_pact_id),14,0);

                         hr_utility.trace('lv_serial_number :' ||lv_serial_number);

                         update pay_assignment_actions paa
                         set paa.serial_number = lv_serial_number
                         where paa.assignment_action_id = lockingactid;

                         l_prev_person_id   := l_person_id;
                         l_prev_pre_organization_id := l_pre_organization_id;

                    end if;
                    close c_archived_person_info;

                 end if;

               end loop;

                 /* Added this validation to fix bug#2135545 */
                if l_asg_set_id is not null then
                   close c_all_asg_in_asgset;
                elsif lv_per_id is not null then
	           close c_single_asg;
                else
	           close c_all_asg;
                end if;

	     hr_utility.trace('End of cursor c_all_asg 12');
         end if;
end if;
		hr_utility.trace('End of If Condition for Loop 13');
end action_creation;
/*
   ---------------------------------- sort_action ----------------------------------
*/
procedure sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out nocopy    number        /* length of the sql string */
) is
   begin
	hr_utility.trace('Start of Sort_Action 1');
	-- assignment_type, primary_flag condition are added by sneelapa, for bug 7572889
      sqlstr :=  'select paa1.rowid   /* we need the row id of the assignment actions that are created by PYUGEN */
                   from hr_all_organization_units  hou1,
                        hr_all_organization_units  hou,
                        hr_locations_all  	   loc,
			per_all_people_f           ppf,
                        per_all_assignments_f      paf,
                        pay_assignment_actions     paa1,
                        pay_payroll_actions        ppa1
		   where ppa1.payroll_action_id = :pactid
		   and   paa1.payroll_action_id = ppa1.payroll_action_id
		   and   paa1.assignment_id = paf.assignment_id
       and   paf.assignment_type = ''E''
       and   paf.primary_flag = ''Y''
       and   paf.business_group_id = ppa1.business_group_id
       and   paf.effective_start_date <= ppa1.effective_date
		   and   hou.organization_id = paa1.tax_unit_id
		   and   loc.location_id  = paf.location_id
		   and   hou1.organization_id  = paf.organization_id
		   and   ppf.person_id = paf.person_id
		   and   ppa1.effective_date between
		         ppf.effective_start_date and ppf.effective_end_date
                   and   paf.effective_end_date =
                          (select max(paaf2.effective_end_date)
                           from per_all_assignments_f paaf2
                           where paaf2.assignment_id = paf.assignment_id
                           and paaf2.effective_start_date <= ppa1.effective_date)
    order by
      decode(pay_ca_rl1_reg.get_parameter(''P_S1'',ppa1.legislative_parameters),
                            ''RL1_PRE'',hou.name,
                            ''RL1_ORG'',hou1.name,
                            ''RL1_LOC'',loc.location_code,null)
     ,decode(pay_ca_rl1_reg.get_parameter(''P_S2'',ppa1.legislative_parameters),
                            ''RL1_PRE'',hou.name,
                            ''RL1_ORG'',hou1.name,
                            ''RL1_LOC'',loc.location_code,null)
     ,decode(pay_ca_rl1_reg.get_parameter(''P_S3'',ppa1.legislative_parameters),
                            ''RL1_PRE'',hou.name,
                            ''RL1_ORG'',hou1.name,
                            ''RL1_LOC'',loc.location_code,null)
     ,ppf.last_name,ppf.first_name';

--   Remove below lines from above query and rewrite it using add_months
--   paaf.effective_end_date,-1,to_date(''31-DEC-''||
--   to_char(paaf.effective_end_date,''YY'')) )

      len := length(sqlstr); -- return the length of the string.
	hr_utility.trace('End of Sort_Action 2');
   end sort_action;
/*
------------------------------ get_parameter -------------------------------
*/
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin

     token_val := name||'=';

     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;

     return par_value;

end get_parameter;

/* Get RL1 Messages */
/* Modified this function on 08-Jan-2002 version 115.8
Bug - 2159362
The "From" date should indicate either the day the employee was hired (hire
date) if hired within the Calendar Year, or January 1st of the Calendar Year
if hired prior to the Calendar Year.  Presently the "From" date is using the
date on which the employee turned 18.
*/
function get_rl1_message(p_tax_year        in varchar2,
                         p_emp_dob         in varchar2,
                         p_hire_dt         in varchar2,
                         p_termination_dt  in varchar2) return varchar2
is
  lv_message  varchar2(250) := null;
  lv_eighteen varchar2(250);
  lv_year     varchar2(250);
  lv_st_dt    varchar2(250);
begin
   if to_number(p_tax_year) -
      to_number(to_char(fnd_date.canonical_to_date(p_emp_dob),'YYYY')) = 18 then
        lv_year := to_char(add_months(trunc(to_date(p_tax_year,'YYYY'),'Y'),
                           12)-1,'DD-MON-YYYY');
        lv_eighteen := to_char(add_months(fnd_date.canonical_to_date(p_emp_dob),
                               216), 'DD-MON-YYYY');
        if fnd_date.canonical_to_date(p_hire_dt) <=
                    trunc(to_date(p_tax_year,'YYYY'),'Y') then
           lv_st_dt := to_char(trunc(to_date(p_tax_year,'YYYY'),'Y'),
                               'DD-MON-YYYY');
        else
           lv_st_dt := p_hire_dt;
        end if;
        if p_termination_dt is not null and
           fnd_date.canonical_to_date(nvl(p_termination_dt,lv_year)) <
              fnd_date.canonical_to_date(lv_year)
        then
           lv_year := p_termination_dt;
        end if;
        hr_utility.set_message(801,'PAY_74040_EOY_EXCP_TURNS_18');
--        hr_utility.set_message_token('ST_DATE',lv_eighteen);
        hr_utility.set_message_token('ST_DATE',lv_st_dt);
        hr_utility.set_message_token('END_DATE',lv_year);
        lv_message := hr_utility.get_message;
   end if;
   return(lv_message);
end get_rl1_message;

--
/* To get primary address of an employee */
/* Address line 1 to 3 are normal address lines */
/* Address Line 4 = City + Province Code + Postal Code */
/* Address Line 5 = Country Code */
/* Address Line 6 = Country Name */
/* Address Line 7 = Town or City */
/* Address Line 8 = Province Code */
/* Address Line 9 = Postal Code */

function get_primary_address(p_person_id       in Number,
                             p_effective_date  in date
                            ) return PrimaryAddress IS

  cursor csr_address( p_person_id      in number,
                      p_effective_date in date) is
    select addr.address_line1
           ,addr.address_line2
           ,addr.address_line3
           ,rtrim(substr(addr.town_or_city,1,23))  ||' '||
            decode(addr.country, 'CA', addr.region_1, 'US', addr.region_2,
                   addr.region_1 )
            ||' '|| addr.country  -- Bug 4134616
            ||' '|| addr.postal_code address_line4
           ,addr.country address_line5 -- Country Code
           ,country.territory_short_name address_line6 -- Country Name
           ,addr.town_or_city Town_or_City
           ,decode(addr.country, 'CA', addr.region_1,
                                 'US', addr.region_2, addr.region_1 ) Province
           ,addr.postal_code Postal_Code
    from   per_addresses             addr
          ,fnd_territories_vl country
    where  addr.person_id      = p_person_id
    and    addr.primary_flag   = 'Y'
/* Added the trunc function by ssmukher for Bug 4205724 */
    and    trunc(p_effective_date) between
                      addr.date_from and nvl(addr.date_to, trunc(p_effective_date))
    and    country.territory_code = addr.country;

addr PrimaryAddress;

begin

  open csr_address(p_person_id,p_effective_date);
  fetch csr_address into addr;
  close csr_address;

  return addr;

end get_primary_address;


function get_label(p_lookup_type in VARCHAR2,
                    p_lookup_code in VARCHAR2)
return VARCHAR2 is
cursor csr_label_meaning is
select meaning
from hr_lookups
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code;

  l_label_meaning  varchar2(80);
begin
  open csr_label_meaning;

    fetch csr_label_meaning into l_label_meaning;
    if csr_label_meaning%NOTFOUND then
      l_label_meaning       := NULL;
    end if;
  close csr_label_meaning;

  return l_label_meaning;
end get_label;


function get_label(p_lookup_type in VARCHAR2,
                    p_lookup_code in VARCHAR2,
                    p_person_language in varchar2)
return VARCHAR2 is
cursor csr_label_meaning is
select 1 ord, meaning
from  fnd_lookup_values
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code
and ( ( p_person_language is null and language = 'US' ) or
      ( p_person_language is not null and language = p_person_language ) )
union all
select 2 ord, meaning
from  fnd_lookup_values
where lookup_type = p_lookup_type
and   lookup_code = p_lookup_code
and ( language = 'US' and p_person_language is not null
      and language <> p_person_language )
order by 1;

  l_order number;
  l_label_meaning  varchar2(80);

begin
  open csr_label_meaning;

   fetch csr_label_meaning into l_order, l_label_meaning;
    if csr_label_meaning%NOTFOUND then
      l_label_meaning       := NULL;
    end if;
  close csr_label_meaning;

   return l_label_meaning;
end get_label;

end pay_ca_rl1_reg;

/
