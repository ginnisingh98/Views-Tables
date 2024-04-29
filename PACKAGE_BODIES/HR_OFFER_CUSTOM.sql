--------------------------------------------------------
--  DDL for Package Body HR_OFFER_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OFFER_CUSTOM" as
/* $Header: hrcustwf.pkb 120.3 2006/01/17 00:05:11 sturlapa noship $ */
--
  g_package      varchar2(31)   := 'hr_offer_custom.';
  --c_title        hr_util_web.g_title%type;
  --c_prompts      hr_util_web.g_prompts%type;
--
-- ----------------------------------------------------------------------------
-- This is the generic product version
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_wf_question_status >----------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns a boolean answer depending on whether an active
-- workflow exists for the question about to be changed.
--
function check_wf_question_status (p_proposal_question_name in varchar2)
                                   return boolean is
--
l_count     number;
--
Begin
--
  Select count(*)
  Into   l_count
  From   per_assign_proposal_answers papa
  Where  papa.proposal_question_name = p_proposal_question_name
  and exists
       (Select *
    From    wf_item_activity_statuses wf
    Where   wf.item_key         = papa.assignment_id
    And wf.item_type        = 'HR_OFFER'
    And wf.activity_status  = 'ACTIVE'
       );
--
if l_count > 0 then     -- the question exists in an active workflow
 return (TRUE);
else
 return (FALSE);
end if;
--
end check_wf_question_status;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_hr_routing1 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of an HR representative that handles the New
-- Hire Process and that maintains the organizational hierarchy.
--
-- This is used for routing in the Web Offers workflow, 'Offer Letter'.
--
function get_hr_routing1
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  -- We return the Hr Assistant id that handles the New Hire process
  return(999999);
end get_hr_routing1;
-- ----------------------------------------------------------------------------
-- |------------------------------< get_hr_routing2 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of an HR representative that would terminate
-- applicants and mail out offer letters.
--
-- This is used for routing in the Web Offers workflow, 'Offer Letter'.
--
function get_hr_routing2
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  -- We return a specific id that handles Mailing the letter,
  -- waiting for the candidate's response, and terminating the applicant
  -- if needed.
  return(999998);
end get_hr_routing2;
-- ----------------------------------------------------------------------------
-- |------------------------------< get_hr_routing3 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a technical HR employee that could check the
-- approval chain for errors.
--
-- This is used for routing in the Web Offers workflow, 'Offer Letter'.
--
function get_hr_routing3
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  -- We return a specific id that handles database/system errors
  return(999997);
end get_hr_routing3;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_candidate_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure retuns the Person Id, Applicant Number and Display Name
-- (as first_name||last_name) of the Candidate.
--
procedure get_candidate_details
     (p_candidate_assignment_id in     per_assignments_f.assignment_id%type
     ,p_candidate_person_id        out nocopy per_people_f.person_id%type
     ,p_candidate_disp_name        out nocopy varchar2
     ,p_applicant_number           out nocopy per_people_f.applicant_number%type) is
--
  cursor csr_pp(l_effective_date in date) is
           select  ppf.person_id
                  ,ppf.first_name||' '||ppf.last_name
                  ,ppf.applicant_number
           from    per_all_people_f      ppf
                  ,per_all_assignments_f paf
           where   paf.assignment_id = p_candidate_assignment_id
           and     l_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date
           and     ppf.person_id     = paf.person_id
           and     l_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date;
--
begin
  -- open the candidate select cursor
  open csr_pp(trunc(sysdate));
  -- fetch the candidate details
  fetch csr_pp
  into  p_candidate_person_id
       ,p_candidate_disp_name
       ,p_applicant_number;
  if csr_pp%notfound then
    -- if the cursor does not return a row then we must set the out
    -- parameters to null
    p_candidate_person_id := null;
    p_candidate_disp_name := null;
    p_applicant_number    := null;
  end if;
  -- close the cursor
  close csr_pp;
  --
end get_candidate_details;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_hr_manager_details >-----------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of an HR manager that the candidate may want to
-- contact for more information.  This appears on the offer letter.
--
function get_hr_manager_details
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
begin
  -- [CUSTOMIZE]
  -- This function will need to be modified by the end customer.
  -- Presently p_person_id is returned.
  -- return(p_person_id);
  return(999996);
end get_hr_manager_details;
-- ----------------------------------------------------------------------------
-- |---------------------< set_training_admin_person >-----------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a Training Manager.
--
function set_training_admin_person
         return number is
l_training_admin_person number;
begin

  -- Bug#1425440 hdshah Read default training administrator from profile instead of hard-coded value.
  l_training_admin_person :=  fnd_profile.value('OTA_SS_DEFAULT_TRAINING_ADMINISTRATOR');
  return l_training_admin_person;
  --  return(9686);
end set_training_admin_person;
-- ----------------------------------------------------------------------------
-- |---------------------< set_supervisor_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the Id of a supervisor.
--
function set_supervisor_id (p_person_id in per_all_people_f.person_id%type)
         return per_all_people_f.person_id%type is
--
cursor csr_supervisor_id is
  select  a.supervisor_id
  from    per_all_assignments_f a
  where   a.person_id = p_person_id
  and     a.primary_flag = 'Y'
  and a.assignment_type in ('E','C')
  and     trunc(sysdate)
  between a.effective_start_date and effective_end_date;
 -- Fix 2883914 - Filter benifits records from the cursor.
