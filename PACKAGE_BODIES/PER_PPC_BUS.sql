--------------------------------------------------------
--  DDL for Package Body PER_PPC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PPC_BUS" as
/* $Header: peppcrhi.pkb 120.4 2006/08/16 14:04:23 abhshriv noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ppc_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id, pay_proposal_id or component_id) have been altered.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
--
--
--
Procedure check_non_updateable_args(p_rec in per_ppc_shd.g_rec_type) is
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
  if not per_ppc_shd.api_updating
                (p_component_id          => p_rec.component_id
                ,p_object_version_number => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_ppc_shd.g_old_rec.business_group_id
     then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if p_rec.pay_proposal_id <> per_ppc_shd.g_old_rec.pay_proposal_id then
     l_argument := 'pay_proposal_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if p_rec.component_id <> per_ppc_shd.g_old_rec.component_id then
     l_argument := 'component_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 9);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end check_non_updateable_args;
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
--    A valid pay_proposal
--
--  In Arguments:
--    p_pay_proposal_id
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
(p_pay_proposal_id  in    per_pay_proposals.pay_proposal_id%TYPE
) is
 --
 -- Declare local variables
 --
 l_proc              varchar2(72)  :=  g_package||'chk_access';
 l_exists            varchar2(1);
 --
 -- Cursor to check access to the assignment record
 --
 cursor csr_asg_sec is
   select null
     from per_pay_proposals pyp,
          per_assignments_f2 asg
     where pyp.pay_proposal_id = p_pay_proposal_id
       and pyp.assignment_id = asg.assignment_id
       and pyp.change_date between asg.effective_start_date
                             and asg.effective_end_date;
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
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
   hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_access;

--
--
-------------------------------------------------------------------------------
-------------------------------< chk_pay_proposal_id >-------------------------
-------------------------------------------------------------------------------
--
--
--  Description:
--   - Validates that the pay_proposal_id exists in per_pay_proposals
--   - Checks that the pay_proposal_id is not null
--   if p_validate is not 'WEAK' then it also
--   - Validates that the multiple_components flag in per_pay_proposals
--     is not set to 'N'
--   - Validates that the approved flag in per_pay_proposals table is not
--     set to 'Y'.
--
--  Pre_conditions:
--    A valid business_group_id
--
--  In Arguments:
--    p_component_id
--    p_pay_proposal_id
--    p_business_group_id
--    p_object_version_number
--    p_validation_strength
--
--  Post Success:
--    Process continues if :
--      - The pay_proposal_id exists and
--      - The multiple_components flag is not set to 'N' and
--      - The approved flag is not set to 'Y'
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--        - The pay_proposal_id not found
--	  - The multiple_components flag in per_pay_proposal is set to 'N'
--        - The approved flag is set to 'Y'
--
--  Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_pay_proposal_id
  (p_component_id
  in 	 per_pay_proposal_components.component_id%TYPE
  ,p_pay_proposal_id
  in	 per_pay_proposal_components.pay_proposal_id%TYPE
  ,p_business_group_id
  in	 per_pay_proposal_components.business_group_id%TYPE
  ,p_object_version_number
  in	 per_pay_proposal_components.object_version_number%TYPE
  ,p_validation_strength in varchar2 default 'STRONG')is
--
   l_proc    varchar2(72)  :=  g_package||'chk_pay_proposal_id';
   l_exists              varchar2(1);
   l_api_updating        boolean;
   l_approved	       	 per_pay_proposals.approved%TYPE;
   l_multiple_components per_pay_proposals.multiple_components%TYPE;
   l_business_group_id   per_pay_proposals.business_group_id%TYPE;
--
  --
  -- Cursor to check for valid pay_proposal_id and gets the value
  -- of the approved and multiple_components flag
  --
  cursor csr_pay_proposal_details is
  select pro.approved, pro.multiple_components,pro.business_group_id
  from   per_pay_proposals pro
  where  pro.pay_proposal_id 	= p_pay_proposal_id;
  --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'pay_proposal_id'
    ,p_argument_value => p_pay_proposal_id
    );
  --
  -- This following checks is done regardless of insert
  -- or update mode due to master-detail relationship
  -- between proposal and component .
  --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check the pay_proposal_id and the value of the approved and
    -- multiple_components flag.
    --
    open csr_pay_proposal_details;
    fetch csr_pay_proposal_details into l_approved,
	  l_multiple_components,l_business_group_id;
    if csr_pay_proposal_details%notfound then
       close csr_pay_proposal_details;
       hr_utility.set_location(l_proc, 3);
       per_ppc_shd.constraint_error('PER_PAY_PROPOSAL_COMPONENT_FK1');
    elsif
       l_business_group_id <> p_business_group_id then
       --
       -- The component exists for a proposal in diferent Business Group.
       --
       close csr_pay_proposal_details;
       hr_utility.set_location(l_proc, 4);
       per_ppc_shd.constraint_error('PER_PAY_PROPOSAL_COMPONENT_FK2');
     else
       close csr_pay_proposal_details;
/*
       if l_approved = 'Y' and p_validation_strength <>'WEAK' then
          hr_utility.set_location(l_proc, 5);
          hr_utility.set_message (801,'HR_51311_PPC_CANT_INS_OR_UPD');
          hr_utility.raise_error;
          --
       els */  -- allow component update.
       if l_multiple_components = 'N' and p_validation_strength <>'WEAK' then
          hr_utility.set_location(l_proc, 6);
          hr_utility.set_message (801,'HR_51312_PPC_COMP_NOT_ALLOWED');
          hr_utility.raise_error;
       end if;
       --
    end if;
    --
  hr_utility.set_location('Leaving: ' || l_proc, 7);
