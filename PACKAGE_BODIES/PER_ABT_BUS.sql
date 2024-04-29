--------------------------------------------------------
--  DDL for Package Body PER_ABT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABT_BUS" as
/* $Header: peabtrhi.pkb 120.1 2005/10/10 04:12 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abt_bus.';  -- Global package name
--
-- The first two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_absence_attendance_type_id  number         default null;
g_language                    varchar2(4)    default null;
g_business_group_id           number(15);    -- For validating translation;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_absence_attendance_type_id           in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , per_absence_attendance_types abb
     where abb.absence_attendance_type_id = p_absence_attendance_type_id
       and pbg.business_group_id (+) = abb.business_group_id;
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
    ,p_argument           => 'absence_attendance_type_id'
    ,p_argument_value     => p_absence_attendance_type_id
    );
  --
  --
  if (( nvl(per_abt_bus.g_absence_attendance_type_id, hr_api.g_number)
       = p_absence_attendance_type_id)
  and ( nvl(per_abt_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_abt_bus.g_legislation_code;
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
    per_abt_bus.g_absence_attendance_type_id  := p_absence_attendance_type_id;
    per_abt_bus.g_language                    := p_language;
    per_abt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_abt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_abt_shd.api_updating
      (p_absence_attendance_type_id        => p_rec.absence_attendance_type_id
      ,p_language                          => p_rec.language
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
-- |---------------------------< chk_name >------------------------------------|
-- ----------------------------------------------------------------------------
-- Developer Implementation Notes:
-- Similar validation is performed in validate_translation, called only by the form
-- Any changes will need to be maintinaed in both places.
--
Procedure chk_name
   (p_rec                         in per_abt_shd.g_rec_type
   ,p_absence_attendance_type_id  in number
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_dummy number;
--
-- Use p_absence_attendance_type_id in this check since this variable is always set
-- p_rec value for the id is not set on insert
--
cursor csr_chk_unique_name is
  select 1
  from per_absence_attendance_types abb, per_abs_attendance_types_tl abt
  where abt.absence_attendance_type_id <> p_absence_attendance_type_id
  and   abt.language = p_rec.language
  and   abt.name = p_rec.name
  and   abb.absence_attendance_type_id = abt.absence_attendance_type_id
  and  (abb.business_group_id is null
        or (abb.business_group_id is not null and abb.business_group_id in
             (select nvl(x.business_group_id,abb.business_group_id)
              from   per_absence_attendance_types x
              where  x.absence_attendance_type_id = p_absence_attendance_type_id)));
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  hr_utility.set_location('Entering:'||to_char(p_absence_attendance_type_id),11);
  --
  -- Use p_rec.absence_attendance_type_id in this check since this is null on insert
  -- p_absence_attendance_type_id is not null and causes error.
  --
  l_api_updating := per_abt_shd.api_updating
                    (p_absence_attendance_type_id => p_rec.absence_attendance_type_id
                    ,p_language                   => p_rec.language );
  --
    if ((l_api_updating and
        per_abt_shd.g_old_rec.name <> p_rec.name) or
        (not l_api_updating)) then
       open csr_chk_unique_name;
       fetch csr_chk_unique_name into l_dummy;
       if csr_chk_unique_name%found then
          close csr_chk_unique_name;
          fnd_message.set_name('PER','HR_7806_DEF_ABS_EXISTS');
          fnd_message.raise_error;
       else
          close csr_chk_unique_name;
       end if;
    end if;
  hr_utility.set_location('Leaving:'||l_proc,70);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
          (p_associated_column1 => 'PER_ABS_ATTENDANCE_TYPES_TL.NAME'
           ) then
        hr_utility.set_location('Leaving:'||l_proc,80);
        raise;
    end if;
  hr_utility.set_location('Leaving:'||l_proc,90);
End chk_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_delete >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
   (p_absence_attendance_type_id  in number
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- No additional validation required
  --
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_abt_shd.g_rec_type
  ,p_absence_attendance_type_id   in number
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Validate Dependent Attributes
  --
  per_abt_bus.chk_name
    ( p_rec                    => p_rec
    , p_absence_attendance_type_id   =>  p_absence_attendance_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_abt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  per_abt_bus.chk_name
    ( p_rec                    => p_rec
    , p_absence_attendance_type_id   =>  p_rec.absence_attendance_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_abt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_abt_bus.chk_delete
    ( p_absence_attendance_type_id   =>  p_rec.absence_attendance_type_id );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_translation_globals >--------------------|
-- ----------------------------------------------------------------------------
-- Developer Implementation Notes:
--
Procedure set_translation_globals
  (p_business_group_id              in number
  ) IS
begin
   g_business_group_id := p_business_group_id;
end set_translation_globals;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_translation >------------------------|
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_absence_attendance_type_id     in number
  ,p_language                       in varchar2
  ,p_name                           in varchar2
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  l_dummy number;
  --
  cursor csr_chk_unique_name is
  select 1
  from per_absence_attendance_types abb, per_abs_attendance_types_tl abt
  where (p_absence_attendance_type_id is null
         or p_absence_attendance_type_id <> abt.absence_attendance_type_id)
  and   abt.language = p_language
  and   abt.name = p_name
  and   abb.absence_attendance_type_id = abt.absence_attendance_type_id
  and  (abb.business_group_id is null
        or (abb.business_group_id is not null
            and abb.business_group_id =
                nvl(per_abt_bus.g_business_group_id,abb.business_group_id)));
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_chk_unique_name;
  fetch csr_chk_unique_name into l_dummy;
  if csr_chk_unique_name%found then
     close csr_chk_unique_name;
     fnd_message.set_name('PER','HR_7806_DEF_ABS_EXISTS');
     fnd_message.raise_error;
  else
     close csr_chk_unique_name;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end validate_translation;
--
end per_abt_bus;

/