--
l_supervisor_id number;
--
BEGIN
  OPEN csr_supervisor_id;
  FETCH csr_supervisor_id into l_supervisor_id;
    If csr_supervisor_id%notfound then
      l_supervisor_id := null;
    END IF;
  CLOSE csr_supervisor_id;

  return(l_supervisor_id);
END set_supervisor_id ;


-- ----------------------------------------------------------------------------
-- |-----------------------------< get_next_approver >------------------------|
-- ----------------------------------------------------------------------------
--
-- This function goes up the approval chain to determine who is the next
-- manager to approve the offer.  This is used in:
--   Routing in the Web Offers workflow, 'Offer Letter'.
--   Security checks on the web pages (to determine who may see which offers),
--            (via check-if-in-approval-chain).
--   Get VP name to get the vice president's name to display on the Offer Page.
--   Get signatory details to decide who needs to sign the offer letter.
--
function get_next_approver
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type is
--
  cursor csr_pa(l_effective_date in date
               ,l_in_person_id   in per_people_f.person_id%type) is
    select  ppf.person_id
    from    per_all_assignments_f paf
           ,per_all_people_f      ppf
    where   paf.person_id             = l_in_person_id
    and     paf.primary_flag          = 'Y'
    and     l_effective_date
    between paf.effective_start_date
    and     paf.effective_end_date
    and     ppf.person_id             = paf.supervisor_id
    and     ppf.current_employee_flag = 'Y'
    and     l_effective_date
    between ppf.effective_start_date
    and     ppf.effective_end_date;
--
  l_out_person_id per_people_f.person_id%type default null;
--
begin
  -- [CUSTOMIZE]
  -- open the candidate select cursor
  open csr_pa(trunc(sysdate), p_person_id);
  -- fetch the candidate details
  fetch csr_pa into l_out_person_id;
  if csr_pa%notfound then
    -- if the cursor does not return a row then we must set the out
    -- parameter to null
    l_out_person_id := null;
  end if;
  --
  -- close the cursor
  close csr_pa;
  return(l_out_person_id);
end get_next_approver;
-- ------------------------------------------------------------------------
-- |---------------------< get_url_string >----------------------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--   This procedure returns the url string needed to build up urls when
--   running disconnected from the web server (such as from email for
--   workflow notifications).
-- ------------------------------------------------------------------------
function get_url_string
         return varchar2 is
  l_owa2        varchar2(2000);
begin
  l_owa2 := fnd_profile.value('APPS_WEB_AGENT');
  return l_owa2;
end get_url_string;
-- ------------------------------------------------------------------------
-- name:
--   get_vp_name
-- description:
--   This procedure obtains the name of the Vice President that the
--   candidate will report to.  It goes up the approval chain for a
--   candidate and finds the first person with a job name like '%Vice%'
--   Obviously this won't work in the police field.
--
--   This name displays on the Update Offer Web Page.
-- requirement:
--   insert a row into fnd_sessions before calling
-- ------------------------------------------------------------------------
procedure get_vp_name
      (p_assignment_id      in  number
      ,p_vp_name            out nocopy varchar2
      ,p_job_name           out nocopy varchar2) is
--
  l_proc_name  varchar2(200) default 'get_vp_name';
--
  cursor csr_papa is
    select distinct papa.person_id, pj.name
    from   per_jobs_tl                  pj
           ,per_assignments             pa
           ,per_assign_proposal_answers papa
    where  pj.job_id          = pa.job_id
      and  pj.language=userenv('LANG')
      and  pa.primary_flag    = 'Y'
      and  pa.person_id   = papa.person_id
      and  papa.assignment_id = p_assignment_id;
  --
  cursor csr_person (p_person_id in number) is
    select distinct first_name||' '||last_name
    from   per_people
    where  person_id = p_person_id;
  --
  cursor csr_job (p_person_id in number) is
    select distinct  pj.name
    from   per_jobs_vl                  pj
           ,per_assignments             pa
    where  pj.job_id          = pa.job_id
      and  pa.primary_flag    = 'Y'
      and  pa.person_id   = p_person_id;
  --
  l_in_chain          boolean := false;
  l_current_person_id per_people_f.person_id%type;
  l_current_job       per_jobs.name%type;
  l_person_id         per_people_f.person_id%type;
  l_vp_name           varchar(200);
  l_found_it          boolean default FALSE;
  l_supervisors       varchar2(32000);
  l_dead_loop         exception;
--
begin
  -- determine the hiring manager for the candidate
  open csr_papa;
  fetch csr_papa into l_current_person_id, l_current_job;
  close csr_papa;
  --
  --
  while l_current_person_id is not null loop
   if upper(l_current_job) like '%VICE%' then
    p_job_name := l_current_job;
     open csr_person(l_current_person_id);
     fetch csr_person into l_vp_name;
     close csr_person;
     p_vp_name  := l_vp_name;
     l_found_it := TRUE;
     exit;
   else
     l_supervisors := l_supervisors || ',' || to_char(l_current_person_id);
     l_current_person_id := get_next_approver
                              (p_person_id => l_current_person_id);
     if l_current_person_id is null then
       exit;
     end if;
     --check approval chain dead loop
     if instr(l_supervisors,to_char(l_current_person_id)) <> 0 then
       raise l_dead_loop;
     end if;
     open csr_job(l_current_person_id);
     fetch csr_job into l_current_job;
     close csr_job;
   end if;
  end loop;
  -- If nothing was found with 'VICE' in the loop, then the loop
  -- will exit and we have found no Vice President in the approval chain.
  --
  if not l_found_it then
     p_vp_name := null;
     p_job_name := null;
  end if;