end chk_pay_proposal_id;
--
--
----------------------------------------------------------------------
-- |---------------< chk_approved >-----------------------------------
----------------------------------------------------------------------
--
--  Description:
--    - Validates that it cannot be set to 'Y' if the change amount
--      or change_percentage is null.
--
--  Pre-condition
--    A valid pay_proposal_id
--    The Change_amount and the Change_percentage have been validated
--    or derived as appropriate.
--
--  In arguments:
--    p_component_id
--    p_change_amount_n
--    p_change_percentage
--    p_component_reason
--    p_object_version_number
--
--  Post_success
--    Process continues if:
--    The change_amount_n and change_percentage are not null.
--
--  Post-Failure:
--    An application error is raised and processing is terminated
--    if any of the following cases are found :
--    - The change_amount_n or change_percentage are null.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
--
procedure chk_approved
  (p_component_id
  in 	per_pay_proposal_components.component_id%TYPE
  ,p_approved
  in  per_pay_proposal_components.approved%TYPE
  ,p_component_reason
  in  per_pay_proposal_components.component_reason%TYPE
  ,p_change_amount_n
  in  per_pay_proposal_components.change_amount_n%TYPE
  ,p_change_percentage
  in	per_pay_proposal_components.change_percentage%TYPE
  ,p_object_version_number
  in  per_pay_proposal_components.object_version_number%TYPE
  ) is
