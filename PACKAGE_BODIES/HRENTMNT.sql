--------------------------------------------------------
--  DDL for Package Body HRENTMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRENTMNT" as
/* $Header: pyentmnt.pkb 120.32.12010000.27 2010/02/17 10:44:25 priupadh ship $ */
--
g_debug boolean := hr_utility.debug_enabled;
indent  varchar2 (32767) := null;
g_package constant varchar2 (32) := 'hrentmnt.';
--
-- Record type to cache an element entry for use when splitting into two.
--
type t_ele_entry_rec is record
  (cost_allocation_keyflex_id number,
   creator_type               varchar2(10),
   entry_type                 varchar2(1),
   comment_id                 number,
   creator_id                 number,
   reason                     varchar2(30),
   target_entry_id            number,

   subpriority                 number,
   personal_payment_method_id  number,
   date_earned                 date,

   balance_adj_cost_flag      varchar2(30),
   source_asg_action_id       number,
   source_link_id             number,
   source_trigger_entry       number,
   source_period              number,
   source_run_type            number,
   source_start_date          date,
   source_end_date            date,

   attribute_category         varchar2(30),
   attribute1                 varchar2(150),
   attribute2                 varchar2(150),
   attribute3                 varchar2(150),
   attribute4                 varchar2(150),
   attribute5                 varchar2(150),
   attribute6                 varchar2(150),
   attribute7                 varchar2(150),
   attribute8                 varchar2(150),
   attribute9                 varchar2(150),
   attribute10                varchar2(150),
   attribute11                varchar2(150),
   attribute12                varchar2(150),
   attribute13                varchar2(150),
   attribute14                varchar2(150),
   attribute15                varchar2(150),
   attribute16                varchar2(150),
   attribute17                varchar2(150),
   attribute18                varchar2(150),
   attribute19                varchar2(150),
   attribute20                varchar2(150),

   entry_information_category varchar2(30),
   entry_information1         varchar2(150),
   entry_information2         varchar2(150),
   entry_information3         varchar2(150),
   entry_information4         varchar2(150),
   entry_information5         varchar2(150),
   entry_information6         varchar2(150),
   entry_information7         varchar2(150),
   entry_information8         varchar2(150),
   entry_information9         varchar2(150),
   entry_information10        varchar2(150),
   entry_information11        varchar2(150),
   entry_information12        varchar2(150),
   entry_information13        varchar2(150),
   entry_information14        varchar2(150),
   entry_information15        varchar2(150),
   entry_information16        varchar2(150),
   entry_information17        varchar2(150),
   entry_information18        varchar2(150),
   entry_information19        varchar2(150),
   entry_information20        varchar2(150),
   entry_information21        varchar2(150),
   entry_information22        varchar2(150),
   entry_information23        varchar2(150),
   entry_information24        varchar2(150),
   entry_information25        varchar2(150),
   entry_information26        varchar2(150),
   entry_information27        varchar2(150),
   entry_information28        varchar2(150),
   entry_information29        varchar2(150),
   entry_information30        varchar2(150));
--
-- Record type and ref cursor type to hold assignment eligibility criteria, i.e.
-- payroll_id, organization_id, people_group_id etc.
-- Used by recreate_cached_entry and val_nonrec_entries.
type t_asg_criteria_rec is record (
  organization_id      number,
  people_group_id      number,
  job_id               number,
  position_id          number,
  grade_id             number,
  location_id          number,
  employment_category  varchar2(30),
  payroll_id           number,
  pay_basis_id         number,
  business_group_id    number);
--
type t_asg_criteria_cur is ref cursor return t_asg_criteria_rec;
--
-- Record type and ref cursor type to hold min/max dates of an element link
-- that matches certain eligibility criteria.
-- Used by recreate_cached_entry and val_nonrec_entries when fetching
-- alternative element links for existing invalidated entries.
type t_eligible_links_rec is record (
  element_link_id      number,
  effective_start_date date,
  effective_end_date   date);
--
type t_eligible_links_cur is ref cursor return t_eligible_links_rec;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.min_eligibility_date                                            --
--                                                                          --
-- DESCRIPTION                                                              --
-- Calculates the minimum date an element entries start date could be set   --
-- to taking into account the eligibility of the element entry over time.   --
-- NOTES                                                                    --
-- New functionality added in response to WWBug 278071. This is used within --
-- adjust_entries_pqc to tighten up the setting of element entry start      --
-- date in response to changing personal qualifying conditions.             --
------------------------------------------------------------------------------
--
function min_eligibility_date
(
 p_element_link_id  number,
 p_assignment_id    number,
 p_range_start_date date,
 p_range_end_date   date
) return date is
  --
  -- Returns the eligibility criteria for an element link.
  --
  cursor csr_link
         (
           p_element_link_id number
         ) is
    select EL.element_link_id,
           EL.effective_start_date,
           EL.link_to_all_payrolls_flag,
           EL.payroll_id,
           EL.job_id,
           EL.grade_id,
           EL.position_id,
           EL.organization_id,
           EL.location_id,
           EL.pay_basis_id,
           EL.employment_category,
           EL.people_group_id
    from   pay_element_links_f EL
    where  EL.element_link_id = p_element_link_id
    order  by EL.effective_start_date;
  --
  -- Fetches all assignment rows for a given assignment that match specific
  -- elgibility criteria over a range of dates NB. they are returned in
  -- reverse order.
  --
  -- EL   |-------------------------------A--------------------------------->
  --
  -- ASG  |----A---|----A----|------B-----|-----A-----|------A-----|----B--->
  --
  -- Range             |---------------------------------------------------->
  --
  -- Fetch 1                                          |------A-----|
  -- Fetch 2                              |-----A-----|
  -- Fetch 3       |----A----|
  --
  cursor csr_assignment
         (
          p_element_link_id           number,
          p_assignment_id             number,
          p_range_start_date          date,
          p_range_end_date            date,
          p_payroll_id                number,
          p_link_to_all_payrolls_flag varchar2,
          p_job_id                    number,
          p_grade_id                  number,
          p_position_id               number,
          p_organization_id           number,
          p_location_id               number,
          p_pay_basis_id              number,
          p_employment_category       varchar2,
          p_people_group_id           number
         ) is
    select ASG.effective_start_date,
           ASG.effective_end_date
    from   per_all_assignments_f ASG
    where  ASG.assignment_id         = p_assignment_id
      and  ASG.assignment_type       = 'E'
      and  ASG.effective_start_date <= p_range_end_date
      and  ASG.effective_end_date   >= p_range_start_date
      and  ((p_payroll_id is not null and
             p_payroll_id = ASG.payroll_id)
       or   (p_link_to_all_payrolls_flag = 'Y' and
             ASG.payroll_id is not null)
       or   (p_link_to_all_payrolls_flag = 'N' and
             p_payroll_id is null))
      and  (p_job_id is null or
            p_job_id = ASG.job_id)
      and  (p_grade_id is null or
            p_grade_id = ASG.grade_id)
      and  (p_position_id is null or
            p_position_id = ASG.position_id)
      and  (p_organization_id is null or
            p_organization_id = ASG.organization_id)
      and  (p_location_id is null or
             p_location_id = ASG.location_id)
      and  (p_pay_basis_id is null or
             p_pay_basis_id = ASG.pay_basis_id)
      and  (p_employment_category is null or
            p_employment_category = ASG.employment_category)
      and  (p_people_group_id is null or
            exists
              (select null
               from   pay_assignment_link_usages_f ALU
               where  ALU.assignment_id         = p_assignment_id
                 and  ALU.element_link_id       = p_element_link_id
                 and  ALU.effective_start_date <= ASG.effective_end_date
                 and  ALU.effective_end_date   >= ASG.effective_start_date))
    order by ASG.effective_start_date desc;
  --
  -- Record to hold a row fetched using the csr_link cursor.
  --
  v_link_rec       csr_link%rowtype;
  --
  -- Record to hold a row fetched using the csr_link cursor.
  --
  v_asg_rec        csr_assignment%rowtype;
  --
  -- Variables to hold the start and ends dates of the current assignment row.
  --
  v_asg_start_date date;
  v_asg_end_date   date;
  --
        procedure check_parameters is
                begin
                --
                hr_utility.trace('In min_eligibility_date');
                hr_utility.trace ('');
                hr_utility.trace ('     p_element_link_id = '
                        ||to_char (p_element_link_id));
                hr_utility.trace ('     p_assignment_id'
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_range_start_date'
                        ||to_char (p_range_start_date));
                hr_utility.trace ('     p_range_end_date'
                        ||to_char (p_range_end_date));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  --
  -- Fetch the first date effective row of the link NB. the criteria cannot
  -- be date effectively changed on a link so the criteria should be the same
  -- for all rows.
  --
  open csr_link(p_element_link_id);
  fetch csr_link into v_link_rec;
  if csr_link%notfound then
    close csr_link;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', 'hrentmnt.min_eligibility_date');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  close csr_link;
  --
  --
  -- Open the cursor ready for processing.
  --
  open csr_assignment
         (p_element_link_id,
          p_assignment_id,
          p_range_start_date,
          p_range_end_date,
          v_link_rec.payroll_id,
          v_link_rec.link_to_all_payrolls_flag,
          v_link_rec.job_id,
          v_link_rec.grade_id,
          v_link_rec.position_id,
          v_link_rec.organization_id,
          v_link_rec.location_id,
          v_link_rec.pay_basis_id,
          v_link_rec.employment_category,
          v_link_rec.people_group_id);
  --
  --
  -- Get first assignment row that matches the criteria. The assumption is
  -- that the there should be at least one row that matches. This assumption
  -- is based on the intended use of this function ie. an entry should already
  -- exist for the assignment / link combination at the end of the seerch
  -- range.
  --
  fetch csr_assignment into v_asg_rec;
  if csr_assignment%notfound then
    close csr_assignment;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', 'hrentmnt.min_eligibility_date');
    hr_utility.set_message_token('STEP','2');
    hr_utility.raise_error;
  end if;
  --
  --
  -- Initialise variables holding the start and end dates of the current
  -- assignment row from the cursor.
  --
  v_asg_start_date := v_asg_rec.effective_start_date;
  v_asg_end_date   := v_asg_rec.effective_end_date;
  --
  -- Fetch all the assignment rows that match the criteria over the range of
  -- dates NB. they are returned in reverse order ie. latest first. Each row
  -- is compared to the previous row to see if the eligibility criteria is
  -- contiguous. If not then we have found the minimum date on which an
  -- element entry could start given that it existed at the end of the range
  -- of dates over which the assignment rows were found ie.
  --
  -- EE                           |-------------------------------------->
  --
  -- EL     |----------------------------A------------------------------->
  --                    .
  -- ASG    |---A--|-B--|--A--|------A------|--------A-------|-----A----->
  --                    .
  -- Range  |---------------------|
  --                    '
  -- New EE             |------------------------------------------------>
  --
  loop
    --
    --
    -- Get next assignment row that matches the criteria.
    --
    fetch csr_assignment into v_asg_rec;
    --
    -- Exit the loop if there are no more assignment rows or the new assignment
    -- row is not contiguous with the previous assignment row found ie. there
    -- is a break in eligibility.
    --
    exit when (csr_assignment%notfound or
                v_asg_rec.effective_end_date <> v_asg_start_date - 1);
    --
    -- Set variables to hold the start and end dates of the current
    -- assignment row from the cursor. These can then be used for comparisons
    -- during the next iteration of the loop.
    --
    v_asg_start_date := v_asg_rec.effective_start_date;
    v_asg_end_date   := v_asg_rec.effective_end_date;
    --
  end loop;
  --
  --
  close csr_assignment;
  --
  -- Calculate the minimum eligibility date based on when the element link
  -- starts and the assignments eligibility for the link ie.
  --
  -- EL        |----------------------------A------------------------------>
  --
  -- ASG    |------A------|------A-------|---------------B----------------->
  --
  -- Range  |--------------------------|
  --
  -- Compare  |----------.... (EL)
  --        |------A---....   (ASG)
  --
  -- Greatest |----------... (EL)
  --
  return(greatest(v_link_rec.effective_start_date,v_asg_start_date));
  --
end min_eligibility_date;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.maintain_alu_asg                                                --
--                                                                          --
-- DESCRIPTION                                                              --
-- Maintains the ALU's for an assignment. An ALU represnts the intersection --
-- of the people group flexfield on the assignment and element link. The    --
-- ALU is used to speed up quickpicks where the partial matching of 30      --
-- columns causes performance problems.                                     --
------------------------------------------------------------------------------
--
procedure maintain_alu_asg
(
 p_assignment_id     number,
 p_business_group_id number,
 p_dt_mode           varchar2,
 p_old_people_group_id number,
 p_new_people_group_id number
) is
  --
  -- user defined types
  --
  type t_asg_rec is record
                    (effective_start_date date,
                     effective_end_date   date,
                     people_group_id      number,
                     id_flex_num          number);
  --
  -- Bugfix 3720575
  -- Added these extra user-defined types to enable bulk-inserts...
  type t_alu_id is table of pay_assignment_link_usages_f.assignment_link_usage_id%type
     index by binary_integer;
  --
  type t_alu_start_date is table of pay_assignment_link_usages_f.effective_start_date%type
     index by binary_integer;
  --
  type t_alu_end_date is table of pay_assignment_link_usages_f.effective_end_date%type
     index by binary_integer;
  --
  type t_alu_link_id is table of pay_assignment_link_usages_f.element_link_id%type
     index by binary_integer;
  --
  -- find all instances of the assignment that has a people group
  --
  cursor csr_assignment
          (
           p_assignment_id number
          ) is
    select asg.effective_start_date,
           asg.effective_end_date,
           asg.people_group_id,
           ppg.id_flex_num
    from   per_all_assignments_f asg,
           pay_people_groups ppg
    where  asg.assignment_id = p_assignment_id
      and  asg.people_group_id is not null
      and  asg.assignment_type not in ('A' ,'O') -- non-applicant assignments only
      and  ppg.people_group_id = asg.people_group_id
    order by asg.effective_start_date;
  --
  -- find all element links that are match the people group
  --
  cursor csr_link
          (
           p_id_flex_num          number,
          p_business_group_id    number,
          p_people_group_id      number,
          p_effective_start_date date,
          p_effective_end_date   date
          ) is
    select el.element_link_id,
           min(el.effective_start_date) effective_start_date,
           max(el.effective_end_date) effective_end_date
    from   pay_element_links_f el,
           pay_people_groups el_pg,
           pay_people_groups asg_pg
    where  asg_pg.id_flex_num      = p_id_flex_num
      and  asg_pg.people_group_id  = p_people_group_id
      and  el_pg.id_flex_num       = asg_pg.id_flex_num
      and  el.business_group_id + 0    = p_business_group_id
      and  el.effective_start_date <= p_effective_end_date
      and  el.effective_end_date   >= p_effective_start_date
      and  el_pg.people_group_id   = el.people_group_id
      and  (el_pg.segment1  is null or el_pg.segment1  = asg_pg.segment1)
      and  (el_pg.segment2  is null or el_pg.segment2  = asg_pg.segment2)
      and  (el_pg.segment3  is null or el_pg.segment3  = asg_pg.segment3)
      and  (el_pg.segment4  is null or el_pg.segment4  = asg_pg.segment4)
      and  (el_pg.segment5  is null or el_pg.segment5  = asg_pg.segment5)
      and  (el_pg.segment6  is null or el_pg.segment6  = asg_pg.segment6)
      and  (el_pg.segment7  is null or el_pg.segment7  = asg_pg.segment7)
      and  (el_pg.segment8  is null or el_pg.segment8  = asg_pg.segment8)
      and  (el_pg.segment9  is null or el_pg.segment9  = asg_pg.segment9)
      and  (el_pg.segment10 is null or el_pg.segment10 = asg_pg.segment10)
      and  (el_pg.segment11 is null or el_pg.segment11 = asg_pg.segment11)
      and  (el_pg.segment12 is null or el_pg.segment12 = asg_pg.segment12)
      and  (el_pg.segment13 is null or el_pg.segment13 = asg_pg.segment13)
      and  (el_pg.segment14 is null or el_pg.segment14 = asg_pg.segment14)
      and  (el_pg.segment15 is null or el_pg.segment15 = asg_pg.segment15)
      and  (el_pg.segment16 is null or el_pg.segment16 = asg_pg.segment16)
      and  (el_pg.segment17 is null or el_pg.segment17 = asg_pg.segment17)
      and  (el_pg.segment18 is null or el_pg.segment18 = asg_pg.segment18)
      and  (el_pg.segment19 is null or el_pg.segment19 = asg_pg.segment19)
      and  (el_pg.segment20 is null or el_pg.segment20 = asg_pg.segment20)
      and  (el_pg.segment21 is null or el_pg.segment21 = asg_pg.segment21)
      and  (el_pg.segment22 is null or el_pg.segment22 = asg_pg.segment22)
      and  (el_pg.segment23 is null or el_pg.segment23 = asg_pg.segment23)
      and  (el_pg.segment24 is null or el_pg.segment24 = asg_pg.segment24)
      and  (el_pg.segment25 is null or el_pg.segment25 = asg_pg.segment25)
      and  (el_pg.segment26 is null or el_pg.segment26 = asg_pg.segment26)
      and  (el_pg.segment27 is null or el_pg.segment27 = asg_pg.segment27)
      and  (el_pg.segment28 is null or el_pg.segment28 = asg_pg.segment28)
      and  (el_pg.segment29 is null or el_pg.segment29 = asg_pg.segment29)
      and  (el_pg.segment30 is null or el_pg.segment30 = asg_pg.segment30)
    group by el.element_link_id;
  --
  -- local variables
  --
  v_assignment      t_asg_rec;
  v_asg_start_date  date;
  v_asg_end_date    date;
  v_people_group_id number;
  v_id_flex_num     number;
  v_alu_start_date  date;
  v_alu_end_date    date;
  v_alu_term_date   date;
  v_dummy_date      date;
  -- Bugfix 3720575
  -- Added these extra local variables types to enable bulk-inserts...
  v_counter            number := 0;
  v_alu_id_tab         t_alu_id;
  v_alu_start_date_tab t_alu_start_date;
  v_alu_end_date_tab   t_alu_end_date;
  v_alu_link_id_tab    t_alu_link_id;
  --
  l_proc            varchar2 (72);
  --
        procedure check_parameters is
                begin
                --
                hr_utility.trace('In '||l_proc);
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                        --
                hr_utility.trace ('     p_business_group_id = '
                        ||to_char (p_business_group_id));
                        --
                hr_utility.trace ('     p_dt_mode = '
                        ||p_dt_mode);
                        --
                hr_utility.trace ('     p_old_people_group_id = '
                        ||to_char (p_old_people_group_id));
                        --
                hr_utility.trace ('     p_new_people_group_id = '
                        ||to_char (p_new_people_group_id));
                        --
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     l_proc := g_package||'maintain_alu_asg';
     check_parameters;
  end if;
  --
  -- Bugfix 3720575
  -- Only rebuild Assignment Link Usages when there has been a genuine change
  -- in people group.
  --
  -- N.B: When both p_old_people_group_id and p_new_people_group_id are null
  -- we want to perform the rebuild, this is probably because the calling
  -- code is not setting these 2 params properly.
  --
  if (nvl(p_old_people_group_id,-1) <> nvl(p_new_people_group_id,-2)
      and p_dt_mode in ('UPDATE',
                        'UPDATE_CHANGE_INSERT',
                        'CORRECTION')
     )
     -- Always rebuild for the following DT modes:
     or p_dt_mode in ('INSERT',
                      'UPDATE_OVERRIDE',
                      'DELETE',
                      'FUTURE_CHANGE',
                      'DELETE_NEXT_CHANGE',
                      'ZAP')
  then
    --
    -- Delete all the alu's for the assignment
    --
    delete from pay_assignment_link_usages_f alu
    where alu.assignment_id = p_assignment_id;
    --
    --
    open csr_assignment(p_assignment_id);
    --
    -- get first assignment record to initialise variables
    --
    fetch csr_assignment into v_assignment;
    if csr_assignment%found then
      --
      -- set up variables for use in loop
      --
      v_asg_start_date  := v_assignment.effective_start_date;
      v_asg_end_date    := v_assignment.effective_end_date;
      v_people_group_id := v_assignment.people_group_id;
      v_id_flex_num     := v_assignment.id_flex_num;
      --
      while csr_assignment%found loop
        --
        --
        -- get next assignment record
        --
        fetch csr_assignment into v_assignment;
        --
        -- detect change of people group , non-contiguous people groups or
        -- that the last record has been read
        --
        if csr_assignment%notfound or not
           (v_assignment.people_group_id = v_people_group_id and
            v_assignment.effective_start_date = v_asg_end_date + 1) then
          --
          --
          -- find all links that overlap with the assignment and have the same
          -- people group as the assignment
          --
          for v_link in csr_link(v_id_flex_num,
                                 p_business_group_id,
                                 v_people_group_id,
                                 v_asg_start_date,
                                 v_asg_end_date) loop
            --
            -- calculate the start date of the alu which is the greatest of
            -- the start dates of the link and assignment
            --
            v_alu_start_date := greatest(v_asg_start_date,
                                          v_link.effective_start_date);
            --
            --
            -- find the termination date of the alu if the person has been
            -- terminated ie. taking inot account the termination processing
            -- rule of the element type. if no termination has taken place
             -- then the date returned is the end of time.
            -- nb. v_dummy_date is used to soak up some out parameters that
             -- are not required.
            --
            -- Bug 5202396.
            -- The check for termination rule caused a significant performance
            -- issue. Since ALU is only a part of the link eligibility rules,
            -- we can determine the end date with the link and the assignment.
            --
            /***
            hr_entry.entry_asg_pay_link_dates(p_assignment_id,
                                              v_link.element_link_id,
                                              v_alu_start_date,
                                              v_alu_term_date,
                                              v_dummy_date,
                                              v_dummy_date,
                                              v_dummy_date,
                                              v_dummy_date,
                                              false);
            ***/
            --
            -- calculate the end date of the alu which is the least of the
            -- end dates of the link and assignment.
            --
            v_alu_end_date := least(v_asg_end_date,
                                    v_link.effective_end_date);
            --
            -- Make sure that the alu start date is on or before the end date
            --
            if v_alu_start_date <= v_alu_end_date then
              --
              -- Bugfix 3720575
              -- Cache the ALU details so they can be bulk-inserted later...
              --
              v_counter := v_counter + 1;
              --
              -- Bug 5202396.
              -- The sequence values are now directly obtained in the
              -- insert statement.
              --
              -- select pay_assignment_link_usages_s.nextval
              -- into v_alu_id_tab(v_counter)
              -- from dual;
              --
              v_alu_start_date_tab(v_counter) := v_alu_start_date;
              v_alu_end_date_tab(v_counter) := v_alu_end_date;
              v_alu_link_id_tab(v_counter) := v_link.element_link_id;
              --
            end if;
            --
          end loop;
          --
          -- reset start and end dates
          --
          v_asg_start_date := v_assignment.effective_start_date;
          v_asg_end_date   := v_assignment.effective_end_date;
          --
        else
          --
          -- increment end date of assignment
          --
          v_asg_end_date := v_assignment.effective_end_date;
          --
        end if;
        --
        -- save value for future comparison
        --
        v_people_group_id := v_assignment.people_group_id;
        v_id_flex_num     := v_assignment.id_flex_num;
        --
        -- Bugfix 3720575
        -- Create the ALUs in bulk
        --
        forall i in 1..v_counter
            insert into pay_assignment_link_usages_f
            (assignment_link_usage_id,
             effective_start_date,
             effective_end_date,
             element_link_id,
             assignment_id)
            values
            (
             pay_assignment_link_usages_s.nextval,
             v_alu_start_date_tab(i),
             v_alu_end_date_tab(i),
             v_alu_link_id_tab(i),
             p_assignment_id
            );
        --
        v_counter := 0;
        v_alu_id_tab.delete;
        v_alu_start_date_tab.delete;
        v_alu_end_date_tab.delete;
        v_alu_link_id_tab.delete;
        --
      end loop;
      --
    end if;
    --
    close csr_assignment;
    --
  end if;
  --
  if g_debug then
     hr_utility.trace('Out '||l_proc);
  end if;
  --
end maintain_alu_asg;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.remove_pay_proposals                                            --
--                                                                          --
-- DESCRIPTION                                                              --
-- Salary Admin specific procedure that will remove a pay proposal if there --
-- are no element entries for the pay proposal.                             --
------------------------------------------------------------------------------
--
procedure remove_pay_proposals
(
 p_assignment_id   number,
 p_pay_proposal_id number
) is
begin
  --
  -- Remove the pay proposal if there are no element entries for it.
  --
  delete from per_pay_proposals pp
  where  pp.assignment_id = p_assignment_id
    and  pp.pay_proposal_id = p_pay_proposal_id
    and  not exists
            (select null
             from   pay_element_entries_f ee
             where  ee.assignment_id = pp.assignment_id
               and  ee.creator_type = 'SP'
               and  ee.creator_id = pp.pay_proposal_id);
end remove_pay_proposals;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.remove_quickpay_inclusions                                      --
--                                                                          --
-- DESCRIPTION                                                              --
-- Removes any quickpay inclusions for which the element entry no longer    --
-- date effectively exists NB. the procedure is used with the assumption    --
-- that the caller has identified the period over which the element entry   --
-- is being removed. Added due to WW Bug 269356.                            --
------------------------------------------------------------------------------
--
procedure remove_quickpay_inclusions
(
 p_element_entry_id      number,
 p_validation_start_date date,
 p_validation_end_date   date
) is
begin
  --
  -- Remove any quickpay inclusions for the element entry where the element
  -- entry no longer date effectively exists.
  --
  delete from pay_quickpay_inclusions pqi
  where  pqi.element_entry_id = p_element_entry_id
    and  exists
           (select null
            from   pay_assignment_actions paa,
                   pay_payroll_actions    ppa
            where  paa.assignment_action_id = pqi.assignment_action_id
              and  ppa.payroll_action_id    = paa.payroll_action_id
              and  ppa.date_earned between p_validation_start_date
                                       and p_validation_end_date);
--
end remove_quickpay_inclusions;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.remove_quickpay_exclusions                                      --
--                                                                          --
-- DESCRIPTION                                                              --
-- Introduced via enhancement 3368211
-- Removes any quickpay exclusions for which the element entry no longer    --
-- date effectively exists NB. the procedure is used with the assumption    --
-- that the caller has identified the period over which the element entry   --
-- is being removed.                                                        --
------------------------------------------------------------------------------
--
procedure remove_quickpay_exclusions
(
 p_element_entry_id      number,
 p_validation_start_date date,
 p_validation_end_date   date
) is
begin
  --
  -- Remove any quickpay exclusions for the element entry where the element
  -- entry no longer date effectively exists.
  --
  delete from pay_quickpay_exclusions pqe
  where  pqe.element_entry_id = p_element_entry_id
    and  exists
           (select null
            from   pay_assignment_actions paa,
                   pay_payroll_actions    ppa
            where  paa.assignment_action_id = pqe.assignment_action_id
              and  ppa.payroll_action_id    = paa.payroll_action_id
              and  ppa.date_earned between p_validation_start_date
                                       and p_validation_end_date);
--
end remove_quickpay_exclusions;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.check_payroll_changes_asg                                       --
--                                                                          --
-- DESCRIPTION                                                              --
-- Makes sure that payroll exists for the lifetime of the assignment that   --
-- uses it and also makes sure that no assignment actions are orphaned by a --
-- change in payroll.                                                       --
------------------------------------------------------------------------------
--
procedure check_payroll_changes_asg
(
 p_assignment_id         number,
 p_payroll_id            number,
 p_dt_mode               varchar2,
 p_validation_start_date date,
 p_validation_end_date   date
) is
  --
  -- local variables
  --
  v_check_failed varchar2(1) := 'N';
  --
  --
  cursor csr_del_or_zap is
   select   pa.effective_date
     from   pay_assignment_actions aa,
            pay_payroll_actions pa
     where  aa.assignment_id = p_assignment_id
       and  pa.action_type not in ('X', 'BEE')
       and  pa.payroll_action_id = aa.payroll_action_id
       and  ((pa.effective_date >= p_validation_start_date)
             or
             (pa.date_earned >= p_validation_start_date));
  --
  cursor csr_not_insert is
   select   pa.effective_date
     from   pay_assignment_actions aa,
            pay_payroll_actions pa
    where  aa.assignment_id = p_assignment_id
      and  pa.payroll_action_id = aa.payroll_action_id
      and  pa.action_type not in ('X', 'BEE')
      and  ((pa.effective_date between p_validation_start_date
                                   and p_validation_end_date)
            or
            (pa.date_earned between p_validation_start_date
                                and p_validation_end_date))
      and  not (exists
                               (select null
                                from   per_all_assignments_f asg
                                where  asg.assignment_id  = p_assignment_id
                                  and  pa.effective_date
                                           between asg.effective_start_date
                                               and asg.effective_end_date
                                  and  asg.payroll_id + 0 = p_payroll_id)
                and exists
                               (select null
                                from   per_all_assignments_f asg
                                where  asg.assignment_id  = p_assignment_id
                                  and  nvl(pa.date_earned,pa.effective_date)
                                           between asg.effective_start_date
                                               and asg.effective_end_date
                                  and  asg.payroll_id + 0 = p_payroll_id));
  --
  cursor csr_valid_payroll (p_date date) is
   select   'Y'
     from   sys.dual
    where   not exists
                               (select null
                                from   per_all_assignments_f asg
                                where  asg.assignment_id  = p_assignment_id
                                  and  p_date
                                           between asg.effective_start_date
                                               and asg.effective_end_date
                                  and  asg.payroll_id + 0 = p_payroll_id);
  --
  l_dummy          varchar2(1);
  l_date           date;
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In check_payroll_changes_asg');
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_payroll_id = '
                        ||to_char (p_payroll_id));
                hr_utility.trace ('     p_dt_mode = '
                        ||p_dt_mode);
                hr_utility.trace ('     p_validation_start_date = '
                        ||to_char (p_validation_start_date));
                hr_utility.trace ('     p_validation_end_date = '
                        ||to_char (p_validation_end_date));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     check_parameters;
  end if;
  --
  -- check to see that when a payroll is used on the assignment it exists for
  -- the duration of the assignments use of the payroll.
  --
  if p_payroll_id is not null and not
     (p_dt_mode = 'DELETE' or
      p_dt_mode = 'ZAP') then
    --
    --
    begin
      select 'Y'
      into   v_check_failed
      from   sys.dual
      where  exists
                (select null
                from   pay_payrolls_f pay
                where  pay.payroll_id = p_payroll_id
                  and  p_validation_end_date >
                                 (select max(pay2.effective_end_date)
                                  from   pay_payrolls_f pay2
                                  where  pay2.payroll_id = pay.payroll_id));
      --
      if v_check_failed = 'Y' then
        hr_utility.set_message(801,'HR_6590_ASS_PYRLL_NOT_EXIST');
         hr_utility.raise_error;
      end if;
      --
    exception
      when no_data_found then null;
    end;
  --
  end if;
  --
  -- Checks to see if there are any assignment actions for the assignment
  -- which are for a payroll that is not on the assignment record at the
  -- point in time the assignment action was processed ie. there are no
  -- orphaned assignment actions nb. the check is different for 'delete' and
  -- 'zap' modes because there is not an new payroll to take into account.
  --
  if p_dt_mode = 'DELETE' or
     p_dt_mode = 'ZAP' then
    --
    --
    -- begin
    --   select 'Y'
    --   into   v_check_failed
    --   from   sys.dual
    --   where  exists
    --             (select null
    --             from   pay_assignment_actions aa,
    --                    pay_payroll_actions pa
    --             where  aa.assignment_id = p_assignment_id
    --               and  pa.action_type not in ('X', 'BEE')
    --               and  pa.payroll_action_id = aa.payroll_action_id
    --               and  ((pa.effective_date >= p_validation_start_date)
    --                     or
    --                     (pa.date_earned >= p_validation_start_date)));
    -- exception
    --   when no_data_found then null;
    -- end;
    --
    --
    for l_rec in csr_del_or_zap loop
       --
       if l_rec.effective_date >= p_validation_start_date then
          l_date := l_rec.effective_date;
          v_check_failed := 'Y';
          exit;
       else
          hr_utility.set_message(801,'PAY_449682_RUN_EXISTS_FOR_DE');
          hr_utility.set_warning;
       end if;
       --
    end loop;
    --
  --
  -- Check if there assignment actions that would be invalidated by the
  -- change to the assignment.
  --
  elsif not p_dt_mode = 'INSERT' then
    --
    --
    -- begin
    --   select 'Y'
    --   into   v_check_failed
    --   from   sys.dual
    --   where  exists
    --             (select null
    --             from   pay_assignment_actions aa,
    --                    pay_payroll_actions pa
    --             where  aa.assignment_id = p_assignment_id
    --               and  pa.payroll_action_id = aa.payroll_action_id
    --               and  pa.action_type not in ('X', 'BEE')
    --               and  ((pa.effective_date between p_validation_start_date
    --                                            and p_validation_end_date)
    --                     or
    --                     (pa.date_earned between p_validation_start_date
    --                                         and p_validation_end_date))
    --               and  not (exists
    --                            (select null
    --                             from   per_all_assignments_f asg
    --                             where  asg.assignment_id  = p_assignment_id
    --                               and  pa.effective_date
    --                                        between asg.effective_start_date
    --                                            and asg.effective_end_date
    --                               and  asg.payroll_id + 0 = p_payroll_id)
    --                         and exists
    --                            (select null
    --                             from   per_all_assignments_f asg
    --                             where  asg.assignment_id  = p_assignment_id
    --                               and  nvl(pa.date_earned,pa.effective_date)
    --                                        between asg.effective_start_date
    --                                            and asg.effective_end_date
    --                               and  asg.payroll_id + 0 = p_payroll_id)));
    --   exception
    --     when no_data_found then null;
    --   end;
    --
    for l_rec in csr_not_insert loop
       --
       if (l_rec.effective_date >= p_validation_start_date and
           l_rec.effective_date <= p_validation_end_date) then
          --
          open csr_valid_payroll(l_rec.effective_date);
          fetch csr_valid_payroll into l_dummy;
          if csr_valid_payroll%found then
             l_date := l_rec.effective_date;
             v_check_failed := 'Y';
             exit;
          else
             --
             hr_utility.set_message(801,'PAY_449682_RUN_EXISTS_FOR_DE');
             hr_utility.set_warning;
             --
          end if;
          close csr_valid_payroll;
          --
       else
          --
          hr_utility.set_message(801,'PAY_449682_RUN_EXISTS_FOR_DE');
          hr_utility.set_warning;
          --
       end if;
       --
    end loop;
    --
  end if;
  --
  if v_check_failed = 'Y' then
    hr_utility.set_message(801,'HR_449757_ASS_ACTIONS_EXIST');
    hr_utility.set_message_token('1', fnd_date.date_to_displaydate(l_date));
    hr_utility.raise_error;
  end if;
  --
