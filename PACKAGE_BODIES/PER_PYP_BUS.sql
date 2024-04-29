--------------------------------------------------------
--  DDL for Package Body PER_PYP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PYP_BUS" as
/* $Header: pepyprhi.pkb 120.17.12010000.7 2009/06/11 05:33:59 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)        := '  per_pyp_bus.';  -- Global package name
g_legislation_code    varchar2(150)   default null;
g_pay_proposal_id     number          default null;

--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_non_updateable_args(p_rec in per_pyp_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_pyp_shd.api_updating
                (p_pay_proposal_id          => p_rec.pay_proposal_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_pyp_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if p_rec.assignment_id <> per_pyp_shd.g_old_rec.assignment_id then
     l_argument := 'assignment_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if p_rec.pay_proposal_id <> per_pyp_shd.g_old_rec.pay_proposal_id then
     l_argument := 'pay_proposal_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 9);
  --
/* change_date can be updated provided that the proposal has not already
   been approved.

 if p_rec.change_date <> per_pyp_shd.g_old_rec.change_date then
     l_argument := 'change_date';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 10);*/
  --
  if p_rec.last_change_date <> per_pyp_shd.g_old_rec.last_change_date then
     l_argument := 'last_change_date';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 11);
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end check_non_updateable_args;
--
/* procedure changed to incorporate changes for Bug#7386307 by schowdhu*/

procedure validate_date_to
  (p_assignment_id  in number,
   p_pay_proposal_id in number,
   p_change_date    in date,
   p_date_to        in date,
   p_approved       in per_pay_proposals.approved%TYPE
  )
  IS
  --
  -- Cursor to find legislation code
  --
  cursor csr_next_proposed_date is
    select min(change_date)
      from per_pay_proposals
     where assignment_id = p_assignment_id
       and change_date >  p_change_date
       and approved = 'N'
       and pay_proposal_id <>  p_pay_proposal_id;

  cursor csr_next_approved_date is
    select min(change_date)
      from per_pay_proposals
     where assignment_id = p_assignment_id
       and change_date >  p_change_date
       and approved = 'Y'
       and pay_proposal_id <>  p_pay_proposal_id;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  'validate_date_to';
  l_next_proposed_date  date;
  l_next_approved_date  date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_date_to is not null then

    OPEN csr_next_proposed_date;
    fetch csr_next_proposed_date into l_next_proposed_date;
    CLOSE csr_next_proposed_date;

    OPEN csr_next_approved_date;
    fetch csr_next_approved_date into l_next_approved_date;
    CLOSE csr_next_approved_date;

   if p_approved = 'N' and l_next_proposed_date is not null then
    if p_date_to >= l_next_proposed_date then
      hr_utility.set_message(800, 'PER_SAL_DATES_OVERLAP');
      hr_utility.raise_error;
    end if;
   end if;
   if p_approved = 'Y' and l_next_approved_date is not null then
    if p_date_to >= l_next_approved_date then
      hr_utility.set_message(800, 'PER_SAL_DATES_OVERLAP');
      hr_utility.raise_error;

    end if;


   end if;



  end if;
  --
  hr_utility.set_location('Leaving :'|| l_proc, 90);
end validate_date_to;
--
procedure  gen_last_change_date
  (p_rec        in out nocopy per_pyp_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package || 'gen_last_change_date';
  l_last_change_date  per_pay_proposals.last_change_date%TYPE;
--
-- define a cusor to determine wheather another proposal exists or not
--
  Cursor csr_last_change_date is
  select max(pro.change_date)
       from per_pay_proposals pro
       where pro.assignment_id = p_rec.assignment_id
       and pro.change_date<p_rec.change_date;

--
Begin
  hr_utility.set_location('Entering:' || l_proc, 1);
  --
  -- set the last_change_date
  --
  open csr_last_change_date;
  fetch csr_last_change_date into l_last_change_date;
  if csr_last_change_date%notfound then
     hr_utility.set_location(l_proc, 2);
     p_rec.last_change_date := null;
  else
     p_rec.last_change_date := l_last_change_date;
  end if;
  close csr_last_change_date;
  --
  hr_utility.set_location('Leaving: ' || l_proc, 3);
  --
end gen_last_change_date;
--
--
-------------------------------------------------------------------------------
-------------------------------< chk_pay_basis_change_date >-------------------
-------------------------------------------------------------------------------
--
--
--  Description:
--   It checks if there is already at least one approved salary proposal exists
--   and there is no current salary element entry (this can only happen if the
--   pay basis has been changed and the salary element closed down), the new
--   salary change date must be one day after the end_date of the previous
--   salary entry i.e. the date of the pay_basis change.
--   It also raise an error informing the user that they must remove the future
--   salary bases changes first, if there are any salary bases changes after
--   the change_date.
--   If the current element has an end date that is not the end of time or the
--   last effective end date of the assignment or the end date of the period
--   of service then an error will be raised.
--
--  Pre_conditions:
--
--  In Arguments:
--    p_assignment_id
--    p_change_date
--
--  Post Success:
--    Process continues if :
--    The change date is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - There exist future change in the pay_basis.
--      - There exists a change in the pay basis that is not on the change_date.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure  chk_pay_basis_change_date
              (p_assignment_id  in  per_pay_proposals.assignment_id%TYPE
              ,p_change_date    in  per_pay_proposals.change_date%TYPE
) is
--
-- Cursor to check that there is at least one approved salary proposal
-- for this assignment
--
cursor csr_first_proposal is
select null
from   per_pay_proposals
where  assignment_id  = p_assignment_id
and    approved   = 'Y';
--
-- cursor which checks whether there is an open salary element.
--
cursor csr_sp_element_open is
select null
from   pay_element_entries_f
where  assignment_id  = p_assignment_id
and    creator_type = 'SP'
and    effective_end_date = hr_general.end_of_time;
--
-- Cursor to get the effective_end_date of the latest salary
-- element.
--
cursor csr_element_effective_end_date is
select max(peef.effective_end_date)
from   pay_element_entries_f peef
,      pay_element_links_f pel
,      pay_input_values_f piv
,      per_pay_bases ppb
,      per_all_assignments_f asg
where  asg.assignment_id = p_assignment_id
and    asg.pay_basis_id=ppb.pay_basis_id
and    ppb.input_value_id=piv.input_value_id
and    asg.effective_start_date
       between piv.effective_start_date and piv.effective_end_date
and    piv.element_type_id=pel.element_type_id
/**
 * Bug Fix : 3036147
 * Description: To allow the user create new salary proposal
 *              when salary element got changed.
 *and    asg.effective_start_date
 *      between pel.effective_start_date and pel.effective_end_date
 **/
and    pel.element_link_id=peef.element_link_id
and    peef.assignment_id=p_assignment_id
and    asg.assignment_id=peef.assignment_id
and    peef.creator_type = 'SP';
--
cursor csr_asg_effective_end_date is
select max(effective_end_date)
from   per_all_assignments_f asg,
       per_assignment_status_types ast
where  asg.assignment_id = p_assignment_id
and    asg.assignment_status_type_id=ast.assignment_status_type_id
and    ast.per_system_status='ACTIVE_ASSIGN';

-- Modified the cursor below to retrieve the last_standard_process_date
-- and actual_termination_date along with the final_process_date
-- as part of the fix for Bug 4073821
--
cursor csr_pds_final_process_date is
select final_process_date,
       last_standard_process_date,
       actual_termination_date
from  per_periods_of_service pds
,     per_all_assignments_f asg
where asg.assignment_id=p_assignment_id
and   p_change_date between asg.effective_start_date and asg.effective_end_date
and   asg.person_id=pds.person_id
and   p_change_date between pds.date_start
      and NVL(pds.final_process_date,hr_general.end_of_time);

--
-- Cursor to check that whether there are any pay_basis changes after
-- the change_date
--
cursor csr_asg_pay_bases is
select null
from   per_all_assignments_f asg1
where  assignment_id    = p_assignment_id
and    exists (select null
       from   per_all_assignments_f asg2
       where  asg2.assignment_id  = p_assignment_id
       and    asg1.pay_basis_id +0  <> asg2.pay_basis_id
       and    asg2.effective_start_date > p_change_date
       and    asg1.effective_end_date  >= p_change_date);

--
-- Cursor to determine the termination rule for the salary element
-- associated with the p_assignment_id as of the p_change_date
-- Added as part of fix for Bug 4073821
--

  CURSOR csr_ele_term_rule(p_assignment_id  IN NUMBER
                          ,p_change_date IN DATE) IS
  SELECT  pet.post_termination_rule
    FROM  pay_element_types_f pet,
          per_all_assignments_f asg,
          per_pay_bases ppb,
          pay_input_values_f iv
   WHERE  pet.element_type_id = iv.element_type_id
     AND  iv.input_value_id = ppb.input_value_id
     AND  ppb.pay_basis_id  = asg.pay_basis_id
     AND  asg.assignment_id = p_assignment_id
     AND  p_change_date BETWEEN iv.effective_start_date  AND iv.effective_end_date
     AND  p_change_date BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND  p_change_date BETWEEN pet.effective_start_date AND pet.effective_end_date;
--
--
l_exists    varchar2(1);
l_effective_end_date    date;
l_asg_effective_end_date per_all_assignments_f.effective_end_date%TYPE;
l_pds_final_process_date per_periods_of_service.final_process_date%TYPE;
--4073821
l_pds_last_std_proc_date  per_periods_of_service.last_standard_process_date%TYPE;
l_pds_actual_term_date    per_periods_of_service.actual_termination_date%TYPE;
l_ele_term_rule           pay_element_types_f.post_termination_rule%TYPE;

  l_proc     varchar2(72) := g_package||'chk_pay_basis_change_date';
--
begin
  --
  hr_utility.set_location('Entering: ' || l_proc,1);
  --
  -- check that whether this is the first salary record or not
  -- i.e. At least one approved salary exists.
  --
  open csr_first_proposal;
  fetch csr_first_proposal into l_exists;
  if csr_first_proposal%found then
    close csr_first_proposal;
    hr_utility.set_location(l_proc,5);
    --
    -- Now check whether there has been a pay_basis change in the assignment.
    -- If there is no salary element going to the end of time this means
    -- that the pay_basis has changed.
    --
    -- now get the effective_end_date of the last salary_element
    --
    open csr_element_effective_end_date;
    fetch csr_element_effective_end_date into l_effective_end_date;
    if csr_element_effective_end_date%notfound then
      close csr_element_effective_end_date;
      hr_utility.set_location(l_proc,10);
      hr_utility.set_message(801,'HR_51716_PYP_ELEMNT_ID_INVL');
      hr_utility.raise_error;
    else
      close csr_element_effective_end_date;
      if l_effective_end_date = hr_general.end_of_time then
        hr_utility.set_location(l_proc,15);
      else
        --
        -- element has ended for some reason. Check
        -- to see if the new proposal is the day after the element has ended
        -- which is correct for a pay basis change
        --
        hr_utility.set_location(l_proc,20);
        if (l_effective_end_date+1 <> p_change_date) then
          --
          -- new proposal is not 1 day after element end so check to see if
          -- element ends on the day the assignment ends, so changes are OK.
          --
          hr_utility.set_location(l_proc,25);
          open csr_asg_effective_end_date;
          fetch csr_asg_effective_end_date into l_asg_effective_end_date;
          close csr_asg_effective_end_date;
          if (l_asg_effective_end_date <>l_effective_end_date) then

    -- Added for fixing the issue reported in Bug 4073821

            OPEN csr_ele_term_rule(p_assignment_id, p_change_date);
            FETCH csr_ele_term_rule INTO l_ele_term_rule;
            CLOSE csr_ele_term_rule;

            open csr_pds_final_process_date;
            fetch csr_pds_final_process_date into l_pds_final_process_date, l_pds_last_std_proc_date, l_pds_actual_term_date;
            close csr_pds_final_process_date;

            IF NVL(l_ele_term_rule,'F') = 'F' THEN -- Start of Termination Rule condition added for Bug 4073821
            --
            -- element does not end on the day that the assignment ends, but
            -- could end on the final process date
            --
      hr_utility.set_location(l_proc,26);
--4073821
--      open csr_pds_final_process_date;
--           fetch csr_pds_final_process_date into l_pds_final_process_date;
--            close csr_pds_final_process_date;
            if (l_pds_final_process_date <> l_effective_end_date) or
               (l_pds_final_process_date is null) then
        hr_utility.set_location(l_proc,27);
              hr_utility.set_message(801,'HR_51717_PYP_CHG_DATE_INVL');
        hr_utility.raise_error;
            end if;
      ELSIF NVL(l_ele_term_rule,'F') = 'L' THEN
            --
            -- Element does not end on the day that the assignment ends, but
            -- could end on the last standard process date
            --
               hr_utility.set_location(l_proc,26);
               if (l_pds_last_std_proc_date <> l_effective_end_date) or
                  (l_pds_last_std_proc_date is null) then
              hr_utility.set_location(l_proc,27);
                  hr_utility.set_message(801,'HR_51717_PYP_CHG_DATE_INVL');
              hr_utility.raise_error;
               end if;
           END IF; -- End of Termination Rule condition added for Bug 4073821
          end if;
  end if;
        --
      end if;
      --
    end if;
    --
  else
     close csr_first_proposal;
     hr_utility.set_location(l_proc,28);
  end if;
  --
  -- Now do a further check to see whether there is future pay_basis changes
  -- The following validation is removed by ggnanagu
  -- As part of the new Salary UI Enhancement 5059480
  --
  /*
  open csr_asg_pay_bases;
  fetch csr_asg_pay_bases into l_exists;
  if csr_asg_pay_bases%found then
     --
     -- raise an error if there future pay_basis change in the assignment.
     --
     close csr_asg_pay_bases;
     hr_utility.set_location(l_proc,30);
     hr_utility.set_message(801,'HR_51718_PYP_FUTU_PAY_BAS_CHG');
     hr_utility.raise_error;
  else
     close csr_asg_pay_bases;
     hr_utility.set_location(l_proc,31);
  end if;
  */

  hr_utility.set_location('Leaving: ' ||l_proc,35);
--
end chk_pay_basis_change_date;
--
--
-- ----------------------------------------------------------------
-- |------------------------< chk_access >------------------------|
-- ----------------------------------------------------------------
-- Description
--
--   This procedure checks whether the assignment id exists as of the
--   change_date of the proposal.
--
--  Pre_conditions:
--    A valid change_date
--
--  In Arguments:
--    p_assignment_id
--    p_change_date
--
--  Post Success:
--  Process continues if the assignment id is valid
--
--  Post Failure:
--  Processing stops after raising appropriate Error Message
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_access
(p_change_date    in    date
,p_assignment_id  in    per_pay_proposals.assignment_id%TYPE
) is
 --
 -- Declare local variables
 --
 l_proc              varchar2(72)  :=  g_package||'chk_access';
 l_exists            varchar2(1);
 --bug#8566773 vkodedal 03-Jun-2009
 l_asg_type          varchar2(1);
 ---
 ---cursor to get the assignment_type
 ---
 cursor csr_asg_type is
    select ASSIGNMENT_TYPE
    from per_all_assignments_f
     where assignment_id=p_assignment_id
     and p_change_date between effective_start_date
                             and effective_end_date;
 --
 -- Cursor to check access to the assignment record
 --
 cursor csr_asg_sec is
   select null
     from per_assignments_f2 asg
     where asg.assignment_id = p_assignment_id
       and p_change_date between asg.effective_start_date
                             and asg.effective_end_date;
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);

   --get the assignment_type
    --bug#8566773 vkodedal 03-Jun-2009 relax the validation for offer assignment
   open csr_asg_type;
   fetch csr_asg_type into l_asg_type;
   close csr_asg_type;

   if l_asg_type <> 'O' then
   --
   -- Always perform this validation on update and delete
   -- even although the assignment_id value cannot be changed.
   --
   open csr_asg_sec;
   fetch csr_asg_sec into l_exists;
   if csr_asg_sec%notfound then
     close csr_asg_sec;
     fnd_message.set_name('PER', 'PER_SAL_ASG_NOT_EXIST');
     fnd_message.raise_error;
   end if;
   close csr_asg_sec;

   end if;
   hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_access;
