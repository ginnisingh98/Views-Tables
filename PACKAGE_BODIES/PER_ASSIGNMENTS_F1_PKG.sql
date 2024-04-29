--------------------------------------------------------
--  DDL for Package Body PER_ASSIGNMENTS_F1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASSIGNMENTS_F1_PKG" AS
/* $Header: peasg01t.pkb 120.29.12010000.8 2009/12/08 12:33:48 brsinha ship $ */
--
g_package  varchar2(33) := 'per_assignments_f1_pkg.';  -- Global package name
g_debug    boolean; -- debug flag
--
-----------------------------------------------------------------------------
--
-- PROCEDURE: iud_update_primary
--
-- If there is to be a change to the Primary Flag and the current assignment
-- will be the primary one after the change then we must ensure that the
-- end date on the assignment is not going to be reset as a result of
-- removing future TERMINATION records (see Termination Logic). This is the
-- case when the P_NEW_END_DATE field is not NULL.
--
-- When there is to be a change the Primary Flag then all the assignments
-- affected must be updated.
--
-- HR_ASSIGNMENT.UPDATE_PRIMARY performs the following logic :-
--
-- If the P_NEW_PRIM_FLAG is 'Y' then all future rows for the current
-- assignment must have PRIMARY_FLAG set to 'Y' and all other assignments
-- that have future PRIMARY_FLAG = 'Y' must be set to non-primary.
--
-- If the P_NEW_PRIM_FLAG is 'N' then the new primary assignment
-- P_NEW_PRIM_ASS_ID should be made PRIMARY. This may involve performing
-- a date effective insert aswell as updating all future rows. In addition
-- all other assignments with future PRIMARY FLAG = 'Y' should be set to
-- non-primary.
--
procedure iud_update_primary(
   p_mod_mode     varchar2,
   p_new_prim_flag      varchar2,
   p_prim_date_from  date,
   p_new_end_date    date,
   p_eot       date,
   p_pd_os_id     number,
   p_ass_id    number,
   p_new_prim_ass_id IN OUT NOCOPY number,
   p_prim_change_flag   IN OUT NOCOPY varchar2) is
--

l_fin_proc_date    date;
l_person_id        number;
l_assignment_type  per_all_assignments_f.assignment_type%TYPE;
l_pdp_date_start   date;
--
l_proc            varchar2(18) :=  'iud_update_primary';
--

--
-- Fetch the person ID and assignment type
-- so the period of placement can be obtained
-- for contingent workers.
--
CURSOR csr_get_assignment_info IS
SELECT paaf.person_id
      ,paaf.assignment_type
      ,paaf.period_of_placement_date_start
FROM   per_all_assignments_f paaf
WHERE  paaf.assignment_id = p_ass_id
AND    paaf.assignment_type IN ('E', 'C');
--
-- Bug 3240313 starts here.
--
CURSOR csr_get_new_asg_info IS
SELECT paaf.person_id
      ,paaf.assignment_type
      ,paaf.period_of_placement_date_start
FROM   per_all_assignments_f paaf
WHERE  paaf.assignment_id = p_new_prim_ass_id
AND    paaf.assignment_type IN ('E', 'C');
--
-- Bug 3240313 ends here.
--
-- Get the termination dates for the period of placement and
-- period of service.
--
CURSOR csr_get_term_dates IS
SELECT NVL(final_process_date, p_eot)
FROM   per_periods_of_service
WHERE  period_of_service_id = p_pd_os_id
UNION
SELECT NVL(pdp.final_process_date, p_eot)
FROM   per_periods_of_placement pdp
WHERE  pdp.person_id = l_person_id
AND    pdp.date_start = l_pdp_date_start;

BEGIN
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

  --
  -- Fetch the desired assignment details.
  --
  OPEN  csr_get_assignment_info;
  FETCH csr_get_assignment_info INTO l_person_id
                                    ,l_assignment_type
                                    ,l_pdp_date_start;
  --
  -- Bug 3240313 starts here.
  --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;

  IF csr_get_assignment_info%notfound then
     OPEN csr_get_new_asg_info;
     FETCH csr_get_new_asg_info INTO l_person_id
                                    ,l_assignment_type
                                    ,l_pdp_date_start;
     CLOSE csr_get_new_asg_info;
  END IF;
  --
  -- Bug 3240313 ends here.
  --
  CLOSE csr_get_assignment_info;

  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 20);
  END IF;

   if p_new_prim_flag = 'Y' and
      (p_new_end_date <> p_eot and p_new_end_date is not null) then
      --
      -- Get final process date of the pos / pop.
      --
      OPEN  csr_get_term_dates;
      FETCH csr_get_term_dates into l_fin_proc_date;
      if (csr_get_term_dates%notfound) or
            (p_new_end_date <> l_fin_proc_date) then
         CLOSE csr_get_term_dates;
         fnd_message.set_name('PAY',
            'HR_6438_EMP_ASS_NOT_CONTIN');
         fnd_message.raise_error;
      end if;
      close csr_get_term_dates;
   end if;
   --
   if p_new_prim_flag = 'Y' then
      p_new_prim_ass_id := p_ass_id;
   end if;
--
-- Comment from hr_assignment.update_primary pkg body:
--
--      For the Current Assignment, if the operation is not ZAP then updates
--         all the future rows to the NEW_PRIMARY_FLAG value.
--      For other assignments,
--         if the other assignment is the new primary then ensure that there
--         is a record starting on the correct date with Primary Flag = 'Y'
--         and update all other future changes to the same Primary value.
--      For any other assignments
--             if the assignment is primary on the date in question then
--             ensure that that there is a row on this date with primary
--             flag = 'N' and that all future changes are set to 'N'
--             otherwise
--             ensure that all future primary flags are set to 'N'.
--      NB. This uses several calls to DO_PRIMARY_UPDATE which handles the
--          date effective insert for an individual assignment row if one
--          is required.
--
-- The 0 parameters below are p_last_updated_by and p_last_update_login, not
-- really used at the moment.
--
  IF l_assignment_type <> 'C' THEN
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 30);
  END IF;


   hr_assignment.update_primary(
         p_ass_id,
         p_pd_os_id,
         p_new_prim_ass_id,
         p_prim_date_from,
         p_new_prim_flag,
         p_mod_mode,
         0,
         0);

  ELSIF l_assignment_type = 'C' THEN
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 40);
  END IF;


   hr_assignment.update_primary_cwk(
         p_ass_id,
                        l_person_id,
         l_pdp_date_start,
         p_new_prim_ass_id,
         p_prim_date_from,
         p_new_prim_flag,
         p_mod_mode,
         0,
         0);

  END IF;

   p_prim_change_flag := 'N';
   --
  IF g_debug THEN
    hr_utility.set_location( 'Leaving ' ||g_package || l_proc, 50);
  END IF;

end iud_update_primary;
-----------------------------------------------------------------------------
procedure update_group(
   p_pg_id     number,
   p_group_name   varchar2,
    p_bg_id       number) is
--
-- Called post-insert/update.
--  Start of fix 2762904
   cursor c_flex is
       SELECT bg.people_group_structure flex_num
              FROM   PER_BUSINESS_GROUPS BG
       WHERE  BG.BUSINESS_GROUP_ID= p_bg_id;

   -- Bug fix 3648612.
   -- Cursor modified to improve performance.

   cursor  c_seg(p_flexnum number) is
     select rownum, format_type
           from fnd_id_flex_segments_vl f, fnd_flex_value_sets v
     where f.flex_value_set_id = v.flex_value_set_id(+)
     and   id_flex_code ='GRP'
     and   f.application_id = 801 -- bug fix 3648612.
     and id_flex_num =  p_flexnum
     and display_flag='Y'
     and enabled_flag='Y'
   order by segment_num;

   l_xname varchar2(240);
   l_ch_seg FND_FLEX_EXT.SegmentArray;
   c number;
   l_rnum number;
   l_format varchar2(1);
   l_flexnum number;
   l_delimiter  varchar2(1);
   l_dateformat varchar2(30);
    i  number := 1;
   -- end of Fix 2762904
--
l_proc            varchar2(12) :=  'update_group';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

   if p_pg_id <> -1 then
   --
   -- This is an existing desc flex record, update group_name held on
   -- combinations table.
   -- Start if fix 2762904
    l_xname := p_group_name;
    if l_xname is not null then
    open c_flex;
    fetch c_flex into l_flexnum;
    if c_flex%notfound  then
       close c_flex;
    end if;
    close c_flex;
    l_delimiter := FND_FLEX_APIS.get_segment_delimiter(
                                                 x_application_id => 801,
                                                 x_id_flex_code   => 'GRP' ,
                                                 x_id_flex_num    => l_flexnum );
   c := fnd_flex_ext.breakup_segments(l_xname,l_delimiter,l_ch_seg);
   fnd_profile.get('ICX_DATE_FORMAT_MASK',l_dateformat);

  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;

    For  x in c_seg(l_flexnum) loop

     --fnd_message.debug('Date Format: '||l_dateformat);
    -- fnd_message.debug('Format : '||x.format_type ||'Seg' ||l_ch_seg(i));
     if x.format_type in ('X') then
         l_ch_seg(i) := to_char(to_date(l_ch_seg(i), l_dateformat),'DD-MON-RRRR');
      --fnd_message.debug('Format :' || l_ch_seg(i));
      elsif x.format_type in ('Y') then
        --  fnd_message.debug ('date format '||l_dateformat);
       --   fnd_message.debug('Length '||length(l_ch_seg(i)));
          l_ch_seg(i):= to_char(to_date(l_ch_seg(i),l_dateformat||' HH24:MI:SS'),'DD-MON-RRRR HH24:MI:SS');
     end if;

     i := i + 1;
   end loop;
   l_xname:= fnd_flex_ext.concatenate_segments(c,l_ch_seg,l_delimiter);
  -- p_group_name := l_xname;
   end if;
   --End of Fix 2762904
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 20);
  END IF;
      update   pay_people_groups
      set   group_name  = l_xname
      where people_group_id = P_PG_ID
           and    (group_name     <> p_group_name
                        or group_name is null)
	   and  l_xname is not null; -- 4103321
      --
      -- Commented out as not needed and causes process to hang if
      -- called and people_group_name has not changed
      --
      /*
      if sql%rowcount = 0 then
         fnd_message.set_name('PAY',
            'HR_6153_ALL_PROCEDURE_FAIL');
                        fnd_message.set_token('PROCEDURE',
                           'PER_ASSIGNMENTS_F1_PKG.UPDATE_GROUP');
                        fnd_message.set_token('STEP', '1');
         fnd_message.raise_error;
      end if;
      */
   end if;
   --
  IF g_debug THEN
    hr_utility.set_location( 'Leaving ' || g_package || l_proc, 30);
  END IF;
end update_group;
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Added to test LOCK is FIXING the Issue
---- changes completed for bug 5219266
-----------------------------------------------------------------------------
procedure update_scl(
   p_scl_id number,
   p_scl_concat   varchar2) is
--
--

CURSOR csr_chk_scl is
    SELECT null
      FROM hr_soft_coding_keyflex
     where  soft_coding_keyflex_id =  p_scl_id
       and (concatenated_segments  <> p_scl_concat
        or concatenated_segments is null);
  --
  l_exists  varchar2(30);
  l_proc   varchar2(72) := g_package||'update_scl ';
  --
  procedure update_scl_auto
   ( p_scl_id number,
     p_scl_concat   varchar2
   ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
    --
    CURSOR csr_scl_lock is
      SELECT null
       FROM 	hr_soft_coding_keyflex
       where  soft_coding_keyflex_id =  p_scl_id
       for update nowait;
    --
    l_exists  varchar2(30);
    l_proc    varchar2(72) := g_package||'update_scl_auto ';

    begin

    --  if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
    --  end if;
    --
    -- The outer procedure has already establish that an update is
    -- required. This sub-procedure uses an autonomous transaction
    -- to ensure that any commits do not impact the main transaction.
    -- If the row is successfully locked then continue and update the
    -- row. If the row cannot be locked then another transaction must
    -- be performing the update. So it is acceptable for this
    -- transaction to silently trap the error and continue.
    --
    -- Note: It is necessary to perform the lock test because in
    -- a batch data upload scenario multiple sessions could be
    -- attempting to insert or update the same Key Flexfield
    -- combination at the same time. Just directly updating the row,
    -- without first locking, can cause sessions to hang and reduce
    -- batch throughput.
    --
    open csr_scl_lock;
    fetch csr_scl_lock into l_exists;
    if csr_scl_lock%found then
    close csr_scl_lock;


    --    if g_debug then
        hr_utility.set_location(l_proc, 20);
    --    end if;
      --
      -- Lock obtained by this transaction, updating the concatenated
      -- segment string should be performed.
      --
          update  hr_soft_coding_keyflex
  	  set     concatenated_segments  = p_scl_concat
  	  where   soft_coding_keyflex_id = p_scl_id
          and (concatenated_segments   <> p_scl_concat
          or  concatenated_segments is null);
      --
      -- Commit this change so the change is immediately visible to
      -- other transactions. Also ensuring that it is not undone if
      -- the main transaction is rolled back. This commit is only
      -- acceptable inside an API because it is being performed inside
      -- an autonomous transaction and AOL code has previously
      -- inserted the Key Flexfield combination row in another
      -- autonomous transaction.
      commit;
    else
--changes for bug 6333879 starts here
      Rollback;
--changes for bug 6333879 ends here
      close csr_scl_lock;
    end if;


    -- if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 30);
    -- end if;

  Exception
    When HR_Api.Object_Locked then
      --
      -- This autonomous transaction was unable to lock the row.
      -- It can be assumed that another transaction has locked the
      -- row and is performing the update. Hence the error can
      -- be suppressed without raising it to the end user.
      --
      hr_utility.set_location('Leaving:'|| l_proc, 40);
  end update_scl_auto;

 begin