end check_payroll_changes_asg;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.cache_element_entry                                             --
--                                                                          --
-- DESCRIPTION                                                              --
-- When splitting element entries ie. when there is a change in assignment  --
-- criteria, the entry values are cached and used when creating the second  --
-- part of the entry.                                                       --
------------------------------------------------------------------------------
--
procedure cache_element_entry
(
 p_element_entry_id   number,
 p_date               date,
 p_ele_entry_rec      out nocopy hrentmnt.t_ele_entry_rec,
 p_num_entry_values   out nocopy number,
 p_input_value_id_tbl out nocopy hr_entry.number_table,
 p_entry_value_tbl    out nocopy hr_entry.varchar2_table
) is
  --
  -- Finds all entry values for an entry.
  --
  cursor csr_entry_values
          (
           p_element_entry_id number,
           p_date             date
         ) is
    select eev.input_value_id,
            eev.screen_entry_value,
           iv.uom,
-- change 115.30
           iv.LOOKUP_TYPE,
-- Bugfix 2827092
           iv.value_set_id,
           et.input_currency_code
    from   pay_element_entry_values_f eev,
           pay_input_values_f iv,
           pay_element_types_f et
    where  eev.element_entry_id = p_element_entry_id
      and  iv.input_value_id = eev.input_value_id
      and  et.element_type_id = iv.element_type_id
      and  eev.effective_end_date = p_date
      and  p_date between iv.effective_start_date
                      and iv.effective_end_date
      and  p_date between et.effective_start_date
                      and et.effective_end_date;
  --
  -- Local Variables
  --
  v_ele_entry_rec      hrentmnt.t_ele_entry_rec;
  v_num_values         number := 0;
  v_input_value_id_tbl hr_entry.number_table;
  v_entry_value_tbl    hr_entry.varchar2_table;
  v_db_format          varchar2(60);
  v_screen_format      varchar2(80);
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.cache_element_entry');
                --
                hr_utility.trace ('');
                hr_utility.trace ('     p_element_entry_id = '
                        ||to_char (p_element_entry_id));
                hr_utility.trace ('     p_date = '
                        ||to_char (p_date));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Fetch entry information into a record.
  --
  begin
    select ee.cost_allocation_keyflex_id,
           ee.creator_type,
           ee.entry_type,
           ee.comment_id,
           ee.creator_id,
           ee.reason,
           ee.target_entry_id,
           ee.subpriority,
           ee.personal_payment_method_id,
           ee.date_earned,
           ee.balance_adj_cost_flag,
           ee.source_asg_action_id,
           ee.source_link_id,
           ee.source_trigger_entry,
           ee.source_period,
           ee.source_run_type,
           ee.source_start_date,
           ee.source_end_date,
           ee.attribute_category,
           ee.attribute1,
           ee.attribute2,
           ee.attribute3,
           ee.attribute4,
           ee.attribute5,
           ee.attribute6,
           ee.attribute7,
           ee.attribute8,
           ee.attribute9,
           ee.attribute10,
           ee.attribute11,
           ee.attribute12,
           ee.attribute13,
           ee.attribute14,
           ee.attribute15,
           ee.attribute16,
           ee.attribute17,
           ee.attribute18,
           ee.attribute19,
           ee.attribute20,
           ee.entry_information_category,
           ee.entry_information1,
           ee.entry_information2,
           ee.entry_information3,
           ee.entry_information4,
           ee.entry_information5,
           ee.entry_information6,
           ee.entry_information7,
           ee.entry_information8,
           ee.entry_information9,
           ee.entry_information10,
           ee.entry_information11,
           ee.entry_information12,
           ee.entry_information13,
           ee.entry_information14,
           ee.entry_information15,
           ee.entry_information16,
           ee.entry_information17,
           ee.entry_information18,
           ee.entry_information19,
           ee.entry_information20,
           ee.entry_information21,
           ee.entry_information22,
           ee.entry_information23,
           ee.entry_information24,
           ee.entry_information25,
           ee.entry_information26,
           ee.entry_information27,
           ee.entry_information28,
           ee.entry_information29,
           ee.entry_information30
    into   v_ele_entry_rec
    from   pay_element_entries_f ee
    where  ee.element_entry_id = p_element_entry_id
      and  p_date between ee.effective_start_date
                       and ee.effective_end_date;
  exception
    when no_data_found then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                    'hrentmnt.cache_element_entry');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end;
  --
  -- Retrieve all entry values for the element entry and convert into screen
  -- format. Store these in a table to be used later by the element entry
  -- api call hr_entry_api.insert_element_entry.
  --
  for v_entry_value in csr_entry_values(p_element_entry_id,
                                         p_date) loop
    --
    v_screen_format                    := null;   -- must be null at each loop.
    v_num_values                       := v_num_values + 1;
    v_input_value_id_tbl(v_num_values) := v_entry_value.input_value_id;
    --
    v_db_format := v_entry_value.screen_entry_value;

-- start of change 115.30
    if g_debug then
       hr_utility.trace('*****before*****');
       hr_utility.trace('*****v_entry_value.lookup_type>' ||
                                   v_entry_value.lookup_type || '<');
       hr_utility.trace('*****v_entry_value.value_set_id>' ||
                                   v_entry_value.value_set_id || '<');
       hr_utility.trace('*****v_entry_value.screen_entry_value>' ||
                                   v_entry_value.screen_entry_value || '<');
    end if;
    --
    -- if entry has lookup and the entry_value is not null,
    -- do special processing
    --
    if v_entry_value.lookup_type is not null
       and v_entry_value.screen_entry_value is not null
    then
        SELECT meaning
        INTO   v_screen_format
        FROM   HR_LOOKUPS
        WHERE  lookup_type = v_entry_value.lookup_type
        and    lookup_code = v_entry_value.screen_entry_value;
    -- Bugfix 2827092
    elsif v_entry_value.value_set_id is not null
          and v_entry_value.screen_entry_value is not null
    then
      --
      -- Entry value is validated by a value set
      -- We need to derive the screen format
      --
      v_screen_format := pay_input_values_pkg.decode_vset_value(
        p_value_set_id => v_entry_value.value_set_id,
        p_value_set_value => v_entry_value.screen_entry_value);
      --
    else
    --
    -- Convert entry value from DB format to screen format.
    --
    hr_chkfmt.changeformat
      (v_db_format,
        v_screen_format,
        v_entry_value.uom,
        v_entry_value.input_currency_code);
    end if;

    if g_debug then
       hr_utility.trace('*****v_screen_format>' || v_screen_format || '<');
       hr_utility.trace('*****v_db_format>' || v_db_format || '<');
       hr_utility.trace('*****after*****');
    end if;
-- end of change 115.30

    --
    -- Store screen format in table.
    --
    v_entry_value_tbl(v_num_values) := v_screen_format;
    --
  end loop;
  --
  -- Assign out variables ie. entry record and tables containing entry values.
  --
  p_ele_entry_rec      := v_ele_entry_rec;
  p_num_entry_values   := v_num_values;
  p_input_value_id_tbl := v_input_value_id_tbl;
  p_entry_value_tbl    := v_entry_value_tbl;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.cache_element_entry');
  end if;
  --
end cache_element_entry;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.check_entry_overridden                                          --
--                                                                          --
-- DESCRIPTION                                                              --
-- Checks to see if a change in the existence of a recurring element entry  --
-- will leave an override for it that will exist outside the recurring      --
-- entry.                                                                   --
------------------------------------------------------------------------------
--
procedure check_entry_overridden
(
 p_assignment_id         number,
 p_element_entry_id      number,
 p_validation_start_date date,
 p_validation_end_date   date
) is
 --
 -- Local Variables
 --
 v_entry_overridden  varchar2(1) := 'N';
 --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.check_entry_overridden');
                hr_utility.trace ('');
                hr_utility.trace('      p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace('      p_element_entry_id = '
                        ||to_char (p_element_entry_id));
                hr_utility.trace('      p_validation_start_date = '
                        ||to_char (p_validation_start_date));
                hr_utility.trace('      p_validation_end_date = '
                        ||to_char (p_validation_end_date));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Make sure that the recurring entry about to be altered ie. deleted or
  -- shortened does not have an adjustment over the time of change. An
  -- adjustment's target entry should exist for the duration of the
  -- adjustment.
  --
  begin
    select 'Y'
    into   v_entry_overridden
    from   sys.dual
    where  exists
              (select null
               from   pay_element_entries_f ee
               where  ee.assignment_id = p_assignment_id
                 and  ee.entry_type in ('A','R')
                 and  ee.target_entry_id = p_element_entry_id
                 and  ee.effective_start_date <= p_validation_end_date
                 and  ee.effective_end_date   >= p_validation_start_date);
  exception
    when no_data_found then null;
  end;
  --
  if v_entry_overridden = 'Y' then
   hr_utility.set_message(801, 'HR_6304_ELE_ENTRY_DT_DEL_ADJ');
   hr_utility.raise_error;
  end if;
  --
end check_entry_overridden;
--
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.log_entry_event                                                 --
--                                                                          --
-- DESCRIPTION                                                              --
-- This procedure is used to record the events in pay_process_events. This  --
-- operation is normally carried out in the API, in below cases we don't    --
-- call API.
-- 1) Backdating the start date of an entry.                                --
-- 2) Extendinging the end date of an entry.                                --
-- For test case Ref Bug#9197105
------------------------------------------------------------------------------
--
procedure log_entry_event (p_element_entry_id     in pay_element_entries_f.element_entry_id%TYPE
                          ,p_old_date             in date
                          ,p_new_date             in date
                          ,p_start_or_end_date    in varchar2
                          ,p_old_start_date       in date
                          ,p_old_end_date         in date
                          ,p_old_upd_action_id    in pay_element_entries_f.updating_action_id%TYPE
                          ,p_old_upd_action_type  in pay_element_entries_f.updating_action_type%TYPE) is

  cursor csr_entry is
  select ee.original_entry_id,
         ee.cost_allocation_keyflex_id,
         ee.creator_type,
         ee.entry_type,
         ee.comment_id,
         ee.creator_id,
         ee.reason,
         ee.target_entry_id,
         ee.subpriority,
         ee.personal_payment_method_id,
         ee.date_earned,
         ee.source_id,
         ee.balance_adj_cost_flag,
         ee.source_asg_action_id,
         ee.source_link_id,
         ee.source_trigger_entry,
         ee.source_period,
         ee.source_run_type,
         ee.source_start_date,
         ee.source_end_date,
         ee.assignment_id,
         ee.updating_action_id,
         ee.updating_action_type,
         ee.element_link_id,
         ee.element_type_id,
         ee.object_version_number,
         ee.attribute_category,
         ee.attribute1,
         ee.attribute2,
         ee.attribute3,
         ee.attribute4,
         ee.attribute5,
         ee.attribute6,
         ee.attribute7,
         ee.attribute8,
         ee.attribute9,
         ee.attribute10,
         ee.attribute11,
         ee.attribute12,
         ee.attribute13,
         ee.attribute14,
         ee.attribute15,
         ee.attribute16,
         ee.attribute17,
         ee.attribute18,
         ee.attribute19,
         ee.attribute20,
         ee.entry_information_category,
         ee.entry_information1,
         ee.entry_information2,
         ee.entry_information3,
         ee.entry_information4,
         ee.entry_information5,
         ee.entry_information6,
         ee.entry_information7,
         ee.entry_information8,
         ee.entry_information9,
         ee.entry_information10,
         ee.entry_information11,
         ee.entry_information12,
         ee.entry_information13,
         ee.entry_information14,
         ee.entry_information15,
         ee.entry_information16,
         ee.entry_information17,
         ee.entry_information18,
         ee.entry_information19,
         ee.entry_information20,
         ee.entry_information21,
         ee.entry_information22,
         ee.entry_information23,
         ee.entry_information24,
         ee.entry_information25,
         ee.entry_information26,
         ee.entry_information27,
         ee.entry_information28,
         ee.entry_information29,
         ee.entry_information30
  from   pay_element_entries_f ee
  where  ee.element_entry_id = p_element_entry_id
  and    ee.effective_start_date = decode(p_start_or_end_date,
                                         'START',p_new_date,
                                         ee.effective_start_date)
  and    ee.effective_end_date   = decode(p_start_or_end_date,
                                         'END',p_new_date,
                                         ee.effective_end_date);
v_entry_rec            csr_entry%rowtype;
l_proc                 varchar2(100) := g_package||' log_entry_event';

l_updating_action_id   pay_element_entries_f.updating_action_id%TYPE;
l_updating_action_type pay_element_entries_f.updating_action_type%TYPE;
l_effective_start_date pay_element_entries_f.effective_start_date%TYPE;
l_effective_end_date   pay_element_entries_f.effective_end_date%TYPE;

l_datetrack_mode  varchar2(10);
l_effective_date    date;

begin
  hr_utility.set_location(l_proc, 10);
  hr_utility.trace('p_element_entry_id   => '||p_element_entry_id);
  hr_utility.trace('p_start_or_end_date  => '||p_start_or_end_date);
  hr_utility.trace('p_old_date           => '||p_old_date);
  hr_utility.trace('p_new_date           => '||p_new_date);
  hr_utility.trace('p_old_start_date     => '||p_old_start_date);
  hr_utility.trace('p_old_end_date       => '||p_old_end_date);

  /*Get the old entry data*/
  open  csr_entry;
  fetch csr_entry into v_entry_rec;
  if (csr_entry%NOTFOUND) then
      close csr_entry;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hrentmnt.log_entry_event');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  l_updating_action_id   := p_old_upd_action_id;
  l_updating_action_type := p_old_upd_action_type;

  /*Determining the start date and end date of the new record*/
  if (p_start_or_end_date = 'START') then
    if (p_old_upd_action_type <> 'S') then
      l_updating_action_id   := null;
      l_updating_action_type := null;
    end if;
    l_effective_start_date := p_new_date;
    l_effective_end_date   := p_old_end_date;
  elsif (p_start_or_end_date = 'END') then
    if (p_old_upd_action_type <> 'U') then
      l_updating_action_id   := null;
      l_updating_action_type := null;
    end if;
    l_effective_start_date := p_old_start_date;
    l_effective_end_date   := p_new_date;
  end if;
  if (p_start_or_end_date = 'START') then
  	l_datetrack_mode := 'UPDATE';
    l_effective_date := p_new_date;
  else
    l_datetrack_mode := 'DELETE';
  end if;

  /*Find out the session date for effective date. Eventhough we pass the
    session date, the new date to which the record is back-dated/extended
    is inserted in EFFECTIVE_DATE of the PROCESS_EVENTS. If need comes
    need to revisit the code to store the proper date.*/
  begin
	    select effective_date into l_effective_date
		  from   fnd_sessions where session_id = userenv('sessionid');
	  	exception
		  when no_data_found then
	  	   l_effective_date := p_new_date;
  end;
  hr_utility.trace('l_session_date   => '||l_effective_date);
  hr_utility.trace('l_datetrack_mode => '||l_datetrack_mode);
  if (p_start_or_end_date = 'START' or p_start_or_end_date = 'END') then
    begin
      /*Calling the AFTER-UPDATE API call to log the event in
        PAY_PROCESS_EVENTS.*/
      pay_ele_rku.after_update
       (
         p_effective_date                 => l_effective_date
        ,p_validation_start_date          => p_old_start_date
        ,p_validation_end_date            => p_old_end_date
        ,p_datetrack_mode                 => l_datetrack_mode
        -- new values set
        ,p_element_entry_id               => p_element_entry_id
        ,p_effective_start_date           => l_effective_start_date
        ,p_effective_end_date             => l_effective_end_date
        ,p_original_entry_id              => v_entry_rec.original_entry_id
        ,p_creator_type                   => v_entry_rec.creator_type
        ,p_cost_allocation_keyflex_id     => v_entry_rec.cost_allocation_keyflex_id
        -- Needed for row handler
        ,p_target_entry_id                => null
        ,p_source_id                      => null
        ,p_balance_adj_cost_flag          => null
        ,p_entry_type                     => null
        --
        ,p_updating_action_id             => l_updating_action_id
        ,p_updating_action_type           => l_updating_action_type
        ,p_comment_id                     => v_entry_rec.comment_id
        ,p_creator_id                     => v_entry_rec.creator_id
        ,p_reason                         => v_entry_rec.reason
        ,p_subpriority                    => v_entry_rec.subpriority
        ,p_date_earned                    => v_entry_rec.date_earned
        ,p_personal_payment_method_id     => v_entry_rec.personal_payment_method_id
        ,p_attribute_category             => v_entry_rec.attribute_category
        ,p_attribute1                     => v_entry_rec.attribute1
        ,p_attribute2                     => v_entry_rec.attribute2
        ,p_attribute3                     => v_entry_rec.attribute3
        ,p_attribute4                     => v_entry_rec.attribute4
        ,p_attribute5                     => v_entry_rec.attribute5
        ,p_attribute6                     => v_entry_rec.attribute6
        ,p_attribute7                     => v_entry_rec.attribute7
        ,p_attribute8                     => v_entry_rec.attribute8
        ,p_attribute9                     => v_entry_rec.attribute9
        ,p_attribute10                    => v_entry_rec.attribute10
        ,p_attribute11                    => v_entry_rec.attribute11
        ,p_attribute12                    => v_entry_rec.attribute12
        ,p_attribute13                    => v_entry_rec.attribute13
        ,p_attribute14                    => v_entry_rec.attribute14
        ,p_attribute15                    => v_entry_rec.attribute15
        ,p_attribute16                    => v_entry_rec.attribute16
        ,p_attribute17                    => v_entry_rec.attribute17
        ,p_attribute18                    => v_entry_rec.attribute18
        ,p_attribute19                    => v_entry_rec.attribute19
        ,p_attribute20                    => v_entry_rec.attribute20
        ,p_entry_information_category     => v_entry_rec.entry_information_category
        ,p_entry_information1             => v_entry_rec.entry_information1
        ,p_entry_information2             => v_entry_rec.entry_information2
        ,p_entry_information3             => v_entry_rec.entry_information3
        ,p_entry_information4             => v_entry_rec.entry_information4
        ,p_entry_information5             => v_entry_rec.entry_information5
        ,p_entry_information6             => v_entry_rec.entry_information6
        ,p_entry_information7             => v_entry_rec.entry_information7
        ,p_entry_information8             => v_entry_rec.entry_information8
        ,p_entry_information9             => v_entry_rec.entry_information9
        ,p_entry_information10            => v_entry_rec.entry_information10
        ,p_entry_information11            => v_entry_rec.entry_information11
        ,p_entry_information12            => v_entry_rec.entry_information12
        ,p_entry_information13            => v_entry_rec.entry_information13
        ,p_entry_information14            => v_entry_rec.entry_information14
        ,p_entry_information15            => v_entry_rec.entry_information15
        ,p_entry_information16            => v_entry_rec.entry_information16
        ,p_entry_information17            => v_entry_rec.entry_information17
        ,p_entry_information18            => v_entry_rec.entry_information18
        ,p_entry_information19            => v_entry_rec.entry_information19
        ,p_entry_information20            => v_entry_rec.entry_information20
        ,p_entry_information21            => v_entry_rec.entry_information21
        ,p_entry_information22            => v_entry_rec.entry_information22
        ,p_entry_information23            => v_entry_rec.entry_information23
        ,p_entry_information24            => v_entry_rec.entry_information24
        ,p_entry_information25            => v_entry_rec.entry_information25
        ,p_entry_information26            => v_entry_rec.entry_information26
        ,p_entry_information27            => v_entry_rec.entry_information27
        ,p_entry_information28            => v_entry_rec.entry_information28
        ,p_entry_information29            => v_entry_rec.entry_information29
        ,p_entry_information30            => v_entry_rec.entry_information30
        ,p_object_version_number          => v_entry_rec.object_version_number
        ,p_comments                       => null
        ,p_all_entry_values_null          => null
        -- old values set
        ,p_effective_start_date_o         => p_old_start_date
        ,p_effective_end_date_o           => p_old_end_date
        ,p_cost_allocation_keyflex_id_o   => v_entry_rec.cost_allocation_keyflex_id
        ,p_assignment_id_o                => v_entry_rec.assignment_id
        ,p_updating_action_id_o           => v_entry_rec.updating_action_id
        ,p_updating_action_type_o         => v_entry_rec.updating_action_type
        ,p_element_link_id_o              => v_entry_rec.element_link_id
        ,p_original_entry_id_o            => v_entry_rec.original_entry_id
        ,p_creator_type_o                 => v_entry_rec.creator_type
        ,p_entry_type_o                   => v_entry_rec.entry_type
        ,p_comment_id_o                   => v_entry_rec.comment_id
        ,p_creator_id_o                   => v_entry_rec.creator_id
        ,p_reason_o                       => v_entry_rec.reason
        ,p_target_entry_id_o              => v_entry_rec.target_entry_id
        ,p_source_id_o                    => v_entry_rec.source_id
        ,p_attribute_category_o           => v_entry_rec.attribute_category
        ,p_attribute1_o                   => v_entry_rec.attribute1
        ,p_attribute2_o                   => v_entry_rec.attribute2
        ,p_attribute3_o                   => v_entry_rec.attribute3
        ,p_attribute4_o                   => v_entry_rec.attribute4
        ,p_attribute5_o                   => v_entry_rec.attribute5
        ,p_attribute6_o                   => v_entry_rec.attribute6
        ,p_attribute7_o                   => v_entry_rec.attribute7
        ,p_attribute8_o                   => v_entry_rec.attribute8
        ,p_attribute9_o                   => v_entry_rec.attribute9
        ,p_attribute10_o                  => v_entry_rec.attribute10
        ,p_attribute11_o                  => v_entry_rec.attribute11
        ,p_attribute12_o                  => v_entry_rec.attribute12
        ,p_attribute13_o                  => v_entry_rec.attribute13
        ,p_attribute14_o                  => v_entry_rec.attribute14
        ,p_attribute15_o                  => v_entry_rec.attribute15
        ,p_attribute16_o                  => v_entry_rec.attribute16
        ,p_attribute17_o                  => v_entry_rec.attribute17
        ,p_attribute18_o                  => v_entry_rec.attribute18
        ,p_attribute19_o                  => v_entry_rec.attribute19
        ,p_attribute20_o                  => v_entry_rec.attribute20
        ,p_entry_information_category_o   => v_entry_rec.entry_information_category
        ,p_entry_information1_o           => v_entry_rec.entry_information1
        ,p_entry_information2_o           => v_entry_rec.entry_information2
        ,p_entry_information3_o           => v_entry_rec.entry_information3
        ,p_entry_information4_o           => v_entry_rec.entry_information4
        ,p_entry_information5_o           => v_entry_rec.entry_information5
        ,p_entry_information6_o           => v_entry_rec.entry_information6
        ,p_entry_information7_o           => v_entry_rec.entry_information7
        ,p_entry_information8_o           => v_entry_rec.entry_information8
        ,p_entry_information9_o           => v_entry_rec.entry_information9
        ,p_entry_information10_o          => v_entry_rec.entry_information10
        ,p_entry_information11_o          => v_entry_rec.entry_information11
        ,p_entry_information12_o          => v_entry_rec.entry_information12
        ,p_entry_information13_o          => v_entry_rec.entry_information13
        ,p_entry_information14_o          => v_entry_rec.entry_information14
        ,p_entry_information15_o          => v_entry_rec.entry_information15
        ,p_entry_information16_o          => v_entry_rec.entry_information16
        ,p_entry_information17_o          => v_entry_rec.entry_information17
        ,p_entry_information18_o          => v_entry_rec.entry_information18
        ,p_entry_information19_o          => v_entry_rec.entry_information19
        ,p_entry_information20_o          => v_entry_rec.entry_information20
        ,p_entry_information21_o          => v_entry_rec.entry_information21
        ,p_entry_information22_o          => v_entry_rec.entry_information22
        ,p_entry_information23_o          => v_entry_rec.entry_information23
        ,p_entry_information24_o          => v_entry_rec.entry_information24
        ,p_entry_information25_o          => v_entry_rec.entry_information25
        ,p_entry_information26_o          => v_entry_rec.entry_information26
        ,p_entry_information27_o          => v_entry_rec.entry_information27
        ,p_entry_information28_o          => v_entry_rec.entry_information28
        ,p_entry_information29_o          => v_entry_rec.entry_information29
        ,p_entry_information30_o          => v_entry_rec.entry_information30
        ,p_subpriority_o                  => v_entry_rec.subpriority
        ,p_personal_payment_method_id_o   => v_entry_rec.personal_payment_method_id
        ,p_date_earned_o                  => v_entry_rec.date_earned
        ,p_object_version_number_o        => v_entry_rec.object_version_number
        ,p_balance_adj_cost_flag_o        => v_entry_rec.balance_adj_cost_flag
        ,p_comments_o                     => null
        ,p_element_type_id_o              => v_entry_rec.element_type_id
        ,p_all_entry_values_null_o        => null
       );
       exception
         when hr_api.cannot_find_prog_unit then
           hr_api.cannot_find_prog_unit_error
                 (p_module_name => 'PAY_ELEMENT_ENTRIES_F'
                 ,p_hook_type   => 'AU'
                 );
       end;
  end if;

