--------------------------------------------------------
--  DDL for Package Body PAY_CA_RL2_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_RL2_REG" as
/* $Header: pycarl2.pkb 120.4.12000000.3 2007/08/08 05:26:53 amigarg noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        :This package defines the cursors needed to run
                RL2 Register Multi-Threaded Report
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   07-OCT-2002  ssouresr    115.0  Created
   18-NOV-2002  ssouresr    115.1  Added to_number to serial_number returned
                                   by range_cursor
   22_NOV-2002  ssouresr    115.2  Changed Report Category to ARCHIVE
   11-NOV-2003  ssouresr    115.4  Made changes to use Prov Reporting Est
                                   instead of Quebec Business Number. Also
                                   made report Multi-GRE compliant.
   30-DEC-2003  ssattini    115.5  Changed the Sort_action procedure to fix
                                   bug#3163968 and also added get_label
                                   function.
   22-Jan-2004  ssattini    115.6  Added function get_primary_address
                                   used in the RL2 Paper Report.
   27-FEB-2004  ssattini    115.7  Modified the c_all_asg cursor
                                   to fix the 11510 performance bug#3356512.
   06-MAY-2004  ssattini    115.8  Modified the c_all_asg cursor
                                   and sort_action sql stmt because the RL2
                                   Paper report was erroring out with assertion
                                   error, changed sort_action same as RL1
                                   Register pkg as mentioned in bug#3493075.
                                   The 11510 bug#3601976 was not showing the
                                   employee in RL2 Paper because that employee
                                   had negative RL2 Box values.
   30-JUL-2004 ssouresr     115.9  Before creating assignment actions we now
                                   check to make sure employee has been previously
                                   archived
   22-NOV-2004 ssouresr     115.10 Replaced tables with views for security group
   15-JUN-2005 ssouresr     115.11 Replaced views with tables in sort_action
                                   as this was causing Assertion failure
   21-JUN-2005 ssouresr     115.12 Security Profile changes to c_first_tax_unit_id
   13-jul-2005 saurgupt     115.13 Modified function get_primary_address. Cursor csr_address
                                   is modified to add country_code in address_line4 to
                                   fix #Bug 4131616.
   04-FEB-2006 ssouresr     115.14 Added code to run the RL2 Paper
                                   Report for a single employee,
                                   part of enhancement to add
                                   'Selection Criterion'
                                   parameters to the RL2 SRS Defn.
                                   Removed references to hr_soft_coding_keyflex
   13-NOV-2006 ssmukher     115.15 Added the orderby clause in c_all_asg cursor.

----------------------------------- range_cursor -----------------------------
*/

procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
  l_payroll_id number;
  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_taxyear    varchar2(100);
  l_pre_org_id varchar2(100);

begin
     --hr_utility.trace_on('Y','RL2');
     hr_utility.trace('begining of range_cursor 1 ');

   select legislative_parameters
   into leg_param
   from pay_payroll_actions ppa
   where ppa.payroll_action_id = pactid;

   l_taxyear    := '''' || pay_ca_rl2_reg.get_parameter('TAX_YEAR',leg_param) || '''';
   l_pre_org_id := '''' || pay_ca_rl2_reg.get_parameter('PRE_ORGANIZATION_ID',leg_param) || '''';

   sqlstr := 'select distinct to_number(paa_arch.serial_number)
              from    pay_action_information pai1,
                      pay_action_information pai2,
	              pay_payroll_actions    ppa_reg,
	              pay_payroll_actions    ppa_arch,
                      pay_assignment_actions paa_arch
              where ppa_reg.payroll_action_id    = :payroll_action_id
              and pai1.action_context_type = ''PA''
              and pai1.action_information1 = ''RL2''
              and pai1.action_information_category = ''CAEOY TRANSMITTER INFO''
              and pai1.action_information8 = nvl(' ||l_taxyear ||', pai1.action_information8)
              and pai1.action_information27 = nvl(' ||l_pre_org_id || ',pai1.action_information27)
              and pai2.action_context_type = ''AAP''
              and pai2.action_information_category = ''CAEOY RL2 EMPLOYEE INFO''
              and ppa_arch.payroll_action_id    = pai1.action_context_id
              and ppa_arch.payroll_action_id    = paa_arch.payroll_action_id
              and paa_arch.assignment_action_id = pai2.action_context_id
              and paa_arch.action_status        = ''C''
              and paa_arch.serial_number = nvl(pay_ca_rl2_reg.get_parameter(''PER_ID'',ppa_reg.legislative_parameters),
                                               paa_arch.serial_number)
	      order by to_number(paa_arch.serial_number)';

	hr_utility.trace('End of range_cursor 2 ');