--

  --if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --end if;
  --
  -- First find out if it is necessary to update the concatenated
  -- segment string column. This select is being done to avoid the
  -- performance unnecessary overhead of set-up an autonomous
  -- transaction when an update is not required. Updates are only
  -- expected immediately after the combination row was first inserted.
  --
  open csr_chk_scl;
  fetch csr_chk_scl into l_exists;
  if csr_chk_scl%found then
    close csr_chk_scl;
    update_scl_auto
      (p_scl_id  => p_scl_id
      ,p_scl_concat   => p_scl_concat
      );
  else
    close csr_chk_scl;
  end if;
  --

 --if g_debug then
  hr_utility.set_location('Leaving:'|| l_proc, 20);
 --end if;

end update_scl;
-----------------------------------------------------------------------------

/* procedure update_scl(
   p_scl_id number,
   p_scl_concat   varchar2) is
--
-- Called post-insert/update.
--
begin
   if p_scl_id <> -1 then
   --
   -- This is an existing desc flex record, update concatenated_segments
   -- field held on hr_soft_coding_keyflex table.
   --
      update   hr_soft_coding_keyflex
      set   concatenated_segments   = p_scl_concat
      where soft_coding_keyflex_id  = p_scl_id;
      --
      if sql%rowcount = 0 then
         fnd_message.set_name('PAY',
            'HR_6153_ALL_PROCEDURE_FAIL');
                        fnd_message.set_token('PROCEDURE',
                           'PER_ASSIGNMENTS_F1_PKG.UPDATE_SCL');
                        fnd_message.set_token('STEP', '1');
         fnd_message.raise_error;
      end if;
   end if;
   --
end update_scl; */
-- changes ended
-- changes completed for bug 5219266
-----------------------------------------------------------------------------
procedure do_cancel_reterm(
   p_ass_id    number,
   p_bg_id        number,
   p_cancel_atd      date,
   p_cancel_lspd     date,
   p_reterm_atd      date,
   p_reterm_lspd     date) is
--
-- Run the check to see whether this update operation will result
-- in a TERM_STATUS being removed or superceded by an earlier one.
-- This also checks to see whether the operation will cause a new
-- "leading TERM_ASSIGN" to be implicitly created (i.e. a row in the
-- future becomes the "leading TERM_ASSIGN").
--
-- VT 10/07/96 bug #306710
l_entries_chng VARCHAR2(1) := 'N';
--
l_proc            varchar2(16) :=  'do_cancel_reterm';
--
begin
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
   hrentmnt.maintain_entries_asg(
      p_ass_id,
      p_bg_id,
      'CNCL_TERM',
      p_cancel_atd,
      p_cancel_lspd,
      null,
      null,
      null,
      null);
        per_saladmin_utility.adjust_pay_proposals(p_assignment_id => p_ass_id);
 --
   if p_reterm_atd is not null then
      hrempter.terminate_entries_and_alus(
         p_ass_id,
         p_reterm_atd,
         p_reterm_lspd,
         null,
         null,
         l_entries_chng);
   end if;
   --
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
end do_cancel_reterm;
----------------------------------------------------------------------------
procedure future_del_cleanup(
   p_ass_id number,
   p_grd_id number,
   p_sess_date date,
   p_calling_proc  varchar2,
        p_val_st_date   date,
   p_val_end_date date,
   p_datetrack_mode varchar2,
   p_future_spp_warnings OUT NOCOPY boolean
   ) is

l_future_spp_warning boolean;
--
l_proc            varchar2(18) :=  'future_del_cleanup';
--
begin
   --
   -- The 2 0's are last_updated_by, last_update_login.
   --
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
   hr_assignment.del_ref_int_delete(
      p_ass_id,
      p_grd_id,
      'FUTURE',
      p_sess_date,
      0, 0,
      p_calling_proc,
      p_val_st_date,
      p_val_end_date,
      p_datetrack_mode,
      l_future_spp_warning);

   p_future_spp_warnings := l_future_spp_warning;
--
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
end future_del_cleanup;
----------------------------------------------------------------------------
procedure tidy_up_ref_int(
   p_mode      varchar2,
   p_sess_date date,
   p_new_end_date date,
   p_val_end_date date,
   p_eff_end_date date,
   p_ass_id number,
   p_cost_warning OUT NOCOPY boolean) is
   l_mode      varchar2(30);
   l_new_end_date date;
   l_old_end_date date;
 --
 l_proc            varchar2(15) :=  'tidy_up_ref_int';
--
--
--  Procedure to reset the end dates of rows in child tables related to the
--  Assignment. This procedure is called when the Assignment is ended using
--  'END' and when the row is opened up using 'FUTURE_CHANGE' or
--  'DELETE_NEXT_CHANGE'.
--
begin
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
   l_mode := p_mode;
   --
   if l_mode = 'END' then
      l_new_end_date    := p_sess_date;
      l_old_end_date    := p_sess_date;
   elsif l_mode = 'INT-END' then
      l_new_end_date    := p_new_end_date;
      l_old_end_date    := p_sess_date;
      l_mode      := 'END';
   else
      l_new_end_date    := nvl(p_new_end_date, p_val_end_date);
      l_old_end_date := p_eff_end_date;
   end if;
   --
   -- The 2 0's are last_updated_by, last_update_login.
   --
   hr_assignment.tidy_up_ref_int(
      p_ass_id,
      l_mode,
      l_new_end_date,
      l_old_end_date,
      0, 0, p_cost_warning);
   --

    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
end tidy_up_ref_int;
----------------------------------------------------------------------------
procedure terminate_entries(
   p_per_sys_st   varchar2,
   p_ass_id number,
   p_sess_date date,
   p_val_st_date  date) is
   l_start_date   date;
begin
    hr_utility.set_location('Entering: '|| 'PER_ASSIGNMENTS_F1_PKG.terminate_entries' , 5);
   if p_per_sys_st = 'END' then
      l_start_date   := p_sess_date;
   else
      l_start_date   := p_val_st_date;
   end if;
   --
   hr_assignment.call_terminate_entries(
      p_ass_id,
      p_per_sys_st,
      l_start_date);
   --
end terminate_entries;
-----------------------------------------------------------------------------
procedure set_end_date(
   p_new_end_date date,
   p_ass_id number) is
--
-- Update the value of effective end date to the NEW END DATE determined by
-- CHECK_TERM.
-- This is to ensure that assignments cannot be 'opened up' past the Period
-- of Service End Date.
--
begin
    hr_utility.set_location('Entering: '|| 'PER_ASSIGNMENTS_F1_PKG.set_end_date' , 5);

   update   per_assignments_f a
   set   a.effective_end_date = P_NEW_END_DATE
   where a.assignment_id      = P_ASS_ID
   and   a.effective_end_date = (
      select   max(a2.effective_end_date)
      from  per_assignments_f a2
      where a2.assignment_id = a.assignment_id);
end set_end_date;
-----------------------------------------------------------------------------
procedure maintain_entries(
   p_dt_upd_mode     varchar2,
   p_dt_del_mode     varchar2,
   p_per_sys_st      varchar2,
   p_sess_date    date,
   p_val_start_date  date,
   p_val_end_date    date,
   p_new_end_date    date,
   p_ass_id    number,
   p_bg_id        number,
   p_old_pay_id      number,
   p_new_pay_id      number,
   p_old_pg_id       number, -- Added for bug#3924690
   p_new_pg_id       number, -- Added for bug#3924690
   p_raise_warning      IN OUT NOCOPY varchar2) is
   l_val_start_date  date;
   l_val_end_date    date;
   l_mode         varchar2(30);
   l_entries_changed varchar2(1);
--
-- Maintain element entries for insert/update/delete
--
begin
--
  hr_utility.set_location('per_assignments_f1_pkg.maintain_entries',1);
  hr_utility.set_location('p_old_pg_id :'||to_char(p_old_pg_id),1);
  hr_utility.set_location('p_new_pg_id :'||to_char(p_new_pg_id),1);

   if p_dt_upd_mode is null then
      if p_dt_del_mode is null then
         l_mode := 'INSERT';
      else
         l_mode := p_dt_del_mode;
      end if;
   else
      if p_per_sys_st = 'END' then
         l_mode := 'DELETE';
      else
         l_mode := p_dt_upd_mode;
      end if;
   end if;
   --
   if l_mode = 'DELETE' then
      l_val_start_date := p_sess_date;
   else
      l_val_start_date := p_val_start_date;
   end if;
   --
   if p_new_end_date is null then
      l_val_end_date := p_val_end_date;
   else
      l_val_end_date := p_new_end_date;
   end if;
   --
   -- N.B. If the mode is 'DELETE' i.e. we are ending the assignment
   -- then the date passed in is the end date of the Assignment.
   -- The validation start date of a date effectively deleted row is
   -- the day after the deletion therefore we must add one day on to the
   -- data in this case.
   --
   if l_mode = 'DELETE' then
      l_val_start_date := l_val_start_date + 1;
   end if;
   --
hr_utility.set_location('per_assignments_f1_pkg.maintain_entries',2);
   hrentmnt.maintain_entries_asg(
      p_ass_id,
      p_old_pay_id,
      p_new_pay_id,
      p_bg_id,
      'ASG_CRITERIA',
      null,
      null,
      null,
      l_mode,
      l_val_start_date,
      l_val_end_date,
      l_entries_changed,
      null,              -- p_old_hire_date. Added for bug#3924690.
      p_old_pg_id,       -- Added for bug#3924690.
      p_new_pg_id        -- Added for bug#3924690.
      );
   --
   if l_entries_changed = 'Y' then
        per_saladmin_utility.adjust_pay_proposals(p_assignment_id => p_ass_id);
	per_saladmin_utility.handle_asg_crit_change (p_assignment_id => p_ass_id, p_effective_date => l_val_start_date);  -- bug 9181563
        p_raise_warning := 'Y';
   elsif l_entries_changed = 'S' then
        per_saladmin_utility.adjust_pay_proposals(p_assignment_id => p_ass_id);
	per_saladmin_utility.handle_asg_crit_change (p_assignment_id => p_ass_id, p_effective_date => l_val_start_date);  -- bug 9181563
	p_raise_warning := 'S';
   else
	p_raise_warning := 'N';
   end if;
   --
end  maintain_entries;
-----------------------------------------------------------------------------
procedure post_update(
  p_upd_mode                     varchar2,
  p_new_prim_flag             varchar2,
  p_val_st_date                   date,
  p_new_end_date                 date,
  p_eot                          date,
  p_pd_os_id                     number,
  p_ass_id                       number,
  p_new_prim_ass_id     IN OUT NOCOPY number,
  p_prim_change_flag   IN OUT NOCOPY varchar2,
   p_old_pg_id                   number, -- Bug#3924690
   p_new_pg_id                   number,
   p_grd_id                      number,
   p_sess_date                   date,
   p_s_grd_id                    number,
   p_eff_end_date              date,
   p_per_sys_st                  varchar2,
        p_old_per_sys_st                varchar2,  --#2404335
   p_val_end_date                date,
   p_del_mode                     varchar2,
   p_bg_id                          number,
   p_old_pay_id                    number,
   p_new_pay_id                  number,
   p_group_name                  varchar2,
   p_was_end_assign             varchar2,
   p_cancel_atd                    date,
   p_cancel_lspd                 date,
   p_reterm_atd                  date,
   p_reterm_lspd                 date,
   p_scl_id                      number,
   p_scl_concat                    varchar2,
  p_end_salary                varchar2 ,
    p_warning               IN OUT NOCOPY varchar2,
    p_re_entry_point     IN OUT NOCOPY number,
  p_future_spp_warning     OUT NOCOPY boolean) is
  --
  -- Define local variables
  --
    l_per_sys_st              varchar2(30);
    l_raise_warning           varchar2(1);
  l_element_entry_id       number;
    l_calling_proc               varchar2(30);
    l_future_spp_warnings    boolean;
    l_cost_warning           boolean;
    l_min_start_date         date;
  l_dummy_warning          boolean;
  --
  l_proc VARCHAR2(72) := g_package||'post_update';
  --
  cursor csr_get_salary is
    select element_entry_id
    from   pay_element_entries_f
    where  assignment_id = p_ass_id
    and    creator_type = 'SP'
    and    p_val_st_date between
           effective_start_date and effective_end_date;
  --
  -- Check to see if min effective_start_date for spp record is less
  -- then the effective date of the process
  --
  cursor csr_min_spp_date is
    select min(effective_start_date)
    from   per_spinal_point_placements_f
    where  assignment_id = p_ass_id;
  --
  --
    -- Start of 3335915
    -- Start of Fix for Bug 2849080
    --
    -- Declare Cursor.
    /*
    cursor csr_grade_step is
     select spp.placement_id, spp.object_version_number ,step_id,
             spp.effective_end_date,spp.effective_start_date
     from per_spinal_point_placements_f  spp
         where spp.assignment_id = p_ass_id
         and p_val_st_date between spp.effective_start_date
                       and spp.effective_end_date;

   CURSOR csr_spp_id IS
        SELECT spp.placement_id , spp.object_version_number,spp.effective_start_date
        FROM  per_spinal_point_placements_f spp
        WHERE assignment_id = p_ass_id
        and p_sess_date between spp.effective_start_date
                        and spp.effective_end_date;

    -- Declare Local Variables
        l_placement_id number;
    l_object_version_number number;
    l_step_id number ;
    l_spp_end_date date ;
    l_spp_st_date date;
    l_max_spp_date date ;
    l_datetrack_mode varchar2(30);
    l_effective_start_date date;
    l_effective_end_date date;
    --
    --  End of Fix for bug 2849080
    --
    */
    -- End of 3335915