end log_entry_event;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.validate_adjust_entry                                           --
--                                                                          --
-- DESCRIPTION                                                              --
-- Validates and adjusts recurring element entries. It accepts 2 modes ie.  --
-- UPDATE and DELETE NB. only UPDATE will result in changes to an           --
-- element entry. The other 2 modes only carry out validation / 3rd party   --
-- logic as it is assumed the DML is done elsewhere. This should be called  --
-- whenever an element entry is created , removed or changed.               --
------------------------------------------------------------------------------
--
procedure validate_adjust_entry
(
 p_mode                 varchar2,
 p_assignment_id        number,
 p_element_entry_id     number,
 p_start_or_end_date    varchar2,
 p_old_date             date,
 p_new_date             date,
 p_effective_start_date date,
 p_effective_end_date   date,
 p_entries_changed      in out nocopy varchar2
) is
  --
  -- Cursor to fetch element information Nb. there are two distinct parts to
  -- the statement. The first part returns if the element entry is used for
  -- salary admin while the second returns if the element entry is not used
  -- for salary admin.
  --
  cursor csr_ele_info is
    select EL.element_type_id element_type_id,
            'Y'                salary_element
    from   pay_element_entries_f EE,
            pay_element_links_f   EL
    where  EE.element_entry_id = p_element_entry_id
      and  EL.element_link_id  = EE.element_link_id
      and  nvl(p_old_date,p_effective_start_date) between
                           EE.effective_start_date and EE.effective_end_date
      and  nvl(p_old_date,p_effective_start_date) between
                           EL.effective_start_date and EL.effective_end_date
      and  exists (select null
                    from   pay_input_values_f IV,
                           per_pay_bases      PB
                   where  IV.element_type_id = EL.element_type_id
                      and  PB.input_value_id  = IV.input_value_id)
    UNION ALL
    select EL.element_type_id element_type_id,
            'N'                salary_element
    from   pay_element_entries_f EE,
            pay_element_links_f   EL
    where  EE.element_entry_id = p_element_entry_id
      and  EL.element_link_id  = EE.element_link_id
      and  nvl(p_old_date,p_effective_start_date) between
                           EE.effective_start_date and EE.effective_end_date
      and  nvl(p_old_date,p_effective_start_date) between
                           EL.effective_start_date and EL.effective_end_date
      and  not exists (select null
                        from   pay_input_values_f IV,
                               per_pay_bases      PB
                       where  IV.element_type_id = EL.element_type_id
                          and  PB.input_value_id  = IV.input_value_id);
  --
  -- Local Variables
  --
  v_element_type_id   number;
  v_change_start_date date;
  v_change_end_date   date;
  v_ele_info_rec      csr_ele_info%rowtype;

  l_effective_start_date pay_element_entries_f.effective_start_date%TYPE;
  l_effective_end_date   pay_element_entries_f.effective_end_date%TYPE;
  l_updating_action_type pay_element_entries_f.updating_action_type%TYPE;
  l_updating_action_id   pay_element_entries_f.updating_action_id%TYPE;
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.validate_adjust_entry');
                hr_utility.trace ('');
                hr_utility.trace ('     p_mode = '
                        ||p_mode);
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_element_entry_id = '
                        ||to_char (p_element_entry_id));
                hr_utility.trace ('     p_start_or_end_date = '
                        ||p_start_or_end_date);
                hr_utility.trace ('     p_old_date = '
                        ||to_char (p_old_date));
                hr_utility.trace ('     p_new_date = '
                        ||to_char (p_new_date));
                hr_utility.trace ('     p_effective_start_date = '
                        ||to_char (p_effective_start_date));
                hr_utility.trace ('     p_effective_end_date = '
                        ||to_char (p_effective_end_date));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Get information about the element entry for future use.
  --
  open csr_ele_info;
  fetch csr_ele_info into v_ele_info_rec;
  if csr_ele_info%notfound then
    close csr_ele_info;
    --
    -- The cursor unexpectedly returned no rows. Present an error message
    -- which includes all the procedure's parameters to assist diagnosis of
    -- why this error occurred.
    --
    hr_utility.set_message(801, 'HR_51058_PAY_VALIDATE_ADJUST');
    hr_utility.set_message_token('P_MODE',p_mode);
    hr_utility.set_message_token('P_ASSIGNMENT_ID',p_assignment_id);
    hr_utility.set_message_token('P_ELEMENT_ENTRY_ID',p_element_entry_id);
    hr_utility.set_message_token('P_START_OR_END_DATE',p_start_or_end_date);
    hr_utility.set_message_token('P_OLD_DATE',p_old_date);
    hr_utility.set_message_token('P_NEW_DATE',p_new_date);
    hr_utility.set_message_token('P_EFFECTIVE_START_DATE',p_effective_start_date);
    hr_utility.set_message_token('P_EFFECTIVE_END_DATE',p_effective_end_date);
    hr_utility.set_message_token('P_ENTRIES_CHANGED',p_entries_changed);
    hr_utility.raise_error;
  end if;
  close csr_ele_info;
  --
  -- Set the dates over which the change is taking place.
  --
  if p_mode = 'DELETE' then
    --
    v_change_start_date := p_effective_start_date;
    v_change_end_date   := p_effective_end_date;
    --
  elsif p_mode = 'UPDATE' then
    --
    v_change_start_date := least(p_old_date,p_new_date);
    v_change_end_date   := greatest(p_old_date,p_new_date);
    --
  end if;
  --
  hr_entry.trigger_workload_shifting
    ('ELEMENT_ENTRY',
     p_assignment_id,
     v_change_start_date,
     v_change_end_date);
  --
  hr_entry.chk_element_entry_open
    (v_ele_info_rec.element_type_id,
     v_change_start_date,
     v_change_start_date,
     v_change_end_date,
     p_assignment_id);
  --
  -- When removing or shortening element entries need to
  --
  --   make sure that the element entry has not been overidden.
  --   remove orphaned quickpay inclusions.
  --   set flag to indicate that element entries have been affected.
  --
  if p_mode = 'DELETE' or
     (p_mode = 'UPDATE' and
      ((p_start_or_end_date = 'START' and
         p_old_date < p_new_date) or
        (p_start_or_end_date = 'END' and
         p_old_date > p_new_date))) then
    --
    hrentmnt.check_entry_overridden
      (p_assignment_id,
       p_element_entry_id,
       v_change_start_date,
       v_change_end_date);
    --
    -- Enhancement 3368211
    --
    -- Delete both QuickPay Inclusions AND Exclusions.
    --
    -- There is a chance the element entry id exists in both tables if
    -- any QuickPay assignment actions were created before the QuickPay
    -- Exclusions data model was in use.
    --
    hrentmnt.remove_quickpay_exclusions
      (p_element_entry_id,
       v_change_start_date,
       v_change_end_date);
    --
    hrentmnt.remove_quickpay_inclusions
      (p_element_entry_id,
       v_change_start_date,
       v_change_end_date);
    --
    -- Set flag to identify that element entries have been shortened
    -- or removed. If the entry is a salary entry then set the flag to 'S' so
    -- that a special warning can be given to the user. Once the flag has been
    -- set to 'S' then make sure that it cannot be set to 'Y' as this would
    -- cover the fact that a salary element entry had been affected.
    --
    if p_entries_changed IN ('S','I') then
      null;
    else
      if v_ele_info_rec.salary_element = 'Y' then
        p_entries_changed := 'S';
      else
        p_entries_changed := 'Y';
      end if;
    end if;
    --
  end if;

  -- Update the covered dependents and beneficiaries for the element entry
  -- This should be called in both DELETE and UPDATE modes.
  --
  if p_start_or_end_date = 'START' then
    hr_entry.delete_covered_dependants(
                 p_validation_start_date => p_old_date,
                 p_element_entry_id => p_element_entry_id,
                 p_start_date => p_new_date);

    hr_entry.delete_beneficiaries(
                 p_validation_start_date => p_old_date,
                 p_element_entry_id => p_element_entry_id,
                 p_start_date => p_new_date);

  elsif p_start_or_end_date = 'END' then
    hr_entry.delete_covered_dependants(
                 p_validation_start_date => p_old_date,
                 p_element_entry_id => p_element_entry_id,
                 p_end_date => p_new_date);

    hr_entry.delete_beneficiaries(
                 p_validation_start_date => p_old_date,
                 p_element_entry_id => p_element_entry_id,
                 p_end_date => p_new_date);

  end if;

  --
  -- When updating an element entry do the DML to move the start or end date.
  --
  -- Bug#9197105 : As we are calling DML so this event is not logging into the
  -- PAY_PROCESS_EVENTS table. So, after the DML is executed, we are calling
  -- AFTER-UPDATE API of element entries to log this event.
  hr_utility.trace('Mode => '||p_mode);
  if p_mode = 'UPDATE' then
    --
    if p_start_or_end_date = 'START' then
    --
      /*Collecting old data to push the details into PAY_PROCESS_EVENTS*/
      hr_utility.trace('Collecting the old data : For back-dating the start date');
      select ee.effective_start_date,
             ee.effective_end_date,
             ee.updating_action_id,
             ee.updating_action_type
      into   l_effective_start_date,
             l_effective_end_date,
             l_updating_action_id,
             l_updating_action_type
      from   pay_element_entries_f ee
      where  ee.element_entry_id     = p_element_entry_id
      and    ee.effective_start_date = p_old_date;

      /*Back-dating the start date of the entry.*/
      hr_utility.trace('Calling actual DML to back-date the effective start date');
      update pay_element_entries_f ee
      set    ee.effective_start_date = p_new_date,
             ee.updating_action_id = decode(ee.updating_action_type, 'S', ee.updating_action_id,
                                                                          null),
             ee.updating_action_type = decode(ee.updating_action_type, 'S', 'S', null)
      where  ee.element_entry_id     = p_element_entry_id
         and  ee.effective_start_date = p_old_date;
      --
      update pay_element_entry_values_f eev
      set    eev.effective_start_date = p_new_date
      where  eev.element_entry_id     = p_element_entry_id
         and  eev.effective_start_date = p_old_date;
      --
    elsif p_start_or_end_date = 'END' then
      --
      --
      /*Collecting old data to push the details into PAY_PROCESS_EVENTS*/
      hr_utility.trace('Collecting the old data : For extending the end date');
      select ee.effective_start_date,
             ee.effective_end_date,
             ee.updating_action_id,
             ee.updating_action_type
      into   l_effective_start_date,
             l_effective_end_date,
             l_updating_action_id,
             l_updating_action_type
      from   pay_element_entries_f ee
      where  ee.element_entry_id     = p_element_entry_id
        and  ee.effective_end_date = p_old_date;

      /*Extending the effective_end_date of the entry.*/
      hr_utility.trace('Calling actual DML to extend the effective end date');
      update pay_element_entries_f ee
      set    ee.effective_end_date = p_new_date,
             ee.updating_action_id = decode(ee.updating_action_type, 'U', ee.updating_action_id,
                                                                          null),
             ee.updating_action_type = decode(ee.updating_action_type, 'U', 'U', null)
      where  ee.element_entry_id   = p_element_entry_id
         and  ee.effective_end_date = p_old_date;
      --
      update pay_element_entry_values_f eev
      set    eev.effective_end_date = p_new_date
      where  eev.element_entry_id   = p_element_entry_id
         and  eev.effective_end_date = p_old_date;
      --
   end if;
   if p_start_or_end_date = 'START' or p_start_or_end_date = 'END' then
     /*As we have back-dated the entry's start date/extended the entry's end date,
       we need to log this event by calling AFTER-UPDATE trigger.*/
      hr_utility.trace('Calling LOG_ENTRY_EVENT to log the event of above date change');
      log_entry_event(    p_element_entry_id    => p_element_entry_id
                          ,p_old_date            => p_old_date
                          ,p_new_date            => p_new_date
                          ,p_start_or_end_date   => p_start_or_end_date
                          ,p_old_start_date      => l_effective_start_date
                          ,p_old_end_date        => l_effective_end_date
                          ,p_old_upd_action_id   => l_updating_action_id
                          ,p_old_upd_action_type => l_updating_action_type);
   end if;
  end if;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.validate_adjust_entry');
  end if;
  --
end validate_adjust_entry;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.validate_purge                                                  --
--                                                                          --
-- DESCRIPTION                                                              --
-- Validates whether it is legal to purge a particular element entry        --
-- depending on the setting of the HR_ELE_ENTRY_PURGE_CONTROL profile and   --
-- the setting of the elements non_payments_flag.                           --
-- Because of the circumstances of calling, the only real way to tell if    --
-- element has been purged is to actually see if any rows remain on the     --
-- database.  i.e. the user doesn't specify a dt mode that we can use.      --
------------------------------------------------------------------------------
--
procedure validate_purge
(
 p_element_entry_id in number,
 p_element_link_id in varchar2
) is
  l_prof_value        varchar2(30);
  l_count             number;
  l_non_payments_flag varchar2(30);
begin
  -- Read the prof value.
  fnd_profile.get('HR_ELE_ENTRY_PURGE_CONTROL', l_prof_value);
  --
  -- See if profile is set in such a way that
  -- we need to perform validation.
  if l_prof_value is not null and l_prof_value <> 'A' then
    -- Use the element_link_id to obtain the non_payment_flag
    -- on the element classification.  We are not concerned
    -- with datetrack joins here.
    begin
      select nvl(pec.non_payments_flag, 'N')
      into   l_non_payments_flag
      from   pay_element_links_f         pel,
             pay_element_types_f         pet,
             pay_element_classifications pec
      where  pel.element_link_id   = p_element_link_id
      and    pet.element_type_id   = pel.element_type_id
      and    pec.classification_id = pet.classification_id
      and    not exists (
             select null
             from   pay_element_entries_f pee
             where  pee.element_entry_id = p_element_entry_id)
      and    rownum = 1;
    exception
      -- If we didn't get a row, this means that we haven't
      -- purged the entry.  We therefore don't care and
      -- can immediately return.
      when no_data_found then return;
    end;
    --
    -- Check whether we need to raise error.
    if l_prof_value = 'N' or
      (l_prof_value = 'I' and l_non_payments_flag = 'N')
    then
      -- Either no entries can be purged or attempting to
      -- purge a payments type of entry when we shouldn't.
      hr_utility.set_message (800,'HR_33000_ENTRY_CANT_PURGE');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
end validate_purge;
--
procedure maintain_dependent_entities(
        p_element_entry_id in number,
        p_element_entry_ESD in date,
        p_element_entry_EED in date,
        p_new_element_entry_id in number,
        p_new_element_entry_ESD in date,
        p_new_element_entry_EED in date)
is
begin
    hr_utility.trace('> hrentmnt.maintain_dependent_entities');

if g_debug then
   hr_utility.trace('p_element_entry_id     >' || p_element_entry_id || '<');
   hr_utility.trace('p_element_entry_ESD    >' || p_element_entry_ESD || '<');
   hr_utility.trace('p_element_entry_EED    >' || p_element_entry_EED || '<');

   hr_utility.trace('p_new_element_entry_id >' || p_new_element_entry_id || '<');
   hr_utility.trace('p_new_element_entry_ESD>' || p_new_element_entry_ESD || '<');
   hr_utility.trace('p_new_element_entry_EED>' || p_new_element_entry_EED || '<');
end if;

    null;

end maintain_dependent_entities;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.open_asg_criteria_cur                                           --
--                                                                          --
-- SINCE                                                                    --
-- Bugfix 5584631                                                           --
--                                                                          --
-- DESCRIPTION                                                              --
--                                                                          --
-- USAGES                                                                   --
-- Used by recreate_cached_entry and val_nonrec_entries.                    --
------------------------------------------------------------------------------
procedure open_asg_criteria_cur (
  p_assignment_id         in number,
  p_validation_start_date in date,
  p_asg_criteria_cv       in out nocopy t_asg_criteria_cur -- cursor variable
)
is
begin
  --
  open p_asg_criteria_cv for
  select asg.organization_id,
         asg.people_group_id,
         asg.job_id,
         asg.position_id,
         asg.grade_id,
         asg.location_id,
         asg.employment_category,
         asg.payroll_id,
         asg.pay_basis_id,
         asg.business_group_id
  from   per_all_assignments_f asg
  where  asg.assignment_id = p_assignment_id
  and    p_validation_start_date between
           asg.effective_start_date and asg.effective_end_date;
  --
end open_asg_criteria_cur;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.open_eligible_links_cur                                         --
--                                                                          --
-- SINCE                                                                    --
-- Bugfix 5584631                                                           --
--                                                                          --
-- DESCRIPTION                                                              --
-- Opens a ref cursor variable for a cursor of element links for given      --
-- eligibility criteria and element type.                                   --
-- The OUT parameter, p_eligible_links_cv, is a pointer to the cursor that  --
-- is successfully opened.                                                  --
--                                                                          --
-- USAGES                                                                   --
-- Used by recreate_cached_entry and val_nonrec_entries.                    --
------------------------------------------------------------------------------
procedure open_eligible_links_cur (
  p_assignment_id         in            number,
  p_validation_start_date in            date,
  p_validation_end_date   in            date,
  p_element_type_id       in            number,
  p_organization_id       in            number,
  p_people_group_id       in            number,
  p_job_id                in            number,
  p_position_id           in            number,
  p_grade_id              in            number,
  p_location_id           in            number,
  p_employment_category   in            varchar2,
  p_payroll_id            in            number,
  p_pay_basis_id          in            number,
  p_business_group_id     in            number,
  p_eligible_links_cv     in out nocopy t_eligible_links_cur -- cursor variable
)
is
begin
  --
  open p_eligible_links_cv for
  select el.element_link_id,
         min(el.effective_start_date) effective_start_date,
         max(el.effective_end_date)   effective_end_date
  from   pay_element_links_f el
  where  el.element_type_id = p_element_type_id
  and    el.standard_link_flag = 'N'
  and    el.business_group_id = p_business_group_id
  --
  -- make sure EL piece overlaps validation period
  --
  -- Bugfix 4627931
  -- Ensure the EL exists as at the validation start date.
  -- This is because hr_entry_api expects the EL to exist as at this date
  -- and raises error APP-PAY-07027 if it does not.
  -- Also, we should not re-create entries after there has been any gap in
  -- eligibility after the validation start date.
  and    p_validation_start_date between el.effective_start_date and el.effective_end_date
  --
  -- match crieria on EL to that on asg
  --
  and    (
          (el.payroll_id is not null and
           el.payroll_id = p_payroll_id)
          or
          (el.link_to_all_payrolls_flag = 'Y' and
           p_payroll_id is not null)
          or
          (el.link_to_all_payrolls_flag = 'N' and
           el.payroll_id is null)
         )
  and    (el.job_id is null or
          el.job_id = p_job_id)
  and    (el.grade_id is null or
          el.grade_id = p_grade_id)
  and    (el.position_id is null or
          el.position_id = p_position_id)
  and    (el.organization_id is null or
          el.organization_id = p_organization_id)
  and    (el.location_id is null or
          el.location_id = p_location_id)
  and    (el.employment_category is null or
          el.employment_category = p_employment_category)
  and    (
          el.pay_basis_id = p_pay_basis_id
          or
          el.pay_basis_id is null and
          not exists
              (select pb.pay_basis_id
               from   per_pay_bases      pb,
                      pay_input_values_f iv
               where  iv.element_type_id = el.element_type_id
               and    p_validation_start_date between
                       iv.effective_start_date and iv.effective_end_date
               and    pb.input_value_id = iv.input_value_id
               and    pb.business_group_id = p_business_group_id
              )
          or
          el.pay_basis_id is null and
          exists
              (select pb.pay_basis_id
               from   per_pay_bases      pb,
                      pay_input_values_f iv
               where  iv.element_type_id = el.element_type_id
               and    p_validation_start_date between
                       iv.effective_start_date and iv.effective_end_date
               and    pb.input_value_id = iv.input_value_id
               and    pb.pay_basis_id = p_pay_basis_id
              )
          or
          el.pay_basis_id is null and
          p_pay_basis_id is null and
          exists
              (select pb.pay_basis_id
               from   per_pay_bases      pb,
                      pay_input_values_f iv
               where  iv.element_type_id = el.element_type_id
               and    p_validation_start_date between
                       iv.effective_start_date and iv.effective_end_date
               and    pb.input_value_id = iv.input_value_id
               and    pb.business_group_id = p_business_group_id
              )
         )
  and    (el.people_group_id is null
          or exists
            (select null
             from   pay_assignment_link_usages_f alu
             where  alu.assignment_id = p_assignment_id
             and    alu.element_link_id = el.element_link_id
             and    alu.effective_start_date <= p_validation_end_date
             and    alu.effective_end_date   >= p_validation_start_date
            )
         )
  group by el.element_link_id;
  --
end open_eligible_links_cur;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.recreate_cached_entry                                           --
--                                                                          --
-- SINCE                                                                    --
-- Bugfix 5247607                                                           --
--                                                                          --
-- DESCRIPTION                                                              --
-- Attempts to recreate a deleted/end-dated recurring entry from cache, via --
-- a different link if a suitable one exists.                               --
-- The OUT parameter, p_entry_recreated, will be set to TRUE if the cached  --
-- entry is successfully recreated.                                         --
-- Otherwise, it will be FALSE.                                             --
------------------------------------------------------------------------------
procedure recreate_cached_entry (
  p_assignment_id           in            number,
  p_element_type_id         in            number,
  p_element_link_id         in            number,
  p_element_entry_id        in            number,
  p_validation_start_date   in            date,
  p_validation_end_date     in            date,
  p_ee_effective_start_date in            date,
  p_ee_effective_end_date   in            date,
  p_ee_creator_type         in            varchar2,
  p_rec_ee                  in            hrentmnt.t_ele_entry_rec,
  p_num_eevs                in            number,
  p_tbl_ivids               in            hr_entry.number_table,
  p_tbl_eevs                in            hr_entry.varchar2_table,
  p_entry_recreated            out nocopy boolean
)
is
  --
  l_proc             varchar2(80) := 'hrentmnt.recreate_cached_entry';
  l_asg_criteria_cv   t_asg_criteria_cur;
  l_rec_asg_criteria  t_asg_criteria_rec;
  l_eligible_links_cv t_eligible_links_cur;
  rec_eligible_links  t_eligible_links_rec;
  l_entry_recreated  boolean := false;
  l_prof_value       varchar2(30);
  l_eeid_out         number;
  l_calc_ee_esd      date;
  l_calc_ee_eed      date;
  l_ee_eed_out       date;

  sp_exists          number; --Bug 9295968
  --
begin

sp_exists :=0;
  --
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('********** BEFORE OAB **********');
  end if;

/*Bug 9295968 Begin */
begin
  select 1
  into sp_exists
  from per_assignments_f
  where assignment_id = p_assignment_id
  and pay_basis_id is not null
  and p_validation_start_date between effective_start_date and effective_end_date;

exception when no_data_found then
 sp_exists:=0;
end;
/*Bug 9295968 End */
  --
  -- Read the prof value
  --
  fnd_profile.get('PAY_ORIG_EL_BEHAVE', l_prof_value);
  if g_debug then
    hr_utility.trace('l_prof_value>' || l_prof_value || '<');
  end if;
  --
  -- Check if any other entries can be created up to the REE's EED,
  -- create REE from VSD to REE's EED
  -- nb. do not look for any new EEs if the EE being updated is a 'SP' EE
  --
  if l_prof_value is null and sp_exists <> 0 then
    -- change 115.28
    --  and p_ee_creator_type <> 'SP' then (Commented for the bug fix 8779392,
    --  so that we check for SP EE also.)
    --
    if g_debug then
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('EE being updated>' || p_element_entry_id || '<');
      hr_utility.trace('VSD>' || p_validation_start_date || '<');
      hr_utility.trace('VED>' || p_validation_end_date || '<');
      hr_utility.trace('EE ESD>' || p_ee_effective_start_date || '<');
      hr_utility.trace('EE EED>' || p_ee_effective_end_date || '<');
    end if;
    --
    -- Fetch the assignment criteria
    open_asg_criteria_cur(p_assignment_id, p_validation_start_date, l_asg_criteria_cv);
    fetch l_asg_criteria_cv into l_rec_asg_criteria;
    close l_asg_criteria_cv;
    --
    open_eligible_links_cur (
      p_assignment_id,
      -- Bugfix 5629530
      greatest(p_ee_effective_start_date, p_validation_start_date),
      least(p_ee_effective_end_date, p_validation_end_date),
      p_element_type_id,
      l_rec_asg_criteria.organization_id,
      l_rec_asg_criteria.people_group_id,
      l_rec_asg_criteria.job_id,
      l_rec_asg_criteria.position_id,
      l_rec_asg_criteria.grade_id,
      l_rec_asg_criteria.location_id,
      l_rec_asg_criteria.employment_category,
      l_rec_asg_criteria.payroll_id,
      l_rec_asg_criteria.pay_basis_id,
      l_rec_asg_criteria.business_group_id,
      l_eligible_links_cv
    );
    --
    loop
      --
      if g_debug then
        hr_utility.set_location(l_proc,25);
      end if;
      --
      fetch l_eligible_links_cv into rec_eligible_links;
      exit when l_eligible_links_cv%notfound;
      --
      if g_debug then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('*****   element_link_id>' ||
          rec_eligible_links.element_link_id || '<');
        hr_utility.trace('*****   ESD of EL>' ||
          rec_eligible_links.effective_start_date || '<');
        hr_utility.trace('*****   EED of EL>' ||
          rec_eligible_links.effective_end_date || '<');
      end if;
      --
      l_calc_ee_esd := greatest(p_ee_effective_start_date,
                                p_validation_start_date);
      l_calc_ee_eed := least(p_ee_effective_end_date,
                             rec_eligible_links.effective_end_date);
      --
      hr_entry_api.insert_element_entry(
        p_effective_start_date  => l_calc_ee_esd,
        p_effective_end_date    => l_ee_eed_out,
        p_element_entry_id      => l_eeid_out,
        p_assignment_id         => p_assignment_id,
        p_element_link_id       => rec_eligible_links.element_link_id,
        p_creator_type          => p_rec_ee.creator_type,
        p_entry_type            => p_rec_ee.entry_type,
        p_cost_allocation_keyflex_id
                                => p_rec_ee.cost_allocation_keyflex_id,
        p_comment_id            => p_rec_ee.comment_id,
        p_creator_id            => p_rec_ee.creator_id,
        p_reason                => p_rec_ee.reason,
        p_target_entry_id       => p_rec_ee.target_entry_id,
        p_subpriority           => p_rec_ee.subpriority,
        p_personal_payment_method_id
                                => p_rec_ee.personal_payment_method_id,
        p_date_earned           => p_rec_ee.date_earned,
        p_attribute_category    => p_rec_ee.attribute_category,
        p_attribute1            => p_rec_ee.attribute1,
        p_attribute2            => p_rec_ee.attribute2,
        p_attribute3            => p_rec_ee.attribute3,
        p_attribute4            => p_rec_ee.attribute4,
        p_attribute5            => p_rec_ee.attribute5,
        p_attribute6            => p_rec_ee.attribute6,
        p_attribute7            => p_rec_ee.attribute7,
        p_attribute8            => p_rec_ee.attribute8,
        p_attribute9            => p_rec_ee.attribute9,
        p_attribute10           => p_rec_ee.attribute10,
        p_attribute11           => p_rec_ee.attribute11,
        p_attribute12           => p_rec_ee.attribute12,
        p_attribute13           => p_rec_ee.attribute13,
        p_attribute14           => p_rec_ee.attribute14,
        p_attribute15           => p_rec_ee.attribute15,
        p_attribute16           => p_rec_ee.attribute16,
        p_attribute17           => p_rec_ee.attribute17,
        p_attribute18           => p_rec_ee.attribute18,
        p_attribute19           => p_rec_ee.attribute19,
        p_attribute20           => p_rec_ee.attribute20,
        p_entry_information_category
                                => p_rec_ee.entry_information_category,
        p_entry_information1    => p_rec_ee.entry_information1,
        p_entry_information2    => p_rec_ee.entry_information2,
        p_entry_information3    => p_rec_ee.entry_information3,
        p_entry_information4    => p_rec_ee.entry_information4,
        p_entry_information5    => p_rec_ee.entry_information5,
        p_entry_information6    => p_rec_ee.entry_information6,
        p_entry_information7    => p_rec_ee.entry_information7,
        p_entry_information8    => p_rec_ee.entry_information8,
        p_entry_information9    => p_rec_ee.entry_information9,
        p_entry_information10   => p_rec_ee.entry_information10,
        p_entry_information11   => p_rec_ee.entry_information11,
        p_entry_information12   => p_rec_ee.entry_information12,
        p_entry_information13   => p_rec_ee.entry_information13,
        p_entry_information14   => p_rec_ee.entry_information14,
        p_entry_information15   => p_rec_ee.entry_information15,
        p_entry_information16   => p_rec_ee.entry_information16,
        p_entry_information17   => p_rec_ee.entry_information17,
        p_entry_information18   => p_rec_ee.entry_information18,
        p_entry_information19   => p_rec_ee.entry_information19,
        p_entry_information20   => p_rec_ee.entry_information20,
        p_entry_information21   => p_rec_ee.entry_information21,
        p_entry_information22   => p_rec_ee.entry_information22,
        p_entry_information23   => p_rec_ee.entry_information23,
        p_entry_information24   => p_rec_ee.entry_information24,
        p_entry_information25   => p_rec_ee.entry_information25,
        p_entry_information26   => p_rec_ee.entry_information26,
        p_entry_information27   => p_rec_ee.entry_information27,
        p_entry_information28   => p_rec_ee.entry_information28,
        p_entry_information29   => p_rec_ee.entry_information29,
        p_entry_information30   => p_rec_ee.entry_information30,
        p_num_entry_values      => p_num_eevs,
        p_input_value_id_tbl    => p_tbl_ivids,
        p_entry_value_tbl       => p_tbl_eevs
      );
      --
      if l_eeid_out is not null then
        -- Set flag to denote entry has been recreated
        l_entry_recreated := true;
      end if;
      --
      if g_debug then
        --
        hr_utility.set_location(l_proc,40);
        hr_utility.trace('*****   new EE>' || l_eeid_out || '<');
        hr_utility.trace('*****   actual ESD of new EE>' ||
          l_calc_ee_esd || '<');
        hr_utility.trace('*****   actual EED of new EE>' ||
          l_ee_eed_out || '<');
        --
      end if;
      --
      if l_ee_eed_out > l_calc_ee_eed then
        --
        -- the above call creates the EE upto the least of the:
        -- EL's EED or
        -- asg piece's EED
        --
        -- if the EED of the created EE is greater than the calc
        -- EED, bring it back
        -- nb. only 1 EE exists at this stage, therefore no need
        --     to use ESD and EED
        --
        if g_debug then
          hr_utility.set_location(l_proc,50);
          hr_utility.trace('*****   bring EED of new EE back');
        end if;
        --
        -- Change l_ee_eed_out here, for separate update to
        -- pay_element_entries_f, below, which *always* occurs.
        --
        l_ee_eed_out := l_calc_ee_eed;
        --
        update pay_element_entry_values_f eev
        set    eev.effective_end_date = l_ee_eed_out
        where  eev.element_entry_id   = l_eeid_out;
        --
      end if;
      --
      -- Set attributes on pay_element_entries_f that are not supported by API.
      -- Also, effective_end_date of new entry is brought back here, if
      -- necessary.
      --
      update pay_element_entries_f pee
      set    pee.effective_end_date    = l_ee_eed_out,
             pee.balance_adj_cost_flag = p_rec_ee.balance_adj_cost_flag,
             pee.source_asg_action_id  = p_rec_ee.source_asg_action_id,
             pee.source_link_id        = p_rec_ee.source_link_id,
             pee.source_trigger_entry  = p_rec_ee.source_trigger_entry,
             pee.source_period         = p_rec_ee.source_period,
             pee.source_run_type       = p_rec_ee.source_run_type,
             pee.source_start_date     = p_rec_ee.source_start_date,
             pee.source_end_date       = p_rec_ee.source_end_date
      where  pee.element_entry_id      = l_eeid_out
      and    l_calc_ee_esd between
               pee.effective_start_date and pee.effective_end_date;
      --
    end loop;
    --
    close l_eligible_links_cv;
    --
  end if;
  --
  -- call routine to maintain entities with FKs to element entry
  -- row just date ended and newly created
  --
  if g_debug then
    hr_utility.set_location(l_proc,60);
    hr_utility.trace('***** maintain dependent entities');
  end if;
  --
  maintain_dependent_entities(
    p_element_entry_id,
    p_ee_effective_start_date,
    p_validation_start_date - 1,
    l_eeid_out,
    l_calc_ee_esd,
    l_calc_ee_eed
  );
  --
  if g_debug then
    hr_utility.set_location(l_proc,70);
    hr_utility.trace('********** AFTER OAB **********');
  end if;
  --
  p_entry_recreated := l_entry_recreated;
  --
end recreate_cached_entry;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.remove_ineligible_recurring                                     --
--                                                                          --
-- DESCRIPTION                                                              --
-- Removes any recurring element entries for a particular assignment and    --
-- element link that exist within a specified period of time that are not   --
-- eligible, or exist beyond the start of the assignment's TERM_ASSIGN status.
------------------------------------------------------------------------------
--
procedure remove_ineligible_recurring
(
 p_assignment_id                       number,
 p_entries_changed       in out nocopy varchar2,
 p_validation_start_date               date,
 p_validation_end_date                 date,
 p_dt_mode                             varchar2 default null
) is
  --
  -- Local Cursors
  --
  cursor csr_orphaned_entries
          (
           p_assignment_id number
          ) is
       select distinct ee.element_entry_id
       from   pay_element_entries_f ee
       where  ee.assignment_id = p_assignment_id;
  --
  cursor csr_entry
          (
           p_assignment_id number,
           p_validation_start_date date,
           p_validation_end_date date
          ) is
       select
            distinct
            ee.element_entry_id,
            ee.creator_type,
            ee.creator_id,
            ee.effective_start_date,
            ee.effective_end_date,
            el.element_link_id,
            el.standard_link_flag,
            el.element_type_id
       from
        pay_element_entries_f ee,
        pay_element_links_f   el,
        pay_element_types_f   et
       where ee.assignment_id = p_assignment_id
       and ee.effective_start_date <= p_validation_end_date
       and ee.effective_end_date >= p_validation_start_date
       and ee.entry_type='E'
       and ee.element_link_id=el.element_link_id
       and el.effective_start_date <= ee.effective_end_date
       and el.effective_end_date >= ee.effective_start_date
        -- start of change 115.18 --
        and ee.effective_start_date between
            el.effective_start_date and el.effective_end_date
        -- end of change 115.18 --
       and el.element_type_id=et.element_type_id
       and et.effective_start_date <= el.effective_end_date
       and et.effective_end_date >= el.effective_start_date
        -- start of change 115.19 --
        and ee.effective_start_date between
            et.effective_start_date and et.effective_end_date
        -- end of change 115.19 --
       and et.processing_type='R'
       and (
        not exists
             (select null
              from   per_all_assignments_f asg
              where asg.assignment_id = ee.assignment_id
	      /* Added Benefits assignment type to the below code to ensure
	      removal of entries wont happen in the case of benifits
	      assignment type also */
               and (asg.assignment_type = 'E' or asg.assignment_type='B')
               and asg.effective_start_date <= p_validation_end_date
               and asg.effective_end_date >= p_validation_start_date
               and  ((el.payroll_id is not null and
                       el.payroll_id = asg.payroll_id)
                 or   (el.link_to_all_payrolls_flag = 'Y' and
                       asg.payroll_id is not null)
                 or   (el.payroll_id is null and
                       el.link_to_all_payrolls_flag = 'N'))
                and  (el.job_id is null or
                      el.job_id = asg.job_id)
                and  (el.grade_id is null or
                      el.grade_id = asg.grade_id)
                and  (el.position_id is null or
                      el.position_id = asg.position_id)
                and  (el.organization_id is null or
                      el.organization_id = asg.organization_id)
                and  (el.location_id is null or
                      el.location_id = asg.location_id)
-- start of change 115.22 --
        and    (
                --
                -- if EL is associated with a pay basis then this clause fails
                --
                el.pay_basis_id is null and
                NOT EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv,
                            PER_PAY_PROPOSALS  pp
                     WHERE  iv.element_type_id = el.element_type_id
                     and    iv.effective_start_date <= asg.effective_end_date   /*Bug 7662923 */
                     and    iv.effective_end_date   >= asg.effective_start_date
                     and    pb.input_value_id = iv.input_value_id
                     and    pb.business_group_id = asg.business_group_id
                     and    pp.assignment_id = asg.assignment_id /*fix 176449*/
                    )
                or
                --
                -- if EL is associated with a pay basis then the associated
                -- PB_ID must match the PB_ID on ASG
                --
                el.pay_basis_id is null and
                EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = el.element_type_id
                     and    iv.effective_start_date <= asg.effective_start_date
                     and    iv.effective_end_date   >= asg.effective_start_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.pay_basis_id = asg.pay_basis_id
                    )
-- change 115.26
                or
                el.standard_link_flag = 'Y' and
                el.pay_basis_id is null and
                asg.pay_basis_id is null and
                EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = el.element_type_id
                     and    iv.effective_start_date <= asg.effective_start_date
                     and    iv.effective_end_date   >= asg.effective_start_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.business_group_id = asg.business_group_id
                    )
                or
                el.pay_basis_id = asg.pay_basis_id
               )
