--------------------------------------------------------
--  DDL for Package Body PAY_RETRO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RETRO_PKG" 
/* $Header: pyretpay.pkb 120.28.12010000.6 2010/04/15 05:43:01 priupadh ship $ */
as
--
--
/*
PRODUCT
    Oracle*Payroll
--
NAME
   pyretpay.pkb
--
DESCRIPTION
--
MODIFIED (DD-MON-YYYY)
   priupadh   15-APR-2010  Bug 9405939 Now using retro element while creating negative retro run result values.
   priupadh   27-AUG-2009  Bug 8790029  Modified process_recorded_date and reset_recorded_request
   phattarg   08-JUL-2009  Bug 8614449. Created a new payroll action whenever a new
                                        assignment action is created in overlap_adjustments.
   ckesanap   04-MAR-2009  Bug 8407213. Insert overlap date(get_ee_overlap_date) and
                           recalculation_date(process_recorded_date) in serial_number
                           column of pay_assignment_actions.
			   Insert the previous recorded_date in label_identifier column
			   and accessed in reset_recorded_request for rollback of retropay.
   ckesanap   17-SEP-2008  Bug 7335351. Modified process_recorded_date.
   ckesanap   25-AUG-2008  Bug 7335351. Added a cursor get_proc_retro_rrv to
                           fetch all the processed retro entries in a given
			   pay period. Creating negative balance adjustment
			   run results for all such retro entries.
   ckesanap   18-AUG-2008  Bug 7335351. Modified overlap_adjustments.
   ckesanap   18-JUL-2008  Bug 7248998. Modified process_recorded_date to
                           return the assignment's reprocess date for the
			   retro_overlap enhancement.
   salogana   18-MAR-2008  In reset_recorded_request to avoid
                           performance issues function to_char
			   has been added for l_assign_id which
			   enables the queries to use the
			   appropriate indexes.
   kkawol     02-AUG-2007  Added reset_recorded_request and
                           process_recorded_date.
   alogue     26-JUN-2007  Performance fix to maintain_retro_entry.
                           Bug 6147807.
   kkawol     19-JUN-2007  get_reprocess_type now uses pay_proc_environment
                           bgid and legc.
   kkawol     04-JUN-2007  Changed get_entry_path so reversals work correctly.
   thabara    26-MAR-2007  Modified maintain_retro_entry to update
                           retro_component_id.
   nbristow   15-JAN-2007  Added overlap_adjustments.
   alogue     12-JAN-2007  Further changes to get_source_element_type.
   alogue     10-JAN-2007  Further changes to get_source_element_type
                           and debug if required.
   alogue     09-JAN-2007  Re-implement get_source_element_type
                           changes. Bug 5747560.
   alogue     30-NOV-2006  Change comment for last change!
   alogue     24-NOV-2006  Undo recent changes to get_source_element_type.
   nbristow   06-NOV-2006  get_ee_overlap_date was not joining to
                           the retro assignments table correctly
                           in a multi-assignment environment.
   mreid      06-OCT-2006  Added hint to business group sql
   nbristow   28-SEP-2006  Fixed test harness failures.
   alogue     13-SEP-2006  Avoid ORA-01422 in get_source_element_type.
                           Bug 5482805.
   nbristow   12-SEP-2006  Added new get_entry_path.
   alogue     07-SEP-2006  Ensure run result is a processed one in
                           get_source_element_type.  Bug 5482805.
   alogue     01-SEP-2006  Performance fix to get_ee_overlap_date_int.
                           Bug 5482574.
   nbristow   01-JUN-2006  Added process_retro_entry
   alogue     17-MAR-2006  Caches in get_reprocess_type. Bug 5101847.
   nbristow   14-MAR-2006  Added get_retro_asg_id.
   alogue     07-MAR-2006  Enhanced generate_obj_grp_actions so
                           don't create actions for assignments
                           only existing in the future. Bug 5082050.
   alogue     01-MAR-2006  Enhanced get_ee_overlap_date_int to
                           account for POG master actions owning
                           the retro element entries. Bug 5057817.
   kkawol     26-JAN-2006  added get_entry_path to convert entry
                           paths for retropay into new shorter format.
   nbristow   28-SEP-2005  get_asg_from_pg_action needs
                           to take into account of date
                           effectiveity.
   nbristow   29-JUN-2005  Overlap satetment was using the
                           wrong entry table.
   nbristow   23-MAR-2005  Performance improvement to the overlap
                           statements.
   nbristow   22-MAR-2005  get_ee_overlap_date now only overrides
                           the date if there are retro entries for
                           the overlapping period.
   nbristow   12-JAN-2005  Added date effective joins to
                           retro_component_usages.
   nbristow   25-NOV-2004  Retropay multi assignments
   jford      08-SEP-2004  Get_retro_component moved to pyretutl.pkb
   tbattoo    09-AUG-2004  Added functions to suporrt reversals in retropay
   jford      05-AUG-2004  maintain_entries now Merges System and User
   nbristow   14-JUL-2004  Changes for Enhanced version of Retro
                           NOticfications.
   nbristow   26-MAY-2004  Fixed previous change.
   alogue     06-MAY-2004  Qualify result to be PROCESSED ones in
                           get_source_element_type to avoid ORA-01422.
                           Bug 3598256.
   alogue     27-APR-2004  Performance fix in latest_replace_ovl_del_ee.
   nbristow   15-MAR-2004  Added is_retro_rr.
   kkawol     07-JAN-2004  Added latest_replace_ovl_ee,
                           latest_replace_ovl_del_ee.
   kkawol     20-NOV-2003  Passing bus grp id to get_retro_element,
                           this is required when calling is_date_in_span.
   nbristow   07-OCT-2003  Added nocopy to get_ee_overlap_date.
   nbristow   07-OCT-2003  Added process_retro_value.
   nbristow   03-OCT-2003  Added get_ee_overlap_date.
   nbristow   02-SEP-2003  Changed get_retro_element to
                           return correct element.
   nbristow   28-AUG-2003  Added dbdrv statements.
   nbristow   28-AUG-2003  Uncommented exit.
   nbristow   27-AUG-2003  Changes for Advanced Retropay
   jalloun    30-JUL-1996  Added error handling.
   nbristow   12-MAR-1996  Created
*/
-- Caches for get_reprocess_type
g_bus_grp  per_business_groups_perf.business_group_id%type := null;
g_leg_code per_business_groups_perf.legislation_code%type := null;
--
   procedure retro_run_proc
   is
   begin
      null;
   end;
--
   procedure retro_end_proc
   is
   begin
      null;
   end;
--
--
-- Name process_retro_entry
-- Description
--
-- Called from the Elment Entry fetch to determin if the Entry
-- can be processed in the Run
--
function process_retro_entry(
                       p_element_entry_id in number,
                       p_element_type_id  in number,
                       p_retro_comp_id    in number,
                       p_retro_asg_id     in number,
                       p_ee_creator_id    in number,
                       p_action_sequence  in number
                      )
return number
is
l_result number;
begin
   select 1
     into l_result
     from dual
    where pay_retro_pkg.process_retro_value(
                                   p_element_entry_id,
                                   p_element_type_id,
                                   p_retro_comp_id,
                                   p_retro_asg_id
                                  ) = 'Y'
      and exists (select ''
                    from pay_assignment_actions paa
                   where paa.assignment_action_id = p_ee_creator_id
                     and paa.action_sequence < p_action_sequence
                 );
--
    return l_result;
--
exception
     when no_data_found then
        return 0;
end process_retro_entry;
--
-- Name get_reprocess_type
-- Description
--
-- Find out how to process the entry for this component.
--
function get_reprocess_type(
                       p_entry_id        in number,
                       p_element_type_id in number,
                       p_retro_comp_id   in number,
                       p_retro_asg_id    in number,
                       p_default_type    in varchar2 default 'R'
                      )
return varchar2
is
--
l_dummy number;
l_reprocess_type pay_retro_component_usages.reprocess_type%type;
--
begin
   select 1
     into l_dummy
     from pay_retro_entries pre
    where retro_assignment_id = p_retro_asg_id
      and retro_component_id = p_retro_comp_id
      and element_entry_id = p_entry_id;
--
   return 'R';
--
exception
    when no_data_found then
--
      begin
--
        hr_utility.trace('Get reprocess type bgid :' || to_char(pay_proc_environment_pkg.bgid));
        hr_utility.trace('Get reprocess type legc:' || pay_proc_environment_pkg.legc);

        select prcu.reprocess_type
          into l_reprocess_type
          from pay_retro_component_usages prcu
         where prcu.retro_component_id = p_retro_comp_id
           and prcu.creator_id = p_element_type_id
           and prcu.creator_type = 'ET'
           and ((    prcu.business_group_id = pay_proc_environment_pkg.bgid
                 and prcu.legislation_code is null)
                or
                (    prcu.legislation_code = pay_proc_environment_pkg.legc
                 and prcu.business_group_id is null)
                or
                (    prcu.legislation_code is null
                 and prcu.business_group_id is null)
               );
