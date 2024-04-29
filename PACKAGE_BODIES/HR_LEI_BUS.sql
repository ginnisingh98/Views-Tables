--------------------------------------------------------
--  DDL for Package Body HR_LEI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEI_BUS" as
/* $Header: hrleirhi.pkb 120.1.12010000.2 2009/01/28 09:08:21 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_lei_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_location_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in LOCATION_ID is in the HR_LOCATIONS table.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_location_id
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
Procedure chk_location_id
  (
   p_location_id        in      hr_location_extra_info.location_id%type
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_location_id';
  l_dummy       varchar2(1);
--
  cursor c_valid_loc is
      select 'x'
        from hr_locations
       where location_id = p_location_id and location_use = 'HR';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'location_id',
     p_argument_value   => p_location_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the location_id is in the hr_locations table.
  --
  open c_valid_loc;
  fetch c_valid_loc into l_dummy;
  if c_valid_loc%notfound then
    close c_valid_loc;
    hr_utility.set_message(800, 'HR_INV_LOC_ID');
    hr_utility.raise_error;
  end if;
  close c_valid_loc;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
End chk_location_id;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the non updateable arguments not changed.
--   For the LOCATION_EXTRA_INFO table neither of the FK's can be updated
--   i.e. LOCATION_ID and INFORMATION_TYPE
--
-- Pre Conditions:
--   None
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
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc        varchar2(72) := g_package||'chk_non_updateable_args';
  l_error       exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema.
  if not hr_lei_shd.api_updating
   (p_location_extra_info_id  => p_rec.location_extra_info_id
   ,p_object_version_number => p_rec.object_version_number
   ) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location (l_proc, 30);
  --
  if nvl(p_rec.location_id,hr_api.g_number)
        <> nvl(hr_lei_shd.g_old_rec.location_id,hr_api.g_number) then
     l_argument := 'location_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.information_type,hr_api.g_varchar2)
        <> nvl(hr_lei_shd.g_old_rec.information_type,hr_api.g_varchar2) then
     l_argument := 'information_type';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Leaving : '|| l_proc, 40);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
end chk_non_updateable_args;
--
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_location_info_type >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_location_info_type(p_information_type varchar2,
					   p_multiple_occurences_flag out nocopy varchar2) is
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure check number of rows against an info type
--   Information_type must exist with active_inactive_flag='Y',
--   FK HR_LOCATION_EXTRA_INFO_FK1, ensures the existence of row in info type table
--   but it should exist with active_inactive_flag = 'Y'
--
--
-- Pre Conditions:
--   This private procedure is called from insert/update_validate procedure.
--
-- In Parameters:
--   A Pl/Sql record structure, and multiple occurence flag.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  l_proc  varchar2(72) := g_package||'chk_location_info_type';
  l_active_inactive_flag HR_LOCATION_INFO_TYPES.ACTIVE_INACTIVE_FLAG%TYPE;
  l_inactive_type exception;
--
  CURSOR c_info_type IS
	SELECT	lit.multiple_occurences_flag
			,lit.active_inactive_flag
	FROM		hr_location_info_types	lit
	WHERE		lit.information_type 		= p_information_type
	;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'information_type',
     p_argument_value   => p_information_type
    );
  open c_info_type;
  fetch c_info_type into p_multiple_occurences_flag, l_active_inactive_flag;
--
-- Check if there is any matching row for given info type
--
  if c_info_type%NOTFOUND then
	raise no_data_found;
  end if;
--
-- Check if info type is active or not.
--
  if l_active_inactive_flag = 'N' then
	raise l_inactive_type;
  end if;
--
  close c_info_type;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
--
  when l_inactive_type then
    close c_info_type;
    hr_utility.set_message(800, 'HR_INACTIVE_INFO_TYPE');
    hr_utility.raise_error;
--
  when no_data_found then
    close c_info_type;
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
--
End chk_location_info_type;
--
--
-- Ensures that number of rows should not exceed one,
-- if multiple_occurences_flag='N'
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_count_rows >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_count_rows(p_information_type in varchar2
				, p_location_id in number
				, p_multiple_occurences_flag in varchar2
			) is
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure check number of rows against an info type
--
-- Pre Conditions:
--   This private procedure is called from insert/update_validate procedure.
--
-- In Parameters:
--   A Pl/Sql record structure
--
-- Out Parameters
--   multiple occurence flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
  l_proc  		varchar2(72) := g_package||'chk_count_rows';
  l_dummy 		varchar2(1);
  l_success 	exception;
  l_failure		exception;
--
  CURSOR c_count_rows IS
	SELECT	'x'
	FROM		hr_location_extra_info	lei
	WHERE		lei.information_type 		= p_information_type
	AND		lei.location_id			= p_location_id ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_multiple_occurences_flag = 'N' then
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
      --
      hr_api.mandatory_arg_error
        (
         p_api_name         => l_proc,
         p_argument         => 'location_id',
         p_argument_value   => p_location_id
        );
	  open c_count_rows;
	  fetch c_count_rows into l_dummy;
	  if c_count_rows%FOUND then
    		close c_count_rows;
		raise l_failure;
	  else
		close c_count_rows;
		raise l_success;
	  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  when l_success then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  when l_failure then
    hr_utility.set_message(800, 'HR_INFO_TYPE_ALLOWS_1_ROW');
    hr_utility.raise_error;

End chk_count_rows;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
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
-- {End Of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_df
  (p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.location_extra_info_id is not null) and (
     nvl(hr_lei_shd.g_old_rec.lei_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute_category, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute1, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute2, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute3, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute4, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute5, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute6, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute7, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute8, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute9, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute10, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute11, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute12, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute13, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute14, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute15, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute16, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute17, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute18, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute19, hr_api.g_varchar2) or
     nvl(hr_lei_shd.g_old_rec.lei_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.lei_attribute20, hr_api.g_varchar2)))
     or
     (p_rec.location_extra_info_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'HR_LOCATION_EXTRA_INFO'
      ,p_attribute_category => p_rec.lei_attribute_category
      ,p_attribute1_name    => 'LEI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.lei_attribute1
      ,p_attribute2_name    => 'LEI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.lei_attribute2
      ,p_attribute3_name    => 'LEI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.lei_attribute3
      ,p_attribute4_name    => 'LEI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.lei_attribute4
      ,p_attribute5_name    => 'LEI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.lei_attribute5
      ,p_attribute6_name    => 'LEI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.lei_attribute6
      ,p_attribute7_name    => 'LEI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.lei_attribute7
      ,p_attribute8_name    => 'LEI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.lei_attribute8
      ,p_attribute9_name    => 'LEI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.lei_attribute9
      ,p_attribute10_name   => 'LEI_ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.lei_attribute10
      ,p_attribute11_name   => 'LEI_ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.lei_attribute11
      ,p_attribute12_name   => 'LEI_ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.lei_attribute12
      ,p_attribute13_name   => 'LEI_ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.lei_attribute13
      ,p_attribute14_name   => 'LEI_ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.lei_attribute14
      ,p_attribute15_name   => 'LEI_ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.lei_attribute15
      ,p_attribute16_name   => 'LEI_ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.lei_attribute16
      ,p_attribute17_name   => 'LEI_ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.lei_attribute17
      ,p_attribute18_name   => 'LEI_ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.lei_attribute18
      ,p_attribute19_name   => 'LEI_ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.lei_attribute19
      ,p_attribute20_name   => 'LEI_ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.lei_attribute20);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_ddf >----------------------------|
-- -----------------------------------------------------------------------
--
-- {Start Of Comments}
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
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec   in hr_lei_shd.g_rec_type) is
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
  if (p_rec.location_extra_info_id is null)
    or ((p_rec.location_extra_info_id is not null)
    and
    nvl(hr_lei_shd.g_old_rec.lei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information_category, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information1, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information2, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information3, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information4, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information5, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information6, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information7, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information8, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information9, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information10, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information11, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information12, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information13, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information14, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information15, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information16, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information17, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information18, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information19, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information20, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information21, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information22, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information23, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information24, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information25, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information26, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information27, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information28, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information29, hr_api.g_varchar2) or
    nvl(hr_lei_shd.g_old_rec.lei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.lei_information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Extra Location Info DDF'
      ,p_attribute_category => p_rec.lei_information_category
      ,p_attribute1_name    => 'LEI_INFORMATION1'
      ,p_attribute1_value   => p_rec.lei_information1
      ,p_attribute2_name    => 'LEI_INFORMATION2'
      ,p_attribute2_value   => p_rec.lei_information2
      ,p_attribute3_name    => 'LEI_INFORMATION3'
      ,p_attribute3_value   => p_rec.lei_information3
      ,p_attribute4_name    => 'LEI_INFORMATION4'
      ,p_attribute4_value   => p_rec.lei_information4
      ,p_attribute5_name    => 'LEI_INFORMATION5'
      ,p_attribute5_value   => p_rec.lei_information5
      ,p_attribute6_name    => 'LEI_INFORMATION6'
      ,p_attribute6_value   => p_rec.lei_information6
      ,p_attribute7_name    => 'LEI_INFORMATION7'
      ,p_attribute7_value   => p_rec.lei_information7
      ,p_attribute8_name    => 'LEI_INFORMATION8'
      ,p_attribute8_value   => p_rec.lei_information8
      ,p_attribute9_name    => 'LEI_INFORMATION9'
      ,p_attribute9_value   => p_rec.lei_information9
      ,p_attribute10_name   => 'LEI_INFORMATION10'
      ,p_attribute10_value  => p_rec.lei_information10
      ,p_attribute11_name   => 'LEI_INFORMATION11'
      ,p_attribute11_value  => p_rec.lei_information11
      ,p_attribute12_name   => 'LEI_INFORMATION12'
      ,p_attribute12_value  => p_rec.lei_information12
      ,p_attribute13_name   => 'LEI_INFORMATION13'
      ,p_attribute13_value  => p_rec.lei_information13
      ,p_attribute14_name   => 'LEI_INFORMATION14'
      ,p_attribute14_value  => p_rec.lei_information14
      ,p_attribute15_name   => 'LEI_INFORMATION15'
      ,p_attribute15_value  => p_rec.lei_information15
      ,p_attribute16_name   => 'LEI_INFORMATION16'
      ,p_attribute16_value  => p_rec.lei_information16
      ,p_attribute17_name   => 'LEI_INFORMATION17'
      ,p_attribute17_value  => p_rec.lei_information17
      ,p_attribute18_name   => 'LEI_INFORMATION18'
      ,p_attribute18_value  => p_rec.lei_information18
      ,p_attribute19_name   => 'LEI_INFORMATION19'
      ,p_attribute19_value  => p_rec.lei_information19
      ,p_attribute20_name   => 'LEI_INFORMATION20'
      ,p_attribute20_value  => p_rec.lei_information20
      ,p_attribute21_name   => 'LEI_INFORMATION21'
      ,p_attribute21_value  => p_rec.lei_information21
      ,p_attribute22_name   => 'LEI_INFORMATION22'
      ,p_attribute22_value  => p_rec.lei_information22
      ,p_attribute23_name   => 'LEI_INFORMATION23'
      ,p_attribute23_value  => p_rec.lei_information23
      ,p_attribute24_name   => 'LEI_INFORMATION24'
      ,p_attribute24_value  => p_rec.lei_information24
      ,p_attribute25_name   => 'LEI_INFORMATION25'
      ,p_attribute25_value  => p_rec.lei_information25
      ,p_attribute26_name   => 'LEI_INFORMATION26'
      ,p_attribute26_value  => p_rec.lei_information26
      ,p_attribute27_name   => 'LEI_INFORMATION27'
      ,p_attribute27_value  => p_rec.lei_information27
      ,p_attribute28_name   => 'LEI_INFORMATION28'
      ,p_attribute28_value  => p_rec.lei_information28
      ,p_attribute29_name   => 'LEI_INFORMATION29'
      ,p_attribute29_value  => p_rec.lei_information29
      ,p_attribute30_name   => 'LEI_INFORMATION30'
      ,p_attribute30_value  => p_rec.lei_information30
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_multiple_occurences_flag	hr_location_info_types.multiple_occurences_flag%type;
--
-- bug 6329528
--
/*
cursor csr_sec_grp is
     select hoi.org_information14, hoi.org_information9
       from hr_organization_information hoi
            , hr_locations_all loc
      where loc.location_id = p_rec.location_id
        and hoi.organization_id = nvl(loc.business_group_id,0)
        and hoi.org_information_context||'' = 'Business Group Information';
*/