-- end of change 115.22 --
                and  (el.employment_category is null or
                       el.employment_category = asg.employment_category)
                and  (el.people_group_id is null or
                      exists
                         (select null
                         from   pay_assignment_link_usages_f alu
                         where  alu.assignment_id = ee.assignment_id
                           and  alu.element_link_id = ee.element_link_id
                           and  alu.effective_start_date <=
                                              asg.effective_end_date
                           and  alu.effective_end_date >=
                                              asg.effective_start_date))))
;
  --
    procedure check_parameters
    is
      --
    begin
      --
      hr_utility.trace('In hrentmnt.remove_ineligible_recurring');
      hr_utility.trace ('');
      hr_utility.trace ('     p_assignment_id = '||to_char (p_assignment_id));
      hr_utility.trace ('     p_entries_changed = '||p_entries_changed);
      hr_utility.trace ('     p_validation_start_date = '||to_char(p_validation_start_date,'DD-MON-YYYY'));
      hr_utility.trace ('     p_validation_end_date = '||to_char(p_validation_end_date,'DD-MON-YYYY'));
      hr_utility.trace ('     p_dt_mode = '||p_dt_mode);
      hr_utility.trace ('');
      --
    end check_parameters;
  --
    --
    --
    -- Bugfix 4358408
    -- The 'do normal delete of REE', 'bring end date of current REE
    -- backwards' and 'move start date of current REE forwards' logic
    -- within this procedure has all been re-created as modular
    -- procedures (do_normal_delete_of_ree, bring_ree_end_date_backwards
    -- and bring_ree_start_date_forwards respectively).
    --
    procedure do_normal_delete_of_ree (
      p_assignment_id           in            number,
      p_element_type_id         in            number,
      p_element_link_id         in            number,
      p_element_entry_id        in            number,
      p_validation_start_date   in            date,
      p_validation_end_date     in            date,
      p_ee_effective_start_date in            date,
      p_ee_effective_end_date   in            date,
      p_ee_creator_type         in            varchar2,
      p_ee_creator_id           in            number,
      p_entries_changed         in out nocopy varchar2
    )
    is
      -- cursor added for 8870436
       CURSOR csr_bus_group(p_assignment_id number) IS
        SELECT business_group_id
          FROM per_all_assignments_f
         WHERE assignment_id = p_assignment_id;

      -- cursor added for 8870436
	CURSOR csr_leg_grp(p_business_group_id number) IS
	SELECT LEGISLATION_CODE
	FROM per_business_groups
	where business_group_id=p_business_group_id;

      l_rec_ee          hrentmnt.t_ele_entry_rec;
      l_num_eevs        number := 0;
      l_tbl_ivids       hr_entry.number_table;
      l_tbl_eevs        hr_entry.varchar2_table;
      l_entry_recreated boolean := false;
      -- below variables added for 8870436
      l_dyt_mode varchar2(75);
      l_business_group_id number;
      l_legislation_code varchar2(10);
    begin
      --
      if g_debug then
         hr_utility.trace ('***** doing normal delete of REE');
         hr_utility.trace ('***** caching EE before delete');
      end if;
      --
      hrentmnt.cache_element_entry(
        p_element_entry_id,
        p_ee_effective_end_date,
        l_rec_ee,
        l_num_eevs,
        l_tbl_ivids,
        l_tbl_eevs);
      --
      hrentmnt.validate_adjust_entry
        ('DELETE',
         p_assignment_id,
         p_element_entry_id,
         null,
         null,
         null,
         p_ee_effective_start_date,
         p_ee_effective_end_date,
         p_entries_changed);
      --
      delete from pay_element_entry_values_f eev
      where  eev.element_entry_id      = p_element_entry_id
        and  eev.effective_start_date >= p_ee_effective_start_date
        and  eev.effective_end_date   <= p_ee_effective_end_date;
      --
      delete from pay_element_entries_f ee
      where  ee.element_entry_id      = p_element_entry_id
        and  ee.effective_start_date >= p_ee_effective_start_date
        and  ee.effective_end_date   <= p_ee_effective_end_date;
      --
      -- Attempt to recreate cached entry before doing further deletes
      --
      recreate_cached_entry (
        p_assignment_id,
        p_element_type_id,
        p_element_link_id,
        p_element_entry_id,
        p_validation_start_date,
        p_validation_end_date,
        p_ee_effective_start_date,
        p_ee_effective_end_date,
        p_ee_creator_type,
        l_rec_ee,
        l_num_eevs,
        l_tbl_ivids,
        l_tbl_eevs,
        l_entry_recreated
      );
      --
      if not l_entry_recreated then
        --
        -- Cached entry was not recreated so proceed with deletes
        if g_debug then
          hr_utility.trace(' Cached entry not recreated. Continuing with delete.');
        end if;
        --
        -- Only delete grossup balance exclusion rows if we are purging the
        -- entry.
        --
        delete from pay_grossup_bal_exclusions exc
        where  exc.source_id = p_element_entry_id
        and    exc.source_type = 'EE'
        and    not exists
                 ( select null
                   from   pay_element_entries_f pee
                 where  pee.element_entry_id = p_element_entry_id);
        --
        -- Call the routine that checks whether an illegal purge
        -- has occurred (i.e. disallowed by profile).
        hrentmnt.validate_purge(p_element_entry_id, p_element_link_id);
        --
        -- Salary Admin entry is being removed. See if the pay proposal is used by
        -- any other entry. If not then it is removed.
        --
        if p_ee_creator_type = 'SP' then
          --
          hrentmnt.remove_pay_proposals
            (p_assignment_id,
             p_ee_creator_id);
          --
        end if;
        --
        -- code for bug 8870436 starts
        l_dyt_mode := pay_dyn_triggers.g_dyt_mode;
        pay_dyn_triggers.g_dyt_mode := 'ZAP';
        --
        open csr_bus_group(p_assignment_id);
        fetch csr_bus_group into l_business_group_id;
        close csr_bus_group;
        --
        open csr_leg_grp(l_business_group_id);
        fetch csr_leg_grp into l_legislation_code;
        close csr_leg_grp;

        pay_continuous_calc.element_entries_ard(
                                p_business_group_id => l_business_group_id,
                                p_legislation_code => l_legislation_code,
                                p_assignment_id => p_assignment_id,
                                p_old_ELEMENT_ENTRY_ID => p_element_entry_id,
                                p_old_effective_start_date => p_ee_effective_start_date,
                                p_new_effective_start_date => null,
                                p_old_effective_end_date => p_ee_effective_end_date,
                                p_new_effective_end_date => null,
                                p_old_ELEMENT_TYPE_ID => p_element_type_id
                               );
        --
        pay_dyn_triggers.g_dyt_mode := l_dyt_mode;
        -- code for bug 8870436 ends
      end if;
      --
    end do_normal_delete_of_ree;
  --
    --
    -- bring_ree_end_date_backwards:
    -- ***** updating "end" date of current REE backwards   *****
    -- *****                 VSD|<-----       |VED          *****
    -- ***** current |-----------------|                    *****
    --
    procedure bring_ree_end_date_backwards (
      p_assignment_id           in            number,
      p_element_type_id         in            number,
      p_element_link_id         in            number,
      p_element_entry_id        in            number,
      p_validation_start_date   in            date,
      p_validation_end_date     in            date,
      p_ee_effective_start_date in            date,
      p_ee_effective_end_date   in            date,
      p_ee_creator_type         in            varchar2,
      p_ee_creator_id           in            number,
      p_entries_changed         in out nocopy varchar2
    )
    is
      --
      CURSOR csr_bus_group(p_assignment_id number) IS
        SELECT business_group_id
          FROM per_all_assignments_f
         WHERE assignment_id = p_assignment_id;

	/*Cursor added for bug:7440183for getting leg code */
	CURSOR csr_leg_grp(p_business_group_id number) IS
	SELECT LEGISLATION_CODE
	FROM per_business_groups
	where business_group_id=p_business_group_id;

      --
      l_rec_ee          hrentmnt.t_ele_entry_rec;
      l_num_eevs        number := 0;
      l_tbl_ivids       hr_entry.number_table;
      l_tbl_eevs        hr_entry.varchar2_table;
      l_entry_recreated boolean := false;
      l_dyt_mode varchar2(75);
      l_business_group_id number;
      l_legislation_code varchar2(10);
      --
    begin
      --
      if g_debug then
        hr_utility.trace ('***** updating "end" date of current REE backwards   *****');
        hr_utility.trace ('*****                 VSD|<-----       |VED          *****');
        hr_utility.trace ('***** current |-----------------|                    *****');
      end if;
      --
      hrentmnt.validate_adjust_entry
        ('DELETE',
         p_assignment_id,
         p_element_entry_id,
         null,
         null,
         null,
         --
         -- bugfix 1115901
         --
         p_validation_start_date,
         p_ee_effective_end_date,
         p_entries_changed);
      --
      -- update first piece of REE that crosses eligibility boundary,
      -- do not delete as this REE cannot be recreated later,
      -- update its EED so that it is a day less than the VSD
      --
      UPDATE PAY_ELEMENT_ENTRY_VALUES_F eev
      SET    eev.effective_end_date = p_validation_start_date - 1
      WHERE  eev.element_entry_id   = p_element_entry_id
      and    eev.effective_start_date < p_validation_start_date
      -- Change 115.60
          -- and    eev.effective_end_date   > p_validation_start_date
      and    eev.effective_end_date   >= p_validation_start_date
      -- End of change 115.60
      ;
      --
      UPDATE PAY_ELEMENT_ENTRIES_F ee
      SET    ee.effective_end_date = p_validation_start_date - 1,
             ee.updating_action_id = decode(ee.updating_action_type, 'U', ee.updating_action_id,
                                                                              null),
             ee.updating_action_type = decode(ee.updating_action_type, 'U', 'U', null)
      WHERE  ee.element_entry_id   = p_element_entry_id
      and    ee.effective_start_date < p_validation_start_date
      -- Change 115.60
      -- and    ee.effective_end_date   > p_validation_start_date
      and    ee.effective_end_date   >= p_validation_start_date
      -- End of change 115.60
      ;
      --
      -- take a copy of the updated EE as these details will be used
      -- to create the new EE
      -- Bugfix 4520103
      -- Use p_validation_start_date - 1 as this is the new effective end
      -- date of the entry.
      --
      hrentmnt.cache_element_entry(
        p_element_entry_id,
        p_validation_start_date - 1,
        l_rec_ee,
        l_num_eevs,
        l_tbl_ivids,
        l_tbl_eevs);
      --
      recreate_cached_entry (
        p_assignment_id,
        p_element_type_id,
        p_element_link_id,
        p_element_entry_id,
        p_validation_start_date,
        p_validation_end_date,
        p_ee_effective_start_date,
        p_ee_effective_end_date,
        p_ee_creator_type,
        l_rec_ee,
        l_num_eevs,
        l_tbl_ivids,
        l_tbl_eevs,
        l_entry_recreated
      );

      -- Bug 6164943 - Log an event in PAY_PROCESS_EVENTS if the entry is end dated
      -- permanently

      if(not l_entry_recreated) then
        --
        l_dyt_mode := pay_dyn_triggers.g_dyt_mode;
        pay_dyn_triggers.g_dyt_mode := 'DELETE';
        --
	open csr_bus_group(p_assignment_id);
	fetch csr_bus_group into l_business_group_id;
	close csr_bus_group;
	--
	open csr_leg_grp(l_business_group_id);
	fetch csr_leg_grp into l_legislation_code;
	close csr_leg_grp;

/* Changed the null value for p_legislation_code to the actual
leg code for fixing bug 7440183 */

        pay_continuous_calc.element_entries_ard(
                                p_business_group_id => l_business_group_id,
                                p_legislation_code => l_legislation_code,
                                p_assignment_id => p_assignment_id,
                                p_old_ELEMENT_ENTRY_ID => p_element_entry_id,
                                p_old_effective_start_date => p_ee_effective_start_date,
                                p_new_effective_start_date => p_ee_effective_start_date,
                                p_old_effective_end_date => p_ee_effective_end_date,
                                p_new_effective_end_date => p_validation_start_date -1,
                                p_old_ELEMENT_TYPE_ID => p_element_type_id
                               );
        --
	pay_dyn_triggers.g_dyt_mode := l_dyt_mode;
	--
      end if;
      --
    end bring_ree_end_date_backwards;
  --
    --
    -- bring_ree_start_date_forwards:
    -- ***** updating "start" date of current REE forwards  *****
    -- *****                 VSD|       ----->|VED          *****
    -- ***** current                   |----------------->  *****
    --
    procedure bring_ree_start_date_forwards (
      p_assignment_id           in            number,
      p_element_entry_id        in            number,
      p_ee_effective_start_date in            date,
      p_validation_end_date     in            date,
      p_ee_creator_type         in            varchar2,
      p_ee_creator_id           in            number,
      p_entries_changed         in out nocopy varchar2
    )
    is
    begin
      --
      if g_debug then
        hr_utility.trace ('***** updating "start" date of current REE forwards  *****');
        hr_utility.trace ('*****                 VSD|       ----->|VED          *****');
        hr_utility.trace ('***** current                   |----------------->  *****');
      end if;
      --
      hrentmnt.validate_adjust_entry
        ('DELETE',
         p_assignment_id,
         p_element_entry_id,
         null,
         null,
         null,
         p_ee_effective_start_date,
         p_validation_end_date,
         p_entries_changed);
      --
      -- update piece of REE that crosses eligibility boundary,
      -- do not delete as this REE cannot be recreated later,
      -- update its EED so that it is a day greater than the VSD
      --
      UPDATE PAY_ELEMENT_ENTRY_VALUES_F eev
      SET    eev.effective_start_date = p_validation_end_date + 1
      WHERE  eev.element_entry_id   = p_element_entry_id
      -- Change 115.60
      -- and    eev.effective_start_date < p_validation_end_date
      and    eev.effective_start_date <= p_validation_end_date
      -- End of change 115.60
      and    eev.effective_end_date   > p_validation_end_date
      ;

      UPDATE PAY_ELEMENT_ENTRIES_F ee
      SET    ee.effective_start_date = p_validation_end_date + 1,
             ee.updating_action_id = decode(ee.updating_action_type, 'S', ee.updating_action_id, null),
             ee.updating_action_type = decode(ee.updating_action_type, 'S', 'S', null)
      WHERE  ee.element_entry_id   = p_element_entry_id
      -- Change 115.60
      -- and    ee.effective_start_date < p_validation_end_date
      and    ee.effective_start_date <= p_validation_end_date
      -- End of change 115.60
      and    ee.effective_end_date   > p_validation_end_date
      ;
-- end of change 115.21 --

-- start of change 115.22 --
      --
      -- also maintain salary proposal change date
      --
      if p_ee_creator_type = 'SP' then
          if g_debug then
             hr_utility.trace ('***** maintain end date of PP >' ||
                              (p_validation_end_date + 1) || '<');
          end if;
          UPDATE PER_PAY_PROPOSALS pp
          SET    pp.change_date = p_validation_end_date + 1
          WHERE  pp.assignment_id = p_assignment_id
          and    pp.pay_proposal_id = p_ee_creator_id
          ;
      end if;
-- end of change 115.22 --
      --
    end bring_ree_start_date_forwards;
    --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Bugfix 2725909
  -- When datetrack mode is ZAP, remove all entries and entry values, as
  -- parent assignment has been removed, and then exit.
  --
  -- Bug 8230599. removed the code added for 7202321

  if p_dt_mode = 'ZAP' then
    --
    if g_debug then
      --
      hr_utility.trace('ZAP orphaned entries and entry values');
      --
    end if;
    --
    -- Remove orphaned entries and entry values
    --
    for v_entry in csr_orphaned_entries(p_assignment_id) loop
      --
      delete from pay_element_entry_values_f eev
      where eev.element_entry_id = v_entry.element_entry_id;
      --
      delete from pay_element_entries_f ee
      where ee.element_entry_id = v_entry.element_entry_id;
      --
    end loop;
    --
    if g_debug then
      --
      hr_utility.trace('Out hrentmnt.remove_ineligible_recurring');
      --
    end if;
    --
    return;
    --
  end if;
  --
  -- Retrieve all recurring entries for the assignment that are no longer
  -- valid ie. assignment and link no longer matches over the existence of the
  -- element entry.
  --
  for v_entry in csr_entry(p_assignment_id,
                           p_validation_start_date, p_validation_end_date) loop
    --
    -- bug 891323,
    -- if a non-SL'ed REE is crossing eligibility boundary then
    -- do special processing as it cannot be recreated later
    --
    if v_entry.effective_start_date <  p_validation_start_date and
-- change 115.23 --
       v_entry.effective_end_date   >= p_validation_start_date then
      --
      -- ***** updating "end" date of current REE backwards   *****
      -- *****                 VSD|<-----       |VED          *****
      -- ***** current |-----------------|                    *****
      --
      bring_ree_end_date_backwards (
        p_assignment_id           => p_assignment_id,
        p_element_type_id         => v_entry.element_type_id,
        p_element_link_id         => v_entry.element_link_id,
        p_element_entry_id        => v_entry.element_entry_id,
        p_validation_start_date   => p_validation_start_date,
        p_validation_end_date     => p_validation_end_date,
        p_ee_effective_start_date => v_entry.effective_start_date,
        p_ee_effective_end_date   => v_entry.effective_end_date,
        p_ee_creator_type         => v_entry.creator_type,
        p_ee_creator_id           => v_entry.creator_id,
        p_entries_changed         => p_entries_changed
      );
      --
-- start of change 115.21 --
-- change 115.23 --
    elsif v_entry.effective_start_date <= p_validation_end_date and
          v_entry.effective_end_date   >  p_validation_end_date then
      --
      -- ***** updating "start" date of current REE forwards  *****
      -- *****                 VSD|       ----->|VED          *****
      -- ***** current                   |----------------->  *****
      --
      bring_ree_start_date_forwards (
        p_assignment_id           => p_assignment_id,
        p_element_entry_id        => v_entry.element_entry_id,
        p_ee_effective_start_date => v_entry.effective_start_date,
        p_validation_end_date     => p_validation_end_date,
        p_ee_creator_type         => v_entry.creator_type,
        p_ee_creator_id           => v_entry.creator_id,
        p_entries_changed         => p_entries_changed
      );
      --
-- start of change 115.23 --
    elsif v_entry.effective_start_date >= p_validation_start_date and
          v_entry.effective_end_date   <= p_validation_end_date then
-- end of change 115.23 --
      --
      -- Entry exists entirely within the validation period.
      -- Do normal delete of REE.
      --
      -- Bugfix 5247607
      -- Now, whenever a recurring entry is deleted as a result of an
      -- assignment criteria change, we always look for a suitable
      -- alternative link under which the entry can be recreated. A new
      -- procedure, recreate_cached_entry, has been created to do this
      -- for us. This is now called from do_normal_delete_of_ree.
      --
      do_normal_delete_of_ree (
        p_assignment_id           => p_assignment_id,
        p_element_type_id         => v_entry.element_type_id,
        p_element_link_id         => v_entry.element_link_id,
        p_element_entry_id        => v_entry.element_entry_id,
        p_validation_start_date   => p_validation_start_date,
        p_validation_end_date     => p_validation_end_date,
        p_ee_effective_start_date => v_entry.effective_start_date,
        p_ee_effective_end_date   => v_entry.effective_end_date,
        p_ee_creator_type         => v_entry.creator_type,
        p_ee_creator_id           => v_entry.creator_id,
        p_entries_changed         => p_entries_changed
      );
      --
    else
      -- start of change 115.23 --
      if g_debug then
        hr_utility.trace ('***** not adjusting, REE outside validation range    *****');
        hr_utility.trace ('*****                 VSD|             |VED          *****');
        hr_utility.trace ('***** current |----|                                 *****');
        hr_utility.trace ('***** or                                             *****');
        hr_utility.trace ('***** current                             |------->  *****');
      end if;
      -- end of change 115.23 --
    end if;
  end loop;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.remove_ineligible_recurring');
  end if;
  --
end remove_ineligible_recurring;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.remove_ineligible_nonrecurring                                  --
--                                                                          --
-- DESCRIPTION                                                              --
-- Deletes any nonrecurring element entries that will be made ineligible by --
-- a change in assignment criteria. The delete runs after the change to the --
-- assignment has taken place.                                              --
-- NB. val_nonrec_entries should be run first. This makes sure that only    --
--     processed nonrecurring and unprocessed personnel element entries     --
--     are deleted.                                                         --
------------------------------------------------------------------------------
--
procedure remove_ineligible_nonrecurring
(
 p_assignment_id         number,
 p_validation_start_date date,
 p_validation_end_date   date,
 p_entries_changed       in out nocopy varchar2
) is
--Added for 6809717
  l_obj_ver_num           number;
  l_eff_str_date          date;
  l_eff_end_date          date;
  l_del_war               boolean;
  l_cnt NUMBER := 0;
  l_prof_value        varchar2(30);
  l_entry_processed   varchar2(10);
  --
  cursor csr_entry
          (
           p_assignment_id         number,
          p_validation_start_date date,
          p_validation_end_date   date
          ) is
    select ee.element_entry_id,
            ee.effective_start_date,
            ee.effective_end_date,
            ee.element_link_id
    from   pay_element_entries_f ee
    where  ee.assignment_id         = p_assignment_id
      and  ee.effective_start_date <= p_validation_end_date
      and  ee.effective_end_date   >= p_validation_start_date
      and  ee.creator_type in ('F','H')
      and  ((ee.entry_type <> 'E')
       or   (ee.entry_type = 'E' and
             exists
                (select null
                from   pay_element_links_f el,
                       pay_element_types_f et
                where  el.element_link_id = ee.element_link_id
                  and  el.element_type_id = et.element_type_id
                  and  et.processing_type = 'N')))
      and  not exists
              (select null
              from   per_all_assignments_f asg,
                     pay_element_links_f el
              where  el.element_link_id        = ee.element_link_id
                and  asg.assignment_id         = ee.assignment_id
                 and  asg.assignment_type       = 'E'
                and  asg.effective_start_date <= ee.effective_end_date
                -- changed to validation start date not effective start date
                -- wmcveagh bug 586139 17/2/98
                and  asg.effective_end_date   >= p_validation_start_date
                and  el.effective_start_date  <= ee.effective_end_date
                and  el.effective_end_date    >= ee.effective_start_date
                and  el.effective_start_date  <= asg.effective_end_date
                and  el.effective_end_date    >= asg.effective_start_date
                and  ((el.payroll_id is not null and
                       el.payroll_id = asg.payroll_id)
                 or   (el.link_to_all_payrolls_flag = 'Y' and
                       asg.payroll_id is not null)
                 or   (el.payroll_id is null and
                       el.link_to_all_payrolls_flag = 'N'))
                and  (el.job_id is null or
                      el.job_id = asg.job_id)
                and  (el.grade_id is null or
                      el.grade_id = asg.grade_id)
                and  (el.position_id is null or
                      el.position_id = asg.position_id)
                and  (el.organization_id is null or
                      el.organization_id = asg.organization_id)
                and  (el.location_id is null or
                      el.location_id = asg.location_id)
                and  (el.pay_basis_id is null or
                       el.pay_basis_id = asg.pay_basis_id)
                and  (el.employment_category is null or
                       el.employment_category = asg.employment_category)
                and  (el.people_group_id is null or
                      exists
                         (select null
                         from   pay_assignment_link_usages_f alu
                         where  alu.assignment_id = ee.assignment_id
                           and  alu.element_link_id = ee.element_link_id
                           and  alu.effective_start_date <=
                                              asg.effective_end_date
                           and  alu.effective_end_date >=
                                              asg.effective_start_date)));
  --
        procedure check_parameters is
                begin
                hr_utility.trace('In hrentmnt.remove_ineligible_nonrecurring');
                --
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char(p_assignment_id));
                hr_utility.trace ('     p_validation_start_date = '
                        ||to_char(p_validation_start_date));
                hr_utility.trace ('     p_validation_end_date = '
                        ||to_char(p_validation_end_date));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Retrieve all nonrecurring entries for the assignment that are no longer
  -- valid ie. assignment and link no longer matches over the existence of the
  -- element entry.
  --
  for v_entry in csr_entry(p_assignment_id,
                           p_validation_start_date,
                           p_validation_end_date) loop
    --
    --
    hrentmnt.validate_adjust_entry
      ('DELETE',
       p_assignment_id,
       v_entry.element_entry_id,
       null,
       null,
       null,
       v_entry.effective_start_date,
       v_entry.effective_end_date,
        p_entries_changed);
    --
    --
    delete from pay_run_results rr
    where  rr.status not like 'P%'
      and  rr.source_type = 'E'
      and  rr.source_id = v_entry.element_entry_id;
    --
    --

    -- Added for Bug 7578009

    -- Bug 8230599. Using only element_entry_id in the where clause to get ovn, as
    -- every non-recurring element entry has only one record in pay_element_Entries_f.
    -- Call the entry api for 'ZAP' mode also to enable logging of events.

    select OBJECT_VERSION_NUMBER into l_obj_ver_num
      from pay_element_entries_f
     where element_entry_id=v_entry.element_entry_id;

	 if g_debug then
            hr_utility.trace('  obj vber no : '||l_obj_ver_num);
            hr_utility.trace('  p_validation_start_date : '||p_validation_start_date);
         end if;

    if(v_entry.effective_start_date>= p_validation_start_date) THEN

         -- Read the profile value.
         fnd_profile.get('HR_ELE_ENTRY_PURGE_CONTROL', l_prof_value);

	 l_entry_processed := pay_paywsmee_pkg.processed(p_element_entry_id => v_entry.element_entry_id,
                                                    p_original_entry_id	=> null,
                                                    p_processing_type	=> 'N',
						    p_entry_type	=> null ,
						    p_effective_date	=> null);
	  if g_debug then
            hr_utility.trace('l_prof_value : '|| l_prof_value);
	    hr_utility.trace('l_entry_processed : '|| l_entry_processed);
          end if;

	  if (l_prof_value = 'PN' and l_entry_processed = 'N') then
            hr_utility.set_message (800,'PAY_33469_UNPROC_NONREC_PURGE');
            hr_utility.raise_error;
          end if;

         if g_debug then
            hr_utility.trace('  ZAP element entry ');
         end if;

       pay_element_entry_api.delete_element_entry
                (p_datetrack_delete_mode => 'ZAP'
                ,p_effective_date   => v_entry.effective_start_date        -- 8230599, pass v_entry.effective_start_date
                ,p_element_entry_id   =>  v_entry.element_entry_id
                 ,p_object_version_number => l_obj_ver_num
                 ,p_effective_start_date  =>l_eff_str_date
                 ,p_effective_end_date    =>l_eff_end_date
                  ,p_delete_warning =>l_del_war);

     ELSE

         if g_debug then
           hr_utility.trace('  DELETE element entry ');
         end if;

            pay_element_entry_api.delete_element_entry
                (p_datetrack_delete_mode => 'DELETE'
                ,p_effective_date   => p_validation_start_date-1
                ,p_element_entry_id   =>  v_entry.element_entry_id
                 ,p_object_version_number => l_obj_ver_num
                 ,p_effective_start_date  =>l_eff_str_date
                 ,p_effective_end_date    =>l_eff_end_date
                  ,p_delete_warning =>l_del_war);
    end if;
-- end of change 115.116

--Commented the below code as part of 6809717
   /* delete from pay_element_entry_values_f eev
    where  eev.element_entry_id = v_entry.element_entry_id;
    --
    delete from pay_element_entries_f ee
    where  ee.element_entry_id = v_entry.element_entry_id;*/
    --
    -- Call the routine that checks whether an illegal purge
    -- has occurred (i.e. disallowed by profile).
    hrentmnt.validate_purge(v_entry.element_entry_id, v_entry.element_link_id);
    --
  end loop;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.remove_ineligible_nonrecurring');
  end if;
  --
end remove_ineligible_nonrecurring;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.return_entry_dates                                              --
--                                                                          --
-- DESCRIPTION                                                              --
-- Given an assignment and element link this returns the start and end      --
-- dates of the element entry taking into account personal qualifying       --
-- conditions and also any future terminations of the assignment NB. for    --
-- discretionary element entries the personal qualifying conditions are not --
-- taken into account as the user is allowed to ignore these when creating  --
-- an entry.                                                                --
------------------------------------------------------------------------------
--
procedure return_entry_dates
(
 p_assignment_id      number,
 p_asg_start_date     date,
 p_element_link_id    number,
 p_link_start_date    date,
 p_standard_link_flag varchar2,
 p_entry_start_date   out nocopy date,
 p_entry_end_date     out nocopy date
) is
  --
  -- Local Variables
  --
  v_los_date         date;
  v_age_date         date;
  v_pqc_start_date   date;
  v_entry_start_date date;
  v_entry_end_date   date;
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.return_entry_dates');
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_asg_start_date = '
                        ||to_char (p_asg_start_date));
                hr_utility.trace ('     p_element_link_id = '
                        ||to_char (p_element_link_id));
                hr_utility.trace ('     p_link_start_date = '
                        ||to_char (p_link_start_date));
                hr_utility.trace ('     p_standard_link_flag = '
                        ||p_standard_link_flag);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Only take into account personal qualifying conditions for standard
  -- element entries.
  --
  if p_standard_link_flag = 'Y' then
    --
    hr_entry.return_qualifying_conditions
      (p_assignment_id,
       p_element_link_id,
       greatest(p_link_start_date,p_asg_start_date),
       v_los_date,
       v_age_date);
    --
    v_pqc_start_date := least(nvl(v_los_date,v_age_date),
                              nvl(v_age_date,v_los_date));
  --
  -- Discretionary entry so do not apply personal qualifying conditions.
  --
  else
    --
    v_pqc_start_date := p_asg_start_date;
    --
  end if;
  --
  v_entry_start_date := greatest(p_link_start_date,
                                 p_asg_start_date,
                                 nvl(v_pqc_start_date,p_asg_start_date));
  --
  -- Calculate the element entry end date taking into account future
  -- terminations.
  --
  v_entry_end_date := hr_entry.recurring_entry_end_date
                        (p_assignment_id,
                         p_element_link_id,
                         greatest(p_link_start_date,p_asg_start_date),
                         'N',
                         'N',
                         null,
                         null);
  --
  -- It is possible that personal qualifying conditions can result in an
  -- entry not being able to start until after the person has become
  -- ineligible for it.
  --
  -- It is not possible for elements to end before they start
  --
  if v_entry_start_date <= v_entry_end_date then
    p_entry_start_date := v_entry_start_date;
    p_entry_end_date   := v_entry_end_date;
  end if;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.return_entry_dates');
  end if;
  --
end return_entry_dates;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.mult_ent_allowed_flag                                           --
--                                                                          --
-- DESCRIPTION                                                              --
-- Simple function to return a flag indicating if multiple entries are      --
-- allowed for a particular element type.                                   --
------------------------------------------------------------------------------
--
function mult_ent_allowed_flag
(
 p_element_link_id number
) return varchar2 is
  --
  -- Are multiple entries allowed.
  --
  cursor csr_element
         (
          p_element_link_id number
         ) is
    select et.multiple_entries_allowed_flag
    from   pay_element_links_f el,
            pay_element_types_f et
    where  el.element_link_id = p_element_link_id
      and  et.element_type_id = el.element_type_id;
  --
  -- Local Variables
  --
  v_mult_ent_allowed_flag varchar2(30);
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.mult_ent_allowed_flag');
                hr_utility.trace ('');
                hr_utility.trace ('     p_element_link_id = '
                        ||to_char (p_element_link_id));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  open csr_element(p_element_link_id);
  fetch csr_element into v_mult_ent_allowed_flag;
  if csr_element%notfound then
    close csr_element;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'hrentmnt.mult_ent_allowed_flag');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  close csr_element;
  --
  return v_mult_ent_allowed_flag;
  --