--
         return l_reprocess_type;
--
      exception
        when no_data_found then
           return p_default_type;
      end;
end get_reprocess_type;
--
--
-- Name get_retro_process_type
-- Description
--
-- Determine the process type for a retro entry.
--
function get_retro_process_type(
                       p_entry_id        in number,
                       p_element_type_id in number,
                       p_retro_comp_id   in number,
                       p_retro_asg_id    in number,
                       p_source_type     in varchar2
                      )
return varchar2
is
proc_type pay_retro_component_usages.reprocess_type%type;
begin
--
   proc_type := get_reprocess_type(p_entry_id,
                                   p_element_type_id,
                                   p_retro_comp_id,
                                   p_retro_asg_id);
--
  if (proc_type = 'P' and p_source_type = 'I') then
     proc_type := 'R';
  end if;
--
  return proc_type;
--
end get_retro_process_type;
--
--
-- Name process_value
-- Description
--
-- Used by the EE fetch to determine if an entry should
-- be processed by this Component.
--
function process_value(p_value_type      in varchar2,
                       p_entry_id        in number,
                       p_element_type_id in number,
                       p_retro_comp_id   in number,
                       p_retro_asg_id    in number,
                       p_result_type     in varchar2)
return varchar2
is
--
l_dummy number;
l_reprocess_type pay_retro_component_usages.reprocess_type%type;
--
begin
--
   l_reprocess_type := get_reprocess_type(p_entry_id,
                                          p_element_type_id,
                                          p_retro_comp_id,
                                          p_retro_asg_id);
--
   if (p_value_type = 'EE') then
--
     if (l_reprocess_type = 'R') then
       return 'Y';
     else
       return 'N';
     end if;
--
   else
--
     -- It must be a Run Result
--
     if (l_reprocess_type = 'R') then
       return 'N';
     elsif (l_reprocess_type = 'S') then
       return 'Y';
     else
       --
       -- It must be a PARTIAL
       --
       if (p_result_type = 'E') then
           return 'Y';
       else
           return 'N';
       end if;
     end if;
   end if;
--
end process_value;
--
--
-- Name process_retro_value
-- Description
--
-- This function is used in the Element entry fetch to
-- determine if a retro entry can be processed in an
-- overlaping retropay.
--
function process_retro_value(
                             p_entry_id        in number,
                             p_element_type_id in number,
                             p_retro_comp_id   in number,
                             p_retro_asg_id    in number
                            )
return varchar2
is
--
l_dummy number;
l_reprocess_type pay_retro_component_usages.reprocess_type%type;
--
begin
--
   /* If no retro component is supplied then it must be
      an old style retropay. Hence do not process
      the retro entry
   */
   if (p_retro_comp_id is null) then
     return 'N';
   end if;
--
   l_reprocess_type := get_reprocess_type(p_entry_id,
                                          p_element_type_id,
                                          p_retro_comp_id,
                                          p_retro_asg_id,
                                          'D'); -- Do not reprocess
--
     if (l_reprocess_type = 'R') then
       return 'Y';
     else
       return 'N';
     end if;
--
end process_retro_value;
--
--
-- Name is_retro_entry
-- Description
--
-- This function determines if an entry is a retro entry
--
function is_retro_entry(p_creator_type in varchar2)
return number
is
begin
--
   if (p_creator_type in ('P', 'R', 'RR', 'EE', 'PR', 'NR') ) then
     return 1;
   else
     return 0;
   end if;
--
end is_retro_entry;
--
function is_retro_rr(p_element_entry_id in number,
                        p_date             in date)
return number
is
--
l_creator_type pay_element_entries_f.creator_type%type;
--
begin
--
  select creator_type
    into l_creator_type
    from pay_element_entries_f
    where element_entry_id = p_element_entry_id
      and p_date between effective_start_date
                     and effective_end_date;
--
   return pay_retro_pkg.is_retro_entry(l_creator_type);
--
exception
   when no_data_found then
       return 0;
end is_retro_rr;
--
--
-- Name get_source_element_type
-- Description
--
-- Find the originating element type.
--
function get_source_element_type (p_entry_id in number,
                                  p_aa_id    in number)
return number
is
--
   cursor c_rr
   is
   select prr2.element_type_id, prr2.element_entry_id
          from pay_run_results prr2
         where prr2.source_id = p_entry_id
           and nvl(prr2.element_entry_id,-999) = p_entry_id
           and prr2.source_type = 'E'
           and prr2.assignment_action_id = p_aa_id;
--
l_src_et_id pay_run_results.element_type_id%type;
--
begin
--
  begin
     select distinct prr2.element_type_id
       into l_src_et_id
       from pay_run_results prr2
      where prr2.source_id = p_entry_id
        and nvl(prr2.element_entry_id,-999) = p_entry_id
        and prr2.source_type = 'E'
        and prr2.assignment_action_id = p_aa_id;
--
  exception
     when others then

        hr_utility.trace('Clash : '||p_entry_id||' '||p_aa_id);
        for rr in c_rr loop
            hr_utility.trace(rr.element_type_id||' '||rr.element_entry_id);
        end loop;

        raise;
  end;
--
  return l_src_et_id;
--
end get_source_element_type;
--
-- Name get_retro_element
-- Description
--
-- Deterime the Retro Element that should be used for this
-- Element Type, Component and date combination
--
procedure get_retro_element(p_element_type_id   in            number,
                            p_retro_eff_date    in            date,
                            p_run_eff_date      in            date,
                            p_retro_comp_id     in            number,
                            p_adjustment_type   in            varchar2,
                            p_retro_ele_type_id    out nocopy number,
                            p_business_group_id in number default null
                           )
is
--
l_retro_ele_type_id pay_element_types_f.retro_summ_ele_id%type;
--
begin
--
   l_retro_ele_type_id := null;
--
   if (p_retro_comp_id is null) then
--
     select nvl(pet1.retro_summ_ele_id, pet1.element_type_id)
     into   l_retro_ele_type_id
     from   pay_element_types_f pet1
     where  pet1.element_type_id = p_element_type_id
      and   p_retro_eff_date between pet1.effective_start_date
                                 and pet1.effective_end_date;
--
   else
--
     declare
      l_leg_code per_business_groups_perf.legislation_code%type;
     begin
--
        select legislation_code
          into l_leg_code
          from per_business_groups_perf
         where business_group_id = p_business_group_id;
--
        select pesu.retro_element_type_id
          into l_retro_ele_type_id
          from pay_element_span_usages    pesu,
               pay_retro_component_usages prcu,
               pay_time_spans             pts
         where prcu.retro_component_id = p_retro_comp_id
           and prcu.creator_id = p_element_type_id
           and prcu.creator_type = 'ET'
           and prcu.retro_component_usage_id = pesu.retro_component_usage_id
           and nvl(pesu.adjustment_type, 'A') = p_adjustment_type
           and pay_core_dates.is_date_in_span
                            (pts.start_time_def_id,
                             pts.end_time_def_id,
                             p_run_eff_date,
                             p_retro_eff_date,
                             p_business_group_id) = 'Y'
          and pts.time_span_id = pesu.time_span_id
          and pts.creator_id = prcu.retro_component_id
          and ((    prcu.business_group_id = p_business_group_id
                 and prcu.legislation_code is null)
                or
                (    prcu.legislation_code = l_leg_code
                 and prcu.business_group_id is null)
                or
                (    prcu.legislation_code is null
                 and prcu.business_group_id is null)
               )
           and ((    pesu.business_group_id = p_business_group_id
                 and pesu.legislation_code is null)
                or
                (    pesu.legislation_code = l_leg_code
                 and pesu.business_group_id is null)
                or
                (    pesu.legislation_code is null
                 and pesu.business_group_id is null)
               );
--
     exception
--
        when no_data_found then
--
          /* When a Credit or Debit Retro Element does not exist look
             for a Standard Retro Element
          */
          select pesu.retro_element_type_id
            into l_retro_ele_type_id
            from pay_element_span_usages    pesu,
                 pay_retro_component_usages prcu,
                 pay_time_spans             pts
           where prcu.retro_component_id = p_retro_comp_id
             and prcu.creator_id = p_element_type_id
             and prcu.creator_type = 'ET'
             and prcu.retro_component_usage_id = pesu.retro_component_usage_id
             and nvl(pesu.adjustment_type, 'A') = 'A'
             and pay_core_dates.is_date_in_span
                              (pts.start_time_def_id,
                               pts.end_time_def_id,
                               p_run_eff_date,
                               p_retro_eff_date,
                               p_business_group_id) = 'Y'
            and pts.time_span_id = pesu.time_span_id
            and pts.creator_id = prcu.retro_component_id
            and ((    prcu.business_group_id = p_business_group_id
                   and prcu.legislation_code is null)
                  or
                  (    prcu.legislation_code = l_leg_code
                   and prcu.business_group_id is null)
                  or
                  (    prcu.legislation_code is null
                   and prcu.business_group_id is null)
                 )
             and ((    pesu.business_group_id = p_business_group_id
                   and pesu.legislation_code is null)
                  or
                  (    pesu.legislation_code = l_leg_code
                   and pesu.business_group_id is null)
                  or
                  (    pesu.legislation_code is null
                   and pesu.business_group_id is null)
                 );
