--------------------------------------------------------
--  DDL for Package Body PER_ASSIGNMENTS_F3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASSIGNMENTS_F3_PKG" AS
/* $Header: peasg01t.pkb 120.29.12010000.8 2009/12/08 12:33:48 brsinha ship $ */
-----------------------------------------------------------------------------
--
g_package  varchar2(24) := 'PER_ASSIGNMENTS_F3_PKG.';
g_debug    boolean; -- debug flag
--
procedure process_end_status(
   p_ass_id number,
   p_sess_date date,
   p_eff_end_date date,
   p_eot    date) is
--
-- If the status is changed to 'END' then if there are any future
-- changes then disallow the update.
---
begin
    hr_utility.set_location('Entering: '|| 'PER_ASSIGNMENTS_F3_PKG.process_end_status', 5);
   if p_eff_end_date < p_eot then
      fnd_message.set_name('PAY', 'HR_6071_APP_ASS_INVALID_END');
      fnd_message.raise_error;
   end if;
   --
   -- Now check delete referential integrity as it will cause date
   -- effective delete.
   --
   hr_assignment.del_ref_int_check(p_ass_id, 'END', p_sess_date);
   --
    hr_utility.set_location('Leaving: '|| 'PER_ASSIGNMENTS_F3_PKG.process_end_status', 5);
end process_end_status;
---------------------------------------------------------------------------
procedure process_term_status(
   p_ass_id number,
   p_sess_date date) is
   l_dummy     number;
--
-- If the status is changed to 'TERM' then if there are any future
-- other than TERM_ASSIGNs changes then disallow the update.
--
   cursor term_assign is
      select   1
      from  per_assignments_f a
      where a.assignment_id      = P_ASS_ID
      and   a.effective_start_date  > P_SESS_DATE
      and   exists (select null
            from  per_assignment_status_types s
            where s.assignment_status_type_id =
                  a.assignment_status_type_id
            and   s.per_system_status <> 'TERM_ASSIGN');
begin
    hr_utility.set_location('Entering: '|| 'PER_ASSIGNMENTS_F3_PKG.process_term_status' , 5);
   open term_assign;
   fetch term_assign into l_dummy;
   if term_assign%found then
      fnd_message.set_name('PAY', 'HR_6387_EMP_ASS_INVALID_TERM');
      close term_assign;
      fnd_message.raise_error;
   end if;
   close term_assign;
end process_term_status;
-----------------------------------------------------------------------------
procedure validate_primary_flag(
   p_val_st_date  date,
   p_pd_os_id  number,
   p_ass_id number) is
--
-- A Primary Assignment must run until NVL(FINAL_PROCESS_DATE,END_OF_TIME)
-- for the Period of Service. If it is terminated the termination must be
-- as a result of termination of the Employees Period of Service i.e. the
-- first termination date is on the Actual Termination Date.
--
-- HR_ASSIGNMENT.CHECK_ASS_FOR_PRIMARY performs these checks on an
-- assignment that has had its PRIMARY FLAG set to 'Yes'
--
begin
    hr_utility.set_location('Entering: '|| 'PER_ASSIGNMENTS_F3_PKG.validate_primary_flag.' , 5);
   hr_assignment.check_ass_for_primary(
      p_pd_os_id,
      p_ass_id,
      p_val_st_date);
end validate_primary_flag;
----------------------------------------------------------------------------
procedure test_for_cancel_term(
   p_ass_id    number,
   p_val_start_date  date,
   p_val_end_date    date,
   p_mode         varchar2,
   p_per_sys_st      varchar2,
   p_s_per_sys_st    varchar2,
   p_cancel_atd      IN OUT NOCOPY date,
   p_cancel_lspd     IN OUT NOCOPY date,
   p_reterm_atd      IN OUT NOCOPY date,
   p_reterm_lspd     IN OUT NOCOPY date) is
--
--  Run the check to see whether this update operation will result
--  in a TERM_STATUS being removed or superceded by an earlier one.
--  This also checks to see whether the operation will cause a new
--  "leading TERM_ASSIGN" to be implicitly created (i.e. a row in the
--  future becomes the "leading TERM_ASSIGN").
--
begin
    hr_utility.set_location('Entering: '|| 'PER_ASSIGNMENTS_F3_PKG.test_for_cancel_term' , 5);
   hr_assignment.test_for_cancel_reterm(
      p_ass_id,
      p_val_start_date,
      p_val_end_date,
      p_mode,
      p_per_sys_st,
      p_s_per_sys_st,
      p_cancel_atd,
      p_cancel_lspd,
      p_reterm_atd,
      p_reterm_lspd);
   --