end mult_ent_allowed_flag;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.val_nonrec_entries                                              --
--                                                                          --
-- DESCRIPTION                                                              --
-- Checks to see if there are nonrecurring element entries that will be     --
-- made ineligible by a change in assignment criteria. The check runs       --
-- after the change to the assignment has taken place. The nonrecurring     --
-- element entries that are validated are :                                 --
--                                                                          --
-- Balance Adjustment                           processed / unprocessed     --
-- Override                                     unprocessed                 --
-- Replacement Adjustment                        ''     ''                  --
-- Additive Adjustment                           ''     ''                  --
-- Additional Entry                              ''     ''                  --
-- Payroll Nonrecurring                          ''     ''                  --
-- Special Entries ie. SSP, Quickpay etc ...    processed / unprocessed     --
--                                                                          --
--  NB. the nonrecurring entry is still valid providing the element link    --
--      and assignment match for at least one day during the duration of    --
--      the entry.                                                          --
--                                                                          --
-- As this check is run during a batch operation it is not possible to      --
-- return specific details for each nonrecurring entry that has been        --
-- made ineligible so an error is only raised for the first one found.      --
------------------------------------------------------------------------------
--
procedure val_nonrec_entries
(
 p_assignment_id         number,
 p_validation_start_date date,
 p_validation_end_date   date,
 p_entries_changed   in out nocopy varchar2
) is
  --
  -- Cursor returns all nonrecurring entries for an assignment over a
  -- specified time period that are unprocessed overrides, replacement
  -- adjustments, additive adjustments, additional entries or nonrecurring
  -- payroll entries. It also returns special nonrecurring entries
  -- irrespective of them having been processed or not ie. Quickpay
  -- entries etc ...
  --
  cursor csr_entry
         (
          p_assignment_id          number,
          p_validation_start_date  date,
          p_validation_end_date    date,
          p_adjust_ee_source       varchar2
         ) is
      select ee.*
      from   pay_element_entries_f ee
            ,pay_element_types_f et
      where  ee.assignment_id = p_assignment_id
      and  ee.effective_start_date <= p_validation_end_date
      and  ee.effective_end_date   >= p_validation_start_date
      and  ee.element_type_id = et.element_type_id
      and  ee.effective_start_date between et.effective_start_date
                                       and et.effective_end_date
      --
      -- Restrict to nonrecurring entries
      --
      and (ee.entry_type in ('S','R','A','D')
           or (ee.entry_type = 'E'
               and et.process_in_run_flag = 'Y'
               and et.processing_type = 'N'))
      --
      -- Restrict to ordinary creator-type entries which have been processed
      -- or to special creator-type entries regardless of processing.
      --
      /* Bug 7603986. All processed and unprocessed entries are checked for any alternate element links
      and  ((ee.creator_type in ('F','H')
                and    not exists
                (select null
                        from   pay_run_results rr
                        where  rr.source_id = decode(ee.entry_type,
                                                     'A', decode (p_adjust_ee_source,
                                                                  'T', ee.target_entry_id,
                                                                  ee.element_entry_id),
                                                     'R', decode (p_adjust_ee_source,
                                                                  'T', ee.target_entry_id,
                                                                  ee.element_entry_id),
                                                     ee.element_entry_id)
                        and  rr.source_type = 'E'
                        and  rr.entry_type = ee.entry_type
                        and  rr.status like 'P%'))
        or  (ee.creator_type not in ('F','H')))
	*/
        --
        -- Restrict to entries for links which no longer match the assignment
        -- criteria.
        --
        and  not exists
             (select null
              from   per_all_assignments_f asg,
                     pay_element_links_f   el
              where  asg.assignment_id   = ee.assignment_id
                and  el.element_link_id  = ee.element_link_id
                and  asg.assignment_type = 'E'
		and  asg.effective_start_date <= ee.effective_end_date
		and  asg.effective_end_date   >= ee.effective_end_date          -- bug 6485636
                and  el.effective_start_date  <= ee.effective_end_date
                and  el.effective_end_date    >= ee.effective_start_date
                and  el.effective_start_date  <= asg.effective_end_date
                and  el.effective_end_date    >= asg.effective_start_date
                 --
                 -- and the link does NOT match the assignment criteria
                 --
                and  ((el.payroll_id is not null
                                and el.payroll_id = asg.payroll_id)
                                or   (el.link_to_all_payrolls_flag = 'Y'
                                        and asg.payroll_id is not null)
                        or   (el.payroll_id is null and
                        el.link_to_all_payrolls_flag = 'N'))
                        and  (el.job_id is null
                                or el.job_id = asg.job_id)
                        and  (el.grade_id is null
                                or el.grade_id = asg.grade_id)
                        and  (el.position_id is null
                                or el.position_id = asg.position_id)
                        and  (el.organization_id is null
                                or el.organization_id = asg.organization_id)
                        and  (el.location_id is null
                                or el.location_id = asg.location_id)
                        and  (el.pay_basis_id is null
                                or el.pay_basis_id = asg.pay_basis_id)
                        and  (el.employment_category is null
                                or el.employment_category = asg.employment_category)
                        and  (el.people_group_id is null
                                or exists (select null
                                        from   pay_assignment_link_usages_f alu
                                        where  alu.assignment_id = ee.assignment_id
                                        and  alu.element_link_id = ee.element_link_id
                                        and  alu.effective_start_date <=
                                                asg.effective_end_date
                                        and  alu.effective_end_date >=
                                                asg.effective_start_date)));
  --
  -- Local types
  --
  type t_element_entry_table_rec is record (
    element_entry_id     dbms_sql.number_table,
    element_link_id      dbms_sql.number_table,
    effective_start_date dbms_sql.date_table,
    effective_end_date   dbms_sql.date_table
  );
  --
  -- Local variables
  --
  l_counter               number := 1;
  l_entry_table           t_element_entry_table_rec;
  l_asg_criteria_cv       t_asg_criteria_cur; -- cursor variable for assignment criteria
  l_asg_criteria_rec      t_asg_criteria_rec;
  l_eligible_links_cv     t_eligible_links_cur; -- cursor variable for eligible links for invalidated entries
  l_eligible_links_rec    t_eligible_links_rec;
  l_link_suitable         boolean;
  l_creator_type_meaning  varchar2(60);
  l_adjust_ee_source      varchar2(1);
  l_proc                  varchar2(80) := 'hrentmnt.val_nonrec_entries';
  --
   l_obj_ver_num           number;
  l_eff_str_date          date;
  l_eff_end_date          date;
  l_del_war               boolean;
  l_cnt NUMBER := 0;
begin
  --
  if g_debug then
    hr_utility.set_location(l_proc, 10);
    hr_utility.trace('  p_assignment_id = ' ||to_char(p_assignment_id));
    hr_utility.trace('  p_validation_start_date = ' ||to_char(p_validation_start_date));
    hr_utility.trace('  p_validation_end_date = ' ||to_char(p_validation_end_date));
  end if;
  --
  -- Get the assignment criteria
  open_asg_criteria_cur(p_assignment_id, p_validation_start_date, l_asg_criteria_cv);
  fetch l_asg_criteria_cv into l_asg_criteria_rec;
  close l_asg_criteria_cv;
  --
  -- Get the legisative rule ADJUSTMENT_EE_SOURCE.
  --
  begin
    --
    if g_debug then
      hr_utility.set_location(l_proc, 20);
    end if;
    --
    select /*+ INDEX(paf PER_ASSIGNMENTS_F_PK)*/ plr.rule_mode
      into l_adjust_ee_source
      from pay_legislation_rules plr,
           per_business_groups_perf pbg,
           per_all_assignments_f paf
     where paf.assignment_id = p_assignment_id
       and p_validation_start_date between paf.effective_start_date
                                and paf.effective_end_date
       and paf.business_group_id = pbg.business_group_id
       and pbg.legislation_code = plr.legislation_code
       and plr.rule_type = 'ADJUSTMENT_EE_SOURCE';
     --
   exception
       when no_data_found then
          l_adjust_ee_source := 'A';
  end;
  --
  if g_debug then
    hr_utility.trace('  l_adjust_ee_source: '||l_adjust_ee_source);
  end if;
  --
  -- Bugfix 5584631
  -- Loop through all invalidated nonrecurring entries.
  -- Look to see if there exists an alternative link for each invalidated entry
  -- Raise an error if no alternative link exists for ANY of the invalidated
  -- entries.
  -- If ALL invalidated nonrecurring entries have an alternative link available
  -- then DO NOT raise an error but update the element_link_id stamped on the
  -- invalidated entries to point to the new links.
  --
  for r_entry in csr_entry (
    p_assignment_id,
    p_validation_start_date,
    p_validation_end_date,
    l_adjust_ee_source
  ) loop
    --
    if g_debug then
      hr_utility.set_location(l_proc, 30);
    end if;
    --
    -- Look for an alternative element link based on the invalidated entry's
    -- element type and the assignment criteria
    open_eligible_links_cur (
      p_assignment_id,
      -- Bugfix 6809717 added greatest , least to the following two lines
      greatest(r_entry.effective_start_date,p_validation_start_date), -- link must span lifetime of entry
      least(r_entry.effective_end_date,p_validation_end_date),
      r_entry.element_type_id,
      l_asg_criteria_rec.organization_id,
      l_asg_criteria_rec.people_group_id,
      l_asg_criteria_rec.job_id,
      l_asg_criteria_rec.position_id,
      l_asg_criteria_rec.grade_id,
      l_asg_criteria_rec.location_id,
      l_asg_criteria_rec.employment_category,
      l_asg_criteria_rec.payroll_id,
      l_asg_criteria_rec.pay_basis_id,
      l_asg_criteria_rec.business_group_id,
      l_eligible_links_cv
    );
    --
    fetch l_eligible_links_cv into l_eligible_links_rec;
    --
    -- Determine if a suitable alternative link has been found
    -- i.e. link must span lifetime of entry
    --
    l_link_suitable :=
      l_eligible_links_cv%found and
      l_eligible_links_rec.effective_start_date <= r_entry.effective_start_date and
      l_eligible_links_rec.effective_end_date >= r_entry.effective_end_date;
    --
    close l_eligible_links_cv;
    --
    if not l_link_suitable then
      --
      if g_debug then
        hr_utility.set_location(l_proc, 40);
      end if;
      --
      -- No alternative link found.
      -- Clear down l_entry_table and raise error.
      --
      l_entry_table.element_entry_id.delete;
      l_entry_table.element_link_id.delete;
      l_entry_table.effective_start_date.delete;
      l_entry_table.effective_end_date.delete;
      --
      if r_entry.creator_type not in ('F','H') then
        --
        -- Special entry was invalidated eg. Balance Adjustment, Quickpay etc .
        -- Lookup the entry type for reporting in error.
        --
        if g_debug then
          hr_utility.set_location(l_proc, 50);
        end if;
        --
        select hl.meaning
        into   l_creator_type_meaning
        from   hr_lookups hl
        where  hl.lookup_type = 'CREATOR_TYPE'
        and    hl.lookup_code = r_entry.creator_type;
        --
        hr_utility.set_message(801,'HR_6589_ASS_SPCL_NONREC_EXIST');
        hr_utility.set_message_token('TYPE',l_creator_type_meaning);
        hr_utility.raise_error;
        --
      else
        --
        -- An unprocessed nonrecurring entry was invalidated. Includes
        -- overrides etc .
        --
        if g_debug then
          hr_utility.set_location(l_proc, 60);
        end if;

        -- 8230599 removed delete logic as val_nonrec is not supposed to delete any entries. All the deletes
	-- are done in remove_ineligible_nonrecurring

	-- 8311681
         p_entries_changed  := 'I';

        -- hr_utility.set_message(801,'HR_6588_ASS_UNPROC_NONREC');
        -- hr_utility.raise_error;

        --
      end if;
      --
    else
      --
      -- A suitable alternative link was found
      -- Store the new link id with the entry details for a bulk update later
      --
      if g_debug then
        hr_utility.set_location(l_proc, 70);
        hr_utility.trace('  Alt element_link_id found for entry '||to_char(r_entry.element_entry_id));
        hr_utility.trace('  Old element_link_id: '||to_char(r_entry.element_link_id)||', new element_link_id: '||to_char(l_eligible_links_rec.element_link_id));
      end if;
      --
      l_entry_table.element_entry_id(l_counter) := r_entry.element_entry_id;
      l_entry_table.element_link_id(l_counter) := l_eligible_links_rec.element_link_id;
      l_entry_table.effective_start_date(l_counter) := r_entry.effective_start_date;
      l_entry_table.effective_end_date(l_counter) := r_entry.effective_end_date;
      --
      l_counter := l_counter + 1;
      --
    end if;
    --
  end loop;
  --
  if l_entry_table.element_entry_id.count > 0 then
    --
    if g_debug then
      hr_utility.set_location(l_proc, 80);
      hr_utility.trace('Doing bulk update of element_link_id');
    end if;
    --
    -- Do bulk update of element entries, to point to their respective new
    -- alternative links
    --
    forall i in 1 .. l_entry_table.element_entry_id.count
      update pay_element_entries_f
      set element_link_id = l_entry_table.element_link_id(i)
      where element_entry_id = l_entry_table.element_entry_id(i)
      and effective_start_date = l_entry_table.effective_start_date(i)
      and effective_end_date = l_entry_table.effective_end_date(i);
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 90);
  end if;
  --
end val_nonrec_entries;
--
------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hrentmnt.validate_adjustment_entries                                     --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- This routine checks for element entries which have more than one         --
 -- adjustments(entry_type = 'A') in the same pay period                     --
 -- and raise an ERROR if such an entry exists.                              --
 ------------------------------------------------------------------------------
procedure validate_adjustment_entries   /* Added for bug 8419416 */
(
 p_payroll_id in number,
 p_assignment_id in number,
 p_val_start_date in date
)
is
   cursor csr_cae is
   select null
   from   dual
   where exists
      (select null
       from pay_element_entries_f pee,
            per_time_periods ptp
       where pee.assignment_id = p_assignment_id
        and pee.entry_type in ('A','R','S')
        and pee.effective_start_date > p_val_start_date
        and ptp.payroll_id = p_payroll_id
        and pee.effective_start_date between ptp.start_date and ptp.end_date
        and pee.effective_end_date between ptp.start_date and ptp.end_date
       group by pee.target_entry_id ,ptp.time_period_id
       having count(*) > 1);
begin
   hr_utility.set_location('hrentmnt.validate_adjustment_entries',10);
   for csr_cae_rec in csr_cae loop
      --  any record fetched is an error
      hr_utility.set_message(801, 'PAY_34196_INVALID_ADJUSTMENTS');
      hr_utility.raise_error;
   end loop;
   hr_utility.set_location('hrentmnt.validate_adjustment_entries',20);
   return;
end validate_adjustment_entries;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.adjust_nonrecurring_entries                                     --
--                                                                          --
-- DESCRIPTION                                                              --
-- Adjusts nonrecurring entries when there is a change in payroll or the    --
-- assignment ends. Nonrecurring entries now only exist for the duration of --
-- the period for which the payroll / assignment exists.                    --
------------------------------------------------------------------------------
--
procedure adjust_nonrecurring_entries
(
 p_assignment_id            number,
 p_val_start_date_minus_one date,
 p_val_end_date_plus_one    date,
 p_entries_changed          in out nocopy varchar2,
 p_dt_mode                  VARCHAR2 DEFAULT NULL /* Added for Bug No : 6835808 */
) is
  --
  -- Finds all nonrecurring entries that overlap with the period of change of
  -- the assignment.
  --
  cursor csr_entry
          (
           p_assignment_id            number,
           p_val_start_date_minus_one date,
           p_val_end_date_plus_one    date
         ) is
    select ee.element_entry_id,
            ee.effective_start_date,
            ee.effective_end_date,
            ee.element_link_id
    from   pay_element_entries_f ee
    where  ee.assignment_id = p_assignment_id
      and  ee.effective_start_date <= p_val_end_date_plus_one
      and  ee.effective_end_date   >= p_val_start_date_minus_one
      and  ((ee.entry_type <> 'E') or
             (ee.entry_type = 'E' and
              exists
                (select null
                 from   pay_element_links_f el,
                        pay_element_types_f et
                where  el.element_link_id = ee.element_link_id
                   and  et.element_type_id = el.element_type_id
                   and  et.processing_type = 'N')));
  --
  cursor get_asg_start_date is                  -- bug 8359932
    select min(effective_start_date)
     from per_all_assignments_f
    where assignment_id = p_assignment_id;

  --
  -- Local Variables
  --
  v_effective_start_date date;
  v_effective_end_date   date;
  v_payroll_id           number;
  v_period_start_date    date;
  v_period_end_date      date;
  v_session_date         date;
  v_asg_start_date       date;
  --Added for bug:6809717
  v_val_date	date;
  v_alu_cnt number;
  v_vale_start_date date;
  v_start_date_check number;
  v_end_date_check  number;
  v_chng_date date;
  v_min_eligible_date date;
  v_max_eligible_date date;
  -- Added for bug 8536385
  l_prof_value        varchar2(30);
  l_entry_processed   varchar2(10);
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace ('In hrentmnt.adjust_nonrecurring_entries');
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_val_start_date_minus_one = '
                        ||to_char (p_val_start_date_minus_one));
                hr_utility.trace ('     p_val_end_date_plus_one = '
                        ||to_char (p_val_end_date_plus_one));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  v_vale_start_date:=hr_general.start_of_time;
  -- Retrieve all nonrecurring entries that overlap the period of change
/* Bug : 6809717 Added the following block of code to calculate the validation start date
properly in case of people group change in assignment information*/
--Start
 if p_dt_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
  if g_debug then
     hr_utility.trace ('1');
  end if;
  --
     select count(*) into v_start_date_check from per_time_periods where payroll_id in(
     select payroll_id from per_all_assignments_f where assignment_id=p_assignment_id
     and p_val_start_date_minus_one between effective_start_date and effective_end_date)
     and p_val_start_date_minus_one between start_date and end_date;

     select count(*) into v_end_date_check from per_time_periods where payroll_id in(
     select payroll_id from per_all_assignments_f where assignment_id=p_assignment_id
     and p_val_end_date_plus_one between effective_start_date and effective_end_date)
     and p_val_end_date_plus_one between start_date and end_date;

  if g_debug then
     hr_utility.trace ('2');
  end if;
  --
        if v_start_date_check=0 and v_end_date_check=0 then
          v_chng_date:=p_val_start_date_minus_one;
        elsif v_start_date_check=0 then
          v_chng_date:=p_val_end_date_plus_one;
        else
          v_chng_date:=p_val_start_date_minus_one;
        end if;
  if g_debug then
     hr_utility.trace ('3');
  end if;
  --
   if v_start_date_check<>0 or v_end_date_check<>0 then
     select end_date into v_vale_start_date from per_time_periods where payroll_id in(
     select payroll_id from per_all_assignments_f where assignment_id=p_assignment_id
     and v_chng_date between effective_start_date and effective_end_date)
     and v_chng_date between start_date and end_date;
   end if;

  if g_debug then
     hr_utility.trace ('4');
  end if;
  --
   if v_vale_start_date<>p_val_start_date_minus_one then /*Bug 8798020 Removed query to get v_alu_cnt and the condition v_alu_cnt = 0 */
     v_vale_start_date:=p_val_start_date_minus_one;
   else
     v_vale_start_date:=p_val_start_date_minus_one+1;
   end if;
  else
     v_vale_start_date:=p_val_start_date_minus_one+1;
  end if;

  -- bug 8359932
  open get_asg_start_date;
  fetch get_asg_start_date into v_asg_start_date;
  close get_asg_start_date;

  if g_debug then
    hr_utility.trace('v_asg_start_date : '|| v_asg_start_date);
  end if;

--End
  for v_entry in csr_entry(p_assignment_id,
                            v_vale_start_date,
                            p_val_end_date_plus_one) loop

    -- Added 1 with p_val_start_date_minus_one to ensure that entries whichever
    -- created in past wasnt touched during this check.


    -- If nonrecurring entry existed before the period of change then
    -- calculate its new dates using the effective date of change otherwise use
    -- the end date of the entry NB. entries that are within the period of
    -- change will either be invalid or if they are link to all payrolls then
    -- their dates may have to be changed.
    --

    -- Bug 6485636. Modified the logic of passing v_session_date, as it was creating
    -- erroneous entries for non-recurring element entries with their periods not
    -- matching the payroll periods and hence not being processed.
    -- Now, (p_val_start_date_minus_one +1) is passed as v_session_date when the date of
    -- payroll change lies in the period of the entry. As the date lies in
    -- the updated assignment period, the new payroll period will be used to update the
    -- non-recurring entry period. Hence, passing the session_date
    -- as (p_val_start_date_minus_one +1) will give correct dates from get_nonrecurring_dates().

/* Altered the following code for Bug No:6835808 which has previously has fix for Bug No:6722391 */
if p_dt_mode='DELETE' then
    /* Code for termination of employee */
    if v_entry.effective_start_date <= p_val_start_date_minus_one then
      v_session_date := v_entry.effective_start_date;
    else
      v_session_date := v_entry.effective_end_date;
    end if;
else
     /* Code for termination of payroll or Assignment */
    if v_entry.effective_start_date > p_val_start_date_minus_one then
      v_session_date := v_entry.effective_start_date;
    else
      v_session_date := p_val_start_date_minus_one+1;
    end if;
end if;

    -- bug 8359932
    if v_session_date < v_asg_start_date then
      v_session_date := v_asg_start_date;
    end if;

    if g_debug then
      hr_utility.trace('Before calling get_nonrecurring_dates, v_session_date : '|| v_session_date);
    end if;
    v_min_eligible_date := null;
    v_max_eligible_date := null;
    --
    -- Calculate the start and end dates of the nonrecurring entry.
    --
    hr_entry.get_nonrecurring_dates
      (p_assignment_id,
       v_session_date,
       v_effective_start_date,
       v_effective_end_date,
       v_payroll_id,
       v_period_start_date,
       v_period_end_date);

    /*Bug 8798020 Added Call to hr_entry.get_eligibility_period */
    hr_entry.get_eligibility_period (p_assignment_id,
                                          v_entry.element_link_id,
                                          v_session_date,
                                          v_min_eligible_date,
                                          v_max_eligible_date);

    v_effective_start_date :=greatest(v_effective_start_date,nvl(v_min_eligible_date,v_effective_start_date));
    v_effective_end_date   :=least(v_effective_end_date,nvl(v_max_eligible_date,v_effective_end_date));

    -- Added for Bug 8536385 - Controlling the adjustment of Processed non-recurring entries based on a profile value(If set to Y)
    -- If the entry is processed, then do not adjust the element entry
    -- Else, adjust the element entry
    -- Read the profile value.
    fnd_profile.get('HR_ADJUST_PROCESSED_NONREC_ENTRIES', l_prof_value);

    if nvl(l_prof_value,'Y') = 'N' then
      l_entry_processed := pay_paywsmee_pkg.processed(p_element_entry_id  => v_entry.element_entry_id,
                                                      p_original_entry_id => null,
                                                      p_processing_type   => 'N',
                                                      p_entry_type        => null ,
                                                      p_effective_date    => v_session_date);
      if g_debug then
        hr_utility.trace('HR_ADJUST_PROCESSED_NONREC_ENTRIES l_prof_value : '|| l_prof_value);
        hr_utility.trace('l_entry_processed : '|| l_entry_processed);
      end if;
    else
      l_entry_processed := 'N';
     end if;

    if l_entry_processed = 'N' then
      --
      -- If current start date is wrong then adjust nonrecurring entry.
      --
      if v_entry.effective_start_date <> v_effective_start_date then
        hrentmnt.validate_adjust_entry
          ('UPDATE',
           p_assignment_id,
           v_entry.element_entry_id,
           'START',
           v_entry.effective_start_date,
           v_effective_start_date,
           null,
           null,
           p_entries_changed);
      end if;
      --
      -- If current end date is wrong then adjust nonrecurring entry.
      --
      if v_entry.effective_end_date <> v_effective_end_date then
        hrentmnt.validate_adjust_entry
          ('UPDATE',
           p_assignment_id,
           v_entry.element_entry_id,
           'END',
           v_entry.effective_end_date,
           v_effective_end_date,
           null,
           null,
           p_entries_changed);
      end if;
    end if;
    --
  end loop;
  --
if g_debug then
   hr_utility.trace ('Out hrentmnt.adjust_nonrecurring_entries');
end if;
--
end adjust_nonrecurring_entries;
--

function get_entry_info_category(
    p_assignment_id    in number,
    p_effective_date   in date,
    p_element_link_id in number)
return varchar2
is
    cursor csr_entry_info_category(b_assignment_id in number,
                                    b_effective_date in date,
                                    b_element_link_id in number) is
SELECT dfc.descriptive_flex_context_code
FROM   PER_BUSINESS_GROUPS_PERF    bg,
       PAY_ELEMENT_LINKS_F         el,
       PAY_ELEMENT_TYPES_F         et,
       PAY_ELEMENT_CLASSIFICATIONS ec,
       FND_DESCR_FLEX_CONTEXTS     dfc
WHERE  bg.business_group_id =
                            el.business_group_id
and    el.element_link_id = b_element_link_id
and    b_effective_date between
            el.effective_start_date and el.effective_end_date
and    et.element_type_id =
                          el.element_type_id
and    b_effective_date between
            et.effective_start_date and et.effective_end_date
and    ec.classification_id =
                            et.classification_id
and    dfc.descriptive_flex_context_code = upper(
            bg.legislation_code || '_' || ec.classification_name)
and    dfc.application_id = 801
and    dfc.descriptive_flexfield_name = 'Element Entry Developer DF';

l_category fnd_descr_flex_contexts.descriptive_flex_context_code%type;
begin
    null;
    open csr_entry_info_category(p_assignment_id, p_effective_date,
                                                        p_element_link_id);
    fetch csr_entry_info_category into l_category;
    close csr_entry_info_category;

    return l_category;
end get_entry_info_category;

------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.adjust_recurring_entries                                        --
--                                                                          --
-- DESCRIPTION                                                              --
-- When passed a table containing what an element entry should look like    --
-- for a particular assignment and element link, it finds and adjusts all   --
-- current entries that represent the same element entry so that they are   --
-- consistent eg.                                                           --
--                                                                          --
-- Calc Entry      |---------------------|            |--------------->     --
-- Current Entry   |-------------------------------------------------->     --
--                                                                          --
-- The current entry would be split into 2 to look exactly like the         --
-- calculated entry.
------------------------------------------------------------------------------
--
procedure adjust_recurring_entries
(
 p_dt_mode                  varchar2,
 p_assignment_id            number,
 p_element_link_id          number,
 p_standard_link_flag       varchar2,
 p_mult_ent_allowed_flag    varchar2,
 p_validation_start_date    date,
 p_validation_end_date      date,
 p_val_start_date_minus_one date,
 p_val_end_date_plus_one    date,
 p_entry_count              number,
 p_entry_start_date_tbl     hrentmnt.t_date_table,
 p_entry_end_date_tbl       hrentmnt.t_date_table,
 p_entries_changed          in out nocopy varchar2,
 p_old_hire_date            date
) is
  --
  cursor csr_distinct_entries
          (
           p_mult_ent_allowed_flag varchar2,
           p_assignment_id         number,
           p_element_link_id       number,
           p_entry_start_date      date,
           p_entry_end_date        date
         ) is
    select distinct nvl(ee.original_entry_id,ee.element_entry_id)
    from   pay_element_entries_f ee
    where  p_mult_ent_allowed_flag  = 'Y'
      and  ee.entry_type            = 'E'
      and  ee.assignment_id         = p_assignment_id
      and  ee.element_link_id       = p_element_link_id
      and  ee.effective_start_date <= p_entry_end_date
      and  ee.effective_end_date   >= p_entry_start_date
    UNION ALL
    select to_number(null)
    from   sys.dual
    where  p_mult_ent_allowed_flag = 'N'
      and  exists
              (select null
               from   pay_element_entries_f ee
               where  ee.entry_type            = 'E'
                 and  ee.assignment_id         = p_assignment_id
                 and  ee.element_link_id       = p_element_link_id
                 and  ee.effective_start_date <= p_entry_end_date
                 and  ee.effective_end_date   >= p_entry_start_date);
  --
  -- Tuned in response to WWBug 273820. Splitting the SQL statement into 3
  -- distinct selects allows the use of indexes on all 3 selects. When the
  -- SQL was one select the combination of OR's and NVL's disabled all the
  -- available indexes.
  --
  cursor csr_entry
          (
           p_mult_ent_allowed_flag varchar2,
           p_element_entry_id      number,
           p_assignment_id         number,
           p_element_link_id       number,
           p_entry_start_date      date,
           p_entry_end_date        date
         ) is
    select ee.element_entry_id,
           ee.original_entry_id,
           ee.effective_start_date,
           ee.effective_end_date,
           ee.element_link_id,
           ee.creator_type
    from   pay_element_entries_f ee
    where  ee.entry_type             = 'E'
      and  ee.effective_start_date  <= p_entry_end_date
      and  ee.effective_end_date    >= p_entry_start_date
      and  p_mult_ent_allowed_flag    = 'Y'
      and  ee.element_entry_id       = p_element_entry_id
      and  ee.original_entry_id      is null
    UNION ALL
    select ee.element_entry_id,
           ee.original_entry_id,
           ee.effective_start_date,
           ee.effective_end_date,
           ee.element_link_id,
           ee.creator_type
    from   pay_element_entries_f ee
    where  ee.entry_type             = 'E'
      and  ee.effective_start_date  <= p_entry_end_date
      and  ee.effective_end_date    >= p_entry_start_date
      and  p_mult_ent_allowed_flag   = 'Y'
      and  ee.original_entry_id      = p_element_entry_id
    UNION ALL
    select ee.element_entry_id,
           ee.original_entry_id,
           ee.effective_start_date,
           ee.effective_end_date,
           ee.element_link_id,
           ee.creator_type
    from   pay_element_entries_f ee
    where  ee.entry_type             = 'E'
      and  ee.effective_start_date  <= p_entry_end_date
      and  ee.effective_end_date    >= p_entry_start_date
      and  p_mult_ent_allowed_flag    = 'N'
      and  ee.assignment_id          = p_assignment_id
      and  ee.element_link_id        = p_element_link_id
    order by 3;
  --
  v_entry                  csr_entry%rowtype;
  v_distinct_entry_id      number;
  v_first_entry_adjusted   boolean := false;
  v_dummy_date             date;
  v_element_entry_id       number;
  v_first_element_entry_id number;
  v_last_element_entry_id  number;
  v_entry_start_date       date;
  v_entry_end_date         date;
  v_calc_entry_start_date  date;
  v_calc_entry_end_date    date;
  v_ele_entry_rec          hrentmnt.t_ele_entry_rec;
  v_num_entry_values       number := 0;
  v_input_value_id_tbl     hr_entry.number_table;
  v_entry_value_tbl        hr_entry.varchar2_table;