end range_cursor;
/*
-------------------------------- action_creation ----------------------------------
*/

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

      lockingactid              number;
      l_asg_id                  number;
      l_asg_set_id              number;
      l_tax_unit_id             number;
      l_year                    varchar2(4);
      l_primary_asg             number;
      l_bus_group_id            number;
      l_person_id               number;
      l_prev_person_id          number;
      l_year_start              date;
      l_year_end                date;
      l_pre_org_id              varchar2(30);
      l_prev_pre_org_id         varchar2(30);
      l_pre_organization_id     number;
      l_rlreg_pre_org_id        varchar2(30);
      l_effective_date          date;
      l_report_type             varchar2(80);
      l_legislative_parameters  varchar2(240);
      lv_serial_number          varchar2(30);
      ln_arch_asgact_id         number;
      ln_arch_pact_id           number;
      lv_per_id                 varchar2(30);


/* For performance: getting all Prov Reporting Est org ids from
   legislative parameter of pay_payroll_actions for RL2 archiver
   for the given year within same business group.
*/
   cursor c_all_pres is
   select pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
          ppa.legislative_parameters )
   from pay_payroll_actions ppa
   where ppa.report_type       = 'RL2'
   and   ppa.report_qualifier  = 'CAEOYRL2'
   and   ppa.report_category   = 'ARCHIVE'
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
   where ppa.report_type       = 'RL2'
   and   ppa.report_qualifier  = 'CAEOYRL2'
   and   ppa.report_category   = 'ARCHIVE'
   and   ppa.effective_date    = l_year_end
   and   ppa.start_date        = l_year_start
   and   ppa.business_group_id = l_bus_group_id
   and   ppa.action_status     = 'C'
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   paa.serial_number     = to_char(cp_person_id)
   and   pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
          ppa.legislative_parameters) = cp_pre_org_id
   and   paa.assignment_id     = cp_assignment_id;

   cursor c_get_asg_id (p_person_id number) is
   select assignment_id
   from per_assignments_f paf
   where person_id = p_person_id
   and   primary_flag    = 'Y'
   and   assignment_type = 'E'
   and   paf.effective_start_date  <= l_year_end
   and   paf.effective_end_date    >= l_year_start
   order by assignment_id desc;


   cursor c_first_tax_unit_id (l_pre_org_id varchar2) is
   select distinct hoi.organization_id
   from hr_organization_information hoi,
        hr_all_organization_units   hou
   where hou.business_group_id  = l_bus_group_id
   and   hou.organization_id    = hoi.organization_id
   and   hoi.org_information_context = 'Canada Employer Identification'
   and   hoi.org_information2 = l_pre_org_id
   and   hoi.org_information5 = 'T4A/RL2';

   cursor c_all_asg (l_year_start   date,
                     l_year_end     date) is
   select distinct paa.assignment_id,
                   to_number(paa.serial_number)
   from pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.report_type       = 'RL2'
   and   ppa.report_qualifier  = 'CAEOYRL2'
   and   ppa.report_category   = 'ARCHIVE'
   and   ppa.effective_date    = l_year_end
   and   ppa.start_date        = l_year_start
   and   ppa.business_group_id = l_bus_group_id
   and   ppa.action_status     = 'C'
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   to_number(paa.serial_number) between stperson and endperson
   order by to_number(paa.serial_number);

