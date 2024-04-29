--------------------------------------------------------
--  DDL for Package Body PAY_ASG_PROCESS_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ASG_PROCESS_GRP_PKG" as
/* $Header: pycorapg.pkb 120.6 2006/01/10 07:19:47 nbristow noship $ */
/* Name
   is_pog_enable
   Description

   This function is used to indicate whether the POG functionality
   is enabled for a localisation.
*/

function is_pog_enable(p_bgp_id in number)
return boolean
is
--
l_leg_code per_business_groups.legislation_code%type;
l_value    pay_legislation_rules.rule_mode%type;
l_found    boolean;
--
begin
--
   select pbg.legislation_code
     into l_leg_code
     from per_business_groups_perf pbg
    where pbg.business_group_id = p_bgp_id;
--
   pay_core_utils.get_legislation_rule
          (p_legrul_name  => 'I',
           p_legislation  => l_leg_code,
           p_legrul_value => l_value,
           p_found        => l_found);
--
   if (l_found = FALSE) then
      l_value := 'N';
   end if;
--
   if (l_value <> 'G') then
      return FALSE;
   else
      return TRUE;
   end if;
--
end is_pog_enable;
--
/*
Name
	get_group_definition
Description

  This function is used to retrieve/Create a group definition.
  */
function get_group_definition(p_definition_name in varchar2)
return number
is
l_definition_id number;
begin
--
    select group_definition_id
      into l_definition_id
      from pay_group_definitions
     where name = p_definition_name;
--
    return l_definition_id;
--
exception
   when no_data_found then
      begin
--
         -- Need to lock the table to esnure only
         -- one thread creates the group row.
--
         lock table pay_group_definitions in share mode;
--
         -- Ensure that nothing has created
         -- the row in the meantime
         select group_definition_id
           into l_definition_id
           from pay_group_definitions
          where name = p_definition_name;
--
         return l_definition_id;
--
      exception
         when no_data_found then
--
           select pay_group_definitions_s.nextval
             into l_definition_id
             from dual;
--
           insert into pay_group_definitions
                             (group_definition_id,
                              name)
           values
                 (l_definition_id,
                  p_definition_name);
--
           return l_definition_id;
      end;
--
end get_group_definition;
--
/*
   Name
      get_assignment_group
   Description

      This function is used to retrieve/Create an assignment group
*/
function get_assignment_group(p_person_group_id      in     number,
                              p_assignment_id        in     number,
                              p_effective_start_date in     date,
                              p_effective_end_date   in     date,
                              p_payroll_id           in     number,
                              p_update_row           in     varchar2 default 'Y'
                             )
return number
is
l_object_group_id pay_object_groups.object_group_id%type;
l_start_date pay_object_groups.start_date%type;
l_end_date pay_object_groups.end_date%type;
l_cnt number;
begin
--
  select object_group_id,
         start_date,
         end_date
    into l_object_group_id,
         l_start_date,
         l_end_date
    from pay_object_groups
   where source_id = p_assignment_id
     and source_type = 'PAF'
     and start_date <= p_effective_end_date
     and end_date >= p_effective_start_date
     and parent_object_group_id = p_person_group_id
     and payroll_id = p_payroll_id;
--
   return l_object_group_id;
--
exception
   when no_data_found then
--
      -- An assignment can not switch
      -- from one processing group to another
--
      select count(*)
        into l_cnt
        from pay_object_groups
       where source_id = p_assignment_id
         and source_type = 'PAF'
         and parent_object_group_id <> p_person_group_id;
--
      if (l_cnt <> 0) then
        pay_core_utils.assert_condition('pay_asg_process_grp_pkg.get_assignment_group:1',
                                        1 = 2);
      end if;
--
      if (p_update_row = 'Y') then
--
         select pay_object_groups_s.nextval
           into l_object_group_id
           from dual;
--
         insert into pay_object_groups
                           (object_group_id,
                            source_id,
                            source_type,
                            start_date,
                            end_date,
                            payroll_id,
                            parent_object_group_id)
         values
               (l_object_group_id,
                p_assignment_id,
                'PAF',
                p_effective_start_date,
                to_date('4712/12/31', 'YYYY/MM/DD'), --p_effective_end_date,
                p_payroll_id,
                p_person_group_id
               );