--
   l_proc                         varchar2(72):= g_package||'chk_approved';
   l_exists                       varchar2(1);
   l_api_updating                 boolean;
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'approved'
    ,p_argument_value   => p_approved
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'component_reason'
    ,p_argument_value   => p_component_reason
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for approved flag has changed
  --
  l_api_updating := per_ppc_shd.api_updating
       (p_component_id           => p_component_id
       ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating AND
     (per_ppc_shd.g_old_rec.approved <> p_approved)
      OR not l_api_updating)
     then
     --
     -- check that the value of the approved is either 'Y' or 'N'
     --
     if (p_approved <> 'Y' AND p_approved <> 'N') then
         hr_utility.set_location(l_proc, 2);
	 per_ppc_shd.constraint_error ('PER_PPC_APPROVED_CHK');
     end if;
      --
      -- Check that a component cannot be approved if the
      -- change_amount_n or component_reason is null
      -- CHANGED to allow change percentage to be null. This would be
      -- the case if the previously approved salary was 0.00.
      --
     hr_utility.set_location(l_proc,3);
     if (p_approved = 'Y') then
	if (p_change_amount_n IS NULL)
           then
           hr_utility.set_location(l_proc, 4);
           hr_utility.set_message(801,'HR_51269_PYP_CANT_APPR_SAL');
           hr_utility.raise_error;
        end if;
	--
	if (p_component_reason IS NULL) then
	   hr_utility.set_location(l_proc, 5);
	   hr_utility.set_message (801, 'HR_51318_PPC_CANT_APP_COMP');
	   hr_utility.raise_error;
        end if;
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving: ' || l_proc, 4);
  --
end chk_approved;
--
--
-- ---------------------------------------------------------------------
-- |-----------------------< chk_component_reason >---------------------|
-- ----------------------------------------------------------------------
--
--
--  Description:
--    Validates the value entered for component_reason exists on hr_lookups.
--    Validates that the component reason is not null
--    Validates that the component reason is unique among the component
--    reason for this salary proposal
--    Validates that the component reason cannot be updated if the approved
--    flag is 'Y'
--
--
--  Pre-conditions:
--    A valid pay_proposal_id
--
--  In Arguments:
--    p_component_id
--    p_pay_proposal_id
--    p_component_reason
--    p_approved
--    p_object_version_number
--
--  Post Success:
--    Processing continues if :
--      - The component_reason value is valid and is unique.
--      - The approved flag is not set to 'Y' if updating.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any
--      - The component_reason value is invalid or duplicated.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_component_reason
  (p_component_id     in  per_pay_proposal_components.component_id%TYPE
  ,p_pay_proposal_id  in  per_pay_proposal_components.pay_proposal_id%TYPE
  ,p_component_reason in  per_pay_proposal_components.component_reason%TYPE
  ,p_approved	      in  per_pay_proposal_components.approved%TYPE
  ,p_object_version_number
  in  per_pay_proposal_components.object_version_number%TYPE
  )
  is
--
   l_proc             varchar2(72):= g_package||'chk_component_reason';
   l_exists           varchar2(1);
   l_api_updating     boolean;
   l_change_date      date;
   l_sal_pro_approved varchar2(10);
   --
   -- Cursor to check that the component reason is unique.
   --
   cursor csr_unique_comp_reason is
   select null
   from   per_pay_proposal_components ppc
   where  ppc.pay_proposal_id	= p_pay_proposal_id
   and    ppc.component_reason	= p_component_reason;
--
   --
   -- cursor to get the change_date from the main proposal.
   -- this date is used in the lookup (i.e. New standard).
   --
   cursor csr_get_date is
   select change_date, approved
   from per_pay_proposals
   where pay_proposal_id = p_pay_proposal_id;
   --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  open csr_get_date;
  fetch csr_get_date into l_change_date, l_sal_pro_approved;
  if csr_get_date%notfound then
     close csr_get_date;
     hr_utility.set_message(801,'HR_51310_PPC_INVAL_PRO_ID');
     hr_utility.raise_error;
  end if;
     close csr_get_date;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'pay_proposal_id'
    ,p_argument_value => p_pay_proposal_id
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'approved'
    ,p_argument_value => p_approved
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'component_reason'
    ,p_argument_value => p_component_reason
    );
  --
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for component_reason  has changed
  --
  l_api_updating := per_ppc_shd.api_updating
         (p_component_id 	   => p_component_id
         ,p_object_version_number  => p_object_version_number);
  --
--  if (l_api_updating) then
     --
     -- Check that the component reason cannot be updated if the
     -- the component is already approved.
     --