end test_for_cancel_term;
-----------------------------------------------------------------------------
procedure check_future_primary(
   p_dt_mode      varchar2,
   p_val_start_date  date,
   p_prim_flag    varchar2,
   p_eff_start_date  date,
   p_s_prim_flag     varchar2,
   p_prim_change_flag   IN OUT NOCOPY varchar2,
   p_new_prim_flag      IN OUT NOCOPY varchar2,
   p_ass_id    number,
   p_eff_end_date    date,
   p_pd_os_id     number,
   p_show_cand_prim_assgts IN OUT NOCOPY varchar2,
   p_prim_date_from  IN OUT NOCOPY date,
   p_new_prim_ass_id IN OUT NOCOPY varchar2) is
   l_prim_flag    varchar2(1);
   l_start_date      date;
--
--  When an operation such as UPDATE_OVERRIDE,DELETE_NEXT_CHANGE,
--  FUTURE_CHANGE or ZAP is performed it may remove future changes to
--  the primary assignment flag.
--
--  In order to cater for this a check is done to see whether there will
--  be a change of primary flag at any point in time. N.B. This may be from
--  primary to non-primary or vice versa.
--
--  HR_ASSIGNMENT.CHECK_FUTURE_PRIMARY returns an indicator PRIMARY_CHANGE_FLAG
--  to show whether a change will be made. C_NEW_PRIMARY_FLAG is the value
--  the current record will have after the operation and
--  C_PRIMARY_DATE_FROM is the date on which changes to other assignment
--  records must be catered for in order to maintain the rule that there
--  may be one and only one primary assignment at any point in time during
--  the lifetime of a Period of Service.
--
--  If the PRIMARY_CHANGE_FLAG is 'N' or if the C_NEW_PRIMARY_FLAG is 'Y'
--  then a new primary assignment record is not required. Otherwise another
--  assignmnet must be chosen to become the new primary assignment with
--  effect from C_PRIMARY_DATE_FROM.
--
--  HR_ASSIGNMENT.GET_NEW_PRIMARY_ASSIGNMENT determines whether there is a
--  single candidate assignment in which case the ID is returned in the
--  variable C_NEW_PRIMARY_ASS_ID. Otherwise an indicator is returned that
--  results in a QuickPick List of Candidate Assignments being displayed.
--
--  P_SHOW_CAND_PRIM_ASSGTS is returned as Y if a list of values needs to be
--  shown on the client to select from a list of primary candidate
--  assignments.
--
begin
hr_utility.set_location('per_assignments_f3_pkg.check_future_primary',1);
   p_show_cand_prim_assgts := null;
   if p_dt_mode = 'UPDATE_OVERRIDE' then
      l_start_date := p_val_start_date;
      l_prim_flag := p_prim_flag;
   else
      l_start_date := p_eff_start_date;
      l_prim_flag := p_s_prim_flag;
   end if;
   --
   -- Note last 3 parameters return values from server-side procedure.
   -- The last is OUT only so no need to get p_prim_date_from, we will
   -- only write to the item.
   --
hr_utility.set_location('per_assignments_f3_pkg.check_future_primary',2);
   hr_assignment.check_future_primary(
      p_ass_id,
      l_start_date,
      p_eff_end_date,
      p_dt_mode,
      l_prim_flag,
      p_prim_change_flag,
      p_new_prim_flag,
      p_prim_date_from);
   --
hr_utility.trace('Primary Effective From '||
         to_char(p_prim_date_from,'DD-MON-YYYY'));
--
   if p_prim_change_flag = 'N' or p_new_prim_flag = 'Y' then
      return;
   end if;
   --
   -- As above, last parameter is OUT only - it's actually a varchar2
   -- returning a number value!
   --
hr_utility.set_location('per_assignments_f3_pkg.check_future_primary',3);
   hr_assignment.get_new_primary_assignment(
      p_ass_id,
      p_pd_os_id,
      l_start_date,
      p_new_prim_ass_id);
   --