---------------------------------------------------------
-- Payroll Object Group functionality - requires call to
-- pay_pog_all_assignments_pkg. This is designed to be called from a row
-- handler user hook, hence has many parameters that are not available here.
-- So a cursor is used to return the values, to pass to the pog procedure.
--
cur_asg_rec per_asg_shd.g_rec_type;
--
  cursor asg_details(p_asg_id number
                    ,p_eff_date date)
  is
  select assignment_id
  ,effective_start_date
  ,effective_end_date
  ,business_group_id
  ,recruiter_id
  ,grade_id
  ,position_id
  ,job_id
  ,assignment_status_type_id
  ,payroll_id
  ,location_id
  ,person_referred_by_id
  ,supervisor_id
  ,special_ceiling_step_id
  ,person_id
  ,recruitment_activity_id
  ,source_organization_id
  ,organization_id
  ,people_group_id
  ,soft_coding_keyflex_id
  ,vacancy_id
  ,pay_basis_id
  ,assignment_sequence
  ,assignment_type
  ,primary_flag
  ,application_id
  ,assignment_number
  ,change_reason
  ,comment_id
  ,null
  ,date_probation_end
  ,default_code_comb_id
  ,employment_category
  ,frequency
  ,internal_address_line
  ,manager_flag
  ,normal_hours
  ,perf_review_period
  ,perf_review_period_frequency
  ,period_of_service_id
  ,probation_period
  ,probation_unit
  ,sal_review_period
  ,sal_review_period_frequency
  ,set_of_books_id
  ,source_type
  ,time_normal_finish
  ,time_normal_start
  ,bargaining_unit_code
  ,labour_union_member_flag
  ,hourly_salaried_code
  ,request_id
  ,program_application_id
  ,program_id
  ,program_update_date
  ,ass_attribute_category
  ,ass_attribute1
  ,ass_attribute2
  ,ass_attribute3
  ,ass_attribute4
  ,ass_attribute5
  ,ass_attribute6
  ,ass_attribute7
  ,ass_attribute8
  ,ass_attribute9
  ,ass_attribute10
  ,ass_attribute11
  ,ass_attribute12
  ,ass_attribute13
  ,ass_attribute14
  ,ass_attribute15
  ,ass_attribute16
  ,ass_attribute17
  ,ass_attribute18
  ,ass_attribute19
  ,ass_attribute20
  ,ass_attribute21
  ,ass_attribute22
  ,ass_attribute23
  ,ass_attribute24
  ,ass_attribute25
  ,ass_attribute26
  ,ass_attribute27
  ,ass_attribute28
  ,ass_attribute29
  ,ass_attribute30
  ,title
  ,object_version_number
  ,contract_id
  ,establishment_id
  ,collective_agreement_id
  ,cagr_grade_def_id
  ,cagr_id_flex_num
  ,notice_period
  ,notice_period_uom
  ,employee_category
  ,work_at_home
  ,job_post_source_name
  ,posting_content_id
  ,period_of_placement_date_start
  ,vendor_id
  ,vendor_employee_number
  ,vendor_assignment_number
  ,assignment_category
  ,project_title
  ,applicant_rank
  ,grade_ladder_pgm_id
  ,supervisor_assignment_id
  ,vendor_site_id
  ,po_header_id
  ,po_line_id
  ,projected_assignment_end
  from per_all_assignments_f
  where assignment_id = p_asg_id
  and   p_eff_date between effective_start_date
                       and effective_end_date;
  --
  ---------------------------------------------------------
  --
  procedure delete_any_pay_proposals(p_ass_id   number,
                                       p_ass_end_date date) is
  --
  -- Private proc to delete any pay proposals which have
  -- a change date after the validation start date of the
  -- current assignment. It is used for assignments
  -- which have just been ended or terminated.
  --
  begin
    --
      delete   from per_pay_proposals p
      where p.assignment_id      = P_ASS_ID
      and   p.change_date     > P_ASS_END_DATE;
    --
  end delete_any_pay_proposals;