--
     end;
--
   end if;
--
   p_retro_ele_type_id := l_retro_ele_type_id;
--
exception
    when no_data_found then
        p_retro_ele_type_id := null;
--
end get_retro_element;
--
--
-- Name get_ee_overlap_date
-- Description
--
-- Given a start date to run the Retropay process, does the
-- system think that we need to alter this date in order for
-- retropay to calculate correctly.
--
-- At the moment this acts like Retropay by Aggregate to
-- go back to the earliest overlapping retropay.
--
   procedure get_ee_overlap_date_int(p_asg_id         in            number,
                                 p_start_date     in            date,
                                 p_effective_date in            date,
                                 p_adj_start_date    out nocopy date
                                )
   is
     l_start_date date;
     l_reprocess_start_date date;
   begin
--
      /* Get the earliest start date on the payroll actions */
      select min(ppa.start_date)
        into l_start_date
        from pay_payroll_actions ppa,
             pay_assignment_actions paa_ret,
             pay_assignment_actions paa_mret
       where ppa.effective_date between p_start_date
                                    and p_effective_date
         and ppa.action_type = 'L'
         and paa_ret.payroll_action_id = ppa.payroll_action_id
         and paa_ret.assignment_id = p_asg_id
         and paa_mret.object_id = paa_ret.object_id
         and paa_mret.object_type = paa_ret.object_type
         and paa_mret.payroll_action_id = paa_ret.payroll_action_id
         and paa_mret.source_action_id is null
         and exists (select ''
                       from pay_element_entries_f pee
                      where pee.creator_id = paa_mret.assignment_action_id
                        and pee.creator_type in ('RR', 'EE', 'NR', 'PR')
                        and pee.assignment_id = paa_ret.assignment_id);
--
      select min(pra.reprocess_date)
        into l_reprocess_start_date
        from pay_retro_assignments pra,
             pay_payroll_actions ppa,
             pay_assignment_actions paa_ret,
             pay_assignment_actions paa_mret
       where ppa.effective_date between p_start_date
                                    and p_effective_date
         and ppa.action_type = 'L'
         and paa_ret.payroll_action_id = ppa.payroll_action_id
         and paa_ret.assignment_id = p_asg_id
         and pra.retro_assignment_action_id = paa_mret.assignment_action_id
                           + decode(paa_ret.action_sequence, 0, 0, 0)
         and paa_mret.object_id = paa_ret.object_id
         and paa_mret.object_type = paa_ret.object_type
         and paa_mret.payroll_action_id = paa_ret.payroll_action_id
         and paa_mret.source_action_id is null
         and exists (select ''
                       from pay_element_entries_f pee
                      where pee.creator_id = paa_mret.assignment_action_id
                        and pee.creator_type in ('RR', 'EE', 'NR', 'PR')
                        and pee.assignment_id = paa_ret.assignment_id);
--
      l_start_date := nvl(l_start_date, p_start_date);
      l_reprocess_start_date := nvl(l_reprocess_start_date, p_start_date);
      l_start_date := least(l_start_date, l_reprocess_start_date);
--
      /* OK we need to recursively call the procedure
         to get the absolutely earliest date the Retropay
         should run for.
      */
      if (l_start_date >= p_start_date) then
         p_adj_start_date := p_start_date;
      else
--
         get_ee_overlap_date_int(p_asg_id,
                             l_start_date,
                             p_effective_date,
                             p_adj_start_date);
      end if;
   end get_ee_overlap_date_int;
--
   procedure get_ee_overlap_date(p_assact         in            number,
                                 p_start_date     in            date,
                                 p_effective_date in            date,
                                 p_adj_start_date    out nocopy date
                                )
   is
--
   cursor c_asg (p_assact number)
   is
   select paa.assignment_id
     from pay_assignment_actions paa,
          pay_assignment_actions paa2
    where paa2.assignment_action_id = p_assact
      and paa2.object_id = paa.object_id
      and paa2.object_type = paa.object_type
      and paa2.payroll_action_id = paa.payroll_action_id
      and paa.assignment_id is not null;
--
   l_adj_start_date date;
   l_serial_number pay_assignment_actions.serial_number%type;
--
   begin
--
     p_adj_start_date := p_start_date;
     for asgrec in c_asg(p_assact) loop
--
        get_ee_overlap_date_int(asgrec.assignment_id,
                                p_start_date,
                                p_effective_date,
                                l_adj_start_date);
        p_adj_start_date := least(p_adj_start_date, l_adj_start_date);
--
     end loop;

     -- bug 8407213. Log earliest_overlap_date in serial_number column of pay_assignment_actions table.

     l_serial_number := 'ovl='||substr(fnd_date.date_to_canonical(p_adj_start_date),1,11);

     update pay_assignment_actions
	set serial_number = l_serial_number
	where assignment_action_id = p_assact;
--
   end get_ee_overlap_date;
--
-- Name latest_replace_ovl_ee
--
-- Description
--
-- For replacement retropay, we are only interested in the most recent overlap
-- entry. This procedure works out whether an overlap is actually the
-- latest one for an entry.
--
function latest_replace_ovl_ee ( p_element_entry_id in NUMBER)
return varchar2
is
--
l_ovl_exists number;
begin
--
   select count(*)
     into l_ovl_exists
     from pay_entry_process_details pepd1,
          pay_entry_process_details pepd2
    where pepd1.element_entry_id = p_element_entry_id
      and pepd2.element_entry_id > pepd1.element_entry_id
      and pepd1.run_result_id = pepd2.run_result_id
      and pepd1.source_entry_id = pepd2.source_entry_id
      and pepd1.source_asg_action_id = pepd2.source_asg_action_id
      and pepd1.source_element_type_id = pepd2.source_element_type_id
      and pepd1.retro_component_id = pepd2.retro_component_id
                 and ((pepd1.tax_unit_id is null
                       and pepd2.tax_unit_id is null
                      ) OR
                      (pepd1.tax_unit_id is not null
                       and pepd2.tax_unit_id is not null
                       and pepd1.tax_unit_id = pepd2.tax_unit_id
                     ));
--
   if (l_ovl_exists = 0) then
     return 'Y';
   else
     return 'N';
   end if;
--
end latest_replace_ovl_ee;
--
-- Name latest_replace_ovl_del_ee
--
-- Description
--
-- For replacement retropay, we are only interested in the most recent overlap
-- entry. This procedure works out whether an overlap is actually the
-- latest one for an entry.
-- This procedure is to return negative replacement entries which have no
-- matching positive replacement, meaning the entry has been deleted.
-- First check it's the last overlap, then check there's no matching PR.
function latest_replace_ovl_del_ee ( p_element_entry_id in NUMBER)
return varchar2
is
--
l_ovl_exists number;
l_matching_pr number;
begin
--
   select count(*)
     into l_ovl_exists
     from pay_entry_process_details pepd1,
          pay_entry_process_details pepd2
    where pepd1.element_entry_id = p_element_entry_id
      and pepd2.element_entry_id > pepd1.element_entry_id
      and pepd1.run_result_id = pepd2.run_result_id
      and pepd1.source_entry_id = pepd2.source_entry_id
      and pepd1.source_asg_action_id = pepd2.source_asg_action_id
      and pepd1.source_element_type_id = pepd2.source_element_type_id
      and pepd1.retro_component_id = pepd2.retro_component_id
                 and ((pepd1.tax_unit_id is null
                       and pepd2.tax_unit_id is null
                      ) OR
                      (pepd1.tax_unit_id is not null
                       and pepd2.tax_unit_id is not null
                       and pepd1.tax_unit_id = pepd2.tax_unit_id
                     ));
