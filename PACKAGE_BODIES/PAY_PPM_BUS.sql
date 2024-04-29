--------------------------------------------------------
--  DDL for Package Body PAY_PPM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPM_BUS" as
/* $Header: pyppmrhi.pkb 120.3.12010000.5 2010/03/30 06:46:19 priupadh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_ppm_bus.';  -- Global package name
--
--  ---------------------------------------------------------------------------
--  |------------------<  balance_remunerative   >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks if a balance type is remunerative
--
--  Pre-conditions:
--    The in arguments must exist and must not be null
--
--  In Arguments:
--    p_org_payment_method_id
--    p_effective_date
--
--  Post Success:
--    If the related balance type is remunerative then
--    returns true, then processing continues.
--
--    If the related balance type is non-remunerative then
--    returns false, then processing continues.
--
--  Post Failure:
--    None
--
--  Access Status:
--    Internal Table Handler Use Only.
--
function balance_remunerative
  (p_org_payment_method_id   in
   pay_personal_payment_methods_f.org_payment_method_id%type
  ,p_effective_date          in   date
  )
  return boolean is
--
  l_exists   varchar2(1);
  l_proc     varchar2(72)  :=  g_package||'balance_remunerative';

--  Check if the related balance type is remunerative

  cursor csr_chk_blt is
    select null
    from pay_balance_types blt,
         pay_defined_balances dfb,
         pay_org_payment_methods_f opm
    where blt.assignment_remuneration_flag = 'Y'
      and blt.balance_type_id = dfb.balance_type_id
      and dfb.defined_balance_id = opm.defined_balance_id
      and opm.org_payment_method_id = p_org_payment_method_id
      and p_effective_date between opm.effective_start_date
                               and opm.effective_end_date;
--
begin
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org payment method id'
    ,p_argument_value => p_org_payment_method_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Check if the related balance type is remunerative
  --
  open csr_chk_blt;
  fetch csr_chk_blt into l_exists;
  if csr_chk_blt%found then
    close csr_chk_blt;
    return true;
  else
    close csr_chk_blt;
    return false;
  end if;
end balance_remunerative;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  return_effective_end_date >--------------------------|
--  ---------------------------------------------------------------------------
--
function return_effective_end_date
  (p_datetrack_mode             in     varchar2,
   p_effective_date             in     date,
   p_personal_payment_method_id in     number,
   p_org_payment_method_id      in     number,
   p_assignment_id              in     number,
   p_run_type_id                in     number   default null,
   p_priority                   in     number,
   p_business_group_id          in     number,
   p_payee_id                   in     number   default null,
   p_payee_type                 in     varchar2 default null,
   p_validation_start_date      in     date,
   p_validation_end_date        in     date)
return date is
  --
    l_proc      varchar2(72) := g_package||'return_effective_end_date';
    l_rtn_date  date;
    --
    -- select the maximum eligibility date for the payment method
    -- taking into account the assignment (which could change payrolls)
    -- and organization payment method usages. to do this we must for
    -- each assignment row which is to a payroll ensure that the row
    -- has a corresponding usage which will last for either the
    -- duration or part duration of the assignment. if a usage only
    -- lasts for part of the assignment duration then the usage end
    -- date will be the last eligible row. if for the assignment
    -- duration a usage doesn't exist at all then the previous
    -- assignment eligible row must be used. Consistency is ensured because
    -- pay_org_pay_method_usages_f must have a table SHARE lock on it before
    -- this routine is called.
    --
    function return_usage_date
             return date is
      --
      cursor csr_check_org_method is
        select  1
        from    pay_org_payment_methods_f opm
        where   opm.org_payment_method_id = p_org_payment_method_id
        and     p_effective_date
        between opm.effective_start_date
        and     opm.effective_end_date;
      --
      cursor asg_sel is
        select pa.payroll_id,
               pa.effective_start_date,
               pa.effective_end_date
        from   per_all_assignments_f pa
        where  pa.assignment_id         = p_assignment_id
        and    pa.business_group_id + 0 = p_business_group_id
        and    pa.effective_end_date >= p_effective_date
        order by pa.effective_start_date;
      --
      cursor popmu_sel(l_payroll_id  in number,
                       l_start_range in date,
                       l_end_range   in date) is
        select min(popmu.effective_start_date),
               max(popmu.effective_end_date)
        from   pay_org_pay_method_usages_f popmu
        where  popmu.payroll_id            = l_payroll_id
      	and    popmu.org_payment_method_id = p_org_payment_method_id
        and    popmu.effective_start_date <= l_end_range
        and    popmu.effective_end_date   >= l_start_range;
      --
      l_previous_payroll_id pay_payrolls_f.payroll_id%TYPE;
      l_start_range         date;
      l_end_range           date;
      l_popmu_start_date    date;
      l_popmu_end_date      date;
      l_popmu_date          date;
      l_dummy               number;
      l_proc	            varchar2(72) := g_package||'return_usage_date';
      --
    begin
      hr_utility.set_location('Entering:'||l_proc, 5);
      l_previous_payroll_id := null;
      -- get assignment rows in effective order for processing
      <<loop1>>
      for sel1 in asg_sel loop
        if sel1.payroll_id is not null then
          hr_utility.set_location(l_proc, 10);
          l_previous_payroll_id := nvl(l_previous_payroll_id, sel1.payroll_id);
          -- as a payroll exists for the assignment we must set the
          -- working range dates
          l_start_range := greatest(p_effective_date,
                                    sel1.effective_start_date);
          l_end_range   := sel1.effective_end_date;
          -- select the min and max usage dates which overlap the
          -- assignment range
          open popmu_sel(sel1.payroll_id, l_start_range, l_end_range);
          fetch popmu_sel into l_popmu_start_date, l_popmu_end_date;
          -- the fetch will always return a row because of the
          -- min/max functions used. if a row isn't found then the
          -- l_popmu_start_date and l_popmu_end_date variables will
          -- contain null
          close popmu_sel;
          --
          if (l_popmu_start_date <= l_start_range and
              l_popmu_end_date   >= l_end_range) then
            -- the usage exists for the duration of the assignment
            -- therefore we set the date to the current assignment end
            -- range date
            l_popmu_date := l_end_range;
          else
            -- the usage does not exist for duration of the assignment
            -- range
            if (l_popmu_start_date <= l_start_range) then
              -- the usage exists at the start of the assignment range
              -- therefore we set the date to the end of the usage
              l_popmu_date := l_popmu_end_date;
            else
              -- the usage does not exist at the start of the
              -- assignment range therefore it must of existed for
              -- the previous assignment range. set the date to the
              -- end of the last assignment range
              if (l_start_range > p_validation_start_date) then
                l_popmu_date := l_start_range - 1;
              else
                l_popmu_date := null;
              end if;
            end if;
            exit loop1;
          end if;
          if (sel1.payroll_id <> l_previous_payroll_id) then
            -- the payroll has changed.
            l_previous_payroll_id := sel1.payroll_id;
          end if;
        else
          --
          -- as an employee assignment row has been selected but is not
          -- to a payroll we must determine if this is the first returned
          -- row (we can determine the first row by examining the value of
          -- l_previous_payroll_id). if it is the first row then we must
          -- error as the assignment is NOT to a payroll. if a previous
          -- payroll exists then the employee assignment has been for a
          -- payroll and we must just exit the loop.
          --
          if l_previous_payroll_id is null or
           (sel1.effective_start_date = p_validation_start_date) then
            hr_utility.set_message(801, 'HR_6500_ASS_NO_PAYROLL');
            hr_utility.raise_error;
          else
            exit loop1;
          end if;
        end if;
      end loop loop1;
      --
      -- check to see if the assignment exists
      --
      if l_previous_payroll_id is null then
        --  the assignment doesn't exists
        hr_utility.set_message(801, 'HR_7348_PPM_ASSIGNMENT_INVALID');
        hr_utility.raise_error;
      end if;
      --
      -- if the returning date is null then we must error as either a
      -- usage or method does not exist
      --
      if l_popmu_date is null then
        -- check to see if the method exists
        open csr_check_org_method;
        fetch csr_check_org_method into l_dummy;
        if csr_check_org_method%notfound then
          -- an organization method does not exist
          close csr_check_org_method;
          hr_utility.set_message(801, 'HR_7347_PPM_INVALID_PAY_TYPE');
          hr_utility.raise_error;
        end if;
        close csr_check_org_method;
        -- usages cannot exist
        hr_utility.set_message(801, 'HR_7869_PPM_USAGE_INVALID');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc, 20);
      return(l_popmu_date);
    end return_usage_date;
    --
    -- if the payee_id is not null and the payee_type = 'P' then
    -- the max(eed) of person where the person_id = payee_id.
    -- need to lock the row selected (i.e. use select..for update).
    -- Note: this violates lock ladder order upon INSERT as person should
    -- be locked before assignment. However it's highly unlikely that this
    -- combination of assignment and person would be locked elsewhere.
    function return_payee_date
             return date is
    --
      cursor pp_sel is
        select pp1.effective_end_date
        from   per_people_f pp1
        where  pp1.person_id = p_payee_id
        and    pp1.effective_start_date >= p_effective_date
        and    pp1.effective_end_date =
              (select max(pp2.effective_end_date)
               from   per_people_f pp2
               where  pp2.person_id = p_payee_id
               and    pp2.effective_start_date >= p_effective_date)
        for    update nowait;
    --
      l_proc 	   varchar2(72)	:= g_package||'return_payee_date';
      l_payee_date date		:= hr_api.g_eot;
    --
    begin
    --
      hr_utility.set_location('Entering:'||l_proc, 5);
      --
      if (p_payee_id is not null and p_payee_type = 'P') then
        open pp_sel;
        fetch pp_sel into l_payee_date;
        if pp_sel%notfound then
          -- person doesn't exist for the p_payee_id therefore error
          close pp_sel;
          hr_utility.set_message(801, 'HR_7846_PPM_INV_PERSON');
          hr_utility.raise_error;
        end if;
        close pp_sel;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      return(l_payee_date);
    --
    end return_payee_date;
    --
    -- the (esd - 1) of the earliest future (remunerative) row in PPM which has the same
    -- priority. Lock the selected row.
    --
    function return_priority_date
             return date is
    --
      cursor ppm_sel is
        select ppm.effective_start_date -1
        from   pay_personal_payment_methods_f ppm
        where  ppm.assignment_id = p_assignment_id
        and    ppm.priority      = p_priority
        and    nvl(ppm.run_type_id,-9999)   = nvl(p_run_type_id,-9999)
        and    (ppm.priority <> 1
                or exists
                   (select null
                    from   pay_org_payment_methods_f opm
                    ,      pay_defined_balances      db
                    ,      pay_balance_types         bt
                    where opm.org_payment_method_id = ppm.org_payment_method_id
                    and   p_effective_date between
                          opm.effective_start_date and opm.effective_end_date
                    and   db.defined_balance_id = opm.defined_balance_id
                    and   bt.balance_type_id    = db.balance_type_id
                    and   bt.assignment_remuneration_flag = 'Y'
                   )
                )
        and   (ppm.personal_payment_method_id <>
               p_personal_payment_method_id
        or     p_personal_payment_method_id is null)
        and    ppm.effective_start_date =
              (select  min(ppm2.effective_start_date)
               from    pay_personal_payment_methods_f ppm2
               where  (ppm2.personal_payment_method_id <>
                       p_personal_payment_method_id
               or      p_personal_payment_method_id is null)
               and     ppm2.assignment_id = p_assignment_id
               and     ppm2.priority      = p_priority
               and     nvl(ppm2.run_type_id,-9999) = nvl(p_run_type_id,-9999)
               and     (ppm2.priority <> 1
                       or exists
                          (select null
                           from   pay_org_payment_methods_f opm
                           ,      pay_defined_balances      db
                           ,      pay_balance_types         bt
                           where opm.org_payment_method_id = ppm2.org_payment_method_id
                           and   p_effective_date between
                                 opm.effective_start_date and opm.effective_end_date
                           and   db.defined_balance_id = opm.defined_balance_id
                           and   bt.balance_type_id    = db.balance_type_id
                           and   bt.assignment_remuneration_flag = 'Y'
                          )
                       )
               and     (ppm2.effective_start_date >= p_effective_date or
                        p_effective_date between
                          ppm2.effective_start_date and ppm2.effective_end_date
                       ))
        for    update nowait;
    --
      l_proc          varchar2(72) := g_package||'return_priority_date';
      l_priority_date date         := hr_api.g_eot;
    --
    begin
    --
      hr_utility.set_location('Entering:'||l_proc, 5);
      --
      if p_priority is null then
        hr_utility.set_message(801, 'HR_7357_PPM_PRIORITY_NULL');
        hr_utility.raise_error;
      end if;
      if balance_remunerative(p_org_payment_method_id, p_effective_date) then
        open ppm_sel;
        fetch ppm_sel into l_priority_date;
        close ppm_sel;
        if (l_priority_date < p_validation_start_date) then
          hr_utility.set_message(801, 'HR_6225_PAYM_DUP_PRIORITY');
          hr_utility.raise_error;
        end if;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      return(l_priority_date);
    --
    end return_priority_date;
    --
    -- Check that the assignment is for an employee before inserting a new
    -- personal payment method.
    --
    procedure chk_assignment_type
      (p_assignment_id         in number
      ,p_effective_date        in date) is
     --
     l_type           per_all_assignments_f.assignment_type%type;
     l_proc           varchar2(72)  :=  g_package||'chk_assignment_type';
     --
     cursor csr_ass_type is
       select asg.assignment_type
       from per_all_assignments_f asg
       where asg.assignment_id = p_assignment_id
       and   p_effective_date between asg.effective_start_date
			      and     asg.effective_end_date;
     --
    begin
      hr_utility.set_location('Entering:'|| l_proc, 1);
      --
      hr_utility.set_location(l_proc, 2);
      open csr_ass_type;
      fetch csr_ass_type
      into l_type;
      if l_type <> 'E' then
        close csr_ass_type;
        hr_utility.set_message(801, 'HR_7951_PPM_ASS_TYPE_NOT_EMP');
        hr_utility.raise_error;
      end if;
      close csr_ass_type;
      --
      hr_utility.set_location(' Leaving:'|| l_proc, 5);
    end chk_assignment_type;
--
  begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    -- check mandatory arguments
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'assignment_id',
       p_argument_value => p_assignment_id);
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'business_group_id',
       p_argument_value => p_business_group_id);
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'org_payment_method_id',
       p_argument_value => p_org_payment_method_id);
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'datetrack_mode',
       p_argument_value => p_datetrack_mode);
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'effective_date',
       p_argument_value => p_effective_date);
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    if (p_datetrack_mode = 'INSERT') then
      chk_assignment_type
	(p_assignment_id  => p_assignment_id
	,p_effective_date => p_effective_date);
    end if;
    --
    if (p_datetrack_mode = 'INSERT'             or
        p_datetrack_mode = 'DELETE_NEXT_CHANGE' or
        p_datetrack_mode = 'FUTURE_CHANGE')     then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      -- determine the least date
      l_rtn_date := least(return_usage_date,
                          return_payee_date,
                          return_priority_date,
                          p_validation_end_date);
      --
      -- ensure that the returning date is not null
      --
      if l_rtn_date is null then
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP','10');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      return(l_rtn_date);
    else
      hr_utility.set_location(' Leaving:'||l_proc, 20);
      return(p_validation_end_date);
    end if;
  end return_effective_end_date;
--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_org_payment_method_id  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the org_payment_method_id entered by carrying
--    out the following:
--	- check that the organisation payment method is valid for the
--	  related payment type
--    Note this is an insert only procedure.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_business_group_id
--    p_personal_payment_method_id
--    p_org_payment_method_id
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If the org_payment_method_id is valid then
--    processing continues
--
--  Post Failure:
--    If any of the following cases are true then
--    an application error will be raised and processing is terminated
--
--      a) the organization payment method is not valid for the related payment
--         type where the territory code matches the legislation of the business
--         group or where no territory code is specified (currently just
--         Cash) then
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_org_payment_method_id
  (p_business_group_id     in number
  ,p_org_payment_method_id in number
  ,p_effective_date        in date) is
 --
 l_exists         varchar2(1);
 l_proc           varchar2(72)  :=  g_package||'chk_org_payment_method_id';
 --
 -- Bug 4644507. Removed the usage of per_business_groups from the cursor.
 cursor csr_is_valid is
   select  null
   from    pay_org_payment_methods_f opm,
           pay_payment_types ppt
   where   opm.org_payment_method_id = p_org_payment_method_id
   and     p_effective_date
   between opm.effective_start_date
   and     opm.effective_end_date
   and     ppt.payment_type_id   = opm.payment_type_id;
 --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org_payment_method_id'
    ,p_argument_value => p_org_payment_method_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date);
  --
  hr_utility.set_location(l_proc, 2);
  open csr_is_valid;
  fetch csr_is_valid into l_exists;
  if csr_is_valid%notfound then
    close csr_is_valid;
    hr_utility.set_message(801, 'HR_7347_PPM_INVALID_PAY_TYPE');
    hr_utility.raise_error;
  end if;
  close csr_is_valid;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 6);
end chk_org_payment_method_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_defined_balance_id  >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_defined_balance_id
  (p_business_group_id                  in number,
   p_assignment_id                      in number,
   p_personal_payment_method_id         in number,
   p_org_payment_method_id		in number,
   p_effective_date			in date,
   p_object_version_number              in number,
   p_payee_type				in varchar2,
   p_payee_id				in number) is
  --
  l_proc                varchar2(72) := g_package||'chk_defined_balance_id';
  l_exists              varchar2(1);
  l_api_updating        boolean;
  --
  -- Check if the personal payment method is a garnishment.
  --
  cursor csr_chk_garnishment is
    select null
    from   pay_org_payment_methods_f opm
    where  opm.org_payment_method_id = p_org_payment_method_id
    and    p_effective_date between opm.effective_start_date
                            and     opm.effective_end_date
    and    opm.defined_balance_id is null;
  --
  -- Check the category of the payment.
  --
  cursor csr_chk_pay_type is
    select pyt.category
    from pay_org_payment_methods_f opm
    ,    pay_payment_types pyt
    where p_org_payment_method_id = opm.org_payment_method_id
      and opm.payment_type_id = pyt.payment_type_id
      and p_effective_date between opm.effective_start_date
                               and opm.effective_end_date;
  --
  --              Local Variables
  --
  l_category pay_payment_types.category%type;
  --
  --
  --  -------------------------------------------------------------------------
  --  |---------------------<  chk_payee_id_and_type  >-----------------------|
  --  -------------------------------------------------------------------------
  --
  --  Description:
  --  This procedure checks that, for garnshments, if PAYEE_TYPE is 'O', then
  --  PAYEE_ID refers to a valid and active organization, in the same business
  --  group as the personal payment method. If PAYEE_TYPE is 'P', then the
  --  procedure checks that PAYEE_ID refers to a valid person and that this
  --  person is a contact with a contact relationship to the owner of the
  --  personal payment method, of the correct type for garnishments.
  --
  --  Pre-conditions:
  --    None
  --
  --  In Arguments:
  --
  --  Post Success:
  --    If PAYEE_TYPE is 'O' and PAYEE_ID refers to a valid organization which
  --    is active and in the same business group as the personal payment
  --    method, then processing continues.
  --    If PAYEE_TYPE is 'P' and PAYEE_ID refers to a valid person, who is a
  --    contact with a contact relationship to the owner of the personal
  --    payment method, and of the correct type for garnishments, then
  --    processing continues.
  --
  --  Post Failure:
  --    If any of the following cases are true then an application error will
  --    be raised and processing terminated:
  --
  --      a) PAYEE_TYPE is 'O' and PAYEE_ID is not a valid organization, or
  --         a non-active organization or an organization not in the correct
  --         business group.
  --
  --      b) PAYEE_TYPE is 'P' and PAYEE_ID is not a valid person or not a
  --	   contact with a contact relationship of the correct type.
  --
  --	c) PAYEE_TYPE is neither 'O' nor 'P'.
  --
  --  Access Status:
  --    Internal Table Handler Use Only.
  -- -------------------------------------------------------------------------
  procedure chk_payee_id_and_type is
  --
    l_proc		varchar2(72) := g_package||'chk_payee_id_and_type';
    l_business_group_id	number(15);
    l_valid               varchar2(1);
  --
  -- Check that the organization is valid and is in the same business group
  -- as the personal payment method.
  --
  -- Bug 6617741 : Changed the cursor to fetch record from table
  -- hr_all_organization_units instead of view hr_organization_units
  -- to bypass the check for valid organization.

    cursor csr_chk_organization is
      select oru.business_group_id
      from   hr_all_organization_units oru
      where  oru.organization_id = p_payee_id
      and    p_effective_date between oru.date_from and
  		 		      nvl(oru.date_to, hr_api.g_eot);
  --
  -- Check that the organization is active and of type 'HR_PAYEE'
  --
    cursor csr_chk_organization_active is
      select null
      from   hr_organization_information ori
      where  ori.organization_id = p_payee_id
      and    ori.org_information_context = 'CLASS'
      and    ori.org_information1 = 'HR_PAYEE'
      and    ori.org_information2 = 'Y';
  --
  -- Check that the person is valid
  --
    cursor csr_chk_person is
      select null
      from   per_people_f per
      where  per.person_id = p_payee_id
      and    p_effective_date between per.effective_start_date
	   		      and     per.effective_end_date;
  --
  -- Check that the person is a contact, with a valid contact relationship
  -- type
  --
    cursor csr_chk_contact is
      select null
      from   per_contact_relationships ctr,
 	     per_all_assignments_f asg
      where  ctr.contact_person_id = p_payee_id
      and    ctr.person_id = asg.person_id
      and    asg.assignment_id = p_assignment_id
      and    p_effective_date between asg.effective_start_date
  		 	      and     asg.effective_end_date
      and    ctr.third_party_pay_flag = 'Y';
  --
  begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    -- Ensure that all mandatory arguments are not null.
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'business_group_id'
      ,p_argument_value => p_business_group_id
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'assignment_id'
      ,p_argument_value => p_assignment_id
      );
    --
    -- If PAYEE_TYPE is 'O' then check that PAYEE_ID refers to a valid
    -- organization, and that this organization is in the same business group
    -- as the personal payment method.
    --
    if p_payee_type = 'O' then
      hr_utility.set_location(l_proc, 10);
      open csr_chk_organization;
      fetch csr_chk_organization into l_business_group_id;
      if csr_chk_organization%notfound then
      -- Error: invalid organization
        close csr_chk_organization;
        hr_utility.set_message(801, 'HR_7839_PPM_INV_ORG');
        hr_utility.raise_error;
      end if;
      close csr_chk_organization;
      -- check the business group
      if l_business_group_id <> p_business_group_id then
      -- Error: organization is not in the correct business group
        hr_utility.set_message(801, 'HR_7844_ORG_INV_BUS_GRP');
        hr_utility.raise_error;
      end if;
      --
      -- check that the organization is active
      --
      open csr_chk_organization_active;
      fetch csr_chk_organization_active into l_valid;
      if csr_chk_organization_active%notfound then
        -- Error: the organization is not active
        close csr_chk_organization_active;
        hr_utility.set_message(801, 'HR_7843_PPM_ORG_NOT_ACTIVE');
        hr_utility.raise_error;
      end if;
      close csr_chk_organization_active;
    --
    --  If PAYEE_TYPE is 'P' then ensure that PAYEE_ID refers to a valid
    --  person and that this person is a contact with a contact relationship
    --  to the owner of the personal payment method, and with the third party
    --  pay flag set to 'Yes'.
    --
    elsif p_payee_type = 'P' then
      hr_utility.set_location(l_proc, 15);
      open csr_chk_person;
      fetch csr_chk_person into l_valid;
      if csr_chk_person%notfound then
        close csr_chk_person;
        hr_utility.set_message(801, 'HR_7846_INV_PERSON');
        hr_utility.raise_error;
      end if;
      close csr_chk_person;
      --
      open csr_chk_contact;
      hr_utility.set_location(l_proc, 20);
      fetch csr_chk_contact into l_valid;
      if csr_chk_contact%notfound then
        close csr_chk_contact;
        hr_utility.set_message(801, 'HR_7847_PPM_INV_CONTACT');
        hr_utility.raise_error;
      end if;
      close csr_chk_contact;
    --
    --  PAYEE_TYPE is invalid
    --
    else
      hr_utility.set_message(801, 'HR_7848_PPM_INV_PAYEE_TYPE');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location('Leaving:'||l_proc, 25);
  end chk_payee_id_and_type;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all mandatory arguments are not null.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org_payment_method_id'
    ,p_argument_value => p_org_payment_method_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- If the personal payment method is a garnishment then check that
  -- PAYEE_ID and PAYEE_TYPE are both not null.
  -- If the personal payment method is not a garnishment (i.e. if the cursor
  -- returns zero rows) then ensure that PAYEE_ID and PAYEE_TYPE are both
  -- null.
  --
  l_api_updating := pay_ppm_shd.api_updating
    (p_personal_payment_method_id => p_personal_payment_method_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating and
      nvl(pay_ppm_shd.g_old_rec.payee_id, hr_api.g_number) <>
      nvl(p_payee_id, hr_api.g_number)) or
     (l_api_updating and
      nvl(pay_ppm_shd.g_old_rec.payee_type, hr_api.g_varchar2) <>
      nvl(p_payee_type, hr_api.g_varchar2)) or
      (not l_api_updating) then
    open csr_chk_garnishment;
    fetch csr_chk_garnishment into l_exists;
    if csr_chk_garnishment%notfound then
      close csr_chk_garnishment;
      -- a garnishment does not exist therefore we must ensure that
      -- the p_payee_id and p_payee_type argument are both null
      if NOT (p_payee_id   is null and
              p_payee_type is null) then
        hr_utility.set_message(801, 'HR_7820_PPM_INV_PAYEE_DETAILS');
        hr_utility.raise_error;
      end if;
    else
      close csr_chk_garnishment;
      -- a garnishment does exist therefore we must ensure that
      -- the p_payee_id and p_payee_type argument are both not null
      if (p_payee_id   is not null and
          p_payee_type is not null) then
        -- check the payee_id and type
        chk_payee_id_and_type;
      else
         -- The error message is restricted for magnetic type payments
	 -- Bug 6439573
	 -- and cheque payment type : Bug 6928340
         open csr_chk_pay_type;
	 fetch csr_chk_pay_type into l_category;
	 close csr_chk_pay_type;
	 if (l_category <> 'MT' and l_category <> 'CH') then
            hr_utility.set_message(801, 'HR_7822_PPM_NO_PAYEE_DETAILS');
            hr_utility.raise_error;
	 end if;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end chk_defined_balance_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_amount_percent  >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_amount_percent
  (p_amount                        in
   pay_personal_payment_methods_f.amount%TYPE
  ,p_percentage                    in
   pay_personal_payment_methods_f.percentage%TYPE
  ,p_personal_payment_method_id    in
   pay_personal_payment_methods_f.personal_payment_method_id%TYPE
  ,p_org_payment_method_id         in
   pay_personal_payment_methods_f.org_payment_method_id%TYPE
  ,p_effective_date                in  date
  ,p_object_version_number         in
   pay_personal_payment_methods_f.object_version_number%TYPE) is
--
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_amount_percent';
  l_api_updating   boolean;
  l_amount         number(38);
  l_percentage     number;            -- Changed to floating-point number, Bug 7499474
  l_curcode        varchar2(15);
--
  -- Currency code for monetary amount comes from the balance.
  cursor get_curcode is
  select bt.currency_code
  from pay_org_payment_methods_f opm
  ,    pay_defined_balances      db
  ,    pay_balance_types         bt
  where org_payment_method_id = p_org_payment_method_id
  and   p_effective_date between
        opm.effective_start_date and opm.effective_end_date
  and   db.defined_balance_id = opm.defined_balance_id
  and   bt.balance_type_id = db.balance_type_id
  ;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org payment method id'
    ,p_argument_value => p_org_payment_method_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The amount or percentage values have changed
  --
  l_api_updating := pay_ppm_shd.api_updating
    (p_personal_payment_method_id => p_personal_payment_method_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_object_version_number);
  --
  if ((l_api_updating and nvl(pay_ppm_shd.g_old_rec.amount,hr_api.g_number)
    <> nvl(p_amount,hr_api.g_number)) or
    (l_api_updating and nvl(pay_ppm_shd.g_old_rec.percentage,hr_api.g_number)
    <> nvl(p_percentage,hr_api.g_number)) or
    (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    --  Check the related balance type
    --
    if not balance_remunerative(p_org_payment_method_id, p_effective_date) then
      --
      --  the related balance type is non-remunerative
      --
      if p_amount is not null then
        --  Error: Amount not enterable
        hr_utility.set_message(801, 'HR_7349_PPM_AMOUNT_NOT_NULL');
        hr_utility.raise_error;
      end if;
      if p_percentage <> 100 then
       --  Error: Percentage error
        hr_utility.set_message(801, 'HR_7354_PPM_PERCENT_NOT_100');
        hr_utility.raise_error;
      end if;
    else
      --
      hr_utility.set_location(l_proc, 3);
      --
      --  When the related balance type is remunerative
      --
      --  Check that percentage and amount are not both not null or both null
      --
      if p_percentage is not null then
        if p_amount is not null then
          -- Error: One and only one of amount or percentage need to be entered
          hr_utility.set_message(801, 'HR_6221_PAYM_INVALID_PPM');
          hr_utility.raise_error;
        end if;
      elsif p_amount is null then
        --  Error: Either amount or percentage need to be entered
        hr_utility.set_message(801, 'HR_6680_PPM_AMT_PERC');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 5);
      --
      --  Check if the amount is less than 0
      --
      if p_amount < 0 then
        --  Error: Amount less than 0
        hr_utility.set_message(801, 'HR_7355_PPM_AMOUNT_NEGATIVE');
        hr_utility.raise_error;
      end if ;
      --
      hr_utility.set_location(l_proc, 6);
      --
      --  Check if the percentage is between 0 and 100
      --
      if p_percentage not between 0 and 100 then
        --  Error: Percentage must be between 0 and 100
        hr_utility.set_message(801, 'HR_7040_PERCENT_RANGE');
        hr_utility.raise_error;
      end if ;
    --
    end if ;
    --
    hr_utility.set_location(l_proc, 7);
    --
    if p_amount is not null then
      --
      --  Check that Amount has a money format
      --
      l_amount := to_char(p_amount);
      open get_curcode;
      fetch get_curcode into l_curcode;
      close get_curcode;
      --
      hr_dbchkfmt.is_db_format
        (p_value    => l_amount,
         p_arg_name => 'AMOUNT',
         p_format   => 'M',
         p_curcode  => l_curcode);
    else
      hr_utility.set_location(l_proc, 8);
      --
      --  p_percentage is not null so check that format is decimal with
      --  2 decimal places
      --
      l_percentage := to_char(p_percentage);
      --
      hr_dbchkfmt.is_db_format
        (p_value    => l_percentage,
         p_arg_name => 'PERCENTAGE',
--         p_format   => 'INTEGER');
         p_format   => 'H_DECIMAL3');  -- Changed to H_DECIMAL3 ,Bug 7499474
    end if;
  end if ;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 9);
end chk_amount_percent;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_external_account_id >------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_external_account_id
  (p_personal_payment_method_id    in
   pay_personal_payment_methods_f.personal_payment_method_id%TYPE
  ,p_org_payment_method_id         in
   pay_personal_payment_methods_f.org_payment_method_id%TYPE
  ,p_external_account_id           in number
  ,p_effective_date                in date
  ,p_object_version_number         in
   pay_personal_payment_methods_f.object_version_number%TYPE) is
--
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_external_account_id';
  l_api_updating   boolean;
--
--  Check if related payment type is Magnetic Tape
--
  cursor csr_chk_pay_type is
    select null
    from pay_org_payment_methods_f opm
    ,    pay_payment_types pyt
    where p_org_payment_method_id = opm.org_payment_method_id
      and opm.payment_type_id = pyt.payment_type_id
      and p_effective_date between opm.effective_start_date
                               and opm.effective_end_date
      and pyt.category = 'MT';
--
--  Check if external_account_id exists on pay_external_accounts
--
  cursor csr_chk_ext_acct_id is
    select null
    from pay_external_accounts pea
    where pea.external_account_id = p_external_account_id;
--
--  Check that the flex structure for the external account matches
--  the flex structure already defined for the opm.
--
  cursor chk_org_flex_struct is
    select null
    from pay_external_accounts pea1,
         pay_external_accounts pea2,
         pay_org_payment_methods_f opm
    where pea1.external_account_id = p_external_account_id
    and opm.org_payment_method_id = p_org_payment_method_id
    and opm.external_account_id = pea2.external_account_id
    and pea1.id_flex_num = pea2.id_flex_num
    and exists
      (select null
       from   pay_legislation_rules
       where  to_char(pea1.id_flex_num) = rule_mode
       and rule_type ='E');
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org payment method id'
    ,p_argument_value => p_org_payment_method_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The external account id value has changed
  --
  l_api_updating := pay_ppm_shd.api_updating
    (p_personal_payment_method_id => p_personal_payment_method_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_object_version_number);
  --
  if ((l_api_updating and nvl(pay_ppm_shd.g_old_rec.external_account_id,
                              hr_api.g_number)
    <> nvl(p_external_account_id,hr_api.g_number)) or
    (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    --  Check if related payment type is Magnetic Tape
    --
    open csr_chk_pay_type;
    fetch csr_chk_pay_type into l_exists;
    if csr_chk_pay_type%found then
      --
      -- related payment type is Magnetic Tape
      --
      if p_external_account_id is null then
        close csr_chk_pay_type;
        --  Error: Bank details needed for magnetic tape payment types
        hr_utility.set_message(801, 'HR_6678_PPM_MT_BANK');
        hr_utility.raise_error;
      end if;
    else
      --
      -- related payment type is not Magnetic Tape
      --
      if p_external_account_id is not null then
        close csr_chk_pay_type;
        --  Error: External account not enterable
        hr_utility.set_message(801, 'HR_7356_PPM_EXT_ACC_NOT_NULL');
        hr_utility.raise_error;
      end if;
    end if;
    close csr_chk_pay_type;
    --
    hr_utility.set_location(l_proc, 3);
    --
    -- Check if foreign key constraint error is violated
    --
    if p_external_account_id is not null then
      open csr_chk_ext_acct_id;
      fetch csr_chk_ext_acct_id into l_exists;
      if csr_chk_ext_acct_id%notfound then
        close csr_chk_ext_acct_id;
        pay_ppm_shd.constraint_error
        (p_constraint_name => 'PAY_PERSONAL_PAYMENT_METHO_FK2');
      else
        close csr_chk_ext_acct_id;
      end if;
    end if;
    --
    --  Check that the flex structure for the external account matches
    --  the flex structure already defined for the opm.
    --
    if p_external_account_id is not null then
    --
      open chk_org_flex_struct;
      fetch chk_org_flex_struct into l_exists;
      if chk_org_flex_struct%notfound then
        close chk_org_flex_struct;
        --  Error: PPM external account structure does not exist
        hr_utility.set_message(801, 'HR_51350_PPM_EXT_ACC_STRUC');
        hr_utility.raise_error;
      else
        close chk_org_flex_struct;
      end if;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_external_account_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_priority  >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_priority
  (p_priority                      in
   pay_personal_payment_methods_f.priority%TYPE
  ,p_personal_payment_method_id    in
   pay_personal_payment_methods_f.personal_payment_method_id%TYPE
  ,p_org_payment_method_id         in
   pay_personal_payment_methods_f.org_payment_method_id%TYPE
  ,p_assignment_id                 in
   pay_personal_payment_methods_f.assignment_id%TYPE
  ,p_run_type_id                 in
   pay_personal_payment_methods_f.run_type_id%TYPE
  ,p_effective_date                in date
  ,p_object_version_number         in
   pay_personal_payment_methods_f.object_version_number%TYPE
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date) is
--
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_priority';
  l_api_updating   boolean;

--  Check if the related priority is unique within validation start date
--  and validation end date. Note: the SQL only includes remunerative pay
--  methods in the check.

  cursor csr_check_unique is
   select  null
     from  pay_personal_payment_methods_f ppm
    where  ppm.priority = p_priority
      and  ppm.assignment_id               = p_assignment_id
      and    nvl(ppm.run_type_id,-9999)   = nvl(p_run_type_id,-9999)
      and (ppm.personal_payment_method_id <> p_personal_payment_method_id
       or  p_personal_payment_method_id is null)
      and (ppm.priority <> 1
           or exists
              (select null
               from   pay_org_payment_methods_f opm
               ,      pay_defined_balances      db
               ,      pay_balance_types         bt
               where opm.org_payment_method_id = ppm.org_payment_method_id
               and   p_effective_date between
                     opm.effective_start_date and opm.effective_end_date
               and   db.defined_balance_id = opm.defined_balance_id
               and   bt.balance_type_id    = db.balance_type_id
               and   bt.assignment_remuneration_flag = 'Y'
              )
           )
      and  ppm.effective_start_date       <= p_validation_end_date
      and  ppm.effective_end_date         >= p_validation_start_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org_payment_method_id'
    ,p_argument_value => p_org_payment_method_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The priority value has changed
  --
  l_api_updating := pay_ppm_shd.api_updating
    (p_personal_payment_method_id => p_personal_payment_method_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_object_version_number);
  --
  if ((l_api_updating and nvl(pay_ppm_shd.g_old_rec.priority,hr_api.g_number)
    <> nvl(p_priority,hr_api.g_number)) or
    (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 2);
    --
    --  Check if priority is null
    --
    if p_priority is null then
      --  Error: Priority required
      hr_utility.set_message(801, 'HR_7357_PPM_PRIORITY_NULL');
      hr_utility.raise_error;
    end if;
    --
    --  Check if the related balance type is remunerative
    --
    if balance_remunerative(p_org_payment_method_id, p_effective_date) then
      --
      --  Check that priority is between 1 and 99
      --  note: this could be coded using the API version of checkformat
      --
      if p_priority not between 1 and 99 then
        --  Error: Priority out of range
        hr_utility.Set_message(801, 'HR_7358_PPM_PRIORITY_RANGE');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 3);
      if l_api_updating then
        --
        -- As we are updating we validate the priority.
        -- We do not need to do this for INSERT because the
        -- process: pay_ppm_bus.return_effective_date has already
        -- completed the check
        --
        open csr_check_unique;
        fetch csr_check_unique into l_exists;
        if csr_check_unique%found then
          close csr_check_unique;
          -- Error: A payment method with this priority exists for this
          -- assignment
          hr_utility.set_message(801, 'HR_6225_PAYM_DUP_PRIORITY');
          hr_utility.raise_error;
        end if;
        close csr_check_unique;
      end if;
    else
      --
      hr_utility.set_location(l_proc, 4);
      --
      --  Balance Type is non_remunerative
      --
      if p_priority <> 1 then
        --  Error: Priority must be 1
        hr_utility.set_message(801, 'HR_7359_PPM_MUST_BE_1');
        hr_utility.raise_error;
      end if;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
end chk_priority;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_delete >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that rows may be deleted from pay_personal_payment_methods_f
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_personal_payment_method_id
--    p_effective_date
--    p_datetrack_mode
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    If any of the following cases are true then
--    an application error will be raised and processing is terminated
--
--      a) If delete mode is DELETE (ie: set end date)
--         and rows exist in PAY_PRE_PAYMENTS for PAY_PAYROLL_ACTION
--         effective dates that are effective beyond the session date
--
--      b) If delete mode is ZAP (ie: remove all records)
--         and rows exist in PAY_PRE_PAYMENTS
--
--	c) If delete mode is DELETE, the personal payment method is to a
--	   third party payee and the new end date is earlier than any element
--	   entry that references it.
--
--	d) If delete mode is ZAP, the personal payment method is to a third
--	   party payee and is used by an element entry.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_delete
  (p_personal_payment_method_id   in
   pay_personal_payment_methods_f.personal_payment_method_id%TYPE
  ,p_effective_date               in   date
  ,p_datetrack_mode               in   varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date) is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_delete';
  --
  --  check if rows exist in PAY_PRE_PAYMENTS for PAY_PAYROLL_ACTION
  --  effective dates that are effective beyond the session date
  cursor csr_date_eff is
    select null
    from   pay_pre_payments ppy
    ,      pay_assignment_actions asa
    ,      pay_payroll_actions pra
    where  p_personal_payment_method_id = ppy.personal_payment_method_id
      and  ppy.assignment_action_id = asa.assignment_action_id
      and  asa.payroll_action_id = pra.payroll_action_id
      and  pra.effective_date > p_effective_date;
  --
  --  check if rows exist in PAY_PRE_PAYMENTS
  --
  cursor csr_del is
    select null
    from   pay_pre_payments ppy
    where  p_personal_payment_method_id = ppy.personal_payment_method_id;
  --
  procedure check_garnishment_delete is
    l_proc	 varchar2(72)  :=  g_package||'check_garnishment_delete';
    --
    -- For garnishments, disallow a date-effective delete or zap if the personal
    -- payment method is referenced by at least one element entry.
    --
    cursor csr_del_garnishment is
      select null
      from   pay_personal_payment_methods_f ppm,
             pay_element_entries_f ele,
             pay_org_payment_methods_f opm
      where  ppm.personal_payment_method_id = p_personal_payment_method_id
      and    p_effective_date between ppm.effective_start_date
                              and     ppm.effective_end_date
      and    ppm.org_payment_method_id = opm.org_payment_method_id
      and    p_effective_date between opm.effective_start_date
                              and     opm.effective_end_date
      and    opm.defined_balance_id is null
      and    ele.personal_payment_method_id = ppm.personal_payment_method_id
      and    ele.effective_start_date <= p_validation_start_date
      and    ele.effective_end_date >= p_validation_end_date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
    open csr_del_garnishment;
    fetch csr_del_garnishment into l_exists;
    if csr_del_garnishment%found then
      close csr_del_garnishment;
      --  Error: Delete not allowed
      hr_utility.set_message(801, 'HR_7849_PPM_ELE_DELETE');
      hr_utility.raise_error;
    end if;
    close csr_del_garnishment;
    hr_utility.set_location(' Leaving:'|| l_proc, 10);
  end check_garnishment_delete;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  --  If delete mode is DELETE (ie: set end date) then
  --  check if rows exist in PAY_PRE_PAYMENTS for PAY_PAYROLL_ACTION
  --  effective dates that are effective beyond the session date
  --
  if p_datetrack_mode = 'DELETE' then
    open csr_date_eff;
    fetch csr_date_eff into l_exists;
    if csr_date_eff%found then
      close csr_date_eff;
      --  Error: Delete not allowed
      hr_utility.set_message(801, 'HR_7360_PPM_DEL_NOT_ALLOWED');
      hr_utility.raise_error;
    end if;
    close csr_date_eff;
    --
    check_garnishment_delete;
  end if;
  --
  hr_utility.set_location(l_proc, 3);
  --
  --  If delete mode is ZAP (ie: remove all records) then
  --  check if rows exist in PAY_PRE_PAYMENTS
  --
  if p_datetrack_mode = 'ZAP' then
    open csr_del;
    fetch csr_del into l_exists;
    if csr_del%found then
      close csr_del;
      --  Error:Cannot delete. Pre payments exist
      hr_utility.set_message(801, 'HR_6679_PPM_PRE_PAY');
      hr_utility.raise_error;
    end if;
    close csr_del;
    --
    check_garnishment_delete;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_non_updateable_args(p_rec in pay_ppm_shd.g_rec_type
                                   ,p_effective_date in date) is
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
  if not pay_ppm_shd.api_updating
    (p_personal_payment_method_id => p_rec.personal_payment_method_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_rec.object_version_number) then
    hr_utility.set_message(801, 'HR_51351_PPM_UPD_ROW_NOT_EXIST');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_ppm_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if p_rec.assignment_id <> pay_ppm_shd.g_old_rec.assignment_id then
     l_argument := 'assignment_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if nvl(p_rec.org_payment_method_id, hr_api.g_number) <>
     nvl(pay_ppm_shd.g_old_rec.org_payment_method_id, hr_api.g_number) then
     l_argument := 'org_payment_method_id';
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
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Pre Conditions:
--   This procedure is called from the update_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_org_payment_method_id         in number default hr_api.g_number,
             p_assignment_id                 in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_org_payment_method_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_org_payment_methods_f',
             p_base_key_column => 'org_payment_method_id',
             p_base_key_value  => p_org_payment_method_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'org payment methods';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_assignment_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_assignments_f',
             p_base_key_column => 'assignment_id',
             p_base_key_value  => p_assignment_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'assignments';
      Raise l_integrity_error;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Pre Conditions:
--   This procedure is called from the delete_validate.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_personal_payment_method_id in number,
             p_datetrack_mode		  in varchar2,
	     p_validation_start_date	  in date,
	     p_validation_end_date	  in date) Is
--
  l_proc	  varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	  Exception;
  l_future_change Exception;
  l_table_name	  all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Raise error if date_track mode is FUTURE_CHANGE
  --
    If (p_datetrack_mode ='FUTURE_CHANGE') then
      raise l_future_change;
--      hr_utility.set_message(801, 'PAY_6209_ELEMENT_NO_FC_DEL');
--      hr_utility.raise_error;
    end if;
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'personal_payment_method_id',
       p_argument_value => p_personal_payment_method_id);
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When l_future_change then
    hr_utility.set_message(801, 'PAY_6209_ELEMENT_NO_FC_DEL');
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the appropriate
  -- Business Rules in payppm.bru is provided.
  --
  -- Validate Business Group ID
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  -- Validate Org Payment Method ID
  --
  chk_org_payment_method_id
    (p_business_group_id           =>  p_rec.business_group_id
    ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
    ,p_effective_date              =>  p_effective_date
    );
  --
  -- Validate payee id and payee type, depending on whether the personal
  -- payment method is a garnishment or not.
  --
  chk_defined_balance_id
    (p_business_group_id           =>  p_rec.business_group_id,
     p_assignment_id               =>  p_rec.assignment_id,
     p_personal_payment_method_id  =>  p_rec.personal_payment_method_id,
     p_org_payment_method_id       =>  p_rec.org_payment_method_id,
     p_effective_date              =>  p_effective_date,
     p_object_version_number       =>  p_rec.object_version_number,
     p_payee_type                  =>  p_rec.payee_type,
     p_payee_id                    =>  p_rec.payee_id
    );
  --
  -- Validate Amount and Percentage
  --
  chk_amount_percent
    (p_amount                      =>  p_rec.amount
    ,p_percentage                  =>  p_rec.percentage
    ,p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
    ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
  --
  -- Validate External Account ID
  --
  chk_external_account_id
    (p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
    ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
    ,p_external_account_id         =>  p_rec.external_account_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
  --
  -- Validate Priority
  --
  chk_priority
    (p_priority                    =>  p_rec.priority
    ,p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
    ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
    ,p_assignment_id               =>  p_rec.assignment_id
    ,p_run_type_id                 =>  p_rec.run_type_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    );
  --
  -- Validate DDF
  --
  pay_ppm_bus.chk_ddf(p_rec => p_rec);
  --
  -- DF external hook
  --
  pay_ppm_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the appropriate
  -- Business Rules in payppm.bru is provided.
  --
  -- Check that the columns which cannot be updated have not changed
  --
  check_non_updateable_args(p_rec            => p_rec
                           ,p_effective_date => p_effective_date);
  --
  -- Validate payee id and payee type, depending on whether the personal
  -- payment method is a garnishment or not.
  --
  chk_defined_balance_id
    (p_business_group_id           =>  p_rec.business_group_id,
     p_assignment_id               =>  p_rec.assignment_id,
     p_personal_payment_method_id  =>  p_rec.personal_payment_method_id,
     p_org_payment_method_id       =>  p_rec.org_payment_method_id,
     p_effective_date              =>  p_effective_date,
     p_object_version_number       =>  p_rec.object_version_number,
     p_payee_type                  =>  p_rec.payee_type,
     p_payee_id                    =>  p_rec.payee_id
    );
  --
  -- Validate Amount and Percentage
  --
  chk_amount_percent
    (p_amount                      =>  p_rec.amount
    ,p_percentage                  =>  p_rec.percentage
    ,p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
    ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
  --
  -- Validate External Account ID
  --
  chk_external_account_id
    (p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
    ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
    ,p_external_account_id         =>  p_rec.external_account_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
  --
  -- Validate Priority
  --
  chk_priority
    (p_priority                    =>  p_rec.priority
    ,p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
    ,p_org_payment_method_id       =>  p_rec.org_payment_method_id
    ,p_assignment_id               =>  p_rec.assignment_id
    ,p_run_type_id                 =>  p_rec.run_type_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    );
  --
  -- Validate DDF
  --
  pay_ppm_bus.chk_ddf(p_rec => p_rec);
  --
  -- DF external hook
  --
  pay_ppm_bus.chk_df(p_rec => p_rec);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_org_payment_method_id         => p_rec.org_payment_method_id,
     p_assignment_id                 => p_rec.assignment_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the appropriate
  -- business rules on paypm.bru is provided
  --
  -- check if delete operations are allowed
  --
  chk_delete
    (p_personal_payment_method_id  =>  p_rec.personal_payment_method_id
    ,p_effective_date              =>  p_effective_date
    ,p_datetrack_mode              =>  p_datetrack_mode
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    );
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_personal_payment_method_id	=> p_rec.personal_payment_method_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_personal_payment_method_id      in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups             pbg
         , pay_personal_payment_methods_f  ppm
     where ppm.personal_payment_method_id = p_personal_payment_method_id
       and          pbg.business_group_id = ppm.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'personal_payment_method_id',
                             p_argument_value => p_personal_payment_method_id);
  --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
    close csr_leg_code;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pay_ppm_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.personal_payment_method_id is not null)  and (
    nvl(pay_ppm_shd.g_old_rec.ppm_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information_category, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information1, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information1, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information2, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information2, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information3, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information3, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information4, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information4, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information5, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information5, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information6, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information6, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information7, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information7, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information8, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information8, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information9, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information9, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information10, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information10, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information11, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information11, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information12, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information12, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information13, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information13, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information14, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information14, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information15, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information15, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information16, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information16, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information17, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information17, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information18, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information18, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information19, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information19, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information20, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information20, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information21, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information21, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information22, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information22, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information23, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information23, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information24, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information24, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information25, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information25, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information26, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information26, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information27, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information27, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information28, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information28, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information29, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information29, hr_api.g_varchar2)  or
    nvl(pay_ppm_shd.g_old_rec.ppm_information30, hr_api.g_varchar2) <>
    nvl(p_rec.ppm_information30, hr_api.g_varchar2)  ))
    or (p_rec.personal_payment_method_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Personal PayMeth Developer DF'
      ,p_attribute_category              => p_rec.ppm_information_category
      ,p_attribute1_name                 => 'PPM_INFORMATION1'
      ,p_attribute1_value                => p_rec.ppm_information1
      ,p_attribute2_name                 => 'PPM_INFORMATION2'
      ,p_attribute2_value                => p_rec.ppm_information2
      ,p_attribute3_name                 => 'PPM_INFORMATION3'
      ,p_attribute3_value                => p_rec.ppm_information3
      ,p_attribute4_name                 => 'PPM_INFORMATION4'
      ,p_attribute4_value                => p_rec.ppm_information4
      ,p_attribute5_name                 => 'PPM_INFORMATION5'
      ,p_attribute5_value                => p_rec.ppm_information5
      ,p_attribute6_name                 => 'PPM_INFORMATION6'
      ,p_attribute6_value                => p_rec.ppm_information6
      ,p_attribute7_name                 => 'PPM_INFORMATION7'
      ,p_attribute7_value                => p_rec.ppm_information7
      ,p_attribute8_name                 => 'PPM_INFORMATION8'
      ,p_attribute8_value                => p_rec.ppm_information8
      ,p_attribute9_name                 => 'PPM_INFORMATION9'
      ,p_attribute9_value                => p_rec.ppm_information9
      ,p_attribute10_name                => 'PPM_INFORMATION10'
      ,p_attribute10_value               => p_rec.ppm_information10
      ,p_attribute11_name                => 'PPM_INFORMATION11'
      ,p_attribute11_value               => p_rec.ppm_information11
      ,p_attribute12_name                => 'PPM_INFORMATION12'
      ,p_attribute12_value               => p_rec.ppm_information12
      ,p_attribute13_name                => 'PPM_INFORMATION13'
      ,p_attribute13_value               => p_rec.ppm_information13
      ,p_attribute14_name                => 'PPM_INFORMATION14'
      ,p_attribute14_value               => p_rec.ppm_information14
      ,p_attribute15_name                => 'PPM_INFORMATION15'
      ,p_attribute15_value               => p_rec.ppm_information15
      ,p_attribute16_name                => 'PPM_INFORMATION16'
      ,p_attribute16_value               => p_rec.ppm_information16
      ,p_attribute17_name                => 'PPM_INFORMATION17'
      ,p_attribute17_value               => p_rec.ppm_information17
      ,p_attribute18_name                => 'PPM_INFORMATION18'
      ,p_attribute18_value               => p_rec.ppm_information18
      ,p_attribute19_name                => 'PPM_INFORMATION19'
      ,p_attribute19_value               => p_rec.ppm_information19
      ,p_attribute20_name                => 'PPM_INFORMATION20'
      ,p_attribute20_value               => p_rec.ppm_information20
      ,p_attribute21_name                => 'PPM_INFORMATION21'
      ,p_attribute21_value               => p_rec.ppm_information21
      ,p_attribute22_name                => 'PPM_INFORMATION22'
      ,p_attribute22_value               => p_rec.ppm_information22
      ,p_attribute23_name                => 'PPM_INFORMATION23'
      ,p_attribute23_value               => p_rec.ppm_information23
      ,p_attribute24_name                => 'PPM_INFORMATION24'
      ,p_attribute24_value               => p_rec.ppm_information24
      ,p_attribute25_name                => 'PPM_INFORMATION25'
      ,p_attribute25_value               => p_rec.ppm_information25
      ,p_attribute26_name                => 'PPM_INFORMATION26'
      ,p_attribute26_value               => p_rec.ppm_information26
      ,p_attribute27_name                => 'PPM_INFORMATION27'
      ,p_attribute27_value               => p_rec.ppm_information27
      ,p_attribute28_name                => 'PPM_INFORMATION28'
      ,p_attribute28_value               => p_rec.ppm_information28
      ,p_attribute29_name                => 'PPM_INFORMATION29'
      ,p_attribute29_value               => p_rec.ppm_information29
      ,p_attribute30_name                => 'PPM_INFORMATION30'
      ,p_attribute30_value               => p_rec.ppm_information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
procedure chk_df
(p_rec in pay_ppm_shd.g_rec_type
) is
l_proc    varchar2(2000) := g_package||'chk_df';
l_rec     pay_ppm_shd.g_rec_type;
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  l_rec := pay_ppm_shd.g_old_rec;
  --
  -- Only do the validation if inserting or if values have changed on
  -- update.
  --
  if (p_rec.personal_payment_method_id is not null and (
      nvl(p_rec.attribute_category, hr_api.g_varchar2) <>
      nvl(l_rec.attribute_category, hr_api.g_varchar2) or
      nvl(p_rec.attribute1, hr_api.g_varchar2) <>
      nvl(l_rec.attribute1, hr_api.g_varchar2) or
      nvl(p_rec.attribute2, hr_api.g_varchar2) <>
      nvl(l_rec.attribute2, hr_api.g_varchar2) or
      nvl(p_rec.attribute3, hr_api.g_varchar2) <>
      nvl(l_rec.attribute3, hr_api.g_varchar2) or
      nvl(p_rec.attribute4, hr_api.g_varchar2) <>
      nvl(l_rec.attribute4, hr_api.g_varchar2) or
      nvl(p_rec.attribute5, hr_api.g_varchar2) <>
      nvl(l_rec.attribute5, hr_api.g_varchar2) or
      nvl(p_rec.attribute6, hr_api.g_varchar2) <>
      nvl(l_rec.attribute6, hr_api.g_varchar2) or
      nvl(p_rec.attribute7, hr_api.g_varchar2) <>
      nvl(l_rec.attribute7, hr_api.g_varchar2) or
      nvl(p_rec.attribute8, hr_api.g_varchar2) <>
      nvl(l_rec.attribute8, hr_api.g_varchar2) or
      nvl(p_rec.attribute9, hr_api.g_varchar2) <>
      nvl(l_rec.attribute9, hr_api.g_varchar2) or
      nvl(p_rec.attribute10, hr_api.g_varchar2) <>
      nvl(l_rec.attribute10, hr_api.g_varchar2) or
      nvl(p_rec.attribute11, hr_api.g_varchar2) <>
      nvl(l_rec.attribute11, hr_api.g_varchar2) or
      nvl(p_rec.attribute12, hr_api.g_varchar2) <>
      nvl(l_rec.attribute12, hr_api.g_varchar2) or
      nvl(p_rec.attribute13, hr_api.g_varchar2) <>
      nvl(l_rec.attribute13, hr_api.g_varchar2) or
      nvl(p_rec.attribute14, hr_api.g_varchar2) <>
      nvl(l_rec.attribute14, hr_api.g_varchar2) or
      nvl(p_rec.attribute15, hr_api.g_varchar2) <>
      nvl(l_rec.attribute15, hr_api.g_varchar2) or
      nvl(p_rec.attribute16, hr_api.g_varchar2) <>
      nvl(l_rec.attribute16, hr_api.g_varchar2) or
      nvl(p_rec.attribute17, hr_api.g_varchar2) <>
      nvl(l_rec.attribute17, hr_api.g_varchar2) or
      nvl(p_rec.attribute18, hr_api.g_varchar2) <>
      nvl(l_rec.attribute18, hr_api.g_varchar2) or
      nvl(p_rec.attribute19, hr_api.g_varchar2) <>
      nvl(l_rec.attribute19, hr_api.g_varchar2) or
      nvl(p_rec.attribute20, hr_api.g_varchar2) <>
      nvl(l_rec.attribute20, hr_api.g_varchar2))) or
      p_rec.personal_payment_method_id is null
  then
    hr_utility.set_location(l_proc, 20);
    hr_dflex_utility.ins_or_upd_descflex_attribs
    (p_appl_short_name    => 'PAY'
    ,p_descflex_name      => 'PAY_PERSONAL_PAYMENT_METHODS'
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
  hr_utility.set_location('Leaving:'||l_proc, 30);
end chk_df;
--
end pay_ppm_bus;

/
