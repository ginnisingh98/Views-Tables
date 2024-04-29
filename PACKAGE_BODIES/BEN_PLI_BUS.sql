--------------------------------------------------------
--  DDL for Package Body BEN_PLI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLI_BUS" as
/* $Header: beplirhi.pkb 115.1 2003/09/24 00:02:28 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pli_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pl_extra_info_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_pl_extra_info_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- ben_pl_extra_info and ben_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , ben_pl_extra_info pli
         , ben_pl_f pl
     where pli.pl_extra_info_id = p_pl_extra_info_id
	and pl.pl_id = pli.pl_id
       and pbg.business_group_id = pl.business_group_id;
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
    ,p_argument           => 'pl_extra_info_id'
    ,p_argument_value     => p_pl_extra_info_id
    );
  --
  if ( nvl(ben_pli_bus.g_pl_extra_info_id, hr_api.g_number)
       = p_pl_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_pli_bus.g_legislation_code;
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
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    ben_pli_bus.g_pl_extra_info_id := p_pl_extra_info_id;
    ben_pli_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_pl_info_type >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the pl information type exists in table
--   ben_pl_info_types where active_inactive_flag is 'Y'.
--
-- Pre Conditions:
--   Data must be existed in table ben_pl_info_types.
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
--   Internal Table Handpl Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_pl_info_type
  (p_information_type   in    ben_pl_info_types.information_type%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_pl_info_type';
  l_flag  ben_pl_info_types.active_inactive_flag%type;
--
  cursor c_pl_info_type (code varchar2) is
      select pl.active_inactive_flag
        from ben_pl_info_types pl
       where pl.information_type = code;
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
  -- Check that the ACTIVE_INACTIVE_FLAG of pl
  -- Information type is active.
  --
  open c_pl_info_type (p_information_type);
  fetch c_pl_info_type into l_flag;
  if c_pl_info_type%notfound then
    close c_pl_info_type;
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE');
    hr_utility.raise_error;
  end if;
  close c_pl_info_type;
  --
  if l_flag = 'N' then
    hr_utility.set_message(800, 'HR_INACTIVE_INFO_TYPE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
End chk_pl_info_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_pl_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in pl_ID is in the ben_pl Table.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_pl_id
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
--   Internal Table Handpl Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_pl_id
  (
   p_pl_id        in      ben_pl_extra_info.pl_id%type
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_pl_id';
  l_dummy       varchar2(1);
--

      cursor c_valid_pl (id number) is
      select 'x'
      from ben_pl_f
      where pl_id = id;


--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'pl_id',
     p_argument_value   => p_pl_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the pl_id is in the ben_pl table.
  --
  open c_valid_pl (p_pl_id);
  fetch c_valid_pl into l_dummy;
  if c_valid_pl%notfound then
    close c_valid_pl;
    hr_utility.set_message(800, 'HR_INV_PL_ID');
    hr_utility.raise_error;
  end if;
  close c_valid_pl;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
End chk_pl_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_multiple_occurences_flag >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments)
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
--   p_pl_id
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
--   Internal Table Handpl Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_multiple_occurences_flag
  (p_information_type   in ben_pl_extra_info.information_type%type
  ,p_pl_id        in ben_pl_extra_info.pl_id%type
  ) is
--
  l_proc                varchar2(72) := g_package||'chk_multiple_occurences_flag';
  l_multi_occur_flag    ben_pl_info_types.multiple_occurences_flag%type;
  l_dummy               varchar2(1);
  l_found_pl           boolean;
--
  cursor c_multi_occur_flag (code varchar2) is
     select multiple_occurences_flag
       from ben_pl_info_types
      where information_type = code;
--
  cursor c_get_row (code varchar2, id number) is
     select 'x'
       from ben_pl_extra_info
      where information_type = code
        and pl_id = id;
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
  open c_get_row(p_information_type, p_pl_id);
  fetch c_get_row into l_dummy;
  if c_get_row%notfound then
    l_found_pl := FALSE;
  else
    l_found_pl := TRUE;
  end if;
  close c_get_row;
  --
  if l_found_pl and l_multi_occur_flag = 'N' then
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
--   Internal Table Handpl Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args (p_rec in ben_pli_shd.g_rec_type) is
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
  if not ben_pli_shd.api_updating
        (p_pl_extra_info_id       => p_rec.pl_extra_info_id
	,p_object_version_number	=> p_rec.object_version_number) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.information_type, hr_api.g_varchar2) <>
     nvl(ben_pli_shd.g_old_rec.information_type, hr_api.g_varchar2) then
    l_argument := 'information_type';
    raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if nvl(p_rec.pl_id, hr_api.g_number) <>
     nvl(ben_pli_shd.g_old_rec.pl_id, hr_api.g_number) then
    l_argument := 'pl_id';
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

-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_pli_shd.g_rec_type) is
--- ----------------------------------------------------------------------------
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate pl ID
  --
  chk_pl_id
        (p_pl_id                  => p_rec.pl_id
	);
  --
  -- Validate pl Info Type
  --
  chk_pl_info_type
        (p_information_type     => p_rec.information_type);
  --
  -- Validate Multiple Occurence Flag
  --
  chk_multiple_occurences_flag
        (p_information_type             => p_rec.information_type
     	  ,p_pl_id				    => p_rec.pl_id
        );
  --
  -- Call df procedure to validation Descriptive Flexfields
  --
/*
  ben_pli_flex.df(p_rec);
*/
  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'BEN'
      ,p_descflex_name      => 'Extra Plan Information'
      ,p_attribute_category => p_rec.pli_attribute_category
      ,p_attribute1_name    => 'PLI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.pli_attribute1
      ,p_attribute2_name    => 'PLI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.pli_attribute2
      ,p_attribute3_name    => 'PLI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.pli_attribute3
      ,p_attribute4_name    => 'PLI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.pli_attribute4
      ,p_attribute5_name    => 'PLI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.pli_attribute5
      ,p_attribute6_name    => 'PLI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.pli_attribute6
      ,p_attribute7_name    => 'PLI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.pli_attribute7
      ,p_attribute8_name    => 'PLI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.pli_attribute8
      ,p_attribute9_name    => 'PLI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.pli_attribute9
      ,p_attribute10_name    => 'PLI_ATTRIBUTE10'
      ,p_attribute10_value   => p_rec.pli_attribute10
      ,p_attribute11_name    => 'PLI_ATTRIBUTE11'
      ,p_attribute11_value   => p_rec.pli_attribute11
      ,p_attribute12_name    => 'PLI_ATTRIBUTE12'
      ,p_attribute12_value   => p_rec.pli_attribute12
      ,p_attribute13_name    => 'PLI_ATTRIBUTE13'
      ,p_attribute13_value   => p_rec.pli_attribute13
      ,p_attribute14_name    => 'PLI_ATTRIBUTE14'
      ,p_attribute14_value   => p_rec.pli_attribute14
      ,p_attribute15_name    => 'PLI_ATTRIBUTE15'
      ,p_attribute15_value   => p_rec.pli_attribute15
      ,p_attribute16_name    => 'PLI_ATTRIBUTE16'
      ,p_attribute16_value   => p_rec.pli_attribute16
      ,p_attribute17_name    => 'PLI_ATTRIBUTE17'
      ,p_attribute17_value   => p_rec.pli_attribute17
      ,p_attribute18_name    => 'PLI_ATTRIBUTE18'
      ,p_attribute18_value   => p_rec.pli_attribute18
      ,p_attribute19_name    => 'PLI_ATTRIBUTE19'
      ,p_attribute19_value   => p_rec.pli_attribute19
      ,p_attribute20_name    => 'PLI_ATTRIBUTE20'
      ,p_attribute20_value   => p_rec.pli_attribute20
      );

  --
  -- Call ddf procedure to validation Developer Descriptive Flexfields
  --
