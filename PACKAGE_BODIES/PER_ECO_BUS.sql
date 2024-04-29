--------------------------------------------------------
--  DDL for Package Body PER_ECO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ECO_BUS" as
/* $Header: peecorhi.pkb 115.7 2002/12/05 10:37:50 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_eco_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_election_constituency_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_election_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a election id exists in table per_elections.
--    - Checks that the election_id is not null
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_election_id
--
--
--  Post Success:
--    If a row does exist in per_elections for the given election id then
--     processing continues.
--
--  Post Failure:
--    If a row does not exist in per_elections for the given election id
--    then an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_election_id
  (p_election_id              in     per_election_constituencys.election_id%TYPE
  ,p_election_constituency_id in     per_election_constituencys.election_constituency_id%TYPE
  ,p_object_version_number    in     per_election_constituencys.object_version_number%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_election_id';
  --
  l_api_updating      boolean;
  l_election_id       number;
  --
  cursor csr_valid_election_id is
    select election_id
    from per_elections pe
    where pe.election_id = p_election_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'election_id'
    ,p_argument_value => p_election_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_eco_shd.api_updating
         (p_election_constituency_id     => p_election_constituency_id
         ,p_object_version_number        => p_object_version_number
         );
  --
  if ((l_api_updating and per_eco_shd.g_old_rec.election_id <> p_election_id)
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the Election ID is linked to a
    -- valid election_id on per_elections
    --
    open csr_valid_election_id;
    fetch csr_valid_election_id into l_election_id;
    if csr_valid_election_id%notfound then
      --
      close csr_valid_election_id;
	 fnd_message.set_name('PER', 'PER_289099_ECO_ELEC_ID_INVALID');
      hr_utility.raise_error;
      --
	 else
  close csr_valid_election_id;

    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_election_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_duplicate_constituency >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a constituency does not already exist for this election.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_election_id
--    p_constituency_id
--
--  Post Success:
--    If a constituency does not exist for this election then processing continues.
--
--  Post Failure:
--    If a constituency already exists for the election then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_duplicate_constituency
(p_election_id           in     per_election_constituencys.election_id%TYPE
,p_constituency_id       in     per_election_constituencys.constituency_id%TYPE
,p_election_constituency_id in  per_election_constituencys.election_constituency_id%TYPE
)
is
--
l_proc              varchar2(72)  :=  g_package||'chk_duplicate_constituency';
--
l_constituency_id number;
--
cursor csr_valid_constituency is
select election_constituency_id
from per_election_constituencys
where election_id    = p_election_id
and constituency_id  = p_constituency_id;
--
begin

hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'election_id'
,p_argument_value => p_election_id
);
--
hr_api.mandatory_arg_error
(p_api_name       => l_proc
,p_argument       => 'constituency_id'
,p_argument_value => p_constituency_id
);
--
hr_utility.set_location(l_proc, 20);
--
-- Check that the candidate has not been entered for this election before
--
open csr_valid_constituency;
fetch csr_valid_constituency into l_constituency_id;
if csr_valid_constituency%found then
--
if p_election_constituency_id is null or
   p_election_constituency_id <> l_constituency_id then
hr_utility.set_location(l_proc, 30);
fnd_message.set_name('PER', 'HR_289258_ECO_DUP_CONSTITUENCY');
hr_utility.raise_error;
--
end if;
end if;
--
close csr_valid_constituency;
--
hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_duplicate_constituency;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_can_delete >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_election_id
--
--
--  Post Success:
--
--  Post Failure:
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_can_delete
  (p_election_constituency_id   in      per_election_constituencys.election_constituency_id%TYPE
  ,p_election_id                        in   per_election_constituencys.election_id%TYPE
  ,p_object_version_number              in   per_election_constituencys.object_version_number%TYPE
  )
  is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_can_exists';
  --
l_api_updating      boolean;
l_election_id_a     number;
l_election_id_b     number;
  --
  --
cursor csr_valid_can_exists is
select pec.election_id
from per_election_candidates pec
where pec.election_id = p_election_id;
  --
  begin
  hr_utility.set_location(l_proc, 20);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Check that the Election ID is not linked to a
  -- valid candidate on per_election_candidates
  --
 open csr_valid_can_exists;
fetch csr_valid_can_exists into l_election_id_a;
if csr_valid_can_exists%found then
  --
 close csr_valid_can_exists;
 fnd_message.set_name('PER', 'PER_289109_ECO_ID_CAN_EXISTS');
hr_utility.raise_error;
  --
end if;
close csr_valid_can_exists;
  --
hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_can_delete;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_constituency_id >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a constituency id exists in table
--      HR_ALL_ORGANIZATION_UNITS.
--    - Validates that the constituency compares with that in
--      table HR_ORGANIZATION_INFORMATION
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_constituency_id
--
--
--  Post Success:
--    If a row does exist in HR_ALL_ORGANIZATION_UNITS for the given
--    constituency id then processing continues.
--
--  Post Failure:
--    If a row does not exist in HR_ALL_ORGANIZATION_UNITS for the given
--    constituency id then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_constituency_id
  (p_constituency_id          in     per_election_constituencys.election_id%TYPE
  ,p_election_constituency_id in     per_election_constituencys.election_constituency_id%TYPE
  ,p_object_version_number    in     per_election_constituencys.object_version_number%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_constituency_id';
  --
  l_api_updating      boolean;
  l_constituency_id   number;
  --
  cursor csr_valid_const_id is
    select haou.organization_id
    from hr_all_organization_units haou
    where haou.organization_id = p_constituency_id
    and exists(select 1
    from hr_organization_information hoi
    where hoi.org_information_context='CLASS'
    and hoi.org_information1='CONSTITUENCY'
    and hoi.org_information2='Y');
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'constituency_id'
    ,p_argument_value => p_constituency_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_eco_shd.api_updating
         (p_election_constituency_id      => p_election_constituency_id
         ,p_object_version_number         => p_object_version_number
         );
  --
  if ((l_api_updating and per_eco_shd.g_old_rec.constituency_id <> p_constituency_id)
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the Constituency ID is linked to a
    -- valid representative on hr_organiztion_information
    --
    open csr_valid_const_id;
    fetch csr_valid_const_id into l_constituency_id;
    if csr_valid_const_id%notfound then
      --
      close csr_valid_const_id;
	 fnd_message.set_name('PER', 'PER_289100_ECO_CONST_INVALID');
      hr_utility.raise_error;
      --
    end if;
    --
    close csr_valid_const_id;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_constituency_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_election_constituency_id             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_election_constituencys eco
     where eco.election_constituency_id = p_election_constituency_id
       and pbg.business_group_id = eco.business_group_id;
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
    ,p_argument           => 'election_constituency_id'
    ,p_argument_value     => p_election_constituency_id
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
  (p_election_constituency_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_election_constituencys eco
     where eco.election_constituency_id = p_election_constituency_id
       and pbg.business_group_id = eco.business_group_id;
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
    ,p_argument           => 'election_constituency_id'
    ,p_argument_value     => p_election_constituency_id
    );
  --
  if ( nvl(per_eco_bus.g_election_constituency_id, hr_api.g_number)
       = p_election_constituency_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_eco_bus.g_legislation_code;
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
    per_eco_bus.g_election_constituency_id:= p_election_constituency_id;
    per_eco_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in per_eco_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.election_constituency_id is not null)  and (
    nvl(per_eco_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_eco_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.election_constituency_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ELECTION_CONSTITUENCYS'
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
  (p_effective_date               in date
  ,p_rec in per_eco_shd.g_rec_type
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
  IF NOT per_eco_shd.api_updating
      (p_election_constituency_id             => p_rec.election_constituency_id
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
  (p_effective_date               in date
  ,p_rec                          in per_eco_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location('Entering: chk_election_id',10);

  chk_election_id
  (p_election_id		=>  p_rec.election_id
  ,p_election_constituency_id   =>  p_rec.election_constituency_id
  ,p_object_version_number	=>  p_rec.object_version_number
  );

  hr_utility.set_location('Entering: chk_constituency_id', 15);

  chk_constituency_id
  (p_constituency_id		=>  p_rec.constituency_id
  ,p_election_constituency_id   =>  p_rec.election_constituency_id
  ,p_object_version_number      =>  p_rec.object_version_number
  );

  hr_utility.set_location('Entering: chk_duplicate_constituency', 15);
  chk_duplicate_constituency
  (p_election_id                =>  p_rec.election_id
  ,p_constituency_id            =>  p_rec.constituency_id
  ,p_election_constituency_id   =>  p_rec.election_constituency_id
  );
  --
  --
  per_eco_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_eco_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  hr_utility.set_location('Entering: chk_election_id',10);

  chk_election_id
  (p_election_id                =>  p_rec.election_id
  ,p_election_constituency_id   =>  p_rec.election_constituency_id
  ,p_object_version_number      =>  p_rec.object_version_number
  );

  hr_utility.set_location('Entering: chk_constituency_id', 15);

  chk_constituency_id
  (p_constituency_id            =>  p_rec.constituency_id
  ,p_election_constituency_id   =>  p_rec.election_constituency_id
  ,p_object_version_number      =>  p_rec.object_version_number
  );

  hr_utility.set_location('Entering: chk_duplicate_constituency', 15);

  chk_duplicate_constituency
  (p_election_id                =>  p_rec.election_id
  ,p_constituency_id            =>  p_rec.constituency_id
  ,p_election_constituency_id   =>  p_rec.election_constituency_id
  );
  --
  per_eco_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_eco_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_eco_bus.chk_can_delete
  (p_election_constituency_id	=> p_rec.election_constituency_id
  ,p_election_id			=>  p_rec.election_id
  ,p_object_version_number	=>  p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end per_eco_bus;

/
