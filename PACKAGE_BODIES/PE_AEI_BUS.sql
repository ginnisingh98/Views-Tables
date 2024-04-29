--------------------------------------------------------
--  DDL for Package Body PE_AEI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_AEI_BUS" as
/* $Header: peaeirhi.pkb 115.8 2002/12/03 15:36:45 raranjan ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_aei_bus.';  -- Global package name
g_legislation_code               varchar2(150) default null;
g_assignment_extra_info_id      number default null;
--
--
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
/*
Procedure set_security_group_id
  (p_assignment_extra_info_id             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_assignment_extra_info aei
         , per_all_assignments_f aaf
     where aei.assignment_extra_info_id = p_assignment_extra_info_id
      and aaf.assignment_id = aei.assignment_id
      and pbg.business_group_id = aaf.business_group_id;
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
    ,p_argument           => 'assignment_extra_info_id'
    ,p_argument_value     => p_assignment_extra_info_id
    );
  --
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
*/

-- ----------------------------------------------------------------------------
-- |------------------------< return_legislation_code >-----------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code(p_assignment_extra_info_id in NUMBER)
                                return varchar2 is
--
        -- Cursor to find legislation code
        --
        cursor csr_leg_code is
                select pbg.legislation_code
                from per_business_groups pbg,
                     per_assignment_extra_info aei,
                     per_all_assignments_f aaf
                where aei.assignment_extra_info_id = p_assignment_extra_info_id
                and   aaf.assignment_id = aei.assignment_id
                and   pbg.business_group_id = aaf.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code varchar2(150);
  l_proc             varchar2(72) := g_package||'return_legislation_code';
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error(p_api_name         => l_proc
                            ,p_argument        => 'assignment_extra_info_id'
                            ,p_argument_value   => p_assignment_extra_info_id
                            );