--
exception
  when l_dead_loop then
    -- set OUT parameters.
    p_vp_name := null;
    p_job_name:= null;

    fnd_message.set_name('PER','HR_WEB_APPROVAL_DEAD_LOOP');
    --hr_java_script_web.alert(fnd_message.get);
    raise hr_util_web.g_error_handled;
  when others then
    -- set OUT parameters.
    p_vp_name := null;
    p_job_name:= null;
     --hr_java_script_web.alert(sqlerrm||' '||sqlcode);
     raise hr_util_web.g_error_handled;
end get_vp_name;
-- ----------------------------------------------------------------------------
-- |--------------------------< check_final_approver >------------------------|
-- ----------------------------------------------------------------------------
--
-- This function determines if the current manager is the final approver for
-- an offer.  It is used in the Web Offer workflow, 'Offer Letter' to determine
-- if we need to look for the next approver or if the offer is ready to be sent
-- to HR for printing/mailing.
--
function check_final_approver
           (p_candidate_assignment_id in per_assignments_f.assignment_id%type
           ,p_fwd_to_mgr_id           in per_people_f.person_id%type
           ,p_person_id               in per_people_f.person_id%type)
         return varchar2 is
--
  cursor csr_pa(l_effective_date in date) is
    select  paf.person_id
    from    per_all_assignments_f paf
    start   with paf.person_id = p_person_id
      and     paf.primary_flag = 'Y'
      and     l_effective_date
      between paf.effective_start_date
      and     paf.effective_end_date
    connect by prior paf.supervisor_id = paf.person_id
      and     paf.primary_flag = 'Y'
      and     l_effective_date
      between paf.effective_start_date
      and     paf.effective_end_date;
--
  l_person_id per_people_f.person_id%type := null;
--
begin
--
  --
  -- loop through each row. the rows are returned in an order which makes
  -- the last row selected the top most node of the chain.
  for lcsr in csr_pa(trunc(sysdate)) loop
    -- set the l_person_id variable to the row fetched
    l_person_id := lcsr.person_id;
  end loop;
  if p_fwd_to_mgr_id = l_person_id then
    return('Y');
  else
    return('N');
  end if;
exception
  when others then
       return('E');
--
end check_final_approver;
-- ----------------------------------------------------------------------------
-- |-----------------------< check_if_in_approval_chain >---------------------|
-- ----------------------------------------------------------------------------
--
-- This function goes up the approval chain (via get_next_approver) to
-- determine if the person who is trying to look at a Candidate Offer can see
-- the offer information or not. It allows specific HR employee's to see the
-- data in update mode. It is used on the web pages.
--
function check_if_in_approval_chain
           (p_person_id               in per_people_f.person_id%type
           ,p_candidate_assignment_id in per_assignments_f.assignment_id%type)
         return boolean is
--
  --1754123 begin
  --the creator may not be the hiring manager if the
  --profile option HR_USE_HIRE_MGR_APPR_CHAIN is set to 'Y'.
  --So, we should get the hiring manager from per_all_assignments_f

  --cursor csr_papa is
  --  select distinct papa.person_id
  --  from   per_assign_proposal_answers papa
  --  where  papa.assignment_id = p_candidate_assignment_id;

  cursor csr_supervisor is
  select asg.supervisor_id
    from per_all_assignments_f asg
   where asg.assignment_id = p_candidate_assignment_id;
  --1754123 end

--
  l_in_chain          boolean := false;
  l_current_person_id per_people_f.person_id%type;
  l_person_id         per_people_f.person_id%type;
--
begin
  -- Oracle internal only:
  -- These are HR reps.
  if p_person_id in (999999, 999998, 999997) then
      l_in_chain := true;
      return(l_in_chain);
  end if;
  -- determine the hiring manager for the candidate
  --1754123 begin
  --open csr_papa;
  --fetch csr_papa into l_current_person_id;
  --close csr_papa;

  open csr_supervisor;
  fetch csr_supervisor into l_current_person_id;
  close csr_supervisor;
  --1754123 end
  --
  while l_current_person_id is not null loop
    if l_current_person_id = p_person_id then
      l_in_chain := true;
      exit;
    else
      l_current_person_id := get_next_approver
                               (p_person_id => l_current_person_id);
    end if;
  end loop;
  return(l_in_chain);
end check_if_in_approval_chain;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_signatories_details >---------------------|
-- ----------------------------------------------------------------------------
--
-- This function determines who should sign the offer letter.  It's used when
-- generating the offer letter.
--
procedure get_signatories_details
            (p_person_id               in  per_people_f.person_id%type
            ,p_candidate_assignment_id in  per_assignments_f.assignment_id%type
            ,p_signatory_id1           out nocopy per_people_f.person_id%type
            ,p_position_title1         out nocopy varchar2
            ,p_signatory_id2           out nocopy per_people_f.person_id%type
            ,p_position_title2         out nocopy varchar2
            ,p_signatory_id3           out nocopy per_people_f.person_id%type
            ,p_position_title3         out nocopy varchar2) is
--
  l_fwd_to_mgr_id per_people_f.person_id%type := p_person_id;
