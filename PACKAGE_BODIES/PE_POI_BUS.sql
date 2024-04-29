--------------------------------------------------------
--  DDL for Package Body PE_POI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_POI_BUS" as
/* $Header: pepoirhi.pkb 120.0 2005/05/31 14:50:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_poi_bus.';  -- Global package name
--
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_position_extra_info_id      number         default null;
--
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_position_extra_info_id               in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_position_extra_info and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_position_extra_info poi
         , hr_all_positions_f pos
     where poi.position_extra_info_id = p_position_extra_info_id
      and pbg.business_group_id = pos.business_group_id
      and pos.position_id = poi.position_id;
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
    ,p_argument           => 'position_extra_info_id'
    ,p_argument_value     => p_position_extra_info_id
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
  (p_position_extra_info_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- per_position_extra_info, per_positions and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_position_extra_info poi
         , per_positions pos
     where poi.position_extra_info_id = p_position_extra_info_id
       and pos.position_id = poi.position_id
       and pbg.business_group_id = pos.business_group_id;
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
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'position_extra_info_id'
    ,p_argument_value     => p_position_extra_info_id
    );
  --
  if ( nvl(pe_poi_bus.g_position_extra_info_id, hr_api.g_number)
       = p_position_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pe_poi_bus.g_legislation_code;
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
    --
    close csr_leg_code;
    pe_poi_bus.g_position_extra_info_id := p_position_extra_info_id;
    pe_poi_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;

--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_position_info_type >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the position information type exists in table
--   per_position_info_types where active_inactive_flag is 'Y'.
--
-- Pre Conditions:
--   Data must be existed in table per_position_info_types.
--
-- In Parameters:
--   p_information_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_position_info_type
  (
   p_information_type   in    per_position_info_types.information_type%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_position_info_type';
  l_flag  per_position_info_types.active_inactive_flag%type;
--
  cursor c_pos_info_type (code varchar2) is
      select poit.active_inactive_flag
        from per_position_info_types poit
       where poit.information_type = code;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'information_type',
     p_argument_value   => p_information_type
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the ACTIVE_INACTIVE_FLAG of Position
  -- Information type is active.
  --
  open c_pos_info_type (p_information_type);
  fetch c_pos_info_type into l_flag;
  if c_pos_info_type%notfound then
    close c_pos_info_type;
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  end if;
  close c_pos_info_type;
  --
  if l_flag = 'N' then
    hr_utility.set_message(800, 'HR_INACTIVE_INFO_TYPE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
End chk_position_info_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_position_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in POSITION_ID is in the hr_positions table.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_position_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_position_id
  (
   p_position_id        in      per_position_extra_info.position_id%type
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_position_id';
  l_dummy       varchar2(1);
--
  --
  -- Changed 12-Oct-99 SCNair (per_positions to hr_positions) date tracked position req.
  --
  cursor c_valid_pos (id number) is
      select 'x'
        from hr_all_positions_f
       where position_id = id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'position_id',
     p_argument_value   => p_position_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the position_id is in the hr_positions table.
  --
  open c_valid_pos (p_position_id);
  fetch c_valid_pos into l_dummy;
  if c_valid_pos%notfound then
    close c_valid_pos;
    hr_utility.set_message(800, 'HR_INV_POS_ID');
    hr_utility.raise_error;
  end if;
  close c_valid_pos;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
End chk_position_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_multiple_occurences_flag >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the number of rows should not exceed one when
--   multiple_occurences_flag = 'N'.
--
-- Pre Conditions:
--   This procedure should execute after procedure chk_information_type.
--
-- In Parameters:
--   p_information_type
--   p_position_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_multiple_occurences_flag
  (p_information_type   in per_position_extra_info.information_type%type
  ,p_position_id        in per_position_extra_info.position_id%type
  ) is
--
  l_proc                varchar2(72) := g_package||'chk_multiple_occurences_flag';
  l_multi_occur_flag    per_position_info_types.multiple_occurences_flag%type;
  l_dummy               varchar2(1);
  l_found_poi           boolean;
--
  cursor c_multi_occur_flag (code varchar2) is
     select multiple_occurences_flag
       from per_position_info_types
      where information_type = code;
--
  cursor c_get_row (code varchar2, id number) is
     select 'x'
       from per_position_extra_info
      where information_type = code
        and position_id = id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_multi_occur_flag (p_information_type);
  fetch c_multi_occur_flag into l_multi_occur_flag;
  --
  -- The following case should not happen since procedure
  -- chk_information_type should capture this error.
  --
  if c_multi_occur_flag%notfound then
    close c_multi_occur_flag;
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  end if;
  --
  close c_multi_occur_flag;
  --
  hr_utility.set_location(l_proc, 10);
  --
  open c_get_row(p_information_type, p_position_id);
  fetch c_get_row into l_dummy;
  if c_get_row%notfound then
    l_found_poi := FALSE;
  else
    l_found_poi := TRUE;
  end if;
  close c_get_row;
  --
  if l_found_poi and l_multi_occur_flag = 'N' then
    hr_utility.set_message(800, 'HR_MORE_THAN_1_EXTRA_INFO');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End chk_multiple_occurences_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the non updateable arguments not changed.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_rec
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args (p_rec in pe_poi_shd.g_rec_type) is
--
  l_proc		varchar2(72) := g_package||'chk_non_updateable_args';
  l_error		exception;
  l_argument            varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not pe_poi_shd.api_updating
        (p_position_extra_info_id       => p_rec.position_extra_info_id
	,p_object_version_number	=> p_rec.object_version_number) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.information_type, hr_api.g_varchar2) <>
     nvl(pe_poi_shd.g_old_rec.information_type, hr_api.g_varchar2) then
    l_argument := 'information_type';
    raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if nvl(p_rec.position_id, hr_api.g_number) <>
     nvl(pe_poi_shd.g_old_rec.position_id, hr_api.g_number) then
    l_argument := 'position_id';
    raise l_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when l_error then
    hr_api.argument_changed_error
	(p_api_name => l_proc
	,p_argument => l_argument
	);
    hr_utility.set_location(l_proc, 60);
  when others then
    hr_utility.set_location(l_proc, 70);
    raise;
end chk_non_updateable_args;
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
  (p_rec in pe_poi_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.position_extra_info_id is not null) and (
     nvl(pe_poi_shd.g_old_rec.poei_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute_category, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute1, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute2, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute3, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute4, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute5, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute6, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute7, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute8, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute9, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute10, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute11, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute12, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute13, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute14, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute15, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute16, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute17, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute18, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute19, hr_api.g_varchar2) or
     nvl(pe_poi_shd.g_old_rec.poei_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.poei_attribute20, hr_api.g_varchar2)))
     or
     (p_rec.position_extra_info_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_POSITION_EXTRA_INFO'
      ,p_attribute_category => p_rec.poei_attribute_category
      ,p_attribute1_name    => 'POEI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.poei_attribute1
      ,p_attribute2_name    => 'POEI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.poei_attribute2
      ,p_attribute3_name    => 'POEI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.poei_attribute3
      ,p_attribute4_name    => 'POEI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.poei_attribute4
      ,p_attribute5_name    => 'POEI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.poei_attribute5
      ,p_attribute6_name    => 'POEI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.poei_attribute6
      ,p_attribute7_name    => 'POEI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.poei_attribute7
      ,p_attribute8_name    => 'POEI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.poei_attribute8
      ,p_attribute9_name    => 'POEI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.poei_attribute9
      ,p_attribute10_name   => 'POEI_ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.poei_attribute10
      ,p_attribute11_name   => 'POEI_ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.poei_attribute11
      ,p_attribute12_name   => 'POEI_ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.poei_attribute12
      ,p_attribute13_name   => 'POEI_ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.poei_attribute13
      ,p_attribute14_name   => 'POEI_ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.poei_attribute14
      ,p_attribute15_name   => 'POEI_ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.poei_attribute15
      ,p_attribute16_name   => 'POEI_ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.poei_attribute16
      ,p_attribute17_name   => 'POEI_ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.poei_attribute17
      ,p_attribute18_name   => 'POEI_ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.poei_attribute18
      ,p_attribute19_name   => 'POEI_ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.poei_attribute19
      ,p_attribute20_name   => 'POEI_ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.poei_attribute20);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_ddf >----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   second last step from insert_validate and update_validate.
--   Before any Descriptive Flexfield (chk_df) calls.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data
--   values are all valid this procedure will end normally and
--   processing will continue.
--
-- Post Failure:
--   If the DDF structure column value or any of the data values
--   are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec   in pe_poi_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'chk_ddf';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
  if (p_rec.position_extra_info_id is null)
    or ((p_rec.position_extra_info_id is not null)
    and
    nvl(pe_poi_shd.g_old_rec.poei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information_category, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information1, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information2, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information3, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information4, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information5, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information6, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information7, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information8, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information9, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information10, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information11, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information12, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information13, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information14, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information15, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information16, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information17, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information18, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information19, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information20, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information21, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information22, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information23, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information24, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information25, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information26, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information27, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information28, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information29, hr_api.g_varchar2) or
    nvl(pe_poi_shd.g_old_rec.poei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.poei_information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Extra Position Info DDF'
      ,p_attribute_category => p_rec.poei_information_category
      ,p_attribute1_name    => 'POEI_INFORMATION1'
      ,p_attribute1_value   => p_rec.poei_information1
      ,p_attribute2_name    => 'POEI_INFORMATION2'
      ,p_attribute2_value   => p_rec.poei_information2
      ,p_attribute3_name    => 'POEI_INFORMATION3'
      ,p_attribute3_value   => p_rec.poei_information3
      ,p_attribute4_name    => 'POEI_INFORMATION4'
      ,p_attribute4_value   => p_rec.poei_information4
      ,p_attribute5_name    => 'POEI_INFORMATION5'
      ,p_attribute5_value   => p_rec.poei_information5
      ,p_attribute6_name    => 'POEI_INFORMATION6'
      ,p_attribute6_value   => p_rec.poei_information6
      ,p_attribute7_name    => 'POEI_INFORMATION7'
      ,p_attribute7_value   => p_rec.poei_information7
      ,p_attribute8_name    => 'POEI_INFORMATION8'
      ,p_attribute8_value   => p_rec.poei_information8
      ,p_attribute9_name    => 'POEI_INFORMATION9'
      ,p_attribute9_value   => p_rec.poei_information9
      ,p_attribute10_name   => 'POEI_INFORMATION10'
      ,p_attribute10_value  => p_rec.poei_information10
      ,p_attribute11_name   => 'POEI_INFORMATION11'
      ,p_attribute11_value  => p_rec.poei_information11
      ,p_attribute12_name   => 'POEI_INFORMATION12'
      ,p_attribute12_value  => p_rec.poei_information12
      ,p_attribute13_name   => 'POEI_INFORMATION13'
      ,p_attribute13_value  => p_rec.poei_information13
      ,p_attribute14_name   => 'POEI_INFORMATION14'
      ,p_attribute14_value  => p_rec.poei_information14
      ,p_attribute15_name   => 'POEI_INFORMATION15'
      ,p_attribute15_value  => p_rec.poei_information15
      ,p_attribute16_name   => 'POEI_INFORMATION16'
      ,p_attribute16_value  => p_rec.poei_information16
      ,p_attribute17_name   => 'POEI_INFORMATION17'
      ,p_attribute17_value  => p_rec.poei_information17
      ,p_attribute18_name   => 'POEI_INFORMATION18'
      ,p_attribute18_value  => p_rec.poei_information18
      ,p_attribute19_name   => 'POEI_INFORMATION19'
      ,p_attribute19_value  => p_rec.poei_information19
      ,p_attribute20_name   => 'POEI_INFORMATION20'
      ,p_attribute20_value  => p_rec.poei_information20
      ,p_attribute21_name   => 'POEI_INFORMATION21'
      ,p_attribute21_value  => p_rec.poei_information21
      ,p_attribute22_name   => 'POEI_INFORMATION22'
      ,p_attribute22_value  => p_rec.poei_information22
      ,p_attribute23_name   => 'POEI_INFORMATION23'
      ,p_attribute23_value  => p_rec.poei_information23
      ,p_attribute24_name   => 'POEI_INFORMATION24'
      ,p_attribute24_value  => p_rec.poei_information24
      ,p_attribute25_name   => 'POEI_INFORMATION25'
      ,p_attribute25_value  => p_rec.poei_information25
      ,p_attribute26_name   => 'POEI_INFORMATION26'
      ,p_attribute26_value  => p_rec.poei_information26
      ,p_attribute27_name   => 'POEI_INFORMATION27'
      ,p_attribute27_value  => p_rec.poei_information27
      ,p_attribute28_name   => 'POEI_INFORMATION28'
      ,p_attribute28_value  => p_rec.poei_information28
      ,p_attribute29_name   => 'POEI_INFORMATION29'
      ,p_attribute29_value  => p_rec.poei_information29
      ,p_attribute30_name   => 'POEI_INFORMATION30'
      ,p_attribute30_value  => p_rec.poei_information30
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--
-- --------------------------------------------------------------------------------
-- |---------------------------< permit_extended_pay_poi >----------------------------|
-- --------------------------------------------------------------------------------
function permit_extended_pay_poi(p_rec in pe_poi_shd.g_rec_type) return boolean is
l_position_family   varchar2(100);
l_chk               boolean := false;
cursor c1 is
select poei_information3
from per_position_extra_info
where position_id = p_rec.position_id
and position_extra_info_id <> p_rec.position_extra_info_id
and information_type = 'PER_FAMILY'
and poei_information3 in ('ACADEMIC','FACULTY');
begin
  if p_rec.position_id is not null then
    open c1;
    fetch c1 into l_position_family;
    if c1%found then
      close c1;
      return true;
    else
      close c1;
      if (p_rec.poei_information3 in ('ACADEMIC', 'FACULTY')) then
        return true;
      else
        return false;
      end if;
    end if;
  else
    return(false);
  end if;
end;

function permit_extended_pay(p_position_id varchar2) return boolean is
l_position_family   varchar2(100);
l_chk               boolean := false;
cursor c1 is
select poei_information3
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_FAMILY'
and poei_information3 in ('ACADEMIC','FACULTY');
begin
  if p_position_id is not null then
    open c1;
    fetch c1 into l_position_family;
    if c1%found then
      close c1;
      return true;
    else
      close c1;
      return false;
    end if;
  else
    return(false);
  end if;
end;
--
-- --------------------------------------------------------------------------------
-- |---------------------------< chk_position_family >----------------------------|
-- --------------------------------------------------------------------------------
procedure chk_position_family(p_work_period_type_cd varchar2, p_rec in pe_poi_shd.g_rec_type) is
begin
  if ( nvl(p_work_period_type_cd,'N') = 'Y' ) then
      if (not permit_extended_pay_poi(p_rec)) then
  	    -- Cannot change Position Family of Position Extra Info
  	    -- to Others if extended pay is permitted
    	    hr_utility.set_message(800, 'HR_INV_POI_FAMILY');
	    hr_utility.raise_error;
      end if;
  end if;
end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pe_poi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_position_rec         hr_all_positions_f%rowtype;
  l_position_start_date date;
  l_effective_date date := trunc(sysdate);
--
  cursor c_effective_date is
  select effective_date
  from fnd_sessions
  where session_id = userenv('sessionid');
--
  cursor c_position(p_position_id number, p_effective_date date) is
  select *
  from hr_all_positions_f
  where position_id = p_position_id
  and p_effective_date between effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_effective_date;
  fetch c_effective_date into l_effective_date;
  close c_effective_date;
  --
  open c_position(p_rec.position_id, l_effective_date);
  fetch c_position into l_position_rec;
  --
  -- Validate Position Id
  --
  if c_position%notfound then
    close c_position;
    hr_utility.set_message(800, 'HR_INV_POS_ID');
    hr_utility.raise_error;
  end if;
  --
  close c_position;
  --
/*
  per_pos_bus.set_security_group_id
    (p_position_id                      => p_rec.position_id
    );
*/
  hr_psf_bus.set_security_group_id
    (p_position_id                      => p_rec.position_id
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Validate Position Info Type
  --
  chk_position_info_type
        (p_information_type             => p_rec.information_type
	);
/*
  --
  -- Validate Position ID
  --
  chk_position_id
        (p_position_id                  => p_rec.position_id
	);
*/
  --
  -- Validate Multiple Occurence Flag
  --
  chk_multiple_occurences_flag
        (p_information_type             => p_rec.information_type
	,p_position_id			=> p_rec.position_id
        );
  --
  -- Call ddf procedure to validation Developer Descriptive Flexfields
  --
  pe_poi_bus.chk_ddf(p_rec => p_rec);
  --
  -- Call df procedure to validate Descriptive Flexfields
  --
  pe_poi_bus.chk_df(p_rec => p_rec);
  --
  -- Validate Seasonal Dates for Position Extra Info
  --
  if (p_rec.information_type = 'PER_SEASONAL')  then
  	if (nvl(l_position_rec.seasonal_flag,'N') = 'N' )then
  	  -- Cannot add Seasonal dates to Position Extra Info if seasonal_flag<>'Y'
    	  hr_utility.set_message(800, 'HR_INV_POI_SEASONAL');
	  hr_utility.raise_error;
  	end if;
  	if (fnd_date.canonical_to_date(p_rec.poei_information3)
        > fnd_date.canonical_to_date(p_rec.poei_information4)) then
  	  -- Seasonal end date should be later than seasonal start date
  	  hr_utility.set_message(800, 'HR_INV_POI_SEASONAL_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  -- Validate Overlap Dates for Position Extra Info
  --
  if (p_rec.information_type = 'PER_OVERLAP')  then
  	if ( l_position_rec.overlap_period is null )then
  	  -- Cannot add Overlap dates to Position Extra Info if overlap_period is null
    	  hr_utility.set_message(800, 'HR_INV_POI_OVERLAP');
	  hr_utility.raise_error;
  	end if;
    l_position_start_date := pqh_utility.position_start_date(p_rec.position_id);
    if (fnd_date.canonical_to_date(p_rec.poei_information3) < l_position_start_date) then
      -- Overlap start date should be greater than or equal to position start date
      hr_utility.set_message(800, 'HR_INV_POI_OVERLAP_ST_DT');
      hr_utility.set_message_token('POSITION_START_DATE', l_position_start_date);
      hr_utility.raise_error;
    end if;
  	if (fnd_date.canonical_to_date(p_rec.poei_information3)
        > fnd_date.canonical_to_date(p_rec.poei_information4)) then
  	  -- Overlap end date should be later than overlap start date
  	  hr_utility.set_message(800, 'HR_INV_POI_OVERLAP_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  --
  -- Validate Reservation Info for PTX Extra Info
  --
  if (p_rec.information_type = 'PER_RESERVED')  then
    l_position_start_date := pqh_utility.position_start_date(p_rec.position_id);
    if (fnd_date.canonical_to_date(p_rec.poei_information3) < l_position_start_date) then
      -- Reservation start date should be greater than or equal to position start date
      hr_utility.set_message(800, 'HR_INV_POI_RESERVED_ST_DT');
      hr_utility.set_message_token('POSITION_START_DATE', l_position_start_date);
      hr_utility.raise_error;
    end if;
  	if (fnd_date.canonical_to_date(p_rec.poei_information3)
        > fnd_date.canonical_to_date(p_rec.poei_information4)) then
  	  -- Reservation end date should be later than reservation start date
  	  hr_utility.set_message(800, 'HR_INV_POI_RESERVED_DATES');
	  hr_utility.raise_error;
  	end if;
    if (p_rec.poei_information6 <= 0) then
      -- FTE should be greater than 0
      hr_utility.set_message(800, 'HR_INV_POI_RESERVED_FTE');
      hr_utility.raise_error;
    end if;
    --
    -- check whether reserved fte is available
    --
    pqh_psf_bus.pqh_poei_validate(p_rec.position_id,
      p_rec.position_extra_info_id, p_rec.poei_information5,
      fnd_date.canonical_to_date(p_rec.poei_information3),
      fnd_date.canonical_to_date(p_rec.poei_information4) , p_rec.poei_information6);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pe_poi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_position_rec         hr_all_positions_f%rowtype;
  l_position_start_date date;
  l_effective_date date := trunc(sysdate);
--
  cursor c_effective_date is
  select effective_date
  from fnd_sessions
  where session_id = userenv('sessionid');
--
  cursor c_position(p_position_id number, p_effective_date date) is
  select *
  from hr_all_positions_f
  where position_id = p_position_id
  and p_effective_date between effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_effective_date;
  fetch c_effective_date into l_effective_date;
  close c_effective_date;
  --
  open c_position(p_rec.position_id, l_effective_date);
  fetch c_position into l_position_rec;
  close c_position;
  --
/*
  per_pos_bus.set_security_group_id
    (p_position_id                      => p_rec.position_id
    );
*/
  hr_psf_bus.set_security_group_id
    (p_position_id                      => p_rec.position_id
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Validate Non-Updateable Fields
  --
  chk_non_updateable_args (p_rec => p_rec);
  --
  -- Call ddf procedure to validation Developer Descriptive Flexfields
  --
  pe_poi_bus.chk_ddf(p_rec => p_rec);
  --
  -- Call df procedure to validation Descriptive Flexfields
  --
  pe_poi_bus.chk_df(p_rec => p_rec);
  --
  --
  if (p_rec.information_type = 'PER_SEASONAL')  then
  	if (nvl(l_position_rec.seasonal_flag,'N') = 'N' )then
  	  -- Cannot add Seasonal dates to Position Extra Info if seasonal_flag<>'Y'
    	  hr_utility.set_message(800, 'HR_INV_POI_SEASONAL');
	  hr_utility.raise_error;
  	end if;
  	if (fnd_date.canonical_to_date(p_rec.poei_information3)
        > fnd_date.canonical_to_date(p_rec.poei_information4)) then
  	  -- Seasonal end date should be later than seasonal start date
  	  hr_utility.set_message(800, 'HR_INV_POI_SEASONAL_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  -- Validate Overlap Dates for Position Extra Info
  --
  if (p_rec.information_type = 'PER_OVERLAP')  then
  	if ( l_position_rec.overlap_period is null )then
  	  -- Cannot add Overlap dates to Position Extra Info if overlap_period is null
    	  hr_utility.set_message(800, 'HR_INV_POI_OVERLAP');
	  hr_utility.raise_error;
  	end if;
    l_position_start_date := pqh_utility.position_start_date(p_rec.position_id);
    if (fnd_date.canonical_to_date(p_rec.poei_information3) < l_position_start_date) then
      -- Overlap start date should be greater than or equal to position start date
      hr_utility.set_message(800, 'HR_INV_POI_OVERLAP_ST_DT');
      hr_utility.set_message_token('POSITION_START_DATE', l_position_start_date);
      hr_utility.raise_error;
    end if;
  	if (fnd_date.canonical_to_date(p_rec.poei_information3)
        > fnd_date.canonical_to_date(p_rec.poei_information4)) then
  	  -- Overlap end date should be later than overlap start date
  	  hr_utility.set_message(800, 'HR_INV_POI_OVERLAP_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  if (p_rec.information_type = 'PER_RESERVED') then
    l_position_start_date := pqh_utility.position_start_date(p_rec.position_id);
    if (fnd_date.canonical_to_date(p_rec.poei_information3) < l_position_start_date) then
      -- Reservation start date should be greater than or equal to position start date
      hr_utility.set_message(800, 'HR_INV_POI_RESERVED_ST_DT');
      hr_utility.set_message_token('POSITION_START_DATE', l_position_start_date);
      hr_utility.raise_error;
    end if;
  	if (fnd_date.canonical_to_date(p_rec.poei_information3)
        > fnd_date.canonical_to_date(p_rec.poei_information4)) then
  	  -- Reservation end date should be later than reservation start date
  	  hr_utility.set_message(800, 'HR_INV_POI_RESERVED_DATES');
	  hr_utility.raise_error;
  	end if;
    if (p_rec.poei_information6 <= 0) then
      -- FTE should be greater than 0
      hr_utility.set_message(800, 'HR_INV_POI_RESERVED_FTE');
      hr_utility.raise_error;
    end if;
    --
    -- check whether reserved fte is available
    --
    pqh_psf_bus.pqh_poei_validate(p_rec.position_id,
        p_rec.position_extra_info_id, p_rec.poei_information5,
        fnd_date.canonical_to_date(p_rec.poei_information3),
        fnd_date.canonical_to_date(p_rec.poei_information4) , p_rec.poei_information6);
    --
  elsif (p_rec.information_type = 'PER_FAMILY')  then
    -- Validate Position Family for Position Extra Info
    chk_position_family(l_position_rec.work_period_type_cd, p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pe_poi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
  l_position_rec         hr_all_positions_f%rowtype;
  l_effective_date date := trunc(sysdate);
--
  cursor c_effective_date is
  select effective_date
  from fnd_sessions
  where session_id = userenv('sessionid');
--
  cursor c_position(p_position_id number, p_effective_date date) is
  select *
  from hr_all_positions_f
  where position_id = p_position_id
  and p_effective_date between effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_effective_date;
  fetch c_effective_date into l_effective_date;
  close c_effective_date;
  --
  --
  -- Call all supporting business operations
  --
  open c_position(p_rec.position_id, l_effective_date);
  fetch c_position into l_position_rec;
  close c_position;
  --
  -- Validate Position Family for Position Extra Info
  --
  if (p_rec.information_type = 'PER_FAMILY')  then
    if (l_position_rec.work_period_type_cd = 'Y') then
    	    -- Cannot delete Position Family of Position Extra Info
  	    -- if extended pay is permitted
    	    hr_utility.set_message(800, 'HR_INV_POI_FAMILY_DEL');
	    hr_utility.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End delete_validate;
--
end pe_poi_bus;

/
