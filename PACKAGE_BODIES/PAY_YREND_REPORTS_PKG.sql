--------------------------------------------------------
--  DDL for Package Body PAY_YREND_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_YREND_REPORTS_PKG" as
/* $Header: pyusw2cu.pkb 120.3.12010000.4 2009/01/29 06:27:45 asgugupt ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Name        :This package defines the cursors needed to run Year End Reports Multi-Threaded

   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   09-MAR-1999  meshah      40.0   created
   20-JUL-2001	irgonzal    115.1  Modified action_creation and sort_
                                   action procedures. Bug fixes:
                                   1850043, 1488083, 1894165.
   22-JUL-2001 ndorai       115.2  Commented the join clause and the
                                   call to API hr_us_w2_rep.person_in_set
                                   in range_cursor to improve performance and
                                   modified the query of action_creation.
   26-JUL-2001 ndorai       115.3  Modified the action_creation cursor and
                                   range_cursor.
   30-JUL-2001 ndorai       115.4  Replaced per_assignments_f with
                                   per_all_assignments_f in sort_action_cursor.
   26-SEP-2001 ndorai       115.5  Fixed the sort_action string so that the
                                   variable value will be substituted properly.
   24-DEC-2001 meshah       115.8  Changed hr_locations to hr_locations_all.
   06-JAN-2002 meshah       115.9  inlcuded a space in range cursor while
                                   constructing the sqlstr.
   11-SEP-2002 ppanda	    115.10 Sort cursor sql string changed to use
                                   pay_assignment_actions instead of per_all_assignments_f
                                   in for update clause

   09-JAN-2003 ahanda	    115.13 Sort cursor changed ti Fix Bug 2743186
   09-JAN-2003 asasthan	    115.14 nocopy changes
   07-AUG-2003 jgoswami     115.15 Action cursor changed to Fix Bug 2573628
                                   split into two cursors as c_actions_with_asg_set
                                   and c_actions_without_asg_set
   11-AUG-2003 jgoswami     115.16 Commented the to_char(USERENV('SESSIONID'))
   05-SEP-2003 ahanda       115.17 Changed sort_action to not go to secure view.
                                   As the action is already created the sort_cursor
                                   should go to the base table(Bug 3131302).
   09-SEP-2004 rsethupa     115.18 Modified cursors in the action_creation
                                   procedure to fetch only from
				   secure view per_assignments_f.
   14-MAR-2005 sackumar     115.19 Bug 4222032
                                   Change in the Range Cursor removing redundant
                                   use of bind Variable (:pactid)
   25-MAY-2005 ahanda       115.20 Bug 4378773
                                   Changed function get_parameter to check for
                                   exact name i.e. ' ' || name || '='
   12-SEP-2005 ynegoro      115.21 Bug 2538173, added locality parameter
   21-SEP-2005 ynegoro      115.22 Bug 2538173, Modifed for locality parameter
   22-SEP-2005 ahanda       115.23 Changed action creation for locality param.
   31-AUG-2006 saurgupt     115.24 Bug 3913757 : Made change to sort_action. Added the employee
                                   name in the sort2 and sort3 if no sort option is provided in
                                   sort2 and sort3.
   12-MAY-2008 keyazawa     115.24 bug 5896290 added deinitialize_code
*/
--
c_package    constant varchar2(31) := 'pay_yrend_reports_pkg.';
c_commit_num constant number := 1000;
--
g_debug      boolean := hr_utility.debug_enabled;
--
----------------------------------- range_cursor ----------------------------------
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is


  l_assign_year number;
  l_tax_unit_id pay_assignment_actions.tax_unit_id%type;
  l_eoy_payroll_action_id pay_payroll_actions.payroll_action_id%type;