--
   if (l_ovl_exists = 0) then
      select count(*)
        into l_matching_pr
        from pay_entry_process_details pepd1,
             pay_element_entries_f pee1
       where pepd1.element_entry_id = p_element_entry_id
         and pepd1.element_entry_id = pee1.element_entry_id
         and exists
             (select 'Y'
                from pay_entry_process_details pepd2,
                     pay_element_entries_f pee2
               where pee2.creator_type = 'PR'
                 and pee2.element_entry_id = pepd2.element_entry_id
                 and pee2.assignment_id = pee1.assignment_id
                 and pepd1.run_result_id = pepd2.run_result_id
                 and pepd1.source_entry_id = pepd2.source_entry_id
                 and pepd1.source_asg_action_id = pepd2.source_asg_action_id
                 and pepd1.source_element_type_id = pepd2.source_element_type_id
                 and pepd1.retro_component_id = pepd2.retro_component_id
                 and ((pepd1.tax_unit_id is null
                       and pepd2.tax_unit_id is null
                      ) OR
                      (pepd1.tax_unit_id is not null
                       and pepd2.tax_unit_id is not null
                       and pepd1.tax_unit_id = pepd2.tax_unit_id
                     ))
                 and pee1.creator_id = pee2.creator_id
             );
--
     if (l_matching_pr = 0) then
        return 'Y';
     else
        return 'N';
     end if;
--
   else
     return 'N';
   end if;
--
end latest_replace_ovl_del_ee;
--
--
-- ----------------------------------------------------------------------------
--                                                                           --
--   get_retro_component_id
--
--     This Function is called during the process to insert the retro_entry --
--   A "Recalculation Reason" (or Retro-Component) is need to associate with --
--   the entry details.  EG What kind of change has required this entry to be--
--   recalculated
--
--   Result: An ID of the seeded retro_component
-- ----------------------------------------------------------------------------
--
FUNCTION get_retro_component_id (
                          p_element_entry_id  in number,
                          p_ef_date    in date) return number IS
--
  l_retro_comp_id number := -1;
BEGIN
  -- This procedure is obsolete
  -- All code should be calling the following directly.
--
  l_retro_comp_id := pay_retro_utils_pkg.get_retro_component_id(
         p_element_entry_id,
         p_ef_date,
         null); -- Direct calls should also pass element_type_id
--
  -- hr_utility.trace(' Returned component_id is '||l_retro_comp_id);
  return l_retro_comp_id;
END get_retro_component_id;
--
/*
   Procedure: create_retro_entry
   Description:
        This procedure creates an entry in the
        PAY_RETRO_ENTRIES table.
*/
procedure create_retro_entry(
        p_retro_assignment_id    IN NUMBER
,       p_element_entry_id       IN NUMBER
,       p_element_type_id        IN NUMBER
,       p_reprocess_date         IN DATE
,       p_eff_date               IN DATE
,       p_retro_component_id     IN NUMBER
,       p_owner_type             IN VARCHAR2
,       p_system_reprocess_date  IN DATE) is
--
Begin
  --
  INSERT INTO pay_retro_entries
  (        retro_assignment_id
  ,        element_entry_id
  ,        reprocess_date
  ,        effective_date
  ,        retro_component_id
  ,        element_type_id
  ,        owner_type
  ,        system_reprocess_date
  )
  VALUES
  (        p_retro_assignment_id
  ,        p_element_entry_id
  ,        p_reprocess_date
  ,        p_eff_date
  ,        p_retro_component_id
  ,        p_element_type_id
  ,        p_owner_type
  ,        p_system_reprocess_date
  );
--
end create_retro_entry;
--
/*
   Procedure: maintain_retro_entry
   Description:
        This procedure creates and maintains an entry in the
        PAY_RETRO_ENTRIES table.
*/
procedure maintain_retro_entry
(
          p_retro_assignment_id    IN NUMBER
  ,       p_element_entry_id       IN NUMBER
  ,       p_element_type_id        IN NUMBER
  ,       p_reprocess_date         IN DATE
  ,       p_eff_date               IN DATE
  ,       p_retro_component_id     IN NUMBER
  ,       p_owner_type             IN VARCHAR2  default 'S' --System
  ,       p_system_reprocess_date  IN DATE  default hr_api.g_eot)
is
l_min_reprocess_date date;
l_min_effective_date date;
l_min_sys_reprocess_date date;
l_owner_type         varchar2(30);
l_retro_component_id pay_retro_entries.retro_component_id%type;
n_min_reprocess_date date;
n_min_effective_date date;
n_min_sys_reprocess_date date;
n_owner_type         varchar2(30);
n_retro_component_id pay_retro_entries.retro_component_id%type;
--
begin
--
   select reprocess_date,
          effective_date,
          owner_type,
          nvl(system_reprocess_date, hr_api.g_eot),
          retro_component_id
     into l_min_reprocess_date,
          l_min_effective_date,
          l_owner_type,
          l_min_sys_reprocess_date,
          l_retro_component_id
     from pay_retro_entries
    where retro_assignment_id = p_retro_assignment_id
      and element_entry_id = p_element_entry_id;
--
-- The reprocess and effective dates are always the least if a row exists
    n_min_reprocess_date := least(l_min_reprocess_date, p_reprocess_date);
    n_min_effective_date := least(l_min_effective_date, p_eff_date);
--
-- The system date is the least of 2  of old and new as long as not User owned
      n_min_sys_reprocess_date := least(l_min_sys_reprocess_date,
                          p_system_reprocess_date);
--
-- Test for conditions, remembering we need to differentiate if the change
-- was user made, or system
-- ( Lookup RETRO_ENTRY_OWNER_TYPE )
--
  -- If old and new owners were USER or both were SYSTEM then
  -- we leave as unaltered, else owner is MERGED
    if (l_owner_type = 'U' and p_owner_type = 'U')
    or (l_owner_type = 'S' and p_owner_type = 'S') then
      n_owner_type := l_owner_type;
    else
      n_owner_type := 'M';
    end if;

    if (p_retro_component_id is not null) then
       n_retro_component_id := p_retro_component_id;
    else
       n_retro_component_id := l_retro_component_id;
    end if;
--
-- Only perform update if need to
--
    if (l_min_reprocess_date <> n_min_reprocess_date OR
        l_min_effective_date <> n_min_effective_date OR
        l_min_sys_reprocess_date <> n_min_sys_reprocess_date OR
        l_owner_type <> n_owner_type OR
        l_retro_component_id <> n_retro_component_id) then
       update pay_retro_entries
          set reprocess_date = n_min_reprocess_date,
              effective_date = n_min_effective_date,
              retro_component_id = n_retro_component_id,
              owner_type     = n_owner_type,
              system_reprocess_date = n_min_sys_reprocess_date
        where retro_assignment_id = p_retro_assignment_id
          and element_entry_id = p_element_entry_id;
    end if;
--
exception
--
   when no_data_found then
--
--  No existing retro_entry exists for this entry_id
--  Thus create one with passed info.
--
-- If system owned then the system_reprocess date is simply this reprocess_date
if ( p_owner_type = 'S' ) then
  l_min_sys_reprocess_date := p_reprocess_date;
else
  l_min_sys_reprocess_date := p_system_reprocess_date;
end if;
--
       create_retro_entry(
          p_retro_assignment_id => p_retro_assignment_id,
          p_element_entry_id    => p_element_entry_id,
          p_element_type_id     => p_element_type_id,
          p_reprocess_date      => p_reprocess_date,
          p_eff_date            => p_eff_date,
          p_retro_component_id  => p_retro_component_id,
          p_owner_type          => p_owner_type,
          p_system_reprocess_date => l_min_sys_reprocess_date);
--
end maintain_retro_entry;
--
/*
   Procedure: merge_retro_assignments
   Description:
        This procedure is used by the Rollback process to merge
        any outstanding Retro assignments with the existing
        retro assignment that is being rolled back.
*/
procedure merge_retro_assignments(p_asg_act_id in number)
is
--
cursor get_unproc(p_assignment_id in number)
is
select pra.retro_assignment_id,
       pre.element_entry_id,
       pre.element_type_id,
       pre.reprocess_date,
       pre.effective_date,
       pre.retro_component_id,
       pre.owner_type,
       pre.system_reprocess_date
  from pay_retro_assignments pra,
       pay_retro_entries     pre
 where pra.assignment_id = p_assignment_id
   and pra.retro_assignment_action_id is null
   and pra.retro_assignment_id = pre.retro_assignment_id;
--
cursor get_ret_asg (p_asg_act_id in number)
is
select retro_assignment_id,
       assignment_id
  from pay_retro_assignments
 where retro_assignment_action_id = p_asg_act_id;
--
l_ret_asg_id pay_retro_assignments.retro_assignment_id%type;
l_asg_id     pay_retro_assignments.assignment_id%type;
--
begin
--
   for retasgrec in get_ret_asg(p_asg_act_id) loop
--
      for unprocrec in get_unproc(retasgrec.assignment_id) loop