--     if (per_ppc_shd.g_old_rec.approved = 'Y' AND p_approved = 'Y' AND
--	 per_ppc_shd.g_old_rec.component_reason <> p_component_reason) then
--        hr_utility.set_location(l_proc, 2);
--        hr_utility.set_message(801,'HR_51268_PYP_CANT_UPD_RECORD');
--        hr_utility.raise_error;
--     end if;
--  end if;
  --
  -- Check if sal proposal is approved
  -- then component should be approved.
  --
  if ( l_sal_pro_approved = 'Y' AND p_approved <>'Y' ) then
    hr_utility.set_location(l_proc, 2);
    hr_utility.set_message(800,'PER_SAL_APRVD_COMP_NOT_APRVD');
    hr_utility.raise_error;
  end if;
  --
  if (l_api_updating AND
     (per_ppc_shd.g_old_rec.component_reason <> p_component_reason)
     OR not l_api_updating) then
     --
     -- Check that the component reason cannot be updated if the
     -- the component is already approved.
     --
--     if (per_ppc_shd.g_old_rec.approved = 'Y' AND p_approved = 'Y'
--         AND l_api_updating) then
--        hr_utility.set_location(l_proc, 2);
--        hr_utility.set_message(801,'HR_51268_PYP_CANT_UPD_RECORD');
--        hr_utility.raise_error;
--     end if;
     --
     -- check that the p_component_reason exists in hr_lookups.
     --
     if hr_api.not_exists_in_hr_lookups
	(p_effective_date        =>  l_change_date
	 ,p_lookup_type           => 'PROPOSAL_REASON'
	 ,p_lookup_code           => p_component_reason
	 ) then
	 --  Error: Invalid proposal_reason
	 hr_utility.set_location(l_proc, 10);
	 hr_utility.set_message(801,'HR_51265_INVAL_PRO_REASON');
	 hr_utility.raise_error;
     end if;
     --
     -- Check whether the component reason is unique.
     --
        open csr_unique_comp_reason;
        fetch csr_unique_comp_reason into l_exists;
        if csr_unique_comp_reason%notfound then
           hr_utility.set_location(l_proc, 5);
           close  csr_unique_comp_reason;
        else
           hr_utility.set_location(l_proc, 6);
           close  csr_unique_comp_reason;
           per_ppc_shd.constraint_error ('PER_PAY_PROPOSAL_COMPONENT_UK2');
        end if;
  end if;
  --
  hr_utility.set_location('Leaving: ' || l_proc, 7);
  --
end chk_component_reason;
--
--
--
-- ------------------------------------------------------------------
-- |-------------< chk_change_amount_percentage >--------------------|
-- -------------------------------------------------------------------
--
--
--  Description:
--    Derives the value of change_amount_n or change_percentage if the
--    change_percentage or change_amount_n is inserted respectively.
--    Checks that the rercord cannot be updated if the approved falg is set
--    to 'Y'.
--    If both of these values are provided, then the change_percentage
--    is recalculated from the change_amount_n.
--    Round the change_percentage by 3.
--
--  Pre-conditions:
--    A valid pa_proposal_id.
--
--  In Arguments:
--    p_component_id
--    p_pay_proposal_id
--    p_change_amount_n
--    p_change_percentage
--    p_approved
--    p_object_version_number
--
--  Post Success:
--    Processing continues if
--      - The approved flag is not set to 'Y' if the record is going to
--        be updated.
--      - The pay_proposal_id is valid and a salary has already being
--        approved for this assignment.
--
--  Post Failure:
--    - The approved flag is set to 'Y" while updating.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_change_amount_percentage
  (p_component_id
  in     per_pay_proposal_components.component_id%TYPE
  ,p_pay_proposal_id
  in     per_pay_proposal_components.pay_proposal_id%TYPE
  ,p_change_amount_n
  in out nocopy per_pay_proposal_components.change_amount_n%TYPE
  ,p_change_percentage
  in out nocopy per_pay_proposal_components.change_percentage%TYPE
  ,p_approved
  in     per_pay_proposal_components.approved%TYPE
  ,p_object_version_number
  in     per_pay_proposal_components.object_version_number%TYPE
  )
  is