--
      else
--
          l_object_group_id := null;
--
      end if;
--
      return l_object_group_id;
--

--
end get_assignment_group;
--
/*
   Name
      get_person_group
   Description

      This function is used to retrieve/Create a person group.
*/

function get_person_group(p_person_id            in     number,
                           p_period_of_service_id in     number,
                           p_effective_start_date in     date,
                           p_effective_end_date   in     date,
                           p_definition_name      in     varchar2,
                           p_update_row           in     varchar2 default 'Y'
                          )
return number
is
l_definition_id pay_group_definitions.group_definition_id%type;
l_object_group_id pay_object_groups.object_group_id%type;
l_start_date pay_object_groups.start_date%type;
l_end_date pay_object_groups.end_date%type;
l_update boolean;
l_upd_start_date date;
l_upd_end_date date;
begin
--
  l_definition_id := get_group_definition(p_definition_name);
--
  select object_group_id,
         start_date,
         end_date
    into l_object_group_id,
         l_start_date,
         l_end_date
    from pay_object_groups
   where source_id = p_person_id
     and source_type = 'PPF'
     and start_date <= p_effective_end_date
     and end_date >= p_effective_start_date
     and period_of_service_id = p_period_of_service_id
     and group_definition_id = l_definition_id;
--
  -- Ensure that the object group dates
  -- are correct
--
  if (p_update_row = 'Y') then
     if (l_start_date > p_effective_start_date) then
        l_update := TRUE;
        l_upd_start_date := p_effective_start_date;
     else
        l_upd_start_date := l_start_date;
     end if;
     if (l_end_date < p_effective_end_date) then
        l_upd_end_date := p_effective_end_date;
     else
        l_update := TRUE;
        l_upd_end_date := l_end_date;
     end if;
     if (l_update = TRUE) then
       update pay_object_groups
          set start_date = l_upd_start_date,
              end_date   = l_upd_end_date
        where object_group_id = l_object_group_id;
     end if;
  end if;
--
  return l_object_group_id;
--
exception
   when no_data_found then
--
      if (p_update_row = 'Y') then
--
         select pay_object_groups_s.nextval
           into l_object_group_id
           from dual;
--
         insert into pay_object_groups
                           (object_group_id,
                            source_id,
                            source_type,
                            start_date,
                            end_date,
                            group_definition_id,
                            period_of_service_id)
         values
               (l_object_group_id,
                p_person_id,
                'PPF',
                p_effective_start_date,
                to_date('4712/12/31', 'YYYY/MM/DD'),
                l_definition_id,
                p_period_of_service_id
               );
--
      else
--
          l_object_group_id := null;
--
      end if;
--
      return l_object_group_id;
--

--
end get_person_group;
--
/*
   Name
      evaluate_asg_group
   Description

      This procedure calls the legislative function to retrieve the
      process group name.
*/

procedure evaluate_asg_group(p_assignment_id        in     number,
                             p_effective_start_date in     date,
                             p_effective_end_date   in     date,
                             p_group_name           out nocopy varchar2)
is
l_leg_code   varchar2(30);
statem       varchar2(2000);  -- used with dynamic pl/sql
sql_cursor   integer;
l_rows       integer;
begin
--
   select distinct legislation_code
     into l_leg_code
     from per_business_groups_perf pbg,
          per_all_assignments_f    paf
    where paf.assignment_id = p_assignment_id
      and p_effective_start_date between paf.effective_start_date
                                     and paf.effective_end_date
      and paf.business_group_id = pbg.business_group_id;
--
   statem :=
'begin
    pay_'||l_leg_code||'_rules.get_asg_process_group(
           :assignment_id,
           :effective_start_date,
           :effective_end_date,
           :group_name);
