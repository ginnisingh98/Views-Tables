--------------------------------------------------------
--  DDL for Package Body PAY_GENERIC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GENERIC_UPGRADE" AS
/* $Header: pycogus.pkb 120.5.12010000.6 2009/10/21 05:28:30 sivanara ship $ */


  /* Name      : set_upgrade_status
     Purpose   : This sets the upgrade status.
     Arguments :
     Notes     :
  */
procedure set_upgrade_status (p_upg_def_id in number,
                              p_upg_lvl    in varchar2,
                              p_bus_grp    in number,
                              p_leg_code   in varchar2,
                              p_status     in varchar2)
is
l_status varchar2(10);
begin
--
   if (p_upg_lvl = 'B') then
--
     begin
--
       select status
         into l_status
         from pay_upgrade_status
        where upgrade_definition_id = p_upg_def_id
          and business_group_id     = p_bus_grp;
--
       /* If we are trying to reset a completed status
          then error
       */
       if (    l_status = 'C'
           and p_status <> 'C') then
--
           pay_core_utils.assert_condition(
                  'pay_generic_upgrade.set_upgrade_status:2',
                  1 = 2);
--
       end if;
--
       update pay_upgrade_status
          set status = p_status
        where upgrade_definition_id = p_upg_def_id
          and business_group_id     = p_bus_grp;
--
     exception
        when no_data_found then
         if (p_status in ('U', 'P')) then
           insert into pay_upgrade_status
                         (upgrade_definition_id,
                          status,
                          business_group_id)
           values (p_upg_def_id,
                   p_status,
                   p_bus_grp);
         else
           pay_core_utils.assert_condition(
                  'pay_generic_upgrade.set_upgrade_status:1',
                  1 = 2);
         end if;
--
     end;
--
   elsif (p_upg_lvl = 'L') then
--
     begin
--
       select status
         into l_status
         from pay_upgrade_status
        where upgrade_definition_id = p_upg_def_id
          and legislation_code     = p_leg_code;
--
       /* If we are trying to reset a completed status
          then error
       */
       if (    l_status = 'C'
           and p_status <> 'C') then
--
           pay_core_utils.assert_condition(
                  'pay_generic_upgrade.set_upgrade_status:2',
                  1 = 2);
--
       end if;
--
       update pay_upgrade_status
          set status = p_status
        where upgrade_definition_id = p_upg_def_id
          and legislation_code     = p_leg_code;
--
     exception
        when no_data_found then
         if (p_status in ('U', 'P')) then
           insert into pay_upgrade_status
                         (upgrade_definition_id,
                          status,
                          legislation_code)
           values (p_upg_def_id,
                   p_status,
                   p_leg_code);
         else
           pay_core_utils.assert_condition(
                  'pay_generic_upgrade.set_upgrade_status:1',
                  1 = 2);
         end if;
--
     end;
--
   elsif (p_upg_lvl = 'G') then
--
     begin
--
       select status
         into l_status
         from pay_upgrade_status
        where upgrade_definition_id = p_upg_def_id
          and legislation_code is null
          and business_group_id is null;
--
       /* If we are trying to reset a completed status
          then error
       */
       if (    l_status = 'C'
           and p_status <> 'C') then
--
           pay_core_utils.assert_condition(
                  'pay_generic_upgrade.set_upgrade_status:2',
                  1 = 2);
--
       end if;
--
       update pay_upgrade_status
          set status = p_status
        where upgrade_definition_id = p_upg_def_id
          and legislation_code is null
          and business_group_id is null;
--
     exception
        when no_data_found then
         if (p_status in ('U', 'P', 'C')) then
           insert into pay_upgrade_status
                         (upgrade_definition_id,
                          status
                          )
           values (p_upg_def_id,
                   p_status
                   );
         else

           pay_core_utils.assert_condition(
                  'pay_generic_upgrade.set_upgrade_status:1',
                  1 = 2);
         end if;
--
     end;
--
   end if;
--
end set_upgrade_status;

  /* Name      : new_business_group
     Purpose   : For a new business group mark all the appropriate
                 upgrades as done.
     Arguments :
     Notes     :
                   There is no point upgrading a brand new
                   business group, just mark then as upgraded.
  */