--
   l_exists           varchar2(1);
   l_api_updating     boolean;
   l_proposed_salary  number;
   l_change_amount_n
per_pay_proposal_components.change_amount_n%TYPE;
   l_change_percentage
per_pay_proposal_components.change_percentage%TYPE;
   l_date              per_pay_proposals.change_date%TYPE;
   l_assignment_id    number;
   l_business_group_id number;
   l_change_date      date;
   l_prev_date        date;
   l_proc      varchar2(72):=
g_package||'chk_change_amount_percentage';
   --
   --
   -- Cursor to get the last approved salary proposal.
   --
   -- BEGIN MODIFICATION FOR BUG 4260464
   --
   -- Modify cursor to join directly to lower subquery.  This allows the
   -- appropriate index to be used instead of a full table scan.
   --
   --  CURSOR csr_last_proposed_salary is
   --   select pro.proposed_salary_n
   --   from per_pay_proposals pro
   --   where pro.change_date=(select max(pro2.change_date)
   --                          from per_pay_proposals pro2
   --                          where pro2.assignment_id=pro.assignment_id
   --                          and pro2.approved='Y'
   --                          and pro2.pay_proposal_id<>p_pay_proposal_id)
   --   and pro.assignment_id = (select pro3.assignment_id
   --                            from per_pay_proposals pro3
   --                            where pro3.pay_proposal_id=p_pay_proposal_id);
   --
   CURSOR csr_dates(p_pay_proposal_id number) is
             select pro2.assignment_id, pro2.business_group_id,
                    pro2.change_date, pro2.change_date-1 prev_date
             from per_pay_proposals pro2
             where pro2.pay_proposal_id = p_pay_proposal_id;

   CURSOR csr_proposal_info(p_assignment_id number, p_query_date date)
is
     select pay_proposal_id, change_date, proposed_salary_n
       ,nvl(ppb.pay_annualization_factor,
       PER_SALADMIN_UTILITY.get_pay_annualization_factor
        (ppp.assignment_id, change_date, ppb.pay_annualization_factor,
ppb.pay_basis)) annualization_factor,
           pet.input_currency_code as currency_code, ppb.pay_basis
frequency
     from per_pay_proposals ppp
  	      ,per_all_assignments_f paa
	      ,per_pay_bases ppb
          ,pay_input_values_f piv
	      ,pay_element_types_f pet
     where
      ppp.assignment_id = p_assignment_id
     and  p_query_date
     between change_date and nvl(date_to, hr_general.end_of_time)
     and  paa.assignment_id = ppp.assignment_id
     and  ppp.change_date
     between paa.effective_start_date and paa.effective_end_date
     and paa.pay_basis_id = ppb.pay_basis_id
     and ppb.input_value_id = piv.input_value_id
     and ppp.change_date
     between piv.effective_start_date and piv.effective_end_date
     and   piv.element_type_id = pet.element_type_id
     and ppp.change_date
     between pet.effective_start_date and pet.effective_end_date;

     CURSOR csr_last_proposed_salary is
               select p1.proposed_salary_n
                 from per_pay_proposals p1,
                      (select pro2.assignment_id, pro2.change_date-1 prev_date
                       from per_pay_proposals pro2
                       where pro2.pay_proposal_id = p_pay_proposal_id ) p2
                where p1.date_to = prev_date
                  and p1.assignment_id = p2.assignment_id;

    r_old csr_proposal_info%rowtype;
    r_new csr_proposal_info%rowtype;
    l_currency_rate       number := 1;
    l_annual_rate         number := 1;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check for mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'pay_proposal_id'
    ,p_argument_value   => p_pay_proposal_id
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
  -- b) The value for change_amount_n or change_percentage has changed
  --
  l_api_updating := per_ppc_shd.api_updating
       (p_component_id           => p_component_id
       ,p_object_version_number  => p_object_version_number);
  --

  if (l_api_updating) then
  --
  -- Check that the change_amount_n and change_percentage cannot be
  -- updated if the the component is already approved.
  --
      if (per_ppc_shd.g_old_rec.approved = 'Y' AND p_approved = 'Y' AND
          (per_ppc_shd.g_old_rec.change_amount_n <> p_change_amount_n OR
	  per_ppc_shd.g_old_rec.change_percentage <> p_change_percentage))
	  then
          hr_utility.set_location(l_proc, 1);