begin

  /* EOY reg code */
  /* year end pre-processor stores person id in serial number */
  -- Query is added to fetch the tax_unit_id, year, EOY payroll_action_id to be
  -- passed to the sqlstring to improve the performance.
  --
  select pay_yrend_reports_pkg.get_parameter('T_U_ID',ppa1.legislative_parameters),
         pay_yrend_reports_pkg.get_parameter('P_YEAR',ppa1.legislative_parameters),
         ppa.payroll_action_id
   into  l_tax_unit_id,
         l_assign_year,
         l_eoy_payroll_action_id
   from pay_payroll_actions ppa,   /* EOY payroll action id */
        pay_payroll_actions ppa1   /* PYUGEN payroll action id */
  where ppa1.payroll_action_id = pactid
    and ppa.effective_date = to_date('31-DEC-'||
                                  pay_yrend_reports_pkg.get_parameter
                                   ('P_YEAR',ppa1.legislative_parameters), 'DD-MON-YYYY')
    and ppa.report_type = 'YREND'
    and pay_yrend_reports_pkg.get_parameter
               ('T_U_ID',ppa1.legislative_parameters) =
                          pay_yrend_reports_pkg.get_parameter
                              ('TRANSFER_GRE',ppa.legislative_parameters);

   sqlstr := 'select distinct to_number(act.serial_number)
                from    pay_assignment_actions act  /* W2 Register Information */
               where  :pactid is not null
                 and    act.payroll_action_id = ' || l_eoy_payroll_action_id ||
 	       ' and    act.tax_unit_id = ' || l_tax_unit_id ||
	       ' order by to_number(act.serial_number)';

--hr_utility.trace('Session ID = '||to_char(USERENV('SESSIONID')));
end range_cursor;

---------------------------------- action_creation ----------------------------------
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is
  -- cursor has been modified by adding new parameter c_pay_action_id and removed
  -- the reference to pay_payroll_actions table by fetching values in a separate query.
  --
  -- cursor will be used when asignment_set is  selected.

  CURSOR c_actions_with_asg_set
      (
         pactid    number,
         stperson  number,
         endperson number,
         c_assign_year number,
         c_tax_unit_id pay_assignment_actions.tax_unit_id%type,
         c_assign_set hr_assignment_set_amendments.assignment_set_id%type,
         c_eoy_payroll_action_id pay_payroll_actions.payroll_action_id%type
      ) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             to_number(act.serial_number)
             -- need to select person id to check for assignment set
       from  pay_assignment_actions  act
      where  act.payroll_action_id = c_eoy_payroll_action_id
        and  act.tax_unit_id = c_tax_unit_id
        and  to_number(act.serial_number) between stperson and endperson
        and  exists ( select 1
                       from per_assignments_f paf,
                            hr_assignment_set_amendments hasa
                      where hasa.assignment_set_id = c_assign_set
                        and hasa.assignment_id = paf.assignment_id
                        and upper(hasa.include_or_exclude) = 'I'
                        and c_assign_set is not null
                        and paf.person_id = to_number(act.serial_number)
                   );

/* when assignment_set is not selected */
-- #3871087 Included join with per_assignments_f
  CURSOR c_actions_without_asg_set
      (
         pactid    number,
         stperson  number,
         endperson number,
         c_assign_year number,
         c_tax_unit_id pay_assignment_actions.tax_unit_id%type,
         c_eoy_payroll_action_id pay_payroll_actions.payroll_action_id%type,
         c_effective_date  pay_payroll_actions.effective_date%TYPE,
         c_start_date      pay_payroll_actions.start_date%TYPE
      ) is
      select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             to_number(act.serial_number)
             -- need to select person id to check for assignment set
       from  pay_assignment_actions  act,
             per_assignments_f paf
      where  act.payroll_action_id = c_eoy_payroll_action_id
        and  act.tax_unit_id = c_tax_unit_id
	and  paf.assignment_id = act.assignment_id
        and  paf.effective_start_date =
                         (select max(paf2.effective_start_date)
                          from per_assignments_f paf2
                          where paf2.assignment_id = paf.assignment_id
                            and paf2.effective_start_date <=
                                                          c_effective_date )
        AND paf.effective_end_date >= c_start_date
        AND paf.assignment_type = 'E'
        and  to_number(act.serial_number) between stperson and endperson;

      lockingactid  number;
      lockedactid   number;
      assignid      number;
      greid         number;
      num           number;
      p_person_id   number;
      l_assign_set  number;
      l_assign_year number;
      l_tax_unit_id pay_assignment_actions.tax_unit_id%type;
      l_eoy_payroll_action_id pay_payroll_actions.payroll_action_id%type;

      l_effective_date pay_payroll_actions.effective_date%TYPE;
      l_start_date     pay_payroll_actions.start_date%TYPE;

      -- BUG2538173
      CURSOR c_state_context (p_context_name varchar2) is
       select context_id from ff_contexts
       where context_name = p_context_name;

      l_state_code       pay_us_states.state_code%type;
      l_locality_code    varchar2(20);

      TYPE RefCurType is REF CURSOR;
      c_actions_with_state      RefCurType;
      c_actions_with_state_sql varchar2(10000);
      l_tuid_context    ff_contexts.context_id%TYPE;
      l_juri_context    ff_contexts.context_id%TYPE;

      CURSOR c_state_ueid (p_user_entity_name varchar2) is
       select user_entity_id
       from ff_user_entities
       where user_entity_name = p_user_entity_name
         and legislation_code = 'US';

      l_subj_whable       ff_user_entities.user_entity_id%TYPE;
      l_subj_nwhable      ff_user_entities.user_entity_id%TYPE;

      l_procedure_name    VARCHAR2(100);

   begin