end;
';
   --
   sql_cursor := dbms_sql.open_cursor;
   --
   dbms_sql.parse(sql_cursor, statem, dbms_sql.v7);
   --
   --
   dbms_sql.bind_variable(sql_cursor, 'assignment_id', p_assignment_id);
   --
   dbms_sql.bind_variable(sql_cursor, 'effective_start_date', p_effective_start_date);
   --
   dbms_sql.bind_variable(sql_cursor, 'effective_end_date', p_effective_end_date);
   --
   dbms_sql.bind_variable(sql_cursor, 'group_name', p_group_name, 30);
   --
   l_rows := dbms_sql.execute (sql_cursor);
   --
   if (l_rows = 1) then
      dbms_sql.variable_value(sql_cursor, 'group_name',
                              p_group_name);
      dbms_sql.close_cursor(sql_cursor);
--
   else
      dbms_sql.close_cursor(sql_cursor);
      pay_core_utils.assert_condition
           ('pay_asg_process_grp_pkg.evaluate_asg_group:1',
            1 = 2);
   end if;
--
   pay_core_utils.assert_condition
           ('pay_asg_process_grp_pkg.evaluate_asg_group:2',
            p_group_name is not null);
--
end evaluate_asg_group;
--
/*
   Name
      generate_asg_group
   Description

      This procedure calls all the required procedures to
      create an assignment group.
*/
procedure generate_asg_group(p_assignment_id        in number,
                             p_person_id            in number,
                             p_period_of_service_id in number,
                             p_effective_start_date in date,
                             p_effective_end_date   in date,
                             p_payroll_id           in number
                            )
is
l_group_name pay_group_definitions.name%type;
l_person_group_id pay_object_groups.object_group_id%type;
l_asg_group_id pay_object_groups.object_group_id%type;
begin
--
   if (p_payroll_id is not null) then
--
     evaluate_asg_group(p_assignment_id,
                        p_effective_start_date,
                        p_effective_end_date,
                        l_group_name
                       );
     l_person_group_id := get_person_group
                           (p_person_id,
                            p_period_of_service_id,
                            p_effective_start_date,
                            p_effective_end_date,
                            l_group_name
                           );
    l_asg_group_id := get_assignment_group
                             (p_person_group_id      => l_person_group_id,
                              p_assignment_id        => p_assignment_id,
                              p_effective_start_date => p_effective_start_date,
                              p_effective_end_date   => p_effective_end_date,
                              p_payroll_id           => p_payroll_id
                             );
--
   end if;
--
end generate_asg_group;
--
/*
   Name
      asg_datetracked_insert
   Description

      This is called from the Assignment Dynamic Triggers
      to maintain the assignment groups
*/

procedure asg_datetracked_insert(p_assignment_id    in number,
                             p_person_id            in number,
                             p_period_of_service_id in number,
                             p_effective_start_date in date,
                             p_effective_end_date   in date,
                             p_payroll_id           in number
                            )
is
begin
--
   generate_asg_group(p_assignment_id,
                      p_person_id,
                      p_period_of_service_id,
                      p_effective_start_date,
                      p_effective_end_date,
                      p_payroll_id
                     );
--
end asg_datetracked_insert;
--
/*
   Name
      zap_object_group
   Description

      This is purges an assignment processing group from the
      system, then removes the person object groups if no
      other assignment processing groups exist for it.
*/

procedure zap_object_group(p_object_group_id in number)
is
l_parent_object_group_id pay_object_groups.parent_object_group_id%type;
l_cnt number;
begin
--
   select parent_object_group_id
     into l_parent_object_group_id
     from pay_object_groups
    where object_group_id = p_object_group_id;
--
   if (l_parent_object_group_id is not null) then
--
     -- Find out how many object groups are on the
     -- parent. If its only one then delete it.
     -- Since its the current object group.
--
     select count(*)
       into l_cnt
       from pay_object_groups
      where parent_object_group_id = l_parent_object_group_id;
--
     if (l_cnt = 1) then
       delete from pay_object_groups
        where object_group_id = l_parent_object_group_id;
     end if;
   end if;
--
   delete from pay_object_groups
    where object_group_id = p_object_group_id;
--
end zap_object_group;
--
/*
   Name
      end_date_object_group
   Description

      This is end dates an object group.
*/