-- fix for the bug 7653370 modified the above cursor..as follows
cursor csr_sec_grp is
 select hoi.org_information14, hoi.org_information9
       from hr_organization_information hoi
            , hr_locations_all loc
      where loc.location_id =  p_rec.location_id
       and hoi.organization_id = nvl(loc.business_group_id,nvl(hr_general.get_business_group_id, -99))
        and hoi.org_information_context||'' = 'Business Group Information';

 l_security_group_id number;
 l_legislation_code  varchar2(150);

  -- 6329528

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
--  hr_api.set_security_group_id(p_security_group_id => 0);  commented   bug 6329528
--  bug 6329528

 open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id, l_legislation_code;
 close csr_sec_grp;
  hr_api.set_security_group_id(p_security_group_id => l_security_group_id);
--
  --
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
  -- Call all supporting business operations
  --
  -- 1) Call chk_location_id to validate location_id
  chk_location_id( p_location_id => p_rec.location_id );
  --
  -- 2) Call info_type procedure to validate info_type
  --
  chk_location_info_type(p_information_type => p_rec.information_type
                ,p_multiple_occurences_flag => l_multiple_occurences_flag);
  --
  --
  -- 3) Call count_rows procedure to allow/disallow inserts in extra_info
  chk_count_rows(p_information_type         => p_rec.information_type
                ,p_location_id              => p_rec.location_id
                ,p_multiple_occurences_flag => l_multiple_occurences_flag
               );
  --
  -- Call ddf procedure to validate Developer Descritive Flex Fields
  --
  hr_lei_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Call df procedure to validate Descritive Flex Fields
  --
  hr_lei_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
