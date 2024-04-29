--------------------------------------------------------
--  DDL for Package Body HR_ORD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORD_BUS" as
/* $Header: hrordrhi.pkb 115.7 2002/12/04 06:20:03 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ord_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_organization_link_id        number         default null;
--
-- ----------------------------------------------------------------------------
-- |                     Private Cursor Definitions                           |
-- ----------------------------------------------------------------------------
--
cursor c_valid_org_for_bg_and_date
  (p_effective_date    in date
  ,p_business_group_id in number
  ,p_organization_id   in number) is
  select org.organization_id
  from   hr_organization_units org
  where  org.organization_id   = p_organization_id
    and  org.business_group_id = p_business_group_id
    and  p_effective_date between org.date_from and nvl(org.date_to, to_date('31/12/4712', 'DD/MM/YYYY'));
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_organization_link_id                 in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hr_de_organization_links ord
     where ord.organization_link_id = p_organization_link_id
       and pbg.business_group_id = ord.business_group_id;
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
    ,p_argument           => 'organization_link_id'
    ,p_argument_value     => p_organization_link_id
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
  (p_organization_link_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , hr_de_organization_links ord
     where ord.organization_link_id = p_organization_link_id
       and pbg.business_group_id = ord.business_group_id;
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
    ,p_argument           => 'organization_link_id'
    ,p_argument_value     => p_organization_link_id
    );
  --
  if ( nvl(hr_ord_bus.g_organization_link_id, hr_api.g_number)
       = p_organization_link_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_ord_bus.g_legislation_code;
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
    hr_ord_bus.g_organization_link_id := p_organization_link_id;
    hr_ord_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_parent_organization_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following parent organization rules...
--
--    1. It is mandatory.
--    2. It belongs to the business group.
--    3. It exists at the effective date.
--    4. It is classified as a HR Organization and it is currently enabled.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_business_group_id
--    p_parent_organization_id
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_parent_organization_id
(p_effective_date         in date
,p_business_group_id      in number
,p_parent_organization_id in number) is
  --
  --
  -- Local Cursors.
  --
  cursor c_valid_hr_org
    (p_organization_id in number) is
    select organization_id
    from   hr_organization_information
    where  organization_id         = p_organization_id
      and  org_information_context = 'CLASS'
      and  org_information1        = 'HR_ORG'
      and  org_information2        = 'Y';
  --
  --
  -- Local Variables.
  --
  l_proc   varchar2(72) :=  g_package || 'chk_parent_organization_id';
  l_org_id number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'parent_organization_id'
    ,p_argument_value => p_parent_organization_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Check that the organization is valid on the effective date and it is valid
  -- for the business group.
  --
  open c_valid_org_for_bg_and_date
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_organization_id   => p_parent_organization_id);
  fetch c_valid_org_for_bg_and_date into l_org_id;
  if c_valid_org_for_bg_and_date%notfound then
    close c_valid_org_for_bg_and_date;
    fnd_message.set_name('PER', 'HR_DE_ORG_BUS_GRP_CHK');
    fnd_message.raise_error;
  else
    close c_valid_org_for_bg_and_date;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Check that the organization is classified as a HR Organization and it is
  -- currently enabled.
  --
  open c_valid_hr_org
    (p_organization_id => p_parent_organization_id);
  fetch c_valid_hr_org into l_org_id;
  if c_valid_hr_org%notfound then
    close c_valid_hr_org;
    fnd_message.set_name('PER', 'HR_DE_ORG_HR_CHK');
    fnd_message.raise_error;
  else
    close c_valid_hr_org;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_parent_organization_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_child_organization_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following child organization rules...
--
--    1. It is mandatory.
--    2. It belongs to the business group.
--    3. It exists at the effective date.
--    4. It is classified correctly according to the rules held in the
--       HR_DE_ORG_LINK_TYPES_MAPPING table.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_business_group_id
--    p_org_link_type
--    p_child_organization_id
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_child_organization_id
(p_effective_date        in date
,p_business_group_id     in number
,p_org_link_type         in varchar2
,p_child_organization_id in number) is
  --
  --
  -- Local Cursors.
  --
  cursor c_valid_org_class
    (p_organization_id in number
    ,p_org_link_type   in varchar2) is
    select organization_id
    from   hr_organization_information  inf
          ,hr_de_org_link_types_mapping map
    where  inf.organization_id         = p_organization_id
      and  inf.org_information_context = 'CLASS'
      and  inf.org_information2        = 'Y'
      and  inf.org_information1        = map.org_class
      and  map.org_link_type           = p_org_link_type;
  --
  --
  -- Local Variables.
  --
  l_proc   varchar2(72) :=  g_package || 'chk_child_organization_id';
  l_org_id number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'child_organization_id'
    ,p_argument_value => p_child_organization_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Check that the organization is valid on the effective date and it is valid
  -- for the business group.
  --
  open c_valid_org_for_bg_and_date
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_organization_id   => p_child_organization_id);
  fetch c_valid_org_for_bg_and_date into l_org_id;
  if c_valid_org_for_bg_and_date%notfound then
    close c_valid_org_for_bg_and_date;
    fnd_message.set_name('PER', 'HR_DE_ORG_CHILD_BUS_GRP_CHK');
    fnd_message.raise_error;
  else
    close c_valid_org_for_bg_and_date;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Check that the organization is classified correctly as per the rules held in the
  -- table HR_DE_ORG_LINK_TYPES_MAPPING and it is currently enabled.
  --
  open c_valid_org_class
    (p_organization_id => p_child_organization_id
    ,p_org_link_type   => p_org_link_type);
  fetch c_valid_org_class into l_org_id;
  if c_valid_org_class%notfound then
    close c_valid_org_class;
    fnd_message.set_name('PER', 'HR_DE_ORG_CHILD_CLASS_CHK');
    fnd_message.raise_error;
  else
    close c_valid_org_class;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_child_organization_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_org_link_type >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following org link type rules...
--
--    1. It is mandatory.
--    2. It is valid value from the lookup type 'DE_LINK_TYPE'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_effective_date
--    p_org_link_type
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_org_link_type
(p_effective_date in     date
,p_org_link_type  in varchar2) is
  --
  --
  -- Local variables.
  --
  l_proc varchar2(72) := g_package || 'chk_org_link_type';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org_link_type'
    ,p_argument_value => p_org_link_type);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Check that the org link type exists in hr_lookups for the
  -- lookup type 'DE_LINK_TYPE'.
  --
  if hr_api.not_exists_in_hr_lookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'DE_LINK_TYPE'
       ,p_lookup_code    => p_org_link_type) then
    hr_utility.set_message(800, 'HR_DE_LINK_TYPE_CHK');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_org_link_type;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_parent_child_org_ids >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following parent / child organization rules...
--
--    1. The parent and child organization cannot be the same organization.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_parent_organization_id
--    p_child_organization_id
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_parent_child_org_ids
(p_parent_organization_id in number
,p_child_organization_id  in number) is
  --
  --
  -- Local variables.
  --
  l_proc varchar2(72) := g_package || 'chk_parent_child_org_ids';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check that the organizations are not the same.
  --
  if p_parent_organization_id = p_child_organization_id THEN
    hr_utility.set_message(800, 'HR_DE_ORG_SAME_CHK');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_parent_child_org_ids;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_localisation_installed >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following installation rules...
--
--    1. The German HR localisation must have been installed.
--    2. The business group must have a legislation code of 'DE'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_business_group_id
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_localisation_installed
(p_business_group_id in number) is
  --
  --
  -- Local Cursors.
  --
  cursor c_valid_legislation
    (p_business_group_id in number) is
    select null
    from   per_business_groups
    where  business_group_id = p_business_group_id
      and  legislation_code  = 'DE';
  --
  --
  -- Local variables.
  --
  l_proc  varchar2(72) := g_package || 'chk_localisation_installed';
  l_dummy varchar2(2000);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check that the German HR localisation has been installed.
  --
  if not hr_utility.chk_product_install('Oracle Human Resources', 'DE') then
    hr_utility.set_message(800, 'HR_DE_LOC_INSTALL_CHK');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Check that the business group has a legislation code of 'DE' ie. Germany.
  --
  open c_valid_legislation
    (p_business_group_id => p_business_group_id);
  fetch c_valid_legislation into l_dummy;
  if c_valid_legislation%notfound then
    close c_valid_legislation;
    fnd_message.set_name('PER', 'HR_DE_BUS_GRP_LEG_CHK');
    fnd_message.raise_error;
  else
    close c_valid_legislation;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
end chk_localisation_installed;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_org_link_info_category >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following org link info category rules...
--
--    1. If the information category is not null then it must match the link type.
--    2. If the link type is either 'DE_SOCIAL_INSURANCE' or 'DE_LIABILITY_INSURANCE'
--       then the information category must match it.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_org_link_type
--    p_org_link_info_category
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_org_link_info_category
(p_org_link_type          in varchar2
,p_org_link_info_category in varchar2) is
  --
  --
  -- Local variables.
  --
  l_proc varchar2(72) := g_package || 'chk_org_link_info_category';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- If the information category is not null then check that the information category
  -- matches the link type.
  --
  if p_org_link_info_category is not null then
    if not (p_org_link_info_category = p_org_link_type) then
      fnd_message.set_name('PER', 'HR_DE_LINK_TYPE_ORG_INFO_CHK');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Check that the information category matches the link type if the link type is either
  -- 'DE_SOCIAL_INSURANCE' or 'DE_LIABILITY_INSURANCE'.
  --
  if p_org_link_type in ('DE_SOCIAL_INSURANCE', 'DE_LIABILITY_INSURANCE') then
    if not (nvl(p_org_link_info_category, hr_api.g_varchar2) = p_org_link_type) then
      fnd_message.set_name('PER', 'HR_DE_LINK_TYPE_MAN_CHK');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_org_link_info_category;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_organization_link_delete >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check the following delete rules...
--
--    1. Cannot delete the record if the link type is 'DE_LIABILITY_INSURANCE'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_org_link_type
--
--  Post Success:
--    Continue processing.
--
--  Post Failure:
--    Application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_organization_link_delete
(p_org_link_type in varchar2) is
  --
  --
  -- Local variables.
  --
  l_proc varchar2(72) := g_package || 'chk_organization_link_delete';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Cannot delete the record when it is for a liability insurance provider.
  --
  if p_org_link_type = 'DE_LIABILITY_INSURANCE' then
    fnd_message.set_name('PER', 'HR_DE_CANT_DEL_LIABILITY_INS');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end chk_organization_link_delete;
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
  (p_rec in hr_ord_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.organization_link_id is not null)  and (
    nvl(hr_ord_shd.g_old_rec.org_link_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information_category, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information1, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information1, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information2, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information2, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information3, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information3, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information4, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information4, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information5, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information5, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information6, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information6, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information7, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information7, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information8, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information8, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information9, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information9, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information10, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information10, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information11, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information11, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information12, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information12, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information13, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information13, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information14, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information14, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information15, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information15, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information16, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information16, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information17, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information17, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information18, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information18, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information19, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information19, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information20, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information20, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information21, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information21, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information22, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information22, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information23, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information23, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information24, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information24, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information25, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information25, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information26, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information26, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information27, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information27, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information28, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information28, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information29, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information29, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.org_link_information30, hr_api.g_varchar2) <>
    nvl(p_rec.org_link_information30, hr_api.g_varchar2) ))
    or (p_rec.organization_link_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Organization Links DF'
      ,p_attribute_category              => p_rec.org_link_information_category
      ,p_attribute1_name                 => 'ORG_LINK_INFORMATION1'
      ,p_attribute1_value                => p_rec.org_link_information1
      ,p_attribute2_name                 => 'ORG_LINK_INFORMATION2'
      ,p_attribute2_value                => p_rec.org_link_information2
      ,p_attribute3_name                 => 'ORG_LINK_INFORMATION3'
      ,p_attribute3_value                => p_rec.org_link_information3
      ,p_attribute4_name                 => 'ORG_LINK_INFORMATION4'
      ,p_attribute4_value                => p_rec.org_link_information4
      ,p_attribute5_name                 => 'ORG_LINK_INFORMATION5'
      ,p_attribute5_value                => p_rec.org_link_information5
      ,p_attribute6_name                 => 'ORG_LINK_INFORMATION6'
      ,p_attribute6_value                => p_rec.org_link_information6
      ,p_attribute7_name                 => 'ORG_LINK_INFORMATION7'
      ,p_attribute7_value                => p_rec.org_link_information7
      ,p_attribute8_name                 => 'ORG_LINK_INFORMATION8'
      ,p_attribute8_value                => p_rec.org_link_information8
      ,p_attribute9_name                 => 'ORG_LINK_INFORMATION9'
      ,p_attribute9_value                => p_rec.org_link_information9
      ,p_attribute10_name                => 'ORG_LINK_INFORMATION10'
      ,p_attribute10_value               => p_rec.org_link_information10
      ,p_attribute11_name                => 'ORG_LINK_INFORMATION11'
      ,p_attribute11_value               => p_rec.org_link_information11
      ,p_attribute12_name                => 'ORG_LINK_INFORMATION12'
      ,p_attribute12_value               => p_rec.org_link_information12
      ,p_attribute13_name                => 'ORG_LINK_INFORMATION13'
      ,p_attribute13_value               => p_rec.org_link_information13
      ,p_attribute14_name                => 'ORG_LINK_INFORMATION14'
      ,p_attribute14_value               => p_rec.org_link_information14
      ,p_attribute15_name                => 'ORG_LINK_INFORMATION15'
      ,p_attribute15_value               => p_rec.org_link_information15
      ,p_attribute16_name                => 'ORG_LINK_INFORMATION16'
      ,p_attribute16_value               => p_rec.org_link_information16
      ,p_attribute17_name                => 'ORG_LINK_INFORMATION17'
      ,p_attribute17_value               => p_rec.org_link_information17
      ,p_attribute18_name                => 'ORG_LINK_INFORMATION18'
      ,p_attribute18_value               => p_rec.org_link_information18
      ,p_attribute19_name                => 'ORG_LINK_INFORMATION19'
      ,p_attribute19_value               => p_rec.org_link_information19
      ,p_attribute20_name                => 'ORG_LINK_INFORMATION20'
      ,p_attribute20_value               => p_rec.org_link_information20
      ,p_attribute21_name                => 'ORG_LINK_INFORMATION21'
      ,p_attribute21_value               => p_rec.org_link_information21
      ,p_attribute22_name                => 'ORG_LINK_INFORMATION22'
      ,p_attribute22_value               => p_rec.org_link_information22
      ,p_attribute23_name                => 'ORG_LINK_INFORMATION23'
      ,p_attribute23_value               => p_rec.org_link_information23
      ,p_attribute24_name                => 'ORG_LINK_INFORMATION24'
      ,p_attribute24_value               => p_rec.org_link_information24
      ,p_attribute25_name                => 'ORG_LINK_INFORMATION25'
      ,p_attribute25_value               => p_rec.org_link_information25
      ,p_attribute26_name                => 'ORG_LINK_INFORMATION26'
      ,p_attribute26_value               => p_rec.org_link_information26
      ,p_attribute27_name                => 'ORG_LINK_INFORMATION27'
      ,p_attribute27_value               => p_rec.org_link_information27
      ,p_attribute28_name                => 'ORG_LINK_INFORMATION28'
      ,p_attribute28_value               => p_rec.org_link_information28
      ,p_attribute29_name                => 'ORG_LINK_INFORMATION29'
      ,p_attribute29_value               => p_rec.org_link_information29
      ,p_attribute30_name                => 'ORG_LINK_INFORMATION30'
      ,p_attribute30_value               => p_rec.org_link_information30
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
  (p_rec in hr_ord_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.organization_link_id is not null)  and (
    nvl(hr_ord_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hr_ord_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.organization_link_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'HR_DE_ORGANIZATION_LINKS'
      ,p_attribute_category              => p_rec.attribute_category
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
  (p_effective_date               in date
  ,p_rec in hr_ord_shd.g_rec_type
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
  IF NOT hr_ord_shd.api_updating
      (p_organization_link_id                 => p_rec.organization_link_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(hr_ord_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.parent_organization_id, hr_api.g_number) <>
     nvl(hr_ord_shd.g_old_rec.parent_organization_id, hr_api.g_number) then
     l_argument := 'parent_organization_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.child_organization_id, hr_api.g_number) <>
     nvl(hr_ord_shd.g_old_rec.child_organization_id, hr_api.g_number) then
     l_argument := 'child_organization_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.org_link_type, hr_api.g_varchar2) <>
     nvl(hr_ord_shd.g_old_rec.org_link_type, hr_api.g_varchar2) then
     l_argument := 'org_link_type';
     raise l_error;
  end if;
  --
  if nvl(p_rec.org_link_information_category, hr_api.g_varchar2) <>
     nvl(hr_ord_shd.g_old_rec.org_link_information_category, hr_api.g_varchar2) then
     l_argument := 'org_link_information_category';
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date in date
,p_rec            in hr_ord_shd.g_rec_type) is
  --
  --
  -- Local Variables.
  --
  l_proc varchar2(72) := g_package || 'insert_validate';
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.validate_bus_grp_id
    (p_rec.business_group_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date);
  --
  chk_localisation_installed
    (p_business_group_id => p_rec.business_group_id);
  --
  chk_org_link_type
    (p_effective_date => p_effective_date
    ,p_org_link_type  => p_rec.org_link_type);
  --
  chk_parent_organization_id
    (p_effective_date         => p_effective_date
    ,p_business_group_id      => p_rec.business_group_id
    ,p_parent_organization_id => p_rec.parent_organization_id);
  --
  chk_child_organization_id
    (p_effective_date        => p_effective_date
    ,p_business_group_id     => p_rec.business_group_id
    ,p_org_link_type         => p_rec.org_link_type
    ,p_child_organization_id => p_rec.child_organization_id);
  --
  chk_parent_child_org_ids
    (p_parent_organization_id => p_rec.parent_organization_id
    ,p_child_organization_id  => p_rec.child_organization_id);
  --
  chk_org_link_info_category
  (p_org_link_type          => p_rec.org_link_type
  ,p_org_link_info_category => p_rec.org_link_information_category);
  --
  hr_ord_bus.chk_ddf
    (p_rec);
  --
  hr_ord_bus.chk_df
    (p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
(p_effective_date in date
,p_rec            in hr_ord_shd.g_rec_type) is
  --
  --
  -- Local Variables.
  --
  l_proc varchar2(72) := g_package || 'update_validate';
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date);
  --
  hr_api.validate_bus_grp_id
    (p_rec.business_group_id);
  --
  chk_non_updateable_args
    (p_effective_date => p_effective_date
    ,p_rec            => p_rec);
  --
  hr_ord_bus.chk_ddf
    (p_rec);
  --
  hr_ord_bus.chk_df
    (p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_ord_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_organization_link_delete
    (p_org_link_type => p_rec.org_link_type);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_ord_bus;

/
