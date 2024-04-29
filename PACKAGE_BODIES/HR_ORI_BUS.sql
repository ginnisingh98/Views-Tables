--------------------------------------------------------
--  DDL for Package Body HR_ORI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORI_BUS" as
/* $Header: hrorirhi.pkb 120.3.12010000.2 2008/08/06 08:45:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ori_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_org_information_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_org_information_id                   in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hr_organization_information and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hr_organization_information ori
      --   , EDIT_HERE table_name(s) 333
     where ori.org_information_id = p_org_information_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'org_information_id'
    ,p_argument_value     => p_org_information_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cost_center_gap >--------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure checks that the organization information being passed
-- in does not result in a gap in existing cost center managers.
-- This function returns a boolean value of true if a gap has occured.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
FUNCTION chk_cost_center_gap
    (p_organization_id         IN number,
     p_org_information_context IN varchar2,
     p_org_information_id      IN number,
     p_start_date              IN date,
     p_end_date                IN date) return boolean is
  --
  l_proc varchar2(72)  :=  g_package||'chk_cost_center_gap';
  --
  cursor c1 is
    select max(fnd_date.canonical_to_date(org_information4)) max_end_date
    from   hr_organization_information
    where  organization_id = p_organization_id
    and    org_information_context = 'Organization Name Alias'
    and    org_information_id <> nvl(p_org_information_id,-1)
    and    fnd_date.canonical_to_date(org_information4) < p_start_date;
  --
  cursor c2 is
    select min(fnd_date.canonical_to_date(org_information3)) min_start_date
    from   hr_organization_information
    where  organization_id = p_organization_id
    and    org_information_context = 'Organization Name Alias'
    and    org_information_id <> nvl(p_org_information_id,-1)
    and    fnd_date.canonical_to_date(org_information3)
           > nvl(p_end_date,hr_api.g_eot);
  --
  l_c2 c2%rowtype;
  l_c1 c1%rowtype;
  --
begin
  --
  hr_utility.set_location(' Entering:'|| l_proc, 20);
  --
  -- Rules are as follows
  -- If record being inserted or updated is before the earliest start
  -- date then compare end date to previous earliest start date.
  -- If record is after earliest start date then grab latest end date where
  -- end date is less than newly created or updated start date and compare.
  -- Additionally check end date compared to next start date that is greater
  -- than end date. Don't bother checking overlaps as they are found elsewhere.
  --
  -- This is only relevant for Organization Name Alias context
  --
  if p_org_information_context <> 'Organization Name Alias' then
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 11);
    return false;
    --
  end if;
  --
  -- Get max end date before new start date first.
  --
  open c1;
    --
    fetch c1 into l_c1;
    if c1%found then
      --
      -- Check if the date is one day before the row we are inserting/updating
      --
      if l_c1.max_end_date+1 < p_start_date then
        --
        -- This results in a gap, if its an overlap then it will be picked
        -- up by the overlap business rule.
        --
        close c1;
        hr_utility.set_location(' Leaving:'|| l_proc, 12);
        return true;
        --
      end if;
      --
    end if;
    --
  close c1;
  --
  -- Get min start date after end date
  --
  open c2;
    --
    fetch c2 into l_c2;
    if c2%found then
      --
      -- Check if the date is one day before the row we are inserting/updating
      --
      if l_c2.min_start_date-1 > p_end_date then
        --
        -- This results in a gap, if its an overlap then it will be picked
        -- up by the overlap business rule.
        --
        close c2;
        hr_utility.set_location(p_end_date|| l_proc, 13);
        hr_utility.set_location(l_c2.min_start_date|| l_proc, 13);
        hr_utility.set_location(' Leaving:'|| l_proc, 13);
        return true;
        --
      end if;
      --
    end if;
    --
  close c2;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return false;
  --
end chk_cost_center_gap;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cost_center_start_date >-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure checks that the start date is entered for the context
-- of "Organization Name Alias" and thats its before the end date.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_cost_center_start_date
  (p_org_information_context in varchar2,
   p_org_information2        in varchar2,
   p_org_information3        in varchar2,
   p_org_information4        in varchar2) is
  --
  l_proc varchar2(72)  :=  g_package||'chk_cost_center_start_date';
  l_start_date date;
  l_end_date date;
  --
begin
  --
  hr_utility.set_location(' Entering:'|| l_proc, 20);
  --
  -- Rules are as follows
  -- Any record being inserted or updated must have a Start Date and if
  -- entered the End Date must be on or after the Start Date.
  --
  if p_org_information_context <> 'Organization Name Alias' then
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 11);
    return;
    --
  end if;
  --
  -- Check if start date has been populated. It may have been updated to null
  -- though which is valid providing all the fields are null.
  --
  if p_org_information3 is null and (p_org_information2 is not null or
    p_org_information4 is not null) then
    --
    fnd_message.set_name('PER','PER_289693_START_DATE_NULL');
    fnd_message.raise_error;
    --
  end if;
  --
  if p_org_information3 is not null and
     p_org_information2 is null then
    --
    fnd_message.set_name('PER','PER_289694_NO_MANAGER');
    fnd_message.raise_error;
    --
  end if;
  --
  if p_org_information2 is null and
     p_org_information3 is null and
     p_org_information4 is null then
    --
    return;
    --
  end if;
  --
  -- Check if start date is less than end date if end date has been
  -- populated.
  --
  begin
    --
    -- Since we are checking the format prior to flex we need to make sure
    -- its all good and valid.
    --
    l_start_date := fnd_date.canonical_to_date(p_org_information3);
    --
  exception
    --
    when others then
      --
      fnd_message.set_name('PER','PER_289695_START_DATE_FORMAT');
      fnd_message.raise_error;
      --
  end;
  --
  if p_org_information4 is not null then
    --
    begin
      --
      -- Since we are checking the format prior to flex we need to make sure
      -- its all good and valid.
      --
      l_end_date := fnd_date.canonical_to_date(p_org_information4);
      --
    exception
      --
      when others then
        --
        fnd_message.set_name('PER','PER_289696_END_DATE_FORMAT');
        fnd_message.raise_error;
        --
    end;
    --
    if l_start_date > l_end_date then
      --
      fnd_message.set_name('PER','PER_289697_START_BEFORE_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_cost_center_start_date;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cost_center_start_end_date >---------------|
-- ----------------------------------------------------------------------------
--
-- This procedure checks that the start date is not before the employees hire
-- date and that the end date is not after the employees termination date.
-- This is only application for the context "Organization Name Alias".
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_cost_center_start_end_date
  (p_org_information_context in varchar2,
   p_org_information2        in varchar2,
   p_org_information3        in varchar2,
   p_org_information4        in varchar2) is
  --
  l_proc varchar2(72)  :=  g_package||'chk_cost_center_start_end_date';
  l_person_id  number;
  l_start_date date;
  l_end_date date;
  --
  cursor c1 is
    select period_of_service_id worker_id,
           date_start
    from   per_periods_of_service
    where  l_start_date
           between date_start
           and     nvl(actual_termination_date,hr_api.g_eot)
    and    person_id = l_person_id
    union
    select period_of_placement_id worker_id,
           date_start
    from   per_periods_of_placement
    where  l_start_date
           between date_start
           and     nvl(actual_termination_date,hr_api.g_eot)
    and    person_id = l_person_id;
  --
  -- They need to share the same period of service id.
  --
  -- WWBUG 2358813.
  --
  cursor c2(p_worker_id number) is
    select actual_termination_date
    from   per_periods_of_service
    where  nvl(l_end_date,hr_api.g_eot)
           between date_start
           and     nvl(actual_termination_date,hr_api.g_eot)
    and    period_of_service_id = p_worker_id
    and    person_id = l_person_id
    union
    select actual_termination_date
    from   per_periods_of_placement
    where  nvl(l_end_date,hr_api.g_eot)
           between date_start
           and     nvl(actual_termination_date,hr_api.g_eot)
    and    period_of_placement_id = p_worker_id
    and    person_id = l_person_id;
  --
  l_c1 c1%rowtype;
  l_c2 c2%rowtype;
  --
begin
  --
  hr_utility.set_location(' Entering:'|| l_proc, 20);
  --
  -- Rules are as follows
  -- Any Cost Center Manager being inserted or updated must have a Hire
  -- Date that is on or before the Start Date and a Termination Date that
  -- is on or after the End Date.
  --
  -- This is only relevant for Organization Name Alias context
  --
  if p_org_information_context <> 'Organization Name Alias' then
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 11);
    return;
    --
  end if;
  --
  -- Check if person has been assigned to the cost center. If not return
  --
  if p_org_information2 is null then
    --
    return;
    --
  end if;
  --
  -- Get value of person id.
  --
  begin
    --
    -- Since we are checking the format prior to flex we need to make sure
    -- its all good and valid.
    --
    l_person_id := to_number(p_org_information2);
    --
  exception
    --
    when others then
      --
      fnd_message.set_name('PER','PER_289698_PERSON_ID_INVALID');
      fnd_message.raise_error;
      --
  end;
  --
  -- Get value of Start Date.
  --
  begin
    --
    -- Since we are checking the format prior to flex we need to make sure
    -- its all good and valid.
    --
    l_start_date := fnd_date.canonical_to_date(p_org_information3);
    --
  exception
    --
    when others then
      --
      fnd_message.set_name('PER','PER_289695_START_DATE_FORMAT');
      fnd_message.raise_error;
      --
  end;
  --
  open c1;
    --
    fetch c1 into l_c1;
    if c1%notfound then
      --
      fnd_message.set_name('PER','PER_289699_START_DATE_BFR_HIRE');
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  -- Get value of end date
  --
  begin
    --
    -- Since we are checking the format prior to flex we need to make sure
    -- its all good and valid.
    --
    l_end_date := fnd_date.canonical_to_date(p_org_information4);
    --
  exception
    --
    when others then
      --
      fnd_message.set_name('PER','PER_289696_END_DATE_FORMAT');
      fnd_message.raise_error;
      --
  end;
  --
  open c2(l_c1.worker_id);
    --
    fetch c2 into l_c2;
    if c2%notfound then
      --
      fnd_message.set_name('PER','PER_289700_END_DATE_AFTER_TERM');
      fnd_message.raise_error;
      --
    end if;
    --
  close c2;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_cost_center_start_end_date;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cost_center_valid >------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure checks that the Cost Center being updated can be seen by the
-- user.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_cost_center_valid
  (p_organization_id         in number,
   p_org_information_context in VARCHAR2) is
  --
  l_proc varchar2(72)  :=  g_package||'chk_cost_center_valid';
  --
  cursor c1 is
    select null
    from   dual
    where  exists
          (select null
           from   hr_organization_units org,
                  hr_organization_information org2,
                  hr_org_info_types_by_class oitbc
           where  org.organization_id = p_organization_id
           and    org.organization_id = org2.organization_id
           and    org2.org_information_context = 'CLASS'
           and    org2.org_information2 = 'Y'
           and    oitbc.org_classification = org2.org_information1
           and    oitbc.org_information_type = 'Organization Name Alias');
  --
  l_c1 c1%rowtype;
  --
begin
  --
  hr_utility.set_location(' Entering:'|| l_proc, 20);
  --
  -- Rules are as follows
  -- Any Cost Center that is being updated must be visible to the user
  -- through the users security profile.
  --
  -- This is only relevant for Organization Name Alias context
  --
  if p_org_information_context <> 'Organization Name Alias' then
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 11);
    return;
    --
  end if;
  --
  -- Check if user can see the organization in question.
  --
  open c1;
    --
    fetch c1 into l_c1;
    if c1%notfound then
      --
      fnd_message.set_name('PER','PER_289701_INVALID_COST_CENTER');
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_cost_center_valid;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cost_center_manager_valid >----------------|
-- ----------------------------------------------------------------------------
--
-- This procedure checks that the Cost Center manager being updated can be
-- seen by the user.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_cost_center_manager_valid
  (p_org_information_context in VARCHAR2,
   p_org_information2        in VARCHAR2,
   p_effective_date          in DATE) is
  --
  l_proc varchar2(72)  :=  g_package||'chk_cost_center_manager_valid';
  l_person_id number;
  --
  cursor c1 is
    select null
    from   per_people_f
    where  person_id = l_person_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_c1 c1%rowtype;
  --
begin
  --
  hr_utility.set_location(' Entering:'|| l_proc, 20);
  --
  -- Rules are as follows
  -- Any Cost Center Manager that is being updated must be visible to the user
  -- through the users security profile.
  --
  -- This is only relevant for Organization Name Alias context
  --
  if p_org_information_context <> 'Organization Name Alias' then
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 11);
    return;
    --
  end if;
  --
  -- Person can be nulled out if they are terminated for example.
  --
  if p_org_information2 is null then
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 12);
    return;
    --
  end if;
  --
  -- Get value of person id.
  --
  begin
    --
    -- Since we are checking the format prior to flex we need to make sure
    -- its all good and valid.
    --
    l_person_id := to_number(p_org_information2);
    --
  exception
    --
    when others then
      --
      fnd_message.set_name('PER','PER_289698_PERSON_ID_INVALID');
      fnd_message.raise_error;
      --
  end;
  --
  -- Check if user can see the manager in question.
  --
  open c1;
    --
    fetch c1 into l_c1;
    if c1%notfound then
      --
      fnd_message.set_name('PER','PER_289702_INVALID_MANAGER');
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_cost_center_manager_valid;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cost_center_man_overlap >------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure checks that the Cost Center Manager Relationship being
-- updated does not overlap an existing Cost Center Manager Relationship.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_cost_center_man_overlap
  (p_organization_id         in NUMBER,
   p_org_information_id      in NUMBER,
   p_org_information_context in VARCHAR2,
   p_org_information3        in VARCHAR2,
   p_org_information4        in VARCHAR2) is
  --
  l_proc varchar2(72)  :=  g_package||'chk_cost_center_man_overlap';
  l_start_date date;
  l_end_date date;
  --
  cursor c1 is
    select null
    from   hr_organization_information
    where  organization_id = p_organization_id
    and    org_information_context = 'Organization Name Alias'
    and    (l_start_date
            between fnd_date.canonical_to_date(org_information3)
            and     nvl(fnd_date.canonical_to_date(org_information4),hr_api.g_eot)
            or
            nvl(l_end_date,hr_api.g_eot)
            between fnd_date.canonical_to_date(org_information3)
            and     nvl(fnd_date.canonical_to_date(org_information4),hr_api.g_eot)
            or fnd_date.canonical_to_date(org_information3)
            between l_start_date
            and     nvl(l_end_date,hr_api.g_eot)
            or nvl(fnd_date.canonical_to_date(org_information4),hr_api.g_eot)
            between l_start_date
            and     nvl(l_end_date,hr_api.g_eot))
    and     org_information_id <> nvl(p_org_information_id,-1)
    and     org_information3 is not null;
  --
  l_c1 c1%rowtype;
  --
  cursor c2 is
    select date_from,
           date_to
    from   hr_organization_units
    where  organization_id = p_organization_id;
  --
  l_c2 c2%rowtype;
  --
begin
  --
  hr_utility.set_location(' Entering:'|| l_proc, 20);
  --
  -- Rules are as follows
  -- Any Cost Center Manager Relationship that is being updated must not
  -- overlap another Cost Center Manager Relationship for the same
  -- Cost Center.
  --
  -- This is only relevant for Organization Name Alias context
  --
  if p_org_information_context <> 'Organization Name Alias' then
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 11);
    return;
    --
  end if;
  --
  -- The row is being updated to null so no need to check for overlap.
  --
  if p_org_information3 is null then
    --
    return;
    --
  end if;
  --
  -- Get value of Start Date.
  --
  begin
    --
    -- Since we are checking the format prior to flex we need to make sure
    -- its all good and valid.
    --
    l_start_date := fnd_date.canonical_to_date(p_org_information3);
    --
  exception
    --
    when others then
      --
      fnd_message.set_name('PER','PER_289695_START_DATE_FORMAT');
      fnd_message.raise_error;
      --
  end;
  --
  -- Get value of End Date.
  --
  begin
    --
    -- Since we are checking the format prior to flex we need to make sure
    -- its all good and valid.
    --
    l_end_date := fnd_date.canonical_to_date(p_org_information4);
    --
  exception
    --
    when others then
      --
      fnd_message.set_name('PER','PER_289696_END_DATE_FORMAT');
      fnd_message.raise_error;
      --
  end;
  --
  hr_utility.set_location('Start Date '||l_start_date,10);
  hr_utility.set_location('End Date '||l_end_date,10);
  hr_utility.set_location('Organization_id '||p_organization_id,10);
  hr_utility.set_location('Org_information_id '||p_org_information_id,10);
  --
  open c1;
    --
    fetch c1 into l_c1;
    if c1%found then
      --
      fnd_message.set_name('PER','PER_289703_CCM_OVERLAP');
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  open c2;
    --
    fetch c2 into l_c2;
    --
    hr_utility.set_location('Start Date '||l_start_date,10);
    hr_utility.set_location('End Date '||l_end_date,10);
    hr_utility.set_location('Org Start Date '||l_c2.date_from,10);
    hr_utility.set_location('Org End Date '||l_c2.date_to,10);
    --
    -- Removed the check for end date for fix of #3137148.
    --
    if l_start_date < l_c2.date_from then
      --
      hr_utility.set_location(' Rel. ship start date is before Org start date '|| l_proc, 15);
      close c2;
      --
      fnd_message.set_name('PER','PER_449079_CCM_BEFORE_ORG');
      fnd_message.raise_error;
      --
    end if;
    --
  close c2;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_cost_center_man_overlap;
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_org_information_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hr_organization_information and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  -- JOIN COMPLETED
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hr_organization_information ori
         , hr_organization_units org
     where ori.org_information_id = p_org_information_id
       and org.organization_id    = ori.organization_id
       and pbg.business_group_id = org.business_group_id; -- AT 27/9/01
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'org_information_id'
    ,p_argument_value     => p_org_information_id
    );
  --
  if ( nvl(hr_ori_bus.g_org_information_id, hr_api.g_number)
       = p_org_information_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_ori_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hr_ori_bus.g_org_information_id:= p_org_information_id;
    hr_ori_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_name >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- if the record being updated or inserted is a business group classification
-- then this procedure checks that the business group name is unique
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_name
   (p_org_information1        IN     hr_organization_information.org_information1%TYPE,
    p_org_information_context IN     hr_organization_information.org_information_context%TYPE,
    p_organization_id         IN     number, --default null, -- R115.21
    p_org_information2        IN     hr_organization_information.org_information2%TYPE
)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_name';
   l_name           hr_all_organization_units.name%TYPE;
   l_exists         number;
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
--
hr_utility.set_location(l_proc, 20);
--
--
-- Check that the business group name is unique if we are adding or updating to
-- a business group classification
--
 select name into l_name from hr_all_organization_units where organization_id = p_organization_id;

if p_org_information1 = 'HR_BG'
 and p_org_information_context = 'CLASS'
 and p_org_information2 = 'Y' then

 select count(*)
 into l_exists
 from hr_organization_information i, hr_all_organization_units u
 where i.organization_id <> p_organization_id
 and i.organization_id = u.organization_id
 and i.org_information1='HR_BG'
 and i.org_information_context='CLASS'
 and i.org_information2 ='Y'
 and u.name = l_name;
if l_exists >0 then
    hr_utility.set_message(800, 'HR_289381_DUPLICATE_BG');
    hr_utility.raise_error;
end if;
end if;
exception
when no_data_found then
    hr_utility.set_message(800, 'HR_289002_INV_ORG_ID');
    hr_utility.raise_error;

end chk_name;

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in hr_ori_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.org_information_id is not null)  and (
    nvl(hr_ori_shd.g_old_rec.org_information_id, hr_api.g_number) <>
    nvl(p_rec.org_information_id, hr_api.g_number)  or
    nvl(hr_ori_shd.g_old_rec.org_information_context, hr_api.g_varchar2) <>
    nvl(p_rec.org_information_context, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information1, hr_api.g_varchar2) <>
    nvl(p_rec.org_information1, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information10, hr_api.g_varchar2) <>
    nvl(p_rec.org_information10, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information11, hr_api.g_varchar2) <>
    nvl(p_rec.org_information11, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information12, hr_api.g_varchar2) <>
    nvl(p_rec.org_information12, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information13, hr_api.g_varchar2) <>
    nvl(p_rec.org_information13, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information14, hr_api.g_varchar2) <>
    nvl(p_rec.org_information14, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information15, hr_api.g_varchar2) <>
    nvl(p_rec.org_information15, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information16, hr_api.g_varchar2) <>
    nvl(p_rec.org_information16, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information17, hr_api.g_varchar2) <>
    nvl(p_rec.org_information17, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information18, hr_api.g_varchar2) <>
    nvl(p_rec.org_information18, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information19, hr_api.g_varchar2) <>
    nvl(p_rec.org_information19, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information2, hr_api.g_varchar2) <>
    nvl(p_rec.org_information2, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information20, hr_api.g_varchar2) <>
    nvl(p_rec.org_information20, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information3, hr_api.g_varchar2) <>
    nvl(p_rec.org_information3, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information4, hr_api.g_varchar2) <>
    nvl(p_rec.org_information4, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information5, hr_api.g_varchar2) <>
    nvl(p_rec.org_information5, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information6, hr_api.g_varchar2) <>
    nvl(p_rec.org_information6, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information7, hr_api.g_varchar2) <>
    nvl(p_rec.org_information7, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information8, hr_api.g_varchar2) <>
    nvl(p_rec.org_information8, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.org_information9, hr_api.g_varchar2) <>
    nvl(p_rec.org_information9, hr_api.g_varchar2) ))
    or (p_rec.org_information_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_utility.set_location('context = '||p_rec.org_information_context,20);
    hr_utility.set_location('org_information1 = '||p_rec.org_information1,30);
    hr_utility.set_location('org_information2 = '||p_rec.org_information2,40);
    hr_utility.set_location('org_information3 = '||p_rec.org_information3,50);
    hr_utility.set_location('org_information4 = '||p_rec.org_information4,60);
    hr_utility.set_location('org_information5 = '||p_rec.org_information5,70);

    /*
    ** Some valuesets used by this flexfield require additional information
    ** this will be passed using profile options. We will create these and
    ** set these on-the-fly now and then we'll call the flex code.
    */
    fnd_profile.put('PER_ORGANIZATION_ID',p_rec.organization_id);
    fnd_profile.put('PER_ORG_INFORMATION_ID',
                    nvl(to_number(p_rec.org_information_id),-1));
    hr_utility.set_location('PER_ORG_INFORMATION_ID'||
                            fnd_profile.value('PER_ORG_INFORMATION_ID'),80);
    hr_utility.set_location('PER_ORGANIZATION_ID'||
                            fnd_profile.value('PER_ORGANIZATION_ID'),80);

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Org Developer DF'
      ,p_attribute_category              => p_rec.org_information_context
      ,p_attribute1_name                 => 'ORG_INFORMATION1'
      ,p_attribute1_value                => p_rec.org_information1
      ,p_attribute2_name                 => 'ORG_INFORMATION2'
      ,p_attribute2_value                => p_rec.org_information2
      ,p_attribute3_name                 => 'ORG_INFORMATION3'
      ,p_attribute3_value                => p_rec.org_information3
      ,p_attribute4_name                 => 'ORG_INFORMATION4'
      ,p_attribute4_value                => p_rec.org_information4
      ,p_attribute5_name                 => 'ORG_INFORMATION5'
      ,p_attribute5_value                => p_rec.org_information5
      ,p_attribute6_name                 => 'ORG_INFORMATION6'
      ,p_attribute6_value                => p_rec.org_information6
      ,p_attribute7_name                 => 'ORG_INFORMATION7'
      ,p_attribute7_value                => p_rec.org_information7
      ,p_attribute8_name                 => 'ORG_INFORMATION8'
      ,p_attribute8_value                => p_rec.org_information8
      ,p_attribute9_name                 => 'ORG_INFORMATION9'
      ,p_attribute9_value                => p_rec.org_information9
      ,p_attribute10_name                => 'ORG_INFORMATION10'
      ,p_attribute10_value               => p_rec.org_information10
      ,p_attribute11_name                => 'ORG_INFORMATION11'
      ,p_attribute11_value               => p_rec.org_information11
      ,p_attribute12_name                => 'ORG_INFORMATION12'
      ,p_attribute12_value               => p_rec.org_information12
      ,p_attribute13_name                => 'ORG_INFORMATION13'
      ,p_attribute13_value               => p_rec.org_information13
      ,p_attribute14_name                => 'ORG_INFORMATION14'
      ,p_attribute14_value               => p_rec.org_information14
      ,p_attribute15_name                => 'ORG_INFORMATION15'
      ,p_attribute15_value               => p_rec.org_information15
      ,p_attribute16_name                => 'ORG_INFORMATION16'
      ,p_attribute16_value               => p_rec.org_information16
      ,p_attribute17_name                => 'ORG_INFORMATION17'
      ,p_attribute17_value               => p_rec.org_information17
      ,p_attribute18_name                => 'ORG_INFORMATION18'
      ,p_attribute18_value               => p_rec.org_information18
      ,p_attribute19_name                => 'ORG_INFORMATION19'
      ,p_attribute19_value               => p_rec.org_information19
      ,p_attribute20_name                => 'ORG_INFORMATION20'
      ,p_attribute20_value               => p_rec.org_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
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
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in hr_ori_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.org_information_id is not null)  and (
    nvl(hr_ori_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hr_ori_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.org_information_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'HR_ORGANIZATION_INFORMATION'
      ,p_attribute_category              =>p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in hr_ori_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_ori_shd.api_updating
      (p_org_information_id                   => p_rec.org_information_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  IF nvl(p_rec.org_information_context, hr_api.g_varchar2) <>
     nvl(hr_ori_shd.g_old_rec.org_information_context, hr_api.g_varchar2) THEN
     l_argument := 'ORG_INFORMATION_CONTEXT';
     RAISE l_error;
  END IF;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_organization_id >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that organization_id of organization unit is present in
--    HR_ALL_ORGANIZATION_UNITS table and valid.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--    p_effective_date
--
--  Post Success:
--    If the organization_id attribute is valid then
--    normal processing continues
--
--  Post Failure:
--    If the organization_id attribute is invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_organization_id
  ( p_organization_id  IN hr_organization_information.organization_id%TYPE,
    p_effective_date   IN DATE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_organization_id';
   l_exists         VARCHAR2(1) := 'N';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check organization_id presence
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT null
      FROM hr_all_organization_units
      WHERE organization_id = p_organization_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'N' THEN
     hr_utility.set_message(800, 'HR_289002_INV_ORG_ID');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_organization_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cls_valid >--------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that ORG_INFORMATION1 for ORG_INFORMATION_CONTEXT 'CLASS' is
--    present in HR_LOKUPS table and valid.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_org_information_context
--    p_org_information1
--    p_effective_date
--
--  Post Success:
--    If ORG_INFORMATION1 is present and valid then
--    normal processing continues
--
--  Post Failure:
--    If ORG_INFORMATION1 is present and invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_cls_valid
  ( p_org_information_context IN hr_organization_information.org_information_context%TYPE,
    p_org_information1        IN hr_organization_information.org_information1%TYPE,
    p_effective_date          IN     DATE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_cls_valid';
   l_exists         VARCHAR2(1) := 'N';
--
   cursor csr_cls_valid IS
     SELECT 'Y'
        FROM hr_lookups
        WHERE lookup_type = 'ORG_CLASS'
          AND lookup_code = p_org_information1
          AND enabled_flag = 'Y'
          AND p_effective_date BETWEEN nvl(start_date_active,p_effective_date)
          AND nvl(end_date_active,p_effective_date);
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check classification
--
  IF p_org_information_context = 'CLASS' THEN
    IF p_org_information1 IS null THEN
      hr_utility.set_message(800, 'HR_52760_NULL_CLSF');
      hr_utility.raise_error;
    ELSE
      OPEN csr_cls_valid;
      FETCH csr_cls_valid INTO l_exists;
--
      hr_utility.set_location(l_proc, 20);
--
      IF csr_cls_valid%notfound THEN
        CLOSE csr_cls_valid;
        hr_utility.set_message(800, 'HR_52759_INV_CLSF');
        hr_utility.raise_error;
      ELSE
        CLOSE csr_cls_valid;
      END IF;
    END IF;
  END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_cls_valid;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cls_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that classification of organization unit is not present in
--    HR_ORGANIZATION_INFORMATION table for ORGANIZATION_ID.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--    p_org_information1
--
--  Post Success:
--    If classification is not present then
--    normal processing continues
--
--  Post Failure:
--    If classification is already present then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_cls_unique
  ( p_organization_id  IN hr_organization_information.organization_id%TYPE,
    p_org_information1 IN hr_organization_information.org_information1%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_cls_unique';
   l_exists         VARCHAR2(1) := 'N';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check classification presence
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT null
      FROM hr_organization_information
      WHERE organization_id = p_organization_id
        AND org_information_context = 'CLASS'
        AND org_information1 = p_org_information1);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN null;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'Y' THEN
     hr_utility.set_message(800, 'HR_52761_ORG_CLSF_EXISTS');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_cls_unique;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_info_type_valid >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that info type is present in the list of info types
--    for all current enabled classifications in
--    HR_ORGANIZATION_INFORMATION table for ORGANIZATION_ID.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--    p_org_information_context
--
--  Post Success:
--    If info type is present in the list then
--    normal processing continues
--
--  Post Failure:
--    If info type is not present in the list then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_info_type_valid
  ( p_organization_id  IN hr_organization_information.organization_id%TYPE,
    p_org_information_context IN hr_organization_information.org_information_context%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_info_type_valid';
   l_exists         VARCHAR2(1) := 'N';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check info type presence
--
-- Added nav method 'LOC'      AT 27/9/01
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT hoit.org_information_type
      FROM hr_org_information_types hoit
      WHERE hoit.org_information_type = p_org_information_context
        AND (hoit.navigation_method = 'GS' OR hoit.navigation_method = 'GM' OR hoit.navigation_method = 'LOC')
        AND EXISTS
        (SELECT null
         FROM hr_org_info_types_by_class hitbc
           ,hr_organization_information hoi
         WHERE hitbc.org_information_type = hoit.org_information_type
           AND hitbc.org_classification = hoi.org_information1
           AND hoi.org_information2 = 'Y'
           AND hoi.org_information_context = 'CLASS'
           AND hoi.organization_id = p_organization_id)
       );
   EXCEPTION
   WHEN NO_DATA_FOUND THEN null;
  END;
-- VT maybe we still need it later modified and added to the
--    select statement above
--
--        AND hoit.legislation_code =
--        (SELECT pbg.legislation_code
--         FROM per_business_groups pbg
--           ,hr_all_organization_units haou
--         WHERE haou.organization_id = p_organization_id
--           AND haou.business_group_id = pbg.business_group_id)
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'N' THEN
     hr_utility.set_message(800, 'HR_289003_INV_INFO_TYPE');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_info_type_valid;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_info_type_unique >-------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that info type is present in the
--    HR_ORGANIZATION_INFORMATION table for ORGANIZATION_ID.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--    p_org_information_context
--
--  Post Success:
--    If info type is not present then
--    normal processing continues
--
--  Post Failure:
--    If info type is present in then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_info_type_unique
  ( p_organization_id  IN hr_organization_information.organization_id%TYPE,
    p_org_information_context IN hr_organization_information.org_information_context%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_info_type_unique';
   l_exists         VARCHAR2(1) := 'N';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check info type presence
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT null
      FROM hr_organization_information hoi
          ,hr_org_information_types hoit
      WHERE hoi.org_information_context = p_org_information_context
        AND hoi.organization_id = p_organization_id
        AND hoit.org_information_type = p_org_information_context
        AND hoit.navigation_method = 'GS');
   EXCEPTION
   WHEN NO_DATA_FOUND THEN null;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'Y' THEN
     hr_utility.set_message(800, 'HR_289004_INFO_TYPE_EXISTS');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_info_type_unique;
--
-- Bug 3456540 Start
procedure chk_location(
   p_organization_id  IN hr_organization_information.organization_id%TYPE
) is
--
   cursor csr_location is
   select location_id
   from hr_all_organization_units
   where organization_id = p_organization_id;
--
   l_location_id number;
--
begin
--
   open csr_location;
   fetch csr_location into l_location_id;
   close csr_location;
--
   if l_location_id is null then
      hr_utility.set_message(800, 'HR_6612_ORG_LEGAL_NO_LOCATION');
      hr_utility.raise_error;
   end if;
--
end chk_location;
--
--
-- Bug 3456540 End
-- Start of Bug No 2586522
-- ----------------------------------------------------------------------------
-- |---------------------------< check_state_tax_rules >----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--  US specific validation to check that if the structure being updated is
--  'State Tax Rules' and the segment being updated is WC Carrier then
--  check that a WC rate for this carrier is not being referenced by
--  an assignment's 'WC Override Code' on the SCL 'GREs and other data'
--
--  Pre-conditions:
--   When Org_Information_context = 'State Tax Rules'.
--
--  In Arguments:
--    X_Org_Information_ID
--    X_org_information1
--    X_org_information8
--
--  Post Success:
--    Normal processing continues
--
--  Post Failure:
--    Error will be raised and processing is terminated.
--
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
Procedure check_state_tax_rules
(X_Org_Information_ID in hr_organization_information.organization_id%TYPE,
 X_org_information1 in  hr_organization_information.org_information1%TYPE,
 X_org_information8 in  hr_organization_information.org_information8%TYPE )
as
--
-- declare local variables
--
l_dummy      VARCHAR2(1);
l_state_code VARCHAR2(2);
l_carrier_id VARCHAR2(17);
l_proc       VARCHAR2(72)  :=  g_package||'check_state_tax_rules';

--
-- declare cursors
--

CURSOR  get_orig_values IS
select
        org_information1,
        org_information8
from
        hr_organization_information
where
        org_information_id      = X_org_information_id;
--

CURSOR check_override IS
SELECT /*+ STAR_TRANSFORMATION */
        'x'
FROM
        pay_wc_rates wcr,
        pay_wc_funds wcf
WHERE
        wcf.carrier_id = l_carrier_id   AND
        wcf.state_code = l_state_code   AND
        wcr.fund_id     = wcf.fund_id
AND EXISTS
      ( SELECT  'code referenced in override'
        FROM    per_assignments_f a,
                fnd_id_flex_structures_vl ifs,
                hr_soft_coding_keyflex sck
        WHERE   sck.segment1    = to_char(X_org_information_id) -- #1683897
        AND     segment8        = to_char(wcr.wc_code)
        AND     ifs.id_flex_structure_name = 'GREs and other data'
        AND     sck.id_flex_num = ifs.id_flex_num
        AND     a.assignment_type = 'E'
        AND     a.soft_coding_keyflex_id = sck.soft_coding_keyflex_id );

Begin
 hr_utility.set_location('Entering:'||l_proc, 10);

--
-- get original values
--
 OPEN  get_orig_values;
 FETCH get_orig_values into l_state_code, l_carrier_id;
 CLOSE get_orig_values;
 --
 -- check if values have changed
 --
 IF ((l_state_code <> X_org_information1) OR
     (NVL(l_carrier_id, X_org_information8) <> X_org_information8) OR
      X_org_information8 IS NULL)
 THEN
    hr_utility.set_location('Entering:'||l_proc, 20);
  OPEN  check_override;
  FETCH check_override into l_dummy;
  IF check_override%FOUND
  THEN
      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800,'HR_51039_ORG_WC_OVRRD_RATE_REF');
      hr_utility.raise_error;
  END IF;
  CLOSE check_override;
 hr_utility.set_location(l_proc, 40);
 END IF;
 hr_utility.set_location('Leaving :'||l_proc, 50);
END check_state_tax_rules;
--
-- End of bug No 2586522
--
--
-- Start of fix for bug 3679256
--
-- ----------------------------------------------------------------------------
-- |----------------------------<  Chk_Bus_grp  >------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--   Retrives Business group id based on Org id passed and sets Context values
--   'Legislation code' and 'Security profile id', which is further used by
--   by Lookup 'HR_LOOKUP'.
--
--  Pre-conditions:
--     Valid organization id is passed.
--
--  In Arguments:
--    p_organization_id
--
--
--  Post Success:
--    Set Context values for LEG CODE and Security Group Id.
--
--
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
Procedure chk_bus_grp
   (p_organization_id in number
   )is


  l_proc  varchar2(72) := g_package||'chk_business_grp';
  l_bg_id number ;
  -- Fetch BG Id from Org id.
  cursor C_BG is
   select business_group_id
        from hr_all_organization_units
        where organization_id = p_organization_id;

Begin
  Open c_bg;
  Fetch c_bg into l_bg_id;
     hr_api.validate_bus_grp_id(l_bg_id);  -- Validate Bus Grp
  Close c_bg;


End chk_bus_grp;
--
-- End of fix for bug 3679256
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hr_ori_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_bg_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ORGANIZATION_ID'
    ,p_argument_value     => p_rec.organization_id
    );
--
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ORG_INFORMATION_CONTEXT'
    ,p_argument_value     => p_rec.org_information_context
    );
--
  -- Validate organization_id
  --=========================
    chk_organization_id(
        p_organization_id => p_rec.organization_id,
        p_effective_date  => p_effective_date);


  -- Check unique business group name
  -- ================================
    chk_name(
       p_org_information1         =>  p_rec.org_information1,
       p_org_information_context  =>  p_rec.org_information_context,
       p_organization_id          =>  p_rec.organization_id,
       p_org_information2         =>  p_rec.org_information2);
  --
  IF p_rec.org_information_context = 'CLASS' THEN

--
-- Start of fix for bug 3679256
--
  -- Validate Business Group.
  --=========================
   If p_rec.org_information1 <> 'HR_BG' then
   chk_bus_grp(
        p_organization_id => p_rec.organization_id);
   End if;
--
-- End of fix for bug 3679256
--

    -- Validate classification
    --=========================
    chk_cls_valid(
    p_org_information_context => p_rec.org_information_context,
    p_org_information1 => p_rec.org_information1,
    p_effective_date   => p_effective_date);
    --
    -- Validate org classification unique
    --=========================
    chk_cls_unique(
    p_organization_id   => p_rec.organization_id,
    p_org_information1  => p_rec.org_information1);

    -- Bug 3456540 Start
    -- Validation for legal entity.
    -- Check if the organization has a location attached to it
    if p_rec.org_information1 = 'HR_LEGAL' and p_rec.org_information2 = 'Y' then
       chk_location( p_organization_id => p_rec.organization_id );
    end if;
    -- Bug 3456540 End
    --
  ELSE
    -- Validate info type
    --=========================
    chk_info_type_valid(
    p_organization_id => p_rec.organization_id,
    p_org_information_context => p_rec.org_information_context);
    --
    -- Validate info type unique
    --=========================
    chk_info_type_unique(
    p_organization_id   => p_rec.organization_id,
    p_org_information_context  => p_rec.org_information_context);
    --
  END IF;
  --
  if p_rec.org_information_context = 'Organization Name Alias' then
    --
    chk_cost_center_start_date
      (p_org_information_context => p_rec.org_information_context,
       p_org_information2        => p_rec.org_information2,
       p_org_information3        => p_rec.org_information3,
       p_org_information4        => p_rec.org_information4);
    --
    chk_cost_center_start_end_date
      (p_org_information_context => p_rec.org_information_context,
       p_org_information2        => p_rec.org_information2,
       p_org_information3        => p_rec.org_information3,
       p_org_information4        => p_rec.org_information4);
    --
    chk_cost_center_valid
      (p_organization_id         => p_rec.organization_id,
       p_org_information_context => p_rec.org_information_context);
    --
    chk_cost_center_manager_valid
      (p_org_information_context => p_rec.org_information_context,
       p_org_information2        => p_rec.org_information2,
       p_effective_date          => p_effective_date);
    --
    chk_cost_center_man_overlap
      (p_organization_id         => p_rec.organization_id,
       p_org_information_id      => p_rec.org_information_id,
       p_org_information_context => p_rec.org_information_context,
       p_org_information3        => p_rec.org_information3,
       p_org_information4        => p_rec.org_information4);
    --
  end if;
  --
--
-- start of fix for Bug #2586522
--
   if p_rec.org_information_context = 'FR_ESTAB_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIRET(X_SIRET => p_rec.org_information2);
   elsif p_rec.org_information_context = 'FR_ESTAB_PREV_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIRET(X_SIRET => p_rec.org_information1);
   end if;

   if p_rec.org_information_context = 'FR_COMP_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIREN(X_SIREN => p_rec.org_information1);
   elsif p_rec.org_information_context = 'FR_COMP_PREV_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIREN(X_SIREN => p_rec.org_information1);
   end if;

   HR_ORG_INFORMATION_PKG.validate_business_group_name
     (p_organization_id         => p_rec.Organization_Id
     ,p_org_information_context => p_rec.Org_Information_Context
     ,p_org_information1        => p_rec.Org_Information1
     ,p_org_information2        => p_rec.Org_Information2
     );

--
-- End of fix for Bug #2586522
--
  --
  -- Added fix for bug #4745845. Do not validate ddf for not usable OU.
  if p_rec.org_information_context = 'Operating Unit Information' and
     p_rec.org_information6 = 'N' then
     null;
  else
    hr_ori_bus.chk_ddf(p_rec);
  end if;
  --
  -- Descriptive Flexfield is context dependent HR_ORGANIZATION_INFORMATION
  --
  --fix for bug 6376908.
  --Added the if condition before calling the procedure chk_df.
  --
  if(p_rec.org_information_context<>'CLASS') then
  hr_ori_bus.chk_df(p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hr_ori_shd.g_rec_type
  ) is
--
  cursor c_date (p_id number) is
   select min(effective_start_date), max(effective_end_date)
   from per_all_people_f
   where current_employee_flag='Y'
   and person_id=p_id;
  l_proc  varchar2(72) := g_package||'update_validate';
  l_startdate date;
  l_enddate date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ORG_INFORMATION_CONTEXT'
    ,p_argument_value     => p_rec.org_information_context
    );
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Check unique business group name
  -- ================================
  chk_name(
    p_org_information1         =>  p_rec.org_information1,
    p_org_information_context  =>  p_rec.org_information_context,
    p_organization_id          =>  p_rec.organization_id,
    p_org_information2         =>  p_rec.org_information2
);
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  -- 3456540 Start
  if p_rec.org_information_context = 'CLASS' then
    -- Validation for legal entity.
    -- Check if the organization has a location attached to it
    if p_rec.org_information1 = 'HR_LEGAL' and p_rec.org_information2 = 'Y' then
       chk_location( p_organization_id => p_rec.organization_id );
    end if;
  end if;
  -- 3456540 end
  if p_rec.org_information_context = 'Organization Name Alias' then
    --
    chk_cost_center_start_date
      (p_org_information_context => p_rec.org_information_context,
       p_org_information2        => p_rec.org_information2,
       p_org_information3        => p_rec.org_information3,
       p_org_information4        => p_rec.org_information4);
    --
    chk_cost_center_start_end_date
      (p_org_information_context => p_rec.org_information_context,
       p_org_information2        => p_rec.org_information2,
       p_org_information3        => p_rec.org_information3,
       p_org_information4        => p_rec.org_information4);
    --
    chk_cost_center_valid
      (p_organization_id         => p_rec.organization_id,
       p_org_information_context => p_rec.org_information_context);
    --
    chk_cost_center_manager_valid
      (p_org_information_context => p_rec.org_information_context,
       p_org_information2        => p_rec.org_information2,
       p_effective_date          => p_effective_date);
    --
    chk_cost_center_man_overlap
      (p_organization_id         => p_rec.organization_id,
       p_org_information_id      => p_rec.org_information_id,
       p_org_information_context => p_rec.org_information_context,
       p_org_information3        => p_rec.org_information3,
       p_org_information4        => p_rec.org_information4);
    --
  end if;
  --
--
-- start of fix for Bug #2586522
--
IF (p_rec.org_information_context = 'State Tax Rules')
THEN
 check_state_tax_rules
   (X_Org_Information_ID => p_rec.org_information_id,
    X_Org_information1   => p_rec.org_information1,
    X_Org_information8   => p_rec.org_information8);
END IF;

   if p_rec.org_information_context = 'FR_ESTAB_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIRET(X_SIRET => p_rec.org_information2);
   elsif p_rec.org_information_context = 'FR_ESTAB_PREV_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIRET(X_SIRET => p_rec.org_information1);
   end if;

   if p_rec.org_information_context = 'FR_COMP_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIREN(X_SIREN => p_rec.org_information1);
   elsif p_rec.org_information_context = 'FR_COMP_PREV_INFO' then
      HR_ORG_INFORMATION_PKG.Validate_SIREN(X_SIREN => p_rec.org_information1);
   end if;

   HR_ORG_INFORMATION_PKG.validate_business_group_name
     (p_organization_id         => p_rec.Organization_Id
     ,p_org_information_context => p_rec.Org_Information_Context
     ,p_org_information1        => p_rec.Org_Information1
     ,p_org_information2        => p_rec.Org_Information2
     );
/* To check uniqueness of identifier segment in extra information type
 of  'grouping unit information' for FR Public Section'*/
/*
if p_rec.Org_Information_Context = 'FR_PQH_GROUPING_UNIT_INFO' then
        pqh_fr_org_validate_pkg.check_unique_identifier
             ( p_org_information_context => p_rec.Org_Information_Context,
               p_org_information_id      => NULL,
               p_org_information6        => p_rec.Org_Information6);
 end if;
*/
--
-- Added by FS
-- End of fix for Bug #2586522
--

--Added for 3034234.Start of fix.
IF (p_rec.org_information_context = 'Organization Name Alias') then
   hr_utility.set_location('The person:'|| p_rec.org_information2,333);
   open c_date(to_number(p_rec.org_information2));
   fetch c_date into l_startdate,l_enddate;
   hr_utility.set_location('Start:'||l_startdate||' Enddate :'||l_enddate,555);
   if c_date%notfound then
   close c_date;
     if(fnd_date.canonical_to_date(p_rec.org_information4) > fnd_date.date_to_canonical(l_enddate)) then

       hr_ori_bus.chk_ddf(p_rec);
       --
     end if;
   close c_date;
   end if;

 else

  hr_ori_bus.chk_ddf(p_rec);
  --
end if;
 -- End of fix for 3034234
  --
   hr_ori_bus.chk_df(p_rec);
   hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_ori_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_ori_bus;

/