--
--      Either update or insert rows to represent those that
--      exist on our unproc RA, adding them to the rolled back RA
        maintain_retro_entry(retasgrec.retro_assignment_id,
                             unprocrec.element_entry_id,
                             unprocrec.element_type_id,
                             unprocrec.reprocess_date,
                             unprocrec.effective_date,
                             unprocrec.retro_component_id,
                             unprocrec.owner_type,
                             unprocrec.system_reprocess_date
                            );
        delete from pay_retro_entries
         where element_entry_id = unprocrec.element_entry_id
           and retro_assignment_id = unprocrec.retro_assignment_id;
--
      end loop;
--
--    Remove the row that has now been replicated/merged
      delete from pay_retro_assignments
       where assignment_id = retasgrec.assignment_id
         and retro_assignment_action_id is null;
--
--    Also need to upd our rolled back RA, (done in calling pyrolbak.pkb)
--     i)  removing the retro_asg_act_id and
--     ii) updating reprocess_date to be the new min of the child REs
--
--
   end loop;
--
end merge_retro_assignments;
--
function get_rr_source_id(p_rr_id in number)
return number
is
 l_source_id number;
begin
 select source_id
 into  l_source_id
 from pay_run_results
 where run_result_id=p_rr_id;
--
 return l_source_id;
--
end get_rr_source_id;
--
function get_rr_source_type(p_rr_id in number)
return varchar2
is
 l_source_type varchar2(1);
begin
 select source_type
 into  l_source_type
 from pay_run_results
 where run_result_id=p_rr_id;
--
 return l_source_type;
--
--
end get_rr_source_type;
--
procedure generate_obj_grp_actions (p_pactid       in number,
                                    p_chunk_number in number)
is
--
    cursor get_actions(p_pactid number,
                       p_chunk_number number)
    is
    select paa.assignment_action_id,
           paa.object_id process_group_id,
           ppa.effective_date
      from pay_assignment_actions paa,
           pay_payroll_actions    ppa
     where paa.payroll_action_id = p_pactid
       and ppa.payroll_action_id = p_pactid
       and paa.source_action_id is null
       and paa.chunk_number = p_chunk_number;
--
    cursor get_asg(p_proc_grp_id number,
                   p_eff_date date)
    is
    select distinct
             pog.source_id,
             hr_dynsql.get_tax_unit(pog.source_id,
                                  p_eff_date) tax_unit_id
      from pay_object_groups pog
     where pog.parent_object_group_id = p_proc_grp_id
       and pog.source_type = 'PAF'
       and p_eff_date between pog.start_date
                          and pog.end_date;
--
--
begin
--
   for actrec in get_actions(p_pactid, p_chunk_number) loop
--
      for asgrec in get_asg(actrec.process_group_id, actrec.effective_date) loop
--
        insert into pay_assignment_actions (
               assignment_action_id,
               assignment_id,
               payroll_action_id,
               action_status,
               chunk_number,
               action_sequence,
               object_version_number,
               tax_unit_id,
               source_action_id,
               object_id,
               object_type
               )
        select pay_assignment_actions_s.nextval,
               asgrec.source_id,
               p_pactid,
               'U',
               p_chunk_number,
               pay_assignment_actions_s.nextval,
               1,
               asgrec.tax_unit_id,
               actrec.assignment_action_id,
               actrec.process_group_id,
               'POG'
        from   dual;
--
        update pay_retro_assignments
           set retro_assignment_action_id = actrec.assignment_action_id
         where assignment_id = asgrec.source_id
           and retro_assignment_action_id is null;
--
      end loop;
--
      -- Now update the master Sequence
      update pay_assignment_actions
         set action_sequence = pay_assignment_actions_s.nextval
       where assignment_action_id = actrec.assignment_action_id;
--
   end loop;
--
end generate_obj_grp_actions;
--
function get_asg_from_pg_action(p_obj_grp_id in number,
                                p_obj_type   in varchar2,
                                p_pactid     in number)
return number
is
l_assignment number;
begin
--
  select paa2.assignment_id
    into l_assignment
    from pay_assignment_actions paa2,
         per_all_assignments_f  paf,
         pay_payroll_actions    ppa
   where p_obj_grp_id = paa2.object_id
     and p_obj_type = paa2.object_type
     and p_pactid = paa2.payroll_action_id
     and ppa.payroll_action_id = p_pactid
     and paa2.assignment_id is not null
     and paa2.assignment_id = paf.assignment_id
     and ppa.effective_date between paf.effective_start_date
                                and paf.effective_end_date
     and rownum = 1;
--
  return l_assignment;
--
end get_asg_from_pg_action;
--
function get_entry_path( p_entry_process_path in varchar2,
                         p_source_type in varchar2,
                         p_element_type_id in number,
                         p_run_result_id in number)
return varchar2
is
l_entry_path varchar2(1000);
n            number;
curr_et      varchar2(30);
curr_pos     number;
next_et      varchar2(30);
next_pos     number;
curr_epath   varchar2(1000);
last_element number;
counter      number;
epath_length number;
recursive_level number;
l_src_type   varchar2(1);
--
begin
--
   curr_pos := 0;
   next_pos := 0;
   counter  := 1;
   last_element := 0;
   recursive_level := 1;
--
   if (p_run_result_id is not null) then
     select source_type
       into l_src_type
       from pay_run_results prr2
      where prr2.run_result_id = p_run_result_id;
   end if;
--
   if ((p_entry_process_path is null) and (p_source_type in ('R', 'E'))) then
      l_entry_path := p_entry_process_path;
   elsif ((p_entry_process_path is null) and (p_source_type in ('V', 'I'))) then
      l_entry_path := to_char(p_element_type_id);
   elsif ((p_entry_process_path is null) and (p_run_result_id is not null)) then
      if (l_src_type = 'E') then l_entry_path := p_entry_process_path;
      else l_entry_path := to_char(p_element_type_id);
      end if;
   else /* p_entry_process_path is not null */
--
      /* If there is a square bracket, we do not need to convert format */
--
      n := instr(p_entry_process_path, '[');
      epath_length := length(p_entry_process_path);
--
      if (n <> 0) then
         hr_utility.set_location('Entry Proc Path in correct format', 10);
         l_entry_path := p_entry_process_path;
      else
         hr_utility.set_location('Convert Entry Proc Path: ' || p_entry_process_path, 20);
--
        /* find first element type */
        curr_pos := instr(p_entry_process_path, '.', 1,counter);
        curr_et := substr(p_entry_process_path, 1, curr_pos-1);
--
        /* find second element type */
        counter := counter +1;
        next_pos := instr(p_entry_process_path, '.', 1, counter);
--
        if (curr_pos = 0) then
          l_entry_path := p_entry_process_path;
        else
        while(last_element = 0) loop
           hr_utility.set_location('Entry Path: ' || curr_epath || 'Counter: ' || to_char(counter), 30);
--
           if (next_pos = 0) then
              next_et := substr(p_entry_process_path, curr_pos+1, epath_length-curr_pos);
           else
              next_et := substr(p_entry_process_path, curr_pos+1,  next_pos-1-curr_pos);
           end if;
--
           if (curr_et = next_et) then
              hr_utility.set_location('If Same Element Type', 40);
              while ((curr_et = next_et) and (last_element = 0)) loop
                 hr_utility.set_location('While Same Element Type: ' || curr_et || ' ' || next_et, 50);
                 hr_utility.set_location('Curr Pos and Next Pos: ' || to_char(curr_pos) || ' ' || to_char(next_pos), 55);
                 recursive_level := recursive_level+1;
--
                 hr_utility.set_location('Recursive Level: ' || to_char(recursive_level), 56);
                 if (next_pos = 0) then
                   last_element := 1;
                   next_et := substr(p_entry_process_path, curr_pos+1, epath_length-curr_pos);
                   hr_utility.set_location('Next ET: ' || next_et || 'Curr Pos: ' || curr_pos, 81);
                 else
                    curr_pos := next_pos;
                    counter := counter +1;
                    next_pos := instr(p_entry_process_path, '.', 1, counter);
                    if (next_pos = 0) then
                       next_et := substr(p_entry_process_path, curr_pos+1, epath_length-curr_pos);
                    else
                       next_et := substr(p_entry_process_path, curr_pos+1,  next_pos-1-curr_pos);
                    end if;
                    hr_utility.set_location('Next ET: ' || next_et, 82);
                 end if;
              end loop;
--
              hr_utility.set_location('Entry Path: ' || curr_epath, 100);
--
              if (curr_epath is null) then
                 curr_epath := curr_et || '[' || to_char(recursive_level) || ']';
              else
                 curr_epath := curr_epath || '[' || to_char(recursive_level) || ']';
              end if;

              if ((last_element = 1) and (curr_et <> next_et)) then
                 curr_epath := curr_epath || '.' || next_et;
              end if;
              hr_utility.set_location('Entry Path: ' || curr_epath, 200);
--
           else
              hr_utility.set_location('If Not Same Element Type: ' || curr_et || ' ' || next_et, 60);
              recursive_level := 1;