--  allow Component update.
--    	  hr_utility.set_message(801,'HR_51268_PYP_CANT_UPD_RECORD');
--	  hr_utility.raise_error;
      end if;
      --
      -- Check to see which of the two attribue has been updated.
      --
  end if;
   --
   --
   l_change_amount_n := p_change_amount_n;
   l_change_percentage := p_change_percentage;
   --
   if (l_api_updating AND
(nvl(per_ppc_shd.g_old_rec.change_amount_n,hr_api.g_number)
       <> nvl(p_change_amount_n, hr_api.g_number) OR
         nvl(per_ppc_shd.g_old_rec.change_percentage,hr_api.g_number)
<>
	 nvl(p_change_percentage ,hr_api.g_number))
         OR  not l_api_updating) then
	 --
	 -- Don't do anything if both are null.
	 --
     if ( p_change_amount_n IS  NULL AND  p_change_percentage IS  NULL)
	then
	hr_utility.set_location(l_proc, 2);
     else
      open csr_dates(p_pay_proposal_id);
      fetch csr_dates into l_assignment_id, l_business_group_id,
                           l_change_date, l_prev_date;
      close csr_dates;
      --
      --
      --
      open csr_proposal_info(l_assignment_id, l_change_date);
      fetch csr_proposal_info into r_new;
      close csr_proposal_info;
      --
      open csr_proposal_info(l_assignment_id, l_prev_date);
      fetch csr_proposal_info into r_old;
      close csr_proposal_info;
      --
      --
      --
      if (r_old.currency_code <> r_new.currency_code)
      then
        l_currency_rate :=
           hr_currency_pkg.get_rate_sql(r_old.currency_code,
                                     r_new.currency_code ,
                                     l_change_date,
hr_currency_pkg.get_rate_type(l_business_group_id,l_change_date,'P'));
      end if;

     if (r_old.annualization_factor<>r_new.annualization_factor
         and r_new.annualization_factor<>0) then
     l_annual_rate :=
r_old.annualization_factor/r_new.annualization_factor;
     end if;

     l_proposed_salary := r_old.proposed_salary_n * l_annual_rate *
l_currency_rate;
     /*
     --
     -- get the last approved salary proposal
     --
     open csr_last_proposed_salary;
     fetch csr_last_proposed_salary into l_proposed_salary;
     close csr_last_proposed_salary;
     */

       if (l_proposed_salary is not null) then
       --
       -- recalculate the  change_amount_n from change_percentage
       --
       if(p_change_amount_n IS NULL AND p_change_percentage IS NULL) then
                    l_change_amount_n := 0;
                    l_change_percentage := 0;
       elsif (p_change_amount_n IS NULL and p_change_percentage IS NOT NULL) then
                    l_change_amount_n := p_change_percentage*l_proposed_salary/100 ;
                    l_change_percentage := p_change_percentage;
       elsif (p_change_amount_n IS NOT NULL and p_change_percentage IS NULL AND l_proposed_salary <>0) then
                    l_change_percentage :=(p_change_amount_n*100)/l_proposed_salary;
                    l_change_amount_n := p_change_amount_n;
      elsif (p_change_amount_n IS NOT NULL and p_change_percentage IS NOT NULL) then
                    l_change_percentage := p_change_percentage;
                    l_change_amount_n := p_change_amount_n;
      end if;


       --
     end if;
   end if;  -- For check percentage and amount null check
   --
  end if;
  --
  -- set output parameters
  --
  p_change_amount_n 	:= l_change_amount_n;
  p_change_percentage	:= l_change_percentage;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