-- bugfix 1691062
l_category fnd_descr_flex_contexts.descriptive_flex_context_code%type;
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.adjust_recurring_entries');
                hr_utility.trace ('');
                hr_utility.trace ('     p_dt_mode = '
                        ||p_dt_mode);
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_element_link_id = '
                        ||to_char (p_element_link_id));
                hr_utility.trace ('     p_standard_link_flag = '
                        ||p_standard_link_flag);
                hr_utility.trace ('     p_mult_ent_allowed_flag = '
                        ||p_mult_ent_allowed_flag);
                hr_utility.trace ('     p_validation_start_date = '
                        ||to_char (p_validation_start_date));
                hr_utility.trace ('     p_validation_end_date = '
                        ||to_char (p_validation_end_date));
                hr_utility.trace ('     p_val_start_date_minus_one = '
                        ||to_char (p_val_start_date_minus_one));
                hr_utility.trace ('     p_val_end_date_plus_one = '
                        ||to_char (p_val_end_date_plus_one));
                        --
                hr_utility.trace ('     p_entry_count = '
                        ||to_char (p_entry_count));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
        function standard_element (
                --
                -- Returns TRUE if the element link specified is a standard
                -- one.
                --
                p_element_link_id in number,
                p_effective_date in date)
                --
                return boolean is
                --
                cursor csr_standard_link is
                        --
                        select  standard_link_flag
                        from    pay_element_links_f
                        where   element_link_id = p_element_link_id
                        and     p_effective_date between effective_start_date
                                                and effective_end_date;
                --
                l_standard      varchar2 (30) := 'N';
                no_link_found   exception;
                --
                begin
                --
                open csr_standard_link;
                fetch csr_standard_link into l_standard;
                --
                if csr_standard_link%notfound then
                  close csr_standard_link;
                  raise no_link_found;
                else
                  close csr_standard_link;
                end if;
                --
                return (l_standard = 'Y');
                --
                EXCEPTION
                --
                when no_link_found then
                  --
                  fnd_message.set_name ('PAY','HR_6153_ALL_PROCEDURE_FAIL');
                  fnd_message.set_token ('PROCEDURE',
                                        'hrentmnt.adjust_recurring_entries');
                  fnd_message.set_token ('STEP','1');
                  fnd_message.raise_error;
                  --
                end standard_element;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Find all distinct element entries that match the calculated element entry
  -- and overlap with the period of change  NB. it is possible that multiple
  -- element entries exist and each must be processed separately ie.
  --
  --  period of change |--------------------------------|
  --  current entry 1      |--------------------|
  --  current entry 2      |--------------------|
  --  current entry 3      |--------------------|
  --
  open csr_distinct_entries(p_mult_ent_allowed_flag,
                             p_assignment_id,
                             p_element_link_id,
                             p_val_start_date_minus_one,
                             p_val_end_date_plus_one);
  --
  -- Get the first distinct current element entry.
  --
  fetch csr_distinct_entries into v_distinct_entry_id;
  --
  -- A current element entry matches the calculated element entry.
  --
  if csr_distinct_entries%found then
    --
    -- Continue for all distinct current element entries.
    --
    if g_debug then
    hr_utility.trace('Distinct entries found');
    end if;
    --
    while csr_distinct_entries%found loop
      --
      -- Loop around for each part of the calculated element entry NB. it is
      -- possible that a change can split an element entry which is then
      -- represented by 2 calculated element entries ie.
      --
      --  period of change      |------------------|
      --  current entry      |------------------------|
      --  calc entry         |--|                  |--|
      --
      -- and find any current element entries that overlap with it.
      --
      for v_loop in 1..p_entry_count loop
        --
        -- Initialse the start and end dates of calculated element entry.
        --
        v_calc_entry_start_date := p_entry_start_date_tbl(v_loop);
        v_calc_entry_end_date   := p_entry_end_date_tbl(v_loop);
        --
        if g_debug then
        hr_utility.trace('esd : ' || v_calc_entry_start_date);
        hr_utility.trace('eed : ' || v_calc_entry_end_date);
        end if;
        --
        -- Initialise the flag.
        --
        v_first_entry_adjusted := false;
        --
        -- Find current element entries that overlap with calculated element
        -- entry (for distinct element entry).
        --
        open csr_entry(p_mult_ent_allowed_flag,
                        v_distinct_entry_id,
                        p_assignment_id,
                        p_element_link_id,
                        v_calc_entry_start_date,
                        v_calc_entry_end_date);
        --
        -- Get the first current element entry (for distinct element entry).
        --
        fetch csr_entry into v_entry;
        --
        -- Current element entry has been found (for distinct element entry).
        --
        if csr_entry%found then
          --
          -- Initialse the start and end dates of current element entry.
          --
          v_first_element_entry_id := v_entry.element_entry_id;
          v_last_element_entry_id  := v_entry.element_entry_id;
          v_entry_start_date       := v_entry.effective_start_date;
          v_entry_end_date         := v_entry.effective_end_date;
          --
          -- Take a copy of the current element entry as this may be needed
          -- later.
          --
          hrentmnt.cache_element_entry
             (v_entry.element_entry_id,
              v_entry.effective_end_date,
              v_ele_entry_rec,
              v_num_entry_values,
              v_input_value_id_tbl,
              v_entry_value_tbl);
          --
          -- Continue for all current element entries that overlap with the
          -- calculated element entry (for current distinct element entry).
          --
          while csr_entry%found loop
            --
            -- Get next current element entry that overlaps with the
            -- calculated element entry (for distinct element entry).
            --
            fetch csr_entry into v_entry;
            --
            -- Either there are no more current element entries that overlap
            -- with the calculated element entry or the next element entry
            -- is not contiguous with the previous one ie.
            --
            --  calc entry     |--------------------------------->
            --  current entry      |---|----|---|-----|    |----->
            --                       1   2    3    4
            --
            -- This can occur when the element entries have been previously
            -- split.
            --
            -- Now have the start and end dates of the calculated and
            -- current element entries which are then compared iand the
            -- current element entry is adjusted accordingly to be in line
            -- with the calculated element entry.
            --
            -- NB. although several element entries may exist only the first
            --     and last could possible be changed ie. 1 and 4.
            --
            if csr_entry%notfound or
                v_entry.effective_start_date <> v_entry_end_date + 1 then
               --
               -- Existing element entry starts before the calculated start
               -- date of new entry so need move the start date forwards.
               --
               --  calc entry          |------------------------>
               --  current entry   |---------------------------->
               --
              if v_entry_start_date < v_calc_entry_start_date and
                  v_calc_entry_start_date > p_validation_start_date and
                  v_calc_entry_start_date <= p_val_end_date_plus_one and
                  not v_first_entry_adjusted then

if g_debug then
hr_utility.trace ('***** bringing "start" date of current REE forwards  *****');
hr_utility.trace ('***** calc           |------------->                 *****');
hr_utility.trace ('*****          ----->                                *****');
hr_utility.trace ('***** current |-------------------->                 *****');
end if;
                --
                -- Validate the adjustment, maintain referential integrity,
                -- and adjust the element entry.
                --
                hrentmnt.validate_adjust_entry
                  ('UPDATE',
                   p_assignment_id,
                   v_first_element_entry_id,
                   'START',
                   v_entry_start_date,
                   v_calc_entry_start_date,
                   null,
                   null,
                   p_entries_changed);
                --
                -- Flag that the EFFECTIVE_START_DATE of an element entry
                -- has been adjusted.
                --
                 v_first_entry_adjusted := true;
               --
               -- Existing element entry starts after the calculated start date
               -- of new entry so need move the start date backwards. NB This
               -- should only be done for standard elements.
               --
               --  calc entry     |------------------------>
               --  current entry       |------------------->
               --
               --
               -- bugfix 725811
               -- if EEs have been created from the Salary Admin form,
               -- then it is valid to pull the EE's ESD
               -- backwards in line with the calculated ESD,
               -- only in the case where the old hire date is the
               -- same as the current entry start date (fix 1711753).
               -- nb. this breaks the rule that EEs associated
               -- with a non-standard element link should NOT have their
               -- ESD/EED altered programatically, however in the case of
               -- Salary Proposal EEs this is ok
               --
               elsif v_entry_start_date > v_calc_entry_start_date and
                     v_calc_entry_start_date >= p_validation_start_date and
                     v_calc_entry_start_date < p_val_end_date_plus_one and
                     not v_first_entry_adjusted and
                     (standard_element(v_entry.element_link_id,
                                       v_calc_entry_start_date)
                      or
                      (v_entry.creator_type = 'SP'
                          and p_old_hire_date = v_entry_start_date)
                     )
                     then

if g_debug then
hr_utility.trace ('***** bringing "start" date of current REE backwards *****');
hr_utility.trace ('***** calc    |-------------------->                 *****');
hr_utility.trace ('*****          <-----                                *****');
hr_utility.trace ('***** current        |------------->                 *****');
end if;
                --
                -- Validate the adjustment, maintain referential integrity,
                -- and adjust the element entry.
                --
                hrentmnt.validate_adjust_entry
                  ('UPDATE',
                   p_assignment_id,
                   v_first_element_entry_id,
                   'START',
                   v_entry_start_date,
                   v_calc_entry_start_date,
                   null,
                   null,
                    p_entries_changed);
                --
                -- Flag that the EFFECTIVE_START_DATE of an element entry
                 -- has been adjusted.
                --
                 v_first_entry_adjusted := true;
                --
              end if;
               --
               -- Existing element entry ends after the calculated end date
               -- of new entry so need move the end date backwards.
               --
               --  calc entry     |----------------|
               --  current entry  |------------------------>
               --
              if v_entry_end_date > v_calc_entry_end_date then

if g_debug then
hr_utility.trace ('***** bringing "end" date of current REE backwards   *****');
hr_utility.trace ('***** calc    |-------------|                        *****');
hr_utility.trace ('*****                        <-----                  *****');
hr_utility.trace ('***** current |-------------------->                 *****');
end if;
                hrentmnt.validate_adjust_entry
                  ('UPDATE',
                   p_assignment_id,
                   v_last_element_entry_id,
                   'END',
                   v_entry_end_date,
                   p_entry_end_date_tbl(v_loop),
                   null,
                   null,
                    p_entries_changed);
               --
               -- Existing element entry ends before the calculated end date
               -- of new entry so need move the end date forwards. NB This
               -- should only be done for standard elements.
               -- Bug 514895. Enabled for non standard elements, this makes above sentence
               -- invalid.
               --
               --  calc entry     |------------------------------->
               --  current entry  |------------------|
               --
               -- NB. if the user is doing a CORRECTION then only extend the
               --     end date of the current element entry if it exists up to
               --     the day before the change ie.  (WWBug 268814)
               --
               --  calc entry        |--------------------------|
               --  current entry     |-----------| (do not extend)
               --  current entry  |--|             (extend)
               --
               -- The same rule applies to DELETE_NEXT_CHANGE as this
               -- effectively corrects the next row using the values from the
               -- earlier row.
               --
               -- NB. if the user is doing an UPDATE then do not extend the
               --     end date of the current element entry. The updating of an
               --     assignment can only result in the shutting down of
               --     existing element entries or the creation of new ones
               --     ie. (WWBug 283275).
               --
               -- The same rule applies to UPDATE_CHANGE_INSERT.
               --
               --  calc entry        |--------------------------|
               --  current entry     |-----------| (do not extend)
               --
               -- Bug 514895. Removed condition for standard element. See comments above.
               --

               --
               -- bug 911328,
               -- when in CORRECT mode only update REE that are SL'ed,
               -- ie. it possible that a non-SL'ed REE may end a
               --     day before the VSD,
               --     in this case its EED should be left alone
               --
              elsif v_entry_end_date < v_calc_entry_end_date and
                     v_entry_end_date >= p_val_start_date_minus_one and
                     p_dt_mode   <> 'UPDATE' and
                     p_dt_mode   <> 'UPDATE_CHANGE_INSERT' and
                     --
-- boundary cases --
                    (
                        -- Bugfix 4221603
                        -- In UPDATE_OVERRIDE mode, only move
                        -- end date forwards when the entry is
                        -- a standard entry.
                        (p_dt_mode = 'UPDATE_OVERRIDE' and
                         standard_element(v_entry.element_link_id,
                                          v_calc_entry_end_date) and
                         -- Bugfix 4765204
                         -- Only continue if entry ends within the
                         -- 'range of change'.
                         p_validation_start_date <= v_entry_end_date
                        )
                        or
                        -- Or when the entry was created by a
                        -- Salary Proposal
                        (p_dt_mode = 'UPDATE_OVERRIDE' and
                         v_entry.creator_type = 'SP' and
                         -- Bugfix 4765204
                         -- Only continue if entry ends within the
                         -- 'range of change'.
                         p_validation_start_date <= v_entry_end_date
                        )
                        or
                        (p_dt_mode <> 'UPDATE_OVERRIDE')
                    ) and
                    (
                        (p_dt_mode = 'DELETE_NEXT_CHANGE' and
                         p_val_start_date_minus_one = v_entry_end_date and
                         standard_element(v_entry.element_link_id,
                                          v_calc_entry_end_date)
                        )
                        or
                        (p_dt_mode = 'DELETE_NEXT_CHANGE' and
                         p_val_start_date_minus_one = v_entry_end_date and
			 --Bug 6809717 Added F to the following code to adjust recurring
			 --entries properly
                         v_entry.creator_type in ('SP', 'UT','F') -- 2437795
                        )
                        or
                        (p_dt_mode <> 'DELETE_NEXT_CHANGE')
                    ) and
                    -- Bugfix 4354757
                    -- Only move end date forwards in FUTURE_CHANGE mode
                    -- for standard entries, salary proposal entries and
                    -- US tax entries (to be consistent with
                    -- DELETE_NEXT_CHANGE mode).
                    (
                        (p_dt_mode = 'FUTURE_CHANGE' and
                         p_val_start_date_minus_one = v_entry_end_date and
                         standard_element(v_entry.element_link_id,
                                          v_calc_entry_end_date)
                        )
                        or
                        (p_dt_mode = 'FUTURE_CHANGE' and
                         p_val_start_date_minus_one = v_entry_end_date and
                         v_entry.creator_type in ('SP', 'UT')
                        )
                        or
                        (p_dt_mode <> 'FUTURE_CHANGE')
                    ) and
                    (
                        (p_dt_mode = 'CORRECTION' and
                         p_val_start_date_minus_one = v_entry_end_date and
                         standard_element(v_entry.element_link_id,
                                          v_calc_entry_end_date)
                        )
                        or
                        (p_dt_mode = 'CORRECTION' and
                         p_val_start_date_minus_one = v_entry_end_date and
                         v_entry.creator_type = 'SP'
                        )
                        or
                        (p_dt_mode <> 'CORRECTION')
                     ) then

if g_debug then
hr_utility.trace ('***** bringing "end" date of current REE forwards    *****');
hr_utility.trace ('***** calc    |-------------------->                 *****');
hr_utility.trace ('*****                         ----->                 *****');
hr_utility.trace ('***** current |--------------|                       *****');
end if;
                 --
                 -- Another current entry exists in the future so only move the
                 -- end date to the day before the this element entry.
                 --
                 if csr_entry%found then
                  --
                   -- Validate the adjustment, maintain referential integrity,
                   -- and adjust the element entry.
                  --
                  hrentmnt.validate_adjust_entry
                    ('UPDATE',
                     p_assignment_id,
                     v_last_element_entry_id,
                     'END',
                     v_entry_end_date,
                     v_entry.effective_start_date - 1,
                     null,
                     null,
                      p_entries_changed);
                  --
                else
                  --
                   -- Validate the adjustment, maintain referential integrity,
                   -- and adjust the element entry.
                  --
                  hrentmnt.validate_adjust_entry
                    ('UPDATE',
                     p_assignment_id,
                     v_last_element_entry_id,
                     'END',
                     v_entry_end_date,
                     v_calc_entry_end_date,
                     null,
                     null,
                      p_entries_changed);
                  --
                end if;
                --
              end if;
              --
              -- A new element entry has been found ie. not contiguous so hold
               -- information about this new element entry.
              --
               v_last_element_entry_id := v_entry.element_entry_id;
              v_entry_start_date      := v_entry.effective_start_date;
               v_entry_end_date        := v_entry.effective_end_date;
              --
            else
              --
              -- A contiguous current element entry has been found so update
               -- the current element entry end date.
              --
               v_last_element_entry_id := v_entry.element_entry_id;
              v_entry_end_date        := v_entry.effective_end_date;
              --
            end if;
            --
          end loop;
        --
        -- Current element entry has been split and first part of new
         -- element entry has been created by adjusting the existing current
         -- element entry. Need to create a new element entry for the
         -- element entry on the other side of the split NB. this uses the
         -- cached values from the first element entry ie.
        --
         --  calc entry     |----|              |----|
         --  current entry  |------------------------|
         --  new entry      |----|  (created by adjusting the current entry)
         --  new entry                          |----| (created from new)
         --
         --
         -- Create element entry.
         -- Do it only when its calculated start date is within a validation
         -- period (bug 398360).
         -- However, do not do so if the entry has a creator type
         -- of SP (salary proposal) - fix 2298468..

        elsif (v_calc_entry_start_date >= p_validation_start_date and
               v_ele_entry_rec.creator_type <> 'SP') then
          --
          if g_debug then
          hr_utility.trace('Original_entry_id : ' || v_distinct_entry_id);
          end if;
          hr_entry_api.insert_element_entry
            (p_effective_start_date => v_calc_entry_start_date,
             p_effective_end_date   => v_dummy_date,
             p_element_entry_id     => v_element_entry_id,
             p_original_entry_id    => v_distinct_entry_id,
             p_assignment_id        => p_assignment_id,
             p_element_link_id      => p_element_link_id,
             p_creator_type         => v_ele_entry_rec.creator_type,
             p_entry_type           => v_ele_entry_rec.entry_type,
             p_cost_allocation_keyflex_id
                                => v_ele_entry_rec.cost_allocation_keyflex_id,
             p_comment_id           => v_ele_entry_rec.comment_id,
             p_creator_id           => v_ele_entry_rec.creator_id,
             p_reason               => v_ele_entry_rec.reason,
             p_target_entry_id      => v_ele_entry_rec.target_entry_id,
             p_subpriority          => v_ele_entry_rec.subpriority,
             p_personal_payment_method_id
                                => v_ele_entry_rec.personal_payment_method_id,
             p_date_earned          => v_ele_entry_rec.date_earned,
             p_attribute_category   => v_ele_entry_rec.attribute_category,
             p_attribute1           => v_ele_entry_rec.attribute1,
             p_attribute2           => v_ele_entry_rec.attribute2,
             p_attribute3           => v_ele_entry_rec.attribute3,
             p_attribute4           => v_ele_entry_rec.attribute4,
             p_attribute5           => v_ele_entry_rec.attribute5,
             p_attribute6           => v_ele_entry_rec.attribute6,
             p_attribute7           => v_ele_entry_rec.attribute7,
             p_attribute8           => v_ele_entry_rec.attribute8,
             p_attribute9           => v_ele_entry_rec.attribute9,
             p_attribute10          => v_ele_entry_rec.attribute10,
             p_attribute11          => v_ele_entry_rec.attribute11,
             p_attribute12          => v_ele_entry_rec.attribute12,
             p_attribute13          => v_ele_entry_rec.attribute13,
             p_attribute14          => v_ele_entry_rec.attribute14,
             p_attribute15          => v_ele_entry_rec.attribute15,
             p_attribute16          => v_ele_entry_rec.attribute16,
             p_attribute17          => v_ele_entry_rec.attribute17,
             p_attribute18          => v_ele_entry_rec.attribute18,
             p_attribute19          => v_ele_entry_rec.attribute19,
             p_attribute20          => v_ele_entry_rec.attribute20,
             p_entry_information_category
                                => v_ele_entry_rec.entry_information_category,
             p_entry_information1   => v_ele_entry_rec.entry_information1,
             p_entry_information2   => v_ele_entry_rec.entry_information2,
             p_entry_information3   => v_ele_entry_rec.entry_information3,
             p_entry_information4   => v_ele_entry_rec.entry_information4,
             p_entry_information5   => v_ele_entry_rec.entry_information5,
             p_entry_information6   => v_ele_entry_rec.entry_information6,
             p_entry_information7   => v_ele_entry_rec.entry_information7,
             p_entry_information8   => v_ele_entry_rec.entry_information8,
             p_entry_information9   => v_ele_entry_rec.entry_information9,
             p_entry_information10  => v_ele_entry_rec.entry_information10,
             p_entry_information11  => v_ele_entry_rec.entry_information11,
             p_entry_information12  => v_ele_entry_rec.entry_information12,
             p_entry_information13  => v_ele_entry_rec.entry_information13,
             p_entry_information14  => v_ele_entry_rec.entry_information14,
             p_entry_information15  => v_ele_entry_rec.entry_information15,
             p_entry_information16  => v_ele_entry_rec.entry_information16,
             p_entry_information17  => v_ele_entry_rec.entry_information17,
             p_entry_information18  => v_ele_entry_rec.entry_information18,
             p_entry_information19  => v_ele_entry_rec.entry_information19,
             p_entry_information20  => v_ele_entry_rec.entry_information20,
             p_entry_information21  => v_ele_entry_rec.entry_information21,
             p_entry_information22  => v_ele_entry_rec.entry_information22,
             p_entry_information23  => v_ele_entry_rec.entry_information23,
             p_entry_information24  => v_ele_entry_rec.entry_information24,
             p_entry_information25  => v_ele_entry_rec.entry_information25,
             p_entry_information26  => v_ele_entry_rec.entry_information26,
             p_entry_information27  => v_ele_entry_rec.entry_information27,
             p_entry_information28  => v_ele_entry_rec.entry_information28,
             p_entry_information29  => v_ele_entry_rec.entry_information29,
             p_entry_information30  => v_ele_entry_rec.entry_information30,
             p_num_entry_values     => v_num_entry_values,
             p_input_value_id_tbl   => v_input_value_id_tbl,
             p_entry_value_tbl      => v_entry_value_tbl);

          -- ** remove ** following update when api supports
          -- the attributes that are being updated.
          update pay_element_entries_f pee
          set pee.balance_adj_cost_flag = v_ele_entry_rec.balance_adj_cost_flag,
              pee.source_asg_action_id  = v_ele_entry_rec.source_asg_action_id,
              pee.source_link_id        = v_ele_entry_rec.source_link_id,
              pee.source_trigger_entry  = v_ele_entry_rec.source_trigger_entry,
              pee.source_period         = v_ele_entry_rec.source_period,
              pee.source_run_type       = v_ele_entry_rec.source_run_type,
              pee.source_start_date     = v_ele_entry_rec.source_start_date,
              pee.source_end_date       = v_ele_entry_rec.source_end_date
          where  pee.element_entry_id   = v_element_entry_id
          and    v_calc_entry_start_date between
                 pee.effective_start_date and pee.effective_end_date;
        --
        end if;
        --
        close csr_entry;
        --
      end loop;
      --
      -- Get the next distinct element entry.
      --
      fetch csr_distinct_entries into v_distinct_entry_id;
    --
    end loop;
  --
  -- No distinct element entries exist for the calculated entry so create
  -- new element entries.
  --
  else
    --
    -- for each calculated element entry.
    --
    for v_loop in 1..p_entry_count loop
      --
      -- Set the start date for each new element entry.
      --
      v_calc_entry_start_date := p_entry_start_date_tbl(v_loop);
      --
      -- Create new element entry.
      -- Do it only when its calculated start date is within a validation
      -- period (bug 398360).
      --
      if v_calc_entry_start_date >= p_validation_start_date then
      --
      if g_debug then
         hr_utility.trace('********** ASG criteria delta');
         hr_utility.trace('********** for SL call EE insert interface');
      end if;
      hr_entry_api.insert_element_entry
        (p_effective_start_date => v_calc_entry_start_date,
         p_effective_end_date   => v_dummy_date,
         p_element_entry_id     => v_element_entry_id,
         p_assignment_id        => p_assignment_id,
         p_element_link_id      => p_element_link_id,
         p_creator_type         => 'F',
         p_entry_type           => 'E');
--
-- bugfix 1691062,
-- check if the element entry could potentially make use of the DDFF,
-- ie. entry information category is not null,
-- if so, then entry_information_category needs to be set on database
--
-- nb. this is only done for new entries created,
-- not entries that are being maintained
--
l_category := get_entry_info_category(p_assignment_id,
                                        v_calc_entry_start_date,
                                        p_element_link_id);
--
-- cannot use insert interface as other DDFF column are not present
-- and these may have validation set up
--
if l_category is not null then
      if g_debug then
         hr_utility.trace('********** ASG criteria delta');
         hr_utility.trace('********** l_category>' || l_category || '<');
      end if;

      --
      -- only single element entry row exists, no need for effective dates
      --
      UPDATE pay_element_entries_f
      SET    entry_information_category = l_category
      WHERE  element_entry_id = v_element_entry_id;
end if;
      --
      end if;
      --
    end loop;
    --
  end if;
  --
  close csr_distinct_entries;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.adjust_recurring_entries');
  end if;
  --
end adjust_recurring_entries;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.adjust_entries_pqc                                              --
--                                                                          --
-- DESCRIPTION                                                              --
-- Adjusts element entries when the personal qualifying conditions for the  --
-- assignment are changed ie. DOB or probation period NB. this is only      --
-- applied for standard element entries as the user is able to override     --
-- personal qualifying conditions when creating discretionary element       --
-- entries.                                                                 --
-- NOTES                                                                    --
-- Only existing standard element entries are adjusted due to a change in   --
-- personal qualifying conditions ie. no new standard element entries are   --
-- created during this process.                                             --
------------------------------------------------------------------------------
--
procedure adjust_entries_pqc
(
 p_assignment_id   number,
 p_entries_changed in out nocopy varchar2
) is
  --
  -- Local Cursors
  --
  cursor csr_standard_entries is
    select ee.element_entry_id,
            ee.creator_type,
            ee.creator_id,
           ee.effective_start_date,
           ee.effective_end_date,
           ee.element_link_id
    from   pay_element_entries_f ee
    where  ee.assignment_id = p_assignment_id
      and  ee.entry_type    = 'E'
      and  exists
             (select null
              from   pay_element_links_f el,
                      pay_element_types_f et
              where  el.element_link_id    = ee.element_link_id
                and  el.standard_link_flag = 'Y'
                 and  et.element_type_id    = el.element_type_id
                 and  et.processing_type    = 'R')
    order by ee.element_link_id, ee.effective_start_date;
  --
  -- Local Variables
  --
  v_current_element_link_id         number := -1;
  v_los_date                        date;
  v_age_date                        date;
  v_start_date_qc                   date;
  v_new_entry_start_date            date;
  v_min_entry_start_date            date;
  v_first_entry_adjusted boolean := false;
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.adjust_entries_pqc');
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Find all standard element entries for the assignment / element link NB.
  -- each date effective instance is returned in order for each element entry
  -- ie.
  --
  --    EE1       |-----------|-----------|----------|------------->
  --
  -- loop 1       |-----------|
  -- loop 2                   |-----------|
  -- loop 3                               |----------|
  -- loop 4                                          |------------->
  --
  --                                         "
  --                                         | QC start date
  --
  -- This is repeated for each element entry.
  --
  -- Each row is compared against the qualifying condition start date. Each
  -- row that exists completely before is removed, the first row that overlaps
  -- with the qualifying condition start date is adjusted accordingly and then
  -- all subsequent rows are left alone eg.
  --
  -- loop 1  row exists before start date so remove.
  -- loop 2  row exists before start date so remove.
  -- loop 3  row overlaps with QC start date so adjust.
  -- loop 4  leave row alone.
  --
  for v_entry in csr_standard_entries loop
    --
    -- Check to see if the qualifying condition start date has already been
    -- obtained for the element entry.
    --
    if v_current_element_link_id <> v_entry.element_link_id then
      --
      -- Get the start date of the element entry accordinbg to the qualifying
      -- conditions.
      --
      hr_entry.return_qualifying_conditions
        (p_assignment_id,
         v_entry.element_link_id,
         v_entry.effective_start_date,
         v_los_date,
         v_age_date);
      --
      -- Calculate the element entry start date according to the qualifying
      -- conditions. Changed due to WWBug 272990.
      --
      v_start_date_qc           := least(nvl(v_los_date,v_age_date),
                                         nvl(v_age_date,v_los_date));
      v_first_entry_adjusted    := false;
      v_current_element_link_id := v_entry.element_link_id;
      --
    end if;
    --
    -- Element entry start date is not the same as that according to the
    -- qualifying conditions.
    --
    if v_start_date_qc is not null and
       v_start_date_qc <> v_entry.effective_start_date then
      --
      -- Element entry ends before it is eligible according to the
      -- qualifying conditions ie.
      --
      --     EE  |--------------------------|
      --                                           "
      --                                           | QC date
      --
      if v_start_date_qc > v_entry.effective_end_date then
        --
        -- Remove element entry that exists before qualifying conditions.
        --
        hrentmnt.validate_adjust_entry
          ('DELETE',
           p_assignment_id,
           v_entry.element_entry_id,
           null,
           null,
           null,
           v_entry.effective_start_date,
           v_entry.effective_end_date,
            p_entries_changed);
        --
        -- Remove element entry values.
        --
         delete from pay_element_entry_values_f eev
         where  eev.element_entry_id     = v_entry.element_entry_id
           and  eev.effective_start_date = v_entry.effective_start_date
           and  eev.effective_end_date   = v_entry.effective_end_date;
        --
        -- Remove element entries.
        --
         delete from pay_element_entries_f ee
         where  ee.element_entry_id     = v_entry.element_entry_id
           and  ee.effective_start_date = v_entry.effective_start_date
           and  ee.effective_end_date   = v_entry.effective_end_date;
        --
        -- Call the routine that checks whether an illegal purge
        -- has occurred (i.e. disallowed by profile).
        hrentmnt.validate_purge(v_entry.element_entry_id,
                                v_entry.element_link_id);
        --
        -- Salary Admin entry is being removed. See if the pay proposal is
         -- used by any other entry. If not then it is removed.
        --
        if v_entry.creator_type = 'SP' then
          --
          hrentmnt.remove_pay_proposals
            (p_assignment_id,
             v_entry.creator_id);
          --
        end if;
      --
      -- Element entry start date does match the qualifying condition
      -- start date ie.
      --
      --     EE  |----------|---------|----->
      --               "
      --               | QC date
      --
      -- or
      --
      --                      EE  |-------|--------|--------->
      --               "
      --               | QC date
      --
      -- NB. only adjust the first date effective instance of each
      --     element entry. Any date effective instances of the element entry
      --     that exist completely before the qualifying condition start date
      --     will have already been removed.
      --
      elsif not v_first_entry_adjusted then
        --
        -- The change in qualifying conditions has meant that the start date
         -- of the element entry has to be moved back ie.
        --
        --            EE |-----------|-----------|----------|------------->
        --        "
        --        | QC start date
         --
         -- Must make sure that the element entry is only moved back as far as
         -- it is eligible ie. the assignments criteria may be different
         -- earlier such that it is not eligible for the element entry ie.
        --
        --  ASG |--A--|--B--|--B--|-------------------B-------------------->
        --
        --  EL  |-------------------------------B-------------------------->
        --
        --            EE |-----------|-----------|----------|------------->
        --        "
        --        | QC start date
         --
         --  New EE    |---------------|----.........
         --
         --  ie. back to point where element entry ceased to be eligible.
         --
        if v_start_date_qc < v_entry.effective_start_date then
           --
           -- Get the earliest date the element entry could be moved back to
           -- ie. as far back as the eligibility allows.
           --
          v_min_entry_start_date := min_eligibility_date
                                       (v_current_element_link_id,
                                        p_assignment_id,
                                        v_start_date_qc,
                                        v_entry.effective_start_date);
          --
          -- The element entry start date must fall within the time where
           -- the element entry is eligible ie. if the minimum possible start
           -- date is aftere the start date according to the qualifying
           -- conditions then the minimum eligibility date must be used.
          --
           v_new_entry_start_date := greatest(v_min_entry_start_date,
                                              v_start_date_qc);
        --
        -- The change in qualifying conditions has meant that the start date
         -- of the element entry has to be moved forward. This change in
         -- element entry start date always falls within the date effective
         -- lifetime of an existing element entry which means the element
         -- entry will be eligible for the assignment and therefore no extra
         -- validation relating to eligibility is required ie.
        --
        --         EE |-----------|-----------|----------|------------->
        --                              "
        --                              | QC start date
         --
        else
           v_new_entry_start_date := v_start_date_qc;
         end if;
        --
        -- Adjust element entry to bring element entry start date into line
         -- with the qualifying condition start date NB. if the new date is
         -- restricted to the current date due to earlier eligibility changes
         -- to the assignment then the start date cannot be altered ie.
        --
        -- EL   |-----------------------A------------------------------->
         --
         -- ASG  |----A-----|--------B--------|------------A------------->
        --
        -- EE                                |-------------------------->
         --                                   ^
         --                                   | current pqc date
        --            ^
         --            | new pqc date
         --
         -- In this case the element entry cannot have its start date altered
         -- as this would result in it existing during a period of time when it
         -- was not eligible.
        --
         if v_new_entry_start_date <> v_entry.effective_start_date then
          hrentmnt.validate_adjust_entry
            ('UPDATE',
             p_assignment_id,
             v_entry.element_entry_id,
             'START',
             v_entry.effective_start_date,
             v_new_entry_start_date,
             null,
             null,
              p_entries_changed);
        end if;
        --
        -- Indicate that the element entry has had its start date assessed
         -- relative to the qualifying condition start date.
        --
        v_first_entry_adjusted := true;
        --
      end if;
      --
    end if;
    --
  end loop;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.adjust_entries_pqc');
  end if;
  --