/*
   select distinct paf.assignment_id  assignment_id,
                   paf.person_id      person_id
   from
         per_assignments_f paf
   where paf.person_id between stperson and endperson
   and   paf.assignment_type       = 'E'
   and   paf.primary_flag          = 'Y'
   and   paf.effective_end_date    >= l_year_start
   and   paf.business_group_id     = l_bus_group_id
   and   paf.effective_start_date =
                         (select max(paf2.effective_start_date)
                          from per_assignments_f paf2
                          where paf2.assignment_id = paf.assignment_id
                            and paf2.effective_start_date <= l_year_end )

   order by paf.person_id;
*/

   cursor c_single_asg (l_year_start   date,
                        l_year_end     date,
                        l_per_id       varchar2) is
   select distinct paa.assignment_id,
                   to_number(paa.serial_number)
   from pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.report_type       = 'RL2'
   and   ppa.report_qualifier  = 'CAEOYRL2'
   and   ppa.report_category   = 'ARCHIVE'
   and   ppa.effective_date    = l_year_end
   and   ppa.start_date        = l_year_start
   and   ppa.business_group_id = l_bus_group_id
   and   ppa.action_status     = 'C'
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   to_number(paa.serial_number) between stperson and endperson
   and   paa.serial_number = l_per_id;

/*
   select distinct paf.assignment_id  assignment_id,
                   paf.person_id      person_id
   from
         per_assignments_f paf
   where paf.person_id between stperson and endperson
   and   paf.person_id             = to_number(l_per_id)
   and   paf.assignment_type       = 'E'
   and   paf.primary_flag          = 'Y'
   and   paf.effective_start_date  <= l_year_end
   and   paf.effective_end_date    >= l_year_start
   and   paf.business_group_id     = l_bus_group_id;
*/


/*  Will be used only if Assignment Set is passed for RL2 reports */

   cursor c_all_asg_in_asgset(l_year_start   date,
                              l_year_end     date) is
   select distinct paa.assignment_id,
                   to_number(paa.serial_number)
   from pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.report_type       = 'RL2'
   and   ppa.report_qualifier  = 'CAEOYRL2'
   and   ppa.report_category   = 'ARCHIVE'
   and   ppa.effective_date    = l_year_end
   and   ppa.start_date        = l_year_start
   and   ppa.business_group_id = l_bus_group_id
   and   ppa.action_status     = 'C'
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   to_number(paa.serial_number) between stperson and endperson
   and exists (select 1
               from hr_assignment_set_amendments hasa,
                    per_assignments_f paf
               where hasa.assignment_set_id         = l_asg_set_id
               and   upper(hasa.include_or_exclude) = 'I'
               and   hasa.assignment_id             = paf.assignment_id
               and   paf.person_id = to_number(paa.serial_number));