procedure new_business_group (p_bus_grp_id in number,
                              p_leg_code in varchar2)
is
cursor get_upg_def (p_legislation in varchar2)
is
select pud.upgrade_definition_id
from pay_upgrade_definitions pud
where pud.upgrade_level = 'B' -- Business Group
and (   pud.legislation_code = p_legislation
     or (    pud.legislation_code is null
         and (    nvl(pud.legislatively_enabled, 'N') = 'N'
               or (    nvl(pud.legislatively_enabled, 'N') = 'Y'
                   and exists (select ''
                                 from pay_upgrade_legislations pul
                                where pul.upgrade_definition_id
                                             = pud.upgrade_definition_id
                                  and pul.legislation_code = p_legislation
                              )
                  )
              )
         )
      );


cursor get_upg_def_leg (p_legislation in varchar2,
                        p_business_group in number)
is
select pud.upgrade_definition_id
from pay_upgrade_definitions pud
where pud.upgrade_level = 'L' -- Business Group
and (   pud.legislation_code = p_legislation
     or (    pud.legislation_code is null
         and nvl(pud.legislatively_enabled, 'N') = 'Y'
         and exists (select ''
                       from pay_upgrade_legislations pul
                      where pul.upgrade_definition_id
                                        = pud.upgrade_definition_id
                        and pul.legislation_code = p_legislation
                   )
         )
     )
and not exists (select 1
                  from per_business_groups_perf
                where legislation_code = p_legislation
                   and business_group_id <> p_business_group
               )
and not exists (select 1                                       --Bug 7296843
                   from hr_organization_information hoi_1 ,    --'not exists' validation being done against the base table itself.
                        hr_organization_information hoi_2
                where hoi_1.organization_id <> p_business_group
                   and hoi_1.organization_id = hoi_2.organization_id
                   and hoi_1.org_information9 = p_legislation
                   and hoi_2.org_information_context ='CLASS'
                   and hoi_1.org_information_context ='Business Group Information'
                   and hoi_2.org_information1 = 'HR_BG'
                   and hoi_2.org_information2='N'
                );


cursor get_upg_def_glo (p_business_group in number)
is
select pud.upgrade_definition_id
from pay_upgrade_definitions pud
where pud.upgrade_level = 'G'
and nvl(pud.legislatively_enabled, 'N') = 'N'
and not exists (select 1
                  from per_business_groups_perf
                 where business_group_id <> p_business_group
               );
begin
--
   for bgrec in get_upg_def(p_leg_code) loop
      set_upgrade_status (p_upg_def_id => bgrec.upgrade_definition_id,
                          p_upg_lvl    => 'B',
                          p_bus_grp    => p_bus_grp_id,
                          p_leg_code   => p_leg_code,
                          p_status     => 'P'
                         );
      set_upgrade_status (p_upg_def_id => bgrec.upgrade_definition_id,
                          p_upg_lvl    => 'B',
                          p_bus_grp    => p_bus_grp_id,
                          p_leg_code   => p_leg_code,
                          p_status     => 'C'
                         );
   end loop;
--
   for legrec in get_upg_def_leg(p_leg_code, p_bus_grp_id) loop
      set_upgrade_status (p_upg_def_id => legrec.upgrade_definition_id,
                          p_upg_lvl    => 'L',
                          p_bus_grp    => p_bus_grp_id,
                          p_leg_code   => p_leg_code,
                          p_status     => 'P'
                         );
      set_upgrade_status (p_upg_def_id => legrec.upgrade_definition_id,
                          p_upg_lvl    => 'L',
                          p_bus_grp    => p_bus_grp_id,
                          p_leg_code   => p_leg_code,
                          p_status     => 'C'
                         );
   end loop;
--
   for glorec in get_upg_def_glo(p_bus_grp_id) loop
      set_upgrade_status (p_upg_def_id => glorec.upgrade_definition_id,
                          p_upg_lvl    => 'G',
                          p_bus_grp    => p_bus_grp_id,
                          p_leg_code   => p_leg_code,
                          p_status     => 'P'
                         );
      set_upgrade_status (p_upg_def_id => glorec.upgrade_definition_id,
                          p_upg_lvl    => 'G',
                          p_bus_grp    => p_bus_grp_id,
                          p_leg_code   => p_leg_code,
                          p_status     => 'C'
                         );
   end loop;