--      hr_utility.trace_on(null, 'W2REG');
      l_procedure_name := 'action_creation';
      hr_utility.set_location(l_procedure_name, 1);
      --
      -- Query has been added to fetch tax_unit_id, year to be passed to the cursor
      select pay_yrend_reports_pkg.get_parameter('ASSIGN_SET',ppa1.legislative_parameters),
             pay_yrend_reports_pkg.get_parameter('T_U_ID',ppa1.legislative_parameters),
             pay_yrend_reports_pkg.get_parameter('P_YEAR',ppa1.legislative_parameters),
             ppa.payroll_action_id,
             ppa.effective_date,
             ppa.start_date
            ,hr_us_w2_mt.get_parameter('STATE',ppa1.legislative_parameters)
            ,hr_us_w2_mt.get_parameter('LOCALITY',ppa1.legislative_parameters)
        into l_assign_set,
             l_tax_unit_id,
             l_assign_year,
             l_eoy_payroll_action_id,
             l_effective_date,
             l_start_date
            ,l_state_code  -- BUG2538173
            ,l_locality_code
        from pay_payroll_actions ppa,   /* W2 payroll action id */
             pay_payroll_actions ppa1   /* PYUGEN payroll action id */
       where ppa1.payroll_action_id = pactid
         and ppa.effective_date = to_date('31-DEC-'|| pay_yrend_reports_pkg.get_parameter
                                   ('P_YEAR',ppa1.legislative_parameters), 'DD-MON-YYYY')
         and ppa.report_type = 'YREND'
         and pay_yrend_reports_pkg.get_parameter
                    ('T_U_ID',ppa1.legislative_parameters) =
                 pay_yrend_reports_pkg.get_parameter
                    ('TRANSFER_GRE',ppa.legislative_parameters);

      hr_utility.trace('l_assign_set= ' || l_assign_set);
      hr_utility.trace('l_tax_unit_id=' || l_tax_unit_id);
      hr_utility.trace('l_eoy_payroll_action_id=' || l_eoy_payroll_action_id);
      hr_utility.trace('l_assign_year=' || l_assign_year);
      hr_utility.trace('pactid=' || pactid);
      hr_utility.trace('stperson=' || stperson);
      hr_utility.trace('endperson=' || endperson);
      hr_utility.set_location(l_procedure_name, 10);

   if l_assign_set is not null then
      hr_utility.set_location(l_procedure_name, 20);
      open c_actions_with_asg_set(pactid, stperson, endperson,
                     l_assign_year, l_tax_unit_id,
                     l_assign_set, l_eoy_payroll_action_id);
      num := 0;
      loop
         fetch c_actions_with_asg_set into lockedactid,assignid,greid,p_person_id;
         if c_actions_with_asg_set%found then num := num + 1; end if;
         exit when c_actions_with_asg_set%notfound;

       -- Commenting the IF clause as this condition is already taken care
       -- in the action_creation cursor.
       -- if (hr_assignment_set.person_in_set(l_assign_set,p_person_id)='Y') then

        -- we need to insert one action for each of the
        -- rows that we return from the cursor (i.e. one
        -- for each assignment/pre-payment/reversal).

        select pay_assignment_actions_s.nextval
        into   lockingactid
        from   dual;

        hr_utility.set_location(l_procedure_name, 30);
        -- insert the action record.
        hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