procedure end_date_object_group(p_object_group_id in number,
                                p_effective_end_date in date)
is
begin
--
   update pay_object_groups
      set end_date = p_effective_end_date
    where object_group_id = p_object_group_id;
--
end end_date_object_group;
--
/*
   Name
      asg_datetracked_delete_next
   Description

      This is called from the Assignment Dynamic Triggers
      to maintain the assignment groups
*/
procedure asg_datetracked_delete_next(p_assignment_id        in number,
                                      p_effective_end_date   in date,
                                      p_effective_end_date_o in date
                                     )
is
cursor get_pogpaf(p_assignment_id number,
                  p_effective_end_date_o date)
is
select object_group_id,
       parent_object_group_id,
       start_date,
       end_date
  from pay_object_groups pog_paf
 where pog_paf.source_id = p_assignment_id
   and pog_paf.source_type = 'PAF'
   and pog_paf.end_date = p_effective_end_date_o;
--
cursor get_pogppf(p_par_object_group_id number,
                  p_effective_end_date_o date)
is
select object_group_id,
       start_date,
       end_date
  from pay_object_groups pog_paf
 where object_group_id = p_par_object_group_id
   and pog_paf.end_date = p_effective_end_date_o;
begin
--
   for pogrec in get_pogpaf(p_assignment_id, p_effective_end_date_o) loop
--
      update pay_object_groups
         set end_date = p_effective_end_date
       where object_group_id = pogrec.object_group_id;
--
      for ppfrec in get_pogppf(pogrec.parent_object_group_id,
                               p_effective_end_date_o)
      loop
--
         update pay_object_groups
            set end_date = p_effective_end_date
          where object_group_id = ppfrec.object_group_id;
--
      end loop;
--
   end loop;
--

--
end asg_datetracked_delete_next;
--
/*
   Name
      asg_datetracked_end_date
   Description

      This is called from the Assignment Dynamic Triggers
      to maintain the assignment groups
*/
procedure asg_datetracked_end_date(p_assignment_id      in number,
                                   p_effective_end_date in date
                                  )
is
cursor get_pogpaf(p_assignment_id number,
                  p_effective_end_date date)
is
select object_group_id,
       start_date,
       end_date
  from pay_object_groups pog_paf
 where pog_paf.source_id = p_assignment_id
   and pog_paf.source_type = 'PAF'
   and pog_paf.end_date > p_effective_end_date
   order by start_date;
begin
--
-- OK the assignment has ended, we need to end all the
-- POG PAFs that the assignment has.
   for pafrec in get_pogpaf(p_assignment_id, p_effective_end_date) loop
--
     if (pafrec.start_date > p_effective_end_date) then
        zap_object_group(pafrec.object_group_id);
     else
        end_date_object_group(pafrec.object_group_id,
                              p_effective_end_date);
     end if;
--
   end loop;
--
end asg_datetracked_end_date;
--
/*
   Name
      find_asg_group_definition
   Description

      This retrieves the group name for an assignment group.
*/
procedure find_asg_group_definition(p_assignment_id   in     number,
                                    p_payroll_id      in     number,
                                    p_effective_date  in     date,
                                    p_definition_name out nocopy varchar2)
is
begin
--
  select pgd.name
    into p_definition_name
    from pay_group_definitions pgd,
         pay_object_groups     pog_ppf,
         pay_object_groups     pog_paf
   where pog_paf.source_id = p_assignment_id
     and pog_paf.source_type = 'PAF'
     and pog_paf.payroll_id = p_payroll_id
     and p_effective_date between pog_paf.start_date
                              and pog_paf.end_date
     and pog_paf.parent_object_group_id = pog_ppf.object_group_id
     and pog_ppf.group_definition_id = pgd.group_definition_id;
--
end find_asg_group_definition;
--
/*
   Name
      asg_datetracked_update
   Description

      This is called from the Assignment Dynamic Triggers
      to maintain the assignment groups
*/

