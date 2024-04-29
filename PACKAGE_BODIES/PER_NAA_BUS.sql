--------------------------------------------------------
--  DDL for Package Body PER_NAA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NAA_BUS" as
/* $Header: penaarhi.pkb 120.1 2006/04/25 06:01:33 niljain noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_naa_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_absence_action_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_absence_attendance_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the absence exists.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_action_id
--    p_object_version_number
--
--  Post Success:
--    If the absence exists, processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_absence_attendance_id
  (p_absence_action_id     in number
  ,p_absence_attendance_id in number
  ,p_object_version_number in number
  )
is
  --
  -- Declare cursor
  --
  cursor cur_chk_abs_atte_id is
    select 1
    from   per_absence_attendances paa
    where  absence_attendance_id = p_absence_attendance_id;
  --
  -- local variables
  l_proc          varchar2(72)  :=  g_package||'chk_absence_attendance_id';
  l_exists        varchar2(1)   := null;
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_absence_attendance_id'
          ,p_argument_value => p_absence_attendance_id
          );
  --
  -- Check that the absence exists.
  --
  open  cur_chk_abs_atte_id;
  fetch cur_chk_abs_atte_id into l_exists;
  close cur_chk_abs_atte_id;
  if l_exists is null then

      fnd_message.set_name('PER', 'HR_NL_INVALID_ABSENCE_ID');
      fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_absence_attendance_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_abs_cat_user_tables  >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the user table exists for absence category.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--
--  Post Success:
--    If the user table exits for absence category exists, processing
--    continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_abs_cat_user_tables
  (p_absence_attendance_id       in number
  )
is
--
-- Declare cursor
--
cursor cur_chk_abs_cat_user_tables is
  select 1
  from   pay_user_tables put,
         per_absence_attendances paa,
	 per_absence_attendance_types paat
  where  put.user_table_name = 'NL_ABS_ACTION_'||paat.absence_category
  and    paa.absence_attendance_type_id = paat.absence_attendance_type_id
  and    paa.absence_attendance_id = p_absence_attendance_id
  and    put.business_group_id = paat.business_group_id;
--
-- local variables
l_proc          varchar2(72)  :=  g_package||'chk_abs_cat_user_tables';
l_exists        varchar2(1)   := null;
l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check that the user table for absence category exists.
  --
  open  cur_chk_abs_cat_user_tables;
  fetch cur_chk_abs_cat_user_tables  into l_exists;
  close cur_chk_abs_cat_user_tables;
  if l_exists is null then

      fnd_message.set_name('PER', 'HR_NL_ACTION_MISSING_SETUP');
      fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_abs_cat_user_tables;
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_expected_date >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the expected date is not null and
--    Validates that the expected date is always greater than or equal to
--    absence start date.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_expected_date
--    p_absence_action_id
--    p_absence_attendance_id
--    p_object_version_number
--
--  Post Success:
--    If the expected date exists and it is valid, processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure  chk_expected_date
  (p_absence_action_id       in number
  ,p_absence_attendance_id   in number
  ,p_expected_date           in date
  ,p_object_version_number   in number
  ) is
  --
  -- Declare cursor
  --
  cursor cur_chk_expected_date is            -- Changes as per bug 2637189
    select nvl(date_start,date_projected_start) absence_date
    from   per_absence_attendances paa
    where  absence_attendance_id = p_absence_attendance_id;
  --
  -- local variables
  l_proc          varchar2(72)  := g_package||'chk_expected_date';
  l_api_updating  boolean;
  l_absence_date  date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check expected date for null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_expected_date'
    ,p_argument_value => p_expected_date
    );
  --
  -- Start changes as per bug 2637189
  -- Check expected date is greater than absence start date
  --
  open  cur_chk_expected_date;
    fetch cur_chk_expected_date into l_absence_date;
  close cur_chk_expected_date;
  --
  if p_expected_date < l_absence_date then
      fnd_message.set_name('PER', 'HR_NL_INVALID_ACTION_EXP_DATE');
      fnd_message.raise_error;
  end if;
  -- end changes as per bug 2637189
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_expected_date;
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_description >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the description is not null.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_description
--    p_absence_action_id
--    p_object_version_number
--
--  Post Success:
--    If the description exists, processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure  chk_description
  (p_absence_action_id       in number
  ,p_description             in varchar2
  ,p_object_version_number   in number
  ) is
  --
  -- Declare cursor
  --
  -- local variables
  l_proc          varchar2(72)  := g_package||'chk_description';
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_description'
    ,p_argument_value => p_description
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_description;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_start_and_end_dates >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the actual start and end dates is not null.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_actual_start_date
--    p_actual_end_date
--    p_absence_action_id
--    p_object_version_number
--
--  Post Success:
--    If the dates are valid, processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure  chk_start_and_end_dates
  (p_absence_action_id       in number
  ,p_actual_start_date       in date
  ,p_actual_end_date         in date
  ,p_object_version_number   in number
  ) is
  --
  -- Declare cursor
  --
  -- local variables
  l_proc          varchar2(72)  := g_package||'chk_start_and_end_dates';
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_actual_start_date is not null and
     p_actual_end_date is not null   then
    if p_actual_start_date > p_actual_end_date then
      fnd_message.set_name('PER', 'HR_NL_INVALID_ABS_ACTION_DATES');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_start_and_end_dates;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_absence_action_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the absence action exists.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_action_id
--    p_object_version_number
--
--  Post Success:
--    If the absence action exists, processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_absence_action_id
  (p_absence_action_id     in number
  ,p_object_version_number in number
  )
is
  --
  -- Declare cursor
  --
  cursor cur_chk_abs_act_id is
    select object_version_number
    from   per_nl_absence_actions paa
    where  absence_action_id = p_absence_action_id;
  --
  -- local variables
  l_proc          varchar2(72)  := g_package||'chk_absence_action_id';
  l_obj_num       number(9)     := null;
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_absence_action_id'
          ,p_argument_value => p_absence_action_id
          );
  --
  -- Check that the absence exists.
  --
  open  cur_chk_abs_act_id;
    fetch cur_chk_abs_act_id into l_obj_num;
  close cur_chk_abs_act_id;
  --
  if l_obj_num is null then

      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
  elsif l_obj_num <> p_object_version_number then

      fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
      fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_absence_action_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_absence_action_id                    in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_nl_absence_actions naa
         , per_absence_attendances paa
     where naa.absence_action_id = p_absence_action_id
     and   naa.absence_attendance_id = paa.absence_attendance_id
     and   pbg.business_group_id = paa.business_group_id;
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
    ,p_argument           => 'absence_action_id'
    ,p_argument_value     => p_absence_action_id
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
  end if;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
     );
  close csr_sec_grp;
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
  (p_absence_action_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_nl_absence_actions naa
         , per_absence_attendances paa
     where naa.absence_action_id = p_absence_action_id
     and   paa.absence_attendance_id = naa.absence_attendance_id
     and   pbg.business_group_id = paa.business_group_id;
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
    ,p_argument           => 'absence_action_id'
    ,p_argument_value     => p_absence_action_id
    );
  --
  if ( nvl(per_naa_bus.g_absence_action_id, hr_api.g_number)
       = p_absence_action_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_naa_bus.g_legislation_code;
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
    per_naa_bus.g_absence_action_id := p_absence_action_id;
    per_naa_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in per_naa_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_naa_shd.api_updating
      (p_absence_action_id                 => p_rec.absence_action_id
      ,p_absence_attendance_id             => p_rec.absence_attendance_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_naa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check Absence attendance id
  --
  chk_absence_attendance_id
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_absence_attendance_id       => p_rec.absence_attendance_id
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- Check User table for Absence Category Lookup Type.
  --
  chk_abs_cat_user_tables
    (p_absence_attendance_id       => p_rec.absence_attendance_id
    );
  --

  -- Check Expected date
  -- changes as per bug 2637189
  -- Bug# 5031662, Reverse the changes made for bug 2637189
  /* chk_expected_date
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_absence_attendance_id       => p_rec.absence_attendance_id
    ,p_expected_date               => p_rec.expected_date
    ,p_object_version_number       => p_rec.object_version_number
    ); */
  --
  -- Check description
  --
  chk_description
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_description                 => p_rec.description
    ,p_object_version_number       => p_rec.object_version_number
    );
  --

 -- Check actual start date and actual end date.
  --
  chk_start_and_end_dates
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_actual_start_date           => p_rec.actual_start_date
    ,p_actual_end_date             => p_rec.actual_end_date
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_naa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check absence is there with right version
  --
  chk_absence_action_id
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- Check Absence attendance id
  --
  chk_absence_attendance_id
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_absence_attendance_id       => p_rec.absence_attendance_id
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- Check Expected date
  -- changes as per bug 2637189
  -- Bug# 5031662, Reverse the changes made for bug 2637189
  /*chk_expected_date
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_absence_attendance_id       => p_rec.absence_attendance_id
    ,p_expected_date               => p_rec.expected_date
    ,p_object_version_number       => p_rec.object_version_number
    );*/
  --
  -- Check description
  --
  chk_description
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_description                 => p_rec.description
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- Check actual start date and actual end date.
  --
  chk_start_and_end_dates
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_actual_start_date           => p_rec.actual_start_date
    ,p_actual_end_date             => p_rec.actual_end_date
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_naa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check absence is there with right version
  --
  chk_absence_action_id
    (p_absence_action_id           => p_rec.absence_action_id
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_naa_bus;

/