--
end new_business_group;
--
  /* Name      : range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows.
     Arguments :
     Notes     :
  */
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
l_upg_def_nm pay_upgrade_definitions.short_name%type;
l_upg_def_id pay_upgrade_definitions.upgrade_definition_id%type;
l_upg_level  pay_upgrade_definitions.upgrade_level%type;
l_bus_grp_id pay_payroll_actions.business_group_id%type;
l_leg_code   per_business_groups.legislation_code%type;
l_thread_level pay_upgrade_definitions.threading_level%type;
l_report_type  pay_report_format_mappings_f.report_type%type;
l_rep_id       pay_report_format_mappings_f.report_format_mapping_id%type;
--

statem varchar2(2000);
sql_cursor           integer;
l_rows               integer;
lv_sqlstr varchar2(2000);

begin

/* chk if generic report or generic upgrade */
commit;

select rf.report_type,rf.report_format_mapping_id
into l_report_type,l_rep_id
from pay_report_format_mappings_f rf,
     pay_payroll_actions pact
where pact.payroll_action_id=pactid
and   rf.report_type =pact.report_type
and   rf.report_qualifier=pact.report_qualifier
and   rf.report_category=pact.report_category
and   pact.effective_date between rf.effective_start_date
                            and rf.effective_end_date;


if l_report_type='GENERIC_REPORT'
then

   select  'B',rg.thread_level,rg.legislation_code
   into l_upg_level, l_thread_level, l_leg_code
   from pay_report_groups rg,pay_payroll_actions ppa
   where rg.report_format_mapping_id=l_rep_id
   and pay_core_utils.get_parameter('REP_GROUP', ppa.legislative_parameters)=rg.short_name
  and ppa.payroll_action_id=pactid;

else
--
  select pay_core_utils.get_parameter('UPG_DEF_NAME',
                                      ppa.legislative_parameters),
         ppa.business_group_id,
         pbg.legislation_code
    into l_upg_def_nm,
         l_bus_grp_id,
         l_leg_code
    from pay_payroll_actions ppa,
         per_business_groups_perf pbg
   where ppa.payroll_action_id = pactid
     and pbg.business_group_id = ppa.business_group_id;
--
   select upgrade_level,
          upgrade_definition_id,
          threading_level
     into l_upg_level,
          l_upg_def_id,
          l_thread_level
     from pay_upgrade_definitions
    where short_name = l_upg_def_nm;
--
end if;
   if (l_thread_level in ('PER', 'ASG')) then
--
     if (l_upg_level = 'B') then
--
       if l_report_type='GENERIC_REPORT' then
           statem := 'begin pay_'||l_leg_code||'_rules.payslip_range_cursor(';
           statem := statem||':pactid, :p_sqlstr); end;';
--
           sql_cursor := dbms_sql.open_cursor;
--
           dbms_sql.parse(sql_cursor, statem, dbms_sql.v7);
--
           dbms_sql.bind_variable(sql_cursor, 'pactid', pactid);
--
           dbms_sql.bind_variable(sql_cursor, 'p_sqlstr', lv_sqlstr,2000);
--
           Begin
             l_rows := dbms_sql.execute (sql_cursor);
           exception when others then
             l_rows := 0;
           end;
--
           if (l_rows = 1) then
             dbms_sql.variable_value(sql_cursor, 'p_sqlstr', lv_sqlstr);
             dbms_sql.close_cursor(sql_cursor);
           else
             lv_sqlstr := null;
             dbms_sql.close_cursor(sql_cursor);
           end if;
           sqlstr:=lv_sqlstr;
       end if;

       if sqlstr is null then
         sqlstr := 'select  distinct asg.person_id
                  from
                          per_all_assignments_f      asg,
                          pay_payroll_actions    pa1
                   where  pa1.payroll_action_id    = :payroll_action_id
                   and    asg.business_group_id    = pa1.business_group_id
                  order by asg.person_id';
       end if;