hr_utility.trace('New Primary is '||p_new_prim_ass_id);
--
   if hr_utility.check_warning then
      p_show_cand_prim_assgts := 'Y';
   end if;
   --
end check_future_primary;
-----------------------------------------------------------------------------
procedure pre_update_bundle2(
        p_upd_mode      varchar2,
        p_del_mode      varchar2,
         p_sess_date    date,
        p_per_sys_st    varchar2,
        p_val_st_date      date,
         p_new_end_date    date,
        p_val_end_date     date,
        p_ass_id     number,
        p_pay_id     number,
   p_eot       date,
   p_eff_end_date    date,
   p_prim_flag    varchar2,
   p_new_prim_flag      IN OUT NOCOPY varchar2,
   p_pd_os_id     number,
   p_s_per_sys_st    varchar2,
   p_ass_number      varchar2,
   p_s_ass_number    varchar2,
   p_row_id    varchar2,
   p_s_prim_flag     varchar2,
   p_bg_id        number,
   p_eff_st_date     date,
   p_grd_id    number,
   p_sp_ceil_st_id      number,
        p_ceil_seq      number,
   p_re_entry_point  IN OUT NOCOPY number,
   p_returned_warning   IN OUT NOCOPY varchar2,
   p_prim_change_flag   IN OUT NOCOPY varchar2,
   p_prim_date_from  IN OUT NOCOPY date,
   p_new_prim_ass_id IN OUT NOCOPY varchar2,
   p_cancel_atd      IN OUT NOCOPY date,
      p_cancel_lspd     IN OUT NOCOPY date,
      p_reterm_atd      IN OUT NOCOPY date,
      p_reterm_lspd     IN OUT NOCOPY date,
   p_copy_y_to_prim_ch  IN OUT NOCOPY varchar2,
   p_pay_basis_id number,  --fix for bug 4764140
   p_ins_new_sal_flag	varchar2	-- fix for bug 9109727
   ) is
   l_re_entry_point  number;
   l_warning      varchar2(80);
   l_new_end_date    date;
   l_show_cand_prim_assgts varchar2(1);
begin
    hr_utility.set_location('Entering: '|| 'PER_ASSIGNMENTS_F3_PKG.pre_update_bundle2' , 5);
   --
   -- NB RE_ENTRY_POINT_1 is no longer used but kept in so that
   -- RE_ENTRY_POINT_2 will behave in the same way.
   --
   if p_re_entry_point = 1 then
      goto RE_ENTRY_POINT_1;
   elsif p_re_entry_point = 2 then
      goto RE_ENTRY_POINT_2;
   end if;
   --
   -- Validate the Payroll exists for the lifetime of the Assignment
   -- and that no assignment actions are orphaned by a change in Payroll.
   --
   -- The payroll_change_validate procedure is already called above for
   -- 'UPDATE_OVERRIDE' so we do not need to recall it here.
   --
   if p_upd_mode <> 'UPDATE_OVERRIDE' then
      --
      -- Do payroll_change_validate.
      --
      l_re_entry_point := 2;
      l_new_end_date := p_new_end_date;
      --
      update_and_delete_bundle(
         p_upd_mode,
         p_val_st_date,
         p_eff_st_date,
         p_eff_end_date,
         p_pd_os_id,
         p_per_sys_st,
         p_ass_id,
         p_val_end_date,
         p_upd_mode,
         p_del_mode,
         p_sess_date,
         p_pay_id,
         p_grd_id,
         p_sp_ceil_st_id,
         p_ceil_seq,
         l_new_end_date,
         l_warning,
         l_re_entry_point,
         'Y',
         p_pay_basis_id,	 --fix for bug 4764140.
	 p_ins_new_sal_flag);			-- fix for bug 9109727
      --
      -- Value of l_new_end_date will not be changed by
      -- update_and_delete_bundle because we are only executing
      -- entry point 2 of the code, not the bit which sets the
      -- l_new_end_date value.
      --
   end if;
   --