/*
   select distinct paf.assignment_id  assignment_id,
                   paf.person_id      person_id
   from  per_assignments_f paf
   where paf.person_id between stperson and endperson
   and   paf.assignment_type       = 'E'
   and   paf.primary_flag          = 'Y'
   and   paf.effective_start_date  <= l_year_end
   and   paf.effective_end_date    >= l_year_start
   and   paf.business_group_id     = l_bus_group_id
   and exists (select 1
               from hr_assignment_set_amendments hasa
               where hasa.assignment_set_id         = l_asg_set_id
               and   hasa.assignment_id             = paf.assignment_id
               and   upper(hasa.include_or_exclude) = 'I');
*/

   begin
        --hr_utility.trace_on('Y','RL2PAPER');
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

   hr_utility.trace('legislative parameters is '||l_legislative_parameters);

   l_year       := pay_ca_rl2_reg.get_parameter('TAX_YEAR',l_legislative_parameters);
   l_year_start := trunc(to_date(l_year,'YYYY'), 'Y');
   l_year_end   := add_months(trunc(to_date(l_year,'YYYY'), 'Y'),12) - 1;
   l_asg_set_id := pay_ca_rl2_reg.get_parameter('ASG_SET_ID',l_legislative_parameters);
   lv_per_id    := pay_ca_rl2_reg.get_parameter('PER_ID',l_legislative_parameters);

   l_rlreg_pre_org_id := pay_ca_rl2_reg.get_parameter('PRE_ORGANIZATION_ID',l_legislative_parameters);

   if  l_rlreg_pre_org_id is NULL then
       open c_all_pres;
       hr_utility.trace('else condition after open c_all_pres c_all_asg cursor 6 ');
   else
       l_pre_org_id := l_rlreg_pre_org_id;
       hr_utility.trace('begining of if condition 5 '||l_pre_org_id);
   end if;


   if l_rlreg_pre_org_id is NULL then

       loop
           fetch c_all_pres into l_pre_org_id;
    	   hr_utility.trace('Begining of else loop for c_all_pres 7 '|| l_pre_org_id);

           exit when c_all_pres%notfound;

           open c_first_tax_unit_id(l_pre_org_id);
           fetch c_first_tax_unit_id into l_tax_unit_id;

           if c_first_tax_unit_id%FOUND then
                close c_first_tax_unit_id;

                l_pre_organization_id := to_number(l_pre_org_id);

                if l_asg_set_id is not null then
                   open c_all_asg_in_asgset(l_year_start, l_year_end );
                elsif lv_per_id is not null then
                   open c_single_asg(l_year_start,
                                     l_year_end, lv_per_id);

                else
                   open c_all_asg(l_year_start, l_year_end );
                end if;

                loop
                    if l_asg_set_id is not null then
                       fetch c_all_asg_in_asgset into l_asg_id, l_person_id;
                       exit when c_all_asg_in_asgset%notfound;
                    elsif lv_per_id is not null then
                       fetch c_single_asg into l_asg_id, l_person_id;
                       exit when c_single_asg%notfound;
                    else
                       fetch c_all_asg into l_asg_id, l_person_id;
                       exit when c_all_asg%notfound;
                    end if;

                    if (l_person_id   = l_prev_person_id   and
                        l_pre_org_id  = l_prev_pre_org_id) then

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
                                                    l_pre_org_id);
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
                                                 l_primary_asg,
                                                 pactid,
                                                 chunk,
                                                 l_pre_organization_id);

       		          hr_utility.trace('after hr_nonrun_asact.insact'||to_char(l_asg_id));

                          lv_serial_number := 'QC' ||lpad(to_char(ln_arch_asgact_id),14,0)||
                                           lpad(to_char(ln_arch_pact_id),14,0);

                          hr_utility.trace('lv_serial_number :' ||lv_serial_number);

                          update pay_assignment_actions paa
                          set paa.serial_number = lv_serial_number
                          where paa.assignment_action_id = lockingactid;

                          l_prev_person_id  := l_person_id;
                          l_prev_pre_org_id := l_pre_org_id;

                       end if;
                       close c_archived_person_info;

                    end if;

                end loop;

                if l_asg_set_id is not null then
                   close c_all_asg_in_asgset;
                elsif lv_per_id is not null then
                   close c_single_asg;
                else
	           close c_all_asg;
                end if;

            else
                close c_first_tax_unit_id;
                hr_utility.trace('No GRE for this PRE ');

            end if;

          end loop;

          close c_all_pres;
   else
          open c_first_tax_unit_id(l_pre_org_id);
          fetch c_first_tax_unit_id into l_tax_unit_id;

          if c_first_tax_unit_id%FOUND then
              close c_first_tax_unit_id;

              l_pre_organization_id := to_number(l_pre_org_id);

              if l_asg_set_id is not null then
                 open c_all_asg_in_asgset(l_year_start,
                                          l_year_end);
              elsif lv_per_id is not null then
                 open c_single_asg(l_year_start,
                                   l_year_end, lv_per_id);

              else
                 open c_all_asg(l_year_start, l_year_end);
              end if;

              loop

                if l_asg_set_id is not null then
                   fetch c_all_asg_in_asgset into l_asg_id, l_person_id;
                   exit when c_all_asg_in_asgset%notfound;
                elsif lv_per_id is not null then
                   fetch c_single_asg into l_asg_id, l_person_id;
                   exit when c_single_asg%notfound;
                else
                   fetch c_all_asg into l_asg_id, l_person_id;
                   exit when c_all_asg%notfound;
                end if;

                if (l_person_id   = l_prev_person_id   and
                    l_pre_org_id = l_prev_pre_org_id) then

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

                    open c_archived_person_info(l_person_id,
                                                l_primary_asg,
                                                l_pre_org_id);
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
                                                l_primary_asg,
                                                pactid,
                                                chunk,
                                                l_pre_organization_id);

	                 hr_utility.trace('after calling hr_nonrun_asact.insact '||to_char(lockingactid));

                         lv_serial_number := 'QC' ||lpad(to_char(ln_arch_asgact_id),14,0)||
                                          lpad(to_char(ln_arch_pact_id),14,0);

                         hr_utility.trace('lv_serial_number :' ||lv_serial_number);

                         update pay_assignment_actions paa
                         set paa.serial_number = lv_serial_number
                         where paa.assignment_action_id = lockingactid;

                         l_prev_person_id   := l_person_id;
                         l_prev_pre_org_id  := l_pre_org_id;

                    end if;
                    close c_archived_person_info;

                 end if;

              end loop;

              if l_asg_set_id is not null then
                 close c_all_asg_in_asgset;
              elsif lv_per_id is not null then
                 close c_single_asg;
              else
	         close c_all_asg;
              end if;

	      hr_utility.trace('End of cursor c_all_asg 12');
         else
              close c_first_tax_unit_id;
              hr_utility.trace('No GRE for this PRE ');
         end if;
   end if;