--
--
-------------------------------------------------------------------------------
-------------------------------< chk_assignment_id_change_date >---------------
-------------------------------------------------------------------------------
--
--
--  Description:
--   - Validates that assignment_id exists and is date effctive on
--     per_assignmnets_f.
--   - Validates that the business group of the assignment is the same as the
--     business group of the pay proposal.
--   - Validates that the assignments has a valid pay_basis associated with it.
--   - Validates that the assingment system_status is not TERM_ASSIGN as of
--     change_date.
--   - Validates that the payroll status associated to the assignment is not
--     closed as of change_date.
--   - Validates that the change_date is after the last change_date.
--   - Validates that the change_date is unique
--     Note that the check for assignment type (i.e. TERM_ASSIG) and
--     valid pay_basis as of change date is done in chk_assignment.
--     validates that there is no other unapproved proposals
--     validates that the change_date is not updated if the proposal was approved.
--  Note: The chk_assignment_id and chk_change_date is merged into this procedure
--        because of close interrelations between assignment_id and change_date.
--
--  Pre_conditions:
--    A valid business_group_id
--
--
--  In Arguments:
--    p_pay_proposal_id
--    p_assignment_id
--    p_business_group_id
--    p_change_date
--    p_payroll_warning
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignmnet_id does not exist or is not date effective
--      - The business group of the assignment is invalid
--      - The assigment has not a pay_bases associated with it.
--      - The assignment system status is TERM_ASSIGN
--      - The change_date with the same date is already exists for the assinment.
--      - The change_date is before another existing change_date for the assignment.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--

procedure chk_assignment_id_change_date
  (p_pay_proposal_id            in      per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id          in      per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id    in  per_pay_proposals.assignment_id%TYPE
  ,p_change_date    in  per_pay_proposals.change_date%TYPE
  ,p_payroll_warning   out nocopy     boolean
  ,p_object_version_number  in  per_pay_proposals.object_version_number%TYPE
  )
  is
--
   l_exists   varchar2(1);
   l_api_updating       boolean;
   l_proc               varchar2(72)  :=  g_package||'chk_assignment_id_change_date';
   l_pay_basis_id       per_all_assignments_f.pay_basis_id%TYPE;
   l_payroll_status per_time_periods.status%TYPE;
   l_assginment_id      per_all_assignments_f.assignment_id%TYPE;
   l_business_group_id  per_all_assignments_f.business_group_id%TYPE;
   l_system_status  per_assignment_status_types.per_system_status%TYPE;
   l_assignment_type  per_all_assignments_f.assignment_type%TYPE;
   l_change_date                  per_pay_proposals.change_date%TYPE;
   l_payroll_id         per_all_assignments_f.payroll_id%TYPE;
   --
   --
   -- Cursor to  check existence of pay proposal with the same change date for the
   -- assignment.
   -- Also to check the latest proposal change_date for the assignment.
   --
   cursor csr_dup_change_date is
     select null
     from   per_pay_proposals
     where  assignment_id         = p_assignment_id
     and    business_group_id + 0 = p_business_group_id
     and    change_date           = p_change_date
     and    pay_proposal_id      <> nvl(p_pay_proposal_id,-1);
   --
   cursor csr_last_change_date is
     select max(change_date)
     from   per_pay_proposals
     where  assignment_id = p_assignment_id
     and    business_group_id + 0 = p_business_group_id
     and    pay_proposal_id<>nvl(p_pay_proposal_id,-1);
   --
   -- Define a cursor to check whether other proposals exist.
   --
   Cursor csr_other_proposals_exist is
   select null
   from   per_pay_proposals
   where  assignment_id        = p_assignment_id
   and    approved = 'N'
   and    pay_proposal_id<>nvl(p_pay_proposal_id,-1);
   --
   cursor csr_chk_assig_details is
   select ast.per_system_status,
          asg.business_group_id,
          asg.assignment_type,
          ptp.status,
          asg.pay_basis_id,
          asg.payroll_id
   from   per_all_assignments_f                   asg,
          per_time_periods                  ptp,
          per_assignment_status_types          ast
   where  asg.assignment_id        =        p_assignment_id
   and    asg.assignment_status_type_id = ast.assignment_status_type_id
   and    p_change_date       between asg.effective_start_date
                                and   asg.effective_end_date
   and    asg.payroll_id=ptp.payroll_id(+)
   and    (p_change_date between ptp.start_date(+)
      and ptp.end_date(+)); --bug 2694178, 2801228
   --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'change_date'
    ,p_argument_value => p_change_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for assignment_id or change_date has changed
  --
  l_api_updating := per_pyp_shd.api_updating
         (p_pay_proposal_id        => p_pay_proposal_id
         ,p_object_version_number  => p_object_version_number);
  --
  -- only proceed if we are inserting or if we are updaing and change date
  -- has changed
  --
  if (l_api_updating AND (nvl(per_pyp_shd.g_old_rec.change_date,hr_api.g_date) <>
      nvl(p_change_date,hr_api.g_date) )or not l_api_updating) then
  --
  -- if we are updating but it was already approved then error.
  --
  if ((l_api_updating and per_pyp_shd.g_old_rec.approved='Y') and
     (nvl(g_validate_ss_change_pay,'N') = 'N'))then
    hr_utility.set_message(800,'HR_51349_PYP_CNT_UPD_CHG_DATE');
    hr_utility.raise_error;
  else
    hr_utility.set_location(l_proc, 2);
    --
    -- Check the assignment details as of change_date
    --
    open csr_chk_assig_details;
    fetch csr_chk_assig_details into l_system_status, l_business_group_id,
    l_assignment_type, l_payroll_status, l_pay_basis_id,l_payroll_id;
    if csr_chk_assig_details%notfound then
       hr_utility.set_location(l_proc, 5);
       -- The assignment_id is incorrect
       close csr_chk_assig_details;
  /**
   * Bug Fix: 3144666
         * Description: To change the error to warning
         **/
       p_payroll_warning := true;
       /*Change date does not fall within any payroll period.
         Message changed for Bug 3077957 */
       -- hr_utility.set_message(800,'PER_289483_CHG_DT_NO_PAY_PRD');
       -- hr_utility.raise_error;
       --
    else close csr_chk_assig_details;
       --
       -- Check that the business group id is the same.
       --
       if l_business_group_id <> p_business_group_id then
          hr_utility.set_location(l_proc, 10);
          -- The business_group_id is incorrect
          hr_utility.set_message(801,'HR_51255_PYP_INVLID_BUS_GROUP');
          hr_utility.raise_error;
       --
       -- Check that the system_status is not  'TERM_ASSIGN'
       --
       elsif l_system_status =  'TERM_ASSIGN' then
          hr_utility.set_location(l_proc, 15);
          hr_utility.set_message(801,'HR_7340_SAL_ASS_TERMINATED');
          hr_utility.raise_error;
       --
       -- Check that the  payroll_status is not closed
       -- If the payroll is null then there is no need check payroll status
       -- bug# 2801228
       elsif (nvl(l_payroll_status,'C') <> 'O' and
    l_payroll_id is not null) then
         hr_utility.set_location(l_proc, 25);
        /**
         * Bug Fix: 3144666
         * Description: To change the error to warning
         **/
   p_payroll_warning := true;
         --hr_utility.set_message(800,'HR_SAL_PAYROLL_PERIOD_CLOSED');
   --hr_utility.raise_error;   -- Error will raised instead of warning.
           -- bug# 2694178
       --
       -- Check that the assignment has a vaild pay_basis
       --
       elsif (l_pay_basis_id IS NULL) then
         hr_utility.set_location(l_proc, 30);
         hr_utility.set_message(801, 'HR_289855_SAL_ASS_NOT_SAL_ELIG');
         hr_utility.raise_error;
       elsif (l_api_updating = false) then
       --
       -- check that the p_change_date is greater than the last proposal
       -- change_date.
       --
       -- The following code is commented out.
  -- New Salary proposals can be added even if future proposals exist
  -- Change made by ggnanagu