/* update pay_assignment_actions with the year end assignment_actions into serial number
   this might help in faster processing at report level and avoid some joins */

        update pay_assignment_actions
        set serial_number = lockedactid
        where assignment_action_id = lockingactid;


         -- insert an interlock to this action.
         -- Bug fix 1850043
         -- hr_nonrun_asact.insint(lockingactid,lockedactid);

      -- end if;

      end loop;
      close c_actions_with_asg_set;
   --
   -- BUG2538173
   --
   elsif l_state_code is not null then
     hr_utility.set_location(l_procedure_name, 40);
     open c_state_context('TAX_UNIT_ID');
     fetch c_state_context into l_tuid_context;
     close c_state_context;

     open c_state_context('JURISDICTION_CODE');
     fetch c_state_context into l_juri_context;
     close c_state_context;

     hr_utility.set_location(l_procedure_name, 50);
     c_actions_with_state_sql :=
      'select act.assignment_action_id,
             act.assignment_id,
             act.tax_unit_id,
             to_number(act.serial_number)
             -- need to select person id to check for assignment set
       from  pay_assignment_actions  act,
             per_assignments_f paf
      where  act.payroll_action_id = ' || l_eoy_payroll_action_id || '
        and  act.tax_unit_id = ' || l_tax_unit_id || '
	and  paf.assignment_id = act.assignment_id
        and  paf.effective_start_date =
                         (select max(paf2.effective_start_date)
                          from per_assignments_f paf2
                          where paf2.assignment_id = paf.assignment_id
                            and paf2.effective_start_date <= ''' ||
                                                          l_effective_date || ''' )
        AND paf.effective_end_date >= ''' || l_start_date || '''
        AND paf.assignment_type = ''E''
        and  to_number(act.serial_number) between ' || stperson || ' and ' ||endperson;

     hr_utility.set_location(l_procedure_name, 60);
     if l_locality_code is null then
        open c_state_ueid('A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_whable;
        close c_state_ueid;

        open c_state_ueid('A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_nwhable;
        close c_state_ueid;

        hr_utility.set_location(l_procedure_name, 70);
        c_actions_with_state_sql := c_actions_with_state_sql ||
            ' AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = act.assignment_action_id
                               and fai.user_entity_id in (' || l_subj_whable || ',
                                                          ' || l_subj_nwhable || ')
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(act.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || l_state_code || ' ))';


     --
     -- County
     --
     elsif length(l_locality_code) = 11 and
           substr(l_locality_code, 8,4) = '0000' then
        hr_utility.set_location(l_procedure_name, 80);
        open c_state_ueid('A_COUNTY_SUBJ_WHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_whable;
        close c_state_ueid;

        open c_state_ueid('A_COUNTY_SUBJ_NWHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_nwhable;
        close c_state_ueid;

        hr_utility.set_location(l_procedure_name, 90);
        c_actions_with_state_sql := c_actions_with_state_sql ||
              ' AND exists ( select 1 from dual
                             where 1 =
                (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                   from ff_archive_items fai,
                        ff_archive_item_contexts fic1,
                        ff_archive_item_contexts fic2
                  where fai.context1 = act.assignment_action_id
                    and fai.user_entity_id in (' || l_subj_whable || ',
                                               ' || l_subj_nwhable || ')
                    and fai.archive_item_id = fic1.archive_item_id
                    and fic1.context_id = ' || l_tuid_context || '
                    and ltrim(rtrim(fic1.context)) = to_char(act.tax_unit_id)
                    and fai.archive_item_id = fic2.archive_item_id
                    and fic2.context_id = ' || l_juri_context || '
                    and substr(ltrim(rtrim(fic2.context)),1,6) = substr(''' || l_locality_code || ''',1,6) ))';

     --
     -- City
     --
     elsif length(l_locality_code) = 11 and
           substr(l_locality_code, 8,4) <> '0000' then
        hr_utility.set_location(l_procedure_name, 100);

        open c_state_ueid('A_CITY_SUBJ_WHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_whable;
        close c_state_ueid;

        open c_state_ueid('A_CITY_SUBJ_NWHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_nwhable;
        close c_state_ueid;
        hr_utility.trace('l_subj_whable='||l_subj_whable);
        hr_utility.trace('l_subj_nwhable='||l_subj_nwhable);

        c_actions_with_state_sql := c_actions_with_state_sql ||
                ' AND exists ( select 1 from dual
                             where 1 =
                 (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                    from ff_archive_items fai,
                         ff_archive_item_contexts fic1,
                         ff_archive_item_contexts fic2
                    where fai.context1 = act.assignment_action_id
                      and fai.user_entity_id in (' || l_subj_whable || ',
                                                 ' || l_subj_nwhable || ')
                      and fai.archive_item_id = fic1.archive_item_id
                      and fic1.context_id = ' || l_tuid_context || '
                      and ltrim(rtrim(fic1.context)) = to_char(act.tax_unit_id)
                      and fai.archive_item_id = fic2.archive_item_id
                      and fic2.context_id = ' || l_juri_context || '
                      and substr(ltrim(rtrim(fic2.context)),1,11) = ''' || l_locality_code || ''' ))';

     --
     -- School District
     --
     elsif length(l_locality_code) = 8 then

        hr_utility.set_location(l_procedure_name, 120);
        open c_state_ueid('A_SCHOOL_SUBJ_WHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_whable;
        close c_state_ueid;

        open c_state_ueid('A_SCHOOL_SUBJ_NWHABLE_PER_JD_GRE_YTD');
        fetch c_state_ueid into l_subj_nwhable;
        close c_state_ueid;

        c_actions_with_state_sql := c_actions_with_state_sql ||
                ' AND exists ( select 1 from dual
                         where 1 =
                 (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                    from ff_archive_items fai,
                         ff_archive_item_contexts fic1,
                         ff_archive_item_contexts fic2
                   where fai.context1 = act.assignment_action_id
                     and fai.user_entity_id in (' || l_subj_whable || ',
                                                ' || l_subj_nwhable || ')
                     and fai.archive_item_id = fic1.archive_item_id
                     and fic1.context_id = ' || l_tuid_context || '
                     and ltrim(rtrim(fic1.context)) = to_char(act.tax_unit_id)
                     and fai.archive_item_id = fic2.archive_item_id
                     and fic2.context_id = ' || l_juri_context || '
                      and substr(ltrim(rtrim(fic2.context)),1,8) = ''' || l_locality_code || '''))';

     end if;
     hr_utility.set_location(l_procedure_name, 150);

     num := 0;
     OPEN c_actions_with_state FOR c_actions_with_state_sql;
     loop
        fetch c_actions_with_state into lockedactid,assignid,greid,p_person_id;
        if c_actions_with_state%found then
           num := num + 1;
           hr_utility.trace('In the c_actions_with_state%found in action cursor');
         else
           hr_utility.trace('In the c_actions_with_state%notfound in action cursor');
           exit;
         end if;

         hr_utility.set_location(l_procedure_name, 160);
         select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert the action record.
            hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

            update pay_assignment_actions
            set serial_number = lockedactid
            where assignment_action_id = lockingactid;

         end loop;
       close c_actions_with_state;
       -- end of l_state_code
   else
      hr_utility.set_location(l_procedure_name, 170);
      open c_actions_without_asg_set(pactid, stperson, endperson,
                     l_assign_year, l_tax_unit_id,
                     l_eoy_payroll_action_id,l_effective_date,l_start_date);
      num := 0;
      loop
         fetch c_actions_without_asg_set into lockedactid,assignid,greid,p_person_id;
         if c_actions_without_asg_set%found then num := num + 1; end if;
         exit when c_actions_without_asg_set%notfound;

       -- Commenting the IF clause as this condition is already taken care
       -- in the action_creation cursor.
       -- if (hr_assignment_set.person_in_set(l_assign_set,p_person_id)='Y') then

        -- we need to insert one action for each of the
        -- rows that we return from the cursor (i.e. one
        -- for each assignment/pre-payment/reversal).

        hr_utility.set_location(l_procedure_name, 180);
        select pay_assignment_actions_s.nextval
        into   lockingactid
        from   dual;

        -- insert the action record.
        hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

/* update pay_assignment_actions with the year end assignment_actions into serial number
   this might help in faster processing at report level and avoid some joins */

        update pay_assignment_actions
        set serial_number = lockedactid
        where assignment_action_id = lockingactid;


         -- insert an interlock to this action.
         -- Bug fix 1850043
         -- hr_nonrun_asact.insint(lockingactid,lockedactid);

      -- end if;

      end loop;
      close c_actions_without_asg_set;
   end if;
   hr_utility.set_location(l_procedure_name, 250);
end action_creation;

   ---------------------------------- sort_action ----------------------------------
procedure sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out nocopy number        /* length of the sql string */
) is

  l_dt               date;
  l_year             number ;
  l_gre_id           pay_assignment_actions.tax_unit_id%type;
  l_org_id           per_assignments_f.organization_id%type;
  l_loc_id           per_assignments_f.location_id%type;
  l_per_id           per_assignments_f.person_id%type;
  l_ssn              per_people_f.national_identifier%type;
  l_state_code       pay_us_states.state_code%type;
  l_sort1            varchar2(60);
  l_sort2            varchar2(60);
  l_sort3            varchar2(60);
  l_year_start       date;
  l_year_end         date;
  l_eoy_payroll_action_id pay_payroll_actions.payroll_action_id%type;
  l_bg_id pay_payroll_actions.business_group_id%type ;

   begin
     begin
       select hr_us_w2_mt.get_parameter('YEAR',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('GRE_ID',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('ORG_ID',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('LOC_ID',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('PER_ID',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('SSN',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('STATE',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('P_S1',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('P_S2',ppa1.legislative_parameters),
              hr_us_w2_mt.get_parameter('P_S3',ppa1.legislative_parameters),
              ppa1.effective_date,
              ppa1.business_group_id
        into  l_year,
              l_gre_id,
              l_org_id,
              l_loc_id,
              l_per_id,
              l_ssn,
              l_state_code,
              l_sort1 ,
              l_sort2,
              l_sort3,
              l_dt, --session_date
              l_bg_id
         from pay_payroll_actions ppa1 /* PYUGEN payroll action id */
        where ppa1.payroll_action_id = payactid;
     exception
       when no_data_found then
            hr_utility.trace('Error in Sort Procedure - getting legislative param');
            raise;
     end;
      sqlstr :=  'select paa1.rowid
                 /* we need the row id of the assignment actions that are
                    created by PYUGEN */
                   from hr_all_organization_units  hou,
                        hr_locations_all       loc,
            		per_all_people_f       ppf,  -- #1894165
                        per_all_assignments_f  paf,
                        /*pay_assignment_actions paa,*/
                        pay_payroll_actions    ppa1,
                        pay_assignment_actions paa1  /* PYUGEN assignment action */
		   where ppa1.payroll_action_id = :pactid
                   and   paa1.payroll_action_id = ppa1.payroll_action_id
                   and   paf.assignment_id = paa1.assignment_id
                   and   paf.effective_start_date =
                           (select max(paf2.effective_start_date)
                              from per_all_assignments_f paf2  -- #3871087
                             where paf2.assignment_id = paf.assignment_id
                               and paf2.effective_start_date <= ppa1.effective_date)
                   and   paf.effective_end_date >= ppa1.start_date
                   and   paf.assignment_type = ''E''
                   /* if assignments organization_id is null pick assignment
                      business_group_id to avoid assertion error. Bug No: 1894165 */
 		   and   hou.organization_id =
                             nvl(paf.organization_id,paf.business_group_id) -- #1894165
                   /* if assignments location_id is null pick assignments
                      organization/business groups location_id to avoid assertion
                      error. Bug No: 1894165 */
		   and   loc.location_id  = nvl(paf.location_id,hou.location_id)
		   and   ppf.person_id = paf.person_id
		   and   ppa1.effective_date between
		           ppf.effective_start_date and ppf.effective_end_date
                   order by
 		     decode(' || '''' || l_sort1 || '''' ||
		            ',''Employee_Name'', ppf.last_name||'' ''||ppf.first_name ||'' ''||ppf.middle_names,
		            ''Social_Security_Number'',ppf.national_identifier,
  		            ''Organization'',hou.name,
		            ''Location'',loc.location_code,
                            ppf.last_name||'' ''||ppf.first_name ||'' ''||ppf.middle_names),
	             decode(' || '''' || l_sort2 || '''' ||
	                    ',''Employee_Name'',ppf.last_name||'' ''||ppf.first_name ||'' ''||ppf.middle_names,
	                    ''Social_Security_Number'',ppf.national_identifier,
                            ''Organization'',hou.name,
                            ''Location'',loc.location_code,
			    ppf.last_name||'' ''||ppf.first_name ||'' ''||ppf.middle_names),
                     decode(' || '''' || l_sort3 || '''' ||
	                    ',''Employee_Name'',ppf.last_name||'' ''||ppf.first_name ||'' ''||ppf.middle_names,
                            ''Social_Security_Number'',ppf.national_identifier,
                            ''Organization'',hou.name,
                            ''Location'',loc.location_code,
			    ppf.last_name||'' ''||ppf.first_name ||'' ''||ppf.middle_names)
		   ';
          -- Bug 3913757
          -- Assignment_id is taken from pay_assignment_action istead of per_all_assignments_f
	  --    for update of paf.assignment_id
          --
          --
      len := length(sqlstr); -- return the length of the string.
   end sort_action;

------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin

     token_val := ' ' || name||'=';

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
--
procedure deinitialize_code(
  p_payroll_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'deinitialize_code';
--
  l_inv_act varchar2(1);
  l_commit_cnt number := 0;
  l_del_cnt number := 0;
--
  cursor csr_inv_act
  is
  select 'Y'
  from   dual
  where  exists(
           select /*+ ORDERED */
                  null
           from   pay_payroll_actions ppa,
                  pay_us_rpt_totals purt
           where  ppa.payroll_action_id = p_payroll_action_id
           and    ppa.action_status = 'E'
           and    purt.session_id = p_payroll_action_id);
--
  -- cannot use for update (record lock) because commit is needed in middle loop of cursor.
  -- this will make plsql error.
  cursor csr_del
  is
  select rowid
  from   pay_us_rpt_totals
  where  session_id = p_payroll_action_id;
--
  l_csr_del csr_del%rowtype;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('pay_yrend_report_pkg start deinitialize code');
  end if;
--
  -- following procedure will be called ordinarily
  -- without calling directly.
  --pay_archive.standard_deinit(p_payroll_action_id);
--
  open csr_inv_act;
  fetch csr_inv_act into l_inv_act;
  close csr_inv_act;
--
  if l_inv_act = 'Y' then
  --
    open csr_del;
    loop
    --
      fetch csr_del into l_csr_del;
      exit when csr_del%notfound;
    --
      delete from pay_us_rpt_totals
      where  rowid = l_csr_del.rowid;
    --
      l_commit_cnt := l_commit_cnt + 1;
      l_del_cnt := l_del_cnt + 1;
    --
      if l_commit_cnt > c_commit_num then
      --
        commit;
        l_commit_cnt := 0;
      --
      end if;
    --
    end loop;
    close csr_del;
  --
    if g_debug then
      hr_utility.trace('pay_yrend_report_pkg delete '||to_char(l_del_cnt)||' records');
    end if;
  --
    if l_del_cnt > 0 then
    --
      commit;
    --
    end if;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
    hr_utility.trace('pay_yrend_report_pkg end deinitialize code');
  end if;
--
end deinitialize_code;
--
end pay_yrend_reports_pkg;

/