end chk_change_amount_percentage;
--
--
-- -------------------------------------------------------------------
--|------------------< chk_delete_component >-----------------------|-
----------------------------------------------------------------------
--
--
-- Description
--   - Validates that a component of an approved proposal cannot
--     be deleted.
--
-- Pre-Condition
--   A valid pay_proposal_id
--
-- Post_success
--   The process continues
--
-- Post_Failure
--   An error message is raised if the approved flag in per_pay_proposal
--   is 'Y'
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_delete_component
   (p_component_id
   in	  per_pay_proposal_components.component_id%TYPE
   ) is
--
  l_exists	varchar2(1);
  l_proc	varchar2(72):= g_package || 'chk_delete_component';
  l_pay_proposal_id 	per_pay_proposals.pay_proposal_id%TYPE;
  --
  -- Cursor to check the status of the per_pay-proposal apprved flag.
  --
  cursor csr_proposal_status is
  select null
  from   per_pay_proposals pro
  where  pro.pay_proposal_id = l_pay_proposal_id
  and    pro.approved	     = 'Y';
  --
  -- Cursor to check that this component exists for this proposal
  --
  Cursor csr_comp_exists is
  select pay_proposal_id
  from   per_pay_proposal_components  comp
  where  comp.component_id = p_component_id;
  --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'component_id'
    ,p_argument_value => p_component_id
    );
  --
  -- Check that the component exists
  --
  open csr_comp_exists;
  fetch csr_comp_exists into l_pay_proposal_id;
  if csr_comp_exists%notfound then
     close csr_comp_exists;
     hr_utility.set_location(l_proc, 2);
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  close csr_comp_exists;
  --
  -- Check that the proposal is not already approved.
  --
  open csr_proposal_status;
  fetch csr_proposal_status into l_exists;
  if csr_proposal_status%notfound then
     hr_utility.set_location(l_proc, 2);
     close csr_proposal_status;
  else
     hr_utility.set_location(l_proc, 3);
     close csr_proposal_status;
--     hr_utility.set_message(801,'HR_51315_PPC_CANT_DEL_RECORD');
--     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location ('Leaving: ' || l_proc, 4);
  --