--
     elsif (l_upg_level = 'L') then
--
       sqlstr := 'select  distinct asg.person_id
                  from
                          per_all_assignments_f      asg,
                          pay_payroll_actions    pa1,
                          per_business_groups_perf    pbg1,
                          per_business_groups_perf    pbg
                   where  pa1.payroll_action_id    = :payroll_action_id
                   and    pbg.business_group_id    = pa1.business_group_id
                   and    pbg1.legislation_code    = pbg.legislation_code
                   and    asg.business_group_id    = pbg1.business_group_id
                  order by asg.person_id';
--
     elsif (l_upg_level = 'G') then
--
       sqlstr := 'select  distinct asg.person_id
                  from
                          per_all_assignments_f      asg,
                          pay_payroll_actions    pa1
                   where  pa1.payroll_action_id    = :payroll_action_id
                  order by asg.person_id';
--
     else
--
        pay_core_utils.assert_condition(
                    'pay_generic_upgrade.range_cursor:2',
                    1 = 2);
--
     end if;
--
   elsif (l_thread_level = 'PET') then
--
     if (l_upg_level = 'B') then
--
       sqlstr := 'select  distinct pet.element_type_id
                  from
                          pay_element_types_f     pet,
                          pay_payroll_actions    pa1
                   where  pa1.payroll_action_id    = :payroll_action_id
                   and    pet.business_group_id    = pa1.business_group_id
                  order by pet.element_type_id';
--
     elsif (l_upg_level = 'L') then
--
       sqlstr := 'select  distinct pet.element_type_id
                  from
                          pay_element_types_f      pet,
                          pay_payroll_actions    pa1,
                          per_business_groups_perf    pbg1,
                          per_business_groups_perf    pbg
                   where  pa1.payroll_action_id    = :payroll_action_id
                   and    pbg.business_group_id    = pa1.business_group_id
                   and    pbg1.legislation_code    = pbg.legislation_code
                   and    (pet.business_group_id = pbg1.business_group_id
                           or pet.legislation_code = pbg1.legislation_code)
                  order by pet.element_type_id';
--
     elsif (l_upg_level = 'G') then
--
       sqlstr := 'select  distinct pet.element_type_id
                  from
                          pay_element_types_f        pet,
                          pay_payroll_actions    pa1
                   where  pa1.payroll_action_id    = :payroll_action_id
                  order by pet.element_type_id';
--
     else
--
        pay_core_utils.assert_condition(
                    'pay_generic_upgrade.range_cursor:3',
                    1 = 2);
--
     end if;
--
   else
--
      pay_core_utils.assert_condition(
                  'pay_generic_upgrade.range_cursor:1',
                  1 = 2);
--
   end if;
--
if l_report_type<>'GENERIC_REPORT'
then
   set_upgrade_status (l_upg_def_id,
                       l_upg_level,
                       l_bus_grp_id,
                       l_leg_code,
                       'P');
end if;
--
end range_cursor;
--
 /* Name    : do_qualification
  Purpose   : This is used to indicate whether the object needs to be upgraded
  Arguments :
  Notes     :
 */
procedure do_qualification(p_object_id in            number,
                           p_qual_proc in            varchar2,
                           p_qualified    out nocopy boolean
                          )
is
sql_cur       number;
l_rows        number;
statem        varchar2(256);
l_qualifer     varchar2(10);
begin
--
   if (p_qual_proc is not null) then
--
     statem := 'BEGIN '||p_qual_proc||'(:objectid, :qual); END;';
--
     hr_utility.trace(statem);

     sql_cur := dbms_sql.open_cursor;
     dbms_sql.parse(sql_cur,
                  statem,
                  dbms_sql.v7);
--
     dbms_sql.bind_variable(sql_cur, 'objectid', p_object_id);
     dbms_sql.bind_variable(sql_cur, 'qual',     l_qualifer, 10);
     l_rows := dbms_sql.execute(sql_cur);
     if (l_rows = 1) then
        dbms_sql.variable_value(sql_cur, 'qual',
                                l_qualifer);
        dbms_sql.close_cursor(sql_cur);
