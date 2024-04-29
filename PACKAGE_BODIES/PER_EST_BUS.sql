--------------------------------------------------------
--  DDL for Package Body PER_EST_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EST_BUS" as
/* $Header: peestrhi.pkb 120.0.12010000.2 2008/11/28 11:06:53 ppentapa ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_est_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_location_unique >----------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that an establishment name and an establishment
--   location are unique.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_establishment_id		PK
--   p_name			name of establishment
--   p_location			location of establishment
--   p_object_version_number	object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
procedure chk_name_location_unique (p_establishment_id      in number,
				    p_name                  in varchar2,
				    p_location              in varchar2,
				    p_object_version_number in number) is
  --
  l_proc varchar2(72) := g_package||'chk_name_location_unique';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  -- cursor to see if an establishment name already exists at a certain
  -- location.
  --
  cursor c1 is
    select null
    from   per_establishments a
    where  a.name = p_name
    and    a.location = p_location;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_est_shd.api_updating
    (p_establishment_id      => p_establishment_id,
     p_object_version_number => p_object_version_number);
  --
  if not l_api_updating
     or (l_api_updating
         and (per_est_shd.g_old_rec.name
	      <> nvl(p_name,hr_api.g_varchar2)
              or per_est_shd.g_old_rec.location
	      <> nvl(p_location,hr_api.g_varchar2))) then
    --
    -- check if name is not null
    --
    if p_name is null then
      --
      -- raise error as name must be not null
      --
      hr_utility.set_message(801,'HR_51487_EST_CHK_NAME_NOT_NULL');
      hr_utility.raise_error;
      --
    end if;
    --
    if p_location is null then
      --
      -- raise error as location must be not null
      --
      hr_utility.set_message(801,'HR_51488_EST_CHK_LOC_NOT_NULL');
      hr_utility.raise_error;
      --
    end if;
    --
    -- check if establishment and location are unique.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      --
      if c1%found then
	--
	-- raise error as name and location exists
	--
	close c1;
	per_est_shd.constraint_error('PER_ESTABLISHMENTS_UK');
	--
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
end chk_name_location_unique;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_establishment_id >-------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that the establishment id is unique and has been
--   entered and is not updated.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_establishment_id		PK
--   p_object_version_number	object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only
--
Procedure chk_establishment_id(p_establishment_id      in number,
			       p_object_version_number in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_establishment_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_est_shd.api_updating
    (p_establishment_id      => p_establishment_id,
     p_object_version_number => p_object_version_number);
  --
  if (not l_api_updating) then
    --
    if p_establishment_id is not null then
      --
      -- raise error as establishment id is a not null value
      --
      per_est_shd.constraint_error('PER_ESTABLISHMENTS_PK');
      --
    end if;
    --
  elsif (l_api_updating
	 and nvl(p_establishment_id,hr_api.g_number)
	 <> per_est_shd.g_old_rec.establishment_id) then
    --
    -- raise error as PK has been updated
    --
    per_est_shd.constraint_error('PER_ESTABLISHMENTS_PK');
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_establishment_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_estab_delete >---------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks whether an establishment can be deleted which
--   depends on whether it is referenced anywhere.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_establishment_id		PK
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only
--
Procedure chk_estab_delete(p_establishment_id      in number) is
  --
  l_proc  varchar2(72) := g_package||'chk_estab_delete';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   per_establishment_attendances per
    where  per.establishment_id = p_establishment_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if the establishment_id is referenced in the per_estab_attendances
  -- table
  --
  open c1;
    --
    fetch c1 into l_dummy;
    --
    if c1%found then
      --
      -- raise error as records exist that reference this primary key
      --
      hr_utility.set_message(801,'HR_51486_EST_CHK_DELETE_EST');
      hr_utility.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_estab_delete;
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
  (p_rec in per_est_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.establishment_id is not null) and (
    nvl(per_est_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_est_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.establishment_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_ESTABLISHMENTS'
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
  (p_rec in per_est_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.establishment_id is not null)  and (
    nvl(per_est_shd.g_old_rec.est_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.est_information_category, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information1, hr_api.g_varchar2) <>
    nvl(p_rec.est_information1, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information2, hr_api.g_varchar2) <>
    nvl(p_rec.est_information2, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information3, hr_api.g_varchar2) <>
    nvl(p_rec.est_information3, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information4, hr_api.g_varchar2) <>
    nvl(p_rec.est_information4, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information5, hr_api.g_varchar2) <>
    nvl(p_rec.est_information5, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information6, hr_api.g_varchar2) <>
    nvl(p_rec.est_information6, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information7, hr_api.g_varchar2) <>
    nvl(p_rec.est_information7, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information8, hr_api.g_varchar2) <>
    nvl(p_rec.est_information8, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information9, hr_api.g_varchar2) <>
    nvl(p_rec.est_information9, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information10, hr_api.g_varchar2) <>
    nvl(p_rec.est_information10, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information11, hr_api.g_varchar2) <>
    nvl(p_rec.est_information11, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information12, hr_api.g_varchar2) <>
    nvl(p_rec.est_information12, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information13, hr_api.g_varchar2) <>
    nvl(p_rec.est_information13, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information14, hr_api.g_varchar2) <>
    nvl(p_rec.est_information14, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information15, hr_api.g_varchar2) <>
    nvl(p_rec.est_information15, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information16, hr_api.g_varchar2) <>
    nvl(p_rec.est_information16, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information17, hr_api.g_varchar2) <>
    nvl(p_rec.est_information17, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information18, hr_api.g_varchar2) <>
    nvl(p_rec.est_information18, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information19, hr_api.g_varchar2) <>
    nvl(p_rec.est_information19, hr_api.g_varchar2)  or
    nvl(per_est_shd.g_old_rec.est_information20, hr_api.g_varchar2) <>
    nvl(p_rec.est_information20, hr_api.g_varchar2) ))
    or (p_rec.establishment_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Establishment Developer DF'
      ,p_attribute_category              => p_rec.EST_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'EST_INFORMATION1'
      ,p_attribute1_value                => p_rec.est_information1
      ,p_attribute2_name                 => 'EST_INFORMATION2'
      ,p_attribute2_value                => p_rec.est_information2
      ,p_attribute3_name                 => 'EST_INFORMATION3'
      ,p_attribute3_value                => p_rec.est_information3
      ,p_attribute4_name                 => 'EST_INFORMATION4'
      ,p_attribute4_value                => p_rec.est_information4
      ,p_attribute5_name                 => 'EST_INFORMATION5'
      ,p_attribute5_value                => p_rec.est_information5
      ,p_attribute6_name                 => 'EST_INFORMATION6'
      ,p_attribute6_value                => p_rec.est_information6
      ,p_attribute7_name                 => 'EST_INFORMATION7'
      ,p_attribute7_value                => p_rec.est_information7
      ,p_attribute8_name                 => 'EST_INFORMATION8'
      ,p_attribute8_value                => p_rec.est_information8
      ,p_attribute9_name                 => 'EST_INFORMATION9'
      ,p_attribute9_value                => p_rec.est_information9
      ,p_attribute10_name                => 'EST_INFORMATION10'
      ,p_attribute10_value               => p_rec.est_information10
      ,p_attribute11_name                => 'EST_INFORMATION11'
      ,p_attribute11_value               => p_rec.est_information11
      ,p_attribute12_name                => 'EST_INFORMATION12'
      ,p_attribute12_value               => p_rec.est_information12
      ,p_attribute13_name                => 'EST_INFORMATION13'
      ,p_attribute13_value               => p_rec.est_information13
      ,p_attribute14_name                => 'EST_INFORMATION14'
      ,p_attribute14_value               => p_rec.est_information14
      ,p_attribute15_name                => 'EST_INFORMATION15'
      ,p_attribute15_value               => p_rec.est_information15
      ,p_attribute16_name                => 'EST_INFORMATION16'
      ,p_attribute16_value               => p_rec.est_information16
      ,p_attribute17_name                => 'EST_INFORMATION17'
      ,p_attribute17_value               => p_rec.est_information17
      ,p_attribute18_name                => 'EST_INFORMATION18'
      ,p_attribute18_value               => p_rec.est_information18
      ,p_attribute19_name                => 'EST_INFORMATION19'
      ,p_attribute19_value               => p_rec.est_information19
      ,p_attribute20_name                => 'EST_INFORMATION20'
      ,p_attribute20_value               => p_rec.est_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_est_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  If hr_multi_tenancy_pkg.is_multi_tenant_system Then
    hr_api.set_security_group_id(p_security_group_id => fnd_global.security_group_id);
  Else
    hr_api.set_security_group_id(p_security_group_id => 0);
  End If;
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTABLISHMENT_ID
  --
  chk_establishment_id(p_rec.establishment_id,
		       p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NAME_LOCATION_UNIQUE
  --
  chk_name_location_unique(p_rec.establishment_id,
			   p_rec.name,
			   p_rec.location,
			   p_rec.object_version_number);
  --
  -- Descriptive flex checking
  --
  per_est_bus.chk_df(p_rec => p_rec);
  --
  per_est_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_est_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  If hr_multi_tenancy_pkg.is_multi_tenant_system Then
    hr_api.set_security_group_id(p_security_group_id => fnd_global.security_group_id);
  Else
    hr_api.set_security_group_id(p_security_group_id => 0);
  End If;
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTABLISHMENT_ID
  --
  chk_establishment_id(p_rec.establishment_id,
		       p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NAME_LOCATION_UNIQUE
  --
  chk_name_location_unique(p_rec.establishment_id,
			   p_rec.name,
			   p_rec.location,
			   p_rec.object_version_number);
  --
  -- Descriptive flex checking
  --
  per_est_bus.chk_df(p_rec => p_rec);
  --
  per_est_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_est_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ESTAB_DELETE
  --
  chk_estab_delete(p_rec.establishment_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_est_bus;

/