--
              hr_utility.set_location('Entry Path: ' || curr_epath, 300);
--
              if (curr_epath is null) then
                 curr_epath := curr_et || '.' || next_et;
              else
                 curr_epath := curr_epath || '.' || next_et;
              end if;

              curr_et := next_et;
              if (next_pos <> 0) then
                 curr_pos := next_pos;
                 counter := counter + 1;
                 next_pos := instr(p_entry_process_path, '.', 1, counter);
              else
                 last_element := 1;
              end if;
--
              hr_utility.set_location('Entry Path: ' || curr_epath, 400);
--
           end if;
        end loop;
        l_entry_path := curr_epath;
      end if;
      end if;
   end if;
--
   return l_entry_path;
--
end get_entry_path;
--
function get_entry_path( p_run_result_id in number)
return varchar2
is
l_entry_process_path pay_run_results.entry_process_path%type;
l_source_type        pay_run_results.source_type%type;
l_element_type_id    pay_run_results.element_type_id%type;
begin
--
    select entry_process_path,
           source_type,
           element_type_id
      into l_entry_process_path,
           l_source_type,
           l_element_type_id
      from pay_run_results
     where run_result_id = p_run_result_id;
--
    return get_entry_path(p_entry_process_path => l_entry_process_path,
                          p_source_type        => l_source_type,
                          p_element_type_id    => l_element_type_id,
                          p_run_result_id      => null);
end get_entry_path;
--
/*
    get_retro_asg_id
  Description
     This function is used by the retropay process to
     find get a retro assignment to be processed by an assignment action
*/
function get_retro_asg_id(p_assignment_action in number)
return number
is
l_ret_asg number;
begin
--
    select retro_assignment_id
      into l_ret_asg
      from pay_retro_assignments
     where retro_assignment_action_id = p_assignment_action
       and rownum = 1;
--
    return l_ret_asg;
--
exception
    when no_data_found then
        return null;
--
end get_retro_asg_id;
--
procedure overlap_adjustments(p_asg_act_id    in number,
                              p_definition_id in number,
                              p_component_id  in number,
                              p_ele_set_id    in number
                             )
is
cursor get_overlaps (p_asg_act_id    in number,
                     p_definition_id in number,
                     p_component_id  in number,
                     p_ele_set_id    in number
                    )
is
   SELECT /*+ INDEX(piv pay_input_values_f_pk)
              INDEX(pet pay_element_types_f_pk)
              USE_NL(piv pet) */
          pee.element_entry_id,
          pee.source_start_date,
          pee.source_end_date,
          piv1.input_value_id,
          peev.screen_entry_value,
          piv.mandatory_flag,
          pet1.element_type_id,
          pepd.source_entry_id,
          pepd.run_result_id,
          pepd.tax_unit_id,
          pepd.time_definition_id,
          pee.source_run_type,
          pee.assignment_id
     FROM pay_element_entries_f       pee,
          pay_input_values_f          piv,
          pay_element_entry_values_f  peev,
          pay_element_types_f         pet,
          pay_element_types_f         pet1,
          pay_input_values_f          piv1,
          pay_entry_process_details   pepd,
          pay_retro_components        prc,
          pay_retro_defn_components   prdc2,
          pay_retro_defn_components   prdc
    WHERE pet1.element_type_id = pepd.source_element_type_id
      and piv1.element_type_id = pet1.element_type_id
      and pepd.source_asg_action_id = p_asg_act_id
      AND pee.element_entry_id = peev.element_entry_id
      AND peev.input_value_id = piv.input_value_id
      AND piv.name = piv1.NAME
      AND piv.uom NOT IN ('D','T','C')
      AND pee.element_type_id = pet.element_type_id
      AND pee.effective_end_date between peev.effective_start_date AND
                 peev.effective_end_date
      AND pee.effective_end_date between piv.effective_start_date AND
                  piv.effective_end_date
      AND pee.effective_end_date between pet.effective_start_date AND
                 pet.effective_end_date
      AND pee.effective_end_date between pet1.effective_start_date AND
                 pet1.effective_end_date
      AND pee.effective_end_date between piv1.effective_start_date AND
                 piv1.effective_end_date
      AND pepd.element_entry_id = pee.element_entry_id
      AND pepd.retro_component_id = prc.retro_component_id (+)
      AND prc.retro_component_id = prdc.retro_component_id (+)
      AND prdc.retro_definition_id (+) = p_definition_id
      AND prdc2.retro_component_id (+) = p_component_id
      AND prdc2.retro_definition_id (+) = p_definition_id
      AND nvl(prdc.priority, 99)  <= nvl(prdc2.priority, 99)
      AND ( prc.recalculation_style is null
            OR
            ( prc.recalculation_style <> 'R'
              OR
              /* Replacement overlap entries, bring back all PR OR
               * fetch NR with no matching PR, i.e. deleted entries.
               */
              ( prc.recalculation_style = 'R'
                AND
                ( (pee.creator_type = 'PR'
                   AND pay_retro_pkg.latest_replace_ovl_ee (pee.element_entry_id) = 'Y'
                  )
                  OR
                  (pee.creator_type = 'NR'
                   AND pay_retro_pkg.latest_replace_ovl_del_ee (pee.element_entry_id) = 'Y'
                  )
                )
              )
            )
          )
      AND (   p_ele_set_id = 0
              or (p_ele_set_id <> 0
                  and  EXISTS
                  (
                  SELECT NULL
                  FROM   pay_ele_classification_rules  ECR
                  WHERE  ECR.element_set_id          =  p_ele_set_id
                  AND    pet1.classification_id        =  ECR.classification_id
                  AND NOT EXISTS
                         (
                          SELECT NULL
                          FROM   pay_element_type_rules    ETR
                          WHERE  ETR.element_set_id      = p_ele_set_id
                          AND    ETR.element_type_id     = pet1.element_type_id
                          AND    ETR.include_or_exclude  = 'E'
                         )
                  UNION
                  SELECT NULL
                  FROM   pay_element_type_rules     ETR
                  WHERE  ETR.element_set_id       = p_ele_set_id
                  AND    ETR.element_type_id      = pet1.element_type_id
                  AND    ETR.include_or_exclude   = 'I'
                 )
                )
        )
    ORDER by pepd.tax_unit_id,
             pee.source_run_type,
             pee.element_entry_id,
             piv.input_value_id;

----
    cursor get_proc_retro_rrv IS                         -- Added for 7335351
      SELECT /*+ INDEX(piv pay_input_values_f_pk)
              INDEX(pet pay_element_types_f_pk)
              USE_NL(piv pet) */
          pee.element_entry_id,
          pee.source_start_date,
          pee.source_end_date,
          piv1.input_value_id,
          peev.screen_entry_value,
          pet1.element_type_id,
          pet.element_type_id       retro_element_type_id,      /* Bug 9405939 */
          piv.input_value_id        retro_ip_value_id,          /* Bug 9405939 */
          pepd.source_entry_id,
          pepd.run_result_id,
          pepd.tax_unit_id,
          pepd.time_definition_id,
          pee.source_run_type,
          pee.assignment_id
     FROM pay_element_entries_f       pee,
          pay_input_values_f          piv,
          pay_element_entry_values_f  peev,
          pay_element_types_f         pet,
          pay_element_types_f         pet1,
          pay_input_values_f          piv1,
          pay_run_results             prr,
          pay_entry_process_details   pepd,
          pay_assignment_actions      paa,
          pay_payroll_actions         ppa,
          pay_retro_components        prc,
          pay_retro_defn_components   prdc2,
          pay_retro_defn_components   prdc
    where paa.assignment_action_id = p_asg_act_id
      and paa.payroll_action_id = ppa.payroll_action_id
      and paa.assignment_id = pee.assignment_id
      and ppa.date_earned between pee.effective_start_date and pee.effective_end_date
      and pee.element_entry_id = pepd.element_entry_id
      and pet1.element_type_id = pepd.source_element_type_id
      and piv1.element_type_id = pet1.element_type_id
      AND pee.element_entry_id = peev.element_entry_id
      AND peev.input_value_id = piv.input_value_id
      AND piv.name = piv1.NAME
      AND piv.uom NOT IN ('D','T','C')
      AND pee.element_type_id = pet.element_type_id
      and prr.element_type_id = pee.element_type_id
      and prr.source_id = pee.element_entry_id
      AND pee.effective_end_date between peev.effective_start_date AND
                 peev.effective_end_date
      AND pee.effective_end_date between piv.effective_start_date AND
                  piv.effective_end_date
      AND pee.effective_end_date between pet.effective_start_date AND
                 pet.effective_end_date
      AND pee.effective_end_date between pet1.effective_start_date AND
                 pet1.effective_end_date
      AND pee.effective_end_date between piv1.effective_start_date AND
                 piv1.effective_end_date
      AND pepd.retro_component_id = prc.retro_component_id (+)
      AND prc.retro_component_id = prdc.retro_component_id (+)
      AND prdc.retro_definition_id (+) = p_definition_id
      AND prdc2.retro_component_id (+) = p_component_id
      AND prdc2.retro_definition_id (+) = p_definition_id
      AND nvl(prdc.priority, 99)  <= nvl(prdc2.priority, 99);