/*
         open csr_last_change_date;
         fetch csr_last_change_date into l_change_date;
         if csr_last_change_date%notfound then
            hr_utility.set_location(l_proc, 35);
            --
         elsif
            l_change_date > p_change_date then
            hr_utility.set_location(l_proc, 40);
            close csr_last_change_date;
            hr_utility.set_message(801,'HR_7293_SAL_FUTURE_APPS_EXIST');
            hr_utility.raise_error;
            --
         end if;
         close csr_last_change_date;
*/
--
-- The following code is commented out.
-- There can be more than one Unapproved Proposal now
-- Change made by ggnanagu
/*
         open csr_other_proposals_exist;
         fetch csr_other_proposals_exist into l_exists;
         if csr_other_proposals_exist%notfound then
            hr_utility.set_location(l_proc, 45);
            close  csr_other_proposals_exist;
            --
         else
            close  csr_other_proposals_exist;
            hr_utility.set_location(l_proc, 50);
            hr_utility.set_message(801, 'HR_7294_SAL_ONLY_ONE_PROPOSAL');
            hr_utility.raise_error;
         end if;
*/

       --
       -- Now check for change_date being unique.
       --
         open csr_dup_change_date;
         fetch csr_dup_change_date into l_exists;
         if csr_dup_change_date%notfound then
            hr_utility.set_location(l_proc, 55);
            close csr_dup_change_date;
         else
            hr_utility.set_location(l_proc, 60);
            close csr_dup_change_date;
            hr_utility.set_message(801,'HR_13000_SAL_DATE_NOT_UNIQUE');
            hr_utility.raise_error;
          end if;
       --
       -- This code was added at version 70.4 to fix bug 411671.
       -- this checks that the change_date of the salary proposal is valid if
       -- the pay_basis has chnaged. It checks that the chnage_date must be the
       -- same date as that of pay_basis chnage in the assignmnet.
       -- it also checks that the change_date cannot be before any pay_basis changes.
       --
       --
       -- This is commented out by ggnanagu
       -- The new salary proposal need not have the change_date equals to the
       -- Salary Basis change date
       /*

       chk_pay_basis_change_date (p_assignment_id,p_change_date);
       hr_utility.set_location(l_proc, 61);

       */
       end if;
    --
    end if;
  end if;
  end if;
  hr_utility.set_location('Leaving: ' || l_proc, 65);
end chk_assignment_id_change_date;
--
--
--
------------------------------------------------------------------------------
----------------------- derive_next_sal_perf_date-----------------------------
------------------------------------------------------------------------------
--
-- Description
--
--   This function sets the next salary or performance review date
--
--
--
--  Pre_conditions:
--    A valid change_date
--
--
--  In Arguments:
--    p_change_date
--    p_period
--    p_frequency_
--
--  Post Success:
--    A date is returned from the arguments.
--
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
function  derive_next_sal_perf_date
  (p_change_date  in  per_pay_proposals.change_date%TYPE
  ,p_period   in  per_all_assignments_f.sal_review_period%TYPE
  ,p_frequency    in  per_all_assignments_f.sal_review_period_frequency%TYPE
  )
  Return Date is
--
    l_proc                 varchar2(72)  :=  g_package||'derive_next_sal_perf_date';
    l_derived_date         date;
    l_num_months           number(15) := 0;
    l_num_days       number(15) := 0;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check if the frequency is year
  --
  if (p_frequency = 'Y')then
      hr_utility.set_location(l_proc, 2);
      l_num_months := 12 * p_period;
  elsif
     (p_frequency = 'M') then
      hr_utility.set_location(l_proc, 3);
      l_num_months := p_period;
  --
  elsif (p_frequency = 'W' ) then
      hr_utility.set_location(l_proc, 4);
      l_num_days := 7 * p_period;
  --
  elsif
     (p_frequency = 'D') then
      hr_utility.set_location(l_proc, 5);
      l_num_days := p_period;
  --
  else
     hr_utility.set_location(l_proc, 6);
     hr_utility.set_message(801,'HR_51258_PYP_INVAL_FREQ_PERIOD');
     hr_utility.raise_error;
  end if;
  --
  -- Now return the derived date
  --
  if (l_num_months <> 0) then
     hr_utility.set_location(l_proc, 7);
     l_derived_date := add_months(p_change_date,l_num_months);
  --
  elsif (l_num_days <> 0 ) then
     hr_utility.set_location(l_proc, 8);
     l_derived_date := p_change_date + l_num_days;
  --
  end if;
  hr_utility.set_location('Leaving: ' ||l_proc, 9);
  --
  return l_derived_date;
  --
end derive_next_sal_perf_date;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_next_sal_review_date >-------------------------|
--  ---------------------------------------------------------------------------
--
--
--
--  Description:
--   - Validates that the next_sal_review_date is after the change_date.
--   - Set a warning flag if the assignment type is TERM_ASSIGN as of
--   - the next_sal_review_date.
--
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_next_sal_review_date
--    p_object_version_number
--    p_inv_next_sal_date_warning
--
--  Post Success:
--    Process continues if :
--    The next_sal_review_date is null or
--    the next_sal_review_date is a date for which the assignment type is
--    not TERM_ASSIGN
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the next_sal_review_date is a date for which
--        the assignment type is TERM_ASSIGN.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_next_sal_review_date
  (p_pay_proposal_id    in     per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id          in     per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id              in     per_pay_proposals.assignment_id%TYPE
  ,p_change_date    in     per_pay_proposals.change_date%TYPE
  ,p_next_sal_review_date       in     per_pay_proposals.next_sal_review_date%TYPE
  ,p_object_version_number      in     per_pay_proposals.object_version_number%TYPE
  ,p_inv_next_sal_date_warning     out nocopy boolean
  )
  is
--
   l_proc                    varchar2(72)  :=  g_package||'chk_next_sal_review_date';
   l_exists        varchar2(1);
   l_api_updating            boolean;
   --
   -- Cursor to check the assignment status as next_sal_review_date.
   --
   cursor csr_valid_assg_status is
     select     null
     from       per_all_assignments_f assg,
                per_assignment_status_types ast
     where      assg.assignment_id             = p_assignment_id
     and        assg.assignment_status_type_id = ast.assignment_status_type_id
     and        assg.business_group_id + 0     = p_business_group_id
     and        p_next_sal_review_date       between assg.effective_start_date
                                    and nvl(assg.effective_end_date, hr_api.g_eot)
     and        ast.per_system_status          = 'TERM_ASSIGN';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  p_inv_next_sal_date_warning := false;
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name   => l_proc
    ,p_argument   => 'change_date'
    ,p_argument_value   => p_change_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'assignment_id'
    ,p_argument_value   => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for next_sal_review_date has changed
  --
  l_api_updating := per_pyp_shd.api_updating
       (p_pay_proposal_id        => p_pay_proposal_id
       ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_pyp_shd.g_old_rec.next_sal_review_date,hr_api.g_date) <>
      nvl(p_next_sal_review_date,hr_api.g_date) )or not l_api_updating) then
     --
     -- If the next_sal_review is not null do the following checks
     --
     if (p_next_sal_review_date IS NOT NULL) then
         hr_utility.set_location(l_proc, 2);
         --
         -- Check that the next_sal_review date is not before the change_date
         --
--   Bug 740286
--         if (p_change_date > p_next_sal_review_date) then
           --
--           hr_utility.set_location(l_proc, 3);
--           hr_utility.set_message(801, 'HR_13007_SAL_DATE_NEXT_DATE');
--           hr_utility.raise_error;
--         end if;
         --
         -- check the assignment_status as the next_sal_review_date.
         -- if the assignment status is TERM_ASSIGN then issue a warning
         -- message to inform the user about it.
         --
         open csr_valid_assg_status;
         fetch csr_valid_assg_status into l_exists;
         if csr_valid_assg_status%found then
            p_inv_next_sal_date_warning := true;
         end if;
         --
         close csr_valid_assg_status;
         --
         hr_utility.set_location('LEAVING  ' ||l_proc, 4);
    end if;
   --
 end if;
 --
 hr_utility.set_location('Leaving: ' ||l_proc, 5);
 --
end chk_next_sal_review_date;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_chg_next_sal_review_date >-----------------|
--  ---------------------------------------------------------------------------
--
--
--  Description:
--   - Derive the next_sal_review_date if the period and frequency information
--   - is set for the salary at the assignment level.
--
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_next_sal_review_date
--    p_object_version_number
--    p_inv_next_sal_date_warning
--
--  Post Success:
--    Process continues if :
--    The next_sal_review_date is null or
--    the next_sal_review_date is a date for which the assignment type is
--    not TERM_ASSIGN
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the next_sal_review_date is a date for which
--        the assignment type is TERM_ASSIGN.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_chg_next_sal_review_date
 (p_pay_proposal_id   in     per_pay_proposals.pay_proposal_id%TYPE
 ,p_business_group_id     in     per_pay_proposals.business_group_id%TYPE
 ,p_assignment_id         in     per_pay_proposals.assignment_id%TYPE
 ,p_change_date       in     per_pay_proposals.change_date%TYPE
 ,p_next_sal_review_date  in out nocopy per_pay_proposals.next_sal_review_date%TYPE
 ,p_object_version_number in     per_pay_proposals.object_version_number%TYPE
 ,p_inv_next_sal_date_warning out nocopy boolean
  )
  is
--
   l_proc          varchar2(72):= g_package||'chk_chg_next_sal_review_date';
   l_exists         varchar2(1);
   l_api_updating       boolean;
   l_sal_review_period                  number(15);
   l_sal_review_period_frequency  varchar2(30);
   l_next_sal_review_date         Date;
   --
   --
   -- Cursor to get the frequency for salary details at
   -- assignment level.
   --
   cursor csr_sal_review_details is
     select sal_review_period,
            sal_review_period_frequency
     from   per_all_assignments_f
     where  assignment_id = p_assignment_id
     and    business_group_id + 0 = p_business_group_id
     and    p_change_date between effective_start_date
                          and nvl(effective_end_date, hr_api.g_eot);
   --
   --
   -- Cursor to check the assignment status as next_sal_review_date.
   --
   cursor csr_valid_assg_status is
     select     null
     from       per_all_assignments_f assg,
                per_assignment_status_types ast
     where      assg.assignment_id             = p_assignment_id
     and        assg.assignment_status_type_id = ast.assignment_status_type_id
     and        assg.business_group_id + 0      = p_business_group_id
     and        p_next_sal_review_date       between assg.effective_start_date
                                    and nvl(assg.effective_end_date, hr_api.g_eot)
     and        ast.per_system_status          = 'TERM_ASSIGN';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  p_inv_next_sal_date_warning := false;
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name   => l_proc
    ,p_argument   => 'change_date'
    ,p_argument_value   => p_change_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'assignment_id'
    ,p_argument_value   => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for next_sal_review_date has changed
  --
  l_api_updating := per_pyp_shd.api_updating
       (p_pay_proposal_id        => p_pay_proposal_id
       ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_pyp_shd.g_old_rec.next_sal_review_date,hr_api.g_date) <>
      nvl(p_next_sal_review_date,hr_api.g_date)) OR not l_api_updating) then
         --
      if (p_next_sal_review_date IS NULL) then
         -- When the next_sal_review is null then we do the following:
         -- a) check the sal_review details at the assignment level
         --    If the details exist then calculate the next_sal_review
         --    date accordingly, otherwise do nothing.
         --
         open csr_sal_review_details;
         fetch csr_sal_review_details into l_sal_review_period,
   l_sal_review_period_frequency;
         if csr_sal_review_details%found then
      if (l_sal_review_period is not null) then
               hr_utility.set_location(l_proc, 6);
               p_next_sal_review_date :=
               derive_next_sal_perf_date
         (p_change_date  => p_change_date
                   ,p_period     => l_sal_review_period
                   ,p_frequency  => l_sal_review_period_frequency
                                      );
               open csr_valid_assg_status;
               fetch csr_valid_assg_status into l_exists;
               --
               if csr_valid_assg_status%found then
                  hr_utility.set_location(l_proc, 7);
                  p_inv_next_sal_date_warning := true;
               end if;
               --
              close csr_valid_assg_status;
              --
      end if;
         end if;
         close csr_sal_review_details;
         hr_utility.set_location(l_proc, 10);
         --
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving: ' ||l_proc, 11);
end chk_chg_next_sal_review_date;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_multiple_components >---------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the first salary proposal cannot have multiple_components.
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_assignment_id
--    p_change_date
--    p_multiple_components
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--     The multiple_components is not set to a value other than 'Y' or 'N'.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The multiple_components is set to a value other than 'Y' or 'N'.
--      - The multiple_components is set to 'Y' for the first salary proposal.
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_multiple_components
  (p_pay_proposal_id          in  per_pay_proposals.pay_proposal_id%TYPE
  ,p_assignment_id            in  per_pay_proposals.assignment_id%TYPE
  ,p_change_date              in  per_pay_proposals.change_date%TYPE
  ,p_multiple_components      in  per_pay_proposals.multiple_components%TYPE
  ,p_object_version_number    in  per_pay_proposals.object_version_number%TYPE
  )
  is