<<RE_ENTRY_POINT_1>>
   --
    hr_utility.set_location('PER_ASSIGNMENTS_F3_PKG.pre_update_bundle2' , 10);
   if p_per_sys_st = 'END' then
      process_end_status(
         p_ass_id,
                        p_sess_date,
                        p_eot,
         p_eff_end_date);
   elsif p_per_sys_st = 'TERM_ASSIGN' then
      process_term_status(
         p_ass_id,
                        p_sess_date);
   end if;
   --
   -- If the primary flag has changed then flag a PRIMARY_CHANGE
   -- otherwise if an UPDATE_OVERRIDE that could potentially remove a
   -- change in primary flag is to be performed then check whether update
   -- of other primary flags is necessary.
   --
   p_copy_y_to_prim_ch := null;
   --
    hr_utility.set_location('PER_ASSIGNMENTS_F3_PKG.pre_update_bundle2' , 20);
   if p_s_prim_flag = p_prim_flag then
      if p_upd_mode = 'UPDATE_OVERRIDE' then
         check_future_primary(
            p_upd_mode,
               p_val_st_date,
                  p_prim_flag,
               p_eff_st_date,
                  p_s_prim_flag,
               p_prim_change_flag,
               p_new_prim_flag,
               p_ass_id,
               p_eff_end_date,
                  p_pd_os_id,
            l_show_cand_prim_assgts,
            p_prim_date_from,
            p_new_prim_ass_id);
         --
         if l_show_cand_prim_assgts = 'Y' then
            --
            -- Need to do a show_lov on client so
            -- return special warning to be interpreted
            -- on client.
            --
            p_returned_warning   := 'SHOW_LOV';
            p_re_entry_point  := 2;
            return;
         end if;
      end if;
   else
      if p_prim_flag = 'Y' then
         validate_primary_flag(
               p_val_st_date,
               p_pd_os_id,
                  p_ass_id);
         p_copy_y_to_prim_ch := 'Y';
      end if;
   end if;
   --
<<RE_ENTRY_POINT_2>>
   --
   -- Now check the changing of term_assign's with relation to it's
   -- impact on element entries (G255).
   --
    hr_utility.set_location('PER_ASSIGNMENTS_F3_PKG.pre_update_bundle2' , 30);
   test_for_cancel_term(
         p_ass_id,
         p_val_st_date,
         p_val_end_date,
         p_upd_mode,
         p_per_sys_st,
         p_s_per_sys_st,
      p_cancel_atd,
         p_cancel_lspd,
         p_reterm_atd,
         p_reterm_lspd);
   --
   -- OK, now ready to update so:
   -- If the assignment number has been changed then update all the other
   -- assignments with the same id as the current one to have the same new
   -- assignment number.
   --
   if p_s_ass_number <> p_ass_number then
      update   per_all_assignments_f a
      set   a.assignment_number  = P_ASS_NUMBER
      where a.business_group_id + 0 = P_BG_ID
      and   a.rowid              <> P_ROW_ID
      and   a.assignment_id      = P_ASS_ID;
   end if;
   --
   p_re_entry_point := 0;
   --
    hr_utility.set_location('Leaving: '|| 'PER_ASSIGNMENTS_F3_PKG.pre_update_bundle2' , 40);
end pre_update_bundle2;
-----------------------------------------------------------------------------
--
--  UPDATE_AND_DELETE_BUNDLE: procedure to bundle procedure calls which follow
--  each other at pre_update and pre_delete time (on PERWSEMA).
--
-- p_re_entry_point is used to re-enter code after warnings and prevent
-- code being re-run. A p_re_entry_point of 0 implies successful completion.
--
-- A null p_re_entry_point should be passed to run whole procedure.
-- p_only_one_entry_point is 'Y' if only the given entry point is to be
-- run through. eg If p_re_entry_point=2 and p_only_one_entry_point='Y' then
-- only the code relating to PAYROLL_CHANGE_VALIDATE will be run and then
-- the procedure will finish.
-- Normally the value of p_only_one_entry_point will be 'N' where the code
-- will run through until the end of the proc unless it hits a warning or
-- error.
--
procedure update_and_delete_bundle(
   p_dt_mode      varchar2,
   p_val_st_date     date,
   p_eff_st_date     date,
   p_eff_end_date    date,
   p_pd_os_id     number,
   p_per_sys_st      varchar2,
   p_ass_id    number,
   p_val_end_date    date,
   p_dt_upd_mode     varchar2,
   p_dt_del_mode     varchar2,
   p_sess_date    date,
   p_pay_id    number,
   p_grd_id    number,
   p_sp_ceil_st_id      number,
   p_ceil_seq     number,
   p_new_end_date    IN OUT NOCOPY date,
   p_returned_warning   IN OUT NOCOPY varchar2,
   p_re_entry_point  IN OUT NOCOPY number,
   p_only_one_entry_point  varchar2,
    p_pay_basis_id number,  --fix for bug 4764140
    p_ins_new_sal_flag     VARCHAR2   DEFAULT 'N'              -- fix for 9109727
    ) is
   --
   l_null         number;
   l_start_date      date;
   l_dt_mode      varchar2(30);
   l_val_start_date  date;
   l_val_end_date    date;
   l_element_entry_id1 number;
   l_element_entry_id number;
   l_entries_changed_warning      varchar2(1) := 'N';
   l_pay_basis_id number; --fix for bug 4764140