procedure asg_datetracked_update(p_assignment_id            in number,
                                 p_person_id                in number,
                                 p_period_of_service_id     in number,
                                 p_old_effective_start_date in date,
                                 p_old_effective_end_date   in date,
                                 p_new_effective_start_date in date,
                                 p_new_effective_end_date   in date,
                                 p_old_payroll_id           in number,
                                 p_new_payroll_id           in number
                                )
is
l_old_group_name pay_group_definitions.name%type;
l_new_group_name pay_group_definitions.name%type;
begin
--
   if (    p_old_payroll_id is null
       and p_new_payroll_id is null) then
--
       return;
--
   elsif (    p_old_payroll_id is null
          and p_new_payroll_id is not null) then
--
         generate_asg_group(p_assignment_id,
                            p_person_id,
                            p_period_of_service_id,
                            p_new_effective_start_date,
                            p_new_effective_end_date,
                            p_new_payroll_id
                           );
   elsif (    p_old_payroll_id is not null
          and p_new_payroll_id is null) then
--
      return;
--
   elsif (p_old_payroll_id = p_new_payroll_id) then
--
      find_asg_group_definition(p_assignment_id   => p_assignment_id,
                                p_payroll_id      => p_old_payroll_id,
                                p_effective_date  => p_old_effective_end_date,
                                p_definition_name => l_old_group_name
                               );
--
       evaluate_asg_group(p_assignment_id,
                          p_new_effective_start_date,
                          p_new_effective_end_date,
                          l_new_group_name
                         );
       if (l_old_group_name <> l_new_group_name) then
         generate_asg_group(p_assignment_id,
                            p_person_id,
                            p_period_of_service_id,
                            p_new_effective_start_date,
                            p_new_effective_end_date,
                            p_new_payroll_id
                           );
       end if;
--
   else
         generate_asg_group(p_assignment_id,
                            p_person_id,
                            p_period_of_service_id,
                            p_new_effective_start_date,
                            p_new_effective_end_date,
                            p_new_payroll_id
                           );

   end if;
--
end asg_datetracked_update;
--
/*
   Name
      asg_datetracked_strt_early
   Description
      This is called from the Assignment Dynamic Triggers
      to maintain the assignment groups
*/

procedure asg_datetracked_strt_early(p_assignment_id            in number,
                                      p_person_id                in number,
                                      p_period_of_service_id     in number,
                                      p_old_effective_start_date in date,
                                      p_old_effective_end_date   in date,
                                      p_new_effective_start_date in date,
                                      p_new_effective_end_date   in date,
                                      p_old_payroll_id           in number,
                                      p_new_payroll_id           in number
                                     )
is
begin
--
   update pay_object_groups
      set start_date = p_new_effective_start_date
    where source_id = p_assignment_id
      and source_type = 'PAF'
      and start_date = p_old_effective_start_date;
--
end asg_datetracked_strt_early;

/*
   Name
      asg_datetracked_ovrr_update
   Description

      This is called from the Assignment Dynamic Triggers
      to maintain the assignment groups
*/

procedure asg_datetracked_ovrr_update(p_assignment_id            in number,
                                      p_person_id                in number,
                                      p_period_of_service_id     in number,
                                      p_old_effective_start_date in date,
                                      p_old_effective_end_date   in date,
                                      p_new_effective_start_date in date,
                                      p_new_effective_end_date   in date,
                                      p_old_payroll_id           in number,
                                      p_new_payroll_id           in number
                                     )
is
cursor get_pogpaf(p_assignment_id number,
                  p_effective_end_date date)
is
select object_group_id,
       start_date,
       end_date
  from pay_object_groups pog_paf
 where pog_paf.source_id = p_assignment_id
   and pog_paf.source_type = 'PAF'
   and pog_paf.end_date > p_effective_end_date;
begin
--
   asg_datetracked_update(p_assignment_id,
                           p_person_id,
                           p_period_of_service_id,
                           p_old_effective_start_date,
                           p_old_effective_end_date,
                           p_new_effective_start_date,
                           p_new_effective_end_date,
                           p_old_payroll_id,
                           p_new_payroll_id
                          );
--
   -- Any POG_PAF that starts after the new start date
   -- then they must be removed as a they have been
   -- overriden
   for pafrec in get_pogpaf(p_assignment_id, p_new_effective_end_date) loop