/*
  ben_pli_flex_ddf.ddf(p_rec);
*/
  --
  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'BEN'
      ,p_descflex_name      => 'Extra Plan Info DDF'
      ,p_attribute_category => p_rec.pli_information_category
      ,p_attribute1_name    => 'PLI_INFORMATION1'
      ,p_attribute1_value   => p_rec.pli_information1
      ,p_attribute2_name    => 'PLI_INFORMATION2'
      ,p_attribute2_value   => p_rec.pli_information2
      ,p_attribute3_name    => 'PLI_INFORMATION3'
      ,p_attribute3_value   => p_rec.pli_information3
      ,p_attribute4_name    => 'PLI_INFORMATION4'
      ,p_attribute4_value   => p_rec.pli_information4
      ,p_attribute5_name    => 'PLI_INFORMATION5'
      ,p_attribute5_value   => p_rec.pli_information5
      ,p_attribute6_name    => 'PLI_INFORMATION6'
      ,p_attribute6_value   => p_rec.pli_information6
      ,p_attribute7_name    => 'PLI_INFORMATION7'
      ,p_attribute7_value   => p_rec.pli_information7
      ,p_attribute8_name    => 'PLI_INFORMATION8'
      ,p_attribute8_value   => p_rec.pli_information8
      ,p_attribute9_name    => 'PLI_INFORMATION9'
      ,p_attribute9_value   => p_rec.pli_information9
      ,p_attribute10_name    => 'PLI_INFORMATION10'
      ,p_attribute10_value   => p_rec.pli_information10
      ,p_attribute11_name    => 'PLI_INFORMATION11'
      ,p_attribute11_value   => p_rec.pli_information11
      ,p_attribute12_name    => 'PLI_INFORMATION12'
      ,p_attribute12_value   => p_rec.pli_information12
      ,p_attribute13_name    => 'PLI_INFORMATION13'
      ,p_attribute13_value   => p_rec.pli_information13
      ,p_attribute14_name    => 'PLI_INFORMATION14'
      ,p_attribute14_value   => p_rec.pli_information14
      ,p_attribute15_name    => 'PLI_INFORMATION15'
      ,p_attribute15_value   => p_rec.pli_information15
      ,p_attribute16_name    => 'PLI_INFORMATION16'
      ,p_attribute16_value   => p_rec.pli_information16
      ,p_attribute17_name    => 'PLI_INFORMATION17'
      ,p_attribute17_value   => p_rec.pli_information17
      ,p_attribute18_name    => 'PLI_INFORMATION18'
      ,p_attribute18_value   => p_rec.pli_information18
      ,p_attribute19_name    => 'PLI_INFORMATION19'
      ,p_attribute19_value   => p_rec.pli_information19
      ,p_attribute20_name    => 'PLI_INFORMATION20'
      ,p_attribute20_value   => p_rec.pli_information20
      ,p_attribute21_name    => 'PLI_INFORMATION21'
      ,p_attribute21_value   => p_rec.pli_information21
      ,p_attribute22_name    => 'PLI_INFORMATION22'
      ,p_attribute22_value   => p_rec.pli_information22
      ,p_attribute23_name    => 'PLI_INFORMATION23'
      ,p_attribute23_value   => p_rec.pli_information23
      ,p_attribute24_name    => 'PLI_INFORMATION24'
      ,p_attribute24_value   => p_rec.pli_information24
      ,p_attribute25_name    => 'PLI_INFORMATION25'
      ,p_attribute25_value   => p_rec.pli_information25
      ,p_attribute26_name    => 'PLI_INFORMATION26'
      ,p_attribute26_value   => p_rec.pli_information26
      ,p_attribute27_name    => 'PLI_INFORMATION27'
      ,p_attribute27_value   => p_rec.pli_information27
      ,p_attribute28_name    => 'PLI_INFORMATION28'
      ,p_attribute28_value   => p_rec.pli_information28
      ,p_attribute29_name    => 'PLI_INFORMATION29'
      ,p_attribute29_value   => p_rec.pli_information29
      ,p_attribute30_name    => 'PLI_INFORMATION30'
      ,p_attribute30_value   => p_rec.pli_information30
      );
    --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_pli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Non-Updateable Fields
  --
  chk_non_updateable_args (p_rec => p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
      hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'BEN'
      ,p_descflex_name      => 'Extra Plan Information'
      ,p_attribute_category => p_rec.pli_attribute_category
      ,p_attribute1_name    => 'PLI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.pli_attribute1
      ,p_attribute2_name    => 'PLI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.pli_attribute2
      ,p_attribute3_name    => 'PLI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.pli_attribute3
      ,p_attribute4_name    => 'PLI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.pli_attribute4
      ,p_attribute5_name    => 'PLI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.pli_attribute5
      ,p_attribute6_name    => 'PLI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.pli_attribute6
      ,p_attribute7_name    => 'PLI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.pli_attribute7
      ,p_attribute8_name    => 'PLI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.pli_attribute8
      ,p_attribute9_name    => 'PLI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.pli_attribute9
      ,p_attribute10_name    => 'PLI_ATTRIBUTE10'
      ,p_attribute10_value   => p_rec.pli_attribute10
      ,p_attribute11_name    => 'PLI_ATTRIBUTE11'
      ,p_attribute11_value   => p_rec.pli_attribute11
      ,p_attribute12_name    => 'PLI_ATTRIBUTE12'
      ,p_attribute12_value   => p_rec.pli_attribute12
      ,p_attribute13_name    => 'PLI_ATTRIBUTE13'
      ,p_attribute13_value   => p_rec.pli_attribute13
      ,p_attribute14_name    => 'PLI_ATTRIBUTE14'
      ,p_attribute14_value   => p_rec.pli_attribute14
      ,p_attribute15_name    => 'PLI_ATTRIBUTE15'
      ,p_attribute15_value   => p_rec.pli_attribute15
      ,p_attribute16_name    => 'PLI_ATTRIBUTE16'
      ,p_attribute16_value   => p_rec.pli_attribute16
      ,p_attribute17_name    => 'PLI_ATTRIBUTE17'
      ,p_attribute17_value   => p_rec.pli_attribute17
      ,p_attribute18_name    => 'PLI_ATTRIBUTE18'
      ,p_attribute18_value   => p_rec.pli_attribute18
      ,p_attribute19_name    => 'PLI_ATTRIBUTE19'
      ,p_attribute19_value   => p_rec.pli_attribute19
      ,p_attribute20_name    => 'PLI_ATTRIBUTE20'
      ,p_attribute20_value   => p_rec.pli_attribute20
      );

  --

  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'BEN'
      ,p_descflex_name      => 'Extra Plan Info DDF'
      ,p_attribute_category => p_rec.pli_information_category
      ,p_attribute1_name    => 'PLI_INFORMATION1'
      ,p_attribute1_value   => p_rec.pli_information1
      ,p_attribute2_name    => 'PLI_INFORMATION2'
      ,p_attribute2_value   => p_rec.pli_information2
      ,p_attribute3_name    => 'PLI_INFORMATION3'
      ,p_attribute3_value   => p_rec.pli_information3
      ,p_attribute4_name    => 'PLI_INFORMATION4'
      ,p_attribute4_value   => p_rec.pli_information4
      ,p_attribute5_name    => 'PLI_INFORMATION5'
      ,p_attribute5_value   => p_rec.pli_information5
      ,p_attribute6_name    => 'PLI_INFORMATION6'
      ,p_attribute6_value   => p_rec.pli_information6
      ,p_attribute7_name    => 'PLI_INFORMATION7'
      ,p_attribute7_value   => p_rec.pli_information7
      ,p_attribute8_name    => 'PLI_INFORMATION8'
      ,p_attribute8_value   => p_rec.pli_information8
      ,p_attribute9_name    => 'PLI_INFORMATION9'
      ,p_attribute9_value   => p_rec.pli_information9
      ,p_attribute10_name    => 'PLI_INFORMATION10'
      ,p_attribute10_value   => p_rec.pli_information10
      ,p_attribute11_name    => 'PLI_INFORMATION11'
      ,p_attribute11_value   => p_rec.pli_information11
      ,p_attribute12_name    => 'PLI_INFORMATION12'
      ,p_attribute12_value   => p_rec.pli_information12
      ,p_attribute13_name    => 'PLI_INFORMATION13'
      ,p_attribute13_value   => p_rec.pli_information13
      ,p_attribute14_name    => 'PLI_INFORMATION14'
      ,p_attribute14_value   => p_rec.pli_information14
      ,p_attribute15_name    => 'PLI_INFORMATION15'
      ,p_attribute15_value   => p_rec.pli_information15
      ,p_attribute16_name    => 'PLI_INFORMATION16'
      ,p_attribute16_value   => p_rec.pli_information16
      ,p_attribute17_name    => 'PLI_INFORMATION17'
      ,p_attribute17_value   => p_rec.pli_information17
      ,p_attribute18_name    => 'PLI_INFORMATION18'
      ,p_attribute18_value   => p_rec.pli_information18
      ,p_attribute19_name    => 'PLI_INFORMATION19'
      ,p_attribute19_value   => p_rec.pli_information19
      ,p_attribute20_name    => 'PLI_INFORMATION20'
      ,p_attribute20_value   => p_rec.pli_information20
      ,p_attribute21_name    => 'PLI_INFORMATION21'
      ,p_attribute21_value   => p_rec.pli_information21
      ,p_attribute22_name    => 'PLI_INFORMATION22'
      ,p_attribute22_value   => p_rec.pli_information22
      ,p_attribute23_name    => 'PLI_INFORMATION23'
      ,p_attribute23_value   => p_rec.pli_information23
      ,p_attribute24_name    => 'PLI_INFORMATION24'
      ,p_attribute24_value   => p_rec.pli_information24
      ,p_attribute25_name    => 'PLI_INFORMATION25'
      ,p_attribute25_value   => p_rec.pli_information25
      ,p_attribute26_name    => 'PLI_INFORMATION26'
      ,p_attribute26_value   => p_rec.pli_information26
      ,p_attribute27_name    => 'PLI_INFORMATION27'
      ,p_attribute27_value   => p_rec.pli_information27
      ,p_attribute28_name    => 'PLI_INFORMATION28'
      ,p_attribute28_value   => p_rec.pli_information28
      ,p_attribute29_name    => 'PLI_INFORMATION29'
      ,p_attribute29_value   => p_rec.pli_information29
      ,p_attribute30_name    => 'PLI_INFORMATION30'
      ,p_attribute30_value   => p_rec.pli_information30
      );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_pli_shd.g_rec_type) is
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
end ben_pli_bus;

/