end chk_delete_component;
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
  (p_rec in per_ppc_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.component_id is not null) and (
     nvl(per_ppc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_ppc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.component_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PAY_PROPOSAL_COMPONENTS'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- ------------------------------------------------------------------
-- |------------------< insert_validate >----------------------------|
-- ------------------------------------------------------------------
Procedure insert_validate(p_rec in out nocopy per_ppc_shd.g_rec_type
                         ,p_validation_strength in varchar2 default 'STRONG') is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping to the
  -- appropriate Business Rules in perpyp.bru is provided (where
  -- relevant)
  --
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
  -- Validate pay_proposal_id
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_PAY_PROPOSAL_ID /a,c,d,e
  --
  per_ppc_bus.chk_pay_proposal_id
    (p_component_id		=> p_rec.component_id
    ,p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_validation_strength      => p_validation_strength
    );
  --
  -- call to chk_access added for fixing bug#3839734
    per_ppc_bus.chk_access(p_pay_proposal_id => p_rec.pay_proposal_id);
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_COMPONENT_REASON /a,b,c
  --
  per_ppc_bus.chk_component_reason
    (p_component_id             => p_rec.component_id
    ,p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_component_reason		=> p_rec.component_reason
    ,p_approved			=> p_rec.approved
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_CHANGE_AMOUNT /a
  -- Rule CHK_CHANGE_PERCENTAGE /a
  -- Rule CHK_CHANGE_AMOUNT_PERCENTAGE /a,b
  --
  per_ppc_bus.chk_change_amount_percentage
    (p_component_id             => p_rec.component_id
    ,p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_change_amount_n		=> p_rec.change_amount_n
    ,p_change_percentage	=> p_rec.change_percentage
    ,p_approved                 => p_rec.approved
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 25);
  --
 --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_APPROVED /a,b,c
  --
  per_ppc_bus.chk_approved
    (p_component_id             => p_rec.component_id
    ,p_approved                 => p_rec.approved
    ,p_component_reason		=> p_rec.component_reason
    ,p_change_amount_n          => p_rec.change_amount_n
    ,p_change_percentage        => p_rec.change_percentage
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Call descriptive flexfield validation routines
  --
  per_ppc_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 35);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in out nocopy per_ppc_shd.g_rec_type
                         ,p_validation_strength in varchar2 default 'STRONG') is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping to the
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
  -- CHK_COMPONENT_ID	 /c
  -- CHK_PAY_PROPOSAL_ID /b
  -- CHK_BUSINESS_GROUP_ID /b
  --
  per_ppc_bus.check_non_updateable_args
     (p_rec              =>p_rec);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate pay_proposal_id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PAY_PROPOSAL_id /e
  --
per_ppc_bus.chk_pay_proposal_id
    (p_component_id             => p_rec.component_id
    ,p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_validation_strength      => p_validation_strength
    );
  --
  -- call to chk_access added for fixing bug#3839734
    per_ppc_bus.chk_access(p_pay_proposal_id => p_rec.pay_proposal_id);
  --
 --
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_COMPONENT_REASON /a,b,d
  --
  per_ppc_bus.chk_component_reason
    (p_component_id             => p_rec.component_id
    ,p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_component_reason         => p_rec.component_reason
    ,p_approved                 => p_rec.approved
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_CHANGE_AMOUNT /a,b
  -- Rule CHK_CHANGE_PERCENTAGE /a
  -- Rule CHK_CHANGE_AMOUNT_PERCENTAGE /a,b
  --
  per_ppc_bus.chk_change_amount_percentage
    (p_component_id             => p_rec.component_id
    ,p_pay_proposal_id          => p_rec.pay_proposal_id
    ,p_change_amount_n          => p_rec.change_amount_n
    ,p_change_percentage        => p_rec.change_percentage
    ,p_approved                 => p_rec.approved
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 25);
 --
 --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_APPROVED /b,c
  --
  per_ppc_bus.chk_approved
    (p_component_id             => p_rec.component_id
    ,p_approved                 => p_rec.approved
    ,p_component_reason         => p_rec.component_reason
    ,p_change_amount_n          => p_rec.change_amount_n
    ,p_change_percentage        => p_rec.change_percentage
    ,p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Call descriptive flexfield validation routines
  --
  per_ppc_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_ppc_shd.g_rec_type,
  p_validation_strength                in varchar2 default 'STRONG') is
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
    per_ppc_bus.chk_access(p_pay_proposal_id => per_ppc_shd.g_old_rec.pay_proposal_id);
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_DELETE_COMPONENT /a
  --
  if    (p_validation_strength='WEAK') THEN
    hr_utility.set_location(' WEAK:'||l_proc, 7);
  elsif (p_validation_strength='STRONG') THEN
    hr_utility.set_location(' STRONG:'||l_proc, 8);
    chk_delete_component
      (p_component_id		=> p_rec.component_id
      );
  else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '1');
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_component_id              in number
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups         pbg
         , per_pay_proposal_components ppc
     where ppc.component_id      = component_id
       and pbg.business_group_id = ppc.business_group_id;
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
                             p_argument       => 'component_id',
                             p_argument_value => p_component_id);
  --
  if nvl(g_component_id, hr_api.g_number) = p_component_id then
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
    g_component_id  := p_component_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_ppc_bus;

/