--
l_Del_proposal_Id           Per_Pay_proposals.Pay_proposal_Id%TYPE;
l_Del_Proposal_Ovn          per_pay_Proposals.Object_version_Number%TYPE;
l_del_proposal_change_dt    per_pay_proposals.change_date%type;
l_del_warn                  boolean;
l_del_bg_id                 per_pay_Proposals.business_group_id%type;
l_inv_next_sal_date_warning boolean;
l_proposed_salary_warning   boolean;
l_approved_warning          boolean;
l_payroll_warning           boolean;

--Bug# 5758747
   l_leg_code varchar2(2);
--
-- Bug# 1321860
--  Description : Removed the cursor, which is not required
--


   cursor sp_point is
      select   1
      from  sys.dual where exists (
         select   null
         from  per_spinal_point_steps_f s,
                     per_spinal_point_placements_f p,
                     per_grade_spines_f g
               where    s.step_id        = p.step_id
               and    g.grade_spine_id = s.grade_spine_id
               and    s.sequence       > P_CEIL_SEQ
               and    p.assignment_id  = P_ASS_ID
               and    g.grade_id       = P_GRD_ID
               and   (

                     (p_eff_st_date BETWEEN p.effective_start_date
                           AND p.effective_end_date)
                        OR  ( ( p_dt_mode='UPDATE_OVERRIDE' or p_dt_mode=  'UPDATE')
                                      and p_eff_st_date <= p.effective_start_date )
                           )

                      );  -- modified the cursor for bug fix 7205433


 -- fix for bug 4531033 starts here
  cursor csr_get_salary is
    select element_entry_id
    from   pay_element_entries_f
    where  assignment_id = p_ass_id
    and    creator_type = 'SP'
    and    l_val_start_date between
         effective_start_date and effective_end_date;

  cursor csr_chk_rec_exists is
    select element_entry_id
    from   pay_element_entries_f
    where  assignment_id = p_ass_id
    and    creator_type = 'SP'
    and    (l_val_start_date - 1) between
         effective_start_date and effective_end_date;
 -- fix for bug 4531033 ends here
   --
-- fix for bug 4764140 starts here.
  cursor csr_pay_basis_id is
  select pay_basis_id
  from per_all_assignments
  where assignment_id = p_ass_id
  and effective_start_date <= p_eff_st_date
  and effective_end_date >= p_eff_st_date;
  --
  --
  Cursor Proposal_Dtls  is
  Select Pay_Proposal_Id, Object_Version_Number,business_group_id,change_date
    From Per_Pay_Proposals
  where assignment_id = p_ass_id
  and change_date <= p_val_st_date
  and nvl(date_to,to_date('31/12/4712','dd/mm/yyyy')) >= p_val_st_date;

  -- fix for bug 4764140 ends here.
 -- fix for the bug 4612843

l_step_enddate date;
l_asg_enddate date;

cursor get_step_enddate is
select s.effective_end_date
   from per_spinal_point_steps_f s,
        per_grade_spines_F g
    where s.step_id= p_sp_ceil_st_id
    and g.grade_id= P_GRD_ID
    and g.grade_spine_id=s.grade_spine_id ;

    cursor get_asg_enddate is
    select max(effective_end_date ) from per_all_assignments_f
	  where assignment_id= P_ASS_ID
	-- and grade_id=P_GRD_ID
	  and assignment_type='E';

    -- end of bug 4612843

-- Bug# 5758747
    CURSOR get_leg_code IS
    SELECT legislation_code
    FROM per_business_groups
    WHERE business_group_id = (SELECT business_group_id
                                                    FROM per_all_assignments_f
                                                    WHERE assignment_id = p_ass_id
						    and effective_start_date <= p_eff_st_date
                                                    and effective_end_date >= p_eff_st_date);