--
   l_proc               varchar2(72):= g_package||'chk_multiple_components';
   l_exists             varchar2(1);
   l_api_updating       boolean;
   --
   -- Cursor to check for the first salary proposals.
   --
   Cursor csr_is_first_proposal is
   select null
   from   per_pay_proposals pro,
          per_all_assignments_f ass
   where  pro.assignment_id  = p_assignment_id
   and    ass.assignment_id  = pro.assignment_id
   and    p_change_date between ass.effective_start_date
                        AND  ass.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'change_date'
    ,p_argument_value   => p_change_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'assignment_id'
    ,p_argument_value   => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'multiple_components'
    ,p_argument_value   => p_multiple_components
   );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for multiple_components has changed
  --
  l_api_updating := per_pyp_shd.api_updating
         (p_pay_proposal_id        => p_pay_proposal_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND(per_pyp_shd.g_old_rec.multiple_components <>
      p_multiple_components) OR not l_api_updating) then
     hr_utility.set_location(l_proc, 4);
     --
     -- check that the value of the multiple_components is either 'Y' or 'N'
     --
     if (p_multiple_components <> 'Y' AND p_multiple_components <> 'N') then
         hr_utility.set_location(l_proc, 5);
         hr_utility.set_message (801, 'HR_51261_PYP_INVAL_MULTI_COMP');
         hr_utility.raise_error;
     end if;
     --
     -- Check that the multiple_components is not set to 'Y' for the first
     -- proposal
     --
     -- Commented by ggnanagu
     -- Now its possible for the first proposal to have components
/*
     open csr_is_first_proposal;
     fetch csr_is_first_proposal into l_exists;
     if csr_is_first_proposal%notfound then
        hr_utility.set_location(l_proc, 10);
        if (p_multiple_components = 'Y') then
           close csr_is_first_proposal;
           hr_utility.set_location(l_proc, 15);
           hr_utility.set_message (801, 'HR_51262_PYP_FIRST_SAL_COMP');
           hr_utility.raise_error;
        end if;
    --
    end if;
    --
    hr_utility.set_location(l_proc, 20);
  --
    close csr_is_first_proposal;  */

  end if;
  hr_utility.set_location('Leaving: '||l_proc, 25);

end chk_multiple_components;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_proposal_reason >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates the value entered for proposal_reason exists on hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_pay_proposal_id
--    p_proposal_reason
--    p_change_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The proposal_reason value is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--      - The proposal_reason value is invalid
--
--  Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_proposal_reason
  (p_pay_proposal_id       in  per_pay_proposals.pay_proposal_id%TYPE
  ,p_change_date     in  per_pay_proposals.change_date%TYPE
  ,p_proposal_reason       in  per_pay_proposals.proposal_reason%TYPE
  ,p_object_version_number in  per_pay_proposals.object_version_number%TYPE
  )
  is
--
   l_proc              varchar2(72):= g_package||'chk_proposal_reason';
   l_api_updating      boolean;
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'change_date'
    ,p_argument_value   => p_change_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for proposal_reason  has changed
  --
  l_api_updating := per_pyp_shd.api_updating
         (p_pay_proposal_id        => p_pay_proposal_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_pyp_shd.g_old_rec.proposal_reason,hr_api.g_varchar2) <>
      nvl(p_proposal_reason,hr_api.g_varchar2))
     OR not l_api_updating ) then
     hr_utility.set_location(l_proc, 6);
     --
     -- check that the p_proposal_reason exists in hr_lookups.
     --
   if (p_proposal_reason IS NOT NULL ) then
     if hr_api.not_exists_in_hr_lookups
  (p_effective_date        => p_change_date
   ,p_lookup_type           => 'PROPOSAL_REASON'
         ,p_lookup_code           => p_proposal_reason
        ) then
        --  Error: Invalid proposal_reason
        hr_utility.set_location(l_proc, 10);
        hr_utility.set_message(801,'HR_51265_INVAL_PRO_REASON');
        hr_utility.raise_error;
     end if;
  --
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
end chk_proposal_reason;
--
-- ----------------------------------------------------------------------------
-- |---------------------< is_salary_in_range >--------------------------------|
-- ----------------------------------------------------------------------------
--
--
--  Description
--    This is to validate that the given salary is within the grade range
--
--  Pre_condition
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_bussiness_group_id
--    p_change_date
--    p_proposed_salary_n
--    p_proposed-salary_warning
--
--  Post Success
--    The process continues if:
--    The proposed salary is in the range determined by the grade rate
--
--  Post Failure:
--    A warning message is issued if the salary in not in the range.
--
--  Access Status
--    Internal Table Handler USe only
--
--
procedure is_salary_in_range
  (p_assignment_id               in  per_pay_proposals.assignment_id%TYPE
   ,p_business_group_id          in  per_pay_proposals.business_group_id%TYPE
   ,p_change_date                in  per_pay_proposals.change_date%TYPE
   ,p_proposed_salary_n          in  per_pay_proposals.proposed_salary_n%TYPE
   ,p_proposed_salary_warning       out nocopy boolean
   ) is

   l_proc                 varchar2(70):= g_package || 'is_salary_in_range';
   l_organization_id             per_all_assignments_f.organization_id%TYPE;
   l_pay_basis_id                per_all_assignments_f.pay_basis_id%TYPE;
   l_position_id                 per_all_assignments_f.position_id%TYPE;
   l_grade_id                    per_all_assignments_f.grade_id%TYPE;
   l_normal_hours                per_all_assignments_f.normal_hours%TYPE;
   l_frequency                   per_all_assignments_f.frequency%TYPE;
   l_prop_salary_link_warning    boolean;
   l_prop_salary_ele_warning     boolean;
   l_prop_salary_grade_warning   boolean;
   --
   cursor csr_asg is
   select organization_id
   ,pay_basis_id
   ,position_id
   ,grade_id
   ,normal_hours
   ,frequency
   from per_all_assignments_f
   where assignment_id=p_assignment_id
   and p_change_date between effective_start_date and effective_end_date;
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open csr_asg;
  fetch csr_asg into
   l_organization_id
  ,l_pay_basis_id
  ,l_position_id
  ,l_grade_id
  ,l_normal_hours
  ,l_frequency;
  close csr_asg;
  --
  hr_utility.set_location(l_proc, 20);
  is_salary_in_range_int
  (p_organization_id             =>l_organization_id
  ,p_pay_basis_id                =>l_pay_basis_id
  ,p_position_id                 =>l_position_id
  ,p_grade_id                    =>l_grade_id
  ,p_normal_hours                =>l_normal_hours
  ,p_frequency                   =>l_frequency
  ,p_business_group_id           =>p_business_group_id
  ,p_change_date                 =>p_change_date
  ,p_proposed_salary_n           =>p_proposed_salary_n
  ,p_prop_salary_link_warning    =>l_prop_salary_link_warning
  ,p_prop_salary_ele_warning     =>l_prop_salary_ele_warning
  ,p_prop_salary_grade_warning   =>l_prop_salary_grade_warning
    --added by vkodedal bug#8452388
  ,p_assignment_id               =>p_assignment_id
);
  --
  hr_utility.set_location(l_proc, 30);
  --
  p_proposed_salary_warning     :=l_prop_salary_link_warning
                               OR l_prop_salary_ele_warning
                               OR l_prop_salary_grade_warning;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
end is_salary_in_range;
--
-- ----------------------------------------------------------------------------
-- |---------------------< is_salary_in_range_int >---------------------------|
-- ----------------------------------------------------------------------------
--
--
--  Description
--    This is to validate that the given salary is within the grade range
--
--  Pre_condition
--    None
--
--  In Arguments:
--    p_organization_id
--    p_pay_basis_id
--    p_posiiton_id
--    p_grade_id
--    p_normal_hours
--    p_frequency
--    p_business_group_id
--    p_change_date
--    p_proposed_salary_n
--
--  Out Arguments:
--    p_prop_salary_link_warning
--    p_prop_salary_ele_warning
--    p_prop_salary_grade_warning
--
--  Post Success
--    The process continues if:
--    The proposed salary is in the range determined by the grade rate
--
--  Post Failure:
--    A warning message is issued if the salary in not in the range.
--
--  Access Status
--    Internal Table Handler Use only
--
--
procedure is_salary_in_range_int
  (p_organization_id             in  per_all_assignments_f.organization_id%TYPE
  ,p_pay_basis_id                in  per_all_assignments_f.pay_basis_id%TYPE
  ,p_position_id                 in  per_all_assignments_f.position_id%TYPE
  ,p_grade_id                    in  per_all_assignments_f.grade_id%TYPE
  ,p_normal_hours                in  per_all_assignments_f.normal_hours%TYPE
  ,p_frequency                   in  per_all_assignments_f.frequency%TYPE
  ,p_business_group_id           in  per_pay_proposals.business_group_id%TYPE
  ,p_change_date                 in  per_pay_proposals.change_date%TYPE
  ,p_proposed_salary_n           in  per_pay_proposals.proposed_salary_n%TYPE
  ,p_prop_salary_link_warning    out nocopy boolean
  ,p_prop_salary_ele_warning     out nocopy boolean
  ,p_prop_salary_grade_warning   out nocopy boolean

  ) is

   l_proc                 varchar2(70):= g_package || 'is_salary_in_range_int';

   begin
    --
  hr_utility.set_location(l_proc, 20);

  is_salary_in_range_int
  (p_organization_id             =>p_organization_id
  ,p_pay_basis_id                =>p_pay_basis_id
  ,p_position_id                 =>p_position_id
  ,p_grade_id                    =>p_grade_id
  ,p_normal_hours                =>p_normal_hours
  ,p_frequency                   =>p_frequency
  ,p_business_group_id           =>p_business_group_id
  ,p_change_date                 =>p_change_date
  ,p_proposed_salary_n           =>p_proposed_salary_n
  ,p_prop_salary_link_warning    =>p_prop_salary_link_warning
  ,p_prop_salary_ele_warning     =>p_prop_salary_ele_warning
  ,p_prop_salary_grade_warning   =>p_prop_salary_grade_warning
    --added by vkodedal bug#8452388
  ,p_assignment_id               =>null
);
  --
  hr_utility.set_location(l_proc, 30);

  end is_salary_in_range_int;
--
-- ----------------------------------------------------------------------------
-- |---------------------< is_salary_in_range_int >---------------------------|
-- ----------------------------------------------------------------------------
--
--
--  Description
--    This is to validate that the given salary is within the grade range
--
--  Pre_condition
--    None
--
--  In Arguments:
--    p_organization_id
--    p_pay_basis_id
--    p_posiiton_id
--    p_grade_id
--    p_normal_hours
--    p_frequency
--    p_business_group_id
--    p_change_date
--    p_proposed_salary_n
--    p_assignment_id

