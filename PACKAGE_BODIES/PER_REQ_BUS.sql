--------------------------------------------------------
--  DDL for Package Body PER_REQ_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REQ_BUS" as
/* $Header: pereqrhi.pkb 120.0.12000000.2 2007/07/10 05:22:20 mkjayara noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_req_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_requisition_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_requisition_id                       in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_requisitions req
     where req.requisition_id = p_requisition_id
       and pbg.business_group_id = req.business_group_id;
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
    ,p_argument           => 'requisition_id'
    ,p_argument_value     => p_requisition_id
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
  (p_requisition_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_requisitions req
     where req.requisition_id = p_requisition_id
       and pbg.business_group_id = req.business_group_id;
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
    ,p_argument           => 'requisition_id'
    ,p_argument_value     => p_requisition_id
    );
  --
  if ( nvl(per_req_bus.g_requisition_id, hr_api.g_number)
       = p_requisition_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_req_bus.g_legislation_code;
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
    per_req_bus.g_requisition_id              := p_requisition_id;
    per_req_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_req_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.requisition_id is not null)  and (
    nvl(per_req_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_req_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.requisition_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_REQUISITIONS'
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
  (p_rec in per_req_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_req_shd.api_updating
    (p_requisition_id                       => p_rec.requisition_id
    ,p_object_version_number                => p_rec.object_version_number
    )THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_name('PROCEDURE ', l_proc);
     fnd_message.set_name('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  if p_rec.business_group_id <> per_req_shd.g_old_rec.business_group_id
    then l_argument := 'business_group_id';
    raise l_error;
  end if;
  --
  if p_rec.requisition_id <> per_req_shd.g_old_rec.requisition_id
    then l_argument := 'requisition_id';
    raise l_error;
  end if;

  EXCEPTION
    WHEN l_error THEN
      hr_api.argument_changed_error
        (p_api_name => l_proc
        ,p_argument => l_argument);
    WHEN OTHERS THEN
      RAISE;

   hr_utility.set_location(' Leaving:'||l_proc,20);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been
--   set. If the requisition name is null or already exists then an error is
--   generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_name.
--
-- Post Success:
--   Processing continues if the requisition name is not null and valid.
--
-- Post Failure:
--   An application error is raised if the requisition name is null or is
--   already found
--   in the business group.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (p_name in per_requisitions.name%type
  ) IS
--
  l_proc varchar2(72) := g_package || 'chk_name';
  l_name varchar2(1);
--
--   Cursor to check that the requisition name does not exist previously
--
cursor csr_name is
  select null
    from per_requisitions
  where name = p_name;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check to ensure that the Requisition Name is not null.
  --
  hr_utility.set_location(l_proc, 20);
  if p_name is null then
    hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'NAME'
    ,p_argument_value     => p_name
    );
  end if;
  --
  -- Check that the requisition name does not exist already.
  --
  open csr_name;
  fetch csr_name into l_name;
  hr_utility.set_location(l_proc, 30);
  if csr_name%found then
    close csr_name;
    fnd_message.set_name('PER','IRC_412115_DUPLICATE_VAC_NAME');
    fnd_message.raise_error;
  end if;
  close csr_name;
  hr_utility.set_location(' Leaving:'||l_proc,40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_REQUISITIONS.NAME'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_requisition_dates >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the start date has been entered
--   and it is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_date_from
--   p_date_to
--
-- Post Success:
--   Processing continues if the start date is not null and valid.
--
-- Post Failure:
--   An application error is raised if the start date is null or is not before
--   the end date.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_requisition_dates
  (p_date_from  in per_requisitions.date_from%type
  ,p_date_to    in per_requisitions.date_to%type
  ,p_requisition_id in per_requisitions.requisition_id%type
  ,p_object_version_number in per_requisitions.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_requisition_dates';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating := per_req_shd.api_updating(p_requisition_id,p_object_version_number);
  --
  --  Check to see if date_from or date_to values have changed.
  --
  hr_utility.set_location(l_proc, 20);
  if ((l_api_updating
    and ((nvl(per_req_shd.g_old_rec.date_from,hr_api.g_date) <> p_date_from)
    or (nvl(per_req_shd.g_old_rec.date_to,hr_api.g_date) <> p_date_to)))
    or (NOT l_api_updating)) then
    --
    -- Check that the start date has been entered.
    --
    hr_utility.set_location(l_proc, 30);
    if(p_date_from is NULL) then
      fnd_message.set_name('PER','PER_289466_REQ_DATE_FROM_MAND');
      hr_multi_message.add
         (p_associated_column1      => 'PER_REQUISITIONS.DATE_FROM'
         );

   end if;
    --
    -- Check that the start date is before the end date.
    --
    hr_utility.set_location(l_proc, 40);
    if(p_date_from > nvl(p_date_to,hr_api.g_eot)) then
      fnd_message.set_name('PER','IRC_ALL_DATE_START_END');
      hr_multi_message.add
         (p_associated_column1      => 'PER_REQUISITIONS.DATE_FROM'
         ,p_associated_column2      => 'PER_REQUISITIONS.DATE_TO'
         );
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
--
end chk_requisition_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_person_id >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that mandatory parameters have been
--   set.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_person_id
--   p_date_from
--   p_date_to.
--
-- Post Success:
--   Processing continues if a valid record for person_id exists in
--   PER_ALL_PEOPLE_F and if the effective date is valid.
--
-- Post Failure:
--   An application error is raised if the person_id does not exist or is not
--   valid at that effective date.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id in per_requisitions.person_id%type
  ,p_requisition_id in per_requisitions.requisition_id%type
  ,p_object_version_number in per_requisitions.object_version_number%type
  ,p_date_from in per_requisitions.date_from%type
  ,p_date_to  in per_requisitions.date_to%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_person_id';
  l_person_id per_requisitions.person_id%type;
  l_api_updating boolean;
--
--   Cursor to check that the person_id exists in PER_ALL_PEOPLE_F
--
cursor csr_person_id is
  select person_id
    from per_all_people_f
  where person_id = p_person_id
  and p_date_from between effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating := per_req_shd.api_updating(p_requisition_id
    ,p_object_version_number);
  --
  --  Check to see if person_id value has changed.
  --
  hr_utility.set_location(l_proc, 20);
  if ((l_api_updating
    and (nvl(per_req_shd.g_old_rec.person_id,hr_api.g_number) <> p_person_id))
    or (NOT l_api_updating)) then
  --
    if p_person_id is not NULL then
    --
    -- Check if the person_id exists in PER_ALL_PEOPLE_F
    -- and if the person is valid at this effective date
    --
      open csr_person_id;
      fetch csr_person_id into l_person_id;
      hr_utility.set_location(l_proc, 30);
      if csr_person_id%notfound then
        close csr_person_id;
        fnd_message.set_name('PER','PER_289467_REQ_INV_PERSON_ID');
        fnd_message.raise_error;
      end if;
      close csr_person_id;
    end if;
   end if;
   hr_utility.set_location(' Leaving:'||l_proc,40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_REQUISITIONS.PERSON_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
--
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_req_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id); -- Validate Bus Grp
  hr_utility.set_location(l_proc, 20);
  --
  per_req_bus.chk_name
  (p_name => p_rec.name
  );
  hr_utility.set_location(l_proc, 30);
  --
  per_req_bus.chk_requisition_dates
  (p_date_from => p_rec.date_from
  ,p_date_to => p_rec.date_to
  ,p_requisition_id => p_rec.requisition_id
  ,p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 40);
  --
  per_req_bus.chk_person_id
  (p_person_id => p_rec.person_id
  ,p_requisition_id => p_rec.requisition_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_date_from => p_rec.date_from
  ,p_date_to => p_rec.date_to
  );
  hr_utility.set_location(l_proc, 50);
  --
  per_req_bus.chk_df
  (p_rec => p_rec
  );
  hr_multi_message.end_validation_set();
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_req_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  hr_utility.set_location(l_proc, 30);
  --
  per_req_bus.chk_requisition_dates
  (p_date_from => p_rec.date_from
  ,p_date_to => p_rec.date_to
  ,p_requisition_id => p_rec.requisition_id
  ,p_object_version_number =>  p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 40);
  --
  per_req_bus.chk_person_id
  (p_person_id => p_rec.person_id
  ,p_requisition_id => p_rec.requisition_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_date_from => p_rec.date_from
  ,p_date_to => p_rec.date_to
  );
  hr_utility.set_location(l_proc, 50);
  --
  per_req_bus.chk_df
  (p_rec => p_rec
  );
  hr_multi_message.end_validation_set();
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_req_shd.g_rec_type
  ) is
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
end per_req_bus;

/