/*  Bug 9109727 */

CURSOR Element_Info(P_assignmnet_id number,P_pay_basis_id number, P_Effective_Date in DAte) IS
Select ele.element_entry_id
 from  per_pay_bases bas,
       pay_element_entries_f ele,
       pay_element_entry_values_f entval
 where bas.pay_basis_id = P_pay_basis_id
   and entval.input_value_id = bas.input_value_id
   and p_effective_date
between entval.effective_start_date
    and entval.effective_end_date
    and ele.assignment_id  = P_assignmnet_id
    and p_effective_date between ele.effective_start_date
    and ele.effective_end_date
    and ele.element_entry_id = entval.element_entry_id;


l_ovn				number;
l_Pay_Proposal_Id		number;
l_proposed_salary 		number;

/* Bug 9109727 */


begin
   p_returned_warning   := null;
   hr_utility.clear_warning;
   --
hr_utility.set_location('per_assignments_f3_pkg.update_and_delete_bundle',1);
hr_utility.trace('RE_ENTRY_POINT is '||to_char(p_re_entry_point));

--Bug# 5758747
OPEN get_leg_code;
FETCH get_leg_code INTO l_leg_code;
CLOSE get_leg_code;

--
   if p_re_entry_point = 1 then
      goto RE_ENTRY_POINT_1;
   elsif p_re_entry_point = 2 then
      goto RE_ENTRY_POINT_2;
   elsif p_re_entry_point = 3 then
      goto RE_ENTRY_POINT_3;
   end if;
   --
   -- CHECK_TERM_BY_POS:
   --
   -- Checks the validity of the end date according to future
   -- terminations. Returns a new end date if appropriate.
   -- If p_only_one_entry_point = 'Y' and p_re_entry_point is not between
   -- 1 and 3 (or 0) then we will perform CHECK_TERM_BY_POS only. We set
   -- p_re_entry_point to 999 as an arbritary value to do this.
   --
   if p_dt_mode = 'UPDATE_OVERRIDE' then
      l_start_date := p_val_st_date;
   else
      l_start_date := p_eff_st_date;
   end if;
   --
   p_new_end_date := null;
   --
   hr_assignment.check_term(
      p_pd_os_id,
      p_ass_id,
      l_start_date,
      p_eff_end_date,
      p_per_sys_st,
      p_dt_mode,
      p_new_end_date);
   --
   --Bug# 5758747
   IF l_leg_code = 'US' THEN
	   hr_assignment.check_for_cobra(
	      p_ass_id,
	      p_val_st_date,
	      p_val_end_date);
	   if hr_utility.check_warning then
	      p_returned_warning   := 'HR_ASS_TERM_COBRA_EXISTS';
	      p_re_entry_point  := 1;
	      return;
	   end if;
   END IF;
   --
   if p_only_one_entry_point = 'Y' then
      return;
   end if;
   --
<<RE_ENTRY_POINT_1>>
hr_utility.trace('RE_ENTRY_POINT1');
   --
   -- WARN_TERM_BY_POS:
   --
   -- Warn user if the operation will remove an assignment with
   -- TERM_ASSIGN status.
   --
   if p_dt_upd_mode = 'UPDATE_OVERRIDE' then
      l_start_date := p_val_st_date;
   else
      l_start_date := p_eff_st_date;
   end if;
   --
   if p_dt_upd_mode is null then
      l_dt_mode := p_dt_del_mode;
   else
      if p_per_sys_st = 'END' then
         l_dt_mode := 'DELETE';
      else
         l_dt_mode := p_dt_del_mode;
      end if;
   end if;
   --
   hr_assignment.warn_del_term(
      p_ass_id,
      l_dt_mode,
      l_start_date,
      p_eff_end_date);
   --
   if hr_utility.check_warning then
      p_returned_warning   := 'HR_EMP_ASS_TERM_FOUND';
      p_re_entry_point  := 2;
      return;
   end if;
   --
   if p_only_one_entry_point = 'Y' then
      return;
   end if;
        --
<<RE_ENTRY_POINT_2>>
hr_utility.trace('RE_ENTRY_POINT2');