--
---------------------------------------------------------
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  hr_utility.set_location(l_proc||' Update Mode: '||p_upd_mode,11);
  hr_utility.set_location(l_proc||' p_sess_date = '||p_sess_date,12);
  --
   p_warning := null;
   --
   -- If the assignment was updated to End Assign then value would
   -- have been reset at pre-update so validate now against END.
   --
   if p_was_end_assign = 'Y' then
    --
      l_per_sys_st := 'END';
    --
   else
    --
      l_per_sys_st := p_per_sys_st;
    --
    end if;
    --
  hr_utility.trace('Reentry Point is '||to_char(p_re_entry_point));
  hr_utility.trace('l_per_sys_st is '||l_per_sys_st);
  --
   if p_re_entry_point = 1 then
    --
      goto RE_ENTRY_POINT_1;
    --
   elsif p_re_entry_point = 2 then
    --
      goto RE_ENTRY_POINT_2;
    --
  end if;
    --
    if p_prim_change_flag = 'Y' then
    --
    hr_utility.set_location(l_proc,20);
    --
        iud_update_primary( p_upd_mode,
                        p_new_prim_flag,
                        p_val_st_date,
                        p_new_end_date,
                        p_eot,
                        p_pd_os_id,
                        p_ass_id,
                        p_new_prim_ass_id,
                        p_prim_change_flag);
    --
    end if;
    --
  hr_utility.set_location(l_proc,30);
  --
   update_group(  p_new_pg_id,
         p_group_name,
                        p_bg_id);
    --
  hr_utility.set_location(l_proc,40);
  --
    update_scl(
      p_scl_id,
      p_scl_concat);
    --
  if p_upd_mode = 'UPDATE_OVERRIDE' then
      --
    hr_utility.set_location(l_proc,50);
    --
    hr_assignment_internal.maintain_spp_asg
      (p_assignment_id                => p_ass_id
      ,p_datetrack_mode               => p_upd_mode
      ,p_validation_start_date        => p_val_st_Date
      ,p_validation_end_date          => p_val_end_date
      ,p_grade_id                         => p_grd_id
      ,p_spp_delete_warning           => l_future_spp_warnings);
    --
    p_future_spp_warning := l_future_spp_warnings;
    --
        -- Execute the future changes delete cleanup trigger. This is
        -- because part of the functionality of the UPDATE_OVERRIDE
        -- option is to perform a future changes delete.
        --
        l_calling_proc := 'POST_UPDATE';
    --
      future_del_cleanup(
            p_ass_id,
            p_grd_id,
            p_sess_date,
            l_calling_proc,
            p_val_st_date,
            p_val_end_date,
            p_upd_mode,
            l_dummy_warning);
    --
    hr_utility.set_location(l_proc,60);
    --
  --
  -- If datetrack mode is not UPDATE_OVERRIDE
  --
    else
        --
        -- Check to see if the grade has changed. If so then date
        -- effectively delete any spinal point placement records that
        -- exist on or after the validation start date. Perform if
        -- p_s_grd_id is not null.
        -- Note that processing of placements for the update mode of
        -- UPDATE_OVERRIDE is handled by the FUTURE_DEL_CLEANUP
        -- procedure.
        -- Perform a date effective delete on the spinal point
        -- placements table for the current assignment, based on the
        -- value in VALIDATION_START_DATE. First delete all records
        -- starting after the day before this date, then end the
        -- current placement record.
        --
        -- Added code to select the minimum grade step for the new grade
        -- so that the future records can be deleted and then the current
         -- record end dated and the next record being inserted with
        -- the assignment on the minimum step for the grade with the
        -- auto increment flag not ticked and without a increment number
     --
    -- Start of 3335915
    /*
    -- Start of Fix for Bug 2849080
    --
     hr_utility.set_location('p_was_end_assign'||p_was_end_assign,2);
     hr_utility.set_location('l_per_sys_st '||l_per_sys_st,2);

    IF (p_grd_id is not null ) and (p_grd_id = p_s_grd_id) then
  -- start of fix for bug 3053428
        IF l_per_sys_st = 'END' then

        OPEN csr_spp_id;
        FETCH csr_spp_id  INTO l_placement_id, l_object_version_number,l_spp_end_date;

        IF csr_spp_id%found then
         IF (l_spp_end_date <> p_sess_date) THEN
           hr_sp_placement_api.delete_spp
           (p_effective_date        => P_sess_date
           ,p_datetrack_mode        => 'DELETE'
           ,p_placement_id          => l_placement_id
           ,p_object_version_number => l_object_version_number
           ,p_effective_start_date  => l_effective_start_date
           ,p_effective_end_date    => l_effective_end_date);
           END IF;
        END if;

        CLOSE csr_spp_id;
    -- -- End of fix for bug 3053428
   ElSe

    hr_utility.set_location('Ass Eff dt matching ',2);

       OPEN csr_grade_step;
       FETCH csr_grade_step
        INTO l_placement_id,l_object_version_number,l_step_id, l_spp_end_date,l_spp_st_date;


        IF  csr_grade_step%found  then
            hr_utility.set_location('Record Found  ',2);
            select max(effective_end_date)
             into   l_max_spp_date
             from   per_spinal_point_placements_f
             where  placement_id = l_placement_id;

          hr_utility.set_location('PD: Max SPP End Dt '|| l_max_spp_date,2);
          hr_utility.set_location('PD: Current SPP end dt '||l_spp_end_date,2);
          hr_utility.set_location('PD: Val Dt '|| p_val_st_date,2);
          hr_utility.set_location('PD: Current SPP st dt '||l_spp_st_date,2);

            IF (l_spp_st_date = p_val_st_date) THEN
               l_datetrack_mode :=  'CORRECTION';
            ELSIF (l_max_spp_date = l_spp_end_date) THEN
                l_datetrack_mode := 'UPDATE';
            ELSE
                l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
            END IF;

          hr_utility.set_location('PD: Date Track Mode '||l_datetrack_mode,2);


              hr_utility.set_location('Calling upadate_spp from post_update ',2);
              hr_utility.set_location('effective_date       : '||p_val_st_date,2);
              hr_utility.set_location('datetrack_mode       : '||l_datetrack_mode,2);
              hr_utility.set_location('placement_id         : '||l_placement_id ,2);
              hr_utility.set_location('OVN                  : '||l_object_version_number,2);
              hr_utility.set_location('Step Id              : '||l_step_id,2);
              hr_utility.set_location('Effective Start date : '||l_effective_start_date,2);
              hr_utility.set_location('Efective end date    : '||l_effective_end_date,2);
              hr_utility.set_location ('Session Date        : '||p_sess_date, 2);


                hr_sp_placement_api.update_spp
                        (p_effective_date        => p_val_st_date
                        ,p_datetrack_mode        => l_datetrack_mode
                        ,p_placement_id          => l_placement_id
                        ,p_object_version_number => l_object_version_number
                        ,p_step_id               => l_step_id
                        ,p_effective_start_date  => l_effective_start_date
                        ,p_effective_end_date    => l_effective_end_date);




             hr_utility.set_location('Call to update_SPP finished ',2);

        END IF;
        CLOSE csr_grade_step;

      END IF;
    END IF;
    --
    --End of Fix for bug 2849080
    --
    */
    -- End of 3335915

    if (p_s_grd_id <> p_grd_id) or
       (p_grd_id is null and p_s_grd_id is not null) then
      --
      hr_utility.set_location(l_proc||'Grade ID = '||p_grd_id,70);
      hr_utility.set_location(l_proc||'Asg ID = '||p_ass_id,71);
            hr_utility.set_location(l_proc||'Val Start Date = '||p_val_st_date,72);
           --
      -- Check that the effective date of the process is not less than the min
      -- effective start date for the spp record for the assignment
           -- If it is then the process will not be able to update the current step
           -- as there is none so raise an error
      --
      open csr_min_spp_date;
      fetch csr_min_spp_date into l_min_start_date;
      --
      if l_min_start_date > p_val_st_date then
        --
        fnd_message.set_name('PER', 'HR_289771_SPP_MIN_START_DATE');
        hr_utility.raise_error;
        --
      end if;
      --
      close csr_min_spp_date;
      --
      hr_utility.set_location(l_proc,80);
      --
      hr_assignment_internal.maintain_spp_asg
        (p_assignment_id                => p_ass_id
        ,p_datetrack_mode               => p_upd_mode
        ,p_validation_start_date        => p_val_st_Date
        ,p_validation_end_date          => p_val_end_date
        ,p_grade_id                          => p_grd_id
        ,p_spp_delete_warning           => l_future_spp_warnings);
      --
    end if; -- if p_s_grd_id <> p_grd_id then
   --
 end if;
 --
 <<RE_ENTRY_POINT_1>>
 --
 hr_utility.set_location(l_proc||' RE_ENTRY_POINT_1 ',90);
 --
   if l_per_sys_st = 'END' then
     --
   hr_utility.set_location(l_proc,100);
   --
      -- Date Effectively Delete any of the assignments' children
      -- records.
      -- The following tables are affected
      -- PER_SPINAL_POINT_PLACEMENTS_F
      -- Warn the user that any associated spinal point placement
      -- records will be deleted and prompt the user to continue.
      -- Then DE delete any such records.
      --
      -- RE_ENTRY_POINT_1 is really further down so need 2nd goto
      -- within this IF construct.
      --
   if p_re_entry_point = 1 then
     --
     hr_utility.set_location(l_proc,110);
     --
         goto RE_ENTRY_POINT_1a;
     --
      end if;
     --
      l_calling_proc := 'POST_UPDATE';
   --
   hr_utility.set_location(l_proc,120);
   --
      hr_assignment.del_ref_int_delete
     (p_ass_id,
            null,
            'END',
            p_sess_date,
            0,
      0,
            l_calling_proc,
            p_val_st_date,
            p_val_end_date,
            p_upd_mode,
            l_future_spp_warnings);
   --
   hr_utility.set_location(l_proc,130);
   --
   p_future_spp_warning := l_future_spp_warnings;
       --
   -- NB l_cost_Warning is not set in this scenario.
   -- It is only used if mode is FUTURE>
       --
   --
   -- Fix for bug 4278579 starts here.
   -- Move the proc call down after to the maintain_entries().
   --
   /*
   tidy_up_ref_int
     ('END',
            p_sess_date,
         p_new_end_date,
         p_val_end_date,
        p_eff_end_date,
        p_ass_id,
        l_cost_warning);
   */
   --
   -- Fix for bug 4278579 ends here.
   --
   hr_utility.set_location(l_proc,140);
    --
    -- Pass null dt delete mode to ensure it is null.
     --
   hr_utility.set_location(l_proc,150);
   --
      maintain_entries
     (p_upd_mode,
            null,
      l_per_sys_st,
      p_sess_date,
      p_val_st_date,
      p_val_end_date,
      p_new_end_date,
      p_ass_id,
      p_bg_id,
      p_old_pay_id,
      p_new_pay_id,
      p_old_pg_id,  -- Added for Bug#3924690
      p_new_pg_id,  -- Added for Bug#3924690.
            l_raise_warning);
      --
      --
      -- Fix for bug 4278579 starts here.
      --
      tidy_up_ref_int
          ('END',
            p_sess_date,
            p_new_end_date,
            p_val_end_date,
            p_eff_end_date,
            p_ass_id,
            l_cost_warning);
      --
      -- Fix for bug 4278579 ends here.
      --
      hr_utility.set_location(l_proc,160);
      --
       if l_raise_warning in ('Y','S') then
     --
     hr_utility.set_location(l_proc,170);
     --
     if l_raise_warning = 'Y' then
       --
       hr_utility.set_location(l_proc,180);
       --
         p_warning := 'HR_7016_ASS_ENTRIES_CHANGED';
       --
     else
       --
       hr_utility.set_location(l_proc,190);
       --
            p_warning := 'HR_7442_ASS_SAL_ENT_CHANGED';
       --
     end if;
     --
       p_re_entry_point := 1;
       return;
     --
   end if;
       --
   <<RE_ENTRY_POINT_1a>>
   --
   hr_utility.set_location(l_proc||' RE_ENTRY_POINT_1a ',200);
       --
       terminate_entries
         (l_per_sys_st,
         p_ass_id,
         p_sess_date,
         p_val_st_date);
   --
   hr_utility.set_location(l_proc,210);
       --
       -- Now delete any pay proposals which have a change date
       -- after the end of this assignment.
       --
      delete_any_pay_proposals
         (p_ass_id,
         p_val_st_date);
        --
    hr_utility.set_location(l_proc,220);
    --
    end if;  -- if l_per_sys_st = 'END'
  --
   <<RE_ENTRY_POINT_2>>
  --
  hr_utility.set_location(l_proc||' RE_ENTRY_POINT2 ',230);
  --
  if l_per_sys_st <> 'END' then
      --
    hr_utility.set_location(l_proc,240);
    --
      -- If UPDATE_OVERRIDE caused TERM_ASSIGNs to be removed this may have
      --  caused the END DATE to move.
      --  If so, the new_end_date will be NOT NULL.
      --
    -- RE_ENTRY_POINT_2 is really further down so need 2nd goto
    -- within this IF construct.
    --
    if p_re_entry_point = 2 then
      --
      hr_utility.set_location(l_proc,250);
      --
      goto RE_ENTRY_POINT_2a;
      --
    end if;
    --
      if p_new_end_date is not null then
      --
      hr_utility.set_location(l_proc,260);
      --
         set_end_date(p_new_end_date,
                        p_ass_id);
      --
      end if;
    --
    hr_utility.set_location(l_proc,270);
    --
    do_cancel_reterm
      (p_ass_id,
       p_bg_id,
       p_cancel_atd,
       p_cancel_lspd,
       p_reterm_atd,
       p_reterm_lspd);
      --
    hr_utility.set_location(l_proc,280);
    --
    -- bug 5190394 added if condition
    if l_per_sys_st = 'TERM_ASSIGN' and p_val_st_date is not null
       	and (p_old_per_sys_st = l_per_sys_st) then
       null;
    else
      maintain_entries
      (p_upd_mode,
       p_del_mode,
       l_per_sys_st,
       p_sess_date,
       p_val_st_date,
       p_val_end_date,
       p_new_end_date,
       p_ass_id,
       p_bg_id,
       p_old_pay_id,
       p_new_pay_id,
       p_old_pg_id,  -- Added for bug#3924690
       p_new_pg_id,      -- Added for bug#3924690
         l_raise_warning);
    --
    hr_utility.set_location(l_proc,290);
    --
    if l_raise_warning in ('Y','S') then
      --
      hr_utility.set_location(l_proc,300);
      --
      if l_raise_warning = 'Y' then
        --
        hr_utility.set_location(l_proc,310);
        --
            p_warning := 'HR_7016_ASS_ENTRIES_CHANGED';
        --
      else
        --
        hr_utility.set_location(l_proc,320);
        --
            p_warning := 'HR_7442_ASS_SAL_ENT_CHANGED';
        --
      end if;
      --
         p_re_entry_point := 2;
         return;
      --
    end if;
    end if; -- bug 5190394
    --
    <<RE_ENTRY_POINT_2a>>
    --
    hr_utility.set_location(l_proc||' RE_ENTRY_POINT_2a',330);
    --
    if l_per_sys_st = 'TERM_ASSIGN' and
       p_val_st_date is not null then
      --
           if (p_old_per_sys_st <> l_per_sys_st) -- #2404335
           then
      --
               hr_utility.set_location(l_proc,340);

          terminate_entries(l_per_sys_st,
                                 p_ass_id,
                         p_sess_date,
                         p_val_st_date);
            end if;
      --
      hr_utility.set_location(l_proc,350);
      --
        delete_any_pay_proposals(p_ass_id,
                                    p_val_st_date);
      --
      end if;
    --
  end if; -- if l_per_sys_st <> 'END'
  --
  p_re_entry_point := 0;
  --
  -- Set out parameters
  --
  p_future_spp_warning := l_future_spp_warnings;
  --
  -- Payroll Object Group functionality, requires call to
  -- pay_pog_all_assignments_pkg. This is designed to be called from a row
  -- handler user hook, hence has many parameters that are not available here.
  -- So a cursor is used to return the current assignment values, to pass to
  -- the pog procedure. The 'old' values were stored in a global record, as
  -- part of the pre_update_bundle procedure, ready for use here.
  --
      hr_utility.set_location(l_proc,355);

  OPEN asg_details(p_ass_id, p_sess_date);
  FETCH asg_details into cur_asg_rec;
  IF asg_details%NOTFOUND THEN
    CLOSE asg_details;
    hr_utility.trace('no rows for cur_asg_rec');
  ELSE
    CLOSE asg_details;
  END IF;
  --

  hr_utility.set_location(l_proc,357);

  pay_pog_all_assignments_pkg.after_update
  (p_effective_date            => p_sess_date
  ,p_datetrack_mode            => p_upd_mode
  ,p_validation_start_date     => p_val_st_date
  ,p_validation_end_date       => p_val_end_date
  ,P_APPLICANT_RANK            => cur_asg_rec.applicant_rank
  ,P_APPLICATION_ID            => cur_asg_rec.application_id
  ,P_ASSIGNMENT_CATEGORY       => cur_asg_rec.assignment_category
  ,P_ASSIGNMENT_ID             => cur_asg_rec.assignment_id
  ,P_ASSIGNMENT_NUMBER         => cur_asg_rec.assignment_number
  ,P_ASSIGNMENT_STATUS_TYPE_ID => cur_asg_rec.assignment_status_type_id
  ,P_ASSIGNMENT_TYPE           => cur_asg_rec.assignment_type
  ,P_ASS_ATTRIBUTE1            => cur_asg_rec.ass_attribute1
  ,P_ASS_ATTRIBUTE10           => cur_asg_rec.ass_attribute10
  ,P_ASS_ATTRIBUTE11           => cur_asg_rec.ass_attribute11
  ,P_ASS_ATTRIBUTE12           => cur_asg_rec.ass_attribute12
  ,P_ASS_ATTRIBUTE13           => cur_asg_rec.ass_attribute13
  ,P_ASS_ATTRIBUTE14           => cur_asg_rec.ass_attribute14
  ,P_ASS_ATTRIBUTE15           => cur_asg_rec.ass_attribute15
  ,P_ASS_ATTRIBUTE16           => cur_asg_rec.ass_attribute16
  ,P_ASS_ATTRIBUTE17           => cur_asg_rec.ass_attribute17
  ,P_ASS_ATTRIBUTE18           => cur_asg_rec.ass_attribute18
  ,P_ASS_ATTRIBUTE19           => cur_asg_rec.ass_attribute19
  ,P_ASS_ATTRIBUTE2            => cur_asg_rec.ass_attribute2
  ,P_ASS_ATTRIBUTE20           => cur_asg_rec.ass_attribute20
  ,P_ASS_ATTRIBUTE21           => cur_asg_rec.ass_attribute21
  ,P_ASS_ATTRIBUTE22           => cur_asg_rec.ass_attribute22
  ,P_ASS_ATTRIBUTE23           => cur_asg_rec.ass_attribute23
  ,P_ASS_ATTRIBUTE24           => cur_asg_rec.ass_attribute24
  ,P_ASS_ATTRIBUTE25           => cur_asg_rec.ass_attribute25
  ,P_ASS_ATTRIBUTE26           => cur_asg_rec.ass_attribute26
  ,P_ASS_ATTRIBUTE27           => cur_asg_rec.ass_attribute27
  ,P_ASS_ATTRIBUTE28           => cur_asg_rec.ass_attribute28
  ,P_ASS_ATTRIBUTE29           => cur_asg_rec.ass_attribute29
  ,P_ASS_ATTRIBUTE3            => cur_asg_rec.ass_attribute3
  ,P_ASS_ATTRIBUTE30           => cur_asg_rec.ass_attribute30
  ,P_ASS_ATTRIBUTE4            => cur_asg_rec.ass_attribute4
  ,P_ASS_ATTRIBUTE5            => cur_asg_rec.ass_attribute5
  ,P_ASS_ATTRIBUTE6            => cur_asg_rec.ass_attribute6
  ,P_ASS_ATTRIBUTE7            => cur_asg_rec.ass_attribute7
  ,P_ASS_ATTRIBUTE8            => cur_asg_rec.ass_attribute8
  ,P_ASS_ATTRIBUTE9            => cur_asg_rec.ass_attribute9
  ,P_ASS_ATTRIBUTE_CATEGORY    => cur_asg_rec.ass_attribute_category
  ,P_BARGAINING_UNIT_CODE      => cur_asg_rec.bargaining_unit_code
  ,P_CAGR_GRADE_DEF_ID         => cur_asg_rec.cagr_grade_def_id
  ,P_CAGR_ID_FLEX_NUM          => cur_asg_rec.cagr_id_flex_num
  ,P_CHANGE_REASON             => cur_asg_rec.change_reason
  ,P_COLLECTIVE_AGREEMENT_ID   => cur_asg_rec.collective_agreement_id
  ,P_COMMENTS                  => cur_asg_rec.comment_text
  ,P_COMMENT_ID                => cur_asg_rec.comment_id
  ,P_CONTRACT_ID               => cur_asg_rec.contract_id
  ,P_DATE_PROBATION_END        => cur_asg_rec.date_probation_end
  ,P_DEFAULT_CODE_COMB_ID      => cur_asg_rec.default_code_comb_id
  ,P_EFFECTIVE_END_DATE        => cur_asg_rec.effective_end_date
  ,P_EFFECTIVE_START_DATE      => cur_asg_rec.effective_start_date
  ,P_EMPLOYEE_CATEGORY         => cur_asg_rec.employee_category
  ,P_EMPLOYMENT_CATEGORY       => cur_asg_rec.employment_category
  ,P_ESTABLISHMENT_ID          => cur_asg_rec.establishment_id
  ,P_FREQUENCY                 => cur_asg_rec.frequency
  ,P_GRADE_ID                  => cur_asg_rec.grade_id
  ,P_HOURLY_SALARIED_CODE      => cur_asg_rec.hourly_salaried_code
  ,P_HOURLY_SALARIED_WARNING   => null
  ,P_INTERNAL_ADDRESS_LINE     => cur_asg_rec.internal_address_line
  ,P_JOB_ID                    => cur_asg_rec.job_id
  ,P_JOB_POST_SOURCE_NAME      => cur_asg_rec.job_post_source_name
  ,P_LABOUR_UNION_MEMBER_FLAG  => cur_asg_rec.labour_union_member_flag
  ,P_LOCATION_ID               => cur_asg_rec.location_id
  ,P_MANAGER_FLAG              => cur_asg_rec.manager_flag
  ,P_NORMAL_HOURS              => cur_asg_rec.normal_hours
  ,P_NOTICE_PERIOD             => cur_asg_rec.notice_period
  ,P_NOTICE_PERIOD_UOM         => cur_asg_rec.notice_period_uom
  ,P_NO_MANAGERS_WARNING       => null
  ,P_OBJECT_VERSION_NUMBER     => cur_asg_rec.object_version_number
  ,P_ORGANIZATION_ID           => cur_asg_rec.organization_id
  ,P_ORG_NOW_NO_MANAGER_WARNING => null
  ,P_OTHER_MANAGER_WARNING     => null
  ,P_PAYROLL_ID                => cur_asg_rec.payroll_id
  ,P_PAYROLL_ID_UPDATED        => null
  ,P_PAY_BASIS_ID              => cur_asg_rec.pay_basis_id
  ,P_PEOPLE_GROUP_ID           => cur_asg_rec.people_group_id
  ,P_PERF_REVIEW_PERIOD        => cur_asg_rec.perf_review_period
  ,P_PERF_REVIEW_PERIOD_FREQUEN => cur_asg_rec.perf_review_period_frequency
  ,P_PERIOD_OF_SERVICE_ID      => cur_asg_rec.period_of_service_id
  ,P_PERSON_REFERRED_BY_ID     => cur_asg_rec.person_referred_by_id
  ,P_PLACEMENT_DATE_START      => cur_asg_rec.period_of_placement_date_start
  ,P_POSITION_ID               => cur_asg_rec.position_id
  ,P_POSTING_CONTENT_ID        => cur_asg_rec.posting_content_id
  ,P_PRIMARY_FLAG              => cur_asg_rec.primary_flag
  ,P_PROBATION_PERIOD          => cur_asg_rec.probation_period
  ,P_PROBATION_UNIT            => cur_asg_rec.probation_unit
  ,P_PROGRAM_APPLICATION_ID    => cur_asg_rec.program_application_id
  ,P_PROGRAM_ID                => cur_asg_rec.program_id
  ,P_PROGRAM_UPDATE_DATE       => cur_asg_rec.program_update_date
  ,P_PROJECT_TITLE             => cur_asg_rec.project_title
  ,P_RECRUITER_ID              => cur_asg_rec.recruiter_id
  ,P_RECRUITMENT_ACTIVITY_ID   => cur_asg_rec.recruitment_activity_id
  ,P_REQUEST_ID                => cur_asg_rec.request_id
  ,P_SAL_REVIEW_PERIOD         => cur_asg_rec.sal_review_period
  ,P_SAL_REVIEW_PERIOD_FREQUEN => cur_asg_rec.sal_review_period_frequency
  ,P_SET_OF_BOOKS_ID           => cur_asg_rec.set_of_books_id
  ,P_SOFT_CODING_KEYFLEX_ID    => cur_asg_rec.soft_coding_keyflex_id
  ,P_SOURCE_ORGANIZATION_ID    => cur_asg_rec.source_organization_id
  ,P_SOURCE_TYPE               => cur_asg_rec.source_type
  ,P_SPECIAL_CEILING_STEP_ID   => cur_asg_rec.special_ceiling_step_id
  ,P_SUPERVISOR_ID             => cur_asg_rec.supervisor_id
  ,P_TIME_NORMAL_FINISH        => cur_asg_rec.time_normal_finish
  ,P_TIME_NORMAL_START         => cur_asg_rec.time_normal_start
  ,P_TITLE                     => cur_asg_rec.title
  ,P_VACANCY_ID                => cur_asg_rec.vacancy_id
  ,P_VENDOR_ASSIGNMENT_NUMBER  => cur_asg_rec.vendor_assignment_number
  ,P_VENDOR_EMPLOYEE_NUMBER    => cur_asg_rec.vendor_employee_number
  ,P_VENDOR_ID                 => cur_asg_rec.vendor_id
  ,P_WORK_AT_HOME              => cur_asg_rec.work_at_home
  ,P_GRADE_LADDER_PGM_ID       => cur_asg_rec.grade_ladder_pgm_id
  ,P_SUPERVISOR_ASSIGNMENT_ID  => cur_asg_rec.supervisor_assignment_id
  ,P_VENDOR_SITE_ID            => cur_asg_rec.vendor_site_id
  ,P_PO_HEADER_ID              => cur_asg_rec.po_header_id
  ,P_PO_LINE_ID                => cur_asg_rec.po_line_id
  ,P_PROJECTED_ASSIGNMENT_END  => cur_asg_rec.projected_assignment_end
  ,P_APPLICANT_RANK_O
     => per_assignments_f2_pkg.g_old_asg_rec.applicant_rank
  ,P_APPLICATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.application_id
  ,P_ASSIGNMENT_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_category
  ,P_ASSIGNMENT_NUMBER_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_number
  ,P_ASSIGNMENT_SEQUENCE_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_sequence
  ,P_ASSIGNMENT_STATUS_TYPE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_status_type_id
  ,P_ASSIGNMENT_TYPE_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_type
  ,P_ASS_ATTRIBUTE1_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute1
  ,P_ASS_ATTRIBUTE10_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute10
  ,P_ASS_ATTRIBUTE11_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute11
  ,P_ASS_ATTRIBUTE12_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute12
  ,P_ASS_ATTRIBUTE13_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute13
  ,P_ASS_ATTRIBUTE14_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute14
  ,P_ASS_ATTRIBUTE15_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute15
  ,P_ASS_ATTRIBUTE16_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute16
  ,P_ASS_ATTRIBUTE17_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute17
  ,P_ASS_ATTRIBUTE18_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute18
  ,P_ASS_ATTRIBUTE19_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute19
  ,P_ASS_ATTRIBUTE2_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute2
  ,P_ASS_ATTRIBUTE20_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute20
  ,P_ASS_ATTRIBUTE21_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute21
  ,P_ASS_ATTRIBUTE22_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute22
  ,P_ASS_ATTRIBUTE23_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute23
  ,P_ASS_ATTRIBUTE24_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute24
  ,P_ASS_ATTRIBUTE25_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute25
  ,P_ASS_ATTRIBUTE26_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute26
  ,P_ASS_ATTRIBUTE27_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute27
  ,P_ASS_ATTRIBUTE28_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute28
  ,P_ASS_ATTRIBUTE29_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute29
  ,P_ASS_ATTRIBUTE3_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute3
  ,P_ASS_ATTRIBUTE30_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute30
  ,P_ASS_ATTRIBUTE4_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute4
  ,P_ASS_ATTRIBUTE5_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute5
  ,P_ASS_ATTRIBUTE6_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute6
  ,P_ASS_ATTRIBUTE7_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute7
  ,P_ASS_ATTRIBUTE8_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute8
  ,P_ASS_ATTRIBUTE9_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute9
  ,P_ASS_ATTRIBUTE_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute_category
  ,P_BARGAINING_UNIT_CODE_O
     => per_assignments_f2_pkg.g_old_asg_rec.bargaining_unit_code
  ,P_BUSINESS_GROUP_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.business_group_id
  ,P_CAGR_GRADE_DEF_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.cagr_grade_def_id
  ,P_CAGR_ID_FLEX_NUM_O
     => per_assignments_f2_pkg.g_old_asg_rec.cagr_id_flex_num
  ,P_CHANGE_REASON_O
     => per_assignments_f2_pkg.g_old_asg_rec.change_reason
  ,P_COLLECTIVE_AGREEMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.collective_agreement_id
  ,P_COMMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.comment_id
  ,P_CONTRACT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.contract_id
  ,P_DATE_PROBATION_END_O
     => per_assignments_f2_pkg.g_old_asg_rec.date_probation_end
  ,P_DEFAULT_CODE_COMB_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.default_code_comb_id
  ,P_EFFECTIVE_END_DATE_O
     => per_assignments_f2_pkg.g_old_asg_rec.effective_end_date
  ,P_EFFECTIVE_START_DATE_O
     => per_assignments_f2_pkg.g_old_asg_rec.effective_start_date
  ,P_EMPLOYEE_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.employee_category
  ,P_EMPLOYMENT_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.employment_category
  ,P_ESTABLISHMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.establishment_id
  ,P_FREQUENCY_O
     => per_assignments_f2_pkg.g_old_asg_rec.frequency
  ,P_GRADE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.grade_id
  ,P_HOURLY_SALARIED_CODE_O
     => per_assignments_f2_pkg.g_old_asg_rec.hourly_salaried_code
  ,P_INTERNAL_ADDRESS_LINE_O
     => per_assignments_f2_pkg.g_old_asg_rec.internal_address_line
  ,P_JOB_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.job_id
  ,P_JOB_POST_SOURCE_NAME_O
     => per_assignments_f2_pkg.g_old_asg_rec.job_post_source_name
  ,P_LABOUR_UNION_MEMBER_FLAG_O
     => per_assignments_f2_pkg.g_old_asg_rec.labour_union_member_flag
  ,P_LOCATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.location_id
  ,P_MANAGER_FLAG_O
     => per_assignments_f2_pkg.g_old_asg_rec.manager_flag
  ,P_NORMAL_HOURS_O
     => per_assignments_f2_pkg.g_old_asg_rec.normal_hours
  ,P_NOTICE_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.notice_period
  ,P_NOTICE_PERIOD_UOM_O
     => per_assignments_f2_pkg.g_old_asg_rec.notice_period_uom
  ,P_OBJECT_VERSION_NUMBER_O
     => per_assignments_f2_pkg.g_old_asg_rec.object_version_number
  ,P_ORGANIZATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.organization_id
  ,P_PAYROLL_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.payroll_id
  ,P_PAY_BASIS_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.pay_basis_id
  ,P_PEOPLE_GROUP_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.people_group_id
  ,P_PERF_REVIEW_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.perf_review_period
  ,P_PERF_REVIEW_PERIOD_FREQUEN_O
     => per_assignments_f2_pkg.g_old_asg_rec.perf_review_period_frequency
  ,P_PERIOD_OF_SERVICE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.period_of_service_id
  ,P_PERSON_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.person_id
  ,P_PERSON_REFERRED_BY_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.person_referred_by_id
  ,P_PLACEMENT_DATE_START_O
     => per_assignments_f2_pkg.g_old_asg_rec.period_of_placement_date_start
  ,P_POSITION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.position_id
  ,P_POSTING_CONTENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.posting_content_id
  ,P_PRIMARY_FLAG_O
     => per_assignments_f2_pkg.g_old_asg_rec.primary_flag
  ,P_PROBATION_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.probation_period
  ,P_PROBATION_UNIT_O
     => per_assignments_f2_pkg.g_old_asg_rec.probation_unit
  ,P_PROGRAM_APPLICATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.program_application_id
  ,P_PROGRAM_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.program_id
  ,P_PROGRAM_UPDATE_DATE_O
     => per_assignments_f2_pkg.g_old_asg_rec.program_update_date
  ,P_PROJECT_TITLE_O
     => per_assignments_f2_pkg.g_old_asg_rec.project_title
  ,P_RECRUITER_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.recruiter_id
  ,P_RECRUITMENT_ACTIVITY_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.recruitment_activity_id
  ,P_REQUEST_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.request_id
  ,P_SAL_REVIEW_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.sal_review_period
  ,P_SAL_REVIEW_PERIOD_FREQUEN_O
     => per_assignments_f2_pkg.g_old_asg_rec.sal_review_period_frequency
  ,P_SET_OF_BOOKS_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.set_of_books_id
  ,P_SOFT_CODING_KEYFLEX_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.soft_coding_keyflex_id
  ,P_SOURCE_ORGANIZATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.source_organization_id
  ,P_SOURCE_TYPE_O
     => per_assignments_f2_pkg.g_old_asg_rec.source_type
  ,P_SPECIAL_CEILING_STEP_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.special_ceiling_step_id
  ,P_SUPERVISOR_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.supervisor_id
  ,P_TIME_NORMAL_FINISH_O
     => per_assignments_f2_pkg.g_old_asg_rec.time_normal_finish
  ,P_TIME_NORMAL_START_O
     => per_assignments_f2_pkg.g_old_asg_rec.time_normal_start
  ,P_TITLE_O
     => per_assignments_f2_pkg.g_old_asg_rec.title
  ,P_VACANCY_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.vacancy_id
  ,P_VENDOR_ASSIGNMENT_NUMBER_O
     => per_assignments_f2_pkg.g_old_asg_rec.vendor_assignment_number
  ,P_VENDOR_EMPLOYEE_NUMBER_O
     => per_assignments_f2_pkg.g_old_asg_rec.vendor_employee_number
  ,P_VENDOR_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.vendor_id
  ,P_WORK_AT_HOME_O
     => per_assignments_f2_pkg.g_old_asg_rec.work_at_home
  ,P_GRADE_LADDER_PGM_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.grade_ladder_pgm_id
  ,P_SUPERVISOR_ASSIGNMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.supervisor_assignment_id
  ,P_VENDOR_SITE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.vendor_site_id
  ,P_PO_HEADER_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.po_header_id
  ,P_PO_LINE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.po_line_id
  ,P_PROJECTED_ASSIGNMENT_END_O
     => per_assignments_f2_pkg.g_old_asg_rec.projected_assignment_end
  );
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
end post_update;
-----------------------------------------------------------------------------
procedure post_insert(
   p_prim_change_flag   IN OUT NOCOPY varchar2,
   p_val_st_date     date,
   p_new_end_date    date,
   p_eot       date,
   p_pd_os_id     number,
   p_ass_id    number,
   p_new_prim_ass_id IN OUT NOCOPY number,
   p_pg_id        number,
   p_group_name      varchar2,
   p_bg_id        number,
   p_dt_upd_mode     varchar2,
        p_dt_del_mode      varchar2,
        p_per_sys_st    varchar2,
        p_sess_date     date,
         p_val_end_date    date,
   p_new_pay_id      number,
   p_old_pay_id      number,
   p_scl_id    number,
   p_scl_concat      varchar2,
   p_warning      IN OUT NOCOPY varchar2) is
   --
   l_raise_warning      varchar2(1);
  --
  -- Payroll Object Group (POG) functionality.
  --
  ins_asg_rec per_asg_shd.g_rec_type;
  --
  cursor asg_details(p_asg_id number
                    ,p_eff_date date)
  is
  select assignment_id
  ,effective_start_date
  ,effective_end_date
  ,business_group_id
  ,recruiter_id
  ,grade_id
  ,position_id
  ,job_id
  ,assignment_status_type_id
  ,payroll_id
  ,location_id
  ,person_referred_by_id
  ,supervisor_id
  ,special_ceiling_step_id
  ,person_id
  ,recruitment_activity_id
  ,source_organization_id
  ,organization_id
  ,people_group_id
  ,soft_coding_keyflex_id
  ,vacancy_id
  ,pay_basis_id
  ,assignment_sequence
  ,assignment_type
  ,primary_flag
  ,application_id
  ,assignment_number
  ,change_reason
  ,comment_id
  ,null
  ,date_probation_end
  ,default_code_comb_id
  ,employment_category
  ,frequency
  ,internal_address_line
  ,manager_flag
  ,normal_hours
  ,perf_review_period
  ,perf_review_period_frequency
  ,period_of_service_id
  ,probation_period
  ,probation_unit
  ,sal_review_period
  ,sal_review_period_frequency
  ,set_of_books_id
  ,source_type
  ,time_normal_finish
  ,time_normal_start
  ,bargaining_unit_code
  ,labour_union_member_flag
  ,hourly_salaried_code
  ,request_id
  ,program_application_id
  ,program_id
  ,program_update_date
  ,ass_attribute_category
  ,ass_attribute1
  ,ass_attribute2
  ,ass_attribute3
  ,ass_attribute4
  ,ass_attribute5
  ,ass_attribute6
  ,ass_attribute7
  ,ass_attribute8
  ,ass_attribute9
  ,ass_attribute10
  ,ass_attribute11
  ,ass_attribute12
  ,ass_attribute13
  ,ass_attribute14
  ,ass_attribute15
  ,ass_attribute16
  ,ass_attribute17
  ,ass_attribute18
  ,ass_attribute19
  ,ass_attribute20
  ,ass_attribute21
  ,ass_attribute22
  ,ass_attribute23
  ,ass_attribute24
  ,ass_attribute25
  ,ass_attribute26
  ,ass_attribute27
  ,ass_attribute28
  ,ass_attribute29
  ,ass_attribute30
  ,title
  ,object_version_number
  ,contract_id
  ,establishment_id
  ,collective_agreement_id
  ,cagr_grade_def_id
  ,cagr_id_flex_num
  ,notice_period
  ,notice_period_uom
  ,employee_category
  ,work_at_home
  ,job_post_source_name
  ,posting_content_id
  ,period_of_placement_date_start
  ,vendor_id
  ,vendor_employee_number
  ,vendor_assignment_number
  ,assignment_category
  ,project_title
  ,applicant_rank
  ,grade_ladder_pgm_id
  ,supervisor_assignment_id
  ,vendor_site_id
  ,po_header_id
  ,po_line_id
  ,projected_assignment_end
  from per_all_assignments_f
  where assignment_id = p_asg_id
  and   p_eff_date between effective_start_date
                       and effective_end_date;
  --
  l_vsd date;
  l_ved date;