--
l_pactid                pay_payroll_actions.payroll_action_id%type;
l_business_group_id     pay_payroll_actions.business_group_id%type;
l_consolidation_set_id  pay_payroll_actions.consolidation_set_id%type;
l_payroll_id            pay_payroll_actions.payroll_id%type;
l_effective_date        pay_payroll_actions.effective_date%type;
l_date_earned           pay_payroll_actions.date_earned%type;
l_time_period_id        pay_payroll_actions.time_period_id%type;
legcode                 per_business_groups.legislation_code%type;
l_jc_name               varchar2(40);
l_rule_mode             varchar2(40);
l_status                varchar2(40);
l_rr_sparse_jc          boolean;
l_rr_sparse             boolean;
l_found                 boolean;
l_ee_id                 number;
l_run_type              number;
l_tax_unit_id           number;
l_asg_act_id            number;
l_rr_id                 number;
l_screen_entry_value    pay_element_entry_values_f.screen_entry_value%TYPE;
--
begin
   hr_utility.set_location('pay_retro_pkg.overlap_adjustments ',10);
   select pay_payroll_actions_s.nextval,
          ppa.business_group_id,
          ppa.consolidation_set_id,
          ppa.payroll_id,
          ppa.effective_date,
          ppa.date_earned,
          ppa.time_period_id,
          pbg.legislation_code
     into l_pactid,
          l_business_group_id,
          l_consolidation_set_id,
          l_payroll_id,
          l_effective_date,
          l_date_earned,
          l_time_period_id,
          legcode
     from pay_payroll_actions ppa,
          pay_assignment_actions paa,
          per_business_groups    pbg
    where ppa.payroll_action_id = paa.payroll_action_id
      and pbg.business_group_id = ppa.business_group_id
      and paa.assignment_action_id = p_asg_act_id;
--
   insert into pay_payroll_actions(
            payroll_action_id,
            action_type,
            business_group_id,
            consolidation_set_id,
            payroll_id,
            action_population_status,
            action_status,
            effective_date,
            date_earned,
            time_period_id,
            object_version_number)
    values (
            l_pactid,
            'B',
            l_business_group_id,
            l_consolidation_set_id,
            l_payroll_id,
            'C',
            'C',
            l_effective_date,
            l_date_earned,
            l_time_period_id,
            1);
--
      -- calc jur code name
        pay_core_utils.get_leg_context_iv_name
                      ('JURISDICTION_CODE',
                       legcode,
                       l_jc_name,
                       l_found);

        if (l_found = FALSE) then
          l_jc_name := 'Jurisdiction';
        end if;


        -- set rr sparse leg_rule
        pay_core_utils.get_legislation_rule('RR_SPARSE',
                                            legcode,
                                            l_rule_mode,
                                            l_found
                                           );
        if (l_found = FALSE) then
          l_rule_mode := 'N';
        end if;

        if upper(l_rule_mode)='Y'
        then
           -- Confirm Enabling Upgrade has been made by customer
           pay_core_utils.get_upgrade_status(l_business_group_id,
                                    'ENABLE_RR_SPARSE',
                                    l_status);

           if upper(l_status)='N'
           then
              l_rule_mode := 'N';
           end if;
        end if;

        if upper(l_rule_mode)='Y'
        then
         l_rr_sparse:=TRUE;
        else
         l_rr_sparse :=FALSE;
        end if;
--
       pay_core_utils.get_upgrade_status(l_business_group_id,
                                    'RR_SPARSE_JC',
                                    l_status);
--
        if upper(l_status)='Y'
        then
         l_rr_sparse_jc :=TRUE;
        else
         l_rr_sparse_jc :=FALSE;
        end if;


--
   hr_utility.set_location('pay_retro_pkg.overlap_adjustments ',20);
   l_ee_id := -1;
   l_run_type := -1;
   l_tax_unit_id := -1;
   l_asg_act_id := -1;

  for eerec in get_overlaps(p_asg_act_id,
                             p_definition_id,
                             p_component_id,
                             p_ele_set_id
                            ) loop
       if (   l_run_type <> eerec.source_run_type
           or l_tax_unit_id <> eerec.tax_unit_id) then
--
          if (l_asg_act_id <> -1) then
             pay_balance_pkg.maintain_balances_for_action(l_asg_act_id);
             -- Bug 8614449 : create a new payroll action
             select pay_payroll_actions_s.nextval
             into l_pactid
             from dual;
--
             insert into pay_payroll_actions(
               payroll_action_id,
               action_type,
               business_group_id,
               consolidation_set_id,
               payroll_id,
               action_population_status,
               action_status,
               effective_date,
               date_earned,
               time_period_id,
               object_version_number)
             values (
               l_pactid,
               'B',
               l_business_group_id,
               l_consolidation_set_id,
               l_payroll_id,
               'C',
               'C',
               l_effective_date,
               l_date_earned,
               l_time_period_id,
               1);
--
          end if;
--
          l_asg_act_id := hrassact.inassact_main
               (
                  pactid            => l_pactid,
                  asgid             => eerec.assignment_id,
                  taxunt            => eerec.tax_unit_id,
                  p_run_type_id     => eerec.source_run_type,
                  p_mode            => 'BACKPAY'
               );
--
          l_run_type := eerec.source_run_type;
          l_tax_unit_id := eerec.tax_unit_id;
--
       end if;
       if (l_ee_id <> eerec.element_entry_id) then
--
           l_rr_id := pay_run_result_pkg.create_run_result_direct
                         (p_element_type_id      => eerec.element_type_id,
                          p_assignment_action_id => l_asg_act_id,
                          p_entry_type           => 'B',
                          p_source_id            => eerec.source_entry_id,
                          p_source_type          => 'E',
                          p_status               => 'P',
                          p_local_unit_id        => null,
                          p_start_date           => eerec.source_start_date,
                          p_end_date             => eerec.source_end_date,
                          p_element_entry_id     => eerec.source_entry_id,
                          p_time_def_id          => eerec.time_definition_id
                         );
           l_ee_id := eerec.element_entry_id;
--
       end if;

       pay_run_result_pkg.maintain_rr_value(p_run_result_id        => l_rr_id,
                         p_session_date         => l_effective_date,
                         p_input_value_id       => eerec.input_value_id,
                         p_value                => eerec.screen_entry_value,
                         p_formula_result_flag  => 'N',
                         p_jc_name              =>  l_jc_name,
                         p_rr_sparse            =>  l_rr_sparse,
                         p_rr_sparse_jc         =>  l_rr_sparse_jc,
                         p_mode                 =>  null
                        );
--
   end loop;
--
   hr_utility.set_location('pay_retro_pkg.overlap_adjustments ',30);
/* Bug 8614449 */
   if (l_asg_act_id <> -1) then
      pay_balance_pkg.maintain_balances_for_action(l_asg_act_id);

      select pay_payroll_actions_s.nextval
      into l_pactid
      from dual;

      insert into pay_payroll_actions(
               payroll_action_id,
               action_type,
               business_group_id,
               consolidation_set_id,
               payroll_id,
               action_population_status,
               action_status,
               effective_date,
               date_earned,
               time_period_id,
               object_version_number)
       values (
               l_pactid,
               'B',
               l_business_group_id,
               l_consolidation_set_id,
               l_payroll_id,
               'C',
               'C',
               l_effective_date,
               l_date_earned,
               l_time_period_id,
               1);
   end if;

   l_ee_id := -1;
   l_run_type := -1;
   l_tax_unit_id := -1;
   l_asg_act_id := -1;
--
/* Added for 7335351. Check if the period of balance adjustment already has run results of retro entries, those entries would already
have been added to the balance values during the balance adjustments of the previous(source) periods. To maintain the consistency
in balance values, create run_results of type 'B' with negative values of such retro run result values.
*/
   for eerec in get_proc_retro_rrv
   loop
       if (   l_run_type <> eerec.source_run_type
           or l_tax_unit_id <> eerec.tax_unit_id) then
--
          if (l_asg_act_id <> -1) then
             pay_balance_pkg.maintain_balances_for_action(l_asg_act_id);
             -- Bug 8614449 : create a new payroll action
             select pay_payroll_actions_s.nextval
             into l_pactid
             from dual;
