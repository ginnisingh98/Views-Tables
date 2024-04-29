--------------------------------------------------------
--  DDL for Package Body PER_ORS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORS_BUS" as
/* $Header: peorsrhi.pkb 115.8 2003/06/30 09:58:15 kjagadee noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ors_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_organization_structure_id   number         default null;

--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_org_name >-----------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_org_name
  (p_organization_structure_id            in number,
   p_business_group_id                    in number,
   p_name                                 in varchar2
  ) is
  l_proc           VARCHAR2(72)  :=  g_package||'chk_org_name';
  --
  -- Declare cursor
  --
  cursor csr_org_name is
   select organization_structure_id, business_group_id
     from per_organization_structures
     where name = p_name;
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'p_name'
    ,p_argument_value     => p_name
    );

--
--
hr_utility.set_location(l_proc, 20);
--
--

for Crec in csr_org_name loop
if Crec.organization_structure_id <> nvl(p_organization_structure_id,-1)
   and Crec.business_group_id = nvl(p_business_group_id,crec.business_group_id) then
      hr_utility.set_message('801','PER_7901_SYS_DUPLICATE_RECORDS');
      hr_utility.raise_error;
   end if;
end loop;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_org_name;


--  ---------------------------------------------------------------------------
--  |---------------------------< get_hr_status >-----------------------------|
--  ---------------------------------------------------------------------------
--

function get_hr_status return VARCHAR2 is
--
l_hr_installed varchar2(1);
begin
   --
   -- Get status of Any of HR's Product set.
   --
   select 'I'
   into   l_hr_installed
   from sys.dual
   where  exists (select 'I'
                  from fnd_product_installations
                  where application_id between 800 and 899
                  and status = 'I');
   return l_hr_installed;
   exception
      when no_data_found then
        return 'S';
end;

--  ---------------------------------------------------------------------------
--  |---------------------------< get_pa_status >-----------------------------|
--  ---------------------------------------------------------------------------
--

function get_pa_status return VARCHAR2 is
--
l_pa_installed boolean;
p_pa_installed varchar2(1);
l_industry     varchar2(1);
begin
   --
   -- Get status of the Oracle Projects application
   --
   l_pa_installed := fnd_installation.get(appl_id => 275
                    ,dep_appl_id => 275
                    ,status => p_pa_installed
                    ,industry => l_industry);
return(p_pa_installed);
end;



--  ---------------------------------------------------------------------------
--  |---------------------------< chk_no_children >---------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_no_children
   (p_organization_structure_id           in number) is

  l_proc           VARCHAR2(72)  :=  g_package||'chk_no_children';
  l_count          number(2);
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'p_organization_structure_id'
    ,p_argument_value     => p_organization_structure_id
    );

 select count(*)
     into l_count
     from PER_ORG_STRUCTURE_VERSIONS
     where ORGANIZATION_STRUCTURE_ID = p_organization_Structure_Id;

if l_count >0 then
 hr_utility.set_message('801','HR_6084_PO_POS_HAS_HIER_VER');
 hr_utility.raise_error;
 end if;

--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_no_children;

--  ---------------------------------------------------------------------------
--  |----------------------------< chk_y_or_n>--------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_y_or_n
   (p_effective_date     in date
   ,p_flag               in varchar2
   ,p_flag_name          in varchar2)
 IS
  l_proc           VARCHAR2(72)  :=  g_package||'chk_sec_profile';
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
 IF hr_api.not_exists_in_hrstanlookups
  (p_effective_date               => p_effective_date
  ,p_lookup_type                  => 'YES_NO'
  ,p_lookup_code                  => p_flag
  ) THEN
       fnd_message.set_name('801','HR_52970_COL_Y_OR_N');
       fnd_message.set_token('COLUMN',p_flag_name);
       fnd_message.raise_error;
end if;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_y_or_n;

--  ---------------------------------------------------------------------------
--  |--------------------------< chk_sec_profile >----------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_sec_profile
   (p_organization_structure_id           in number) is

  l_proc           VARCHAR2(72)  :=  g_package||'chk_sec_profile';
  l_count          number(2);
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'p_organization_structure_id'
    ,p_argument_value     => p_organization_structure_id
    );
 select count(*)
    into l_count
    from per_security_profiles
    where organization_structure_id = p_organization_structure_id;
 if l_count >0 then
 hr_utility.set_message('801','PAY_7694_PER_NO_DEL_STRUCTURE');
 hr_utility.raise_error;
 end if;

--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_sec_profile;


--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_position_control >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_position_control
  (p_organization_structure_id            in number,
   p_business_group_id                    in number,
   p_pos_control_structure_flag      in varchar2
  ) is
  l_proc           VARCHAR2(72)  :=  g_package||'chk_position_control';
  --
  -- Declare cursor
  --
  cursor csr_org_pos is
   select organization_structure_id,business_group_id
     from per_organization_structures
     where position_control_structure_flg = 'Y'
      and business_group_id = p_business_group_id;
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
--
--
hr_utility.set_location(l_proc, 20);
--
--
if p_pos_control_structure_flag = 'Y' then
  for Crec in csr_org_pos loop
    if Crec.organization_structure_id <> nvl(p_organization_structure_id,-1) then
          hr_utility.set_message(800, 'PER_50053_POS_CTRL_DUPLICATED');
          hr_utility.raise_error;
    end if;
  end loop;
end if;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_position_control;

--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_primary_flag >----------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_primary_flag
  (p_organization_structure_id            in number,
   p_business_group_id                    in number,
   p_primary_structure_flag      in varchar2
  ) is
  l_proc           VARCHAR2(72)  :=  g_package||'chk_primary_flag';
  --
  -- Declare cursor
  --
  cursor csr_org_primary is
   select organization_structure_id,business_group_id
     from per_organization_structures
     where primary_structure_flag = 'Y';
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
hr_utility.set_location(l_proc, 20);
--
--
if p_primary_structure_flag = 'Y' then
  for Crec in csr_org_primary loop
    if Crec.organization_structure_id <> nvl(p_organization_structure_id,-1)
       and Crec.business_group_id = p_business_group_id then
          hr_utility.set_message(800, 'HR_6085_PO_POS_ONE_PRIMARY');
          hr_utility.raise_error;
    end if;
  end loop;
end if;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_primary_flag;

--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_organization_structure_id            in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_organization_structures ors
     where ors.organization_structure_id = p_organization_structure_id
       and pbg.business_group_id = ors.business_group_id;
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
    ,p_argument           => 'organization_structure_id'
    ,p_argument_value     => p_organization_structure_id
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
  (p_organization_structure_id            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_organization_structures ors
     where ors.organization_structure_id = p_organization_structure_id
       and pbg.business_group_id (+) = ors.business_group_id;
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
    ,p_argument           => 'organization_structure_id'
    ,p_argument_value     => p_organization_structure_id
    );
  --
  if ( nvl(per_ors_bus.g_organization_structure_id, hr_api.g_number)
       = p_organization_structure_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ors_bus.g_legislation_code;
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
    per_ors_bus.g_organization_structure_id   := p_organization_structure_id;
    per_ors_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_ors_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.organization_structure_id is not null)  and (
    nvl(per_ors_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_ors_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.organization_structure_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ORGANIZATION_STRUCTURES'
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
  ,p_rec in per_ors_shd.g_rec_type
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
  IF NOT per_ors_shd.api_updating
      (p_organization_structure_id            => p_rec.organization_structure_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
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
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_ors_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
if p_rec.business_group_id IS NOT NULL then
   hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
end if;

  chk_org_name
  (p_organization_structure_id  =>      p_rec.organization_structure_id
   ,p_business_group_id         =>      p_rec.business_group_id
   ,p_name                      =>      p_rec.name);

chk_y_or_n
   (p_effective_date            =>      p_effective_date
   ,p_flag                      =>      p_rec.primary_structure_flag
   ,p_flag_name                 =>      'PRIMARY_STRUCTURE_FLAG');

chk_y_or_n
   (p_effective_date            =>      p_effective_date
   ,p_flag                      =>      p_rec.position_control_structure_flg
   ,p_flag_name                 =>      'POSITION_CONTROL_STRUCTURE_F');

chk_primary_flag
  (p_organization_structure_id  =>      p_rec.organization_structure_id
   ,p_business_group_id         =>      p_rec.business_group_id
   ,p_primary_structure_flag    =>      p_rec.primary_structure_flag);

  --
  --
  per_ors_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_ors_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
if p_rec.business_group_id IS NOT NULL then
hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
end if;

chk_y_or_n
   (p_effective_date            =>      p_effective_date
   ,p_flag                      =>      p_rec.primary_structure_flag
   ,p_flag_name                 =>      'PRIMARY_STRUCTURE_FLAG');

chk_y_or_n
   (p_effective_date            =>      p_effective_date
   ,p_flag                      =>      p_rec.position_control_structure_flg
   ,p_flag_name                 =>      'POSITION_CONTROL_STRUCTURE_F');

chk_org_name
  (p_organization_structure_id  =>      p_rec.organization_structure_id
   ,p_business_group_id         =>      p_rec.business_group_id
   ,p_name                      =>      p_rec.name);

chk_primary_flag
  (p_organization_structure_id  =>      p_rec.organization_structure_id
   ,p_business_group_id         =>      p_rec.business_group_id
   ,p_primary_structure_flag    =>      p_rec.primary_structure_flag);
 --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  per_ors_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ors_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
chk_no_children
      (p_organization_structure_id => p_rec.organization_structure_id);
chk_sec_profile
      (p_organization_structure_id => p_rec.organization_structure_id);
if get_hr_status = 'I' then
      pa_org.pa_os_predel_validation(p_rec.organization_structure_id);
 end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_ors_bus;

/