end action_creation;
/*
   ---------------------------------- sort_action ----------------------------------
*/
procedure sort_action
(payactid   in     varchar2,     /* payroll action id */
 sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
 len        out nocopy    number)       /* length of the sql string */
is
   begin
     hr_utility.trace('Start of Sort_Action 1');

     sqlstr :=  'select paa1.rowid   /* we need the row id of the assignment actions that are created by PYUGEN */
                   from hr_all_organization_units  hou1,
                        hr_all_organization_units  hou,
                        hr_locations_all           loc,
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
                   and   ppa1.effective_date >= paf.effective_start_date
                   and    hou.organization_id = paa1.tax_unit_id
                   and    loc.location_id  = paf.location_id
                   and    hou1.organization_id  = paf.organization_id
                   and    ppf.person_id = paf.person_id
                   and    ppa1.effective_date between
                          ppf.effective_start_date and ppf.effective_end_date
                   and    paf.effective_end_date = (
                           select max(paaf2.effective_end_date)
                           from per_all_assignments_f paaf2
                           where paaf2.assignment_id = paf.assignment_id
                           and paaf2.effective_start_date <= ppa1.effective_date
                          )
                   order by
                   decode(pay_ca_rl2_reg.get_parameter(''P_S1'',ppa1.legislative_parameters),                            ''RL1_PRE'',hou.name,
                            ''RL1_ORG'',hou1.name,
                            ''RL1_LOC'',loc.location_code,null)
                   ,decode(pay_ca_rl2_reg.get_parameter(''P_S2'',ppa1.legislative_parameters),                            ''RL1_PRE'',hou.name,
                            ''RL1_ORG'',hou1.name,
                            ''RL1_LOC'',loc.location_code,null)
                   ,decode(pay_ca_rl2_reg.get_parameter(''P_S3'',ppa1.legislative_parameters),                            ''RL1_PRE'',hou.name,
                            ''RL1_ORG'',hou1.name,
                            ''RL1_LOC'',loc.location_code,null)
     ,ppf.last_name,ppf.first_name';

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

function get_label(p_lookup_type in varchar2,
                   p_lookup_code in varchar2) return varchar2 is

  l_meaning  hr_lookups.meaning%TYPE;

  CURSOR cur_get_meaning IS
  SELECT hl.meaning
  FROM hr_lookups hl
  WHERE hl.lookup_type = p_lookup_type AND
    hl.lookup_code = p_lookup_code;

BEGIN

  OPEN cur_get_meaning;
  FETCH cur_get_meaning
  INTO  l_meaning;
  if cur_get_meaning%NOTFOUND then
    l_meaning := NULL;
  end if;

  CLOSE cur_get_meaning;

  RETURN l_meaning;

END get_label; -- get_label

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
            ||' '|| addr.country      -- Bug 4134616
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
    and    p_effective_date between
                      addr.date_from and nvl(addr.date_to, p_effective_date)
    and    country.territory_code = addr.country;

addr PrimaryAddress;

begin

  open csr_address(p_person_id,p_effective_date);
  fetch csr_address into addr;
  close csr_address;

  return addr;

end get_primary_address;

end pay_ca_rl2_reg;

/