--
             insert into pay_payroll_actions(
               payroll_action_id,
               action_type,
               business_group_id,
               consolidation_set_id,
               payroll_id,
               action_population_status,
               action_status,
               effective_date,
               date_earned,
               time_period_id,
               object_version_number)
             values (
               l_pactid,
               'B',
               l_business_group_id,
               l_consolidation_set_id,
               l_payroll_id,
               'C',
               'C',
               l_effective_date,
               l_date_earned,
               l_time_period_id,
               1);
--
          end if;
--
          l_asg_act_id := hrassact.inassact_main
               (
                  pactid            => l_pactid,
                  asgid             => eerec.assignment_id,
                  taxunt            => eerec.tax_unit_id,
                  p_run_type_id     => eerec.source_run_type,
                  p_mode            => 'BACKPAY'
               );
--
          l_run_type := eerec.source_run_type;
          l_tax_unit_id := eerec.tax_unit_id;
--
       end if;
       if (l_ee_id <> eerec.element_entry_id) then

/*Bug 9405939 Using  eerec.retro_element_type_id in place of eerec.element_type_id */

--
           l_rr_id := pay_run_result_pkg.create_run_result_direct
                         (p_element_type_id      => eerec.retro_element_type_id,
                          p_assignment_action_id => l_asg_act_id,
                          p_entry_type           => 'B',
                          p_source_id            => eerec.source_entry_id,
                          p_source_type          => 'E',
                          p_status               => 'P',
                          p_local_unit_id        => null,
                          p_start_date           => eerec.source_start_date,
                          p_end_date             => eerec.source_end_date,
                          p_element_entry_id     => eerec.source_entry_id,
                          p_time_def_id          => eerec.time_definition_id
                         );
           l_ee_id := eerec.element_entry_id;
--
       end if;

         l_screen_entry_value := -fnd_number.canonical_to_number(eerec.screen_entry_value);

/*Bug 9405939 Using  eerec.retro_ip_value_id in place of eerec.input_value_id */

	 pay_run_result_pkg.maintain_rr_value(p_run_result_id        => l_rr_id,
                         p_session_date         => l_effective_date,
                         p_input_value_id       => eerec.retro_ip_value_id,
                         p_value                => fnd_number.number_to_canonical(l_screen_entry_value),
                         p_formula_result_flag  => 'N',
                         p_jc_name              =>  l_jc_name,
                         p_rr_sparse            =>  l_rr_sparse,
                         p_rr_sparse_jc         =>  l_rr_sparse_jc,
                         p_mode                 =>  null
                        );
 --
   end loop;
--
   if (l_asg_act_id <> -1) then
      pay_balance_pkg.maintain_balances_for_action(l_asg_act_id);
   end if;
   hr_utility.set_location('pay_retro_pkg.overlap_adjustments ',40);
--
end overlap_adjustments;
--
-- Note in process_recorded_date, we're using the serial_number column to
-- store the recalculation date used for the assignment in the retropay run.
-- Modified for bugs 7248998, 7335351
function process_recorded_date (p_process in varchar2,
                                p_assignment_id in varchar2,
                                p_adj_start_date in date,
                                p_assact_id in number)
return date
is
l_rec_date date;
v_recorded_date date;
l_date date;
l_min_retro_asg_date date;
begin
   hr_utility.set_location('process_recorded_date', 10);

-- p_adj_start_date is the earliest overlap_start_date for the assignment in this retropay run
   hr_utility.trace('p_adj_start_date : '|| p_adj_start_date);

-- Get the recorded_date for 'RETRO_OVERLAP' attribute for the assignment
   pay_recorded_requests_pkg.get_recorded_date_no_ins( p_process,
                                                       l_rec_date,
                                                       p_assignment_id);
   --
   hr_utility.trace('l_rec_date : '|| l_rec_date);
--
/*
   If retropay is being run for the first time since enabling RETRO_OVERLAP functionality or
   if the earliest overlapping_start_date is less than the recorded_date, then do full recalculations
   from the earliest overlapping_start_date.
   Otherwise, Balance Adjustments will be used till the reprocess_date and recalculations can be done from the reprocess_date.
   v_recorded_date is the date from which full recalculations are done. This is stored in serial_number column of
   pay_assignment_actions and can be queried after the retropay run to verify the recalculation_date used by the process.
*/
   if (l_rec_date = hr_api.g_sot OR
       p_adj_start_date < l_rec_date) THEN
   --
   hr_utility.set_location('process_recorded_date', 20);

      v_recorded_date := p_adj_start_date;
--
      pay_recorded_requests_pkg.set_recorded_date(
                 p_process            => p_process,
                 p_recorded_date      => p_adj_start_date,
                 p_recorded_date_o    => l_date,
                 p_attribute1         => p_assignment_id);

    -- bug 8407213. If the recorded_date is being updated to a new value, log the previous recorded_date in lable_identifier column
    -- of pay_assignment_actions.This value is then used for setting the recorded_date to the correct value during rollback of
    -- the retropay process.

     -- bug 8790029 removed if condition

       update pay_assignment_actions
       set label_identifier = fnd_date.date_to_canonical(l_date)
       where assignment_action_id = p_assact_id;
--
   else
   --
   hr_utility.set_location('process_recorded_date', 30);

   -- Get the reprocess_date of the assignment for this retropay run.

       begin
       select reprocess_date into l_min_retro_asg_date
       from pay_retro_assignments
       where assignment_id =p_assignment_id
       and retro_assignment_action_id = p_assact_id;

       exception
       when others
       then null;
       end;

   hr_utility.trace('l_min_retro_asg_date : '|| l_min_retro_asg_date);

      v_recorded_date := l_min_retro_asg_date;
   --
   end if;
   --
   -- bug 8407213. Append the recalculation_date to the serial_number column of pay_assignment_actions. The difference in the
   -- overlap_date and recalculation_date will give an indication of the number of periods for which balance adjustmnets were
   -- done in place of complete retro reprocessing.
   --
   update pay_assignment_actions
   set serial_number = serial_number || 'rcl=' || substr(fnd_date.date_to_canonical(v_recorded_date),1,11)
   where assignment_action_id = p_assact_id;
   --
   hr_utility.set_location('process_recorded_date', 40);
   --
   return v_recorded_date;
--
end process_recorded_date;
--
--
procedure reset_recorded_request(p_assact_id in number) is
--
l_prev_rec_date date := null;
l_assign_id number;

begin
--
  hr_utility.set_location('reset_recorded_request', 10);
--
  hr_utility.trace('p_assact_id : '|| p_assact_id);

  -- bug 8407213. Fetch the previous recorded_date from label_identifier column of pay_assignment_actions during rollback.

select to_date(substr(label_identifier, 1,11), 'YYYY/MM/DD'), assignment_id
    into l_prev_rec_date, l_assign_id
    from pay_assignment_actions
   where assignment_action_id = p_assact_id;

--
  hr_utility.set_location('reset_recorded_request', 20);
  --

hr_utility.trace('l_assign_id : '|| l_assign_id);
hr_utility.trace('l_prev_rec_date : '|| l_prev_rec_date);

  /* Added to_char for l_assign_id in the following
  two queries for fixing Bug:6893208 */
  /* Bug 8790029
  Case : Label_identifier in pay_assignment_actions was populated in process_recorded_date only when we are changing the recorded_date
         and recorded_date is not equal to start of time (hr_api.g_sot)  .
         If the Overlap date comes after recorded_date label_identifier was not populated .

         After enabling retro_overlap ,Whenever retropay is rolled back , row from pay_recorded_requests for Retro_Overlap
         was getting deleted .This was because label_identifier in pay_assignment_actions was populated as null for Retro assignment action.

         This issue causes retro to run payrolls from overlap start date as there is no record in pay_recorded_requests for RETRO_OVERLAP.

  Fix  : Modified pay_recorded_requests and removed the check  "if (l_date <> hr_api.g_sot)" before updating label_identifier
         Start of time will get populated the first time reropay is run after Retro_Overlap feature is enabled

          Modified reset_recorded_request ,delete the 'RETRO_OVERLAP' row from pay_recorded_requests only when
          label_identifier is equal to start of time .
          If above is not the case  update recorded_date only when label_identifier is not null .
  */

  if (l_prev_rec_date = hr_api.g_sot)
  then
    delete from pay_recorded_requests
     where ATTRIBUTE_CATEGORY = 'RETRO_OVERLAP'
      and ATTRIBUTE1 =to_char(l_assign_id);
  elsif l_prev_rec_date is not null then
    update pay_recorded_requests
    set RECORDED_DATE = l_prev_rec_date
     where ATTRIBUTE_CATEGORY = 'RETRO_OVERLAP'
       and ATTRIBUTE1 = to_char(l_assign_id);
--
  end if;
  hr_utility.set_location('reset_recorded_request', 30);
--
end reset_recorded_request;
--
end pay_retro_pkg;

/