--
l_proc            varchar2(11) :=  'post_insert';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

   if p_prim_change_flag = 'Y' then
      --
      -- Perform primary flag validation / processing.
      --
      iud_update_primary(
         'INSERT',
         'Y',
         p_val_st_date,
         p_new_end_date,
         p_eot,
         p_pd_os_id,
         p_ass_id,
         p_new_prim_ass_id,
         p_prim_change_flag);
      --
      -- NB The above proc may have changed the last 2 parameters.
      --
   end if;
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;
   update_group(
         p_pg_id,
         p_group_name,
                        p_bg_id);
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 20);
  END IF;
   update_scl(
      p_scl_id,
      p_scl_concat);
   --
   -- Now insert assignment budget values from the defaults for this
   -- bg.
   -- NB to_char(0)'s are last_updated_by and last_update_login which
   -- are varchar2 parameters in load_budget_values.
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 30);
  END IF;
   hr_assignment.load_budget_values(
      p_ass_id,
      p_bg_id,
      to_char(0),
      to_char(0),
      p_val_st_date,
      p_eot);
   --
   -- To load default assignment cost allocations
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 40);
  END IF;
        declare
             l_position_id       number;
             --
             cursor c_position is
             select position_id
             from per_all_assignments
             where assignment_id = p_ass_id;
        begin
          --
          open c_position;
          fetch c_position into l_position_id;
          close c_position;
          --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 45);
  END IF;
          hr_assignment.load_assignment_allocation
                                  (p_assignment_id => p_ass_id
                                  ,p_business_group_id => p_bg_id
                                  ,p_effective_date =>p_val_st_date
                                  ,p_position_id => l_position_id);
        end;
   --
   -- Insert element entries for new assignment, 1st 2 parameters are
   -- dt update and delete modes - ensure these are null.
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 50);
  END IF;
   maintain_entries(
      null,
         null,
         p_per_sys_st,
         p_sess_date,
         p_val_st_date,
            p_val_end_date,
         p_new_end_date,
         p_ass_id,
            p_bg_id,
      p_old_pay_id,
      p_new_pay_id,
      null,    -- p_old_pg_id. Added for bug#3924690.
      null,    -- p_new_pg_id. Added for bug#3924690.
      l_raise_warning);
   --
        if l_raise_warning in ('Y','S') then
           if l_raise_warning = 'Y' then
              p_warning := 'HR_7016_ASS_ENTRIES_CHANGED';
           else
              p_warning := 'HR_7442_ASS_SAL_ENT_CHANGED';
           end if;
                   --
   end if;
  --
  -- Payroll Object Group functionality, requires call to
  -- pay_pog_all_assignments_pkg. This is designed to be called from a row
  -- handler user hook, hence has many parameters that are not available here.
  -- So a cursor is used to return the values, to pass to the pog procedure.
  --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 60);
  END IF;
  OPEN asg_details(p_ass_id, p_sess_date);
  FETCH asg_details into ins_asg_rec;
  IF asg_details%NOTFOUND THEN
    CLOSE asg_details;
    hr_utility.trace('no rows for asg_details');
  ELSE
    CLOSE asg_details;
  END IF;
  --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 70);
  END IF;
  dt_api.validate_dt_mode
  (p_effective_date          => p_sess_date
  ,p_datetrack_mode          => 'INSERT'
  ,p_base_table_name         => 'per_all_assignments_f'
  ,p_base_key_column         => 'assignment_id'
  ,p_base_key_value          => p_ass_id
  ,p_validation_start_date   => l_vsd
  ,p_validation_end_date     => l_ved
  );
  --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 80);
  END IF;

  pay_pog_all_assignments_pkg.after_insert
  (p_effective_date             => p_sess_date
  ,p_validation_start_date      => l_vsd
  ,p_validation_end_date        => l_ved
  ,P_APPLICANT_RANK             => ins_asg_rec.applicant_rank
  ,P_APPLICATION_ID             => ins_asg_rec.program_application_id
  ,P_ASSIGNMENT_CATEGORY        => ins_asg_rec.assignment_category
  ,P_ASSIGNMENT_ID              => ins_asg_rec.assignment_id
  ,P_ASSIGNMENT_NUMBER          => ins_asg_rec.assignment_number
  ,P_ASSIGNMENT_SEQUENCE        => ins_asg_rec.assignment_sequence
  ,P_ASSIGNMENT_STATUS_TYPE_ID  => ins_asg_rec.assignment_status_type_id
  ,P_ASSIGNMENT_TYPE            => ins_asg_rec.assignment_type
  ,P_ASS_ATTRIBUTE1             => ins_asg_rec.ass_attribute1
  ,P_ASS_ATTRIBUTE10            => ins_asg_rec.ass_attribute10
  ,P_ASS_ATTRIBUTE11            => ins_asg_rec.ass_attribute11
  ,P_ASS_ATTRIBUTE12            => ins_asg_rec.ass_attribute12
  ,P_ASS_ATTRIBUTE13            => ins_asg_rec.ass_attribute13
  ,P_ASS_ATTRIBUTE14            => ins_asg_rec.ass_attribute14
  ,P_ASS_ATTRIBUTE15            => ins_asg_rec.ass_attribute15
  ,P_ASS_ATTRIBUTE16            => ins_asg_rec.ass_attribute16
  ,P_ASS_ATTRIBUTE17            => ins_asg_rec.ass_attribute17
  ,P_ASS_ATTRIBUTE18            => ins_asg_rec.ass_attribute18
  ,P_ASS_ATTRIBUTE19            => ins_asg_rec.ass_attribute19
  ,P_ASS_ATTRIBUTE2             => ins_asg_rec.ass_attribute2
  ,P_ASS_ATTRIBUTE20            => ins_asg_rec.ass_attribute20
  ,P_ASS_ATTRIBUTE21            => ins_asg_rec.ass_attribute21
  ,P_ASS_ATTRIBUTE22            => ins_asg_rec.ass_attribute22
  ,P_ASS_ATTRIBUTE23            => ins_asg_rec.ass_attribute23
  ,P_ASS_ATTRIBUTE24            => ins_asg_rec.ass_attribute24
  ,P_ASS_ATTRIBUTE25            => ins_asg_rec.ass_attribute25
  ,P_ASS_ATTRIBUTE26            => ins_asg_rec.ass_attribute26
  ,P_ASS_ATTRIBUTE27            => ins_asg_rec.ass_attribute27
  ,P_ASS_ATTRIBUTE28            => ins_asg_rec.ass_attribute28
  ,P_ASS_ATTRIBUTE29            => ins_asg_rec.ass_attribute29
  ,P_ASS_ATTRIBUTE3             => ins_asg_rec.ass_attribute3
  ,P_ASS_ATTRIBUTE30            => ins_asg_rec.ass_attribute30
  ,P_ASS_ATTRIBUTE4             => ins_asg_rec.ass_attribute4
  ,P_ASS_ATTRIBUTE5             => ins_asg_rec.ass_attribute5
  ,P_ASS_ATTRIBUTE6             => ins_asg_rec.ass_attribute6
  ,P_ASS_ATTRIBUTE7             => ins_asg_rec.ass_attribute7
  ,P_ASS_ATTRIBUTE8             => ins_asg_rec.ass_attribute8
  ,P_ASS_ATTRIBUTE9             => ins_asg_rec.ass_attribute9
  ,P_ASS_ATTRIBUTE_CATEGORY     => ins_asg_rec.ass_attribute_category
  ,P_BARGAINING_UNIT_CODE       => ins_asg_rec.bargaining_unit_code
  ,P_BUSINESS_GROUP_ID          => ins_asg_rec.business_group_id
  ,P_CAGR_GRADE_DEF_ID          => ins_asg_rec.cagr_grade_def_id
  ,P_CAGR_ID_FLEX_NUM           => ins_asg_rec.cagr_id_flex_num
  ,P_CHANGE_REASON              => ins_asg_rec.change_reason
  ,P_COLLECTIVE_AGREEMENT_ID    => ins_asg_rec.collective_agreement_id
  ,P_COMMENT_ID                 => ins_asg_rec.comment_id
  ,P_CONTRACT_ID                => ins_asg_rec.contract_id
  ,P_DATE_PROBATION_END         => ins_asg_rec.date_probation_end
  ,P_DEFAULT_CODE_COMB_ID       => ins_asg_rec.default_code_comb_id
  ,P_EFFECTIVE_END_DATE         => ins_asg_rec.effective_end_date
  ,P_EFFECTIVE_START_DATE       => ins_asg_rec.effective_start_date
  ,P_EMPLOYEE_CATEGORY          => ins_asg_rec.employee_category
  ,P_EMPLOYMENT_CATEGORY        => ins_asg_rec.employment_category
  ,P_ESTABLISHMENT_ID           => ins_asg_rec.establishment_id
  ,P_FREQUENCY                  => ins_asg_rec.frequency
  ,P_GRADE_ID                   => ins_asg_rec.grade_id
  ,P_HOURLY_SALARIED_CODE       => ins_asg_rec.hourly_salaried_code
  ,P_INTERNAL_ADDRESS_LINE      => ins_asg_rec.internal_address_line
  ,P_JOB_ID                     => ins_asg_rec.job_id
  ,P_JOB_POST_SOURCE_NAME       => ins_asg_rec.job_post_source_name
  ,P_LABOUR_UNION_MEMBER_FLAG   => ins_asg_rec.labour_union_member_flag
  ,P_LOCATION_ID                => ins_asg_rec.location_id
  ,P_MANAGER_FLAG               => ins_asg_rec.manager_flag
  ,P_NORMAL_HOURS               => ins_asg_rec.normal_hours
  ,P_NOTICE_PERIOD              => ins_asg_rec.notice_period
  ,P_NOTICE_PERIOD_UOM          => ins_asg_rec.notice_period_uom
  ,P_OBJECT_VERSION_NUMBER      => ins_asg_rec.object_version_number
  ,P_ORGANIZATION_ID            => ins_asg_rec.organization_id
  ,P_PAYROLL_ID                 => ins_asg_rec.payroll_id
  ,P_PAY_BASIS_ID               => ins_asg_rec.pay_basis_id
  ,P_PEOPLE_GROUP_ID            => ins_asg_rec.people_group_id
  ,P_PERF_REVIEW_PERIOD         => ins_asg_rec.perf_review_period
  ,P_PERF_REVIEW_PERIOD_FREQUEN => ins_asg_rec.perf_review_period_frequency
  ,P_PERIOD_OF_SERVICE_ID       => ins_asg_rec.period_of_service_id
  ,P_PERSON_ID                  => ins_asg_rec.person_id
  ,P_PERSON_REFERRED_BY_ID      => ins_asg_rec.person_referred_by_id
  ,P_PLACEMENT_DATE_START       => ins_asg_rec.period_of_placement_date_start
  ,P_POSITION_ID                => ins_asg_rec.position_id
  ,P_POSTING_CONTENT_ID         => ins_asg_rec.posting_content_id
  ,P_PRIMARY_FLAG               => ins_asg_rec.primary_flag
  ,P_PROBATION_PERIOD           => ins_asg_rec.probation_period
  ,P_PROBATION_UNIT             => ins_asg_rec.probation_unit
  ,P_PROGRAM_APPLICATION_ID     => ins_asg_rec.program_application_id
  ,P_PROGRAM_ID                 => ins_asg_rec.program_id
  ,P_PROGRAM_UPDATE_DATE        => ins_asg_rec.program_update_date
  ,P_PROJECT_TITLE              => ins_asg_rec.project_title
  ,P_RECRUITER_ID               => ins_asg_rec.recruiter_id
  ,P_RECRUITMENT_ACTIVITY_ID    => ins_asg_rec.recruitment_activity_id
  ,P_REQUEST_ID                 => ins_asg_rec.request_id
  ,P_SAL_REVIEW_PERIOD          => ins_asg_rec.sal_review_period
  ,P_SAL_REVIEW_PERIOD_FREQUEN  => ins_asg_rec.sal_review_period_frequency
  ,P_SET_OF_BOOKS_ID            => ins_asg_rec.set_of_books_id
  ,P_SOFT_CODING_KEYFLEX_ID     => ins_asg_rec.soft_coding_keyflex_id
  ,P_SOURCE_ORGANIZATION_ID     => ins_asg_rec.source_organization_id
  ,P_SOURCE_TYPE                => ins_asg_rec.source_type
  ,P_SPECIAL_CEILING_STEP_ID    => ins_asg_rec.special_ceiling_step_id
  ,P_SUPERVISOR_ID              => ins_asg_rec.supervisor_id
  ,P_TIME_NORMAL_FINISH         => ins_asg_rec.time_normal_finish
  ,P_TIME_NORMAL_START          => ins_asg_rec.time_normal_start
  ,P_TITLE                      => ins_asg_rec.title
  ,P_VACANCY_ID                 => ins_asg_rec.vacancy_id
  ,P_VENDOR_ASSIGNMENT_NUMBER   => ins_asg_rec.vendor_assignment_number
  ,P_VENDOR_EMPLOYEE_NUMBER     => ins_asg_rec.vendor_employee_number
  ,P_VENDOR_ID                  => ins_asg_rec.vendor_id
  ,P_WORK_AT_HOME               => ins_asg_rec.work_at_home
  ,P_GRADE_LADDER_PGM_ID        => ins_asg_rec.grade_ladder_pgm_id
  ,P_SUPERVISOR_ASSIGNMENT_ID   => ins_asg_rec.supervisor_assignment_id
  ,P_VENDOR_SITE_ID             => ins_asg_rec.vendor_site_id
  ,P_PO_HEADER_ID               => ins_asg_rec.po_header_id
  ,P_PO_LINE_ID                 => ins_asg_rec.po_line_id
  ,P_PROJECTED_ASSIGNMENT_END   => ins_asg_rec.projected_assignment_end
  );
  IF g_debug THEN
    hr_utility.set_location( 'Leaving ' || g_package || l_proc, 10);
  END IF;