--  Out Arguments:
--    p_prop_salary_link_warning
--    p_prop_salary_ele_warning
--    p_prop_salary_grade_warning
--
--  Post Success
--    The process continues if:
--    The proposed salary is in the range determined by the grade rate
--
--  Post Failure:
--    A warning message is issued if the salary in not in the range.
--
--  Access Status
--    Internal Table Handler Use only
--
--
procedure is_salary_in_range_int
  (p_organization_id             in  per_all_assignments_f.organization_id%TYPE
  ,p_pay_basis_id                in  per_all_assignments_f.pay_basis_id%TYPE
  ,p_position_id                 in  per_all_assignments_f.position_id%TYPE
  ,p_grade_id                    in  per_all_assignments_f.grade_id%TYPE
  ,p_normal_hours                in  per_all_assignments_f.normal_hours%TYPE
  ,p_frequency                   in  per_all_assignments_f.frequency%TYPE
  ,p_business_group_id           in  per_pay_proposals.business_group_id%TYPE
  ,p_change_date                 in  per_pay_proposals.change_date%TYPE
  ,p_proposed_salary_n           in  per_pay_proposals.proposed_salary_n%TYPE
  ,p_prop_salary_link_warning    out nocopy boolean
  ,p_prop_salary_ele_warning     out nocopy boolean
  ,p_prop_salary_grade_warning   out nocopy boolean
  --added by vkodedal bug#8452388
  ,p_assignment_id               in  per_all_assignments_f.assignment_id%TYPE
  ) is

   l_proc                 varchar2(70):= g_package || 'is_salary_in_range_int';
   l_working_hours                       per_all_assignments_f.normal_hours%TYPE;
   l_working_hours_frequency             per_all_assignments_f.frequency%TYPE;
   l_normal_hours                        per_all_assignments_f.normal_hours%TYPE;
   l_normal_hours_frequency              per_all_assignments_f.frequency%TYPE;
   l_org_working_hours                   NUMBER;
   l_org_working_hours_frequency         per_organization_units.frequency%TYPE;
   l_bus_working_hours                   NUMBER;
   l_bus_working_hours_frequency         per_business_groups.frequency%TYPE;
   l_pyp_working_hours                   hr_all_positions_f.working_hours%TYPE;
   l_pyp_working_hours_frequency         hr_all_positions_f.frequency%TYPE;
   l_minimum                             NUMBER;
   l_maximum                             NUMBER;
   l_ele_w_or_e                 pay_input_values_f.warning_or_error%TYPE;
   l_ele_min_value       pay_input_values_f.min_value%TYPE;
   l_ele_max_value       pay_input_values_f.max_value%TYPE;
   l_link_w_or_e         pay_link_input_values_f.warning_or_error%TYPE;
   l_link_min_value      pay_link_input_values_f.min_value%TYPE;
   l_link_max_value      pay_link_input_values_f.max_value%TYPE;
   l_element_type_id     pay_element_types_f.element_type_id%TYPE;
   l_pay_basis           VARCHAR2(30);
   l_grade_basis         VARCHAR2(30);
   l_annual_salary       number;
   l_currency_code       VARCHAR2(15);
   l_uom                 VARCHAR2(30);
   l_ann_minimum         number;
   l_ann_maximum         number;
   l_fte_factor                 number;
   l_rgeflg                 varchar2(1) := 'S';
   l_grade_annualization_factor NUMBER;
   l_pay_annualization_factor  NUMBER;
   l_dummy VARCHAR2(200);
   l_fte_profile_value VARCHAR2(240) := fnd_profile.VALUE('BEN_CWB_FTE_FACTOR');
   --
   --
   -- define cursor to get ele/link min/max values
   --
--Bug: 3026239
--Change Description: Modified the cursor to use fnd_number.canonical_to_number instead of to_number
--Changed by: kgowripe
   Cursor csr_get_ele_values  is
   select iv.warning_or_error,
          fnd_number.canonical_to_number(iv.min_value),
          fnd_number.canonical_to_number(iv.max_value),
          liv.warning_or_error,
          fnd_number.canonical_to_number(liv.min_value),
          fnd_number.canonical_to_number(liv.max_value)
   from   pay_link_input_values_f liv,
          pay_input_values_f iv,
          pay_element_links_f el,
          per_pay_bases     ppb
   where
        p_pay_basis_id=ppb.pay_basis_id
   and  ppb.input_value_id=iv.input_value_id and
        p_change_date BETWEEN
        iv.effective_start_date AND iv.effective_end_date
   and  iv.element_type_id      = el.element_type_id  and
        p_change_date BETWEEN
        el.effective_start_date AND el.effective_end_date
   and  liv.element_link_id     = el.element_link_id    and
        liv.input_value_id      = iv.input_value_id   and
        p_change_date BETWEEN
        liv.effective_start_date AND liv.effective_end_date;
   --
   -- Define a cursor to get the working hours and min/max for a grade
   --
   -- Changes 11-Oct-99 SCNair (per_all_positions to hr_all_positions) Date track pos req.
   --
   Cursor csr_get_min_max_values is
   select  p_normal_hours,
           p_frequency,
           fnd_number.canonical_to_number(O2.ORG_INFORMATION3) working_hours,
           O2.ORG_INFORMATION4 frequency,
           fnd_number.canonical_to_number(b2.ORG_INFORMATION3) working_hours,
           b2.ORG_INFORMATION4 frequency,
           fnd_number.canonical_to_number(pgr.minimum),
           fnd_number.canonical_to_number(pgr.maximum)
   from
           hr_all_organization_units bus, HR_ORGANIZATION_INFORMATION b2 ,
           hr_all_organization_units org, HR_ORGANIZATION_INFORMATION O2 ,
           pay_grade_rules_f pgr,
           per_pay_bases     ppb
   where
          org.organization_id = p_organization_id
   and    org.ORGANIZATION_ID = O2.ORGANIZATION_ID (+)
   and    O2.ORG_INFORMATION_CONTEXT (+) = 'Work Day Information'
   and
          pgr.grade_or_spinal_point_id  = p_grade_id   and
          pgr.rate_id                   = ppb.rate_id  and
          p_change_date
          between pgr.effective_start_date and pgr.effective_end_date
   and
          ppb.pay_basis_id    =  p_pay_basis_id
   and    bus.organization_id = p_business_group_id
   and    bus.ORGANIZATION_ID = b2.ORGANIZATION_ID (+)
   and    b2.ORG_INFORMATION_CONTEXT (+) = 'Work Day Information';
   --
   Cursor csr_get_pos_min_max_values is
   select  pos.working_hours,
           pos.frequency
   from    hr_all_positions_f   pos
   where   p_position_id              = pos.position_id
   and     p_change_date
           BETWEEN pos.effective_start_date AND pos.effective_end_date;
   --

  CURSOR Currency IS
  SELECT PET.INPUT_CURRENCY_CODE
, PPB.PAY_ANNUALIZATION_FACTOR
, PPB.GRADE_ANNUALIZATION_FACTOR
, PPB.PAY_BASIS
, PPB.RATE_BASIS
, PET.ELEMENT_TYPE_ID
, PIV.UOM
  FROM PAY_ELEMENT_TYPES_F PET
, PAY_INPUT_VALUES_F       PIV
, PER_PAY_BASES            PPB
--
  WHERE PPB.PAY_BASIS_ID=P_PAY_BASIS_ID
--
  AND PPB.INPUT_VALUE_ID=PIV.INPUT_VALUE_ID
  AND p_change_date  BETWEEN
  PIV.EFFECTIVE_START_DATE AND
  PIV.EFFECTIVE_END_DATE
--
  AND PIV.ELEMENT_TYPE_ID=PET.ELEMENT_TYPE_ID
  AND p_change_date  BETWEEN
  PET.EFFECTIVE_START_DATE AND
  PET.EFFECTIVE_END_DATE;

   --
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
        -- Get the pay_basis details for validating
        -- the proposed salary.
  open currency;
  fetch currency into
   l_currency_code
  ,l_pay_annualization_factor
  ,l_grade_annualization_factor
  ,l_pay_basis
  ,l_grade_basis
  ,l_element_type_id
  ,l_uom;

  if currency%notfound is null then
    close currency;
    hr_utility.set_location(l_proc, 5);
    hr_utility.set_message(801, 'HR_289855_SAL_ASS_NOT_SAL_ELIG');
    hr_utility.raise_error;
    --
  elsif (l_element_type_id IS NULL) then
    --
    -- issue an error message if the l_element_type_id is null
    --
     close currency;
     hr_utility.set_location(l_proc, 6);
     hr_utility.set_message(801, 'HR_289855_SAL_ASS_NOT_SAL_ELIG');
     hr_utility.raise_error;
  else
    close currency;
  end if;
        --
        -- Now check the proporsed salary to be in appropriate range
        --
              hr_utility.set_location(l_proc, 7);
      open csr_get_min_max_values;
       fetch csr_get_min_max_values into
             l_normal_hours,
             l_normal_hours_frequency,
             l_org_working_hours,
             l_org_working_hours_frequency,
             l_bus_working_hours,
             l_bus_working_hours_frequency,
             l_minimum,l_maximum;
       hr_utility.set_location(l_proc, 10);
       if csr_get_min_max_values%notfound then
          hr_utility.set_location(l_proc, 11);
          close csr_get_min_max_values;
       else
          open csr_get_pos_min_max_values;
          fetch csr_get_pos_min_max_values into
             l_pyp_working_hours,
             l_pyp_working_hours_frequency;
          close csr_get_pos_min_max_values;
          --
          open csr_get_ele_values;
          fetch csr_get_ele_values into l_ele_w_or_e, l_ele_min_value,
                l_ele_max_value, l_link_w_or_e, l_link_min_value,
                l_link_max_value;
          if csr_get_ele_values%notfound then
             hr_utility.set_location(l_proc, 12);
          end if;
          close csr_get_ele_values;
          --
          hr_utility.set_location(l_proc, 15);
          --
          if l_pyp_working_hours is null then
             if l_org_working_hours is null then
               l_working_hours := l_bus_working_hours;
               l_working_hours_frequency := l_bus_working_hours_frequency;
         hr_utility.set_location(l_proc, 17);
            else
               l_working_hours := l_org_working_hours;
               l_working_hours_frequency := l_org_working_hours_frequency;
         hr_utility.set_location(l_proc, 18);
            end if;
          else
             l_working_hours := l_pyp_working_hours;
             l_working_hours_frequency := l_pyp_working_hours_frequency;
       hr_utility.set_location(l_proc, 19);
          end if;
          --

        --
        -- check link min/max
        --
        if((p_proposed_salary_n < NVL(l_link_min_value,p_proposed_salary_n-1))
           or(p_proposed_salary_n > NVL(l_link_max_value,p_proposed_salary_n+1)))
           then
           hr_utility.set_location(l_proc, 20);
           p_prop_salary_link_warning := true;
        end if;
        --
        -- check ele min/max
        --
        if((p_proposed_salary_n < NVL(l_ele_min_value,p_proposed_salary_n-1))
           or (p_proposed_salary_n > NVL(l_ele_max_value,p_proposed_salary_n+1)))
           then
           hr_utility.set_location(l_proc, 30);
           p_prop_salary_ele_warning := true;
        end if;
        --
        -- Now check if the assignment has a grade then the proposed
        -- salary is within the range.
        --

              if (l_minimum IS NOT NULL and l_maximum IS NOT NULL) then
           --
           -- checks grade rates and pro rates if necessary
           --
           hr_utility.set_location(l_proc, 40);

            --8452388 vkodedal introduced profile option 03-Jun-2009
--8587143 handle null assignment id
            if ( p_assignment_id is not null ) then
            l_fte_factor := PER_SALADMIN_UTILITY.get_fte_factor(p_assignment_id,p_CHANGE_DATE);
            else
                if (l_fte_profile_value = 'NHBGWH') then
                    if (l_working_hours = 0) then
                    -- if working hours are set to zero then ignore it.
                        hr_utility.set_location(l_proc, 45);
                        l_fte_factor:=1;
                    elsif
                        (l_working_hours IS NOT NULL)
                        AND (l_normal_hours IS NOT NULL)
                        AND NOT((l_pay_basis = 'HOURLY')
                        AND (l_grade_basis = 'HOURLY'))
                        AND (l_normal_hours_frequency=l_working_hours_frequency) then
               -- if both assignment hours and normal hours are defined then do a comparison
               --
                     hr_utility.set_location(l_proc, 50);
                    l_fte_factor  := l_normal_hours/l_working_hours;
                    end if;
                else
                  l_fte_factor := 1;
                end if;
             end if;

                l_annual_salary:=p_proposed_salary_n
                                 *nvl(l_pay_annualization_factor,1);

                if l_pay_basis <> 'HOURLY' then
               --FTE ANNUAL SALARY WILL BE USED FOR COMPARISION WHEN PROFILE IS Y
                 if NVL(fnd_profile.value('PER_ANNUAL_SALARY_ON_FTE'),'Y') = 'Y' then
                l_annual_salary := l_annual_salary / l_fte_factor;
                end if;
                end if;


               l_ann_minimum := l_minimum
                                *nvl(l_grade_annualization_factor,1);
               l_ann_maximum := l_maximum
                                *nvl(l_grade_annualization_factor,1);

             if l_pay_basis = 'HOURLY' and l_grade_basis = 'HOURLY'
             then
                if( (p_proposed_salary_n < l_minimum) or
                (p_proposed_salary_n > l_maximum) ) then
                hr_utility.set_location(l_proc, 55);
                p_prop_salary_grade_warning := true;
                end if;
             else
                if( (l_annual_salary < l_ann_minimum) or
                (l_annual_salary > l_ann_maximum) ) then
                hr_utility.set_location(l_proc, 60);
                p_prop_salary_grade_warning := true;
                end if;
            end if;
       --
        end if;
       --
   end if;
       if csr_get_min_max_values%ISOPEN then
          close csr_get_min_max_values;
       end if;
   hr_utility.set_location('Leaving: ' ||l_proc, 65);