--
-- Bug# 1321860
-- Description : Removed the future payroll action check condition.
--
        --
   -- PAYROLL_CHANGE_VALIDATE:
   --
   if p_dt_upd_mode is null then
      if p_dt_del_mode is null then
         goto CHECK_TERM_COBRA;
      else
         l_dt_mode := p_dt_del_mode;
      end if;
   else
      if p_per_sys_st = 'END' then
         l_dt_mode := 'DELETE';
      else
         l_dt_mode := p_dt_upd_mode;
      end if;
   end if;
   --
   if l_dt_mode = 'DELETE' then
      l_val_start_date := p_sess_date;
   else
      l_val_start_date := p_val_st_date;
   end if;
   --
   if p_new_end_date is null then
      l_val_end_date := p_val_end_date;
   else
      l_val_end_date := p_new_end_date;
   end if;
   --
--fix for bug 4764140 starts here.
open  csr_pay_basis_id;
fetch csr_pay_basis_id  into l_pay_basis_id;
close csr_pay_basis_id;
if (nvl(p_pay_basis_id,hr_api.g_number) <> nvl(l_pay_basis_id,hr_api.g_number)) then
--fix for bug 4764140 ends here.
-- fix for bug 4531033 starts here
            Open Proposal_Dtls;
            Fetch proposal_Dtls into l_Del_Proposal_Id, l_Del_Proposal_Ovn, l_del_bg_id,l_del_proposal_change_dt;
            Close Proposal_Dtls;

               --
               -- End date the proposal. This should end date the element entry as well.
               --
            If l_del_proposal_change_dt < l_val_start_date then
               hr_utility.set_location('End date proposal',25);
               hr_maintain_proposal_api.update_salary_proposal(
                                  p_validate                     => false,
                                  p_pay_proposal_id              => l_Del_proposal_Id,
                                  p_date_to                      => l_val_start_date - 1,
                                  p_object_version_number        => l_Del_Proposal_Ovn,
                                  p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning,
                                  p_proposed_salary_warning      => l_proposed_salary_warning,
                                  p_approved_warning             => l_approved_warning,
                                  p_payroll_warning              => l_payroll_warning);

              	-- Bug 9109727 changes start.
		-- If asked by the user, create a new sal proposal with the new sal basis
	        IF nvl(p_ins_new_sal_flag, 'N') = 'Y' then

		 Open  Element_Info(p_ass_id, p_pay_basis_id, l_val_start_date);
		 Fetch Element_Info Into L_Element_Entry_Id;
		 Close Element_Info;

		 Hr_Maintain_Proposal_Api.INSERT_SALARY_PROPOSAL
				   (P_PAY_PROPOSAL_ID            =>  l_Pay_Proposal_Id
				   ,P_ASSIGNMENT_ID              =>  p_ass_id
				   ,P_BUSINESS_GROUP_ID          =>  l_del_bg_id
				   ,P_CHANGE_DATE                =>  l_val_start_date
				   ,P_PROPOSED_SALARY_N          =>  per_saladmin_utility.get_proposed_salary(p_ass_id,l_val_start_date-1)
				   ,P_OBJECT_VERSION_NUMBER      =>  l_ovn
				   ,P_ELEMENT_ENTRY_ID           =>  L_Element_Entry_Id
				   ,P_MULTIPLE_COMPONENTS        =>  'N'
				   ,P_APPROVED                   =>  'Y'
				   ,P_PROPOSAL_REASON            =>  'SALBASISCHG'
				   ,P_INV_NEXT_SAL_DATE_WARNING  =>  L_INV_NEXT_SAL_DATE_WARNING
				   ,P_PROPOSED_SALARY_WARNING    =>  L_PROPOSED_SALARY_WARNING
				   ,P_APPROVED_WARNING           =>  L_APPROVED_WARNING
				   ,P_PAYROLL_WARNING            =>  L_PAYROLL_WARNING);
		END IF ;
  	        -- Bug 9109727 changes end

              Elsif l_del_proposal_change_dt = l_val_start_date THEN
	         -- Zap the proposal and the element entry.
                 hr_utility.set_location('Zap proposal',25);

                 Hr_Maintain_Proposal_Api.DELETE_SALARY_PROPOSAL
                                 (P_PAY_PROPOSAL_ID              =>   l_Del_proposal_Id
                                 ,P_BUSINESS_GROUP_ID           =>    l_del_bg_id
                                 ,P_OBJECT_VERSION_NUMBER       =>    l_Del_Proposal_Ovn
                                 ,P_SALARY_WARNING              =>    l_Del_Warn);
             Else
                hr_utility.set_location('Should never come here',25);
                null;
             End if;

               /***
 	open csr_get_salary;
        fetch csr_get_salary into l_element_entry_id;
        if csr_get_salary%found then
  	    close csr_get_salary;



  	    open csr_chk_rec_exists;
       	    fetch csr_chk_rec_exists into l_element_entry_id1;

 	    if csr_chk_rec_exists%found then
    	       close csr_chk_rec_exists;

    	       --
   	       hr_entry_api.delete_element_entry
   	       ('DELETE'
   	       ,l_val_start_date - 1
    	       ,l_element_entry_id1);
               --

       	     else

     	        close csr_chk_rec_exists;
        	  hr_entry_api.delete_element_entry
        	    ('ZAP'
        	  ,l_val_start_date
        	   ,l_element_entry_id);

       	     end if;

      l_entries_changed_warning := 'S';
    else
       close csr_get_salary;
    end if;

 **/
   -- fix for bug 4531033 ends here
 end if;--fix for bug 4764140.

   hrentmnt.check_payroll_changes_asg(
                p_ass_id,
                p_pay_id,
                l_dt_mode,
                l_val_start_date,
                l_val_end_date);
   --
        -- added the IF clause for bug 2537091
        if p_per_sys_st <> 'END' then
          hrentmnt.check_opmu(
                  p_ass_id,
                  p_pay_id,
                  l_dt_mode,
                  l_val_start_date,
                  l_val_end_date);
        end if;
   --
   if p_only_one_entry_point = 'Y' then
      return;
   end if;
   --