--
begin
  -- find the final approver
  loop
    l_fwd_to_mgr_id := get_next_approver
                         (p_person_id => l_fwd_to_mgr_id);
    --
    if l_fwd_to_mgr_id is not null then
      -- check to see if final approver
      if check_final_approver
           (p_candidate_assignment_id => p_candidate_assignment_id
           ,p_fwd_to_mgr_id           => l_fwd_to_mgr_id
           ,p_person_id               => p_person_id)= 'Y' then
        -- the final approver has been found
        p_signatory_id1 := l_fwd_to_mgr_id;
        exit;
      end if;
    else
      -- a broken chain must exist therefore we cannot set the signatory
      -- details
      exit;
    end if;
  end loop;
  --
  --  Position title of approvers.
  --
  p_position_title1 := '(Position title1)';
  p_position_title2 := '(Position title2)';
  p_position_title3 := '(Position title3)';
  --
exception
when others then
p_signatory_id1     := null;
p_position_title1   := null;
p_signatory_id2     := null;
p_position_title2   := null;
p_signatory_id3     := null;
p_position_title3   := null;
raise;

end get_signatories_details;
-- ----------------------------------------------------------------------------
-- |-----------------------------< set_apl_status >---------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   this procedure will correctly update the applicant assignment status type
--   to the specified type. because the assignment entity is datetracked this
--   change might have to be 'rippled' through onto future datetracked rows,
--   if the rows exist in the future. this procedure adhere's to the following
--   rules:
--
--   1. performing an update on the day the applicant was created:
--
--      because an applicant assignment has to be an ACTIVE_APL for at least
--      1 day, you cannot perform any datetrack update operations on this day.
--      to get around this problem, the effective date has to be increased by
--      a day (which equates to sysdate + 1). after the effective date has
--      been increased, the datetrack mode can be re-derived.
--
--   2. performing an update after the day the applicant was created without
--      any future changes existing:
--
--      if the datetrack mode of UPDATE is allowed as of the session date,
--      then this mode will always succeed. because future changes do
--      not exist the process will finish.
--
--   3. performing an update after the day the applicant was created but
--      with future changes existing:
--
--      if future changes exist as of the effective date then we need to
--      establish; a) the datetrack mode to be used for the initial API status
--      call, and b) if the future changes require further datetrack
--      CORRECTION updates to the future rows.
--
--      a) if the effective date of the API call falls on an effective start
--         date of the applicant assignment then only a CORRECTION is allowed
--         otherwise only a UPDATE_CHANGE_INSERT is allowed.
--      b) if future rows exist beyond the current row as of the effective
--         date then each subsequent row needs to be date effectively updated
--         by the API in CORRECTION mode to reflect the assignment status
--         change (referred to as rippling). if during execution of the API an
--         error is encountered, then the error is ignored and the processing
--         of future rows is stopped.
--
-- Pre Conditions:
--   The applicant must exist.
--
-- In Arguments:
--    p_candidate_assignment_id   -> The assignment_id of the candidate
--                                  (applicant).
--    p_status_type_id            -> The applicant assignment status type
--                                   to update the assignment with.
--                                   If not specified (i.e. null) then the
--                                   API will assume the default OFFER
--                                   status is required.
-- Post Success:
--   The API will update the applicant assignment row(s) to the specified or
--   defaulted status.
--
-- Post Failure:
--   An error will be raised.
--
-- Developer Implmentation Notes:
--
-- Access Status:
--   Private to this package.
-- ----------------------------------------------------------------------------
procedure set_apl_status
   (p_candidate_assignment_id  in
      per_assignments_f.assignment_id%type
   ,p_status_type_id           in
      per_assignments_f.assignment_status_type_id%type default null) is
  --
  -- define the pl/sql table types to be used
  --
  type l_ed_tab_type is table of date
       index by binary_integer;
  type l_ovn_tab_type is table of per_assignments_f.object_version_number%type
       index by binary_integer;
  -- define the local variables to be used
  l_esd_tab                   l_ed_tab_type;  -- effective start date table
  l_eed_tab                   l_ed_tab_type;  -- effective end date table
  l_ovn_tab                   l_ovn_tab_type; -- object version number table
  l_index                     binary_integer := 0;
  l_ovn_index                 binary_integer;
  l_correction_on_esd         boolean;
  l_initial_api_call          boolean := true;
  l_correction                boolean;
  l_update                    boolean;
  l_update_override           boolean;
  l_update_change_insert      boolean;
  l_datetrack_update_mode     varchar2(30);
  l_effective_date            date := trunc(sysdate);
  l_object_version_number     per_assignments_f.object_version_number%type;
  l_effective_start_date      per_assignments_f.effective_start_date%type;
  l_effective_end_date        per_assignments_f.effective_end_date%type;
--
  cursor csr_paf is
    select   paf.effective_start_date
            ,paf.effective_end_date
            ,paf.object_version_number
    from     per_all_assignments_f paf   -- 10/17/97 Changed
    where    paf.assignment_id = p_candidate_assignment_id
    order by paf.effective_start_date;