end is_salary_in_range_int;
--
----------------------------------------------------------------------------
-- |--------------------------< chk_proposed_salary >-----------------------
----------------------------------------------------------------------------
--
--  Description:
--   - Check that the assignment's salary basis has an associated grade rate.
--   - If so, check if the assignment has a grade
--   - If so, check if the assignment has a rate assoiated with it.
--   - If so, check if the propoosed salary comes within the min and max
--   - specified for the grade and grade rate.
--   - If it doesn't, raise a warning to this effect.
--
--   - Validates that the proposed salary cannot be updated if the overall
--     proposal is approved (i.e. approved ='Y').
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_proposed_salary_n
--    p_object_version_number
--    p_proposed_salary_warning
--    p_multiple_components
--  Post Success:
--    Process continues if :
--    The the assignment's salary basis has no garde assoicated with it or
--    the proposed salary is within the assignment's grade_rate.
--    The proposed salary has a valid currency_code associated with it.
--
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the proposed salary is not within min
--          and max of salary basis' grade rate.
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_proposed_salary
(p_pay_proposal_id        in     per_pay_proposals.pay_proposal_id%TYPE
 ,p_business_group_id     in     per_pay_proposals.business_group_id%TYPE
 ,p_assignment_id         in     per_pay_proposals.assignment_id%TYPE
 ,p_change_date           in     per_pay_proposals.change_date%TYPE
 ,p_proposed_salary_n     in     per_pay_proposals.proposed_salary_n%TYPE
 ,p_object_version_number in     per_pay_proposals.object_version_number%TYPE
 ,p_proposed_salary_warning  out nocopy boolean
 -- vkodedal 19-feb-2008
 ,p_multiple_components   in     per_pay_proposals.multiple_components%TYPE
 )
  is

--
   l_proc             varchar2(72):= g_package||'chk_proposed_salary';
   l_api_updating                     boolean;
   l_proposed_salary_warning        boolean;

   --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'change_date'
    ,p_argument_value   => p_change_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'assignment_id'
    ,p_argument_value   => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
-- vkodedal 19-feb-2008 p_proposed_salary_n can be null when there are multiple components
if( p_multiple_components <> 'Y' ) then
  /*hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'proposed_salary_n'
    ,p_argument_value   => p_proposed_salary_n
    ); */
  --smadhuna Bug 7704348 08-jan-2009 User defined error message is to be thrown when proposed_salary_n is null
  IF p_proposed_salary_n IS NULL THEN
    hr_utility.set_location(l_proc, 2);
    hr_utility.set_message(800,'PER_33483_SALARY_NULL');
    hr_utility.raise_error;
  END IF;
end if;
    --
    --
    -- Only proceed with validation if :
    -- a) The current  g_old_rec is current and
    -- b) The value for proposed_salary_n has changed
    --
    l_api_updating := per_pyp_shd.api_updating
         (p_pay_proposal_id        => p_pay_proposal_id
         ,p_object_version_number  => p_object_version_number);
    --
    if (l_api_updating AND (nvl(per_pyp_shd.g_old_rec.proposed_salary_n,hr_api.g_number) <>
        nvl(p_proposed_salary_n,hr_api.g_number))OR not l_api_updating) then
     if p_proposed_salary_n is not null then

--
--   The following check is commented out. As now we are allowing update of Approved Salary Proposals
--   Change made by ggnanagu
--

/*  if (l_api_updating)AND(per_pyp_shd.g_old_rec.approved = 'Y' ) then
          hr_utility.set_location(l_proc||' proposed = '||to_char(p_proposed_salary_n)||' old = '||to_char(per_pyp_shd.g_old_rec.proposed_salary_n), 2);
          hr_utility.set_message(801,'HR_51268_PYP_CANT_UPD_RECORD');
          hr_utility.raise_error;
       end if;                  */

       is_salary_in_range
         (p_assignment_id                => p_assignment_id
         ,p_business_group_id            => p_business_group_id
         ,p_change_date                  => p_change_date
         ,p_proposed_salary_n            => p_proposed_salary_n
         ,p_proposed_salary_warning      => l_proposed_salary_warning);
         p_proposed_salary_warning := l_proposed_salary_warning;
     end if;
   end if;
   hr_utility.set_location('Leaving: ' ||l_proc, 3);
end chk_proposed_salary;
--
--
------------------------------------------------------------------------
-- |-----------------< chk_approved >-----------------------------------
------------------------------------------------------------------------
--
--  Description:
--    Validates that the approved can only have values of 'Y' and 'N'
--    Validates that it is a mandatory column
--    Checks the value of the approved flag is 'Y' for the first emp proposal
--    automatically.
--    Checks the value for an applicants proposal is 'N'
--    Validates that the approved flag can not be set to 'Y' if the proposed
--    salary is null.
--    Validates that when the approved flag is set to  'Y' if some unapproved
--    components then raising a warning message.
--    Validates that the approved falg can not be set to 'N' if the proposal
--    is not the latest proposals.
--
--  Pre_conditions:
--    A valid change_date
--    A valid business_group_id
--    A valid assignment_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_business_group_id
--    p_assignment_id
--    p_change_date
--    p_proposed_salary_n
--    p_object_version_number
--    p_approved_warning
--
--  Post Success:
--    Process continues if :
--    The value of the approved is 'Y' or 'N'
--    The proposed salary is not null when approved is set to 'Y'.
--
--
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The assignment_id is null.
--      - The change_date is null.
--      - A warning flag is set if the approved flag is set to yes while
--      - there are some outstanding unapproved components.
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_approved
  (p_pay_proposal_id        in per_pay_proposals.pay_proposal_id%TYPE
  ,p_business_group_id      in per_pay_proposals.business_group_id%TYPE
  ,p_assignment_id            in per_pay_proposals.assignment_id%TYPE
  ,p_change_date            in per_pay_proposals.change_date%TYPE
  ,p_proposed_salary_n            in per_pay_proposals.proposed_salary_n%TYPE
  ,p_object_version_number  in per_pay_proposals.object_version_number%TYPE
  ,p_approved       in per_pay_proposals.approved%TYPE
  ,p_approved_warning       out nocopy boolean
  )
  is
--
   l_proc                              varchar2(72):= g_package||'chk_approved';
   l_exists                          varchar2(1);
   l_api_updating                  boolean;
   l_assignment_type              per_all_assignments_f.assignment_type%TYPE;
   l_autoApprove               varchar2(1);
   --
   -- Cursor which checks for unapproved components
   --
   Cursor csr_unapproved_components is
   select null
   from   per_pay_proposal_components
   where  pay_proposal_id     = p_pay_proposal_id
   and    business_group_id + 0 = p_business_group_id
   and    approved = 'N';
   --
   -- Cursor to get the latest proposals
   --
   Cursor csr_is_first_proposal is
   select null
   from   per_pay_proposals
   where  assignment_id                 = p_assignment_id
   and    business_group_id        + 0        = p_business_group_id
   and    pay_proposal_id<>nvl(p_pay_proposal_id,-1);
--
   cursor asg_type is
   select assignment_type
   from per_all_assignments_f
   where assignment_id=p_assignment_id
   and p_change_date between
       effective_start_date and effective_end_date;

   --
   -- Define a cursor to check for approved proposals in the future
   --
   Cursor csr_future_approved_proposals is
   select null
   from   per_pay_proposals
   where  assignment_id        = p_assignment_id
   and    approved = 'Y'
   and    change_date > p_change_date;
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check mandatory parameters have being set.
  --
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'change_date'
    ,p_argument_value   => p_change_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'assignment_id'
    ,p_argument_value   => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
  --
   hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'approved'
    ,p_argument_value   => p_approved
    );
    --
    -- Only proceed with validation if :
    -- a) The current  g_old_rec is current and
    -- b) The value for approved has changed
    --
    l_api_updating := per_pyp_shd.api_updating
         (p_pay_proposal_id        => p_pay_proposal_id
         ,p_object_version_number  => p_object_version_number);
    --
    -- always check whether it is updating or changed or not
    -- because the person type may have changed.
    --
/*    if (l_api_updating AND (per_pyp_shd.g_old_rec.approved <> p_approved)
       or not l_api_updating) then */
       --
       --
       -- check that the value of the approved is either 'Y' or 'N'
       --
       if (p_approved <> 'Y' AND p_approved <> 'N') then
         hr_utility.set_location(l_proc, 10);
         hr_utility.set_message (801, 'HR_51278_PYP_INVL_APPR_VAL');
         hr_utility.raise_error;
       end if;
       --
       --
       -- Check that the approved flag cannot be set to 'Y' if the
       -- proposed salary is null.
       --
       if
         (p_proposed_salary_n IS NULL AND p_approved = 'Y') then
          hr_utility.set_location(l_proc, 20);
          hr_utility.set_message(801,'HR_51269_PYP_CANT_APPR_SAL');
          hr_utility.raise_error;
       end if;

       -- Validation Added by ggnanagu
       -- If there are approved proposals in the future then this proposal
       -- Cannot be in Proposed status

        ---changed for Bug 7126872 in order to skip the error for cwb process
        if (p_approved = 'N' and NVL(BEN_CWB_POST_PROCESS.g_is_cwb_component_plan,'N') = 'N') THEN
        open csr_future_approved_proposals;
         fetch csr_future_approved_proposals into l_exists;
         if csr_future_approved_proposals%notfound then
            hr_utility.set_location(l_proc, 55);
            close csr_future_approved_proposals;
         else
            hr_utility.set_location(l_proc, 60);
            close csr_future_approved_proposals;
            hr_utility.set_message(801,'HR_FUTURE_APPROVED_PROPOSALS');
            hr_utility.raise_error;
          end if;
          end if;
       --
       -- Check that the approve flag is correct for the first proposal.
       --
       if ( p_proposed_salary_n IS NOT NULL) then
         open csr_is_first_proposal;
         fetch csr_is_first_proposal into l_exists;
         if csr_is_first_proposal%notfound then
           hr_utility.set_location(l_proc, 30);
           close csr_is_first_proposal;
           open asg_type;
           fetch asg_type into l_assignment_type;
           if (asg_type%notfound) then
             close asg_type;
             hr_utility.set_location(l_proc, 40);
             hr_utility.set_message(801,'HR_289855_SAL_ASS_NOT_SAL_ELIG');
             hr_utility.raise_error;
           else
             hr_utility.set_location(l_proc, 50);
             close asg_type;
             if (l_assignment_type='E' or l_assignment_type='C') then -- a workers 1st proposal must be approved
             hr_utility.set_location(l_proc, 55);
               if p_approved = 'N' then
