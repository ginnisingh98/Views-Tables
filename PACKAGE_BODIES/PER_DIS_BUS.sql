--------------------------------------------------------
--  DDL for Package Body PER_DIS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DIS_BUS" as
/* $Header: pedisrhi.pkb 115.8 2002/12/04 18:57:24 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_dis_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_disability_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_disability_id                        in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_disabilities_f dis
         , per_people_f per
     where dis.disability_id = p_disability_id
       and dis.person_id = per.person_id
       and pbg.business_group_id = per.business_group_id;
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
    ,p_argument           => 'disability_id'
    ,p_argument_value     => p_disability_id
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_disability_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_disabilities_f dis
         , per_people_f per
     where dis.disability_id = p_disability_id
      and dis.person_id = per.person_id
      and pbg.business_group_id = per.business_group_id;
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
    ,p_argument           => 'disability_id'
    ,p_argument_value     => p_disability_id
    );
  --
  if ( nvl(per_dis_bus.g_disability_id, hr_api.g_number)
       = p_disability_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_dis_bus.g_legislation_code;
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
    per_dis_bus.g_disability_id     := p_disability_id;
    per_dis_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_person_id >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that PERSON_ID is not null and that
--    it exists in per_people_f on the effective_date.
--    (Insert only  - non updateable)
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_person_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_person_id
  (p_person_id             in per_disabilities_f.person_id%TYPE
  ,p_effective_date        in per_disabilities_f.effective_start_date%TYPE
  )
  is
--
   cursor csr_person is
     select   null
     from     per_people_f ppf
     where    ppf.person_id = p_person_id
     and      p_effective_date between ppf.effective_start_date
                               and     ppf.effective_end_date;
   --
   l_exists             varchar2(1);
   l_proc               varchar2(72)  :=  g_package||'chk_person_id';
   --
   --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  if p_person_id is null then
    hr_utility.set_message(800, 'HR_52892_DIS_PERSON_NULL');
    hr_utility.raise_error;
  else
  --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check that person exists on this effective date
    --
    open csr_person;
    fetch csr_person into l_exists;
    if csr_person%notfound then
      close csr_person;
      hr_utility.set_message(800, 'HR_52911_DIS_INV_PERSON');
      hr_utility.raise_error;
    end if;
    close csr_person;
    end if;
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_person_id;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_incident_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that INCIDENT_ID exists in per_work_incidents on the
--    effective_date for the person_id. Check that the value matches
--    that of the work incident that is parent of the medical assessment record
--    that has previously been linked to the disability, if one exists.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_disability_id
--    p_person_id
--    p_effective_date
--    p_incident_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_incident_id
  (p_disability_id         in per_disabilities_f.disability_id%TYPE
  ,p_person_id             in per_disabilities_f.person_id%TYPE
  ,p_effective_date        in per_disabilities_f.effective_start_date%TYPE
  ,p_incident_id           in per_disabilities_f.incident_id%TYPE
  )
  is
--
   cursor csr_inc is
     select   null
     from     per_work_incidents pwi
     where    pwi.person_id = p_person_id
     and      pwi.incident_id = p_incident_id
     and      p_effective_date >= pwi.incident_date;
   --
   cursor csr_mea is
	select   null
	from     per_medical_assessments pma
	where    pma.disability_id = p_disability_id
	and      pma.incident_id <> p_incident_id
	and      pma.consultation_result = 'DIS';

   l_proc               varchar2(72)  :=  g_package||'chk_incident_id';
   l_dummy              varchar2(1);
   --
   --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
    --
    -- validate if:
    --  1) inserting
    --  2) updating and value has changed
    --
    if ((p_disability_id is null) or
       ((p_disability_id is not null) and
         (per_dis_shd.g_old_rec.incident_id <> p_incident_id))) then
    --
      hr_utility.set_location(l_proc, 3);

      if p_incident_id is not null then
      --
      -- Check the incident exists in per_work_incidents
      -- for the person_id, with incident_date <= effective_date
      --
        open csr_inc;
        fetch csr_inc into l_dummy;
        if csr_inc%NOTFOUND then
          close csr_inc;
          hr_utility.set_message(800, 'HR_289017_DIS_INV_INC');
          hr_utility.raise_error;
        end if;
        close csr_inc;
        --
        hr_utility.set_location(l_proc, 6);
        --
        -- The value must match that of the work incident id that is held
        -- on the parent medical assessment record that has previously been
        -- linked to the disability, if one exists.
        --
	hr_utility.set_location(l_proc, 8);
	open csr_mea;
        fetch csr_mea into l_dummy;
	if csr_mea%FOUND then
	  close csr_mea;
	  hr_utility.set_message(800, 'HR_289047_DIS_INV_INC_MEA');
	  hr_utility.raise_error;
        end if;
	close csr_mea;
        --
      end if;
    --
    end if;
  --
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end chk_incident_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_category >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that mandatory CATEGORY value is not null and that
--    it exists and is enabled in hr_leg_lookups view for the type
--    'DISABILITY_CATEGORY' on the validation date range.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_disability_id
--    p_category
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_category
  (p_disability_id          in     per_disabilities_f.disability_id%TYPE
  ,p_category               in     per_disabilities_f.category%TYPE
  ,p_effective_date         in     date
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  )
  is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_category';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Ensure mandatory category is set
  if p_category is null then
    hr_utility.set_message(800, 'HR_52912_DIS_CATEGORY_NULL');
    hr_utility.raise_error;
  else
    --
    -- validate if:
    --  1) inserting
    --  2) updating and value has changed
    --
    if ((p_disability_id is null) or
       ((p_disability_id is not null) and
         (per_dis_shd.g_old_rec.category <> p_category))) then
    --
      hr_utility.set_location(l_proc, 30);
    --
      if hr_api.not_exists_in_dt_leg_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'DISABILITY_CATEGORY'
        ,p_lookup_code           => p_category
         )
       then
         --
         hr_utility.set_message(800, 'HR_52913_DIS_INV_CATEGORY');
         hr_utility.raise_error;
      end if;
    end if;
  end if;
--
hr_utility.set_location(' Leaving:'|| l_proc, 40);
--
end chk_category;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_status >--------------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that the passed in lookup code exists in hr_lookups for the with an
--    enabled flag set to 'Y' and that the effective start date of the disability
--    is between start date active and end date active in hr_lookups.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_disability_id
--    p_status
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    If lookup exists and can be derived then processing
--    continues
--
--  Post Failure:
--    If lookup is not valid or cannot be derived then an
--    application error is raised and processing is terminated
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_status
 (p_disability_id          in     per_disabilities_f.disability_id%TYPE
 ,p_status                 in     per_disabilities_f.status%TYPE
 ,p_effective_date         in     date
 ,p_validation_start_date  in     date
 ,p_validation_end_date    in     date
 )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_status';
   l_exists         varchar2(1);
   l_api_updating   boolean;
--
begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
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
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Ensure mandatory status is set
  if p_status is null then
    hr_utility.set_message(800, 'HR_289016_DIS_STATUS_NULL');
    hr_utility.raise_error;
  else
    --
    -- validate if:
    --  1) inserting
    --  2) updating and value has changed
    --
    if ((p_disability_id is null) or
       ((p_disability_id is not null) and
         (per_dis_shd.g_old_rec.status <> p_status))) then
    --
      hr_utility.set_location(l_proc, 30);
    --
      if hr_api.not_exists_in_dt_leg_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'DISABILITY_STATUS'
        ,p_lookup_code           => p_status
         )
       then
         --
         hr_utility.set_message(800, 'HR_52913_DIS_INV_STATUS');
         hr_utility.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
  --
end chk_status;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_quota_fte >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that mandatory quota_fte is set, and is within the range >= 0 < 100.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_quota_fte
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_quota_fte
  (p_quota_fte          in     per_disabilities_f.quota_fte%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_quota_fte';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- check not null
  if p_quota_fte is null then
    hr_utility.set_message(800, 'HR_52915_DIS_QUOTA_NULL');
    hr_utility.raise_error;
  elsif (p_quota_fte < 0 ) or (p_quota_fte >= 100 ) then
    -- check not negative or 100 or over
    hr_utility.set_message(800, 'HR_52916_DIS_INV_QUOTA');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end chk_quota_fte;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_reason >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that REASON value exists and is enabled in hr_leg_lookups view
--     for the type 'DISABILITY_REASON' on the validation date range.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_disability_id
--    p_reason
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_reason
  (p_disability_id          in     per_disabilities_f.disability_id%TYPE
  ,p_reason                 in     per_disabilities_f.reason%TYPE
  ,p_effective_date         in     date
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  )
  is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_reason';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory arguments
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  --
 if p_reason is not null then
  --
  -- validate if:
  -- 1) inserting
  -- 2) updating and value has changed
  --
  if ((p_disability_id is null) or
     ((p_disability_id is not null) and
       (per_dis_shd.g_old_rec.reason <> p_reason))) then
  --
    hr_utility.set_location(l_proc, 30);
  --
    if hr_api.not_exists_in_dt_leg_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'DISABILITY_REASON'
      ,p_lookup_code           => p_reason
       )
     then
       --
       hr_utility.set_message(800, 'HR_52917_DIS_INV_REASON');
       hr_utility.raise_error;
    end if;
  end if;
 end if;
--
hr_utility.set_location(' Leaving:'|| l_proc, 40);
--
end chk_reason;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_degree >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that degree is greater than zero and not greater than one hundred.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_degree
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_degree
  (p_degree          in     per_disabilities_f.degree%TYPE) is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_degree';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- check within range
  if p_degree is not null then
    if (p_degree <= 0) or (p_degree > 100)  then
      hr_utility.set_message(800, 'HR_52918_DIS_INV_DEGREE');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end chk_degree;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_organization_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate organization_id is in same business group as person, and is
--    external type. Ensure organization_id is defined under class of
--    disability_org.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_disability_id
--    p_organization_id
--    p_business_group_id
--    p_validation_start_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
procedure chk_organization_id
  (p_disability_id           in  per_disabilities_f.disability_id%TYPE
  ,p_organization_id         in  per_disabilities_f.organization_id%TYPE
  ,p_business_group_id       in  per_all_people_f.business_group_id%TYPE
  ,p_validation_start_date   in  per_disabilities_f.effective_start_date%TYPE
  )
is
   --
  cursor csr_org is
    select   business_group_id
    from     hr_all_organization_units hou
    where    hou.organization_id = p_organization_id
    and      p_validation_start_date between hou.date_from and nvl(hou.date_to, hr_api.g_eot)
    and      hou.internal_external_flag = 'EXT';
   --
  cursor csr_org_inf is
    select   null
    from     hr_organization_information hoi
    where    hoi.organization_id = p_organization_id
    and      hoi.org_information_context = 'CLASS'
    and      hoi.org_information1 = 'DISABILITY_ORG'
    and      hoi.org_information2 = 'Y';
  --
  l_exists               varchar2(1);
  l_proc                 varchar2(72)  :=  g_package||'chk_organization_id';
  l_business_group_id    per_assignments_f.business_group_id%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date);
  --
  if  p_organization_id is not null then
  --
    hr_utility.set_location(l_proc, 20);
    --
    -- validate if:
    -- 1) inserting
    -- 2) updating and value has changed
    --
    if ((p_disability_id is null) or
       ((p_disability_id is not null) and
       (per_dis_shd.g_old_rec.organization_id <> p_organization_id))) then
    --
      hr_utility.set_location(l_proc, 30);
    --
    -- check org exists in hr_all_organization_units (fk) for the persons bg
    -- within the validation date range.
      open csr_org;
      fetch csr_org into l_business_group_id;
      if csr_org%notfound then
        close csr_org;
        -- error as org not found
        hr_utility.set_message(800, 'HR_52919_DIS_INV_ORG');
        hr_utility.raise_error;
      else
        if l_business_group_id <> p_business_group_id then
          close csr_org;
          -- error as org is in different business group to person
          hr_utility.set_message(800, 'HR_52920_DIS_INV_ORG_BG');
          hr_utility.raise_error;
        end if;
      end if;
      close csr_org;
      hr_utility.set_location(l_proc, 40);
      --
      -- check org exists in hr_organization_information for the relevant
      -- organisation class.
      open csr_org_inf;
      fetch csr_org_inf into l_exists;
      if csr_org_inf%notfound then
        close csr_org_inf;
        -- error as org is not in the correct class of disability_org
        hr_utility.set_message(800, 'HR_52921_DIS_INV_ORG_CLASS');
        hr_utility.raise_error;
      end if;
      close csr_org_inf;
    --
    end if;
  end if;
--
  hr_utility.set_location('Entering:'|| l_proc, 50);
--
end chk_organization_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_registration_details >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--    Validate registration_id, registration_date and registration_exp_date
--
--  Pre-conditions :
--
--  In Arguments :
--    p_registration_id
--    p_registration_date
--    p_registration_exp_date
--    p_organization_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
procedure chk_registration_details
  (p_organization_id         in  per_disabilities_f.organization_id%TYPE
  ,p_registration_id         in  per_disabilities_f.registration_id%TYPE
  ,p_registration_date       in  per_disabilities_f.registration_date%TYPE
  ,p_registration_exp_date   in  per_disabilities_f.registration_exp_date%TYPE
  ) IS
--
l_proc                 varchar2(72)  :=  g_package||'chk_registration_details';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- when inserting or updating
  -- disallow registration details if org is null
  if p_organization_id is null then
    if p_registration_id is not null then
      hr_utility.set_message(800, 'HR_52922_DIS_REG_ID_NULL');
      hr_utility.raise_error;
    elsif p_registration_date is not null then
      hr_utility.set_message(800, 'HR_52923_DIS_REG_DATE_NULL');
      hr_utility.raise_error;
    elsif p_registration_exp_date is not null then
      hr_utility.set_message(800, 'HR_52924_DIS_REG_EXP_DATE_NULL');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- ensure reg date is set if reg exp is set and
  -- that it is before reg expiry date
  if (p_registration_date is not null and p_registration_exp_date is not null) then
    if (p_registration_date > p_registration_exp_date) then
      hr_utility.set_message(800, 'HR_52914_DIS_INV_DATES');
      hr_utility.raise_error;
    end if;
  elsif (p_registration_date is null and p_registration_exp_date is not null) then
    hr_utility.set_message(800, 'HR_52926_DIS_REG_NOT_NULL');
    hr_utility.raise_error;
  end if;
--
hr_utility.set_location('Leaving:'|| l_proc, 30);
--
end chk_registration_details;
--
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
  (p_rec in per_dis_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.disability_id is not null)  and (
    nvl(per_dis_shd.g_old_rec.dis_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information_category, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information1, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information1, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information2, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information2, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information3, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information3, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information4, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information4, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information5, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information5, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information6, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information6, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information7, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information7, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information8, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information8, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information9, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information9, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information10, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information10, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information11, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information11, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information12, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information12, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information13, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information13, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information14, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information14, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information15, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information15, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information16, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information16, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information17, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information17, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information18, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information18, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information19, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information19, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information20, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information20, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information21, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information21, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information22, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information22, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information23, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information23, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information24, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information24, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information25, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information25, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information26, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information26, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information27, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information27, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information28, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information28, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information29, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information29, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.dis_information30, hr_api.g_varchar2) <>
    nvl(p_rec.dis_information30, hr_api.g_varchar2) ))
    or (p_rec.disability_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Disability Developer DF'
      ,p_attribute_category              => p_rec.DIS_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'DIS_INFORMATION1'
      ,p_attribute1_value                => p_rec.dis_information1
      ,p_attribute2_name                 => 'DIS_INFORMATION2'
      ,p_attribute2_value                => p_rec.dis_information2
      ,p_attribute3_name                 => 'DIS_INFORMATION3'
      ,p_attribute3_value                => p_rec.dis_information3
      ,p_attribute4_name                 => 'DIS_INFORMATION4'
      ,p_attribute4_value                => p_rec.dis_information4
      ,p_attribute5_name                 => 'DIS_INFORMATION5'
      ,p_attribute5_value                => p_rec.dis_information5
      ,p_attribute6_name                 => 'DIS_INFORMATION6'
      ,p_attribute6_value                => p_rec.dis_information6
      ,p_attribute7_name                 => 'DIS_INFORMATION7'
      ,p_attribute7_value                => p_rec.dis_information7
      ,p_attribute8_name                 => 'DIS_INFORMATION8'
      ,p_attribute8_value                => p_rec.dis_information8
      ,p_attribute9_name                 => 'DIS_INFORMATION9'
      ,p_attribute9_value                => p_rec.dis_information9
      ,p_attribute10_name                => 'DIS_INFORMATION10'
      ,p_attribute10_value               => p_rec.dis_information10
      ,p_attribute11_name                => 'DIS_INFORMATION11'
      ,p_attribute11_value               => p_rec.dis_information11
      ,p_attribute12_name                => 'DIS_INFORMATION12'
      ,p_attribute12_value               => p_rec.dis_information12
      ,p_attribute13_name                => 'DIS_INFORMATION13'
      ,p_attribute13_value               => p_rec.dis_information13
      ,p_attribute14_name                => 'DIS_INFORMATION14'
      ,p_attribute14_value               => p_rec.dis_information14
      ,p_attribute15_name                => 'DIS_INFORMATION15'
      ,p_attribute15_value               => p_rec.dis_information15
      ,p_attribute16_name                => 'DIS_INFORMATION16'
      ,p_attribute16_value               => p_rec.dis_information16
      ,p_attribute17_name                => 'DIS_INFORMATION17'
      ,p_attribute17_value               => p_rec.dis_information17
      ,p_attribute18_name                => 'DIS_INFORMATION18'
      ,p_attribute18_value               => p_rec.dis_information18
      ,p_attribute19_name                => 'DIS_INFORMATION19'
      ,p_attribute19_value               => p_rec.dis_information19
      ,p_attribute20_name                => 'DIS_INFORMATION20'
      ,p_attribute20_value               => p_rec.dis_information20
      ,p_attribute21_name                => 'DIS_INFORMATION21'
      ,p_attribute21_value               => p_rec.dis_information21
      ,p_attribute22_name                => 'DIS_INFORMATION22'
      ,p_attribute22_value               => p_rec.dis_information22
      ,p_attribute23_name                => 'DIS_INFORMATION23'
      ,p_attribute23_value               => p_rec.dis_information23
      ,p_attribute24_name                => 'DIS_INFORMATION24'
      ,p_attribute24_value               => p_rec.dis_information24
      ,p_attribute25_name                => 'DIS_INFORMATION25'
      ,p_attribute25_value               => p_rec.dis_information25
      ,p_attribute26_name                => 'DIS_INFORMATION26'
      ,p_attribute26_value               => p_rec.dis_information26
      ,p_attribute27_name                => 'DIS_INFORMATION27'
      ,p_attribute27_value               => p_rec.dis_information27
      ,p_attribute28_name                => 'DIS_INFORMATION28'
      ,p_attribute28_value               => p_rec.dis_information28
      ,p_attribute29_name                => 'DIS_INFORMATION29'
      ,p_attribute29_value               => p_rec.dis_information29
      ,p_attribute30_name                => 'DIS_INFORMATION30'
      ,p_attribute30_value               => p_rec.dis_information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
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
  (p_rec in per_dis_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.disability_id is not null)  and (
    nvl(per_dis_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_dis_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.disability_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_DISABILITIES'
      ,p_attribute_category              => p_rec.ATTRIBUTE_CATEGORY
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
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
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
  (p_effective_date  in date
  ,p_rec             in per_dis_shd.g_rec_type
  ) is
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
  if NOT per_dis_shd.api_updating
      (p_disability_id                    => p_rec.disability_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  end if;
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     nvl(per_dis_shd.g_old_rec.person_id
        ,hr_api.g_number) then
     l_argument := 'person_id';
     raise l_error;
  end if;
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
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_person_id                     in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  If ((nvl(p_person_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_people_f'
            ,p_base_key_column => 'PERSON_ID'
            ,p_base_key_value  => p_person_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'all people';
     raise l_integrity_error;
  End If;
  --
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
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
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_disability_id                    in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'disability_id'
      ,p_argument_value => p_disability_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in per_dis_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  cursor csr_person is
    select business_group_id
    from per_all_people_f pap
    where pap.person_id = p_rec.person_id
    and p_validation_start_date between pap.effective_start_date and pap.effective_end_date;
--
  l_proc	        varchar2(72) := g_package||'insert_validate';
  l_business_group_id	per_all_people_f.business_group_id%TYPE;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_per_bus.set_security_group_id(p_person_id => p_rec.person_id);
  --
  -- Validate PERSON_ID
  --
  per_dis_bus.chk_person_id
    (p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    );

  --
  -- Validate CATEGORY
  --
  per_dis_bus.chk_category
    (p_disability_id            =>  p_rec.disability_id
    ,p_category                 =>  p_rec.category
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    );

  --
  -- Validate STATUS
  --
  per_dis_bus.chk_status
    (p_disability_id          =>     p_rec.disability_id
    ,p_status                 =>     p_rec.status
    ,p_effective_date         =>     p_effective_date
    ,p_validation_start_date  =>     p_validation_start_date
    ,p_validation_end_date    =>     p_validation_end_date
    );
  --
  -- Validate QUOTA_FTE
  --
  per_dis_bus.chk_quota_fte
    (p_quota_fte            =>  p_rec.quota_fte);
  --
  -- Validate REASON
  --
  per_dis_bus.chk_reason
    (p_disability_id            =>  p_rec.disability_id
    ,p_reason                   =>  p_rec.reason
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    );
  --
  -- Validate DEGREE
  --
  per_dis_bus.chk_degree
    (p_degree            =>  p_rec.degree);
  --
  --
  -- Validate INCIDENT_ID
  --
  per_dis_bus.chk_incident_id
    (p_disability_id         => p_rec.disability_id
    ,p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date
    ,p_incident_id           => p_rec.incident_id
    );
  --
  -- Validate ORGANIZATION_ID
  --
  open csr_person;
  fetch csr_person into l_business_group_id;
  close csr_person;
  per_dis_bus.chk_organization_id
    (p_disability_id               =>  p_rec.disability_id
    ,p_organization_id             =>  p_rec.organization_id
    ,p_business_group_id           =>  l_business_group_id
    ,p_validation_start_date       =>  p_validation_start_date
    );
  --
  -- Validate REGISTRATION details
  --
  per_dis_bus.chk_registration_details
    (p_organization_id             =>  p_rec.organization_id
    ,p_registration_id             =>  p_rec.registration_id
    ,p_registration_date           =>  p_rec.registration_date
    ,p_registration_exp_date       =>  p_rec.registration_exp_date
    );
  --
  per_dis_bus.chk_ddf(p_rec);
  --
  per_dis_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in per_dis_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  cursor csr_person is
    select business_group_id
    from per_all_people_f pap
    where pap.person_id = p_rec.person_id
    and p_validation_start_date between pap.effective_start_date and pap.effective_end_date;
--
  l_business_group_id	per_all_people_f.business_group_id%TYPE;
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_per_bus.set_security_group_id(p_person_id => p_rec.person_id);
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  -- Validate PERSON ID
  --
per_dis_bus.chk_person_id
    (p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    );
  --
  -- Validate CATEGORY
  --
  per_dis_bus.chk_category
    (p_disability_id            =>  p_rec.disability_id
    ,p_category                 =>  p_rec.category
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    );
  --
  -- Validate STATUS
  --
  per_dis_bus.chk_status
    (p_disability_id          =>     p_rec.disability_id
    ,p_status                 =>     p_rec.status
    ,p_effective_date         =>     p_effective_date
    ,p_validation_start_date  =>     p_validation_start_date
    ,p_validation_end_date    =>     p_validation_end_date
    );
  --
  -- Validate QUOTA_FTE
  --
  per_dis_bus.chk_quota_fte
    (p_quota_fte            =>  p_rec.quota_fte);
  --
  -- Validate REASON
  --
  per_dis_bus.chk_reason
    (p_disability_id            =>  p_rec.disability_id
    ,p_reason                   =>  p_rec.reason
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    );
  --
  -- Validate DEGREE
  --
  per_dis_bus.chk_degree
    (p_degree            =>  p_rec.degree);
  --
  -- Validate INCIDENT_ID
  --
  per_dis_bus.chk_incident_id
    (p_disability_id         => p_rec.disability_id
    ,p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date
    ,p_incident_id           => p_rec.incident_id
    );
  --
  -- Validate ORGANIZATION_ID
  --
  open csr_person;
  fetch csr_person into l_business_group_id;
  close csr_person;
  per_dis_bus.chk_organization_id
    (p_disability_id               =>  p_rec.disability_id
    ,p_organization_id             =>  p_rec.organization_id
    ,p_business_group_id           =>  l_business_group_id
    ,p_validation_start_date       =>  p_validation_start_date
    );
  --
  -- Validate REGISTRATION details
  --
  per_dis_bus.chk_registration_details
    (p_organization_id             =>  p_rec.organization_id
    ,p_registration_id             =>  p_rec.registration_id
    ,p_registration_date           =>  p_rec.registration_date
    ,p_registration_exp_date       =>  p_rec.registration_exp_date
    );
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_person_id                      => p_rec.person_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  per_dis_bus.chk_ddf(p_rec);
  --
  per_dis_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in per_dis_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_disability_id                    => p_rec.disability_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_dis_bus;

/