--
     if (pafrec.start_date > p_new_effective_end_date) then
        zap_object_group(pafrec.object_group_id);
     end if;
--
   end loop;
--
end asg_datetracked_ovrr_update;
--
/*
   Name
      asg_datetracked_zap
   Description

      This is called from the Assignment Dynamic Triggers
      to maintain the assignment groups
*/

procedure asg_datetracked_zap(p_assignment_id in number)
is
cursor get_pogpaf(p_assignment_id number)
is
select object_group_id,
       start_date,
       end_date
  from pay_object_groups pog_paf
 where pog_paf.source_id = p_assignment_id
   and pog_paf.source_type = 'PAF';
begin
--
   -- all POG_PAF for the assignment must be removed
   for pafrec in get_pogpaf(p_assignment_id) loop
--
    zap_object_group(pafrec.object_group_id);
--
   end loop;
--

end;

/*
   Name
      asg_insert_trigger
   Description

      This is the Dynamic Trigger Code for Assignment Processing
      Groups
*/

procedure asg_insert_trigger(p_assignment_id            in number,
                             p_person_id                in number,
                             p_period_of_service_id     in number,
                             p_new_effective_start_date in date,
                             p_new_effective_end_date   in date,
                             p_new_payroll_id           in number,
                             p_business_group_id        in number
                            )
is
dt_mode varchar2(20);
begin
--
  if (is_pog_enable(p_business_group_id) = TRUE) then
     asg_datetracked_insert(p_assignment_id,
                       p_person_id,
                       p_period_of_service_id,
                       p_new_effective_start_date,
                       p_new_effective_end_date,
                       p_new_payroll_id
                      );
  end if;
--
end asg_insert_trigger;

/*
   Name
      asg_update_trigger
   Description

      This is the Dynamic Trigger Code for Assignment Processing
      Groups
*/

procedure asg_update_trigger(p_assignment_id            in number,
                             p_person_id                in number,
                             p_period_of_service_id     in number,
                             p_old_effective_start_date in date,
                             p_old_effective_end_date   in date,
                             p_new_effective_start_date in date,
                             p_new_effective_end_date   in date,
                             p_old_payroll_id           in number,
                             p_new_payroll_id           in number,
                             p_business_group_id        in number
                            )
is
dt_mode varchar2(20);
begin
--
  if (is_pog_enable(p_business_group_id) = TRUE) then
     --
     -- First set the Date Track mode
     --
     dt_mode := PAY_POG_ALL_ASSIGNMENTS_PKG.dyt_mode;
--
     if (   dt_mode = 'CORRECTION'
         or dt_mode = 'UPDATE'
         or dt_mode = 'UPDATE_CHANGE_INSERT') then
--
        asg_datetracked_update(p_assignment_id,
                           p_person_id,
                           p_period_of_service_id,
                           p_old_effective_start_date,
                           p_old_effective_end_date,
                           p_new_effective_start_date,
                           p_new_effective_end_date,
                           p_old_payroll_id,
                           p_new_payroll_id
                          );
--
     elsif (   dt_mode = 'UPDATE_OVERRIDE') then
--
        asg_datetracked_ovrr_update(p_assignment_id,
                                p_person_id,
                                p_period_of_service_id,
                                p_old_effective_start_date,
                                p_old_effective_end_date,
                                p_new_effective_start_date,
                                p_new_effective_end_date,
                                p_old_payroll_id,
                                p_new_payroll_id
                               );
--
     elsif (   dt_mode = 'START_EARLIER') then
--
        asg_datetracked_strt_early(p_assignment_id,
                                p_person_id,
                                p_period_of_service_id,
                                p_old_effective_start_date,
                                p_old_effective_end_date,
                                p_new_effective_start_date,
                                p_new_effective_end_date,
                                p_old_payroll_id,
                                p_new_payroll_id
                               );
--
     end if;
  end if;
--
end asg_update_trigger;
--
/*
   Name
      asg_delete_trigger
   Description

      This is the Dynamic Trigger Code for Assignment Processing
      Groups
*/