--
     else
         dbms_sql.close_cursor(sql_cur);
         pay_core_utils.assert_condition(
                     'pay_generic_upgrade.do_qualification:1',
                     1 = 2);
     end if;
--
   else
     l_qualifer:= 'Y';
   end if;
--
   if (l_qualifer = 'Y') then
     p_qualified := TRUE;
   else
     p_qualified := FALSE;
   end if;
--
end do_qualification;
--
 /* Name    : create_object_action
  Purpose   : This creates the object action if it passes qualification.
  Arguments :
  Notes     :
 */
procedure create_object_action(p_object_id   in number,
                               p_object_type in varchar2,
                               p_qual_proc   in varchar2,
                               p_pactid      in number,
                               p_chunk       in number
                              )
is
l_action_id    pay_temp_object_actions.object_action_id%type;
l_qualified    boolean;
begin

--
   do_qualification(p_object_id, p_qual_proc, l_qualified);
--
   if (l_qualified = TRUE) then
--
     select pay_assignment_actions_s.nextval
       into l_action_id
       from dual;
--
      hr_nonrun_asact.insact(lockingactid       => l_action_id,
                             pactid             => p_pactid,
                             chunk              => p_chunk,
                             object_id          => p_object_id,
                             object_type        => p_object_type,
                             p_transient_action => TRUE);
--
   end if;
--
end create_object_action;
--
 /* Name    : action_creation
  Purpose   : This creates the assignment actions for a specific chunk.
  Arguments :
  Notes     :
 */
--
procedure action_creation(p_pactid in number,
                          p_stperson in number,
                          p_endperson in number,
                          p_chunk in number) is
  cursor c_bgp_per (cp_pactid number,
                    cp_stperson  number,
                    cp_endperson number
                   ) is
  select /*+ INDEX(ppf PER_PEOPLE_F_PK)*/
         distinct ppf.person_id
    from per_all_people_f ppf,
         pay_payroll_actions ppa
   where ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = ppf.business_group_id
     and ppf.person_id between cp_stperson and cp_endperson;
--
  cursor c_bgp_asg (cp_pactid number,
                    cp_stperson  number,
                    cp_endperson number
                   ) is
  select distinct paf.assignment_id
    from
         per_all_assignments_f      paf,
         pay_payroll_actions    ppa
   where ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = paf.business_group_id
     and paf.person_id between cp_stperson and cp_endperson;
--
  cursor c_bgp_asg_range (cp_pactid number,
                          c_chunk number
                   ) is
  select distinct paf.assignment_id
    from
         per_all_assignments_f      paf,
         pay_payroll_actions    ppa,
         pay_population_ranges ppr
   where ppr.chunk_number = c_chunk
     and ppr.payroll_action_id = ppa.payroll_action_id
     and ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = paf.business_group_id
     and paf.person_id = ppr.person_id;
--
  cursor c_bgp_pet (cp_pactid number,
                    cp_stetid  number,
                    cp_endetid number
                   ) is
  select distinct pet.element_type_id
    from
         pay_element_types_f    pet,
         pay_payroll_actions    ppa
   where ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = pet.business_group_id
     and pet.element_type_id between cp_stetid and cp_endetid;
--
  cursor c_leg_per (cp_pactid number,
                    cp_stperson  number,
                    cp_endperson number
                   ) is
  select /*+ INDEX(ppf PER_PEOPLE_F_PK)*/
         distinct ppf.person_id
    from per_all_people_f ppf,
         pay_payroll_actions ppa,
         per_business_groups_perf pbg,
         per_business_groups_perf pbg1
   where ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = pbg.business_group_id
     and pbg.legislation_code = pbg1.legislation_code
     and pbg1.business_group_id = ppf.business_group_id
     and ppf.person_id between cp_stperson and cp_endperson;