--
  if ( nvl(pe_aei_bus.g_assignment_extra_info_id, hr_api.g_number)
       = p_assignment_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pe_aei_bus.g_legislation_code;
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
    pe_aei_bus.g_assignment_extra_info_id := p_assignment_extra_info_id;
    pe_aei_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------<chk_assignment_info_type >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the assignment information type exists in table
--   per_assignment_info_types where active_inactive_flag is 'Y'.
--
-- Pre Conditions:
--   Data must be existed in table per_assignment_info_types.
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
Procedure chk_assignment_info_type
  (
   p_information_type   in    per_assignment_extra_info.information_type%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_assignment_info_type';
  l_flag  per_assignment_info_types.active_inactive_flag%type;
--
  cursor c_asg_info_type (code varchar2) is
      select aeit.active_inactive_flag
        from per_assignment_info_types aeit
       where aeit.information_type = code;
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
  hr_utility.set_location('p_inf_type: '||p_information_type||' '||l_proc, 2);
  --
  -- Check that the ACTIVE_INACTIVE_FLAG of assignment
  -- Information type is active.
  --
  open c_asg_info_type (p_information_type);
  fetch c_asg_info_type into l_flag;
  if c_asg_info_type%notfound then
    close c_asg_info_type;
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE 2');
    hr_utility.raise_error;
  end if;
  close c_asg_info_type;
  --
  if l_flag = 'N' then
    hr_utility.set_message(800, 'HR_INACTIVE_INFO_TYPE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
  --
End chk_assignment_info_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in assignment_ID is in the per_assignments table.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   p_assignment_extra_info_id
--   p_assignment_id
--   p_object_version_number
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
Procedure chk_assignment_id
  (
   p_assignment_id      in      per_assignment_extra_info.assignment_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_assignment_id';
  l_dummy varchar2(1);
--
  cursor c_valid_asg (id number) is
      select 'x'
        from per_all_assignments_f asg
       where asg.assignment_id = id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'assignment_id',
     p_argument_value   => p_assignment_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the assignment_id is in the per_assignments table.
  --
  open c_valid_asg (p_assignment_id);
  fetch c_valid_asg into l_dummy;
  if c_valid_asg%notfound then
    close c_valid_asg;
    hr_utility.set_message(800, 'HR_INV_ASG_ID');
    hr_utility.raise_error;
  end if;
  close c_valid_asg;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
End chk_assignment_id;
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
--   p_assignment_id
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
  (p_information_type   in per_assignment_extra_info.information_type%type
  ,p_assignment_id      in per_assignment_extra_info.assignment_id%type
  ) is
--
  l_proc                varchar2(72) := g_package||'chk_multiple_occurences_flag';
  l_multi_occur_flag    per_assignment_info_types.multiple_occurences_flag%type;
  l_dummy               varchar2(1);
  l_found_poi           boolean;
--
  cursor c_multi_occur_flag (code varchar2) is
     select multiple_occurences_flag
       from per_assignment_info_types
      where information_type = code;
--
  cursor c_get_row (code varchar2, id number) is
     select 'x'
       from per_assignment_extra_info
      where information_type = code
        and assignment_id = id;
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
    hr_utility.set_message(800, 'HR_INV_INFO_TYPE 3');
    hr_utility.raise_error;
  end if;
  --
  close c_multi_occur_flag;
  --
  hr_utility.set_location(l_proc, 10);
  --
  open c_get_row(p_information_type, p_assignment_id);
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
Procedure chk_non_updateable_args (p_rec in pe_aei_shd.g_rec_type) is
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
  if not pe_aei_shd.api_updating
        (p_assignment_extra_info_id     => p_rec.assignment_extra_info_id
	,p_object_version_number	=> p_rec.object_version_number) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.information_type, hr_api.g_varchar2) <>
     nvl(pe_aei_shd.g_old_rec.information_type, hr_api.g_varchar2) then
    l_argument := 'information_type';
    raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if nvl(p_rec.assignment_id, hr_api.g_number) <>
     nvl(pe_aei_shd.g_old_rec.assignment_id, hr_api.g_number) then
    l_argument := 'assignment_id';
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_df
  (p_rec in pe_aei_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.assignment_extra_info_id is not null) and (
     nvl(pe_aei_shd.g_old_rec.aei_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute_category, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute1, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute2, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute3, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute4, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute5, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute6, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute7, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute8, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute9, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute10, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute11, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute12, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute13, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute14, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute15, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute16, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute17, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute18, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute19, hr_api.g_varchar2) or
     nvl(pe_aei_shd.g_old_rec.aei_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.aei_attribute20, hr_api.g_varchar2)))
     or
     (p_rec.assignment_extra_info_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_ASSIGNMENT_EXTRA_INFO'
      ,p_attribute_category => p_rec.aei_attribute_category
      ,p_attribute1_name    => 'AEI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.aei_attribute1
      ,p_attribute2_name    => 'AEI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.aei_attribute2
      ,p_attribute3_name    => 'AEI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.aei_attribute3
      ,p_attribute4_name    => 'AEI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.aei_attribute4
      ,p_attribute5_name    => 'AEI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.aei_attribute5
      ,p_attribute6_name    => 'AEI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.aei_attribute6
      ,p_attribute7_name    => 'AEI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.aei_attribute7
      ,p_attribute8_name    => 'AEI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.aei_attribute8
      ,p_attribute9_name    => 'AEI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.aei_attribute9
      ,p_attribute10_name   => 'AEI_ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.aei_attribute10
      ,p_attribute11_name   => 'AEI_ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.aei_attribute11
      ,p_attribute12_name   => 'AEI_ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.aei_attribute12
      ,p_attribute13_name   => 'AEI_ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.aei_attribute13
      ,p_attribute14_name   => 'AEI_ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.aei_attribute14
      ,p_attribute15_name   => 'AEI_ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.aei_attribute15
      ,p_attribute16_name   => 'AEI_ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.aei_attribute16
      ,p_attribute17_name   => 'AEI_ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.aei_attribute17
      ,p_attribute18_name   => 'AEI_ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.aei_attribute18
      ,p_attribute19_name   => 'AEI_ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.aei_attribute19
      ,p_attribute20_name   => 'AEI_ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.aei_attribute20);
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
  (p_rec   in pe_aei_shd.g_rec_type) is
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
  if (p_rec.assignment_extra_info_id is null)
    or ((p_rec.assignment_extra_info_id is not null)
    and
    nvl(pe_aei_shd.g_old_rec.aei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information_category, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information1, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information2, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information3, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information4, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information5, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information6, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information7, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information8, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information9, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information10, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information11, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information12, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information13, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information14, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information15, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information16, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information17, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information18, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information19, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information20, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information21, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information22, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information23, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information24, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information25, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information26, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information27, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information28, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information29, hr_api.g_varchar2) or
    nvl(pe_aei_shd.g_old_rec.aei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.aei_information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Assignment Developer DF'
      ,p_attribute_category => p_rec.aei_information_category
      ,p_attribute1_name    => 'AEI_INFORMATION1'
      ,p_attribute1_value   => p_rec.aei_information1
      ,p_attribute2_name    => 'AEI_INFORMATION2'
      ,p_attribute2_value   => p_rec.aei_information2
      ,p_attribute3_name    => 'AEI_INFORMATION3'
      ,p_attribute3_value   => p_rec.aei_information3
      ,p_attribute4_name    => 'AEI_INFORMATION4'
      ,p_attribute4_value   => p_rec.aei_information4
      ,p_attribute5_name    => 'AEI_INFORMATION5'
      ,p_attribute5_value   => p_rec.aei_information5
      ,p_attribute6_name    => 'AEI_INFORMATION6'
      ,p_attribute6_value   => p_rec.aei_information6
      ,p_attribute7_name    => 'AEI_INFORMATION7'
      ,p_attribute7_value   => p_rec.aei_information7
      ,p_attribute8_name    => 'AEI_INFORMATION8'
      ,p_attribute8_value   => p_rec.aei_information8
      ,p_attribute9_name    => 'AEI_INFORMATION9'
      ,p_attribute9_value   => p_rec.aei_information9
      ,p_attribute10_name   => 'AEI_INFORMATION10'
      ,p_attribute10_value  => p_rec.aei_information10
      ,p_attribute11_name   => 'AEI_INFORMATION11'
      ,p_attribute11_value  => p_rec.aei_information11
      ,p_attribute12_name   => 'AEI_INFORMATION12'
      ,p_attribute12_value  => p_rec.aei_information12
      ,p_attribute13_name   => 'AEI_INFORMATION13'
      ,p_attribute13_value  => p_rec.aei_information13
      ,p_attribute14_name   => 'AEI_INFORMATION14'
      ,p_attribute14_value  => p_rec.aei_information14
      ,p_attribute15_name   => 'AEI_INFORMATION15'
      ,p_attribute15_value  => p_rec.aei_information15
      ,p_attribute16_name   => 'AEI_INFORMATION16'
      ,p_attribute16_value  => p_rec.aei_information16
      ,p_attribute17_name   => 'AEI_INFORMATION17'
      ,p_attribute17_value  => p_rec.aei_information17
      ,p_attribute18_name   => 'AEI_INFORMATION18'
      ,p_attribute18_value  => p_rec.aei_information18
      ,p_attribute19_name   => 'AEI_INFORMATION19'
      ,p_attribute19_value  => p_rec.aei_information19
      ,p_attribute20_name   => 'AEI_INFORMATION20'
      ,p_attribute20_value  => p_rec.aei_information20
      ,p_attribute21_name   => 'AEI_INFORMATION21'
      ,p_attribute21_value  => p_rec.aei_information21
      ,p_attribute22_name   => 'AEI_INFORMATION22'
      ,p_attribute22_value  => p_rec.aei_information22
      ,p_attribute23_name   => 'AEI_INFORMATION23'
      ,p_attribute23_value  => p_rec.aei_information23
      ,p_attribute24_name   => 'AEI_INFORMATION24'
      ,p_attribute24_value  => p_rec.aei_information24
      ,p_attribute25_name   => 'AEI_INFORMATION25'
      ,p_attribute25_value  => p_rec.aei_information25
      ,p_attribute26_name   => 'AEI_INFORMATION26'
      ,p_attribute26_value  => p_rec.aei_information26
      ,p_attribute27_name   => 'AEI_INFORMATION27'
      ,p_attribute27_value  => p_rec.aei_information27
      ,p_attribute28_name   => 'AEI_INFORMATION28'
      ,p_attribute28_value  => p_rec.aei_information28
      ,p_attribute29_name   => 'AEI_INFORMATION29'
      ,p_attribute29_value  => p_rec.aei_information29
      ,p_attribute30_name   => 'AEI_INFORMATION30'
      ,p_attribute30_value  => p_rec.aei_information30
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
Procedure insert_validate(p_rec in pe_aei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_asg_bus1.set_security_group_id
   (
    p_assignment_id             => p_rec.assignment_id
   );
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Validate Assignment Info Type
  --
  chk_assignment_info_type
        (p_information_type     => p_rec.information_type
        );
  --
  -- Validate Assignment ID
  --
  chk_assignment_id (p_assignment_id  => p_rec.assignment_id);
  --
  -- Validate Multiple Occurence Flag
  --
  chk_multiple_occurences_flag
        (p_information_type     => p_rec.information_type
        ,p_assignment_id        => p_rec.assignment_id
        );
  --
  if pe_aei_shd.g_called_from_form = FALSE then
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- Call ddf procedure to validation Developer Descriptive Flexfields
    --
    pe_aei_bus.chk_ddf(p_rec => p_rec);
    --
    -- Call df procedure to validation Descriptive Flexfields
    --
    pe_aei_bus.chk_df(p_rec => p_rec);
    --
    hr_utility.set_location(l_proc, 15);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pe_aei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_asg_bus1.set_security_group_id
   (
    p_assignment_id             => p_rec.assignment_id
   );
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  -- Validate Non-Updateable Fields
  --
  chk_non_updateable_args (p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 15);
  --
  if pe_aei_shd.g_called_from_form = FALSE then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Call ddf procedure to validate Developer Descriptive Flexfields
    --
    pe_aei_bus.chk_ddf(p_rec => p_rec);
    --
    -- Call df procedure to validate Descriptive Flexfields
    --
    pe_aei_bus.chk_df(p_rec => p_rec);
    --
    hr_utility.set_location(l_proc, 25);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pe_aei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End delete_validate;
--
end pe_aei_bus;

/