end adjust_entries_pqc;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.adjust_entries_cncl_term                                        --
--                                                                          --
-- DESCRIPTION                                                              --
-- Adjusts element entries that have been closed down during a termination. --
-- When the termination is cancelled all recurring element entries that     --
-- were closed down are opened up again NB. any nonrecurring entries that   --
-- removed cannot be recreated.
------------------------------------------------------------------------------
--
procedure adjust_entries_cncl_term
(
 p_business_group_id  number,
 p_assignment_id      number,
 p_actual_term_date   date,
 p_last_standard_date date,
 p_final_process_date date,
 p_entries_changed    in out nocopy varchar2,
 p_dt_mode            varchar2,
 p_old_people_group_id   number,
 p_new_people_group_id   number
) is
  --
  -- Find all recurring element entries that are ended according to their
  -- termination processing rule.
  --
  -- Bugfix 2249308:
  -- Ignore entries that were previously stopped by a formula result
  -- rule. We do not wish to extend entries of this type.
  --
  cursor csr_entry
         (
          p_assignment_id      number,
           p_actual_term_date   date,
           p_last_standard_date date,
           p_final_process_date date,
           p_sot                date
         ) is
    select ee.element_entry_id,
           ee.effective_start_date,
           ee.effective_end_date,
            ee.element_link_id
    from   pay_element_entries_f ee
    where  ee.assignment_id = p_assignment_id
      and  ee.entry_type = 'E'
      and  nvl(ee.updating_action_type,'null') <> 'S' -- Bugfix 2249308
      and  exists
             (select null
              from   pay_element_links_f el,
                     pay_element_types_f et
              where  el.element_link_id = ee.element_link_id
                and  el.element_type_id = et.element_type_id
                and  et.processing_type = 'R')
      and  ee.effective_end_date =
              (select decode(et.post_termination_rule,
                               'A',nvl(p_actual_term_date,p_sot),
                               'L',nvl(p_last_standard_date,p_sot),
                               'F',nvl(p_final_process_date,p_sot),
                                   p_sot)
               from   pay_element_links_f el,
                      pay_element_types_f et
               where  el.element_link_id = ee.element_link_id
                 and  et.element_type_id = el.element_type_id
                 and  ee.effective_start_date between el.effective_start_date
                                                  and el.effective_end_date
                 and  ee.effective_start_date between et.effective_start_date
                                                  and et.effective_end_date);
  --
  -- Local Constants
  --
  c_sot             constant date := to_date('01/01/0001','DD/MM/YYYY');
  --
  -- Local Variables
  --
  v_entry_end_date  date;
  v_entries_changed varchar2(1);
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.adjust_entries_cncl_term');
                hr_utility.trace ('');
                hr_utility.trace ('     p_business_group_id = '
                        ||to_char (p_business_group_id));
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_actual_term_date = '
                        ||to_char (p_actual_term_date));
                hr_utility.trace ('     p_last_standard_date = '
                        ||to_char (p_last_standard_date));
                hr_utility.trace ('     p_final_process_date = '
                        ||to_char (p_final_process_date));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Maintain assignment link usages for the assignment.
  --
  hrentmnt.maintain_alu_asg
    (p_assignment_id,
     p_business_group_id,
     p_dt_mode,
     p_old_people_group_id,
     p_new_people_group_id);
  --
  -- The final process date has been set for the termination so the assignment
  -- will have been date effectively ended.
  --
  if p_final_process_date is not null then
    --
    -- Open up any nonrecurring entries which had been closed down when the
    -- assignment was date effectively ended.
    --
    -- WWBUG 314279. Switched the ordering of c_sot and p_final_process_date
    --     so that they agree with the parameters.
    --      c_sot -> validation_start_date
    --      p_final_process_date -> validation_end_date
    --      rathers than the other way around
    --
    hrentmnt.adjust_nonrecurring_entries
      (p_assignment_id,
       c_sot,
       p_final_process_date,
       v_entries_changed,
       p_dt_mode);
    --
  end if;
  --
  -- Loop for all recurring entries which have been closed down during the
  -- employees termination.
  --
  for v_entry in csr_entry(p_assignment_id,
                            p_actual_term_date,
                            p_last_standard_date,
                            p_final_process_date,
                            c_sot) loop
    --
    -- Get the true end date of the recurring entry.
    --
    v_entry_end_date := hr_entry.recurring_entry_end_date
                           (p_assignment_id,
                            v_entry.element_link_id,
                            v_entry.effective_start_date,
                            'N',
                            'N',
                            null,
                            null);
    --
    -- The recurring entry end date is less than the true end date of the
    -- element entry.
    --
    if v_entry.effective_end_date < v_entry_end_date then
      --
      -- Extend the recurring entry end date to the correct date.
      --
      hrentmnt.validate_adjust_entry
        ('UPDATE',
         p_assignment_id,
         v_entry.element_entry_id,
         'END',
         v_entry.effective_end_date,
         v_entry_end_date,
         null,
         null,
          p_entries_changed);
      --
    end if;
    --
  end loop;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.adjust_entries_cncl_term');
  end if;
  --
end adjust_entries_cncl_term;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.adjust_entries_cncl_hire                                        --
--                                                                          --
-- DESCRIPTION                                                              --
-- Adjusts element entries that are no longer valid when the hiring of a    --
-- person to an assignment is cancelled. The assignment ceases to exist as  --
-- an employee assignment so it is no longer valid to have element entries. --
------------------------------------------------------------------------------
--
procedure adjust_entries_cncl_hire
(
 p_business_group_id     number,
 p_assignment_id         number,
 p_validation_start_date date,
 p_validation_end_date   date,
 p_entries_changed       in out nocopy varchar2,
 p_dt_mode            varchar2,
 p_old_people_group_id   number,
 p_new_people_group_id   number
) is
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.adjust_entries_cncl_hire');
                hr_utility.trace ('');
                hr_utility.trace ('     p_business_group_id = '
                        ||to_char (p_business_group_id));
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_validation_start_date = '
                        ||to_char (p_validation_start_date));
                hr_utility.trace ('     p_validation_end_date = '
                        ||to_char (p_validation_end_date));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Maintain assignment link usages for the assignment.
  --
  hrentmnt.maintain_alu_asg
    (p_assignment_id,
     p_business_group_id,
     p_dt_mode,
     p_old_people_group_id,
     p_new_people_group_id
     );
  --
  -- Make sure there are no nonrecurring entries that have been made
  -- invalid by a change in assignment criteria.
  --
  hrentmnt.val_nonrec_entries
    (p_assignment_id,
     p_validation_start_date,
     p_validation_end_date,
     p_entries_changed);
  --
  -- Remove any recurring entries which are no longer valid.
  --
/*
  hrentmnt.remove_ineligible_recurring
    (p_assignment_id,
     p_entries_changed);
Added the p_dt_mode parameter to the following call to enable purging of
entries if cancel hire is being done*/
  hrentmnt.remove_ineligible_recurring
    (p_assignment_id,
     p_entries_changed,
        p_validation_start_date,
        p_validation_end_date,
	p_dt_mode);
  --
  -- Remove any nonrecurring entries which are no longer valid.
  --
  hrentmnt.remove_ineligible_nonrecurring
    (p_assignment_id,
     p_validation_start_date,
     p_validation_end_date,
     p_entries_changed);
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.adjust_entries_cncl_hire');
  end if;
  --
end adjust_entries_cncl_hire;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.adjust_entries_asg_criteria                                     --
--                                                                          --
-- DESCRIPTION                                                              --
-- Adjusts element entries that are affected by changes in assignment       --
-- criteria.                                                                --
------------------------------------------------------------------------------
--
procedure adjust_entries_asg_criteria
(
 p_business_group_id     number,
 p_assignment_id         number,
 p_dt_mode               varchar2,
 p_old_payroll_id        number,
 p_new_payroll_id        number,
 p_validation_start_date date,
 p_validation_end_date   date,
 p_entries_changed       in out nocopy varchar2,
 p_old_hire_date         date,
 p_old_people_group_id   number,
 p_new_people_group_id   number
) is
 --
 type t_asg_rec is record
   (effective_start_date date,
    effective_end_date   date);
 --
 cursor csr_link
 --
 -- Finds all standard links and also any links for which the assignment has
 -- entries NB. only those links that exist during the time over which the
 -- assignment has been changed are returned.
 -- also see bugs 2167881 and 2610904.
 --
        (
         p_business_group_id        number,
         p_assignment_id            number,
         p_validation_start_date    date,
         p_validation_end_date      date,
         p_val_start_date_minus_one date,
         p_val_end_date_plus_one    date
        ) is
   select el.element_link_id,
          min(el.effective_start_date) effective_start_date,
          max(el.effective_end_date) effective_end_date,
          el.link_to_all_payrolls_flag,
          el.payroll_id,
          el.job_id,
          el.grade_id,
          el.position_id,
          el.organization_id,
          el.location_id,
          el.pay_basis_id,
          el.employment_category,
          el.people_group_id,
          el.element_type_id,
          el.standard_link_flag
   from   pay_element_links_f el
   where  el.business_group_id = p_business_group_id
     and  ((el.standard_link_flag = 'Y' and
              exists
                (select null
                 from   pay_element_links_f el2
                 where  el2.element_link_id = el.element_link_id
                   and  el.effective_start_date <= p_validation_end_date
                   and  el.effective_end_date   >= p_validation_start_date))
       or   (el.standard_link_flag = 'N' and
             (exists
               (
                -- change 115.40
                --select null
                select /*+ index(ee pay_element_entries_f_n51) */ null
                from   pay_element_entries_f ee,
                       pay_element_types_f et
                where  ee.element_type_id = et.element_type_id
                  and  et.processing_type = 'R'
                  and  ee.entry_type = 'E'
                  and  ee.assignment_id = p_assignment_id
                  and  ee.element_link_id = el.element_link_id
                  -- Bugfix 7662923
                  and  ee.effective_start_date <= p_val_end_date_plus_one
                  and  ee.effective_end_date >= p_val_start_date_minus_one)) /*Bug 8879339 reverted fix for 7662923 ,it is now fixed in remove_eligible_recurring */
	   or (exists    -- Bug 8407592. Added this condition to check if any 'SP' creator type salary entries are there.
               (
                select /*+ index(ee pay_element_entries_f_n51) */ null
                from   pay_element_entries_f ee,
                       pay_element_types_f et
                where  ee.element_type_id = et.element_type_id
                  and  et.processing_type = 'R'
                  and  ee.entry_type = 'E'
		  and  ee.creator_type = 'SP'
                  and  ee.assignment_id = p_assignment_id
                  and  ee.element_link_id = el.element_link_id
                  and  ee.effective_end_date >= p_val_start_date_minus_one)) /*Bug 8773398 changed p_validation_start_date to p_val_start_date_minus_one*/

          -- start of change 115.16 --
          -- Ensure this non-standard link has not been changed from/to a standard link
          and NOT EXISTS
                (SELECT null
                 FROM   PAY_ELEMENT_LINKS_F el_sub
                 WHERE  el_sub.element_link_id = el.element_link_id
                 and    el_sub.standard_link_flag = 'Y'
                )
          -- end of change 115.16 --
))
-- Change 115.60
     -- Bugfix 2121907
     -- Ensure no entries exist for this element link and assignment
     and  not exists (
            select null
            from   pay_element_entries_f ee
            where  ee.assignment_id = p_assignment_id
            and    ee.element_link_id = el.element_link_id
            and    ee.effective_start_date <= p_validation_end_date
            and    ee.effective_end_date >= p_validation_start_date
            and    p_dt_mode in
                     ('UPDATE','CORRECTION','UPDATE_CHANGE_INSERT'))
-- End of change 115.60
   group by el.element_link_id,
            el.link_to_all_payrolls_flag,
            el.payroll_id,
            el.job_id,
            el.grade_id,
            el.position_id,
            el.organization_id,
            el.location_id,
            el.pay_basis_id,
            el.employment_category,
            el.people_group_id,
            el.element_type_id,
            el.standard_link_flag
;
 --
 -- Finds all assignment pieces that match the element link eg.
 --
 -- EL   |-----------------------------A------------------------------>
 --
 -- ASG       |---A----|----A----|-----B-----|-----A------|-----A----->
 --
 -- pieces    |--------|---------|           |------------|----------->
 --
 -- These pieces can then be assembled into possible element entries that
 -- need to be created ie.
 --
 -- EE        |------------------|
 --
 -- EE                                       |------------------------>
 --
 -- also see bugs 2167881 and 2610904.
 cursor csr_assignment
        (
         p_element_link_id           number,
         p_link_start_date              date,
         p_link_end_date                date,
         p_assignment_id             number,
         p_val_start_date_minus_one  date,
         p_val_end_date_plus_one     date,
         p_payroll_id                number,
         p_link_to_all_payrolls_flag varchar2,
         p_job_id                    number,
         p_grade_id                  number,
         p_position_id               number,
         p_organization_id           number,
         p_location_id               number,
         p_pay_basis_id              number,
         p_employment_category       varchar2,
         p_people_group_id           number
        ) is
   select asg.effective_start_date,
          asg.effective_end_date
   from   per_all_assignments_f asg
   where  asg.assignment_id = p_assignment_id
     and  asg.assignment_type = 'E'
     and  asg.effective_start_date <= p_val_end_date_plus_one
     and  asg.effective_end_date   >= p_val_start_date_minus_one
     and  asg.effective_start_date <= p_link_end_date
     and  asg.effective_end_date >= p_link_start_date
     and  ((p_payroll_id is not null and
            p_payroll_id = asg.payroll_id)
      or   (p_link_to_all_payrolls_flag = 'Y' and
            asg.payroll_id is not null)
      or   (p_link_to_all_payrolls_flag = 'N' and
            p_payroll_id is null))
     and  (p_job_id is null or
           p_job_id = asg.job_id)
     and  (p_grade_id is null or
           p_grade_id = asg.grade_id)
     and  (p_position_id is null or
           p_position_id = asg.position_id)
     and  (p_organization_id is null or
           p_organization_id = asg.organization_id)
     and  (p_location_id is null or
           p_location_id = asg.location_id)
     and  (
            --
            -- null passed down from EL,
            -- if EL is NOT associated with a pay basis then return true
            --
            p_pay_basis_id is null and
            NOT EXISTS
                (SELECT /*+ ORDERED INDEX(pb PER_PAY_BASES_N1)*/
                        pb.pay_basis_id
                 FROM   PAY_ELEMENT_LINKS_F el,
                        PAY_INPUT_VALUES_F  iv,
                        PER_PAY_BASES       pb
                 WHERE  el.element_link_id = p_element_link_id
                 and    el.effective_start_date <= asg.effective_start_date
                 and    el.effective_end_date   >= asg.effective_start_date
                 and    iv.element_type_id =
                                           el.element_type_id
                 and    iv.effective_start_date <= el.effective_start_date
                 and    iv.effective_end_date   >= el.effective_start_date
                 and    pb.input_value_id =
                                          iv.input_value_id
                 and    pb.business_group_id = asg.business_group_id
                )
            or
            --
            -- null passed down from EL,
            -- if EL is associated with a pay basis then the associated PB_ID
            -- must match the PB_ID on ASG
            --
            p_pay_basis_id is null and
            EXISTS
                (SELECT pb.pay_basis_id
                 FROM   PER_PAY_BASES       pb,
                        PAY_INPUT_VALUES_F  iv,
                        PAY_ELEMENT_LINKS_F el
                 WHERE  el.element_link_id = p_element_link_id
                 and    el.effective_start_date <= asg.effective_start_date
                 and    el.effective_end_date   >= asg.effective_start_date
                 and    iv.element_type_id =
                                           el.element_type_id
                 and    iv.effective_start_date <= el.effective_start_date
                 and    iv.effective_end_date   >= el.effective_start_date
                 and    pb.input_value_id =
                                          iv.input_value_id
                 and    pb.pay_basis_id = asg.pay_basis_id
                )
-- change 115.26
            or
            p_pay_basis_id is null and
            asg.pay_basis_id is null and
            EXISTS
                (SELECT /*+ ORDERED INDEX(pb PER_PAY_BASES_N1)*/
                        pb.pay_basis_id
                 FROM   PAY_ELEMENT_LINKS_F el,
                        PAY_INPUT_VALUES_F  iv,
                        PER_PAY_BASES       pb
                 WHERE  el.element_link_id = p_element_link_id
                 and    el.effective_start_date <= asg.effective_start_date
                 and    el.effective_end_date   >= asg.effective_start_date
                 and    iv.element_type_id =
                                           el.element_type_id
                 and    iv.effective_start_date <= el.effective_start_date
                 and    iv.effective_end_date   >= el.effective_start_date
                 and    pb.input_value_id =
                                          iv.input_value_id
                 and    pb.business_group_id = asg.business_group_id
                )
            or
            p_pay_basis_id = asg.pay_basis_id
          )
     and  (p_employment_category is null or
           p_employment_category = asg.employment_category)
     and  (p_people_group_id is null or
           exists
             (select null
              from   pay_assignment_link_usages_f alu
              where  alu.assignment_id = p_assignment_id
                and  alu.element_link_id = p_element_link_id
                and  alu.effective_start_date <= asg.effective_end_date
                and  alu.effective_end_date   >= asg.effective_start_date))
    order by asg.effective_start_date
    for update;
  --
  -- Local Variables
  --
  v_mult_ent_allowed_flag    varchar2(30);
  v_assignment               t_asg_rec;
  v_asg_start_date           date;
  v_asg_end_date             date;
  v_entry_start_date         date;
  v_entry_end_date           date;
  v_val_start_date_minus_one date;
  v_val_end_date_plus_one    date;
  v_entry_count              number := 0;
  v_entry_start_date_tbl     hrentmnt.t_date_table;
  v_entry_end_date_tbl       hrentmnt.t_date_table;
  v_message_name             varchar2(30);
  v_appl_short_name          varchar2(30);
  l_proc constant varchar2 (72) := g_package||'adjust_entries_asg_criteria';
  --
procedure check_parameters is
        --
        begin
        --
        hr_utility.trace('In '||l_proc);
        hr_utility.trace ('');
        hr_utility.trace ('     p_business_group_id = '
                ||to_char (p_business_group_id));
                --
        hr_utility.trace ('     p_assignment_id = '
                ||to_char (p_assignment_id));
                --
        hr_utility.trace ('     p_dt_mode = '
                ||p_dt_mode);
                --
        hr_utility.trace ('     p_old_payroll_id = '
                ||to_char (p_old_payroll_id));
                --
        hr_utility.trace ('     p_new_payroll_id = '
                ||to_char (p_new_payroll_id));
                --
        hr_utility.trace ('     p_validation_start_date = '
                ||to_char (p_validation_start_date));
                --
        hr_utility.trace ('     p_validation_end_date = '
                ||to_char (p_validation_end_date));
                --
        hr_utility.trace ('     p_entries_changed = '
                ||p_entries_changed);
                --
        hr_utility.trace ('     p_old_hire_date = '
                ||to_char(p_old_hire_date));
                --
        hr_utility.trace ('     p_old_people_group_id = '
                ||to_char(p_old_people_group_id));
                --
        hr_utility.trace ('     p_new_people_group_id = '
                ||to_char(p_new_people_group_id));
                --
        hr_utility.trace ('');
        --
        end check_parameters;
        --
begin
  --
  if g_debug then
     check_parameters;
  end if;
  --
  if p_validation_start_date = hr_general.start_of_time then
    v_val_start_date_minus_one := hr_general.start_of_time;
  else
    v_val_start_date_minus_one := p_validation_start_date -1;
  end if;
  --
  if p_validation_end_date = hr_general.end_of_time then
    v_val_end_date_plus_one := hr_general.end_of_time;
  else
    v_val_end_date_plus_one := p_validation_end_date +1;
  end if;
  --
  -- Maintain assignment link usages for the assignment.
  --
  hrentmnt.maintain_alu_asg (p_assignment_id,
                             p_business_group_id,
                             p_dt_mode,
                             p_old_people_group_id,
                             p_new_people_group_id);
  --
  -- Make sure there are no nonrecurring entries that have been made
  -- invalid by a change in assignment criteria.
  --
  hrentmnt.val_nonrec_entries ( p_assignment_id,
                                        p_validation_start_date,
                                        p_validation_end_date,
					p_entries_changed);
  --
  -- Remove any nonrecurring entries which are no longer valid.
  --
  hrentmnt.remove_ineligible_nonrecurring (     p_assignment_id,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                p_entries_changed);
  --
  -- Only adjust nonrecurring entries when there has been a change of payroll
  --
  if (p_old_payroll_id <> p_new_payroll_id
      and p_dt_mode in (        'UPDATE',
                                'UPDATE_CHANGE_INSERT',
                                'UPDATE_OVERRIDE',
                                'CORRECTION') )
        --
  or p_dt_mode in (     'DELETE',
                        'FUTURE_CHANGE',
                        'DELETE_NEXT_CHANGE')
  then
    --
    -- Adjust any nonrecurring entries which have been affected by a change
    -- of payroll.
    --
    hrentmnt.adjust_nonrecurring_entries (      p_assignment_id,
                                                v_val_start_date_minus_one,
                                                v_val_end_date_plus_one,
                                                p_entries_changed,
						p_dt_mode);
    --
    -- Check for element entries which have more than one adjustments
    -- in the same pay period.
    -- Fix for bug 8419416
    hrentmnt.validate_adjustment_entries ( p_new_payroll_id,
                                           p_assignment_id,
                                           v_val_start_date_minus_one);
    --
  end if;
  --
  -- Remove any recurring entries that are no longer eligible NB. this makes
  -- the adjustment of entries easier.
  --
  hrentmnt.remove_ineligible_recurring(p_assignment_id, p_entries_changed,p_validation_start_date,p_validation_end_date,p_dt_mode);
  --
  -- By this stage, all that should be left to do is to adjust the dates of
  -- any entries which cross the boundary of the criteria change and to insert
  -- any standard entries for which the assignment is eligible as a result of
  -- the change.
  --
  -- Find all links that are either standard links or links for which the
  -- assignment already has recurring entries.
  --
  for v_link in csr_link (      p_business_group_id,
                                p_assignment_id,
                                p_validation_start_date,
                                p_validation_end_date,
                                v_val_start_date_minus_one,
                                v_val_end_date_plus_one)
  LOOP
    --
    -- No links match the assignment so stop processing.
    --
    if v_link.element_link_id is null then
      exit;
    end if;
    --
    open csr_assignment (       v_link.element_link_id,
                                v_link.effective_start_date,
                                v_link.effective_end_date,
                                p_assignment_id,
                                v_val_start_date_minus_one,
                                v_val_end_date_plus_one,
                                v_link.payroll_id,
                                v_link.link_to_all_payrolls_flag,
                                v_link.job_id,
                                v_link.grade_id,
                                v_link.position_id,
                                v_link.organization_id,
                                v_link.location_id,
                                v_link.pay_basis_id,
                                v_link.employment_category,
                                v_link.people_group_id);
    --
    -- Get first assignment piece matching the standard link.
    --
    fetch csr_assignment into v_assignment;
    --
    -- Assignment matching standard link has been found.
    --
    if csr_assignment%found then
      --
      v_asg_start_date := v_assignment.effective_start_date;
      v_asg_end_date   := v_assignment.effective_end_date;
      --
      -- Loop for all assignment pieces that match the standard link.
      --
      while csr_assignment%found loop
        --
        -- Get next piece of assignment.
        --
        fetch csr_assignment into v_assignment;
        --
        -- No more Assignment pieces exist or piece is is not contiguous with
        -- the previous piece of assignment.
        --
        if csr_assignment%notfound
         or v_assignment.effective_start_date <> v_asg_end_date + 1
         then
          --
          -- Calculate the element entry dates NB. need to check to see if the
          -- element entry cannot be created because the assignment has been
          -- terminated in the future and the end date according to the
          -- termination rule is before the calculated start date of the
          -- element entry. This should not stop other entries being created !
          --
           begin
             --
            hrentmnt.return_entry_dates (p_assignment_id,
                                         v_asg_start_date,
                                         v_link.element_link_id,
                                         v_link.effective_start_date,
                                         v_link.standard_link_flag,
                                         v_entry_start_date,
                                         v_entry_end_date);
             --
          exception
             --
             when hr_utility.hr_error then
               --
               hr_utility.get_message_details(v_message_name,v_appl_short_name);
               --
              if v_message_name = 'HR_6370_ELE_ENTRY_NO_TERM' then
                 --
                 v_entry_start_date := null;
                v_message_name     := null;
                v_appl_short_name  := null;
                 --
              else
                 --
                raise;
                 --
              end if;
               --
          end;
          --
          -- Bug 2950302 : remove restriction on putting details of
          -- entry into array when assignment has been terminated,
          -- as originally introduced for bugs 425686 and 476600.
          --
          -- Put details of entry into array for subsequent processing.
          --
          v_entry_count                         := v_entry_count + 1;
          v_entry_start_date_tbl(v_entry_count) := v_entry_start_date;
          v_entry_end_date_tbl(v_entry_count)   := v_entry_end_date;
          --
          --
          -- Reset the variables to the effective dates of the new assignment.
          --
          v_asg_start_date := v_assignment.effective_start_date;
          v_asg_end_date   := v_assignment.effective_end_date;
        --
        -- Assignment piece is for the same assignment as the previous piece
        -- and it is contiguous with the previous piece.
        --
        else
          --
          -- Increment the end date of the assignment.
          --
          v_asg_end_date := v_assignment.effective_end_date;
          --
        end if;
        --
      end loop;
      --
      -- Have found some entries which may need changing.
      --
      if v_entry_count > 0 then
        --
        -- Compare the calculated element entries with those on the system
         -- and adjust as necessary.
        --
        if g_debug then
        hr_utility.trace('v_entry_count : ' || v_entry_count);
        end if;
        --
        -- See if multiple entries are allowed.
        --
        v_mult_ent_allowed_flag := hrentmnt.mult_ent_allowed_flag
                                                    (v_link.element_link_id);
        --
        hrentmnt.adjust_recurring_entries (     p_dt_mode,
                                                p_assignment_id,
                                                v_link.element_link_id,
                                                v_link.standard_link_flag,
                                                v_mult_ent_allowed_flag,
                                                p_validation_start_date,
                                                p_validation_end_date,
                                                v_val_start_date_minus_one,
                                                v_val_end_date_plus_one,
                                                v_entry_count,
                                                v_entry_start_date_tbl,
                                                v_entry_end_date_tbl,
                                                p_entries_changed,
                                                p_old_hire_date);
        --
        -- Reset the number of entries found.
        --
        v_entry_count := 0;
        --
      end if;
      --
    end if;
    --
    close csr_assignment;
    --
  end loop;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.adjust_entries_asg_criteria');
  end if;
  --
end adjust_entries_asg_criteria;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.maintain_entries_el                                             --
--                                                                          --
-- DESCRIPTION                                                              --
-- Creates element entries on creation of a standard element link.          --
-- If p_assignment_id is specified, the element entry is created only for   --
-- the assignment. By default all of the eligible assignments will be       --
-- processed.                                                               --
------------------------------------------------------------------------------
--
procedure maintain_entries_el
(
 p_business_group_id         number,
 p_element_link_id           number,
 p_element_type_id           number,
 p_effective_start_date      date,
 p_effective_end_date        date,
 p_payroll_id                number,
 p_link_to_all_payrolls_flag varchar2,
 p_job_id                    number,
 p_grade_id                  number,
 p_position_id               number,
 p_organization_id           number,
 p_location_id               number,
 p_pay_basis_id              number,
 p_employment_category       varchar2,
 p_people_group_id           number,
 p_assignment_id             number default null
) is
 --
 -- Finds all assignment pieces that match the standard element link eg.
 --
 -- EL   |-----------------------------A------------------------------>
 --
 -- ASG       |---A----|----A----|-----B-----|-----A------|-----A----->
 --
 -- pieces    |--------|---------|           |------------|----------->
 --
 -- These pieces can then be assembled into possible element entries that
 -- need to be created ie.
 --
 -- EE        |------------------|
 --
 -- EE                                       |------------------------>
 --
 type t_asg_rec is record
                    (assignment_id        number,
                     effective_start_date date,
                     effective_end_date   date);
 type cursor_type is ref cursor;
  --
  -- performance fix on cursor csr_assignment to split it based on assignment_id - bug 9167393
  --
 csr_assignment cursor_type;
  --
  -- Check if the assignment is visible with the secure view. Bug 5512101.
  --
  cursor csr_sec_asg(p_asgid number)
  is
  select 1
  from per_assignments_f
  where assignment_id = p_asgid;

  --
  -- local variables
  --
  v_assignment         t_asg_rec;
  v_asg_id             number;
  v_asg_start_date     date;
  v_asg_end_date       date;
  v_entry_start_date   date;
  v_entry_end_date     date;
  v_dummy_number       number;
  v_num_entry_values   number;
  v_input_value_id_tbl hr_entry.number_table;
  v_entry_value_tbl    hr_entry.varchar2_table;
  v_message_name       varchar2(30);
  v_appl_short_name    varchar2(30);
  v_asg_visible        number;