--
begin
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- populate the pl/sql tables for the applicant assignment
  for lcsr in csr_paf loop
    l_index := l_index + 1;
    l_esd_tab(l_index) := lcsr.effective_start_date;
    l_eed_tab(l_index) := lcsr.effective_end_date;
    l_ovn_tab(l_index) := lcsr.object_version_number;
  end loop;
  --
  if l_index > 0 then
    -- check to see if the minimum effective start date is the same as the
    -- sysdate
    if l_esd_tab(1) = l_effective_date then
      -- the effective start date is the same as the sysdate therefore
      -- we must move the date on because an applicant must have an 'ACTIVE_APL'
      -- status for at least one day
      l_effective_date := l_effective_date + 1;
    end if;
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- the following section determines the datetrack mode to be used for
    -- the initial API call
    --
    -- determine what datetrack modes are available as of the effective date
    per_asg_shd.find_dt_upd_modes
        (p_effective_date   => l_effective_date
        ,p_base_key_value   => p_candidate_assignment_id
        ,p_correction           => l_correction
        ,p_update       => l_update
        ,p_update_override      => l_update_override
        ,p_update_change_insert => l_update_change_insert);
    --
    if l_update then
      -- as we can perform an UPDATE we must set the datetrack mode accordingly.
      -- we can also assume that no future changes exist for this applicant
      -- (otherwise we would not be able to perform an UPDATE)
      l_datetrack_update_mode := 'UPDATE';
    else
      if l_correction then
         l_correction_on_esd := false;
         -- as CORRECTION is allowed therefore, determine if the effective
         -- date is the same as an effective start date for the applicant
         for i in 1..l_index loop
           if l_esd_tab(i) = l_effective_date then
             -- set the flag to indicate that an effective start date does exist
             -- for the given effective date
             l_correction_on_esd := true;
             exit;
           end if;
         end loop;
         --
         if l_correction_on_esd then
           -- perform a CORRECTION
           l_datetrack_update_mode := 'CORRECTION';
         else
           -- perform a CHANGE_INSERT
           l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
         end if;
      end if;
    end if;
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- process the initial API call and subsequent API calls (if required) to
    -- ripple through any date effective CORRECTION's
    --
    loop
      -- determine the object_version_number as of the effective date
      for i in 1..l_index loop
        if l_effective_date >= l_esd_tab(i) and
           l_effective_date <= l_eed_tab(i) then
          -- set the object version number
          l_object_version_number := l_ovn_tab(i);
          -- set the object version number index
          l_ovn_index := i;
          exit;
        end if;
      end loop;
      --
      begin
        -- perform the status change
        hr_assignment_api.offer_apl_asg
          (p_effective_date            => l_effective_date
          ,p_datetrack_update_mode     => l_datetrack_update_mode
          ,p_assignment_id             => p_candidate_assignment_id
          ,p_object_version_number     => l_object_version_number
          ,p_assignment_status_type_id => p_status_type_id
          ,p_effective_start_date      => l_effective_start_date
          ,p_effective_end_date        => l_effective_end_date);
        --
        l_initial_api_call := false;
        --
      exception
        when others then
          -- the API call has failed. if the failure has ocurred on the initial
          -- call we must let the workflow engine report the error.
          -- if the API call has failed in the datetrack CORRECTION 'ripple'
          -- mode we ignore the error and exit the loop.
          if l_initial_api_call then
            raise;
          else
            exit;
          end if;
      end;
      if l_ovn_index < l_index then
        -- future changes exist which we must ripple through as a date effective
        -- CORRECTION
        l_effective_date        := l_esd_tab(l_ovn_index + 1);
        l_datetrack_update_mode := 'CORRECTION';
      else
        exit;
      end if;
    end loop;
  else
    -- the assignment was not found as of the sysdate. this is a fatal error
    -- which we must raise
    fnd_message.set_name('PER', 'HR_ASG_DOES_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  -- commit any outstanding changes
  -- commit;
  --
end set_apl_status;
-- ----------------------------------------------------------------------------
-- |--------------------------< set_status_to_offer >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This function just sets the applicant status to offer.  It is called when
-- the offer is approved by the final approver.  It is used in the Web Offer
-- workflow, 'Offer Letter'.
--
--
procedure set_status_to_offer
          (p_candidate_assignment_id in per_assignments_f.assignment_id%type) is
begin
  -- set applicant to default OFFER status
  set_apl_status(p_candidate_assignment_id => p_candidate_assignment_id);
end set_status_to_offer;
-- ----------------------------------------------------------------------------
-- |--------------------------< set_status_to_sent >--------------------------|
-- ----------------------------------------------------------------------------
--
-- This function just sets the applicant status to sent.  It is called when
-- the offer is mailed to the candidate.  It is used in the Web Offer workflow,
-- 'Offer Letter'.
--
procedure set_status_to_sent
          (p_candidate_assignment_id in per_assignments_f.assignment_id%type) is
begin
  -- [CUSTOMIZE]
  -- set applicant OFFER SENT status, this status must be set up in
  -- per_assignment_status_types.  As delivered, we have no 'sent'
  -- status in core hrms, so we are not calling the procedure.
  null;
 -- set_apl_status(p_candidate_assignment_id => p_candidate_assignment_id
 --               ,p_status_type_id          => 6786);
end set_status_to_sent;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_attachment >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_attachment
          (p_attachment_text    in long default null
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_attached_document_id  out nocopy
              fnd_attached_documents.attached_document_id%TYPE
          ,p_document_id           out nocopy
              fnd_documents.document_id%TYPE
          ,p_media_id              out nocopy
              fnd_documents_tl.media_id%TYPE
          ,p_rowid                 out nocopy varchar2
          ,p_login_person_id   in  number) is   -- 10/14/97 Changed

  -- [CUSTOMIZE]
  -- Call fnd_attached_documents_pkg.insert_row api to insert into fnd_documents
  -- table.  If customer uses third party software to store the resume, modify
  -- the code here.

  l_rowid                  varchar2(50) default null;
  l_media_id               fnd_documents_tl.media_id%TYPE;
  l_attached_document_id   fnd_attached_documents.attached_document_id%TYPE
                             default null;
  l_document_id            fnd_documents.document_id%TYPE default null;
  l_category_id            fnd_document_categories.category_id%TYPE
                           default null;
  l_datatype_id            fnd_document_datatypes.datatype_id%TYPE default 2;
  l_language               varchar2(30) default 'AMERICAN';
  l_seq_num                fnd_attached_documents.seq_num%type;


  cursor csr_get_seq_num is
         select nvl(max(seq_num),0) + 10
           from fnd_attached_documents
          where entity_name = p_entity_name
            and pk1_value   = p_pk1_value
            and pk2_value is null
            and pk3_value is null
            and pk4_value is null
            and pk5_value is null;

  cursor csr_get_category_id (csr_p_lang in varchar2) is
         select category_id
           from fnd_document_categories_tl
          where language = csr_p_lang
            and name = 'HR_RESUME'; -- updated for bug no:2533461
  --

  Begin
  --
  -- Get language
  select userenv('LANG') into l_language from dual;
  --
  --  Get seq num
  --
  l_seq_num := 0;
  open csr_get_seq_num;
  fetch csr_get_seq_num into l_seq_num;
  close csr_get_seq_num;
  --
  --  Get category ID
  --
  open csr_get_category_id (csr_p_lang => l_language);
  fetch csr_get_category_id into l_category_id;
  if csr_get_category_id%notfound then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_get_category_id;
  --
  -- get sequence id for attached_document_id
     select fnd_attached_documents_s.nextval
       into l_attached_document_id
       from sys.dual;

  -- Insert document to fnd_documents_long_text
  --
            fnd_attached_documents_pkg.insert_row
            (x_rowid                      => l_rowid
            ,x_attached_document_id       => l_attached_document_id
            ,x_document_id                => l_document_id
            ,x_creation_date              => trunc(sysdate)
            ,x_created_by                 => p_login_person_id --10/14/97Chg
            ,x_last_update_date           => trunc(sysdate)
            ,x_last_updated_by            => p_login_person_id --10/14/97Chg
            ,x_seq_num                    => l_seq_num
            ,x_entity_name                => p_entity_name
            ,x_column1                    => 'PERSON_ID'
            ,x_pk1_value                  => p_pk1_value
            ,x_pk2_value                  => null
            ,x_pk3_value                  => null
            ,x_pk4_value                  => null
            ,x_pk5_value                  => null
            ,x_automatically_added_flag   => 'N'
            ,x_datatype_id                => l_datatype_id
            ,x_category_id                => l_category_id
            ,x_security_type              => 4
            ,x_publish_flag               =>'N'
            ,x_usage_type                 =>'O'
            ,x_language                   => l_language
            ,x_media_id                   => l_media_id
            ,x_doc_attribute_category     => null
            ,x_doc_attribute1             => null
            ,x_doc_attribute2             => null
            ,x_doc_attribute3             => null
            ,x_doc_attribute4             => null
            ,x_doc_attribute5             => null
            ,x_doc_attribute6             => null
            ,x_doc_attribute7             => null
            ,x_doc_attribute8             => null
            ,x_doc_attribute9             => null
            ,x_doc_attribute10            => null
            ,x_doc_attribute11            => null
            ,x_doc_attribute12            => null
            ,x_doc_attribute13            => null
            ,x_doc_attribute14            => null
            ,x_doc_attribute15            => null);
        --

  -- Now insert into fnd_documents_long_text using the media_id
  -- generated from the above api call
  --
  insert into fnd_documents_long_text
    (media_id
    ,long_text)
  values
    (l_media_id
    ,p_attachment_text);

  p_attached_document_id := l_attached_document_id;
  p_document_id          := l_document_id;
  p_media_id             := l_media_id;
  p_rowid                := l_rowid;

  EXCEPTION
    When others then
    p_attached_document_id := null;
    p_document_id          := null;
    p_media_id             := null;
    p_rowid                := null;
    raise;
  --
end insert_attachment;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_attachment >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_attachment
          (p_attachment_text    in long default null
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_rowid              in varchar2
          ,p_login_person_id in number) is   -- 10/14/97 Changed

  -- [CUSTOMIZE]
  -- Call fnd_attached_documents_pkg.update_row api to update fnd_documents
  -- table.  If customer uses third party software to store the resume, modify
  -- the code here.

  l_rowid                  varchar2(50);
  l_language               varchar2(30) default 'AMERICAN';

  data_error               exception;
  --
  -- -------------------------------------------------------------
  -- Get the before update nullable fields so that we can
  -- preserve the values entered in 10SC GUI after the update.
  -- -------------------------------------------------------------
  cursor csr_get_attached_doc  is
    select *
    from   fnd_attached_documents
    where  rowid = p_rowid;
  --
  cursor csr_get_doc(csr_p_document_id in number)  is
    select *
    from   fnd_documents
    where  document_id = csr_p_document_id;
  --
  cursor csr_get_doc_tl  (csr_p_lang in varchar2
                         ,csr_p_document_id in number) is
    select *
    from   fnd_documents_tl
    where  document_id = csr_p_document_id
    and    language = csr_p_lang;
  --
  l_attached_doc_pre_upd   csr_get_attached_doc%rowtype;
  l_doc_pre_upd            csr_get_doc%rowtype;
  l_doc_tl_pre_upd         csr_get_doc_tl%rowtype;
  --
  --
  Begin
  --
  -- Get language
  select userenv('LANG') into l_language from dual;
  --
  -- Get the before update nullable fields which are not used by the
  -- Web page to ensure the values are propagated.
     Open csr_get_attached_doc;
     fetch csr_get_attached_doc into l_attached_doc_pre_upd;
     IF csr_get_attached_doc%NOTFOUND THEN
        close csr_get_attached_doc;
        raise data_error;
     END IF;

     Open csr_get_doc(l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc into l_doc_pre_upd;
     IF csr_get_doc%NOTFOUND then
        close csr_get_doc;
        raise data_error;
     END IF;

     Open csr_get_doc_tl (csr_p_lang => l_language
                      ,csr_p_document_id => l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc_tl into l_doc_tl_pre_upd;
     IF csr_get_doc_tl%NOTFOUND then
        close csr_get_doc_tl;
        raise data_error;
     END IF;

     -- Now, lock the rows.
     fnd_attached_documents_pkg.lock_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                      l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => l_attached_doc_pre_upd.entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => l_attached_doc_pre_upd.pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                    l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                    l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
            ,x_start_date_active          => l_doc_pre_upd.start_date_active
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_doc_tl_pre_upd.language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_tl_pre_upd.file_name
            ,x_media_id                   => l_doc_tl_pre_upd.media_id
            ,x_doc_attribute_category     =>
                          l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15);


  -- Update document to fnd_attached_documents, fnd_documents,
  -- fnd_documents_tl and fnd_documents_long_text
  --
            fnd_attached_documents_pkg.update_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                        l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_last_update_date           => trunc(sysdate)
            ,x_last_updated_by            => p_login_person_id --10/14/97chg
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => p_entity_name
            ,x_column1                    => 'PERSON_ID'
            ,x_pk1_value                  => p_pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                      l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                      l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            /*   columns necessary for creating a document on the fly  */
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
            ,x_start_date_active          => trunc(sysdate)
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_tl_pre_upd.file_name
            ,x_media_id                   => l_doc_tl_pre_upd.media_id
            ,x_doc_attribute_category     =>
                      l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15);

  -- Now update the long text table
     update fnd_documents_long_text
        set long_text = p_attachment_text
      where media_id  = l_doc_tl_pre_upd.media_id;

  EXCEPTION
    when others then
         raise;
  --
  End update_attachment;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_attachment >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_attachment
          (p_attachment_text    out nocopy long
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_effective_date     in varchar2
          ,p_attached_document_id  out nocopy
              fnd_attached_documents.attached_document_id%TYPE
          ,p_document_id           out nocopy fnd_documents.document_id%TYPE
          ,p_media_id              out nocopy fnd_documents_tl.media_id%TYPE
          ,p_rowid                 out nocopy varchar2
          ,p_category_id           out nocopy fnd_documents.category_id%type
          ,p_seq_num               out nocopy fnd_attached_documents.seq_num%type) is

  -- [CUSTOMIZE]
  -- Call fnd_attached_documents, fnd_documents_tl and
  -- fnd_documents_long_text tables. If customer uses third party
  -- software to store the resumes, modify the code here.

  l_attached_document_id  fnd_attached_documents.attached_document_id%TYPE
                          default null;
  l_document_id           fnd_documents.document_id%TYPE default null;
  l_media_id              fnd_documents_tl.media_id%TYPE default null;
  l_attachment_text       long default null;
  l_rowid                 varchar2(50) default null;
  l_category_id           fnd_documents.category_id%type default null;
  l_language              varchar2(30) default 'AMERICAN';
  l_seq_num               fnd_attached_documents.seq_num%type default null;
  l_update_date           date default null;

  cursor csr_get_category_id (csr_p_lang in varchar2) is
  select category_id
    from fnd_document_categories_tl
   where language = csr_p_lang
     and name = 'HR_RESUME'; -- updated for bug no:2533461

  ------------------------------------------------------------------------------
  -- Jan. 11, 2001 Bug Fix 1576603:
  -- In closer look at the FND api, the fnd_attached_documents_pkg.insert_row
  -- (AFAKAADB.pls) always sets start_date_active and end_date_active to null in
  -- call to fnd_documents_pkg.insert_row (AFAKADCB.pls).  Therefore, the
  -- comparision of p_effective_date to start_date_active and end_date_active in
  -- the cursor is futile.  Therefore, remove the p_effective_date comparision
  -- in the cursor and sort the records by creation date, last_update_date so
  -- that the most current resume will be displayed.
  ------------------------------------------------------------------------------
  cursor csr_attached_documents (csr_p_cat_id in number) is
  select fatd.rowid, fatd.attached_document_id, fatd.document_id, fatd.seq_num
         ,fd.last_update_date
    from fnd_attached_documents  fatd
         ,fnd_documents          fd
   where fd.category_id = csr_p_cat_id
     and fatd.entity_name = p_entity_name
     and fatd.pk1_value   = p_pk1_value
     and fatd.document_id = fd.document_id
   order by fd.creation_date desc
           ,fd.last_update_date desc;   -- retrieve the one updated the last

  cursor csr_documents_tl (csr_p_document_id in number) is
  select media_id
    from fnd_documents_tl
   where document_id = csr_p_document_id;

  cursor csr_documents_long_text (csr_p_media_id in number) is
  select long_text
    from fnd_documents_long_text
   where media_id = csr_p_media_id;

Begin
  --
  -- Get language
  select userenv('LANG') into l_language from dual;
  --
  -- -------------------------------------------------------------------------
  -- Retrieving a resume requires 4 steps:
  --   1) Get Category ID.
  --   2) Get the attached_document_id, document_id and other fields from
  --      the table join of fnd_attached_documents and fnd_documents.  The
  --      result set can have more than 1 row and is sorted by descending
  --      order of the last_update_date.  So, if there are multipe resumes
  --      returned (which could be possible because a user in 10SC Person
  --      form can add an attachment with the category of 'Resume'.  When
  --      that happens, we only want the one which is updated most recently.
  --   3) Use the document_id obtained from the 1st record of step 2 to
  --      get the media_id from fnd_documents_tl.
  --   4) Use the media_id from step 3 to obtain the resume text from
  --      fnd_documents_long_text.
  -- -------------------------------------------------------------------------
  --
  -- -------------------------------------------------------------------------
  -- 1) Get Category ID.
  -- -------------------------------------------------------------------------
  open csr_get_category_id (csr_p_lang => l_language);
  fetch csr_get_category_id into l_category_id;
  if csr_get_category_id%notfound then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_get_category_id;
  --
  -- -------------------------------------------------------------------------
  -- 2) Get attached_document_id, document_id.
  -- -------------------------------------------------------------------------
  --
  Open csr_attached_documents (csr_p_cat_id => l_category_id);
  fetch csr_attached_documents into l_rowid, l_attached_document_id,
                                    l_document_id, l_seq_num, l_update_date;

  IF csr_attached_documents%NOTFOUND THEN
     close csr_attached_documents;
  ELSE
     open csr_documents_tl(csr_p_document_id => l_document_id);
     fetch csr_documents_tl into l_media_id;
     IF csr_documents_tl%NOTFOUND THEN
        close csr_attached_documents;
        close csr_documents_tl;
        raise hr_utility.hr_error;
     ELSE
        open csr_documents_long_text(csr_p_media_id  => l_media_id);
        fetch csr_documents_long_text into l_attachment_text;
        IF csr_documents_long_text%NOTFOUND THEN
           close csr_attached_documents;
           close csr_documents_tl;
           close csr_documents_long_text;
           raise hr_utility.hr_error;
        ELSE
           close csr_attached_documents;
           close csr_documents_tl;
           close csr_documents_long_text;
        END IF;
     END IF;
  END IF;

  p_attachment_text := l_attachment_text;
  p_attached_document_id := l_attached_document_id;
  p_document_id := l_document_id;
  p_media_id := l_media_id;
  p_rowid := l_rowid;
  p_category_id := l_category_id;
  p_seq_num := l_seq_num;