--vkodedal 05-Oct-2007 ER to satisfy satutory requirement
--Retain auto approve first proposal functionality if profile is null or set to Yes
                l_autoApprove:=fnd_profile.value('HR_AUTO_APPROVE_FIRST_PROPOSAL');
                  if(l_autoApprove is null or l_autoApprove ='Y') then
                    hr_utility.set_location(l_proc, 60);
                    hr_utility.set_message (800,'HR_52513_PYP_FIRST_EMP_NOT_APR');
                    hr_utility.raise_error;
                 end if;
               end if;
             else
               if p_approved = 'Y' then -- an applicants first proposal must be unapproved
                  hr_utility.set_location(l_proc, 70);
                 hr_utility.set_message (800,'HR_52514_PYP_FIRST_APPL_APR');
                 hr_utility.raise_error;
               end if;
             end if;
           end if;
         else
           close csr_is_first_proposal;
         end if;
       hr_utility.set_location(l_proc, 80);
       end if;
       --
       -- Check that if the approved set to 'Y' and one or more
       -- unapproved components exists.
       --
       open csr_unapproved_components;
       fetch csr_unapproved_components into l_exists;
       hr_utility.set_location(l_proc,90);
       if csr_unapproved_components%found then
          hr_utility.set_location(l_proc,100);
          p_approved_warning := true;
       end if;
       close  csr_unapproved_components;
       --
       -- Check that an approved proposal cannot be unapproved.
       --
       if (l_api_updating AND per_pyp_shd.g_old_rec.approved = 'Y' AND p_approved = 'N') then
          hr_utility.set_location(l_proc,110);
          hr_utility.set_message(801,'HR_51270_PYP_CANT_UNAPPRO_PRO');
          hr_utility.raise_error;
       end if;
       hr_utility.set_location(l_proc,120);
--  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,130);
  --
end chk_approved;
--
--
--
--------------------------------------------------------------------------------
--|-----------------------< chk_del_pay_proposal >---------------------------|
--------------------------------------------------------------------------------
--
--
--  Description
--    - Checks that only the last salary proposal can be deleted.
--    - Checks if the proposal has some components then the process fails
--    - If the salary falls below or above the grade min and max as a result
--    - of the
--      deleting an approved proposal, then a warning message is issued to
--      this effect.
--
--  Pre-conditions:
--    A valid pay_proposal_id
--
--  In Arguments:
--    p_pay_proprosal_id
--    p_object_version_number
--    p_salary_warning
--
--  Post Success:
--    Process continues if :
--    The  proposal is the last proposal.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - The pay_proposal  is null.
--      - The salary proposal is not the latest one.

--
--
procedure chk_del_pay_proposal
  (p_pay_proposal_id       in  per_pay_proposals.pay_proposal_id%TYPE
  ,p_object_version_number in  per_pay_proposals.object_version_number%TYPE
  ,p_salary_warning        out nocopy boolean
  ) is
--
   l_proc                     varchar2(72):= g_package||'chk_del_pay_proposal';
   l_exists                   varchar2(1);
   l_proposed_salary          per_pay_proposals.proposed_salary_n%TYPE;
   l_last_change_date         per_pay_proposals.change_date%TYPE;
   l_assignment_id            per_pay_proposals.assignment_id%TYPE;
   l_business_group_id  per_pay_proposals.business_group_id%TYPE;
   l_change_date  per_pay_proposals.change_date%TYPE;
   l_approved           per_pay_proposals.approved%TYPE;
   l_multiple_components  per_pay_proposals.multiple_components%TYPE;
--
   --
   -- Define a cursor to get the proposals details
   --
   cursor csr_get_pro_detail is
   select assignment_id,business_group_id,change_date,
    multiple_components,approved
   from   per_pay_proposals
   where  pay_proposal_id = p_pay_proposal_id
   and    object_version_number = p_object_version_number;
   --
   -- Define a cursor to check for unapproved componnets
   --
   cursor csr_unapproved_components is
   select null
   from   per_pay_proposal_components
   where  pay_proposal_id = p_pay_proposal_id
   and    approved    = 'N';
   --
   -- Define a cursor which gets the latest approved salary_proposal.
   --
   cursor csr_get_latest_salary is
   select proposed_salary_n
   from   per_pay_proposals
   where  assignment_id = l_assignment_id
   and    change_date < l_change_date
   order  by change_date desc;
   --
   Cursor csr_is_latest_proposal is
   select max(change_date)
   from   per_pay_proposals
   where  assignment_id = l_assignment_id;
   --
   -- Cursor to check that there are components for the proposal
   -- Note: If the proposal has some components, the delete process
   -- should fail.
   --
   cursor csr_component_exists is
   select null
   from   per_pay_proposal_components
   where  pay_proposal_id = p_pay_proposal_id;

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  -- get the proposal details first.
  --
  open csr_get_pro_detail;
  fetch csr_get_pro_detail into l_assignment_id,l_business_group_id,
        l_change_date,l_multiple_components, l_approved;
  if    csr_get_pro_detail%notfound then
        close csr_get_pro_detail;
  hr_utility.set_location(l_proc, 2);
  per_pyp_shd.constraint_error('PER_PAY_PROPOSALS_PK');
  end if;
  close csr_get_pro_detail;
  --
  -- Check mandatory column from the above cursor are set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => l_assignment_id
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => l_business_group_id
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'change_date'
    ,p_argument_value => l_change_date
    );
  --
   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'multiple_components'
    ,p_argument_value => l_multiple_components
    );
  --
   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'approved'
    ,p_argument_value => l_approved
    );
  --
  --
  -- check that the proposal has no components
  --
  if(l_multiple_components = 'Y') then
     open csr_component_exists;
     fetch csr_component_exists into l_exists;
     if    csr_component_exists%found then
           close csr_component_exists;
     hr_utility.set_location (l_proc,2);
     hr_utility.set_message(801, 'HR_51326_PYP_CANT_DEL_MULT_PRO');
     hr_utility.raise_error;
     end if;
     close csr_component_exists;
  end if;
  --
  -- Check that, this is the latest salary proposal
  -- i.e. Only the latest salary proposal can be deleted.
  --
  open  csr_is_latest_proposal;
  fetch csr_is_latest_proposal into l_last_change_date;
  if  csr_is_latest_proposal%notfound then
      hr_utility.set_location(l_proc,5);
      close csr_is_latest_proposal;
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
      --
      -- The following code is commented out by ggnanagu
      -- Now its possible to delete any salary proposal
      --
/*  elsif (l_change_date < l_last_change_date) then
      --
      -- raise an error. You can only delete the latest proposal
      --
      hr_utility.set_location(l_proc,10);
      close csr_is_latest_proposal;
      hr_utility.set_message(801, 'HR_7292_SAL_NOT_LATEST_SAL_REC');
      hr_utility.raise_error;*/
      --
  elsif l_approved = 'Y' then
      --
      -- Only do the salary range validation check, if we are
      -- deleting an approved proposal.
      --
     open csr_get_latest_salary;
     fetch csr_get_latest_salary into l_proposed_salary;
     if (csr_get_latest_salary%notfound) then
        --
        -- This means that there is no other proposals
        --
        hr_utility.set_location(l_proc, 20);
        close csr_get_latest_salary;
     --
     --
     else
     --
     -- Call the is_salary_in_range procedure for salary range checking.
     --
        is_salary_in_range
           (p_assignment_id                => l_assignment_id
           ,p_business_group_id            => l_business_group_id
           ,p_change_date                  => l_change_date
           ,p_proposed_salary_n            => l_proposed_salary
           ,p_proposed_salary_warning      => p_salary_warning);
         --
         hr_utility.set_location(l_proc, 40);
     --
    end if;
  --
  /**** This check should be done at BP level  ***/
  /***elsif (p_multiple_components = 'Y') then
    --
    -- check that there is some unapproved components
    --
    open csr_unapproved_components;
    fetch csr_unapproved_components into l_exists;
    if csr_unapproved_components%notfound then
       hr_utility.set_location(l_proc, 45);
       --
       -- There is no unapproved components
       --
       p_components_warning := false;
    else
      hr_utility.set_location(l_proc, 50);
      p_components_warning := true;
    end if;
    close csr_unapproved_components;
   ***/
  end if;
  if csr_is_latest_proposal%ISOPEN then
     close csr_is_latest_proposal;
  end if;
  hr_utility.set_location('Leaving: ' ||l_proc, 55);
end chk_del_pay_proposal;

-- -----------------------------------------------------------------------
-- |---------------------< chk_date_overlapping >--------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the change_date and date_to.
--
-- Pre-conditions:
--
--  In Arguments:
--    p_change_date and p_date_to
--
--  Post Success:
--    Process continues if :
--    p_change_date <= p_date_to
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - p_change_date > p_date_to
--
--
procedure chk_date_overlapping
  (p_change_date  in per_pay_proposals.change_date%TYPE,
   p_date_to     in per_pay_proposals.date_to%TYPE) is
--
   l_proc               varchar2(72):= g_package||'chk_date_overlapping';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  if(p_change_date > p_date_to ) then
    hr_utility.set_location(l_proc, 10);
    hr_utility.set_message(800,'PER_PROPOSAL_DATE_OVERLAP');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_date_overlapping;
--
--
--
-- -----------------------------------------------------------------------
-- |---------------------< chk_forced_ranking >--------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the forced ranking.
--
-- Pre-conditions:
--
--  In Arguments:
--    p_forced_ranking
--
--  Post Success:
--    Process continues if :
--    p_forced_ranking is a positive integer
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - p_forced_ranking is less than or equal to 0.
--
--
procedure chk_forced_ranking
  (p_forced_ranking        in  per_pay_proposals.forced_ranking%TYPE) is
--
   l_proc               varchar2(72):= g_package||'chk_forced_ranking';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  if(p_forced_ranking <= 0) then
    hr_utility.set_location(l_proc, 10);
    hr_utility.set_message(800,'HR_52400_PYP_INVALID_RANKING');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_forced_ranking;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_performance_review_id >-----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the value entered for performance_review_id is valid.
--
--  Pre-conditions:
--    p_assignment_id is valid
--
--  In Arguments:
--    p_pay_proposal_id
--    p_assignment_id
--    p_performance_review_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The performance_review_id value is valid
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--      - The performance_review_id value is invalid
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_performance_review_id
  (p_pay_proposal_id     in  per_pay_proposals.pay_proposal_id%TYPE
  ,p_assignment_id     in  per_pay_proposals.assignment_id%TYPE
  ,p_performance_review_id in  per_pay_proposals.performance_review_id%TYPE
  ,p_object_version_number in  per_pay_proposals.object_version_number%TYPE
  )
  is