procedure asg_delete_trigger(p_assignment_id        in number,
                             p_effective_end_date   in date,
                             p_business_group_id    in number,
                             p_effective_end_date_o in date
                            )
is
dt_mode varchar2(20);
begin
--
  if (is_pog_enable(p_business_group_id) = TRUE) then
     --
     -- First set the Date Track mode
     --
     dt_mode := PAY_POG_ALL_ASSIGNMENTS_PKG.dyt_mode;
--
     if (   dt_mode = 'ZAP') then
--
       asg_datetracked_zap(p_assignment_id);
--
     elsif (   dt_mode = 'DELETE') then
--
       asg_datetracked_end_date(p_assignment_id,
                          p_effective_end_date
                         );
--
     elsif (   dt_mode = 'FUTURE_CHANGE'
            or dt_mode = 'DELETE_NEXT_CHANGE') then
        asg_datetracked_delete_next(p_assignment_id,
                                    p_effective_end_date,
                                    p_effective_end_date_o
                                   );
     end if;
  end if;
--
end asg_delete_trigger;
--
/*
   Name
      upgrade_asg
   Description

      Upgrades existing data to have process groups. This is used by
      the generic upgrade process to convert existing legislations.
*/
procedure upgrade_asg(p_asg_id in number)
is
--
cursor get_asg_info(p_asg_id in number)
is
select assignment_id,
       person_id,
       period_of_service_id,
       payroll_id,
       effective_start_date,
       effective_end_date,
       business_group_id
from per_all_assignments_f
where assignment_id = p_asg_id
order by assignment_id, effective_start_date;
--
asg_id               per_all_assignments_f.assignment_id%type;
per_id               per_all_assignments_f.person_id%type;
pos_id               per_all_assignments_f.period_of_service_id%type;
pay_id               per_all_assignments_f.payroll_id%type;
effective_start_date date;
effective_end_date   date;
first_row            boolean;
--
begin
--
  first_row := TRUE;
  for asgrec in get_asg_info(p_asg_id) loop
--
    if (first_row = TRUE) then
--
      PAY_POG_ALL_ASSIGNMENTS_PKG.dyt_mode := 'INSERT';
      asg_insert_trigger
           (p_assignment_id            => asgrec.assignment_id,
            p_person_id                => asgrec.person_id,
            p_period_of_service_id     => asgrec.period_of_service_id,
            p_new_effective_start_date => asgrec.effective_start_date,
            p_new_effective_end_date   => asgrec.effective_end_date,
            p_new_payroll_id           => asgrec.payroll_id,
            p_business_group_id        => asgrec.business_group_id
           );
      asg_id := asgrec.assignment_id;
      per_id := asgrec.person_id;
      pos_id := asgrec.period_of_service_id;
      pay_id := asgrec.payroll_id;
      effective_start_date := asgrec.effective_start_date;
      effective_end_date := asgrec.effective_end_date;
      first_row := FALSE;
--
    else
--
       PAY_POG_ALL_ASSIGNMENTS_PKG.dyt_mode := 'UPDATE';
       asg_update_trigger
             (p_assignment_id            => asgrec.assignment_id,
              p_person_id                => asgrec.person_id,
              p_period_of_service_id     => asgrec.period_of_service_id,
              p_old_effective_start_date => effective_start_date,
              p_old_effective_end_date   => effective_end_date,
              p_new_effective_start_date => asgrec.effective_start_date,
              p_new_effective_end_date   => asgrec.effective_end_date,
              p_old_payroll_id           => pay_id,
              p_new_payroll_id           => asgrec.payroll_id,
              p_business_group_id        => asgrec.business_group_id
             );
--
      asg_id := asgrec.assignment_id;
      per_id := asgrec.person_id;
      pos_id := asgrec.period_of_service_id;
      pay_id := asgrec.payroll_id;
      effective_start_date := asgrec.effective_start_date;
      effective_end_date := asgrec.effective_end_date;
      first_row := FALSE;
--
    end if;
--
  end loop;
--
end upgrade_asg;
--
end pay_asg_process_grp_pkg;

/