exception
  when hr_utility.hr_error THEN
    p_attachment_text := null;
    p_attached_document_id := null;
    p_document_id := null;
    p_media_id := null;
    p_rowid := null;
    p_category_id := null;
    p_seq_num := null;
    raise;

  when others then
    p_attachment_text := null;
    p_attached_document_id := null;
    p_document_id := null;
    p_media_id := null;
    p_rowid := null;
    p_category_id := null;
    p_seq_num := null;
    --hr_java_script_web.alert(sqlerrm||' '||sqlcode);
    --hr_util_web.standard_close;
    raise hr_util_web.g_error_handled;

end get_attachment;

-- ----------------------------------------------------------------------------
-- |--------------------------< validate_phone_format >-----------------------|
-- ----------------------------------------------------------------------------
--  Name: validate_phone_format
--
--  Function: This procedure validates a phone number format by country code.
--            This procedure is expected to be modified by customers to suit
--            their needs in different ways of formatting a phone number.
--
--  Output: p_phone_num_out - Customers need to set this output parameter to
--                            a non-null value, formatted phone number which
--                            will be used to display in the offer letter.
--
--          p_phone_format_err - Customers need to set this parameter to 'Y' if
--                               there is an error.  Otherwise, set it to 'N'
--                               if the phone passes their validation code.
-- ----------------------------------------------------------------------------
--
procedure validate_phone_format(p_phone_num_in      in   varchar2
                               ,p_country_code      in   varchar2 default 'US'
                               ,p_phone_num_out     out nocopy  varchar2
                               ,p_phone_format_err  out nocopy  varchar2) IS

Begin
--
--  Customers need to put in code for their own validations.  If no
--  code is put in here, the product validation code in
--  hr_offer_util_web.validate_phone_format will be used.
--  When validate, do:
--    IF p_country_code = 'US' THEN
--       . . . .
--    ELSE
--       . . . .
--    END IF;
--
-- --------------------------------------------------------------------
-- NOTE: For a list of country_code, please refer to
--       fnd_territories_vl.territory_code.
-- --------------------------------------------------------------------
   p_phone_num_out := null;
   p_phone_format_err := null;
--
END validate_phone_format;

end hr_offer_custom;

/
