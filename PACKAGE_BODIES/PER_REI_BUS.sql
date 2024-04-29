--------------------------------------------------------
--  DDL for Package Body PER_REI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REI_BUS" as
/* $Header: pereirhi.pkb 115.6 2003/10/07 19:01:25 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rei_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_contact_extra_info_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_contact_relationship_id	in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_contact_relationships pcr
     where pcr.contact_relationship_id = p_contact_relationship_id
   AND pbg.business_group_id = pcr.business_group_id;
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
    ,p_argument           => 'contact_relationship_id'
    ,p_argument_value     => p_contact_relationship_id
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
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'CONTACT_EXTRA_INFO_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
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
  (p_contact_extra_info_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_contact_extra_info_f and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf  pbg
         , per_contact_relationships ctr
         , per_contact_extra_info_f  cei
     where cei.contact_extra_info_id = p_contact_extra_info_id
     and   ctr.contact_relationship_id = cei.contact_relationship_id
     and   pbg.business_group_id = ctr.business_group_id;
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
    ,p_argument           => 'contact_extra_info_id'
    ,p_argument_value     => p_contact_extra_info_id
    );
  --
  if ( nvl(per_rei_bus.g_contact_extra_info_id, hr_api.g_number)
       = p_contact_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_rei_bus.g_legislation_code;
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
    per_rei_bus.g_contact_extra_info_id := p_contact_extra_info_id;
    per_rei_bus.g_legislation_code  := l_legislation_code;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_contact_relationship_id >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in p_contact_relationship_id is in the
--   per_contact_relationships table.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   Name                      Reqd Type	Description
--   p_contact_relationship_id Yes  NUMBER	Contact Releationship ID.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_contact_relationship_id(
  p_contact_relationship_id	IN	per_contact_extra_info_f.contact_relationship_id%TYPE) IS
--
  l_proc	VARCHAR2(72) := g_package || 'chk_contact_relationship_id';
  l_dummy	VARCHAR2(1);
--
  CURSOR c_valid_rel IS
  SELECT 'x'
  FROM   per_contact_relationships con
  WHERE  con.contact_relationship_id = p_contact_relationship_id;
--
BEGIN
  hr_utility.set_location('Entering:' || l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error(
   p_api_name       => l_proc,
   p_argument       => 'contact_relationship_id',
   p_argument_value => p_contact_relationship_id);
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the contact_relationship_id is in the per_contact_relationships table.
  --
  OPEN c_valid_rel;
  FETCH c_valid_rel INTO l_dummy;
  IF c_valid_rel%NOTFOUND THEN
    CLOSE c_valid_rel;
    fnd_message.set_name('PER', 'HR_INV_REL_ID');
    fnd_message.raise_error;
  END IF;
  CLOSE c_valid_rel;
  --
  hr_utility.set_location(' Leaving:' || l_proc, 3);
END chk_contact_relationship_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_information_type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the contact information type exists in table
--   per_contact_info_types where active_inactive_flag is 'Y'.
--
-- Pre Conditions:
--   Data must be existed in table per_contact_info_types.
--
-- In Parameters:
--   Name               Reqd    Type            Description
--   p_information_type Yes     VARCHAR2	Contact Information Type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_information_type(
	p_information_type		in varchar2,
	p_datetrack_mode		in varchar2,
	p_contact_relationship_id	in number,
	p_contact_extra_info_id		in number,
	p_validation_start_date		in date,
	p_validation_end_date		in out nocopy date)
is
	l_proc		VARCHAR2(72) := g_package || 'chk_information_type';
	l_dummy		varchar2(1);
	cursor csr_information_type is
		select	legislation_code,
			active_inactive_flag,
			multiple_occurences_flag
		from	per_contact_info_types
		where	information_type = p_information_type;
	l_rec		csr_information_type%rowtype;
	l_min_esd	date;
begin
	hr_utility.set_location('Entering:' || l_proc, 1);
	--
	-- Check mandatory parameters have been set
	--
	hr_api.mandatory_arg_error(
		p_api_name		=> l_proc,
		p_argument		=> 'information_type',
		p_argument_value	=> p_information_type);
	--
	-- "Multiple Occurences Flag" needs to be checked in the following datetrack modes.
	-- 1) INSERT
	-- 2) FUTURE_CHANGE (possibly extend effective_end_date)
	-- 3) DELETE_NEXT_CHANGE (possibly extend effective_end_date)
	--
	if p_datetrack_mode in (hr_api.g_insert, hr_api.g_future_change, hr_api.g_delete_next_change) then
		open csr_information_type;
		fetch csr_information_type into l_rec;
		if csr_information_type%notfound then
			close csr_information_type;
			fnd_message.set_name('PER', 'HR_INV_INFO_TYPE');
			fnd_message.raise_error;
		end if;
		close csr_information_type;
		--
		-- The following validation is only done when INSERTING
		--
		if p_datetrack_mode = hr_api.g_insert then
			--
			-- Check the information_type is available in current legislation.
			--
			if (l_rec.legislation_code is not null and
			    l_rec.legislation_code <> per_ctr_bus.return_legislation_code(p_contact_relationship_id)) then
				fnd_message.set_name('PER', 'HR_INV_INFO_TYPE');
				fnd_message.raise_error;
			end if;
			--
			-- Raise an error when specified information type is inactive.
			--
			if l_rec.active_inactive_flag = 'N' then
				fnd_message.set_name('PER', 'HR_INACTIVE_INFO_TYPE');
				fnd_message.raise_error;
			end if;
		end if;
		--
		-- Check the information_type is unique on arbitrary date
		-- when multiple_occurences_flag = 'N'.
		--
		if l_rec.multiple_occurences_flag = 'N' then
			hr_utility.trace('validation_start_date   : ' || p_validation_start_date);
			hr_utility.trace('validation_end_date     : ' || p_validation_end_date);
			--
			-- Lock parent contact_relationship_id to guarantee uniqueness.
			-- This is to prevent other db sessions to modify the information_type
			-- with the same contact_relationship_id.
			--
			select	'Y'
			into	l_dummy
			from	per_contact_relationships
			where	contact_relationship_id = p_contact_relationship_id
			for update nowait;
			--
			-- Derive the min(ESD) with the same information_type
			-- which overlaps between VSD and VED.
			-- Note p_contact_extra_info_id for INSERTING is null.
			--
			select	min(effective_start_date)
			into	l_min_esd
			from	per_contact_extra_info_f
			where	contact_relationship_id = p_contact_relationship_id
			and	information_type = p_information_type
			and	contact_extra_info_id <> nvl(p_contact_extra_info_id, -1)
			and	effective_end_date >= p_validation_start_date
			and	effective_start_date <= p_validation_end_date;
			--
			hr_utility.trace('min_esd                 : ' || l_min_esd);
			--
			if l_min_esd is not null then
				if l_min_esd <= p_validation_start_date then
					fnd_message.set_name('PER', 'HR_MORE_THAN_1_EXTRA_INFO');
					fnd_message.raise_error;
				end if;
				--
				p_validation_end_date := l_min_esd - 1;
				--
				hr_utility.trace('validation_end_date_new : ' || p_validation_end_date);
			end if;
		end if;
	end if;
	--
	hr_utility.set_location(' Leaving:' || l_proc, 4);
end chk_information_type;
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
  (p_rec in per_rei_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Descriptive Flexfield reference field check
  -- Reference field check is not done automatically, so must be done manually.
  -- Note information_type is checked "not null" by chk_information_type
  -- and cei_information_category is checked "not null" by df routine(context_required_flag = 'Y').
  -- The cost of this checking is very low, so the validation is done
  -- whenever this procedure is called.
  --
  if p_rec.information_type <> p_rec.cei_information_category then
    fnd_message.set_name('PER', 'HR_7438_FLEX_INV_REF_FIELD_VAL');
    fnd_message.raise_error;
  end if;
  --
  if ((p_rec.contact_extra_info_id is not null)  and (
    nvl(per_rei_shd.g_old_rec.information_type, hr_api.g_varchar2) <>
    nvl(p_rec.information_type, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information_category, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information1, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information2, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information3, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information4, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information5, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information6, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information7, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information8, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information9, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information10, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information11, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information12, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information13, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information14, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information15, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information16, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information17, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information18, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information19, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information20, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information21, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information22, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information23, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information24, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information25, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information26, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information27, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information28, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information29, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.cei_information30, hr_api.g_varchar2) ))
    or (p_rec.contact_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Extra Contact Info DDF'
-- Bug.2770089
--      ,p_attribute_category              => 'CEI_INFORMATION_CATEGORY'
      ,p_attribute_category              => p_rec.cei_information_category
      ,p_attribute1_name                 => 'CEI_INFORMATION1'
      ,p_attribute1_value                => p_rec.cei_information1
      ,p_attribute2_name                 => 'CEI_INFORMATION2'
      ,p_attribute2_value                => p_rec.cei_information2
      ,p_attribute3_name                 => 'CEI_INFORMATION3'
      ,p_attribute3_value                => p_rec.cei_information3
      ,p_attribute4_name                 => 'CEI_INFORMATION4'
      ,p_attribute4_value                => p_rec.cei_information4
      ,p_attribute5_name                 => 'CEI_INFORMATION5'
      ,p_attribute5_value                => p_rec.cei_information5
      ,p_attribute6_name                 => 'CEI_INFORMATION6'
      ,p_attribute6_value                => p_rec.cei_information6
      ,p_attribute7_name                 => 'CEI_INFORMATION7'
      ,p_attribute7_value                => p_rec.cei_information7
      ,p_attribute8_name                 => 'CEI_INFORMATION8'
      ,p_attribute8_value                => p_rec.cei_information8
      ,p_attribute9_name                 => 'CEI_INFORMATION9'
      ,p_attribute9_value                => p_rec.cei_information9
      ,p_attribute10_name                => 'CEI_INFORMATION10'
      ,p_attribute10_value               => p_rec.cei_information10
      ,p_attribute11_name                => 'CEI_INFORMATION11'
      ,p_attribute11_value               => p_rec.cei_information11
      ,p_attribute12_name                => 'CEI_INFORMATION12'
      ,p_attribute12_value               => p_rec.cei_information12
      ,p_attribute13_name                => 'CEI_INFORMATION13'
      ,p_attribute13_value               => p_rec.cei_information13
      ,p_attribute14_name                => 'CEI_INFORMATION14'
      ,p_attribute14_value               => p_rec.cei_information14
      ,p_attribute15_name                => 'CEI_INFORMATION15'
      ,p_attribute15_value               => p_rec.cei_information15
      ,p_attribute16_name                => 'CEI_INFORMATION16'
      ,p_attribute16_value               => p_rec.cei_information16
      ,p_attribute17_name                => 'CEI_INFORMATION17'
      ,p_attribute17_value               => p_rec.cei_information17
      ,p_attribute18_name                => 'CEI_INFORMATION18'
      ,p_attribute18_value               => p_rec.cei_information18
      ,p_attribute19_name                => 'CEI_INFORMATION19'
      ,p_attribute19_value               => p_rec.cei_information19
      ,p_attribute20_name                => 'CEI_INFORMATION20'
      ,p_attribute20_value               => p_rec.cei_information20
      ,p_attribute21_name                => 'CEI_INFORMATION21'
      ,p_attribute21_value               => p_rec.cei_information21
      ,p_attribute22_name                => 'CEI_INFORMATION22'
      ,p_attribute22_value               => p_rec.cei_information22
      ,p_attribute23_name                => 'CEI_INFORMATION23'
      ,p_attribute23_value               => p_rec.cei_information23
      ,p_attribute24_name                => 'CEI_INFORMATION24'
      ,p_attribute24_value               => p_rec.cei_information24
      ,p_attribute25_name                => 'CEI_INFORMATION25'
      ,p_attribute25_value               => p_rec.cei_information25
      ,p_attribute26_name                => 'CEI_INFORMATION26'
      ,p_attribute26_value               => p_rec.cei_information26
      ,p_attribute27_name                => 'CEI_INFORMATION27'
      ,p_attribute27_value               => p_rec.cei_information27
      ,p_attribute28_name                => 'CEI_INFORMATION28'
      ,p_attribute28_value               => p_rec.cei_information28
      ,p_attribute29_name                => 'CEI_INFORMATION29'
      ,p_attribute29_value               => p_rec.cei_information29
      ,p_attribute30_name                => 'CEI_INFORMATION30'
      ,p_attribute30_value               => p_rec.cei_information30
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
  (p_rec in per_rei_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.contact_extra_info_id is not null)  and (
    nvl(per_rei_shd.g_old_rec.cei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute_category, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute1, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute2, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute3, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute4, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute5, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute6, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute7, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute8, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute9, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute10, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute11, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute12, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute13, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute14, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute15, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute16, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute17, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute18, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute19, hr_api.g_varchar2)  or
    nvl(per_rei_shd.g_old_rec.cei_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.cei_attribute20, hr_api.g_varchar2) ))
    or (p_rec.contact_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_CONTACT_EXTRA_INFO'
-- Bug.2770089
--      ,p_attribute_category              => 'CEI_ATTRIBUTE_CATEGORY'
      ,p_attribute_category              => p_rec.cei_attribute_category
      ,p_attribute1_name                 => 'CEI_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.cei_attribute1
      ,p_attribute2_name                 => 'CEI_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.cei_attribute2
      ,p_attribute3_name                 => 'CEI_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.cei_attribute3
      ,p_attribute4_name                 => 'CEI_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.cei_attribute4
      ,p_attribute5_name                 => 'CEI_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.cei_attribute5
      ,p_attribute6_name                 => 'CEI_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.cei_attribute6
      ,p_attribute7_name                 => 'CEI_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.cei_attribute7
      ,p_attribute8_name                 => 'CEI_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.cei_attribute8
      ,p_attribute9_name                 => 'CEI_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.cei_attribute9
      ,p_attribute10_name                => 'CEI_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.cei_attribute10
      ,p_attribute11_name                => 'CEI_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.cei_attribute11
      ,p_attribute12_name                => 'CEI_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.cei_attribute12
      ,p_attribute13_name                => 'CEI_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.cei_attribute13
      ,p_attribute14_name                => 'CEI_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.cei_attribute14
      ,p_attribute15_name                => 'CEI_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.cei_attribute15
      ,p_attribute16_name                => 'CEI_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.cei_attribute16
      ,p_attribute17_name                => 'CEI_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.cei_attribute17
      ,p_attribute18_name                => 'CEI_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.cei_attribute18
      ,p_attribute19_name                => 'CEI_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.cei_attribute19
      ,p_attribute20_name                => 'CEI_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.cei_attribute20
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
  ,p_rec             in per_rei_shd.g_rec_type
  ) IS
--
  l_argument	VARCHAR2(30);
  l_error	EXCEPTION;
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_rei_shd.api_updating
      (p_contact_extra_info_id            => p_rec.contact_extra_info_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Check if contact_relationship_id is updated.
  -- Raise an error when contact_relationship_id is updated.
  --
  hr_utility.set_location(l_proc, 20);
  IF NVL(p_rec.contact_relationship_id, hr_api.g_number) <>
     NVL(per_rei_shd.g_old_rec.contact_relationship_id, hr_api.g_number) THEN
    --
    l_argument := 'contact_relationship_id';
    RAISE l_error;
  END IF;
  --
  -- Check if information_type is updated.
  -- Raise an error when information_type is updated.
  --
  hr_utility.set_location(l_proc, 30);
  IF NVL(p_rec.information_type, hr_api.g_varchar2) <>
     NVL(per_rei_shd.g_old_rec.information_type, hr_api.g_varchar2) THEN
    --
    l_argument := 'information_type';
    RAISE l_error;
  END IF;
  --
  -- Check if cei_information_category is updated.
  -- Raise an error when information_type is updated.
  --
  hr_utility.set_location(l_proc, 40);
  IF NVL(p_rec.cei_information_category, hr_api.g_varchar2) <>
     NVL(per_rei_shd.g_old_rec.cei_information_category, hr_api.g_varchar2) THEN
    --
    l_argument := 'cei_information_category';
    RAISE l_error;
  END IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc, 50);
EXCEPTION
  WHEN l_error THEN
    hr_utility.set_location(l_proc, 60);
    --
    hr_api.argument_changed_error(
     p_api_name => l_proc,
     p_argument => l_argument);
  WHEN OTHERS THEN
    hr_utility.set_location(l_proc, 70);
    --
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
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
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
  --
  --
Exception
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
  (p_contact_extra_info_id            in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
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
      ,p_argument       => 'contact_extra_info_id'
      ,p_argument_value => p_contact_extra_info_id
      );
    --
    --
    --
  End If;
  --
Exception
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
  (p_rec                   in per_rei_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in out nocopy date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Set security_group_id in CLIENT_INFO
  --
  per_rei_bus.set_security_group_id(
   p_contact_relationship_id => p_rec.contact_relationship_id);
  --
  -- Validate Contact Relationship ID
  -- This needs to be validated before information_type.
  --
  per_rei_bus.chk_contact_relationship_id(
   p_contact_relationship_id => p_rec.contact_relationship_id);
  --
  -- Validate Contact Info Type
  --
  per_rei_bus.chk_information_type(
   p_information_type		=> p_rec.information_type,
   p_datetrack_mode		=> p_datetrack_mode,
   p_contact_relationship_id	=> p_rec.contact_relationship_id,
   p_contact_extra_info_id	=> p_rec.contact_extra_info_id,
   p_validation_start_date	=> p_validation_start_date,
   p_validation_end_date	=> p_validation_end_date);
  --
  -- Skip descriptive flexfield validation when the API is called from form.
  --
  IF per_rei_shd.g_called_from_form = FALSE THEN
    hr_utility.set_location(l_proc, 10);
    --
    -- Bug.2770089
    -- Support dynamic profile option "PER_CONTACT_RELATIONSHIP_ID"
    -- which is available in df value set.
    -- If you want to reference contact_relationship_id in value set,
    -- use ":$PROFILES$.PER_CONTACT_RELATIONSHIP_ID".
    -- Note that we do not have to create this profile option
    -- in FND_PROFILE_OPTIONS, this profile option is created dynamically
    -- in memory by the following code.
    -- Remember to populate PER_CONTACT_RELATIONSHIP_ID to not only forms PERWSREI.fmb
    -- but also any selfservice modules which reference PER_CONTACT_EXTRA_INFO_F df.
    --
    fnd_profile.put('PER_CONTACT_RELATIONSHIP_ID', to_char(p_rec.contact_relationship_id));
    --
    per_rei_bus.chk_ddf(p_rec);
    --
    per_rei_bus.chk_df(p_rec);
  END IF;
  -- =
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in per_rei_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Set security_group_id in CLIENT_INFO
  --
  per_rei_bus.set_security_group_id(
   p_contact_relationship_id => p_rec.contact_relationship_id);
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  -- Skip descriptive flexfield validation when the API is called from form.
  --
  IF per_rei_shd.g_called_from_form = FALSE THEN
    hr_utility.set_location(l_proc, 7);
    --
    -- Bug.2770089
    -- Support dynamic profile option "PER_CONTACT_RELATIONSHIP_ID"
    -- which is available in df value set.
    -- If you want to reference contact_relationship_id in value set,
    -- use ":$PROFILES$.PER_CONTACT_RELATIONSHIP_ID".
    -- Note that we do not have to create this profile option
    -- in FND_PROFILE_OPTIONS, this profile option is created dynamically
    -- in memory by the following code.
    -- Remember to populate PER_CONTACT_RELATIONSHIP_ID to not only forms PERWSREI.fmb
    -- but also any selfservice modules which reference PER_CONTACT_EXTRA_INFO_F df.
    --
    fnd_profile.put('PER_CONTACT_RELATIONSHIP_ID', to_char(p_rec.contact_relationship_id));
    --
    per_rei_bus.chk_ddf(p_rec);
    --
    per_rei_bus.chk_df(p_rec);
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in per_rei_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in out nocopy date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
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
    ,p_contact_extra_info_id            => p_rec.contact_extra_info_id
    );
  --
  -- Validate Contact Info Type
  -- This is non-updatable argument, but needs to validate
  -- whether this information is unique when information_type is multiple entries not allowed.
  --
  per_rei_bus.chk_information_type(
   p_information_type		=> per_rei_shd.g_old_rec.information_type,
   p_datetrack_mode		=> p_datetrack_mode,
   p_contact_relationship_id	=> per_rei_shd.g_old_rec.contact_relationship_id,
   p_contact_extra_info_id	=> p_rec.contact_extra_info_id,
   p_validation_start_date	=> p_validation_start_date,
   p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_rei_bus;

/