-- bug 6329528
/*
cursor csr_sec_grp is
     select hoi.org_information14, hoi.org_information9
       from hr_organization_information hoi
            , hr_locations_all loc
      where loc.location_id = p_rec.location_id
        and hoi.organization_id = nvl(loc.business_group_id,0)
        and hoi.org_information_context||'' = 'Business Group Information';
*/

-- fix for the bug 7653370 modified the above cursor..as follows
cursor csr_sec_grp is
 select hoi.org_information14, hoi.org_information9
       from hr_organization_information hoi
            , hr_locations_all loc
      where loc.location_id =  p_rec.location_id
       and hoi.organization_id = nvl(loc.business_group_id,nvl(hr_general.get_business_group_id, -99))
       and hoi.org_information_context||'' = 'Business Group Information';

  l_security_group_id number;
  l_legislation_code  varchar2(150);
-- bug 6329528
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  -- bug 6329528
--   hr_api.set_security_group_id(p_security_group_id => 0);  commented -- bug 6329528
--

open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id, l_legislation_code;
 close csr_sec_grp;
  hr_api.set_security_group_id(p_security_group_id => l_security_group_id);
--

  --
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
  -- Call all supporting business operations
  --
  -- 1) Check those columns which cannot be updated have not changed.
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_non_updateable_args (p_rec => p_rec);
  --
  -- Call ddf procedure to validate Developer Descritive Flex Fields
  --
  hr_lei_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Call df procedure to validate Descritive Flex Fields
  --
  hr_lei_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location('Leaving: '||l_proc, 25);
  --
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_lei_shd.g_rec_type) is
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
end hr_lei_bus;

/