--
  cursor c_leg_asg (cp_pactid number,
                    cp_stperson  number,
                    cp_endperson number
                   ) is
  select distinct paf.assignment_id
    from
         per_all_assignments_f      paf,
         pay_payroll_actions    ppa,
         per_business_groups_perf    pbg,
         per_business_groups_perf    pbg1
   where ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = pbg.business_group_id
     and pbg.legislation_code = pbg1.legislation_code
     and pbg1.business_group_id = paf.business_group_id
     and paf.person_id between cp_stperson and cp_endperson;
--
  cursor c_leg_pet (cp_pactid number,
                    cp_stetid  number,
                    cp_endetid number
                   ) is
  select distinct pet.element_type_id
    from
         pay_element_types_f    pet,
         pay_payroll_actions    ppa,
         per_business_groups_perf    pbg,
         per_business_groups_perf    pbg1
   where ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = pbg.business_group_id
     and pbg.legislation_code = pbg1.legislation_code
     and (   pbg1.business_group_id = pet.business_group_id
          or pet.legislation_code = pbg1.legislation_code
         )
     and pet.element_type_id between cp_stetid and cp_endetid;
--
  cursor c_glo_per (
                    cp_stperson  number,
                    cp_endperson number
                   ) is
  select /*+ INDEX(ppf PER_PEOPLE_F_PK)*/
         distinct ppf.person_id
    from per_all_people_f ppf
   where ppf.person_id between cp_stperson and cp_endperson;
--
  cursor c_glo_asg (
                    cp_stperson  number,
                    cp_endperson number
                   ) is
  select distinct paf.assignment_id
    from
         per_all_assignments_f      paf
   where paf.person_id between cp_stperson and cp_endperson;
--
  cursor c_glo_pet (
                    cp_stetid  number,
                    cp_endetid number
                   ) is
  select distinct pet.element_type_id
    from pay_element_types_f pet
   where pet.element_type_id between cp_stetid and cp_endetid;
--
l_upg_def_id   pay_upgrade_definitions.upgrade_definition_id%type;
l_upg_def_nm   pay_upgrade_definitions.short_name%type;
l_upg_level    pay_upgrade_definitions.upgrade_level%type;
l_thread_level pay_upgrade_definitions.threading_level%type;
l_qual_proc    pay_upgrade_definitions.qualifying_procedure%type;
l_report_type  pay_report_format_mappings_f.report_type%type;
l_report_format     pay_report_format_mappings_f.report_format%type;
l_report_qualifier  pay_report_format_mappings_f.report_qualifier%type;
l_report_category   pay_report_format_mappings_f.report_category%type;
l_rep_id       pay_report_format_mappings_f.report_format_mapping_id%type;
l_range_person    boolean default FALSE;   -- Variable used to check if RANGE_PERSON_ID is enabled, introduced for bug 8851143
--
begin

/* chk if generic report or generic upgrade */

select rf.report_type, rf.report_format, rf.report_qualifier, rf.report_category, rf.report_format_mapping_id
into l_report_type, l_report_format, l_report_qualifier, l_report_category, l_rep_id
from pay_report_format_mappings_f rf,
     pay_payroll_actions pact
where pact.payroll_action_id=p_pactid
and   rf.report_type =pact.report_type
and   rf.report_qualifier=pact.report_qualifier
and   rf.report_category=pact.report_category
and   pact.effective_date between rf.effective_start_date
                            and rf.effective_end_date;


if l_report_type='GENERIC_REPORT'
then
   select  'B',rg.thread_level,
           rg.qualifying_procedure
   into l_upg_level,
	l_thread_level,
        l_qual_proc
   from pay_report_groups rg,pay_payroll_actions ppa
   where rg.report_format_mapping_id=l_rep_id
   and pay_core_utils.get_parameter('REP_GROUP', ppa.legislative_parameters)=rg.short_name
  and ppa.payroll_action_id=p_pactid;


else
  select pay_core_utils.get_parameter('UPG_DEF_NAME',
                                      ppa.legislative_parameters)
    into l_upg_def_nm
    from pay_payroll_actions ppa
   where payroll_action_id = p_pactid;
--
   select upgrade_level,
          threading_level,
          upgrade_definition_id,
          qualifying_procedure
     into l_upg_level,
          l_thread_level,
          l_upg_def_id,
          l_qual_proc
     from pay_upgrade_definitions
    where short_name = l_upg_def_nm;