-- bugfix 1691062
l_category fnd_descr_flex_contexts.descriptive_flex_context_code%type;
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace ('hrentmnt.maintain_entries_el');
                hr_utility.trace ('');
                hr_utility.trace ('     p_business_group_id = '
                        ||to_char (p_business_group_id));
                hr_utility.trace ('     p_element_link_id = '
                        ||to_char (p_element_link_id));
                hr_utility.trace ('     p_element_type_id = '
                        ||to_char (p_element_type_id));
                hr_utility.trace ('     p_effective_start_date = '
                        ||to_char (p_effective_start_date));
                hr_utility.trace ('     p_effective_end_date = '
                        ||to_char (p_effective_end_date));
                hr_utility.trace ('     p_payroll_id = '
                        ||to_char (p_payroll_id));
                hr_utility.trace ('     p_link_to_all_payrolls_flag = '
                        ||p_link_to_all_payrolls_flag);
                hr_utility.trace ('     p_job_id = '
                        ||to_char (p_job_id));
                hr_utility.trace ('     p_grade_id = '
                        ||to_char (p_grade_id));
                hr_utility.trace ('     p_position_id = '
                        ||to_char (p_position_id));
                hr_utility.trace ('     p_organization_id = '
                        ||to_char (p_organization_id));
                hr_utility.trace ('     p_location_id = '
                        ||to_char (p_location_id));
                hr_utility.trace ('     p_pay_basis_id = '
                        ||to_char (p_pay_basis_id));
                hr_utility.trace ('     p_employment_category = '
                        ||p_employment_category);
                hr_utility.trace ('     p_people_group_id = '
                        ||to_char (p_people_group_id));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- Open assignment cursor ready for processing.
  --
  begin
    -- performance fix on cursor csr_assignment to split it based on assignment_id - bug 9167393
    if p_assignment_id is not null then
        open csr_assignment for
        select asg.assignment_id,
               asg.effective_start_date,
               asg.effective_end_date
        from   per_all_assignments_f asg
        where  asg.assignment_id = p_assignment_id
          and  asg.assignment_type = 'E'
          and  asg.effective_start_date <= p_effective_end_date
          and  asg.effective_end_date   >= p_effective_start_date
          and  ((p_payroll_id is not null and
                 p_payroll_id = asg.payroll_id)
           or   (p_link_to_all_payrolls_flag = 'Y' and
                 asg.payroll_id is not null)
           or   (p_link_to_all_payrolls_flag = 'N' and
                 p_payroll_id is null))
          and  (p_job_id is null or
                p_job_id = asg.job_id)
          and  (p_grade_id is null or
                p_grade_id = asg.grade_id)
          and  (p_position_id is null or
                p_position_id = asg.position_id)
          and  (p_organization_id is null or
                p_organization_id = asg.organization_id)
          and  (p_location_id is null or
                p_location_id = asg.location_id)
          and  (p_employment_category is null or
                p_employment_category = asg.employment_category)
          and  (p_people_group_id is null or
                exists
                  (select null
                   from   pay_assignment_link_usages_f alu
                   where  alu.assignment_id = asg.assignment_id
                     and  alu.element_link_id = p_element_link_id
                     and  alu.effective_start_date <= asg.effective_end_date
                     and  alu.effective_end_date   >= asg.effective_start_date))
          and  (p_pay_basis_id = asg.pay_basis_id
                or (p_pay_basis_id is null and
                     (asg.pay_basis_id is null
                     -- Indirect salary basis check.
                      or not exists
                          (select pb.pay_basis_id
                           from   per_pay_bases      pb,
                                  pay_input_values_f iv
                           where  iv.element_type_id = p_element_type_id
                           and    pb.input_value_id = iv.input_value_id
                           and    pb.business_group_id = p_business_group_id
                          )
                      or exists
                          (select pb.pay_basis_id
                           from   per_pay_bases      pb,
                                  pay_input_values_f iv
                           where  iv.element_type_id = p_element_type_id
                           and    pb.input_value_id = iv.input_value_id
                           and    pb.pay_basis_id = asg.pay_basis_id
                          )
                     )
                   )
               )
          --
          -- ensure no entries exist for the assignment
          --
          and  not exists
                 (select null from pay_element_entries_f pee
                  where pee.assignment_id = asg.assignment_id
                  and   pee.element_link_id = p_element_link_id
                 )
        order by asg.assignment_id, asg.effective_start_date
        for update nowait;
    else
        open csr_assignment for
        select asg.assignment_id,
               asg.effective_start_date,
               asg.effective_end_date
        from   per_all_assignments_f asg
        where asg.business_group_id = p_business_group_id
          and  asg.assignment_type = 'E'
          and  asg.effective_start_date <= p_effective_end_date
          and  asg.effective_end_date   >= p_effective_start_date
          and  ((p_payroll_id is not null and
                 p_payroll_id = asg.payroll_id)
           or   (p_link_to_all_payrolls_flag = 'Y' and
                 asg.payroll_id is not null)
           or   (p_link_to_all_payrolls_flag = 'N' and
                 p_payroll_id is null))
          and  (p_job_id is null or
                p_job_id = asg.job_id)
          and  (p_grade_id is null or
                p_grade_id = asg.grade_id)
          and  (p_position_id is null or
                p_position_id = asg.position_id)
          and  (p_organization_id is null or
                p_organization_id = asg.organization_id)
          and  (p_location_id is null or
                p_location_id = asg.location_id)
          and  (p_employment_category is null or
                p_employment_category = asg.employment_category)
          and  (p_people_group_id is null or
                exists
                  (select null
                   from   pay_assignment_link_usages_f alu
                   where  alu.assignment_id = asg.assignment_id
                     and  alu.element_link_id = p_element_link_id
                     and  alu.effective_start_date <= asg.effective_end_date
                     and  alu.effective_end_date   >= asg.effective_start_date))
          and  (p_pay_basis_id = asg.pay_basis_id
                or (p_pay_basis_id is null and
                     (asg.pay_basis_id is null
                     -- Indirect salary basis check.
                      or not exists
                          (select pb.pay_basis_id
                           from   per_pay_bases      pb,
                                  pay_input_values_f iv
                           where  iv.element_type_id = p_element_type_id
                           and    pb.input_value_id = iv.input_value_id
                           and    pb.business_group_id = p_business_group_id
                          )
                      or exists
                          (select pb.pay_basis_id
                           from   per_pay_bases      pb,
                                  pay_input_values_f iv
                           where  iv.element_type_id = p_element_type_id
                           and    pb.input_value_id = iv.input_value_id
                           and    pb.pay_basis_id = asg.pay_basis_id
                          )
                     )
                   )
               )
          --
          -- ensure no entries exist for the assignment
          --
          and  not exists
                 (select null from pay_element_entries_f pee
                  where pee.assignment_id = asg.assignment_id
                  and   pee.element_link_id = p_element_link_id
                 )
        order by asg.assignment_id, asg.effective_start_date
        for update nowait;
    end if;
  exception
    when hr_api.object_locked then
        --
        -- Failed to lock the assignment.
        --
        hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
        hr_utility.set_message_token('TABLE_NAME', 'per_all_assignments_f');
        hr_utility.raise_error;
  end;
  --
  -- Get first assignment piece matching the standard link.
  --
  fetch csr_assignment into v_assignment;
  --
  -- Assignment matching standard link has been found.
  --
  if csr_assignment%found then
    --
    -- Initialise variables for the assignment.
    --
    v_asg_id         := v_assignment.assignment_id;
    v_asg_start_date := v_assignment.effective_start_date;
    v_asg_end_date   := v_assignment.effective_end_date;
    --
    -- Check to see if this assignment is visible to a secure user.
    -- Bug 5512101.
    --
    open csr_sec_asg(v_asg_id);
    fetch csr_sec_asg into v_asg_visible;
    if csr_sec_asg%notfound then
      --
      if g_debug then
        hr_utility.trace('Assignment ID Not Found: '||v_asg_id);
      end if;
      --
      -- The user is not authorized to process this assignment.
      --
      close csr_sec_asg;
      close csr_assignment;
      --
      hr_utility.set_message(801,'PAY_33449_STD_LINK_SEC_ASG');
      hr_utility.raise_error;
    end if;
    close csr_sec_asg;

    --
    -- Loop for all assignment pieces that match the standard link.
    --
    while csr_assignment%found loop
      --
      -- Get next piece of assignment.
      --
      fetch csr_assignment into v_assignment;
      --
      -- Assignment piece is not for the same assignment previously found or
      -- it is but is is not contiguous with the previous pice of assignment.
      --
      if csr_assignment%notfound or not
          (v_assignment.assignment_id = v_asg_id and
           v_assignment.effective_start_date = v_asg_end_date + 1) then
        --
        -- Calculate the element entry dates NB. need to check to see if the
        -- element entry cannot be created because the assignment has been
        -- terminated in the future and the end date according to the
        -- termination rule is before the calculated start date of the element
        -- entry. This should not stop other entries being created !
        --
         begin
          hrentmnt.return_entry_dates
            (v_asg_id,
              v_asg_start_date,
             p_element_link_id,
             p_effective_start_date,
              'Y',
             v_entry_start_date,
             v_entry_end_date);
        exception
           when hr_utility.hr_error then
             hr_utility.get_message_details(v_message_name,v_appl_short_name);
            if v_message_name = 'HR_6370_ELE_ENTRY_NO_TERM' then
              v_entry_start_date := null;
              v_message_name     := null;
              v_appl_short_name  := null;
            else
              raise;
            end if;
        end;
        --
        -- An element entry needs to be created.
        --
         if v_entry_start_date is not null then
          --
          -- Create new element netry for standard link.
          --
          if g_debug then
             hr_utility.trace('********** SL creation');
             hr_utility.trace('********** for SL call EE insert interface');
          end if;
          hr_entry_api.insert_element_entry
            (p_effective_start_date => v_entry_start_date,
             p_effective_end_date   => v_entry_end_date,
             p_element_entry_id     => v_dummy_number,
             p_assignment_id        => v_asg_id,
             p_element_link_id      => p_element_link_id,
             p_creator_type         => 'F',
             p_entry_type           => 'E');

-- bugfix 1691062
l_category := get_entry_info_category(v_asg_id,
                                        v_entry_start_date,
                                        p_element_link_id);
if l_category is not null then
      if g_debug then
         hr_utility.trace('********** SL creation');
         hr_utility.trace('********** l_category>' || l_category || '<');
      end if;

      UPDATE pay_element_entries_f
      SET    entry_information_category = l_category
      WHERE  element_entry_id = v_dummy_number;
end if;

         end if;
        --
        -- Reset the variables to the effective dates of the new assignment.
        --
        v_asg_start_date := v_assignment.effective_start_date;
        v_asg_end_date   := v_assignment.effective_end_date;
      --
      -- Assignment piece is for the same assignment as the previous piece
      -- and it is contiguous with the previous piece.
      --
      else
        --
        -- Increment the end date of the assignment.
        --
        v_asg_end_date := v_assignment.effective_end_date;
        --
      end if;
      --
      -- Keep track of the current assignment being processed.
      --
      v_asg_id := v_assignment.assignment_id;
      --
    end loop;
    --
  end if;
  --
  -- Close assignment cursor as all assignments have been processed.
  --
  close csr_assignment;
  --
if g_debug then
   hr_utility.trace ('Out hrentmnt.maintain_entries_el');
end if;
--
end maintain_entries_el;
--
--
--
procedure dump_info(p_assignment_id     in number,
                    p_business_group_id in number)
is
    cursor csr_assignment(b_assignment_id     number,
                          b_business_group_id number) is
        SELECT  asg.assignment_id,
                asg.effective_start_date,
                asg.effective_end_date,
                asg.primary_flag,
                --
                -- begin criteria used for EL matching
                --
                asg.organization_id,
                asg.people_group_id,
                asg.job_id,
                asg.position_id,
                asg.grade_id,
                asg.location_id,
                asg.employment_category,
                asg.payroll_id,
                asg.pay_basis_id
                --
                -- end criteria used for EL matching
                --
        FROM    PER_ALL_ASSIGNMENTS_F asg
        WHERE   asg.assignment_id = b_assignment_id
        and     asg.business_group_id = b_business_group_id
        ORDER BY
                asg.assignment_id,
                asg.effective_start_date
        ;

        cursor ee is
        select distinct
               pee.element_entry_id,
               pee.entry_type,
               pee.creator_type,
               to_char(pee.effective_start_date, 'YYYY/MM/DD') esd,
               to_char(pee.effective_end_date, 'YYYY/MM/DD') eed,
               pel.element_link_id,
               pel.element_type_id,
               pel.payroll_id,
               pel.job_id,
               pel.position_id,
               pel.people_group_id,
               pel.organization_id,
               pel.location_id,
               pel.grade_id,
               pel.pay_basis_id,
               pel.link_to_all_payrolls_flag,
               pel.standard_link_flag
        from   pay_element_entries_f pee,
               pay_element_links_f  pel
        where  pee.assignment_id   = p_assignment_id
        and    pel.element_link_id = pee.element_link_id;

begin
    hr_utility.trace('***** dump start *****');

    for rec_assignment in csr_assignment(p_assignment_id,
                                         p_business_group_id) loop
        hr_utility.trace('rec_assignment.assignment_id>' ||
                          rec_assignment.assignment_id   || '<');
        hr_utility.trace('  rec_assignment.effective_start_date>' ||
                            rec_assignment.effective_start_date   || '<');
        hr_utility.trace('  rec_assignment.effective_end_date>' ||
                            rec_assignment.effective_end_date   || '<');
        hr_utility.trace('  rec_assignment.primary_flag>' ||
                            rec_assignment.primary_flag   || '<');
        hr_utility.trace('  rec_assignment.organization_id>' ||
                            rec_assignment.organization_id   || '<');
        hr_utility.trace('  rec_assignment.people_group_id>' ||
                            rec_assignment.people_group_id   || '<');
        hr_utility.trace('  rec_assignment.job_id>' ||
                            rec_assignment.job_id   || '<');
        hr_utility.trace('  rec_assignment.position_id>' ||
                            rec_assignment.position_id   || '<');
        hr_utility.trace('  rec_assignment.grade_id>' ||
                            rec_assignment.grade_id   || '<');
        hr_utility.trace('  rec_assignment.location_id>' ||
                            rec_assignment.location_id   || '<');
        hr_utility.trace('  rec_assignment.employment_category>' ||
                            rec_assignment.employment_category   || '<');
        hr_utility.trace('  rec_assignment.payroll_id>' ||
                            rec_assignment.payroll_id   || '<');
        hr_utility.trace('  rec_assignment.pay_basis_id>' ||
                            rec_assignment.pay_basis_id   || '<');
    end loop;

    hr_utility.trace('>>> Element Entry info <<<');
    hr_utility.trace('EEID ET CT ESD EED ELID ETID PYID JOB POS PGRP ORG LOC GRD PBID LFLG SLFLG');

    for eerec in ee loop

      hr_utility.trace(
         eerec.element_entry_id || ' ' ||
         eerec.entry_type || ' ' ||
         eerec.creator_type || ' ' ||
         eerec.esd || ' ' ||
         eerec.eed || ' ' ||
         eerec.element_link_id || ' ' ||
         eerec.element_type_id || ' ' ||
         nvl(to_char(eerec.payroll_id), '*') || ' ' ||
         nvl(to_char(eerec.job_id), '*') || ' ' ||
         nvl(to_char(eerec.position_id), '*') || ' ' ||
         nvl(to_char(eerec.people_group_id), '*') || ' ' ||
         nvl(to_char(eerec.organization_id), '*') || ' ' ||
         nvl(to_char(eerec.location_id), '*') || ' ' ||
         nvl(to_char(eerec.grade_id), '*') || ' ' ||
         nvl(to_char(eerec.pay_basis_id), '*') || ' ' ||
         eerec.link_to_all_payrolls_flag || ' ' ||
         eerec.standard_link_flag);

    end loop;

    hr_utility.trace('***** dump end *****');
end dump_info;
--
--
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.maintain_entries_asg                                            --
--                                                                          --
-- DESCRIPTION                                                              --
-- This forms the interface into the procedures that maintain element       --
-- entries when affected by various events ie.                              --
--                                                                          --
-- CHANGE_PQC   : changes in personal qualifying conditions.                --
-- CNCL_TERM    : a termination is cancelled.                               --
-- CNCL_HIRE    : the hiring of a person is cancelled.                      --
-- ASG_CRITERIA : assignment criteria has chnaged.                          --
-- HIRE_APPL    : an applicant is hired.                                    --
------------------------------------------------------------------------------
--
procedure maintain_entries_asg
(
 p_assignment_id         number,
 p_old_payroll_id        number,
 p_new_payroll_id        number,
 p_business_group_id     number,
 p_operation             varchar2,
 p_actual_term_date      date,
 p_last_standard_date    date,
 p_final_process_date    date,
 p_dt_mode               varchar2,
 p_validation_start_date date,
 p_validation_end_date   date,
 p_entries_changed       in out nocopy varchar2,
 p_old_hire_date         date default null,
 p_old_people_group_id   number default null,
 p_new_people_group_id   number default null
) is
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace('In hrentmnt.maintain_entries_asg');
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_old_payroll_id = '
                        ||to_char (p_old_payroll_id));
                hr_utility.trace ('     p_new_payroll_id = '
                        ||to_char (p_new_payroll_id));
                hr_utility.trace ('     p_business_group_id = '
                        ||to_char (p_business_group_id));
                hr_utility.trace ('     p_operation = '
                        ||p_operation);
                hr_utility.trace ('     p_actual_term_date = '
                        ||to_char (p_actual_term_date));
                hr_utility.trace ('     p_last_standard_date = '
                        ||to_char (p_last_standard_date));
                hr_utility.trace ('     p_final_process_date = '
                        ||to_char (p_final_process_date));
                hr_utility.trace ('     p_dt_mode = '
                        ||p_dt_mode);
                hr_utility.trace ('     p_validation_start_date = '
                        ||to_char (p_validation_start_date));
                hr_utility.trace ('     p_validation_end_date = '
                        ||to_char (p_validation_end_date));
                hr_utility.trace ('     p_entries_changed = '
                        ||p_entries_changed);
                hr_utility.trace ('     p_old_hire_date = '
                        ||to_char(p_old_hire_date));
                hr_utility.trace ('     p_old_people_group_id = '
                        ||to_char(p_old_people_group_id));
                hr_utility.trace ('     p_new_people_group_id = '
                        ||to_char(p_new_people_group_id));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  --
  null;
-- --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     check_parameters;
  end if;
  --
  p_entries_changed := null;
  --
  -- Qualifying conditions have changed.
  --
  if p_operation = 'CHANGE_PQC' then
    hrentmnt.adjust_entries_pqc
      (p_assignment_id,
        p_entries_changed);
  --
  -- An employee termination is being cancelled.
  --
  elsif p_operation = 'CNCL_TERM' then
    hrentmnt.adjust_entries_cncl_term
      (p_business_group_id,
       p_assignment_id,
       p_actual_term_date,
       p_last_standard_date,
       p_final_process_date,
        p_entries_changed,
        p_dt_mode,
        p_old_people_group_id,
        p_new_people_group_id);
  --
  -- The hiring of an employee has been cancelled.
  --
  elsif p_operation = 'CNCL_HIRE' then
    hrentmnt.adjust_entries_cncl_hire
      (p_business_group_id,
       p_assignment_id,
       p_validation_start_date,
       p_validation_end_date,
        p_entries_changed,
        p_dt_mode,
        p_old_people_group_id,
        p_new_people_group_id);
  --
  -- An employees assignment has been changed.
  --
  elsif p_operation ='ASG_CRITERIA' then
    hrentmnt.adjust_entries_asg_criteria
      (p_business_group_id,
       p_assignment_id,
        p_dt_mode,
        p_old_payroll_id,
        p_new_payroll_id,
       p_validation_start_date,
       p_validation_end_date,
        p_entries_changed,
        p_old_hire_date,
        p_old_people_group_id,
        p_new_people_group_id);
  --
  -- An applicant has been hired
  --
  elsif p_operation = 'HIRE_APPL' then
    --
    -- Bugfix 5182845
    -- We need to ensure that the ALUs are rebuilt, since ALUs are never
    -- maintained for applicants. Therefore, even if the old and new people
    -- group ids are the same, the ALUs won't have been built previously.
    -- In order to force a rebuild of the ALUs, the old and new people group
    -- ids must differ. We modify the old people group id to ensure this.
    -- The min value of the pay_people_groups_s sequence is 1, so setting
    -- p_old_people_group_id to 0 will guarantee the old and new people group
    -- ids will always differ.
    --
    hrentmnt.adjust_entries_asg_criteria
      (p_business_group_id,
       p_assignment_id,
       p_dt_mode,
       p_old_payroll_id,
       p_new_payroll_id,
       p_validation_start_date,
       p_validation_end_date,
       p_entries_changed,
       p_old_hire_date,
       0, -- p_old_new_people_group_id
       p_new_people_group_id);
  end if;
  --
  if g_debug then
     hr_utility.trace('Out hrentmnt.maintain_entries_asg');
  end if;
  --
exception
    when others then
        --
        -- if an error occurs, print the message and raise the error again
        if g_debug then

           hr_utility.trace('****************************************');
           hr_utility.trace('Sqlcode>' || Sqlcode || '<');
           hr_utility.trace('Sqlerrm>' || Sqlerrm || '<');
           hr_utility.trace('****************************************');

           dump_info(p_assignment_id, p_business_group_id);

        end if;
        raise;
end;
-- --
end maintain_entries_asg;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.maintain_entries_asg                                            --
--                                                                          --
-- DESCRIPTION                                                              --
-- Overloaded version to allow backward compatibility.                      --
------------------------------------------------------------------------------
--
procedure maintain_entries_asg
(
 p_assignment_id         number,
 p_business_group_id     number,
 p_operation             varchar2,
 p_actual_term_date      date,
 p_last_standard_date    date,
 p_final_process_date    date,
 p_dt_mode               varchar2,
 p_validation_start_date date,
 p_validation_end_date   date
) is
  --
  -- Local Variables
  --
  v_entries_changed varchar2(1);
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace ('In hrentmnt.maintain_entries_asg');
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_business_group_id = '
                        ||to_char (p_business_group_id));
                hr_utility.trace ('     p_operation = '
                        ||p_operation);
                hr_utility.trace ('     p_actual_term_date = '
                        ||to_char (p_actual_term_date));
                hr_utility.trace ('     p_last_standard_date = '
                        ||to_char (p_last_standard_date));
                hr_utility.trace ('     p_final_process_date = '
                        ||to_char (p_final_process_date));
                hr_utility.trace ('     p_dt_mode = '
                        ||p_dt_mode);
                hr_utility.trace ('     p_validation_start_date = '
                        ||to_char (p_validation_start_date));
                hr_utility.trace ('     p_validation_end_date = '
                        ||to_char (p_validation_end_date));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  null;
-- --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     check_parameters;
  end if;
  --
  hrentmnt.maintain_entries_asg
    (p_assignment_id,
     1,
     2,
     p_business_group_id,
     p_operation,
     p_actual_term_date,
     p_last_standard_date,
     p_final_process_date,
     p_dt_mode,
     p_validation_start_date,
     p_validation_end_date,
     v_entries_changed,
     null,  -- p_old_people_group_id
     null); -- p_new_people_group_id
  --
exception
    when others then
        --
        -- if an error occurs, print the message and raise the error again
        --
        if g_debug then
           hr_utility.trace('***** over');
           hr_utility.trace('Sqlcode>' || Sqlcode || '<');
           hr_utility.trace('Sqlerrm>' || Sqlerrm || '<');
           hr_utility.trace('*****');
        end if;
        raise;
end;
-- --
end maintain_entries_asg;
--
------------------------------------------------------------------------------
-- NAME                                                                     --
-- hrentmnt.check_opmu                                                      --
--                                                                          --
-- DESCRIPTION                                                              --
-- Ensures that on transfer of Payroll (on the Assignment) or when a change --
-- causes the Payroll to change in the future that Personal Payment Methods --
-- have corresponding Org Pay Methods that are used by the new Payroll.     --
-- i.e. that Personal Payment Methods are not invalidated.                  --
------------------------------------------------------------------------------
--
procedure check_opmu
(
 p_assignment_id         number,
 p_payroll_id            number,
 p_dt_mode               varchar2,
 p_validation_start_date date,
 p_validation_end_date   date
) is
  --
  cursor csr_personal_payment_methods
          (
           p_assignment_id         number,
           p_validation_start_date date,
           p_validation_end_date   date
          ) is
    select ppm.personal_payment_method_id,
           ppm.org_payment_method_id,
           greatest(ppm.effective_start_date,p_validation_start_date)
                                                     start_date,
           least(ppm.effective_end_date,p_validation_end_date) end_date
    from   pay_personal_payment_methods_f ppm
    where  ppm.assignment_id = p_assignment_id
      and  ppm.effective_start_date <= p_validation_end_date
      and  ppm.effective_end_date   >= p_validation_start_date;
  --
  -- Local Variables
  --
  no_opmu varchar2(1) := 'N';
  --
        procedure check_parameters is
                --
                begin
                --
                hr_utility.trace ('In hrentmnt.check_opmu');
                hr_utility.trace ('');
                hr_utility.trace ('     p_assignment_id = '
                        ||to_char (p_assignment_id));
                hr_utility.trace ('     p_payroll_id = '
                        ||to_char (p_payroll_id));
                hr_utility.trace ('     p_dt_mode = '
                        ||p_dt_mode);
                hr_utility.trace ('     p_validation_start_date = '
                        ||to_char (p_validation_start_date));
                hr_utility.trace ('     p_validation_end_date = '
                        ||to_char (p_validation_end_date));
                hr_utility.trace ('');
                --
                end check_parameters;
                --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     check_parameters;
  end if;
  --
  -- If the mode is DELETE or ZAP then merely check to see if there will be
  --  any PPMs left after the end date of the Assignment
  --
  if p_dt_mode = 'DELETE' or p_dt_mode = 'ZAP' then
    --
    begin
      select 'Y'
      into   no_opmu
      from   sys.dual
      where  exists
                (select null
                 from   pay_personal_payment_methods_f ppm
                 where  assignment_id = p_assignment_id
                   and  ppm.effective_end_date >= p_validation_start_date);
    exception
      when no_data_found then
         if g_debug then
            hr_utility.trace('No opmu for DELETE or ZAP mode');
         end if;
    end;
  --
  -- Otherwise check that the existing PPMs remain valid after the Transfer
  --
  elsif not p_dt_mode = 'INSERT' then
    --
    -- For each PPM for the Assignment that has any part of its life within the
    -- Assignment Validation Start Date and Validation End Date Range if the
    -- following statements returns 'Y' then ERROR because OPMUs are
    -- invalidated by the change of PAYROLL.
    --
    for v_ppm in csr_personal_payment_methods(p_assignment_id,
                                               p_validation_start_date,
                                               p_validation_end_date) loop
      --
      -- first ensure that there is a valid opmu on the start date of the ppm
      -- if there isn't then flag an error
      --
      begin
        select 'Y'
        into   no_opmu
        from   sys.dual
        where  not exists
                  (select null
                   from   pay_org_pay_method_usages_f opmu,
                          pay_payrolls_f p
                   where  v_ppm.start_date between opmu.effective_start_date
                                               and opmu.effective_end_date
                    and  opmu.org_payment_method_id =
                                                   v_ppm.org_payment_method_id
                     and  opmu.effective_start_date
                        between p.effective_start_date and p.effective_end_date
                    and  opmu.payroll_id = p.payroll_id
                     and  p.payroll_id  = p_payroll_id);
      exception
        when no_data_found then null;
      end;
      --
      if no_opmu = 'Y' then
         if g_debug then
            hr_utility.trace('No opmu from first check.');
         end if;
         exit;
      end if;
      --
      -- Now ensure that there is a valid OPMU for the lifetime of the PPM.
      -- For each OPMU that is valid ensure that if it ends before the end of
      -- the PPM then there is at least one other OPMU that is valid on the day
      -- after the end date of the OPMU currently being considered. If there is
      -- no such OPMU then an error is flagged.
      --
      begin
        select 'Y'
        into   no_opmu
        from   sys.dual
        where  exists
                 (select null
                  from   pay_org_pay_method_usages_f opmu,
                         pay_payrolls_f p
                  where  opmu.effective_start_date <= v_ppm.end_date
                    and  opmu.effective_end_date >= v_ppm.start_date
                    and  opmu.org_payment_method_id =
                                                  v_ppm.org_payment_method_id
                    and  opmu.effective_start_date between
                              p.effective_start_date and p.effective_end_date
                    and  opmu.payroll_id = p.payroll_id
                    and  p.payroll_id = p_payroll_id
                    and  opmu.effective_end_date < v_ppm.end_date
                    and  not exists
                            (select null
                             from   pay_org_pay_method_usages_f opmu2,
                                    pay_payrolls_f p2
                             where  opmu2.effective_start_date <=
                                                 opmu.effective_end_date + 1
                               and  opmu2.effective_end_date >
                                                 opmu.effective_end_date
                              and  opmu2.org_payment_method_id =
                                                 v_ppm.org_payment_method_id
                               and  opmu2.payroll_id = p2.payroll_id
                               and  p2.payroll_id  = p_payroll_id
                               and  opmu2.effective_start_date between
                            p2.effective_start_date and p2.effective_end_date));
      exception
        when no_data_found then null;
      end;
      --
      if no_opmu = 'Y' then
         if g_debug then
            hr_utility.trace('No opmu from second check.');
         end if;
         exit;
      end if;
      --
    end loop;
    --
  end if;
  --
  if no_opmu = 'Y' then
    hr_utility.set_message(801,'HR_6844_ASS_PPM_INVALID');
    hr_utility.raise_error;
  end if;
  --
if g_debug then
   hr_utility.trace ('Out hrentmnt.check_opmu');
end if;
--
end check_opmu;
--

------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.move_fpd_entries                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- This procedure should be called from HR code to carry out entry changes  --
 -- when final process date is changed.                                      --
 ------------------------------------------------------------------------------

procedure move_fpd_entries
(
 p_assignment_id           in number
,p_period_of_service_id    in number
,p_new_final_process_date  in date
,p_old_final_process_date  in date
)
is
  l_session_date date;
  l_new_esd date;
  l_new_eed date;
  l_object_version_number number;
  l_warnings_exist boolean;
  l_new_final_process_date date;
  l_proc varchar2(80):= 'hrentmnt.move_fpd_entries';
  --
  cursor process_entries(c_old_final_process_date date, c_assignment_id number) is
  select asg.assignment_id,
    ee.element_entry_id,
    ee.element_link_id,
    ee.original_entry_id,
    ee.effective_start_date,
    ee.effective_end_date,
    ee.target_entry_id,
    ee.entry_type,
    ee.creator_type,
    et.processing_type,
    ee.updating_action_id,
    ee.updating_action_type,
    ee.object_version_number
  from per_all_assignments_f asg
     , pay_element_entries_f ee
     , pay_element_types_f et
  where  asg.assignment_id = c_assignment_id
  and asg.assignment_id = ee.assignment_id
  and ee.element_type_id = et.element_type_id
  and et.post_termination_rule = 'F'
  and c_old_final_process_date between ee.effective_start_date and ee.effective_end_date
  and c_old_final_process_date between et.effective_start_date and et.effective_end_date;

BEGIN
    hr_utility.set_location(l_proc, 10);

    SAVEPOINT move_fpd_entries;

    l_new_final_process_date := p_new_final_process_date;

    if l_new_final_process_date is null then
       l_new_final_process_date := hr_general.end_of_time;
    end if;


    -- Get all the entries of termination rule type F which could be affected by change in fpd.
    for r_entry in process_entries(p_old_final_process_date,p_assignment_id)
     loop
      --
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('EE processing type: '||r_entry.processing_type);
      hr_utility.trace('Old EE effective end date: '||to_char(r_entry.effective_end_date,'DD-MON-YYYY'));

      l_object_version_number := r_entry.object_version_number;
      l_new_esd := r_entry.effective_start_date;
      l_new_eed := r_entry.effective_end_date;
      l_session_date := least(r_entry.effective_end_date, l_new_final_process_date);

      if l_new_final_process_date < r_entry.effective_start_date then

	     /* Code to ZAP the element entry*/
	     hr_utility.set_location(l_proc,30);

	     pay_element_entry_api.delete_element_entry
              (p_validate                => false
              ,p_datetrack_delete_mode   => 'ZAP'
              ,p_effective_date          => l_session_date
              ,p_element_entry_id        => r_entry.element_entry_id
              ,p_object_version_number   => r_entry.object_version_number
              ,p_effective_start_date    => l_new_esd
              ,p_effective_end_date      => l_new_eed
              ,p_delete_warning          => l_warnings_exist
              );

      else
        if r_entry.processing_type = 'N' then
	      hr_utility.set_location(l_proc,40);
          -- Non-recurring entry
          -- Derive new effective end date using chk_element_entry_main
          -- This will ensure the payroll period is considered
          hr_entry.chk_element_entry_main
           (
             p_element_entry_id         => r_entry.element_entry_id,
             p_original_entry_id        => r_entry.original_entry_id,
             p_session_date             => l_session_date,
             p_element_link_id          => r_entry.element_link_id,
             p_assignment_id            => r_entry.assignment_id,
             p_entry_type               => r_entry.entry_type,
             p_effective_start_date     => l_new_esd,
             p_effective_end_date       => l_new_eed,
             p_validation_start_date    => r_entry.effective_start_date,
             p_validation_end_date      => hr_general.end_of_time,
             p_dt_update_mode           => 'CORRECTION',
             p_dt_delete_mode           => null,
             p_usage                    => 'UPDATE',
             p_target_entry_id          => r_entry.target_entry_id,
             p_creator_type             => r_entry.creator_type
           );
        else
	      hr_utility.set_location(l_proc,50);
          -- Recurring entry
          -- Derive new effective end date using get_eligibility_period
          -- This will ensure entry is not extended beyond lifetime of link
          hr_entry.get_eligibility_period
           (
             p_assignment_id         => r_entry.assignment_id,
             p_element_link_id       => r_entry.element_link_id,
             p_session_date          => l_session_date,
             p_min_eligibility_date  => l_new_esd,
             p_max_eligibility_date  => l_new_eed
           );
        end if;
        --
        hr_utility.trace('New EE effective end date: '||to_char(l_new_eed,'DD-MON-YYYY'));
        --
        -- Now we have the new effective end date
        -- Perform checks to make sure we don't move the EED unnecessarily

	if l_new_final_process_date > p_old_final_process_date then
          -- Moving FPD forwards
          -- Only change effective end date of entry if it wasn't earlier than the old FPD
          -- i.e. the entry may have been stopped by something other than the termination
	  -- Added a condition to check that the entries do not have the updating_action_id - which
	  -- means that the entry was updated by UPDATE_RECURRING or STOP_RECURRING formula result rules.

	      if r_entry.effective_end_date >= p_old_final_process_date
             	 AND (r_entry.updating_action_id IS NULL 		  -- bug 7315564
		 OR r_entry.updating_action_type = 'U') THEN -- bug 9069114
            --Bug Fix 9069114, Modified condition to check element entries
	    -- NOT end dated by STOP_RECURRING formula result rules

	         hr_utility.set_location(l_proc,60);

     	    update pay_element_entry_values_f
     	    set effective_end_date = l_new_eed
     	    where element_entry_id = r_entry.element_entry_id
            and p_old_final_process_date between effective_start_date and effective_end_date;

     	    update pay_element_entries_f
     	    set effective_end_date = l_new_eed
     	    where element_entry_id = r_entry.element_entry_id
            and p_old_final_process_date between effective_start_date and effective_end_date;

           end if;

	else
          -- Moving FPD backwards
          -- Only change effective end date of entry if it is greater than the new FPD
          if r_entry.effective_end_date > l_new_final_process_date then

	         hr_utility.set_location(l_proc,70);

	         update pay_element_entry_values_f
	         set effective_end_date = l_new_eed
	         where element_entry_id = r_entry.element_entry_id
             and p_old_final_process_date between effective_start_date and effective_end_date
             and l_new_eed >= effective_start_date;

	         update pay_element_entries_f
	         set effective_end_date = l_new_eed
	         where element_entry_id = r_entry.element_entry_id
             and p_old_final_process_date between effective_start_date and effective_end_date
             and l_new_eed >= effective_start_date;

          end if;
        end if;
      end if;
    end loop;

EXCEPTION
  --
  WHEN OTHERS THEN

    ROLLBACK TO move_fpd_entries;
    RAISE;

END move_fpd_entries;
--

end hrentmnt;

/