<<CHECK_TERM_COBRA>>
hr_utility.trace('CHECK_TERM_COBRA');
   --
   -- CHECK_TERM_COBRA:
   --
   --Bug# 5758747
   IF l_leg_code = 'US' THEN
	   hr_assignment.check_for_cobra(
	      p_ass_id,
	      p_val_st_date,
	      p_val_end_date);
	   --
	   if hr_utility.check_warning then
	      p_returned_warning   := 'HR_ASS_TERM_COBRA_EXISTS';
	      p_re_entry_point  := 3;
	      return;
	   end if;
  END IF;
        --
<<RE_ENTRY_POINT_3>>
hr_utility.trace('RE_ENTRY_POINT3');
   --
   -- CHECK_SPP_AND_CEIL:
   --
   -- Check to see if there are any placements for the assignment that
   -- have a spinal point sequence greater than the ceiling spinal
   -- point sequence. Note the check is limited to those placements
   -- linked to a grade spine record whose grade id is the same as
   -- ASS.GRADE_ID.
   --
   if p_grd_id is not null and p_sp_ceil_st_id is not null then
   hr_utility.set_location ('RE_ENTRY_POINT3 ' ||p_dt_mode,10 );
      hr_utility.set_location ('p_eff_st_date ' ||p_eff_st_date,10 );

      open sp_point;
      fetch sp_point into l_null;
      if sp_point%found then
         fnd_message.set_name('PAY',
            'PER_7935_CEIL_PLACE_HIGH_EXIST');
         close sp_point;
         fnd_message.raise_error;
      end if;
      close sp_point;
   end if;
   --fix for  bug 4612843
    open get_step_enddate;
     fetch get_step_enddate into l_step_enddate;
     if (l_step_enddate < hr_api.g_eot) then
         close get_step_enddate;
         open get_asg_enddate;
         fetch get_asg_enddate into l_asg_enddate;
         if ( l_asg_enddate > l_step_enddate ) then
         close  get_asg_enddate;
              fnd_message.set_name('PAY','PAY_7589_SYS_STEP_DT_OUTDATE');
               fnd_message.raise_error;
               else
               close  get_asg_enddate;
           end if ;
           else
           close get_step_enddate;
      end if;

-- end of fix for the bug 4612843
   --
   p_re_entry_point  := 0;
   --
hr_utility.set_location('per_assignments_f3_pkg.update_and_delete_bundle',2);
--
end update_and_delete_bundle;
-----------------------------------------------------------------------------
END PER_ASSIGNMENTS_F3_PKG;

/