end post_insert;
-----------------------------------------------------------------------------
procedure post_delete(
   p_ass_id    number,
   p_grd_id    number,
   p_sess_date    date,
   p_new_end_date    date,
   p_val_end_date    date,
   p_eff_end_date    date,
   p_del_mode     varchar2,
   p_val_st_date     date,
   p_new_prim_flag      varchar2,
   p_eot       date,
   p_pd_os_id     number,
   p_new_prim_ass_id IN OUT NOCOPY number,
   p_prim_change_flag   IN OUT NOCOPY varchar2,
   p_per_sys_st      varchar2,
   p_bg_id        number,
   p_old_pay_id      number,
   p_new_pay_id      number,
   p_cancel_atd      date,
        p_cancel_lspd      date,
        p_reterm_atd    date,
        p_reterm_lspd      date,
   p_warning      IN OUT NOCOPY varchar2,
   p_future_spp_warning OUT NOCOPY boolean,
   p_cost_warning          OUT NOCOPY boolean) is
   l_raise_warning      varchar2(1);
   l_calling_proc    varchar2(30);
   l_future_spp_warnings   boolean;
 l_dummy_warning         boolean;
   l_Cost_warning          boolean;
 --
 l_proc VARCHAR2(72) := g_package||'post_delete';
 --
  -- Payroll Object Group functionality. Not all the values required for call
  -- to pay_pog_all_assignments_pkg are available, so cursor is used to get the
  -- values.
  --
  cursor cur_asg_details(p_asg_id number
                        ,p_eff_date date)
  is
  select effective_start_date
  ,      object_version_number
  ,      business_group_id
  from   per_all_assignments_f
  where  assignment_id = p_asg_id
  and    p_eff_date between effective_start_date
                        and effective_end_date;
  --
  l_esd date;
  l_ovn number;
  l_bg_id number;
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  --
  hr_assignment_internal.maintain_spp_asg
    (p_assignment_id                => p_ass_id
    ,p_datetrack_mode               => p_del_mode
    ,p_validation_start_date        => p_val_st_Date
    ,p_validation_end_date          => p_val_end_date
    ,p_grade_id                           => p_grd_id
    ,p_spp_delete_warning           => l_future_spp_warnings);
  --
  hr_utility.set_location(l_proc,20);
  --
    if p_del_mode in ('FUTURE_CHANGE', 'DELETE_NEXT_CHANGE') then
        --
        l_calling_proc := 'POST_DELETE';
        --
    hr_utility.set_location(l_proc||' / '||p_del_mode,30);
    --
      future_del_cleanup
      (p_ass_id,
       p_grd_id,
       p_sess_date,
             l_calling_proc,
       p_val_st_date,
       p_val_end_date,
           p_del_mode,
             l_dummy_warning);
    --
        if p_new_end_date is null then
            --
            if p_val_end_date = p_eot then
                --
                tidy_up_ref_int(
                              'FUTURE',
                              p_sess_date,
                              p_new_end_date,
                              p_val_end_date,
                              p_eff_end_date,
                              p_ass_id,
                                    l_cost_warning);
        --
          end if;
      --
      else
      --
            l_calling_proc := 'POST_DELETE';
      --
            hr_utility.set_location(l_proc,40);

            hr_assignment.del_ref_int_delete(
               p_ass_id,
               p_grd_id,
               'END',
               p_new_end_date,
                0, 0,
                l_calling_proc,
                p_val_st_date,
                p_val_end_date,
               p_del_mode,
              l_dummy_warning);
            --
            -- NB l_cost_warning is not set in this sceanrio. It
            -- is only used if mode is FUTURE.
            --
            tidy_up_ref_int
        ('INT-END',
         p_sess_date,
         p_new_end_date,
         p_val_end_date,
         p_eff_end_date,
         p_ass_id,
            l_cost_warning);
            --
      end if;
        --
    elsif p_del_mode = 'ZAP' then
      --
        -- Delete any of the assignments' children records.
        -- Warn the user that any associated assignment status,
      -- nonrecurring entry, or recurring entry records will be
      -- deleted, and prompt the user to continue. Then delete any
      -- such records. Checks are performed to ensure that
      -- nonrecurring or recurring entry records exist before
      -- deleting them, as this improves performance.
        --
      l_calling_proc := 'POST_DELETE';
    --
      hr_utility.set_location(l_proc,50);

      hr_assignment.del_ref_int_delete(
            p_ass_id,
            null,
            'ZAP',
            p_val_st_date,
            0, 0,
            l_calling_proc,
            p_val_st_date,
            p_val_end_date,
            p_del_mode,
            l_dummy_warning);
    --
  end if;
   --
    if p_prim_change_flag = 'Y' then
    --
        hr_utility.set_location(l_proc,60);

        iud_update_primary(
                        p_del_mode,
                        p_new_prim_flag,
                        p_val_st_date,
                        p_new_end_date,
                        p_eot,
                        p_pd_os_id,
                        p_ass_id,
                        p_new_prim_ass_id,
                        p_prim_change_flag);
    --
    end if;
   --
    --  If TERM_ASSIGN statuses were removed or if the END status was
    --  overridden then a new end date may need to be set. This was
    --  determined in the HR_ASSIGNMENT.CHECK_TERM server-side pkg
    --  called from the CHECK_TERM_BY_POS call (in
    --  update_and_delete_bundle) and a value for the new end date will
    --  have been put in P_NEW_END_DATE.
    --
    if p_del_mode in ('DELETE_NEXT_CHANGE', 'FUTURE_CHANGE') then
    --
      if p_new_end_date is not null then
      --
            set_end_date
        (p_new_end_date,
         p_ass_id);
      --
      end if;
    --
    end if;
    --
    hr_utility.set_location(l_proc,70);

    do_cancel_reterm(
         p_ass_id,
         p_bg_id,
         p_cancel_atd,
         p_cancel_lspd,
         p_reterm_atd,
         p_reterm_lspd);
    --
    -- Pass null p_upd_mode.
    --
    hr_utility.set_location(l_proc,80);

    maintain_entries
    (null,
      p_del_mode,
      p_per_sys_st,
      p_sess_date,
      p_val_st_date,
      p_val_end_date,
      p_new_end_date,
      p_ass_id,
      p_bg_id,
      p_old_pay_id,
      p_new_pay_id,
      null,    -- p_old_pg_id. Added for bug#3924690.
      null,    -- p_new_pg_id. Added for bug#3924690.
         l_raise_warning);
    --
    if l_raise_warning in ('Y','S') then
    --
    if l_raise_warning = 'Y' then
      --
         p_warning := 'HR_7016_ASS_ENTRIES_CHANGED';
      --
    else
      --
         p_warning := 'HR_7442_ASS_SAL_ENT_CHANGED';
      --
    end if;
    --
  end if;
  --
    p_cost_warning := l_cost_warning;
  p_future_spp_warning := l_future_spp_warnings;
      --
  --
  -- Payroll Object Group functionality, requires call to
  -- pay_pog_all_assignments_pkg. This is designed to be called from a row
  -- handler user hook, hence has many parameters that are not available here.
  -- So a cursor is used to return those values that are not available to this
  -- procedure. The 'old' values have been selected into a record in the
  -- pre_delete procedure
  --
  hr_utility.set_location(l_proc,90);
  OPEN cur_asg_details(p_ass_id, p_sess_date);
  FETCH cur_asg_details into l_esd, l_ovn, l_bg_id;
  IF cur_asg_details%NOTFOUND THEN
    CLOSE cur_asg_details;
    hr_utility.trace('no rows from cur_asg_details');
    --
    -- if ZAP mode no rows returned, setup l_ovn and l_esd
    --
    IF p_del_mode = 'ZAP' THEN
      l_ovn := per_assignments_f2_pkg.g_old_asg_rec.object_version_number;
      l_esd := per_assignments_f2_pkg.g_old_asg_rec.effective_start_date;
    ELSE
      hr_utility.trace('Not zap - error');
    END IF;
  ELSE
    CLOSE cur_asg_details;
  END IF;
  --
  -- call temporary POG package
  --
  hr_utility.set_location(l_proc,100);
  pay_pog_all_assignments_pkg.after_delete
  (p_effective_date               => p_sess_date
  ,p_datetrack_mode               => p_del_mode
  ,p_validation_start_date        => p_val_st_date
  ,p_validation_end_date          => p_val_end_date
  ,P_ASSIGNMENT_ID                => p_ass_id
  ,P_EFFECTIVE_END_DATE           => p_eff_end_date
  ,P_EFFECTIVE_START_DATE         => l_esd
  ,P_OBJECT_VERSION_NUMBER        => l_ovn
  ,P_ORG_NOW_NO_MANAGER_WARNING   => null
  ,P_APPLICANT_RANK_O
     => per_assignments_f2_pkg.g_old_asg_rec.applicant_rank
  ,P_APPLICATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.application_id
  ,P_ASSIGNMENT_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_category
  ,P_ASSIGNMENT_NUMBER_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_number
  ,P_ASSIGNMENT_SEQUENCE_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_sequence
  ,P_ASSIGNMENT_STATUS_TYPE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_status_type_id
  ,P_ASSIGNMENT_TYPE_O
     => per_assignments_f2_pkg.g_old_asg_rec.assignment_type
  ,P_ASS_ATTRIBUTE1_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute1
  ,P_ASS_ATTRIBUTE10_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute10
  ,P_ASS_ATTRIBUTE11_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute11
  ,P_ASS_ATTRIBUTE12_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute12
  ,P_ASS_ATTRIBUTE13_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute13
  ,P_ASS_ATTRIBUTE14_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute14
  ,P_ASS_ATTRIBUTE15_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute15
  ,P_ASS_ATTRIBUTE16_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute16
  ,P_ASS_ATTRIBUTE17_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute17
  ,P_ASS_ATTRIBUTE18_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute18
  ,P_ASS_ATTRIBUTE19_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute19
  ,P_ASS_ATTRIBUTE2_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute2
  ,P_ASS_ATTRIBUTE20_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute20
  ,P_ASS_ATTRIBUTE21_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute21
  ,P_ASS_ATTRIBUTE22_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute22
  ,P_ASS_ATTRIBUTE23_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute23
  ,P_ASS_ATTRIBUTE24_O
    => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute24
  ,P_ASS_ATTRIBUTE25_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute25
  ,P_ASS_ATTRIBUTE26_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute26
  ,P_ASS_ATTRIBUTE27_O
    => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute27
  ,P_ASS_ATTRIBUTE28_O
    => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute28
  ,P_ASS_ATTRIBUTE29_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute29
  ,P_ASS_ATTRIBUTE3_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute3
  ,P_ASS_ATTRIBUTE30_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute30
  ,P_ASS_ATTRIBUTE4_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute4
  ,P_ASS_ATTRIBUTE5_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute5
  ,P_ASS_ATTRIBUTE6_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute6
  ,P_ASS_ATTRIBUTE7_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute7
  ,P_ASS_ATTRIBUTE8_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute8
  ,P_ASS_ATTRIBUTE9_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute9
  ,P_ASS_ATTRIBUTE_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.ass_attribute_category
  ,P_BARGAINING_UNIT_CODE_O
     => per_assignments_f2_pkg.g_old_asg_rec.bargaining_unit_code
  ,P_BUSINESS_GROUP_ID_O
     => p_bg_id
  ,P_CAGR_GRADE_DEF_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.cagr_grade_def_id
  ,P_CAGR_ID_FLEX_NUM_O
     => per_assignments_f2_pkg.g_old_asg_rec.cagr_id_flex_num
  ,P_CHANGE_REASON_O
     => per_assignments_f2_pkg.g_old_asg_rec.change_reason
  ,P_COLLECTIVE_AGREEMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.collective_agreement_id
  ,P_COMMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.comment_id
  ,P_CONTRACT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.contract_id
  ,P_DATE_PROBATION_END_O
     => per_assignments_f2_pkg.g_old_asg_rec.date_probation_end
  ,P_DEFAULT_CODE_COMB_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.default_code_comb_id
  ,P_EFFECTIVE_END_DATE_O
     => per_assignments_f2_pkg.g_old_asg_rec.effective_end_date
  ,P_EFFECTIVE_START_DATE_O
     => per_assignments_f2_pkg.g_old_asg_rec.effective_start_date
  ,P_EMPLOYEE_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.employee_category
  ,P_EMPLOYMENT_CATEGORY_O
     => per_assignments_f2_pkg.g_old_asg_rec.employment_category
  ,P_ESTABLISHMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.establishment_id
  ,P_FREQUENCY_O
     => per_assignments_f2_pkg.g_old_asg_rec.frequency
  ,P_GRADE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.grade_id
  ,P_HOURLY_SALARIED_CODE_O
     => per_assignments_f2_pkg.g_old_asg_rec.hourly_salaried_code
  ,P_INTERNAL_ADDRESS_LINE_O
     => per_assignments_f2_pkg.g_old_asg_rec.internal_address_line
  ,P_JOB_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.job_id
  ,P_JOB_POST_SOURCE_NAME_O
     => per_assignments_f2_pkg.g_old_asg_rec.job_post_source_name
  ,P_LABOUR_UNION_MEMBER_FLAG_O
     => per_assignments_f2_pkg.g_old_asg_rec.labour_union_member_flag
  ,P_LOCATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.location_id
  ,P_MANAGER_FLAG_O
     => per_assignments_f2_pkg.g_old_asg_rec.manager_flag
  ,P_NORMAL_HOURS_O
     => per_assignments_f2_pkg.g_old_asg_rec.normal_hours
  ,P_NOTICE_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.notice_period
  ,P_NOTICE_PERIOD_UOM_O
     => per_assignments_f2_pkg.g_old_asg_rec.notice_period_uom
  ,P_OBJECT_VERSION_NUMBER_O
     => per_assignments_f2_pkg.g_old_asg_rec.object_version_number
  ,P_ORGANIZATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.organization_id
  ,P_PAYROLL_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.payroll_id
  ,P_PAY_BASIS_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.pay_basis_id
  ,P_PEOPLE_GROUP_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.people_group_id
  ,P_PERF_REVIEW_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.perf_review_period
  ,P_PERF_REVIEW_PERIOD_FREQUEN_O
     => per_assignments_f2_pkg.g_old_asg_rec.perf_review_period_frequency
  ,P_PERIOD_OF_SERVICE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.period_of_service_id
  ,P_PERSON_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.person_id
  ,P_PERSON_REFERRED_BY_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.person_referred_by_id
  ,P_PLACEMENT_DATE_START_O
     => per_assignments_f2_pkg.g_old_asg_rec.period_of_placement_date_start
  ,P_POSITION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.position_id
  ,P_POSTING_CONTENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.posting_content_id
  ,P_PRIMARY_FLAG_O
     => per_assignments_f2_pkg.g_old_asg_rec.primary_flag
  ,P_PROBATION_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.probation_period
  ,P_PROBATION_UNIT_O
     => per_assignments_f2_pkg.g_old_asg_rec.probation_unit
  ,P_PROGRAM_APPLICATION_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.program_application_id
  ,P_PROGRAM_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.program_id
  ,P_PROGRAM_UPDATE_DATE_O
     => per_assignments_f2_pkg.g_old_asg_rec.program_update_date
  ,P_PROJECT_TITLE_O
     => per_assignments_f2_pkg.g_old_asg_rec.project_title
  ,P_RECRUITER_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.recruiter_id
  ,P_RECRUITMENT_ACTIVITY_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.recruitment_activity_id
  ,P_REQUEST_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.request_id
  ,P_SAL_REVIEW_PERIOD_O
     => per_assignments_f2_pkg.g_old_asg_rec.sal_review_period
  ,P_SAL_REVIEW_PERIOD_FREQUEN_O
     => per_assignments_f2_pkg.g_old_asg_rec.sal_review_period_frequency
  ,P_SET_OF_BOOKS_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.set_of_books_id
  ,P_SOFT_CODING_KEYFLEX_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.soft_coding_keyflex_id
  ,P_SOURCE_ORGANIZATION_ID_O
    => per_assignments_f2_pkg.g_old_asg_rec.source_organization_id
  ,P_SOURCE_TYPE_O
     => per_assignments_f2_pkg.g_old_asg_rec.source_type
  ,P_SPECIAL_CEILING_STEP_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.special_ceiling_step_id
  ,P_SUPERVISOR_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.supervisor_id
  ,P_TIME_NORMAL_FINISH_O
     => per_assignments_f2_pkg.g_old_asg_rec.time_normal_finish
  ,P_TIME_NORMAL_START_O
     => per_assignments_f2_pkg.g_old_asg_rec.time_normal_start
  ,P_TITLE_O
     => per_assignments_f2_pkg.g_old_asg_rec.title
  ,P_VACANCY_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.vacancy_id
  ,P_VENDOR_ASSIGNMENT_NUMBER_O
     => per_assignments_f2_pkg.g_old_asg_rec.vendor_assignment_number
  ,P_VENDOR_EMPLOYEE_NUMBER_O
    => per_assignments_f2_pkg.g_old_asg_rec.vendor_employee_number
  ,P_VENDOR_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.vendor_id
  ,P_WORK_AT_HOME_O
     => per_assignments_f2_pkg.g_old_asg_rec.work_at_home
  ,P_GRADE_LADDER_PGM_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.grade_ladder_pgm_id
  ,P_SUPERVISOR_ASSIGNMENT_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.supervisor_assignment_id
  ,P_VENDOR_SITE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.vendor_site_id
  ,P_PO_HEADER_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.po_header_id
  ,P_PO_LINE_ID_O
     => per_assignments_f2_pkg.g_old_asg_rec.po_line_id
  ,P_PROJECTED_ASSIGNMENT_END_O
     => per_assignments_f2_pkg.g_old_asg_rec.projected_assignment_end
  );
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
end post_delete;
-----------------------------------------------------------------------------
END PER_ASSIGNMENTS_F1_PKG;

/