--
   l_proc                         varchar2(72):= g_package||'chk_performance_review_id';
   l_exists                       varchar2(1);
   l_api_updating                 boolean;
   --
   --
   -- Cursor to  check existence of performance_review_id in per_performance_reviews
   --
   --
   cursor csr_chk_performance_review_id is
     select null
     from   per_performance_reviews prv
     ,      per_all_assignments_f asg
     where  asg.assignment_id  = p_assignment_id
     and    asg.person_id=prv.person_id
     and    prv.performance_review_id       = p_performance_review_id;
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'assignment_id'
    ,p_argument_value   => p_assignment_id
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for event_id  has changed
  --
  l_api_updating := per_pyp_shd.api_updating
         (p_pay_proposal_id        => p_pay_proposal_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_pyp_shd.g_old_rec.performance_review_id,hr_api.g_number)
      <> nvl(p_performance_review_id,hr_api.g_number))
     or not l_api_updating) then
     hr_utility.set_location(l_proc, 10);
     --
     --
   if (p_performance_review_id IS NOT NULL) then
     --
     open csr_chk_performance_review_id;
     fetch csr_chk_performance_review_id into l_exists;
     if csr_chk_performance_review_id%notfound then
        hr_utility.set_location(l_proc, 15);
        close csr_chk_performance_review_id;
  per_pyp_shd.constraint_error('PER_PAY_PROPOSALS_FK4');
     end if;
  --
     close csr_chk_performance_review_id;
   end if;
   --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end chk_performance_review_id;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in per_pyp_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.pay_proposal_id is not null) and (
     nvl(per_pyp_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_pyp_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.pay_proposal_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
   if nvl(fnd_profile.value('FLEXFIELDS:VALIDATE_ON_SERVER'),'N') = 'Y'
       then
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PAY_PROPOSALS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      );
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure insert_validate
        (p_rec                   in out nocopy  per_pyp_shd.g_rec_type
        ,p_inv_next_sal_date_warning   out nocopy  boolean
        ,p_proposed_salary_warning   out nocopy  boolean
        ,p_approved_warning    out nocopy  boolean
  ,p_payroll_warning     out nocopy  boolean
        ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_inv_next_sal_date_warning     boolean := false;
  l_inv_next_perf_date_warning    boolean := false;
  l_proposed_salary_warning   boolean := false;
  l_approved_warning      boolean := false;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in perpyp.bru is provided (where
  -- relevant)
  --
  -- Validate business_group id
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_BUSINESS_GROUP_ID a,c
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  -- Validate assignment id and change_date
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_ASSIGNMENT_ID /a,c,d,e,f,g,h
  -- Rule CHK_CHANGE_DATE  /a,b,c
  --
  -- call to chk_access added for fixing bug#3839734
    per_pyp_bus.chk_access(p_assignment_id => p_rec.assignment_id
                          ,p_change_date => p_rec.change_date);
  --
  per_pyp_bus.chk_assignment_id_change_date
    (p_pay_proposal_id    => p_rec.pay_proposal_id
    ,p_business_group_id  => p_rec.business_group_id
    ,p_assignment_id    => p_rec.assignment_id
    ,p_change_date    => p_rec.change_date
    ,p_payroll_warning    => p_payroll_warning
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 15);

  --
  --
  --  Validate that date_to is not earlier than the start_date
  --
  --
  per_pyp_bus.chk_date_overlapping
    (p_change_date    => p_rec.change_date
    ,p_date_to      => p_rec.date_to
    );
--
--
--
/*changed for Bug#7386307 as procedure signature is changed--schowdhu*/
  per_pyp_bus.validate_date_to
  (p_assignment_id  => p_rec.assignment_id,
   p_pay_proposal_id          => p_rec.pay_proposal_id,
   p_change_date    => p_rec.change_date,
   p_date_to        => p_rec.date_to,
   p_approved       => p_rec.approved
  );
  --
  -- Validate proposal_reason
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_PROPOSAL_REASON  a
  --
  per_pyp_bus.chk_proposal_reason
    (p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_proposal_reason    => p_rec.proposal_reason
    ,p_change_date    => p_rec.change_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Validate multiple_components
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_MULTIPLE_COMPONENTS  a,b,c
  --
  per_pyp_bus.chk_multiple_components
    (p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_assignment_id            => p_rec.assignment_id
    ,p_change_date              => p_rec.change_date
    ,p_multiple_components      => p_rec.multiple_components
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 35);
  --
  --
  -- Validate next_sal_review_date and change_date
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_CHG_NEXT_SAL_REVIEW_DATE  a
  --
  per_pyp_bus.chk_chg_next_sal_review_date
    (p_pay_proposal_id           => p_rec.pay_proposal_id
    ,p_business_group_id         => p_rec.business_group_id
    ,p_assignment_id             => p_rec.assignment_id
    ,p_change_date               => p_rec.change_date
    ,p_next_sal_review_date      => p_rec.next_sal_review_date
    ,p_object_version_number     => p_rec.object_version_number
    ,p_inv_next_sal_date_warning => p_inv_next_sal_date_warning
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate next_sal_review_date
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_NEXT_SAL_REVIEW_DATE  a
  --
  per_pyp_bus.chk_next_sal_review_date
    (p_pay_proposal_id           => p_rec.pay_proposal_id
    ,p_business_group_id         => p_rec.business_group_id
    ,p_assignment_id             => p_rec.assignment_id
    ,p_change_date       => p_rec.change_date
    ,p_next_sal_review_date      => p_rec.next_sal_review_date
    ,p_object_version_number     => p_rec.object_version_number
    ,p_inv_next_sal_date_warning => p_inv_next_sal_date_warning
    );
  --
  hr_utility.set_location(l_proc, 55);
  --
  --
  -- Validate proposed_salary
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_PROPOSED_SALARY  a,c
  --
  per_pyp_bus.chk_proposed_salary
    (p_pay_proposal_id            => p_rec.pay_proposal_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_assignment_id              => p_rec.assignment_id
    ,p_change_date                => p_rec.change_date
    ,p_proposed_salary_n          => p_rec.proposed_salary_n
    ,p_object_version_number      => p_rec.object_version_number
    ,p_proposed_salary_warning    => p_proposed_salary_warning
    -- vkodedal 19-feb-2008
    ,p_multiple_components        => p_rec.multiple_components
    );
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Validate approved
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_APPROVED  b,c,d,f
  --
  per_pyp_bus.chk_approved
    (p_pay_proposal_id            => p_rec.pay_proposal_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_assignment_id              => p_rec.assignment_id
    ,p_change_date                => p_rec.change_date
    ,p_approved                   => p_rec.approved
    ,p_proposed_salary_n          => p_rec.proposed_salary_n
    ,p_object_version_number      => p_rec.object_version_number
    ,p_approved_warning           => p_approved_warning
    );
 hr_utility.set_location(l_proc, 75);
  --
  -- Validate performance_review_id
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_PERFORMANCE_REVIEW_ID a,b
  --
  per_pyp_bus.chk_performance_review_id
    (p_pay_proposal_id            => p_rec.pay_proposal_id
    ,p_assignment_id              => p_rec.assignment_id
    ,p_performance_review_id      => p_rec.performance_review_id
    ,p_object_version_number      => p_rec.object_version_number
    );
  --
 hr_utility.set_location(l_proc, 80);
  --
  -- Validate forced_ranking
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_FORCED_RANKING a
  --
  per_pyp_bus.chk_forced_ranking
    (p_forced_ranking             => p_rec.forced_ranking);
  --
  --
  hr_utility.set_location(l_proc, 85);
  --
  --
  -- Call descriptive flexfield validation routines
  --
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
        (p_rec                                 in out nocopy  per_pyp_shd.g_rec_type
        ,p_inv_next_sal_date_warning              out nocopy  boolean
        ,p_proposed_salary_warning                out nocopy  boolean
        ,p_approved_warning                       out nocopy  boolean
        ,p_payroll_warning                        out nocopy  boolean
        ) is

--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in perpyp.bru is provided (where
  -- relevant)
  --
  -- Validate business_group id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 12);
  --
  -- Check those columns which cannot be updated
  -- have not changed
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID /b
  -- CHK_ASSIGNMENT_ID  /b
  -- CHK_PAY_PROPOSAL_ID /c
  -- CHK_LAST_CHANGE_DATE /c
  --
  per_pyp_bus.check_non_updateable_args
    (p_rec    =>p_rec);
  --
  hr_utility.set_location (l_proc,10);
  --
  -- Validate assignment id and change_date
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_ASSIGNMENT_ID /a,c,d,e,f,g,h
  -- Rule CHK_CHANGE_DATE  /a,b,c
  --
  -- call to chk_access added for fixing bug#3839734
    per_pyp_bus.chk_access(p_assignment_id => p_rec.assignment_id
                          ,p_change_date => p_rec.change_date);
  --
  per_pyp_bus.chk_assignment_id_change_date
    (p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_assignment_id            => p_rec.assignment_id
    ,p_change_date              => p_rec.change_date
    ,p_payroll_warning          => p_payroll_warning
    ,p_object_version_number    => p_rec.object_version_number
    );
--
  hr_utility.set_location (l_proc,12);
--
  --
  --  Validate that date_to is not earlier than the start_date
  --
  --
  per_pyp_bus.chk_date_overlapping
    (p_change_date    => p_rec.change_date
    ,p_date_to      => p_rec.date_to
    );
  --
  --
/* changed for Bug#7386307 as procedure signature is changed--schowdhu */

  per_pyp_bus.validate_date_to
  (p_assignment_id  => p_rec.assignment_id,
   p_pay_proposal_id          => p_rec.pay_proposal_id,
   p_change_date    => p_rec.change_date,
    p_date_to        => p_rec.date_to,
    p_approved       => p_rec.approved
  );
  --
  --
  -- Validate proposal_reason
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_PROPOSAL_REASON  a
  --
  per_pyp_bus.chk_proposal_reason
    (p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_proposal_reason    => p_rec.proposal_reason
    ,p_change_date    => p_rec.change_date
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Validate multiple_components
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_MULTIPLE_COMPONENTS  a,c,d
  --
  per_pyp_bus.chk_multiple_components
    (p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_assignment_id            => p_rec.assignment_id
    ,p_change_date              => p_rec.change_date
    ,p_multiple_components      => p_rec.multiple_components
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate next_sal_review_date and change_date
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_CHG_NEXT_SAL_REVIEW_DATE  a
  --
  per_pyp_bus.chk_chg_next_sal_review_date
    (p_pay_proposal_id           => p_rec.pay_proposal_id
    ,p_business_group_id         => p_rec.business_group_id
    ,p_assignment_id             => p_rec.assignment_id
    ,p_change_date               => p_rec.change_date
    ,p_next_sal_review_date      => p_rec.next_sal_review_date
    ,p_object_version_number     => p_rec.object_version_number
    ,p_inv_next_sal_date_warning => p_inv_next_sal_date_warning
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate next_sal_review_date
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_NEXT_SAL_REVIEW_DATE  a
  --
  per_pyp_bus.chk_next_sal_review_date
    (p_pay_proposal_id           => p_rec.pay_proposal_id
    ,p_business_group_id         => p_rec.business_group_id
    ,p_assignment_id             => p_rec.assignment_id
    ,p_change_date       => p_rec.change_date
    ,p_next_sal_review_date      => p_rec.next_sal_review_date
    ,p_object_version_number     => p_rec.object_version_number
    ,p_inv_next_sal_date_warning => p_inv_next_sal_date_warning
    );
  --
  hr_utility.set_location(l_proc, 45);
  --
  --
  -- Validate proposed_salary
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_PROPOSED_SALARY  a,c
  --
  per_pyp_bus.chk_proposed_salary
    (p_pay_proposal_id            => p_rec.pay_proposal_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_assignment_id              => p_rec.assignment_id
    ,p_change_date                => p_rec.change_date
    ,p_proposed_salary_n          => p_rec.proposed_salary_n
    ,p_object_version_number      => p_rec.object_version_number
    ,p_proposed_salary_warning    => p_proposed_salary_warning
    -- vkodedal 19-feb-2008
    ,p_multiple_components        => p_rec.multiple_components
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate approved
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_APPROVED  b,c,e,f
  --
  per_pyp_bus.chk_approved
    (p_pay_proposal_id            => p_rec.pay_proposal_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_assignment_id              => p_rec.assignment_id
    ,p_change_date                => p_rec.change_date
    ,p_approved                   => p_rec.approved
    ,p_proposed_salary_n          => p_rec.proposed_salary_n
    ,p_object_version_number      => p_rec.object_version_number
    ,p_approved_warning           => p_approved_warning
    );
  --
  hr_utility.set_location(l_proc, 65);
  --
 -- Validate performance_review_id
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_PERFORMANCE_REVIEW_ID
  --
  per_pyp_bus.chk_performance_review_id
    (p_pay_proposal_id            => p_rec.pay_proposal_id
    ,p_assignment_id              => p_rec.assignment_id
    ,p_performance_review_id      => p_rec.performance_review_id
    ,p_object_version_number      => p_rec.object_version_number
    );
  --
 hr_utility.set_location(l_proc, 70);
  --
  -- Validate forced_ranking
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_FORCED_RANKING
  --
  per_pyp_bus.chk_forced_ranking
    (p_forced_ranking             => p_rec.forced_ranking);
  --
 hr_utility.set_location(l_proc, 75);
  --
  --
  -- Call descriptive flexfield validation routines
  --
  chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 85);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec    in  per_pyp_shd.g_rec_type
  ,p_salary_warning out nocopy boolean
 ) is

--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate delete
  -- call to chk_access added for fixing bug#3839734
    per_pyp_bus.chk_access(p_assignment_id => per_pyp_shd.g_old_rec.assignment_id
                          ,p_change_date => per_pyp_shd.g_old_rec.change_date);
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_del_pay_proposal b,c,d
  --
  chk_del_pay_proposal
     (p_pay_proposal_id     => p_rec.pay_proposal_id
     ,p_object_version_number   => p_rec.object_version_number
     ,p_salary_warning      => p_salary_warning
     );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_pay_proposal_id              in number
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_pay_proposals    pyp
     where pyp.pay_proposal_id   = p_pay_proposal_id
       and pbg.business_group_id = pyp.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'pay_proposal_id',
                             p_argument_value => p_pay_proposal_id);
  --
  if nvl(g_pay_proposal_id, hr_api.g_number) = p_pay_proposal_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function
    --
    close csr_leg_code;
    g_pay_proposal_id  := p_pay_proposal_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_pyp_bus;

/