end if;
--
   if (l_upg_level = 'B') then
     if (l_thread_level = 'PER') then
       for perrec in c_bgp_per(p_pactid, p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => perrec.person_id,
                             p_object_type => 'PER',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     elsif (l_thread_level = 'ASG') THEN -- Bug 8851133 Implemented RANGE_PERSON_ID
       l_range_person:=pay_ac_utility.range_person_on(
                              p_report_type      => l_report_type
                             ,p_report_format    => l_report_format
                             ,p_report_qualifier => l_report_qualifier
                             ,p_report_category  => l_report_category);
       if l_range_person then
         for asgrec in c_bgp_asg_range(p_pactid, p_chunk) loop
--
          create_object_action(p_object_id   => asgrec.assignment_id,
                               p_object_type => 'ASG',
                               p_qual_proc   => l_qual_proc,
                               p_pactid      => p_pactid,
                               p_chunk       => p_chunk
                              );
--
         end loop;
       else
         for asgrec in c_bgp_asg(p_pactid, p_stperson, p_endperson) loop
--
          create_object_action(p_object_id   => asgrec.assignment_id,
                               p_object_type => 'ASG',
                               p_qual_proc   => l_qual_proc,
                               p_pactid      => p_pactid,
                               p_chunk       => p_chunk
                              );
--
         end loop;
       end if;
     elsif (l_thread_level = 'PET') then
       for etrec in c_bgp_pet(p_pactid, p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => etrec.element_type_id,
                             p_object_type => 'PET',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     else
       pay_core_utils.assert_condition(
                   'pay_generic_upgrade.action_creation:1',
                   1 = 2);
     end if;
   elsif (l_upg_level = 'L') then
     if (l_thread_level = 'PER') then
       for perrec in c_leg_per(p_pactid, p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => perrec.person_id,
                             p_object_type => 'PER',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     elsif (l_thread_level = 'ASG') then
       for asgrec in c_leg_asg(p_pactid, p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => asgrec.assignment_id,
                             p_object_type => 'ASG',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     elsif (l_thread_level = 'PET') then
       for etrec in c_leg_pet(p_pactid, p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => etrec.element_type_id,
                             p_object_type => 'PET',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     else
       pay_core_utils.assert_condition(
                   'pay_generic_upgrade.action_creation:2',
                   1 = 2);
     end if;
   elsif (l_upg_level = 'G') then
     if (l_thread_level = 'PER') then
       for perrec in c_glo_per(p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => perrec.person_id,
                             p_object_type => 'PER',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     elsif (l_thread_level = 'ASG') then
       for asgrec in c_glo_asg(p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => asgrec.assignment_id,
                             p_object_type => 'ASG',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     elsif (l_thread_level = 'PET') then
       for etrec in c_glo_pet(p_stperson, p_endperson) loop
--
        create_object_action(p_object_id   => etrec.element_type_id,
                             p_object_type => 'PET',
                             p_qual_proc   => l_qual_proc,
                             p_pactid      => p_pactid,
                             p_chunk       => p_chunk
                            );
--
       end loop;
     else
       pay_core_utils.assert_condition(
                   'pay_generic_upgrade.action_creation:3',
                   1 = 2);
     end if;
   else
     pay_core_utils.assert_condition(
                   'pay_generic_upgrade.action_creation:4',
                   1 = 2);
   end if;
end action_creation;
--
 /* Name      : archinit
    Purpose   : This performs the US specific initialisation section.
    Arguments :
    Notes     :
 */
procedure archinit(p_payroll_action_id in number) is
      jurisdiction_code      pay_state_rules.jurisdiction_code%TYPE;
      l_state                VARCHAR2(30);
begin
   null;
end archinit;
--

  /* Name      : archive_data
     Purpose   : This performs the US specific employee context setting for the SQWL
                 report.
     Arguments :
     Notes     :
  */
procedure upgrade_data(p_assactid in number, p_effective_date in date) is
--
sql_cur       number;
ignore        number;
upgrade_proc  pay_upgrade_definitions.upgrade_procedure%TYPE;
statem        varchar2(256);
l_upg_def_id   pay_upgrade_definitions.upgrade_definition_id%type;
l_upg_def_nm   pay_upgrade_definitions.short_name%type;
object_id     pay_temp_object_actions.object_id%type;
--
begin
--
  select pay_core_utils.get_parameter('UPG_DEF_NAME',
                                      ppa.legislative_parameters),
         ptoa.object_id
    into l_upg_def_nm,
         object_id
    from pay_payroll_actions ppa,
         pay_temp_object_actions ptoa
   where ppa.payroll_action_id = ptoa.payroll_action_id
     and ptoa.object_action_id = p_assactid;
--
   select upgrade_procedure,
          upgrade_definition_id
     into upgrade_proc,
          l_upg_def_id
     from pay_upgrade_definitions
    where short_name = l_upg_def_nm;
--
   statem := 'BEGIN '||upgrade_proc||'(:objectid); END;';
--
   hr_utility.trace(statem);

   sql_cur := dbms_sql.open_cursor;
   dbms_sql.parse(sql_cur,
                statem,
                dbms_sql.v7);
--
   dbms_sql.bind_variable(sql_cur, 'objectid', object_id);
   ignore := dbms_sql.execute(sql_cur);
   dbms_sql.close_cursor(sql_cur);
--
end upgrade_data;

  /* Name      : deinitialise
     Purpose   : This procedure simply removes all the actions processed
                 in this run
     Arguments :
     Notes     :
  */
  procedure deinitialise (pactid in number)
  is
--
    l_remove_act     varchar2(10);
    cnt_incomplete_actions number;
    l_upg_def_id pay_upgrade_definitions.upgrade_definition_id%type;
    l_upg_def_nm pay_upgrade_definitions.short_name%type;
    l_upg_level  pay_upgrade_definitions.upgrade_level%type;
    l_bus_grp_id pay_payroll_actions.business_group_id%type;
    l_leg_code   per_business_groups.legislation_code%type;
    l_report_type pay_payroll_actions.report_type%type;
--
  begin
--

     select pay_core_utils.get_parameter('UPG_DEF_NAME',
                                         ppa.legislative_parameters),
            pay_core_utils.get_parameter('REMOVE_ACT',
                                         ppa.legislative_parameters),
            ppa.business_group_id,
            pbg.legislation_code,
            ppa.report_type
       into l_upg_def_nm,
            l_remove_act,
            l_bus_grp_id,
            l_leg_code,
            l_report_type
       from pay_payroll_actions ppa,
            per_business_groups_perf pbg
      where ppa.payroll_action_id = pactid
        and pbg.business_group_id = ppa.business_group_id;
--
if l_report_type='GENERIC_REPORT'
then
     select count(*)
       into cnt_incomplete_actions
       from pay_temp_object_actions
       where payroll_action_id = pactid
       and action_status <> 'C';

       if (l_remove_act is null or l_remove_act = 'Y') then
         DELETE FROM pay_file_details pfd
           WHERE EXISTS (SELECT 1
                 FROM pay_temp_object_actions ptoa
                 WHERE ptoa.object_action_id = pfd.source_id
                 AND pfd.source_type = 'PAA') OR
                    (pfd.source_id = pactid
                        AND pfd.source_type = 'PPA') ;
	  pay_archive.remove_report_actions(pactid);
       end if;
else
     select upgrade_level,
            upgrade_definition_id
       into l_upg_level,
            l_upg_def_id
       from pay_upgrade_definitions
      where short_name = l_upg_def_nm;
--
     select count(*)
       into cnt_incomplete_actions
       from pay_temp_object_actions
      where payroll_action_id = pactid
        and action_status <> 'C';
--
--
      if (cnt_incomplete_actions = 0) then
--
         set_upgrade_status (l_upg_def_id,
                             l_upg_level,
                             l_bus_grp_id,
                             l_leg_code,
                             'C');
--
         if (l_remove_act is null or l_remove_act = 'Y') then
           pay_archive.remove_report_actions(pactid);
         end if;
      end if;
end if;
--
end deinitialise;
--
--
END pay_generic_upgrade;

/
